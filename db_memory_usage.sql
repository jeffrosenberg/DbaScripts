select * from sys.dm_os_process_memory

/*
--OS memory usage
SELECT total_memory_gb = CAST(osm.total_physical_memory_kb / 1024.0 / 1024 AS decimal(7,2))
, available_memory_gb = CAST(osm.available_physical_memory_kb / 1024.0 / 1024 AS decimal(7,2))
, available_memory_pct = CAST((osm.available_physical_memory_kb*1.0) / osm.total_physical_memory_kb * 100.0 AS decimal(5,2))
, osm.system_memory_state_desc
FROM sys.dm_os_sys_memory AS osm
*/

--Buffer memory - via https://www.mssqltips.com/sqlservertip/2393/determine-sql-server-memory-use-by-database-and-object/
DECLARE @total_buffer INT;
SELECT @total_buffer = cntr_value
   FROM sys.dm_os_performance_counters 
   WHERE RTRIM([object_name]) LIKE '%Buffer Manager'
   AND counter_name = 'Database Pages';

;WITH src AS
(
   SELECT 
       database_id, db_buffer_pages = COUNT_BIG(*)
       FROM sys.dm_os_buffer_descriptors
       --WHERE database_id BETWEEN 5 AND 32766
       GROUP BY database_id
)
SELECT
   [db_name] = CASE [database_id] WHEN 32767 
       THEN 'Resource DB' 
       ELSE DB_NAME([database_id]) END,
   db_buffer_pages,
   db_buffer_MB = db_buffer_pages / 128,
   db_buffer_percent = CONVERT(DECIMAL(5,2), 
       db_buffer_pages * 100.0 / @total_buffer)
FROM src
ORDER BY db_buffer_MB DESC;