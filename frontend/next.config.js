/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  output: 'standalone',
  // NOTE: Do NOT use next.config.js `rewrites()` for backend proxying.
  //
  // Next.js evaluates `rewrites()` at BUILD time and serializes the resolved
  // destination URLs into .next/required-server-files.js. If the env var
  // (API_URL) is not set during the Docker build, the default value
  // "http://localhost:8000" gets baked into the standalone bundle, and the
  // runtime env var set in Kubernetes is ignored — causing the production
  // server to proxy to localhost:8000 (ECONNREFUSED).
  //
  // Instead, backend proxying is done via App Router Route Handlers
  // (src/app/api/.../route.ts and src/app/health/route.ts) which read
  // process.env.API_URL at RUNTIME on every request.
};

module.exports = nextConfig;