'use client';

import { useCallback, useRef, useState } from 'react';
import { motion } from 'framer-motion';
import html2canvas from 'html2canvas';
import { RewindStats, User } from '@/types';
import { formatNumber } from '@/utils/rewindUtils';
import { generateDownloadFilename } from '@/utils/shareUtils';
import toast from 'react-hot-toast';
import { Download, Loader2 } from 'lucide-react';

interface StoryGeneratorProps {
  stats: RewindStats;
  user: User;
  aiImageUrl: string | null;
}

export function StoryGenerator({ stats, user, aiImageUrl }: StoryGeneratorProps) {
  const storyRef = useRef<HTMLDivElement>(null);
  const [isGenerating, setIsGenerating] = useState(false);

  const handleGenerateStory = useCallback(async () => {
    if (!storyRef.current) return;

    setIsGenerating(true);

    try {
      await new Promise(resolve => setTimeout(resolve, 100));

      const canvas = await html2canvas(storyRef.current, {
        backgroundColor: null,
        scale: 2,
        useCORS: true,
        allowTaint: true,
        logging: false,
        width: 1080,
        height: 1920,
      });

      const blob = await new Promise<Blob>((resolve, reject) => {
        canvas.toBlob(
          (blob) => {
            if (blob) resolve(blob);
            else reject(new Error('Failed to create image'));
          },
          'image/png',
          1.0
        );
      });

      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = generateDownloadFilename(user.displayName || 'User', 'story');
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);

      toast.success('Story saved! Share it on Instagram or TikTok 📱');
    } catch (error) {
      console.error('Story generation error:', error);
      toast.error('Failed to generate story');
    } finally {
      setIsGenerating(false);
    }
  }, [user.displayName]);

  return (
    <div className="space-y-4">
      {/* Story preview (9:16 aspect ratio) */}
      <div className="relative w-full max-w-[270px] mx-auto">
        <div
          ref={storyRef}
          className="aspect-[9/16] rounded-2xl overflow-hidden relative"
          style={{
            background: 'linear-gradient(180deg, #0a0a0b 0%, #1a0a2e 30%, #0a1a2e 70%, #0a0a0b 100%)',
          }}
        >
          {/* Background effects */}
          <div className="absolute inset-0">
            <div className="absolute top-0 left-1/2 -translate-x-1/2 w-64 h-64 bg-primary-500/20 rounded-full blur-3xl" />
            <div className="absolute bottom-1/3 right-0 w-48 h-48 bg-accent-500/20 rounded-full blur-3xl" />
          </div>

          {/* Content */}
          <div className="relative h-full flex flex-col p-6 z-10">
            {/* Header */}
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-2">
                <span className="text-xl">🎌</span>
                <span className="font-display font-bold text-sm gradient-text">AniSurge</span>
              </div>
              <span className="text-white/50 text-xs font-medium">REWIND 2025</span>
            </div>

            {/* User avatar */}
            <div className="flex-1 flex flex-col items-center justify-center">
              {user.photoURL && (
                <img
                  src={user.photoURL}
                  alt=""
                  className="w-20 h-20 rounded-full border-4 border-primary-500/50 mb-4"
                />
              )}
              
              <h3 className="font-display font-bold text-2xl text-white mb-2 text-center">
                {user.displayName || 'Anime Fan'}
              </h3>
              
              <div className="text-4xl mb-4">{stats.personality.emoji}</div>
              
              <p 
                className="font-semibold text-lg mb-6 text-center"
                style={{ color: stats.personality.color }}
              >
                {stats.personality.title}
              </p>

              {/* Stats */}
              <div className="grid grid-cols-2 gap-4 w-full max-w-[200px]">
                <div className="glass-card p-3 text-center">
                  <p className="text-2xl font-bold text-white">{formatNumber(stats.totalEpisodes)}</p>
                  <p className="text-[10px] text-white/50">EPISODES</p>
                </div>
                <div className="glass-card p-3 text-center">
                  <p className="text-2xl font-bold text-white">{stats.totalWatchTimeHours}h</p>
                  <p className="text-[10px] text-white/50">WATCH TIME</p>
                </div>
                <div className="glass-card p-3 text-center">
                  <p className="text-2xl font-bold text-white">{stats.uniqueAnimeWatched}</p>
                  <p className="text-[10px] text-white/50">ANIME</p>
                </div>
                <div className="glass-card p-3 text-center">
                  <p className="text-2xl font-bold text-white">{stats.daysActive}</p>
                  <p className="text-[10px] text-white/50">DAYS</p>
                </div>
              </div>

              {/* Top anime images */}
              <div className="flex gap-1 mt-6">
                {stats.topAnime.slice(0, 3).map((entry) => (
                  <div
                    key={entry.anime.id}
                    className="w-12 h-16 rounded-lg overflow-hidden"
                  >
                    <img
                      src={entry.anime.imageUrl}
                      alt=""
                      className="w-full h-full object-cover"
                    />
                  </div>
                ))}
              </div>
            </div>

            {/* Footer */}
            <div className="text-center mt-auto">
              <p className="text-white/30 text-xs">anisurge.app/rewind</p>
            </div>
          </div>
        </div>
      </div>

      {/* Generate button */}
      <motion.button
        whileHover={{ scale: 1.02 }}
        whileTap={{ scale: 0.98 }}
        onClick={handleGenerateStory}
        disabled={isGenerating}
        className="w-full btn-primary flex items-center justify-center gap-2"
      >
        {isGenerating ? (
          <>
            <Loader2 className="w-5 h-5 animate-spin" />
            Generating...
          </>
        ) : (
          <>
            <Download className="w-5 h-5" />
            Save Story (9:16)
          </>
        )}
      </motion.button>
    </div>
  );
}
