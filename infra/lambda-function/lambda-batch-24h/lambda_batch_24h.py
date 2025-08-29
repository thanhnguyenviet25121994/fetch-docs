import boto3
import json
import os
import requests

# Load configurations from environment variables
AWS_REGION = os.getenv('AWS_REGION', 'ap-southeast-1')
LARK_WEBHOOK_URL = os.getenv('LARK_WEBHOOK_URL')

# Initialize the AWS Batch client outside the function for better performance
batch_client = boto3.client('batch', region_name=AWS_REGION)

def send_to_lark(message):
    """
    Send a message to the Lark bot via webhook.
    """
    if not LARK_WEBHOOK_URL:
        print("❌ LARK_WEBHOOK_URL is not set. Skipping notification.")
        return
    
    payload = {
        "msg_type": "text",
        "content": {
            "text": message
        }
    }
    
    try:
        response = requests.post(
            LARK_WEBHOOK_URL, 
            data=json.dumps(payload), 
            headers={"Content-Type": "application/json"}
        )
        response.raise_for_status()
        print("✅ Message sent to Lark successfully!")
    except requests.exceptions.RequestException as e:
        print(f"❌ Failed to send message to Lark: {e}")

def get_running_jobs(job_queue_name):
    """
    Get all running jobs in the specified job queue.
    """
    running_jobs = []
    next_token = None

    while True:
        # Fetch running jobs in the queue
        response = batch_client.list_jobs(
            jobQueue=job_queue_name,
            jobStatus='RUNNING',
            nextToken=next_token
        )

        # Extract job details
        jobs = response.get('jobSummaryList', [])
        for job in jobs:
            running_jobs.append(f"🔹 Job ID: {job['jobId']}, Job Name: {job['jobName']}")

        # Handle pagination
        next_token = response.get('nextToken')
        if not next_token:
            break
    
    return running_jobs

def list_job_queues_with_running_jobs():
    """
    List all job queues with running jobs in AWS Batch.
    """
    try:
        # Retrieve all job queues
        job_queues_response = batch_client.describe_job_queues()
        job_queues = [queue['jobQueueName'] for queue in job_queues_response['jobQueues']]

        all_job_details = []  # Store all running job details

        for job_queue in job_queues:
            job_details = get_running_jobs(job_queue)
            if job_details:
                all_job_details.append(f"📌 Job Queue: {job_queue}")
                all_job_details.extend(job_details)

        # Send aggregated job details to Lark
        if all_job_details:
            message = "\n".join(all_job_details)
            send_to_lark(f"🚀 **AWS Batch Running Jobs**:\n{message}")
            print(f"🚀 AWS Batch Running Jobs:\n{message}")
        else:
            print("✅ No running jobs found in any job queues.")

    except Exception as e:
        print(f"❌ Error retrieving job queues with running jobs: {e}")

def lambda_handler(event, context):
    """
    AWS Lambda function handler.
    """
    print("🔄 Lambda function triggered.")
    list_job_queues_with_running_jobs()
    return {
        'statusCode': 200,
        'body': json.dumps("Lambda execution completed successfully!")
    }
