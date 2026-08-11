

-- 1. BACKUP 
BACKUP DATABASE BancoDB
TO DISK = 'BancoDB_Backup.bak'
WITH FORMAT, 
     MEDIANAME = 'RespaldoBancario', 
     NAME = 'Copia de seguridad completa de BancoDB';
GO

PRINT 'Backup completado. El archivo se guardó en la ruta por defecto de SQL Server.';
GO


-- 2. RECOVERY (Restauración de la base de datos)

USE master;
GO


RESTORE DATABASE BancoDB
FROM DISK = 'BancoDB_Backup.bak'
WITH REPLACE;
PRINT 'Restauración completada con éxito.';

GO