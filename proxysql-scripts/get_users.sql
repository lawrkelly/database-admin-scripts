-- simple script to output users to a file

select user, authentication_string from mysql.user;
-- select user, authentication_string from mysql.user where user not like 'mysql.sys' or user not like 'proxy%';