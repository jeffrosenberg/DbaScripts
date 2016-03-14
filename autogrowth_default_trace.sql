DECLARE @path NVARCHAR(260);

--Get the path to the original trace file
--Rollover files will be included automatically
SELECT  @path = REVERSE(SUBSTRING(REVERSE([path]), CHARINDEX('\', REVERSE([path])), 260)) + N'log.trc'
FROM sys.traces
WHERE is_default = 1;

SELECT ServerName, DatabaseID, DatabaseName, [FileName]
, FileType = CASE EventClass 
              WHEN 92 THEN 'Data'
              WHEN 93 THEN 'Log'
              END
, StartTime, EndTime, Duration
, ApplicationName, NTDomainName, HostName
, LoginName, SessionLoginName
FROM sys.fn_trace_gettable(@path, DEFAULT) --DEFAULT = include rollover files
WHERE EventClass IN (92,93) --Data/Log file auto growth events
ORDER BY StartTime DESC;
