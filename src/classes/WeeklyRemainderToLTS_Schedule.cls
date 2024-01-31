// Work Item : W-001121
// Schdeuler to call WeeklyRemainderToLTS batch class for email notification purpose
// Created by HL on Mar 19 2019
// Scheduled on Weekly basis - Weekly Timesheet Approval Remainder - Send at 12:00pm Monday

global class WeeklyRemainderToLTS_Schedule implements Schedulable {

    global void execute(SchedulableContext sc) {
    
        Set<Date> federalHoliday = new Set<Date>();
        
        federalHoliday = HolidayService.getHolidaysWithRecurrence(Date.newInstance(system.today().year(),01,01),Date.newInstance(system.today().year(),12,31));
        system.debug(':::::federalHoliday::::::'+federalHoliday);
        
        Date todayDt = system.today();
                
        if(!federalHoliday.contains(todayDt)) {
            
            WeeklyRemainderToLTS  remainder = new WeeklyRemainderToLTS();
            database.executeBatch(remainder,1);
        }
    }
}