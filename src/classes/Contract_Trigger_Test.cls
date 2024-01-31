@isTest
private class Contract_Trigger_Test {
    
    @testSetup static void setup(){
        List<Contract> contractList = TestClassUtil.createTestContracts(); 
        List<CLIN__c> clins = TestClassUtil.createTestClin();
    }
    
    // To update the billing and shipping address of the contract based on related account
    private static testMethod void myTest1() {
        
        /*System_Values__c sysval = new System_Values__c();
        sysval.Name = 'Contract Modified Notify Users';
        sysval.Value__c = 'karthiga@softsquare.biz,sukanyan@softsquare.biz,nixon@softsquare.biz';  
        insert sysval;*/
              
        List<Contract> contList = [SELECT RecordTypeId, AccountId, Status, StartDate, Billing_Contact__c, Primary_POC__c FROM Contract LIMIT 2];
        
        if(contList.size() > 0) {
            
            List<Account> accList = [SELECT Id, Name, BillingAddress FROM Account WHERE Id != :contList[0].AccountId];
            
            if(accList.size() > 0) {
                
                accList[0].BillingCity = 'Test City';
                accList[0].BillingStreet = 'Test Street';
                accList[0].BillingCountry = 'Test Country';
                accList[0].BillingState = 'Test State';
                accList[0].BillingPostalCode = '0123';
                update accList[0];
                
                contList[0].Status = 'Completed Draft';
                contList[0].AccountId = accList[0].Id;
                contList[0].BillingCity = null;
                contList[0].BillingStreet = null;
                contList[0].BillingCountry = null;
                contList[0].BillingState = null;
                contList[0].BillingPostalCode = null;
                contList[1].Status = 'In-Progress Draft';
                update contList;
                
                List<Contract> contrUpList = [SELECT Id, Name, BillingCity, BillingAddress FROM Contract WHERE Id = :contList[0].Id];
                if(contrUpList.size() > 0)
                    System.assertEquals(accList[0].BillingCity, contrUpList[0].BillingCity);
               
               List<Contract> contrUpList1 = [SELECT Id, Name, BillingCity, BillingAddress FROM Contract WHERE Id = :contList[1].Id];
               if(contrUpList1.size() > 0)
                    System.assertNotEquals(accList[0].BillingCity, contrUpList1[0].BillingCity);
               
            }
        }
    }    
    
    //Funding_Type__c = 'Delivery Order (Child)'
    private static testMethod void myTest2(){
    
        List<Contract> contracts = [SELECT Id, Funding_Type__c,Total_Amount_Funded_DOs__c, APXT_Redlining__Contract_Family_Parent__c FROM Contract];
        System.debug('contracts[0]=='+contracts[0].Total_Amount_Funded_DOs__c);
        contracts[0].Funding_Type__c  = 'Delivery Order (Child)';
        contracts[0].Total_Amount_Funded_DOs__c = 10;
        update contracts[0];
        
        
        List<Contract> contracts1 = [SELECT Id, Amount_Funded__c FROM Contract WHERE Id IN :contracts];
        System.assertEquals(10, contracts1 [0].Amount_Funded__c);
    }
    
    //Funding_Type__c = 'Delivery Order (Child)'
    private static testMethod void myTest2a(){
    
        List<Contract> contracts = [SELECT Id,Name, Funding_Type__c,Total_Amount_Funded_DOs__c,Total_Amount_Funded_All_CLINs__c FROM Contract];
        contracts[0].Funding_Type__c  = 'Delivery Order (Child)';
        update contracts[0];
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Id rTId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Federal_Client').getRecordTypeId();
    
        List<Contract> childContracts = new List<Contract> {
            
            new Contract(Name = contracts[0].Name+'-01',RecordTypeId = rTId, AccountId = acc.Id, Status = 'Completed Draft', StartDate = system.today(), APXT_Redlining__Contract_Family_Parent__c = contracts[0].Id, Funding_Type__c = 'Delivery Order (Child)'),
            new Contract(Name = contracts[0].Name+'-02',RecordTypeId = rTId, AccountId = acc.Id, Status = 'Completed Draft', StartDate = system.today(), APXT_Redlining__Contract_Family_Parent__c = contracts[0].Id, Funding_Type__c = 'Delivery Order (Child)')
        };
        
        insert childContracts ;
        
        List<CLIN__c> clinList = new List<CLIN__c> {
            new CLIN__c(Contract__c = childContracts[0].Id, CLIN_Name__c = '2',Name= '2a', Amount_Funded__c = 10),
            new CLIN__c(Contract__c = childContracts[0].Id, CLIN_Name__c = '1',Name= '1a', Amount_Funded__c = 20)
        };
        insert clinList;
        
        List<Contract> contracts1 = [SELECT Id, Amount_Funded__c FROM Contract WHERE Id IN :childContracts];
        System.assertEquals(30, contracts1[0].Amount_Funded__c );
    }
    
