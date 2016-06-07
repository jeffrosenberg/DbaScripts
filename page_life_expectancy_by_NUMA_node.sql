/*
Source: 
http://blog.sqlxdetails.com/page-life-expectancy-and-300-sec-limit/

Other resources:
https://www.sqlskills.com/blogs/jonathan/finding-what-queries-in-the-plan-cache-use-a-specific-index/
http://www.sqlskills.com/blogs/paul/page-life-expectancy-isnt-what-you-think/

From the article:

Jonathan [Kehayias] shows how 300 sec threshold is obsolete, and that it should be per every 4GB of RAM. 
That makes a big difference on current servers which have much more RAM than 4GB. 
I will split it down to the NUMA node level, because today’s servers not only have plenty of RAM, 
but also plenty of CPU’s which are grouped into NUMA nodes, and so is the memory divided into memory nodes.

That means the PLE limit is better calculated per memory node. If we calculate it globally, it might hide the 
fact that a single memory node falls way below the treshold, because other numas are in good standing, healthy. 
If we look only global PLE we will not notice that one numa node’s PLE is not ok.

The Formula

Jonathan’s formula for the PLE treshold to worry about is “(DataCacheSizeInGB/4GB)*300”. 
That means PLE of your system should normally be higher that that number. If you have 4GB of cached data, 
your treshold is 300 secs. If you have server with a lot of RAM, e.g. 40GB is cached, your PLE treshold should be 3 000 seconds. 
Basically, PLE should be 300 sec per every 4GB of data you have cached in the buffer pool.

This is the query of the PLE per NUMA node, normalized to 4GB, baked ready for you:
*/
SELECT numa_node = ISNULL(NULLIF(ple.instance_name, ''), 'ALL')
     , ple_sec = ple.cntr_value
     , db_node_mem_GB = dnm.cntr_value*8/1048576
     , ple_per_4gb = ple.cntr_value * 4194304 / (dnm.cntr_value*8) --Should be 300+
FROM sys.dm_os_performance_counters ple join sys.dm_os_performance_counters dnm
    on ple.instance_name = dnm.instance_name
    and ple.counter_name='Page life expectancy' -- PLE per NUMA node
    and dnm.counter_name='Database pages' -- buffer pool size (pages) per NUMA node