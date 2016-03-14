select @@SERVERNAME	
,sl.name	
,isnull(server_roles.Roles,'Public') 	
from syslogins sl	
left join	
(	
select 'sysadmin' as Roles	
union all 	
select 'securityadmin' 	
union all 	
select 'serveradmin' 	
union all 	
select 'setupadmin' 	
union all 	
select 'processadmin' 	
union all 	
select 'diskadmin' 	
union all 	
select 'dbcreator' 	
union all 	
select 'bulkadmin' 	
union all 	
select 'No serverRole' 	
union all	
select 'public'	
) AS server_roles 	
on 	
Case When sl.sysadmin=1 and server_roles.Roles='sysadmin' then 'sysadmin' 	
	When sl.securityadmin=1 and server_roles.Roles='securityadmin' then 'securityadmin'
	When sl.serveradmin=1 and server_roles.Roles='serveradmin' then 'serveradmin' 
	When sl.setupadmin=1 and server_roles.Roles='setupadmin' then 'setupadmin' 
	When sl.processadmin=1 and server_roles.Roles='processadmin' then 'processadmin' 
	When sl.diskadmin=1 and server_roles.Roles='diskadmin' then 'diskadmin' 
	When sl.dbcreator=1 and server_roles.Roles='dbcreator' then 'dbcreator'  
	When sl.bulkadmin=1 and server_roles.Roles='bulkadmin' then 'bulkadmin' 
	else null end=server_roles.Roles
ORDER BY [name]	
