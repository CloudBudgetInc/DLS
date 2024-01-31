@isTest 
private class User_Trigger_Test {

     @testSetup static void setup(){
        List<User> userList = TestClassUtil.createTestUsers();
    }
    public static testMethod void myTest1() {
    
        User thisUser = [SELECT Id FROM User WHERE Id=: UserInfo.getUserId()];
        List<RecordType> recList = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType='Contact' AND DeveloperName='DLS_Employee'];
        
        List<Contact> conList=new List<Contact> {
            new Contact(FirstName='Test', LastName='Contact', RecordTypeId=recList[0].Id),
            new Contact(FirstName='Test', MiddleName='UUU', LastName='Contact-001', RecordTypeId=recList[0].Id)
        };
        
        insert conList;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Standard User'].Id;
        
        List<User> users = new List<User>{
            new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='mytestcontactusr@noemail.com'
            ),
            new User(alias = 'test345', email='test345@noemail.com',
                emailencodingkey='UTF-8', lastname='userTesting', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='myusrcontacttest@noemail.com'
            ),
            new User(alias = 'test567', email='test567@noemail.com',
                emailencodingkey='UTF-8', lastname='triggerTestUser', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='mytesttriggerusr@noemail.com'
            )
        };
       
        insert users;
        
        Test.Starttest();
        System.runAs (thisUser) {
        
            List<User> userList = [Select Id,FirstName,LastName,MiddleName,managerid From User WHERE Id IN :users];
            
            userList[0].FirstName='Test';
            userList[0].LastName='Contact';
            userList[0].managerid = userlist[1].id;
            update userList;
            
            userList[0].FirstName='TestUser';
            userList[0].LastName='Contact';
            userList[0].managerid = userlist[2].id;
            update userList;
            
            userList[1].FirstName='Test';
            userList[1].MiddleName='UUU';
            userList[1].LastName='Contact-001';
            update userList;
            
            userList[1].FirstName='null';
            userList[1].MiddleName='Test';
            userList[1].LastName='con';
            update userList;
        }
        Test.Stoptest();
    }
    
    // Task Creation when user creation
    public static testMethod void myTest2() {
    
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
       
        Account a = new Account(Name = 'Test');
        insert a;
        
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.AccountId = a.Id;
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.MiddleName = 'Test';
        c.Email = 'test@gmail.com';
        c.RecordTypeId = stdRTId;
        insert c;
          
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = c.Id, 
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
                
        Test.startTest();
            insert user;
        Test.stopTest(); 
        
        List<Task> taskList = [SELECT Id FROM Task WHERE WhoId = :c.Id];
        System.assertEquals(3, taskList.size());
        
    }
    
    // Task Creation when user updation
    public static testMethod void myTest3() {
    
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        User portalAccountOwner1 = new User(UserRoleId = portalRole.Id,ProfileId = profile1.Id,Username = uniqueName + '@test' + orgId + '.org',
                                                Alias = 'batman',Email = uniqueName + '@test' + orgId + '.org',EmailEncodingKey='UTF-8',Firstname='Bruce',
                                                Lastname='Wayne',LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Chicago');
        
        Database.insert(portalAccountOwner1);

        System.runAs ( portalAccountOwner1 ) {
            //Create account
            Account portalAccount1 = new Account(Name = 'TestAccount',OwnerId = portalAccountOwner1.Id);
            Database.insert(portalAccount1);
        
            //Create contact
            Contact contact1 = new Contact(FirstName = 'Test',Lastname = 'McTesty',AccountId = portalAccount1.Id,Email = System.now().millisecond() + 'test@test.com');
            Database.insert(contact1);
        
            //Create user
            Profile portalProfile = [SELECT Id FROM Profile WHERE Name = 'Instructor Community' Limit 1];
            
            User user1 = new User(Username = System.now().millisecond() + 'test12345@test.com',ContactId = contact1.Id,ProfileId = portalProfile.Id,
                                    Alias = 'test123',Email = 'test12345@test.com',EmailEncodingKey = 'UTF-8',LastName = 'McTesty',CommunityNickname = 'test12345',
                                    TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',LanguageLocaleKey = 'en_US');
            
            Database.insert(user1);
            
            User u = [SELECT Id, Email FROM User WHERE Id = :user1.Id];
            u.Email = 'myCommTest_user@ss.biz';
            update u;
        }
    }
}