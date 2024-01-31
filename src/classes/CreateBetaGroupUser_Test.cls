@isTest
private class CreateBetaGroupUser_Test{

    @testSetup static void setupMethod(){
    
        List<Contact> contacts = TestClassUtil.createTestContacts();
    }
    
    // User not exist and Contact RT = 'Candidate'
    private static testMethod void myTest1(){
    
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName
            FROM Contact  
            WHERE RecordType.DeveloperName IN ('Candidate', 'Student')
        ];
        System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        contacts[0].FirstName = 'Test';
        contacts[0].MiddleName = 'Test';
        update contacts[0];
        
        Test.startTest();
            CreateBetaGroupUser testBatch = new CreateBetaGroupUser();
            Database.ExecuteBatch(testBatch);
        Test.stopTest();
    }
    
    // User not exist and Contact RT = 'Candidate'
    private static testMethod void myTest1a(){
    
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName
            FROM Contact  
            WHERE RecordType.DeveloperName IN ('Candidate', 'Student')
        ];
        System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        contacts[0].FirstName = 'Test';
        contacts[0].MiddleName = 'Test';
        contacts[0].Email = NULL;
        update contacts[0];
        
        Test.startTest();
            CreateBetaGroupUser testBatch = new CreateBetaGroupUser();
            Database.ExecuteBatch(testBatch);
        Test.stopTest();
    }
    
    // User not exist and Contact RT = 'Candidate'
    private static testMethod void myTest1b(){
    
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName
            FROM Contact  
            WHERE RecordType.DeveloperName = 'Candidate'
        ];
        System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        contacts[0].FirstName = 'Test';
        contacts[0].MiddleName = 'Test';
        contacts[0].Email = 'Test.test@gmail.com';
        update contacts[0];
        
        Test.startTest();
            CreateBetaGroupUser testBatch = new CreateBetaGroupUser();
            Database.ExecuteBatch(testBatch);
        Test.stopTest();
    }
    
    // User not exist and Contact RT = 'Candidate'
    private static testMethod void myTest1c(){
    
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName
            FROM Contact  
            WHERE RecordType.DeveloperName = 'Candidate'
        ];
        System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        contacts[0].FirstName = 'Test';
        contacts[0].MiddleName = 'Test';
        contacts[0].LastName = 'Test';
        contacts[0].Email = 'test_test@gmail.com';
        update contacts[0];
        
        Test.startTest();
            CreateBetaGroupUser testBatch = new CreateBetaGroupUser();
            Database.ExecuteBatch(testBatch);
        Test.stopTest();
    }
    
    // User not exist and Contact RT = 'Student'
    private static testMethod void myTest1d(){
    
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName
            FROM Contact  
            WHERE RecordType.DeveloperName = 'Student'
        ];
        System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        contacts[0].FirstName = 'Test';
        contacts[0].MiddleName = 'Test';
        contacts[0].LastName = 'est';
        contacts[0].Email = 'test_test@gmail.com';
        update contacts[0];
        
        Test.startTest();
            CreateBetaGroupUser testBatch = new CreateBetaGroupUser();
            Database.ExecuteBatch(testBatch);
        Test.stopTest();
    }
    
    // User not exist and Contact RT = 'Student' and nickname contains (.)
    private static testMethod void myTest2(){
    
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName
            FROM Contact  
            WHERE RecordType.DeveloperName ='Student'
        ];
        System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        contacts[0].FirstName = 'Test';
        contacts[0].LastName = 'Test';
        contacts[0].MiddleName = 'Test';
        contacts[0].Email = 'Test.test@gmail.com';
        update contacts[0];
        
        Test.startTest();
            CreateBetaGroupUser testBatch = new CreateBetaGroupUser();
            Database.ExecuteBatch(testBatch);
        Test.stopTest();
    }
    
    // User not exist and Contact RT = 'Student' and nickname contains (_)
    private static testMethod void myTest3(){
    
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName
            FROM Contact  
            WHERE RecordType.DeveloperName ='Student'
        ];
        System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        contacts[0].FirstName = 'Test';
        contacts[0].LastName = 'Test';
        contacts[0].MiddleName = 'Test';
        contacts[0].Email = 'Test_test@gmail.com';
        update contacts[0];
        
        Test.startTest();
            CreateBetaGroupUser testBatch = new CreateBetaGroupUser();
            Database.ExecuteBatch(testBatch);
        Test.stopTest();
    }
    
    // User exist and Contact RT = 'Candidate'
    private static testMethod void myTest4(){
    
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName 
            FROM Contact  
            WHERE RecordType.DeveloperName ='Candidate'
        ];
        System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        contacts[0].FirstName = 'Test';
        contacts[0].LastName = 'Test';
        contacts[0].MiddleName = 'Test';
        contacts[0].Email = 'Test_test@gmail.com';
        update contacts[0];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        
            User user = new User(alias = 'test123', email='Test_test@gmail.com',
                    emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = contacts[0].Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            
            ContactTrigger_FutureHandler.fromContactEmail = true;
            
            CreateBetaGroupUser testBatch = new CreateBetaGroupUser();
            Database.ExecuteBatch(testBatch);
        Test.stopTest();
    }
    
    // User exist and Contact RT = 'Student'
    private static testMethod void myTest5(){
    
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName
            FROM Contact  
            WHERE RecordType.DeveloperName ='Student'
        ];
        System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        contacts[0].FirstName = 'Test';
        contacts[0].LastName = 'Test';
        contacts[0].MiddleName = 'Test';
        contacts[0].Email = 'Test_test@gmail.com';
        update contacts[0];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = contacts[0].Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
        
            CreateBetaGroupUser testBatch = new CreateBetaGroupUser();
            Database.ExecuteBatch(testBatch);
        Test.stopTest();
    }
    
    // User exist and Contact RT = 'Student' and IsActive = FALSE
    private static testMethod void myTest6(){
    
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName
            FROM Contact  
            WHERE RecordType.DeveloperName ='Student'
        ];
        System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        contacts[0].FirstName = 'Test';
        contacts[0].LastName = 'Test';
        contacts[0].MiddleName = 'Test';
        contacts[0].Email = 'Test_test@gmail.com';
        update contacts[0];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =false,
                    ContactId = contacts[0].Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
        
            CreateBetaGroupUser testBatch = new CreateBetaGroupUser();
            Database.ExecuteBatch(testBatch);
        Test.stopTest();
    }
    
    // User exist and Contact RT = 'Student' and IsActive = FALSE
    private static testMethod void myTest7(){
    
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName
            FROM Contact  
            WHERE RecordType.DeveloperName ='Student'
        ];
        System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        contacts[0].FirstName = 'Test';
        contacts[0].LastName = 'Test';
        contacts[0].MiddleName = 'Test';
        contacts[0].Email = 'test123@noemail.com';
        update contacts[0];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = contacts[0].Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
        
            CreateBetaGroupUser testBatch = new CreateBetaGroupUser();
            Database.ExecuteBatch(testBatch);
        Test.stopTest();
    }
    
    // Cover mail sending part for user creation
    private static testMethod void myTest8(){
            
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName
            FROM Contact  
            WHERE RecordType.DeveloperName ='Student'
        ];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com', FirstName = 'test', MiddleName = 'Test',
                emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = contacts[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        contacts[0].FirstName = user.FirstName;
        contacts[0].MiddleName = user.MiddleName;
        contacts[0].LastName = user.LastName;
        contacts[0].Email = user.Email;
        update contacts[0];
        
        Test.startTest();
            CreateBetaGroupUser testBatch = new CreateBetaGroupUser();
            Database.ExecuteBatch(testBatch);
        Test.stopTest();
    }   
    
    // Cover mail sending part for user updation
    private static testMethod void myTest9(){
    
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName
            FROM Contact  
            WHERE RecordType.DeveloperName ='Student'
        ];
        System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        contacts[0].FirstName = 'Test';
        contacts[0].LastName = 'Test';
        contacts[0].MiddleName = 'Test';
        contacts[0].Email = NULL;
        update contacts[0];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = contacts[0].Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
        
            CreateBetaGroupUser testBatch = new CreateBetaGroupUser();
            Database.ExecuteBatch(testBatch);
        Test.stopTest();
    } 
    
    // User not exist and Contact RT = 'Candidate'and having task record under this contact
    private static testMethod void myTest10(){
    
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName
            FROM Contact  
            WHERE RecordType.DeveloperName IN ('Candidate', 'Student')
        ];
        System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        contacts[0].FirstName = 'Test';
        contacts[0].MiddleName = 'Test';
        update contacts[0];
        
        Task t = new Task(Subject = 'Watch Timekeeping Training Video', Type = 'To Do', To_Do_Type__c = '10 - Watch Timekeeping Training Video', Status = 'In Progress', WhoId = contacts[0].Id);
        insert t;
                        
        Test.startTest();
            CreateBetaGroupUser testBatch = new CreateBetaGroupUser();
            Database.ExecuteBatch(testBatch);
        Test.stopTest();
    }
    
    // User exist and Contact RT = 'Student'
    private static testMethod void myTest11(){
    
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName
            FROM Contact  
            WHERE RecordType.DeveloperName ='Student'
        ];
        System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        contacts[0].FirstName = 'Test';
        contacts[0].LastName = 'Test';
        contacts[0].MiddleName = 'Test';
        contacts[0].Email = 'Test_test@gmail.com';
        update contacts[0];
        
        Task t = new Task(Subject = 'Watch Timekeeping Approval Training Video', Type = 'To Do', To_Do_Type__c = '30 - Watch Timekeeping Approval Training Video', Status = 'In Progress', WhoId = contacts[0].Id);
        insert t;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = contacts[0].Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
        
            CreateBetaGroupUser testBatch = new CreateBetaGroupUser();
            Database.ExecuteBatch(testBatch);
        Test.stopTest();
    }
}