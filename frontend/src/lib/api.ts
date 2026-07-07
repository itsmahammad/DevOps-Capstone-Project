const API_BASE_URL = '';

async function request<T>(path: string, init?: RequestInit): Promise<T> {
    const response = await fetch(`${API_BASE_URL}${path}`, init);
    const data = await response.json().catch(() => ({}));

    if (!response.ok) {
        throw new Error(data.message || data.error || 'Request failed');
    }

    return data as T;
}

export const api = {
    analyzeResume: (formData: FormData) => request('/api/analyze', { method: 'POST', body: formData }),
    downloadReport: (payload: unknown) =>
        fetch('/api/download-report', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(payload),
        }),
};
