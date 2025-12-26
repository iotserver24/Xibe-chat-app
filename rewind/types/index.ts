// User Types
export interface User {
  uid: string;
  email: string | null;
  displayName: string | null;
  photoURL: string | null;
  createdAt: Date;
  lastLoginAt: Date;
}

// Anime Types
export interface AnimeEntry {
  id: string;
  malId?: number;
  anilistId?: number;
  title: string;
  titleEnglish?: string;
  imageUrl: string;
  bannerUrl?: string;
  episodes: number;
  episodesWatched: number;
  score?: number;
  status: 'watching' | 'completed' | 'on_hold' | 'dropped' | 'plan_to_watch';
  startDate?: Date;
  endDate?: Date;
  genres: string[];
  type: 'tv' | 'movie' | 'ova' | 'special' | 'ona';
  duration?: number; // in minutes per episode
  studio?: string;
  season?: string;
  year?: number;
  audioLanguage: 'sub' | 'dub' | 'both';
}

export interface WatchSession {
  id: string;
  animeId: string;
  episodesWatched: number;
  watchedAt: Date;
  duration: number; // total minutes watched
  dayOfWeek: number; // 0-6
  hourOfDay: number; // 0-23
}

// Rewind Stats Types
export interface RewindStats {
  // Overview
  totalEpisodes: number;
  totalWatchTimeMinutes: number;
  totalWatchTimeHours: number;
  uniqueAnimeWatched: number;
  daysActive: number;
  
  // Top Anime
  topAnime: TopAnimeEntry[];
  
  // Habits
  subVsDub: {
    sub: number;
    dub: number;
    percentage: number; // percentage of sub
  };
  watchTimeByDay: { [key: string]: number }; // Monday-Sunday
  peakWatchingHour: number;
  averageEpisodesPerDay: number;
  
  // Genres
  topGenres: GenreStat[];
  
  // Personality
  personality: PersonalityType;
  longestBingeSession: {
    anime: string;
    episodes: number;
    duration: number;
  };
  favoriteStudio?: string;
  
  // Timeline
  accountCreatedAt: Date;
  firstAnimeWatched?: string;
  mostRecentAnime?: string;
  
  // AI Generated
  aiImagePrompt?: string;
  aiImageUrl?: string;
}

export interface TopAnimeEntry {
  anime: AnimeEntry;
  episodesWatched: number;
  watchTimeMinutes: number;
  rank: number;
}

export interface GenreStat {
  genre: string;
  count: number;
  percentage: number;
}

export interface PersonalityType {
  type: string;
  emoji: string;
  title: string;
  description: string;
  traits: string[];
  color: string;
  gradient: string;
}

// Personality Types
export const PERSONALITY_TYPES: { [key: string]: PersonalityType } = {
  binge_master: {
    type: 'binge_master',
    emoji: '🎭',
    title: 'The Binge Master',
    description: 'You don\'t just watch anime, you DEVOUR it! Marathon sessions are your specialty.',
    traits: ['Dedicated', 'Passionate', 'Night Owl', 'All-or-Nothing'],
    color: '#d946ef',
    gradient: 'from-purple-500 to-pink-500',
  },
  casual_explorer: {
    type: 'casual_explorer',
    emoji: '🌟',
    title: 'The Casual Explorer',
    description: 'You take your time discovering new worlds, savoring each episode like fine wine.',
    traits: ['Relaxed', 'Curious', 'Open-minded', 'Balanced'],
    color: '#06b6d4',
    gradient: 'from-cyan-500 to-blue-500',
  },
  genre_specialist: {
    type: 'genre_specialist',
    emoji: '🎯',
    title: 'The Genre Specialist',
    description: 'You know exactly what you like and stick to your favorites. Respect!',
    traits: ['Focused', 'Loyal', 'Expert', 'Discerning'],
    color: '#f97316',
    gradient: 'from-orange-500 to-red-500',
  },
  completionist: {
    type: 'completionist',
    emoji: '✨',
    title: 'The Completionist',
    description: 'Once you start a series, there\'s no stopping until the finale credits roll.',
    traits: ['Determined', 'Thorough', 'Committed', 'Reliable'],
    color: '#22c55e',
    gradient: 'from-green-500 to-emerald-500',
  },
  night_owl: {
    type: 'night_owl',
    emoji: '🦉',
    title: 'The Night Owl',
    description: 'The moon rises and so does your anime queue. Late nights are your domain.',
    traits: ['Nocturnal', 'Mysterious', 'Focused', 'Independent'],
    color: '#8b5cf6',
    gradient: 'from-violet-500 to-purple-500',
  },
  variety_seeker: {
    type: 'variety_seeker',
    emoji: '🌈',
    title: 'The Variety Seeker',
    description: 'From shonen to slice-of-life, you sample everything anime has to offer!',
    traits: ['Adventurous', 'Eclectic', 'Flexible', 'Creative'],
    color: '#ec4899',
    gradient: 'from-pink-500 to-rose-500',
  },
  weekend_warrior: {
    type: 'weekend_warrior',
    emoji: '⚔️',
    title: 'The Weekend Warrior',
    description: 'Weekdays are for work, weekends are for anime battles. You fight on!',
    traits: ['Strategic', 'Patient', 'Balanced', 'Disciplined'],
    color: '#f59e0b',
    gradient: 'from-amber-500 to-orange-500',
  },
  new_adventurer: {
    type: 'new_adventurer',
    emoji: '🚀',
    title: 'The New Adventurer',
    description: 'Your anime journey is just beginning! So many worlds await you!',
    traits: ['Eager', 'Enthusiastic', 'Fresh', 'Optimistic'],
    color: '#3b82f6',
    gradient: 'from-blue-500 to-indigo-500',
  },
};

// Slide Types
export type SlideType = 
  | 'intro'
  | 'stats-overview'
  | 'top-anime'
  | 'habits'
  | 'personality'
  | 'ai-image'
  | 'share-card';

export interface Slide {
  id: SlideType;
  index: number;
  title: string;
  component: React.ComponentType<SlideProps>;
}

export interface SlideProps {
  stats: RewindStats;
  user: User;
  isActive: boolean;
  direction: 'left' | 'right' | null;
  onNext?: () => void;
  onPrevious?: () => void;
}

// Share Types
export interface ShareData {
  title: string;
  text: string;
  url: string;
  imageUrl?: string;
}

export interface CardData {
  username: string;
  stats: RewindStats;
  createdAt: Date;
}

// Animation Types
export interface AnimationConfig {
  duration: number;
  delay: number;
  ease: string;
}

// Loading States
export type LoadingState = 'idle' | 'loading' | 'success' | 'error' | 'insufficient-data';

export interface LoadingMessage {
  text: string;
  emoji: string;
}

export const LOADING_MESSAGES: LoadingMessage[] = [
  { text: 'Calculating your watch time...', emoji: '⏱️' },
  { text: 'Analyzing your anime taste...', emoji: '🎭' },
  { text: 'Finding your top shows...', emoji: '🏆' },
  { text: 'Determining your personality...', emoji: '🧠' },
  { text: 'Creating your unique rewind...', emoji: '✨' },
  { text: 'Almost there...', emoji: '🚀' },
];
