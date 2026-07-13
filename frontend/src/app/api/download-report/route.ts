import { NextRequest, NextResponse } from 'next/server';

// Runtime proxy for POST /api/download-report.
//
// This Route Handler reads process.env.API_URL at RUNTIME (not build time),
// so the Kubernetes env var takes effect after deploy. This replaces the
// old next.config.js `rewrites()` approach which baked the URL into the
// standalone bundle at build time.
export async function POST(request: NextRequest) {
  const apiBaseUrl = process.env.API_URL || 'http://localhost:8000';

  try {
    const body = await request.json();

    const backendRes = await fetch(`${apiBaseUrl}/api/download-report`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
      // Don't cache API requests.
      cache: 'no-store',
    });

    if (!backendRes.ok) {
      const data = await backendRes.json().catch(() => ({}));
      return NextResponse.json(data, { status: backendRes.status });
    }

    // The backend returns a PDF binary — pass it through unchanged.
    const pdfBuffer = await backendRes.arrayBuffer();
    return new NextResponse(pdfBuffer, {
      status: backendRes.status,
      headers: {
        'Content-Type': 'application/pdf',
        'Content-Disposition': 'attachment; filename="ats-resume-report.pdf"',
      },
    });
  } catch (error) {
    return NextResponse.json(
      { success: false, message: 'Backend unreachable' },
      { status: 502 }
    );
  }
}