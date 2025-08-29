import boto3
import re
import gzip
import os
import io
from datetime import datetime, timedelta
import json
import requests
import pytz

def get_time_range_paths(hours=6):
    """
    Generate list of date paths to check for the last N hours
    Returns tuples of (date_path, hour_prefix)
    """
    paths = []
    # Set timezone to UTC since ALB logs use UTC
    now = datetime.now(pytz.UTC)
    
    # Loop for each hour in the range
    for hour_offset in range(hours):
        time_point = now - timedelta(hours=hour_offset + 1)
        date_path = time_point.strftime("%Y/%m/%d")
        hour_prefix = time_point.strftime("%H")
        paths.append((date_path, hour_prefix))
    
    return paths

def percentile(data, p):
    """Calculate the pth percentile of the given data."""
    if not data:
        return None
    
    # Sort the data
    sorted_data = sorted(data)
    
    # Calculate the index
    k = (len(sorted_data) - 1) * (p / 100)
    
    # Get the integer and fractional parts
    f = int(k)
    c = k - f
    
    # Interpolate between the two nearest values
    if f + 1 < len(sorted_data):
        return sorted_data[f] + c * (sorted_data[f + 1] - sorted_data[f])
    else:
        return sorted_data[f]

def categorize_request(method, url):
    """
    Categorize requests into different types
    Returns: 'spin', 'authorize-game', 'history', or 'other'
    """
    spin_pattern = re.compile(r"/[^/]+/spin\b|/Spin\b|/api/play/bet\b")
    authorize_pattern = re.compile(r"/authorize-game")
    history_pattern = re.compile(r"/[^/]+/total-bets\b|/[^/]+/bets\b|/api/v[12]/bets\b|/api/v2/history\b")
    
    if method == 'POST' and spin_pattern.search(url):
        return 'spin'
    elif method == 'POST' and authorize_pattern.search(url):
        return 'authorize-game'
    elif method == 'GET' and history_pattern.search(url):
        return 'history'
    else:
        return 'other'

def process_log_files_streaming(bucket_name, prefix, region, hours=6):
    """Process ALB logs directly from S3 without downloading to disk"""
    s3 = boto3.client("s3", region_name=region)
    time_range_paths = get_time_range_paths(hours)
    
    # Separate collections for each request type
    request_data = {
        'spin': [],
        'authorize-game': [],
        'history': [],
        'other': []
    }
    
    request_counts = {
        'spin': 0,
        'authorize-game': 0,
        'history': 0,
        'other': 0
    }
    
    # Track max duration requests for each type
    max_duration_requests = {
        'spin': {'duration': 0, 'url': '', 'method': ''},
        'authorize-game': {'duration': 0, 'url': '', 'method': ''},
        'history': {'duration': 0, 'url': '', 'method': ''},
        'other': {'duration': 0, 'url': '', 'method': ''}
    }
    
    processed_files_count = 0
    
    for date_path, hour_prefix in time_range_paths:
        log_prefix = f"{prefix}AWSLogs/211125478834/elasticloadbalancing/{region}/{date_path}/"
        
        print(f"Searching for logs with prefix: {log_prefix} for hour: {hour_prefix}")
        
        paginator = s3.get_paginator('list_objects_v2')
        
        for page in paginator.paginate(Bucket=bucket_name, Prefix=log_prefix):
            if 'Contents' not in page:
                continue
            
            for obj in page['Contents']:
                key = obj['Key']
                # Filter by hour using the filename pattern which typically includes the hour
                if not key.endswith('.gz') or f"T{hour_prefix}" not in os.path.basename(key):
                    continue
                
                # Stream the file directly from S3
                try:
                    response = s3.get_object(Bucket=bucket_name, Key=key)
                    with gzip.GzipFile(fileobj=io.BytesIO(response['Body'].read())) as f:
                        content = f.read().decode('utf-8')
                        
                        for line_num, line in enumerate(content.splitlines(), 1):
                            # Skip empty lines
                            if not line.strip():
                                continue

                            parts = line.strip().split()
                            try:
                                method = parts[12].strip('"')
                                url = parts[13]
                                duration = parts[6]
                                
                                # Skip if duration is invalid
                                if float(duration) <= 0.01:
                                    continue
                                
                                # Categorize the request
                                request_type = categorize_request(method, url)
                                
                                # Store the processing time for the appropriate category
                                processing_time = float(duration)
                                request_data[request_type].append(processing_time)
                                request_counts[request_type] += 1
                                
                                # Track maximum duration request for each type
                                if processing_time > max_duration_requests[request_type]['duration']:
                                    max_duration_requests[request_type] = {
                                        'duration': processing_time,
                                        'url': url,
                                        'method': method
                                    }
                                
                            except (ValueError, IndexError) as e:
                                # Skip malformed lines
                                continue
                    
                    processed_files_count += 1
                except Exception as e:
                    print(f"Error processing file {key}: {str(e)}")
    
    print(f"Total processed files: {processed_files_count}")
    print(f"Total requests by type:")
    for req_type, count in request_counts.items():
        print(f"  {req_type}: {count}")
    
    return request_data, request_counts, max_duration_requests

