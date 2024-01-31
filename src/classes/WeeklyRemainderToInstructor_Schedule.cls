// Work Item : W-001111
// Scheduler to call WeeklyRemainderToInstructor batch class for email notification purpose
// Created by HL on Mar 08 2019
// Scheduled on Weekly basis - Weekly Remainder for Weekly Timesheet Submission - Send @ 12:00 pm on Monday following timesheet week
global class WeeklyRemainderToInstructor_Schedule implements Schedulable {

    global void execute(SchedulableContext sc) {
    
        Set<Date> federalHoliday = new Set<Date>();
        
        federalHoliday = HolidayService.getHolidaysWithRecurrence(Date.newInstance(system.today().year(),01,01),Date.newInstance(system.today().year(),12,31));
        system.debug(':::::federalHoliday::::::'+federalHoliday);
        
        Date todayDt = system.today();
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
                
        if(!federalHoliday.contains(todayDt) && todayVal.format('EEEE') != 'Saturday' && todayVal.format('EEEE') != 'Sunday') {
            
            System.debug('WeeklyRemainderToInstructor_Schedule======');
            WeeklyRemainderToInstructor dailyRemainder = new WeeklyRemainderToInstructor();
            database.executeBatch(dailyRemainder,1);
        }
    }
}