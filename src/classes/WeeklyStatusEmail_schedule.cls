// Schdeuler to call supervisor_WeeklyStatus_Email_Batch batch class for email notification purpose
// Created by Sukanya on March 27 2017
// Scheduled on daily basis - Weekly Timesheet Status E-mail to Supervisor (Monday @ 2:00 pm ET)

global class WeeklyStatusEmail_schedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        
        supervisor_WeeklyStatus_Email_Batch weeklyStatus = new supervisor_WeeklyStatus_Email_Batch();
        database.executeBatch(weeklyStatus,10);
    }
}