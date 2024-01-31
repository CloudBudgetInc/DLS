//Last Modified by Ilavarasan
@isTest
private class OpportunityLineItem_Trigger_Test{

    @testsetup static void setup() {
        
        Test.StartTest();
            List<System_Values__c> sysVal = TestClassUtil.createSystemValues();
            List<OpportunityLineItem> opliList = TestClassUtil.createTestOppLineItem();
        Test.stopTest();
        List<Contract> contracts = TestClassUtil.createTestContracts();
        List<AcctSeed__Accounting_Period__c> acpList = TestClassUtil.createTestAccountingPeriod();
        List<AcctSeed__Ledger__c> ledger = TestClassUtil.createTestLedger();
        
    }     
    //for update contact assignment object using trigger while deleting an opportunity line item record
    static testmethod void testMethod1(){
        
        List<Account> accList = [SELECT Id, Name FROM Account LIMIT 2];
        
        List<RecordType> conAssignRTList = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Contact_Assignments__c' AND DeveloperName = 'Student'];
        
        List<Opportunity> oppList = [SELECT Id,Name,Start_Date__c,End_Date__c FROM Opportunity  WHERE RecordType.DeveloperName = 'New_Classes_Opportunities'];
        
        Test.startTest();
        
        List<Contact> contactList = new List<Contact>{
            new Contact(LastName = 'Test Student 1', AccountId = accList[0].Id,Email = 'test1@gmail.com'),
            new Contact(LastName = 'Test Student 2', AccountId = accList[0].Id,Email = 'test2@gmail.com'),
            new Contact(LastName = 'Test Student 3', AccountId = accList[1].Id,Email = 'test3@gmail.com')
        };
        
        insert contactList;
        List<OpportunityLineItem> opliList = [SELECT Id,OpportunityId FROM OpportunityLineItem LIMIT 2];
        if(conAssignRTList != null && oppList != null && contactList != null && conAssignRTList.size() > 0 && oppList.size() > 0 && contactList.size() > 0){
            
            List<Contact_Assignments__c> conAssignList = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(Candidate_Name__c = contactList[0].Id,RecordTypeId = conAssignRTList[0].Id,Opportunity_Name__c = oppList[0].Id,Status__c = 'Active',Start_Date__c = oppList[0].Start_Date__c,End_Date__c = oppList[0].End_Date__c,Opportunity_Product_Id__c = opliList[0].Id),
                new Contact_Assignments__c(Candidate_Name__c = contactList[1].Id,RecordTypeId = conAssignRTList[0].Id,Opportunity_Name__c = oppList[0].Id,Status__c = 'Planned',Start_Date__c = oppList[0].Start_Date__c,End_Date__c = oppList[0].End_Date__c,Opportunity_Product_Id__c = opliList[0].Id),
                new Contact_Assignments__c(Candidate_Name__c = contactList[2].Id,RecordTypeId = conAssignRTList[0].Id,Opportunity_Name__c = oppList[0].Id,Status__c = 'Active',Start_Date__c = oppList[0].Start_Date__c,End_Date__c = oppList[0].End_Date__c,Opportunity_Product_Id__c = opliList[0].Id)
            };
            insert conAssignList;
        }
        List<OpportunityLineItem> opliList1 = [SELECT Id,OpportunityId FROM OpportunityLineItem LIMIT 10];
        Delete opliList1;
        
        Test.stopTest();
        
