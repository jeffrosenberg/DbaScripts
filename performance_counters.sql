DECLARE @TargetDatabase AS sysname ='Amtrak' --Set to NULL to get all databases

SELECT pc.object_name, pc.counter_name, pc.instance_name, pc.cntr_value
, cntr_type = CASE pc.cntr_type --types via https://blogs.msdn.microsoft.com/psssql/2013/09/23/interpreting-the-counter-values-from-sys-dm_os_performance_counters/
                WHEN 1073939712 THEN'PERF_LARGE_RAW_BASE'
                WHEN 537003264  THEN'PERF_LARGE_RAW_FRACTION'
                WHEN 1073874176 THEN'PERF_AVERAGE_BULK'
                WHEN 272696576  THEN'PERF_COUNTER_BULK_COUNT'
                WHEN 65792      THEN'PERF_COUNTER_LARGE_RAWCOUNT'
                ELSE CAST(pc.cntr_type AS varchar(50))
                END
, type_desc = CASE pc.cntr_type --types via https://blogs.msdn.microsoft.com/psssql/2013/09/23/interpreting-the-counter-values-from-sys-dm_os_performance_counters/
                WHEN 1073939712 THEN'raw data that is used as the denominator of a counter that presents a instantaneous arithmetic fraction'
                WHEN 537003264  THEN'represents a fractional value as a ratio to its corresponding PERF_LARGE_RAW_BASE counter value'
                WHEN 1073874176 THEN'represents an average metric; the cntr_value is cumulative. The value is obtained by first taking two samples of both the PERF_AVERAGE_BULK value A1 and A2 as well as the  PERF_LARGE_RAW_BASE value B1 and B2.'
                WHEN 272696576  THEN'represents a rate metric; the cntr_value is cumulative. The value is obtained by taking two samples of the PERF_COUNTER_BULK_COUNT value. The difference between the sample values is divided by the time gap between the samples in seconds.'
                WHEN 65792      THEN'shows the last observed value directly'
                ELSE CAST(pc.cntr_type AS varchar(50))
                END
FROM sys.dm_os_performance_counters AS pc
LEFT OUTER JOIN sys.databases AS d
  ON d.name = pc.instance_name
WHERE (d.name = @TargetDatabase OR d.name IS NULL) --Exclude counters for other databases
AND pc.instance_name NOT IN ('internal') --Resource group
AND pc.object_name NOT IN ('SQLServer:Workload Group Stats')
--/*
AND pc.counter_name IN (
'Page life expectancy'
,'Page lookups/sec'
,'Page reads/sec'
,'Page writes/sec'
,''
,'Granted Workspace Memory (KB)'
,''
,'Used memory (KB)'
,'Target memory (KB)'
,'Max memory (KB)'
,'Disk Read IO/sec'
,'Disk Write IO/sec'
,'CPU usage %'
,'CPU usage % base'
)
--*/