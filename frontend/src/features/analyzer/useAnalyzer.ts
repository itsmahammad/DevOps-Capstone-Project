import { useCallback, useEffect, useState } from 'react';
import { api } from '@/lib/api';
import { AnalysisResult } from '@/types';

export function useAnalyzer() {
    const [isVerified, setIsVerified] = useState(false);
    const [isAnalyzing, setIsAnalyzing] = useState(false);
    const [results, setResults] = useState<AnalysisResult | null>(null);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        const verified = sessionStorage.getItem('backend_verified');
        if (verified === 'true') {
            setIsVerified(true);
        }
    }, []);

    const handleVerified = useCallback(() => {
        setIsVerified(true);
        sessionStorage.setItem('backend_verified', 'true');
    }, []);

    const handleAnalyze = useCallback(async (file: File) => {
        setIsAnalyzing(true);
        setError(null);
        setResults(null);

        const formData = new FormData();
        formData.append('file', file);

        try {
            const data = await api.analyzeResume(formData);
            setResults(data as AnalysisResult);
        } catch (err) {
            setError(err instanceof Error ? err.message : 'An error occurred');
        } finally {
            setIsAnalyzing(false);
        }
    }, []);

    const handleReset = useCallback(() => {
        setResults(null);
        setError(null);
    }, []);

    return {
        isVerified,
        isAnalyzing,
        results,
        error,
        handleVerified,
        handleAnalyze,
        handleReset,
    };
}
