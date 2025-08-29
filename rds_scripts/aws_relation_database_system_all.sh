#delete obsolete connections
bash delete_script.sh 

nohup bash rds_sandboxdb.sh &
nohup bash rds_singapore_dev.sh &
# nohup bash rds_prod_brl.sh &
# nohup bash rds_mkt_brl.sh &
# nohup bash rds_eu_west_1_mkt.sh &
# nohup bash rds_eu_west_1_prod.sh & 
nohup bash rds_prod_asia.sh & 
nohup bash rds_mkt_asia.sh & 
# nohup bash clickhouse.sh &