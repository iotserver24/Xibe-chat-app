import { 
  collection, 
  query, 
  where, 
  getDocs, 
  doc, 
  getDoc,
  orderBy
} from 'firebase/firestore';
import { db } from './firebaseConfig';
import { 
  AnimeEntry, 
  WatchSession, 
  RewindStats, 
  TopAnimeEntry, 
  GenreStat,
  PersonalityType,
  PERSONALITY_TYPES 
} from '@/types';

// Firestore collection names
const COLLECTIONS = {
  USERS: 'users',
  ANIME_LIST: 'animeList',
  WATCH_SESSIONS: 'watchSessions',
  WATCH_HISTORY: 'watchHistory',
};

export class RewindDataService {
  private userId: string;

  constructor(userId: string) {
    this.userId = userId;
  }

  // Fetch user's anime list from Firestore
  async fetchAnimeList(): Promise<AnimeEntry[]> {
    try {
      const animeListRef = collection(db, COLLECTIONS.USERS, this.userId, COLLECTIONS.ANIME_LIST);
      const q = query(animeListRef, orderBy('updatedAt', 'desc'));
      const snapshot = await getDocs(q);

      return snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          malId: data.malId,
          anilistId: data.anilistId,
          title: data.title || 'Unknown Anime',
          titleEnglish: data.titleEnglish,
          imageUrl: data.imageUrl || data.coverImage || '/placeholder-anime.png',
          bannerUrl: data.bannerUrl,
          episodes: data.episodes || 0,
          episodesWatched: data.episodesWatched || data.progress || 0,
          score: data.score,
          status: data.status || 'completed',
          startDate: data.startDate?.toDate ? data.startDate.toDate() : undefined,
          endDate: data.endDate?.toDate ? data.endDate.toDate() : undefined,
          genres: data.genres || [],
          type: data.type || 'tv',
          duration: data.duration || 24,
          studio: data.studio,
          season: data.season,
          year: data.year,
          audioLanguage: data.audioLanguage || 'sub',
        } as AnimeEntry;
      });
    } catch (error) {
      console.error('Error fetching anime list:', error);
      return [];
    }
  }

  // Fetch watch sessions
  async fetchWatchSessions(): Promise<WatchSession[]> {
    try {
      const sessionsRef = collection(db, COLLECTIONS.USERS, this.userId, COLLECTIONS.WATCH_SESSIONS);
      const q = query(
        sessionsRef, 
        where('watchedAt', '>=', new Date(2025, 0, 1)),
        where('watchedAt', '<', new Date(2026, 0, 1)),
        orderBy('watchedAt', 'desc')
      );
      const snapshot = await getDocs(q);

      return snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          animeId: data.animeId,
          episodesWatched: data.episodesWatched || 1,
          watchedAt: data.watchedAt?.toDate ? data.watchedAt.toDate() : new Date(),
          duration: data.duration || 24,
          dayOfWeek: data.dayOfWeek ?? new Date(data.watchedAt?.toDate?.() || Date.now()).getDay(),
          hourOfDay: data.hourOfDay ?? new Date(data.watchedAt?.toDate?.() || Date.now()).getHours(),
        } as WatchSession;
      });
    } catch (error) {
      console.error('Error fetching watch sessions:', error);
      return [];
    }
  }

  // Fetch user profile
  async fetchUserProfile(): Promise<{ createdAt: Date } | null> {
    try {
      const userRef = doc(db, COLLECTIONS.USERS, this.userId);
      const snapshot = await getDoc(userRef);

      if (snapshot.exists()) {
        const data = snapshot.data();
        return {
          createdAt: data.createdAt?.toDate ? data.createdAt.toDate() : new Date(),
        };
      }
      return null;
    } catch (error) {
      console.error('Error fetching user profile:', error);
      return null;
    }
  }

  // Calculate all rewind stats
  async calculateRewindStats(): Promise<RewindStats> {
    const [animeList, watchSessions, userProfile] = await Promise.all([
      this.fetchAnimeList(),
      this.fetchWatchSessions(),
      this.fetchUserProfile(),
    ]);

    // Filter to only 2025 data
    const year2025Start = new Date(2025, 0, 1);
    const year2025End = new Date(2025, 11, 31, 23, 59, 59);
    
    const animeWatched2025 = animeList.filter(anime => {
      if (anime.startDate && anime.startDate >= year2025Start && anime.startDate <= year2025End) {
        return true;
      }
      if (anime.endDate && anime.endDate >= year2025Start && anime.endDate <= year2025End) {
        return true;
      }
      // Include if has episodes watched (no date info)
      return anime.episodesWatched > 0;
    });

    // Calculate totals
    const totalEpisodes = animeWatched2025.reduce((sum, anime) => sum + anime.episodesWatched, 0);
    const totalWatchTimeMinutes = animeWatched2025.reduce(
      (sum, anime) => sum + (anime.episodesWatched * (anime.duration || 24)), 
      0
    );

    // Calculate unique days active
    const uniqueDays = new Set(watchSessions.map(s => s.watchedAt.toDateString()));
    const daysActive = uniqueDays.size || Math.ceil(totalEpisodes / 3); // Estimate if no sessions

    // Calculate top anime
    const topAnime = this.calculateTopAnime(animeWatched2025);

    // Calculate sub vs dub
    const subVsDub = this.calculateSubVsDub(animeWatched2025);

    // Calculate watch time by day
    const watchTimeByDay = this.calculateWatchTimeByDay(watchSessions, animeWatched2025);

    // Calculate peak watching hour
    const peakWatchingHour = this.calculatePeakHour(watchSessions);

    // Calculate top genres
    const topGenres = this.calculateTopGenres(animeWatched2025);

    // Calculate personality
    const personality = this.calculatePersonality(animeWatched2025, watchSessions, topGenres);

    // Calculate longest binge
    const longestBinge = this.calculateLongestBinge(watchSessions, animeList);

    // Get favorite studio
    const favoriteStudio = this.getFavoriteStudio(animeWatched2025);

    // Generate AI image prompt
    const aiImagePrompt = this.generateAIImagePrompt(topAnime, topGenres, personality);

    return {
      totalEpisodes,
      totalWatchTimeMinutes,
      totalWatchTimeHours: Math.round(totalWatchTimeMinutes / 60),
      uniqueAnimeWatched: animeWatched2025.length,
      daysActive: daysActive || 1,
      topAnime,
      subVsDub,
      watchTimeByDay,
      peakWatchingHour,
      averageEpisodesPerDay: Math.round((totalEpisodes / (daysActive || 1)) * 10) / 10,
      topGenres,
      personality,
      longestBingeSession: longestBinge,
      favoriteStudio,
      accountCreatedAt: userProfile?.createdAt || new Date(),
      firstAnimeWatched: animeWatched2025[animeWatched2025.length - 1]?.title,
      mostRecentAnime: animeWatched2025[0]?.title,
      aiImagePrompt,
    };
  }

  private calculateTopAnime(animeList: AnimeEntry[]): TopAnimeEntry[] {
    return animeList
      .filter(anime => anime.episodesWatched > 0)
      .sort((a, b) => {
        // Sort by watch time (episodes * duration)
        const aTime = a.episodesWatched * (a.duration || 24);
        const bTime = b.episodesWatched * (b.duration || 24);
        return bTime - aTime;
      })
      .slice(0, 5)
      .map((anime, index) => ({
        anime,
        episodesWatched: anime.episodesWatched,
        watchTimeMinutes: anime.episodesWatched * (anime.duration || 24),
        rank: index + 1,
      }));
  }

  private calculateSubVsDub(animeList: AnimeEntry[]): { sub: number; dub: number; percentage: number } {
    const sub = animeList.filter(a => a.audioLanguage === 'sub' || a.audioLanguage === 'both').length;
    const dub = animeList.filter(a => a.audioLanguage === 'dub' || a.audioLanguage === 'both').length;
    const total = sub + dub || 1;
    return {
      sub,
      dub,
      percentage: Math.round((sub / total) * 100),
    };
  }

  private calculateWatchTimeByDay(
    sessions: WatchSession[], 
    animeList: AnimeEntry[]
  ): { [key: string]: number } {
    const days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const result: { [key: string]: number } = {};
    
    days.forEach(day => { result[day] = 0; });

    if (sessions.length > 0) {
      sessions.forEach(session => {
        const dayName = days[session.dayOfWeek];
        result[dayName] += session.duration;
      });
    } else {
      // Generate estimated data based on anime count
      const totalMinutes = animeList.reduce((sum, a) => sum + (a.episodesWatched * (a.duration || 24)), 0);
      const avgPerDay = totalMinutes / 7;
      
      // Weekends get more watch time
      result['Saturday'] = Math.round(avgPerDay * 1.5);
      result['Sunday'] = Math.round(avgPerDay * 1.4);
      result['Friday'] = Math.round(avgPerDay * 1.2);
      result['Monday'] = Math.round(avgPerDay * 0.8);
      result['Tuesday'] = Math.round(avgPerDay * 0.8);
      result['Wednesday'] = Math.round(avgPerDay * 0.9);
      result['Thursday'] = Math.round(avgPerDay * 0.9);
    }

    return result;
  }

  private calculatePeakHour(sessions: WatchSession[]): number {
    if (sessions.length === 0) return 21; // Default to 9 PM

    const hourCounts: { [key: number]: number } = {};
    sessions.forEach(session => {
      hourCounts[session.hourOfDay] = (hourCounts[session.hourOfDay] || 0) + 1;
    });

    let maxHour = 21;
    let maxCount = 0;
    Object.entries(hourCounts).forEach(([hour, count]) => {
      if (count > maxCount) {
        maxCount = count;
        maxHour = parseInt(hour);
      }
    });

    return maxHour;
  }

  private calculateTopGenres(animeList: AnimeEntry[]): GenreStat[] {
    const genreCounts: { [key: string]: number } = {};
    
    animeList.forEach(anime => {
      anime.genres.forEach(genre => {
        genreCounts[genre] = (genreCounts[genre] || 0) + 1;
      });
    });

    const total = Object.values(genreCounts).reduce((sum, count) => sum + count, 0) || 1;

    return Object.entries(genreCounts)
      .map(([genre, count]) => ({
        genre,
        count,
        percentage: Math.round((count / total) * 100),
      }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 5);
  }

  private calculatePersonality(
    animeList: AnimeEntry[],
    sessions: WatchSession[],
    topGenres: GenreStat[]
  ): PersonalityType {
    const totalEpisodes = animeList.reduce((sum, a) => sum + a.episodesWatched, 0);
    const uniqueGenres = new Set(animeList.flatMap(a => a.genres)).size;
    const completedCount = animeList.filter(a => a.status === 'completed').length;
    
    // Calculate average episodes per session
    const avgEpisodesPerSession = sessions.length > 0 
      ? totalEpisodes / sessions.length 
      : totalEpisodes / (animeList.length || 1);

    // Calculate peak hour patterns
    const nightHours = sessions.filter(s => s.hourOfDay >= 22 || s.hourOfDay <= 4).length;
    const isNightOwl = nightHours > sessions.length * 0.5;

    // Weekend vs weekday
    const weekendSessions = sessions.filter(s => s.dayOfWeek === 0 || s.dayOfWeek === 6).length;
    const isWeekendWarrior = weekendSessions > sessions.length * 0.6;

    // Determine personality
    if (animeList.length < 5) {
      return PERSONALITY_TYPES.new_adventurer;
    }
    
    if (avgEpisodesPerSession > 5) {
      return PERSONALITY_TYPES.binge_master;
    }
    
    if (completedCount > animeList.length * 0.8) {
      return PERSONALITY_TYPES.completionist;
    }
    
    if (uniqueGenres < 4 && topGenres.length > 0) {
      return PERSONALITY_TYPES.genre_specialist;
    }
    
    if (uniqueGenres > 8) {
      return PERSONALITY_TYPES.variety_seeker;
    }
    
    if (isNightOwl) {
      return PERSONALITY_TYPES.night_owl;
    }
    
    if (isWeekendWarrior) {
      return PERSONALITY_TYPES.weekend_warrior;
    }
    
    return PERSONALITY_TYPES.casual_explorer;
  }

  private calculateLongestBinge(
    sessions: WatchSession[],
    animeList: AnimeEntry[]
  ): { anime: string; episodes: number; duration: number } {
    if (sessions.length === 0) {
      // Fallback to top anime - use slice() to avoid mutating original array
      const topAnime = [...animeList].sort((a, b) => b.episodesWatched - a.episodesWatched)[0];
      if (topAnime) {
        return {
          anime: topAnime.title,
          episodes: Math.min(topAnime.episodesWatched, 12),
          duration: Math.min(topAnime.episodesWatched, 12) * (topAnime.duration || 24),
        };
      }
      return { anime: 'Unknown', episodes: 0, duration: 0 };
    }

    // Group sessions by anime and find longest
    const animeMap = new Map<string, { episodes: number; duration: number }>();
    
    sessions.forEach(session => {
      const current = animeMap.get(session.animeId) || { episodes: 0, duration: 0 };
      animeMap.set(session.animeId, {
        episodes: current.episodes + session.episodesWatched,
        duration: current.duration + session.duration,
      });
    });

    let maxAnimeId = '';
    let maxData = { episodes: 0, duration: 0 };
    
    animeMap.forEach((data, animeId) => {
      if (data.episodes > maxData.episodes) {
        maxAnimeId = animeId;
        maxData = data;
      }
    });

    const anime = animeList.find(a => a.id === maxAnimeId);
    
    return {
      anime: anime?.title || 'Your Favorite Show',
      episodes: maxData.episodes,
      duration: maxData.duration,
    };
  }

  private getFavoriteStudio(animeList: AnimeEntry[]): string | undefined {
    const studioCounts: { [key: string]: number } = {};
    
    animeList.forEach(anime => {
      if (anime.studio) {
        studioCounts[anime.studio] = (studioCounts[anime.studio] || 0) + anime.episodesWatched;
      }
    });

    let maxStudio: string | undefined;
    let maxCount = 0;
    
    Object.entries(studioCounts).forEach(([studio, count]) => {
      if (count > maxCount) {
        maxCount = count;
        maxStudio = studio;
      }
    });

    return maxStudio;
  }

  private generateAIImagePrompt(
    topAnime: TopAnimeEntry[],
    topGenres: GenreStat[],
    personality: PersonalityType
  ): string {
    const genreText = topGenres.slice(0, 3).map(g => g.genre.toLowerCase()).join(', ');
    const animeText = topAnime.slice(0, 2).map(a => a.anime.title).join(' and ');
    
    return `Anime style digital art illustration representing a ${personality.title.toLowerCase()} anime fan, ` +
      `featuring elements from ${genreText} anime genres, ` +
      `inspired by ${animeText}, ` +
      `with vibrant colors, dynamic composition, aesthetic background with cherry blossoms and cosmic elements, ` +
      `detailed anime art style, 4k quality, trending on artstation`;
  }
}

