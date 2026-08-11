USE BancoDB;
GO

-- ============================================================================
-- 1. TRIGGER DE SEGURIDAD: Evitar saldos negativos en las cuentas
-- ============================================================================
CREATE OR ALTER TRIGGER trg_PreventSaldoNegativo
ON Cuentas
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM inserted WHERE Saldo < 0)
    BEGIN
        RAISERROR('Operación cancelada: El saldo de la cuenta no puede ser negativo.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- ============================================================================
-- 2. TRIGGER DE AUDITORÍA: Registrar cada movimiento en la tabla de auditoría
-- ============================================================================
CREATE OR ALTER TRIGGER trg_AuditoriaTransacciones
ON Transacciones
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO AuditoriaTransacciones (TransaccionID, Accion, Detalles)
    SELECT 
        i.TransaccionID,
        'NUEVA_TRANSACCION',
        CONCAT('Tipo: ', i.TipoTransaccion, ' | Monto: $', i.Monto, ' | Origen ID: ', ISNULL(CAST(i.CuentaOrigenID AS VARCHAR), 'N/A'), ' | Destino ID: ', ISNULL(CAST(i.CuentaDestinoID AS VARCHAR), 'N/A'))
    FROM inserted i;
END;
GO

-- ============================================================================
-- 3. TRIGGER DE SEGURIDAD: Impedir el borrado directo de clientes con cuentas activas
-- ============================================================================
CREATE OR ALTER TRIGGER trg_PreventDeleteCliente
ON Clientes
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1 
        FROM deleted d 
        INNER JOIN Cuentas c ON d.ClienteID = c.ClienteID 
        WHERE c.Estado = 'Activa'
    )
    BEGIN
        RAISERROR('No se puede eliminar un cliente que posee cuentas bancarias activas.', 16, 1);
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        -- Desactivar lógicamente en lugar de borrar
        UPDATE Clientes 
        SET Estado = 0 
        WHERE ClienteID IN (SELECT ClienteID FROM deleted);
        
        PRINT 'Cliente desactivado lógicamente.';
    END
END;
GO