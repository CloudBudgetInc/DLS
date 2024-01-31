@isTest
private class AccountingVariableTrigger_Test{

    @testSetup static void setupMethod(){
    
        List<AcctSeed__Accounting_Variable__c> accVarRecs = TestClassUtil.createAccountingVariable();
    }
    
    private static testMethod void myTest(){
        
        BillDotComUtil.updateFromBillDotComSync = FALSE;
        
        List<AcctSeed__Accounting_Variable__c> accVar = [SELECT Id, AcctSeed__Active__c FROM AcctSeed__Accounting_Variable__c WHERE AcctSeed__Type__c = 'GL Account Variable 1' LIMIT 1];
        accVar[0].AcctSeed__Active__c = TRUE;
        update accVar;
        
        
        List<AcctSeed__Accounting_Variable__c> accVarRecs = [SELECT Id, Bill_com_Sync_Status__c FROM AcctSeed__Accounting_Variable__c WHERE Id = :accVar[0].Id];
        System.assertEquals('Pending', accVarRecs[0].Bill_com_Sync_Status__c);
    }
}