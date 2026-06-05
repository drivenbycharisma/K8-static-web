FROM nginx:alpine

# Clear original root defaults
RUN rm /usr/share/nginx/html/index.html

# Transfer our advanced tracking panel to public server root
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 80
