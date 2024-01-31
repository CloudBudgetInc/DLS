@isTest
private class DailyRemainderToInstructor_Schedule_Test{

    @testSetup static void setupMethod(){
    
        List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
        Test.startTest();
            List<Schedule__c> schList = TestClassUtil.createTestSchedule();
            List<AcctSeed__Time_Card_Day__c> days = TestClassUtil.createTestTimeCardDay();
        Test.stopTest();
    }
    
    private static testMethod void sendAnEmailToInstructors1(){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        Date PrevDate;
        
        if(todayVal.format('EEEE') == 'Monday'){
            PrevDate = system.today().addDays(-3);
        }else{
            PrevDate = system.today().addDays(-1);
        }
            
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        List<Schedule__c> schList = [SELECT Id, Project__c FROM Schedule__c LIMIT 1];
        System.debug('schList===='+schList);
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE Id =: schList[0].Project__c];
        System.debug('projs ======'+projs);
        
        Test.startTest();
        
            Id staffId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            
            /*
            Contact_Assignments__c conAss = new Contact_Assignments__c(RecordTypeId = staffId, Project__c = projs[0].Id,Candidate_Name__c = conList[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Project Manager');
            insert conAss;
            System.debug('conAss ======'+conAss );
            
            Contact_Assignments__c insConAss = new Contact_Assignments__c(Paper_Timesheet__c = FALSE, RecordTypeId = insRTId, Project__c = projs[0].Id,Candidate_Name__c = conList[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Instructor');
            insert insConAss;         
            */
            
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = staffId, Project__c = projs[0].Id,Candidate_Name__c = conList[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Project Manager'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projs[0].Id,Candidate_Name__c = conList[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Instructor')
            };
            insert conAssignRecs;
            
            List<Contact_Assignments__c> conAsign = [SELECT Id, Paper_Timesheet__c FROM Contact_Assignments__c WHERE Id IN :conAssignRecs AND RecordType.DeveloperName = 'Instructor'];
            System.debug('conAsign[0].Paper_Timesheet__c::::'+conAsign[0].Paper_Timesheet__c);
            conAsign[0].Paper_Timesheet__c = FALSE;
            update conAsign[0];
            
            Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = PrevDate,Project__c = schList[0].Project__c,Status__c = 'Scheduled');
            insert event;
            
            List<AcctSeed__Time_Card_Day__c> days = [SELECT Id FROM AcctSeed__Time_Card_Day__c];
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            DailyRemainderToInstructor_Schedule sch = new DailyRemainderToInstructor_Schedule();
            system.schedule('DailyRemainderToInstructor', CRON_EXP, sch);
        
        Test.stopTest();
    }
    
    private static testMethod void sendAnEmailToInstructors2(){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        Date PrevDate;
        
        if(todayVal.format('EEEE') == 'Monday'){
            PrevDate = system.today().addDays(-3);
        }else{
            PrevDate = system.today().addDays(-1);
        }
            
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        List<Schedule__c> schList = [SELECT Id, Project__c FROM Schedule__c LIMIT 1];
        System.debug('schList===='+schList);
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE Id =: schList[0].Project__c];
        System.debug('projs ======'+projs);
        
        Test.startTest();
        
            Id staffId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
            Contact_Assignments__c conAss = new Contact_Assignments__c(RecordTypeId = staffId, Project__c = projs[0].Id,Candidate_Name__c = conList[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Project Manager');
            insert conAss;
            System.debug('conAss ======'+conAss );
                                    
            List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, AcctSeed__Date__c FROM AcctSeed__Time_Card_Day__c];
            
            List<Events__c> events = new List<Events__c>{
                new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = PrevDate,Project__c = schList[0].Project__c,Status__c = 'Scheduled'),
                new Events__c(Name = '15-00687-SH1-EV2',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = PrevDate,Project__c = schList[0].Project__c,Status__c = 'Scheduled')
            };
            insert events;
                        
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            DailyRemainderToInstructor_Schedule sch = new DailyRemainderToInstructor_Schedule();
            system.schedule('DailyRemainderToInstructor', CRON_EXP, sch);
        
        Test.stopTest();
    }
    
    private static testMethod void sendAnEmailToInstructors3(){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        Date PrevDate;
        
        if(todayVal.format('EEEE') == 'Monday'){
            PrevDate = system.today().addDays(-3);
        }else{
            PrevDate = system.today().addDays(-1);
        }
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month()+1,03);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,30);
        
        List<Contact> conList = [SELECT Id, AccountId FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' LIMIT 1];
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = conList[0].AccountId, Name = 'Test Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
                
        Test.startTest(); 
        
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training',Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Scheduled', Schedule_Type__c = 'Regular', Instructor__c = conList[0].Id)
            };
            insert schList;
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
        
             //Insert Paper Timesheet custom setting
            List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'False')};
            Insert sysVal;
            
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            Contact_Assignments__c conAss = new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = proj.Id,Candidate_Name__c = conList[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Status__c = 'Active', Assignment_Position__c = 'Project Manager');
            insert conAss;
            
            List<Contact_Assignments__c> insCA = [SELECT Id, Paper_Timesheet__c FROM Contact_Assignments__c WHERE Id = :conAss.Id];
            
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = projTask.Id;
            timeCardLine.AcctSeed__Project__c = proj.Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss.Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = PrevDate, Status__c = 'Draft', Late_Cancellation__c = TRUE);
            insert day;
        
            List<Events__c> events = new List<Events__c>{
                new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = PrevDate,Project__c = proj.Id,Status__c = 'Scheduled')
            };
            insert events;
                        
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            DailyRemainderToInstructor_Schedule sch = new DailyRemainderToInstructor_Schedule();
            system.schedule('DailyRemainderToInstructor', CRON_EXP, sch);
        
        Test.stopTest();
    }
    
    private static testMethod void sendAnEmailToInstructors4(){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        Date PrevDate;
        
        if(todayVal.format('EEEE') == 'Monday'){
            PrevDate = system.today().addDays(-3);
        }else{
            PrevDate = system.today().addDays(-1);
        }
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month()+1,03);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,30);
        
        List<Contact> conList = [SELECT Id, AccountId FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' LIMIT 1];
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = conList[0].AccountId, Name = 'Test Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
                
        Test.startTest(); 
        
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training',Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+10, Start_Date__c=System.Today(),Status__c= 'Scheduled', Schedule_Type__c = 'Regular', Instructor__c = conList[0].Id)
            };
            insert schList;
        
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
        
             //Insert Paper Timesheet custom setting
            List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'False')};
            Insert sysVal;
            
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            Contact_Assignments__c conAss = new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = proj.Id,Candidate_Name__c = conList[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Status__c = 'Active', Assignment_Position__c = 'Project Manager');
            insert conAss;
            
            List<Contact_Assignments__c> insCA = [SELECT Id, Paper_Timesheet__c FROM Contact_Assignments__c WHERE Id = :conAss.Id];
            
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = projTask.Id;
            timeCardLine.AcctSeed__Project__c = proj.Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss.Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = PrevDate, Status__c = 'Draft', Late_Cancellation__c = TRUE);
            insert day;
        
            List<Events__c> events = new List<Events__c>{
                new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = PrevDate,Project__c = proj.Id,Status__c = 'Scheduled'),
                new Events__c(Time_Card_Day__c = day.Id, Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = PrevDate,Project__c = proj.Id,Status__c = 'Scheduled')
            };
            insert events;
                        
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            DailyRemainderToInstructor_Schedule sch = new DailyRemainderToInstructor_Schedule();
            system.schedule('DailyRemainderToInstructor', CRON_EXP, sch);
        
        Test.stopTest();
    }
}