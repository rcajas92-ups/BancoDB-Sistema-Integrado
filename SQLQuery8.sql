-- 1. Crear Base de Datos para el Data Warehouse
CREATE DATABASE BancoDW;
GO

USE BancoDW;
GO

-- 2. Dimension Cliente
CREATE TABLE Dim_Cliente (
    ClienteKey INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID INT,
    NombreCompleto VARCHAR(200),
    DocumentoIdentidad VARCHAR(20)
);
GO

-- 3. Dimension Tiempo
CREATE TABLE Dim_Tiempo (
    TiempoKey INT PRIMARY KEY, -- Formato YYYYMMDD
    Fecha DATE,
    Anio INT,
    Mes INT,
    NombreMes VARCHAR(20),
    Dia INT
);
GO

-- 4. Tabla de Hechos Transacciones
CREATE TABLE Fact_Transacciones (
    TransaccionKey INT IDENTITY(1,1) PRIMARY KEY,
    ClienteKey INT FOREIGN KEY REFERENCES Dim_Cliente(ClienteKey),
    TiempoKey INT FOREIGN KEY REFERENCES Dim_Tiempo(TiempoKey),
    TipoTransaccion VARCHAR(20),
    Monto DECIMAL(18,2)
);
GO