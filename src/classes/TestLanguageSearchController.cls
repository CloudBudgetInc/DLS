@isTest

private class TestLanguageSearchController{
    @testSetup static void setup(){
        List<Known_Language__c> KnownlangList = TestClassUtil.createTestKnownLanguages();
    
    }
    Static testMethod void testSearchContact(){
    
        /*List<Contact> conList = new List<Contact> {
        
            new Contact(
                LastName = 'Test Contact 1', Email = 'test1@test.com',MobilePhone = '1234567890', 
                Language_1__c = 'Bulgarian', Language_2__c = 'German', Language_3__c = 'Russian', 
                Source_Language_1__c = 'Bulgarian', Source_Language_2__c = 'German', 
                Target_Language_1__c = 'English', Target_Language_2__c = 'Bulgarian'
            ),
            new Contact(
                LastName = 'Test Contact 2', Email = 'test2@test.com', MobilePhone = '1234567890', 
                Language_1__c = 'English', Language_2__c = 'Bulgarian', Language_3__c = 'Russian', 
                Source_Language_1__c = 'Bulgarian', Source_Language_2__c = 'German', 
                Target_Language_1__c = 'English', Target_Language_2__c = 'Bulgarian'
            ),
            new Contact(
                LastName = 'Test Contact 3', Email = 'test3@test.com', MobilePhone = '1234567890', 
                Language_1__c = 'Tamil', Language_2__c = 'Telugu', Language_3__c = 'English', 
                Source_Language_1__c = 'Bulgarian', Source_Language_2__c = 'German', 
                Target_Language_1__c = 'English', Target_Language_2__c = 'Bulgarian'
            ),
            new Contact(
                LastName = 'Test Contact 4', Email = 'test4@test.com', MobilePhone = '1234567890', 
                Language_1__c = 'German', Language_2__c = 'Russian', Language_3__c = 'English', 
                Source_Language_1__c = 'Bulgarian', Source_Language_2__c = 'German', 
                Target_Language_1__c = 'English', Target_Language_2__c = 'Bulgarian'
            ),
            new Contact(
                LastName = 'Test Contact 5', Email = 'test5@test.com', MobilePhone = '1234567890', 
                Language_1__c = 'Bulgarian', Language_2__c = 'German', Language_3__c = 'English', 
                Source_Language_1__c = 'English', Source_Language_2__c = 'German', 
                Target_Language_1__c = 'German', Target_Language_2__c = 'Bulgarian'
            ),
            new Contact(
                LastName = 'Test Contact 6', Email = 'test6@test.com', MobilePhone = '1234567890', 
                Language_1__c = 'Bulgarian', Language_2__c = 'German', Language_3__c = 'English', 
                Source_Language_1__c = 'English', Source_Language_2__c = 'German', 
                Target_Language_1__c = 'German', Target_Language_2__c = 'Bulgarian'
            ),
            new Contact(
                LastName = 'Test Contact 7', Email = 'test7@test.com', MobilePhone = '1234567890', 
                Language_1__c = 'Tamil', Language_2__c = 'German', Language_3__c = 'Bulgarian', 
                Source_Language_1__c = 'English', Source_Language_2__c = 'German', 
                Target_Language_1__c = 'German', Target_Language_2__c = 'Bulgarian'
            )
        
        };
        insert conList;*/
        
        LanguageSearchController lsc = new LanguageSearchController();
         
        lsc.getLanguages();
        lsc.getfilterOptions();
        
        lsc.lang1 = 'Bulgarian';
        //lsc.filter = 'All Languages';
        lsc.searchContact();
        
        LanguageSearchController.searchLanguageRelatedDetails('Dari');
        
        List<Known_Language__c> knownLang = [SELECT Id,Language__c,Contact__c FROM Known_Language__c LIMIT 5];
        
        LanguageSearchController.getLanguageDetails(knownLang[0].Contact__c);
        
        /*lsc.lang1 = 'Bulgarian';
        lsc.filter = 'Language 1';
        lsc.searchContact();
        
        lsc.lang1 = 'Bulgarian';
        lsc.filter = 'Language 2';
        lsc.searchContact();
        
        lsc.lang1 = 'Bulgarian';
        lsc.filter = 'Language 3';
        lsc.searchContact();
        
        lsc.lang1 = 'English';
        lsc.filter = 'Source Language 1';
        lsc.searchContact();
        
        lsc.lang1 = 'German';
        lsc.filter = 'Source Language 2';
        lsc.searchContact();
        
        lsc.lang1 = 'English';
        lsc.filter = 'Target Language 1';
        lsc.searchContact();
        
        lsc.lang1 = 'Bulgarian';
        lsc.filter = 'Target Language 2';
        lsc.searchContact();*/
        
    }
    
