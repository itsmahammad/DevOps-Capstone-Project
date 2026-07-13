'use client';

import { useState, useEffect, useCallback } from 'react';
import { Wifi, WifiOff } from 'lucide-react';

const POLL_INTERVAL = 30000;

export default function BackendStatusBanner() {
  const [isOnline, setIsOnline] = useState<boolean | null>(null); // null = checking

  const checkHealth = useCallback(async () => {
    try {
      const controller = new AbortController();
      const timeout = setTimeout(() => controller.abort(), 8000);
      // Use the same-origin /health path. Next.js rewrites this to the backend
      // via its server-side proxy (see next.config.js), so the browser never
      // needs to reach the (cluster-internal) backend directly.
      const res = await fetch('/health', { signal: controller.signal });
      clearTimeout(timeout);
      setIsOnline(res.ok);
    } catch {
      setIsOnline(false);
    }
  }, []);

  useEffect(() => {
    checkHealth();
    const interval = setInterval(checkHealth, POLL_INTERVAL);
    return () => clearInterval(interval);
  }, [checkHealth]);

  return (
    <div className="fixed top-[68px] left-1/2 -translate-x-1/2 z-40 transition-all duration-500">
      <div
        className={`flex items-center gap-2 px-4 py-1.5 rounded-full text-xs font-medium shadow-lg backdrop-blur-md border transition-all duration-500 ${isOnline === null
            ? 'bg-gray-800/80 border-gray-600/50 text-gray-300'
            : isOnline
              ? 'bg-emerald-900/80 border-emerald-500/30 text-emerald-300'
              : 'bg-red-900/80 border-red-500/30 text-red-300'
          }`}
      >
        {isOnline === null ? (
          <>
            <div className="w-2 h-2 rounded-full bg-gray-400 animate-pulse" />
            <span>Checking server...</span>
          </>
        ) : isOnline ? (
          <>
            <Wifi className="w-3.5 h-3.5" />
            <span>Server Online</span>
            <div className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
          </>
        ) : (
          <>
            <WifiOff className="w-3.5 h-3.5" />
            <span>Server Offline</span>
            <div className="w-2 h-2 rounded-full bg-red-400" />
          </>
        )}
      </div>
    </div>
  );
}
