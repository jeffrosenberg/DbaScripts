--===================================================================================
--Source: http://blogs.msdn.com/b/carlnol/archive/2011/11/23/sql-server-query-performance-analysis-using-dmvs.aspx
--===================================================================================

SELECT TOP 100
    total_logical_reads/execution_count AS avg_logical_reads,
    total_logical_writes/execution_count AS avg_logical_writes,
    total_worker_time/execution_count AS avg_cpu_cost, execution_count,
    total_worker_time, total_logical_reads, total_logical_writes, 
    (SELECT DB_NAME(dbid) + ISNULL('..' + OBJECT_NAME(objectid), '')
        FROM sys.dm_exec_sql_text([sql_handle])) AS query_database,
    (SELECT SUBSTRING(est.[text], statement_start_offset/2 + 1,
        (CASE WHEN statement_end_offset = -1
            THEN LEN(CONVERT(nvarchar(max), est.[text])) * 2
            ELSE statement_end_offset
            END - statement_start_offset
        ) / 2)
        FROM sys.dm_exec_sql_text(sql_handle) AS est) AS query_text,
    last_logical_reads, min_logical_reads, max_logical_reads,
    last_logical_writes, min_logical_writes, max_logical_writes,
    total_physical_reads, last_physical_reads, min_physical_reads, max_physical_reads,
    (total_logical_reads + (total_logical_writes * 5))/execution_count AS io_weighting,
    plan_generation_num, qp.query_plan
FROM sys.dm_exec_query_stats
    OUTER APPLY sys.dm_exec_query_plan([plan_handle]) AS qp
WHERE [dbid] >= 5 AND DB_NAME(dbid) IS NOT NULL
  and (total_worker_time/execution_count) > 100
  AND last_execution_time >= DATEADD(day, DATEDIFF(day, 0, GETDATE()) - 1, 0) --Last executed yesterday or sooner
--ORDER BY io_weighting DESC;
--ORDER BY total_logical_reads DESC;
ORDER BY total_physical_reads DESC;
--ORDER BY avg_logical_reads DESC;
--ORDER BY avg_logical_writes DESC;
--ORDER BY avg_cpu_cost DESC;
--ORDER BY execution_count DESC