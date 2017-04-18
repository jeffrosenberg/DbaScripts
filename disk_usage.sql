-- Disk usage per drive (all drives)
SELECT [Table] = 'Drives'
EXEC sys.xp_fixeddrives

-- Disk usage per drive (drives with databases)
SELECT [Table] = 'Drives with databases'
SELECT drive = s.volume_mount_point, drive_name = s.logical_volume_name
, database_size_gb = CAST(SUM(f.size * 8.0 / 1024 / 1024) AS decimal(6,2))
, total_space_gb = CAST(MAX(s.total_bytes / 1024.0 / 1024 / 1024) AS decimal(7,2))
, available_space_gb = CAST(MAX(s.available_bytes / 1024.0 / 1024 / 1024) AS decimal(7,2))
, available_space_pct = 
    CAST(
      MAX(s.available_bytes) / MAX(s.total_bytes * 1.0) * 100
      AS decimal(6,2))
FROM sys.master_files AS f
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS s
GROUP BY s.volume_mount_point, s.logical_volume_name
ORDER BY s.volume_mount_point;

-- Disk usage per database
SELECT [Table] = 'Disk usage per database'
SELECT database_id, database_name = DB_NAME(database_id)
, data_size_mb = CAST(SUM(CASE WHEN type_desc = 'ROWS' THEN size * 8.0 / 1024 END) AS decimal(10,2))
, log_size_mb  = CAST(SUM(CASE WHEN type_desc = 'LOG'  THEN size * 8.0 / 1024 END) AS decimal(10,2))
, total_size_mb  = CAST(SUM(size * 8.0 / 1024) AS decimal(11,2))
FROM sys.master_files
GROUP BY database_id
UNION ALL
SELECT database_id = 99998
, database_name = 'TOTAL User DBs'
, data_size_mb = CAST(SUM(CASE WHEN type_desc = 'ROWS' THEN size * 8.0 / 1024 END) AS decimal(10,2))
, log_size_mb  = CAST(SUM(CASE WHEN type_desc = 'LOG'  THEN size * 8.0 / 1024 END) AS decimal(10,2))
, total_size_mb  = CAST(SUM(size * 8.0 / 1024) AS decimal(11,2))
FROM sys.master_files
WHERE database_id > 4
UNION ALL
SELECT database_id = 99999
, database_name = 'TOTAL ALL DBs'
, data_size_mb = CAST(SUM(CASE WHEN type_desc = 'ROWS' THEN size * 8.0 / 1024 END) AS decimal(10,2))
, log_size_mb  = CAST(SUM(CASE WHEN type_desc = 'LOG'  THEN size * 8.0 / 1024 END) AS decimal(10,2))
, total_size_mb  = CAST(SUM(size * 8.0 / 1024) AS decimal(11,2))
FROM sys.master_files
ORDER BY database_id;

--Log usage
SELECT [Table] = 'Log Usage'
DBCC SQLPERF(LOGSPACE)

--Allocated space -- applies only to current database
/*
SELECT [Table] = 'Internal Allocated/Unallocated Space'
EXEC sp_spaceused;
*/

--Allocated space -- applies only to current database (the slow way)
/*
SELECT [Table] = 'Internal Allocated/Unallocated Space'
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
*/

--Detailed transaction log usage
/*
SELECT [Table] = 'Detailed Log Usage / VLFs'
DBCC LOGINFO
*/

-- Database files (including OS volume details)
SELECT [Table] = 'Database files'
SELECT f.database_id, database_name = DB_NAME(f.database_id)
, [file_name] = f.name, f.file_id, f.type_desc, f.state_desc
, drive = s.volume_mount_point, drive_name = s.logical_volume_name
, file_path = f.physical_name
, size_mb = CAST((f.size * 8.0 / 1024) AS decimal(10,2))
, size_gb = CAST((f.size * 8.0 / 1024 / 1024) AS decimal(7,2))
, growth = CASE
            WHEN f.is_percent_growth = 1 
              THEN CAST(growth AS varchar(3)) + '%'
            ELSE CAST(growth * 8 / 1024 AS varchar(20)) + ' MB'
            END
FROM sys.master_files AS f
CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS s
ORDER BY f.database_id, f.[type];