        List<Contact_Assignments__c> caList = [SELECT Id, Opportunity_Product_Id__c FROM Contact_Assignments__c LIMIT 2];
        System.AssertEquals(NULL,caList[0].Opportunity_Product_Id__c);
    }
    //for calculate quantity or total based on product family while insert or updating an record in opportuntiy line item
    static testmethod void testMethod2() {
        
        List<PricebookEntry> priceBookEntryList = [SELECT Id,product2.Family FROM PricebookEntry LIMIT 10];
        List<Product2> productList = [SELECT Id,Family FROM Product2 LIMIT 10];
        Map<String,Id> productMap = new Map<String,Id>();
        Map<String,Id> priceBookMap = new Map<String,Id>();
        for(Product2 pro : productList){
            
            productMap.put(pro.Family,pro.Id);
        }
        for(PricebookEntry price : priceBookEntryList){
            
            priceBookMap.put(price.product2.Family,price.Id);
        }
        System.debug('::::::::productMap'+productMap);
        List<Opportunity> oppList = [SELECT Id,Name,Start_Date__c,End_Date__c FROM Opportunity  WHERE RecordType.DeveloperName = 'New_Classes_Opportunities'];
        List<CLIN__c> clinList = [SELECT Id FROM CLIN__c LIMIT 2];
        List<Language__c> langList = [SELECT Id FROM Language__c LIMIT 2];
        List<OpportunityLineItem> opliList = new List<OpportunityLineItem> {
            new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = priceBookMap.get('Material Budget'), Quantity = 1, UnitPrice = 2100,CLIN_LU__c = clinList[0].Id, Language__c = langList[0].Id, Product2Id=productMap.get('Material Budget')),
            new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = priceBookMap.get('Material Budget'), Quantity = 1, UnitPrice = 200,CLIN_LU__c = clinList[0].Id, Language__c = langList[1].Id, Product2Id=productMap.get('Material Budget')),
            new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = priceBookMap.get('ODC'), Quantity = 1, UnitPrice = 200,CLIN_LU__c = clinList[1].Id, Language__c = langList[1].Id, Product2Id=productMap.get('ODC')),
            new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = priceBookMap.get('Travel'), Quantity = 1, UnitPrice = 200,CLIN_LU__c = clinList[1].Id, Language__c = langList[1].Id, Product2Id=productMap.get('Travel')),
            new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = priceBookMap.get('Language Training'), Quantity = 1, UnitPrice = 200,CLIN_LU__c = clinList[1].Id, Language__c = langList[1].Id, Product2Id=productMap.get('Language Training'))};
        insert opliList;
        List<OpportunityLineItem> opliListToUpdate = [SELECT Id,Name,CLIN_LU__c,Product2.Family,UnitPrice FROM OpportunityLineItem WHERE CLIN_LU__c != null LIMIt 5];
        System.debug('opliListToUpdate ::::'+opliListToUpdate);
        opliListToUpdate[0].CLIN_LU__c = null;
        system.debug('::::clinList'+clinList);
        
        opliListToUpdate[1].CLIN_LU__c = clinList[0].Id; 
        update opliListToUpdate;
        List<Opportunity> oppList2 = [SELECT Id,Name,Start_Date__c,End_Date__c,Materials_CLIN__c FROM Opportunity  WHERE Id = :oppList[0].Id];
        System.AssertEquals('2a: ($200.00) \n2a: ($2100.00)',oppList2[0].Materials_CLIN__c);
    }
    //for update the Billing Line when the Qty or UnitPrice is updated in the OPLI
    static testmethod void testMethod3(){
        Date currentMonthStartDt = System.Date.today().toStartOfMonth(); 
        Date currentMonthEndDt =  currentMonthStartDt.addMonths(1).addDays(-1);
        
        List<AcctSeed__Accounting_Period__c> acpList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c = :currentMonthStartDt AND AcctSeed__End_Date__c = :currentMonthEndDt];
        List<OpportunityLineItem> opli = [SELECT Id,Product2Id,OpportunityId FROM OpportunityLineItem LIMIT 2];
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        List<AcctSeed__Ledger__c> ledger =  [SELECT Id FROM AcctSeed__Ledger__c LIMIT 1];
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id FROM AcctSeed__GL_Account__c WHERE AcctSeed__Bank__c = FALSE LIMIT 1];
        List<AcctSeed__Billing_Line__c> billingRecLineList = new List<AcctSeed__Billing_Line__c>();
        
        Test.StartTest(); 
        
        AcctSeed__Billing_Format__c pdfFormat= new AcctSeed__Billing_Format__c(); 
        pdfFormat.AcctSeed__Default_Email_Template__c = 'Billing_Email_Template';
        pdfFormat.AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF';
        pdfFormat.AcctSeed__Type__c = 'Billing';
        pdfFormat.Name = 'Default Billing Product';
        
        insert pdfFormat;       
        
        List<AcctSeed__Billing__c> billingRecList = new List<AcctSeed__Billing__c> {
            new AcctSeed__Billing__c(AcctSeed__Opportunity__c = opli[0].OpportunityId,AcctSeed__Accounting_Period__c = acpList[0].Id,AcctSeed__Billing_Cycle_Start_Date__c = acpList[0].AcctSeed__Start_Date__c,AcctSeed__Billing_Cycle_End_Date__c = acpList[0].AcctSeed__End_Date__c,AcctSeed__Customer__c = accList[0].Id,AcctSeed__Ledger__c = ledger[0].Id,AcctSeed__Billing_Format__c = pdfFormat.Id)
          };
          insert billingRecList;
        
        
        if(billingRecList.size() > 0 && billingRecList[0].Id != null){
            
            billingRecLineList = new List<AcctSeed__Billing_Line__c> {
                new AcctSeed__Billing_Line__c(AcctSeed__Billing__c = billingRecList[0].Id,AcctSeed__Opportunity_Product_Id__c = opli[0].Id,AcctSeed__Revenue_GL_Account__c = glAccList[0].Id,AcctSeed__Rate__c = 20,AcctSeed__Hours_Units__c = 20),
                new AcctSeed__Billing_Line__c(AcctSeed__Billing__c = billingRecList[0].Id,AcctSeed__Opportunity_Product_Id__c = opli[1].Id,AcctSeed__Revenue_GL_Account__c = glAccList[0].Id,AcctSeed__Rate__c = 10,AcctSeed__Hours_Units__c = 10)
              };
              insert billingRecLineList;
        }
        
        Test.StopTest();
        
        if(opli.size() > 0){
            opli[0].Quantity = 30;
            opli[0].UnitPrice = 25;
            
            opli[1].Quantity = 11;
            opli[1].UnitPrice = 17;
            
            update opli; 
            
            if(billingRecLineList.size() > 0 && billingRecLineList[0].Id != null){
                
                List<AcctSeed__Billing_Line__c> billLine = [SELECT Id,AcctSeed__Rate__c,AcctSeed__Hours_Units__c FROM AcctSeed__Billing_Line__c WHERE Id = :billingRecLineList[0].Id];
                
                if(billLine.size() > 0){
                    System.assertEquals(opli[0].Quantity,Integer.valueOf(billLine[0].AcctSeed__Hours_Units__c));
                    System.assertEquals(opli[0].UnitPrice,Integer.valueOf(billLine[0].AcctSeed__Rate__c));
                }
            }                      
        }
    } 
    static testmethod void testMethod4(){
        List<Account> accList = new List<Account> {
            new Account(Name = 'DODA')
        };
        insert accList;
        
        Id dodaOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('ODNI_CLP_Opportunities').getRecordTypeId();
        List<Opportunity> oppList = new List<Opportunity> { 
            new Opportunity(AccountId=accList[0].Id, Name='Test Opp', Language__c='English', CloseDate=System.Today().addDays(30), StageName='Active', Start_Date__c = System.today(),End_Date__c = System.today().addDays(60), RecordTypeId = dodaOppRTId)
        };
        Insert oppList;
        
        List<Product2> prodList = new List<Product2> {
            new Product2(Name = 'Language Training- English', Description = 'Test Desc1', productCode = 'Test Code1', isActive = TRUE,Family='Language Training'),
            new Product2(Name = 'Language Materials', Description = 'Test Desc2', productCode = 'Test Code2', isActive = TRUE,Family='Material Budget')
        };
        insert prodList;
        Test.startTest();
            
            List<System_Values__c> sysVal = [SELECT Id, Name FROM System_Values__c WHERE Name IN ('DODA CLIN for LT & Prep Time PTs', 'DODA CLIN for Material PTs')];
            List<PricebookEntry> pbeList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 130),
                 new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prodList[1].Id, IsActive = TRUE, UnitPrice = 100)
            };
            insert pbeList;
            
            List<Language__c> langList = new List<Language__c> {
                new Language__c(Name = 'English')
            };
            insert langList;
            
            List<Contract> contracts = [SELECT Id, Name FROM Contract LIMIT 1];
            List<CLIN__c> clins = new List<CLIN__c>{
                new CLIN__c(Name = '00010- (BY)', Contract__c = contracts[0].Id, CLIN_Name__c = 'DODA CLIN TEST1'), 
                new CLIN__c(Name = '00020- (BY)', Contract__c = contracts[0].Id, CLIN_Name__c = 'DODA CLIN TEST2')
            };
            insert clins;
            
            List<OpportunityLineItem> opliList = new List<OpportunityLineItem> {
                new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = pbeList[0].Id,Quantity = 2, UnitPrice = 200, Language__c = langList[0].Id),
                new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = pbeList[1].Id,Quantity = 1, UnitPrice = 300, Language__c = langList[0].Id)
            };
            insert opliList;
            
            List<OpportunityLineItem> opliRec = [SELECT Id, CLIN_LU__r.name FROM OpportunityLineItem WHERE Product2.Family = 'Language Training' AND Id IN :opliList];
            //System.assertEquals('00010- (BY)', opliRec[0].CLIN_LU__r.name);
        Test.stopTest();
    }
}