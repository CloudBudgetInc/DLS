@isTest
private class ContactRollupHelperBatch_Schedule_Test{

    @testSetup static void setupMethod(){
    
        List<Contact> contacts= TestClassUtil.createTestContacts();
        List<AcctSeed__Project__c> projects = TestClassUtil.createTestProject();
        
        //Insert Paper Timesheet custom setting
        List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'True')};
        Insert sysVal;
    }
    
    // of_Class_Projects_Taught__c value changed from null to not null
    private static testMethod void rollUpTestMethod1(){
    
        Set<String> conRTNames = new Set<String>{'Candidate', 'DLS_Employee'};
        Set<String> projRTNames = new Set<String>{'Language_Training_Projects', 'Testing_Projects'};
        
        List<Contact> conList = [SELECT Id, RecordTypeId, of_Class_Projects_Taught__c, of_Students_Taught__c, of_Tests_Perfomed__c FROM Contact WHERE RecordType.DeveloperName IN :conRTNames LIMIT 1];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName IN :projRTNames LIMIT 1];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        Test.startTest();
            List<Contact_Assignments__c> conAssigns = new List<Contact_Assignments__c>{
            
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projects[0].Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Opportunity_Name__c = projects[0].AcctSeed__Opportunity__c, Status__c = 'Active', Assignment_Position__c = 'Instructor'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projects[0].Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today(), Opportunity_Name__c = projects[0].AcctSeed__Opportunity__c, Status__c = 'Ended', Assignment_Position__c = 'Instructor')
            };
            insert conAssigns;
                                    
            // Schedule coverage
            String CRON_EXP = '0 0 1 * * ?';
            ContactRollupHelperBatch_Schedule sch = new ContactRollupHelperBatch_Schedule();
            system.schedule('Rollup Contact fields', CRON_EXP, sch);
        Test.stopTest();        
        
        List<Contact> conList1 = [SELECT Id, RecordTypeId, of_Class_Projects_Taught__c FROM Contact WHERE Id = :conList[0].Id];
    }
    
    // of_Tests_Perfomed__c value changed from null to not null
    private static testMethod void rollUpTestMethod2(){
    
        Set<String> conRTNames = new Set<String>{'Candidate', 'DLS_Employee'};
        
        List<Contact> conList = [SELECT Id, RecordTypeId, of_Class_Projects_Taught__c, of_Students_Taught__c, of_Tests_Perfomed__c FROM Contact WHERE RecordType.DeveloperName IN :conRTNames LIMIT 1];
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id testProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        AcctSeed__Project__c projects = new AcctSeed__Project__c(Name = 'Test Con Rollup Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = testProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert projects;
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        Test.startTest();
            List<Contact_Assignments__c> conAssigns = new List<Contact_Assignments__c>{
            
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projects.Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Opportunity_Name__c = projects.AcctSeed__Opportunity__c, Status__c = 'Active', Assignment_Position__c = 'Instructor'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projects.Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today(), Opportunity_Name__c = projects.AcctSeed__Opportunity__c, Status__c = 'Ended', Assignment_Position__c = 'Instructor')
            };
            insert conAssigns;
         
            // Schedule coverage
            String CRON_EXP = '0 0 1 * * ?';
            ContactRollupHelperBatch_Schedule sch = new ContactRollupHelperBatch_Schedule();
            system.schedule('Rollup Contact fields', CRON_EXP, sch);
        Test.stopTest();
    }
    
    // of_Students_Taught__c value changed from null to not null
    private static testMethod void rollUpTestMethod3(){
    
        Set<String> conRTNames = new Set<String>{'Candidate', 'DLS_Employee'};
        Set<String> projRTNames = new Set<String>{'Language_Training_Projects', 'Testing_Projects'};
        
        List<Contact> conList = [SELECT Id, RecordTypeId, of_Class_Projects_Taught__c, of_Students_Taught__c, of_Tests_Perfomed__c FROM Contact WHERE RecordType.DeveloperName IN :conRTNames LIMIT 1];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName IN :projRTNames LIMIT 1];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        Test.startTest();
            Contact_Assignments__c insCA = new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projects[0].Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Opportunity_Name__c = projects[0].AcctSeed__Opportunity__c, Status__c = 'Active', Assignment_Position__c = 'Instructor');
            insert insCA;
            
            Contact_Assignments__c stdCA = new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = projects[0].Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Opportunity_Name__c = projects[0].AcctSeed__Opportunity__c, Status__c = 'Active');
            //insert stdCA;
            
            List<Contact_Assignments__c> stdCAs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = projects[0].Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Opportunity_Name__c = projects[0].AcctSeed__Opportunity__c, Status__c = 'Active'),
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = projects[0].Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today(), Opportunity_Name__c = projects[0].AcctSeed__Opportunity__c, Status__c = 'Ended')
            };
            insert stdCAs;
                                                
            // Schedule coverage
            String CRON_EXP = '0 0 1 * * ?';
            ContactRollupHelperBatch_Schedule sch = new ContactRollupHelperBatch_Schedule();
            system.schedule('Rollup Contact fields', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // of_Class_Projects_Taught__c value changed from not null to not null
    private static testMethod void rollUpTestMethod4(){
    
        Set<String> conRTNames = new Set<String>{'Candidate', 'DLS_Employee'};
        Set<String> projRTNames = new Set<String>{'Language_Training_Projects', 'Testing_Projects'};
        
        List<Contact> conList = [SELECT Id, RecordTypeId, of_Class_Projects_Taught__c, of_Students_Taught__c, of_Tests_Perfomed__c FROM Contact WHERE RecordType.DeveloperName IN :conRTNames LIMIT 1];
        conList[0].of_Class_Projects_Taught__c = 1;
        update conList[0];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName IN :projRTNames LIMIT 1];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        Test.startTest();
            List<Contact_Assignments__c> conAssigns = new List<Contact_Assignments__c>{
            
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projects[0].Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Opportunity_Name__c = projects[0].AcctSeed__Opportunity__c, Status__c = 'Active', Assignment_Position__c = 'Instructor'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projects[0].Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today(), Opportunity_Name__c = projects[0].AcctSeed__Opportunity__c, Status__c = 'Ended', Assignment_Position__c = 'Instructor')
            };
            insert conAssigns;
            
            // Schedule coverage
            String CRON_EXP = '0 0 1 * * ?';
            ContactRollupHelperBatch_Schedule sch = new ContactRollupHelperBatch_Schedule();
            system.schedule('Rollup Contact fields', CRON_EXP, sch);
        Test.stopTest();
    }
    
    // of_Tests_Perfomed__c value changed from not null to not null
    private static testMethod void rollUpTestMethod5(){
    
        Set<String> conRTNames = new Set<String>{'Candidate', 'DLS_Employee'};
        
        List<Contact> conList = [SELECT Id, RecordTypeId, of_Class_Projects_Taught__c, of_Students_Taught__c, of_Tests_Perfomed__c FROM Contact WHERE RecordType.DeveloperName IN :conRTNames LIMIT 1];
        conList[0].of_Tests_Perfomed__c = 1;
        update conList[0];
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        Id testProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        AcctSeed__Project__c projects = new AcctSeed__Project__c(Name = 'Test Con Rollup Project 2',AcctSeed__Status__c = 'Active',RecordTypeId = testProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert projects;
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        Test.startTest();
            List<Contact_Assignments__c> conAssigns = new List<Contact_Assignments__c>{
            
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projects.Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Opportunity_Name__c = projects.AcctSeed__Opportunity__c, Status__c = 'Active', Assignment_Position__c = 'Instructor'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projects.Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today(), Opportunity_Name__c = projects.AcctSeed__Opportunity__c, Status__c = 'Ended', Assignment_Position__c = 'Instructor')
            };
            insert conAssigns;
      
            // Schedule coverage
            String CRON_EXP = '0 0 1 * * ?';
            ContactRollupHelperBatch_Schedule sch = new ContactRollupHelperBatch_Schedule();
            system.schedule('Rollup Contact fields', CRON_EXP, sch);
        Test.stopTest();
    }
    
    // of_Students_Taught__c value changed from not null to not null
    private static testMethod void rollUpTestMethod6(){
    
        Set<String> conRTNames = new Set<String>{'Candidate', 'DLS_Employee'};
        Set<String> projRTNames = new Set<String>{'Language_Training_Projects', 'Testing_Projects'};
        
        List<Contact> conList = [SELECT Id, RecordTypeId, of_Class_Projects_Taught__c, of_Students_Taught__c, of_Tests_Perfomed__c FROM Contact WHERE RecordType.DeveloperName IN :conRTNames LIMIT 1];
        conList[0].of_Students_Taught__c = 2;
        update conList[0];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName IN :projRTNames LIMIT 1];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        Test.startTest();
            Contact_Assignments__c insCA = new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projects[0].Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Opportunity_Name__c = projects[0].AcctSeed__Opportunity__c, Status__c = 'Active', Assignment_Position__c = 'Instructor');
            insert insCA;
            
            Contact_Assignments__c stdCA1 = new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = projects[0].Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Opportunity_Name__c = projects[0].AcctSeed__Opportunity__c, Status__c = 'Active');
            insert stdCA1;
            
            Contact_Assignments__c stdCA2 = new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = projects[0].Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Opportunity_Name__c = projects[0].AcctSeed__Opportunity__c, Status__c = 'Active');
            insert stdCA2;
            
            // Schedule coverage
            String CRON_EXP = '0 0 1 * * ?';
            ContactRollupHelperBatch_Schedule sch = new ContactRollupHelperBatch_Schedule();
            system.schedule('Rollup Contact fields', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
     // Calculate Candidate_Profile_Complete__c
    private static testMethod void rollUpTestMethod7(){
    
        Set<String> conRTNames = new Set<String>{'Candidate', 'DLS_Employee'};
        
        List<Contact> contacts = [SELECT Id,Evaluate_Candidate_Profile_Rating__c, dls_candidate_rating__c, of_related_Skills__c, Experience_with_DLI_Students__c FROM Contact WHERE RecordType.DeveloperName IN :conRTNames LIMIT 1];
        
        contacts[0].Evaluate_Candidate_Profile_Rating__c = FALSE;
        contacts[0].dls_candidate_rating__c = '4';
        contacts[0].of_related_Skills__c = 8;
        contacts[0].Experience_with_DLI_Students__c = TRUE;
        update contacts;
        
        Test.startTest();
        
            // Schedule coverage
            String CRON_EXP = '0 0 1 * * ?';
            ContactRollupHelperBatch_Schedule sch = new ContactRollupHelperBatch_Schedule();
            system.schedule('Rollup Contact fields', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // Populate Average_Get_Feedback_Rating__c field in contact
    private static testMethod void rollUpTestMethod8(){
    
        Id endOfTrainingRTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('Ending_Feedback').getRecordTypeId();
        
        Set<String> conRTNames = new Set<String>{'Candidate', 'DLS_Employee'};
        
        List<Contact> contacts = [SELECT Id, Average_Get_Feedback_Rating__c  FROM Contact WHERE RecordType.DeveloperName IN :conRTNames LIMIT 1];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        
        List < Get_Feedback__c > feedbacks = new List < Get_Feedback__c > {
            new Get_Feedback__c(Name = 'Test Feedback 1', Instructor__c = contacts[0].Id, Over_all_Instructor_rating__c = 6, Project__c = projects[0].Id, RecordTypeId = endOfTrainingRTId), 
            new Get_Feedback__c(Name = 'Test Feedback 2', Instructor__c = contacts[0].Id, Over_all_Instructor_rating__c = 8, Project__c = projects[0].Id, RecordTypeId = endOfTrainingRTId) 
        };
        insert feedbacks;
        
        Test.startTest();
        
            // Schedule coverage
            String CRON_EXP = '0 0 1 * * ?';
            ContactRollupHelperBatch_Schedule sch = new ContactRollupHelperBatch_Schedule();
            system.schedule('Rollup Contact fields', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // of_Students_Taught__c value changed from not null to not null( Same instructor with different projects)
    private static testMethod void rollUpTestMethod9(){
    
        Set<String> conRTNames = new Set<String>{'Candidate', 'DLS_Employee'};
        Set<String> projRTNames = new Set<String>{'Language_Training_Projects', 'Testing_Projects'};
        
        List<Contact> conList = [SELECT Id, RecordTypeId, of_Class_Projects_Taught__c, of_Students_Taught__c, of_Tests_Perfomed__c FROM Contact WHERE RecordType.DeveloperName IN :conRTNames LIMIT 1];
        conList[0].of_Students_Taught__c = 2;
        update conList[0];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName IN :projRTNames LIMIT 2];
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        Test.startTest();
        
            List<Contact_Assignments__c> insCAs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projects[0].Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Opportunity_Name__c = projects[0].AcctSeed__Opportunity__c, Status__c = 'Active', Assignment_Position__c = 'Instructor'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projects[1].Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Opportunity_Name__c = projects[0].AcctSeed__Opportunity__c, Status__c = 'Active', Assignment_Position__c = 'Instructor')
            };
            insert insCAs;
            
            List<Contact_Assignments__c> stdCAs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = projects[0].Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Opportunity_Name__c = projects[0].AcctSeed__Opportunity__c, Status__c = 'Active'),
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = projects[1].Id, Candidate_Name__c = conList[0].Id, Start_Date__c = System.today(), End_Date__c = System.today()+30, Opportunity_Name__c = projects[0].AcctSeed__Opportunity__c, Status__c = 'Active')
            };
            insert stdCAs;
          
            
            // Schedule coverage
            String CRON_EXP = '0 0 1 * * ?';
            ContactRollupHelperBatch_Schedule sch = new ContactRollupHelperBatch_Schedule();
            system.schedule('Rollup Contact fields', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    // To cover Candidate_Hiring_Stage__c value
    private static testMethod void rollUpTestMethod10(){
    
        List<Account> acc = [SELECT Id FROM Account LIMIT 1];
        
        Id canRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        Contact newHireCon = new Contact(RecordTypeId = canRTId, LastName = 'Test Hire Contact', Email = 'testhirecontact@gmail.com', AccountId = acc[0].Id);
        insert newHireCon;
                
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            
        List<AcctSeed__Project__c> projList = [SELECT Id, Start_Date__c, End_Date__c FROM AcctSeed__Project__c WHERE RecordType.DeveloperName != 'Testing_Projects' LIMIT 1];
        
        Contact_Assignments__c conAssign = new Contact_Assignments__c(RecordTypeId = insRTId, Candidate_Name__c = newHireCon.Id, Project__c = projList[0].Id, Status__c = 'Active', Start_Date__c = Date.Today(), End_Date__c = Date.Today().addMonths(1));
        insert conAssign;
        
        Test.startTest();
            
            List<Contact> conRec = [SELECT Id, Candidate_Hiring_Stage__c FROM Contact WHERE Id = : newHireCon.Id];
            System.assertEquals('Hired', conRec[0].Candidate_Hiring_Stage__c);
            
            Contact updateHireCon = new Contact(Id = newHireCon.Id, Original_Hire_Date__c = Date.Today().addMonths(-7));
            update updateHireCon;
            
            String CRON_EXP = '0 0 1 * * ?';
            ContactRollupHelperBatch_Schedule sch = new ContactRollupHelperBatch_Schedule();
            system.schedule('Rollup Contact fields', CRON_EXP, sch);
            
        Test.stopTest();
    }
}