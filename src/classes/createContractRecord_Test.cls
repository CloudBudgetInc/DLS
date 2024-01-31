@isTest
private class createContractRecord_Test {
    
    @testSetup static void setup(){
        List<Opportunity> opplist = TestClassUtil.createTestOpportunities();
        List<Contact> conList = TestClassUtil.createTestContacts();
    }
    
    // For creating the contract Record
    static testMethod void testMyWebSvc1() {
        
        Opportunity opp = new Opportunity();
        Id contrId = createContractRecord.createContractRec(opp.Id);
        
        List<Contract> contrListIn = [SELECT Id, Name FROM Contract];
        if(contrListIn.size() > 0)
            System.assertEquals(contrListIn[0].Id, contrId);
    }
    
    // For creating the contract Record
    static testMethod void testMyWebSvc2() {
        
        List<Opportunity> oppList = [SELECT Id,Name,StageName FROM Opportunity LIMIT 5];
        Id contrId = createContractRecord.createContractRec(oppList[0].Id);
        
        List<Contract> contrListIn = [SELECT Id, Name FROM Contract];
        if(contrListIn.size() > 0)
            System.assertEquals(contrListIn[0].Id, contrId);
    }
    
    // For Creating the OPLI records - To display the error message when the recordType is not equals to 'ODNI_CLP_Opportunities'
    static testMethod void testCreateOpliRec1() {
        
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        
         if(oppList.size() > 0) {
            String msg = createContractRecord.createOPLIRecord(oppList[0].Id);
            if(msg != null && msg != '')
                System.assert(msg.contains('only can be created for DODA Opportunities'));
         }
    }
    
    // For Creating the OPLI records - To display the error message when the recordType is 'ODNI_CLP_Opportunities' and without Program Iteration
    static testMethod void testCreateOpliRec2() {
            
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'ODNI_CLP_Opportunities'];
        
