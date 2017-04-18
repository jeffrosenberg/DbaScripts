DECLARE @startDate AS datetime = DATEADD(day, DATEDIFF(day, 0, GETDATE()), 0); -- Today midnight

SELECT sja.session_id
     , sja.job_id
     , sj.name
     , sja.run_requested_date
     , sja.start_execution_date
     , sja.last_executed_step_id
     , sja.last_executed_step_date
     , sja.stop_execution_date
FROM msdb.dbo.sysjobactivity AS sja
INNER JOIN msdb.dbo.sysjobs AS sj
  ON sj.job_id = sja.job_id
WHERE sja.start_execution_date >= @startDate
  AND sja.stop_execution_date IS NULL;

RETURN; -- Review jobs and update stop_execution_date if necessary

UPDATE msdb.dbo.sysjobactivity
SET stop_execution_date = GETDATE()
WHERE start_execution_date >= @startDate 
  AND stop_execution_date IS NULL
  --AND session_id NOT IN (,,,) -- Exclude sessions that are legitimately still running