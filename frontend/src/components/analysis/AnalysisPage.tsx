'use client';

import { useAnalyzer } from '@/features/analyzer/useAnalyzer';
import Header from '@/components/Header';
import Hero from '@/components/Hero';
import HowItWorks from '@/components/HowItWorks';
import Features from '@/components/Features';
import UploadSection from '@/components/UploadSection';
import ResultsDashboard from '@/components/ResultsDashboard';
import ContactSection from '@/components/ContactSection';
import PrivacyBanner from '@/components/PrivacyBanner';
import Footer from '@/components/Footer';
import LoadingOverlay from '@/components/LoadingOverlay';
import WakeUpScreen from '@/components/WakeUpScreen';
import BackendStatusBanner from '@/components/BackendStatusBanner';

export default function AnalysisPage() {
    const { isVerified, isAnalyzing, results, error, handleVerified, handleAnalyze, handleReset } = useAnalyzer();

    return (
        <main className="min-h-screen">
            {!isVerified && <WakeUpScreen onVerified={handleVerified} />}
            <Header />
            <BackendStatusBanner />
            {isAnalyzing && <LoadingOverlay />}
            {results ? (
                <ResultsDashboard results={results} onReset={handleReset} />
            ) : (
                <>
                    <Hero />
                    <UploadSection onAnalyze={handleAnalyze} error={error} />
                    <HowItWorks />
                    <Features />
                    <PrivacyBanner />
                    <ContactSection />
                </>
            )}
            <Footer />
        </main>
    );
}
