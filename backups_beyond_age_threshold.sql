--=============================================================================
-- Backups beyond age threshold
-------------------------------------------------------------------------------
-- Groups backups by database and type, displays any groupings that 
-- exceed the health thresholds defined below

-- Modify the variables below to edit the threshold for old backups warnings
--=============================================================================

DECLARE @full_backup_threshold_hours AS int = (24 * 7) --Full backup within 7 days
DECLARE @diff_backup_threshold_hours AS int = (24 * 7) --Diff backup within 7 days
DECLARE  @log_backup_threshold_hours AS int = 6 --Log backup within 6 hours


SELECT database_name
, backup_type = 
    CASE [type] --Types detailed here: https://technet.microsoft.com/en-us/library/ms186299.aspx
      WHEN 'D' THEN 'FULL'
      WHEN 'I' THEN 'DIFF'
      WHEN 'L' THEN 'LOG'
      END
, most_recent_finish_date = MAX(backup_finish_date)
, most_recent_backup_status = 
    CASE [type] --Compare most recent backup to the thresholds above
      WHEN 'D' THEN 
        CASE WHEN DATEDIFF(hour, MAX(backup_finish_date), GETDATE()) <= @full_backup_threshold_hours THEN 'ok'
             ELSE 'EXCEEDS THRESHOLD'
             END
      WHEN 'I' THEN 
        CASE WHEN DATEDIFF(hour, MAX(backup_finish_date), GETDATE()) <= @diff_backup_threshold_hours THEN 'ok'
             ELSE 'EXCEEDS THRESHOLD'
             END
      WHEN 'L' THEN 
        CASE WHEN DATEDIFF(hour, MAX(backup_finish_date), GETDATE()) <= @log_backup_threshold_hours THEN 'ok'
             ELSE 'EXCEEDS THRESHOLD'
             END
      ELSE 'na'
      END
FROM  msdb..backupset
WHERE database_name NOT IN ('master','model','msdb') --Exclude system tables
GROUP BY database_name, type
HAVING ([type] = 'D' AND DATEDIFF(hour, MAX(backup_finish_date), GETDATE()) > @full_backup_threshold_hours)
    OR ([type] = 'I' AND DATEDIFF(hour, MAX(backup_finish_date), GETDATE()) > @diff_backup_threshold_hours)
    OR ([type] = 'L' AND DATEDIFF(hour, MAX(backup_finish_date), GETDATE()) >  @log_backup_threshold_hours)
ORDER BY database_name, type