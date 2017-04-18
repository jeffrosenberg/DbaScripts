-- Is the DAC enabled?
--EXEC sys.sp_configure @configname = 'remote admin connections'

-- Is the DAC being used? What's using it?
SELECT ses.session_id, ses.login_name, ses.host_name, ses.login_time, ses.status
FROM sys.endpoints as en
INNER JOIN sys.dm_exec_sessions ses
ON en.endpoint_id=ses.endpoint_id
WHERE en.name='Dedicated Admin Connection'

SELECT TOP 10 dec.*, dest.text
FROM sys.dm_exec_connections AS dec
OUTER APPLY sys.dm_exec_sql_text(dec.most_recent_sql_handle) AS dest
WHERE dec.local_tcp_port = 1434