@isTest
private class EventCalendarController_Test{

    @testSetup static void setupMethod(){
            
        Test.startTest();
            //List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment(); 
            
            List<AcctSeed__Time_Card_Day__c>  tcd = TestClassUtil.createTestTimeCardDay();
        Test.stopTest();
            List<Planned_Days_Off__c> pdo = TestClassUtil.createTestPlannedDaysOff();
            List<MTT_Location__c> location = TestClassUtil.createTestLocations();
            List<Events__c> events = TestClassUtil.createTestEvent();
    }
    
    private static testMethod void myTest1(){
    
        Integer year1 = Date.Today().Year();
        Integer year2 = year1+1;
        List<String> status = new List<String>{'Scheduled','Completed'};
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        update conAss[0]; 
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
            
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
                
        //List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        //System.debug('projects========'+projects);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        System.debug('task ====='+task);
            
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        update schList;
        System.debug('schList===='+schList);
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
        insert event;
        System.debug('event ========='+event );
        
        System.runAs(user){
            EventCalendarController.getEventRecordList(String.valueOf(year1), String.valueOf(Year2), status);
        }
        
        Test.stopTest();
    }
    
    private static testMethod void myTest2(){
    
        Integer year1 = Date.Today().Year();
        Integer year2 = year1-1;
        List<String> status = new List<String>{'Scheduled','Completed'};
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        update conAss[0]; 
         
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
               
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
                         
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
                
        //List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        //System.debug('projects========'+projects);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        System.debug('task ====='+task);
    
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        update schList;
        System.debug('schList===='+schList);
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
        insert event;
        System.debug('event ========='+event );
        
        System.runAs(user){
            EventCalendarController.getEventRecordList(String.valueOf(year1), String.valueOf(Year2), status);
        }
        
        Test.stopTest();
    }
    
    private static testMethod void myTest3(){
    
        Integer year1 = Date.Today().Year();
        Integer year2 = year1-1;
        List<String> status = new List<String>{'Scheduled','Completed'};
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        update conAss[0]; 
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
    
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
                        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
                
        //List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        //System.debug('projects========'+projects);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        System.debug('task ====='+task);
    
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        update schList;
        System.debug('schList===='+schList);
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
        insert event;
        System.debug('event ========='+event );
        
        List<Planned_Days_Off__c> pdo = [SELECT Id, Name, Status__c, Contact__c FROM Planned_Days_Off__c WHERE RecordType.DeveloperName = 'Instructor_Planned_Days_Off'];
        pdo[0].Contact__c = conList[0].Id;
        pdo[0].Status__c = 'Approved';
        update pdo[0];
        
        System.runAs(user){
            EventCalendarController.getEventRecordList(String.valueOf(year1), '', status); 
            EventCalendarController.getEventRecordList('', String.valueOf(Year2), status);
            EventCalendarController.getEventRecordList('', '', status);
        }
        Test.stopTest();
    }
    
    private static testMethod void myTest4(){
        EventCalendarController.getLookupRecords('Test','Account','Name','',new List<String>());
    }
    
    private static testMethod void myTest5(){
        EventCalendarController.getTimeValues();
    }
    
