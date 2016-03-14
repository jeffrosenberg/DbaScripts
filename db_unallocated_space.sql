
SELECT f.database_id, database_name = DB_NAME(f.database_id)
, f.type_desc, f.state_desc
, drive = s.volume_mount_point, drive_name = s.logical_volume_name
, [used_space_gb] = 
    CAST(SUM((su.allocated_extent_page_count * 8.0 / 1024 / 1024)) AS decimal(12,2))
, [unused_space_gb] = 
    CAST(SUM((su.unallocated_extent_page_count * 8.0 / 1024 / 1024)) AS decimal(12,2))
, [unused_space_pct] = 
    CAST(
      SUM((su.unallocated_extent_page_count * 8.0 / 1024 / 1024))/
      (SUM((su.allocated_extent_page_count * 8.0 / 1024 / 1024))
      +SUM((su.unallocated_extent_page_count * 8.0 / 1024 / 1024)))
    * 100 AS decimal(6,2))
, size_mb = 
    CAST(SUM((f.size * 8.0 / 1024)) AS decimal(12,2))
, size_gb = 
    CAST(SUM((f.size * 8.0 / 1024 / 1024)) AS decimal(12,2))
FROM sys.master_files AS f
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS s
INNER JOIN sys.dm_db_file_space_usage AS su
  ON su.database_id = f.database_id
    AND su.file_id = f.file_id
GROUP BY f.database_id, f.type_desc, f.state_desc
, s.volume_mount_point, s.logical_volume_name