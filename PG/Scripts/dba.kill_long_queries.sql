Because the pg_stat_activity table shows queries that are running right now, we can use its pg_cancel_backend function to kill problematic queries.

For example, if pg_stat_activity reveals long-running queries clogging up your database, a hot fix can just be to kill those queries.

This will give a chance for the shorter queries to use the database. 

It’s better to have a few internal server errors caused by killing these queries, than to have the entire database unavailable.


/*
  Kill long-running read-only queries
*/
SELECT 
  application_name, 
  pg_cancel_backend(pid), /* returns boolean indicating whether or not query was killed */
  state, 
  age(clock_timestamp(), query_start), 
  usename, 
  query
FROM pg_stat_activity
WHERE state != 'idle' 
AND query ILIKE '%SELECT%' /* Safer to kill non-state-changing queries */
AND query_start < (NOW() - INTERVAL '300 seconds'); /* older than 5 minutes */

------------- example -------------------
/* You can also kill the query if you have the pid */
/* This will gracefully kill the query */
SELECT pg_cancel_backend(12345);

/* This will hard kill the query */
SELECT pg_terminate_backend(12345);

