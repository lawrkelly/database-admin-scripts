#!/bin/bash

# full backup of admin proxysql sqlite3 database

mkdir -p ~/backups

date="$(date +%Y-%m-%d-%H)"

sqlite3 /var/lib/proxysql/proxysql.db .dump > ~/backups/backup_proxysql_full_$date.sql

aws s3 cp ~/backups/backup_proxysql_full_$date.sql s3://qa-db-dump-nov-2020