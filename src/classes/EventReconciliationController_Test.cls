@isTest
public class EventReconciliationController_Test {

    @testsetup static void setup() {
        
        List<AcctSeed__Time_Card_Day__c> tcd = TestClassUtil.createTestTimeCardDay();
        Test.startTest();
            List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();
            List<Events__c> eventsRecs = TestClassUtil.createTestEvent();
        Test.stopTest();
    }

    public static testMethod void testMethod1() {
                
        List<Events__c> eventsRecs = [SELECT Id, Name,Project__c,Date__c FROM Events__c WHERE Project__c != null LIMIT 3];
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
       
        List<AcctSeed__Project_Task__c> projTask = [SELECT Id,AcctSeed__Labor_GL_Account__c,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 1];
        
        List<AcctSeed__Time_Card_Day__c> dayRecords = [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c FROM AcctSeed__Time_Card_Day__c LIMIT 5];
        
        List < System_Values__c > sysValuesList = new List < System_Values__c > {
           new System_Values__c(Name = 'TimeLog_Locking_Date', Value__c = String.valueOf(System.today().addMonths(-1)))
        };
            
        for(Events__c eve : eventsRecs){
            eve.Date__c = eve.Date__c.addDays(1);
        }
        
        update eventsRecs;
        
        List<Contact_Assignments__c> caRecords = [SELECT Id,Name,Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Project__c = :eventsRecs[0].Project__c LIMIT 1];
        
        if(caRecords.size() > 0){
            caRecords[0].Candidate_Name__c = conList[0].Id;
        }
        update caRecords;
        
        Insert sysValuesList;
        
        if(eventsRecs.size() > 0 && conList.size() > 0) {
            Test.startTest();
            
            Date thisWeekStart = system.today().toStartofWeek() + 1;
            Date stDate = thisWeekStart.addDays(-7);
            Date endDate = stDate.addDays(6);
                        
            EventDomain.TimeEventDetails timeEvents1 = EventReconciliationController.getWholeDetails(null, null, conList[0].Id,'Approved', 'AA');
            // By HL
            EventDomain.TimeEventDetails timeEvents2 = EventReconciliationController.getWholeDetails(null, null, conList[0].Id,'No Time Entries', 'AA');
            
            string weekrange = EventReconciliationController.weekRangeFormation();
            
            EventDomain.ProjectTimeEventInfo proTimeEventInfo = EventReconciliationController.getProjectBasedEventTimeDetails(String.valueOf(stDate), String.valueOf(endDate),conList[0].Id,eventsRecs[0].Project__c,'Approved', conList[0].Id, projTask[0].Id);
            
            List <SObject> lookuprecords1 = EventReconciliationController.getLookupRecords('Test', 'Contact', 'Name', null, null); 
            
            string updateresult = EventReconciliationController.eventUpdate(JSON.serialize(eventsRecs));
            EventTranslator.dayCountCalculationPerProject(dayRecords);
            
            //system.assert(Date.valueOf(timeEvents.timeEventInfo[0].eventInfo[0].eventDate) < endDate);
            system.assert('SUCCESS' == updateresult);
            
            Test.stopTest();
        }
    }
    
