// Work Item : W-000934
// Schdeuler to call ReminderofDatawatchCardReturn batch class for email notification purpose
// Created by HL on Mar 16 2019
// Scheduled on Daily basis - Reminder to return your Building Access Card

global class ReminderofDatawatchCardReturn_Schedule implements Schedulable {

    global void execute(SchedulableContext sc) {
    
        Set<Date> federalHoliday = new Set<Date>();
        
        federalHoliday = HolidayService.getHolidaysWithRecurrence(Date.newInstance(system.today().year(),01,01),Date.newInstance(system.today().year(),12,31));
        system.debug(':::::federalHoliday::::::'+federalHoliday);
        
        Date todayDt = system.today();
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        if(!federalHoliday.contains(todayDt) && todayVal.format('EEEE') != 'Sunday' && todayVal.format('EEEE') != 'Saturday') {
            
            ReminderofDatawatchCardReturn dailyReminder= new ReminderofDatawatchCardReturn();
            database.executeBatch(dailyReminder,1);
        }
    }
}