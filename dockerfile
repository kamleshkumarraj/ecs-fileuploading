# ===============================
# Single-stage, ROOT container
# ===============================
FROM node:18-alpine

WORKDIR /app

# Copy package files first
COPY package*.json ./
RUN npm install --production

# Copy app source
COPY . .

# Create uploads dir with FULL access
RUN mkdir -p /app/uploads && chmod -R 777 /app/uploads

EXPOSE 3000

# RUN AS ROOT (default)
CMD ["node", "app.js"]
