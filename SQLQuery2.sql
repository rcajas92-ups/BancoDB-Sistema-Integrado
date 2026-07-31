USE BancoDB;
GO

-- ============================================================================
-- 1. SP: Registrar nuevo cliente
-- ============================================================================
CREATE OR ALTER PROCEDURE sp_RegistrarCliente
    @Nombre VARCHAR(100),
    @Apellido VARCHAR(100),
    @Documento VARCHAR(20),
    @Email VARCHAR(100),
    @Telefono VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO Clientes (Nombre, Apellido, DocumentoIdentidad, Email, Telefono)
        VALUES (@Nombre, @Apellido, @Documento, @Email, @Telefono);

        PRINT 'Cliente registrado exitosamente.';
    END TRY
    BEGIN CATCH
        THROW 50001, 'Error al registrar el cliente. Verifique que el documento o email no existan.', 1;
    END CATCH
END;
GO

-- ============================================================================
-- 2. SP: Apertura de nueva cuenta bancaria
-- ============================================================================
CREATE OR ALTER PROCEDURE sp_AbrirCuenta
    @NumeroCuenta VARCHAR(20),
    @ClienteID INT,
    @TipoCuenta VARCHAR(20),
    @MontoInicial DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @MontoInicial < 0
            RAISERROR('El monto inicial no puede ser negativo.', 16, 1);

        INSERT INTO Cuentas (NumeroCuenta, ClienteID, TipoCuenta, Saldo)
        VALUES (@NumeroCuenta, @ClienteID, @TipoCuenta, @MontoInicial);

        PRINT 'Cuenta abierta exitosamente.';
    END TRY
    BEGIN CATCH
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- ============================================================================
-- 3. SP: Realizar Depósito en cuenta
-- ============================================================================
CREATE OR ALTER PROCEDURE sp_RealizarDeposito
    @CuentaID INT,
    @Monto DECIMAL(18,2),
    @Descripcion VARCHAR(255) = 'Depósito en efectivo'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @Monto <= 0
            RAISERROR('El monto debe ser mayor a cero.', 16, 1);

        BEGIN TRANSACTION;

        UPDATE Cuentas 
        SET Saldo = Saldo + @Monto 
        WHERE CuentaID = @CuentaID;

        INSERT INTO Transacciones (CuentaOrigenID, CuentaDestinoID, TipoTransaccion, Monto, Descripcion)
        VALUES (NULL, @CuentaID, 'Deposito', @Monto, @Descripcion);

        COMMIT TRANSACTION;
        PRINT 'Depósito realizado con éxito.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- ============================================================================
-- 4. SP: Realizar Retiro de cuenta
-- ============================================================================
CREATE OR ALTER PROCEDURE sp_RealizarRetiro
    @CuentaID INT,
    @Monto DECIMAL(18,2),
    @Descripcion VARCHAR(255) = 'Retiro en cajero/ventanilla'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @Monto <= 0
            RAISERROR('El monto del retiro debe ser positivo.', 16, 1);

        DECLARE @SaldoActual DECIMAL(18,2);
        SELECT @SaldoActual = Saldo FROM Cuentas WHERE CuentaID = @CuentaID;

        IF @SaldoActual IS NULL
            RAISERROR('La cuenta no existe.', 16, 1);

        IF @SaldoActual < @Monto
            RAISERROR('Saldo insuficiente para completar la transacción.', 16, 1);

        BEGIN TRANSACTION;

        UPDATE Cuentas 
        SET Saldo = Saldo - @Monto 
        WHERE CuentaID = @CuentaID;

        INSERT INTO Transacciones (CuentaOrigenID, CuentaDestinoID, TipoTransaccion, Monto, Descripcion)
        VALUES (@CuentaID, NULL, 'Retiro', @Monto, @Descripcion);

        COMMIT TRANSACTION;
        PRINT 'Retiro ejecutado correctamente.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

-- ============================================================================
-- 5. SP CRÍTICO: Transferencia bancaria entre dos cuentas (con manejo de transacción)
-- ============================================================================
CREATE OR ALTER PROCEDURE sp_TransferirDinero
    @CuentaOrigenID INT,
    @CuentaDestinoID INT,
    @Monto DECIMAL(18,2),
    @Descripcion VARCHAR(255) = 'Transferencia bancaria'
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        IF @Monto <= 0
            RAISERROR('El monto a transferir debe ser mayor a cero.', 16, 1);

        IF @CuentaOrigenID = @CuentaDestinoID
            RAISERROR('La cuenta origen y destino no pueden ser la misma.', 16, 1);

        DECLARE @SaldoOrigen DECIMAL(18,2);
        SELECT @SaldoOrigen = Saldo FROM Cuentas WHERE CuentaID = @CuentaOrigenID AND Estado = 'Activa';

        IF @SaldoOrigen IS NULL
            RAISERROR('La cuenta de origen no existe o está inactiva.', 16, 1);

        IF @SaldoOrigen < @Monto
            RAISERROR('Saldo insuficiente en la cuenta de origen.', 16, 1);

        IF NOT EXISTS (SELECT 1 FROM Cuentas WHERE CuentaID = @CuentaDestinoID AND Estado = 'Activa')
            RAISERROR('La cuenta de destino no existe o está inactiva.', 16, 1);

        -- Iniciar Transacción Atómica
        BEGIN TRANSACTION;

        -- Restar de la cuenta origen
        UPDATE Cuentas SET Saldo = Saldo - @Monto WHERE CuentaID = @CuentaOrigenID;

        -- Sumar a la cuenta destino
        UPDATE Cuentas SET Saldo = Saldo + @Monto WHERE CuentaID = @CuentaDestinoID;

        -- Registrar transacción
        INSERT INTO Transacciones (CuentaOrigenID, CuentaDestinoID, TipoTransaccion, Monto, Descripcion)
        VALUES (@CuentaOrigenID, @CuentaDestinoID, 'Transferencia', @Monto, @Descripcion);

        COMMIT TRANSACTION;
        PRINT 'Transferencia realizada con éxito.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO