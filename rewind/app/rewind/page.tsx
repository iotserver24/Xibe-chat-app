'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { onAuthStateChanged, User as FirebaseUser } from 'firebase/auth';
import { auth } from '@/services/firebaseConfig';
import { User, LOADING_MESSAGES } from '@/types';
import { useRewindData } from '@/hooks/useRewindData';
import { useSlideNavigation } from '@/hooks/useSlideNavigation';
import { RewindContainer } from '@/components/RewindContainer';
import { LoadingScreen } from '@/components/LoadingScreen';
import { InsufficientDataScreen } from '@/components/InsufficientDataScreen';
import { ErrorScreen } from '@/components/ErrorScreen';
import { ParticleBackground } from '@/components/ParticleBackground';

export default function RewindPage() {
  const router = useRouter();
  const [firebaseUser, setFirebaseUser] = useState<FirebaseUser | null>(null);
  const [authLoading, setAuthLoading] = useState(true);

  // Convert Firebase user to our User type
  const user: User | null = firebaseUser
    ? {
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        photoURL: firebaseUser.photoURL,
        createdAt: new Date(firebaseUser.metadata.creationTime || Date.now()),
        lastLoginAt: new Date(firebaseUser.metadata.lastSignInTime || Date.now()),
      }
    : null;

  const { stats, loadingState, error, refetch, aiImageUrl, isAiImageLoading } = useRewindData(user);
  const slideNavigation = useSlideNavigation();

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (fbUser) => {
      setFirebaseUser(fbUser);
      setAuthLoading(false);
      
      if (!fbUser) {
        router.push('/');
      }
    });

    return () => unsubscribe();
  }, [router]);

  // Show loading while checking auth
  if (authLoading) {
    return (
      <div className="rewind-container flex items-center justify-center animated-gradient-bg">
        <ParticleBackground />
        <div className="loading-spinner" />
      </div>
    );
  }

  // Redirect if not authenticated
  if (!firebaseUser || !user) {
    return null;
  }

  // Show loading screen while fetching data or in idle state (before query starts)
  if (loadingState === 'loading' || loadingState === 'idle') {
    return <LoadingScreen messages={LOADING_MESSAGES} />;
  }

  // Show insufficient data screen
  if (loadingState === 'insufficient-data') {
    return <InsufficientDataScreen user={user} />;
  }

  // Show error screen
  if (loadingState === 'error') {
    return <ErrorScreen error={error || 'Something went wrong'} onRetry={refetch} />;
  }

  // Show rewind experience
  if (loadingState === 'success' && stats) {
    return (
      <RewindContainer
        user={user}
        stats={stats}
        slideNavigation={slideNavigation}
        aiImageUrl={aiImageUrl}
        isAiImageLoading={isAiImageLoading}
      />
    );
  }

  // Fallback to loading screen for any unhandled state
  return <LoadingScreen messages={LOADING_MESSAGES} />;
}
