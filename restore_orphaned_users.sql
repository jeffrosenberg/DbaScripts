USE [Amtrak]

--Get a list of orphaned users
exec sp_change_users_login 'report';
GO

-------------------------------------------------------------------------------
--Easy fix: ALTER USER
ALTER USER [user] WITH LOGIN = [user]

-----------------------------------------------------------------------------
--Difficult fix: Recreate orphaned users and with explicit SIDs

--Get logins, SIDs, and password hashes
DECLARE @loginName AS sysname;

SELECT sl.name, sl.sid, sl.password_hash
FROM sys.sql_logins AS sl
WHERE sl.name = @loginName

USE [Master]
GO

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

USE [Amtrak]

--Re-run the report
exec sp_change_users_login 'report';
GO