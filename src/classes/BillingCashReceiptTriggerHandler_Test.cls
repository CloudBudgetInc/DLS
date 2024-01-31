@isTest
public class BillingCashReceiptTriggerHandler_Test{

    @testSetup static void setupMethod(){
    
        Test.startTest();
            List<AcctSeed__Project_Task__c> projTaskRecs = TestClassUtil.createTestProjectTask();
            List<AcctSeed__Accounting_Period__c> ap = TestClassUtil.createTestAccountingPeriod();
            TestClassUtil.createTestOppLineItem();
            List<AcctSeed__Accounting_Variable__c> acVar1 = TestClassUtil.createAccountingVariable();
        Test.stopTest();
        TestClassUtil.createAccountSettings();
    }
    
    private static testMethod void testMethod1(){
        
        List<Account> accList = [SELECT Id,Name, AcctSeed__Billing_Contact__c  FROM Account LIMIT 1];
        accList[0].Name = 'PVT '+ accList[0].Name;
        update accList;
        List<AcctSeed__Project__c> proList = [SELECT Id,AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c LIMIT 1];
        List<AcctSeed__Project_Task__c> proPTList = [SELECT Id,RecordTypeId FROM AcctSeed__Project_Task__c LIMIT 1];
        List<AcctSeed__Ledger__c> ledger = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        List<AcctSeed__GL_Account_Default__c> glAccountDefaultList = [SELECT Id, Name, AcctSeed__GL_Account__c, AcctSeed__Ledger__c, AcctSeed__GL_Account_Specification__c FROM AcctSeed__GL_Account_Default__c WHERE AcctSeed__GL_Account_Specification__c IN ('Revenue_GL_Account', 'Default_Credit_GL_Account_Revenue')];
        
        Id revenueGLAccId;
        Id creditGLAccId;
        for(AcctSeed__GL_Account_Default__c glAccDef : glAccountDefaultList){
        
            revenueGLAccId = (glAccDef.AcctSeed__GL_Account_Specification__c == 'Revenue_GL_Account') ? glAccDef.AcctSeed__GL_Account__c : null;
            creditGLAccId = (glAccDef.AcctSeed__GL_Account_Specification__c == 'Default_Credit_GL_Account_Revenue') ? glAccDef.AcctSeed__GL_Account__c : null;
        }
        
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
                billLine.AcctSeed__Revenue_GL_Account__c = revenueGLAccId;
                
                insert billLine;
                
                if(billLine.Id != null){
                    List<AcctSeed__Billing_Line__c> billLineList = [SELECT Id,AcctSeed__GL_Account_Variable_1__c FROM AcctSeed__Billing_Line__c WHERE Id = :billLine.Id];
                    //System.assertEquals(acVar[0].Id,billLineList[0].AcctSeed__GL_Account_Variable_1__c);
                }
            }
        }
        List<AcctSeed__Billing__c> billingLists = [SELECT Id, AcctSeed__Accounting_Period__c, AcctSeed__Total__c, AcctSeed__Customer__c, Project__c FROM AcctSeed__Billing__c];        
        List<AcctSeed__Cash_Receipt__c> cashReciepts = new List<AcctSeed__Cash_Receipt__c>{
            new AcctSeed__Cash_Receipt__c(
                            AcctSeed__Accounting_Period__c=billingLists[0].AcctSeed__Accounting_Period__c, 
                            AcctSeed__Amount__c=billingLists[0].AcctSeed__Total__c, AcctSeed__Receipt_Date__c=System.today(),
                            AcctSeed__Payment_Reference__c='Test1234', AcctSeed__Account__c=billingLists[0].AcctSeed__Customer__c, AcctSeed__Credit_GL_Account__c = creditGLAccId
            )
        };
        insert cashReciepts;  
                
        
        AcctSeed.PostResult[] postResults = AcctSeed.CashReceiptPostService.postCashReceipts(cashReciepts);
        Test.startTest();
        List<Transaction__c> fundingList = [SELECT Id FROM Transaction__c WHERE Project__c = :billingLists[0].Project__c];
        System.assertEquals(0, fundingList.size());
        
        AcctSeed__Billing_Cash_Receipt__c billingCashReceipt = new AcctSeed__Billing_Cash_Receipt__c(AcctSeed__Billing__c=billingLists[0].Id, AcctSeed__Cash_Receipt__c=cashReciepts[0].Id,
                                                AcctSeed__Accounting_Period__c=billingLists[0].AcctSeed__Accounting_Period__c,
                                                AcctSeed__Applied_Amount__c=billingLists[0].AcctSeed__Total__c,AcctSeed__Applied_Date__c=System.today()); 
        insert billingCashReceipt; 
        
        fundingList = [SELECT Id, Transaction_Date__c FROM Transaction__c WHERE Project__c = :billingLists[0].Project__c];
        System.assertEquals(1, fundingList.size()); 
        System.assertEquals(fundingList[0].Transaction_Date__c, System.Today());
        
        delete billingCashReceipt;
        
        // Unpost the cash receipts
        AcctSeed.PostResult[] unpostResults = AcctSeed.CashReceiptPostService.unpostCashReceipts(cashReciepts); 
        
        cashReciepts[0].AcctSeed__Receipt_Date__c = System.Today().addDays(-1); 
        update cashReciepts; 
        
        fundingList = [SELECT Id, Transaction_Date__c FROM Transaction__c WHERE Project__c = :billingLists[0].Project__c];
        System.assertEquals(1, fundingList.size()); 
        System.assertEquals(fundingList[0].Transaction_Date__c, System.Today().addDays(-1));                                      

        postResults = AcctSeed.CashReceiptPostService.postCashReceipts(cashReciepts);
        
        AcctSeed__Billing_Cash_Receipt__c billingCashReceipt1 = new AcctSeed__Billing_Cash_Receipt__c(AcctSeed__Billing__c=billingLists[0].Id, AcctSeed__Cash_Receipt__c=cashReciepts[0].Id,
                                                AcctSeed__Accounting_Period__c=billingLists[0].AcctSeed__Accounting_Period__c,
                                                AcctSeed__Applied_Amount__c=billingLists[0].AcctSeed__Total__c,AcctSeed__Applied_Date__c=System.today()); 
        insert billingCashReceipt1; 
        
        fundingList = [SELECT Id, Transaction_Date__c FROM Transaction__c WHERE Project__c = :billingLists[0].Project__c];
        System.assertEquals(1, fundingList.size()); 
        Test.stopTest();
    }
    
    private static testMethod void testMethod2(){
        
        List<Account> accList = [SELECT Id,Name, AcctSeed__Billing_Contact__c  FROM Account LIMIT 1];
        accList[0].Name = 'PVT '+ accList[0].Name;
        update accList;
        
        List<Opportunity> proList = new List<Opportunity>();        
        List<OpportunityLineItem> opli = new List<OpportunityLineItem>();
        for(Opportunity opp : [SELECT Id,AccountId, StageName, (SELECT Id, Product2.Id, Product2.Family, Product2.Name, Quantity, UnitPrice, TotalPrice FROM OpportunityLineItems) FROM Opportunity LIMIT 1]){
            if(opp.OpportunityLineItems.size() > 0){
                proList.add(opp);
                opli.addAll(opp.OpportunityLineItems);
            }
        }
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c LIMIT 1];
        
        //List<AcctSeed__Project_Task__c> proPTList = [SELECT Id,RecordTypeId FROM AcctSeed__Project_Task__c LIMIT 1];
        List<AcctSeed__Ledger__c> ledger = [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        List<AcctSeed__GL_Account_Default__c> glAccountDefaultList = [SELECT Id, Name, AcctSeed__GL_Account__c, AcctSeed__Ledger__c, AcctSeed__GL_Account_Specification__c FROM AcctSeed__GL_Account_Default__c WHERE AcctSeed__GL_Account_Specification__c IN ('Revenue_GL_Account', 'Default_Credit_GL_Account_Revenue')];
        
        Id revenueGLAccId;
        Id creditGLAccId;
        for(AcctSeed__GL_Account_Default__c glAccDef : glAccountDefaultList){
        
            revenueGLAccId = (glAccDef.AcctSeed__GL_Account_Specification__c == 'Revenue_GL_Account') ? glAccDef.AcctSeed__GL_Account__c : null;
            creditGLAccId = (glAccDef.AcctSeed__GL_Account_Specification__c == 'Default_Credit_GL_Account_Revenue') ? glAccDef.AcctSeed__GL_Account__c : null;
        }
        
        AcctSeed__Billing_Format__c pdfFormat= new AcctSeed__Billing_Format__c(); 
        pdfFormat.AcctSeed__Default_Email_Template__c = 'Billing_Email_Template';
        pdfFormat.AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF';
        pdfFormat.AcctSeed__Type__c = 'Billing';
        pdfFormat.Name = 'Default Billing Product';
        
        insert pdfFormat;
            
         System.debug('opli::>'+opli);   
        if(proList.size() > 0 && opli.size() > 0 && accList.size() > 0){
            
            proList[0].AccountId = accList[0].Id;
            proList[0].StageName = 'Closed Won';
            update proList;
            
            List<AcctSeed__Accounting_Variable__c> acVar = [SELECT Id,AcctSeed__Active__c FROM AcctSeed__Accounting_Variable__c WHERE AcctSeed__Type__c = 'GL Account Variable 1' LIMIT 1];
            acVar[0].AcctSeed__Active__c = TRUE;
            update acVar;
            
            /*proPTList[0].AcctSeed__GL_Account_Variable_1__c = acVar[0].Id;
            update proPTList;
            */
            
            List<AcctSeed__Billing__c> billingList = new List<AcctSeed__Billing__c>{
                new AcctSeed__Billing__c(AcctSeed__Customer__c = accList[0].Id,AcctSeed__Billing_Format__c = pdfFormat.Id,AcctSeed__Ledger__c = ledger[0].Id,AcctSeed__Status__c = 'Approved',AcctSeed__Date__c = system.today(),AcctSeed__Billing_Cycle_End_Date__c = acpList[0].AcctSeed__End_Date__c,AcctSeed__Billing_Cycle_Start_Date__c = acpList[0].AcctSeed__Start_Date__c, AcctSeed__Opportunity__c=proList[0].Id),
                new AcctSeed__Billing__c(AcctSeed__Customer__c = accList[0].Id,AcctSeed__Billing_Format__c = pdfFormat.Id,AcctSeed__Ledger__c = ledger[0].Id,AcctSeed__Status__c = 'Approved',AcctSeed__Date__c = system.today().addDays(1),AcctSeed__Billing_Cycle_End_Date__c = acpList[0].AcctSeed__End_Date__c,AcctSeed__Billing_Cycle_Start_Date__c = acpList[0].AcctSeed__Start_Date__c, AcctSeed__Opportunity__c=proList[0].Id)
            };
            
            if(billingList.size() > 0){
                insert billingList;
           
                AcctSeed__Billing_Line__c billLine = new AcctSeed__Billing_Line__c();
                
                billLine.AcctSeed__Opportunity_Product_Id__c = opli[0].Product2.Id;
                billLine.AcctSeed__Hours_Units__c = 2;
                billLine.AcctSeed__Rate__c = 10;
                billLine.AcctSeed__Date__c = system.today();
                billLine.AcctSeed__Comment__c = 'Test';
                billLine.AcctSeed__Billing__c = billingList[0].Id;
                billLine.AcctSeed__Revenue_GL_Account__c = revenueGLAccId;
                
                insert billLine;
                
                if(billLine.Id != null){
                    List<AcctSeed__Billing_Line__c> billLineList = [SELECT Id,AcctSeed__GL_Account_Variable_1__c FROM AcctSeed__Billing_Line__c WHERE Id = :billLine.Id];
                    //System.assertEquals(acVar[0].Id,billLineList[0].AcctSeed__GL_Account_Variable_1__c);
                }
            }
        }
        List<AcctSeed__Billing__c> billingLists = [SELECT Id, AcctSeed__Accounting_Period__c, AcctSeed__Total__c, AcctSeed__Customer__c, Project__c FROM AcctSeed__Billing__c];        
        List<AcctSeed__Cash_Receipt__c> cashReciepts = new List<AcctSeed__Cash_Receipt__c>{
            new AcctSeed__Cash_Receipt__c(
                            AcctSeed__Accounting_Period__c=billingLists[0].AcctSeed__Accounting_Period__c, 
                            AcctSeed__Amount__c=billingLists[0].AcctSeed__Total__c, AcctSeed__Receipt_Date__c=System.today(),
                            AcctSeed__Payment_Reference__c='Test1234', AcctSeed__Account__c=billingLists[0].AcctSeed__Customer__c, AcctSeed__Credit_GL_Account__c = creditGLAccId
            )
        };
        insert cashReciepts;  
                
        
        AcctSeed.PostResult[] postResults = AcctSeed.CashReceiptPostService.postCashReceipts(cashReciepts);
        Test.startTest();
        List<Transaction__c> fundingList = [SELECT Id FROM Transaction__c WHERE Project__c = :billingLists[0].Project__c];
        System.assertEquals(0, fundingList.size());
        
        AcctSeed__Billing_Cash_Receipt__c billingCashReceipt = new AcctSeed__Billing_Cash_Receipt__c(AcctSeed__Billing__c=billingLists[0].Id, AcctSeed__Cash_Receipt__c=cashReciepts[0].Id,
                                                AcctSeed__Accounting_Period__c=billingLists[0].AcctSeed__Accounting_Period__c,
                                                AcctSeed__Applied_Amount__c=billingLists[0].AcctSeed__Total__c,AcctSeed__Applied_Date__c=System.today()); 
        insert billingCashReceipt; 
        
        fundingList = [SELECT Id, Transaction_Date__c FROM Transaction__c WHERE Project__c = :billingLists[0].Project__c];
        System.assertEquals(1, fundingList.size()); 
        System.assertEquals(fundingList[0].Transaction_Date__c, System.Today());
               
        Test.stopTest();
    }
}