        if(oppList.size() > 0 && rType.size() > 0) {
                
            oppList[0].RecordTypeId = rType[0].Id;
            update oppList;
            
            String msg = createContractRecord.createOPLIRecord(oppList[0].Id);
            if(msg != null && msg != '')
                System.assert(msg.contains('select a Iteration Program'));
        }
    }
    
    // For Creating the OPLI records - To display the error message When the opportunity without students contact assignment
    static testMethod void testCreateOpliRec3() {
            
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Opportunity', 'Program_Iteration__c') AND DeveloperName IN ('ODNI_CLP_Opportunities', 'JMAS_Iteration')];
        
        if(oppList.size() > 0 && rType.size() > 0) {
            
            String oppRt, proItJMASRt;
            
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'ODNI_CLP_Opportunities') oppRt = rt.Id;
                if(rt.DeveloperName == 'JMAS_Iteration') proItJMASRt = rt.Id;
            }
            
            List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
                new Program_Iteration__c(Name = 'proItr 1', Total_LT_Class_Hours__c = 85, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), RecordTypeId = proItJMASRt, Final_Progress_Due_Date__c = System.today().addDays(3))
            };
            insert proItrList;
            
            oppList[0].Program_Iteration__c = proItrList[0].Id;
            oppList[0].Project_Type__c = 'JMAS';
            oppList[0].RecordTypeId = oppRt;
            update oppList;
            
            String msg = createContractRecord.createOPLIRecord(oppList[0].Id);
            if(msg != null && msg != '')
                System.assert(msg.contains('add student contact assignments'));
            
        }
    }
    
    // For Creating the OPLI records - To display the error message when the opportunity is without language
    static testMethod void testCreateOpliRec4() {
            
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Opportunity', 'Program_Iteration__c', 'Contact_Assignments__c') AND DeveloperName IN ('ODNI_CLP_Opportunities', 'JMAS_Iteration', 'Student')];
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        if(oppList.size() > 0 && rType.size() > 0 && conList.size() > 0) {
            
            String oppRt, proItJMASRt,conAssRt;
            
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'ODNI_CLP_Opportunities') oppRt = rt.Id;
                if(rt.DeveloperName == 'JMAS_Iteration') proItJMASRt = rt.Id;
                if(rt.DeveloperName == 'Student') conAssRt = rt.Id;
            }
            
            List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
                new Program_Iteration__c(Name = 'proItr 1', Total_LT_Class_Hours__c = 50, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), RecordTypeId = proItJMASRt, Final_Progress_Due_Date__c = System.today().addDays(3))
            };
            insert proItrList;
            
            oppList[0].Program_Iteration__c = proItrList[0].Id;
            oppList[0].Project_Type__c = 'JMAS';
            oppList[0].RecordTypeId = oppRt;
            update oppList;
            
            Test.startTest();
            
            List<Contact_Assignments__c> conAssList = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Candidate_Name__c=conList[0].Id,RecordTypeId=conAssRt,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=oppList[0].Id,Status__c = 'Active')
            };
            insert conAssList;
           
            String msg = createContractRecord.createOPLIRecord(oppList[0].Id);
            if(msg != null && msg != '')
                System.assert(msg.contains('Please select a Langauge'));
                
            Test.stopTest();
        }
    }
    
    // For Creating the OPLI records - Price Book Entry with the Product name as 'Language Materials'
    static testMethod void testCreateOpliRec5() {
            
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Opportunity', 'Program_Iteration__c', 'Contact_Assignments__c') AND DeveloperName IN ('ODNI_CLP_Opportunities', 'JMAS_Iteration', 'Student')];
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        if(oppList.size() > 0 && rType.size() > 0 && conList.size() > 0) {
            
            List<Language__c> LangList = new List<Language__c> {
                new Language__c(Name ='English')
            };
            insert LangList;
            
            String oppRt, proItJMASRt,conAssRt;
            
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'ODNI_CLP_Opportunities') oppRt = rt.Id;
                if(rt.DeveloperName == 'JMAS_Iteration') proItJMASRt = rt.Id;
                if(rt.DeveloperName == 'Student') conAssRt = rt.Id;
            }
            
            List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
                new Program_Iteration__c(Name = 'proItr 1', Total_LT_Class_Hours__c = 20, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), RecordTypeId = proItJMASRt, Final_Progress_Due_Date__c = System.today().addDays(3))
            };
            insert proItrList;
            
            oppList[0].Program_Iteration__c = proItrList[0].Id;
            oppList[0].Project_Type__c = 'SLP-FT';
            oppList[0].RecordTypeId = oppRt;
            oppList[0].Language_LU__c = LangList[0].Id;
            update oppList;
            
            Test.startTest();
            
            List<Contact_Assignments__c> conAssList = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Candidate_Name__c=conList[0].Id,RecordTypeId=conAssRt,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=oppList[0].Id,Status__c = 'Active')
            };
            insert conAssList;
           
            Test.stopTest();
            
            List<Product2> prodList = new List<Product2> {
                new Product2(Name = 'Language Materials', Description = 'Test Desc', productCode = 'Test Code', isActive = TRUE,Family='Language Training')
            };
            insert prodList;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 130)
            };
            insert pbeList;
            
            List<PriceBook2> pbList = new List<PriceBook2> {
                new PriceBook2(Name = 'GSA Language Training Price Book', IsActive = True)
            };
            insert pbList;
            
            List<PricebookEntry> pbeCusList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = pbList[0].Id, Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 100)
            };
            insert pbeCusList;
            
            String msg = createContractRecord.createOPLIRecord(oppList[0].Id);
            if(msg != null && msg != '')
                System.assert(msg.contains('Success'));
        }
    } 
   
    // For Creating the OPLI records - Price Book Entry with the Product name as 'Language Training- Preparation' AND Program Iteration RecordType equal to 'SLP_Iteration'
    static testMethod void testCreateOpliRec6() {
            
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Opportunity', 'Program_Iteration__c', 'Contact_Assignments__c') AND DeveloperName IN ('ODNI_CLP_Opportunities', 'SLP_Iteration', 'Student')];
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        if(oppList.size() > 0 && rType.size() > 0 && conList.size() > 0) {
            
            List<Language__c> LangList = new List<Language__c> {
                new Language__c(Name ='English')
            };
            insert LangList;
            
            String oppRt, proItSLPRt,conAssRt;
            
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'ODNI_CLP_Opportunities') oppRt = rt.Id;
                if(rt.DeveloperName == 'SLP_Iteration') proItSLPRt = rt.Id;
                if(rt.DeveloperName == 'Student') conAssRt = rt.Id;
            }
            
            List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
                new Program_Iteration__c(Name = 'proItr 1', Total_LT_Class_Hours__c = 20, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), RecordTypeId = proItSLPRt, Final_Progress_Due_Date__c = System.today().addDays(3), Midterm_Progress_Due_Date__c= System.today().addDays(2))
            };
            insert proItrList;
            
            oppList[0].Program_Iteration__c = proItrList[0].Id;
            oppList[0].RecordTypeId = oppRt;
            oppList[0].Language_LU__c = LangList[0].Id;
            oppList[0].Project_Type__c = 'IND';
            update oppList;
            
            Test.startTest();
            
            List<Contact_Assignments__c> conAssList = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Candidate_Name__c=conList[0].Id,RecordTypeId=conAssRt,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=oppList[0].Id,Status__c = 'Active')
            };
            insert conAssList;
            
            Test.stopTest();
            
            List<Product2> prodList = new List<Product2> {
                new Product2(Name = 'Language Training- Preparation', Description = 'Test Desc', productCode = 'Test Code', isActive = TRUE,Family='Language Training')
            };
            insert prodList;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 130)
            };
            insert pbeList;
            
            List<PriceBook2> pbList = new List<PriceBook2> {
                new PriceBook2(Name = 'GSA Language Training Price Book', IsActive = True)
            };
            insert pbList;
            
            List<PricebookEntry> pbeCusList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = pbList[0].Id, Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 100)
            };
            insert pbeCusList;
           
            String msg = createContractRecord.createOPLIRecord(oppList[0].Id);
            if(msg != null && msg != '')
                System.assertEquals(msg,'Success');
        }
    }
    
    static testMethod void testCreateOpliRec6a() {
            
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Opportunity', 'Program_Iteration__c', 'Contact_Assignments__c') AND DeveloperName IN ('ODNI_CLP_Opportunities', 'SLP_Iteration', 'Student')];
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        if(oppList.size() > 0 && rType.size() > 0 && conList.size() > 0) {
            Account a = new Account(Name = 'DODA');
            insert a;
            
            List<Language__c> LangList = new List<Language__c> {
                new Language__c(Name ='English')
            };
            insert LangList;
            
            String oppRt, proItSLPRt,conAssRt;
            
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'ODNI_CLP_Opportunities') oppRt = rt.Id;
                if(rt.DeveloperName == 'SLP_Iteration') proItSLPRt = rt.Id;
                if(rt.DeveloperName == 'Student') conAssRt = rt.Id;
            }
            
            List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
                new Program_Iteration__c(Name = 'proItr 1', Total_LT_Class_Hours__c = 20, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), RecordTypeId = proItSLPRt, Final_Progress_Due_Date__c = System.today().addDays(3), Midterm_Progress_Due_Date__c= System.today().addDays(2))
            };
            insert proItrList;
            
            oppList[0].Program_Iteration__c = proItrList[0].Id;
            oppList[0].RecordTypeId = oppRt;
            oppList[0].Language_LU__c = LangList[0].Id;
            oppList[0].Project_Type__c = 'IND';
            oppList[0].AccountId = a.Id;
            update oppList;
            
            Test.startTest();
            
            List<Contact_Assignments__c> conAssList = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Candidate_Name__c=conList[0].Id,RecordTypeId=conAssRt,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=oppList[0].Id,Status__c = 'Active')
            };
            insert conAssList;
            
            Test.stopTest();
            
            List<Product2> prodList = new List<Product2> {
                new Product2(Name = 'Language Training- English', Description = 'Test Desc', productCode = 'Test Code', isActive = TRUE,Family='Language Training')
            };
            insert prodList;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 130)
            };
            insert pbeList;
            
            List<PriceBook2> pbList = new List<PriceBook2> {
                new PriceBook2(Name = 'DODA Price Book', IsActive = True)
            };
            insert pbList;
            
            List<PricebookEntry> pbeCusList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = pbList[0].Id, Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 100)
            };
            insert pbeCusList;
           
            String msg = createContractRecord.createOPLIRecord(oppList[0].Id);
            if(msg != null && msg != '')
                System.assertEquals(msg,'Success');
        }
    } 
    
    static testMethod void testCreateOpliRec6b() {
            
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Opportunity', 'Program_Iteration__c', 'Contact_Assignments__c') AND DeveloperName IN ('ODNI_CLP_Opportunities', 'SLP_Iteration', 'Student')];
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        if(oppList.size() > 0 && rType.size() > 0 && conList.size() > 0) {
            Account a = new Account(Name = 'DODA');
            insert a;
            
            List<Language__c> LangList = new List<Language__c> {
                new Language__c(Name ='English')
            };
            insert LangList;
            
            String oppRt, proItSLPRt,conAssRt;
            
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'ODNI_CLP_Opportunities') oppRt = rt.Id;
                if(rt.DeveloperName == 'SLP_Iteration') proItSLPRt = rt.Id;
                if(rt.DeveloperName == 'Student') conAssRt = rt.Id;
            }
            
            List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
                new Program_Iteration__c(Name = 'proItr 1', Total_LT_Class_Hours__c = 20, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), RecordTypeId = proItSLPRt, Final_Progress_Due_Date__c = System.today().addDays(3), Midterm_Progress_Due_Date__c= System.today().addDays(2))
            };
            insert proItrList;
            
            oppList[0].Program_Iteration__c = proItrList[0].Id;
            oppList[0].RecordTypeId = oppRt;
            oppList[0].Language_LU__c = LangList[0].Id;
            oppList[0].Project_Type__c = 'IND';
            oppList[0].AccountId = a.Id;
            update oppList;
            
            Test.startTest();
            
            List<Contact_Assignments__c> conAssList = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Candidate_Name__c=conList[0].Id,RecordTypeId=conAssRt,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=oppList[0].Id,Status__c = 'Active')
            };
            insert conAssList;
            
            Test.stopTest();
            
            List<Product2> prodList = new List<Product2> {
                new Product2(Name = 'Language Training- Preparation', Description = 'Test Desc', productCode = 'Test Code', isActive = TRUE,Family='Language Training')
            };
            insert prodList;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 130)
            };
            insert pbeList;
            
            List<PriceBook2> pbList = new List<PriceBook2> {
                new PriceBook2(Name = 'DODA Price Book', IsActive = True)
            };
            insert pbList;
            
            List<PricebookEntry> pbeCusList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = pbList[0].Id, Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 100)
            };
            insert pbeCusList;
           
            String msg = createContractRecord.createOPLIRecord(oppList[0].Id);
            if(msg != null && msg != '')
                System.assertEquals(msg,'Success');
        }
    }
    
    static testMethod void testCreateOpliRec6c() {
            
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Opportunity', 'Program_Iteration__c', 'Contact_Assignments__c') AND DeveloperName IN ('ODNI_CLP_Opportunities', 'SLP_Iteration', 'Student')];
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        if(oppList.size() > 0 && rType.size() > 0 && conList.size() > 0) {
            Account a = new Account(Name = 'DODA');
            insert a;
            
            List<Language__c> LangList = new List<Language__c> {
                new Language__c(Name ='English')
            };
            insert LangList;
            
            String oppRt, proItSLPRt,conAssRt;
            
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'ODNI_CLP_Opportunities') oppRt = rt.Id;
                if(rt.DeveloperName == 'SLP_Iteration') proItSLPRt = rt.Id;
                if(rt.DeveloperName == 'Student') conAssRt = rt.Id;
            }
            
            List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
                new Program_Iteration__c(Name = 'proItr 1', Total_LT_Class_Hours__c = 20, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), RecordTypeId = proItSLPRt, Final_Progress_Due_Date__c = System.today().addDays(3), Midterm_Progress_Due_Date__c= System.today().addDays(2))
            };
            insert proItrList;
            
            oppList[0].Program_Iteration__c = proItrList[0].Id;
            oppList[0].RecordTypeId = oppRt;
            oppList[0].Language_LU__c = LangList[0].Id;
            oppList[0].Project_Type__c = 'IND';
            oppList[0].AccountId = a.Id;
            update oppList;
            
            Test.startTest();
            
            List<Contact_Assignments__c> conAssList = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Candidate_Name__c=conList[0].Id,RecordTypeId=conAssRt,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=oppList[0].Id,Status__c = 'Active')
            };
            insert conAssList;
            
            Test.stopTest();
            
            List<Product2> prodList = new List<Product2> {
                new Product2(Name = 'Language Materials', Description = 'Test Desc', productCode = 'Test Code', isActive = TRUE,Family='Language Training')
            };
            insert prodList;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 130)
            };
            insert pbeList;
            
            List<PriceBook2> pbList = new List<PriceBook2> {
                new PriceBook2(Name = 'DODA Price Book', IsActive = True)
            };
            insert pbList;
            
            List<PricebookEntry> pbeCusList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = pbList[0].Id, Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 100)
            };
            insert pbeCusList;
           
            String msg = createContractRecord.createOPLIRecord(oppList[0].Id);
            if(msg != null && msg != '')
                System.assertEquals(msg,'Success');
        }
    }
    
    // For Creating the OPLI records - Price Book Entry with the Product name equal to 'Language Training- '+Opportunity Language name
    static testMethod void testCreateOpliRec7() {
            
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Opportunity', 'Program_Iteration__c', 'Contact_Assignments__c') AND DeveloperName IN ('ODNI_CLP_Opportunities', 'JMAS_Iteration', 'Student')];
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        if(oppList.size() > 0 && rType.size() > 0 && conList.size() > 0) {
            
            List<Language__c> LangList = new List<Language__c> {
                new Language__c(Name ='English')
            };
            insert LangList;
            
            String oppRt, proItJMASRt,conAssRt;
            
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'ODNI_CLP_Opportunities') oppRt = rt.Id;
                if(rt.DeveloperName == 'JMAS_Iteration') proItJMASRt = rt.Id;
                if(rt.DeveloperName == 'Student') conAssRt = rt.Id;
            }
            
            List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
                new Program_Iteration__c(Name = 'proItr 1', Total_LT_Class_Hours__c = 20, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), RecordTypeId = proItJMASRt, Final_Progress_Due_Date__c = System.today().addDays(3))
            };
            insert proItrList;
            
            oppList[0].Program_Iteration__c = proItrList[0].Id;
            oppList[0].Project_Type__c = 'SLP-FT';
            oppList[0].RecordTypeId = oppRt;
            oppList[0].Language_LU__c = LangList[0].Id;
            update oppList;
            
            Test.startTest();
            
            List<Contact_Assignments__c> conAssList = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Candidate_Name__c=conList[0].Id,RecordTypeId=conAssRt,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=oppList[0].Id,Status__c = 'Active')
            };
            insert conAssList;
           
            Test.stopTest();
            
            List<Product2> prodList = new List<Product2> {
                new Product2(Name = 'Language Training- '+LangList[0].Name, Description = 'Test Desc', productCode = 'Test Code', isActive = TRUE,Family='Language Training')
            };
            insert prodList;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 130)
            };
            insert pbeList;
            
            List<PriceBook2> pbList = new List<PriceBook2> {
                new PriceBook2(Name = 'GSA Language Training Price Book', IsActive = True)
            };
            insert pbList;
            
            List<PricebookEntry> pbeCusList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = pbList[0].Id, Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 100)
            };
            insert pbeCusList;
           
            String msg = createContractRecord.createOPLIRecord(oppList[0].Id);
            if(msg != null && msg != '')
                System.assert(msg.contains('Success'));
        }
    }
    
    // For Creating the OPLI records - To display an error message when the opportunity has an opli
    static testMethod void testCreateOpliRec8() {
            
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Opportunity', 'Program_Iteration__c', 'Contact_Assignments__c') AND DeveloperName IN ('ODNI_CLP_Opportunities', 'JMAS_Iteration', 'Student')];
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        if(oppList.size() > 0 && rType.size() > 0 && conList.size() > 0) {
            
            List<Language__c> LangList = new List<Language__c> {
                new Language__c(Name ='English')
            };
            insert LangList;
            
            String oppRt, proItJMASRt,conAssRt;
            
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'ODNI_CLP_Opportunities') oppRt = rt.Id;
                if(rt.DeveloperName == 'JMAS_Iteration') proItJMASRt = rt.Id;
                if(rt.DeveloperName == 'Student') conAssRt = rt.Id;
            }
            
            List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
                new Program_Iteration__c(Name = 'proItr 1', Total_LT_Class_Hours__c = 20, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), RecordTypeId = proItJMASRt, Final_Progress_Due_Date__c = System.today().addDays(3))
            };
            insert proItrList;
            
            oppList[0].Program_Iteration__c = proItrList[0].Id;
            oppList[0].Project_Type__c = 'SLP-FT';
            oppList[0].RecordTypeId = oppRt;
            oppList[0].Language_LU__c = LangList[0].Id;
            update oppList;
            
            Test.startTest();
            
            List<Contact_Assignments__c> conAssList = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Candidate_Name__c=conList[0].Id,RecordTypeId=conAssRt,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=oppList[0].Id,Status__c = 'Active')
            };
            insert conAssList;
           
            Test.stopTest();
            
            List<Product2> prodList = new List<Product2> {
                new Product2(Name = 'Language Training- '+LangList[0].Name, Description = 'Test Desc', productCode = 'Test Code', isActive = TRUE,Family='Language Training')
            };
            insert prodList;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 130)
            };
            insert pbeList;
            
            List<PriceBook2> pbList = new List<PriceBook2> {
                new PriceBook2(Name = 'GSA Language Training Price Book', IsActive = True)
            };
            insert pbList;
            
            List<PricebookEntry> pbeCusList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = pbList[0].Id, Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 100)
            };
            insert pbeCusList;
            
            List<OpportunityLineItem> opliList = new List<OpportunityLineItem> {
                new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = pbeCusList[0].Id, Quantity = 2, UnitPrice = 200, Language__c = langList[0].Id)
            };
            insert opliList;
            String msg = createContractRecord.createOPLIRecord(oppList[0].Id);
            if(msg != null && msg != '')
                System.assert(msg.contains('Already there is a Product'));
        }
    }
    
    // For Creating the Funding records - To display an error message when the opportunity recordtype is not equal to 'DODA Opportunities' or 'DLI-W TO Opportunities'
    static testMethod void testCreateFundingRecord1() {
        
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        
        if(oppList.size() > 0) {
            String msg = createContractRecord.createFundingRecord(oppList[0].Id);
            if(msg != null && msg != '')
                System.assert(msg.contains('created for DODA Opportunities and DLI-W TO Opportunities'));
        }
    }
    
    // For Creating the Funding records - To display an error message when the opportunity without product
    static testMethod void testCreateFundingRecord2() {
        
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'DLI_W_TO_Opportunities'];
        
        if(oppList.size() > 0 && rType.size() > 0) {
            
            oppList[0].RecordTypeId = rType[0].Id;
            update oppList;
            
            String msg = createContractRecord.createFundingRecord(oppList[0].Id);
            if(msg != null && msg != '')
                System.assert(msg.contains('Please create Product under Opportunity'));
        }
    }
    
    // For Creating the Funding records
    static testMethod void testCreateFundingRecord3() {
        
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'DLI_W_TO_Opportunities'];
        
        if(oppList.size() > 0 && rType.size() > 0) {
            
            oppList[0].RecordTypeId = rType[0].Id;
            update oppList;
            
            List<Language__c> LangList = new List<Language__c> {
                new Language__c(Name ='English')
            };
            insert LangList;
            
            List<Product2> prodList = new List<Product2> {
                new Product2(Name = 'Language Training- '+LangList[0].Name, Description = 'Test Desc', productCode = 'Test Code', isActive = TRUE,Family='Language Training')
            };
            insert prodList;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 130)
            };
            insert pbeList;
            
            List<OpportunityLineItem> opliList = new List<OpportunityLineItem> {
                new OpportunityLineItem(OpportunityId = oppList[0].Id, PricebookEntryId = pbeList[0].Id, Quantity = 2, UnitPrice = 200, Language__c = langList[0].Id)
            };
            insert opliList;
            
            String msg = createContractRecord.createFundingRecord(oppList[0].Id);
            if(msg != null && msg != '')
                System.assert(msg.contains('Success'));
        }
    }
    
    // For Creating the Funding records - To display the erroe message when opportunity has funding records
    static testMethod void testCreateFundingRecord4() {
        
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity' AND DeveloperName = 'DLI_W_TO_Opportunities'];
        
        if(oppList.size() > 0 && rType.size() > 0) {
            
            oppList[0].RecordTypeId = rType[0].Id;
            update oppList;
          
            List<Transaction__c> fundingList = new List<Transaction__c> {
                new Transaction__c(Opportunity__c = oppList[0].Id,Transaction_Date__c=System.today())
            };
            insert fundingList;
            
            String msg = createContractRecord.createFundingRecord(oppList[0].Id);
            if(msg != null && msg != '')
                System.assert(msg.contains('Already we have funding record'));
        }
    }
    
    static testMethod void testCreateOpliRec_new() {
            
        List<Opportunity> oppList = [SELECT Id, Name FROM Opportunity LIMIT 2];
        List<RecordType> rType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType IN ('Opportunity', 'Program_Iteration__c', 'Contact_Assignments__c') AND DeveloperName IN ('ODNI_CLP_Opportunities', 'SLP_Iteration', 'Student')];
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        if(oppList.size() > 0 && rType.size() > 0 && conList.size() > 0) {
            Account a = new Account(Name = 'DODA');
            insert a;
            
            List<Language__c> LangList = new List<Language__c> {
                new Language__c(Name ='Chinese - Mandarin')
            };
            insert LangList;
            
            String oppRt, proItSLPRt,conAssRt;
            
            for(RecordType rt : rType) {
                if(rt.DeveloperName == 'ODNI_CLP_Opportunities') oppRt = rt.Id;
                if(rt.DeveloperName == 'SLP_Iteration') proItSLPRt = rt.Id;
                if(rt.DeveloperName == 'Student') conAssRt = rt.Id;
            }
            
            List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
                new Program_Iteration__c(Name = 'proItr 1', Total_LT_Class_Hours__c = 20, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5), RecordTypeId = proItSLPRt, Final_Progress_Due_Date__c = System.today().addDays(3), Midterm_Progress_Due_Date__c= System.today().addDays(2))
            };
            insert proItrList;
            
            oppList[0].Program_Iteration__c = proItrList[0].Id;
            oppList[0].RecordTypeId = oppRt;
            oppList[0].Language_LU__c = LangList[0].Id;
            oppList[0].Project_Type__c = 'IND';
            oppList[0].AccountId = a.Id;
            update oppList;
            
            Test.startTest();
            
            List<Contact_Assignments__c> conAssList = new List<Contact_Assignments__c> {
                new Contact_Assignments__c(Candidate_Name__c=conList[0].Id,RecordTypeId=conAssRt,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=oppList[0].Id,Status__c = 'Active')
            };
            insert conAssList;
            
            Test.stopTest();
            
            List<Product2> prodList = new List<Product2> {
                new Product2(Name = 'Language Training- Chinese (Mandarin)', Description = 'Test Desc', productCode = 'Test Code', isActive = TRUE,Family='Language Training')
            };
            insert prodList;
            
            List<PricebookEntry> pbeList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 130)
            };
            insert pbeList;
            
            List<PriceBook2> pbList = new List<PriceBook2> {
                new PriceBook2(Name = 'DODA Price Book', IsActive = True)
            };
            insert pbList;
            
            List<PricebookEntry> pbeCusList = new List<PricebookEntry>{
                new PricebookEntry(Pricebook2Id = pbList[0].Id, Product2Id = prodList[0].Id, IsActive = TRUE, UnitPrice = 100)
            };
            insert pbeCusList;
           
            String msg = createContractRecord.createOPLIRecord(oppList[0].Id);
            if(msg != null && msg != '')
                System.assertEquals(msg,'Success');
        }
    } 
}