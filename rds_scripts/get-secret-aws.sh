echo "secret sandbox"
aws secretsmanager get-secret-value \
  --secret-id 'rds!cluster-cdc34abc-de42-4ccc-bb96-895a6192f3b0' \
  --region ap-northeast-1

echo "---------"
echo "---------"
echo "---------"

echo "secret dev"
aws secretsmanager get-secret-value \
  --secret-id 'rds!cluster-978bb354-4ff6-483a-8b8b-707d2281b7e6' \
  --region ap-southeast-1

echo "---------"
echo "---------"
echo "---------"

echo "secret asia prod"
aws secretsmanager get-secret-value \
  --secret-id 'rds!cluster-978bb354-4ff6-483a-8b8b-707d2281b7e6' \
  --region ap-southeast-1