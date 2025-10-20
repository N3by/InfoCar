#!/bin/bash

# Script para desarrollo local con Docker
echo "🚀 Iniciando desarrollo local con Docker..."
echo ""

# Verificar que Docker esté corriendo
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker no está corriendo. Por favor inicia Docker Desktop."
    exit 1
fi

# Iniciar servicios
echo "📦 Iniciando servicios Docker..."
docker-compose up -d

# Esperar a que los servicios estén listos
echo "⏳ Esperando a que los servicios estén listos..."
sleep 10

# Verificar estado de servicios
echo ""
echo "🔍 Verificando estado de servicios:"
echo ""

# Verificar MySQL
if docker exec mysql_transito mysql -u root -proot -e "SELECT 1" > /dev/null 2>&1; then
    echo "✅ MySQL: Conectado"
else
    echo "❌ MySQL: Error de conexión"
fi

# Verificar Backend
if curl -s http://localhost:8000/api/health > /dev/null 2>&1; then
    echo "✅ Backend: Funcionando"
else
    echo "❌ Backend: Error de conexión"
fi

# Verificar Frontend
if curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "✅ Frontend: Funcionando"
else
    echo "❌ Frontend: Error de conexión"
fi

echo ""
echo "🌐 URLs disponibles:"
echo "   Frontend: http://localhost:3000"
echo "   Backend:  http://localhost:8000"
echo "   API Docs: http://localhost:8000/docs"
echo "   Adminer:  http://localhost:8080"
echo ""
echo "📋 Para detener los servicios: docker-compose down"
echo "📋 Para ver logs: docker-compose logs -f"
echo ""
echo "🎉 ¡Desarrollo local listo!"
