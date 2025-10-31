# Use the official Nginx image to serve static files
FROM nginx:alpine

# Copy static files to the default Nginx public directory
COPY . /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx server
CMD ["nginx", "-g", "daemon off;"]