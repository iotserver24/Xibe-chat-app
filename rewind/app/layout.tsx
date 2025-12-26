import type { Metadata, Viewport } from 'next';
import { Inter, Outfit } from 'next/font/google';
import '@/styles/globals.css';
import { Providers } from './providers';

const inter = Inter({ 
  subsets: ['latin'],
  variable: '--font-inter',
  display: 'swap',
});

const outfit = Outfit({ 
  subsets: ['latin'],
  variable: '--font-outfit',
  display: 'swap',
});

export const metadata: Metadata = {
  title: 'AniSurge Rewind 2025 - Your Anime Year in Review',
  description: 'Discover your anime watching journey in 2025. See your stats, top anime, personality type, and more!',
  keywords: ['anime', 'rewind', '2025', 'stats', 'wrapped', 'year in review', 'AniSurge'],
  authors: [{ name: 'AniSurge' }],
  openGraph: {
    title: 'AniSurge Rewind 2025',
    description: 'Discover your anime watching journey in 2025',
    type: 'website',
    siteName: 'AniSurge',
    images: [
      {
        url: '/og-image.png',
        width: 1200,
        height: 630,
        alt: 'AniSurge Rewind 2025',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'AniSurge Rewind 2025',
    description: 'Discover your anime watching journey in 2025',
    images: ['/og-image.png'],
  },
  robots: {
    index: true,
    follow: true,
  },
};

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
  userScalable: false,
  themeColor: '#0a0a0b',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en" className={`${inter.variable} ${outfit.variable}`}>
      <head>
        <link rel="icon" href="/favicon.ico" sizes="any" />
        <link rel="apple-touch-icon" href="/apple-touch-icon.png" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
      </head>
      <body className="antialiased">
        <Providers>
          {children}
        </Providers>
      </body>
    </html>
  );
}
