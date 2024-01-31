@isTest
public class SendProgressReportReminderCmp_Ctrl_Test {
	@TestSetup
    static void setupMethod(){
         List<Assessment_Report__c> contactAssignList = TestClassUtil.createTestAssessmentReport(); 
    }
    
    private static testMethod void testsendReminderMailToInstructor(){
        Assessment_Report__c ar = [SELECT Id, Report_Date__c FROM Assessment_Report__c LIMIT 1];
        ar.Report_Date__c = System.today().addDays(10);
        update ar;
        SendProgressReportReminderCmp_Ctrl.sendReminderMailToInstructor(ar.Id);
    }
}