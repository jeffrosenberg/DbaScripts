IF @@SERVERNAME LIKE '%[sp][0-9]%' OR @@SERVERNAME LIKE '%[sp]y[0-9]%'
BEGIN
  RAISERROR('This looks like a production environment!',16,1);
  RETURN;
END

DBCC FREEPROCCACHE
DBCC DROPCLEANBUFFERS
DBCC SQLPERF('sys.dm_os_wait_stats', CLEAR)