def calculate_statistics(processing_times, request_count):
    """Calculate statistics for processing times"""
    if not processing_times or request_count == 0:
        return {
            "Count": 0,
            "Avg": 0,
            "Min": 0,
            "Max": 0,
            "P95": 0,
            "P99": 0
        }
    
    avg_time = sum(processing_times) / len(processing_times)
    min_time = min(processing_times)
    max_time = max(processing_times)
    p95 = percentile(processing_times, 95)
    p99 = percentile(processing_times, 99)
    
    return {
        "Count": request_count,
        "Avg": round(avg_time, 3),
        "Min": round(min_time, 3),
        "Max": round(max_time, 3),
        "P95": round(p95, 3),
        "P99": round(p99, 3)
    }

def calculate_all_statistics(request_data, request_counts):
    """Calculate statistics for all request types"""
    all_stats = {}
    
    for request_type in ['spin', 'authorize-game', 'history', 'other']:
        all_stats[request_type] = calculate_statistics(
            request_data[request_type], 
            request_counts[request_type]
        )
    
    return all_stats

def send_to_lark(all_statistics, max_duration_requests, time_range_str, region='sa-east-1'):
    """Send statistics to Lark bot"""
    webhook_url = "https://open.larksuite.com/open-apis/bot/v2/hook/17a41246-012c-4fe6-8a34-a6a5a8208699"
    
    # Format message for Lark with all request types and max duration URLs
    message = f"""📊 ALB Report for {time_range_str} region {region}

🎰 SPIN Requests:
Total: {all_statistics['spin']['Count']}
Avg: {all_statistics['spin']['Avg']}s | Min: {all_statistics['spin']['Min']}s | Max: {all_statistics['spin']['Max']}s
P95: {all_statistics['spin']['P95']}s | P99: {all_statistics['spin']['P99']}s
Max Duration URL: {max_duration_requests['spin']['method']} {max_duration_requests['spin']['url']} ({max_duration_requests['spin']['duration']}s)

🔐 AUTHORIZE-GAME Requests:
Total: {all_statistics['authorize-game']['Count']}
Avg: {all_statistics['authorize-game']['Avg']}s | Min: {all_statistics['authorize-game']['Min']}s | Max: {all_statistics['authorize-game']['Max']}s
P95: {all_statistics['authorize-game']['P95']}s | P99: {all_statistics['authorize-game']['P99']}s
Max Duration URL: {max_duration_requests['authorize-game']['method']} {max_duration_requests['authorize-game']['url']} ({max_duration_requests['authorize-game']['duration']}s)

📜 HISTORY Requests:
Total: {all_statistics['history']['Count']}
Avg: {all_statistics['history']['Avg']}s | Min: {all_statistics['history']['Min']}s | Max: {all_statistics['history']['Max']}s
P95: {all_statistics['history']['P95']}s | P99: {all_statistics['history']['P99']}s
Max Duration URL: {max_duration_requests['history']['method']} {max_duration_requests['history']['url']} ({max_duration_requests['history']['duration']}s)

🔧 OTHER Requests:
Total: {all_statistics['other']['Count']}
Avg: {all_statistics['other']['Avg']}s | Min: {all_statistics['other']['Min']}s | Max: {all_statistics['other']['Max']}s
P95: {all_statistics['other']['P95']}s | P99: {all_statistics['other']['P99']}s
Max Duration URL: {max_duration_requests['other']['method']} {max_duration_requests['other']['url']} ({max_duration_requests['other']['duration']}s)
"""
    
    payload = {
        "msg_type": "text",
        "content": {
            "text": message
        }
    }
    
    try:
        response = requests.post(webhook_url, json=payload)
        if response.status_code == 200:
            print(f"Successfully sent report to Lark bot")
        else:
            print(f"Failed to send to Lark bot. Status code: {response.status_code}, Response: {response.text}")
    except Exception as e:
        print(f"Error sending to Lark bot: {str(e)}")

