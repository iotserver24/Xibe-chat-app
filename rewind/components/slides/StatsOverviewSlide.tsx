'use client';

import { useEffect, useRef } from 'react';
import { motion } from 'framer-motion';
import { gsap } from 'gsap';
import { SlideProps } from '@/types';
import { formatNumber, getRankTitle, getPercentile } from '@/utils/rewindUtils';
import { staggerContainerVariants, staggerItemVariants, fadeInUpVariants } from '@/utils/animations';
import { Play, Clock, Star, Calendar, Trophy } from 'lucide-react';

interface StatCardProps {
  icon: React.ReactNode;
  value: number;
  label: string;
  suffix?: string;
  delay: number;
  gradient: string;
  isActive: boolean;
}

function StatCard({ icon, value, label, suffix = '', delay, gradient, isActive }: StatCardProps) {
  const valueRef = useRef<HTMLSpanElement>(null);
  const counterRef = useRef({ value: 0 });

  useEffect(() => {
    if (!isActive || !valueRef.current) return;

    const timer = setTimeout(() => {
      gsap.to(counterRef.current, {
        value,
        duration: 2,
        ease: 'power2.out',
        onUpdate: () => {
          if (valueRef.current) {
            valueRef.current.textContent = formatNumber(Math.round(counterRef.current.value)) + suffix;
          }
        },
      });
    }, delay * 1000);

    return () => {
      clearTimeout(timer);
      gsap.killTweensOf(counterRef.current);
    };
  }, [isActive, value, suffix, delay]);

  return (
    <motion.div
      variants={staggerItemVariants}
      whileHover={{ scale: 1.02, y: -5 }}
      className="stat-card relative overflow-hidden"
    >
      {/* Gradient background */}
      <div 
        className={`absolute inset-0 opacity-10 bg-gradient-to-br ${gradient}`}
      />
      
      {/* Icon */}
      <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${gradient} flex items-center justify-center mb-4`}>
        {icon}
      </div>

      {/* Value */}
      <span 
        ref={valueRef}
        className="text-3xl sm:text-4xl font-bold text-white counter block mb-2"
      >
        0{suffix}
      </span>

      {/* Label */}
      <span className="text-white/60 text-sm">{label}</span>
    </motion.div>
  );
}

export function StatsOverviewSlide({ stats, user, isActive }: SlideProps) {
  const rank = getRankTitle(stats.totalEpisodes);
  const percentile = getPercentile(stats.totalEpisodes);

  return (
    <div className="slide-wrapper">
      <div className="content-container">
        {/* Header */}
        <motion.div
          variants={fadeInUpVariants}
          initial="hidden"
          animate={isActive ? "visible" : "hidden"}
          className="text-center mb-8"
        >
          <h2 className="font-display text-3xl sm:text-4xl md:text-5xl font-bold mb-4">
            <span className="gradient-text">Your 2025</span>
            <br />
            <span className="text-white">In Numbers</span>
          </h2>
          <p className="text-white/60">
            Here&apos;s what you accomplished this year
          </p>
        </motion.div>

        {/* Stats grid */}
        <motion.div
          variants={staggerContainerVariants}
          initial="hidden"
          animate={isActive ? "visible" : "hidden"}
          className="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8"
        >
          <StatCard
            icon={<Play className="w-6 h-6 text-white" />}
            value={stats.totalEpisodes}
            label="Episodes Watched"
            delay={0.2}
            gradient="from-purple-500 to-pink-500"
            isActive={isActive}
          />
          <StatCard
            icon={<Clock className="w-6 h-6 text-white" />}
            value={stats.totalWatchTimeHours}
            label="Hours of Anime"
            suffix="h"
            delay={0.4}
            gradient="from-blue-500 to-cyan-500"
            isActive={isActive}
          />
          <StatCard
            icon={<Star className="w-6 h-6 text-white" />}
            value={stats.uniqueAnimeWatched}
            label="Unique Anime"
            delay={0.6}
            gradient="from-amber-500 to-orange-500"
            isActive={isActive}
          />
          <StatCard
            icon={<Calendar className="w-6 h-6 text-white" />}
            value={stats.daysActive}
            label="Days Active"
            delay={0.8}
            gradient="from-green-500 to-emerald-500"
            isActive={isActive}
          />
        </motion.div>

        {/* Rank card */}
        <motion.div
          variants={fadeInUpVariants}
          initial="hidden"
          animate={isActive ? "visible" : "hidden"}
          transition={{ delay: 1 }}
          className="glass-card p-6 text-center max-w-md mx-auto"
        >
          <div className="flex items-center justify-center gap-3 mb-4">
            <Trophy className="w-8 h-8 text-amber-400" />
            <span className="text-3xl">{rank.emoji}</span>
          </div>
          
          <h3 className="text-2xl font-bold text-white mb-2">
            {rank.title}
          </h3>
          
          <p className="text-white/60 mb-4">
            You&apos;re in the top <span className="text-primary-400 font-bold">{100 - percentile}%</span> of anime watchers!
          </p>

          {/* Fun comparison */}
          <div className="text-sm text-white/50">
            That&apos;s like watching a movie every{' '}
            <span className="text-primary-400">
              {Math.max(1, Math.round(365 / stats.uniqueAnimeWatched))} days
            </span>
          </div>
        </motion.div>

        {/* Average per day */}
        <motion.div
          variants={fadeInUpVariants}
          initial="hidden"
          animate={isActive ? "visible" : "hidden"}
          transition={{ delay: 1.2 }}
          className="text-center mt-6"
        >
          <p className="text-white/50 text-sm">
            Average: <span className="text-white">{stats.averageEpisodesPerDay} episodes</span> per day
          </p>
        </motion.div>
      </div>
    </div>
  );
}
