'use client';

import { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { RewindStats, User } from '@/types';
import {
  shareToTwitter,
  shareToReddit,
  generateDiscordMessage,
  generateEmailShare,
  generateWhatsAppShare,
  generateTelegramShare,
  generateShareUrl,
  copyToClipboard,
  nativeShare,
} from '@/utils/shareUtils';
import { generateTwitterText } from '@/utils/rewindUtils';
import toast from 'react-hot-toast';
import {
  X,
  Twitter,
  MessageCircle,
  Mail,
  Link,
  Copy,
  CheckCircle,
  Share2,
  Send,
} from 'lucide-react';

interface ShareModalProps {
  isOpen: boolean;
  onClose: () => void;
  stats: RewindStats;
  user: User;
  cardRef: React.RefObject<HTMLDivElement>;
}

const shareOptions = [
  {
    id: 'twitter',
    name: 'Twitter / X',
    icon: Twitter,
    color: 'from-blue-400 to-blue-600',
  },
  {
    id: 'reddit',
    name: 'Reddit',
    icon: MessageCircle,
    color: 'from-orange-500 to-red-500',
  },
  {
    id: 'discord',
    name: 'Discord',
    icon: MessageCircle,
    color: 'from-indigo-500 to-purple-600',
  },
  {
    id: 'whatsapp',
    name: 'WhatsApp',
    icon: Send,
    color: 'from-green-500 to-emerald-600',
  },
  {
    id: 'telegram',
    name: 'Telegram',
    icon: Send,
    color: 'from-blue-400 to-cyan-500',
  },
  {
    id: 'email',
    name: 'Email',
    icon: Mail,
    color: 'from-gray-500 to-gray-700',
  },
];

export function ShareModal({ isOpen, onClose, stats, user }: ShareModalProps) {
  const [copiedLink, setCopiedLink] = useState(false);
  const [copiedDiscord, setCopiedDiscord] = useState(false);
  const shareUrl = generateShareUrl(user.uid);

  useEffect(() => {
    if (isOpen) {
      document.body.style.overflow = 'hidden';
    } else {
      document.body.style.overflow = '';
    }
    return () => {
      document.body.style.overflow = '';
    };
  }, [isOpen]);

  const handleShare = async (optionId: string) => {
    switch (optionId) {
      case 'twitter':
        shareToTwitter(stats, shareUrl);
        break;
      case 'reddit':
        shareToReddit(stats, shareUrl);
        break;
      case 'discord':
        const discordMessage = generateDiscordMessage(stats, shareUrl);
        const copied = await copyToClipboard(discordMessage);
        if (copied) {
          setCopiedDiscord(true);
          toast.success('Discord message copied! Paste it in your server');
          setTimeout(() => setCopiedDiscord(false), 3000);
        }
        break;
      case 'whatsapp':
        window.open(generateWhatsAppShare(stats, shareUrl), '_blank');
        break;
      case 'telegram':
        window.open(generateTelegramShare(stats, shareUrl), '_blank');
        break;
      case 'email':
        window.location.href = generateEmailShare(stats, shareUrl);
        break;
    }
  };

  const handleCopyLink = async () => {
    const copied = await copyToClipboard(shareUrl);
    if (copied) {
      setCopiedLink(true);
      toast.success('Link copied!');
      setTimeout(() => setCopiedLink(false), 3000);
    } else {
      toast.error('Failed to copy link');
    }
  };

  const handleNativeShare = async () => {
    const shared = await nativeShare({
      title: 'AniSurge Rewind 2025',
      text: generateTwitterText(stats),
      url: shareUrl,
    });
    if (!shared) {
      // Fallback to copy
      handleCopyLink();
    }
  };

  return (
    <AnimatePresence>
      {isOpen && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          className="modal-backdrop"
          onClick={onClose}
        >
          <motion.div
            initial={{ opacity: 0, scale: 0.9, y: 20 }}
            animate={{ opacity: 1, scale: 1, y: 0 }}
            exit={{ opacity: 0, scale: 0.9, y: 20 }}
            transition={{ type: 'spring', damping: 25, stiffness: 300 }}
            className="modal-content"
            onClick={(e) => e.stopPropagation()}
          >
            {/* Header */}
            <div className="flex items-center justify-between mb-6">
              <h3 className="text-xl font-bold text-white flex items-center gap-2">
                <Share2 className="w-5 h-5 text-primary-400" />
                Share Your Rewind
              </h3>
              <button
                onClick={onClose}
                className="w-8 h-8 rounded-full bg-white/10 flex items-center justify-center
                         text-white/60 hover:text-white hover:bg-white/20 transition-colors"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            {/* Native share button (mobile) */}
            {typeof navigator !== 'undefined' && navigator.share && (
              <motion.button
                whileHover={{ scale: 1.02 }}
                whileTap={{ scale: 0.98 }}
                onClick={handleNativeShare}
                className="w-full btn-primary mb-4 flex items-center justify-center gap-2"
              >
                <Share2 className="w-5 h-5" />
                Share
              </motion.button>
            )}

            {/* Share options grid */}
            <div className="grid grid-cols-3 gap-3 mb-6">
              {shareOptions.map((option) => {
                const Icon = option.icon;
                const isDiscordCopied = option.id === 'discord' && copiedDiscord;
                
                return (
                  <motion.button
                    key={option.id}
                    whileHover={{ scale: 1.05 }}
                    whileTap={{ scale: 0.95 }}
                    onClick={() => handleShare(option.id)}
                    className="flex flex-col items-center gap-2 p-4 rounded-xl bg-white/5
                             hover:bg-white/10 transition-colors"
                  >
                    <div className={`w-10 h-10 rounded-full bg-gradient-to-br ${option.color}
                                  flex items-center justify-center`}>
                      {isDiscordCopied ? (
                        <CheckCircle className="w-5 h-5 text-white" />
                      ) : (
                        <Icon className="w-5 h-5 text-white" />
                      )}
                    </div>
                    <span className="text-xs text-white/70">
                      {isDiscordCopied ? 'Copied!' : option.name}
                    </span>
                  </motion.button>
                );
              })}
            </div>

            {/* Copy link section */}
            <div className="space-y-3">
              <p className="text-white/60 text-sm">Or copy link</p>
              
              <div className="flex gap-2">
                <div className="flex-1 bg-white/5 rounded-xl px-4 py-3 flex items-center gap-2 overflow-hidden">
                  <Link className="w-4 h-4 text-white/40 flex-shrink-0" />
                  <span className="text-white/60 text-sm truncate">{shareUrl}</span>
                </div>
                
                <motion.button
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  onClick={handleCopyLink}
                  className={`px-4 rounded-xl flex items-center justify-center transition-colors ${
                    copiedLink 
                      ? 'bg-green-500 text-white' 
                      : 'bg-white/10 text-white/70 hover:bg-white/20'
                  }`}
                >
                  {copiedLink ? (
                    <CheckCircle className="w-5 h-5" />
                  ) : (
                    <Copy className="w-5 h-5" />
                  )}
                </motion.button>
              </div>
            </div>

            {/* Preview text */}
            <div className="mt-6 pt-4 border-t border-white/10">
              <p className="text-white/40 text-xs mb-2">Preview message:</p>
              <p className="text-white/60 text-sm whitespace-pre-line">
                {generateTwitterText(stats)}
              </p>
            </div>
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}
