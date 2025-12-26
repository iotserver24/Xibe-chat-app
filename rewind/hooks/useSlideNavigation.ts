'use client';

import { useState, useCallback, useEffect, useRef } from 'react';
import { SlideType } from '@/types';

const SLIDES: SlideType[] = [
  'intro',
  'stats-overview',
  'top-anime',
  'habits',
  'personality',
  'ai-image',
  'share-card',
];

const SWIPE_THRESHOLD = 50;
const KEYBOARD_COOLDOWN = 300;

interface UseSlideNavigationResult {
  currentSlide: number;
  currentSlideType: SlideType;
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
}

export function useSlideNavigation(): UseSlideNavigationResult {
  const [currentSlide, setCurrentSlide] = useState(0);
  const [direction, setDirection] = useState<'left' | 'right' | null>(null);
  const [swipeOffset, setSwipeOffset] = useState(0);
  
  const touchStartX = useRef(0);
  const touchStartY = useRef(0);
  const lastKeyPress = useRef(0);
  const isSwipingRef = useRef(false);

  const totalSlides = SLIDES.length;
  const canGoNext = currentSlide < totalSlides - 1;
  const canGoPrevious = currentSlide > 0;
  const progress = ((currentSlide + 1) / totalSlides) * 100;

  const goToSlide = useCallback((index: number) => {
    if (index >= 0 && index < totalSlides && index !== currentSlide) {
      setDirection(index > currentSlide ? 'right' : 'left');
      setCurrentSlide(index);
    }
  }, [currentSlide, totalSlides]);

  const goToNext = useCallback(() => {
    if (canGoNext) {
      setDirection('right');
      setCurrentSlide(prev => prev + 1);
    }
  }, [canGoNext]);

  const goToPrevious = useCallback(() => {
    if (canGoPrevious) {
      setDirection('left');
      setCurrentSlide(prev => prev - 1);
    }
  }, [canGoPrevious]);

  // Handle touch start
  const handleTouchStart = useCallback((e: React.TouchEvent) => {
    touchStartX.current = e.touches[0].clientX;
    touchStartY.current = e.touches[0].clientY;
    isSwipingRef.current = false;
  }, []);

  // Handle touch move
  const handleTouchMove = useCallback((e: React.TouchEvent) => {
    const currentX = e.touches[0].clientX;
    const currentY = e.touches[0].clientY;
    const diffX = currentX - touchStartX.current;
    const diffY = currentY - touchStartY.current;

    // Only start tracking horizontal swipes
    if (!isSwipingRef.current && Math.abs(diffX) > Math.abs(diffY) && Math.abs(diffX) > 10) {
      isSwipingRef.current = true;
    }

    if (isSwipingRef.current) {
      // Limit swipe offset based on navigation possibilities
      let limitedOffset = diffX;
      if (!canGoNext && diffX < 0) {
        limitedOffset = diffX * 0.3; // Resistance when swiping left at end
      }
      if (!canGoPrevious && diffX > 0) {
        limitedOffset = diffX * 0.3; // Resistance when swiping right at start
      }
      setSwipeOffset(limitedOffset);
    }
  }, [canGoNext, canGoPrevious]);

  // Handle touch end
  const handleTouchEnd = useCallback(() => {
    if (Math.abs(swipeOffset) > SWIPE_THRESHOLD) {
      if (swipeOffset > 0 && canGoPrevious) {
        goToPrevious();
      } else if (swipeOffset < 0 && canGoNext) {
        goToNext();
      }
    }
    setSwipeOffset(0);
    isSwipingRef.current = false;
  }, [swipeOffset, canGoNext, canGoPrevious, goToNext, goToPrevious]);

  // Keyboard navigation
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      const now = Date.now();
      if (now - lastKeyPress.current < KEYBOARD_COOLDOWN) return;
      
      // Don't navigate if user is typing in an input
      if (e.target instanceof HTMLInputElement || e.target instanceof HTMLTextAreaElement) {
        return;
      }

      switch (e.key) {
        case 'ArrowRight':
        case 'ArrowDown':
        case ' ':
          e.preventDefault();
          if (canGoNext) {
            lastKeyPress.current = now;
            goToNext();
          }
          break;
        case 'ArrowLeft':
        case 'ArrowUp':
          e.preventDefault();
          if (canGoPrevious) {
            lastKeyPress.current = now;
            goToPrevious();
          }
          break;
        case 'Home':
          e.preventDefault();
          lastKeyPress.current = now;
          goToSlide(0);
          break;
        case 'End':
          e.preventDefault();
          lastKeyPress.current = now;
          goToSlide(totalSlides - 1);
          break;
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, [canGoNext, canGoPrevious, goToNext, goToPrevious, goToSlide, totalSlides]);

  // Reset direction after animation
  useEffect(() => {
    const timer = setTimeout(() => {
      setDirection(null);
    }, 500);
    return () => clearTimeout(timer);
  }, [currentSlide]);

  return {
    currentSlide,
    currentSlideType: SLIDES[currentSlide],
    totalSlides,
    direction,
    canGoNext,
    canGoPrevious,
    goToSlide,
    goToNext,
    goToPrevious,
    progress,
    handleTouchStart,
    handleTouchMove,
    handleTouchEnd,
    swipeOffset,
  };
}
