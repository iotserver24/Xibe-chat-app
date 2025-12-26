const POLLINATIONS_BASE_URL = 'https://image.pollinations.ai/prompt';

export interface AIImageConfig {
  prompt: string;
  width?: number;
  height?: number;
  model?: string;
  seed?: number;
  nologo?: boolean;
}

export class AIService {
  // Generate AI image URL using Pollinations
  static generateImageUrl(config: AIImageConfig): string {
    const {
      prompt,
      width = 1024,
      height = 1024,
      model = 'flux',
      seed,
      nologo = true,
    } = config;

    // Encode the prompt for URL
    const encodedPrompt = encodeURIComponent(prompt);
    
    // Build URL with parameters
    let url = `${POLLINATIONS_BASE_URL}/${encodedPrompt}`;
    
    const params = new URLSearchParams();
    params.append('width', width.toString());
    params.append('height', height.toString());
    params.append('model', model);
    if (seed) params.append('seed', seed.toString());
    if (nologo) params.append('nologo', 'true');
    
    return `${url}?${params.toString()}`;
  }

  // Generate a unique seed based on user ID for consistent images
  static generateUserSeed(userId: string): number {
    let hash = 0;
    for (let i = 0; i < userId.length; i++) {
      const char = userId.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32-bit integer
    }
    return Math.abs(hash);
  }

  // Generate a rewind-themed prompt
  static generateRewindPrompt(
    personality: string,
    topGenres: string[],
    topAnime: string[]
  ): string {
    const genreText = topGenres.slice(0, 3).join(', ').toLowerCase();
    const animeInspo = topAnime.slice(0, 2).join(' and ');
    
    const basePrompts = [
      `Stunning anime-style digital artwork representing "${personality}" anime enthusiast, `,
      `Beautiful illustration in Japanese animation style celebrating a "${personality}" viewer, `,
      `Artistic anime wallpaper featuring the spirit of a "${personality}" fan, `,
    ];
    
    const styleElements = [
      'vibrant neon colors, dynamic lighting, ',
      'ethereal glow effects, cinematic composition, ',
      'stunning visual effects, sakura petals falling, ',
    ];
    
    const backgrounds = [
      'cosmic starry sky background with aurora borealis, ',
      'magical floating islands with cherry blossoms, ',
      'cyberpunk cityscape at sunset with holographic displays, ',
    ];
    
    const quality = [
      'ultra detailed, 4k resolution, trending on artstation, masterpiece quality',
      'highly detailed anime art, professional quality, breathtaking composition',
      'intricate details, award-winning digital art, stunning anime aesthetic',
    ];

    // Pick random elements for variety
    const randomIndex = Math.floor(Math.random() * 3);
    
    return (
      basePrompts[randomIndex] +
      `featuring elements from ${genreText} genres, ` +
      `inspired by ${animeInspo}, ` +
      styleElements[randomIndex] +
      backgrounds[randomIndex] +
      quality[randomIndex]
    );
  }

  // Pre-generate image by loading it
  static async preloadImage(url: string): Promise<boolean> {
    return new Promise((resolve) => {
      const img = new Image();
      img.onload = () => resolve(true);
      img.onerror = () => resolve(false);
      img.src = url;
    });
  }
}
