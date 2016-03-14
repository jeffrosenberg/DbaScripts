-- DMV queries sent over by the Hyatt team DBA for troubleshooting performance issues
-- I added applies to get select text

SELECT stat.total_physical_reads
, (stat.total_physical_reads/stat.execution_count) "physical reads per exec"
, stat.execution_count, stat.total_elapsed_time, stat.max_elapsed_time 
, select_text = SUBSTRING(text.text, CHARINDEX('select', text.text),9999999)
FROM sys.dm_exec_query_stats AS stat
OUTER APPLY sys.dm_exec_sql_text(sql_handle) AS text
WHERE execution_count > 100 
ORDER by total_physical_reads desc
 
SELECT stat.total_physical_reads,stat.execution_count,stat.total_elapsed_time
, stat.max_elapsed_time,((stat.total_elapsed_time/stat.execution_count)*.000001) "Time per execution"
, select_text = SUBSTRING(text.text, CHARINDEX('select', text.text),9999999)
FROM sys.dm_exec_query_stats AS stat
OUTER APPLY sys.dm_exec_sql_text(sql_handle) AS text
WHERE ((total_elapsed_time/execution_count)*.000001) > 0.4 
ORDER by "Time per execution" desc
 
SELECT stat.total_logical_reads,(stat.total_logical_reads/stat.execution_count) "logical reads per exec"
, stat.execution_count, stat.total_elapsed_time, stat.max_elapsed_time
, ((stat.total_elapsed_time/stat.execution_count)*.000001) "Time per execution"  
, select_text = SUBSTRING(text.text, CHARINDEX('select', text.text),9999999)
FROM sys.dm_exec_query_stats AS stat
OUTER APPLY sys.dm_exec_sql_text(sql_handle) AS text
WHERE ((total_elapsed_time/execution_count)*.000001)> 1 
ORDER by "Time per execution" desc
 