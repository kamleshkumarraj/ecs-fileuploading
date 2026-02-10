# ===============================
# Stage 1: Dependencies
# ===============================
FROM node:18-alpine AS deps

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# ===============================
# Stage 2: Runtime
# ===============================
FROM node:18-alpine

WORKDIR /app

# Create user
RUN addgroup -S nodegroup && adduser -S nodeuser -G nodegroup

# Copy deps and app
COPY --from=deps /app/node_modules ./node_modules
COPY . .

# Create uploads dir + give FULL ACCESS
RUN mkdir -p /app/uploads \
    && chmod -R 777 /app/uploads

# Switch user
USER nodeuser

EXPOSE 3000
CMD ["node", "app.js"]
