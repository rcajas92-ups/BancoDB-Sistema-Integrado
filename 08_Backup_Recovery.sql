USE master;
GO

-- 1. RESPALDO COMPLETO (BACKUP)
BACKUP DATABASE BancoDB
TO DISK = 'C:\SQL_Backups\BancoDB_Full.bak'
WITH FORMAT,
     MEDIANAME = 'BancoDB_Backup_Media',
     NAME = 'Respaldo Completo de BancoDB';
GO

-- 2. RESTAURACIÓN (RECOVERY / RESTORE)
RESTORE DATABASE BancoDB
FROM DISK = 'C:\SQL_Backups\BancoDB_Full.bak'
WITH REPLACE;
GO
