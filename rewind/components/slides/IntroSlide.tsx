'use client';

import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { SlideProps } from '@/types';
import { formatDate, getJourneyLength } from '@/utils/rewindUtils';
import { 
  letterContainerVariants, 
  letterVariants, 
  fadeInUpVariants,
  staggerContainerVariants,
  staggerItemVariants 
} from '@/utils/animations';

export function IntroSlide({ stats, user, isActive }: SlideProps) {
  const [showContent, setShowContent] = useState(false);

  useEffect(() => {
    if (isActive) {
      const timer = setTimeout(() => setShowContent(true), 500);
      return () => clearTimeout(timer);
    }
  }, [isActive]);

  const titleLetters = "REWIND".split('');
  const yearLetters = "2025".split('');

  return (
    <div className="slide-wrapper">
      <div className="content-container text-center">
        {/* Animated title */}
        <div className="mb-8">
          <motion.div
            variants={letterContainerVariants}
            initial="hidden"
            animate={isActive ? "visible" : "hidden"}
            className="flex justify-center mb-2"
          >
            {titleLetters.map((letter, index) => (
              <motion.span
                key={index}
                variants={letterVariants}
                className="font-display text-6xl sm:text-7xl md:text-8xl lg:text-9xl font-black gradient-text inline-block"
                style={{ 
                  textShadow: '0 0 40px rgba(217, 70, 239, 0.5)',
                }}
              >
                {letter}
              </motion.span>
            ))}
          </motion.div>

          <motion.div
            variants={letterContainerVariants}
            initial="hidden"
            animate={isActive ? "visible" : "hidden"}
            className="flex justify-center"
          >
            {yearLetters.map((letter, index) => (
              <motion.span
                key={index}
                variants={letterVariants}
                className="font-display text-5xl sm:text-6xl md:text-7xl lg:text-8xl font-black text-white inline-block"
              >
                {letter}
              </motion.span>
            ))}
          </motion.div>
        </div>

        {/* User greeting */}
        {showContent && (
          <motion.div
            variants={staggerContainerVariants}
            initial="hidden"
            animate="visible"
            className="space-y-6"
          >
            <motion.div
              variants={staggerItemVariants}
              className="flex items-center justify-center gap-3"
            >
              {user.photoURL && (
                <motion.img
                  src={user.photoURL}
                  alt={user.displayName || 'User'}
                  className="w-12 h-12 rounded-full border-2 border-primary-500/50"
                  initial={{ scale: 0 }}
                  animate={{ scale: 1 }}
                  transition={{ delay: 0.5, type: 'spring' }}
                />
              )}
              <motion.h2
                className="text-2xl sm:text-3xl md:text-4xl font-bold text-white"
              >
                Hey, {user.displayName?.split(' ')[0] || 'there'}! 👋
              </motion.h2>
            </motion.div>

            <motion.p
              variants={staggerItemVariants}
              className="text-lg sm:text-xl text-white/70"
            >
              Let&apos;s look back at your incredible anime journey
            </motion.p>

            {/* Journey stats */}
            <motion.div
              variants={staggerItemVariants}
              className="glass-card p-6 max-w-md mx-auto"
            >
              <div className="flex items-center justify-center gap-2 mb-3">
                <span className="text-2xl">🗓️</span>
                <span className="text-white/60">Your journey started</span>
              </div>
              
              <p className="text-xl sm:text-2xl font-semibold text-white mb-2">
                {formatDate(stats.accountCreatedAt)}
              </p>
              
              <p className="text-primary-400 font-medium">
                {getJourneyLength(stats.accountCreatedAt)} of anime adventures
              </p>
            </motion.div>

            {/* First anime hint */}
            {stats.firstAnimeWatched && (
              <motion.p
                variants={staggerItemVariants}
                className="text-white/50 text-sm"
              >
                First anime: <span className="text-primary-400">{stats.firstAnimeWatched}</span>
              </motion.p>
            )}
          </motion.div>
        )}

        {/* Decorative elements */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 1.5 }}
          className="absolute bottom-32 left-1/2 -translate-x-1/2"
        >
          <motion.div
            animate={{ y: [0, 10, 0] }}
            transition={{ duration: 2, repeat: Infinity }}
            className="text-4xl"
          >
            🎌
          </motion.div>
        </motion.div>
      </div>
    </div>
  );
}
