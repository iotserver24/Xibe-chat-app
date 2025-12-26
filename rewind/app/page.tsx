'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { motion, AnimatePresence } from 'framer-motion';
import { onAuthStateChanged, User as FirebaseUser } from 'firebase/auth';
import { auth } from '@/services/firebaseConfig';
import { LoginForm } from '@/components/Auth/LoginForm';
import { ParticleBackground } from '@/components/ParticleBackground';

export default function HomePage() {
  const router = useRouter();
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (firebaseUser: FirebaseUser | null) => {
      if (firebaseUser) {
        // Redirect authenticated users without setting loading to false
        // This prevents the login UI from flashing
        router.push('/rewind');
      } else {
        // Only show login UI when we know user is not authenticated
        setLoading(false);
      }
    });

    return () => unsubscribe();
  }, [router]);

  if (loading) {
    return (
      <div className="rewind-container flex items-center justify-center animated-gradient-bg">
        <ParticleBackground />
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="text-center z-10"
        >
          <div className="loading-spinner mx-auto mb-4" />
          <p className="text-white/70">Loading...</p>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="rewind-container animated-gradient-bg overflow-y-auto">
      <ParticleBackground />
      
      <div className="min-h-screen flex flex-col items-center justify-center px-4 py-12 relative z-10">
        <AnimatePresence mode="wait">
          <motion.div
            key="landing"
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            transition={{ duration: 0.5 }}
            className="w-full max-w-md mx-auto text-center"
          >
            {/* Logo */}
            <motion.div
              initial={{ scale: 0.8, opacity: 0 }}
              animate={{ scale: 1, opacity: 1 }}
              transition={{ delay: 0.2, duration: 0.5 }}
              className="mb-8"
            >
              <div className="w-20 h-20 mx-auto mb-4 rounded-2xl bg-gradient-to-br from-primary-500 to-accent-500 flex items-center justify-center glow-primary">
                <span className="text-4xl">🎌</span>
              </div>
            </motion.div>

            {/* Title */}
            <motion.h1
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3, duration: 0.5 }}
              className="font-display text-4xl sm:text-5xl font-bold mb-4"
            >
              <span className="gradient-text">AniSurge</span>
              <br />
              <span className="text-white">Rewind 2025</span>
            </motion.h1>

            {/* Subtitle */}
            <motion.p
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.4, duration: 0.5 }}
              className="text-white/70 text-lg mb-8"
            >
              Discover your anime watching journey
            </motion.p>

            {/* Features */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.5, duration: 0.5 }}
              className="grid grid-cols-3 gap-4 mb-8"
            >
              {[
                { icon: '📊', label: 'Stats' },
                { icon: '🏆', label: 'Top Anime' },
                { icon: '✨', label: 'Personality' },
              ].map((feature, index) => (
                <motion.div
                  key={feature.label}
                  initial={{ opacity: 0, scale: 0.8 }}
                  animate={{ opacity: 1, scale: 1 }}
                  transition={{ delay: 0.6 + index * 0.1 }}
                  className="glass-card p-4 text-center"
                >
                  <span className="text-2xl mb-2 block">{feature.icon}</span>
                  <span className="text-sm text-white/70">{feature.label}</span>
                </motion.div>
              ))}
            </motion.div>

            {/* Login Form */}
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.8, duration: 0.5 }}
            >
              <LoginForm />
            </motion.div>

            {/* Footer */}
            <motion.p
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 1, duration: 0.5 }}
              className="mt-8 text-white/40 text-sm"
            >
              Sign in to see your personalized rewind
            </motion.p>
          </motion.div>
        </AnimatePresence>
      </div>
    </div>
  );
}
