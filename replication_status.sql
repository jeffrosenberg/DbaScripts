--Via http://www.sqlsoldier.com/wp/sqlserver/countingunreplicatedcommandsandtransactions
WITH MaxXact (ServerName, PublisherDBID, XactSeqNo)
As (Select S.name, DA.publisher_database_id, max(H.xact_seqno)
    From distribution.dbo.MSdistribution_history H with(nolock)
    Inner Join distribution.dbo.MSdistribution_agents DA with(nolock) On DA.id = H.agent_id
    Inner Join master.sys.servers S with(nolock) On S.server_id = DA.subscriber_id
    Group By S.name, DA.publisher_database_id)
Select MX.ServerName, MX.PublisherDBID, COUNT(*) As TransactionsNotReplicated
From distribution.dbo.msrepl_transactions T with(nolock)
Right Join MaxXact MX On MX.XactSeqNo < T.xact_seqno And MX.PublisherDBID = T.publisher_database_id
Group By MX.ServerName, MX.PublisherDBID;

With MaxXact (ServerName, PublisherDBID, XactSeqNo)
As (Select S.name, DA.publisher_database_id, max(H.xact_seqno)
    From distribution.dbo.MSdistribution_history H with(nolock)
    Inner Join distribution.dbo.MSdistribution_agents DA with(nolock) On DA.id = H.agent_id
    Inner Join master.sys.servers S with(nolock) On S.server_id = DA.subscriber_id
    Group By S.name, DA.publisher_database_id)
Select MX.ServerName, MX.PublisherDBID, COUNT(*) As CommandsNotReplicated
From distribution.dbo.MSrepl_commands C with(nolock)
Right Join MaxXact MX On MX.XactSeqNo < C.xact_seqno And MX.PublisherDBID = C.publisher_database_id
Group By MX.ServerName, MX.PublisherDBID;

--Via Mark Christenson
select LatencySeconds = cntr_value/1000 
FROM sys.dm_os_performance_counters 
WHERE object_name like '%replica%' and counter_name like '%Logreader:Delivery Latency%'