# ---- Base image ----
FROM node:18-alpine AS base

# Set working directory
WORKDIR /app

# ---- Build arguments for build-time env variables ----
ARG NEXT_PUBLIC_CONVEX_URL
ARG NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
ARG NEXT_PUBLIC_STREAM_API_KEY

# ---- Set environment variables for Next.js build ----
ENV NEXT_PUBLIC_CONVEX_URL=$NEXT_PUBLIC_CONVEX_URL
ENV NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=$NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
ENV NEXT_PUBLIC_STREAM_API_KEY=$NEXT_PUBLIC_STREAM_API_KEY

# ---- Copy package files first (for caching dependencies) ----
COPY package*.json ./

# ---- Install dependencies ----
RUN npm install

# ---- Copy the rest of the app ----
COPY . .

# ---- Build Next.js app ----
RUN npm run build

# ---- Production image ----
FROM node:18-alpine AS prod

WORKDIR /app

# Copy only production dependencies
COPY package*.json ./
RUN npm install --production

# Copy built Next.js app from builder
COPY --from=base /app/.next ./.next
COPY --from=base /app/public ./public
# COPY --from=base /app/next.config.js ./   <-- REMOVED because file not present
COPY --from=base /app/node_modules ./node_modules

# Expose port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
