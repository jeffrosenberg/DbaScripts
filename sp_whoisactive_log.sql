-- Based on the following post from Kendra Little:
-- http://www.littlekendra.com/2011/02/01/whoisactive/

DECLARE @sql AS varchar(max);
DECLARE @i AS smallint = 0;

----------------------------------------------------------------------------
--Create logging table

--Process variables
DECLARE @tableName AS sysname = N'tempdb.dbo.whoisactive_output'

--sp_whoisactive parameters
DECLARE @showSleepingSpids  AS bit = 0;
DECLARE @getPlans           AS bit = 1;
DECLARE @formatOutput       AS bit = 0;

IF OBJECT_ID(@tableName) IS NOT NULL
BEGIN
  SET @sql = N'DROP TABLE ' + @tableName;
  EXEC (@sql);
  SET @sql = NULL;
END

EXEC sp_whoisactive 
  @show_sleeping_spids = @showSleepingSpids, 
  @get_plans = @getPlans,
  @format_output = @formatOutput,
  @return_schema = 1,
  @schema = @sql OUTPUT;

SET @sql = REPLACE(@sql, '<table_name>', @tableName)

PRINT @sql;
--EXEC(@sql); --Uncomment to automatically create the table

----------------------------------------------------------------------------
--Loop and log each repetition

DECLARE @repetitions AS smallint = 5;
DECLARE @waitFor AS char(8) = '00:00:10';

WHILE @i < @repetitions
BEGIN
  EXEC sp_whoisactive 
    @show_sleeping_spids = @showSleepingSpids, 
    @get_plans = @getPlans,
    @format_output = @formatOutput,
    @destination_table = @tableName;

  WAITFOR DELAY @waitFor;

  SET @i += 1;
END

SET @sql = 'SELECT * FROM ' + @tableName;
EXEC(@sql);
/*
SET @sql = N'DROP TABLE ' + @tableName;
EXEC (@sql);
*/