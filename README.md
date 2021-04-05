This repository contains Database engineering scripts for various tasks

- alter tables to utf8mb4 format to accept universal coded character sets
	
	The database in our infra is set to an older latin1 character type

- downlaod RDS logs; general, slow query or error logs

- proxySQL managements scripts
	
	Set up users by populating the proxySQL SQLite3 DB with the
	production DB accounts.
	It aquires the source/target prod database users for the proxysql.
	This is required to autheticate users and theup to date passwords.
	If there is a password change in the target prod this will update
	the password also.


	
