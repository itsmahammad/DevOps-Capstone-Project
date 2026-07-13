'use client';

import { useState, useEffect, useCallback } from 'react';
import { ShieldCheck, Loader2, CheckCircle2, WifiOff, RefreshCw } from 'lucide-react';

interface WakeUpScreenProps {
  onVerified: () => void;
}

export default function WakeUpScreen({ onVerified }: WakeUpScreenProps) {
  const [status, setStatus] = useState<'idle' | 'waking' | 'success' | 'error'>('idle');
  const [dots, setDots] = useState('');
  const [attempt, setAttempt] = useState(0);

  // Animate dots while waking
  useEffect(() => {
    if (status !== 'waking') return;
    const interval = setInterval(() => {
      setDots((prev) => (prev.length >= 3 ? '' : prev + '.'));
    }, 500);
    return () => clearInterval(interval);
  }, [status]);

  const pingBackend = useCallback(async (): Promise<boolean> => {
    try {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), 30000);
      // Use the same-origin /health path. Next.js rewrites this to the backend
      // via its server-side proxy (see next.config.js), so the browser never
      // needs to reach the (cluster-internal) backend directly.
      const res = await fetch('/health', { signal: controller.signal });
      clearTimeout(timeout);
      return res.ok;
    } catch {
      return false;
    }
  }, []);

  const handleVerify = async () => {
    setStatus('waking');
    setAttempt(0);

    // Retry up to 5 times — free-tier can take ~30s to wake
    for (let i = 0; i < 5; i++) {
      setAttempt(i + 1);
      const ok = await pingBackend();
      if (ok) {
        setStatus('success');
        // Small delay so user sees the success state
        setTimeout(() => onVerified(), 800);
        return;
      }
      // Wait a bit before retrying
      if (i < 4) await new Promise((r) => setTimeout(r, 3000));
    }

    setStatus('error');
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center bg-gradient-to-br from-gray-900 via-gray-800 to-gray-900">
      {/* Background decorations */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-brand-500/10 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-brand-600/10 rounded-full blur-3xl" />
      </div>

      <div className="relative w-full max-w-md mx-4">
        {/* Card */}
        <div className="bg-white/[0.03] backdrop-blur-xl border border-white/10 rounded-3xl p-8 sm:p-10 text-center shadow-2xl">
          {/* Logo area */}
          <div className="mb-6">
            <div className="w-16 h-16 mx-auto bg-gradient-to-br from-brand-500 to-brand-600 rounded-2xl flex items-center justify-center shadow-lg shadow-brand-500/30 mb-4">
              <ShieldCheck className="w-8 h-8 text-white" />
            </div>
            <h1 className="text-2xl font-bold text-white font-display">
              ATS<span className="text-brand-400">Analyzer</span>
            </h1>
          </div>

          {/* Status-specific content */}
          {status === 'idle' && (
            <>
              <p className="text-gray-400 mb-2 text-sm">
                Quick verification required
              </p>
              <p className="text-gray-500 mb-8 text-xs leading-relaxed">
                Our backend runs on a free tier and may be sleeping.
                Click below to wake it up and verify you're a real person.
              </p>

              <button
                onClick={handleVerify}
                className="group relative w-full bg-white/5 hover:bg-white/10 border border-white/20 hover:border-brand-500/50 rounded-2xl p-5 transition-all duration-300 cursor-pointer"
              >
                <div className="flex items-center gap-4">
                  {/* Checkbox */}
                  <div className="w-7 h-7 rounded-lg border-2 border-gray-500 group-hover:border-brand-500 flex items-center justify-center transition-colors">
                    <div className="w-3 h-3 rounded-sm bg-transparent group-hover:bg-brand-500/30 transition-colors" />
                  </div>
                  <span className="text-gray-300 font-medium text-lg">
                    I'm not a robot
                  </span>
                </div>
              </button>

              <p className="text-gray-600 mt-6 text-xs">
                This wakes up our analysis server so you can use the tool
              </p>
            </>
          )}

          {status === 'waking' && (
            <>
              <div className="mb-6">
                <Loader2 className="w-10 h-10 text-brand-400 mx-auto animate-spin" />
              </div>
              <p className="text-white font-semibold text-lg mb-2">
                Waking up server{dots}
              </p>
              <p className="text-gray-400 text-sm mb-4">
                Free-tier servers sleep when inactive. This may take up to 30-60 seconds.
              </p>

              {/* Progress indicator */}
              <div className="flex items-center justify-center gap-2 mb-4">
                {[1, 2, 3, 4, 5].map((n) => (
                  <div
                    key={n}
                    className={`w-2.5 h-2.5 rounded-full transition-all duration-500 ${n < attempt
                        ? 'bg-brand-500'
                        : n === attempt
                          ? 'bg-brand-400 animate-pulse'
                          : 'bg-gray-700'
                      }`}
                  />
                ))}
              </div>
              <p className="text-gray-600 text-xs">
                Attempt {attempt} of 5
              </p>

              {/* Fun waiting tips */}
              <div className="mt-6 p-3 bg-white/5 rounded-xl border border-white/5">
                <p className="text-gray-500 text-xs italic">
                  💡 Tip: Grab a coffee while the server wakes up!
                </p>
              </div>
            </>
          )}

          {status === 'success' && (
            <>
              <div className="mb-6">
                <div className="w-16 h-16 mx-auto bg-success-500/20 rounded-2xl flex items-center justify-center">
                  <CheckCircle2 className="w-10 h-10 text-success-500" />
                </div>
              </div>
              <p className="text-white font-semibold text-lg mb-2">
                Server is online!
              </p>
              <p className="text-gray-400 text-sm">
                Redirecting you to the analyzer...
              </p>
            </>
          )}

          {status === 'error' && (
            <>
              <div className="mb-6">
                <div className="w-16 h-16 mx-auto bg-danger-500/20 rounded-2xl flex items-center justify-center">
                  <WifiOff className="w-10 h-10 text-danger-500" />
                </div>
              </div>
              <p className="text-white font-semibold text-lg mb-2">
                Server is unavailable
              </p>
              <p className="text-gray-400 text-sm mb-6">
                The server couldn't be reached after multiple attempts.
                It may be undergoing maintenance.
              </p>
              <button
                onClick={handleVerify}
                className="inline-flex items-center gap-2 px-6 py-3 bg-brand-600 hover:bg-brand-700 text-white font-semibold rounded-xl transition-colors"
              >
                <RefreshCw className="w-4 h-4" />
                Try Again
              </button>
              <button
                onClick={onVerified}
                className="block mx-auto mt-4 text-gray-500 hover:text-gray-400 text-sm underline transition-colors"
              >
                Continue anyway →
              </button>
            </>
          )}
        </div>
      </div>
    </div>
  );
}