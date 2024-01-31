@isTest
public class Test_createOpportunityContactRoles_Batch {
    
    @testSetup static void setup(){
        Test.startTest();
        List<Opportunity> oppList = TestClassUtil.createTestOpportunities();
        Test.stopTest();
    }
    
    public static testmethod void createOpportunityContactRoles_Batch_Fun1() {
        
        Test.startTest();
        List<Opportunity> oppList = [SELECT Id,Name,AccountId,StageName,CloseDate,Student_Name__c,Contracting_Officer__c,Supervisor__c,InstructorName__c FROM Opportunity];
        
        createOpportunityContactRoles_Batch c = new createOpportunityContactRoles_Batch();
        Id batchInstanceId = Database.executeBatch(c, 10); 
        System.debug('batchInstanceId : ' + batchInstanceId);
        
        Test.stopTest();
    }
}