import { NextResponse } from 'next/server';

// Runtime proxy for the backend /health endpoint.
//
// This Route Handler reads process.env.API_URL at RUNTIME (not build time),
// so the Kubernetes env var takes effect after deploy. This replaces the
// old next.config.js `rewrites()` approach which baked the URL into the
// standalone bundle at build time.
export async function GET() {
  const apiBaseUrl = process.env.API_URL || 'http://localhost:8000';

  try {
    const backendRes = await fetch(`${apiBaseUrl}/health`, {
      // Don't cache health checks — always hit the backend.
      cache: 'no-store',
    });

    const data = await backendRes.json().catch(() => ({}));
    return NextResponse.json(data, { status: backendRes.status });
  } catch (error) {
    return NextResponse.json(
      { status: 'error', message: 'Backend unreachable' },
      { status: 502 }
    );
  }
}