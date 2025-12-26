'use client';

import { motion } from 'framer-motion';
import { ChevronLeft, ChevronRight } from 'lucide-react';

interface ControlsProps {
  currentSlide: number;
  totalSlides: number;
  canGoNext: boolean;
  canGoPrevious: boolean;
  onNext: () => void;
  onPrevious: () => void;
}

export function Controls({
  canGoNext,
  canGoPrevious,
  onNext,
  onPrevious,
}: ControlsProps) {
  return (
    <>
      {/* Previous button */}
      {canGoPrevious && (
        <motion.button
          initial={{ opacity: 0, x: -20 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: -20 }}
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.9 }}
          onClick={onPrevious}
          className="fixed left-4 top-1/2 -translate-y-1/2 z-20
                     w-12 h-12 rounded-full bg-white/10 backdrop-blur-sm
                     border border-white/20 flex items-center justify-center
                     text-white/70 hover:text-white hover:bg-white/20
                     transition-colors hidden md:flex"
          aria-label="Previous slide"
        >
          <ChevronLeft className="w-6 h-6" />
        </motion.button>
      )}

      {/* Next button */}
      {canGoNext && (
        <motion.button
          initial={{ opacity: 0, x: 20 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: 20 }}
          whileHover={{ scale: 1.1 }}
          whileTap={{ scale: 0.9 }}
          onClick={onNext}
          className="fixed right-4 top-1/2 -translate-y-1/2 z-20
                     w-12 h-12 rounded-full bg-white/10 backdrop-blur-sm
                     border border-white/20 flex items-center justify-center
                     text-white/70 hover:text-white hover:bg-white/20
                     transition-colors hidden md:flex"
          aria-label="Next slide"
        >
          <ChevronRight className="w-6 h-6" />
        </motion.button>
      )}

      {/* Mobile bottom navigation */}
      <div className="fixed bottom-4 left-0 right-0 z-20 px-4 md:hidden">
        <div className="flex items-center justify-between max-w-sm mx-auto">
          <motion.button
            whileTap={{ scale: 0.9 }}
            onClick={onPrevious}
            disabled={!canGoPrevious}
            className={`w-14 h-14 rounded-full flex items-center justify-center
                       transition-all ${
                         canGoPrevious
                           ? 'bg-white/10 backdrop-blur-sm border border-white/20 text-white'
                           : 'bg-white/5 text-white/30 cursor-not-allowed'
                       }`}
            aria-label="Previous slide"
          >
            <ChevronLeft className="w-6 h-6" />
          </motion.button>

          <motion.button
            whileTap={{ scale: 0.9 }}
            onClick={onNext}
            disabled={!canGoNext}
            className={`w-14 h-14 rounded-full flex items-center justify-center
                       transition-all ${
                         canGoNext
                           ? 'bg-gradient-to-r from-primary-500 to-accent-500 text-white glow-primary'
                           : 'bg-white/5 text-white/30 cursor-not-allowed'
                       }`}
            aria-label="Next slide"
          >
            <ChevronRight className="w-6 h-6" />
          </motion.button>
        </div>
      </div>
    </>
  );
}
