aws ecr describe-repositories --region ap-southeast-1 --output json | jq -r '.repositories[].repositoryName'  | \
while read repo; do
  aws ecr describe-images \
    --repository-name "$repo" \
    --query 'max_by(imageDetails, &imagePushedAt)' \
    --output json
  echo "----------------------------------------"
done