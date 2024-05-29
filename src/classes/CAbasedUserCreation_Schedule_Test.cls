@isTest
private class CAbasedUserCreation_Schedule_Test{

    @testSetup static void setupMethod(){
    
        List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();
        
        Test.startTest();
            List<Materials_Request__c> matReqs = TestClassUtil.createTestMaterialRequest();
        Test.stopTest();
    }
    
    // User not exist and Contact RT = 'Candidate'
    private static testMethod void myTest1(){
    
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.MiddleName = 'Test';
        c.Email = 'Test.test@gmail.com';
        c.RecordTypeId = candidateRTId;
        c.Active_DLS_Online_User__c = FALSE;
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
        
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Start_Date__c, End_Date__c, Candidate_Name__c, Assignment_Position__c, Paper_Timesheet__c, Project__c FROM Contact_Assignments__c WHERE Status__c IN ('Active', 'Planned') AND RecordType.DeveloperName IN ('Student', 'Instructor') LIMIT 1];
            conAssigns[0].Start_Date__c = startDate;
            conAssigns[0].End_Date__c = Date.Today()+9;
            conAssigns[0].Candidate_Name__c = c.Id;
            conAssigns[0].Assignment_Position__c = 'Instructor';
            conAssigns[0].Paper_Timesheet__c = FALSE;
            update conAssigns[0];
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = conAssigns[0].Project__c;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            List<Contact> contacts = [
                SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName, Beta_Group__c 
                FROM Contact  
                WHERE Id = :conAssigns[0].Candidate_Name__c
            ];
            System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreation_Schedule sch = new CAbasedUserCreation_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // User not exist and Contact RT = 'Candidate'
    private static testMethod void myTest1a(){
    
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
        
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.MiddleName = 'Test';
        c.Email = 'Test.test@gmail.com';
        c.RecordTypeId = candidateRTId;
        c.Active_DLS_Online_User__c = FALSE;
        insert c;
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        Date startDate = Date.Today()+20;
               
        List<Program_Iteration__c> proItrList = new List<Program_Iteration__c> {
            new Program_Iteration__c(Name = 'SLP PI', Total_LT_Class_Hours__c = 85, Total_LT_Prep_Hours__c = 10, Start_Date__c = System.today(), End_Date__c = System.today().addDays(5))
        };
        insert proItrList;
        
        Test.startTest();
        
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Start_Date__c, End_Date__c, Candidate_Name__c, Assignment_Position__c, Paper_Timesheet__c, Project__c FROM Contact_Assignments__c WHERE Status__c IN ('Active', 'Planned') AND RecordType.DeveloperName IN ('Student', 'Instructor') LIMIT 1];
            conAssigns[0].Start_Date__c = startDate;
            conAssigns[0].End_Date__c = Date.Today()+9;
            conAssigns[0].Candidate_Name__c = c.Id;
            conAssigns[0].Assignment_Position__c = 'Instructor';
            conAssigns[0].Paper_Timesheet__c = FALSE;
            update conAssigns[0];
            
            List<AcctSeed__Project__c> projRecs = [SELECT Id, RecordTypeId, Project_Type__c, Program_Iteration__c FROM AcctSeed__Project__c WHERE Id = :conAssigns[0].Project__c];
            projRecs[0].RecordTypeId = dodaRTId;
            projRecs[0].Project_Type__c = 'SLP-PT';
            projRecs[0].Program_Iteration__c =proItrList[0].Id;
            update projRecs[0];
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = projRecs[0].Id;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
                
        List<Contact> contacts = [
            SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName, Beta_Group__c 
            FROM Contact  
            WHERE Id = :conAssigns[0].Candidate_Name__c
        ];
        System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
        
        // Schedule coverage
        String CRON_EXP = '0 0 14 * * ?';
        CAbasedUserCreation_Schedule sch = new CAbasedUserCreation_Schedule();
        system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // User not exist and Contact RT = 'Candidate'
    private static testMethod void myTest2(){
    
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.FirstName = 'Test';
        c.LastName = 'Test';
        c.MiddleName = 'Test';
        c.Email = 'Test_test@gmail.com';
        c.RecordTypeId = candidateRTId;
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
        
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c, Start_Date__c, End_Date__c, Candidate_Name__c, Assignment_Position__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE Status__c IN ('Active', 'Planned') AND RecordType.DeveloperName IN ('Student', 'Instructor') LIMIT 1];
            conAssigns[0].Start_Date__c = startDate;
            conAssigns[0].End_Date__c = Date.Today()+9;
            conAssigns[0].Candidate_Name__c = c.Id;
            conAssigns[0].Assignment_Position__c = 'Instructor';
            conAssigns[0].Paper_Timesheet__c = FALSE;
            update conAssigns[0];
        