    Static testMethod void testConstructor(){
    
        /*List<Contact> conList = new List<Contact> {
        
            new Contact(
                LastName = 'Test Contact 1', Email = 'test1@test.com',MobilePhone = '1234567890', 
                Language_1__c = 'Bulgarian', Language_2__c = 'German', Language_3__c = 'Russian', 
                Source_Language_1__c = 'Bulgarian', Source_Language_2__c = 'German', 
                Target_Language_1__c = 'English', Target_Language_2__c = 'Bulgarian'
            ),
            new Contact(
                LastName = 'Test Contact 2', Email = 'test2@test.com', MobilePhone = '1234567890', 
                Language_1__c = 'English', Language_2__c = 'Bulgarian', Language_3__c = 'Russian', 
                Source_Language_1__c = 'Bulgarian', Source_Language_2__c = 'German', 
                Target_Language_1__c = 'English', Target_Language_2__c = 'Bulgarian'
            ),
            new Contact(
                LastName = 'Test Contact 3', Email = 'test3@test.com', MobilePhone = '1234567890', 
                Language_1__c = 'Tamil', Language_2__c = 'Telugu', Language_3__c = 'English', 
                Source_Language_1__c = 'Bulgarian', Source_Language_2__c = 'German', 
                Target_Language_1__c = 'English', Target_Language_2__c = 'Bulgarian'
            ),
            new Contact(
                LastName = 'Test Contact 4', Email = 'test4@test.com', MobilePhone = '1234567890', 
                Language_1__c = 'German', Language_2__c = 'Russian', Language_3__c = 'English', 
                Source_Language_1__c = 'Bulgarian', Source_Language_2__c = 'German', 
                Target_Language_1__c = 'English', Target_Language_2__c = 'Bulgarian'
            ),
            new Contact(
                LastName = 'Test Contact 5', Email = 'test5@test.com', MobilePhone = '1234567890', 
                Language_1__c = 'Bulgarian', Language_2__c = 'German', Language_3__c = 'English', 
                Source_Language_1__c = 'English', Source_Language_2__c = 'German', 
                Target_Language_1__c = 'German', Target_Language_2__c = 'Bulgarian'
            ),
            new Contact(
                LastName = 'Test Contact 6', Email = 'test6@test.com', MobilePhone = '1234567890', 
                Language_1__c = 'Bulgarian', Language_2__c = 'German', Language_3__c = 'English', 
                Source_Language_1__c = 'English', Source_Language_2__c = 'German', 
                Target_Language_1__c = 'German', Target_Language_2__c = 'Bulgarian'
            ),
            new Contact(
                LastName = 'Test Contact 7', Email = 'test7@test.com', MobilePhone = '1234567890', 
                Language_1__c = 'Tamil', Language_2__c = 'German', Language_3__c = 'Bulgarian', 
                Source_Language_1__c = 'English', Source_Language_2__c = 'German', 
                Target_Language_1__c = 'German', Target_Language_2__c = 'Bulgarian'
            )
        
        };
        insert conList;*/
        
        String Lang1=ApexPages.currentPage().getParameters().put('param1', 'English');
        String filter = ApexPages.currentPage().getParameters().put('param2', 'All Languages');
        LanguageSearchController lsc = new LanguageSearchController();
        
        Lang1=ApexPages.currentPage().getParameters().put('param1', 'Bulgarian');
        filter = ApexPages.currentPage().getParameters().put('param2', 'All Languages');
        LanguageSearchController lsc1 = new LanguageSearchController();
        
        Lang1=ApexPages.currentPage().getParameters().put('param1', 'Bulgarian');
        filter = ApexPages.currentPage().getParameters().put('param2', 'Language 1');
        LanguageSearchController lsc2 = new LanguageSearchController();
        
        Lang1=ApexPages.currentPage().getParameters().put('param1', 'Bulgarian');
        filter = ApexPages.currentPage().getParameters().put('param2', 'Language 2');
        LanguageSearchController lsc3 = new LanguageSearchController();
        
        Lang1=ApexPages.currentPage().getParameters().put('param1', 'Bulgarian');
        filter = ApexPages.currentPage().getParameters().put('param2', 'Language 3');
        LanguageSearchController lsc4 = new LanguageSearchController();
        
        Lang1=ApexPages.currentPage().getParameters().put('param1', 'Bulgarian');
        filter = ApexPages.currentPage().getParameters().put('param2', 'Source Language 1');
        LanguageSearchController lsc5 = new LanguageSearchController();
        
        Lang1=ApexPages.currentPage().getParameters().put('param1', 'German');
        filter = ApexPages.currentPage().getParameters().put('param2', 'Source Language 2');
        LanguageSearchController lsc6 = new LanguageSearchController();
        
        Lang1=ApexPages.currentPage().getParameters().put('param1', 'English');
        filter = ApexPages.currentPage().getParameters().put('param2', 'Target Language 1');
        LanguageSearchController lsc7 = new LanguageSearchController();
        
        Lang1=ApexPages.currentPage().getParameters().put('param1', 'Bulgarian');
        filter = ApexPages.currentPage().getParameters().put('param2', 'Target Language 2');
        LanguageSearchController lsc8 = new LanguageSearchController();
    }

}