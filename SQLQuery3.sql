USE BancoDB;
GO

-- ============================================================================
-- 1. Función Escalar: Obtener el saldo total consolidado de un cliente
-- ============================================================================
CREATE OR ALTER FUNCTION fn_ObtenerSaldoTotalCliente (@ClienteID INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @SaldoTotal DECIMAL(18,2);
    
    SELECT @SaldoTotal = ISNULL(SUM(Saldo), 0.00)
    FROM Cuentas
    WHERE ClienteID = @ClienteID AND Estado = 'Activa';

    RETURN @SaldoTotal;
END;
GO

-- ============================================================================
-- 2. Función con Valor de Tabla: Historial de transacciones por rango de fechas
-- ============================================================================
CREATE OR ALTER FUNCTION fn_HistorialTransaccionesCuenta (
    @CuentaID INT,
    @FechaInicio DATETIME,
    @FechaFin DATETIME
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        TransaccionID,
        TipoTransaccion,
        Monto,
        FechaTransaccion,
        Descripcion,
        CASE 
            WHEN CuentaOrigenID = @CuentaID THEN 'Egreso'
            WHEN CuentaDestinoID = @CuentaID THEN 'Ingreso'
            ELSE 'N/A'
        END AS Flujo
    FROM Transacciones
    WHERE (CuentaOrigenID = @CuentaID OR CuentaDestinoID = @CuentaID)
      AND FechaTransaccion BETWEEN @FechaInicio AND @FechaFin
);
GO

-- ============================================================================
-- 3. Función Escalar: Validar si una cuenta tiene saldo suficiente
-- ============================================================================
CREATE OR ALTER FUNCTION fn_ValidarSaldoSuficiente (
    @CuentaID INT,
    @MontoRequerido DECIMAL(18,2)
)
RETURNS BIT
AS
BEGIN
    DECLARE @Resultado BIT = 0;
    DECLARE @SaldoActual DECIMAL(18,2);

    SELECT @SaldoActual = Saldo 
    FROM Cuentas 
    WHERE CuentaID = @CuentaID AND Estado = 'Activa';

    IF @SaldoActual IS NOT NULL AND @SaldoActual >= @MontoRequerido
    BEGIN
        SET @Resultado = 1;
    END

    RETURN @Resultado;
END;
GO



