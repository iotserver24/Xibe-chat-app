'use client';

import { useState, useEffect, useCallback } from 'react';
import { useQuery } from '@tanstack/react-query';
import { RewindStats, LoadingState, User } from '@/types';
import { RewindDataService, generateMockRewindStats } from '@/services/rewindDataService';
import { AIService } from '@/services/aiService';

const MIN_ANIME_REQUIRED = 5;
const USE_MOCK_DATA = true; // Set to false when connecting to real Firebase data

interface UseRewindDataResult {
  stats: RewindStats | null;
  loadingState: LoadingState;
  error: string | null;
  refetch: () => void;
  aiImageUrl: string | null;
  isAiImageLoading: boolean;
}

export function useRewindData(user: User | null): UseRewindDataResult {
  const [aiImageUrl, setAiImageUrl] = useState<string | null>(null);
  const [isAiImageLoading, setIsAiImageLoading] = useState(false);

  const fetchRewindStats = async (): Promise<RewindStats> => {
    if (!user) {
      throw new Error('User not authenticated');
    }

    // Use mock data for demo purposes
    if (USE_MOCK_DATA) {
      // Simulate loading time
      await new Promise(resolve => setTimeout(resolve, 2000));
      return generateMockRewindStats(user.uid, user.displayName);
    }

    // Real data fetching from Firebase
    const service = new RewindDataService(user.uid);
    const stats = await service.calculateRewindStats();
    
    // Check if user has enough data
    if (stats.uniqueAnimeWatched < MIN_ANIME_REQUIRED) {
      throw new Error('INSUFFICIENT_DATA');
    }
    
    return stats;
  };

  const {
    data: stats,
    isLoading,
    isError,
    error,
    refetch,
  } = useQuery({
    queryKey: ['rewindStats', user?.uid],
    queryFn: fetchRewindStats,
    enabled: !!user,
    staleTime: 1000 * 60 * 30, // 30 minutes
    gcTime: 1000 * 60 * 60, // 1 hour (formerly cacheTime)
    retry: 1,
    refetchOnWindowFocus: false,
  });

  // Generate AI image when stats are loaded
  const generateAiImage = useCallback(async () => {
    if (!stats || !user) return;

    setIsAiImageLoading(true);
    
    try {
      const prompt = AIService.generateRewindPrompt(
        stats.personality.title,
        stats.topGenres.map(g => g.genre),
        stats.topAnime.map(a => a.anime.title)
      );
      
      const seed = AIService.generateUserSeed(user.uid);
      
      const imageUrl = AIService.generateImageUrl({
        prompt,
        width: 1024,
        height: 1024,
        seed,
        nologo: true,
      });
      
      // Pre-load the image
      const loaded = await AIService.preloadImage(imageUrl);
      
      if (loaded) {
        setAiImageUrl(imageUrl);
      }
    } catch (err) {
      console.error('Failed to generate AI image:', err);
    } finally {
      setIsAiImageLoading(false);
    }
  }, [stats, user]);

  useEffect(() => {
    if (stats && !aiImageUrl) {
      generateAiImage();
    }
  }, [stats, aiImageUrl, generateAiImage]);

  // Determine loading state
  const loadingState: LoadingState = (() => {
    if (!user) return 'idle';
    if (isLoading) return 'loading';
    if (isError) {
      if ((error as Error)?.message === 'INSUFFICIENT_DATA') {
        return 'insufficient-data';
      }
      return 'error';
    }
    if (stats) return 'success';
    return 'idle';
  })();

  return {
    stats: stats ?? null,
    loadingState,
    error: isError ? (error as Error)?.message ?? 'Failed to load rewind data' : null,
    refetch: () => refetch(),
    aiImageUrl,
    isAiImageLoading,
  };
}
