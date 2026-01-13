
import React, { useState } from 'react';
import { CalendarRange } from 'lucide-react';
import { SvgGradients } from './constants';
import RingProgress from './components/RingProgress';
import WeekView from './components/WeekView';
import StatsRow from './components/StatsRow';
import GeminiAdvisor from './components/GeminiAdvisor';
import { DayInfo } from './types';

const App: React.FC = () => {
  const [isPeriod, setIsPeriod] = useState(false);
  const [currentDay, setCurrentDay] = useState(12);
  const [cycleDay, setCycleDay] = useState(18);
  
  const nonPeriodDays: DayInfo[] = [
    { date: new Date(), isToday: false, isPeriod: false, label: '一', dayNum: 6 },
    { date: new Date(), isToday: false, isPeriod: false, label: '二', dayNum: 7 },
    { date: new Date(), isToday: false, isPeriod: false, label: '三', dayNum: 8 },
    { date: new Date(), isToday: false, isPeriod: false, label: '四', dayNum: 9 },
    { date: new Date(), isToday: false, isPeriod: false, label: '五', dayNum: 10 },
    { date: new Date(), isToday: false, isPeriod: false, label: '六', dayNum: 11 },
    { date: new Date(), isToday: true, isPeriod: false, label: '今天', dayNum: 12 },
  ];

  const periodDays: DayInfo[] = [
    { date: new Date(), isToday: false, isPeriod: true, label: '一', dayNum: 30 },
    { date: new Date(), isToday: false, isPeriod: true, label: '二', dayNum: 31 },
    { date: new Date(), isToday: false, isPeriod: true, label: '三', dayNum: 1 },
    { date: new Date(), isToday: false, isPeriod: true, label: '四', dayNum: 2 },
    { date: new Date(), isToday: true, isPeriod: true, label: '今天', dayNum: 3 },
    { date: new Date(), isToday: false, isPeriod: false, label: '六', dayNum: 4 },
    { date: new Date(), isToday: false, isPeriod: false, label: '日', dayNum: 5 },
  ];

  const toggleMode = () => {
    setIsPeriod(!isPeriod);
    const nextCurrent = isPeriod ? 12 : 3;
    const nextCycle = isPeriod ? 18 : 4;
    setCurrentDay(nextCurrent);
    setCycleDay(nextCycle);
  };

  const handleSelectDay = (dayNum: number) => {
    setCurrentDay(dayNum);
  };

  return (
    <div className="min-h-screen p-4 md:p-12 flex flex-col items-center">
      <SvgGradients />
      
      <div className="text-center mb-10">
        <h1 className="varela text-4xl font-bold mb-2 tracking-tighter text-[#2B2527]">大姨 <span className="text-[#ff5a7d]">Auntie</span></h1>
        <p className="text-[10px] text-[#8E8186] font-bold tracking-[0.3em] uppercase opacity-30 italic">Minimal Pearl Edition</p>
      </div>

      <div className="w-full max-w-4xl grid grid-cols-1 md:grid-cols-2 gap-12 items-center">
        
        {/* 左侧说明 */}
        <div className="hidden md:block">
          <div className="bg-white/40 p-10 rounded-[48px] border border-white/60 shadow-sm backdrop-blur-sm">
            <h3 className="varela text-2xl font-bold mb-8 text-[#2B2527]">Pearl & Glow</h3>
            <ul className="space-y-8">
              <li className="flex gap-5 items-start">
                <div className="w-8 h-8 rounded-xl bg-[#ff5a7d]/10 text-[#ff5a7d] flex items-center justify-center shrink-0">
                   <span className="text-[11px] font-bold">1</span>
                </div>
                <div>
                  <h4 className="font-bold text-sm text-[#2B2527] mb-1">色彩克制</h4>
                  <p className="text-xs text-[#5D5154] opacity-60 leading-relaxed">全站统一采用珊瑚粉 (#ff5a7d)，移除大面积背景色，保持极简白皙感。</p>
                </div>
              </li>
              <li className="flex gap-5 items-start">
                <div className="w-8 h-8 rounded-xl bg-[#ff5a7d]/10 text-[#ff5a7d] flex items-center justify-center shrink-0">
                   <span className="text-[11px] font-bold">2</span>
                </div>
                <div>
                  <h4 className="font-bold text-sm text-[#2B2527] mb-1">中心呼吸灯</h4>
                  <p className="text-xs text-[#5D5154] opacity-60 leading-relaxed">仅在圆环中心保留晕染效果，强化“聚焦”感，降低视觉干扰。</p>
                </div>
              </li>
            </ul>
            <button 
              onClick={toggleMode}
              className="mt-12 w-full py-4 rounded-full bg-white border border-[#ff5a7d]/15 text-[#ff5a7d] font-bold text-sm shadow-sm active:scale-95 transition-all"
            >
              演示：切换为{isPeriod ? '非经期' : '经期'}状态
            </button>
          </div>
        </div>

        {/* 手机容器 */}
        <div className="flex justify-center">
          <div className={`
            relative w-[296px] h-[630px] rounded-[54px] border-[9px] border-[#1E1A1C] overflow-hidden
            bg-white shadow-[0_60px_110px_-25px_rgba(0,0,0,0.12)] flex flex-col transition-colors duration-1000
          `}>
            
            {/* 顶栏保持一致的背景，不随经期大幅变色 */}
            <div className="absolute top-[15px] left-1/2 -translate-x-1/2 w-[96px] h-[28px] bg-[#1E1A1C] rounded-full z-[100]"></div>
            
            <div className="flex-1 flex flex-col relative z-20 overflow-hidden">
              {/* 顶栏 */}
              <div className="px-7 pt-[52px] shrink-0 flex items-center justify-between">
                <div className="w-8"></div>
                <div className="text-center">
                  <div className={`text-[15px] font-bold transition-colors duration-700 ${isPeriod ? 'text-[#ff5a7d]' : 'text-[#2B2527]'}`}>
                    1月{isPeriod ? '3' : '12'}日 周{isPeriod ? '五' : '日'}
                  </div>
                </div>
                <button className={`w-8 h-8 rounded-full flex items-center justify-center transition-colors ${isPeriod ? 'text-[#ff5a7d] bg-[#ff5a7d]/5' : 'text-[#2B2527] bg-black/[0.03]'}`}>
                  <CalendarRange size={16} />
                </button>
              </div>

              <div className="flex-1 overflow-y-auto no-scrollbar px-5 pt-2">
                <WeekView 
                  days={isPeriod ? periodDays : nonPeriodDays} 
                  isPeriodMode={isPeriod} 
                  selectedDayNum={currentDay}
                  onSelectDay={handleSelectDay}
                />

                <div className="py-5 flex items-center justify-center">
                  <RingProgress 
                    percentage={isPeriod ? 20 : 64} 
                    value={cycleDay} 
                    label={isPeriod ? '经期天数' : '周期天数'} 
                    isPeriod={isPeriod}
                    onAction={toggleMode}
                  />
                </div>

                <GeminiAdvisor day={cycleDay} isPeriod={isPeriod} />

                <div className="mt-4">
                  <StatsRow 
                    stats={isPeriod ? [
                      { value: 3, label: '预计还剩', highlight: true },
                      { value: '26-30', label: '周期', clickable: true },
                      { value: '5-7', label: '经期', clickable: true },
                    ] : [
                      { value: 28, label: '上次周期' },
                      { value: '26-30', label: '周期', clickable: true },
                      { value: '5-7', label: '经期', clickable: true },
                    ]}
                  />
                </div>
                
                <div className="h-12"></div>
              </div>

              {/* 底部指示 */}
              <div className="h-10 flex justify-center items-end pb-3 pointer-events-none">
                <div className="w-20 h-1.5 rounded-full bg-black/5"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <footer className="mt-20 text-center opacity-20 select-none varela">
        <span className="font-bold text-2xl text-[#2B2527] tracking-[0.3em]">AUNTIE</span>
      </footer>
    </div>
  );
};

export default App;
