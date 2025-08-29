#/bin/bash!
kill -9 $(ps xua | grep rds | awk '{print$2}')

