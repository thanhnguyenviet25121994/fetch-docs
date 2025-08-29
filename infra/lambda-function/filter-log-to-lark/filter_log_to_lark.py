import gzip
import json
import base64
import os
import urllib.request
from typing import Dict, List

# Configuration
LARK_WEBHOOK_URLS = {
    'default': os.environ.get("PROD_LARK_WEBHOOK_URL"),
    'operator': os.environ.get("PROD_OPERATOR_LARK_WEBHOOK_URL"),
    'bigwin': os.environ.get("PROD_BIGWIN_LARK_WEBHOOK_URL")
}

# Exclusion patterns for error filtering
EXCLUSION_PATTERNS = [
    "Error during WebSocket session",
    "amazing-circus",
    "vs20wildparty",
    "com.revenge.game.api.PlayServiceV2",
    "Unable to decode data",
    "INVALID_GAME_CODE",
    "Bet history for",
    "Encountered unregistered class",
    "Exception occured. Channel",
    "brandCode=demo",
    '"brandCode": "demo"',
    '"brandCode":"demo"',
    '"brandCode":"cldemo"',
    '"brandCode":"hsdemo"',
    '"brandCode":"pgsdemo"'
]

GAME_CODE_EXCLUSIONS = [
    "pandora", "sanguo", "mahjong-fortune", "bikini-babes",
    "Treasure mermaid", "run-pug-run", "mochi-mochi", "rave-on",
    "samba-fiesta", "stallion-gold", "sexy-christmas", "gates-of-kunlun"
]

def send_to_lark(webhook_url: str, message: str) -> None:
    """Send a message to Lark using an incoming webhook."""
    payload = json.dumps({
        "msg_type": "text",
        "content": {
            "text": message
        }
    }).encode('utf-8')
    
    req = urllib.request.Request(
        webhook_url,
        data=payload,
        headers={'Content-Type': 'application/json'}
    )
    
    try:
        with urllib.request.urlopen(req) as response:
            response.read() 
    except urllib.error.URLError as e:
        print(f"Failed to send message to Lark: {e}")

def should_process_error(log_message: str) -> bool:
    """Determine if an error message should be processed."""
    if "BIGWIN: oc: demo" in log_message or "BIGWIN: oc: cldemo" in log_message or "BIGWIN: oc: hsdemo" in log_message or "BIGWIN: oc: pgsdemo" in log_message:
        return False

    if "ERROR" not in log_message:
        return False
        
    for pattern in EXCLUSION_PATTERNS:
        if pattern in log_message:
            return False
            
    for game_code in GAME_CODE_EXCLUSIONS:
        if f'"gameCode":"{game_code}"' in log_message:
            return False
            
    return True

def determine_webhook(log_message: str) -> str:
    """Determine which webhook URL to use based on message content."""
    if "BIGWIN" in log_message:
        if "oc: demo" not in log_message and "oc: cldemo" not in log_message and "oc: hsdemo" not in log_message and "oc: pgsdemo" not in log_message:
            return LARK_WEBHOOK_URLS['bigwin']
    elif ("OPERATOR_RESPONSE_FORMAT_ERROR" in log_message or 
          "Error processing payout" in log_message):
        return LARK_WEBHOOK_URLS['operator']
    return LARK_WEBHOOK_URLS['default']

def process_log_event(log_event: Dict, log_group: str) -> None:
    """Process a single log event and send notifications if needed."""
    log_message = log_event['message']
    
    if should_process_error(log_message):
        webhook_url = determine_webhook(log_message)
        notification_msg = f"ERROR log found - {log_group}:\n{log_message}"
        send_to_lark(webhook_url, notification_msg)

def lambda_handler(event: Dict, context: object) -> None:
    """AWS Lambda handler for processing CloudWatch logs."""
    try:
        
        compressed_data = base64.b64decode(event['awslogs']['data'])
        decompressed_data = gzip.decompress(compressed_data)
        log_data = json.loads(decompressed_data)
        
        
        for log_event in log_data['logEvents']:
            process_log_event(log_event, log_data['logGroup'])
            
    except Exception as e:
        print(f"Error processing log event: {e}")
        raise  