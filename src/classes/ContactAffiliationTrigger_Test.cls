@isTest
private class ContactAffiliationTrigger_Test{

    @testSetup static void setupMethod(){
    
        List<Contact> contacts = TestClassUtil.createTestContacts();
    }  
    
    // For insert
    private static testMethod void myTest1(){
    
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 2];
        
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        
        List<Contact_Affiliation__c> conAff = new List<Contact_Affiliation__c>{
    
            new Contact_Affiliation__c(Account__c = accounts[0].Id, Contact__c = contacts[0].Id, Status__c = 'Planned', Position__c = 'Client', Start_Date__c = Date.Today(), End_Date__c = Date.Today().addDays(1)),
            new Contact_Affiliation__c(Account__c = accounts[0].Id, Contact__c = contacts[0].Id, Status__c = 'Active', Position__c = 'Client', Start_Date__c = Date.Today(), End_Date__c = Date.Today().addDays(1))
        };
        insert conAff;
        
        List<Contact_Affiliation__c> conAffRec = [SELECT Id, Unique_Contact_Affiliation__c FROM Contact_Affiliation__c ORDER BY CreatedDate ASC];
        System.assertEquals(1, conAffRec[0].Unique_Contact_Affiliation__c);
        System.assertEquals(0, conAffRec[1].Unique_Contact_Affiliation__c);
    }  
    
    // For insert
    private static testMethod void myTest2(){
    
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 2];
        
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        
        Contact_Affiliation__c ca = new Contact_Affiliation__c(Account__c = accounts[0].Id, Contact__c = contacts[0].Id, Status__c = 'Planned', Position__c = 'Client', Start_Date__c = Date.Today(), End_Date__c = Date.Today().addDays(1));
        insert ca;
        
        List<Contact_Affiliation__c> conAff = new List<Contact_Affiliation__c>{
    
            new Contact_Affiliation__c(Account__c = accounts[0].Id, Contact__c = contacts[0].Id, Status__c = 'Planned', Position__c = 'Client', Start_Date__c = Date.Today(), End_Date__c = Date.Today().addDays(1)),
            new Contact_Affiliation__c(Account__c = accounts[0].Id, Contact__c = contacts[0].Id, Status__c = 'Active', Position__c = 'Client', Start_Date__c = Date.Today(), End_Date__c = Date.Today().addDays(1))
        };
        insert conAff;
        
        List<Contact_Affiliation__c> conAffRec = [SELECT Id, Unique_Contact_Affiliation__c FROM Contact_Affiliation__c WHERE Id IN : conAff ORDER BY CreatedDate ASC];
        System.assertEquals(0, conAffRec[0].Unique_Contact_Affiliation__c);
    }  
    
    // For delete
    private static testMethod void myTest3(){
    
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 2];
        
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        
        List<Contact_Affiliation__c> conAff = new List<Contact_Affiliation__c>{
    
            new Contact_Affiliation__c(Account__c = accounts[0].Id, Contact__c = contacts[0].Id, Status__c = 'Planned', Position__c = 'Client', Start_Date__c = Date.Today(), End_Date__c = Date.Today().addDays(1)),
            new Contact_Affiliation__c(Account__c = accounts[0].Id, Contact__c = contacts[0].Id, Status__c = 'Active', Position__c = 'Client', Start_Date__c = Date.Today(), End_Date__c = Date.Today().addDays(1))
        };
        insert conAff;
        
        List<Contact_Affiliation__c> conAffRec = [SELECT Id, Unique_Contact_Affiliation__c FROM Contact_Affiliation__c WHERE Id IN : conAff ORDER BY CreatedDate ASC LIMIT 1];
        delete conAffRec[0];
        
        List<Contact_Affiliation__c> conAffRecs = [SELECT Id, Unique_Contact_Affiliation__c FROM Contact_Affiliation__c WHERE Id IN : conAff];
        System.assertEquals(1, conAffRecs[0].Unique_Contact_Affiliation__c);
    }  
    
    // For update
    private static testMethod void myTest4(){
    
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 2];
        
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        
        List<Contact_Affiliation__c> conAff = new List<Contact_Affiliation__c>{
    
            new Contact_Affiliation__c(Account__c = accounts[0].Id, Contact__c = contacts[0].Id, Status__c = 'Planned', Position__c = 'Client', Start_Date__c = Date.Today(), End_Date__c = Date.Today().addDays(1)),
            new Contact_Affiliation__c(Account__c = accounts[0].Id, Contact__c = contacts[0].Id, Status__c = 'Active', Position__c = 'Client', Start_Date__c = Date.Today(), End_Date__c = Date.Today().addDays(1))
        };
        insert conAff;
        
        List<Contact_Affiliation__c> conAffRec = [SELECT Id, Contact__c FROM Contact_Affiliation__c WHERE Id IN : conAff ORDER BY CreatedDate ASC ];
        conAffRec[0].Contact__c = contacts[1].Id;
        update conAffRec[0];
        
        List<Contact_Affiliation__c> conAffRecs = [SELECT Id, Unique_Contact_Affiliation__c FROM Contact_Affiliation__c WHERE Id IN : conAff ORDER BY CreatedDate ASC ];
        System.assertEquals(1, conAffRecs[0].Unique_Contact_Affiliation__c);
        System.assertEquals(1, conAffRecs[1].Unique_Contact_Affiliation__c);
    }
    
    // For update
    private static testMethod void myTest5(){
    
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 2];
        
        List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
        
        List<Contact_Affiliation__c> conAff = new List<Contact_Affiliation__c>{
    
            new Contact_Affiliation__c(Account__c = accounts[0].Id, Contact__c = contacts[0].Id, Status__c = 'Planned', Position__c = 'Client', Start_Date__c = Date.Today(), End_Date__c = Date.Today().addDays(1)),
            new Contact_Affiliation__c(Account__c = accounts[0].Id, Contact__c = contacts[0].Id, Status__c = 'Active', Position__c = 'Client', Start_Date__c = Date.Today(), End_Date__c = Date.Today().addDays(1)),
            new Contact_Affiliation__c(Account__c = accounts[0].Id, Contact__c = contacts[1].Id, Status__c = 'Active', Position__c = 'Client', Start_Date__c = Date.Today(), End_Date__c = Date.Today().addDays(1))
        };
        insert conAff;
        
        List<Contact_Affiliation__c> conAffRec = [SELECT Id, Contact__c FROM Contact_Affiliation__c WHERE Id IN : conAff AND Contact__c = :contacts[0].Id ORDER BY CreatedDate ASC ];
        conAffRec[0].Contact__c = contacts[1].Id;
        conAffRec[1].Contact__c = contacts[1].Id;
        update conAffRec;
        
        List<Contact_Affiliation__c> conAffRecs = [SELECT Id, Unique_Contact_Affiliation__c FROM Contact_Affiliation__c WHERE Id IN : conAffRec AND Contact__c = :contacts[1].Id ORDER BY CreatedDate ASC ];
        //System.assertEquals(1, conAffRecs[0].Unique_Contact_Affiliation__c);
        //System.assertEquals(0, conAffRecs[1].Unique_Contact_Affiliation__c);
    }
}