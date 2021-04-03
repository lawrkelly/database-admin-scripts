SELECT digest,SUBSTR(digest_text,0,25),count_star,sum_time FROM stats_mysql_query_digest WHERE digest_text LIKE 'SELECT%' ORDER BY sum_time DESC LIMIT 5;

SELECT digest,SUBSTR(digest_text,0,25),count_star,sum_time FROM stats_mysql_query_digest WHERE digest_text LIKE 'SELECT%' ORDER BY count_star DESC LIMIT 5;

SELECT digest,SUBSTR(digest_text,0,25),count_star,sum_time,sum_time/count_star avg_time, min_time, max_time FROM stats_mysql_query_digest WHERE digest_text LIKE 'SELECT%' ORDER BY max_time DESC LIMIT 5;

 SELECT digest,SUBSTR(digest_text,0,20),count_star,sum_time,sum_time/count_star avg_time, min_time, max_time FROM stats_mysql_query_digest WHERE digest_text LIKE 'SELECT%' AND min_time > 1000 ORDER BY sum_time DESC LIMIT 5;

SELECT digest,SUBSTR(digest_text,0,25),count_star,sum_time,sum_time/count_star avg_time, ROUND(sum_time*100.00/(SELECT SUM(sum_time) FROM stats_mysql_query_digest),3) pct FROM stats_mysql_query_digest WHERE digest_text LIKE 'SELECT%' AND sum_time/count_star > 1000000 ORDER BY sum_time DESC LIMIT 5;

SELECT digest,SUBSTR(digest_text,0,25),count_star,sum_time,sum_time/count_star avg_time, ROUND(sum_time*100.00/(SELECT SUM(sum_time) FROM stats_mysql_query_digest WHERE digest_text LIKE 'SELECT%'),3) pct FROM stats_mysql_query_digest WHERE digest_text LIKE 'SELECT%' AND sum_time/count_star > 15000 ORDER BY sum_time DESC LIMIT 5;


SELECT hostgroup, digest, digest_text, count_star FROM stats_mysql_query_digest LIMIT 10\G

SELECT hostgroup, digest, digest_text, count_star FROM stats_mysql_query_digest where digest_text not like '%INSERT%' LIMIT 10\G

SELECT hostgroup, digest, digest_text, count_star FROM stats_mysql_query_digest where digest_text like '%INSERT%' LIMIT 10\G

SELECT hits, mysql_query_rules.rule_id,digest,active,username, match_digest, match_pattern, replace_pattern, cache_ttl, apply FROM mysql_query_rules NATURAL JOIN stats.stats_mysql_query_rules ORDER BY mysql_query_rules.rule_id;

SELECT rule_id, destination_hostgroup ,proxy_port,username,destination_hostgroup,active,retries,match_digest,apply from runtime_mysql_query_rules;

SELECT hostgroup,count_star,sum_time,(sum_time/count_star)/1000 as average_time_ms,digest_text
from stats_mysql_query_digest
where count_star > 100 order by average_time_ms desc limit 10\G

SELECT * from stats_history.history_mysql_query_digest\G

SELECT * from stats_mysql_connection_pool;

SELECT * FROM stats.stats_memory_metrics;

SELECT hostgroup hg, srv_host, status, ConnUsed, ConnFree, ConnOK, ConnERR 
FROM stats_mysql_connection_pool WHERE ConnUsed+ConnFree > 0 ORDER BY hg, srv_host;

select "************************";

SELECT CONFIG INTO OUTFILE proxsql_runtime_out.txt;

