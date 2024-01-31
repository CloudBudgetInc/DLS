// This email logic moved from scheduler to batch class to fix the issue related to "ERROR: System.EmailException:SendEmail failed. Too many SOQL queries: 101"

public class WeeklyStudentHoursApprovalRequest_Batch implements Database.batchable<sObject>,Database.Stateful { 

    public Date currentWeekStart = System.today().toStartofWeek().addDays(1);
    public Date currentWeekEnd = currentWeekStart.addDays(6);
        
    public Database.QueryLocator start(Database.BatchableContext info){   
            
        String contactQry = 'SELECT Id, Name FROM Contact WHERE Email != NULL AND Id IN (SELECT Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = \'Student\' AND Assignment_Position__c = \'Student\' AND Time_Approval_Preference__c = \'Weekly\')';
        contactQry += ' AND Id IN (SELECT Student__c FROM Attendance__c WHERE Date__c >= :currentWeekStart AND  Date__c <= :currentWeekEnd AND Time_Card_Day__c != NULL AND Student_Approval_Status__c = \'Submitted\'';
        contactQry += ' AND Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.No_Student_Approval__c = FALSE)';
        
        System.debug('::::::::contactQry::::::::::'+contactQry);
        return Database.getQueryLocator(contactQry);
    }
    
    public void execute(Database.BatchableContext info, List<Contact > contacts){
        
        if(contacts.size() > 0){
      
            List<Attendance__c> attendanceRecs = [SELECT Id, Student__c, Time_Card_Day__c, Project_RecordType_Name__c, Late_Cancellation__c, 
                                                    Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, Date__c, 
                                                    DLS_Class__c, Time_Card_Day__r.Time_Card_Period_Week_Range_Format__c, Student__r.Name, 
                                                    Instructor__c, Instructor_Name__c
                                                FROM Attendance__c
                                                WHERE Student__c IN : contacts AND Date__c >= :currentWeekStart AND  Date__c <= :currentWeekEnd AND Time_Card_Day__c != NULL AND Student_Approval_Status__c = 'Submitted' AND
                                                    Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.No_Student_Approval__c = FALSE];
            System.debug('::attendanceRecs:::'+attendanceRecs);
            System.debug('::attendanceRecs::SIZE:'+attendanceRecs.size());
            
            if(attendanceRecs.size() > 0){
                timeCardRelated_Email_Controller.sendStudentHoursEmail(attendanceRecs, 'Request');
            }
        }      
    }
    
    public void finish(Database.BatchableContext info){
    }
}