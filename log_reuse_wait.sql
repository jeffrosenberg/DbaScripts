SELECT name, database_id, create_date,
     compatibility_level, user_access_desc, is_cdc_enabled,
     state_desc, recovery_model_desc, log_reuse_wait_desc
FROM sys.databases