#!/bin/sh

# Script para iniciar ngrok
echo "🚀 Iniciando ngrok..."

# Configurar authtoken si está disponible
if [ ! -z "$NGROK_AUTHTOKEN" ]; then
    echo "🔑 Configurando authtoken..."
    ngrok config add-authtoken $NGROK_AUTHTOKEN
fi

# Iniciar ngrok en el puerto del frontend
echo "🌐 Exponiendo puerto 3000 (frontend)..."
ngrok http frontend_transito:80 --log=stdout
