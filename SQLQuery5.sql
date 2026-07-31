USE BancoDB;
GO

-- ============================================================================
-- CURSOR 1: Procesar corte de saldos y mostrar resumen por cliente
-- ============================================================================
DECLARE @ClienteID INT, @Nombre VARCHAR(100), @Apellido VARCHAR(100);

DECLARE cursor_ResumenClientes CURSOR FOR
SELECT ClienteID, Nombre, Apellido FROM Clientes WHERE Estado = 1;

OPEN cursor_ResumenClientes;

FETCH NEXT FROM cursor_ResumenClientes INTO @ClienteID, @Nombre, @Apellido;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @TotalSaldo DECIMAL(18,2) = dbo.fn_ObtenerSaldoTotalCliente(@ClienteID);
    
    PRINT CONCAT('Cliente: ', @Nombre, ' ', @Apellido, ' | Saldo Total Consolidado: $', @TotalSaldo);

    FETCH NEXT FROM cursor_ResumenClientes INTO @ClienteID, @Nombre, @Apellido;
END;

CLOSE cursor_ResumenClientes;
DEALLOCATE cursor_ResumenClientes;
GO

-- ============================================================================
-- CURSOR 2: Aplicar tasa de interés (1%) a todas las cuentas de ahorro activas
-- ============================================================================
DECLARE @CuentaID INT, @SaldoActual DECIMAL(18,2), @Interes DECIMAL(18,2);

DECLARE cursor_AplicaInteres CURSOR FOR
SELECT CuentaID, Saldo FROM Cuentas WHERE TipoCuenta = 'Ahorros' AND Estado = 'Activa';

OPEN cursor_AplicaInteres;

FETCH NEXT FROM cursor_AplicaInteres INTO @CuentaID, @SaldoActual;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Interes = @SaldoActual * 0.01; -- 1% de rendimiento
    
    IF @Interes > 0
    BEGIN
        EXEC sp_RealizarDeposito @CuentaID = @CuentaID, @Monto = @Interes, @Descripcion = 'Abono de Intereses Mensuales';
    END

    FETCH NEXT FROM cursor_AplicaInteres INTO @CuentaID, @SaldoActual;
END;

CLOSE cursor_AplicaInteres;
DEALLOCATE cursor_AplicaInteres;
GO