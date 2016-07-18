SELECT TOP 100
  DB_NAME(COALESCE(dest.dbid, qp.dbid)) 
    + ISNULL('..' + OBJECT_NAME(COALESCE(dest.objectid, qp.objectid)), '') AS query_database,
  SUBSTRING(dest.[text], statement_start_offset/2 + 1,
    (CASE WHEN statement_end_offset = -1
        THEN LEN(CONVERT(nvarchar(max), dest.[text])) * 2
        ELSE statement_end_offset
        END - statement_start_offset
    ) / 2) AS query_text,
  execution_count, plan_generation_num, qp.query_plan,
  total_rows/execution_count AS avg_rows, min_rows, max_rows,
  total_elapsed_time, total_elapsed_time/execution_count AS avg_elapsed_time,
    min_elapsed_time, max_elapsed_time,
  total_logical_reads,  total_logical_reads/execution_count AS avg_logical_reads,
    min_logical_reads, max_logical_reads,
  total_logical_writes, total_logical_writes/execution_count AS avg_logical_writes,
    min_logical_writes, max_logical_writes,
  (total_logical_reads + (total_logical_writes * 5))/execution_count AS io_weighting,
  total_physical_reads, last_physical_reads, min_physical_reads, max_physical_reads,
  total_worker_time, total_worker_time/execution_count AS avg_cpu_cost
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_query_plan([plan_handle]) AS qp
OUTER APPLY sys.dm_exec_sql_text([sql_handle]) AS dest
WHERE qp.dbid >= 5
  AND (total_elapsed_time/execution_count) >= 1000 --1ms or longer average elapsed time
  AND last_execution_time >= DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0) --queries that have executed at least once today
  --AND dest.[text] LIKE '%%' --always use wildcards on both sides
--ORDER BY deqs.total_elapsed_time DESC
--ORDER BY deqs.total_physical_reads DESC
ORDER BY total_logical_reads DESC;
--ORDER BY avg_logical_reads DESC;
--ORDER BY avg_logical_writes DESC;
--ORDER BY avg_cpu_cost DESC;