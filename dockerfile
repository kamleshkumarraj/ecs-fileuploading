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
FROM node:18-alpine AS runner

WORKDIR /app

# 1️⃣ Create user FIRST (as root)
RUN addgroup -S nodegroup && adduser -S nodeuser -G nodegroup

# 2️⃣ Copy dependencies
COPY --from=deps /app/node_modules ./node_modules

# 3️⃣ Copy app source (still root)
COPY . .

# 4️⃣ Create uploads directory AND fix ownership (as root)
RUN mkdir -p /app/uploads \
    && chown -R nodeuser:nodegroup /app

# 5️⃣ Switch to non-root user (LAST STEP)
USER nodeuser

EXPOSE 3000
CMD ["node", "app.js"]
