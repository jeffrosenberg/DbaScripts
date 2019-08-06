SELECT [Server] = @@SERVERNAME
     , [Availability Group] = ag.name
     , [Role] = s.Role_Desc
FROM sys.dm_hadr_availability_replica_states s
INNER JOIN sys.availability_groups AS ag
  ON ag.group_id = s.group_id
WHERE s.is_local = 1
