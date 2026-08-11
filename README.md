# 🏦 Sistema Bancario Integrado: Transaccional (BancoDB) & Data Warehouse (BancoDW)

Este proyecto implementa una arquitectura completa de gestión financiera bancaria que abarca el procesamiento de transacciones en tiempo real (OLTP), un Data Warehouse en esquema estrella (OLAP), procesos ETL y la integración NoSQL con MongoDB.

---

## 🚀 Componentes del Proyecto

### 1. Base de Datos Transaccional (`BancoDB`)
- **Gestión de Clientes y Cuentas**: Tablas con claves primarias, foráneas y restricciones de unicidad.
- **Lógica de Negocio (Stored Procedures)**:
  - `sp_RegistrarCliente`, `sp_AbrirCuenta`, `sp_RealizarDeposito`, `sp_RealizarRetiro`.
  - `sp_TransferirDinero`: Manejo atómico de transacciones con `TRY...CATCH` y `ROLLBACK`.
- **Funciones**:
  - `fn_ObtenerSaldoTotalCliente`, `fn_HistorialTransaccionesCuenta`, `fn_ValidarSaldoSuficiente`.
- **Triggers de Seguridad y Auditoría**:
  - Control de saldos no negativos.
  - Registro automatizado en `AuditoriaTransacciones`.
  - Prevención de borrado directo de clientes activos.
- **Procesamiento de Lotes**:
  - Cursores para corte de saldos y aplicación mensual de tasas de interés.
- **Rendimiento**:
  - Vista materializada e índice *Clustered* en `vw_ResumenCuentasClientes`.

---

### 2. Data Warehouse (`BancoDW`) & ETL
- **Esquema Estrella**:
  - Tablas de dimensiones: `Dim_Cliente`, `Dim_Tiempo`.
  - Tabla de hechos: `Fact_Transacciones`.
- **Proceso ETL**: Extracción, transformación y carga limpia de transacciones operacionales al DW.

---

### 3. Integración NoSQL (`MongoDB`)
- Script en Python (`integracion.py`) que utiliza `pyodbc` y `pymongo` para replicar y sincronizar registros desde SQL Server hacia una colección NoSQL en MongoDB.

---

### 4. Estrategia de Backup y Recovery
- Generación de respaldos **Full** y **Diferenciales** en almacenamiento local (`C:\SQL2022\`).

---

## 🛠️ Tecnologías Utilizadas
- **SQL Server 2022 / Express** (SSMS)
- **Python 3** (`pyodbc`, `pymongo`)
- **MongoDB**
