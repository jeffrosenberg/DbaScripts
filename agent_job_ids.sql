SELECT job_id
, name
, job_binary = CONVERT(BINARY(16),job_id) 
, [app_name] = 'SQLAgent - TSQL JobStep (Job ' + CONVERT(nvarchar(MAX), CONVERT(BINARY(16),job_id), 1)
FROM msdb.dbo.sysjobs