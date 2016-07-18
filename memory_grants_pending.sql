/* ========================== Memory grants pending =================================
via: http://www.sqlshack.com/sql-server-memory-performance-metrics-part-5-understanding-lazy-writes-free-list-stallssec-memory-grants-pending/

Its value shows the total number of SQL Server processes that are waiting to be 
granted workspace in the memory.

The recommended Memory Grants Pending value is zero, meaning no processes are waiting 
for the memory, as there’s enough memory so the processes are not queued. If the value 
is constantly above 0, try with increasing the Maximum Server Memory value.
--===================================================================================*/
SELECT object_name, counter_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Memory Manager%'
AND [counter_name] = 'Memory Grants Pending'