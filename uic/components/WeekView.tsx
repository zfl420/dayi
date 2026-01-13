
import React from 'react';
import { DayInfo } from '../types';

interface WeekViewProps {
  days: DayInfo[];
  isPeriodMode?: boolean;
  selectedDayNum: number;
  onSelectDay: (dayNum: number) => void;
}

const WeekView: React.FC<WeekViewProps> = ({ days, isPeriodMode, selectedDayNum, onSelectDay }) => {
  return (
    <div className="flex justify-center gap-2 px-1 py-4">
      {days.map((day, idx) => {
        const isSelected = day.dayNum === selectedDayNum;
        
        return (
          <button 
            key={idx} 
            onClick={() => onSelectDay(day.dayNum)}
            className="flex flex-col items-center gap-2.5 focus:outline-none group relative w-9"
          >
            {/* 保持固定的标签颜色 */}
            <span className="text-[9px] font-bold tracking-widest transition-colors duration-500 uppercase text-[#8E8186]/70">
              {day.label}
            </span>
            
            <div className="relative w-8 h-8 flex items-center justify-center">
              {isSelected && (
                <div className="absolute inset-0 rounded-full animate-in zoom-in duration-300 bg-[#ff5a7d]/5 shadow-inner" />
              )}
              
              <span className={`
                w-7 h-7 flex items-center justify-center text-[13px] rounded-full font-bold transition-all duration-500 relative z-10
                ${isSelected ? 'text-[#ff5a7d]' : 'text-[#2B2527]'}
                ${day.isToday && !isSelected ? 'text-[#ff5a7d] opacity-60' : ''}
                ${day.isPeriod && !isSelected ? 'text-[#ff5a7d]/40' : ''}
              `}>
                {day.dayNum}
              </span>
            </div>
          </button>
        );
      })}
    </div>
  );
};

export default WeekView;
