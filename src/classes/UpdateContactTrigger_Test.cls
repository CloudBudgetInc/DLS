@isTest
public class UpdateContactTrigger_Test {

    @testsetup static void setup() {
        //  List<User> usrlist = TestClassUtil.createTestUsers();
        //  List<Opportunity> oppList = TestClassUtil.createTestOpportunities();
        List<Contact_Assignments__c > conAssList = TestClassUtil.createTestContactAssignment();
        Test.startTest();
        
            List<AcctSeed__Project_Task__c > projTask = TestClassUtil.createTestProjectTask();
            
            List<System_Values__c> sysValues = new List<System_Values__c>{
                new System_Values__c(Name ='Get Feedback Response Email - Default', Value__c = 'hemalatha@softsquare.biz'),
                new System_Values__c(Name ='Get Feedback Response Email - DODA', Value__c = 'hemalatha@softsquare.biz'),
                new System_Values__c(Name ='Get Feedback Response Email - DLI', Value__c = 'hemalatha@softsquare.biz')
            };
            insert sysValues;
        Test.stopTest();   
    }
    
    // Active Supervisor
    static testMethod void UpdateContacttest1() {
        Test.startTest();

        //   List<Opportunity> OppRecList = [SELECT Id,Name FROM Opportunity LIMIT 2];
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'first',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r.Id
        );
        
        
        system.runAs(u){
        
        List < RecordType > conrt = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact'
            AND DeveloperName = 'DLS_Employee'
        ];
        List < AcctSeed__Project__c > projectList = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 3];
        List < Contact_Assignments__c > conAss = [SELECT Id, Name, Project__c, Candidate_Name__c, Assignment_Position__c, RecordTypeId, Status__c FROM Contact_Assignments__c WHERE Candidate_Name__c != Null];
        List < RecordType > rtConAss = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact_Assignments__c'
            AND DeveloperName = 'Staff'
        ];
        List < Profile > Profile = [SELECT Id FROM Profile WHERE Name = 'DLS Instructor'];
        //  list<user> userList = [select id from user where CustomerPortalUser = true and contact : objeContact.ID];
        system.debug(':::Profile' + Profile);

        String un = String.valueOf(System.now().millisecond()) + '@dlsTestOrg.dlsdc';
        String en = String.valueOf(System.now().millisecond()) + '@dlsTestOrg.com';

        Account a = new Account(Name = 'Test Account Name');
        insert a;

        List < Contact > con1 = new List < Contact > {
            new Contact(recordtypeid = '01260000000LunbAAC',DLS_Candidate_Rating__c = '0', Candidate_Notes__c = 'long long text',firstname='re', LastName = 'Testing Contact', AccountId = a.Id, Last_Notes_Update__c = system.today(), Last_rating_update__c = system.today())
        };

        insert con1;

        con1[0].lastname='name change';
        con1[0].firstname = 'name change ';
        con1[0].Email = 'gowthamjohn261@gmail.com';
        con1[0].MobilePhone= '9597296919';
        con1[0].MailingState= 'tnm';
        con1[0].MailingCountry= 'india';
        con1[0].Phone = '(758) 771-0091';
        con1[0].MailingPostalCode = '638057';
        con1[0].DLS_Candidate_Rating__c = '1';
        con1[0].Candidate_Notes__c = 'first';
        con1[0].First_Performance_Review_Date__c = null;
        con1[0].Original_Hire_Date__c = system.today();
        con1[0].MailingCity = 'erode';
        con1[0].Supervisor_Name__c = u.id; 
        update con1;

        User usr = new User(Alias = 'standt', Email = 'test@gmail.com', EmailEncodingKey = 'UTF-8', LastName = con1[0].LastName,
            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Profile[0].Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = un, ContactId = con1[0].Id);

        insert usr;

        if (conAss != Null && conAss.size() > 0 && rtConAss != Null && rtConAss.size() > 0) {
            conAss[0].RecordTypeId = rtConAss[0].Id;
            conAss[0].Project__c = projectList[0].Id;
            conAss[0].Status__c = 'Active';
            conAss[0].Assignment_Position__c = 'Project Manager';
        }
        update conAss;

        if (projectList != Null && projectList.size() > 0) { //OppRecList.size() > 0 && 

            //  OppRecList[0].Supervisor__c = usr.Id;
            //   OppRecList[1].Supervisor__c = usr.Id;

            //   update OppRecList;
            //   system.debug(':::::OppRecList::::::'+OppRecList);

            List < Get_Feedback__c > getFeedBackList = new List < Get_Feedback__c > {
                new Get_Feedback__c(Name = 'Test Record 1', Project__c = projectList[0].Id), //Opportunity__c = OppRecList[0].Id,
                    new Get_Feedback__c(Name = 'Test Record 2', Project__c = projectList[2].Id) //Opportunity__c = OppRecList[1].Id,
            };

            system.debug(':::::getFeedBackList::::::' + getFeedBackList);
            insert getFeedBackList;

            List < Get_Feedback__c > getFeedBack = [SELECT Id, Name, Supervisor_Project_Manager__c FROM Get_Feedback__c WHERE Id = : getFeedBackList[0].Id];

            // Contact assignment Candidate_Name__c is assigned to get feedBack Supervisor_Project_Manager__c
            System.assertEquals(conAss[0].Candidate_Name__c, getFeedBack[0].Supervisor_Project_Manager__c);
        }
        
        }
        
        Test.stopTest();
    }
    
    // Ended Supervisor
    static testMethod void UpdateContacttest2() {
        Test.startTest();

        //   List<Opportunity> OppRecList = [SELECT Id,Name FROM Opportunity LIMIT 2];
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'first',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r.Id
        );
        
        
        system.runAs(u){
        
        List < RecordType > conrt = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact'
            AND DeveloperName = 'DLS_Employee'
        ];
        List < AcctSeed__Project__c > projectList = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 3];
        List < Contact_Assignments__c > conAss = [SELECT Id, Name, Project__c, Candidate_Name__c, Assignment_Position__c, RecordTypeId, Status__c, End_Date__c FROM Contact_Assignments__c WHERE Candidate_Name__c != Null];
        List < RecordType > rtConAss = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact_Assignments__c'
            AND DeveloperName = 'Staff'
        ];
        List < RecordType > rtFeedback = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Get_Feedback__c'
            AND DeveloperName = 'Ending_Feedback'
        ];
        List < Profile > Profile = [SELECT Id FROM Profile WHERE Name = 'DLS Instructor'];
        //  list<user> userList = [select id from user where CustomerPortalUser = true and contact : objeContact.ID];
        system.debug(':::Profile' + Profile);

        String un = String.valueOf(System.now().millisecond()) + '@dlsTestOrg.dlsdc';
        String en = String.valueOf(System.now().millisecond()) + '@dlsTestOrg.com';

        Account a = new Account(Name = 'Test Account Name');
        insert a;

        List < Contact > con1 = new List < Contact > {
            new Contact(recordtypeid = '01260000000LunbAAC',DLS_Candidate_Rating__c = '0', Candidate_Notes__c = 'long long text',firstname='re', LastName = 'Testing Contact', AccountId = a.Id, Last_Notes_Update__c = system.today(), Last_rating_update__c = system.today())
        };

        insert con1;

        con1[0].lastname='name change';
        con1[0].firstname = 'name change ';
        con1[0].Email = 'gowthamjohn261@gmail.com';
        con1[0].MobilePhone= '9597296919';
        con1[0].MailingState= 'tnm';
        con1[0].MailingCountry= 'india';
        con1[0].Phone = '(758) 771-0091';
        con1[0].MailingPostalCode = '638057';
        con1[0].DLS_Candidate_Rating__c = '1';
        con1[0].Candidate_Notes__c = 'first';
        con1[0].First_Performance_Review_Date__c = null;
        con1[0].Original_Hire_Date__c = system.today();
        con1[0].MailingCity = 'erode';
        con1[0].Supervisor_Name__c = u.id; 
        update con1;

        User usr = new User(Alias = 'standt', Email = 'test@gmail.com', EmailEncodingKey = 'UTF-8', LastName = con1[0].LastName,
            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Profile[0].Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = un, ContactId = con1[0].Id);

        insert usr;

        if (conAss != Null && conAss.size() > 0 && rtConAss != Null && rtConAss.size() > 0) {
            conAss[0].RecordTypeId = rtConAss[0].Id;
            conAss[0].Project__c = projectList[0].Id;
            conAss[0].Status__c = 'Ended';
            conAss[0].End_Date__c = Date.Today()-1;
            conAss[0].Assignment_Position__c = 'Project Manager';
        }
        update conAss;

        if (projectList != Null && projectList.size() > 0) { //OppRecList.size() > 0 && 

            //  OppRecList[0].Supervisor__c = usr.Id;
            //   OppRecList[1].Supervisor__c = usr.Id;

            //   update OppRecList;
            //   system.debug(':::::OppRecList::::::'+OppRecList);

            List < Get_Feedback__c > getFeedBackList = new List < Get_Feedback__c > {
                new Get_Feedback__c(Name = 'Test Record 1', Project__c = projectList[0].Id, recordTypeId = rtFeedback[0].Id), //Opportunity__c = OppRecList[0].Id,
                    new Get_Feedback__c(Name = 'Test Record 2', Project__c = projectList[2].Id, recordTypeId = rtFeedback[0].Id) //Opportunity__c = OppRecList[1].Id,
            };

            system.debug(':::::getFeedBackList::::::' + getFeedBackList);
            insert getFeedBackList;

            List < Get_Feedback__c > getFeedBack = [SELECT Id, Name, Supervisor_Project_Manager__c FROM Get_Feedback__c WHERE Id = : getFeedBackList[0].Id];

            // Contact assignment Candidate_Name__c is assigned to get feedBack Supervisor_Project_Manager__c
            System.assertEquals(conAss[0].Candidate_Name__c, getFeedBack[0].Supervisor_Project_Manager__c);
        }
        
        }
        
        Test.stopTest();
    }

    // On Hold Supervisor
    static testMethod void UpdateContacttest3() {
        Test.startTest();

        //   List<Opportunity> OppRecList = [SELECT Id,Name FROM Opportunity LIMIT 2];
        UserRole r = new UserRole(DeveloperName = 'MyCustomRole', Name = 'My Role');
        insert r;
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'first',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId = r.Id
        );
        
        
        system.runAs(u){
        
        List < RecordType > conrt = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact'
            AND DeveloperName = 'DLS_Employee'
        ];
        List < AcctSeed__Project__c > projectList = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 3];
        List < Contact_Assignments__c > conAss = [SELECT Id, Name, Project__c, Candidate_Name__c, Assignment_Position__c, RecordTypeId, Status__c FROM Contact_Assignments__c WHERE Candidate_Name__c != Null];
        List < RecordType > rtConAss = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact_Assignments__c'
            AND DeveloperName = 'Staff'
        ];
        List < RecordType > rtFeedback = [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Get_Feedback__c'
            AND DeveloperName = 'Ending_Feedback'
        ];
        List < Profile > Profile = [SELECT Id FROM Profile WHERE Name = 'DLS Instructor'];
        //  list<user> userList = [select id from user where CustomerPortalUser = true and contact : objeContact.ID];
        system.debug(':::Profile' + Profile);

        String un = String.valueOf(System.now().millisecond()) + '@dlsTestOrg.dlsdc';
        String en = String.valueOf(System.now().millisecond()) + '@dlsTestOrg.com';

        Account a = new Account(Name = 'Test Account Name');
        insert a;

        List < Contact > con1 = new List < Contact > {
            new Contact(recordtypeid = '01260000000LunbAAC',DLS_Candidate_Rating__c = '0', Candidate_Notes__c = 'long long text',firstname='re', LastName = 'Testing Contact', AccountId = a.Id, Last_Notes_Update__c = system.today(), Last_rating_update__c = system.today())
        };

        insert con1;

        con1[0].lastname='name change';
        con1[0].firstname = 'name change ';
        con1[0].Email = 'gowthamjohn261@gmail.com';
        con1[0].MobilePhone= '9597296919';
        con1[0].MailingState= 'tnm';
        con1[0].MailingCountry= 'india';
        con1[0].Phone = '(758) 771-0091';
        con1[0].MailingPostalCode = '638057';
        con1[0].DLS_Candidate_Rating__c = '1';
        con1[0].Candidate_Notes__c = 'first';
        con1[0].First_Performance_Review_Date__c = null;
        con1[0].Original_Hire_Date__c = system.today();
        con1[0].MailingCity = 'erode';
        con1[0].Supervisor_Name__c = u.id; 
        update con1;

        User usr = new User(Alias = 'standt', Email = 'test@gmail.com', EmailEncodingKey = 'UTF-8', LastName = con1[0].LastName,
            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = Profile[0].Id,
            TimeZoneSidKey = 'America/Los_Angeles', UserName = un, ContactId = con1[0].Id);

        insert usr;

        if (conAss != Null && conAss.size() > 0 && rtConAss != Null && rtConAss.size() > 0) {
            conAss[0].RecordTypeId = rtConAss[0].Id;
            conAss[0].Project__c = projectList[0].Id;
            conAss[0].Status__c = 'On Hold';
            conAss[0].Assignment_Position__c = 'Project Manager';
        }
        update conAss;
        
        if (projectList != Null && projectList.size() > 0) { //OppRecList.size() > 0 && 

            //  OppRecList[0].Supervisor__c = usr.Id;
            //   OppRecList[1].Supervisor__c = usr.Id;

            //   update OppRecList;
            //   system.debug(':::::OppRecList::::::'+OppRecList);

            List < Get_Feedback__c > getFeedBackList = new List < Get_Feedback__c > {
                new Get_Feedback__c(Name = 'Test Record 1', Project__c = projectList[0].Id), //Opportunity__c = OppRecList[0].Id,
                    new Get_Feedback__c(Name = 'Test Record 2', Project__c = projectList[2].Id) //Opportunity__c = OppRecList[1].Id,
            };

            system.debug(':::::getFeedBackList::::::' + getFeedBackList);
            insert getFeedBackList;

            List < Get_Feedback__c > getFeedBack = [SELECT Id, Name, Supervisor_Project_Manager__c FROM Get_Feedback__c WHERE Id = : getFeedBackList[0].Id];

            // Contact assignment Candidate_Name__c is assigned to get feedBack Supervisor_Project_Manager__c
            //System.assertEquals(conAss[0].Candidate_Name__c, getFeedBack[0].Supervisor_Project_Manager__c);
        }
        
        }
        
        Test.stopTest();
    }
    
    // To update Contact_Record_Type__c field value in Cost Rate record when Contact RecordType is changed
    public static testMethod void toUpdateCRTestMethod() {

        Id partnerRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Partner').getRecordTypeId();
        Id studentRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();

        List < Contact > contacts = [SELECT ID, RecordTypeId FROM Contact WHERE RecordTypeId = : studentRTId];
        System.debug('contacts=====' + contacts + 'contacts SIZE=======' + contacts.size());
        List < AcctSeed__Project__c > projList = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        List < AcctSeed__Project_Task__c > projTask = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN: projList LIMIT 1];

        List < AcctSeed__Cost_Rates__c > costRates = new List < AcctSeed__Cost_Rates__c > {
            new AcctSeed__Cost_Rates__c(Contact__c = contacts[0].Id, Status__c = 'Draft', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT', AcctSeed__Hourly_Cost__c = 43, Payroll_Item__c = 'R'),
                new AcctSeed__Cost_Rates__c(Contact__c = contacts[0].Id, Status__c = 'Approved', AcctSeed__Project__c = projList[0].Id, AcctSeed__Project_Task__c = projTask[0].Id, Exempt_Status__c = 'Non-Exempt', Pay_Type__c = 'Hourly', Rate_Type__c = 'DLI-21 SCA LT', AcctSeed__Hourly_Cost__c = 43, Payroll_Item__c = 'R')
        };
        
        Test.startTest();
            insert costRates;
    
            contacts[0].RecordTypeId = partnerRTId;
            update contacts;
    
            List < AcctSeed__Cost_Rates__c > costRateRecs = [SELECT Id, Contact_Record_Type__c FROM AcctSeed__Cost_Rates__c WHERE Id IN: costRates];
            System.assertEquals('Partner', costRateRecs[0].Contact_Record_Type__c);
        Test.stopTest();
    }
    
    // To update Evaluate_Candidate_Profile_Rating__c field in Contact
    public static testMethod void toUpdateProfileRating(){
    
        List<Contact> contacts = [SELECT Id,Evaluate_Candidate_Profile_Rating__c, dls_candidate_rating__c, of_related_Skills__c FROM Contact];
        System.debug('contacts ========='+contacts);
        
        contacts[0].Evaluate_Candidate_Profile_Rating__c = TRUE;
        contacts[0].dls_candidate_rating__c = '4';
        contacts[0].of_related_Skills__c = 8;
        
        Test.startTest();
            update contacts;
        Test.stopTest();
    }
    
    // to update Instructor__c field in Get_Feedback__c 
    public static testMethod void toUpdateInstructor(){
    
        Id endOfTrainingRTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('Ending_Feedback').getRecordTypeId();
        Id weekfeedbackRTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('weekly_feedback').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        System.debug('conAssigns=========='+conAssigns);
        
        List < Get_Feedback__c > feedbacks = new List < Get_Feedback__c > {
            new Get_Feedback__c(Name = 'Test Feedback 1', Project__c = conAssigns[0].Project__c, Instructor_Name__c = conAssigns[0].Candidate_Name__r.Name, RecordTypeId = endOfTrainingRTId), 
            new Get_Feedback__c(Name = 'Test Feedback 2', Project__c = conAssigns[0].Project__c, Instructor_Name__c = conAssigns[0].Candidate_Name__r.Name, RecordTypeId = weekfeedbackRTId) 
        };
        
        Test.startTest();
            insert feedbacks;
            
            List<Get_Feedback__c> feedbackList = [SELECT Id, Instructor__c FROM Get_Feedback__c WHERE Id IN :feedbacks];
            System.debug('feedbackList==========='+feedbackList);
            
            System.assertEquals(conAssigns[0].Candidate_Name__c, feedbackList[0].Instructor__c );
            System.assertEquals(NULL, feedbackList[1].Instructor__c );
        Test.stopTest();
    }
    
    // Test method to show the validation message
    public static testMethod void toShowValidationMsg1(){
    
        Id endOfTrainingRTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('Ending_Feedback').getRecordTypeId();
        Id weekfeedbackRTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('weekly_feedback').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        System.debug('conAssigns=========='+conAssigns);
        
        List < Get_Feedback__c > feedbacks = new List < Get_Feedback__c > {
            new Get_Feedback__c(Name = 'Test Feedback 1', Project__c = conAssigns[0].Project__c, Instructor_Name__c = 'Test Contact', RecordTypeId = endOfTrainingRTId), 
            new Get_Feedback__c(Name = 'Test Feedback 2', Project__c = conAssigns[0].Project__c, Instructor_Name__c = 'Demo Contact', RecordTypeId = weekfeedbackRTId) 
        };
        insert feedbacks;
        
        List<Get_Feedback__c> feedbackList = [SELECT Id, Instructor__c FROM Get_Feedback__c WHERE Id IN :feedbacks];
        System.debug('feedbackList==========='+feedbackList);
        
        Test.startTest();
            try{
            
                feedbackList[0].Instructor__c = conAssigns[0].Candidate_Name__c;
                update feedbackList[0];
            }catch(Exception e){
            
                System.debug('MESSAGE=========='+e.getMessage());
                //System.assert(e.getMessage().contains('The Selected Contact name doesn\'t match with the \"Instructor Name\", Please verify the \"Instructor Name\"'));
            }
        Test.stopTest();
    }
    
    public static testMethod void toShowValidationMsg2(){
    
        Id endOfTrainingRTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('Ending_Feedback').getRecordTypeId();
        Id weekfeedbackRTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('weekly_feedback').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        System.debug('conAssigns=========='+conAssigns);
        
        //List<AcctSeed__Project__c> proj = [SELECT Id, Name, Oral_Exam_Date_Time__c FROM AcctSeed__Project__c LIMIT 1];
        List<Contact> con = [SELECT Id FROM Contact LIMIT 2];
        
        List < Get_Feedback__c > feedbacks = new List < Get_Feedback__c > {
            new Get_Feedback__c(Name = 'Test Feedback 1', Project__c = conAssigns[0].Project__c, Instructor_Name__c = 'Test Contact', RecordTypeId = endOfTrainingRTId), 
            new Get_Feedback__c(Name = 'Test Feedback 2', Project__c = conAssigns[0].Project__c, Instructor_Name__c = 'Demo Contact', RecordTypeId = weekfeedbackRTId) 
        };
        insert feedbacks;
        
        List<Get_Feedback__c> feedbackList = [SELECT Id, Instructor__c FROM Get_Feedback__c WHERE Id IN :feedbacks];
        System.debug('feedbackList==========='+feedbackList);
        System.debug('con:::::::'+con);
        Test.startTest();
            try{
            
                feedbackList[0].Instructor__c = con[1].Id;
                update feedbackList[0];
            }catch(Exception e){
            
                System.debug('MESSAGE=========='+e.getMessage());
                //System.assert(e.getMessage().contains('The Selected Contact name doesn\'t match with the "Instructor Name", Please verify the "Instructor Name"'));
            }
        Test.stopTest();
    }
    
    public static testMethod void toShowValidationMsg3(){
    
        Id endOfTrainingRTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('Ending_Feedback').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        System.debug('conAssigns=========='+conAssigns);
                
        List < Get_Feedback__c > feedbacks = new List < Get_Feedback__c > {
            new Get_Feedback__c(Name = 'Test Feedback 1', Project__c = conAssigns[0].Project__c, RecordTypeId = endOfTrainingRTId)
        };
        insert feedbacks;
        
        List<Get_Feedback__c> feedbackList = [SELECT Id, Instructor__c FROM Get_Feedback__c WHERE Id IN :feedbacks];
        System.debug('feedbackList==========='+feedbackList);
        
        Test.startTest();
            try{
                
                feedbackList[0].Instructor_Name__c = conAssigns[0].Candidate_Name__r.Name;
                feedbackList[0].Instructor__c = conAssigns[0].Candidate_Name__c;
                update feedbackList[0];
            }catch(Exception e){
            
                System.debug('MESSAGE=========='+e.getMessage());
            }
        Test.stopTest();
    }
    
    public static testMethod void toShowValidationMsg4(){
    
        Id endOfTrainingRTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('Ending_Feedback').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
                
        List<AcctSeed__Project__c> proj = [SELECT Id, Name, Oral_Exam_Date_Time__c FROM AcctSeed__Project__c WHERE Id !=:conAssigns[0].Project__c  LIMIT 1];
        
        List < Get_Feedback__c > feedbacks = new List < Get_Feedback__c > {
            new Get_Feedback__c(Name = 'Test Feedback 1', Project__c = conAssigns[0].Project__c, RecordTypeId = endOfTrainingRTId),
            new Get_Feedback__c(Name = 'Test Feedback 1', Project__c = proj[0].Id, RecordTypeId = endOfTrainingRTId)
        };
        insert feedbacks;
        
        List<Get_Feedback__c> feedbackList = [SELECT Id, Instructor__c FROM Get_Feedback__c WHERE Id IN :feedbacks];
        
        Test.startTest();
            try{
                
                feedbackList[0].Instructor_Name__c = conAssigns[0].Candidate_Name__r.Name;
                feedbackList[0].Instructor__c = conAssigns[0].Candidate_Name__c;
                feedbackList[1].Instructor_Name__c = conAssigns[0].Candidate_Name__r.Name;
                feedbackList[1].Instructor__c = conAssigns[0].Candidate_Name__c;
                update feedbackList;
            }catch(Exception e){
            
                System.debug('MESSAGE=========='+e.getMessage());
            }
        Test.stopTest();
    }
    
    public static testMethod void sendResponseEmailToUser_Test1(){
            
        Account a = new Account(Name = 'DLI Test Acc');
        insert a;
        
         List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
         
        Id weeklyRTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('weekly_feedback').getRecordTypeId();
        Id monthlyRTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('Monthly_Feedback_Survey').getRecordTypeId();
                        
        List<AcctSeed__Project__c> proj = [SELECT Id, Name, Section__c, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        proj[0].Section__c = 'AA';
        proj[0].AcctSeed__Account__c = a.Id;
        update proj[0];
                
        List<Get_Feedback__c>  getFeedbacks = new List<Get_Feedback__c>{
            new Get_Feedback__c(Name = 'Test Feedback 1', Project__c = proj[0].Id, RecordTypeId = weeklyRTId, Sent_Responce__c = False, Contact__c = stdCon[0].Id),
            new Get_Feedback__c(Name = 'Test Feedback 2', Project__c = proj[0].Id, RecordTypeId = monthlyRTId, Sent_Responce__c = False, Contact__c = stdCon[1].Id)
        };
        insert getFeedbacks;
    }
    
    public static testMethod void sendResponseEmailToUser_Test2(){
            
        Account a = new Account(Name = 'DODA Test Acc');
        insert a;
                
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 3];
         
        Id eotRTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('Ending_Feedback').getRecordTypeId();
        Id ins_EOT_RTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('End_of_Training_Evaluation_Instructor').getRecordTypeId();
        Id vr_RTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('VR_Survey').getRecordTypeId();
                        
        List<AcctSeed__Project__c> proj = [SELECT Id, Name, Section__c, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        proj[0].Section__c = 'AA';
        proj[0].AcctSeed__Account__c = a.Id;
        update proj[0];
                
        List<Get_Feedback__c>  getFeedbacks = new List<Get_Feedback__c>{
            new Get_Feedback__c(Name = 'Test Feedback 1', Project__c = proj[0].Id, RecordTypeId = eotRTId, Sent_Responce__c = False, Contact__c = stdCon[0].Id),
            new Get_Feedback__c(Name = 'Test Feedback 2', Project__c = proj[0].Id, RecordTypeId = ins_EOT_RTId, Sent_Responce__c = False, Contact__c = stdCon[1].Id),
            new Get_Feedback__c(Name = 'Test Feedback 3', Project__c = proj[0].Id, RecordTypeId = vr_RTId, Sent_Responce__c = False, Contact__c = stdCon[2].Id)
        };
        insert getFeedbacks;
    }
    
    public static testMethod void sendResponseEmailToUser_Test3(){
            
        Account a = new Account(Name = 'DODA Test Acc');
        insert a;
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
         
        Id doda_EOT_RTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('DODA_End_of_Training_Survey').getRecordTypeId();
                        
        List<AcctSeed__Project__c> proj = [SELECT Id, Name, Section__c, AcctSeed__Account__c FROM AcctSeed__Project__c LIMIT 1];
        proj[0].Section__c = 'AA';
        proj[0].AcctSeed__Account__c = a.Id;
        update proj[0];
                
        List<Get_Feedback__c>  getFeedbacks = new List<Get_Feedback__c>{
            new Get_Feedback__c(Name = 'Test Feedback 1', Project__c = proj[0].Id, RecordTypeId = doda_EOT_RTId, Sent_Responce__c = False, Contact__c = stdCon[0].Id)
        };
        insert getFeedbacks;
    }
}