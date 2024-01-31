@isTest
private class CaseEscalationReminder_Schedule_Test{
    
    @testSetup static void mySetupMethod(){
        
        List<Case> cases = TestClassUtil.createTestCase();
    }
    
    private static testMethod void myTestMethod(){
        
        List<Case> caseRecs = [SELECT Id, Subject, Is_Send_Escalation_Reminder__c FROM Case];
        
        CaseEscalationReminder_Schedule  sch2 = new CaseEscalationReminder_Schedule(); 
        String cron = '0 0 * * * ?'; 
        system.schedule('Case Escalation Reminder Update on @Every Hour', cron, sch2);
    }
}