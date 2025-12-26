# AniSurge Rewind 2025 🎌

A stunning, animated year-in-review experience for anime fans. Built with Next.js, Framer Motion, GSAP, and Firebase.

![AniSurge Rewind 2025](./public/og-image.png)

## ✨ Features

- **7 Animated Slides** - Beautiful transitions and animations throughout
- **Firebase Authentication** - Google OAuth and email/password login
- **Personalized Stats** - Episodes watched, watch time, top anime, and more
- **Anime Personality** - Unique personality type based on viewing habits
- **AI-Generated Portrait** - Unique anime-style image created just for you
- **Share & Export** - Download your card, share to social media, save as story
- **Responsive Design** - Works on mobile, tablet, and desktop
- **Swipe Navigation** - Touch gestures for mobile, keyboard for desktop
- **Premium Animations** - Framer Motion + GSAP for smooth 60fps animations

## 🚀 Getting Started

### Prerequisites

- Node.js 18+ 
- npm or yarn
- Firebase project with Authentication and Firestore enabled

### Installation

1. Clone the repository and navigate to the rewind folder:
   ```bash
   cd rewind
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Copy the environment example and configure:
   ```bash
   cp .env.example .env.local
   ```

4. Fill in your Firebase configuration in `.env.local`:
   ```env
   NEXT_PUBLIC_FIREBASE_API_KEY=your_api_key
   NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
   NEXT_PUBLIC_FIREBASE_PROJECT_ID=your-project-id
   NEXT_PUBLIC_FIREBASE_STORAGE_BUCKET=your-project.appspot.com
   NEXT_PUBLIC_FIREBASE_MESSAGING_SENDER_ID=your_sender_id
   NEXT_PUBLIC_FIREBASE_APP_ID=your_app_id
   ```

5. Start the development server:
   ```bash
   npm run dev
   ```

6. Open [http://localhost:3000](http://localhost:3000) in your browser.

## 📁 Project Structure

```
rewind/
├── app/                    # Next.js App Router pages
│   ├── page.tsx           # Landing/auth page
│   ├── layout.tsx         # Root layout
│   ├── providers.tsx      # React Query & toast providers
│   └── rewind/
│       └── page.tsx       # Main rewind experience
├── components/
│   ├── slides/            # 7 slide components
│   ├── Navigation/        # Progress bar & controls
│   ├── Auth/              # Login form
│   └── Share/             # Share modal, card downloader
├── hooks/                 # Custom React hooks
├── services/              # Firebase & API services
├── utils/                 # Helper functions
├── types/                 # TypeScript interfaces
└── styles/                # Global CSS with Tailwind
```

## 🎨 Slide Components

1. **IntroSlide** - Welcome with animated title and user greeting
2. **StatsOverviewSlide** - Animated counters for key stats
3. **TopAnimeSlide** - Top 5 anime with images and details
4. **HabitsSlide** - Sub vs dub chart, watch time by day, peak hour
5. **PersonalitySlide** - Unique personality type with traits
6. **AIImageSlide** - AI-generated anime portrait
7. **ShareCardSlide** - Shareable card with export options

## 🔧 Configuration

### Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Authentication with Google and Email providers
3. Create a Firestore database
4. Add your web app and copy the config values

### Firestore Structure

The app expects user data in this structure:
```
users/
  {userId}/
    animeList/          # User's anime entries
    watchSessions/      # Watch session records
```

### Mock Data

For demo purposes, the app uses mock data by default. To use real Firebase data:

1. Open `hooks/useRewindData.ts`
2. Set `USE_MOCK_DATA = false`

## 📱 Navigation

- **Swipe** - Left/right swipe on touch devices
- **Keyboard** - Arrow keys or spacebar
- **Buttons** - On-screen next/previous buttons
- **Progress** - Click dots to jump to slides

## 🎭 Personality Types

The app calculates personality based on:
- Binge watching patterns
- Completion rate
- Genre diversity
- Watch time distribution
- Peak hours

Types include: Binge Master, Completionist, Night Owl, Variety Seeker, and more!

## 📤 Sharing

- **Download Card** - PNG export of your rewind card
- **Save as Story** - 9:16 format for Instagram/TikTok
- **Social Share** - Twitter, Reddit, Discord, WhatsApp, Telegram
- **Copy Link** - Shareable URL

## 🛠️ Tech Stack

- **Framework**: Next.js 14 (App Router)
- **Styling**: Tailwind CSS
- **Animations**: Framer Motion + GSAP
- **Auth & Database**: Firebase
- **State Management**: React Query
- **Image Export**: html2canvas
- **Icons**: Lucide React

## 📦 Scripts

```bash
npm run dev      # Start development server
npm run build    # Build for production
npm run start    # Start production server
npm run lint     # Run ESLint
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

MIT License - feel free to use this for your own projects!

---

Made with 💜 for the anime community
