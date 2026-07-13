/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  output: 'standalone',
  async rewrites() {
    // Default to the local backend for development.
    // In production (Kubernetes), NEXT_PUBLIC_API_URL is set to the internal
    // backend service URL (e.g. http://backend.resumeats-prod.svc.cluster.local),
    // so the Next.js server-side rewrite proxy forwards requests to the backend
    // without exposing it to the Internet.
    const apiBaseUrl = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000';

    return [
      {
        source: '/api/:path*',
        destination: `${apiBaseUrl}/api/:path*`,
      },
      {
        // Health-check endpoint used by BackendStatusBanner and WakeUpScreen.
        // Routed through the Next.js server-side proxy so the browser never
        // needs to reach the backend directly (which is cluster-internal only).
        source: '/health',
        destination: `${apiBaseUrl}/health`,
      },
    ];
  },
};

module.exports = nextConfig;