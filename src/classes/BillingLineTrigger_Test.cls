@isTest
private class BillingLineTrigger_Test{

    @testSetup static void setupMethod(){
    
        Test.startTest();
        
            List<AcctSeed__Project_Task__c> projTaskRecs = TestClassUtil.createTestProjectTask();
            List<AcctSeed__Accounting_Period__c> ap = TestClassUtil.createTestAccountingPeriod();
            List<CLIN__c> clins = TestClassUtil.createTestClin();
        Test.stopTest();
        List<AcctSeed__Ledger__c> ledger = TestClassUtil.createTestLedger();
        List<AcctSeed__Accounting_Variable__c> acVar = TestClassUtil.createAccountingVariable();
    }
    private static testMethod void testMethod1(){
        List<Account> accList = [SELECT Id,AcctSeed__Billing_Contact__c  FROM Account LIMIT 1];
        List<AcctSeed__Project__c> proList = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c LIMIT 1];
        List<AcctSeed__Project_Task__c> proPTList = [SELECT Id,RecordTypeId FROM AcctSeed__Project_Task__c LIMIT 1];
        List<AcctSeed__Ledger__c> ledger = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id FROM AcctSeed__GL_Account__c WHERE AcctSeed__Bank__c = FALSE LIMIT 2];
        
        
        AcctSeed__Billing_Format__c pdfFormat= new AcctSeed__Billing_Format__c(); 
        pdfFormat.AcctSeed__Default_Email_Template__c = 'Billing_Email_Template';
        pdfFormat.AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF';
        pdfFormat.AcctSeed__Type__c = 'Billing';
        pdfFormat.Name = 'Default Billing Product';
        
        insert pdfFormat;
            
            
        if(proList.size() > 0 && proPTList.size() > 0 && accList.size() > 0){
            
            proList[0].AcctSeed__Account__c = accList[0].Id;
            update proList;
            
            List<AcctSeed__Accounting_Variable__c> acVar = [SELECT Id,AcctSeed__Active__c FROM AcctSeed__Accounting_Variable__c WHERE AcctSeed__Type__c = 'GL Account Variable 1' LIMIT 1];
            acVar[0].AcctSeed__Active__c = TRUE;
            update acVar;
            
            proPTList[0].AcctSeed__GL_Account_Variable_1__c = acVar[0].Id;
            update proPTList;
            
            
            List<AcctSeed__Billing__c> billingList = new List<AcctSeed__Billing__c>{
                new AcctSeed__Billing__c(AcctSeed__Customer__c = accList[0].Id,AcctSeed__Billing_Format__c = pdfFormat.Id,AcctSeed__Ledger__c = ledger[0].Id,AcctSeed__Status__c = 'Approved',AcctSeed__Date__c = system.today(),AcctSeed__Billing_Cycle_End_Date__c = acpList[0].AcctSeed__End_Date__c,AcctSeed__Billing_Cycle_Start_Date__c = acpList[0].AcctSeed__Start_Date__c),
                new AcctSeed__Billing__c(AcctSeed__Customer__c = accList[0].Id,AcctSeed__Billing_Format__c = pdfFormat.Id,AcctSeed__Ledger__c = ledger[0].Id,AcctSeed__Status__c = 'Approved',AcctSeed__Date__c = system.today().addDays(1),AcctSeed__Billing_Cycle_End_Date__c = acpList[0].AcctSeed__End_Date__c,AcctSeed__Billing_Cycle_Start_Date__c = acpList[0].AcctSeed__Start_Date__c)
            };
            
            if(billingList.size() > 0){
                insert billingList;
           
                AcctSeed__Billing_Line__c billLine = new AcctSeed__Billing_Line__c();
                
                billLine.AcctSeed__Project__c = proList[0].Id;
                billLine.AcctSeed__Project_Task__c = proPTList[0].Id;
                billLine.AcctSeed__Hours_Units__c = 2;
                billLine.AcctSeed__Rate__c = 10;
                billLine.AcctSeed__Date__c = system.today();
                billLine.AcctSeed__Comment__c = 'Test';
                billLine.AcctSeed__Billing__c = billingList[0].Id;
                billLine.AcctSeed__Revenue_GL_Account__c = glAccList[0].Id;
                
                insert billLine;
                
                if(billLine.Id != null){
                    List<AcctSeed__Billing_Line__c> billLineList = [SELECT Id,AcctSeed__GL_Account_Variable_1__c FROM AcctSeed__Billing_Line__c WHERE Id = :billLine.Id];
                    System.assertEquals(acVar[0].Id,billLineList[0].AcctSeed__GL_Account_Variable_1__c);
                }
            }
        }
    }
    
    private static testMethod void testMethod1a(){
        
        List<Account> accList = [SELECT Id,Name, AcctSeed__Billing_Contact__c  FROM Account LIMIT 1];
        accList[0].Name = 'PVT '+ accList[0].Name;
        update accList;
        List<AcctSeed__Project__c> proList = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c LIMIT 1];
        List<AcctSeed__Project_Task__c> proPTList = [SELECT Id,RecordTypeId FROM AcctSeed__Project_Task__c LIMIT 1];
        List<AcctSeed__Ledger__c> ledger = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        List<AcctSeed__GL_Account__c> glAcc = new List<AcctSeed__GL_Account__c> {new AcctSeed__GL_Account__c(Name = 'AccountSettingGLAccount14',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false)  };
        
        insert glAcc;
        
        AcctSeed__Billing_Format__c pdfFormat= new AcctSeed__Billing_Format__c(); 
        pdfFormat.AcctSeed__Default_Email_Template__c = 'Billing_Email_Template';
        pdfFormat.AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF';
        pdfFormat.AcctSeed__Type__c = 'Billing';
        pdfFormat.Name = 'Default Billing Product';
        
        insert pdfFormat;
            
            
        if(proList.size() > 0 && proPTList.size() > 0 && accList.size() > 0){
            
            proList[0].AcctSeed__Account__c = accList[0].Id;
            update proList;
            
            List<AcctSeed__Accounting_Variable__c> acVar = [SELECT Id,AcctSeed__Active__c FROM AcctSeed__Accounting_Variable__c WHERE AcctSeed__Type__c = 'GL Account Variable 1' LIMIT 1];
            acVar[0].AcctSeed__Active__c = TRUE;
            update acVar;
            
            proPTList[0].AcctSeed__GL_Account_Variable_1__c = acVar[0].Id;
            update proPTList;
            
            
            List<AcctSeed__Billing__c> billingList = new List<AcctSeed__Billing__c>{
                new AcctSeed__Billing__c(AcctSeed__Customer__c = accList[0].Id,AcctSeed__Billing_Format__c = pdfFormat.Id,AcctSeed__Ledger__c = ledger[0].Id,AcctSeed__Status__c = 'Approved',AcctSeed__Date__c = system.today(),AcctSeed__Billing_Cycle_End_Date__c = acpList[0].AcctSeed__End_Date__c,AcctSeed__Billing_Cycle_Start_Date__c = acpList[0].AcctSeed__Start_Date__c),
                new AcctSeed__Billing__c(AcctSeed__Customer__c = accList[0].Id,AcctSeed__Billing_Format__c = pdfFormat.Id,AcctSeed__Ledger__c = ledger[0].Id,AcctSeed__Status__c = 'Approved',AcctSeed__Date__c = system.today().addDays(1),AcctSeed__Billing_Cycle_End_Date__c = acpList[0].AcctSeed__End_Date__c,AcctSeed__Billing_Cycle_Start_Date__c = acpList[0].AcctSeed__Start_Date__c)
            };
            
            if(billingList.size() > 0){
                insert billingList;
               
                AcctSeed__Billing_Line__c billLine = new AcctSeed__Billing_Line__c();
                billLine.AcctSeed__Hours_Units__c = 2;
                billLine.AcctSeed__Rate__c = 10;
                billLine.AcctSeed__Date__c = system.today();
                billLine.AcctSeed__Comment__c = 'Test';
                billLine.AcctSeed__Billing__c = billingList[0].Id;
                billLine.AcctSeed__Revenue_GL_Account__c = glAcc[0].Id;
                
                insert billLine;
                
                if(billLine.Id != null){
                    List<AcctSeed__Billing_Line__c> billLineList = [SELECT Id,AcctSeed__GL_Account_Variable_1__c FROM AcctSeed__Billing_Line__c WHERE Id = :billLine.Id];
                    billLineList[0].AcctSeed__Project__c = proList[0].Id;
                    billLineList[0].AcctSeed__Project_Task__c = proPTList[0].Id;
                    update billLineList[0];
                }
            }
        }
    }
    
     private static testMethod void testMethod2(){
        List<Account> accList = [SELECT Id,AcctSeed__Billing_Contact__c  FROM Account LIMIT 1];
        List<AcctSeed__Project__c> proList = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c LIMIT 1];
        List<AcctSeed__Project_Task__c> proPTList = [SELECT Id,RecordTypeId FROM AcctSeed__Project_Task__c LIMIT 1];
        List<AcctSeed__Ledger__c> ledger = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id FROM AcctSeed__GL_Account__c WHERE AcctSeed__Bank__c = FALSE LIMIT 2];
        
        
        AcctSeed__Billing_Format__c pdfFormat= new AcctSeed__Billing_Format__c(); 
        pdfFormat.AcctSeed__Default_Email_Template__c = 'Billing_Email_Template';
        pdfFormat.AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF';
        pdfFormat.AcctSeed__Type__c = 'Billing';
        pdfFormat.Name = 'Default Billing Product';
        
        insert pdfFormat;
            
            
        if(proList.size() > 0 && proPTList.size() > 0 && accList.size() > 0){
            
            proList[0].AcctSeed__Account__c = accList[0].Id;
            update proList;
            
            List<AcctSeed__Accounting_Variable__c> acVar = [SELECT Id,AcctSeed__Active__c FROM AcctSeed__Accounting_Variable__c WHERE AcctSeed__Type__c = 'GL Account Variable 1' LIMIT 1];
            acVar[0].AcctSeed__Active__c = TRUE;
            update acVar;
            
            proPTList[0].AcctSeed__GL_Account_Variable_1__c = acVar[0].Id;
            update proPTList;
            
            
            List<AcctSeed__Billing__c> billingList = new List<AcctSeed__Billing__c>{
                new AcctSeed__Billing__c(AcctSeed__Customer__c = accList[0].Id,AcctSeed__Billing_Format__c = pdfFormat.Id,AcctSeed__Ledger__c = ledger[0].Id,AcctSeed__Status__c = 'Approved',AcctSeed__Date__c = system.today(),AcctSeed__Billing_Cycle_End_Date__c = acpList[0].AcctSeed__End_Date__c,AcctSeed__Billing_Cycle_Start_Date__c = acpList[0].AcctSeed__Start_Date__c),
                new AcctSeed__Billing__c(AcctSeed__Customer__c = accList[0].Id,AcctSeed__Billing_Format__c = pdfFormat.Id,AcctSeed__Ledger__c = ledger[0].Id,AcctSeed__Status__c = 'Approved',AcctSeed__Date__c = system.today().addDays(1),AcctSeed__Billing_Cycle_End_Date__c = acpList[0].AcctSeed__End_Date__c,AcctSeed__Billing_Cycle_Start_Date__c = acpList[0].AcctSeed__Start_Date__c)
            };
            
            if(billingList.size() > 0){
                insert billingList;
           
                AcctSeed__Billing_Line__c billLine = new AcctSeed__Billing_Line__c();
                
                billLine.AcctSeed__Project__c = proList[0].Id;
                billLine.AcctSeed__Project_Task__c = proPTList[0].Id;
                billLine.AcctSeed__Hours_Units__c = 2;
                billLine.AcctSeed__Rate__c = 10;
                billLine.AcctSeed__Date__c = system.today();
                billLine.AcctSeed__Comment__c = 'Test';
                billLine.AcctSeed__Billing__c = billingList[0].Id;
                
                try{
                    insert billLine;
                }catch(Exception e){
                    Boolean expectedExceptionThrown =  e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, You must enter a value: [AcctSeed__Revenue_GL_Account__c]') ? true : false;
                   System.AssertEquals(expectedExceptionThrown, true);
                }
            }
        }
    }
    
    private static testMethod void testMethod3(){
    
        List<Account> accList = [SELECT Id,Name, AcctSeed__Billing_Contact__c  FROM Account LIMIT 1];
        accList[0].Name = 'PVT '+ accList[0].Name;
        update accList;
        List<CLIN__c> clins = [SELECT Id, Contract__c FROM CLIN__c LIMIT 1];
        List<AcctSeed__Project__c> proList = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        proList[0].CLIN__c = clins[0].Id;
        proList[0].Contract__c = clins[0].Contract__c;
        update proList[0];
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c LIMIT 1];
        List<AcctSeed__Project_Task__c> proPTList = [SELECT Id,RecordTypeId FROM AcctSeed__Project_Task__c LIMIT 1];
        proPTList[0].CLIN__c = clins[0].Id;
        update proPTList[0];
        List<AcctSeed__Ledger__c> ledger = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        List<AcctSeed__GL_Account__c> glAcc = new List<AcctSeed__GL_Account__c> {new AcctSeed__GL_Account__c(Name = 'AccountSettingGLAccount14',AcctSeed__Sub_Type_1__c = 'Assets',AcctSeed__Sub_Type_2__c = 'Equity',AcctSeed__Active__c  = true,AcctSeed__Type__c ='Balance Sheet', AcctSeed__Bank__c = false)  };
        
        insert glAcc;
        
        AcctSeed__Billing_Format__c pdfFormat= new AcctSeed__Billing_Format__c(); 
        pdfFormat.AcctSeed__Default_Email_Template__c = 'Billing_Email_Template';
        pdfFormat.AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF';
        pdfFormat.AcctSeed__Type__c = 'Billing';
        pdfFormat.Name = 'Default Billing Product';
        
        insert pdfFormat;
            
            
        if(proList.size() > 0 && proPTList.size() > 0 && accList.size() > 0){
            
            proList[0].AcctSeed__Account__c = accList[0].Id;
            update proList;
            
            List<AcctSeed__Accounting_Variable__c> acVar = [SELECT Id,AcctSeed__Active__c FROM AcctSeed__Accounting_Variable__c WHERE AcctSeed__Type__c = 'GL Account Variable 1' LIMIT 1];
            acVar[0].AcctSeed__Active__c = TRUE;
            update acVar;
            
            proPTList[0].AcctSeed__GL_Account_Variable_1__c = acVar[0].Id;
            update proPTList;
            
            Test.StartTest();
                List<AcctSeed__Billing__c> billingList = new List<AcctSeed__Billing__c>{
                    new AcctSeed__Billing__c(AcctSeed__Customer__c = accList[0].Id,AcctSeed__Billing_Format__c = pdfFormat.Id,AcctSeed__Ledger__c = ledger[0].Id,AcctSeed__Status__c = 'Approved',AcctSeed__Date__c = system.today(),AcctSeed__Billing_Cycle_End_Date__c = acpList[0].AcctSeed__End_Date__c,AcctSeed__Billing_Cycle_Start_Date__c = acpList[0].AcctSeed__Start_Date__c),
                    new AcctSeed__Billing__c(AcctSeed__Customer__c = accList[0].Id,AcctSeed__Billing_Format__c = pdfFormat.Id,AcctSeed__Ledger__c = ledger[0].Id,AcctSeed__Status__c = 'Approved',AcctSeed__Date__c = system.today().addDays(1),AcctSeed__Billing_Cycle_End_Date__c = acpList[0].AcctSeed__End_Date__c,AcctSeed__Billing_Cycle_Start_Date__c = acpList[0].AcctSeed__Start_Date__c)
                };
                
                if(billingList.size() > 0){
                    insert billingList;
                   
                    AcctSeed__Billing_Line__c billLine = new AcctSeed__Billing_Line__c();
                    
                    billLine.AcctSeed__Project__c = proList[0].Id;
                    billLine.AcctSeed__Project_Task__c = proPTList[0].Id;
                    billLine.AcctSeed__Hours_Units__c = 2;
                    billLine.AcctSeed__Rate__c = 10;
                    billLine.AcctSeed__Date__c = system.today();
                    billLine.AcctSeed__Comment__c = 'Test';
                    billLine.AcctSeed__Billing__c = billingList[0].Id;
                    billLine.AcctSeed__Revenue_GL_Account__c = glAcc[0].Id;
                    insert billLine;
                    
                }
            Test.StopTest();
        }
    }
}