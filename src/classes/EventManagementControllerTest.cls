@isTest
public class EventManagementControllerTest {

    @testSetup static void setup(){
            
        Test.StartTest();
            List<Contact_Assignments__c> conAssList = TestClassUtil.createTestContactAssignment();
            List<AcctSeed__Time_Card_Day__c> timecarddayList = TestClassUtil.createTestTimeCardDay();
        Test.Stoptest();    
        List<Attendance__c> attenList = TestClassUtil.createTestAttendance();
        List<Room__c> roomlist = TestClassUtil.createTestRoom();     
    }
    
    static testMethod void testremoveEvents() {
        List<Events__c> remEvList = [SELECT Id, Schedule__c FROM Events__c WHERE Schedule__c != null LIMIT 2];
        Test.startTest();
        if(remEvList != null && remEvList.size() > 0){
            String jsonUpEvent = JSON.serializePretty(remEvList);
            EventManagementController.removeEvents(jsonUpEvent);
        }
        Test.stopTest();    
    }
    static testMethod void testmethod1() {
        
        try{            
            List<Events__c> upEvList = [SELECT Id, Schedule__c,Schedule__r.Project__c FROM Events__c WHERE Schedule__c != null LIMIT 1];
            
            upEvList[0].Status__c = 'Scheduled';
            update upEvList;
            
            
            Test.startTest();
            
                EventManagementController.cancelSchedule(upEvList[0].Schedule__c, 'Test Cancel');
                List<Contact_Assignments__c> Conassign = [SELECT Id,Name,Candidate_Name__c from Contact_Assignments__c LIMIT 1];
                if(Conassign != null && Conassign.size() > 0){
                    EventManagementController.getStudentEvents(Conassign[0].Candidate_Name__c);
                }
                
            Test.stopTest();  

        }catch(Exception e){
            System.assertEquals(true, e.getMessage().contains('Case Created to Create meeting for this Event.'));
        }
         
    }
    static testMethod void testmethod3() {
        
        List<Events__c> upEvList = [SELECT Id, Schedule__c, Instructor__c, Schedule__r.Project__c,Project__c,Schedule__r.Project_Task__c FROM Events__c WHERE Schedule__c != null LIMIT 1];
        
        List<Contact_Assignments__c> Conassign = [SELECT Id,Name,Candidate_Name__c from Contact_Assignments__c LIMIT 1];
        
        Test.startTest();
        
        EventManagementController.getStudentEvents(Conassign[0].Candidate_Name__c);
        
        //List<AcctSeed__Time_Card_Day__c> timecardDayList = [select id,AcctSeed__Time_Card_Line__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c from AcctSeed__Time_Card_Day__c];
        //system.debug('timecardDayList:::'+timecardDayList);       
        Test.stopTest();
    }
    static testMethod void testmethod4() {
        
        List<Events__c> upEvList = [SELECT Id, Schedule__c,Schedule__r.Project__c,Project__c,Instructor__c FROM Events__c WHERE Schedule__c != null LIMIT 1];        
        String updateevent = Json.Serialize(upEvList);
        Test.StartTest();
            List<Schedule__c> schList = [SELECT Id, Name,Project__c, Project__r.Project_Manager__c FROM Schedule__c WHERE Project__c =:upEvList[0].Project__c LIMIT 2];            
            EventManagementController.getInstructorsWithConflicts(upEvList[0].Schedule__c, 'Admin_Projects');
            EventManagementController.setInstructor(schList[0].Id, upEvList[0].Instructor__c);
            EventManagementController.geteventupdate(updateevent);
            EventManagementController.getEventsByparentType(schList[0].Project__c,'Project',2,5);
        Test.StopTest();
    }
    static testMethod void testmethod5() {
        
        List<Events__c> upEvList = [SELECT Id, Schedule__c,Schedule__r.Project__c,Project__c FROM Events__c WHERE Schedule__c != null];
        Test.startTest();
        try{
            EventManagementController.isConflicted(system.today(),'5','6',upEvList[0]);            
            EventManagementController.getInstructorsWithConflicts(upEvList[0].Schedule__c,'Testing_Projects');            
        }
        catch(Exception e){
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }   
    static testMethod void testmethod6() {
        Test.startTest();
            List<Events__c> upEvList = [SELECT Id, Schedule__c,Schedule__r.Project__c,Project__c,Instructor__c FROM Events__c WHERE Schedule__c != null];
            List<Contact_Assignments__c> contactAssignmnetsList = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c LIMIT 3];
            Set<Id> schId = new Set<Id>();
            
            for(Events__c eve : upEvList) {
                schId.add(eve.Schedule__c);
            }
            
            List<Schedule__c> schList = [SELECT Id, Name FROM Schedule__c WHERE Id NOT IN :schId];
            
            EventManagementController.getEventCountOn(system.today(), contactAssignmnetsList[0].Candidate_Name__c);
            EventManagementController.getEventsListOn(system.today(), upEvList[0].Instructor__c);
            EventManagementController.getContactAllEvents(upEvList[0].Instructor__c);
            EventManagementController.getCoContactAllEvents(upEvList[0].Instructor__c);
            EventManagementController.getHolidays();
            EventManagementController.getPlannedOffs(upEvList[0].Instructor__c);
            String jsonevtupdate = Json.serialize(upEvList);
            EventManagementController.EventUpdationFromAgendaBuilder(jsonevtupdate);
            //EventManagementController.removeOpportunitySchedule(schList[0].Id);
        Test.StopTest();
        
    }
    static testMethod void testmethod7() {
        Test.startTest();
        List<Events__c> upEvList = [SELECT Id, Schedule__c,Schedule__r.Project__c,Project__c FROM Events__c WHERE Schedule__c != null LIMIT 1];
        EventManagementController.updateAgenda(upEvList[0].Id,'');
        EventManagementController.getTimzone();
        EventManagementController.activateSchedule(upEvList[0].Schedule__c);
        EventManagementController.testmet();
        Test.StopTest();
    }
    static testMethod void testContentDistributionMethods(){
        Test.startTest();
        List<Events__c> upEvList = [SELECT Id, Schedule__c,Schedule__r.Project__c,Project__c FROM Events__c WHERE Schedule__c != null];
        EventManagementController.convertToMinutes(' 11:AM');
        EventManagementController.convertToMinutes(' 12:AM');
        EventManagementController.TotalOffs totalOff = new EventManagementController.TotalOffs('',system.today(),'',system.today());
        Set<Id> eventset = new Set<Id>();
        for(Events__c pl : upEvList){
            eventset.add(pl.Id);
            
        }        
                
        List<Contact_Assignments__c> Conassign = [SELECT Id,Name,Candidate_Name__c from Contact_Assignments__c];        
        
        List<Planned_Days_Off__c> plannedDays = [SELECT Id, Name FROM Planned_Days_Off__c];
        
        Set<Id> plannedDaysoff = new Set<Id>();
        for(Planned_Days_Off__c pl : plannedDays){
            plannedDaysoff.add(pl.Id);
            
        }
        string jsonplannedDays = JSON.serializePretty(plannedDays);
        String jsonevtupdate = JSON.serializePretty(upEvList);
        String jsonevtdel = JSON.serializePretty(eventset);
        String jsonplannedDaysoffdel = JSON.serializePretty(plannedDaysoff);
        
        try{
            EventManagementController.InstructorWithConflicts insConflict = new EventManagementController.InstructorWithConflicts();
            EventManagementController.InstructorWithConflicts insConflict1 = new EventManagementController.InstructorWithConflicts(Conassign[0].Candidate_Name__c,'');
            
           
            EventManagementController.StudentClass studcls = new EventManagementController.StudentClass('',Conassign[0].Candidate_Name__c);
            studcls.add(upEvList[0]);
            
            EventManagementController.updatePlannedDaysEditorData(jsonevtupdate,jsonevtdel,jsonplannedDays,jsonplannedDaysoffdel);
        }catch(Exception e){}
        Test.stopTest();
        
    }  
    static testMethod void testcancellEventByUserCommunity() {
        
        List<Events__c> upEvList = [SELECT Id, Schedule__c, Instructor__c,Project__c ,Schedule__r.Opportunity__c FROM Events__c WHERE Schedule__c != null];
        
        List<AcctSeed__Project__c> projList = [SELECT Id, Name, AcctSeed__Status__c,RecordTypeId, Project_Manager__c, AcctSeed__Opportunity__c, Start_Date__c, End_Date__c FROM AcctSeed__Project__c LIMIT 2];
        
        Test.StartTest();
        List<Contact_Assignments__c> conAssign = new List<Contact_Assignments__c> {                
            new Contact_Assignments__c(Project__c=upEvList[0].Project__c,Candidate_Name__c=upEvList[0].Instructor__c,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=projList[0].AcctSeed__Opportunity__c,Status__c = 'Active')
            //new Contact_Assignments__c(Project__c=upEvList[0].Project__c,Candidate_Name__c=upEvList[0].Instructor__c,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=projList[0].AcctSeed__Opportunity__c,Status__c = 'Active')
        };
        
        List<RecordType> conrt = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType = 'Contact' And DeveloperName = 'Candidate'];
        Account a = new Account(Name='Test Account Name');
        insert a;
        
