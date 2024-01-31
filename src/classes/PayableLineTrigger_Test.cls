@isTest
private class PayableLineTrigger_Test{

    @testSetup static void setupMethod(){
    
        Test.startTest();
        
            List<AcctSeed__Project_Task__c> projTaskRecs = TestClassUtil.createTestProjectTask();
            List<AcctSeed__Accounting_Period__c> ap = TestClassUtil.createTestAccountingPeriod();
        Test.stopTest();
        List<AcctSeed__Ledger__c> ledger = TestClassUtil.createTestLedger();
        List<AcctSeed__Accounting_Variable__c> acVar = TestClassUtil.createAccountingVariable();
    }
    
    private static testMethod void myTest1(){
    
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        
        List<AcctSeed__Accounting_Period__c> ap = [SELECT Id FROM AcctSeed__Accounting_Period__c LIMIT 1];
        
        List<AcctSeed__Ledger__c> ledger = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id FROM AcctSeed__GL_Account__c WHERE AcctSeed__Bank__c = FALSE LIMIT 2];
        
        List<AcctSeed__Account_Payable__c> payableRecs = new List<AcctSeed__Account_Payable__c>{
            new AcctSeed__Account_Payable__c(AcctSeed__Accounting_Period__c = ap[0].Id, AcctSeed__Ledger__c = ledger[0].Id, AcctSeed__Contact__c = contacts[0].Id, AcctSeed__Status__c = 'In Process', AcctSeed__Date__c = Date.Today(), AcctSeed__Due_Date__c = Date.Today().addDays(7), AcctSeed__Payee_Reference__c = 'Test Ref1'),
            new AcctSeed__Account_Payable__c(AcctSeed__Accounting_Period__c = ap[0].Id, AcctSeed__Ledger__c = ledger[0].Id, AcctSeed__Contact__c = contacts[0].Id, AcctSeed__Status__c = 'In Process', AcctSeed__Date__c = Date.Today(), AcctSeed__Due_Date__c = Date.Today().addDays(7), AcctSeed__Payee_Reference__c = 'Test Ref2')
        };
        insert payableRecs;
        
        Test.startTest();
        
            List<AcctSeed__Account_Payable__c> payables = [SELECT Id, Name FROM AcctSeed__Account_Payable__c WHERE Id IN : payableRecs];
            
            List<AcctSeed__Account_Payable_Line__c> lines = new List<AcctSeed__Account_Payable_Line__c>{
                
                new AcctSeed__Account_Payable_Line__c(AcctSeed__Expense_GL_Account__c = glAccList[0].Id, AcctSeed__Account_Payable__c = payables[0].Id, AcctSeed__Amount__c = 50, Amount_per_Quantity__c = 20, AcctSeed__Quantity__c = 2),
                new AcctSeed__Account_Payable_Line__c(AcctSeed__Expense_GL_Account__c = glAccList[1].Id, AcctSeed__Account_Payable__c = payables[0].Id, AcctSeed__Amount__c = 50, Amount_per_Quantity__c = 20, AcctSeed__Quantity__c = 2)
            };
            insert lines;
            
            List<AcctSeed__Account_Payable_Line__c> payableLines = [SELECT Id, AcctSeed__Amount__c FROM AcctSeed__Account_Payable_Line__c WHERE Id IN : lines];
            System.assertEquals(40, payableLines[0].AcctSeed__Amount__c);
            
