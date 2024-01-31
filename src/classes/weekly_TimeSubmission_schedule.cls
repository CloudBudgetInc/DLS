// Schdeuler to call weeklyRemainder_TimeSubmission batch class for email notification purpose
// Created by Sukanya on March 27 2017
// Scheduled on daily basis - Weekly Reminder for Timesheet Submission (Monday 1:00 pm ET) - Excluded Sunday

global class weekly_TimeSubmission_schedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        
        weeklyRemainder_TimeSubmission weeklyReminder = new weeklyRemainder_TimeSubmission();
        database.executeBatch(weeklyReminder,10);
    }
}