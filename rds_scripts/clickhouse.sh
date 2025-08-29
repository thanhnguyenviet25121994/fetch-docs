aws ssm start-session \
            --region ap-southeast-1 \
            --target i-0a7f05a474d30f822 \
            --document-name AWS-StartPortForwardingSessionToRemoteHost \
            --parameters '{"host":["127.0.0.1"],"portNumber":["8123"],"localPortNumber":["8123"]}'
