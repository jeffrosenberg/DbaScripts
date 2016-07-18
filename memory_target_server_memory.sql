/* ============================= Target server memory ================================
via: http://www.sqlshack.com/sql-server-memory-performance-metrics-part-2-available-bytes-total-server-target-server-memory/

When the Total Server Memory and Target Server Memory values are close, there’s no 
memory pressure on the server

In other words, the Total Server Memory/ Target Server Memory ratio should be close 
to 1. If the Total Server Memory value is significantly lower than the Target Server 
Memory value during normal SQL Server operation, it can mean that there’s memory 
pressure on the server so SQL Server cannot get as much memory as needed, or that 
the Maximum server memory option is set too low.
--===================================================================================*/

SELECT object_name ,counter_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Total Server Memory (KB)'

SELECT object_name ,counter_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Target Server Memory (KB)'

DECLARE @totalMemory AS decimal(10,2), @targetMemory AS decimal(10,2);

SELECT @totalMemory = cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Total Server Memory (KB)'

SELECT @targetMemory = cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Target Server Memory (KB)'

SELECT target_memory_pct = @targetMemory / @totalMemory