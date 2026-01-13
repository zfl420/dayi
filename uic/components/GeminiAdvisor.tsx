
import React, { useState, useEffect } from 'react';
import { Sparkles, Loader2, ChevronRight } from 'lucide-react';
import { getCycleAdvice } from '../services/geminiService';

interface GeminiAdvisorProps {
  day: number;
  isPeriod: boolean;
}

const GeminiAdvisor: React.FC<GeminiAdvisorProps> = ({ day, isPeriod }) => {
  const [advice, setAdvice] = useState<{ tips: any[], summary: string } | null>(null);
  const [loading, setLoading] = useState(false);
  const [expanded, setExpanded] = useState(false);

  const fetchAdvice = async () => {
    setLoading(true);
    try {
      const result = await getCycleAdvice(day, isPeriod);
      if (result) setAdvice(result);
    } catch (e) {
      console.error(e);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchAdvice();
  }, [day, isPeriod]);

  return (
    <div className={`
      mt-2 rounded-3xl border transition-all duration-700 p-5
      ${isPeriod ? 'bg-[#ff5a7d]/5 border-[#ff5a7d]/10' : 'bg-white/40 border-white/80 shadow-sm'}
    `}>
      <div className="flex items-center justify-between mb-3">
        <div className="flex items-center gap-2 text-[#ff5a7d] font-bold text-[10px] uppercase tracking-widest opacity-80">
          <Sparkles size={14} />
          <span>大姨小贴士</span>
        </div>
        {loading ? (
          <Loader2 size={14} className="animate-spin opacity-40" />
        ) : (
          <button 
            onClick={() => setExpanded(!expanded)}
            className="w-6 h-6 rounded-full bg-white/60 flex items-center justify-center shadow-sm"
          >
            <ChevronRight size={12} className={`transition-transform duration-300 ${expanded ? 'rotate-90' : ''}`} />
          </button>
        )}
      </div>

      {advice ? (
        <div className="space-y-3">
          <p className="text-[12px] text-[#5D5154] leading-relaxed">
            {advice.summary}
          </p>
          
          {expanded && (
            <div className="pt-2 space-y-4 animate-in fade-in slide-in-from-top-2">
              {advice.tips.map((tip, idx) => (
                <div key={idx} className="flex flex-col gap-1">
                  <span className="text-[9px] font-bold text-[#ff5a7d] uppercase tracking-widest opacity-70">
                    {tip.category}
                  </span>
                  <p className="text-[11px] text-[#5D5154] leading-snug">
                    {tip.content}
                  </p>
                </div>
              ))}
            </div>
          )}
        </div>
      ) : (
        <div className="flex items-center gap-2 opacity-30">
           <div className="w-1.5 h-1.5 rounded-full bg-[#ff5a7d] animate-bounce"></div>
           <div className="w-1.5 h-1.5 rounded-full bg-[#ff5a7d] animate-bounce [animation-delay:0.2s]"></div>
           <div className="w-1.5 h-1.5 rounded-full bg-[#ff5a7d] animate-bounce [animation-delay:0.4s]"></div>
        </div>
      )}
    </div>
  );
};

export default GeminiAdvisor;
