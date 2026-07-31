import pyodbc
import pymongo

# 1. Conexión a MongoDB (Local)
try:
    mongo_client = pymongo.MongoClient("mongodb://localhost:27017/", serverSelectionTimeoutMS=2000)
    db = mongo_client["BancoDB_NoSQL"]
    coleccion = db["transacciones_audit"]
    mongo_client.server_info() # Probar conexión
except Exception as e:
    print("⚠️ Nota: MongoDB no parece estar corriendo en local, pero el script procesará la lógica SQL.")

# 2. Conexión a SQL Server
try:
    conexion_sql = pyodbc.connect(
        "DRIVER={ODBC Driver 17 for SQL Server};"
        "SERVER=localhost\\SQLEXPRESS;"
        "DATABASE=BancoDB;"
        "Trusted_Connection=yes;"
    )
    cursor = conexion_sql.cursor()

    # 3. Extraer transacciones desde SQL Server
    cursor.execute("SELECT TransaccionID, TipoTransaccion, Monto, FechaTransaccion, Descripcion FROM Transacciones")
    registros = cursor.fetchall()

    print(f"✅ Se encontraron {len(registros)} transacciones en SQL Server (BancoDB).")

    # 4. Intentar Réplica NoSQL
    contador = 0
    for row in registros:
        doc = {
            "transaccion_id": row[0],
            "tipo": row[1],
            "monto": float(row[2]),
            "fecha": str(row[3]),
            "descripcion": row[4]
        }
        try:
            coleccion.update_one({"transaccion_id": row[0]}, {"$set": doc}, upsert=True)
            contador += 1
        except:
            pass

    if contador > 0:
        print(f"🚀 ¡Éxito! Se replicaron {contador} registros en MongoDB.")

    cursor.close()
    conexion_sql.close()

except Exception as err:
    print(f"❌ Error al conectar con SQL Server: {err}")