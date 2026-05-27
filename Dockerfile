# Use the ultra-lightweight Alpine Linux version of Nginx
FROM nginx:alpine

# Remove the default Nginx welcome page
RUN rm /usr/share/nginx/html/index.html

# Copy our custom index.html into the Nginx web directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80 so traffic can access the container
EXPOSE 80