        List<Contact> con1 = new List<Contact>{
            new Contact(LastName = 'Testing Contact',RecordTypeId = conrt[0].Id, AccountId = a.Id)
            //new Contact(LastName = 'Testing Contact 1',RecordTypeId = conrt[0].Id, AccountId = a.Id)
        };
        
        insert con1;
        List<Profile> Profile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User Clone'];
        
        String un = String.valueOf(System.now().millisecond())+'@dlsTestOrg.dlsdc';
        String en = String.valueOf(System.now().millisecond())+'@dlsTestOrg.com';
        
        User usr = new User(Alias = 'standt', Email='test@gmail.com',EmailEncodingKey='UTF-8',LastName = con1[0].LastName,
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = Profile[0].Id,Instructor_Access__c = false,
        TimeZoneSidKey='America/Los_Angeles', UserName=un,ContactId = con1[0].Id);
        
        insert usr;   
        System.runAs(usr){ 
        
            //User userList = [SELECT Id, contactId FROM User WHERE Instructor_Access__c = true AND IsActive = true LIMIT 1];
           // system.debug('::::userList'+userList);
            
            //System.runAs(userList)         
          
           try{
                EventManagementController.cancellEventByUserCommunity(upEvList[0].Id,upEvList[0].Instructor__c);
                
            }catch(Exception e){
                System.assertEquals(true,e.getMessage().Contains('Case Created for cancelling this Event'));
            }
    
            try{
                EventManagementController.rescheduleEventCommunity(upEvList[0].Id, conAssign[0].Candidate_Name__c, String.ValueOf(System.today()),String.ValueOf(System.today().addDays(1)), '', 'COMMUNITY');
            }catch(Exception e){
                System.assertEquals(true,e.getMessage().Contains('Case Created To Reschedule this Event'));
            }
            List<Holiday> holydayList = [SELECT Id, ActivityDate FROM Holiday LIMIT 1];
            String leave = String.valueOf(holydayList[0].ActivityDate);
            List<Planned_Days_Off__c> plannedDaysOff = [SELECT Description__c, Name, Id, Date__c FROM Planned_Days_Off__c LIMIT 1];
            List<Events__c> evlist = [SELECT Id, Name, Schedule__c, Instructor__c, Date__c FROM Events__c WHERE Schedule__r.Project__c = Null LIMIT 1];

            try{
                EventManagementController.rescheduleEventCommunity(evlist[0].Id, conAssign[0].Candidate_Name__c, String.ValueOf(System.today()),String.ValueOf(System.today().addDays(1)), '', 'COMMUNITY');
            }catch(Exception e){
                System.assertEquals(true,e.getMessage().Contains('Case Created To Reschedule this Event'));
            }
            try{
                EventManagementController.rescheduleEventCommunity(upEvList[0].Id, conAssign[0].Candidate_Name__c, String.ValueOf(System.today()),String.ValueOf(System.today().addDays(1)), '', '');
            }catch(Exception e){
                //System.assertEquals(true,e.getMessage().Contains('Already an event'));                
            }
            try{
                EventManagementController.rescheduleEventCommunity(upEvList[0].Id, conAssign[0].Candidate_Name__c, leave,String.ValueOf(System.today().addDays(1)), '', '');
            }catch(Exception e){
                //System.assertEquals(true,e.getMessage().Contains('New Date conflicted with an holiday at'));                
            }
            try{
                EventManagementController.rescheduleEventCommunity(upEvList[0].Id, conAssign[0].Candidate_Name__c, String.ValueOf(System.today().addDays(7)), '09.00AM', '07.30PM', '');
            }catch(Exception e){
                // Error while inserting new event in LineNo:609 on Apex Class EventManagementController
                System.debug('$$$$$$$'+e.getMessage());
            }
            
            String dt = String.ValueOf(system.today());
            EventManagementController.cancellEventByUser(upEvList[0].Id,con1[0].Id);
            EventManagementController.rescheduleEvent(upEvList[0].Id,con1[0].Id,dt,'09:00','21:00','COMMUNITY');
          
            try {
                EventManagementController.rescheduleEvent(upEvList[0].Id,con1[0].Id,dt,'00:30','00:35','CONFLICTED');
            } catch(exception ex) {
                System.debug(':::***:::Exception:::'+ex.getMessage());
            }         
            
            Test.stopTest();
        }   
    }  
    
    static testMethod void testcancellEventByUserCommunity1() {
        
        List<Events__c> upEvList = [SELECT Id, Schedule__c, Instructor__c,Project__c ,Schedule__r.Opportunity__c FROM Events__c WHERE Schedule__c != null];
        List<AcctSeed__Project__c> projList = [SELECT Id, Name, AcctSeed__Status__c,RecordTypeId, Project_Manager__c, AcctSeed__Opportunity__c, Start_Date__c, End_Date__c FROM AcctSeed__Project__c LIMIT 2];
        List<RecordType> conrt = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType = 'Contact' And DeveloperName = 'Candidate'];
        
        Account a = new Account(Name='Test Account Name');
        insert a;
        
        List<Contact> con1 = new List<Contact>{
            new Contact(LastName = 'Testing Contact',RecordTypeId = conrt[0].Id, AccountId = a.Id)
        };
        insert con1;
        String dt = String.ValueOf(system.today().addDays(-10));
       
        if(upEvList.size() > 0 && projList.size() > 0) {
            Test.StartTest();
            EventManagementController.rescheduleEvent(upEvList[0].Id,con1[0].Id,dt,'06:00 AM','07:00 AM','CONFLICTED');
            Test.stopTest();
        }   
    }
    
    static testMethod void myNewTest(){
    
        
        Room__c room = [SELECT Id FROM Room__c LIMIT 1];
        EventManagementController.getEventsByparentType(room.Id,'room',2,5);
        
        List<Events__c> evlist = [SELECT Id, Name, Schedule__c, Schedule__r.Project__c, Instructor__c, Date__c, Project__c FROM Events__c WHERE Schedule__c != Null LIMIT 1];
        
        Test.startTest();
        
        try{
            EventManagementController.rescheduleEventCommunity(evlist[0].Id, evlist[0].Instructor__c, String.ValueOf(System.today()),String.ValueOf(System.today().addDays(1)), '', 'INSTRUCTOR');
        }catch(Exception e){
            System.assertEquals(true,e.getMessage().Contains('Case Created To Reschedule this Event'));
        }
        Test.stopTest();
        
    }
    static testMethod void myTest1(){
                
        List<AcctSeed__Project__c> prolist=[SELECT Id ,Name FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projectlist =  [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__c, Project_Task_Type__c, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        
        List<Events__c> evlist = [SELECT Id, Name, Schedule__c, Schedule__r.Project__c, Instructor__c, Date__c, Project__c FROM Events__c WHERE Schedule__c != Null LIMIT 1];
           
        List<Schedule__c> schList = [SELECT Id, Name,Project__c, Project__r.Project_Manager__c FROM Schedule__c LIMIT 1];
        Contact con = [SELECT Id, Name,AccountId FROM Contact WHERE Name LIKE '%Testing%' LIMIT 1];
        System.debug('schList'+schList);
        System.debug('evlist'+evlist);
        
        Room__c room = [SELECT Id FROM Room__c LIMIT 1];
        List<Events__c> evlist1 = [SELECT Id, Name, Schedule__c, Schedule__r.Project__c, Instructor__c, Date__c, Project__c FROM Events__c WHERE Schedule__c != Null AND Id != :evlist[0].Id LIMIT 1];
        String jsonUpEvent1 = JSON.serializePretty(evlist1);
        
        Test.startTest();
        List<Events__c> myEvt = new List<Events__c> {
                
            new Events__c(Schedule__c = evlist1[0].Schedule__c, SequenceNo__c = 12, Status__c = 'Scheduled', Project__c = evlist1[0].Schedule__r.Project__c, 
            Date__c = System.today(),Instructor__c = evlist1[0].Instructor__c, Room__c = room.Id)
        
        };
        
        if(evlist!= null && evlist.size() > 0){
            String jsonUpEvent = JSON.serializePretty(evlist);
            EventManagementController.UpdateEvents(jsonUpEvent1,evlist[0].Schedule__c,jsonUpEvent,evlist[0].Instructor__c,room.Id);
            
        }        
        
        List<Contact_Assignments__c> Conassign = [SELECT Id,Name,Candidate_Name__c from Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' LIMIT 1];
        
        String jsonUpEvent5 = JSON.serializePretty(myEvt);
        EventManagementController.modifyOpportunitySchedule(evlist1[0].Schedule__c,jsonUpEvent5);
        
        EventManagementController.getEventsByparentType(projectlist[0].Id,'projectTask',2,5);
        
        Test.stopTest();
        
        EventManagementController.getEventsByparentType(evlist[0].Instructor__c, 'instructor',2,5);
        EventManagementController.getEventsByparentType(Conassign[0].Candidate_Name__c, 'client',2,0);
        
        //try{
            //EventManagementController.setInstructor(null,evlist[0].Instructor__c);
       //}catch(Exception e){
           // System.assertEquals(true, e.getMessage().contains('Schedule Id should not be nul'));
        //}
        
    }
    
    static testMethod void myTest1a(){
    
        List<AcctSeed__Project_Task__c> projectlist =  [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__c, Project_Task_Type__c, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        
        List<Events__c> evlist = [SELECT Id, Name, Schedule__c, Schedule__r.Project__c, Instructor__c, Date__c, Project__c FROM Events__c WHERE Schedule__c != Null LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Name,Project__c, Project__r.Project_Manager__c FROM Schedule__c LIMIT 1];
        
        Contact con = [SELECT Id, Name,AccountId FROM Contact WHERE Name LIKE '%Testing%' LIMIT 1];
        
        List<Contact_Assignments__c> Conassign = [SELECT Id,Name,Candidate_Name__c from Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' LIMIT 1];
        
        Test.startTest();
        
        EventManagementController.getEventsByparentType(Conassign[0].Candidate_Name__c, 'client',2,5);
        EventManagementController.getEventsByparentType(con.AccountId, 'test',2,5);
        EventManagementController.getEventsByparentType(Conassign[0].Candidate_Name__c , 'Staff',2,5);
        EventManagementController.getEventsByparentType(Conassign[0].Candidate_Name__c , 'Staff',2,0);        
        EventManagementController.getTodayEvents();
        
        List<Events__c> event = new List<Events__c>{
            new Events__c(Name = 'Test Event', Schedule__c = schList[0].Id, SequenceNo__c = 1, Instructor__c=evlist[0].Instructor__c, Date__c = system.today().addDays(-1), Status__c = 'Completed', Project__c = evlist[0].Project__c)
        };
        
        String jsonEvent = JSON.Serialize(event[0]);system.debug('jsonEvent'+jsonEvent);
        EventManagementController.createTestEvent(jsonEvent);
        
        EventManagementController.getStudentRelative(evlist[0].Project__c, schList[0].Id);
        EventManagementController.getContactassignmentByParent(projectlist[0].Id,'projectTask');
        //EventManagementController.setInstructor(schList[0].Id, con.Id);
        
        try{
            EventManagementController.setInstructor(schList[0].Id, null);
        }catch(Exception e){
            //System.assertEquals(true, e.getMessage().contains('Instructor Id should not be null'));
        }
        Test.stopTest();
    }
    
    static testMethod void myTest3(){
        
        List<Events__c> evlist2 = new List<Events__c>();
        Date weekStart = System.today().toStartofWeek().addDays(1);
        Date WeekEnd = System.today().toStartofWeek().addDays(7);

        List<Events__c> evt = [SELECT Id, Name, Schedule__c, Instructor__c FROM Events__c WHERE Schedule__r.Project__c = Null LIMIT 1];
        List<Events__c> evlist = [SELECT Id, Schedule__c, Schedule__r.Project__c, Instructor__c, Date__c, Project__c FROM Events__c WHERE Schedule__r.Project__c != Null LIMIT 1];//Schedule__r.Project__c  != Null AND Status__c = 'Scheduled'
          
        EventManagementController.cancelSchedule(evt[0].Schedule__c, 'Test Cancel');

        Room__c room = [SELECT Id FROM Room__c LIMIT 1];
        List<Events__c> diffSchEvlist = [SELECT Id, Schedule__c, Schedule__r.Project__c, Instructor__c, Date__c, Project__c FROM Events__c WHERE Schedule__c != :evlist[0].Schedule__c LIMIT 1];
        
        diffSchEvlist[0].Room__c = room.Id;
        diffSchEvlist[0].Date__c = System.today().addDays(100);
        diffSchEvlist[0].Status__c= 'Scheduled';
        diffSchEvlist[0].Date__c= system.Today().addDays(120);
        update diffSchEvlist;
        Test.startTest();
        evlist[0].Room__c = room.Id;
        evlist[0].Date__c = System.today().addDays(11);
        evlist[0].Status__c= 'Scheduled';
        update evList;
        
        EventManagementController.getNonConflictedRooms(evt[0].Schedule__c);
        String jsonUpEvent3 = JSON.serializePretty(evList);
        try{
            EventManagementController.isConflictsInNewEventsOnSave(jsonUpEvent3);
        }
        catch(Exception e){
            //System.assertEquals(true, e.getMessage().contains('Already an event'));
        }
        
        List<Holiday> holydayList = [SELECT Id, ActivityDate FROM Holiday LIMIT 1];
        evlist[0].Date__c = System.Today().addDays(15);
        update evList; 
        String jsonEvent = JSON.serializePretty(evList);
        
        try{
            EventManagementController.isConflictsInNewEventsOnSave(jsonEvent);
        }catch(Exception e){
           // System.assertEquals(true, e.getMessage().contains('Event Conflict with a holiday at'));
        }
        String jsonEvent1 = JSON.serialize(diffSchEvlist);
        EventManagementController.isConflictsInNewEventsOnSave(jsonEvent1);
                
        Test.stopTest();
    }
    
    static testMethod void myTest3a(){
    
        Date weekStart = System.today().toStartofWeek().addDays(1);
        Date WeekEnd = System.today().toStartofWeek().addDays(7);
        
        Room__c room = [SELECT Id FROM Room__c LIMIT 1];
        
        List<Events__c> evt = [SELECT Id, Name, Schedule__c, Instructor__c FROM Events__c WHERE Schedule__r.Project__c = Null LIMIT 1];
        List<Events__c> evlist = [SELECT Id, Schedule__c, Schedule__r.Project__c, Instructor__c, Date__c, Project__c FROM Events__c WHERE Schedule__r.Project__c != Null LIMIT 1];//Schedule__r.Project__c  != Null AND Status__c = 'Scheduled'
        
        List<Events__c> evlist2 = [SELECT Id, Name, Schedule__c, Schedule__r.Project__c, Instructor__c, Date__c, Project__c FROM Events__c WHERE Id != :evlist[0].Id LIMIT 1];
        
        String jsonUpEvent = JSON.serializePretty(evlist);
        String jsonUpEvent2 = JSON.serializePretty(evlist2);
        String jsonUpEvent1 = JSON.serializePretty(evt);
        Test.startTest();
        List<AcctSeed__Time_Card_Day__c> cardDay = [SELECT Id, AcctSeed__Date__c, AcctSeed__Time_Card_Line__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c FROM AcctSeed__Time_Card_Day__c LIMIT 1];
        
        String stDate = String.valueOf(weekStart);
        String edDate = String.valueOf(WeekEnd);
        if(cardDay != null && cardDay.size()>0){
            String prjtTaskType = cardDay[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c;
            Id insId = cardDay[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
                                  
            Contact con = [SELECT Id FROM Contact WHERE Name LIKE 'Testing' LIMIT 1];
            EventManagementController.UpdateEvents(jsonUpEvent2,evlist[0].Schedule__c,jsonUpEvent,con.Id,room.Id);
        }
        Test.stopTest();
    }
    static testMethod void myTest4(){
        
        List<Events__c> evlist = [SELECT Id, Name, Schedule__c, Instructor__c,Schedule__r.Opportunity__c, Date__c FROM Events__c WHERE Schedule__r.Project__c = Null LIMIT 2];
        Test.startTest();
        EventManagementController.setInstructor(evlist[0].Schedule__c, evlist[0].Instructor__c);
        
        Room__c room = [SELECT Id FROM Room__c LIMIT 1];
        
        List<Events__c> newEvt1 = new List<Events__c>{new Events__c(Name=evList[0].Name,SequenceNo__c=1,Schedule__c=evList[0].Schedule__c,Instructor__c=evList[0].Instructor__c,Date__c=evList[0].Date__c,Room__c=room.Id ,Status__c = 'Scheduled')
                                                    };
        String jsonEvent2 = JSON.serializePretty(newEvt1);
        EventManagementController.isConflictsInNewEvents(jsonEvent2,evlist[0].Schedule__c,evlist[0].Schedule__r.Opportunity__c,'OPPORTUNITY');
        EventManagementController.CreateEvents(jsonEvent2,evList[0].Schedule__c);
        
        evlist[0].Start_Time__c = '10:00 AM';
        evlist[0].End_Time__c = '07:30 PM';
        evlist[0].Room__c = room.Id;
        evlist[0].Date__c = System.Today().addDays(150);
        evlist[1].Date__c = System.Today().addDays(170);
        update evlist;
        String jsonEvent = JSON.serializePretty(evList);
        EventManagementController.isConflictsInNewEventsOnSave(jsonEvent);
        
        List<Events__c> newEvt = new List<Events__c>{new Events__c(Name=evList[0].Name,SequenceNo__c=1,Schedule__c=evList[0].Schedule__c,Instructor__c=evList[0].Instructor__c,Date__c=System.Today().addDays(10),Room__c=evList[0].Room__c,Status__c = 'Scheduled')
                                                    };
        String jsonEvent1 = JSON.serializePretty(newEvt);
        EventManagementController.modifyOpportunitySchedule(evlist[0].Schedule__c, jsonEvent1);
        EventManagementController.getInstructorsWithConflicts(evlist[0].Schedule__c, '');
        
        ContentVersion cv = new ContentVersion(title='Test title',VersionData=blob.valueof('New Bitmap Image.bmp'), PathOnClient ='/google.com');
        insert cv;
        ContentVersion cv1 = new ContentVersion(title='Test title',VersionData=blob.valueof('Testing'), PathOnClient ='/google.com');
        insert cv1;
        
        List<ContentDistribution> con = new List<ContentDistribution>{new ContentDistribution(Name ='Delete Test', ContentVersionId=cv.Id)};
        String jsonContact = JSON.serializePretty(con);
        
        Test.stopTest();
        
        List<ContentDistribution> con1 = new List<ContentDistribution>{new ContentDistribution(Name ='Insert Test', ContentVersionId=cv1.Id)};
        insert con1;
        String jsonContact1 = JSON.serializePretty(con1);
        
        EventManagementController.ContentDistributionMethods(jsonContact,jsonContact1);
        
    }
    
    static testMethod void myTest4a(){
        
        List<Events__c> evlist = [SELECT Id, Name, Schedule__c, Instructor__c,Schedule__r.Opportunity__c, Date__c, Schedule__r.Project__c FROM Events__c WHERE Status__c = 'Scheduled' LIMIT 2];
        Test.startTest();
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student'];
        
        List<AcctSeed__Project__c> proList = [SELECT Id, Name FROM AcctSeed__Project__c LIMIT 2];
        List<Schedule__c> schList = [SELECT Id, Name, Project__c FROM Schedule__c WHERE Id = :evlist[0].Schedule__c];
        
        if(proList.size() > 0 && schList.size() > 0 && conAssList.size() > 0) {
            
            for(Contact_Assignments__c ca : conAssList) {
                ca.Project__c = proList[1].Id;
            }
            conAssList[0].Project__c = proList[0].Id;
            update conAssList;
            
            for(Schedule__c sch : schList) {
                sch.Project__c = proList[0].Id;
            }
            update schList;
        }
        
        Room__c room = [SELECT Id FROM Room__c LIMIT 1];
        List<Schedule__c> schList1 = [SELECT Id, Name, Project__c FROM Schedule__c WHERE Id != :evlist[0].Schedule__c];
        
        if(schList1.size() > 0) {
            
            schList1[0].Project__c = proList[0].Id;
            update schList1;
            
            List<Events__c> newEvt1 = new List<Events__c>{
                new Events__c(Name=evList[0].Name,SequenceNo__c=1,Schedule__c=schList1[0].Id,Instructor__c=evList[0].Instructor__c,Date__c=evList[0].Date__c,Room__c=room.Id ,Status__c = 'Scheduled')
            };
            insert newEvt1;
            
            String jsonEvent2 = JSON.serializePretty(newEvt1);
            EventManagementController.isConflictsInNewEvents(jsonEvent2,evlist[0].Schedule__c,evlist[0].Schedule__r.Project__c,'PROJECT');
        
        }
    }
    
    static testMethod void myTest5(){
        List<Events__c> evlist = [SELECT Id, Name, Schedule__c, Instructor__c,Schedule__r.Opportunity__c, Date__c FROM Events__c WHERE Schedule__r.Project__c = Null LIMIT 2];
        Test.StartTest();
        Contact_Assignments__c conAssign = [SELECT Id, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' LIMIT 1];
        try{
            EventManagementController.rescheduleEventCommunity(evlist[0].Schedule__c, conAssign.Candidate_Name__c, String.ValueOf(System.today()),String.ValueOf(System.today().addDays(1)), '', 'COMMUNITY');
        }catch(Exception e){
            System.assertEquals(true,e.getMessage().Contains('Case Created To Reschedule this Event'));
        }
        Test.StopTest();
    }
    
    static testMethod void myTest(){
       
        Test.startTest();
        
        User userList = [SELECT Id, contactId FROM User WHERE Instructor_Access__c = true AND IsActive = true LIMIT 1];
        List<AcctSeed__Project__c> prolist=[SELECT Id ,Name FROM AcctSeed__Project__c LIMIT 1];
        List<AcctSeed__Project_Task__c> projectlist =  [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__c, Project_Task_Type__c, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 2];
        
        List<Contact> con = [SELECT Id, Name FROM Contact WHERE Name LIKE '%Testing%' LIMIT 1];
        List<Opportunity> opp = [SELECT Id,Name FROM Opportunity LIMIT 1];
        System.runAs(userList){
            EventManagementController.getRecordType(opp[0].Id, 'OPPORTUNITY');
            EventManagementController.getRecordType(prolist[0].Id, 'PROJECT');
            EventManagementController.getAllStudnetEvents();
            EventManagementController.getUserdetails(userList.Id);
            system.debug('prolist'+prolist[0].Id);
            
            List<Planned_Days_Off__c> plannedDaysOff = [SELECT Description__c, Name, Id, Date__c FROM Planned_Days_Off__c LIMIT 1];
            
            EventManagementController.getUserRec();
            EventManagementController.getAllOffs(prolist[0].Id,true);
            EventManagementController.getAllOffs(opp[0].Id,false);
            EventManagementController.getOpportunityDetails();
            EventManagementController.getPlanneddaysOffdetails(con[0].Id);
            EventManagementController.getContactassignmentByParent(prolist[0].Id,'Project');
            EventManagementController.getContactassignmentByParent(opp[0].Id,'Opportunity');
            EventManagementController.getEventsByparentType(opp[0].Id,'opportunity',2,5);
            if(prolist.size() > 0)
                EventManagementController.getProjectIdSet(prolist[0].Id);
        }
        List<User> userList1 = [SELECT Id, Email FROM User WHERE Instructor_Access__c = true LIMIT 1];
        String userupdate = JSON.serialize(userList1);
        system.debug('userupdate'+userupdate);
        EventManagementController.getUserupdate(userupdate);
        Test.StopTest();
    } 
    static testMethod void myTest6(){
        
        List<Events__c> eveList = [SELECT Id, Schedule__c, Instructor__c,Project__c ,Schedule__r.Opportunity__c FROM Events__c Limit 2];
        
        List<RecordType> conrt = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType = 'Contact' And DeveloperName = 'Candidate'];
        Test.startTest();        
        
        Account a = new Account(Name='Test Account Name');
        insert a;
        
        List<Contact> con1 = new List<Contact>{
            new Contact(LastName = 'Testing Contact',RecordTypeId = conrt[0].Id, AccountId = a.Id)
            //new Contact(LastName = 'Testing Contact 1',RecordTypeId = conrt[0].Id, AccountId = a.Id)
        };
        
        insert con1;
        List<Profile> Profile = [SELECT Id FROM Profile WHERE Name = 'Customer Community User Clone'];
        
        String un = String.valueOf(System.now().millisecond())+'@dlsTestOrg.dlsdc';
        String en = String.valueOf(System.now().millisecond())+'@dlsTestOrg.com';
        
        User usr = new User(Alias = 'standt', Email='test@gmail.com',EmailEncodingKey='UTF-8',LastName = con1[0].LastName,
        LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = Profile[0].Id,Instructor_Access__c = false,
        TimeZoneSidKey='America/Los_Angeles', UserName=un,ContactId = con1[0].Id);
        
        insert usr;   
        System.runAs(usr){               
            try{
                EventManagementController.cancellEventByUserCommunity(eveList[1].Id,eveList[1].Instructor__c);
                
            }catch(Exception e){
                System.assertEquals(true,e.getMessage().Contains('Case Created for cancelling this Event'));
            }
        }
        
        EventManagementController.getHomepagedetails('STAFF');
        EventManagementController.getHomepagedetails('INSTRUCTOR');
        EventManagementController.getContactRec();
        
        Test.StopTest();   
    }
    
    // Add the method to increases the code coverage from 73%
    // get Conflicts on Schedules on project
    static testMethod void myTest7() {
        String conSchedule = '[{"Id":"a5WW00000005jLpMAI","Start_Date__c":"2017-11-01","End_Date__c":"2017-12-13","Start_Time__c":"09:00 AM","End_Time__c":"11:00 AM","Room__c":"a0860000008j4sFAAQ","Monday__c":true,"Tuesday__c":true,"Wednesday__c":true,"Thursday__c":false,"Friday__c":false,"Saturday__c":false,"Sunday__c":false}]';
        List<Contact_Assignments__c> conAssCandidateId = [SELECT Id, Candidate_Name__c, Project__c,Project__r.RecordType.DeveloperName, Opportunity_Name__c,Opportunity_Name__r.RecordType.DeveloperName From Contact_Assignments__c];
        
        List<Id> idsList = new List<Id>();
        String uiJson = JSON.serializePretty(idsList);
        
        EventManagementController.getConflictsonSchedules(conSchedule,conAssCandidateId[0].Candidate_Name__c,'PROJECT',conAssCandidateId[0].Project__c,conAssCandidateId[0].Project__r.RecordType.DeveloperName,uiJson); 
        EventManagementController.checkForRoomEditCP();
    }  
    
    // get Conflicts on Schedules on opportunity
    static testMethod void myTest8() {
        String conSchedule = '[{"Id":"a5WW00000005jLpMAI","Start_Date__c":"2017-11-01","End_Date__c":"2017-12-13","Start_Time__c":"09:00 AM","End_Time__c":"11:00 AM","Room__c":"a0860000008j4sFAAQ","Monday__c":true,"Tuesday__c":true,"Wednesday__c":true,"Thursday__c":false,"Friday__c":false,"Saturday__c":false,"Sunday__c":false}]';
        List<Contact_Assignments__c> conAssCandidateId = [SELECT Id, Candidate_Name__c, Project__c,Project__r.RecordType.DeveloperName, Opportunity_Name__c,Opportunity_Name__r.RecordType.DeveloperName From Contact_Assignments__c];
        
        List<Id> idsList = new List<Id>();
        String uiJson = JSON.serializePretty(idsList);
        
        EventManagementController.getConflictsonSchedules(conSchedule,conAssCandidateId[0].Candidate_Name__c,'Opportunity',conAssCandidateId[0].Opportunity_Name__c,conAssCandidateId[0].Opportunity_Name__r.RecordType.DeveloperName,uiJson);
    } 
        
    // For getting Room Conflict Details
    private static testMethod void testMethod8() {
        
        List<Events__c> eveList = [SELECT Id, Name, Schedule__c, Date__c FROM Events__c WHERE Schedule__c != null LIMIT 2];
        List<AcctSeed__Project__c> proList = [SELECT Id, Name FROM AcctSeed__Project__c WHERE AcctSeed__Status__c = 'Active'];
        List<Room__c> roomList = [SELECT Id, Name FROM Room__c WHERE Name != 'Zoom'];
        
        if(eveList.size() > 0 && proList.size() > 0 && roomList != null) {
            
            Set<Id> schIds = new Set<Id>();
            
            for(Events__c eve : eveList) {
                schIds.add(eve.Schedule__c);
            }
            
            List<Schedule__c> schList = [SELECT Id, Name, Start_Date__c,Start_Time__c,End_Time__c,Sunday__c,Monday__c,Tuesday__c,
                                                Wednesday__c,Thursday__c,Friday__c,Saturday__c 
                                        FROM Schedule__c WHERE Id NOT IN :schIds];
                        
            if(schList.size() > 0) {
                
                schList[0].Sunday__c = true;
                schList[0].Monday__c = true;
                schList[0].Tuesday__c = true;
                schList[0].Wednesday__c = true;
                schList[0].Thursday__c = true;
                schList[0].Friday__c = true;
                schList[0].Saturday__c = true;
                schList[0].Start_Time__c = '09:00 AM';
                schList[0].End_Time__c = '03:00 PM';
                update schList[0];
                
                eveList[0].Date__c = schList[0].Start_Date__c;
                eveList[0].Room__c = roomList[0].Id;
                eveList[0].Status__c = 'Scheduled';
                eveList[1].Date__c = schList[0].Start_Date__c;
                eveList[1].Room__c = roomList[0].Id;
                eveList[1].Status__c = 'Scheduled';
                eveList[1].Start_Time__c = '10:00 AM';
                eveList[1].End_Time__c = '02:00 PM';
                update eveList;
                
                EventManagementController.getRoomConflictDetails(schList[0].Id);
            }
            
            
        }
    }
    
    private static testMethod void testMethod9() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c, Project__c, Opportunity_Name__c FROM Contact_Assignments__c WHERE Project__c != null AND 
                                                   RecordType.DeveloperName = 'Instructor' AND Candidate_Name__c != null AND Opportunity_Name__c != null];
        
        List<Schedule__c> schList = [SELECT Id, Name, Start_Date__c FROM Schedule__c LIMIT 3];
        List<RecordType> rType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'DLS_Employee'];
        
        if(schList.size() > 0 && conAssList.size() > 0 && rType.size() > 0) {
        
            List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :conAssList[0].Candidate_Name__c];
            Set<Id> conIds = new Set<Id>();
            
            for(Contact_Assignments__c ca : conAssList) {
                conIds.add(ca.Candidate_Name__c);
            }
            Test.startTest();
            
            List<Contact> conList1 = [SELECT Id, Name FROM Contact WHERE Id != :conIds];
            
            if(conList.size() > 0) {
                conList[0].RecordTypeId = rType[0].Id;
            }
            update conList;
            
            List<String> dtList = new List<String>();            
            
            if(conList1.size() > 0) {
                for(Schedule__c sch :schList) {
                    dtList.add(String.valueOf(sch.Start_Date__c));
                    sch.Instructor__c = conList1[0].Id;
                }
                schList[0].Opportunity__c = conAssList[0].Opportunity_Name__c;
                schList[1].Project__c = conAssList[0].Project__c;
                update schList;
            }
            
            EventManagementController.createScheduleForChange(JSON.serialize(schList[0]), 'Replace Instructor', '', dtList);
           
            //EventManagementController.createScheduleForChange(JSON.serialize(schList[1]), 'Substitute', '', dtList);
            Test.stopTest();
        }
    }

    private static testMethod void testMethod10() {
        
        List<Contact_Assignments__c> conAssList = [SELECT Id, Name, Candidate_Name__c, Project__c, Opportunity_Name__c FROM Contact_Assignments__c WHERE Project__c != null AND 
                                                   RecordType.DeveloperName = 'Instructor' AND Candidate_Name__c != null AND Opportunity_Name__c != null];
        
        List<Schedule__c> schList = [SELECT Id, Name, Start_Date__c,End_Date__c FROM Schedule__c LIMIT 2];
        List<RecordType> rType = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'DLS_Employee'];
        
        if(schList.size() > 0 && conAssList.size() > 0 && rType.size() > 0) {
        
            List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :conAssList[0].Candidate_Name__c];
            Set<Id> conIds = new Set<Id>();
            
            for(Contact_Assignments__c ca : conAssList) {
                conIds.add(ca.Candidate_Name__c);
            }
            
            List<Contact> conList1 = [SELECT Id, Name FROM Contact WHERE Id != :conIds];
            
            Test.startTest();
            
            if(conList.size() > 0) {
                conList[0].RecordTypeId = rType[0].Id;
            }
            update conList;
            
            List<String> dtList = new List<String>();            
            
            if(conList1.size() > 0) {
               for(Schedule__c sch :schList) {
                    dtList.add(String.valueOf(sch.Start_Date__c));
                    sch.Instructor__c = conAssList[0].Candidate_Name__c;
                    sch.Project__c = conAssList[0].Project__c;
                    sch.Schedule_Type__c = 'Substitute';
                }
                update schList;
            }
            EventManagementController.createScheduleForChange(JSON.serialize(schList[0]), 'Substitute', '',dtList);
            Test.stopTest();
        }
    }
    
    // For getting Event for Schedule
    private static testMethod void testMethod11() {
        List<Events__c> evList = [SELECT Id, Schedule__c, Date__c FROM Events__c WHERE Schedule__c != null AND Date__c != null];
        
        if(evList.size() > 0) {
            EventManagementController.getEventsForSch(evList[0].Schedule__c, String.valueOf(evList[0].Date__c.addDays(-5)), String.valueOf(evList[0].Date__c.addDays(5)), new List<String>{'Scheduled'});
        }
    }
    
    // For getting PickList Values and Lookup Records
    private static testMethod void testMethod12() {
        EventManagementController.getPicklistValues('Events__c', 'Status__c');
        EventManagementController.getLookupRecords('Events__c', 'Test', '');
    }
    
    // For creating Events for the newly selected events for an existing Substitute Events
    private static testMethod void testMethod13() {
        
        List<Schedule__c> schList = [SELECT Id, Name, Start_Date__c FROM Schedule__c LIMIT 2];
        List<String> dtList = new List<String> {String.valueOf(System.today()), String.valueOf(System.today().addDays(5))};
                
        if(schList.size() > 0) {
            EventManagementController.createEventsForSubstituteSchEdit(JSON.Serialize(schList[0]), dtList);
        }
    }
}