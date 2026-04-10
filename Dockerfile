# Stage 1: Build the frontend
FROM node:20-alpine AS builder
WORKDIR /app

# Copy package files from pucho-dashboard
COPY pucho-dashboard/package.json pucho-dashboard/package-lock.json ./pucho-dashboard/

# Install dependencies for pucho-dashboard
RUN cd pucho-dashboard && npm install

# Copy all files for pucho-dashboard
COPY pucho-dashboard/ ./pucho-dashboard/

# Build the frontend
RUN cd pucho-dashboard && npm run build

# Stage 2: Production Server
FROM node:20-alpine AS runner
WORKDIR /app

# Set environment
ENV NODE_ENV=production
ENV PORT=5001

# Copy built assets and server file
COPY --from=builder /app/pucho-dashboard/dist ./dist
COPY --from=builder /app/pucho-dashboard/server.cjs ./server.cjs
COPY --from=builder /app/pucho-dashboard/package.json ./package.json

# Install production dependencies only
RUN npm install --omit=dev

# Expose the application port
EXPOSE 5001

# Start the bridge server which also serves the frontend
CMD ["node", "server.cjs"]
