
import React from 'react';
import { History, Activity, CalendarHeart, Info } from 'lucide-react';

interface Stat {
  value: string | number;
  label: string;
  clickable?: boolean;
  highlight?: boolean;
}

interface StatsRowProps {
  stats: Stat[];
}

const StatsRow: React.FC<StatsRowProps> = ({ stats }) => {
  const getIcon = (label: string) => {
    if (label.includes('周期')) return <Activity size={14} />;
    if (label.includes('经期')) return <CalendarHeart size={14} />;
    if (label.includes('上次')) return <History size={14} />;
    return <Info size={14} />;
  };

  return (
    <div className="flex gap-3 py-4">
      {stats.map((stat, idx) => (
        <div 
          key={idx} 
          className={`
            flex-1 bg-white/70 rounded-2xl p-3 flex flex-col items-center justify-center gap-1.5
            border border-[#ff5a7d]/5 shadow-sm
            transition-all duration-300 active:scale-95
            ${stat.clickable ? 'cursor-pointer active:bg-white/90' : ''}
          `}
        >
          <div className={`${stat.highlight ? 'text-[#ff5a7d]' : 'text-[#8E8186]'} opacity-60`}>
            {getIcon(stat.label)}
          </div>
          
          <div className="flex flex-col items-center">
            <span className={`text-[15px] font-bold tracking-tight ${stat.highlight ? 'text-[#ff5a7d]' : 'text-[#2B2527]'}`}>
              {stat.value}
            </span>
            <span className="text-[9px] text-[#8E8186] font-bold uppercase tracking-wider opacity-60">
              {stat.label}
            </span>
          </div>
        </div>
      ))}
    </div>
  );
};

export default StatsRow;