        Test.stopTest();
    }
    
    private static testMethod void myTest2(){
    
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        
        List<AcctSeed__Accounting_Period__c> ap = [SELECT Id FROM AcctSeed__Accounting_Period__c LIMIT 1];
        
        List<AcctSeed__Ledger__c> ledger = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id FROM AcctSeed__GL_Account__c WHERE AcctSeed__Bank__c = FALSE LIMIT 2];
        
        List<AcctSeed__Account_Payable__c> payableRecs = new List<AcctSeed__Account_Payable__c>{
            new AcctSeed__Account_Payable__c(AcctSeed__Accounting_Period__c = ap[0].Id, AcctSeed__Ledger__c = ledger[0].Id, AcctSeed__Contact__c = contacts[0].Id, AcctSeed__Status__c = 'In Process', AcctSeed__Date__c = Date.Today(), AcctSeed__Due_Date__c = Date.Today().addDays(7), AcctSeed__Payee_Reference__c = 'Test Ref1'),
            new AcctSeed__Account_Payable__c(AcctSeed__Accounting_Period__c = ap[0].Id, AcctSeed__Ledger__c = ledger[0].Id, AcctSeed__Contact__c = contacts[0].Id, AcctSeed__Status__c = 'In Process', AcctSeed__Date__c = Date.Today(), AcctSeed__Due_Date__c = Date.Today().addDays(7), AcctSeed__Payee_Reference__c = 'Test Ref2')
        };
        
        Test.startTest();
        
            insert payableRecs;
            
            List<AcctSeed__Account_Payable__c> payables = [SELECT Id, Name FROM AcctSeed__Account_Payable__c WHERE Id IN : payableRecs];
            
            List<AcctSeed__Account_Payable_Line__c> lines = new List<AcctSeed__Account_Payable_Line__c>{
                
                new AcctSeed__Account_Payable_Line__c(AcctSeed__Expense_GL_Account__c = glAccList[0].Id, AcctSeed__Account_Payable__c = payables[0].Id, AcctSeed__Amount__c = 50, Amount_per_Quantity__c = 20)
            };
            
            try{
                insert lines;
            }catch(Exception e){
            
                Boolean expectedExceptionThrown =  e.getMessage().contains('Either the Quantity or Amount per Quantity is blank. Please enter both the Quantity and the Amount per Quantity to calculate the amount based on Quantity, or leave both fields blank.') ? true : false;
                System.AssertEquals(expectedExceptionThrown, true);
            }
        
        Test.stopTest();
    }
    
    private static testMethod void myTest3(){
    
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        
        List<AcctSeed__Accounting_Period__c> ap = [SELECT Id FROM AcctSeed__Accounting_Period__c LIMIT 1];
        
        List<AcctSeed__Ledger__c> ledger = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, AcctSeed__Bank__c FROM AcctSeed__GL_Account__c WHERE AcctSeed__Type__c = 'Expense' LIMIT 1];
        glAccList[0].AcctSeed__Bank__c = FALSE;
        update glAccList[0];
        
        List<AcctSeed__Accounting_Variable__c> acVar = [SELECT Id,AcctSeed__Active__c FROM AcctSeed__Accounting_Variable__c WHERE AcctSeed__Type__c = 'GL Account Variable 1' LIMIT 1];
        acVar[0].AcctSeed__Active__c = TRUE;
        update acVar[0];
        
        List<AcctSeed__Project_Task__c> tasks = [SELECT Id, AcctSeed__GL_Account_Variable_1__c, AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 1];
        tasks[0].AcctSeed__GL_Account_Variable_1__c = acVar[0].Id;
        
        Test.startTest();
        
            update tasks[0];
                
            AcctSeed__Account_Payable__c pay = new AcctSeed__Account_Payable__c(AcctSeed__Accounting_Period__c = ap[0].Id, AcctSeed__Ledger__c = ledger[0].Id, AcctSeed__Contact__c = contacts[0].Id, AcctSeed__Status__c = 'In Process', AcctSeed__Date__c = Date.Today(), AcctSeed__Due_Date__c = Date.Today().addDays(7), AcctSeed__Payee_Reference__c = 'Test Ref1');
            insert pay;
            
            List<AcctSeed__Account_Payable__c> payables = [SELECT Id, Name FROM AcctSeed__Account_Payable__c WHERE Id =: pay.Id];
            
            List<AcctSeed__Account_Payable_Line__c> lines = new List<AcctSeed__Account_Payable_Line__c>{
                
                new AcctSeed__Account_Payable_Line__c(AcctSeed__Project__c = tasks[0].AcctSeed__Project__c, AcctSeed__Project_Task__c = tasks[0].Id, AcctSeed__Expense_GL_Account__c = glAccList[0].Id, AcctSeed__Account_Payable__c = payables[0].Id, AcctSeed__Amount__c = 50,Amount_per_Quantity__c = 20, AcctSeed__Quantity__c = 2)
            };   
            insert lines;
            
            List<AcctSeed__Account_Payable_Line__c> lineRec = [SELECT Id, AcctSeed__GL_Account_Variable_1__c FROM AcctSeed__Account_Payable_Line__c WHERE Id IN : lines];
            System.assertEquals(acVar[0].Id, lineRec[0].AcctSeed__GL_Account_Variable_1__c);
            
        Test.stopTest();     
    }
}