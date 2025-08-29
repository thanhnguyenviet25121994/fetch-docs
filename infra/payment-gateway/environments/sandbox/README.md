```
# aws s3api create-bucket --bucket pg-tfstate-dev --region ap-southeast-1 --create-bucket-configuration LocationConstraint=ap-southeast-1

# aws s3api put-bucket-tagging --bucket pg-tfstate-dev --region ap-southeast-1 --tagging 'TagSet=[{Key=Env_ProjectB,Value=dev},{Key=Project_Name,Value=projectB}]'

# aws s3api put-bucket-versioning --bucket pg-tfstate-dev --versioning-configuration Status=Enabled --region ap-southeast-1

# aws s3api put-public-access-block \
    --bucket pg-tfstate-dev \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
    --region ap-southeast-1

# aws dynamodb create-table \
    --table-name pg-terraform-state-lock-dev \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --tags Key=Name,Value=pg-terraform-state-lock-dev Key=Env_ProjectB,Value=dev Key=Project_Name,Value=projectB \
    --region ap-southeast-1
```

