'use client';

import { motion } from 'framer-motion';
import Image from 'next/image';
import { SlideProps } from '@/types';
import { fadeInUpVariants, scaleUpVariants, imageRevealVariants } from '@/utils/animations';
import { Sparkles, Wand2, Loader2 } from 'lucide-react';

interface AIImageSlideProps extends SlideProps {
  aiImageUrl: string | null;
  isLoading: boolean;
}

export function AIImageSlide({ stats, isActive, aiImageUrl, isLoading }: AIImageSlideProps) {
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
          <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-gradient-to-r from-primary-500/20 to-accent-500/20 border border-primary-500/30 mb-4">
            <Wand2 className="w-4 h-4 text-primary-400" />
            <span className="text-sm text-primary-400 font-medium">AI Generated</span>
          </div>
          
          <h2 className="font-display text-3xl sm:text-4xl md:text-5xl font-bold mb-4">
            <span className="text-white">Your Unique</span>{' '}
            <span className="gradient-text">Anime Portrait</span>
          </h2>
          <p className="text-white/60 max-w-md mx-auto">
            Based on your top genres and personality, AI created this image just for you
          </p>
        </motion.div>

        {/* AI Image */}
        <motion.div
          variants={scaleUpVariants}
          initial="hidden"
          animate={isActive ? "visible" : "hidden"}
          className="relative max-w-md mx-auto mb-6"
        >
          <div className="aspect-square rounded-2xl overflow-hidden relative">
            {/* Animated border */}
            <motion.div
              className="absolute inset-0 rounded-2xl"
              animate={isActive ? {
                boxShadow: [
                  '0 0 20px rgba(217, 70, 239, 0.3), inset 0 0 20px rgba(217, 70, 239, 0.1)',
                  '0 0 40px rgba(217, 70, 239, 0.5), inset 0 0 30px rgba(217, 70, 239, 0.2)',
                  '0 0 20px rgba(217, 70, 239, 0.3), inset 0 0 20px rgba(217, 70, 239, 0.1)',
                ],
              } : {}}
              transition={{
                duration: 2,
                repeat: Infinity,
                ease: 'easeInOut',
              }}
              style={{ zIndex: 10, pointerEvents: 'none' }}
            />

            {isLoading ? (
              <div className="absolute inset-0 flex flex-col items-center justify-center bg-white/5 backdrop-blur-sm">
                <motion.div
                  animate={{ rotate: 360 }}
                  transition={{ duration: 2, repeat: Infinity, ease: 'linear' }}
                >
                  <Loader2 className="w-12 h-12 text-primary-400" />
                </motion.div>
                <p className="text-white/60 mt-4">Generating your portrait...</p>
                <p className="text-white/40 text-sm mt-2">This may take a moment</p>
              </div>
            ) : aiImageUrl ? (
              <motion.div
                variants={imageRevealVariants}
                initial="hidden"
                animate={isActive ? "visible" : "hidden"}
                className="w-full h-full"
              >
                <Image
                  src={aiImageUrl}
                  alt="AI Generated Anime Portrait"
                  fill
                  className="object-cover"
                  sizes="(max-width: 768px) 100vw, 448px"
                  priority
                />
                
                {/* Shimmer overlay */}
                <motion.div
                  className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent"
                  animate={{
                    x: ['-100%', '100%'],
                  }}
                  transition={{
                    duration: 2,
                    repeat: Infinity,
                    repeatDelay: 3,
                    ease: 'easeInOut',
                  }}
                />
              </motion.div>
            ) : (
              <div className="absolute inset-0 flex flex-col items-center justify-center bg-gradient-to-br from-primary-500/20 to-accent-500/20">
                <Sparkles className="w-16 h-16 text-primary-400 mb-4" />
                <p className="text-white/60">Image not available</p>
              </div>
            )}
          </div>
        </motion.div>

        {/* Image info */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isActive ? { opacity: 1, y: 0 } : {}}
          transition={{ delay: 1 }}
          className="max-w-md mx-auto"
        >
          <div className="glass-card p-4 text-left">
            <div className="flex items-start gap-3">
              <Sparkles className="w-5 h-5 text-primary-400 flex-shrink-0 mt-0.5" />
              <div>
                <p className="text-white/80 text-sm mb-2">
                  This image is <span className="text-primary-400 font-medium">unique to you</span> and was created based on:
                </p>
                <ul className="text-white/60 text-sm space-y-1">
                  <li>• Your personality: {stats.personality.title}</li>
                  <li>• Top genres: {stats.topGenres.slice(0, 3).map(g => g.genre).join(', ')}</li>
                  <li>• Favorite anime styles</li>
                </ul>
              </div>
            </div>
          </div>

          {/* Prompt preview */}
          {stats.aiImagePrompt && (
            <motion.div
              initial={{ opacity: 0 }}
              animate={isActive ? { opacity: 1 } : {}}
              transition={{ delay: 1.5 }}
              className="mt-4"
            >
              <details className="text-left">
                <summary className="text-white/40 text-xs cursor-pointer hover:text-white/60 transition-colors">
                  View AI prompt
                </summary>
                <p className="text-white/30 text-xs mt-2 italic">
                  {stats.aiImagePrompt}
                </p>
              </details>
            </motion.div>
          )}
        </motion.div>
      </div>
    </div>
  );
}
