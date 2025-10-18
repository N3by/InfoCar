# 🚀 Dashboard de Consultas Vehiculares

## 📋 **Descripción**

Sistema completo de consultas vehiculares desarrollado con tecnologías modernas:

- **Frontend**: React + TailwindCSS + Vite
- **Backend**: FastAPI + Python
- **Base de Datos**: MySQL
- **Deploy**: Docker + Cloudflare Tunnel

## 🎯 **Características**

- ✅ **Validaciones Colombianas**: Cédula y placa según estándares nacionales
- ✅ **Interfaz Moderna**: Dashboard responsive con modo oscuro/claro
- ✅ **API REST**: Endpoints documentados con FastAPI
- ✅ **Base de Datos**: MySQL con datos de prueba incluidos
- ✅ **Dockerizado**: Fácil despliegue y desarrollo
- ✅ **Demo Pública**: Acceso mundial con Cloudflare Tunnel

## 🚀 **Inicio Rápido**

### **Prerrequisitos**
- Docker y Docker Compose
- Git

### **Instalación**
```bash
# 1. Clonar el repositorio
git clone <tu-repositorio>
cd testing-project

# 2. Desarrollo local
./start-local.sh

# 3. Abrir en el navegador
# http://localhost:3000
```

### **Demo Pública**
```bash
# Para crear una demo pública
./start-demo.sh
```

## 📦 **Servicios Incluidos**

| Servicio | Puerto | Descripción |
|----------|--------|-------------|
| **Frontend** | 3000 | React app con validaciones |
| **Backend** | 8000 | API REST con FastAPI |
| **MySQL** | 3306 | Base de datos |
| **Adminer** | 8080 | Interfaz web para MySQL |
| **Cloudflare** | - | Tunnel para demo pública |

## 🌐 **URLs Disponibles**

### **Desarrollo Local**
- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs
- **Adminer**: http://localhost:8080

### **Demo Pública**
- URL generada automáticamente por Cloudflare Tunnel

## 🧪 **Datos de Prueba**

| Placa | Cédula | Descripción |
|-------|--------|-------------|
| `XYZ001` | `1000000001` | Vehículo con multa pagada |
| `XYZ002` | `1000000002` | Vehículo con multa pendiente |
| `XYZ003` | `1000000003` | Vehículo con documentos vencidos |
| `XYZ004` | `1000000004` | Vehículo sin problemas |

## 🔧 **Comandos Útiles**

```bash
# Ver estado de contenedores
docker ps

# Ver logs en tiempo real
docker-compose logs -f

# Detener todos los servicios
docker-compose down

# Reiniciar servicios específicos
docker-compose restart backend

# Reconstruir imágenes
docker-compose build --no-cache
```

## 📁 **Estructura del Proyecto**

```
testing-project/
├── start-local.sh              # Script desarrollo local
├── start-demo.sh               # Script demo pública
├── docker-compose.yml          # Orquestación Docker
├── .gitignore                  # Archivos a ignorar en Git
├── backend/                    # API FastAPI
│   ├── main.py                 # Código principal del backend
│   ├── requirements.txt        # Dependencias Python
│   └── Dockerfile              # Imagen Docker backend
├── vehiculos-dashboard/        # Frontend React
│   ├── src/                    # Código fuente React
│   ├── package.json            # Dependencias Node.js
│   ├── Dockerfile              # Imagen Docker frontend
│   └── nginx.conf              # Configuración Nginx
├── database/                   # MySQL + datos
│   └── init.sql                # Script inicialización BD
└── ngrok/                      # Configuración ngrok (opcional)
```

## 🛠️ **Desarrollo**

### **Frontend**
- **Framework**: React 18
- **Styling**: TailwindCSS
- **Build**: Vite
- **Validaciones**: Cédula y placa colombianas

### **Backend**
- **Framework**: FastAPI
- **Base de Datos**: MySQL 8.0
- **ORM**: SQLAlchemy
- **Validaciones**: Pydantic

### **Base de Datos**
- **Motor**: MySQL 8.0
- **Datos**: Incluye datos de prueba
- **Inicialización**: Script automático

## 🚨 **Solución de Problemas**

### **Error de Puerto en Uso**
```bash
# Detener servicios
docker-compose down

# Verificar puertos ocupados
lsof -i :3000
lsof -i :8000
```

### **Error de Base de Datos**
```bash
# Recrear volúmenes
docker-compose down -v
docker-compose up --build
```

### **Error de CORS**
- El backend está configurado para permitir cualquier origen
- Si persiste, verificar configuración de proxy en nginx.conf

## 📝 **API Endpoints**

### **Consultas**
- `GET /api/consulta/{placa}/{cedula}` - Consulta principal
- `GET /api/health` - Estado del sistema

### **Ejemplo de Uso**
```bash
curl "http://localhost:8000/api/consulta/XYZ001/1000000001"
```

## 🎉 **¡Listo para Usar!**

El sistema está completamente funcional y listo para:
- ✅ Desarrollo local
- ✅ Demos públicas
- ✅ Despliegue en producción
- ✅ Contribuciones de la comunidad

## 📄 **Licencia**

Este proyecto está disponible bajo la licencia MIT.
# consultCar
# ConsultCart
