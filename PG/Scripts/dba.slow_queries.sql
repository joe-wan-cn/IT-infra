

# See the 10 slowest queries with over a 1000 calls
SELECT query, calls, (total_time/calls)::integer AS avg_time_ms 
FROM pg_stat_statements
WHERE calls > 1000
ORDER BY avg_time_ms DESC
LIMIT 10;

#  query     |  calls  | avg_time_ms
#  ----------+---------+-------------
#  INSERT .. |   52323 |          12
#  SELECT .. |  116948 |          10
#  INSERT .. |  116948 |           4
#  SELECT .. |  116948 |           4
#  INSERT .. |  116948 |           3
#  SELECT .. |  116948 |           1
#  UPDATE .. |  116949 |           1
#  SELECT .. |  116947 |           1
#  DELETE .. |  116946 |           1
#  SELECT .. |    1465 |           1
#  (10 rows)


# See the 10 slowest SELECT queries with over a 1000 calls
SELECT query, calls, (total_time/calls)::integer AS avg_time_ms 
FROM pg_stat_statements
WHERE calls > 1000
AND query iLIKE '%SELECT%'
ORDER BY avg_time_ms DESC
LIMIT 10;

#  query     |  calls  | avg_time_ms
#  ----------+---------+-------------
#  SELECT .. |   52323 |          12
#  SELECT .. |  116948 |          10
#  SELECT .. |  116948 |           4
#  SELECT .. |  116948 |           4
#  SELECT .. |  116948 |           3
#  SELECT .. |  116948 |           1
#  SELECT .. |  116949 |           1
#  SELECT .. |  116947 |           1
#  SELECT .. |  116946 |           1
#  SELECT .. |    1465 |           1
#  (10 rows)


------ What are the slowest queries running right now sorted by running time
# See the slowest queries right now

SELECT
      pid,
      age(clock_timestamp(), query_start) as time_running,
      substr(query, 0, 75)
FROM pg_stat_activity WHERE state != 'idle'
ORDER BY time_running DESC;

#   pid  |  time_running   | query
#   123  |   00:00:29      | SELECT users WHERE email ILIKE '%dba%';


------- Which SELECT queries have read/touched the greatest number of rows

# See the 10 SELECT queries which touch the most number of rows.
# These queries may benefit from adding indexes to reduce the number
# of rows retrieved/affected.
SELECT
  rows, # rows is the number of rows retrieved/affected by the query
  query
FROM pg_stat_statements
WHERE query iLIKE '%SELECT%'
ORDER BY rows DESC
LIMIT 10;

#  query   |  rows 
#  --------+--------
#  SELECT  |  701724
#  SELECT  |  284772
#  SELECT  |  233914
#  SELECT  |  196424
#  SELECT  |  164421
#  SELECT  |  164419
#  SELECT  |  164419
#  SELECT  |  164419
#  SELECT  |  138395
#  SELECT  |  117636
#  (10 rows)





------- How many queries have been running for longer than a minute?

SELECT count(*) 
FROM pg_stat_activity 
WHERE state != 'idle' 
AND query_start < (NOW() - INTERVAL '60 seconds');



------- How long have the oldest queries been running?
SELECT application_name, 
       pid, 
       state,
       age(clock_timestamp(), query_start), /* How long has the query has been running in h:m:s */
       usename, 
       query /* The query text */
FROM pg_stat_activity
WHERE state != 'idle'
AND query NOT ILIKE '%pg_stat_activity%'
ORDER BY query_start asc;



---------  How many queries are currently writing to the same table?


SELECT * FROM pg_stat_activity
WHERE state != 'idle'
AND query NOT ILIKE '%SELECT%'
AND query ILIKE '%some_big_table%'
AND query NOT ILIKE '%pg_stat_activity%';












