// Work Item : W-001111
// Schdeuler to call WeeklyRequestToInstructor batch class for email notification purpose
// Created by HL on Mar 15 2019
// Scheduled on Daily basis - Weekly Request for Weekly Timesheet Submission - Immediately at Event End Time for the last Event for the Time Card Period

global class WeeklyRequestToInstructor_Schedule implements Schedulable {

    global void execute(SchedulableContext sc) {
    
        Set<Date> federalHoliday = new Set<Date>();
        
        federalHoliday = HolidayService.getHolidaysWithRecurrence(Date.newInstance(system.today().year(),01,01),Date.newInstance(system.today().year(),12,31));
        system.debug(':::::federalHoliday::::::'+federalHoliday);
        
        Date todayDt = system.today();
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
                
        if(!federalHoliday.contains(todayDt) && todayVal.format('EEEE') != 'Saturday' && todayVal.format('EEEE') != 'Sunday') {
            
            WeeklyRequestToInstructor dailyRemainder = new WeeklyRequestToInstructor();
            database.executeBatch(dailyRemainder,1);
        }
    }
}