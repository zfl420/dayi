
import React from 'react';

export const COLORS = {
  primary: '#ff5a7d',
  primaryStrong: '#ff4466',
  primarySoft: '#fff0f3',
  textPrimary: '#2B2527',
  textSecondary: '#5D5154',
  textMuted: '#8E8186',
};

export const SvgGradients = () => (
  <svg width="0" height="0" style={{ position: 'absolute' }}>
    <defs>
      <linearGradient id="ringTrack" x1="0%" y1="0%" x2="100%" y2="100%">
        <stop offset="0%" style={{ stopColor: '#F7EDEE' }} />
        <stop offset="100%" style={{ stopColor: '#EFE3E7' }} />
      </linearGradient>
      <linearGradient id="ringGradient" x1="0%" y1="0%" x2="100%" y2="0%">
        <stop offset="0%" style={{ stopColor: '#ff8ca4' }} />
        <stop offset="100%" style={{ stopColor: '#ff5a7d' }} />
      </linearGradient>
    </defs>
  </svg>
);