    public static testMethod void testMethod2() {
        List<Events__c> eventsRecs = [SELECT Id, Name,Project__c,Date__c FROM Events__c WHERE Project__c != null LIMIT 3];
        List<AcctSeed__Time_Card_Day__c> dayRecords = [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c FROM AcctSeed__Time_Card_Day__c LIMIT 5];
        
        
        Contact testCon = [SELECT Id FROM Contact WHERE Name LIKE '%Testing%' LIMIT 1];
        User usr = [SELECT Id,contactId,Name FROM User WHERE Name = 'Testing' LIMIT 1];
        
        List < System_Values__c > sysValuesList = new List < System_Values__c > {
           new System_Values__c(Name = 'TimeLog_Locking_Date', Value__c = String.valueOf(System.today().addMonths(-1)))
        };
        Insert sysValuesList;
            
        for(Events__c eve : eventsRecs){
            eve.Date__c = eve.Date__c.addDays(1);
        }
        
        update eventsRecs;
        
        List<Contact_Assignments__c> caRecords = [SELECT Id,Name,Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Project__c = :eventsRecs[0].Project__c LIMIT 1];
        
        if(caRecords.size() > 0){
            caRecords[0].Candidate_Name__c = testCon.Id;
        }
        update caRecords;
        
        Test.startTest();
        
            Date thisWeekStart = system.today().toStartofWeek() + 1;
            Date stDate = thisWeekStart.addDays(-7);
            Date endDate = stDate.addDays(6);
            System.runAs(usr){
                EventDomain.TimeEventDetails timeEvents11 = EventReconciliationController.getWholeDetails(String.valueOf(stDate.addDays(-7)), String.valueOf(endDate.addDays(-7)),'','All', '');
            }
            
            EventDomain.TimeEventDetails timeEvents = EventReconciliationController.getWholeDetails(String.valueOf(stDate), String.valueOf(endDate), testCon.Id,'Rejected', 'AFPAK');
            EventDomain.TimeEventDetails timeEvents2 = EventReconciliationController.getWholeDetails(null, null, testCon.Id,'Rejected', 'AFPAK');
            
        Test.stopTest();
    }
    
    public static testMethod void testMethod3() {
    
        List<Events__c> eventsRecs = [SELECT Id, Name,Project__c,Date__c FROM Events__c WHERE Project__c != null LIMIT 3];
        List<AcctSeed__Time_Card_Day__c> dayRecords = [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c FROM AcctSeed__Time_Card_Day__c LIMIT 5];
        
        Contact testCon = [SELECT Id FROM Contact WHERE Name LIKE '%Testing%' LIMIT 1];
        
        User usr = [SELECT Id,contactId,Name FROM User WHERE Name = 'Testing' LIMIT 1];
        
        List < System_Values__c > sysValuesList = new List < System_Values__c > {
           new System_Values__c(Name = 'TimeLog_Locking_Date', Value__c = String.valueOf(System.today().addMonths(-1)))
        };
        Insert sysValuesList;
            
        for(Events__c eve : eventsRecs){
            eve.Date__c = eve.Date__c.addDays(1);
        }
        
        update eventsRecs;
        
        List<Contact_Assignments__c> caRecords = [SELECT Id,Name,Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Project__c = :eventsRecs[0].Project__c LIMIT 1];
        
        if(caRecords.size() > 0){
            caRecords[0].Candidate_Name__c = testCon.Id;
        }
        update caRecords;
        
        Test.startTest();
        
            Date thisWeekStart = system.today().toStartofWeek() + 1;
            Date stDate = thisWeekStart.addDays(-7);
            Date endDate = stDate.addDays(6);
            System.runAs(usr){
                EventDomain.TimeEventDetails timeEvents11 = EventReconciliationController.getWholeDetails(String.valueOf(stDate.addDays(-7)), String.valueOf(endDate.addDays(-7)),'','Approved', 'HRN');
            }
            
            EventDomain.TimeEventDetails timeEvents = EventReconciliationController.getWholeDetails(String.valueOf(stDate), String.valueOf(endDate), testCon.Id,'Pending Approval', 'HRN');
            EventDomain.TimeEventDetails timeEvents2 = EventReconciliationController.getWholeDetails(null, null, testCon.Id,'Pending Approval', 'HRN');
            
        Test.stopTest();
    }
    
