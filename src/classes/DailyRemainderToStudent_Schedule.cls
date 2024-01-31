// Work Item : W-001120
// Schdeuler to call DailyTimeEntryRemainderToStudent batch class for email notification purpose
// Created by HL on Mar 07 2019
// Scheduled on Daily basis - Daily Time Entry Approval Reminder (if overdue) - Only Send if time entry has not yet been approved @ 10.00 am and @ 2.00 pm     

global class DailyRemainderToStudent_Schedule implements Schedulable {

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
        
        if(!federalHoliday.contains(todayDt) && !federalHoliday.contains(previousDate)) {
            
            DailyTimeEntryRemainderToStudent dailyRemainder= new DailyTimeEntryRemainderToStudent();
            database.executeBatch(dailyRemainder,1);
        }
    }
}