import json
import requests
import os
import boto3

batch_client = boto3.client('batch')

WEBHOOK_URL_RTP = "https://open.larksuite.com/open-apis/bot/v2/hook/868b1d58-2e50-4460-8e80-05d585b7af96"  
WEBHOOK_URL_CRAWL = "https://open.larksuite.com/open-apis/bot/v2/hook/d5072f01-ec9d-41f4-b202-cea92bbd1d38" 

TARGET_COMPUTE_ENVIRONMENTS = {
    "dev-logic-rtp": WEBHOOK_URL_RTP,
    "dev-logic-crawl": WEBHOOK_URL_CRAWL
}

def send_to_lark(message, webhook_url):
    """
    Send a message to Lark via the appropriate webhook URL.
    """
    if not webhook_url:
        print("No webhook URL provided for this compute environment. Skipping alert.")
        return

    lark_message = {
        "msg_type": "text",
        "content": {
            "text": message
        }
    }

    try:
        response = requests.post(
            webhook_url,
            data=json.dumps(lark_message),
            headers={"Content-Type": "application/json"}
        )
        response.raise_for_status()
        print("Alert sent to Lark successfully.")
    except requests.exceptions.RequestException as e:
        print(f"Error sending alert to Lark: {e}")

def get_compute_environment_name_from_job_queue_arn(job_queue_arn):
    """
    Fetch the compute environment name associated with a given AWS Batch Job Queue ARN.
    """
    try:
        response = batch_client.describe_job_queues(jobQueues=[job_queue_arn])
        job_queues = response.get('jobQueues', [])

        if not job_queues:
            print(f"No job queue found with ARN: {job_queue_arn}")
            return None

        compute_environments = job_queues[0].get('computeEnvironmentOrder', [])

        if not compute_environments:
            print(f"No Compute Environment found for Job Queue: {job_queue_arn}")
            return None

        return compute_environments[0]['computeEnvironment'].split("/")[-1]

    except Exception as e:
        print(f"Error retrieving compute environment for Job Queue {job_queue_arn}: {e}")
        return None

def lambda_handler(event, context):
    """
    AWS Lambda function to process AWS Batch job state change events.
    """
    try:
        print("Received Event:", json.dumps(event, indent=2))

        detail = event.get('detail', {})
        job_name = detail.get('jobName', 'Unknown')
        job_id = detail.get('jobId', 'Unknown')
        status = detail.get('status', 'Unknown')
        job_queue_arn = detail.get('jobQueue', 'Unknown')
        reason = detail.get('statusReason', 'No reason provided.')

        if status == 'FAILED':
            compute_env = get_compute_environment_name_from_job_queue_arn(job_queue_arn)

            if compute_env in TARGET_COMPUTE_ENVIRONMENTS:
                webhook_url = TARGET_COMPUTE_ENVIRONMENTS[compute_env]
                alert_message = (
                    f"AWS Batch Job Failed!\n"
                    f"Compute Environment: {compute_env}\n"
                    f"Job Name: {job_name}\n"
                    f"Job ID: {job_id}\n"
                    f"Reason: {reason}"
                )
                send_to_lark(alert_message, webhook_url)
            else:
                print(f"Job failed in an unmonitored environment: {compute_env}. No alert sent.")

        else:
            print("Job is not in a FAILED state. No alert sent.")

    except Exception as e:
        print(f"Error processing event: {e}")

    return {
        "statusCode": 200,
        "body": json.dumps("Lambda executed successfully!")
    }
