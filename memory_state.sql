
SELECT total_physical_memory_mb = total_physical_memory_kb / 1024
, used_physical_memory_mb = (total_physical_memory_kb - available_physical_memory_kb) / 1024
, pct_memory_usage = CAST(100.0 - ((available_physical_memory_kb + 0.0) / total_physical_memory_kb) * 100 AS decimal(6,2))
, total_page_file_mb = total_page_file_kb / 1024
, used_page_file_mb = (total_page_file_kb - available_page_file_kb) / 1024
, pct_paging_file_usage = CAST(100.0 - ((available_page_file_kb + 0.0) / total_page_file_kb) * 100 AS decimal(6,2))
, paging_file_pct_of_memory = CAST(((total_page_file_kb + 0.0) / total_physical_memory_kb) * 100 AS decimal(6,2))
, memory_high = system_high_memory_signal_state
, memory_low = system_low_memory_signal_state
, memory_state_desc = system_memory_state_desc
FROM sys.dm_os_sys_memory