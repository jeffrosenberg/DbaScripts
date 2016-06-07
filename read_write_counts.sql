/*----------------------------------------------------------------------------------------------------------
 * Based on updates/scans
 * via: https://technet.microsoft.com/en-us/library/dd894051%28v=sql.100%29.aspx?f=255&MSPPError=-2147217396
 *----------------------------------------------------------------------------------------------------------*/
 GO

SELECT [Schema_Name], Table_Name, Index_Name, Index_ID, Index_Type
, Reads = SUM(range_scan_count + singleton_lookup_count)
, Writes = SUM(leaf_insert_count + leaf_update_count)
, Deletes = SUM(leaf_delete_count + leaf_ghost_count)
--, Ghosts = SUM(leaf_ghost_count)
FROM
(
  SELECT s.name AS [Schema_Name], o.name AS [Table_Name], x.name AS [Index_Name],
         i.partition_number AS [Partition],
         i.index_id AS [Index_ID], x.type_desc AS [Index_Type],
         i.range_scan_count, i.singleton_lookup_count, i.leaf_insert_count,
         i.leaf_update_count, i.leaf_ghost_count, i.leaf_delete_count
  FROM sys.dm_db_index_operational_stats (db_id(), NULL, NULL, NULL) i
  JOIN sys.objects o ON o.object_id = i.object_id
  JOIN sys.schemas AS s ON s.schema_id = o.schema_id
  JOIN sys.indexes x ON x.object_id = i.object_id AND x.index_id = i.index_id
  WHERE (i.range_scan_count + i.leaf_insert_count
         + i.leaf_delete_count + leaf_update_count
         + i.leaf_page_merge_count + i.singleton_lookup_count) != 0
    AND objectproperty(i.object_id,'IsUserTable') = 1
    AND s.name = 'dbo'
) AS counts
GROUP BY [Schema_Name], Table_Name, Index_Name, Index_ID, Index_Type
ORDER BY Reads DESC  