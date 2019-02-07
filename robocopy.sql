/* Robocopy detailed syntax: http://ss64.com/nt/robocopy.html
   Common switches:
     /S: Copy subfolders
     /MAXAGE:n : MAXimum file AGE - exclude files older than n days/date.
     /MINAGE:n : MINimum file AGE - exclude files newer than n days/date.
     /L : List only - don’t copy, timestamp or delete any files.
     /Z : Copy files in restartable mode (survive network glitch).
     /R:n : Number of Retries on failed copies - default is 1 million.
     /IPG:n : Inter-Packet Gap (ms), to free bandwidth on slow lines.
*/
DECLARE @cmd varchar(4000);
SET @cmd = 'robocopy Source_folder Destination_folder files_to_copy [/options]';

EXEC xp_cmdshell @cmd;