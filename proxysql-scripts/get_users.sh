#!/bin/bash

# script to populate the mysql_users table
# in the proxy server from the specified source DB server
# The IP address is just an example and needs to be changed
# to the proxysql address.  As well as the proxysql admin 
# account details
# 

echo "Enter the source DB server"
read host

echo "Enter user name with privs to query mysql.user table"
read user

mysql -N -u $user -h $host -e "source ~/get_users.sql" -p > users.txt

filename='users.txt'
n=1
while read line;
do
    # reading each line
    name=`echo $line |  awk {'print $1'}`
    passwd=`echo $line |  awk {'print $2'}`
    #echo $name
    #echo $passwd
    mysql -h 127.0.0.1 -P6032 -uradmin -pradmin -e "INSERT OR REPLACE INTO mysql_users VALUES('$name','$passwd',1,0,10,NULL,0,1,0,1,1,10000,'','');"
    # mysql -h 192.168.100.140 -P6032 -uradmin -pradmin -e "INSERT INTO mysql_users_bkp VALUES('$name','$passwd',1,0,20,NULL,0,1,0,1,1,10000,'') ON DUPLICATE KEY UPDATE password='$password';"

    n=$((n+1))
done < $filename

    mysql -h 127.0.0.1 -P6032 -uradmin -pradmin -e "source ~/load_variables.sql"
    