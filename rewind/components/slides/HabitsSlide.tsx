'use client';

import { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { gsap } from 'gsap';
import { SlideProps } from '@/types';
import { formatHourTo12, getShortDayName } from '@/utils/rewindUtils';
import { fadeInUpVariants, staggerContainerVariants, staggerItemVariants } from '@/utils/animations';
import { Clock, Subtitles, Calendar } from 'lucide-react';

// Donut chart component for sub vs dub
function DonutChart({ subPercent, isActive }: { subPercent: number; isActive: boolean }) {
  const [animatedPercent, setAnimatedPercent] = useState(0);
  const circumference = 2 * Math.PI * 45;

  useEffect(() => {
    if (!isActive) return;
    
    let tween: gsap.core.Tween | null = null;
    const animTarget = { value: 0 };
    
    const timer = setTimeout(() => {
      tween = gsap.to(animTarget, {
        value: subPercent,
        duration: 1.5,
        ease: 'power2.out',
        onUpdate: function() {
          setAnimatedPercent(animTarget.value);
        },
      });
    }, 500);

    return () => {
      clearTimeout(timer);
      if (tween) tween.kill();
    };
  }, [isActive, subPercent]);

  return (
    <div className="relative w-40 h-40 mx-auto">
      <svg viewBox="0 0 100 100" className="transform -rotate-90 w-full h-full">
        {/* Background circle */}
        <circle
          cx="50"
          cy="50"
          r="45"
          fill="none"
          stroke="rgba(255,255,255,0.1)"
          strokeWidth="10"
        />
        {/* Sub portion */}
        <circle
          cx="50"
          cy="50"
          r="45"
          fill="none"
          stroke="url(#subGradient)"
          strokeWidth="10"
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={circumference * (1 - animatedPercent / 100)}
          className="transition-all duration-300"
        />
        <defs>
          <linearGradient id="subGradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#d946ef" />
            <stop offset="100%" stopColor="#ec4899" />
          </linearGradient>
        </defs>
      </svg>
      
      {/* Center text */}
      <div className="absolute inset-0 flex flex-col items-center justify-center">
        <span className="text-3xl font-bold text-white">{Math.round(animatedPercent)}%</span>
        <span className="text-sm text-white/60">Sub</span>
      </div>
    </div>
  );
}

const DAYS_OF_WEEK = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'] as const;

// Bar chart for watch time by day
function DayChart({ data, isActive }: { data: { [key: string]: number }; isActive: boolean }) {
  const [heights, setHeights] = useState<{ [key: string]: number }>({});
  const maxValue = Math.max(...Object.values(data), 1); // Ensure maxValue is at least 1

  useEffect(() => {
    if (!isActive) return;

    const initialHeights: { [key: string]: number } = {};
    DAYS_OF_WEEK.forEach(day => { initialHeights[day] = 0; });
    setHeights(initialHeights);

    const timeoutIds: NodeJS.Timeout[] = [];
    const tweens: gsap.core.Tween[] = [];

    DAYS_OF_WEEK.forEach((day, index) => {
      const animTarget = { value: 0 };
      const timeoutId = setTimeout(() => {
        const tween = gsap.to(animTarget, {
          value: (data[day] / maxValue) * 100,
          duration: 1,
          ease: 'power2.out',
          onUpdate: function() {
            setHeights(prev => ({ ...prev, [day]: animTarget.value }));
          },
        });
        tweens.push(tween);
      }, index * 100);
      timeoutIds.push(timeoutId);
    });

    return () => {
      timeoutIds.forEach(id => clearTimeout(id));
      tweens.forEach(tween => tween.kill());
    };
  }, [isActive, data, maxValue]);

  return (
    <div className="flex items-end justify-between gap-2 h-32">
      {DAYS_OF_WEEK.map((day) => (
        <div key={day} className="flex-1 flex flex-col items-center gap-2">
          <div className="w-full bg-white/5 rounded-t-lg overflow-hidden h-24 flex items-end">
            <motion.div
              className={`w-full rounded-t-lg ${
                day === 'Saturday' || day === 'Sunday'
                  ? 'bg-gradient-to-t from-primary-500 to-pink-500'
                  : 'bg-gradient-to-t from-primary-500/60 to-pink-500/60'
              }`}
              style={{ height: `${heights[day] || 0}%` }}
            />
          </div>
          <span className="text-xs text-white/50">{getShortDayName(day)}</span>
        </div>
      ))}
    </div>
  );
}

export function HabitsSlide({ stats, isActive }: SlideProps) {
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
            <span className="text-white">Your Watching</span>{' '}
            <span className="gradient-text">Habits</span>
          </h2>
          <p className="text-white/60">
            When and how you watch
          </p>
        </motion.div>

        <motion.div
          variants={staggerContainerVariants}
          initial="hidden"
          animate={isActive ? "visible" : "hidden"}
          className="space-y-6"
        >
          {/* Sub vs Dub */}
          <motion.div
            variants={staggerItemVariants}
            className="glass-card p-6"
          >
            <div className="flex items-center gap-2 mb-4">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-primary-500 to-pink-500 flex items-center justify-center">
                <Subtitles className="w-5 h-5 text-white" />
              </div>
              <h3 className="font-semibold text-white">Sub vs Dub</h3>
            </div>

            <div className="flex items-center justify-around gap-4">
              <DonutChart subPercent={stats.subVsDub.percentage} isActive={isActive} />
              
              <div className="space-y-4">
                <div className="flex items-center gap-3">
                  <div className="w-4 h-4 rounded-full bg-gradient-to-r from-primary-500 to-pink-500" />
                  <div>
                    <p className="text-white font-medium">{stats.subVsDub.sub} anime</p>
                    <p className="text-sm text-white/50">Subtitles</p>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <div className="w-4 h-4 rounded-full bg-white/20" />
                  <div>
                    <p className="text-white font-medium">{stats.subVsDub.dub} anime</p>
                    <p className="text-sm text-white/50">Dubbed</p>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>

          {/* Watch time by day */}
          <motion.div
            variants={staggerItemVariants}
            className="glass-card p-6"
          >
            <div className="flex items-center gap-2 mb-6">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500 to-cyan-500 flex items-center justify-center">
                <Calendar className="w-5 h-5 text-white" />
              </div>
              <h3 className="font-semibold text-white">Watch Time by Day</h3>
            </div>

            <DayChart data={stats.watchTimeByDay} isActive={isActive} />

            <p className="text-center text-white/50 text-sm mt-4">
              {Object.keys(stats.watchTimeByDay).length > 0 
                ? `${Object.entries(stats.watchTimeByDay).sort((a, b) => b[1] - a[1])[0][0]} is your binge day! 📺`
                : 'Track your watching habits! 📺'}
            </p>
          </motion.div>

          {/* Peak hour */}
          <motion.div
            variants={staggerItemVariants}
            className="glass-card p-6"
          >
            <div className="flex items-center gap-2 mb-4">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-amber-500 to-orange-500 flex items-center justify-center">
                <Clock className="w-5 h-5 text-white" />
              </div>
              <h3 className="font-semibold text-white">Peak Watching Hour</h3>
            </div>

            <div className="flex items-center justify-center gap-4">
              <motion.div
                initial={{ scale: 0 }}
                animate={isActive ? { scale: 1 } : { scale: 0 }}
                transition={{ delay: 0.8, type: 'spring' }}
                className="text-5xl"
              >
                {stats.peakWatchingHour >= 22 || stats.peakWatchingHour <= 4 ? '🌙' : 
                 stats.peakWatchingHour >= 17 ? '🌆' : 
                 stats.peakWatchingHour >= 12 ? '☀️' : '🌅'}
              </motion.div>
              
              <div className="text-center">
                <p className="text-3xl font-bold text-white">
                  {formatHourTo12(stats.peakWatchingHour)}
                </p>
                <p className="text-white/50 text-sm">
                  {stats.peakWatchingHour >= 22 || stats.peakWatchingHour <= 4 
                    ? 'Night owl vibes 🦉' 
                    : stats.peakWatchingHour >= 17 
                    ? 'Evening chill time' 
                    : 'Daytime watcher'}
                </p>
              </div>
            </div>
          </motion.div>
        </motion.div>
      </div>
    </div>
  );
}