    //Funding_Type__c = 'Delivery Order (Child)'
    private static testMethod void myTest2b(){
    
        List<Contract> contracts = [SELECT Id,Name, Funding_Type__c,Total_Amount_Funded_DOs__c,Total_Amount_Funded_All_CLINs__c FROM Contract];
        contracts[0].Funding_Type__c  = 'Delivery Order (Child)';
        update contracts[0];
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Id rTId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Federal_Client').getRecordTypeId();
    
        List<Contract> childContracts = new List<Contract> {
            
            new Contract(Name = contracts[0].Name+'-01',RecordTypeId = rTId, AccountId = acc.Id, Status = 'Completed Draft', StartDate = system.today(), APXT_Redlining__Contract_Family_Parent__c = contracts[0].Id, Funding_Type__c = 'Delivery Order (Child)', Total_Amount_Funded_DOs__c = 90),
            new Contract(Name = contracts[0].Name+'-02',RecordTypeId = rTId, AccountId = acc.Id, Status = 'Completed Draft', StartDate = system.today(), APXT_Redlining__Contract_Family_Parent__c = contracts[0].Id, Funding_Type__c = 'Delivery Order (Child)', Total_Amount_Funded_DOs__c = 20)
        };
        
        insert childContracts ;
        
        childContracts[0].APXT_Redlining__Contract_Family_Parent__c = NULL;
        update childContracts[0];
        
        List<Contract> contracts1 = [SELECT Id, Amount_Funded__c FROM Contract WHERE Id IN :childContracts];
        System.assertEquals(90, contracts1[0].Amount_Funded__c );
    }
    
    //Funding_Type__c = 'Delivery Order (Child)'
    private static testMethod void myTest2c(){
    
        List<Contract> contracts = [SELECT Id, Funding_Type__c,Total_Amount_Funded_DOs__c,Total_Amount_Funded_All_CLINs__c FROM Contract];
        contracts[0].Funding_Type__c  = 'Delivery Order (Child)';
        update contracts[0];
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Id rTId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Federal_Client').getRecordTypeId();
    
        List<Contract> childContracts = new List<Contract> {
            
            new Contract(RecordTypeId = rTId, AccountId = acc.Id, Status = 'Completed Draft', StartDate = system.today(), APXT_Redlining__Contract_Family_Parent__c = NULL, Funding_Type__c = 'Delivery Order (Child)', Amount_Funded__c = 10),
            new Contract(RecordTypeId = rTId, AccountId = acc.Id, Status = 'Completed Draft', StartDate = system.today(), APXT_Redlining__Contract_Family_Parent__c = contracts[0].Id, Funding_Type__c = 'Delivery Order (Child)', Amount_Funded__c = 20)
        };
        
        insert childContracts ;
        
        List<CLIN__c> clinList = new List<CLIN__c> {
            new CLIN__c(Contract__c = childContracts[0].Id, CLIN_Name__c = '2',Name= '2a', Amount_Funded__c = 10),
            new CLIN__c(Contract__c = childContracts[0].Id, CLIN_Name__c = '1',Name= '1a', Amount_Funded__c = 20)
        };
        insert clinList;
        
        childContracts[0].APXT_Redlining__Contract_Family_Parent__c = contracts[0].Id;
        update childContracts[0];
        
        List<Contract> contracts1 = [SELECT Id, Amount_Funded__c FROM Contract WHERE Id IN :childContracts];
        System.assertEquals(30, contracts1[0].Amount_Funded__c );
    }
    
    //Funding_Type__c = 'CLIN'
    private static testMethod void myTest3(){
    
        List<Contract> contracts = [SELECT Id, Funding_Type__c,Total_Amount_Funded_DOs__c FROM Contract];
        System.debug('contracts[0]=='+contracts[0].Total_Amount_Funded_DOs__c);
        contracts[0].Funding_Type__c  = 'CLIN';
        update contracts[0];
        
        List<CLIN__c> clinList = new List<CLIN__c> {
            new CLIN__c(Contract__c = contracts[0].Id, CLIN_Name__c = '2',Name= '2a', Amount_Funded__c = 10),
            new CLIN__c(Contract__c = contracts[0].Id, CLIN_Name__c = '1',Name= '1a', Amount_Funded__c = 20)
        };
        insert clinList;
        
        List<Contract> contracts1 = [SELECT Id, Amount_Funded__c FROM Contract WHERE Id IN :contracts];
        System.assertEquals(30, contracts1[0].Amount_Funded__c);
    }
    
    //Funding_Type__c = 'CLIN'
    private static testMethod void myTest3a(){
    
        List<Contract> contracts = [SELECT Id,Name, Funding_Type__c,Total_Amount_Funded_DOs__c,Total_Amount_Funded_All_CLINs__c FROM Contract];
        
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Id rTId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('Federal_Client').getRecordTypeId();
    
        List<Contract> childContracts = new List<Contract> {
            
            new Contract(Name = contracts[0].Name+'-01',RecordTypeId = rTId, AccountId = acc.Id, Status = 'Completed Draft', StartDate = system.today(), APXT_Redlining__Contract_Family_Parent__c = contracts[0].Id, Funding_Type__c = 'CLIN', Amount_Funded__c = 10),
            new Contract(Name = contracts[0].Name+'-02',RecordTypeId = rTId, AccountId = acc.Id, Status = 'Completed Draft', StartDate = system.today(), APXT_Redlining__Contract_Family_Parent__c = contracts[0].Id, Funding_Type__c = 'CLIN', Amount_Funded__c = 20)
        };
        
        insert childContracts ;
        
        List<CLIN__c> clinList = new List<CLIN__c> {
            new CLIN__c(Contract__c = childContracts[0].Id, CLIN_Name__c = '2',Name= '2a', Amount_Funded__c = 10),
            new CLIN__c(Contract__c = childContracts[0].Id, CLIN_Name__c = '1',Name= '1a', Amount_Funded__c = 20)
        };
        insert clinList;
        
        childContracts[0].APXT_Redlining__Contract_Family_Parent__c = NULL;
        update childContracts[0];
        
        List<Contract> contracts1 = [SELECT Id, Amount_Funded__c FROM Contract WHERE Id IN :childContracts];
        System.assertEquals(30, contracts1[0].Amount_Funded__c);
        
    }
}