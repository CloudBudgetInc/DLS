@isTest
public Class PaymentAndPaymentItemCreation_Test{
  
    @testsetup static void setup() {
        List<Payment_Item__c> contactAssignmentsList = TestClassUtil.createTestpaymentItems();
        List<AcctSeed__Project_Task__c> projTaskList1 = TestClassUtil.createTestProjectTask(); 
        TestClassUtil.createTestOppLineItem();
    } 
    
    static testmethod void paymentMethod1() {
                  
        List<Transaction__c> transactionList = new List<Transaction__c>();
        transactionList = [SELECT Opportunity__c,Contract__c,Transaction_Date__c,Project__c, Reviewed__c  FROM Transaction__c];
        List<Transaction__c> tranListNotInserted = new List<Transaction__c>{
            new Transaction__c(Opportunity__c = transactionList[0].Opportunity__c,Transaction_Date__c=System.today(),Project__c=transactionList[0].Project__c, Reviewed__c = False),
            new Transaction__c(Opportunity__c = transactionList[1].Opportunity__c,Transaction_Date__c=System.today(), Reviewed__c = True)
        };
        
        List<OpportunityLineItem> OLI = [SELECT Id, Name, PricebookEntry.Product2Id FROM OpportunityLineItem WHERE OpportunityId = :transactionList[1].Opportunity__c];
       
        List<Product2> prodList = [SELECT Id,Name FROM Product2];
        if(OLI != Null && OLI.size() > 0) {
            List<Payment_Item__c> paymentItemList = new List<Payment_Item__c>{
               new Payment_Item__c(Payment__c = transactionList[1].Id,Amount__c=100,Product__c = OLI[0].PricebookEntry.Product2Id, Opportunity_Product_Id__c = OLI[0].Id)
            };
            Insert paymentItemList;
        }
        
        ApexPages.StandardController sc1 = new ApexPages.standardController(tranListNotInserted[0]);
        PaymentAndPaymentItemCreationHandler pay1 = new PaymentAndPaymentItemCreationHandler(sc1);
        
        pay1.previousPage();
        
        ApexPages.StandardController sc2 = new ApexPages.standardController(tranListNotInserted[1]);
        PaymentAndPaymentItemCreationHandler pay2 = new PaymentAndPaymentItemCreationHandler(sc2);
                
        pay2.previousPage();
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.standardController(transactionList[0]);
        PaymentAndPaymentItemCreationHandler pay = new PaymentAndPaymentItemCreationHandler(sc);
        // Project is available in the Trancaction Record
        System.assertEquals(True, pay.hasProject); 

        ApexPages.StandardController sc3 = new ApexPages.standardController(transactionList[1]);
        
        PaymentAndPaymentItemCreationHandler pay3 = new PaymentAndPaymentItemCreationHandler(sc3);
        // Project is not available in the Trancaction Record
        System.assertEquals(False, pay3.hasProject); 

        pay.createPayment();
        apexpages.currentPage().getParameters().put('payIndex','0');
        pay.previousPage();
        pay.insertNewPayment();  
        Test.stopTest();
    }
    
    static testmethod void paymentMethod2() {
    
        List<Transaction__c> transactionList = new List<Transaction__c>();
        
        List<AcctSeed__Project_Task__c> projTaskList = [SELECT Id, Name, Total_Qty_Planned__c, Rate__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c = 'Language Training'];
        projTaskList[0].Name = 'Language Training - Tamil';
        projTaskList[0].Total_Qty_Planned__c = 50;
        projTaskList[0].Rate__c = 50;
        update projTaskList[0];
        
        transactionList = [SELECT Opportunity__c,Contract__c,Transaction_Date__c,Project__c, Reviewed__c  FROM Transaction__c];
        List<Transaction__c> tranListNotInserted = new List<Transaction__c>{
            new Transaction__c(Opportunity__c = transactionList[0].Opportunity__c,Transaction_Date__c=System.today(),Project__c=transactionList[0].Project__c, Reviewed__c = TRUE),
            new Transaction__c(Opportunity__c = transactionList[1].Opportunity__c,Transaction_Date__c=System.today(), Reviewed__c = True)
        };
        
        if(projTaskList != Null && projTaskList.size() > 0) {
        
            List<Payment_Item__c> paymentItemList = new List<Payment_Item__c>{
               new Payment_Item__c(Payment__c = transactionList[0].Id,Amount__c=100,Project_Task__c = projTaskList[0].Id)
            };
            Insert paymentItemList;
        }
        
        ApexPages.StandardController sc1 = new ApexPages.standardController(tranListNotInserted[0]);
        PaymentAndPaymentItemCreationHandler pay1 = new PaymentAndPaymentItemCreationHandler(sc1);
        
        pay1.previousPage();
        
        ApexPages.StandardController sc2 = new ApexPages.standardController(tranListNotInserted[1]);
        PaymentAndPaymentItemCreationHandler pay2 = new PaymentAndPaymentItemCreationHandler(sc2);
                
        pay2.previousPage();
       
        ApexPages.StandardController sc = new ApexPages.standardController(transactionList[0]);
        

        ApexPages.StandardController sc3 = new ApexPages.standardController(transactionList[1]);
        Test.startTest();
        PaymentAndPaymentItemCreationHandler pay = new PaymentAndPaymentItemCreationHandler(sc);
        // Project is available in the Trancaction Record
        System.assertEquals(True, pay.hasProject); 
        PaymentAndPaymentItemCreationHandler pay3 = new PaymentAndPaymentItemCreationHandler(sc3);
        // Project is not available in the Trancaction Record
        System.assertEquals(False, pay3.hasProject); 

        pay.createPayment();
        apexpages.currentPage().getParameters().put('payIndex','0');
        pay.previousPage();
        pay.insertNewPayment();
        Test.stopTest();
    }
    
    static testmethod void paymentMethod3() {
    
        List<Transaction__c> transactionList = new List<Transaction__c>();
        
        List<AcctSeed__Project_Task__c> projTaskList = [SELECT Id, Name, Total_Qty_Planned__c, Rate__c, Total_Amount_Paid__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c = 'Language Training'];
        projTaskList[0].Name = 'Language Training - Tamil';
        projTaskList[0].Total_Qty_Planned__c = 50;
        projTaskList[0].Rate__c = 50;
        projTaskList[0].Total_Amount_Paid__c = 5000;
        update projTaskList[0];
        
        transactionList = [SELECT Opportunity__c,Contract__c,Transaction_Date__c,Project__c, Reviewed__c  FROM Transaction__c];
        List<Transaction__c> tranListNotInserted = new List<Transaction__c>{
            new Transaction__c(Opportunity__c = transactionList[0].Opportunity__c,Transaction_Date__c=System.today(),Project__c=transactionList[0].Project__c, Reviewed__c = TRUE),
            new Transaction__c(Opportunity__c = transactionList[1].Opportunity__c,Transaction_Date__c=System.today(), Reviewed__c = True)
        };
        
        if(projTaskList != Null && projTaskList.size() > 0) {
        
            List<Payment_Item__c> paymentItemList = new List<Payment_Item__c>{
               new Payment_Item__c(Payment__c = transactionList[0].Id,Amount__c=100,Project_Task__c = projTaskList[0].Id, Quantity__c = 100)
            };
        }       
        ApexPages.StandardController sc = new ApexPages.standardController(transactionList[0]);
        PaymentAndPaymentItemCreationHandler pay = new PaymentAndPaymentItemCreationHandler(sc);
        // Project is available in the Trancaction Record
        System.assertEquals(True, pay.hasProject); 

        pay.createPayment();
        apexpages.currentPage().getParameters().put('payIndex','0');
        pay.previousPage();
        pay.insertNewPayment();  
    }
    
    static testmethod void paymentMethod4() {
    
        List<Transaction__c> transactionList = new List<Transaction__c>();
        Account acc= new Account(Name='DLI-W - LT');
        insert acc;
        Id DLIWLTProjectRecordTypeId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        List<AcctSeed__Project_Task__c> projTaskList = [SELECT Id, Name, AcctSeed__Project__c, Total_Qty_Planned__c, Rate__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c = 'Language Training'];
        projTaskList[0].Name = 'Language Training - Tamil';
        projTaskList[0].Total_Qty_Planned__c = 50;
        projTaskList[0].Rate__c = 50;
        update projTaskList[0];
        
        List<Contract> contracts = [SELECT Id, APXT_Redlining__Contract_Family_Parent__c FROM Contract];
        contracts[1].APXT_Redlining__Contract_Family_Parent__c = contracts[0].Id;
        contracts[1].Name = 'contract 1';
        contracts[0].Name = 'contract 1';
        update contracts;
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Id=projTaskList[0].AcctSeed__Project__c, AcctSeed__Account__c=acc.Id,RecordTypeId=DLIWLTProjectRecordTypeId, Contract__c=contracts[1].Id);
        update proj;
        
        transactionList = [SELECT Opportunity__c,Contract__c,Transaction_Date__c,Project__c, Reviewed__c  FROM Transaction__c];
        List<Transaction__c> tranListNotInserted = new List<Transaction__c>{
            new Transaction__c(Opportunity__c = transactionList[0].Opportunity__c,Transaction_Date__c=System.today(),Project__c=transactionList[0].Project__c, Reviewed__c = TRUE),
            new Transaction__c(Opportunity__c = transactionList[1].Opportunity__c,Transaction_Date__c=System.today(), Reviewed__c = True)
        };
        
        if(projTaskList != Null && projTaskList.size() > 0) {
        
            List<Payment_Item__c> paymentItemList = new List<Payment_Item__c>{
               new Payment_Item__c(Payment__c = transactionList[0].Id,Amount__c=100,Project_Task__c = projTaskList[0].Id)
            };
            Insert paymentItemList;
        }
        
        Test.startTest();
        
        ApexPages.StandardController sc1 = new ApexPages.standardController(tranListNotInserted[0]);
        PaymentAndPaymentItemCreationHandler pay1 = new PaymentAndPaymentItemCreationHandler(sc1);
        
        pay1.previousPage();
        
        ApexPages.StandardController sc2 = new ApexPages.standardController(tranListNotInserted[1]);
        PaymentAndPaymentItemCreationHandler pay2 = new PaymentAndPaymentItemCreationHandler(sc2);
                
        pay2.previousPage();
        
        List<CLIN__c> clins = [SELECT Id FROM CLIN__c WHERE Contract__c = :contracts[0].Id];
        clins[0].CLIN_Start_Date__c = System.today().addDays(-1);
        clins[0].CLIN_End_Date__c = System.today().addDays(10);
        update clins[0];
        
        ApexPages.StandardController sc = new ApexPages.standardController(transactionList[0]);
        PaymentAndPaymentItemCreationHandler pay = new PaymentAndPaymentItemCreationHandler(sc);
        // Project is available in the Trancaction Record
        System.assertEquals(True, pay.hasProject); 

        ApexPages.StandardController sc3 = new ApexPages.standardController(transactionList[1]);
        
        PaymentAndPaymentItemCreationHandler pay3 = new PaymentAndPaymentItemCreationHandler(sc3);
        // Project is not available in the Trancaction Record
        System.assertEquals(False, pay3.hasProject); 
        pay.createChildContract();
        pay.paymentItemList[0].parentClin = clins[0].Id;
        pay.paymentItemList[1].payItem.Rate_per_Quantity__c = 1;
        pay.paymentItemList[1].payItem.Quantity__c = 1;
        System.debug('paymentItemList::'+pay.paymentItemList);
        System.debug('newPaymentItemList::'+pay.newPaymentItemList);
        pay.createPayment();
        apexpages.currentPage().getParameters().put('payIndex','0');
        pay.previousPage();
        pay.insertNewPayment();  
        Test.stopTest();
    }
}