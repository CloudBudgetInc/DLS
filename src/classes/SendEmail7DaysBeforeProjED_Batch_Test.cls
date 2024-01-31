@isTest
private class SendEmail7DaysBeforeProjED_Batch_Test{
    
    @testSetup static void setupMethod(){
        
        List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();
    }
    
    @isTest
    private static void sendEmail_1(){
        
        Account acc = new Account(Name = 'DLS Send Email Acc');
        insert acc;
        
        List<AcctSeed__Project__c> projs = [SELECT Id, Name, End_Date__C FROM AcctSeed__Project__c WHERE Acctseed__Status__c = 'Active'];
        projs[0].End_Date__C = Date.Today().addDays(7);
        projs[0].AcctSeed__Account__c = acc.Id;
        update projs[0];
        
        Test.startTest();
        
        SendEmail7DaysBeforeProjectEndDate_Batch  sch2 = new SendEmail7DaysBeforeProjectEndDate_Batch(); 
        String sch = '0 0 1 * * ?'; 
        system.schedule('Send Email 7 Days Before Project EndDate', sch, sch2); 
        
        Test.stopTest();
    }
}