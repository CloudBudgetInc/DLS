@isTest
private class CAbasedUserCreationOnEveryHour_Sch_Test{

    @testSetup static void setupMethod(){
    
        Test.startTest();
            List<AcctSeed__Project__c> projects = TestClassUtil.createTestProject();
        Test.stopTest();
        
        List<Materials_Request__c> matReqs = TestClassUtil.createTestMaterialRequest();
        
        List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'FALSE')};
        insert sysVal;    
    }
    
    // User not exist and Contact RT = 'Candidate'
    private static testMethod void myTest1(){
    
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        Account a = new Account(Name = 'Test');
        insert a;
        
        List<User> usr = [SELECT Id, FirstName, MiddleName, LastName, Email FROM User WHERE FirstName != NULL AND MiddleName != NULL AND LastName != NULL AND Email != NULL AND IsPortalEnabled = TRUE AND IsActive = TRUE];
        
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.AccountId = a.Id;
        c.FirstName = usr[0].FirstName;
        c.LastName = usr[0].LastName;
        c.MiddleName = usr[0].MiddleName;
        //c.Email = usr[0].Email;
        c.RecordTypeId = candidateRTId;
        c.Active_DLS_Online_User__c = FALSE;
        insert c;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = insRTId;
        conAssigns.Assignment_Position__c = 'Instructor';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
          
        Test.startTest();
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projects[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // User not exist and Contact RT = 'Candidate'
    private static testMethod void myTest1a(){
    
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        Account a = new Account(Name = 'Test');
        insert a;
        
        List<User> usr = [SELECT Id, FirstName, MiddleName, LastName, Email FROM User WHERE FirstName != NULL AND MiddleName != NULL AND LastName != NULL AND Email != NULL AND IsPortalEnabled = TRUE AND IsActive = TRUE];
        
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.AccountId = a.Id;
        c.FirstName = usr[0].FirstName;
        c.LastName = usr[0].LastName;
        c.MiddleName = usr[0].MiddleName;
        //c.Email = usr[0].Email;
        c.RecordTypeId = candidateRTId;
        c.Active_DLS_Online_User__c = FALSE;
        insert c;
        
        List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
            new Program_Iteration__c(Name = 'SLP PI', Total_LT_Class_Hours__c = 85, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5))
        };
        insert proItrList;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = insRTId;
        conAssigns.Assignment_Position__c = 'Instructor';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
        
        projects[0].RecordTypeId = dodaRTId;
        projects[0].Project_Type__c = 'SLP-PT';
        projects[0].Program_Iteration__c =proItrList[0].Id;
        update projects[0];
        
        Test.startTest();
                
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projects[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // User not exist and Contact RT = 'Student'
    private static testMethod void myTest2(){
    
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
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
        c.Active_DLS_Online_User__c = FALSE;
        insert c;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
            
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = insRTId;
        conAssigns.Assignment_Position__c = 'Instructor';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
          
        Test.startTest();
                
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projects[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // User not exist to cover nickname if else part
    private static testMethod void myTest3(){
    
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        Account a = new Account(Name = 'Test');
        insert a;
        
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.AccountId = a.Id;
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.MiddleName = 'Test';
        c.Email = 'test_test@gmail.com';
        c.RecordTypeId = stdRTId;
        c.Active_DLS_Online_User__c = FALSE;
        insert c;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
            
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = insRTId;
        conAssigns.Assignment_Position__c = 'Instructor';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
          
        Test.startTest();
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projects[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // User exist and Contact RT = 'Student'
    private static testMethod void myTest4(){
    
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
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
        c.Active_DLS_Online_User__c = FALSE;
        insert c;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
            
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = insRTId;
        conAssigns.Assignment_Position__c = 'Instructor';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
        
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        System.debug('p=========='+p);
        
        List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
        mat[0].Name = 'LMS Enrollment Test';
        update mat[0];
        
        List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
        matReq[0].Materials_Name__c = mat[0].Id;
        matReq[0].Project__c = projects[0].Id;
        matReq[0].Request_Status__c = 'Requested by LTS';
        update matReq[0];
            
        Test.startTest();
                        
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // User exist and Contact RT = 'Candidate' and contact have task records already
    private static testMethod void myTest5(){
    
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        Account a = new Account(Name = 'Test');
        insert a;
        
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.AccountId = a.Id;
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.MiddleName = 'Test';
        c.Email = 'test@gmail.com';
        c.RecordTypeId = candidateRTId;
        c.Active_DLS_Online_User__c = FALSE;
        insert c;
        
        Task testTask = new Task(Subject = 'Watch Timekeeping Training Video', Type = 'To Do', To_Do_Type__c = '10 - Watch Timekeeping Training Video', Status = 'In Progress', WhoId = c.Id);
        insert testTask;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
            
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = insRTId;
        conAssigns.Assignment_Position__c = 'Instructor';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
        
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projects[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =false,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // User exist and Contact RT = 'Candidate'
    private static testMethod void myTest6(){
    
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        Account a = new Account(Name = 'Test');
        insert a;
        
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.AccountId = a.Id;
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.MiddleName = 'Test';
        c.Email = 'test@gmail.com';
        c.RecordTypeId = candidateRTId;
        c.Active_DLS_Online_User__c = FALSE;
        insert c;
                
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
            
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = insRTId;
        conAssigns.Assignment_Position__c = 'Instructor';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
        
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projects[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =false,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    /*
    // Cover mail sending part
    private static testMethod void myTest7(){
    
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        Account a = new Account(Name = 'New Test');
        insert a;
        List<User> usr = [SELECT Id, FirstName, MiddleName, LastName, Email FROM User WHERE FirstName != NULL AND MiddleName != NULL AND LastName != NULL AND Email != NULL AND IsPortalEnabled = TRUE AND IsActive = TRUE];
        
        Contact c = new Contact();
        //c.Beta_Group__c = TRUE;
        c.AccountId = a.Id;
        c.FirstName = usr[0].FirstName;
        c.LastName = usr[0].LastName;
        c.MiddleName = usr[0].MiddleName;
        c.Email = usr[0].Email;
        c.RecordTypeId = candidateRTId;
        c.Active_DLS_Online_User__c = FALSE;
        insert c;
                
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
            
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = insRTId;
        conAssigns.Assignment_Position__c = 'Instructor';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
        
        Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projects[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive = false,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            
            try{
                // Schedule coverage
                String CRON_EXP = '0 0 14 * * ?';
                CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
                system.schedule('CA Based User Creation', CRON_EXP, sch);
            }catch(Exception e){
                System.debug(':::::::'+e.getMessage());
            }
        Test.stopTest();
    }
    */
    // SLP Student User Creation
    private static testMethod void myTest8(){
    
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id stdCARTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
        
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
        c.Active_DLS_Online_User__c = FALSE;
        insert c;
        
        List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
            new Program_Iteration__c(Name = 'SLP PI', Total_LT_Class_Hours__c = 85, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5))
        };
        insert proItrList;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        projects[0].RecordTypeId = dodaRTId;
        projects[0].Project_Type__c = 'SLP-PT';
        projects[0].Program_Iteration__c =proItrList[0].Id;
        projects[0].Moodle_Course_Id__c = '123';
        update projects[0];
        
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = stdCARTId;
        conAssigns.Assignment_Position__c = 'Student';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
        
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projects[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            User user = new User(alias = 'test123', email='moodletest123@noemail.com',
                    emailencodingkey='UTF-8', lastname='moodleTestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =false,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // SLP Student User Reactivation
    private static testMethod void myTest9(){
    
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id stdCARTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
        
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
        c.Active_DLS_Online_User__c = FALSE;
        c.Moodle_User_Id__c = '345';
        c.Moodle_User_Status__c = 'Suspended';
        insert c;
        
        List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
            new Program_Iteration__c(Name = 'SLP PI', Total_LT_Class_Hours__c = 85, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5))
        };
        insert proItrList;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        projects[0].RecordTypeId = dodaRTId;
        projects[0].Project_Type__c = 'SLP-PT';
        projects[0].Program_Iteration__c =proItrList[0].Id;
        projects[0].Moodle_Course_Id__c = '123';
        update projects[0];
        
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = stdCARTId;
        conAssigns.Assignment_Position__c = 'Student';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
        
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projects[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            User user = new User(alias = 'test123', email='moodletest123@noemail.com',
                    emailencodingkey='UTF-8', lastname='moodleTestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =false,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // Instructor User Creation and Substitute Instructor User Creation
    private static testMethod void myTest10(){
    
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id insCARTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
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
        c.Active_DLS_Online_User__c = FALSE;
        insert c;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        projects[0].Moodle_Course_Id__c = '123';
        update projects[0];
        
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = insCARTId;
        conAssigns.Assignment_Position__c = 'Instructor';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
        
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projects[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            User user = new User(alias = 'test123', email='moodletest123@noemail.com',
                    emailencodingkey='UTF-8', lastname='moodleTestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =false,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // Instructor User Reactivation and Substitute Instructor User Reactivation
    private static testMethod void myTest11(){
    
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id insCARTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
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
        c.Active_DLS_Online_User__c = FALSE;
        c.Moodle_User_Id__c = '345';
        c.Moodle_User_Status__c = 'Suspended';
        insert c;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        projects[0].Moodle_Course_Id__c = '123';
        update projects[0];
        
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = insCARTId;
        conAssigns.Assignment_Position__c = 'Substitute Instructor';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
        
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projects[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            User user = new User(alias = 'test123', email='moodletest123@noemail.com',
                    emailencodingkey='UTF-8', lastname='moodleTestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =false,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // Student User Creation
    private static testMethod void myTest12(){
    
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id stdCARTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
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
        c.Active_DLS_Online_User__c = FALSE;
        insert c;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        projects[0].Moodle_Course_Id__c = '123';
        update projects[0];
        
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = stdCARTId;
        conAssigns.Assignment_Position__c = 'Student';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
        
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projects[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            User user = new User(alias = 'test123', email='moodletest123@noemail.com',
                    emailencodingkey='UTF-8', lastname='moodleTestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =false,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // Student User Reactivation
    private static testMethod void myTest13(){
    
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id stdCARTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
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
        c.Active_DLS_Online_User__c = FALSE;
        c.Moodle_User_Id__c = '345';
        c.Moodle_User_Status__c = 'Suspended';
        insert c;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        projects[0].Moodle_Course_Id__c = '123';
        update projects[0];
        
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = stdCARTId;
        conAssigns.Assignment_Position__c = 'Student';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
        
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projects[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            User user = new User(alias = 'test123', email='moodletest123@noemail.com',
                    emailencodingkey='UTF-8', lastname='moodleTestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =false,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // SLP Student Course Enrolment
    private static testMethod void myTest14(){
    
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id stdCARTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
        
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
        c.Active_DLS_Online_User__c = FALSE;
        c.Moodle_User_Id__c = '345';
        c.Moodle_User_Status__c = 'Active';
        insert c;
        
        List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
            new Program_Iteration__c(Name = 'SLP PI', Total_LT_Class_Hours__c = 85, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5))
        };
        insert proItrList;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        projects[0].RecordTypeId = dodaRTId;
        projects[0].Project_Type__c = 'SLP-PT';
        projects[0].Program_Iteration__c =proItrList[0].Id;
        projects[0].Moodle_Course_Id__c = '123';
        update projects[0];
        
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = stdCARTId;
        conAssigns.Assignment_Position__c = 'Student';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
        
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projects[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            User user = new User(alias = 'test123', email='moodletest123@noemail.com',
                    emailencodingkey='UTF-8', lastname='moodleTestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =false,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // Instructor Course Enrolment and Substitute Instructor Course Enrolment
    private static testMethod void myTest15(){
    
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id insCARTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
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
        c.Active_DLS_Online_User__c = FALSE;
        c.Moodle_User_Id__c = '345';
        c.Moodle_User_Status__c = 'Active';
        insert c;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        projects[0].Moodle_Course_Id__c = '123';
        update projects[0];
        
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = insCARTId;
        conAssigns.Assignment_Position__c = 'Instructor';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
        
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projects[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            User user = new User(alias = 'test123', email='moodletest123@noemail.com',
                    emailencodingkey='UTF-8', lastname='moodleTestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =false,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // Student Course Enrolment
    private static testMethod void myTest16(){
    
        Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id stdCARTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
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
        c.Active_DLS_Online_User__c = FALSE;
        c.Moodle_User_Id__c = '345';
        c.Moodle_User_Status__c = 'Active';
        insert c;
        
        List<AcctSeed__Project__c> projects = [SELECT Id FROM AcctSeed__Project__c LIMIT 1];
        projects[0].Moodle_Course_Id__c = '123';
        update projects[0];
        
        Contact_Assignments__c conAssigns = new Contact_Assignments__c();
        conAssigns.Start_Date__c = Date.Today()+1;
        conAssigns.End_Date__c = Date.Today()+2;
        conAssigns.Candidate_Name__c = c.Id;
        conAssigns.Status__c = 'Active';
        conAssigns.Project__c = projects[0].Id;
        conAssigns.RecordTypeId = stdCARTId;
        conAssigns.Assignment_Position__c = 'Student';
        conAssigns.Paper_Timesheet__c = FALSE;
        insert conAssigns;        
        
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projects[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            User user = new User(alias = 'test123', email='moodletest123@noemail.com',
                    emailencodingkey='UTF-8', lastname='moodleTestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =false,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // To cover exception part in reminderToCreatePassword() method
    private static testMethod void myTest17(){
    
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
        c.Active_DLS_Online_User__c = FALSE;
        insert c;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        User myUser = new User(alias = 'test123', email='extest123@noemail.com',
            emailencodingkey='UTF-8', lastname='exTestingUsr', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p, country='United States',IsActive =false,
            ContactId = c.Id,
            timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        UserManagementUtil.reminderToCreatePassword(new List<User>{myUser});
    }
    
    // User not exist and Contact RT = 'Commercial_Client'
    private static testMethod void myTest18(){
    
        Id ccRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Commercial_Client').getRecordTypeId();
        Id cpRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Client_Partner').getRecordTypeId();
        
        Account a = new Account(Name = 'Test DLI Acc');
        insert a;
        
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.MiddleName = 'Test';
        c.Email = 'Test.test@gmail.com';
        c.RecordTypeId = ccRTId;
        c.Active_DLS_Online_User__c = FALSE;
        c.AccountId = a.Id;
        insert c;
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        Date startDate = Date.Today();
        
        if(todayVal.format('EEEE') == 'Monday'){
            startDate = Date.Today() + 4;
        }
        
        if(todayVal.format('EEEE') == 'Tuesday' || todayVal.format('EEEE') == 'Wednesday' || 
            todayVal.format('EEEE') == 'Thursday' || todayVal.format('EEEE') == 'Friday'){
            startDate = Date.Today() + 6;
        }
        
        Test.startTest();
        
            Date projSD = Date.Today().addDays(-2);
            Date projED = Date.Today().addDays(60);
            
            List<Account> acc = [SELECT Id, Name FROM Account LIMIT 1];
            
            List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
            
            Id dliRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
            Id usrId = UserInfo.getUserId();
            
            AcctSeed__Project__c proj = new AcctSeed__Project__c(Moodle_Course_Id__c = 'Test Course Id', AcctSeed__Account__c = acc[0].Id, Name = 'Test Moodle Integ Project 18',AcctSeed__Status__c = 'Active',RecordTypeId = dliRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
            insert proj;
                            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = cpRTId, Project__c = proj.Id, Candidate_Name__c = c.Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Client')
            };
            insert conAssignRecs;
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = conAssignRecs[0].Project__c;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
        
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreationOnEveryHour_Schedule sch = new CAbasedUserCreationOnEveryHour_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
}