    private static testMethod void myTest6(){
        List<Events__c> evts = [SELECT Id,Project__c FROM Events__c LIMIT 4];
        String insRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        String stuRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id != :evts[0].Project__c];
      
         Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = conList[0].Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE Status__c = 'Active' LIMIT 2];
        conAss[0].Project__c = evts[0].Project__c;
        conAss[0].RecordTypeId = stuRT;
        conAss[0].Candidate_Name__c = conList[0].Id;

        
        conAss[1].RecordTypeId = insRT;
        conAss[1].Project__c = projects[0].Id;
        
        update conAss; 
        
        evts[0].Start_Time__c = '6:00 AM'; 
        evts[0].End_Time__c = '8:00 AM';
        evts[0].Date__c = System.Today();
        
        evts[1].Status__c = 'Scheduled';
        evts[1].Start_Time__c = '7:00 AM';
        evts[1].End_Time__c = '9:00 AM';
        evts[1].Date__c = System.Today();
        
       
        evts[2].Status__c = 'Scheduled';
        evts[2].Start_Time__c = '8:00 AM';
        evts[2].End_Time__c = '9:00 AM';
        evts[2].Date__c = System.Today();
        evts[2].Project__c = projects[0].Id;

        evts[3].Status__c = 'Scheduled';
        evts[3].Start_Time__c = '10:00 AM'; 
        evts[3].End_Time__c = '11:00 AM';
        evts[3].Date__c = System.Today();
        evts[3].Project__c = projects[0].Id;
        
        
        update evts;
        
        Test.stopTest();
        
        List<EventDomain.EventCalendarInfo> eventInfos = new List<EventDomain.EventCalendarInfo>();
        EventDomain.EventCalendarInfo eventInfo = new EventDomain.EventCalendarInfo();
        eventInfo.eventId = evts[0].Id;
        eventInfo.projectId = evts[0].Project__c;
        eventInfo.eventDate = evts[0].Date__c;
        eventInfo.startTime = '7:30 AM';
        eventInfo.endTime = '9:30 AM';
        
        eventInfos.add(eventInfo); 
        String eventJSON = JSON.serialize(eventInfos);
        
        System.runAs(user){ 
            EventDomain.EventConflictInfo evntInfo = EventCalendarController.getEventConflictInfo(eventJSON,'instructor');
            Map<String,List<EventDomain.EventConflictDetail>> conflictDetailMap = evntInfo.EventConflicts;
            System.assertEquals(true,evntInfo.isAllowForReschedule);
            system.assertEquals(true,conflictDetailMap.containsKey('Room Conflict'));
            system.assertEquals(false,conflictDetailMap.containsKey('Student/Instructor Conflict'));
        }
    }
    
    private static testMethod void myTest6A(){
        List<Events__c> evts = [SELECT Id,Project__c FROM Events__c LIMIT 3];
        String insRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        String stuRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id != :evts[0].Project__c];


      
         Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = conList[0].Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE Status__c = 'Active' LIMIT 2];
        conAss[0].Project__c = evts[0].Project__c;
        conAss[0].RecordTypeId = stuRT;
        
        conAss[1].RecordTypeId = insRT;
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[1].Project__c = projects[0].Id;
        
        update conAss; 
        
        evts[0].Start_Time__c = '6:00 AM'; 
        evts[0].End_Time__c = '8:00 AM';
        evts[0].Date__c = System.Today();
        
        
        evts[1].Status__c = 'Scheduled';
        evts[1].Start_Time__c = '8:00 AM';
        evts[1].End_Time__c = '10:00 AM';
        evts[1].Date__c = System.Today();
        
        evts[2].Status__c = 'Scheduled';
        evts[2].Start_Time__c = '6:00 AM';
        evts[2].End_Time__c = '7:00 AM';
        evts[2].Date__c = System.Today();
        evts[2].Project__c = projects[0].Id;
                
        update evts;
        
        Test.stopTest();
        
        List<EventDomain.EventCalendarInfo> eventInfos = new List<EventDomain.EventCalendarInfo>();
        EventDomain.EventCalendarInfo eventInfo = new EventDomain.EventCalendarInfo();
        eventInfo.eventId = evts[0].Id;
        eventInfo.projectId = evts[0].Project__c;
        eventInfo.eventDate = evts[0].Date__c;
        eventInfo.startTime = '7:30 AM';
        eventInfo.endTime = '8:30 AM';
        
        eventInfos.add(eventInfo); 
        String eventJSON = JSON.serialize(eventInfos);
        
        System.runAs(user){ 
            EventDomain.EventConflictInfo evntInfo = EventCalendarController.getEventConflictInfo(eventJSON,'student');
            Map<String,List<EventDomain.EventConflictDetail>> conflictDetailMap = evntInfo.EventConflicts;
            System.assertEquals(true,evntInfo.isAllowForReschedule);
            system.assertEquals(false,conflictDetailMap.containsKey('Student/Instructor Conflict'));
        }
    }
    
    //To cover saveEventRecords() method with (update parent status as Late Cancellation) 
    private static testMethod void myTest8(){
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = conList[0].Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        
        Test.startTest();
        
        insert user;
        
        List<Events__c> events = [SELECT Id,Project__c,Schedule__r.Project_Task__r.Project_Task_Type__c, Instructor__c, Status__c, Date__c FROM Events__c LIMIT 2];
        
        Events__c childEvt = new Events__c();
        
        childEvt.Id = events[1].Id;
        childEvt.Approval_Status__c = 'LTS Approved';
        childEvt.Parent_Event__c = events[0].Id;
        childEvt.Status__c = 'Draft';
        childEvt.Approver_Name__c = conList[0].Id;
        childEvt.Parent_Status_Changed_To__c = 'Rescheduled';
        
        update childEvt;
        
        System.runAs(user){ 
            childEvt.Approval_Status__c = 'Instructor Approved';
            childEvt.Status__c = 'Scheduled';
            
            EventCalendarController.saveEventRecs(new List<Events__c>{childEvt});
            List<Events__c> evts = [SELECT Id, Status__c FROM Events__c WHERE  Id = :events[0].Id];
            
            System.assertEquals('Rescheduled', evts[0].Status__c);
        }
        Test.stopTest();
    }
    
    private static testMethod void myTest9(){
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = conList[0].Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        
        Test.startTest();
        
        insert user;
        
        
        List<Events__c> events = [SELECT Id,Project__c,Schedule__c,Schedule__r.Project_Task__r.Project_Task_Type__c, Instructor__c, Status__c, Date__c FROM Events__c LIMIT 1];
        
        Events__c newEvt = new Events__c();
        
        newEvt.Approval_Status__c = 'Submitted for Approval';
        newEvt.Parent_Event__c = events[0].Id;
        newEvt.Status__c = 'Draft';
        newEvt.Approver_Name__c = conList[0].Id;
        newEvt.Parent_Status_Changed_To__c = 'Late Cancellation';
        newEvt.Schedule__c = events[0].Schedule__c;
        
        System.runAs(user){ 
          EventCalendarController.createRescheduledEvent(JSON.serialize(new List<Events__c>{newEvt}));
        }
        Test.stopTest();
    }
    
    private static testMethod void myTest10(){
    
        List<Events__c> evts = [SELECT Id,Project__c FROM Events__c LIMIT 3];
        String insRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        String stuRT = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id != :evts[0].Project__c];

      
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = conList[0].Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE Status__c = 'Active' LIMIT 2];
        conAss[0].Project__c = evts[0].Project__c;
        conAss[0].RecordTypeId = stuRT;
        
        conAss[1].RecordTypeId = insRT;
        conAss[1].Candidate_Name__c = conList[0].Id;
        conAss[1].Project__c = projects[0].Id;
        
        update conAss; 
        
        evts[0].Start_Time__c = '6:00 AM'; 
        evts[0].End_Time__c = '8:00 AM';
        evts[0].Date__c = System.Today();
        
         
         evts[1].Status__c = 'Scheduled';
         evts[1].Start_Time__c = '8:00 AM';
         evts[1].End_Time__c = '10:00 AM';
         evts[1].Date__c = System.Today();
         evts[1].Project__c = projects[0].Id;

        
        evts[2].Status__c = 'Scheduled';
        evts[2].Start_Time__c = '6:00 AM';
        evts[2].End_Time__c = '7:00 AM';
        evts[2].Date__c = System.Today();
                
        update evts;
        
        Test.stopTest();
        
        List<EventDomain.EventCalendarInfo> eventInfos = new List<EventDomain.EventCalendarInfo>();
        EventDomain.EventCalendarInfo eventInfo = new EventDomain.EventCalendarInfo();
        eventInfo.eventId = evts[0].Id;
        eventInfo.projectId = evts[0].Project__c;
        eventInfo.eventDate = evts[0].Date__c;
        eventInfo.startTime = '7:30 AM';
        eventInfo.endTime = '8:30 AM';
        
        eventInfos.add(eventInfo); 
        String eventJSON = JSON.serialize(eventInfos);
        
         System.runAs(user){ 
             EventDomain.EventConflictInfo evntInfo = EventCalendarController.getEventConflictInfo(eventJSON,'instructor');
             Map<String,List<EventDomain.EventConflictDetail>> conflictDetailMap = evntInfo.EventConflicts;
             System.assertEquals(true,evntInfo.isAllowForReschedule);
             system.assertEquals(false,conflictDetailMap.containsKey('Student/Instructor Conflict'));
         }
     }
     
     // To cover getEventsForApproval() method in EventCalendarController
     private static testMethod void myTest11(){
     
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = conList[0].Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        System.runAs(user){ 
        
            EventCalendarController.getEventsForApproval();
        }
        Test.stopTest();
     }
     
     // To cover getDetailsForRequestEvent() method in EventCalendarController
     private static testMethod void myTest12(){
     
        Account a = new Account();
        a.Name = 'Softsquare ELT';
        insert a;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        
        List<Contact> conList = [SELECT Id, AccountId FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Student'];
        conList[0].AccountId = a.Id;
        update conList[0];
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                             ContactId = conList[0].Id,
                             timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE Status__c = 'Active' AND RecordType.DeveloperName = 'Student' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        update conAss[0];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        projects[0].AcctSeed__Account__c = a.Id;
        update projects[0];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
    
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        update schList;
        System.debug('schList===='+schList);
            
        System.runAs(user){ 
        
            EventCalendarController.getDetailsForRequestEvent();
        }
        Test.stopTest();
     }
}