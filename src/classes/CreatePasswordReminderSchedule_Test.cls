@isTest
private class CreatePasswordReminderSchedule_Test{

    @testSetup static void setupMethod(){
    
        List<Contact> cons = TestClassUtil.createTestContacts();
        List<Opportunity> opps = TestClassUtil.createTestOpportunities();
        
        Test.StartTest();
        
            //Insert Paper Timesheet custom setting
            List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'False')};
            Insert sysVal;
        
        Test.stopTest();
    }
    
    // Having user with Instructor Community profile
    private static testMethod void myTest1(){
    
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName, Beta_Group__c 
            FROM Contact  
            WHERE RecordType.DeveloperName ='Candidate' AND LastName='Test Contact1' LIMIT 1
        ];
        contacts[0].Active_DLS_Online_User__c = TRUE;
        update contacts[0];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        Test.startTest();
        
        Date projSD = Date.Today().addDays(1);
        Date projED = Date.Today().addDays(60);
        
        List<Account> acc = [SELECT Id, Name FROM Account LIMIT 1];
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = acc[0].Id, Name = 'Test Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = dodaRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = proj.Id, Candidate_Name__c = contacts[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Instructor')
        };
        
        insert conAssignRecs;
            
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = contacts[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
    
         // Schedule coverage
        String CRON_EXP = '0 0 14 * * ?';
        CreatePasswordReminder_Schedule sch = new CreatePasswordReminder_Schedule();
        system.schedule('Create Password Reminder', CRON_EXP, sch);
        
        Test.stopTest();
    }
    
    // Having user with Student Community profile
    private static testMethod void myTest2(){
    
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName, Beta_Group__c 
            FROM Contact  
            WHERE RecordType.DeveloperName ='Candidate' AND LastName='Test Contact1' LIMIT 1
        ];
        contacts[0].Active_DLS_Online_User__c = TRUE;
        update contacts[0];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        
        Test.startTest();
        
        Date projSD = Date.Today().addDays(1);
        Date projED = Date.Today().addDays(60);
        
        List<Account> acc = [SELECT Id, Name FROM Account LIMIT 1];
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = acc[0].Id, Name = 'Test Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = dodaRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = proj.Id, Candidate_Name__c = contacts[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Instructor')
        };
        
        insert conAssignRecs;
            
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = contacts[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
    
         // Schedule coverage
        String CRON_EXP = '0 0 14 * * ?';
        CreatePasswordReminder_Schedule sch = new CreatePasswordReminder_Schedule();
        system.schedule('Create Password Reminder', CRON_EXP, sch);
        
        Test.stopTest();
    }
}