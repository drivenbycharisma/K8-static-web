FROM node:18-alpine

# Install kubectl directly into the container so it can poll its own cluster
RUN apk add --no-cache curl \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

WORKDIR /app
COPY package*.json ./
RUN npm install express
COPY . .

EXPOSE 80
CMD ["node", "metrics-server.js"]
