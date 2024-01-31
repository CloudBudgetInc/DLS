// Schdeuler to call dailyRemainder_Overdue batch class for email notification purpose
// Created by Sukanya on March 27 2017
// Scheduled on daily basis - Daily Reminder for Overdue Daily Time Entry (Every day @01:00pm ET)

global class DailyRemainder_Overdue_schedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        
        Set<Date> federalHoliday = new Set<Date>();
        
        /*for(Holiday hol :[SELECT Id, Name, ActivityDate FROM Holiday WHERE ActivityDate = THIS_YEAR]) {
            federalHoliday.add(hol.ActivityDate);
        }*/
        //Recurrence method call to get correct holiday dates for these date interval
        // Modified by NS on Jan 07 2019
        federalHoliday = HolidayService.getHolidaysWithRecurrence(Date.newInstance(system.today().year(),01,01),Date.newInstance(system.today().year(),12,31));
        system.debug(':::::federalHoliday::::::'+federalHoliday);
        
        Date todayDt = system.today();
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        // Do not send overdue remainder for holiday days
        Date previousDate;
        
        if(todayVal.format('EEEE') == 'Monday') {
            previousDate = system.today().addDays(-3);
        } else {
            previousDate = system.today().addDays(-1);
        }
        
        if(!federalHoliday.contains(todayDt) && !federalHoliday.contains(previousDate) 
            && todayVal.format('EEEE') != 'Saturday' && todayVal.format('EEEE') != 'Sunday') {
            
            dailyRemainder_Overdue dailyOverdue = new dailyRemainder_Overdue();
            database.executeBatch(dailyOverdue,10);
        }
    }
}