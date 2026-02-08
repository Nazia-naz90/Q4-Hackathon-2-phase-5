# frontend/Dockerfile

# Multi-stage build for optimized production image
# Stage 1: Dependencies installation
FROM node:20-bookworm AS deps

# Install curl and python3 for potential build dependencies
RUN apt-get update && apt-get install -y curl python3 make g++ build-essential

# Working directory
WORKDIR /app

# Copy package files
COPY package.json ../package-lock.json* ./

# Install all dependencies (including dev dependencies) for the build process
RUN npm ci

# Stage 2: Build stage
FROM node:20-bookworm AS builder

# Install curl and build tools
RUN apt-get update && apt-get install -y curl python3 make g++ build-essential

# Working directory
WORKDIR /app

# Copy package files and installed dependencies from deps stage
COPY --from=deps /app/node_modules ./node_modules
COPY package.json ../package-lock.json* ./

# Copy entire frontend code (excluding files via .dockerignore)
COPY . .

# Build the application with specific environment to avoid Turbopack issues
RUN NEXT_PUBLIC_DOCKER_BUILD=1 npm run build

# Stage 3: Production stage - Install only production dependencies
FROM node:20-bookworm AS production-deps

# Install curl for health check
RUN apt-get update && apt-get install -y curl

# Working directory
WORKDIR /app

# Copy package files and install only production dependencies
COPY package.json ../package-lock.json* ./
RUN npm ci --only=production

# Stage 4: Final production stage
FROM node:20-bookworm AS production

# Install curl for health check
RUN apt-get update && apt-get install -y curl

# Create non-root user for security
RUN groupadd -g 1001 nodejs && \
    useradd -u 1001 -g nodejs nextjs

# Working directory
WORKDIR /app

# Copy necessary files from previous stages
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
COPY --from=production-deps /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Change ownership to non-root user
RUN chown -R nextjs:nodejs /app

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/api/health || exit 1

# Start Next.js app
CMD ["node", "server.js"]