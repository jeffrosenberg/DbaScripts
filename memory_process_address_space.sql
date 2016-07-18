
-- SQL Server Process Address space info  (Query 6) (Process Memory)
-- (shows whether locked pages is enabled, among other things)
-- via: https://sqlserverperformance.wordpress.com/2010/10/08/sql-server-memory-related-queries/
SELECT physical_memory_in_use_kb/1024 AS [SQL Server Memory Usage (MB)],
       large_page_allocations_kb, locked_page_allocations_kb, page_fault_count, 
          memory_utilization_percentage, available_commit_limit_kb, 
          process_physical_memory_low, process_virtual_memory_low
FROM sys.dm_os_process_memory WITH (NOLOCK) OPTION (RECOMPILE);

-- You want to see 0 for process_physical_memory_low
-- You want to see 0 for process_virtual_memory_low
-- This indicates that you are not under internal memory pressure
