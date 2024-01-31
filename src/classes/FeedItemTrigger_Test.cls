@isTest
private class FeedItemTrigger_Test{
    
    @testSetup static void setupMethod() {
        Test.StartTest();
            List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment(); 
        Test.StopTest();
        
    }
    
    // Internal User to create FeedItem (Case Contact havn't related User)
    private static testMethod void myTest1(){        
        
        Profile prof = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        System.debug('profile===='+prof );
                
        User u = new User(alias = 'sys', email='sysadmin6@testorg.com',
            emailencodingkey='UTF-8', firstname='fake', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = prof.Id,
            timezonesidkey='America/Los_Angeles', username='sysadmin6@testorg.com');
        insert u;
        System.debug('USER========'+u);
        
        Test.startTest();
            
            Contact con = new Contact(LastName = 'Test Con', Email = 'testcon@gmail.com');
            insert con;
        
            Case c = new Case (ContactId = con.Id, OwnerId = u.Id, SuppliedEmail = 'test@test.com', Subject = 'Missing TimeLog Entry', Priority ='High', Description ='text case document', Status ='New', Origin = 'Web');
            insert c;       
                       
            List<Case> cases = [SELECT Id, OwnerId, Owner.Email, Owner.Name, Subject, CaseNumber, Contact.Name, ContactId, Owner.Type, owner.Username FROM Case WHERE Id = :c.Id];
            
            FeedItem f = new FeedItem();
            f.ParentId = c.id;
            f.body = 'Test';
            insert f;
                
        Test.stopTest();
    }
    
    // Internal User to create FeedItem (Case Contact have related User and FeedItem created userId != Case Contact related UserId)
    private static testMethod void myTest2(){        
        
        Profile prof = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        System.debug('profile===='+prof );
                
        User u = new User(alias = 'sys', email='sysadmin6@testorg.com',
            emailencodingkey='UTF-8', firstname='fake', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = prof.Id,
            timezonesidkey='America/Los_Angeles', username='sysadmin6@testorg.com');
        insert u;
        System.debug('USER========'+u);
        
        Test.startTest();
            
            Contact con = new Contact(LastName = 'Test Connnnn', Email = 'testcon@gmail.com');
            insert con;
            
            User u1 = new User(alias = 'sys', email='sysadmin24@testorg.com',
                emailencodingkey='UTF-8', firstname='', lastname= con.LastName, languagelocalekey='en_US',
                localesidkey='en_US', profileid = prof.Id,
                timezonesidkey='America/Los_Angeles', username='sysadmin24@testorg.com');
            insert u1;
        
            Case c = new Case (ContactId = con.Id, OwnerId = u.Id, SuppliedEmail = 'test@test.com', Subject = 'Missing TimeLog Entry', Priority ='High', Description ='text case document', Status ='New', Origin = 'Web');
            insert c;       
                       
            List<Case> cases = [SELECT Id, OwnerId, Owner.Email, Owner.Name, Subject, CaseNumber, Contact.Name, ContactId, Owner.Type, owner.Username FROM Case WHERE Id = :c.Id];
            
            FeedItem f = new FeedItem();
            f.ParentId = c.id;
            f.body = '@Test Connnnn';
            insert f;
                
        Test.stopTest();
    }
    
    // Internal User to create FeedItem (Case Contact have related User and FeedItem created userId == Case Contact related UserId)
    private static testMethod void myTest3(){        
        
        Profile prof = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
        System.debug('profile===='+prof );
                
        User u = new User(alias = 'sys', email='sysadmin6@testorg.com',
            emailencodingkey='UTF-8', firstname='fake', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = prof.Id,
            timezonesidkey='America/Los_Angeles', username='sysadmin6@testorg.com');
        insert u;
        System.debug('USER========'+u);
        
        Test.startTest();
            
            Contact con = new Contact(LastName = 'Test Connnnn', Email = 'testcon@gmail.com');
            insert con;
            
            User u1 = new User(alias = 'sys', email='sysadmin24@testorg.com',
                emailencodingkey='UTF-8', firstname='', lastname= con.LastName, languagelocalekey='en_US',
                localesidkey='en_US', profileid = prof.Id,
                timezonesidkey='America/Los_Angeles', username='sysadmin24@testorg.com');
            insert u1;
        
            Case c = new Case (ContactId = con.Id, OwnerId = u.Id, SuppliedEmail = 'test@test.com', Subject = 'Missing TimeLog Entry', Priority ='High', Description ='text case document', Status ='New', Origin = 'Web');
            insert c;       
                       
            List<Case> cases = [SELECT Id, OwnerId, Owner.Email, Owner.Name, Subject, CaseNumber, Contact.Name, ContactId, Owner.Type, owner.Username FROM Case WHERE Id = :c.Id];
            
            System.runAs(u1){
                FeedItem f = new FeedItem();
                f.ParentId = c.id;
                f.body = 'Test';
                insert f;
            }
        Test.stopTest();
    }
    
    // Portal User to create FeedItem (Case OwnerId == FeedItem Created UserId)
    private static testMethod void myTest4(){        
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        String contactId;
        
        User u = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert u;
        
        Test.startTest();
            
            Case c = new Case (ContactId = conList[0].Id, OwnerId = u.Id, SuppliedEmail = 'test@test.com', Subject = 'Missing TimeLog Entry', Priority ='High', Description ='text case document', Status ='New', Origin = 'Web');
            insert c;       
                       
            List<Case> cases = [SELECT Id, OwnerId, Owner.Email, Owner.Name, Subject, CaseNumber, Contact.Name, ContactId, Owner.Type, owner.Username FROM Case WHERE Id = :c.Id];
            
            System.runAs(u){
            
                FeedItem f = new FeedItem();
                f.ParentId = c.id;
                f.body = 'Test';
                insert f;
            }
        Test.stopTest();
    }
    
    // Portal User to create FeedItem (Case OwnerId != FeedItem Created UserId)
    private static testMethod void myTest5(){        
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        String contactId;
        
        User u = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='TestingUser', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert u;
        
        //Test.startTest();
        
            Profile prof = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'];
            System.debug('profile===='+prof );
                
            User u1 = new User(alias = 'sys', email='sysadmin6@testorg.com',
                emailencodingkey='UTF-8', firstname='fake', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = prof.Id,
                timezonesidkey='America/Los_Angeles', username='sysadmin6@testorg.com');
            insert u1;
            System.debug('USER========'+u);
            
        Test.startTest();
        
            Case c = new Case (ContactId = conList[0].Id, OwnerId = u1.Id, SuppliedEmail = 'test@test.com', Subject = 'Missing TimeLog Entry', Priority ='High', Description ='text case document', Status ='New', Origin = 'Web');
            insert c;       
                       
            List<Case> cases = [SELECT Id, OwnerId, Owner.Email, Owner.Name, Subject, CaseNumber, Contact.Name, ContactId, Owner.Type, owner.Username FROM Case WHERE Id = :c.Id];
            
            System.runAs(u){
            
                FeedItem f = new FeedItem();
                f.ParentId = cases[0].id;
                f.body = '@Testing';
                //insert f;
            }
        Test.stopTest();
    }
}