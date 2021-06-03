run_pt-osc_utf8mb4.sh#!/bin/bash

# runs pt-osc by taking some prompts that detail the host, DB, table and mode
# tested and runs on unicorn@ip-192-168-118-158

echo "select the host"
echo " 1)proxy3"
echo "  2)inst1"
read answ
echo "enter the DB"
read schema
echo "enter the table name"
read table
echo "dry run: y/n:"
read dry

if [ $answ = 1 ]; then
    host='leadedata-stage2-proxy3.cowdp1swpwvs.us-west-2.rds.amazonaws.com'
else
    host='leadedata-stage2-vpc-aurora-cluster.cluster-cowdp1swpwvs.us-west-2.rds.amazonaws.com'
fi

if [ $dry = y ]; then
    run='--dry-run'
else
    run='--exec'
fi

#echo $host echo $table echo $schema

date="$(date +%Y-%m-%d-%H-%M)" file="$table"_"$date"

mkdir -p ~/pt-osc-logs

date > ~/pt-osc-logs/"$file"_"mb4.log"

~/percona-toolkit-3.3.0/bin/pt-online-schema-change \
D=$schema,t=$table,h=$host,u=givdbman --ask-pass --alter=" CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci" \
--progress percentage,1 --alter-foreign-keys-method=rebuild_constraints --chunk-size 50000 $run 2>&1 | tee -a ~/pt-osc-logs/"$file"_"mb4.log"

date >> ~/pt-osc-logs/"$file"_"mb4.log"
