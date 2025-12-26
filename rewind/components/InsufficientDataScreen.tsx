'use client';

import { motion } from 'framer-motion';
import { useRouter } from 'next/navigation';
import { signOut } from 'firebase/auth';
import { auth } from '@/services/firebaseConfig';
import { User } from '@/types';
import { ParticleBackground } from './ParticleBackground';
import { LogOut, AlertCircle, Play } from 'lucide-react';

interface InsufficientDataScreenProps {
  user: User;
}

export function InsufficientDataScreen({ user }: InsufficientDataScreenProps) {
  const router = useRouter();

  const handleLogout = async () => {
    try {
      await signOut(auth);
      router.push('/');
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  return (
    <div className="rewind-container flex items-center justify-center animated-gradient-bg">
      <ParticleBackground />
      
      <div className="relative z-10 text-center px-4 max-w-md">
        {/* Icon */}
        <motion.div
          initial={{ scale: 0.5, opacity: 0 }}
          animate={{ scale: 1, opacity: 1 }}
          transition={{ duration: 0.5 }}
          className="mb-8"
        >
          <div className="w-24 h-24 mx-auto rounded-2xl bg-gradient-to-br from-amber-500 to-orange-500 flex items-center justify-center">
            <AlertCircle className="w-12 h-12 text-white" />
          </div>
        </motion.div>

        {/* Title */}
        <motion.h1
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="font-display text-3xl sm:text-4xl font-bold mb-4"
        >
          <span className="text-white">Not Enough Data</span>
        </motion.h1>

        {/* Greeting */}
        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="text-white/70 text-lg mb-6"
        >
          Hey {user.displayName || 'there'}! 👋
        </motion.p>

        {/* Message */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.4 }}
          className="glass-card p-6 mb-8"
        >
          <p className="text-white/80 mb-4">
            It looks like you haven&apos;t watched enough anime yet to generate your 2025 Rewind.
          </p>
          <p className="text-white/60 text-sm">
            You need to have watched at least <strong className="text-primary-400">5 anime</strong> to unlock your personalized experience.
          </p>
        </motion.div>

        {/* Tips */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.5 }}
          className="glass-card p-6 mb-8 text-left"
        >
          <h3 className="font-semibold text-white mb-3 flex items-center gap-2">
            <Play className="w-4 h-4 text-primary-400" />
            Quick Tips
          </h3>
          <ul className="space-y-2 text-sm text-white/70">
            <li>• Start tracking your anime in the AniSurge app</li>
            <li>• Add at least 5 anime to your list</li>
            <li>• Come back when you&apos;ve watched more</li>
          </ul>
        </motion.div>

        {/* Actions */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.6 }}
          className="flex flex-col gap-3"
        >
          <a
            href="https://anisurge.app"
            target="_blank"
            rel="noopener noreferrer"
            className="btn-primary flex items-center justify-center gap-2"
          >
            <Play className="w-4 h-4" />
            Open AniSurge App
          </a>
          
          <button
            onClick={handleLogout}
            className="btn-secondary flex items-center justify-center gap-2"
          >
            <LogOut className="w-4 h-4" />
            Sign Out
          </button>
        </motion.div>
      </div>
    </div>
  );
}
