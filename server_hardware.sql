SELECT cpu_count AS [Logical CPU Count]
, hyperthread_ratio AS [Hyperthread Ratio]
, cpu_count/hyperthread_ratio AS [Physical CPU Count]
, physical_memory_kb/1024 AS [Physical Memory (MB)]
, affinity_type_desc
, sqlserver_start_time
, virtual_machine_type_desc --SQL Server 2012+ only
FROM sys.dm_os_sys_info OPTION (RECOMPILE);