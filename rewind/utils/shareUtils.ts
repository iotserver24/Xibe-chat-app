import { RewindStats, ShareData } from '@/types';
import { formatNumber, formatHours, generateTwitterText } from './rewindUtils';

const SITE_URL = process.env.NEXT_PUBLIC_SITE_URL || 'https://anisurge.app';

// Generate shareable URL
export function generateShareUrl(userId: string): string {
  return `${SITE_URL}/rewind/share/${userId}`;
}

// Copy text to clipboard
export async function copyToClipboard(text: string): Promise<boolean> {
  try {
    await navigator.clipboard.writeText(text);
    return true;
  } catch (error) {
    console.error('Failed to copy:', error);
    // Fallback for older browsers
    try {
      const textArea = document.createElement('textarea');
      textArea.value = text;
      textArea.style.position = 'fixed';
      textArea.style.left = '-999999px';
      document.body.appendChild(textArea);
      textArea.select();
      document.execCommand('copy');
      document.body.removeChild(textArea);
      return true;
    } catch {
      return false;
    }
  }
}

// Share to Twitter/X
export function shareToTwitter(stats: RewindStats, shareUrl: string): void {
  const text = generateTwitterText(stats);
  const url = `https://twitter.com/intent/tweet?text=${encodeURIComponent(text)}&url=${encodeURIComponent(shareUrl)}`;
  window.open(url, '_blank', 'width=600,height=400');
}

// Share to Reddit
export function shareToReddit(stats: RewindStats, shareUrl: string): void {
  const title = `My AniSurge Rewind 2025 - ${formatNumber(stats.totalEpisodes)} episodes watched!`;
  const url = `https://reddit.com/submit?url=${encodeURIComponent(shareUrl)}&title=${encodeURIComponent(title)}`;
  window.open(url, '_blank', 'width=600,height=600');
}

// Share to Discord (copy formatted message)
export function generateDiscordMessage(stats: RewindStats, shareUrl: string): string {
  return `# 🎌 My AniSurge Rewind 2025\n\n` +
    `**📺 Episodes Watched:** ${formatNumber(stats.totalEpisodes)}\n` +
    `**⏱️ Watch Time:** ${formatHours(stats.totalWatchTimeHours)}\n` +
    `**🎭 Anime Watched:** ${stats.uniqueAnimeWatched}\n` +
    `**✨ Personality:** ${stats.personality.emoji} ${stats.personality.title}\n\n` +
    `> "${stats.personality.description}"\n\n` +
    `Get your anime rewind: ${shareUrl}`;
}

// Native share API (for mobile)
export async function nativeShare(data: ShareData): Promise<boolean> {
  if (navigator.share) {
    try {
      await navigator.share({
        title: data.title,
        text: data.text,
        url: data.url,
      });
      return true;
    } catch (error) {
      if ((error as Error).name !== 'AbortError') {
        console.error('Share failed:', error);
      }
      return false;
    }
  }
  return false;
}

// Generate email share link
export function generateEmailShare(stats: RewindStats, shareUrl: string): string {
  const subject = encodeURIComponent('Check out my AniSurge Rewind 2025!');
  const body = encodeURIComponent(
    `Hey!\n\n` +
    `I just got my anime year in review and wanted to share it with you!\n\n` +
    `This year I watched:\n` +
    `📺 ${formatNumber(stats.totalEpisodes)} episodes\n` +
    `⏱️ ${formatHours(stats.totalWatchTimeHours)} of anime\n` +
    `🎭 ${stats.uniqueAnimeWatched} different anime\n\n` +
    `My anime personality is: ${stats.personality.emoji} ${stats.personality.title}\n\n` +
    `Check out my full rewind here: ${shareUrl}\n\n` +
    `You should get yours too!`
  );
  
  return `mailto:?subject=${subject}&body=${body}`;
}

// Generate WhatsApp share link
export function generateWhatsAppShare(stats: RewindStats, shareUrl: string): string {
  const text = encodeURIComponent(
    `🎌 My AniSurge Rewind 2025\n\n` +
    `📺 ${formatNumber(stats.totalEpisodes)} episodes watched\n` +
    `⏱️ ${formatHours(stats.totalWatchTimeHours)} of anime\n` +
    `✨ I'm a ${stats.personality.title}!\n\n` +
    `Check it out: ${shareUrl}`
  );
  
  return `https://wa.me/?text=${text}`;
}

// Generate Telegram share link
export function generateTelegramShare(stats: RewindStats, shareUrl: string): string {
  const text = encodeURIComponent(
    `🎌 My AniSurge Rewind 2025\n` +
    `📺 ${formatNumber(stats.totalEpisodes)} episodes • ⏱️ ${stats.totalWatchTimeHours}h\n` +
    `✨ ${stats.personality.title}`
  );
  
  return `https://t.me/share/url?url=${encodeURIComponent(shareUrl)}&text=${text}`;
}

// Format stats for OG image text
export function formatOGStats(stats: RewindStats): string[] {
  return [
    `${formatNumber(stats.totalEpisodes)} episodes`,
    `${formatHours(stats.totalWatchTimeHours)}`,
    `${stats.uniqueAnimeWatched} anime`,
    stats.personality.title,
  ];
}

// Generate filename for downloads
export function generateDownloadFilename(username: string, type: 'card' | 'story'): string {
  const sanitizedUsername = username.replace(/[^a-zA-Z0-9]/g, '_');
  const timestamp = new Date().toISOString().split('T')[0];
  return `anisurge_rewind_2025_${sanitizedUsername}_${type}_${timestamp}.png`;
}
