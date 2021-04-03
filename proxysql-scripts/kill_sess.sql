-- get session ids to kill sessions

Select concat('KILL ',id,';') from information_schema.processlist;
