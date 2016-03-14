/* -------------------------------------------------------------------------------------------------
 * Restore script examples
 * -------------------------------------------------------------------------------------------------
 * Author:  Jeff Rosenberg
 * Date:    9/24/2015
 *
 * NOTE: These scripts would typically be run as three separate processes: FULL, DIFF, and then LOG.
 *       They are presented together here just to make them easier to read.
 * ------------------------------------------------------------------------------------------------*/

RESTORE -- 1. Restore FULL backup
DATABASE Amtrak
FROM DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\FULL\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_FULL_20150920_010003_4.bak'
, DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\FULL\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_FULL_20150920_010003_3.bak'
, DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\FULL\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_FULL_20150920_010003_6.bak'
, DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\FULL\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_FULL_20150920_010003_7.bak'
, DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\FULL\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_FULL_20150920_010003_8.bak'
, DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\FULL\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_FULL_20150920_010003_1.bak'
, DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\FULL\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_FULL_20150920_010003_5.bak'
, DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\FULL\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_FULL_20150920_010003_2.bak'
WITH NORECOVERY,
  CHECKSUM, STOP_ON_ERROR,
  STATS = 5
GO

RESTORE -- 2. Restore DIFF backup
DATABASE Amtrak
FROM DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\DIFF\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_DIFF_20150924_000002_1.bak'
, DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\DIFF\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_DIFF_20150924_000002_2.bak'
, DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\DIFF\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_DIFF_20150924_000002_3.bak'
, DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\DIFF\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_DIFF_20150924_000002_4.bak'
, DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\DIFF\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_DIFF_20150924_000002_5.bak'
, DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\DIFF\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_DIFF_20150924_000002_6.bak'
, DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\DIFF\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_DIFF_20150924_000002_7.bak'
, DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\DIFF\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_DIFF_20150924_000002_8.bak'
WITH NORECOVERY,
  CHECKSUM, STOP_ON_ERROR,
  STATS = 5
GO

-- 3. Restore LOG backups
-- There would typically be one of these for each 20-minute interval. I've truncated them at 4, because they all look the same
RESTORE LOG Amtrak
FROM DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\LOG\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_LOG_20150924_000002.trn'
WITH NORECOVERY, STOP_ON_ERROR
RESTORE LOG Amtrak
FROM DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\LOG\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_LOG_20150924_002004.trn'
WITH NORECOVERY, STOP_ON_ERROR
RESTORE LOG Amtrak
FROM DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\LOG\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_LOG_20150924_004000.trn'
WITH NORECOVERY, STOP_ON_ERROR
RESTORE LOG Amtrak
FROM DISK = '\\commvault\SQLDump\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01\Amtrak\LOG\AGR-SQL-PROD-CLUS$agrsqlserv-prd-ag01_Amtrak_LOG_20150924_010000.trn'
WITH NORECOVERY, STOP_ON_ERROR
GO

-- 4. Finalize the restore and put the database into production
RESTORE
DATABASE Amtrak
WITH RECOVERY