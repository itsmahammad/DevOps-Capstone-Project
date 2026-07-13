# ---- Build stage: install deps and build Next.js standalone ----
FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci --no-audit --no-fund

COPY . .
RUN npm run build

# ---- Runtime stage: slim image using Next.js standalone output ----
FROM node:20-alpine AS runtime

# Apply security updates for base image packages (e.g. OpenSSL fixes)
RUN apk update && apk upgrade --no-cache

WORKDIR /app

ENV NODE_ENV=production

# Next.js standalone mode produces a self-contained server in .next/standalone
# that includes only the needed node_modules. We also copy static assets.
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/public ./public

# The node:20-alpine image includes a built-in non-root user "node" (UID 1000).
# We ensure all application files are owned by this user, then switch to it.
# This follows the principle of least privilege — the process should never run as root.
RUN chown -R node:node /app
USER node

EXPOSE 3000

# The standalone server.js is the entry point
CMD ["node", "server.js"]
