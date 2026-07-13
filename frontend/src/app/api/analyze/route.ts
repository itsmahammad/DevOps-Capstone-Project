import { NextRequest, NextResponse } from 'next/server';

// Runtime proxy for POST /api/analyze.
//
// This Route Handler reads process.env.API_URL at RUNTIME (not build time),
// so the Kubernetes env var takes effect after deploy. This replaces the
// old next.config.js `rewrites()` approach which baked the URL into the
// standalone bundle at build time.
export async function POST(request: NextRequest) {
  const apiBaseUrl = process.env.API_URL || 'http://localhost:8000';

  try {
    const formData = await request.formData();

    const backendRes = await fetch(`${apiBaseUrl}/api/analyze`, {
      method: 'POST',
      body: formData,
      // Don't cache API requests.
      cache: 'no-store',
    });

    const data = await backendRes.json().catch(() => ({}));
    return NextResponse.json(data, { status: backendRes.status });
  } catch (error) {
    return NextResponse.json(
      { success: false, message: 'Backend unreachable' },
      { status: 502 }
    );
  }
}