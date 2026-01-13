
export interface CycleData {
  currentDay: number;
  totalCycleDays: number;
  isPeriod: boolean;
  periodDay: number;
  lastCycleLength: number;
  cycleRange: string;
  periodRange: string;
}

export interface DayInfo {
  date: Date;
  isToday: boolean;
  isPeriod: boolean;
  label: string;
  dayNum: number;
}
