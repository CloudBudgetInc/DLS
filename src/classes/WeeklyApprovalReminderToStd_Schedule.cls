/****************
    - Added by HL on Oct 17 2019
    - Work Item : W-002922 - Student Time Approval Preferences (Daily, Weekly, No Approval)
    - To send an email notification to students on Monday at 9:00 AM if they still have not approved the time entries and if the student selects "Weekly" Time Approval Preferences
    - This scheduler runs Monday at 9:00 AM
    ******************/
    
public class WeeklyApprovalReminderToStd_Schedule implements Schedulable{

    public void execute(SchedulableContext sc) {
    
        Date currentWeekStart = System.today().toStartofWeek().addDays(1);
        Date currentWeekEnd = currentWeekStart.addDays(6);
        
        Date previouswkStart = currentWeekStart.addDays(-7);
        Date previouswkEnd = previouswkStart.addDays(6);
                        
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects', 'ESL_LT_Projects'};
            
        Map<Id, AcctSeed__Time_Card_Day__c> dayIdAndRec = new Map<Id, AcctSeed__Time_Card_Day__c>([
            SELECT Id 
            FROM AcctSeed__Time_Card_Day__c 
            WHERE Project_Task_Type__c != 'Preparation time' AND (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'Candidate' 
                OR (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'DLS_Employee' 
                AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Active_DLS_Employee__c = TRUE))
                AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName IN :projRTDevNames 
                AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.No_Student_Approval__c = FALSE AND 
                AcctSeed__Date__c >= :previouswkStart AND  AcctSeed__Date__c <= :previouswkEnd 
                AND AcctSeed__Time_Card_Line__r.Completed__c = FALSE AND Status__c != 'Submitted'
        ]);
        System.debug(':::dayIdAndRec::::'+dayIdAndRec);
        System.debug(':::dayIdAndRec::SIZE::::'+dayIdAndRec.size());
        
        if(dayIdAndRec.size() > 0){
        
            timeCardRelated_Email_Controller.sendAnEmailToStudent(dayIdAndRec.keySet(), FALSE);
        }
    }
}