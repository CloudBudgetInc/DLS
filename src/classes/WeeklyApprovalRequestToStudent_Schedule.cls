/****************
    - Added by HL on Oct 17 2019
    - Work Item : W-002922 - Student Time Approval Preferences (Daily, Weekly, No Approval)
    - To send an email notification to students at Friday at 5:00 PM if the Instructor did not Complete or Submit their Timesheet and if the student selects "Weekly" Time Approval Preferences
    - This scheduler runs Friday at 5:00
    ******************/
    
public class WeeklyApprovalRequestToStudent_Schedule implements Schedulable{

    public void execute(SchedulableContext sc) {
    
        Date currentWeekStart = System.today().toStartofWeek().addDays(1);
        Date currentWeekEnd = currentWeekStart.addDays(6);
        
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects', 'ESL_LT_Projects'};
        
        Map<Id, AcctSeed__Time_Card_Day__c> dayIdAndRec = new Map<Id, AcctSeed__Time_Card_Day__c>([
            SELECT Id 
            FROM AcctSeed__Time_Card_Day__c 
            WHERE Project_Task_Type__c != 'Preparation time' AND (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'Candidate' 
                OR (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'DLS_Employee' 
                AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Active_DLS_Employee__c = TRUE))
                AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName IN :projRTDevNames 
                AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.No_Student_Approval__c = FALSE  
                AND AcctSeed__Date__c >= :currentWeekStart AND  AcctSeed__Date__c <= :currentWeekEnd 
                AND AcctSeed__Time_Card_Line__r.Completed__c = FALSE AND Status__c != 'Submitted'
        ]);
        System.debug(':::dayIdAndRec::::'+dayIdAndRec);
        System.debug(':::dayIdAndRec::SIZE::::'+dayIdAndRec.size());
        
        if(dayIdAndRec.size() > 0){
        
            timeCardRelated_Email_Controller.sendAnEmailToStudent(dayIdAndRec.keySet(), FALSE);
        }
    }
}