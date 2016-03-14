DECLARE @loginName AS sysname;

SELECT sl.name, sl.sid, sl.password_hash
FROM sys.sql_logins AS sl
--WHERE name = @loginName

-----------------------------------------------------------------------------
--Drop logins for orphaned users and recreate them with explicit SIDs

--We know the password
DROP LOGIN cfuser2;

CREATE LOGIN cfuser2 
WITH PASSWORD = 'Denali1234!',
SID = 0xA4D53846DECAE1409B1C9F9EC730F992;
GO

--We don't know the password - note HASHED keyword on PASSWORD clause
DROP LOGIN monitoring
GO

CREATE LOGIN monitoring
WITH PASSWORD = 0x0200973FD1F3B5D794661324DD502B1FA5A73FF0D423F1DE9EB7E5E2198E84CC81C4DF4B6672D96F21325A9608F1D1CCA21791736CC887214EDDC4509D9550E22B6DBFAB180B HASHED
, SID = 0x18C3874624E9CF42AC6DC8F296E47399
, CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO

-----------------------
SELECT 'IF(SUSER_ID('+QUOTENAME(SP.name,'''')+') IS NULL)BEGIN CREATE LOGIN ' + QUOTENAME(SP.name) + 
       CASE WHEN SP.type_desc = 'SQL_LOGIN'
            THEN ' WITH PASSWORD = '+CONVERT(NVARCHAR(MAX),SL.password_hash,1)+' HASHED'
            ELSE ' FROM WINDOWS'
       END + ';/*'+SP.type_desc+'*/ END;'
       COLLATE SQL_Latin1_General_CP1_CI_AS
FROM sys.server_principals AS SP
LEFT JOIN sys.sql_logins AS SL
  ON SP.principal_id = SL.principal_id
 WHERE SP.type_desc IN ('SQL_LOGIN','WINDOWS_GROUP','WINDOWS_LOGIN')
   AND SP.name NOT LIKE '##%##'
   AND SP.name NOT IN ('SA')
   AND SP.name = 'monitoring'