USE BancoDW;
GO

-- ============================================================================
-- PROCESO ETL: Carga de Datos desde BancoDB hacia BancoDW (Esquema Estrella)
-- ============================================================================

-- PASO 1: Cargar Dimensión Clientes
INSERT INTO BancoDW.dbo.Dim_Cliente (ClienteID, NombreCompleto, DocumentoIdentidad)
SELECT 
    c.ClienteID,
    CONCAT(c.Nombre, ' ', c.Apellido) AS NombreCompleto,
    c.DocumentoIdentidad
FROM BancoDB.dbo.Clientes c
WHERE NOT EXISTS (
    SELECT 1 FROM BancoDW.dbo.Dim_Cliente dc WHERE dc.ClienteID = c.ClienteID
);
GO

-- PASO 2: Cargar Dimensión Tiempo (basada en las fechas de transacciones)
INSERT INTO BancoDW.dbo.Dim_Tiempo (TiempoKey, Fecha, Anio, Mes, NombreMes, Dia)
SELECT DISTINCT 
    CAST(FORMAT(t.FechaTransaccion, 'yyyyMMdd') AS INT) AS TiempoKey,
    CAST(t.FechaTransaccion AS DATE) AS Fecha,
    YEAR(t.FechaTransaccion) AS Anio,
    MONTH(t.FechaTransaccion) AS Mes,
    DATENAME(MONTH, t.FechaTransaccion) AS NombreMes,
    DAY(t.FechaTransaccion) AS Dia
FROM BancoDB.dbo.Transacciones t
WHERE NOT EXISTS (
    SELECT 1 FROM BancoDW.dbo.Dim_Tiempo dt 
    WHERE dt.TiempoKey = CAST(FORMAT(t.FechaTransaccion, 'yyyyMMdd') AS INT)
);
GO

-- PASO 3: Cargar Tabla de Hechos (Fact_Transacciones)
INSERT INTO BancoDW.dbo.Fact_Transacciones (ClienteKey, TiempoKey, TipoTransaccion, Monto)
SELECT 
    dc.ClienteKey,
    dt.TiempoKey,
    t.TipoTransaccion,
    t.Monto
FROM BancoDB.dbo.Transacciones t
-- Relacionamos la transacción con el cliente a través de la cuenta origen o destino
LEFT JOIN BancoDB.dbo.Cuentas c ON t.CuentaOrigenID = c.CuentaID OR t.CuentaDestinoID = c.CuentaID
INNER JOIN BancoDW.dbo.Dim_Cliente dc ON c.ClienteID = dc.ClienteID
INNER JOIN BancoDW.dbo.Dim_Tiempo dt ON dt.TiempoKey = CAST(FORMAT(t.FechaTransaccion, 'yyyyMMdd') AS INT)
WHERE NOT EXISTS (
    -- Evitar duplicados en cargas iterativas
    SELECT 1 FROM BancoDW.dbo.Fact_Transacciones ft 
    WHERE ft.ClienteKey = dc.ClienteKey AND ft.TiempoKey = dt.TiempoKey AND ft.Monto = t.Monto
);
GO

PRINT '¡Proceso ETL ejecutado y cargado con éxito en el Data Warehouse!';