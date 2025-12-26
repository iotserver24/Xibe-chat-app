'use client';

import { ReactNode, useCallback } from 'react';
import html2canvas from 'html2canvas';
import toast from 'react-hot-toast';
import { generateDownloadFilename } from '@/utils/shareUtils';

interface CardDownloaderProps {
  cardRef: React.RefObject<HTMLDivElement>;
  username: string;
  type?: 'card' | 'story';
  onDownloadStart?: () => void;
  onDownloadEnd?: () => void;
  children: ReactNode;
}

export function CardDownloader({
  cardRef,
  username,
  type = 'card',
  onDownloadStart,
  onDownloadEnd,
  children,
}: CardDownloaderProps) {
  const handleDownload = useCallback(async () => {
    if (!cardRef.current) {
      toast.error('Card not found');
      return;
    }

    onDownloadStart?.();

    try {
      // Wait a bit for any animations to settle
      await new Promise(resolve => setTimeout(resolve, 100));

      const canvas = await html2canvas(cardRef.current, {
        backgroundColor: null,
        scale: 2, // Higher quality
        useCORS: true,
        allowTaint: true,
        logging: false,
        imageTimeout: 15000,
        onclone: (clonedDoc, element) => {
          // Ensure all styles are applied
          element.style.transform = 'none';
          element.style.borderRadius = '24px';
        },
      });

      // Convert to blob
      const blob = await new Promise<Blob>((resolve, reject) => {
        canvas.toBlob(
          (blob) => {
            if (blob) {
              resolve(blob);
            } else {
              reject(new Error('Failed to create image'));
            }
          },
          'image/png',
          1.0
        );
      });

      // Create download link
      const url = URL.createObjectURL(blob);
      const link = document.createElement('a');
      link.href = url;
      link.download = generateDownloadFilename(username, type);
      
      // Trigger download
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      
      // Cleanup
      URL.revokeObjectURL(url);

      toast.success('Card saved! 🎉');
    } catch (error) {
      console.error('Download error:', error);
      toast.error('Failed to save card. Try again!');
    } finally {
      onDownloadEnd?.();
    }
  }, [cardRef, username, type, onDownloadStart, onDownloadEnd]);

  return (
    <div onClick={handleDownload}>
      {children}
    </div>
  );
}
