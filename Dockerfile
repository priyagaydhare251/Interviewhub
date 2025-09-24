# ---- Base image ----
FROM node:18-alpine AS base

# Set working directory inside container
WORKDIR /app

# Copy package files first (for dependency caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the project
COPY . .

# Build Next.js app (frontend + backend)
RUN npm run build

# ---- Production image ----
FROM node:18-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Copy only necessary files from builder
COPY --from=base /app/package*.json ./
COPY --from=base /app/node_modules ./node_modules
COPY --from=base /app/.next ./.next
COPY --from=base /app/public ./public
COPY --from=base /app/next.config.mjs ./next.config.mjs

# Expose port
EXPOSE 3000

# Start Next.js server (runs frontend + backend APIs)
CMD ["npm", "start"]
