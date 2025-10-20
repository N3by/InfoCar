# Dockerfile para ngrok
FROM alpine:latest

# Instalar ngrok
RUN apk add --no-cache curl unzip && \
    curl -s https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz | tar -xz -C /usr/local/bin

# Crear directorio de trabajo
WORKDIR /app

# Script para iniciar ngrok
COPY start-ngrok.sh /app/start-ngrok.sh
RUN chmod +x /app/start-ngrok.sh

EXPOSE 4040

CMD ["/app/start-ngrok.sh"]
