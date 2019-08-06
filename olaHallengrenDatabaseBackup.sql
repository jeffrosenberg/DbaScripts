EXEC master.dbo.DatabaseBackup 
  @Databases = N'USER_DATABASES', -- nvarchar(max)
  @Directory = N'Z:', -- nvarchar(max)
  @BackupType = N'FULL', -- nvarchar(max)
  @Verify = N'Y', -- nvarchar(max)
  @CleanupTime = 24, -- int
  @Compress = N'Y', -- nvarchar(max)
  @CopyOnly = N'N', -- nvarchar(max)
  @ChangeBackupType = N'Y', -- nvarchar(max)
  @CheckSum = N'Y', -- nvarchar(max)
  @NumberOfFiles = 1, -- int
  @LogToTable = N'Y', -- nvarchar(max)
  @Execute = N'Y' -- nvarchar(max)