/* 
--Options for showing all configurations
EXEC sp_configure 
select * from sys.configurations
*/

declare @option AS sysname = 'Agent XPs';
declare @optionNewValue AS int = 1;

declare @advOptVal AS int;
declare @existingVal AS int;
declare @config AS TABLE (
  name sysname,
  minimum int,
  maximum int,
  config_value int,
  run_value int
)

insert into @config
EXEC sp_configure 'show advanced options'

SELECT @advOptVal = run_value
FROM @config
WHERE name = 'show advanced options';

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;

EXEC sp_configure @option, @optionNewValue;
RECONFIGURE

EXEC sp_configure 'show advanced options', @advOptVal;
RECONFIGURE;
