/* ============================= Lazy writes / sec ==================================
via: http://www.sqlshack.com/sql-server-memory-performance-metrics-part-5-understanding-lazy-writes-free-list-stallssec-memory-grants-pending/

"For performance reasons, the Database Engine performs modifications to database 
pages in memory—in the buffer cache—and does not write these pages to disk after every 
change. Rather, the Database Engine periodically issues a checkpoint on each database. 
A checkpoint writes the current in-memory modified pages (known as dirty pages) and 
transaction log information from memory to disk and, also, records information about 
the transaction log."[1]

The lazy writer is a process that periodically checks the available free space in the 
buffer cache between two checkpoints and ensures that there is always enough free memory. 
When the lazy writer determines free pages are needed in the buffer for better 
performance, it removes the old pages before the regular checkpoint occurs.

If a dirty data page (a page read and/or modified) in the buffer hasn’t been used for 
a while, the lazy writer flushes it to disk and then marks as free in the buffer cache.

If SQL Server needs more memory then currently used and the buffer cache size is below 
the value set as the Maximum server memory parameter for the SQL Server instance, 
the lazy writer will take more memory. On the other hand, the lazy writer will release 
free buffer memory to the operating system in case there’s insufficient memory for 
Windows operations.

The Lazy writes metric is defined as "Number of times per second SQL Server relocates 
dirty pages from buffer pool (memory) to disk" [2]

The threshold value for Lazy Writes is 20. If SQL Server is under memory pressure, 
the lazy writer will be busy trying to free enough internal memory pages and will be 
flushing the pages extensively. The intensive lazy writer activity can cause a system 
bottleneck, as it affects other resources by causing additional physical disk I/O activity 
and using more CPU resources.
--===================================================================================*/
DECLARE @LazyWrites1 bigint;
SELECT @LazyWrites1 = cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Lazy writes/sec';
 
WAITFOR DELAY '00:00:10';
 
SELECT(cntr_value - @LazyWrites1) / 10 AS 'LazyWrites/sec'
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Lazy writes/sec';