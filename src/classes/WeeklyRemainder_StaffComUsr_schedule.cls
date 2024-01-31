// Schdeuler to call StaffComUsrEmailRemainder batch class for email notification purpose
// Created by Sukanya on Dec 11 2018
// Scheduled on weekly basis - Weekly Reminder for Staff Com User on Friday & Monday (@10:00am ET)

global class WeeklyRemainder_StaffComUsr_schedule implements Schedulable {
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
        if(!federalHoliday.contains(todayDt) && todayVal.format('EEEE') != 'Saturday' && todayVal.format('EEEE') != 'Sunday') {
            
            StaffComUsrEmailRemainder weeklyOverdue = new StaffComUsrEmailRemainder();
            database.executeBatch(weeklyOverdue,10);
        }
    }
}