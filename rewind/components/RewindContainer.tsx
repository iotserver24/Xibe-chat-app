'use client';

import { useMemo } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { User, RewindStats } from '@/types';
import { ParticleBackground } from './ParticleBackground';
import { SlideProgress } from './Navigation/SlideProgress';
import { Controls } from './Navigation/Controls';
import { IntroSlide } from './slides/IntroSlide';
import { StatsOverviewSlide } from './slides/StatsOverviewSlide';
import { TopAnimeSlide } from './slides/TopAnimeSlide';
import { HabitsSlide } from './slides/HabitsSlide';
import { PersonalitySlide } from './slides/PersonalitySlide';
import { AIImageSlide } from './slides/AIImageSlide';
import { ShareCardSlide } from './slides/ShareCardSlide';
import { slideVariants, smoothSpring } from '@/utils/animations';

interface RewindContainerProps {
  user: User;
  stats: RewindStats;
  slideNavigation: {
    currentSlide: number;
    currentSlideType: string;
    totalSlides: number;
    direction: 'left' | 'right' | null;
    canGoNext: boolean;
    canGoPrevious: boolean;
    goToSlide: (index: number) => void;
    goToNext: () => void;
    goToPrevious: () => void;
    progress: number;
    handleTouchStart: (e: React.TouchEvent) => void;
    handleTouchMove: (e: React.TouchEvent) => void;
    handleTouchEnd: () => void;
    swipeOffset: number;
  };
  aiImageUrl: string | null;
  isAiImageLoading: boolean;
}

export function RewindContainer({
  user,
  stats,
  slideNavigation,
  aiImageUrl,
  isAiImageLoading,
}: RewindContainerProps) {
  const {
    currentSlide,
    totalSlides,
    direction,
    canGoNext,
    canGoPrevious,
    goToNext,
    goToPrevious,
    progress,
    handleTouchStart,
    handleTouchMove,
    handleTouchEnd,
    swipeOffset,
  } = slideNavigation;

  // Slide components
  const slides = useMemo(() => [
    <IntroSlide key="intro" stats={stats} user={user} isActive={currentSlide === 0} direction={direction} onNext={goToNext} />,
    <StatsOverviewSlide key="stats" stats={stats} user={user} isActive={currentSlide === 1} direction={direction} onNext={goToNext} onPrevious={goToPrevious} />,
    <TopAnimeSlide key="top-anime" stats={stats} user={user} isActive={currentSlide === 2} direction={direction} onNext={goToNext} onPrevious={goToPrevious} />,
    <HabitsSlide key="habits" stats={stats} user={user} isActive={currentSlide === 3} direction={direction} onNext={goToNext} onPrevious={goToPrevious} />,
    <PersonalitySlide key="personality" stats={stats} user={user} isActive={currentSlide === 4} direction={direction} onNext={goToNext} onPrevious={goToPrevious} />,
    <AIImageSlide key="ai-image" stats={stats} user={user} isActive={currentSlide === 5} direction={direction} onNext={goToNext} onPrevious={goToPrevious} aiImageUrl={aiImageUrl} isLoading={isAiImageLoading} />,
    <ShareCardSlide key="share" stats={stats} user={user} isActive={currentSlide === 6} direction={direction} onPrevious={goToPrevious} aiImageUrl={aiImageUrl} />,
  ], [stats, user, currentSlide, direction, goToNext, goToPrevious, aiImageUrl, isAiImageLoading]);

  return (
    <div 
      className="rewind-container animated-gradient-bg"
      onTouchStart={handleTouchStart}
      onTouchMove={handleTouchMove}
      onTouchEnd={handleTouchEnd}
    >
      <ParticleBackground />
      
      {/* Progress bar */}
      <SlideProgress 
        progress={progress} 
        currentSlide={currentSlide} 
        totalSlides={totalSlides} 
      />

      {/* Slides */}
      <div className="relative w-full h-full overflow-hidden">
        <AnimatePresence initial={false} custom={direction === 'right' ? 1 : -1} mode="wait">
          <motion.div
            key={currentSlide}
            custom={direction === 'right' ? 1 : -1}
            variants={slideVariants}
            initial="enter"
            animate="center"
            exit="exit"
            transition={smoothSpring}
            className="absolute inset-0"
            style={{
              x: swipeOffset,
            }}
          >
            {slides[currentSlide]}
          </motion.div>
        </AnimatePresence>
      </div>

      {/* Navigation controls */}
      <Controls
        currentSlide={currentSlide}
        totalSlides={totalSlides}
        canGoNext={canGoNext}
        canGoPrevious={canGoPrevious}
        onNext={goToNext}
        onPrevious={goToPrevious}
      />

      {/* Swipe hint for first slide */}
      {currentSlide === 0 && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 2 }}
          className="absolute bottom-8 left-1/2 -translate-x-1/2 z-20"
        >
          <motion.div
            animate={{ x: [0, 10, 0] }}
            transition={{ duration: 1.5, repeat: Infinity }}
            className="flex items-center gap-2 text-white/40 text-sm"
          >
            <span>Swipe to continue</span>
            <span>→</span>
          </motion.div>
        </motion.div>
      )}
    </div>
  );
}
