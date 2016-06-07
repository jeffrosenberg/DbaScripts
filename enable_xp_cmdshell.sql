-------------------------------------------------------------------------------
--Enable XP_CmdShell
-------------------------------------------------------------------------------

--Save the state of the 'show advanced options' configuration
DECLARE @advancedOptionsValue AS int;
DECLARE @advancedOptions AS table(
  name nvarchar(35),
  minimum int,
  maximum int,
  config_value int,
  run_value int
);
INSERT INTO @advancedOptions 
EXEC sp_configure @configname = 'show advanced options';

SELECT @advancedOptionsValue = ao.config_value 
FROM @advancedOptions AS ao
WHERE ao.name = 'show advanced options';

--Enable advanced options in case it's not already enabled
EXEC sp_configure @configname = 'show advanced options', @configvalue = 1;
RECONFIGURE;

--Enable xp_cmdshell
EXEC sp_configure @configname = 'xp_cmdshell', @configvalue = 1;
RECONFIGURE;

--Reset advanced options to the saved state
EXEC sp_configure @configname = 'show advanced options', @configvalue = @advancedOptionsValue;
RECONFIGURE;