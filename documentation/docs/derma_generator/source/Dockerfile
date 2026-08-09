# Stage 1: Build the React application
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install


COPY . .
RUN npm run build

# Stage 2: Serve the app using a lightweight Nginx server
FROM nginx:alpine
# Copy the built files from the previous stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Create a custom Nginx config to handle React Router (Single Page App)
# This ensures that refreshing a page doesn't give a 404 error
RUN echo 'server { \
    listen 8080; \
    server_name localhost; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html index.htm; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Cloud Run expects the container to listen on port 8080
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
