
import React from 'react';

interface RingProgressProps {
  percentage: number;
  value: number;
  label: string;
  isPeriod: boolean;
  onAction: () => void;
}

const RingProgress: React.FC<RingProgressProps> = ({ percentage, value, label, isPeriod, onAction }) => {
  const r = 90;
  const circumference = 2 * Math.PI * r;
  const offset = circumference - (percentage / 100) * circumference;

  return (
    <div className="flex flex-col items-center justify-center relative">
      <div className="w-[210px] h-[210px] relative">
        {/* 中心极简微光 - 经期模式下更明显的晕染效果 */}
        <div className={`
          absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 
          w-20 h-20 rounded-full blur-2xl transition-all duration-1000
          ${isPeriod ? 'bg-[#ff5a7d]/25 opacity-100 scale-125' : 'bg-[#ff5a7d]/10 opacity-40 scale-100'}
        `}></div>
        
        <svg width="210" height="210" viewBox="0 0 210 210" className="transform -rotate-90 relative z-10">
          <circle 
            className="fill-none stroke-[#F7EDEE] stroke-[7px]" 
            cx="105" cy="105" r={r} 
          />
          <circle 
            className="fill-none stroke-[url(#ringGradient)] stroke-[8px] transition-all duration-1000 ease-in-out" 
            cx="105" cy="105" r={r} 
            strokeLinecap="round"
            strokeDasharray={circumference}
            strokeDashoffset={offset}
            style={{ filter: 'drop-shadow(0 2px 6px rgba(255, 90, 125, 0.15))' }}
          />
        </svg>

        <div className="absolute inset-0 flex flex-col items-center justify-center text-center z-20">
          <div 
            className="text-[58px] font-normal leading-none tracking-tight transition-colors duration-700 varela"
            style={{ color: '#2B2527' }}
          >
            {value}
          </div>
          <div className={`text-[11px] mt-1 font-bold tracking-[0.25em] transition-colors duration-700 uppercase ${isPeriod ? 'text-[#ff5a7d]' : 'text-[#8E8186]'}`}>
            {label}
          </div>
          
          <button 
            onClick={onAction}
            className={`
              mt-5 px-6 py-2 rounded-full text-[11px] font-bold transition-all duration-500 active:scale-95 shadow-sm
              ${isPeriod 
                ? 'bg-transparent border border-[#ff5a7d]/20 text-[#8E8186]' 
                : 'bg-[#ff5a7d] text-white'}
            `}
          >
            {isPeriod ? '编辑日期' : '记录月经'}
          </button>
        </div>
      </div>
    </div>
  );
};

export default RingProgress;
