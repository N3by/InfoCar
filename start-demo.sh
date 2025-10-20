#!/bin/bash

# Script para demo pública con Cloudflare Tunnel
echo "🌐 Iniciando demo pública con Cloudflare Tunnel..."
echo ""

# Verificar que cloudflared esté instalado
if ! command -v cloudflared &> /dev/null; then
    echo "❌ cloudflared no está instalado."
    echo "   Instala con: brew install cloudflared"
    exit 1
fi

# Verificar que los servicios locales estén corriendo
if ! curl -s http://localhost:3000 > /dev/null 2>&1; then
    echo "❌ El frontend no está corriendo en localhost:3000"
    echo "   Primero ejecuta: ./start-local.sh"
    exit 1
fi

echo "✅ Frontend local verificado"
echo ""

# Iniciar Cloudflare Tunnel
echo "🚀 Iniciando Cloudflare Tunnel..."
echo "   Esto creará una URL pública para tu demo"
echo "   Presiona Ctrl+C para detener"
echo ""

# Ejecutar cloudflared
cloudflared tunnel --url http://localhost:3000
