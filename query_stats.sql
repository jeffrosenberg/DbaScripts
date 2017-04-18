SELECT TOP 50
  DB_NAME(COALESCE(dest.dbid, qp.dbid)) 
    + ISNULL('..' + OBJECT_NAME(COALESCE(dest.objectid, qp.objectid)), '') AS query_database,
  SUBSTRING(dest.[text], statement_start_offset/2 + 1,
    (CASE WHEN statement_end_offset = -1
        THEN LEN(CONVERT(nvarchar(max), dest.[text])) * 2
        ELSE statement_end_offset
        END - statement_start_offset
    ) / 2) AS query_text
, execution_count
, executions_per_minute = -- Via Brent Ozar sp_blitzCache
    CASE WHEN execution_count = 0 THEN 0
         WHEN COALESCE(DATEDIFF(mi, deqs.creation_time, deqs.last_execution_time), 0) = 0 THEN 0
         ELSE CAST((1.00 * execution_count / DATEDIFF(mi, deqs.creation_time, deqs.last_execution_time)) AS money)
         END
, plan_generation_num
, deqs.last_execution_time
, qp.query_plan
, total_rows/execution_count AS avg_rows, min_rows, max_rows
, total_elapsed_time, total_elapsed_time/execution_count AS avg_elapsed_time
, min_elapsed_time, max_elapsed_time
, total_logical_reads, total_logical_reads/execution_count AS avg_logical_reads
,   min_logical_reads, max_logical_reads
, total_logical_writes, total_logical_writes/execution_count AS avg_logical_writes
,   min_logical_writes, max_logical_writes
, (total_logical_reads + (total_logical_writes * 5))/execution_count AS io_weighting
, total_physical_reads, last_physical_reads, min_physical_reads, max_physical_reads
, total_worker_time, total_worker_time/execution_count AS avg_cpu_cost
--,  deqs.plan_handle, deqs.sql_handle, deqs.query_hash
FROM sys.dm_exec_query_stats AS deqs WITH(NOLOCK)
CROSS APPLY sys.dm_exec_query_plan([plan_handle]) AS qp
OUTER APPLY sys.dm_exec_sql_text([sql_handle]) AS dest
WHERE qp.dbid >= 5
  --AND last_execution_time >= DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0) --queries that have executed at least once today
  --AND (total_elapsed_time/execution_count) >= 1000 --1ms or longer average elapsed time
  --AND dest.[text] LIKE '%insert into darden.AccrualGroupContext%' --always use wildcards on both sides

-------------------------------------------------------------------------------
-- Use ORDER BY clause to manage what kind of query stats we're getting

ORDER BY total_logical_reads DESC
--ORDER BY deqs.total_worker_time DESC
--ORDER BY deqs.total_physical_reads DESC
--ORDER BY deqs.total_elapsed_time DESC
--ORDER BY avg_logical_reads DESC
--ORDER BY avg_cpu_cost DESC
--ORDER BY avg_logical_writes DESC
--ORDER BY deqs.execution_count DESC
--ORDER BY executions_per_minute DESC