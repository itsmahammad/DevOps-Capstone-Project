import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// =============================================================================
// k6 load test for Resume-ATS
// Usage: k6 run loadtest/k6-script.js
// Target: >=300 req/s at p95 <= 300ms for the /health endpoint
// Note: /api/analyze uses text-based PDFs (not scanned) to avoid slow OCR path.
// =============================================================================

// Custom metrics
const errorRate = new Rate('errors');
const analyzeLatency = new Trend('analyze_latency');

// Test configuration
export const options = {
  stages: [
    { duration: '30s', target: 50 },   // ramp up to 50 VUs
    { duration: '1m', target: 100 },   // ramp up to 100 VUs
    { duration: '2m', target: 300 },   // ramp up to 300 VUs (target load)
    { duration: '2m', target: 300 },   // hold at 300 VUs
    { duration: '30s', target: 0 },    // ramp down
  ],
  thresholds: {
    // p95 latency for health check must be <= 300ms
    'http_req_duration{endpoint:health}': ['p(95)<300'],
    // p95 latency for analyze (text PDF, no OCR) should be <= 2000ms
    'http_req_duration{endpoint:analyze}': ['p(95)<2000'],
    // Error rate must be < 1%
    errors: ['rate<0.01'],
  },
};

// Base URL — override with K6_BASE_URL env var
const BASE_URL = __ENV.K6_BASE_URL || 'http://localhost:8000';

// A minimal text-based PDF (not scanned) for /api/analyze testing.
// This is a simple PDF with text content that will use the standard
// extraction path, NOT the OCR fallback (which would be much slower).
// Place a sample text PDF at loadtest/sample-resume.pdf before running.
// If the file doesn't exist, the analyze test will be skipped.
let samplePdf = null;
try {
  samplePdf = open('./sample-resume.pdf', 'b');
} catch (e) {
  console.warn('sample-resume.pdf not found — /api/analyze tests will be skipped. Place a text-based PDF at loadtest/sample-resume.pdf');
}

export default function () {
  // ---- Health check (lightweight, high frequency) ----
  const healthRes = http.get(`${BASE_URL}/health`, {
    tags: { endpoint: 'health' },
  });

  check(healthRes, {
    'health status is 200': (r) => r.status === 200,
    'health body has status ok': (r) => r.json('status') === 'ok',
  });

  errorRate.add(healthRes.status !== 200);

  // ---- Analyze endpoint (heavier, lower frequency) ----
  // Only run if we have a sample PDF. Use 1-in-10 ratio to avoid overwhelming.
  if (samplePdf && __ITER % 10 === 0) {
    const formData = {
      file: http.file(samplePdf, 'resume.pdf', 'application/pdf'),
    };

    const analyzeRes = http.post(`${BASE_URL}/api/analyze`, formData, {
      tags: { endpoint: 'analyze' },
    });

    check(analyzeRes, {
      'analyze status is 200': (r) => r.status === 200,
      'analyze has ats_score': (r) => r.json('ats_score') !== undefined,
    });

    errorRate.add(analyzeRes.status !== 200);
    analyzeLatency.add(analyzeRes.timings.duration);
  }

  sleep(0.1);
}