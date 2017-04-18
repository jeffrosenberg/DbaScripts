-- Quickly get a basic profile of a server's workload
-- via Joe Sack, Common Query Tuning Problems and Solutions
-- https://app.pluralsight.com/library/courses/sql-server-common-query-tuning-problems-solutions-part2/exercise-files

-- SQL Server instance up time
SELECT sqlserver_start_time
FROM sys.dm_os_sys_info;

-- Trivial plan: No joins, obvious plan
-- Search 0 - Transaction Processing: Serial plan, low cost (<.2)
-- Search 1 - Quick Plan: Cost < 1.0
-- Search 2 - Full Optimization:  Parallelism considered, all rules evaluated
SELECT counter
     , occurrence
     , value
FROM sys.dm_exec_query_optimizer_info
WHERE counter IN ( 'trivial plan', 'search 0', 'search 1', 'search 2' );
