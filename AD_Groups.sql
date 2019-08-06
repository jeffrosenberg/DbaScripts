-- Check the membership of a group
EXEC xp_logininfo 'YOSEMITE\HGP_SQL_P_HyattMemoryOptimized_RWA', 'members'
 
-- Check the groups of a member
EXEC xp_logininfo 'YOSEMITE\GWillprecht', 'all'