            List<Contact> contacts = [
                SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName, Beta_Group__c 
                FROM Contact  
                WHERE Id = :conAssigns[0].Candidate_Name__c
            ];
            System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = conAssigns[0].Project__c;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreation_Schedule sch = new CAbasedUserCreation_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // User not exist and Contact RT = 'Student'
    private static testMethod void myTest3(){
    
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.FirstName = 'Test';
        c.LastName = 'Testtest';
        c.MiddleName = 'Test';
        c.Email = 'test@gmail.com';
        c.RecordTypeId = candidateRTId;
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
        
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c, Start_Date__c, End_Date__c, Candidate_Name__c, Assignment_Position__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE Status__c IN ('Active', 'Planned') AND RecordType.DeveloperName IN ('Student', 'Instructor') LIMIT 1];
            conAssigns[0].Start_Date__c = startDate;
            conAssigns[0].End_Date__c = Date.Today()+9;
            conAssigns[0].Candidate_Name__c = c.Id;
            conAssigns[0].Assignment_Position__c = 'Instructor';
            conAssigns[0].Paper_Timesheet__c = FALSE;
            update conAssigns[0];
            
            List<Contact> contacts = [
                SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName, Beta_Group__c 
                FROM Contact  
                WHERE Id = :conAssigns[0].Candidate_Name__c
            ];
            System.debug('contacts===='+contacts+'contacts SIZE==='+contacts.size());
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = conAssigns[0].Project__c;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreation_Schedule sch = new CAbasedUserCreation_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // User exist and Contact RT = 'Candidate'
    private static testMethod void myTest4(){
    
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        Account a = new Account(Name='Test Account Name');
        insert a;
  
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.FirstName = 'Test';
        c.LastName = 'Testtest';
        c.MiddleName = 'Test';
        c.Email = 'test@gmail.com';
        c.RecordTypeId = candidateRTId;
        c.AccountId = a.id;
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
        
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c, Start_Date__c, End_Date__c, Candidate_Name__c, Assignment_Position__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE Status__c IN ('Active', 'Planned') AND RecordType.DeveloperName IN ('Student', 'Instructor') LIMIT 1];
            conAssigns[0].Start_Date__c = startDate;
            conAssigns[0].End_Date__c = Date.Today()+9;
            conAssigns[0].Candidate_Name__c = c.Id;
            conAssigns[0].Assignment_Position__c = 'Instructor';
            conAssigns[0].Paper_Timesheet__c = FALSE;
            update conAssigns[0];
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = conAssigns[0].Project__c;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            List<Contact> contacts = [
                SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName, Beta_Group__c 
                FROM Contact  
                WHERE Id = :conAssigns[0].Candidate_Name__c
            ];
        
            Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
            System.debug('p=========='+p);
                
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = contacts[0].Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
        
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreation_Schedule sch = new CAbasedUserCreation_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
        Test.stopTest();
    }
    
    // User exist and Contact RT = 'Student'
    private static testMethod void myTest5(){
    
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        Account a = new Account(Name='Test Account Name');
        insert a;
  
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.FirstName = 'Test';
        c.LastName = 'Testtest';
        c.MiddleName = 'Test';
        c.Email = 'test@gmail.com';
        c.RecordTypeId = candidateRTId;
        c.AccountId = a.id;
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
        
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c, Start_Date__c, End_Date__c, Candidate_Name__c, Assignment_Position__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE Status__c IN ('Active', 'Planned') AND RecordType.DeveloperName IN ('Student', 'Instructor') LIMIT 1];
            conAssigns[0].Start_Date__c = startDate;
            conAssigns[0].End_Date__c = Date.Today()+9;
            conAssigns[0].Candidate_Name__c = c.Id;
            conAssigns[0].Assignment_Position__c = 'Instructor';
            conAssigns[0].Paper_Timesheet__c = FALSE;
            update conAssigns[0];
            
            List<Materials__c> mat = [SELECT Id, Name FROM Materials__c LIMIT 1];
            mat[0].Name = 'LMS Enrollment Test';
            update mat[0];
            
            List<Materials_Request__c> matReq = [SELECT Id, Materials_Name__c, Project__c, Request_Status__c FROM Materials_Request__c LIMIT 1];
            matReq[0].Materials_Name__c = mat[0].Id;
            matReq[0].Project__c = conAssigns[0].Project__c;
            matReq[0].Request_Status__c = 'Requested by LTS';
            update matReq[0];
            
            List<Contact> contacts = [
                SELECT Id, Name, FirstName, MiddleName, LastName ,Email,RecordType.DeveloperName, Beta_Group__c 
                FROM Contact  
                WHERE Id = :conAssigns[0].Candidate_Name__c
            ];
        
            Task t = new Task(Subject = 'Watch Timekeeping Training Video', Type = 'To Do', To_Do_Type__c = '10 - Watch Timekeeping Training Video', Status = 'In Progress', WhoId = c.Id);
            insert t;
            
            Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
            System.debug('p=========='+p);
                
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =FALSE,
                    ContactId = contacts[0].Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
        
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreation_Schedule sch = new CAbasedUserCreation_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
        Test.stopTest();
    }
    
    // User not exist and Contact RT = 'Commercial_Client'
    private static testMethod void myTest6(){
    
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
        c.AccountId = a.id;
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
                        
            List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
            
            Id dliRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
            Id usrId = UserInfo.getUserId();
            
            AcctSeed__Project__c proj = new AcctSeed__Project__c(Moodle_Course_Id__c = 'Test Course Id', AcctSeed__Account__c = a.Id, Name = 'Test CA Based User Creation Project 6',AcctSeed__Status__c = 'Active',RecordTypeId = dliRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
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
            CAbasedUserCreation_Schedule sch = new CAbasedUserCreation_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // User exist and Contact RT = 'Candidate'
    private static testMethod void myTest7(){
    
        Id usgClientRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('USG_Client').getRecordTypeId();
        Id cpRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Client_Partner').getRecordTypeId();
        
        Account a = new Account(Name = 'Test DLI Acc');
        insert a;
  
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.FirstName = 'Test';
        c.LastName = 'Testtest';
        c.MiddleName = 'Test';
        c.Email = 'test@gmail.com';
        c.RecordTypeId = usgClientRTId;
        c.AccountId = a.id;
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
                        
            List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
            
            Id dliRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
            Id usrId = UserInfo.getUserId();
            
            AcctSeed__Project__c proj = new AcctSeed__Project__c(Moodle_Course_Id__c = 'Test Course Id', AcctSeed__Account__c = a.Id, Name = 'Test CA Based User Creation Project 7',AcctSeed__Status__c = 'Active',RecordTypeId = dliRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
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
        
            Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
                
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
        
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreation_Schedule sch = new CAbasedUserCreation_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
        Test.stopTest();
    }
    
    // DLI User Course Enrolment
    private static testMethod void myTest8(){
    
        Id usgClientRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('USG_Client').getRecordTypeId();
        Id cpRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Client_Partner').getRecordTypeId();
        
        Account a = new Account(Name = 'Test DLI Acc');
        insert a;
  
        Contact c = new Contact();
        c.Beta_Group__c = TRUE;
        c.FirstName = 'Test';
        c.LastName = 'Testtest';
        c.MiddleName = 'Test';
        c.Email = 'test@gmail.com';
        c.RecordTypeId = usgClientRTId;
        c.AccountId = a.id;
        c.Moodle_User_Status__c = 'Active';
        c.Moodle_User_Id__c = 'Test User Id';
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
            
            List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
            
            Id dliRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
            Id usrId = UserInfo.getUserId();
            
            AcctSeed__Project__c proj = new AcctSeed__Project__c(Moodle_Course_Id__c = 'Test Course Id', AcctSeed__Account__c = a.Id, Name = 'Test CA Based User Creation Project 8',AcctSeed__Status__c = 'Active',RecordTypeId = dliRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
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
        
            Id p = [SELECT Id FROM Profile WHERE Name='Staff Community'].Id;
                
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='TestingUsr', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
        
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            CAbasedUserCreation_Schedule sch = new CAbasedUserCreation_Schedule();
            system.schedule('CA Based User Creation', CRON_EXP, sch);
        Test.stopTest();
    }
}