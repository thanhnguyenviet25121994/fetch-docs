import os
import json
import logging
import urllib3

http = urllib3.PoolManager()
webhook_url = os.getenv('WEBHOOK_URL')  # Ensure this points to your Lark webhook URL
chatops_url = os.getenv('CHATOPS_URL')  # Ensure this points to your Lark webhook URL

def get_arn_url(arn):
    """Generate a URL to AWS Console based on the provided ECS ARN."""
    arn_parts = arn.split(":")
    region = arn_parts[3]
    resource = arn_parts[5]
    
    cluster_name = "Unknow Cluster"
    
    if resource.startswith("service/"):
        _, cluster_name, service_name = resource.split("/")
        url = f"https://{region}.console.aws.amazon.com/ecs/v2/clusters/{cluster_name}/services/{service_name}/health?region={region}"
    elif resource.startswith("cluster/"):
        _, cluster_name = resource.split("/")
        url = f"https://{region}.console.aws.amazon.com/ecs/v2/clusters/{cluster_name}/services?region={region}"
    else:
        url = "Unsupported ARN format"
    return url,cluster_name

def lambda_handler(event, context):
    """Lambda function entry point for handling ECS deployment events."""
    detail = event.get('detail', {})
    deployment_id = detail.get('deploymentId')
    reason = detail.get('reason', 'No reason provided')
    region = event.get('region')
    resources = event.get('resources', [])
    event_name = detail.get('eventName', 'UNKNOWN')

    # Determine deployment action based on event type
    if event_name == "SERVICE_DEPLOYMENT_IN_PROGRESS":
        action = 'start'
    elif event_name == "SERVICE_DEPLOYMENT_COMPLETED":
        action = 'complete'
    else:
        action = 'failure'

    # Generate the ARN URL
    arn_url,cluster_name = get_arn_url(resources[0]) if resources else ("ARN not provided", "Unknown Cluster")
    service_name = resources[0].split('/')[-1] if resources else "Unknown Service"

    # Select appropriate emoji for the deployment status
    state_emoji = {
        "failure": "🆘",
        "complete": "✅",
        "start": "🔁"
    }.get(action, "❓")

    # Format the Lark message payload
    message = {
        "msg_type": "interactive",
        "card": {
            "config": {"wide_screen_mode": True},
            "header": {
                "title": {"tag": "plain_text", "content": f"ECS Deployment {action.capitalize()}"},
                "template": "blue" if action == "start" else "green" if action == "complete" else "red"
            },
            "elements": [
                {
                    "tag": "div",
                    "text": {
                        "tag": "lark_md",
                        "content": f"{state_emoji} **Service Name:** {service_name}\n"
                                   f"**Cluster Name:** {cluster_name}\n"
                                   f"**Status:** {reason}\n"
                                   f"[More details]({arn_url})"
                    }
                }
            ]
        }
    }

    print("---------Message---------")
    print(json.dumps(message, indent=4))

    # Send the message to the Lark webhook
    response = http.request(
        'POST',
        webhook_url,
        body=json.dumps(message),
        headers={'Content-Type': 'application/json'}
    )
    print(f"Response Status webhook: {response.status}")
    
    # response = http.request(
    #     'POST',
    #     chatops_url,
    #     body=json.dumps(message),
    #     headers={'Content-Type': 'application/json'}
    # )
    # print(f"Response Status chatops_url: {response.status}")

    return {
        'statusCode': response.status,
        'body': response.data.decode('utf-8')
    }
