USE msdb
GO
--SELECT * FROM msdb.dbo.log_shipping_monitor_alert AS lsma
SELECT * FROM msdb.dbo.log_shipping_monitor_error_detail AS lsmed
SELECT * FROM msdb.dbo.log_shipping_monitor_history_detail AS lsmhd
--SELECT * FROM msdb.dbo.log_shipping_monitor_primary AS lsmp
SELECT * FROM msdb.dbo.log_shipping_monitor_secondary AS lsms
--SELECT * FROM msdb.dbo.log_shipping_primaries AS lsp
--SELECT * FROM msdb.dbo.log_shipping_primary_databases AS lspd
--SELECT * FROM msdb.dbo.log_shipping_primary_secondaries AS lsps
--SELECT * FROM msdb.dbo.log_shipping_secondaries AS lss
SELECT * FROM msdb.dbo.log_shipping_secondary AS lss
SELECT * FROM msdb.dbo.log_shipping_secondary_databases AS lssd

EXEC xp_dirtree 'Z:\Transfer\Sandbox',5,1
EXEC xp_dirtree 'Z:\Transfer\jRewardToysRUs',5,1
/*
select lss.primary_database, lss.monitor_server, r.restore_history_id
, r.restore_date, r.backup_start_date, r.backup_finish_date, r.server_name 
from msdb.dbo.log_shipping_secondary AS lss
cross apply (
	select top 1 rh.restore_history_id, rh.restore_date, rh.destination_database_name
	, bs.backup_start_date, bs.backup_finish_date, bs.server_name
	from msdb.dbo.restorehistory AS rh
	inner join msdb.dbo.backupset AS bs
		on bs.backup_set_id = rh.backup_set_id
	where rh.destination_database_name = lss.primary_database
	order by rh.restore_history_id desc
) AS r
*/