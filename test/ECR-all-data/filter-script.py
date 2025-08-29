import json
import csv
from datetime import datetime, timedelta
import boto3

# region = 'ap-southeast-1'  # singapore dev
# region = 'ap-northeast-1' # tokyo sb
# region = 'sa-east-1' # brazil prod
region = 'eu-west-1' # eu prod-eu

# Create the ECR client with region
ecr = boto3.client('ecr', region_name=region)

INPUT_FILE = 'EU'
OUTPUT_FILE = f'{INPUT_FILE}_old_images.csv'

def set_lifecycle_policy(repository_name):
    # Define the lifecycle policy
    policy = {
        "rules": [
            {
                "rulePriority": 1,
                "description": "Delete images older than 30 days",
                "selection": {
                    "tagStatus": "any",
                    "countType": "sinceImagePushed",
                    "countUnit": "days",
                    "countNumber": 30
                },
                "action": {
                    "type": "expire"
                }
            }
        ]
    }

    try:
        response = ecr.put_lifecycle_policy(
            repositoryName=repository_name,
            lifecyclePolicyText=json.dumps(policy)
        )
        print(f"This is the response remove image longer than 30 days: {response}")
        print("Lifecycle policy applied successfully.")
    except Exception as e:
        print(f"Error setting lifecycle policy: {e}")


def delete_repo(repository_name, force=True):
    try:
        response = ecr.delete_repository(
            repositoryName=repository_name,
            force=force  # Force deletes the repo even if it contains images
        )
        print(f"This is the response: {response}")
        print(f"Repository '{repository_name}' deleted.")
    except ecr.exceptions.RepositoryNotFoundException:
        print(f"Repository '{repository_name}' not found.")
    except Exception as e:
        print(f"Error deleting repository: {e}")


# Load input content
with open(INPUT_FILE, 'r') as file:
    content = file.read()

# Split JSON blocks
blocks = content.strip().split('----------------------------------------')

# Prepare CSV output
with open(OUTPUT_FILE, mode='w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    # Header: leave columns A and B empty, C-E used
    writer.writerow(["Repository Name", "Image Tag(s)", "Last push At"])

    # Set timezone-aware cutoff time (90 days ago)
    now = datetime.now().astimezone()
    cutoff = now - timedelta(days=90)
    n=0
    m=0
    for block in blocks:
        print("-----------------")
        print("-----------------")
        block = block.strip()
        if not block:
            continue
        try:
            data = json.loads(block)
            repo = data.get('repositoryName', 'N/A')
            #test
            repo='revengegames/service-marketing-2'
            #test
            pushed_at_str = data.get('imagePushedAt', '')
            image_tags = ", ".join(data.get('imageTags', []))
            # if repo.startswith("revengegames/logic"):
            # if "logic" in repo:
            if "service" in repo:
                print(f"Repository: {repo}")
                print(f"Image Pushed At: {pushed_at_str}")
                # delete_repo(repo)
                set_lifecycle_policy(repo)
                m=m+1
            

            # Parse imagePushedAt as timezone-aware datetime
#             try:
#                 pushed_at = datetime.fromisoformat(pushed_at_str.replace("Z", "+00:00"))
#             except ValueError:
#                 print("Invalid date format, skipping.")
#                 continue
#             now = datetime.now().astimezone()
#             cutoff = now - timedelta(days=90)
#             if pushed_at <= cutoff:
#                 print("The latest image was pushed more than 90 days ago, add this repo to CSV file.")
#                 writer.writerow([repo, image_tags, pushed_at_str])
#             else:
#                 print("Skip.")
        
        except json.JSONDecodeError as e:
            print("Skipping invalid JSON block:", e)
        n=n+1
        #test
        break
        #test
    
print(f"number of all item:{n}")
print(f"number of revengegames/logic:{m}")
# print(f"CSV file saved as: {OUTPUT_FILE}")
