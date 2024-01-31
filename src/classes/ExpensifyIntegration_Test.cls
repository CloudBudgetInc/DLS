@isTest
public class ExpensifyIntegration_Test {
     @testSetup
    static void setupMethod(){
        TestClassUtil.createTestAccounts();
        TestClassUtil.createTestAccountingPeriod();
        TestClassUtil.createAccountSettings();
        TestClassUtil.createTestGLAccount();
    }
    
    private static testmethod void getLookupRecordsTest(){
        
        Test.startTest();
            List<sObject> sObjectList = CreateExpenses_Ctrl.getLookupRecords('test','Account','Name','',new List<String>());            
        Test.stopTest();
    }
    
    private static testmethod void exportReportAndCreatePayableAndPaybleLinesTest(){
        List<Account> acc = [SELECT Id FROM Account];
        List<AcctSeed__Accounting_Period__c> period = [SELECT Id FROM AcctSeed__Accounting_Period__c];
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ExpensifyMock.ExpensifyExportReportMock());
            String payableLine = CreateExpenses_Ctrl.exportReport('2021-02-19','2021-02-19'); 
            Set<String> availableTransIds = (Set<String>) JSON.deserialize(CreateExpenses_Ctrl.getPayableLineByTransactionId(new List<String>{'52186854828539937'}), Set<String>.class);
            System.assertEquals(0,availableTransIds.size());
            
            List<ExpensifyDomain.payableLineWrap> payableLineWrapObj = (List<ExpensifyDomain.payableLineWrap>) JSON.deserialize(payableLine, List<ExpensifyDomain.payableLineWrap>.class);    
            payableLineWrapObj[0].Expense_GL_Account = '51220 - Direct Contractors-Other'; 
        	payableLineWrapObj[0].transactionId = '52186854828539937';
            String payableObj = '{"accountingPeriod":[{"Id":"'+period[0].Id+'","Name":"2021-02"}],"vendor":[{"Id":"'+acc[0].Id+'","Name":"American Express Company"}],"totalAmount":13.58,"dateVal":"2021-03-10","dueDate":"2021-03-10","payeeReference":"FEB_SS_2021_1"}';   
            String result = CreateExpenses_Ctrl.createPayableAndPayableLines(payableObj,JSON.serialize(payableLineWrapObj));
        
            availableTransIds = (Set<String>) JSON.deserialize(CreateExpenses_Ctrl.getPayableLineByTransactionId(new List<String>{'52186854828539937'}), Set<String>.class);
            System.assertEquals(1,availableTransIds.size());
        Test.stopTest();
    }
    
    private static testmethod void getCreditCardDetailsTest(){
        
        Map<String, String> creditCardMap = (Map<String, String>) JSON.deserialize(CreateExpenses_Ctrl.getExpensifyCreditCard(), Map<String, String>.class);
        System.assertEquals(0, creditCardMap.size());
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new ExpensifyMock.ExpensifyCreditCardMock());
            ExpensifyCreditCardSync_Scheduler sch = new ExpensifyCreditCardSync_Scheduler();
            sch.execute(null);
        Test.stopTest();
        
        creditCardMap = (Map<String, String>) JSON.deserialize(CreateExpenses_Ctrl.getExpensifyCreditCard(), Map<String, String>.class);
        System.assertEquals(1, creditCardMap.size());
    }
}