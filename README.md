This repository contains Database engineering scripts for various tasks

- alter tables to utf8mb4 format to accept universal coded character sets
	
	The DB infra is using an older latin1 character set.  This causes
	data to be rejected.  This fixes the issue by altering tables 
	to the new utf8 character set.  This is done online with no impact
	to the tables access.  It uses Percona online schema change. 

- downlaod RDS logs; general, slow query or error logs.

- proxySQL managements scripts
	
	It aquires the source/target prod database users and their 
	passwords.  Then sets up these users by populating the 
	proxySQL SQLite3.  This is required for authentication 
	in the proxySQL DB that makes connections on port 6033
	In addtion it will update any user password changes.

	
