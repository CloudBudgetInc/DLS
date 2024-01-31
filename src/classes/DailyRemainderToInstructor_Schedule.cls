// Work Item : W-001111
// Schdeuler to call DailyTimeEntryRemainderToInstructor batch class for email notification purpose
// Created by HL on Mar 06 2019
// Scheduled on Daily basis - Event Driven Daily Time Entry Reminder - Send an email on the second day from the missed entry @ 08.00 am, @ 12:00 pm and @ 04:00 pm

global class DailyRemainderToInstructor_Schedule implements Schedulable {

    global void execute(SchedulableContext sc) {
    
        Set<Date> federalHoliday = new Set<Date>();
        
        federalHoliday = HolidayService.getHolidaysWithRecurrence(Date.newInstance(system.today().year(),01,01),Date.newInstance(system.today().year(),12,31));
        system.debug(':::::federalHoliday::::::'+federalHoliday);
        
        Date todayDt = system.today();
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        Date previousDate;
        
        if(todayVal.format('EEEE') == 'Monday') {
            previousDate = system.today().addDays(-3);
        } else {
            previousDate = system.today().addDays(-1);
        }
        
        if(!federalHoliday.contains(previousDate) && todayVal.format('EEEE') != 'Saturday' && todayVal.format('EEEE') != 'Sunday') {
            
            DailyTimeEntryRemainderToInstructor dailyRemainder= new DailyTimeEntryRemainderToInstructor();
            database.executeBatch(dailyRemainder,1);
        }
    }
}