#!/bin/bash

# captures the process session no. and kills it
# useful if the number of connections are too high
# change username for acess as necessary


mysql -sN -h 127.0.0.1 -P16033 -u lkelly givelify_stage1 -e "source kill_sess.sql" > kill_process.sql

mysql -sN -h 127.0.0.1 -P16033 -u lkelly givelify_stage1 -e "source kill_process.sql"

mysql -sN -h givelify-stage2-proxy1.cowdp1swpwvs.us-west-2.rds.amazonaws.com -u lkelly -e "source kill_sess.sql" > kill_process_p1.sql

mysql -sN -h givelify-stage2-proxy1.cowdp1swpwvs.us-west-2.rds.amazonaws.com -u lkelly -e "source kill_process_p1.sql"

mysql -sN -h givelify-stage2-proxy2.cowdp1swpwvs.us-west-2.rds.amazonaws.com -u lkelly -e "source kill_sess.sql" > kill_process_p2.sql

mysql -sN -h givelify-stage2-proxy2.cowdp1swpwvs.us-west-2.rds.amazonaws.com -u lkelly -e "source kill_process_p2.sql"

mysql -sN -h givelify-stage2-proxy3.cowdp1swpwvs.us-west-2.rds.amazonaws.com -u lkelly -e "source kill_sess.sql" > kill_process_p3.sql

mysql -sN -h givelify-stage2-proxy3.cowdp1swpwvs.us-west-2.rds.amazonaws.com -u lkelly -e "source kill_process_p3.sql"
