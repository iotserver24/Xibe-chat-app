'use client';

import { useEffect, useRef, useState } from 'react';
import { gsap } from 'gsap';

interface CounterOptions {
  start?: number;
  end: number;
  duration?: number;
  delay?: number;
  suffix?: string;
  prefix?: string;
  decimals?: number;
}

interface UseCounterResult {
  value: string;
  isComplete: boolean;
}

// Hook for animated counter
export function useAnimatedCounter(options: CounterOptions): UseCounterResult {
  const {
    start = 0,
    end,
    duration = 2,
    delay = 0,
    suffix = '',
    prefix = '',
    decimals = 0,
  } = options;

  const [value, setValue] = useState(start);
  const [isComplete, setIsComplete] = useState(false);
  const elementRef = useRef<{ value: number }>({ value: start });

  useEffect(() => {
    const timer = setTimeout(() => {
      gsap.to(elementRef.current, {
        value: end,
        duration,
        ease: 'power2.out',
        onUpdate: () => {
          setValue(elementRef.current.value);
        },
        onComplete: () => {
          setIsComplete(true);
        },
      });
    }, delay * 1000);

    return () => {
      clearTimeout(timer);
      gsap.killTweensOf(elementRef.current);
    };
  }, [end, duration, delay]);

  const formattedValue = decimals > 0
    ? value.toFixed(decimals)
    : Math.round(value).toLocaleString();

  return {
    value: `${prefix}${formattedValue}${suffix}`,
    isComplete,
  };
}

// Hook for staggered list animation
export function useStaggeredAnimation(
  containerRef: React.RefObject<HTMLElement>,
  itemSelector: string,
  options: {
    delay?: number;
    stagger?: number;
    duration?: number;
    fromY?: number;
    fromOpacity?: number;
  } = {}
) {
  const {
    delay = 0.2,
    stagger = 0.1,
    duration = 0.6,
    fromY = 30,
    fromOpacity = 0,
  } = options;

  const [isComplete, setIsComplete] = useState(false);

  useEffect(() => {
    if (!containerRef.current) return;

    const items = containerRef.current.querySelectorAll(itemSelector);
    if (items.length === 0) return;

    // Set initial state
    gsap.set(items, { y: fromY, opacity: fromOpacity });

    // Animate
    const tl = gsap.timeline({
      delay,
      onComplete: () => setIsComplete(true),
    });

    tl.to(items, {
      y: 0,
      opacity: 1,
      duration,
      stagger,
      ease: 'power2.out',
    });

    return () => {
      tl.kill();
    };
  }, [containerRef, itemSelector, delay, stagger, duration, fromY, fromOpacity]);

  return { isComplete };
}

// Hook for progress bar animation
export function useProgressAnimation(
  targetProgress: number,
  duration: number = 1.5,
  delay: number = 0.5
) {
  const [progress, setProgress] = useState(0);
  const progressRef = useRef({ value: 0 });

  useEffect(() => {
    const timer = setTimeout(() => {
      gsap.to(progressRef.current, {
        value: targetProgress,
        duration,
        ease: 'power2.out',
        onUpdate: () => {
          setProgress(progressRef.current.value);
        },
      });
    }, delay * 1000);

    return () => {
      clearTimeout(timer);
      gsap.killTweensOf(progressRef.current);
    };
  }, [targetProgress, duration, delay]);

  return progress;
}

// Hook for typewriter effect
export function useTypewriter(
  text: string,
  options: {
    delay?: number;
    speed?: number;
    onComplete?: () => void;
  } = {}
) {
  const { delay = 0, speed = 30, onComplete } = options;
  const [displayText, setDisplayText] = useState('');
  const [isComplete, setIsComplete] = useState(false);

  useEffect(() => {
    let timeout: NodeJS.Timeout;
    let currentIndex = 0;

    const startTyping = () => {
      const typeNextChar = () => {
        if (currentIndex < text.length) {
          setDisplayText(text.slice(0, currentIndex + 1));
          currentIndex++;
          timeout = setTimeout(typeNextChar, speed);
        } else {
          setIsComplete(true);
          onComplete?.();
        }
      };
      typeNextChar();
    };

    const delayTimeout = setTimeout(startTyping, delay * 1000);

    return () => {
      clearTimeout(delayTimeout);
      clearTimeout(timeout);
    };
  }, [text, delay, speed, onComplete]);

  return { displayText, isComplete };
}

// Hook for chart bar animation
export function useChartAnimation(
  data: { value: number; max: number }[],
  duration: number = 1,
  stagger: number = 0.1
) {
  const [heights, setHeights] = useState<number[]>(data.map(() => 0));
  const valuesRef = useRef<{ value: number }[]>(data.map(() => ({ value: 0 })));

  useEffect(() => {
    valuesRef.current.forEach((ref, index) => {
      const targetHeight = (data[index].value / data[index].max) * 100;
      
      gsap.to(ref, {
        value: targetHeight,
        duration,
        delay: index * stagger,
        ease: 'power2.out',
        onUpdate: () => {
          setHeights(prev => {
            const newHeights = [...prev];
            newHeights[index] = ref.value;
            return newHeights;
          });
        },
      });
    });

    return () => {
      valuesRef.current.forEach(ref => gsap.killTweensOf(ref));
    };
  }, [data, duration, stagger]);

  return heights;
}

// Hook for parallax effect
export function useParallax(
  speed: number = 0.5,
  direction: 'up' | 'down' = 'up'
) {
  const [offset, setOffset] = useState(0);

  useEffect(() => {
    const handleScroll = () => {
      const scrollY = window.scrollY;
      const multiplier = direction === 'up' ? -1 : 1;
      setOffset(scrollY * speed * multiplier);
    };

    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, [speed, direction]);

  return offset;
}

// Hook for reveal on mount animation
export function useRevealAnimation(
  elementRef: React.RefObject<HTMLElement>,
  options: {
    delay?: number;
    duration?: number;
    fromY?: number;
    fromScale?: number;
    fromOpacity?: number;
  } = {}
) {
  const {
    delay = 0,
    duration = 0.8,
    fromY = 50,
    fromScale = 0.95,
    fromOpacity = 0,
  } = options;

  const [isRevealed, setIsRevealed] = useState(false);

  useEffect(() => {
    if (!elementRef.current) return;

    gsap.set(elementRef.current, {
      y: fromY,
      scale: fromScale,
      opacity: fromOpacity,
    });

    gsap.to(elementRef.current, {
      y: 0,
      scale: 1,
      opacity: 1,
      duration,
      delay,
      ease: 'power3.out',
      onComplete: () => setIsRevealed(true),
    });
  }, [elementRef, delay, duration, fromY, fromScale, fromOpacity]);

  return isRevealed;
}

// Hook for circular progress animation
export function useCircularProgress(
  targetValue: number,
  maxValue: number,
  duration: number = 2
) {
  const [progress, setProgress] = useState(0);
  const progressRef = useRef({ value: 0 });

  useEffect(() => {
    const targetProgress = (targetValue / maxValue) * 100;
    
    gsap.to(progressRef.current, {
      value: targetProgress,
      duration,
      ease: 'power2.out',
      onUpdate: () => {
        setProgress(progressRef.current.value);
      },
    });

    return () => {
      gsap.killTweensOf(progressRef.current);
    };
  }, [targetValue, maxValue, duration]);

  return progress;
}

// Cleanup all GSAP animations
export function useGSAPCleanup() {
  useEffect(() => {
    return () => {
      gsap.killTweensOf('*');
    };
  }, []);
}
