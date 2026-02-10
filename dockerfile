# ===============================
# Stage 1: Dependencies
# ===============================
FROM node:18-alpine AS deps

WORKDIR /app

# Copy only package files first (better caching)
COPY package*.json ./

# Install only production dependencies
RUN npm ci --only=production

# ===============================
# Stage 2: Runtime Image
# ===============================
FROM node:18-alpine AS runner

WORKDIR /app

# Create non-root user
RUN addgroup -S nodegroup && adduser -S nodeuser -G nodegroup

# Copy node_modules from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy app source
COPY . .

# Ensure uploads directory exists
RUN mkdir -p uploads && chown -R nodeuser:nodegroup uploads

USER nodeuser

EXPOSE 3000

CMD ["node", "app.js"]
