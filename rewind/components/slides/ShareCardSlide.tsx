'use client';

import { useRef, useState } from 'react';
import { motion } from 'framer-motion';
import { useRouter } from 'next/navigation';
import { signOut } from 'firebase/auth';
import { auth } from '@/services/firebaseConfig';
import { SlideProps } from '@/types';
import { formatNumber, formatHours } from '@/utils/rewindUtils';
import { fadeInUpVariants, staggerContainerVariants, staggerItemVariants, buttonHoverVariants } from '@/utils/animations';
import { ShareModal } from '@/components/Share/ShareModal';
import { CardDownloader } from '@/components/Share/CardDownloader';
import toast from 'react-hot-toast';
import { 
  Share2, 
  Download, 
  Image as ImageIcon, 
  LogOut, 
  Twitter, 
  Copy, 
  CheckCircle,
  Sparkles 
} from 'lucide-react';

interface ShareCardSlideProps extends SlideProps {
  aiImageUrl: string | null;
}

export function ShareCardSlide({ stats, user, isActive, aiImageUrl }: ShareCardSlideProps) {
  const router = useRouter();
  const cardRef = useRef<HTMLDivElement>(null);
  const [isShareModalOpen, setIsShareModalOpen] = useState(false);
  const [isDownloading, setIsDownloading] = useState(false);

  const handleLogout = async () => {
    try {
      await signOut(auth);
      toast.success('See you next year! 👋');
      router.push('/');
    } catch (error) {
      console.error('Logout error:', error);
      toast.error('Failed to sign out');
    }
  };

  const handleDownload = () => {
    setIsDownloading(true);
    // CardDownloader will handle the actual download
  };

  return (
    <div className="slide-wrapper overflow-y-auto">
      <div className="content-container py-16">
        {/* Header */}
        <motion.div
          variants={fadeInUpVariants}
          initial="hidden"
          animate={isActive ? "visible" : "hidden"}
          className="text-center mb-6"
        >
          <h2 className="font-display text-3xl sm:text-4xl md:text-5xl font-bold mb-4">
            <span className="text-white">Share Your</span>{' '}
            <span className="gradient-text">Rewind</span>
          </h2>
          <p className="text-white/60">
            Show off your anime journey to the world!
          </p>
        </motion.div>

        {/* Share Card Preview */}
        <motion.div
          variants={fadeInUpVariants}
          initial="hidden"
          animate={isActive ? "visible" : "hidden"}
          className="max-w-md mx-auto mb-8"
        >
          <div
            ref={cardRef}
            className="relative rounded-3xl overflow-hidden"
            style={{
              background: 'linear-gradient(135deg, #0f0f1a 0%, #1a0a2e 50%, #0a1a2e 100%)',
            }}
          >
            {/* Card content */}
            <div className="p-6 sm:p-8">
              {/* Logo and year */}
              <div className="flex items-center justify-between mb-6">
                <div className="flex items-center gap-2">
                  <span className="text-2xl">🎌</span>
                  <span className="font-display font-bold text-lg gradient-text">AniSurge</span>
                </div>
                <span className="text-white/60 font-medium">REWIND 2025</span>
              </div>

              {/* User info */}
              <div className="flex items-center gap-3 mb-6">
                {user.photoURL && (
                  <img
                    src={user.photoURL}
                    alt={user.displayName || 'User'}
                    className="w-12 h-12 rounded-full border-2 border-primary-500/50"
                  />
                )}
                <div>
                  <h3 className="font-semibold text-white text-lg">
                    {user.displayName || 'Anime Fan'}
                  </h3>
                  <p className="text-white/50 text-sm">{stats.personality.title}</p>
                </div>
              </div>

              {/* Stats grid */}
              <div className="grid grid-cols-2 gap-4 mb-6">
                <div className="glass-card p-4 text-center">
                  <p className="text-2xl font-bold text-white">{formatNumber(stats.totalEpisodes)}</p>
                  <p className="text-xs text-white/50">Episodes</p>
                </div>
                <div className="glass-card p-4 text-center">
                  <p className="text-2xl font-bold text-white">{stats.totalWatchTimeHours}h</p>
                  <p className="text-xs text-white/50">Watch Time</p>
                </div>
                <div className="glass-card p-4 text-center">
                  <p className="text-2xl font-bold text-white">{stats.uniqueAnimeWatched}</p>
                  <p className="text-xs text-white/50">Anime</p>
                </div>
                <div className="glass-card p-4 text-center">
                  <p className="text-2xl font-bold text-white">{stats.daysActive}</p>
                  <p className="text-xs text-white/50">Days Active</p>
                </div>
              </div>

              {/* Top anime */}
              <div className="mb-6">
                <p className="text-white/50 text-xs mb-2">TOP ANIME</p>
                <div className="flex gap-2 overflow-hidden">
                  {stats.topAnime.slice(0, 3).map((entry, index) => (
                    <div
                      key={entry.anime.id}
                      className="flex-1 h-16 rounded-lg overflow-hidden relative"
                    >
                      <img
                        src={entry.anime.imageUrl}
                        alt={entry.anime.title}
                        className="w-full h-full object-cover"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-black/80 to-transparent" />
                      <span className="absolute bottom-1 left-1 text-xs font-bold text-white">
                        #{index + 1}
                      </span>
                    </div>
                  ))}
                </div>
              </div>

              {/* Personality */}
              <div 
                className="rounded-xl p-4 text-center"
                style={{
                  background: `linear-gradient(135deg, ${stats.personality.color}20 0%, ${stats.personality.color}05 100%)`,
                  border: `1px solid ${stats.personality.color}30`,
                }}
              >
                <span className="text-3xl mb-2 block">{stats.personality.emoji}</span>
                <p className="font-semibold text-white">{stats.personality.title}</p>
              </div>

              {/* Footer */}
              <div className="mt-6 pt-4 border-t border-white/10 text-center">
                <p className="text-white/40 text-xs">
                  Get your rewind at anisurge.app/rewind
                </p>
              </div>
            </div>

            {/* Decorative elements */}
            <div className="absolute top-0 right-0 w-32 h-32 bg-gradient-to-br from-primary-500/20 to-transparent rounded-full blur-2xl" />
            <div className="absolute bottom-0 left-0 w-24 h-24 bg-gradient-to-tr from-accent-500/20 to-transparent rounded-full blur-2xl" />
          </div>
        </motion.div>

        {/* Action buttons */}
        <motion.div
          variants={staggerContainerVariants}
          initial="hidden"
          animate={isActive ? "visible" : "hidden"}
          className="space-y-4 max-w-md mx-auto"
        >
          {/* Primary actions */}
          <motion.div
            variants={staggerItemVariants}
            className="grid grid-cols-2 gap-4"
          >
            <motion.button
              variants={buttonHoverVariants}
              initial="rest"
              whileHover="hover"
              whileTap="tap"
              onClick={() => setIsShareModalOpen(true)}
              className="btn-primary flex items-center justify-center gap-2"
            >
              <Share2 className="w-5 h-5" />
              Share
            </motion.button>

            <CardDownloader
              cardRef={cardRef}
              username={user.displayName || 'User'}
              onDownloadStart={() => setIsDownloading(true)}
              onDownloadEnd={() => setIsDownloading(false)}
            >
              <motion.button
                variants={buttonHoverVariants}
                initial="rest"
                whileHover="hover"
                whileTap="tap"
                disabled={isDownloading}
                className="btn-secondary flex items-center justify-center gap-2 w-full"
              >
                {isDownloading ? (
                  <motion.div
                    animate={{ rotate: 360 }}
                    transition={{ duration: 1, repeat: Infinity, ease: 'linear' }}
                  >
                    <Download className="w-5 h-5" />
                  </motion.div>
                ) : (
                  <Download className="w-5 h-5" />
                )}
                Save Card
              </motion.button>
            </CardDownloader>
          </motion.div>

          {/* Story format button */}
          <motion.button
            variants={staggerItemVariants}
            onClick={() => setIsShareModalOpen(true)}
            className="w-full btn-secondary flex items-center justify-center gap-2"
          >
            <ImageIcon className="w-5 h-5" />
            Save as Story
          </motion.button>

          {/* Logout */}
          <motion.button
            variants={staggerItemVariants}
            onClick={handleLogout}
            className="w-full py-3 text-white/50 hover:text-white/80 transition-colors flex items-center justify-center gap-2"
          >
            <LogOut className="w-4 h-4" />
            Sign Out
          </motion.button>
        </motion.div>

        {/* Thank you message */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={isActive ? { opacity: 1 } : {}}
          transition={{ delay: 1.5 }}
          className="text-center mt-8"
        >
          <p className="text-white/40 text-sm">
            Thanks for being part of our anime community! 💜
          </p>
          <p className="text-white/30 text-xs mt-2">
            See you in 2026!
          </p>
        </motion.div>
      </div>

      {/* Share Modal */}
      <ShareModal
        isOpen={isShareModalOpen}
        onClose={() => setIsShareModalOpen(false)}
        stats={stats}
        user={user}
        cardRef={cardRef}
      />
    </div>
  );
}