// Generate mock data for demo purposes
export function generateMockRewindStats(userId: string, displayName: string | null): RewindStats {
  const mockAnime: AnimeEntry[] = [
    {
      id: '1',
      title: 'Frieren: Beyond Journey\'s End',
      imageUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx154587-gHSraOSa0nBG.jpg',
      episodes: 28,
      episodesWatched: 28,
      genres: ['Adventure', 'Drama', 'Fantasy'],
      type: 'tv',
      duration: 24,
      status: 'completed',
      audioLanguage: 'sub',
      year: 2023,
    },
    {
      id: '2', 
      title: 'Jujutsu Kaisen Season 2',
      imageUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx145064-5fa4ZBbW4dqA.jpg',
      episodes: 23,
      episodesWatched: 23,
      genres: ['Action', 'Fantasy', 'Supernatural'],
      type: 'tv',
      duration: 24,
      status: 'completed',
      audioLanguage: 'sub',
      year: 2023,
    },
    {
      id: '3',
      title: 'Solo Leveling',
      imageUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx151807-m1gX3iwfIsLu.png',
      episodes: 12,
      episodesWatched: 12,
      genres: ['Action', 'Adventure', 'Fantasy'],
      type: 'tv',
      duration: 24,
      status: 'completed',
      audioLanguage: 'sub',
      year: 2024,
    },
    {
      id: '4',
      title: 'Oshi no Ko',
      imageUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx150672-2WWJVXIAOG11.png',
      episodes: 11,
      episodesWatched: 11,
      genres: ['Drama', 'Supernatural', 'Music'],
      type: 'tv',
      duration: 24,
      status: 'completed',
      audioLanguage: 'sub',
      year: 2023,
    },
    {
      id: '5',
      title: 'Demon Slayer: Hashira Training Arc',
      imageUrl: 'https://s4.anilist.co/file/anilistcdn/media/anime/cover/large/bx166240-JzdvHoXxSkNw.jpg',
      episodes: 8,
      episodesWatched: 8,
      genres: ['Action', 'Fantasy', 'Supernatural'],
      type: 'tv',
      duration: 24,
      status: 'completed',
      audioLanguage: 'dub',
      year: 2024,
    },
  ];

  const topAnime: TopAnimeEntry[] = mockAnime.map((anime, index) => ({
    anime,
    episodesWatched: anime.episodesWatched,
    watchTimeMinutes: anime.episodesWatched * (anime.duration || 24),
    rank: index + 1,
  }));

  const totalEpisodes = mockAnime.reduce((sum, a) => sum + a.episodesWatched, 0);
  const totalMinutes = mockAnime.reduce((sum, a) => sum + (a.episodesWatched * (a.duration || 24)), 0);

  return {
    totalEpisodes,
    totalWatchTimeMinutes: totalMinutes,
    totalWatchTimeHours: Math.round(totalMinutes / 60),
    uniqueAnimeWatched: mockAnime.length,
    daysActive: 156,
    topAnime,
    subVsDub: { sub: 4, dub: 1, percentage: 80 },
    watchTimeByDay: {
      Sunday: 420,
      Monday: 180,
      Tuesday: 200,
      Wednesday: 220,
      Thursday: 190,
      Friday: 300,
      Saturday: 480,
    },
    peakWatchingHour: 21,
    averageEpisodesPerDay: 2.3,
    topGenres: [
      { genre: 'Action', count: 4, percentage: 35 },
      { genre: 'Fantasy', count: 4, percentage: 35 },
      { genre: 'Drama', count: 2, percentage: 15 },
      { genre: 'Supernatural', count: 3, percentage: 10 },
      { genre: 'Adventure', count: 2, percentage: 5 },
    ],
    personality: PERSONALITY_TYPES.binge_master,
    longestBingeSession: {
      anime: 'Frieren: Beyond Journey\'s End',
      episodes: 8,
      duration: 192,
    },
    favoriteStudio: 'MAPPA',
    accountCreatedAt: new Date(2023, 5, 15),
    firstAnimeWatched: 'Attack on Titan',
    mostRecentAnime: 'Solo Leveling',
    aiImagePrompt: 'Anime style digital art of a passionate anime fan surrounded by elements of action, fantasy, and adventure genres, with cosmic cherry blossom aesthetic, vibrant colors, 4k quality',
  };
}
