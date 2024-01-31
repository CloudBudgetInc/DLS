@isTest
private class GLAccountTrigger_Test{

    @testSetup static void setupMethod(){
    
        List<AcctSeed__GL_Account__c> glAccounts = TestClassUtil.createTestGLAccount();
    }
    
    private static testMethod void myTest(){
        
        BillDotComUtil.updateFromBillDotComSync = FALSE;
        
        List<AcctSeed__GL_Account__c> glAccs = [SELECT Id, AcctSeed__Sub_Type_1__c FROM AcctSeed__GL_Account__c LIMIT 1];
        glAccs[0].AcctSeed__Sub_Type_1__c = 'Cost of Goods Sold';
        update glAccs[0];
        
        List<AcctSeed__GL_Account__c> glAccRecs = [SELECT Id, Bill_com_Sync_Status__c FROM AcctSeed__GL_Account__c WHERE Id = :glAccs[0].Id];
        System.assertEquals('Pending', glAccRecs[0].Bill_com_Sync_Status__c);
    }
}