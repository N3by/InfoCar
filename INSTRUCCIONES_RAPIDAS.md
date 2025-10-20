# 🚀 INSTRUCCIONES RÁPIDAS - Sistema de Consultas Vehiculares

## 📋 **Para Reiniciar el Desarrollo**

### **Opción 1: Desarrollo Local (Recomendado)**
```bash
cd vehiculos-dashboard
npm run dev
# URL: http://localhost:5173
# Cambios instantáneos con hot reload
```

### **Opción 2: Stack Completo con Docker**
```bash
./start-local.sh
# URLs:
# - Frontend: http://localhost:3000
# - Backend: http://localhost:8000
# - API Docs: http://localhost:8000/docs
# - Adminer: http://localhost:8080
```

### **Opción 3: Demo Pública**
```bash
./start-local.sh
./start-demo.sh
# URL pública generada automáticamente
```

## 🧪 **Datos de Prueba**
- **Placa**: XYZ001
- **Cédula**: 1000000001

## 📁 **Archivos Principales**
- **Frontend**: `vehiculos-dashboard/src/DashboardMVP.jsx`
- **Backend**: `backend/main.py`
- **Base de datos**: `database/init.sql`

## 🔧 **Comandos Útiles**
```bash
# Ver contenedores
docker ps

# Ver logs
docker-compose logs -f

# Detener todo
docker-compose down

# Rebuild frontend
docker-compose build frontend
```

## 🎯 **Estado Actual**
✅ Todo cerrado correctamente
✅ Código fuente guardado
✅ Base de datos persistente
✅ Scripts listos para usar

¡Listo para continuar cuando quieras! 🚀
