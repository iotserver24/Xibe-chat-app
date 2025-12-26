import type { CSSProperties } from 'react';
import { RewindStats, PersonalityType } from '@/types';

// Format time duration in a human-readable way
export function formatWatchTime(minutes: number): string {
  if (minutes < 60) {
    return `${minutes} min`;
  }
  
  const hours = Math.floor(minutes / 60);
  const remainingMinutes = minutes % 60;
  
  if (hours < 24) {
    return remainingMinutes > 0 ? `${hours}h ${remainingMinutes}m` : `${hours} hours`;
  }
  
  const days = Math.floor(hours / 24);
  const remainingHours = hours % 24;
  
  if (days < 7) {
    return remainingHours > 0 ? `${days}d ${remainingHours}h` : `${days} days`;
  }
  
  const weeks = Math.floor(days / 7);
  const remainingDays = days % 7;
  
  return remainingDays > 0 ? `${weeks}w ${remainingDays}d` : `${weeks} weeks`;
}

// Format large numbers with comma separators
export function formatNumber(num: number): string {
  return num.toLocaleString('en-US');
}

// Format hours with appropriate unit
export function formatHours(hours: number): string {
  if (hours >= 24) {
    const days = Math.floor(hours / 24);
    const remainingHours = hours % 24;
    return `${days} day${days !== 1 ? 's' : ''}${remainingHours > 0 ? ` ${remainingHours}h` : ''}`;
  }
  return `${hours} hour${hours !== 1 ? 's' : ''}`;
}

// Format hour to 12-hour time
export function formatHourTo12(hour: number): string {
  const ampm = hour >= 12 ? 'PM' : 'AM';
  const hour12 = hour % 12 || 12;
  return `${hour12} ${ampm}`;
}

// Get day name from index
export function getDayName(dayIndex: number): string {
  const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  return days[dayIndex];
}

// Get short day name
export function getShortDayName(dayName: string): string {
  return dayName.slice(0, 3);
}

// Calculate personality based on stats
export function calculatePersonality(stats: RewindStats): PersonalityType {
  return stats.personality;
}

// Get fun fact based on stats
export function getFunFact(stats: RewindStats): string {
  const facts = [
    `If you watched anime at work, you'd need ${Math.ceil(stats.totalWatchTimeHours / 8)} work days off!`,
    `You could have flown around the world ${Math.floor(stats.totalWatchTimeMinutes / (24 * 60))} times!`,
    `That's like reading ${Math.floor(stats.totalEpisodes * 0.5)} manga chapters!`,
    `You've watched enough to fill ${Math.floor(stats.totalWatchTimeMinutes / 90)} movie marathons!`,
    `If each episode was a meal, you'd eat anime for ${Math.floor(stats.totalEpisodes / 3)} days!`,
  ];
  
  // Pick based on a hash of the stats to be consistent
  const index = stats.totalEpisodes % facts.length;
  return facts[index];
}

// Generate share text for different platforms
export function generateShareText(stats: RewindStats, username: string): string {
  const text = `🎌 My AniSurge Rewind 2025\n\n` +
    `📺 ${formatNumber(stats.totalEpisodes)} episodes watched\n` +
    `⏱️ ${formatHours(stats.totalWatchTimeHours)} of anime\n` +
    `🎭 ${stats.uniqueAnimeWatched} unique anime\n` +
    `✨ I'm a ${stats.personality.title}!\n\n` +
    `Check out your anime year in review!`;
  
  return text;
}

// Generate Twitter share text (limited to 280 characters)
export function generateTwitterText(stats: RewindStats): string {
  return `🎌 My #AniSurgeRewind2025\n\n` +
    `📺 ${formatNumber(stats.totalEpisodes)} episodes\n` +
    `⏱️ ${stats.totalWatchTimeHours}h of anime\n` +
    `✨ I'm a ${stats.personality.title}!\n\n` +
    `Get your anime rewind 👇`;
}

// Generate Instagram caption
export function generateInstagramCaption(stats: RewindStats, username: string): string {
  return `🎌 My AniSurge Rewind 2025 ✨\n\n` +
    `This year I watched:\n` +
    `📺 ${formatNumber(stats.totalEpisodes)} episodes\n` +
    `⏱️ ${formatHours(stats.totalWatchTimeHours)}\n` +
    `🎭 ${stats.uniqueAnimeWatched} different anime\n\n` +
    `My anime personality: ${stats.personality.emoji} ${stats.personality.title}\n\n` +
    `"${stats.personality.description}"\n\n` +
    `#AniSurgeRewind2025 #AnimeRewind #Anime2025 #AnimeStats #AnimeCommunity`;
}

// Get color gradient based on personality
export function getPersonalityGradient(personality: PersonalityType): string {
  return personality.gradient;
}

// Get personality background style
export function getPersonalityBackground(personality: PersonalityType): CSSProperties {
  return {
    background: `linear-gradient(135deg, ${personality.color}20 0%, ${personality.color}05 100%)`,
    borderColor: `${personality.color}40`,
  };
}

// Calculate rank title based on stats
export function getRankTitle(totalEpisodes: number): { title: string; emoji: string } {
  if (totalEpisodes >= 1000) return { title: 'Legendary Otaku', emoji: '🏆' };
  if (totalEpisodes >= 500) return { title: 'Elite Weeb', emoji: '⭐' };
  if (totalEpisodes >= 200) return { title: 'Dedicated Fan', emoji: '🎖️' };
  if (totalEpisodes >= 100) return { title: 'Anime Enthusiast', emoji: '🎭' };
  if (totalEpisodes >= 50) return { title: 'Rising Weeb', emoji: '🌟' };
  if (totalEpisodes >= 20) return { title: 'Anime Explorer', emoji: '🔍' };
  return { title: 'New Adventurer', emoji: '🚀' };
}

// Calculate percentile (mock - in real app would compare to all users)
export function getPercentile(totalEpisodes: number): number {
  // Mock percentile calculation
  if (totalEpisodes >= 500) return 99;
  if (totalEpisodes >= 300) return 95;
  if (totalEpisodes >= 200) return 90;
  if (totalEpisodes >= 100) return 75;
  if (totalEpisodes >= 50) return 50;
  if (totalEpisodes >= 20) return 25;
  return 10;
}

// Format date nicely
export function formatDate(date: Date): string {
  return date.toLocaleDateString('en-US', {
    month: 'long',
    day: 'numeric',
    year: 'numeric',
  });
}

// Get relative time string
export function getRelativeTime(date: Date): string {
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
  
  if (diffDays < 1) return 'today';
  if (diffDays === 1) return 'yesterday';
  if (diffDays < 7) return `${diffDays} days ago`;
  if (diffDays < 30) return `${Math.floor(diffDays / 7)} weeks ago`;
  if (diffDays < 365) return `${Math.floor(diffDays / 30)} months ago`;
  return `${Math.floor(diffDays / 365)} years ago`;
}

// Calculate journey length
export function getJourneyLength(startDate: Date): string {
  const now = new Date();
  const diffMs = now.getTime() - startDate.getTime();
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
  
  if (diffDays < 30) return `${diffDays} days`;
  if (diffDays < 365) return `${Math.floor(diffDays / 30)} months`;
  
  const years = Math.floor(diffDays / 365);
  const months = Math.floor((diffDays % 365) / 30);
  
  if (months === 0) return `${years} year${years !== 1 ? 's' : ''}`;
  return `${years}y ${months}m`;
}
