'use client';

import { motion } from 'framer-motion';

interface SlideProgressProps {
  progress: number;
  currentSlide: number;
  totalSlides: number;
}

export function SlideProgress({ progress, currentSlide, totalSlides }: SlideProgressProps) {
  return (
    <div className="fixed top-0 left-0 right-0 z-30 p-4 safe-area-padding">
      <div className="max-w-4xl mx-auto">
        {/* Progress bar */}
        <div className="relative h-1 bg-white/10 rounded-full overflow-hidden">
          <motion.div
            className="absolute top-0 left-0 h-full rounded-full bg-gradient-to-r from-primary-500 to-accent-500"
            initial={{ width: 0 }}
            animate={{ width: `${progress}%` }}
            transition={{ duration: 0.5, ease: 'easeOut' }}
          />
          
          {/* Glow effect */}
          <motion.div
            className="absolute top-0 h-full rounded-full bg-primary-500 opacity-50 blur-sm"
            style={{ width: `${progress}%` }}
            animate={{
              opacity: [0.3, 0.6, 0.3],
            }}
            transition={{
              duration: 2,
              repeat: Infinity,
              ease: 'easeInOut',
            }}
          />
        </div>

        {/* Slide indicators */}
        <div className="flex items-center justify-between mt-2">
          <div className="flex items-center gap-1.5">
            {Array.from({ length: totalSlides }).map((_, index) => (
              <motion.div
                key={index}
                className={`h-1.5 rounded-full transition-all duration-300 ${
                  index === currentSlide
                    ? 'w-4 bg-primary-500'
                    : index < currentSlide
                    ? 'w-1.5 bg-primary-500/50'
                    : 'w-1.5 bg-white/20'
                }`}
                animate={index === currentSlide ? {
                  boxShadow: [
                    '0 0 5px rgba(217, 70, 239, 0.5)',
                    '0 0 10px rgba(217, 70, 239, 0.8)',
                    '0 0 5px rgba(217, 70, 239, 0.5)',
                  ],
                } : {}}
                transition={{
                  duration: 1.5,
                  repeat: Infinity,
                  ease: 'easeInOut',
                }}
              />
            ))}
          </div>

          {/* Slide counter */}
          <span className="text-xs text-white/50 font-medium tabular-nums">
            {currentSlide + 1} / {totalSlides}
          </span>
        </div>
      </div>
    </div>
  );
}
