/* ============================= Page reads / sec ==================================
via: http://www.sqlshack.com/sql-server-memory-performance-metrics-part-2-available-bytes-total-server-target-server-memory/

“Page reads/sec indicates the number of physical database page reads that are issued 
per second. This statistic displays the total number of physical page reads across 
all databases. Because physical I/O is expensive, you may be able to minimize the 
cost, either by using a larger data cache, intelligent indexes, and more efficient 
queries, or by changing the database design.”[1]

In other words, this shows how many times the pages were read from disk, in a second. 
Please note that this is not the number of pages read from disk (which is the 
Pages input/sec metric described below). This is a server-level metric, the number 
indicates page reads for all databases on the instance.

The recommended Page reads/sec value should be under 90. Higher values indicate 
insufficient memory and indexing issues.
(Note from JR: this advice appears to be outdated)
--===================================================================================*/
DECLARE @PageReads1 bigint;
SELECT @PageReads1 = cntr_value
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Buffer Manager%'
AND [counter_name] = 'Page reads/sec'
 
WAITFOR DELAY '00:00:10';
 
SELECT(cntr_value - @PageReads1) / 10 AS 'Page Reads/sec'
FROM sys.dm_os_performance_counters
WHERE [object_name] LIKE '%Buffer Manager%'
AND [counter_name] = 'Page reads/sec'