// Work Item : W-001111
// Scheduler to call DailyTimeEntryRequestToInstructor batch class for email notification purpose
// Created by HL on May 30 2019
// Scheduled Daily basis on every one hour- Daily Time Entry Request To Instructor
 
global class DailyRequestToInstructor_Schedule implements Schedulable {

    global void execute(SchedulableContext sc) {
    
        Set<Date> federalHoliday = new Set<Date>();
        
        federalHoliday = HolidayService.getHolidaysWithRecurrence(Date.newInstance(system.today().year(),01,01),Date.newInstance(system.today().year(),12,31));
        system.debug(':::::federalHoliday::::::'+federalHoliday);
        
        Date todayDt = system.today();
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
                
        if(!federalHoliday.contains(todayDt) &&  todayVal.format('EEEE') != 'Saturday' && todayVal.format('EEEE') != 'Sunday') {
            
            DailyTimeEntryRequestToInstructor  dailyRemainder= new DailyTimeEntryRequestToInstructor();
            database.executeBatch(dailyRemainder,1);
        }
    }
}