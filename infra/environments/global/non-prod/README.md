# readme
```aws s3api create-bucket --bucket revengegames-tfstate --region ap-southeast-1 --create-bucket-configuration LocationConstraint=ap-southeast-1```

```aws s3api put-bucket-tagging --bucket revengegames-tfstate --region ap-southeast-1 --tagging 'TagSet=[{Key=ProjectName,Value=RG}]'```

```aws s3api put-bucket-versioning --bucket revengegames-tfstate --versioning-configuration Status=Enabled --region ap-southeast-1```


```
aws s3api put-public-access-block \
    --bucket revengegames-tfstate \
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
    --region ap-southeast-1
```

```
aws dynamodb create-table \
    --table-name rg-tf-state-lock-global \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --tags Key=Name,Value=rg-tf-state-lock-global Key=Environment,Value=global Key=ProjectName,Value=RG \
    --region ap-southeast-1
```


