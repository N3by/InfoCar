# main.py - Backend FastAPI básico
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import mysql.connector
from mysql.connector import pooling
import os
from datetime import date
import re

# =========================
# CONFIGURACIÓN
# =========================
app = FastAPI(
    title="API Consultas Vehiculares",
    description="API para consultar información de vehículos y propietarios",
    version="1.0.0"
)

# CORS para permitir tu frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Permitir cualquier origen para demo pública
    allow_credentials=False,  # Cambiar a False cuando allow_origins=["*"]
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configuración de base de datos
DB_CONFIG = {
    'user': os.getenv('DB_USER', 'root'),
    'password': os.getenv('DB_PASSWORD', 'root'),
    'host': os.getenv('DB_HOST', 'mysql'),
    'port': int(os.getenv('DB_PORT', 3306)),
    'database': os.getenv('DB_NAME', 'transito_db'),
    'charset': 'utf8mb4',
    'collation': 'utf8mb4_unicode_ci',
    'autocommit': True
}

# Pool de conexiones
connection_pool = None

def init_db_connection():
    """Inicializar conexión a la base de datos con retry"""
    global connection_pool
    max_retries = 10
    retry_count = 0
    
    while retry_count < max_retries:
        try:
            connection_pool = pooling.MySQLConnectionPool(
                pool_name="transito_pool",
                pool_size=5,
                pool_reset_session=True,
                **DB_CONFIG
            )
            print("✅ Conexión a MySQL establecida")
            return
        except Exception as e:
            retry_count += 1
            print(f"❌ Intento {retry_count} de conexión fallido: {e}")
            if retry_count >= max_retries:
                print("❌ No se pudo conectar a MySQL después de todos los intentos")
                connection_pool = None
                return
            import time
            time.sleep(3)  # Esperar 3 segundos antes del siguiente intento

# =========================
# MODELOS PYDANTIC
# =========================
class Propietario(BaseModel):
    cedula: str
    nombre: str
    telefono: Optional[str] = None
    email: Optional[str] = None
    direccion: Optional[str] = None

class Multa(BaseModel):
    id_multa: int
    fecha: date
    tipo_infraccion: str
    monto: float
    estado: str

class Documento(BaseModel):
    tipo: str
    estado: str
    vencimiento: date
    valor: Optional[str] = None

class HistorialPropietario(BaseModel):
    cedula: str
    nombre: str
    desde: str
    hasta: str

class Vehiculo(BaseModel):
    placa: str
    marca: Optional[str] = None
    modelo: Optional[int] = None
    tipo: Optional[str] = None
    cilindraje: Optional[int] = None
    propietario: Propietario
    documentos: List[Documento] = []
    multas: List[Multa] = []
    historial: List[HistorialPropietario] = []

class ConsultaResponse(BaseModel):
    success: bool
    message: str
    data: Optional[Vehiculo] = None

# =========================
# VALIDADORES
# =========================
def validar_cedula_colombiana(cedula: str) -> bool:
    """Valida formato de cédula colombiana"""
    cedula_limpia = cedula.replace(' ', '')
    
    # Solo números
    if not cedula_limpia.isdigit():
        return False
    
    # Longitud entre 6 y 10
    if len(cedula_limpia) < 6 or len(cedula_limpia) > 10:
        return False
    
    # No secuencia de números iguales
    if len(set(cedula_limpia)) == 1:
        return False
    
    return True

def validar_placa_colombiana(placa: str) -> bool:
    """Valida formato de placa colombiana"""
    placa_limpia = placa.replace(' ', '').upper()
    
    # Patrones válidos
    patrones = [
        r'^[A-Z]{3}-\d{3}$',      # ABC-123
        r'^[A-Z]{3}\d{3}$',       # ABC123
        r'^[A-Z]{3}-\d{4}$',      # ABC-1234
        r'^[A-Z]{3}\d{4}$',       # ABC1234
        r'^[A-Z]{3}-\d{2}[A-Z]$', # ABC-12A
        r'^[A-Z]{3}\d{2}[A-Z]$'   # ABC12A
    ]
    
    # Verificar patrón
    if not any(re.match(patron, placa_limpia) for patron in patrones):
        return False
    
    # Verificar que las letras no sean todas iguales
    letras = re.findall(r'[A-Z]', placa_limpia)
    if len(set(letras)) == 1 and len(letras) >= 3:
        return False
    
    return True

# =========================
# FUNCIONES DE BASE DE DATOS
# =========================
def get_db_connection():
    """Obtiene conexión del pool"""
    if not connection_pool:
        raise HTTPException(status_code=500, detail="Base de datos no disponible")
    return connection_pool.get_connection()

