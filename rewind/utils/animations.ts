import { Variants, Transition } from 'framer-motion';

// Spring physics for natural animations
export const springTransition: Transition = {
  type: 'spring',
  stiffness: 300,
  damping: 30,
};

export const smoothSpring: Transition = {
  type: 'spring',
  stiffness: 200,
  damping: 25,
};

export const bouncySpring: Transition = {
  type: 'spring',
  stiffness: 400,
  damping: 20,
};

// Slide transitions
export const slideVariants: Variants = {
  enter: (direction: number) => ({
    x: direction > 0 ? '100%' : '-100%',
    opacity: 0,
  }),
  center: {
    x: 0,
    opacity: 1,
  },
  exit: (direction: number) => ({
    x: direction < 0 ? '100%' : '-100%',
    opacity: 0,
  }),
};

// Fade in variants
export const fadeInVariants: Variants = {
  hidden: { opacity: 0 },
  visible: { 
    opacity: 1,
    transition: { duration: 0.5 },
  },
};

// Fade in up variants
export const fadeInUpVariants: Variants = {
  hidden: { 
    opacity: 0, 
    y: 30 
  },
  visible: { 
    opacity: 1, 
    y: 0,
    transition: { 
      duration: 0.6,
      ease: [0.25, 0.46, 0.45, 0.94],
    },
  },
};

// Fade in down variants
export const fadeInDownVariants: Variants = {
  hidden: { 
    opacity: 0, 
    y: -30 
  },
  visible: { 
    opacity: 1, 
    y: 0,
    transition: { 
      duration: 0.6,
      ease: [0.25, 0.46, 0.45, 0.94],
    },
  },
};

// Scale up variants
export const scaleUpVariants: Variants = {
  hidden: { 
    opacity: 0, 
    scale: 0.8 
  },
  visible: { 
    opacity: 1, 
    scale: 1,
    transition: smoothSpring,
  },
};

// Pop variants (scale with bounce)
export const popVariants: Variants = {
  hidden: { 
    opacity: 0, 
    scale: 0.5 
  },
  visible: { 
    opacity: 1, 
    scale: 1,
    transition: bouncySpring,
  },
};

// Stagger container variants
export const staggerContainerVariants: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.1,
      delayChildren: 0.2,
    },
  },
};

// Stagger item variants
export const staggerItemVariants: Variants = {
  hidden: { 
    opacity: 0, 
    y: 20 
  },
  visible: { 
    opacity: 1, 
    y: 0,
    transition: {
      duration: 0.5,
      ease: 'easeOut',
    },
  },
};

// Card hover variants
export const cardHoverVariants: Variants = {
  rest: { 
    scale: 1,
    boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
  },
  hover: { 
    scale: 1.02,
    boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)',
    transition: smoothSpring,
  },
  tap: { 
    scale: 0.98,
    transition: { duration: 0.1 },
  },
};

// Button hover variants
export const buttonHoverVariants: Variants = {
  rest: { scale: 1 },
  hover: { 
    scale: 1.05,
    transition: smoothSpring,
  },
  tap: { 
    scale: 0.95,
    transition: { duration: 0.1 },
  },
};

// Glow pulse animation
export const glowPulseVariants: Variants = {
  initial: {
    boxShadow: '0 0 20px rgba(217, 70, 239, 0.3)',
  },
  animate: {
    boxShadow: [
      '0 0 20px rgba(217, 70, 239, 0.3)',
      '0 0 40px rgba(217, 70, 239, 0.5)',
      '0 0 20px rgba(217, 70, 239, 0.3)',
    ],
    transition: {
      duration: 2,
      repeat: Infinity,
      ease: 'easeInOut',
    },
  },
};

// Float animation
export const floatVariants: Variants = {
  initial: { y: 0 },
  animate: {
    y: [-10, 10, -10],
    transition: {
      duration: 4,
      repeat: Infinity,
      ease: 'easeInOut',
    },
  },
};

// Rotate animation
export const rotateVariants: Variants = {
  initial: { rotate: 0 },
  animate: {
    rotate: 360,
    transition: {
      duration: 20,
      repeat: Infinity,
      ease: 'linear',
    },
  },
};

// Letter stagger variants (for text animations)
export const letterContainerVariants: Variants = {
  hidden: { opacity: 0 },
  visible: {
    opacity: 1,
    transition: {
      staggerChildren: 0.04,
      delayChildren: 0.1,
    },
  },
};

export const letterVariants: Variants = {
  hidden: { 
    opacity: 0, 
    y: 50,
    rotateX: -90,
  },
  visible: { 
    opacity: 1, 
    y: 0,
    rotateX: 0,
    transition: {
      duration: 0.5,
      ease: [0.25, 0.46, 0.45, 0.94],
    },
  },
};

// Counter animation config
export const counterConfig = {
  duration: 2,
  ease: [0.25, 0.46, 0.45, 0.94] as const,
};

// Progress bar variants
export const progressBarVariants: Variants = {
  hidden: { width: 0 },
  visible: (width: number) => ({
    width: `${width}%`,
    transition: {
      duration: 1.5,
      ease: [0.25, 0.46, 0.45, 0.94],
      delay: 0.5,
    },
  }),
};

// Chart bar variants
export const chartBarVariants: Variants = {
  hidden: { 
    height: 0,
    opacity: 0,
  },
  visible: (height: number) => ({
    height: `${height}%`,
    opacity: 1,
    transition: {
      height: {
        duration: 1,
        ease: [0.25, 0.46, 0.45, 0.94],
      },
      opacity: {
        duration: 0.3,
      },
    },
  }),
};

// Circular progress variants
export const circularProgressVariants: Variants = {
  hidden: { 
    pathLength: 0,
    opacity: 0,
  },
  visible: (progress: number) => ({
    pathLength: progress / 100,
    opacity: 1,
    transition: {
      pathLength: {
        duration: 2,
        ease: 'easeOut',
      },
      opacity: {
        duration: 0.5,
      },
    },
  }),
};

// Image reveal variants
export const imageRevealVariants: Variants = {
  hidden: {
    clipPath: 'inset(0 100% 0 0)',
    opacity: 0,
  },
  visible: {
    clipPath: 'inset(0 0% 0 0)',
    opacity: 1,
    transition: {
      duration: 1,
      ease: [0.25, 0.46, 0.45, 0.94],
    },
  },
};

// Particle animation config
export const particleConfig = {
  count: 50,
  colors: ['#d946ef', '#ec4899', '#8b5cf6', '#06b6d4'],
  sizeRange: [2, 8],
  durationRange: [10, 20],
};

// Shimmer animation
export const shimmerVariants: Variants = {
  initial: {
    backgroundPosition: '-200% 0',
  },
  animate: {
    backgroundPosition: '200% 0',
    transition: {
      duration: 2,
      repeat: Infinity,
      ease: 'linear',
    },
  },
};

// Typewriter effect config
export const typewriterConfig = {
  charDelay: 0.03,
  lineDelay: 0.5,
};

// Reduced motion variants (for accessibility)
export const reducedMotionVariants: Variants = {
  hidden: { opacity: 0 },
  visible: { 
    opacity: 1,
    transition: { duration: 0.2 },
  },
};

// Check for reduced motion preference
export function prefersReducedMotion(): boolean {
  if (typeof window === 'undefined') return false;
  return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
}

// Get appropriate variants based on motion preference
export function getMotionVariants(
  normalVariants: Variants,
  reducedVariants: Variants = reducedMotionVariants
): Variants {
  return prefersReducedMotion() ? reducedVariants : normalVariants;
}
