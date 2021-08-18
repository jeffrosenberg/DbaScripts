EXEC master.dbo.DatabaseBackup 
  @Databases = N'TallyHotel', -- nvarchar(max)
  @Directory = N'Z:', -- nvarchar(max)
  @BackupType = N'FULL', -- nvarchar(max)
  @Verify = N'Y', -- nvarchar(max)
  @CleanupTime = 24, -- int
  @Compress = N'Y', -- nvarchar(max)
  @CopyOnly = N'N', -- nvarchar(max)
  @ChangeBackupType = N'Y', -- nvarchar(max)
  @CheckSum = N'Y', -- nvarchar(max)
  @NumberOfFiles = 8, -- int
  @LogToTable = N'Y', -- nvarchar(max)
  @Execute = N'Y' -- nvarchar(max)

BACKUP DATABASE TallyHotel 
TO DISK = 'Z:\tally_hotel_backup\TallyHotel-2020-10-22_1.bak'
 , DISK = 'Z:\tally_hotel_backup\TallyHotel-2020-10-22_2.bak'
 , DISK = 'Z:\tally_hotel_backup\TallyHotel-2020-10-22_3.bak'
 , DISK = 'Z:\tally_hotel_backup\TallyHotel-2020-10-22_4.bak'
WITH COMPRESSION, CHECKSUM, STATS = 2