    public static testMethod void testMethod4() {
    
        List<Events__c> eventsRecs = [SELECT Id, Name,Project__c,Date__c FROM Events__c WHERE Project__c != null LIMIT 3];
        List<AcctSeed__Time_Card_Day__c> dayRecords = [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c FROM AcctSeed__Time_Card_Day__c LIMIT 5];
        
        Contact testCon = [SELECT Id FROM Contact WHERE Name LIKE '%Testing%' LIMIT 1];
                
        User usr = [SELECT Id,contactId,Name, FirstName FROM User WHERE Name = 'Testing' LIMIT 1];
        
        List < System_Values__c > sysValuesList = new List < System_Values__c > {
           new System_Values__c(Name = 'TimeLog_Locking_Date', Value__c = String.valueOf(System.today().addMonths(-1)))
        };
        Insert sysValuesList;
            
        for(Events__c eve : eventsRecs){
            eve.Date__c = eve.Date__c.addDays(1);
        }
        
        update eventsRecs;
        
        List<Contact_Assignments__c> caRecords = [SELECT Id,Name,Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Project__c = :eventsRecs[0].Project__c LIMIT 1];
        
        if(caRecords.size() > 0){
            caRecords[0].Candidate_Name__c = testCon.Id;
        }
        update caRecords;
        
        Test.startTest();
            Date thisWeekStart = system.today().toStartofWeek() + 1;
            Date stDate = thisWeekStart.addDays(-7);
            Date endDate = stDate.addDays(6);
            System.runAs(usr){
                EventDomain.TimeEventDetails timeEvents11 = EventReconciliationController.getWholeDetails(String.valueOf(stDate.addDays(-7)), String.valueOf(endDate.addDays(-7)),'','Approved', 'CD');
            }
            
            EventDomain.TimeEventDetails timeEvents = EventReconciliationController.getWholeDetails(String.valueOf(stDate), String.valueOf(endDate), testCon.Id,'Pending Submission', 'CD');
            EventDomain.TimeEventDetails timeEvents2 = EventReconciliationController.getWholeDetails(null, null, testCon.Id,'Pending Submission', 'CD');
            
        Test.stopTest();
    }
    
    public static testMethod void testMethod5() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
    
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
      
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
        schList[0].Status__c = 'Active';
        update schList;
        System.debug('schList===='+schList);
    
