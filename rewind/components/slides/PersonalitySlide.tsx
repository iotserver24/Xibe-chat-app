'use client';

import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { SlideProps } from '@/types';
import { formatWatchTime, getFunFact } from '@/utils/rewindUtils';
import { fadeInUpVariants, staggerContainerVariants, staggerItemVariants, scaleUpVariants } from '@/utils/animations';
import { Sparkles, Clock, Zap } from 'lucide-react';

export function PersonalitySlide({ stats, isActive }: SlideProps) {
  const [displayedDescription, setDisplayedDescription] = useState('');
  const personality = stats.personality;
  const funFact = getFunFact(stats);

  // Typewriter effect for description
  useEffect(() => {
    if (!isActive) {
      setDisplayedDescription('');
      return;
    }

    const text = personality.description;
    let index = 0;
    setDisplayedDescription('');

    const timer = setTimeout(() => {
      const interval = setInterval(() => {
        if (index < text.length) {
          setDisplayedDescription(text.slice(0, index + 1));
          index++;
        } else {
          clearInterval(interval);
        }
      }, 30);

      return () => clearInterval(interval);
    }, 1000);

    return () => clearTimeout(timer);
  }, [isActive, personality.description]);

  return (
    <div className="slide-wrapper">
      <div className="content-container text-center">
        {/* Header */}
        <motion.div
          variants={fadeInUpVariants}
          initial="hidden"
          animate={isActive ? "visible" : "hidden"}
          className="mb-6"
        >
          <h2 className="font-display text-2xl sm:text-3xl font-bold text-white mb-2">
            Your Anime Personality
          </h2>
          <p className="text-white/60">Based on your watching patterns</p>
        </motion.div>

        {/* Personality card */}
        <motion.div
          variants={scaleUpVariants}
          initial="hidden"
          animate={isActive ? "visible" : "hidden"}
          className="glass-card p-8 max-w-md mx-auto mb-6 relative overflow-hidden"
          style={{
            background: `linear-gradient(135deg, ${personality.color}15 0%, ${personality.color}05 100%)`,
            borderColor: `${personality.color}40`,
          }}
        >
          {/* Glow effect */}
          <motion.div
            className="absolute inset-0 opacity-20"
            animate={{
              background: [
                `radial-gradient(circle at 30% 30%, ${personality.color}40, transparent 60%)`,
                `radial-gradient(circle at 70% 70%, ${personality.color}40, transparent 60%)`,
                `radial-gradient(circle at 30% 30%, ${personality.color}40, transparent 60%)`,
              ],
            }}
            transition={{ duration: 5, repeat: Infinity, ease: 'easeInOut' }}
          />

          {/* Emoji */}
          <motion.div
            initial={{ scale: 0, rotate: -180 }}
            animate={isActive ? { scale: 1, rotate: 0 } : {}}
            transition={{ delay: 0.5, type: 'spring', stiffness: 200 }}
            className="text-7xl mb-4"
          >
            {personality.emoji}
          </motion.div>

          {/* Title */}
          <motion.h3
            initial={{ opacity: 0, y: 20 }}
            animate={isActive ? { opacity: 1, y: 0 } : {}}
            transition={{ delay: 0.7 }}
            className={`font-display text-3xl sm:text-4xl font-bold mb-4 bg-gradient-to-r ${personality.gradient} bg-clip-text text-transparent`}
          >
            {personality.title}
          </motion.h3>

          {/* Description with typewriter */}
          <motion.p
            initial={{ opacity: 0 }}
            animate={isActive ? { opacity: 1 } : {}}
            transition={{ delay: 0.9 }}
            className="text-white/80 text-lg leading-relaxed min-h-[4rem]"
          >
            {displayedDescription}
            <motion.span
              animate={{ opacity: [1, 0, 1] }}
              transition={{ duration: 0.8, repeat: Infinity }}
              className="inline-block w-0.5 h-5 bg-primary-400 ml-1 align-middle"
              style={{ display: displayedDescription.length < personality.description.length ? 'inline-block' : 'none' }}
            />
          </motion.p>

          {/* Traits */}
          <motion.div
            variants={staggerContainerVariants}
            initial="hidden"
            animate={isActive ? "visible" : "hidden"}
            className="flex flex-wrap justify-center gap-2 mt-6"
          >
            {personality.traits.map((trait, index) => (
              <motion.span
                key={trait}
                variants={staggerItemVariants}
                className="px-3 py-1 rounded-full text-sm font-medium"
                style={{
                  backgroundColor: `${personality.color}20`,
                  color: personality.color,
                  border: `1px solid ${personality.color}40`,
                }}
              >
                {trait}
              </motion.span>
            ))}
          </motion.div>
        </motion.div>

        {/* Binge session */}
        <motion.div
          variants={staggerContainerVariants}
          initial="hidden"
          animate={isActive ? "visible" : "hidden"}
          className="grid grid-cols-1 sm:grid-cols-2 gap-4 max-w-md mx-auto"
        >
          <motion.div
            variants={staggerItemVariants}
            className="glass-card p-4"
          >
            <div className="flex items-center gap-2 mb-2">
              <Zap className="w-5 h-5 text-amber-400" />
              <span className="text-white/60 text-sm">Longest Binge</span>
            </div>
            <p className="text-lg font-semibold text-white truncate">
              {stats.longestBingeSession.anime}
            </p>
            <p className="text-primary-400 text-sm">
              {stats.longestBingeSession.episodes} episodes • {formatWatchTime(stats.longestBingeSession.duration)}
            </p>
          </motion.div>

          {stats.favoriteStudio && (
            <motion.div
              variants={staggerItemVariants}
              className="glass-card p-4"
            >
              <div className="flex items-center gap-2 mb-2">
                <Sparkles className="w-5 h-5 text-cyan-400" />
                <span className="text-white/60 text-sm">Favorite Studio</span>
              </div>
              <p className="text-lg font-semibold text-white">
                {stats.favoriteStudio}
              </p>
              <p className="text-cyan-400 text-sm">
                Your most watched
              </p>
            </motion.div>
          )}
        </motion.div>

        {/* Fun fact */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isActive ? { opacity: 1, y: 0 } : {}}
          transition={{ delay: 1.5 }}
          className="mt-8"
        >
          <p className="text-white/50 text-sm italic">
            💡 {funFact}
          </p>
        </motion.div>
      </div>
    </div>
  );
}
