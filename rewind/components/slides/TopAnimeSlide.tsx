'use client';

import { motion } from 'framer-motion';
import Image from 'next/image';
import { SlideProps } from '@/types';
import { formatWatchTime } from '@/utils/rewindUtils';
import { staggerContainerVariants, staggerItemVariants, fadeInUpVariants } from '@/utils/animations';
import { Crown, Play, Clock, Star } from 'lucide-react';

export function TopAnimeSlide({ stats, isActive }: SlideProps) {
  const topAnime = stats.topAnime;

  return (
    <div className="slide-wrapper overflow-y-auto">
      <div className="content-container py-16">
        {/* Header */}
        <motion.div
          variants={fadeInUpVariants}
          initial="hidden"
          animate={isActive ? "visible" : "hidden"}
          className="text-center mb-8"
        >
          <h2 className="font-display text-3xl sm:text-4xl md:text-5xl font-bold mb-4">
            <span className="text-white">Your</span>{' '}
            <span className="gradient-text">Top Anime</span>
          </h2>
          <p className="text-white/60">
            The shows that defined your year
          </p>
        </motion.div>

        {/* Top anime list */}
        <motion.div
          variants={staggerContainerVariants}
          initial="hidden"
          animate={isActive ? "visible" : "hidden"}
          className="space-y-4"
        >
          {topAnime.map((entry, index) => (
            <motion.div
              key={entry.anime.id}
              variants={staggerItemVariants}
              whileHover={{ scale: 1.02, x: 10 }}
              className={`relative overflow-hidden rounded-2xl ${
                index === 0 ? 'glass-card border-2 border-primary-500/50' : 'glass-card'
              }`}
            >
              <div className="flex items-stretch">
                {/* Rank badge */}
                <div className={`w-16 sm:w-20 flex-shrink-0 flex items-center justify-center ${
                  index === 0 
                    ? 'bg-gradient-to-br from-amber-400 to-orange-500' 
                    : index === 1 
                    ? 'bg-gradient-to-br from-slate-300 to-slate-400'
                    : index === 2
                    ? 'bg-gradient-to-br from-amber-600 to-amber-700'
                    : 'bg-white/5'
                }`}>
                  {index === 0 ? (
                    <Crown className="w-8 h-8 text-white" />
                  ) : (
                    <span className={`text-2xl font-bold ${
                      index < 3 ? 'text-white' : 'text-white/50'
                    }`}>
                      #{entry.rank}
                    </span>
                  )}
                </div>

                {/* Anime image */}
                <div className="w-20 sm:w-28 h-28 sm:h-36 flex-shrink-0 relative overflow-hidden">
                  <Image
                    src={entry.anime.imageUrl}
                    alt={entry.anime.title}
                    fill
                    className="object-cover"
                    sizes="(max-width: 640px) 80px, 112px"
                  />
                  {index === 0 && (
                    <div className="absolute inset-0 bg-gradient-to-r from-primary-500/20 to-transparent" />
                  )}
                </div>

                {/* Info */}
                <div className="flex-1 p-4 flex flex-col justify-center min-w-0">
                  <h3 className={`font-semibold mb-2 truncate ${
                    index === 0 ? 'text-lg sm:text-xl text-white' : 'text-base sm:text-lg text-white/90'
                  }`}>
                    {entry.anime.title}
                  </h3>
                  
                  <div className="flex flex-wrap items-center gap-3 text-sm text-white/60">
                    <div className="flex items-center gap-1">
                      <Play className="w-4 h-4" />
                      <span>{entry.episodesWatched} eps</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <Clock className="w-4 h-4" />
                      <span>{formatWatchTime(entry.watchTimeMinutes)}</span>
                    </div>
                    {entry.anime.score && (
                      <div className="flex items-center gap-1 text-amber-400">
                        <Star className="w-4 h-4 fill-current" />
                        <span>{entry.anime.score}/10</span>
                      </div>
                    )}
                  </div>

                  {/* Genres */}
                  <div className="flex flex-wrap gap-1 mt-2">
                    {entry.anime.genres.slice(0, 3).map((genre) => (
                      <span
                        key={genre}
                        className="text-xs px-2 py-0.5 rounded-full bg-white/10 text-white/60"
                      >
                        {genre}
                      </span>
                    ))}
                  </div>
                </div>
              </div>

              {/* Glow effect for #1 */}
              {index === 0 && (
                <motion.div
                  className="absolute inset-0 pointer-events-none"
                  animate={{
                    boxShadow: [
                      'inset 0 0 20px rgba(217, 70, 239, 0.1)',
                      'inset 0 0 40px rgba(217, 70, 239, 0.2)',
                      'inset 0 0 20px rgba(217, 70, 239, 0.1)',
                    ],
                  }}
                  transition={{
                    duration: 2,
                    repeat: Infinity,
                    ease: 'easeInOut',
                  }}
                />
              )}
            </motion.div>
          ))}
        </motion.div>

        {/* Most recent */}
        {stats.mostRecentAnime && (
          <motion.div
            variants={fadeInUpVariants}
            initial="hidden"
            animate={isActive ? "visible" : "hidden"}
            transition={{ delay: 1 }}
            className="text-center mt-8"
          >
            <p className="text-white/50 text-sm">
              Most recently watched:{' '}
              <span className="text-primary-400">{stats.mostRecentAnime}</span>
            </p>
          </motion.div>
        )}
      </div>
    </div>
  );
}
