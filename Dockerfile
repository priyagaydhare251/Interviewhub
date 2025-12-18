# -----------------------------
# ---- Base Image (from Docker Hub)
# -----------------------------
FROM node:18-alpine AS base

WORKDIR /app

# ---- Build-time environment variables ----
ARG NEXT_PUBLIC_CONVEX_URL
ARG NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
ARG NEXT_PUBLIC_STREAM_API_KEY

ENV NEXT_PUBLIC_CONVEX_URL=$NEXT_PUBLIC_CONVEX_URL
ENV NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=$NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY
ENV NEXT_PUBLIC_STREAM_API_KEY=$NEXT_PUBLIC_STREAM_API_KEY

# Copy package files first (cache layer)
COPY package*.json ./

RUN npm install --force

# Copy the complete project
COPY . .

# Build the Next.js application
RUN npm run build


# -----------------------------
# ---- Production Image -------
# -----------------------------
FROM node:18-alpine AS prod

WORKDIR /app

COPY package*.json ./
RUN npm install --omit=dev --force

COPY --from=base /app/.next ./.next
COPY --from=base /app/public ./public
COPY --from=base /app/node_modules ./node_modules

EXPOSE 3000

CMD ["npm", "start"]
