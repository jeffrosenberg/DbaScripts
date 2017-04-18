--CREATE SCHEMA [YOSEMITE\jrosenberg] AUTHORIZATION dbo

--CREATE TABLE [YOSEMITE\jrosenberg].PLE (
--  Id int NOT NULL IDENTITY(1,1) PRIMARY KEY
--, CreateDate datetime NOT NULL DEFAULT GETDATE()
--, numa_node varchar(3)
--, ple_sec int
--)

--DROP TABLE [YOSEMITE\jrosenberg].PLE

WHILE 1=1
BEGIN
  INSERT INTO [YOSEMITE\jrosenberg].PLE (numa_node, ple_sec)
  SELECT numa_node = ISNULL(NULLIF(ple.instance_name, ''), 'ALL')
       , ple_sec = ple.cntr_value
  FROM sys.dm_os_performance_counters ple join sys.dm_os_performance_counters dnm
      on ple.instance_name = dnm.instance_name
      and ple.counter_name='Page life expectancy' -- PLE per NUMA node
      and dnm.counter_name='Database pages' -- buffer pool size (pages) per NUMA node
  WHERE ple.instance_name IS NULL OR ple.instance_name = ''

  WAITFOR DELAY '00:00:05'
END