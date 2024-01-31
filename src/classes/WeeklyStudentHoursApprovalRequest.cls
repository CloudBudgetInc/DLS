/******************
    - Added By HL on Apr 26 2022
    - Work Item: W-007441 - Student Timekeeping Approval Reminder and Process Changes (4.20.22)
    - To send an email notification to students(not for class leaders) to approve or reject their student hours (Attendance) which are submitted by the instructors
    - This email logic moved from Attendance Trigger to Scheduler. Because default timekeeping reminders(Time_Approval_Preference__c) modified from "Daily" to "Weekly"
    - This scheduler runs Friday at 5:00 PM
    ***********/
public class WeeklyStudentHoursApprovalRequest implements Schedulable{

    public void execute(SchedulableContext sc) {
        
        WeeklyStudentHoursApprovalRequest_Batch approval_Request = new WeeklyStudentHoursApprovalRequest_Batch();
        Database.Executebatch(approval_Request, 10);
    }
}