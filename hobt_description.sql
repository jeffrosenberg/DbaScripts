-- Get schema, table, and object names from hobt_id
-- for example, in the following output from dm_os_waiting_tasks:
-- keylock hobtid=72057594635157504 dbid=5 id=lock7d5be1580 mode=X associatedObjectId=72057594635157504

-- via: http://www.practicalsqldba.com/2012/04/sql-server-deciphering-wait-resource.html

SELECT 
  SCHEMA_NAME(o.schema_id) AS SchemaName
, o.name AS TableName
, i.name AS IndexName
FROM sys.partitions p JOIN sys.objects o ON p.OBJECT_ID = o.OBJECT_ID 
JOIN sys.indexes i ON p.OBJECT_ID = i.OBJECT_ID  AND p.index_id = i.index_id 
WHERE p.hobt_id = ?
