@isTest
private class formResponseTrigger_Test{
    
    @testSetup static void setupMethod(){
        
        List<Contact> contacts = TestClassUtil.createTestContacts();    
    }
    
    @isTest
    private static void sendPerformanceEmailTest(){
        
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 3];
        
        List<Performance_Cycle__c> performanceCycleRecs = new List<Performance_Cycle__c>{
            new Performance_Cycle__c(Name = 'Test Performance Cycle 1', Activity_From__c = Date.Today(), Activity_To__c = Date.Today().addMonths(5), Status__c = 'Pending'),
            new Performance_Cycle__c(Name = 'Test Performance Cycle 2', Activity_From__c = Date.Today(), Activity_To__c = Date.Today().addMonths(5), Status__c = 'Deployed')
        };
        insert performanceCycleRecs;
        
        List<Form_Response__c> formResponses = new List<Form_Response__c>{
            new Form_Response__c(Performance_Cycle__c = performanceCycleRecs[0].Id, Feedback_From__c = contacts[0].Id, Feedback_About__c = contacts[1].Id, Form_Feedback_Type__c = 'Manager Summary', Due_Date__c = Date.Today().addDays(1)),
            new Form_Response__c(Performance_Cycle__c = performanceCycleRecs[1].Id, Feedback_From__c = contacts[0].Id, Feedback_About__c = contacts[1].Id, Form_Feedback_Type__c = 'Peer Summary', Due_Date__c = Date.Today().addDays(3)),
            new Form_Response__c(Performance_Cycle__c = performanceCycleRecs[1].Id, Feedback_From__c = contacts[0].Id, Feedback_About__c = contacts[1].Id, Form_Feedback_Type__c = 'Self Summary', Due_Date__c = Date.Today().addDays(5))
        };
        insert formResponses;
    }
}