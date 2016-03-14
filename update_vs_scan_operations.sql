/*----------------------------------------------------------------------------------------------------------
 * Object percent updates/scans
 * via: https://technet.microsoft.com/en-us/library/dd894051%28v=sql.100%29.aspx?f=255&MSPPError=-2147217396
 * Presented in the article as a method for researching whether to implement data compression,
 * but should be useful for any application where read vs. write workload needs to be considered.
 *----------------------------------------------------------------------------------------------------------*/
 GO

 /* Directly from link above:

 --Update operations
 SELECT o.name AS [Table_Name], x.name AS [Index_Name],
       i.partition_number AS [Partition],
       i.index_id AS [Index_ID], x.type_desc AS [Index_Type],
       i.leaf_update_count * 100.0 /
           (i.range_scan_count + i.leaf_insert_count
            + i.leaf_delete_count + i.leaf_update_count
            + i.leaf_page_merge_count + i.singleton_lookup_count
           ) AS [Percent_Update]
FROM sys.dm_db_index_operational_stats (db_id(), NULL, NULL, NULL) i
JOIN sys.objects o ON o.object_id = i.object_id
JOIN sys.indexes x ON x.object_id = i.object_id AND x.index_id = i.index_id
WHERE (i.range_scan_count + i.leaf_insert_count
       + i.leaf_delete_count + leaf_update_count
       + i.leaf_page_merge_count + i.singleton_lookup_count) != 0
AND objectproperty(i.object_id,'IsUserTable') = 1
ORDER BY [Percent_Update] ASC;

--Scan operations
SELECT o.name AS [Table_Name], x.name AS [Index_Name],
       i.partition_number AS [Partition],
       i.index_id AS [Index_ID], x.type_desc AS [Index_Type],
       i.range_scan_count * 100.0 /
           (i.range_scan_count + i.leaf_insert_count
            + i.leaf_delete_count + i.leaf_update_count
            + i.leaf_page_merge_count + i.singleton_lookup_count
           ) AS [Percent_Scan]
FROM sys.dm_db_index_operational_stats (db_id(), NULL, NULL, NULL) i
JOIN sys.objects o ON o.object_id = i.object_id
JOIN sys.indexes x ON x.object_id = i.object_id AND x.index_id = i.index_id
WHERE (i.range_scan_count + i.leaf_insert_count
       + i.leaf_delete_count + leaf_update_count
       + i.leaf_page_merge_count + i.singleton_lookup_count) != 0
AND objectproperty(i.object_id,'IsUserTable') = 1
ORDER BY [Percent_Scan] DESC;
*/
GO

--Modified:
SELECT o.name AS [Table_Name], x.name AS [Index_Name],
       i.partition_number AS [Partition],
       i.index_id AS [Index_ID], x.type_desc AS [Index_Type],
       (i.range_scan_count + i.singleton_lookup_count) * 100.0 /
           (i.range_scan_count + i.singleton_lookup_count 
            + i.leaf_insert_count + i.leaf_update_count
            + i.leaf_ghost_count + i.leaf_delete_count
           ) AS [Percent_Read],
       i.leaf_update_count * 100.0 /
           (i.range_scan_count + i.singleton_lookup_count 
            + i.leaf_insert_count + i.leaf_update_count
            + i.leaf_ghost_count + i.leaf_delete_count
           ) AS [Percent_Update],
       (i.leaf_insert_count + i.leaf_ghost_count + i.leaf_delete_count) * 100.0 /
           (i.range_scan_count + i.singleton_lookup_count 
            + i.leaf_insert_count + i.leaf_update_count
            + i.leaf_ghost_count + i.leaf_delete_count
           ) AS [Percent_Other_DML]
FROM sys.dm_db_index_operational_stats (db_id(), NULL, NULL, NULL) i
JOIN sys.objects o ON o.object_id = i.object_id
JOIN sys.indexes x ON x.object_id = i.object_id AND x.index_id = i.index_id
WHERE (i.range_scan_count + i.leaf_insert_count
       + i.leaf_delete_count + leaf_update_count
       + i.leaf_page_merge_count + i.singleton_lookup_count) != 0
AND objectproperty(i.object_id,'IsUserTable') = 1
ORDER BY [Percent_Read] DESC;