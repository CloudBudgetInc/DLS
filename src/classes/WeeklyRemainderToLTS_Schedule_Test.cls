@isTest
private class WeeklyRemainderToLTS_Schedule_Test{

    @testSetup static void setupMethod(){
    
        List<Contact_Assignments__c> conAssign = TestClassUtil.createTestContactAssignment();
        Test.startTest();
            List<Schedule__c> schList = TestClassUtil.createTestSchedule();
            List<AcctSeed__Time_Card__c> getcards = TestClassUtil.createTestTimeCard();
        Test.stopTest();
    }
    
    private static testMethod void sendAnEmailTestMehod1(){
    
        Date currentWeekStart = system.today().toStartofWeek().addDays(1);
        
        Date previouswkStart = currentWeekStart.addDays(-7);
        Date previouswkEnd = previouswkStart.addDays(6);
        
        Set<String> conRTNames = new Set<String>{'DLS_Employee'};
        Set<String> langProjRTNames = new Set<String>{'Language_Training_Projects', 'DLI_W_LT_Projects', 'DODA_Projects', 'EFL_Projects', 'Linguist_Support_Projects', 'Testing_Projects', 'Translation_Projects', 'Interpretation_Projects'};
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName IN :conRTNames LIMIT 1];
        
        Contact c = new Contact();
        c.LastName = 'Test Ins Contact';
        insert c;
        
        List<AcctSeed__Time_Card__c> timeCardList = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCardList[0].Intructor__c = c.Id;
        update timeCardList[0];
        
