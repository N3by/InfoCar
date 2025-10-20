# Dockerfile para el frontend React
FROM node:20-alpine as build

WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias y limpiar caché
RUN npm install && npm cache clean --force

# Copiar código fuente
COPY . .

# Configurar variable de entorno para la API (URL relativa para proxy)
ENV VITE_API_URL=

# Build para producción
RUN npm run build

# Etapa de producción con nginx
FROM nginx:alpine

# Copiar archivos build
COPY --from=build /app/dist /usr/share/nginx/html

# Copiar configuración de nginx
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
