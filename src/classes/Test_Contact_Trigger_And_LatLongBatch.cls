@isTest
Class Test_Contact_Trigger_And_LatLongBatch{
     
     @testSetup static void setup(){
          //List<Contact> ConList = TestClassUtil.createTestContacts();
          //List<User> UsrList = TestClassUtil.createTestUsers();
          List<System_Values__c> sysValList = TestClassUtil.createSystemValues();
          
          Test.startTest();
              List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();
          Test.stopTest();
     }
    
    static testMethod void conTestMethod() {
       
        List<Contact> conList = [SELECT Id, Name, MailingPostalCode FROM Contact WHERE Account.RecordType.DeveloperName = 'DLS' LIMIT 1];
        conList[0].MailingPostalCode = '60013';
        //update conList;
        
        Id employeeRTId;
        
        List<Contact> contactList = [SELECT Id,Name,FirstName,LastName,AccountId FROM Contact LIMIT 3];
        List<User> usrList = [SELECT Id,Name,FirstName,LastName FROM User WHERE Profile.Name = 'Standard User'];
        
        
        for(RecordType recordType : [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType = 'Contact']) {
            if(recordType.DeveloperName == 'DLS_Employee')
                employeeRTId = recordType.Id;
        }
        
        Id p = [SELECT Id FROM Profile WHERE Name='Standard User'].Id;
        System.debug('p=========='+p);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='mycontactusr@noemail.com');
       
        insert user;
            
        List<Contact> newConList = new List<Contact>{
            new Contact(FirstName = 'SS Test',LastName = 'Contact Record 2',AccountId = contactList[0].AccountId,DLS_Candidate_Rating__c = '3',Candidate_Notes__c = 'Test Record'),
            new Contact(LastName = 'Contact Record 3',AccountId = contactList[0].AccountId,DLS_Candidate_Rating__c = '2',Candidate_Notes__c = 'Test Record')
        };
        
        insert newConList;
        
        contactList[0].RecordTypeId = employeeRTId;
        contactList[0].FirstName = usrList[0].FirstName;
        contactList[0].LastName = usrList[0].LastName;
        contactList[0].Supervisor_Name__c = user.Id;
        contactList[0].DLS_Candidate_Rating__c = '2';
        contactList[0].Candidate_Notes__c = 'Testing Contact Record Updation';
        contactList[0].Original_Hire_Date__c = system.today().addDays(-100);
        
        update contactList[0];
    }
     static testMethod void testContactLatLongBatchClass() {
        Test.startTest();
        ContactLatLongBatchClass al = new ContactLatLongBatchClass();
        Database.executeBatch(al);
        Test.stopTest();
    } 
    
    static testMethod void conFutureTestMethod() {
        
        System_Values__c sysVal = new System_Values__c();
        sysVal.Name = 'Contact field change notify Usr Ids';
        sysVal.value__c = '00532000005xUZO';
        insert sysVal;
        
        RecordType rt = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'DLS_Employee'];
        List<Contact> conList = [SELECT Id,Name,FirstName,LastName,MailingCity,EMail,Phone,MobilePhone,MailingState,MailingCountry,MailingPostalCode FROM Contact LIMIT 3];
        
        List<Profile> Profile = [SELECT Id FROM Profile WHERE Name = 'Timekeeping'];
        String un = String.valueOf(System.now().millisecond())+'@dlsTestOrg.dlsdc';
        String en = String.valueOf(System.now().millisecond())+'@dlsTestOrg.com';
        String un1 = String.valueOf(System.now().addSeconds(20).millisecond())+'@TestOrg.co';
        
        User usr = new User(Alias = 'standt', Email='test@gmail.com',EmailEncodingKey='UTF-8', LastName='LNameTest1', 
            LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = Profile[0].Id, contact=conList[1],isactive = true, 
            TimeZoneSidKey='America/Los_Angeles', UserName=un, FirstName = 'FNameTest1', MiddleName = 'MNameTest1');
            
        insert usr;

        conList[0].FirstName = 'LNameTest';
        conList[0].LastName = 'FNameTest';
        conList[0].MiddleName = 'MNameTest';
        conList[0].EMail = 'testCon1@test.com';
        conList[0].Phone = '0425201542';
        conList[0].MobilePhone = '8956471230';
        conList[0].MailingCity = 'Test City1';
        conList[0].MailingState = 'TN';
        conList[0].MailingCountry = 'IN';
        conList[0].MailingPostalCode = '25362';
        conList[0].RecordTypeId = rt.Id;
        
        update conList;
        
        User usr1 = new User(Alias = 'standt', Email='test@gmail.com',EmailEncodingKey='UTF-8', LastName='LNameTest', 
            LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = Profile[0].Id, contact=conList[1],isactive = true, 
            TimeZoneSidKey='America/Los_Angeles', UserName=un1, FirstName = 'FNameTest', MiddleName = 'MNameTest', ManagerId = usr.Id);
            
        insert usr1;
        
        Contact con = [SELECT Id, Name,FirstName,LastName,MailingCity,EMail,Phone,MobilePhone,MailingState,MailingCountry,MailingPostalCode FROM Contact WHERE Id = :conList[0].Id];
        System.debug(':::Contact::UP:::'+con);
    }
    
    // To cover updateUserTimeZone method()
    @isTest
    static void myTest1(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id, FirstName, LastName, MiddleName, Timezone__c FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Student'];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
            FirstName = conList[0].FirstName, LastName = conList[0].LastName, MiddleName = conList[0].MiddleName,
            emailencodingkey = 'UTF-8', languagelocalekey = 'en_US',
            localesidkey = 'en_US', profileid = p, country='United States',IsActive = TRUE,
            ContactId = conList[0].Id,
            timezonesidkey = 'America/Los_Angeles', username = 'tester@noemail.com'
        );
        
        insert user;
        
        System.runAs(user){
                        
            conList[0].Timezone__c = 'America/Adak';
            update conList[0];
        }
    }
    
    // To cover task updation
    @isTest
    static void myTest2(){
    
        List<Contact> conList = [SELECT Id, Agreed_DLS_Policies_And_Procedures__c FROM Contact WHERE RecordType.DeveloperName = 'Student'];
        System.debug('conList==='+conList);
        
        List<Task> stdTaskList = new List<Task>{
            new Task(Subject = 'Watch Timekeeping Approval Training Video', Type = 'To Do', To_Do_Type__c = '30 - Watch Timekeeping Approval Training Video', Status = 'In Progress', WhoId = conList[0].Id),
            new Task(Subject = 'Student Policies & Procedures', Type = 'To Do', To_Do_Type__c = '40 - Student Policies & Procedures', Status = 'In Progress', WhoId = conList[0].Id),
            new Task(Subject = 'Confirm your Contact Information', Type = 'To Do', To_Do_Type__c = '50 - Confirm your Contact Information', Status = 'In Progress', WhoId = conList[0].Id)
        };  
        insert stdTaskList;
        
        conList[0].Agreed_DLS_Policies_And_Procedures__c = TRUE;
        update conList[0];
        
        List<Task> tasks = [SELECT Id, Status FROM Task WHERE To_Do_Type__c = '40 - Student Policies & Procedures'];
        //System.assertEquals('Completed', tasks[0].Status);
    }
    
    // To cover user creation when contact's email is populated
    @isTest
    static void myTest3(){
    
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
                
        Account a = new Account(Name = 'Test');
        insert a;
        
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.AccountId = a.Id;
        c.FirstName = 'Test';
        c.LastName = 'TestCon';
        c.MiddleName = 'Test';
        //c.Email = 'testcon.test@gmail.com';
        c.RecordTypeId = candidateRTId;
        c.Evaluate_Candidate_Profile_Rating__c = TRUE;
        insert c;
        
        List<Contact> con = [SELECT Id, Email FROM Contact WHERE Id = :c.Id];
        con[0].Email = 'testcon.test@gmail.com';
        update con;
    }
    
    // To cover user updation when contact's email is populated
    @isTest
    static void myTest4(){
    
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
                
        Account a = new Account(Name = 'Test');
        insert a;
        
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.AccountId = a.Id;
        c.FirstName = 'Test';
        c.LastName = 'TestCon';
        c.MiddleName = 'Test';
        //c.Email = 'testcon.test@gmail.com';
        c.RecordTypeId = candidateRTId;
        insert c;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
            
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
        Test.stopTest();
        
        List<Contact> con = [SELECT Id, Email FROM Contact WHERE Id = :c.Id];
        con[0].Email = 'testcon.test@gmail.com';
        update con;
    }
    
    // To populate Time_Approval_Preference__c field in related Student Contact Assignment records whenever contact's Time_Approval_Preference__c field is changed
    @isTest
    static void myTest5(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Time_Approval_Preference__c, Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Candidate_Name__r.RecordType.DeveloperName = 'Student'];   
        
        List<Contact> contacts = [SELECT Id, Time_Approval_Preference__c FROM Contact WHERE Id = :conAssigns[0].Candidate_Name__c];
        
        contacts[0].Time_Approval_Preference__c = 'Daily';
        update contacts[0];
        
        List<Contact_Assignments__c> conAssigns1 = [SELECT Id, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE Id = :conAssigns[0].Id];   
        
        System.assertEquals('Daily', conAssigns1[0].Time_Approval_Preference__c);
    }
    
    // To create / update user record when contact's email is populated from blank
    @isTest
    static void myTest6(){
    
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.MiddleName = 'Test';
        c.RecordTypeId = candidateRTId;
        c.Active_DLS_Online_User__c = FALSE;
        insert c;
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Start_Date__c, End_Date__c, Candidate_Name__c, Assignment_Position__c FROM Contact_Assignments__c WHERE Status__c IN ('Active', 'Planned') AND RecordType.DeveloperName IN ('Student', 'Instructor') LIMIT 1];
        conAssigns[0].Start_Date__c = Date.Today()+3;
        conAssigns[0].End_Date__c = Date.Today()+5;
        conAssigns[0].Candidate_Name__c = c.Id;
        conAssigns[0].Assignment_Position__c = 'Instructor';
        conAssigns[0].Paper_Timesheet__c = FALSE;
        update conAssigns[0];
        
        List<Contact> con = [SELECT Id, Email FROM Contact WHERE Id = :c.Id];
        con[0].Email  = 'newtest.test@gmail.com';
        update con[0];
    }
    
    // To create / update user record when contact's email is populated from blank
    @isTest
    static void myTest7(){
    
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        Account a = new Account(Name='Test Account Name');
        insert a;
  
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.FirstName = 'Test';
        c.LastName = 'Testtest';
        c.MiddleName = 'Test';
        c.RecordTypeId = candidateRTId;
        c.AccountId = a.id;
        insert c;
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Start_Date__c, End_Date__c, Candidate_Name__c FROM Contact_Assignments__c WHERE Status__c IN ('Active', 'Planned') AND RecordType.DeveloperName IN ('Student', 'Instructor') LIMIT 1];
        conAssigns[0].Start_Date__c = Date.Today()+3;
        conAssigns[0].End_Date__c = Date.Today()+5;
        conAssigns[0].Candidate_Name__c = c.Id;
        conAssigns[0].Assignment_Position__c = 'Instructor';
        conAssigns[0].Paper_Timesheet__c = FALSE;
        update conAssigns[0];
                
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
                
        Test.stopTest();
    }
    
    static testMethod void myTest8() {
    
        List<Contact> conList = [SELECT Id, Email FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
            Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
            System.debug('p=========='+p);
            
            List<User> usr = [SELECT Id, Email, UserName FROM User WHERE Email != NULL AND UserName != NULL AND ContactId != NULL LIMIT 1];
            
            User u = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert u;
            
        Test.stopTest();
        
        conList[0].Email = usr[0].UserName;
        update conList[0];
    }
    
    static testMethod void myTest9() {
    
        List<Contact> conList = [SELECT Id, Email FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
            Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
            System.debug('p=========='+p);
                        
            User u = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert u;
        
        Test.stopTest();
        
        conList[0].Email = 'mynewtestusr123@gmail.com';
        update conList[0];        
    }
    
    static testMethod void myTest10() {
    
        Account a = new Account(Name = 'My Test Acc');
        insert a;
        
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        Contact c = new Contact(RecordtypeId = candidateRTId, LastName = 'My Test Con', Email = 'mytescon@gmail.com', AccountId = a.Id,
            MailingStreet = 'Test Street', MailingCity = 'Test City', MailingState = 'Test State', MailingCountry = 'Test Country', MailingPostalCode = '621303');   
        insert c;
        
        List<Contact> con = [SELECT Id, MailingStreet, MailingPostalCode, MailingCity, MailingState, MailingCountry FROM Contact WHERE Id = :c.Id];
        con[0].MailingStreet = 'My Mailing Street';
        con[0].MailingPostalCode = '621203';
        con[0].MailingCity = 'My City';
        con[0].MailingState = 'My State';
        con[0].MailingCountry = 'My Country';
        con[0].W_9_on_file__c = TRUE;
        con[0].PC_EE_ID__c = 'My Test Id';
        con[0].EE_Pay_Status__c = 'Salary';
        update con[0];
        
        List<Account> ac = [SELECT Id, W_9_on_file__c, ShippingCountry, BillingCountry FROM Account WHERE Id = :a.Id];
        System.assertEquals(ac[0].W_9_on_file__c, TRUE);
        System.assertEquals(ac[0].ShippingCountry, 'My Country');
        System.assertEquals(ac[0].BillingCountry, 'My Country');
    }
    
    //To update Instructors__c, Students__c and Staffs__c text fields under related project records whenever contact's name is changed
    @isTest
    static void myTest11(){
    
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.MiddleName = 'Test';
        c.RecordTypeId = stdRTId;
        insert c;
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Start_Date__c, End_Date__c, Candidate_Name__c, Assignment_Position__c FROM Contact_Assignments__c WHERE Status__c IN ('Active', 'Planned') AND RecordType.DeveloperName IN ('Student') LIMIT 1];
        conAssigns[0].Start_Date__c = Date.Today()+3;
        conAssigns[0].End_Date__c = Date.Today()+5;
        conAssigns[0].Candidate_Name__c = c.Id;
        update conAssigns[0];
        
        List<Contact> con = [SELECT Id, Email FROM Contact WHERE Id = :c.Id];
        con[0].FirstName  = 'new FirstName';
        update con[0];        
    }
    
    //To update Instructors__c, Students__c and Staffs__c text fields under related project records whenever contact's name is changed
    @isTest
    static void myTest12(){
    
        Id staffRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
        
        Contact c = new Contact();
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.MiddleName = 'Test';
        c.RecordTypeId = staffRTId;
        insert c;
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Start_Date__c, End_Date__c, Candidate_Name__c, Assignment_Position__c FROM Contact_Assignments__c WHERE Status__c IN ('Active', 'Planned') AND RecordType.DeveloperName IN ('Staff') LIMIT 1];
        conAssigns[0].Start_Date__c = Date.Today()+3;
        conAssigns[0].End_Date__c = Date.Today()+5;
        conAssigns[0].Candidate_Name__c = c.Id;
        update conAssigns[0];
        
        List<Contact> con = [SELECT Id, Email FROM Contact WHERE Id = :c.Id];
        con[0].FirstName  = 'new FirstName';
        update con[0];        
    }    
}