@isTest(SeeAllData=True) // Required for using the standard pricebook
private class QuoteListViewController_Test{
    
    
    // Cover getQuoteInformation method
    private static testMethod void myTest1(){
            
        Account a = new Account(Name = 'Test Account');
        insert a;
        
        Id newClassOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Classes_Opportunities').getRecordTypeId();
    
        Opportunity o = new Opportunity(Name = 'Test Opp', StageName = 'Test Stage', CloseDate = Date.today(), AccountId = a.Id, RecordTypeId = newClassOppRTId);
        insert o;
        
        Id projRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c (Name = 'Test Proj',AcctSeed__Status__c = 'Active', RecordTypeId = projRTId, AcctSeed__Opportunity__c = o.Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert proj;
           
        Pricebook2 pb = [select Id from Pricebook2 where IsStandard = true limit 1];

        Product2 p = new Product2(Name = 'Test Product', isActive = true);
        insert p;

        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = p.Id, UnitPrice = 1, isActive = true);
        insert pbe;

        Quote q = new Quote(Name = 'Test Quote', OpportunityId = o.Id, PriceBook2Id = pb.Id, Date__c = Date.today(), Registrar__c = 'April Bellas');
        insert q;

        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = 100);
        insert qli;
            
        QuoteListViewController.getQuoteInformation(proj.Id);
    }
    
    // Cover getQuoteLineInformation method
    private static testMethod void myTest2(){
            
        Account a = new Account(Name = 'Test Account');
        insert a;
        
        Id newClassOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('New_Classes_Opportunities').getRecordTypeId();
    
        Opportunity o = new Opportunity(Name = 'Test Opp', StageName = 'Test Stage', CloseDate = Date.today(), AccountId = a.Id, RecordTypeId = newClassOppRTId);
        insert o;
        
        Id projRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c (Name = 'Test Proj',AcctSeed__Status__c = 'Active', RecordTypeId = projRTId, AcctSeed__Opportunity__c = o.Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert proj;
           
        Pricebook2 pb = [select Id from Pricebook2 where IsStandard = true limit 1];

        Product2 p = new Product2(Name = 'Test Product', isActive = true);
        insert p;

        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = pb.Id, Product2Id = p.Id, UnitPrice = 1, isActive = true);
        insert pbe;

        Quote q = new Quote(Name = 'Test Quote', OpportunityId = o.Id, PriceBook2Id = pb.Id, Date__c = Date.today(), Registrar__c = 'April Bellas');
        insert q;

        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = 100);
        insert qli;
            
        QuoteListViewController.getQuoteLineInformation(q.Id);
    }
}