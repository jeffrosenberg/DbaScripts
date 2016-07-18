/* ============================= Paging file pct usage ================================
Based on: http://www.sqlshack.com/sql-server-memory-performance-metrics-part-6-memory-metrics/

Paging File % Usage indicates the amount of the paging file used by the operating system

Paging is a process that occurs on systems with insufficient. To provide enough memory 
for the running processes, it temporarily stores some of the memory pages into the paging 
file on disk. Next time a process needs this page, it will not be read from RAM, but from 
the page file on disk

When there’s no memory pressure on the system, every process has enough memory, pages 
are written into memory and flushed after the process is completed, freeing up the 
page for the forthcoming process.

A hard page fault is when the page is not in memory, but has to be loaded from a 
paging file on disk. This affects performance, as writing and reading a page from disk 
is several times slower than writing and reading from memory

A soft page fault is when a page is still in memory, but on another address, or is 
being used by another program. Soft page faults don’t affect performance.
--===================================================================================*/
SELECT total_page_file_kb
, available_page_file_kb
, used_page_file_kb = total_page_file_kb - available_page_file_kb
, pct_paging_file_usage = 100.0 - ((available_page_file_kb + 0.0) / total_page_file_kb) * 100
, total_physical_memory_kb
, paging_file_pct_of_memory = ((total_page_file_kb + 0.0) / total_physical_memory_kb) * 100
, system_memory_state_desc
FROM sys.dm_os_sys_memory