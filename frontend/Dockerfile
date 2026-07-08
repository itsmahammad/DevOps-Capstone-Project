# ---- Build stage: install deps and build Next.js standalone ----
FROM node:20-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci --no-audit --no-fund

COPY . .
RUN npm run build

# ---- Runtime stage: slim image using Next.js standalone output ----
FROM node:20-alpine AS runtime

WORKDIR /app

ENV NODE_ENV=production

# Next.js standalone mode produces a self-contained server in .next/standalone
# that includes only the needed node_modules. We also copy static assets.
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/public ./public

EXPOSE 3000

# The standalone server.js is the entry point
CMD ["node", "server.js"]