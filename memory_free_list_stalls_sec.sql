/* ============================ Free List Stalls/sec =================================
via: http://www.sqlshack.com/sql-server-memory-performance-metrics-part-5-understanding-lazy-writes-free-list-stallssec-memory-grants-pending/

If there were no free pages in the buffer cache, a request is stalled and has to wait 
until a page in the buffer is freed

The recommended value is below 2. When the Free list stalls/sec value is higher than 
the recommended, check the Page Life Expectancy and Lazy Writes/sec values, as well. 
If the Page Life Expectancy value is below 300 seconds and Lazy Writes/sec above 2, 
it’s a clear sign of memory pressure
--===================================================================================*/
DECLARE @FreeListStalls1 bigint;
SELECT @FreeListStalls1 = cntr_value
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Free list stalls/sec';
 
WAITFOR DELAY '00:00:10';
 
SELECT(cntr_value - @FreeListStalls1) / 10 AS 'Free list stalls/sec'
FROM sys.dm_os_performance_counters
WHERE counter_name = 'Free list stalls/sec';