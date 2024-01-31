@isTest
private class DODA_EOT_GetFeedback_Survey_Email_Test{
    
    @testSetup static void setupMethod(){
        
         List<Contact_Assignments__c > conAssList = TestClassUtil.createTestContactAssignment();
    }
    
    private static testMethod void myTest(){
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id doda_GF_RTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('DODA_End_of_Training_Survey').getRecordTypeId();
        Id doda_Proj_RTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
                        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<AcctSeed__Project__c> proj = [SELECT Id, RecordTypeId, Start_Date__c, End_Date__c FROM AcctSeed__Project__c LIMIT 1];
        proj[0].RecordTypeId = doda_Proj_RTId;
        proj[0].Start_Date__c = Date.Today().addDays(-10);
        proj[0].End_Date__c = Date.Today();
        update proj[0];
                            
        List<Contact_Assignments__c> conAssignRecs = [SELECT Id, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' LIMIT 1];
        conAssignRecs[0].Project__c = proj[0].Id;
        update conAssignRecs[0];
        
        Test.startTest();
            
            DODA_EOT_GetFeedback_Survey_Email  sch2 = new DODA_EOT_GetFeedback_Survey_Email(); 
            String sch = '0 0 0 * * ?'; 
            system.schedule('DODA EOT Get Feedback Survey Email', sch, sch2); 

        Test.stopTest();
    }
}