#!/bin/bash

date="$(date +%Y-%m-%d-%H-%M)"

# mysql -v -u radmin -pradmin -h 192.168.100.140 -P6032 < /users/lawrencekelly/Documents/proxy_test/EC-2/sql/tuner.sql 2>&1 | tee ProxySQL_performance_$date.txt
mysql -vv -u radmin -pradmin -h 192.168.100.140 -P6032 < tuner.sql > ProxySQL_performance_$date.txt 2>&1

sudo mv /var/lib/proxysql/proxsql_runtime_out.txt ~/proxsql_runtime_variables_out_$date.txt