        List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'False')};
        Insert sysVal;
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c, Candidate_Name__c, Assignment_Position__c, Status__c  FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Project__r.RecordType.DeveloperName IN :langProjRTNames LIMIT 1];
        conAssigns[0].Assignment_Position__c = 'Project Manager';
        conAssigns[0].Candidate_Name__c=conList[0].Id;
        conAssigns[0].Status__c = 'Active';
        
        Test.startTest();  
            update conAssigns[0];

            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :conAssigns[0].Project__c LIMIT 1];
                        
            List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c LIMIT 1];
            schList[0].Status__c = 'Active';
            schList[0].Project__c = task[0].AcctSeed__Project__c;
            update schList;
                        
            List<AcctSeed__Time_Card_Line__c> timeCardLine = new List<AcctSeed__Time_Card_Line__c> {
                new AcctSeed__Time_Card_Line__c(AcctSeed__Time_Card__c = timeCardList[0].Id,AcctSeed__Project_Task__c = task[0].Id, AcctSeed__Project__c = task[0].AcctSeed__Project__c)    
            };
            insert timeCardLine;
            
            List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
                
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = previouswkStart,Status__c= 'Draft'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 4.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = previouswkEnd,Status__c= 'Draft')
            };    
            insert days;
            
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            List<Contact_Assignments__c> insConAssigns = new List<Contact_Assignments__c>{
            
                new Contact_Assignments__c(Paper_Timesheet__c = FALSE, RecordTypeId = insRTId, Project__c=task[0].AcctSeed__Project__c,Candidate_Name__c=c.Id,Start_Date__c=System.today(),End_Date__c=System.today()+30,Status__c = 'Active')
            };
            insert insConAssigns;
            
            List<Events__c> events = new List<Events__c>{
                new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = c.Id,Date__c = previouswkStart,Project__c = task[0].AcctSeed__Project__c,Status__c = 'Scheduled', Duration__c = 6),
                new Events__c(Name = '15-00687-SH1-EV2',Schedule__c = schList[0].Id,SequenceNo__c = 2,Instructor__c = c.Id,Date__c = previouswkEnd,Project__c = task[0].AcctSeed__Project__c,Status__c = 'Scheduled', Duration__c = 4)
            };
            insert events;                         
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            WeeklyRemainderToLTS_Schedule sch = new WeeklyRemainderToLTS_Schedule();
            system.schedule('Weekly Timesheet Approval Remainder To LTS', CRON_EXP, sch);   
        Test.stopTest(); 
    }
    
    private static testMethod void sendAnEmailTestMehod2(){
    
        Date currentWeekStart = system.today().toStartofWeek().addDays(1);
        
        Date previouswkStart = currentWeekStart.addDays(-7);
        Date previouswkEnd = previouswkStart.addDays(6);
        
        Set<String> conRTNames = new Set<String>{'DLS_Employee'};
        Set<String> langProjRTNames = new Set<String>{'Language_Training_Projects', 'DLI_W_LT_Projects', 'DODA_Projects', 'EFL_Projects', 'Linguist_Support_Projects', 'Testing_Projects', 'Translation_Projects', 'Interpretation_Projects'};
        Set<String> otherProjRTNames = new Set<String>{'CD_Projects', 'Admin_Projects'};
    
        List<Contact> conList = [SELECT Id,LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName IN :conRTNames LIMIT 1];
        System.debug('::conList::'+conList[0].Id);
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        
        User u = new User(Alias = 'standt', Email='standardusertest@testorg.com', 
        EmailEncodingKey='UTF-8', LastName=conList[0].LastName, LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, IsActive = TRUE,
        TimeZoneSidKey='America/Los_Angeles', UserName='weeklyremtestuser1@testorg.com');
        insert u;
          
        Contact c = new Contact();
        c.LastName = 'Test Ins Contact';
        insert c;
                     
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__r.RecordType.DeveloperName IN : otherProjRTNames LIMIT 1];
        
        Test.startTest();
            
            List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'False')};
            Insert sysVal;
            
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            Id staffRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
            List<Contact_Assignments__c> insConAssigns = new List<Contact_Assignments__c>{
            
                new Contact_Assignments__c(Paper_Timesheet__c = FALSE, RecordTypeId = insRTId, Project__c=task[0].AcctSeed__Project__c,Candidate_Name__c=c.Id,Start_Date__c=System.today(),End_Date__c=System.today()+30,Status__c = 'Active')
            };
            insert insConAssigns;
            
            List<AcctSeed__Project_Task__c> taskRec = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__r.RecordType.DeveloperName IN : langProjRTNames LIMIT 1];
            
            List<Contact_Assignments__c> allCAs = new List<Contact_Assignments__c>();         
            
            Contact_Assignments__c insCA = new Contact_Assignments__c(Paper_Timesheet__c = FALSE, RecordTypeId = insRTId, Project__c=task[0].AcctSeed__Project__c,Candidate_Name__c=c.Id,Start_Date__c=System.today(),End_Date__c=System.today()+30,Status__c = 'Active');
            Contact_Assignments__c staffCA = new Contact_Assignments__c(RecordTypeId = staffRTId, Project__c=task[0].AcctSeed__Project__c,Candidate_Name__c=conList[0].Id,Start_Date__c=System.today(),End_Date__c=System.today()+30,Status__c = 'Active', Assignment_Position__c = 'Project Manager');
            allCAs.add(insCA);
            allCAs.add(staffCA);
            insert allCAs;
            
            List<AcctSeed__Time_Card__c> timeCardList = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCardList[0].Intructor__c = c.Id;
            update timeCardList[0];
        
            List<AcctSeed__Time_Card_Line__c> timeCardLine = new List<AcctSeed__Time_Card_Line__c> {
                new AcctSeed__Time_Card_Line__c(AcctSeed__Time_Card__c = timeCardList[0].Id,AcctSeed__Project_Task__c = taskRec[0].Id, AcctSeed__Project__c = taskRec[0].AcctSeed__Project__c)    
            };
            insert timeCardLine;
            
            List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
                
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = previouswkStart,Status__c= 'Draft'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 4.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = previouswkEnd,Status__c= 'Draft')
            };    
            insert days;
            
            c.Supervisor_Name__c = u.Id;
            update c;
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            WeeklyRemainderToLTS_Schedule sch = new WeeklyRemainderToLTS_Schedule();
            system.schedule('Weekly Timesheet Approval Remainder To LTS', CRON_EXP, sch);   
        Test.stopTest(); 
    }
}