        Test.startTest();
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Student_Approval_Status__c = 'Submitted');
        insert day;
        
        Events__c event = new Events__c(Name = '15-00687-SH1-EV1', Time_Card_Day__c = day.Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
        insert event;
        
        EventDomain.TimeEventDetails timeEvents = EventReconciliationController.getWholeDetails(String.valueOf(Date.Today()), String.valueOf(Date.Today().addDays(3)), conList[0].Id,'Approved', 'SLP');
        EventDomain.TimeEventDetails timeEvents2 = EventReconciliationController.getWholeDetails(null, null, conList[0].Id,'Approved', 'SLP');
            
        Test.stopTest();
    }
    
    public static testMethod void testMethod6() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
              
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
    
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);       
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
      
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = projects[0].Id;
        update schList;
        System.debug('schList===='+schList);
    
        Test.startTest();
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(), Status__c = 'Approved'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today().addDays(1), Status__c = 'Approved')
        
        };
        insert days;
        
        List<Events__c> events = new List<Events__c>{
            new Events__c(Name = '15-00687-SH1-EV1', Time_Card_Day__c = days[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled'),
            new Events__c(Name = '15-00687-SH1-EV2', Time_Card_Day__c = days[1].Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled')
        };
        insert events;
        
        EventDomain.TimeEventDetails timeEvents = EventReconciliationController.getWholeDetails(String.valueOf(Date.Today()), String.valueOf(Date.Today().addDays(1)), conList[0].Id,'Approved', 'PS');
            
        Test.stopTest();
    }
    
    public static testMethod void testMethod7() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
    
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
      
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
        schList[0].Status__c = 'Active';
        update schList;
        System.debug('schList===='+schList);
    
        Test.startTest();
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(), Status__c = 'Approved', Student_Approval_Status__c = 'Approved'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today().addDays(1), Status__c = 'Approved', Student_Approval_Status__c = 'Approved')
        
        };
        insert days;
        
        List<Events__c> events = new List<Events__c>{
            new Events__c(Name = '15-00687-SH1-EV1', Time_Card_Day__c = days[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled'),
            new Events__c(Name = '15-00687-SH1-EV2', Time_Card_Day__c = days[1].Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled')
        };
        insert events;
        
        EventDomain.TimeEventDetails timeEvents = EventReconciliationController.getWholeDetails(String.valueOf(Date.Today()), String.valueOf(Date.Today().addDays(1)), conList[0].Id,'Approved', 'EE');
            
        Test.stopTest();
    }
    
    public static testMethod void testMethod8() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
    
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
      
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
        schList[0].Status__c = 'Active';
        update schList;
        System.debug('schList===='+schList);
    
        Test.startTest();
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today().addDays(1), Status__c = 'Submitted')
        
        };
        insert days;
        
        List<Events__c> events = new List<Events__c>{
            new Events__c(Name = '15-00687-SH1-EV1', Time_Card_Day__c = days[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled'),
            new Events__c(Name = '15-00687-SH1-EV2', Time_Card_Day__c = days[1].Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled')
        };
        insert events;
        
        EventDomain.ProjectTimeEventInfo proTimeEventInfo = EventReconciliationController.getProjectBasedEventTimeDetails(String.valueOf(Date.Today()), String.valueOf(Date.Today().addDays(1)),conList[0].Id,events[0].Project__c,'Pending Approval', conList[0].Id, NULL);
        Test.stopTest();
    }
    
    public static testMethod void mytestMethod8() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
    
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
      
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
        schList[0].Status__c = 'Active';
        update schList;
        System.debug('schList===='+schList);
    
        Test.startTest();
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
            new AcctSeed__Time_Card_Day__c(Start_Time2__c = '08:30 AM', End_Time2__c = '10:30 AM', AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(Start_Time2__c = '08:30 AM', End_Time2__c = '10:30 AM', AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today().addDays(1), Status__c = 'Submitted')
        
        };
        insert days;
        
        List<Events__c> events = new List<Events__c>{
            new Events__c(Name = '15-00687-SH1-EV1', Time_Card_Day__c = days[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled'),
            new Events__c(Name = '15-00687-SH1-EV2', Time_Card_Day__c = days[1].Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled')
        };
        insert events;
        
        EventDomain.ProjectTimeEventInfo proTimeEventInfo = EventReconciliationController.getProjectBasedEventTimeDetails(String.valueOf(Date.Today()), String.valueOf(Date.Today().addDays(1)),conList[0].Id,events[0].Project__c,'Pending Approval', conList[0].Id, NULL);
        Test.stopTest();
    }
    
    public static testMethod void testMethod8a() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
    
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c, RecordTypeId FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        projects[0].RecordTypeId = dodaRTId;
        update projects[0];
        System.debug('projects========'+projects);
    
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
      
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
        schList[0].Status__c = 'Active';
        update schList;
        System.debug('schList===='+schList);
    
        Test.startTest();
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today().addDays(1), Status__c = 'Submitted')
        
        };
        insert days;
        
        List<Events__c> events = new List<Events__c>{
            new Events__c(Name = '15-00687-SH1-EV1', Time_Card_Day__c = days[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled'),
            new Events__c(Name = '15-00687-SH1-EV2', Time_Card_Day__c = days[1].Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled')
        };
        insert events;
        
        EventDomain.ProjectTimeEventInfo proTimeEventInfo = EventReconciliationController.getProjectBasedEventTimeDetails(String.valueOf(Date.Today()), String.valueOf(Date.Today().addDays(1)),conList[0].Id,events[0].Project__c,'All', conList[0].Id, NULL);
        Test.stopTest();
    }
    
    public static testMethod void testMethod9() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
    
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
      
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
        schList[0].Status__c = 'Active';
        update schList;
        System.debug('schList===='+schList);
    
        Test.startTest();
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(), Status__c = 'Rejected'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today().addDays(1), Status__c = 'Rejected')
        
        };
        insert days;
        
        List<Events__c> events = new List<Events__c>{
            new Events__c(Name = '15-00687-SH1-EV1', Time_Card_Day__c = days[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled'),
            new Events__c(Name = '15-00687-SH1-EV2', Time_Card_Day__c = days[1].Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled')
        };
        insert events;
        
        EventDomain.ProjectTimeEventInfo proTimeEventInfo = EventReconciliationController.getProjectBasedEventTimeDetails(String.valueOf(Date.Today()), String.valueOf(Date.Today().addDays(1)),conList[0].Id,events[0].Project__c,'Rejected', conList[0].Id, NULL);
        Test.stopTest();
    }
    
    public static testMethod void testMethod10() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
    
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
      
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
        schList[0].Status__c = 'Active';
        update schList;
        System.debug('schList===='+schList);
    
        Test.startTest();
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(), Status__c = 'Rejected'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today().addDays(1), Status__c = 'Rejected')
        
        };
        insert days;
        
        List<Events__c> events = new List<Events__c>{
            new Events__c(Name = '15-00687-SH1-EV1', Time_Card_Day__c = days[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled'),
            new Events__c(Name = '15-00687-SH1-EV2', Time_Card_Day__c = days[1].Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled')
        };
        insert events;
        
        EventDomain.ProjectTimeEventInfo proTimeEventInfo = EventReconciliationController.getProjectBasedEventTimeDetails(String.valueOf(Date.Today()), String.valueOf(Date.Today().addDays(1)),conList[0].Id,events[0].Project__c,'Pending Submission', conList[0].Id, NULL);
        Test.stopTest();
    }
    
    public static testMethod void testMethod11() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
    
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
      
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
        schList[0].Status__c = 'Active';
        update schList;
        System.debug('schList===='+schList);
    
        Test.startTest();
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(), Status__c = 'Rejected'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today().addDays(1), Status__c = 'Rejected')
        
        };
        insert days;
                
        String res= EventReconciliationController.saveTimeCardEntryRecords(JSON.Serialize(days), 'Save Changes','Test');
        Test.stopTest();
    }
    
    public static testMethod void testMethod12() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
    
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
      
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
        schList[0].Status__c = 'Active';
        update schList;
        System.debug('schList===='+schList);
    
        Test.startTest();
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(), Status__c = 'Rejected'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today().addDays(1), Status__c = 'Rejected')
        
        };
        insert days;
                
        String res= EventReconciliationController.saveTimeCardEntryRecords(JSON.Serialize(days), 'Test','');
        Test.stopTest();
    }
    
    public static testMethod void testMethod13() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c  FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Paper_Timesheet__c = FALSE;
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
    
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
      
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
        schList[0].Status__c = 'Active';
        update schList;
        System.debug('schList===='+schList);
    
        Test.startTest();
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(), Status__c = 'Approved'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today().addDays(1), Status__c = 'Approved')
        
        };
        insert days;
                
        String res= EventReconciliationController.saveTimeCardEntryRecords(JSON.Serialize(days), 'Approve All','');
        Test.stopTest();
    }
    
    public static testMethod void testMethod13a() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c  FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Paper_Timesheet__c = FALSE;
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
    
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, Total_Qty_Planned__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
        task[0].Total_Qty_Planned__c = 10;
        task[0].Project_Task_Type__c = 'Language Training';
        task[0].Total_Hours_Used_For_Language_Training__c  = 10;
        task[0].Total_Days_Used_for_Language_Training__c = 10;
        update task[0];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
        schList[0].Status__c = 'Active';
        update schList;
        System.debug('schList===='+schList);
    
        Test.startTest();
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(), Status__c = 'Approved'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today().addDays(1), Status__c = 'Approved')
        
        };
        insert days;
        
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project__c, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.Total_Qty_Used__c, AcctSeed__Project_Task__r.Total_Qty_Planned_Remaining__c,
                                                      (SELECT Id, AcctSeed__Hours__c FROM AcctSeed__Time_Card_Days__r) 
                                                  FROM AcctSeed__Time_Card_Line__c WHERE Id = :timeCardLine.Id];
        System.debug('::lines:::::'+lines[0].AcctSeed__Project_Task__r.Total_Qty_Used__c);
        
        String res= EventReconciliationController.saveTimeCardEntryRecords(JSON.Serialize(days), 'Approve All','');
        Test.stopTest();
    }
    
    public static testMethod void testMethod14() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                    
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Paper_Timesheet__c = FALSE;
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
    
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
      
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c FROM Schedule__c WHERE Project_Task__c = :task[0].Id LIMIT 1];
        schList[0].Status__c = 'Active';
        update schList;
        System.debug('schList===='+schList);
    
        Test.startTest();
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(), Status__c = 'Approved'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today().addDays(1), Status__c = 'Approved')
        
        };
        insert days;
        
        List<AcctSeed__Time_Card_Day__c> daysRec = [SELECT Id, AcctSeed__Time_Card_Line__c , Total_Hours_Before_Approved__c , AcctSeed__Hours__c , AcctSeed__Date__c, Status__c FROM AcctSeed__Time_Card_Day__c WHERE Id IN : days];
        daysRec[0].Status__c = 'Rejected';
        daysRec[1].Status__c = 'Rejected';
        //update daysRec;
        
        String res= EventReconciliationController.saveTimeCardEntryRecords(JSON.Serialize(daysRec), 'Reject All','');
        Test.stopTest();
    }
    
    // To cover sendReminderEmailToStudentInstructor() method 
    private static testMethod void testMethod15() {
    
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                        
            Test.startTest();
            
                List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
                conAss[0].Candidate_Name__c = conList[0].Id;
                conAss[0].Assignment_Position__c = 'Class Leader';
                conAss[0].Time_Approval_Preference__c = 'Weekly';
                update conAss[0]; 
                
                List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            
                List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
                timeCard[0].Intructor__c = conList[0].Id;
                update timeCard;
                
                List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
              
                AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
                timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
                timeCardLine.AcctSeed__Project__c = projects[0].Id;
                timeCardLine.AcctSeed__Billable__c = TRUE;
                timeCardLine.Payroll_Item__c = 'ADM';
                timeCardLine.Contact_Assignment__c = conAss[0].Id;
                timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
                insert timeCardLine;
                            
                AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Student_Approval_Status__c = 'Submitted', Status__c = 'Draft');
                insert day;
                
                // To avoid Script-thrown exception : NO_MASS_MAIL_PERMISSION , try -catch block is used                
                try{
                    EventReconciliationController.sendReminderEmailToStudentInstructor(projects[0].Id, conList[0].Id, String.valueOf(Date.Today()), String.valueOf(Date.Today()), 'Send Email', new List<String>{conList[0].Id});
                }catch(Exception e){
                
                }
                
            Test.stopTest();    
    }
    
    // To cover sendReminderEmailToStudentInstructor() method 
    private static testMethod void testMethod15a() {
    
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                        
            Test.startTest();
            
                List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
                conAss[0].Candidate_Name__c = conList[0].Id;
                conAss[0].Assignment_Position__c = 'Class Leader';
                conAss[0].Time_Approval_Preference__c = 'Weekly';
                update conAss[0]; 
                
                List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            
                List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
                timeCard[0].Intructor__c = conList[0].Id;
                update timeCard;
                
                List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
              
                AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
                timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
                timeCardLine.AcctSeed__Project__c = projects[0].Id;
                timeCardLine.AcctSeed__Billable__c = TRUE;
                timeCardLine.Payroll_Item__c = 'ADM';
                timeCardLine.Contact_Assignment__c = conAss[0].Id;
                timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
                insert timeCardLine;
                            
                AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Student_Approval_Status__c = 'Submitted', Status__c = 'Draft');
                insert day;
                
                try{
                    EventReconciliationController.sendReminderEmailToStudentInstructor(projects[0].Id, conList[0].Id, String.valueOf(Date.Today()), String.valueOf(Date.Today()), 'Test Email', new List<String>{conList[0].Id});
                }catch(Exception e){
                
                }
            Test.stopTest();    
    }
    
    // To cover sendReminderEmailToStudentInstructor() method 
    private static testMethod void testMethod16() {
    
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                        
            Test.startTest();
            
                List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
                conAss[0].Candidate_Name__c = conList[0].Id;
                conAss[0].Assignment_Position__c = 'Class Leader';
                conAss[0].Time_Approval_Preference__c = 'Weekly';
                update conAss[0]; 
                
                List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            
                List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
                timeCard[0].Intructor__c = conList[0].Id;
                update timeCard;
                
                List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
              
                AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
                timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
                timeCardLine.AcctSeed__Project__c = projects[0].Id;
                timeCardLine.AcctSeed__Billable__c = TRUE;
                timeCardLine.Payroll_Item__c = 'ADM';
                timeCardLine.Contact_Assignment__c = conAss[0].Id;
                timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
                insert timeCardLine;
                
                List<Events__c> eventsRecs = [SELECT Id, Name,Project__c,Date__c FROM Events__c WHERE Project__c != null AND Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time' LIMIT 1];
                eventsRecs[0].Project__c = projects[0].Id;
                eventsRecs[0].Instructor__c = conList[0].Id;
                eventsRecs[0].Date__c = Date.Today();
                eventsRecs[0].Status__c = 'Scheduled';
                update eventsRecs[0];
                
                try{
                    EventReconciliationController.sendReminderEmailToStudentInstructor(projects[0].Id, conList[0].Id, String.valueOf(Date.Today()), String.valueOf(Date.Today()), 'Test Email', new List<String>{conList[0].Id});
                }catch(Exception e){
                
                }
            Test.stopTest();    
    }
    
    // To cover sendReminderEmailToStudentInstructor() method 
    private static testMethod void testMethod16a() {
    
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
                        
            Test.startTest();
            
                List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
                conAss[0].Candidate_Name__c = conList[0].Id;
                conAss[0].Assignment_Position__c = 'Class Leader';
                conAss[0].Time_Approval_Preference__c = 'Weekly';
                update conAss[0]; 
                
                List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            
                List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
                timeCard[0].Intructor__c = conList[0].Id;
                update timeCard;
                
                List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
              
                AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
                timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
                timeCardLine.AcctSeed__Project__c = projects[0].Id;
                timeCardLine.AcctSeed__Billable__c = TRUE;
                timeCardLine.Payroll_Item__c = 'ADM';
                timeCardLine.Contact_Assignment__c = conAss[0].Id;
                timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
                insert timeCardLine;
                
                List<Events__c> eventsRecs = [SELECT Id, Name,Project__c,Date__c FROM Events__c WHERE Project__c != null AND Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time' LIMIT 1];
                eventsRecs[0].Project__c = projects[0].Id;
                eventsRecs[0].Instructor__c = conList[0].Id;
                eventsRecs[0].Date__c = Date.Today();
                eventsRecs[0].Status__c = 'Scheduled';
                update eventsRecs[0];
                
                try{
                    EventReconciliationController.sendReminderEmailToStudentInstructor(projects[0].Id, conList[0].Id, String.valueOf(Date.Today()), String.valueOf(Date.Today()), 'Send Email', new List<String>{conList[0].Id});
                }catch(Exception e){
                    Boolean expectedExceptionThrown =  e.getMessage().contains('Script-thrown exception') ? true : false;
                    System.AssertEquals(expectedExceptionThrown, true);
                }
            Test.stopTest();    
    }
    
    // To cover eventsCountCalculationPerProject() method in EventTranslator
    private static testMethod void testMethod17() {
    
        List<Events__c> eventsRecs = [SELECT Id, Name,Project__c,Instructor__c FROM Events__c WHERE Project__c != null];
        EventTranslator.eventsCountCalculationPerProject(eventsRecs);
    }
    
    // To cover isEventAllowedForReschedule() method in EventTranslator
    private static testMethod void testMethod18() {
    
        EventTranslator.isEventAllowedForReschedule(System.now(), 'America/New_York');
    }
}