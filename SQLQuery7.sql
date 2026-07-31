import pyodbc
import pymongo

# ============================================================================
# SCRIPT DE INTEGRACIÓN: SQL Server (BancoDB) -> MongoDB (NoSQL)
# ============================================================================

# 1. Conexión a MongoDB (Local)
mongo_client = pymongo.MongoClient("mongodb://localhost:27017/")
db = mongo_client["BancoDB_NoSQL"]
coleccion_transacciones = db["transacciones_audit"]

# 2. Conexión a SQL Server
conexion_sql = pyodbc.connect(
    "DRIVER={ODBC Driver 17 for SQL Server};"
    "SERVER=localhost\\SQLEXPRESS;"
    "DATABASE=BancoDB;"
    "Trusted_Connection=yes;"
)
cursor = conexion_sql.cursor()

# 3. Extraer transacciones desde SQL Server
cursor.execute(
    "SELECT TransaccionID, TipoTransaccion, Monto, FechaTransaccion, Descripcion FROM Transacciones"
)
registros = cursor.fetchall()

# 4. Transformar e Insertar en MongoDB
contador = 0
for row in registros:
    documento_nosql = {
        "transaccion_id": row[0],
        "tipo_transaccion": row[1],
        "monto": float(row[2]),
        "fecha": str(row[3]),
        "descripcion": row[4],
        "origen": "Sincronizado desde SQL Server - Proyecto Bancario",
    }

    # Upsert para evitar duplicados basado en el ID de transacción
    coleccion_transacciones.update_one(
        {"transaccion_id": row[0]}, {"$set": documento_nosql}, upsert=True
    )
    contador += 1

print(
    f"¡Integración exitosa! Se sincronizaron {contador} registros hacia MongoDB."
)

# Cerrar conexiones
cursor.close()
conexion_sql.close()
mongo_client.close()