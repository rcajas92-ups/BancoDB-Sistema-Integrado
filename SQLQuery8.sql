-- =========================================================
-- 1. CREAR EL RESPALDO (BACKUP)
-- =========================================================
BACKUP DATABASE BancoDB
TO DISK = 'BancoDB_Backup.bak'
WITH FORMAT, 
     MEDIANAME = 'RespaldoBancario', 
     NAME = 'Copia de seguridad completa de BancoDB';
GO

PRINT 'Backup completado con éxito.';
GO


-- =========================================================
-- 2. RESTAURACIÓN (RECOVERY / RESTORE)
-- =========================================================
USE master;
GO

-- Paso de seguridad: Desconecta a cualquier usuario/conexión de BancoDB
ALTER DATABASE BancoDB 
SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE;
GO

-- Restaura la base de datos sobreescribiendo la actual
RESTORE DATABASE BancoDB
FROM DISK = 'BancoDB_Backup.bak'
WITH REPLACE;
GO

-- Vuelve a permitir que múltiples usuarios usen la base de datos
ALTER DATABASE BancoDB 
SET MULTI_USER;
GO

PRINT 'Restauración completada con éxito.';
GO