def lambda_handler(event, context):
    # Get configuration from event parameter with fallbacks to environment variables
    bucket_name = event.get('LOG_BUCKET_NAME', os.environ.get('LOG_BUCKET_NAME', 'alb-revengegames-prod'))
    prefix = event.get('LOG_PREFIX', os.environ.get('LOG_PREFIX', 'access-logs/prod/'))
    region = event.get('AWS_REGION', os.environ.get('AWS_REGION', 'sa-east-1'))
    send_to_lark_bot = event.get('SEND_TO_LARK', os.environ.get('SEND_TO_LARK', 'false')).lower() == 'true'
    hours_to_analyze = int(event.get('HOURS_TO_ANALYZE', os.environ.get('HOURS_TO_ANALYZE', '6')))
    
    # Get current time in UTC
    now = datetime.now(pytz.UTC)
    time_range_str = f"Last {hours_to_analyze} hours (from {(now - timedelta(hours=hours_to_analyze)).strftime('%Y-%m-%d %H:%M UTC')} to {now.strftime('%Y-%m-%d %H:%M UTC')})"
    
    print(f"Analyzing logs for {time_range_str}")
    print(f"Configuration: bucket={bucket_name}, prefix={prefix}, region={region}, send_to_lark={send_to_lark_bot}, hours={hours_to_analyze}")
    
    try:
        # Process log files streaming directly from S3
        request_data, request_counts, max_duration_requests = process_log_files_streaming(bucket_name, prefix, region, hours=hours_to_analyze)
        
        total_requests = sum(request_counts.values())
        
        if total_requests == 0:
            empty_stats = {
                request_type: {
                    "Count": 0,
                    "Avg": 0,
                    "Min": 0,
                    "Max": 0,
                    "P95": 0,
                    "P99": 0
                } for request_type in ['spin', 'authorize-game', 'history', 'other']
            }
            
            empty_max_requests = {
                request_type: {'duration': 0, 'url': '', 'method': ''}
                for request_type in ['spin', 'authorize-game', 'history', 'other']
            }
            
            print(f"No matching requests found for {time_range_str}")
            print(f"Statistics: {json.dumps(empty_stats, indent=2)}")
            
            if send_to_lark_bot:
                send_to_lark(empty_stats, empty_max_requests, time_range_str, region)
                
            return {
                'statusCode': 200,
                'message': f'No matching requests found for {time_range_str}',
                'statistics': empty_stats,
                'maxDurationRequests': empty_max_requests
            }
        
        # Calculate statistics for all request types
        all_statistics = calculate_all_statistics(request_data, request_counts)
        
        # Print to stdout
        print(f"\nStatistics for {time_range_str}:")
        print("="*60)
        
        for request_type in ['spin', 'authorize-game', 'history', 'other']:
            stats = all_statistics[request_type]
            max_req = max_duration_requests[request_type]
            
            print(f"\n{request_type.upper()} Requests:")
            print(f"  Count: {stats['Count']}")
            if stats['Count'] > 0:
                print(f"  Avg: {stats['Avg']} seconds")
                print(f"  Min: {stats['Min']} seconds")
                print(f"  Max: {stats['Max']} seconds")
                print(f"  P95: {stats['P95']} seconds")
                print(f"  P99: {stats['P99']} seconds")
                print(f"  Max Duration URL: {max_req['method']} {max_req['url']} ({max_req['duration']}s)")
        
        # Send to Lark if configured
        if send_to_lark_bot:
            send_to_lark(all_statistics, max_duration_requests, time_range_str, region)
        
        return {
            'statusCode': 200,
            'timeRange': time_range_str,
            'statistics': all_statistics,
            'maxDurationRequests': max_duration_requests
        }
    
    except Exception as e:
        error_message = f"Error: {str(e)}"
        print(error_message)
        
        return {
            'statusCode': 500,
            'error': error_message
        }

def main():
    event = {
        'LOG_BUCKET_NAME': os.environ.get('LOG_BUCKET_NAME', 'alb-revengegames-prod'),
        'LOG_PREFIX': os.environ.get('LOG_PREFIX', 'access-logs/prod/'),
        'AWS_REGION': os.environ.get('AWS_REGION', 'sa-east-1'),
        'SEND_TO_LARK': os.environ.get('SEND_TO_LARK', 'false'),
        'HOURS_TO_ANALYZE': os.environ.get('HOURS_TO_ANALYZE', '1')
    }

    result = lambda_handler(event, None)
    print("Result:")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()