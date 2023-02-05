Is there Enough Shared Buffer Cache?
Postgres caches recent queries in memory called the shared buffer cache (shared_buffers in postgresql.conf).
The pg_statio_user_tables has as rows representing various stats on each of the (user) tables.
The two columns of interest we’ll be looking at are:

pg_statio_user_tables.heap_blks_read — Number of disk blocks read from a table (ie. missed cache)
pg_statio_user_tables.heap_blks_hits — Number of buffer hits from this table (ie. cache hit)


-- we can determine the cache hit ratio of a table by:
SELECT 
  (heap_blks_hit::decimal / (heap_blks_hit + heap_blks_read)) as cache_hit_ratio
FROM 
  pg_statio_user_tables
WHERE relname = 'large_table';


--  determine the average cache hit ratio across all tables:
SELECT 
  SUM(heap_blks_hit) / (SUM(heap_blks_hit) + SUM(heap_blks_read)) as cache_hit_ratio
FROM 
  pg_statio_user_tables;


--  determine the cache hit ratio for a given index or across all indexes
# See Cache Hit Ratio for a given index
SELECT 
  (heap_blks_hit::decimal / (heap_blks_hit + heap_blks_read)) as cache_hit_ratio
FROM 
  pg_statio_user_indexes
WHERE indexrelname = 'some_high_use_index';

# See overall Cache Hit Ratio across all indexes
SELECT 
  sum(idx_blks_hit)/(sum(idx_blks_read) + sum(idx_blks_hit)) as cache_hit_ratio
FROM 
  pg_statio_user_indexes;
  
  ---------------------- note -------------
  A cache hit ratio of 99% is considered “well-engineered”. 
  If it’s significantly less than that, 
  we will need to increase the shared buffer cache (which ranges from 15% to 25% of the total system memory).
  
  
  SHOW SHARED_BUFFERS;

#  shared_buffers
# ----------------
#  128MB
#  (1 row)
  
  
  
