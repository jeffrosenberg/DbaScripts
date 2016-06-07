--===================================================================================
--Source: http://blogs.msdn.com/b/carlnol/archive/2011/11/23/sql-server-query-performance-analysis-using-dmvs.aspx
--===================================================================================

SELECT TOP 100
    total_worker_time, total_elapsed_time,
    total_worker_time/execution_count AS avg_cpu_cost, execution_count,
    (SELECT DB_NAME(dbid) + ISNULL('..' + OBJECT_NAME(objectid), '')
        FROM sys.dm_exec_sql_text([sql_handle])) AS query_database,
    (SELECT SUBSTRING(est.[text], statement_start_offset/2 + 1,
        (CASE WHEN statement_end_offset = -1
            THEN LEN(CONVERT(nvarchar(max), est.[text])) * 2
            ELSE statement_end_offset
            END - statement_start_offset) / 2
        )
        FROM sys.dm_exec_sql_text([sql_handle]) AS est) AS query_text,
    total_logical_reads/execution_count AS avg_logical_reads,
    total_logical_writes/execution_count AS avg_logical_writes,
    last_worker_time, min_worker_time, max_worker_time,
    last_elapsed_time, min_elapsed_time, max_elapsed_time,
    plan_generation_num, qp.query_plan
FROM sys.dm_exec_query_stats
    OUTER APPLY sys.dm_exec_query_plan([plan_handle]) AS qp
WHERE [dbid] >= 5 AND DB_NAME(dbid) IS NOT NULL
  AND (total_worker_time/execution_count) > 100
--ORDER BY avg_cpu_cost DESC;
--ORDER BY execution_count DESC;
ORDER BY total_worker_time DESC;