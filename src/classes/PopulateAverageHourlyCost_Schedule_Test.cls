@isTest
private class PopulateAverageHourlyCost_Schedule_Test{

    @testSetup static void setupMethod(){
    
        List<Language__c> languages = TestClassUtil.createTestLanguages();
        List<AcctSeed__Cost_Rates__c> costRates = TestClassUtil.createTestCostRates();
    }
    
    // Update Average_Hourly_Cost_LT_Cost_Rate__c value from NULL to NOT NULL
    private static testMethod void myTest1(){
    
        List<Language__c> languages = [SELECT Id, Name, Average_Hourly_Cost_LT_Cost_Rate__c FROM Language__c];
        System.debug('languages======='+languages);
                
        List<Contact> contacts = [SELECT Id, Language_1__c FROM Contact WHERE RecordType.DeveloperName = 'Candidate'];
        System.debug('contacts======='+contacts);
        
        contacts[0].Language_1__c = languages[0].Name;
        update contacts[0];
        
        List<AcctSeed__Cost_Rates__c> costRates = [SELECT Id, Contact__c, Rate_Type__c, Status__c, AcctSeed__Hourly_Cost__c FROM AcctSeed__Cost_Rates__c WHERE Contact__c != NULL AND Status__c = 'Approved' LIMIT 1];
        System.debug('costRates========'+costRates);
        
        costRates[0].Contact__c = contacts[0].Id;
        costRates[0].Rate_Type__c = 'LT with Prep';
        update costRates;
        
        Test.startTest();
        
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            PopulateAverageHourlyCost_Schedule sch = new PopulateAverageHourlyCost_Schedule();
            system.schedule('To populate average hourly cost', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // Update Average_Hourly_Cost_LT_Cost_Rate__c value from NOT NULL to NOT NULL
    private static testMethod void myTest2(){
    
        List<Language__c> languages = [SELECT Id, Name, Average_Hourly_Cost_LT_Cost_Rate__c FROM Language__c];
        languages[0].Average_Hourly_Cost_LT_Cost_Rate__c = 10;
        update languages[0];
        System.debug('languages======='+languages);
                
        List<Contact> contacts = [SELECT Id, Language_1__c FROM Contact WHERE RecordType.DeveloperName = 'Candidate'];
        System.debug('contacts======='+contacts);
        
        contacts[0].Language_1__c = languages[0].Name;
        update contacts[0];
        
        List<AcctSeed__Cost_Rates__c> costRates = [SELECT Id, Contact__c, Rate_Type__c, Status__c FROM AcctSeed__Cost_Rates__c WHERE Contact__c != NULL AND Status__c = 'Approved' LIMIT 1];
        System.debug('costRates========'+costRates);
        
        costRates[0].Contact__c = contacts[0].Id;
        costRates[0].Rate_Type__c = 'LT with Prep';
        update costRates;
        
        List<Language__c> lang = [SELECT Id, Name, Average_Hourly_Cost_LT_Cost_Rate__c FROM Language__c WHERE Id =:languages[0].Id];
        System.debug('lang==========='+lang[0].Average_Hourly_Cost_LT_Cost_Rate__c);
        
        Test.startTest();
        
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            PopulateAverageHourlyCost_Schedule sch = new PopulateAverageHourlyCost_Schedule();
            system.schedule('To populate average hourly cost', CRON_EXP, sch);
            
        Test.stopTest();
    }
     // Update Average_Hourly_Cost_LT_Cost_Rate__c value from NOT NULL to NOT NULL
    private static testMethod void myTest3(){
    
        List<Language__c> languages = [SELECT Id, Name, Average_Hourly_Cost_LT_Cost_Rate__c FROM Language__c];
        languages[0].Average_Hourly_Cost_LT_without_Prep__c = 10;
        update languages[0];
        System.debug('languages======='+languages);
                
        List<Contact> contacts = [SELECT Id, Language_1__c FROM Contact WHERE RecordType.DeveloperName = 'Candidate'];
        System.debug('contacts======='+contacts);
        
        contacts[0].Language_1__c = languages[0].Name;
        update contacts[0];
        
        List<AcctSeed__Cost_Rates__c> costRates = [SELECT Id, Contact__c, Rate_Type__c, Status__c FROM AcctSeed__Cost_Rates__c WHERE Contact__c != NULL AND Status__c = 'Approved' LIMIT 1];
        System.debug('costRates========'+costRates);
        
        costRates[0].Contact__c = contacts[0].Id;
        costRates[0].Rate_Type__c = 'LT without Prep';
        update costRates;
        
        List<Language__c> lang = [SELECT Id, Name, Average_Hourly_Cost_LT_without_Prep__c FROM Language__c WHERE Id =:languages[0].Id];
        System.debug('lang==========='+lang[0].Average_Hourly_Cost_LT_without_Prep__c);
        
        Test.startTest();
        
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            PopulateAverageHourlyCost_Schedule sch = new PopulateAverageHourlyCost_Schedule();
            system.schedule('To populate average hourly cost', CRON_EXP, sch);
            
        Test.stopTest();
    }
}