def consultar_vehiculo_completo(placa: str, cedula: str) -> Optional[Vehiculo]:
    """Consulta completa de vehículo con toda la información"""
    conn = None
    try:
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        # Consulta principal del vehículo y propietario
        query_principal = """
        SELECT 
            v.placa, v.marca, v.modelo, v.tipo, v.cilindraje,
            v.estado_soat, v.vencimiento_soat,
            v.estado_tecnomecanica, v.vencimiento_tecnomecanica,
            p.cedula, p.nombre, p.telefono, p.email, p.direccion
        FROM vehiculo v
        JOIN propietario p ON p.id_propietario = v.id_propietario
        WHERE v.placa = %s AND p.cedula = %s
        """
        
        cursor.execute(query_principal, (placa, cedula))
        resultado_principal = cursor.fetchone()
        
        if not resultado_principal:
            return None
        
        # Consultar multas
        query_multas = """
        SELECT id_multa, fecha, tipo_infraccion, monto, estado
        FROM multas
        WHERE id_vehiculo = (
            SELECT id_vehiculo FROM vehiculo WHERE placa = %s
        )
        ORDER BY fecha DESC
        """
        
        cursor.execute(query_multas, (placa,))
        multas_data = cursor.fetchall()
        
        # Consultar historial de propietarios
        query_historial = """
        SELECT cedula_antiguo_propietario as cedula, fecha_transferencia
        FROM historial_propietarios
        WHERE id_vehiculo = (
            SELECT id_vehiculo FROM vehiculo WHERE placa = %s
        )
        ORDER BY fecha_transferencia DESC
        """
        
        cursor.execute(query_historial, (placa,))
        historial_data = cursor.fetchall()
        
        # Construir respuesta
        propietario = Propietario(
            cedula=resultado_principal['cedula'],
            nombre=resultado_principal['nombre'],
            telefono=resultado_principal['telefono'],
            email=resultado_principal['email'],
            direccion=resultado_principal['direccion']
        )
        
        # Documentos
        documentos = [
            Documento(
                tipo="SOAT",
                estado=resultado_principal['estado_soat'],
                vencimiento=resultado_principal['vencimiento_soat'],
                valor="$150.000"
            ),
            Documento(
                tipo="Tecnomecánica",
                estado=resultado_principal['estado_tecnomecanica'],
                vencimiento=resultado_principal['vencimiento_tecnomecanica'],
                valor="$180.000"
            )
        ]
        
        # Multas
        multas = [
            Multa(
                id_multa=m['id_multa'],
                fecha=m['fecha'],
                tipo_infraccion=m['tipo_infraccion'],
                monto=float(m['monto']),
                estado=m['estado']
            ) for m in multas_data
        ]
        
        # Historial
        historial = [
            HistorialPropietario(
                cedula=h['cedula'],
                nombre=f"Propietario {h['cedula'][-3:]}",  # Nombre dummy
                desde=h['fecha_transferencia'].strftime('%Y'),
                hasta="Actual"
            ) for h in historial_data
        ]
        
        vehiculo = Vehiculo(
            placa=resultado_principal['placa'],
            marca=resultado_principal['marca'],
            modelo=resultado_principal['modelo'],
            tipo=resultado_principal['tipo'],
            cilindraje=resultado_principal['cilindraje'],
            propietario=propietario,
            documentos=documentos,
            multas=multas,
            historial=historial
        )
        
        return vehiculo
        
    except Exception as e:
        print(f"Error en consulta: {e}")
        return None
    finally:
        if conn:
            conn.close()

# =========================
# ENDPOINTS
# =========================
@app.get("/")
async def root():
    """Endpoint de bienvenida"""
    return {
        "message": "API Consultas Vehiculares",
        "version": "1.0.0",
        "docs": "/docs",
        "status": "running"
    }

@app.get("/api/consulta/{placa}/{cedula}", response_model=ConsultaResponse)
async def consultar_vehiculo(placa: str, cedula: str):
    """Consulta principal de vehículo por placa y cédula"""
    
    # Validaciones
    if not validar_placa_colombiana(placa):
        raise HTTPException(
            status_code=400, 
            detail="Formato de placa inválido. Ejemplos válidos: ABC-123, ABC123, ABC-1234"
        )
    
    if not validar_cedula_colombiana(cedula):
        raise HTTPException(
            status_code=400, 
            detail="Formato de cédula inválido. Debe tener entre 6 y 10 dígitos"
        )
    
    # Consulta a la base de datos
    resultado = consultar_vehiculo_completo(placa, cedula)
    
    if not resultado:
        return ConsultaResponse(
            success=False,
            message="No se encontró información para la placa y cédula proporcionadas"
        )
    
    return ConsultaResponse(
        success=True,
        message="Consulta exitosa",
        data=resultado
    )

@app.get("/api/health")
async def health_check():
    """Health check del sistema"""
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT 1")
        result = cursor.fetchone()  # Leer el resultado
        conn.close()
        return {"status": "healthy", "database": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}

# =========================
# INICIALIZACIÓN
# =========================
@app.on_event("startup")
async def startup_event():
    """Evento de inicio de la aplicación"""
    print("🚀 Iniciando API Consultas Vehiculares...")
    init_db_connection()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
