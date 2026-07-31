-- 1. Crear Base de Datos Financiera
CREATE DATABASE BancoDB;
GO

USE BancoDB;
GO

-- 2. Tabla Clientes
CREATE TABLE Clientes (
    ClienteID INT IDENTITY(1,1) PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    DocumentoIdentidad VARCHAR(20) UNIQUE NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    Telefono VARCHAR(20),
    FechaRegistro DATETIME DEFAULT GETDATE(),
    Estado BIT DEFAULT 1
);
GO

-- 3. Tabla Cuentas Bancarias
CREATE TABLE Cuentas (
    CuentaID INT IDENTITY(1,1) PRIMARY KEY,
    NumeroCuenta VARCHAR(20) UNIQUE NOT NULL,
    ClienteID INT NOT NULL,
    TipoCuenta VARCHAR(20) CHECK (TipoCuenta IN ('Ahorros', 'Corriente')),
    Saldo DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
    Estado VARCHAR(20) DEFAULT 'Activa',
    CONSTRAINT FK_Cuentas_Clientes FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);
GO

-- 4. Tabla Transacciones
CREATE TABLE Transacciones (
    TransaccionID INT IDENTITY(1,1) PRIMARY KEY,
    CuentaOrigenID INT,
    CuentaDestinoID INT,
    TipoTransaccion VARCHAR(20) CHECK (TipoTransaccion IN ('Deposito', 'Retiro', 'Transferencia')),
    Monto DECIMAL(18, 2) NOT NULL CHECK (Monto > 0),
    FechaTransaccion DATETIME DEFAULT GETDATE(),
    Descripcion VARCHAR(255),
    CONSTRAINT FK_Transacciones_Origen FOREIGN KEY (CuentaOrigenID) REFERENCES Cuentas(CuentaID),
    CONSTRAINT FK_Transacciones_Destino FOREIGN KEY (CuentaDestinoID) REFERENCES Cuentas(CuentaID)
);
GO

-- 5. Tabla de Auditoría (Para los Triggers de Seguridad)
CREATE TABLE AuditoriaTransacciones (
    AuditoriaID INT IDENTITY(1,1) PRIMARY KEY,
    TransaccionID INT,
    Accion VARCHAR(50),
    Usuario VARCHAR(100) DEFAULT SYSTEM_USER,
    FechaRegistro DATETIME DEFAULT GETDATE(),
    Detalles VARCHAR(MAX)
);
GO

-- Insertar Datos de Prueba
INSERT INTO Clientes (Nombre, Apellido, DocumentoIdentidad, Email, Telefono)
VALUES 
('Carlos', 'Pérez', '1712345678', 'carlos.perez@email.com', '0991234567'),
('María', 'Gómez', '1787654321', 'maria.gomez@email.com', '0987654321');

INSERT INTO Cuentas (NumeroCuenta, ClienteID, TipoCuenta, Saldo)
VALUES 
('CTA-1001', 1, 'Ahorros', 500.00),
('CTA-1002', 2, 'Corriente', 1200.00);
GO