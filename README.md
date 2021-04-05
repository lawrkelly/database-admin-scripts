# Repo for Database Engineering 

## run_pt-osc_utf8mb4.sh

###### Alters specified table to utf8mb4 format to accept universal coded character sets
	
	The DB infra is using an older latin1 character set that causes
	data to be rejected.  The fix alters the table to the new utf8 (universal) 
	character set allowing global characters.  This is done online with no impact
	to tables access.  It uses Percona online schema change. 

## rds_log_downloader.py

######   Downlaods RDS logs; general, slow query or error logs.

## proxysql-scripts DIR

###### ProxySQL managements scripts
	
	get_users.sql
	-------------

	Aquires the source/target prod database users and 
	passwords.  Sets up these users by populating the 
	proxySQL SQLite3.  This is required for authentication 
	in the proxySQL DB that makes connections on port 6033
	In addtion it will update any user password changes.
	
	kill_sql_sessions.sh
	--------------------

	Kills ALL sql user sessions.  Useful if there are too many 
	connections.

	monitor_tuner.sh
	----------------

	Gives detailed performance info for the ProxySQL DB.

	backup_proxysql.sh
	------------------

	Backs up the SQLite3 ProxySQL DB using dump. This
	produces a SQL text file, useful for any
	SQL that needs to be run ad hoc as well.
	
