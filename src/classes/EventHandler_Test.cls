@isTest
public class EventHandler_Test {
    
    @testsetup static void setup() {
    
        Test.startTest();
        
            List<Events__c> eventList =  TestClassUtil.createTestEvent();
            List<Room__c> roomList = TestClassUtil.createTestRoom();   
                        
        Test.stopTest();   
        List<Schedule__c> scheduleRecordList = TestClassUtil.createTestSchedule(); 
    }
    
    public static Set<Id> scheduleIdSet = new Set<Id>();
    
    public static Set<Id> proIds = new Set<Id>();
    
    public static Map<String, Map<String, Id>> RecrdTypeMap = TestClassUtil.queryRecordTypes();
    
    public static testMethod void deleteExcessEventsRecords_Test() {
        
        Set<Id> scheduleId = new Set<Id>();
        List<Schedule__c> udpateScheduleList = new List<Schedule__c>();
              
        List<Schedule__c> scheduleList = [SELECT Id, Schedule_Type__c, Status__c, Prior_Schedule__c, Name FROM Schedule__c WHERE Name IN('15-00687-SH1', '15-00687-SH1', 'scheduleWithoutEvent')];
        
         scheduleList[0].End_Date__c = System.Today() + 7;     
         scheduleList[0].Status__c = 'Active';
         scheduleList[1].End_Date__c = System.Today() + 8;
         scheduleList[1].Status__c = 'Active';     
         
        List<Events__c> eventList = [SELECT Date__c , Schedule__c FROM Events__c WHERE Schedule__c IN :scheduleList];        
         
         eventList[0].Date__c = system.today()+7;
         eventList[1].Date__c = system.today()+8; 
                  
         update eventList;     
         
        update scheduleList;             
         
         List<Events__c> obtainedList = [SELECT Date__c , Schedule__c FROM Events__c WHERE Schedule__c =:scheduleList[0].Id OR Schedule__c =: scheduleList[1].Id];  
         //System.assertEquals(2, obtainedList.size());     
     }
     
     public static testMethod void handleEventRecords_Test() {
         
        List<Contact> contList = [SELECT Id, Name, Email FROM Contact WHERE Name IN ('Test Contact1', 'Test Contact2', 'Test Contact3')];
        
        List<Room__c> roomList = [SELECT Id, Name FROM Room__c WHERE Name IN('Room', 'Room 1')];  
        
        EventHandler eveInst = new EventHandler();
        
        Id studRTId = RecrdTypeMap.get('Contact_Assignments__c').get('Student');
        Id staffRTId = RecrdTypeMap.get('Contact_Assignments__c').get('Staff');
        Id studContRTId = RecrdTypeMap.get('Contact').get('Student');
        Id projPlanned = RecrdTypeMap.get('Planned_Days_Off__c').get('Project_Planned_Days_Off');
        
        contList[1].RecordTypeId = studContRTId;
        update contList;
        
        List<Schedule__c> scheduleList = [SELECT Id, Schedule_Type__c, Project__c, Status__c, Prior_Schedule__c, Name FROM Schedule__c WHERE Name IN('15-00687-SH1', 'scheduleWithoutEvent') LIMIT 8];
        System.debug('*scheduleList*'+scheduleList.size()+'(scheduleList)'+scheduleList );
         
         List<Schedule__c > priorSchedulesList = new List<Schedule__c > {
             
              new Schedule__c(Start_Date__c= System.Today()+3, End_Date__c = System.today()+10, Status__c = 'Active', Schedule_Type__c = 'Substitute'),
              new Schedule__c(Start_Date__c= System.Today()+3, End_Date__c = System.today()+10)
         };
         insert priorSchedulesList;
         
         priorSchedulesList[1].Status__c = 'Active';
         update priorSchedulesList;         
         
         //not for scheuleIdsTocreateEventsmethod because 'Substitute'
         
         scheduleList[0].Status__c = 'Active';
         scheduleList[0].Schedule_Type__c = 'Substitute';
         scheduleList[0].Prior_Schedule__c = priorSchedulesList[0].Id;        
         scheduleList[0].Room__c = roomList[1].Id; 
         scheduleList[0].Start_Date__c= System.Today()+3;
         scheduleList[0].End_Date__c = System.today()+10;    
         
         //for scheuleIdsTocreateEventsmethod (only 7 records)
         
         scheduleList[1].Status__c = 'Active';
         scheduleList[1].Prior_Schedule__c = priorSchedulesList[1].Id;    
         scheduleList[1].Instructor__c = contList[0].Id;
         scheduleList[1].Room__c = roomList[1].Id;
         scheduleList[1].Start_Date__c= System.Today()+3;
         scheduleList[1].End_Date__c = System.today()+10;
         scheduleList[1].Start_Time__c ='03:30 AM';
         scheduleList[1].End_Time__c = '05:30 PM';
         scheduleList[1].Monday__c = True;
         
         scheduleList[2].Status__c = 'Active';
         scheduleList[2].Prior_Schedule__c = priorSchedulesList[1].Id;
         scheduleList[2].Schedule_Type__c = 'Replace Instructor';
         scheduleList[2].Start_Date__c= System.Today()+3;
         scheduleList[2].End_Date__c = System.today()+10;
         scheduleList[2].Start_Time__c ='03:30 AM';
         scheduleList[2].End_Time__c = '05:30 PM';
         scheduleList[2].Tuesday__c = True;    
         
         scheduleList[3].Status__c = 'Active';
         scheduleList[3].Prior_Schedule__c = priorSchedulesList[1].Id;
         scheduleList[3].Schedule_Type__c = 'Replace Instructor';
         scheduleList[3].Start_Date__c= System.Today()+3;
         scheduleList[3].End_Date__c = System.today()+10;
         scheduleList[3].Start_Time__c ='03:30 AM';
         scheduleList[3].End_Time__c = '05:30 PM';
         scheduleList[3].Wednesday__c = True; 
         
         scheduleList[4].Status__c = 'Active';
         scheduleList[4].Prior_Schedule__c = priorSchedulesList[1].Id;
         scheduleList[4].Schedule_Type__c = 'Replace Instructor';
         scheduleList[4].Start_Date__c= System.Today()+3;
         scheduleList[4].End_Date__c = System.today()+10;
         scheduleList[4].Thursday__c= True; 
         
         scheduleList[5].Status__c = 'Active';
         scheduleList[5].Prior_Schedule__c = priorSchedulesList[1].Id;
         scheduleList[5].Schedule_Type__c = 'Replace Instructor';
         scheduleList[5].Start_Date__c= System.Today()+3;
         scheduleList[5].End_Date__c = System.today()+10;
         scheduleList[5].Friday__c= True; 
         
         scheduleList[6].Status__c = 'Active';
         scheduleList[6].Prior_Schedule__c = priorSchedulesList[1].Id;
         scheduleList[6].Schedule_Type__c = 'Replace Instructor';
         scheduleList[6].Start_Date__c= System.Today()+3;
         scheduleList[6].End_Date__c = System.today()+10;
          scheduleList[6].Start_Time__c ='03:30 AM';
         scheduleList[6].End_Time__c = '05:30 PM';
         scheduleList[6].Saturday__c= True; 
         
         scheduleList[7].Status__c = 'Active';
         scheduleList[7].Prior_Schedule__c = priorSchedulesList[1].Id;
         scheduleList[7].Schedule_Type__c = 'Replace Instructor';
         scheduleList[7].Start_Date__c= System.Today()+3;
         scheduleList[7].End_Date__c = System.today()+10;
          scheduleList[7].Start_Time__c ='03:30 AM';
         scheduleList[7].End_Time__c = '05:30 PM';
         scheduleList[7].Sunday__c= True;      
                  
         update scheduleList;   
         
         //updateOldScheduleEventsStatus
         
         List<Events__c> eventOldList = new List<Events__c>{
         
            new Events__c(Date__c = System.Today()+4, Schedule__c = scheduleList[0].Id, Instructor__c = contList[0].Id, SequenceNo__c = 1,  Status__c = 'Draft')
            
         };
         insert eventOldList ; 
        
        //related event records to avoid duplicate
                
         List<Events__c> eventdupList = new List<Events__c>{
         
            new Events__c(Date__c = System.Today()+4, Status__c = 'Scheduled', Schedule__c = scheduleList[0].Id, Instructor__c = contList[0].Id, SequenceNo__c = 1)
            
         };
         insert eventdupList; 
        
         List<Planned_Days_Off__c> plannedList = new List<Planned_Days_Off__c> {
             
             new Planned_Days_Off__c(Contact__c = contList[0].Id, Status__c = 'Approved', RecordTypeId = projPlanned , Project__c = scheduleList[0].Project__c, Date__c = system.today()+3)
            
         };
         insert plannedList;  
         
         for(Schedule__c scInst : scheduleList) {
             proIds.add(scInst.Project__c);
             scheduleIdSet.add(scInst.Id);
         }  
         // Get Events based on the Student related Project
         
         List<AcctSeed__Project__c> ActtprojList = [SELECT Id, Name FROM AcctSeed__Project__c WHERE Id NOT IN :proIds LIMIT 3];
         
         Schedule__c schIns = new Schedule__c (Room__c = roomList [1].Id, Start_Date__c= System.Today()+3, End_Date__c = System.today()+10);
         insert schIns;         
         schIns.Project__c = ActtprojList[1].Id;
         
         update schIns;
        
         List<Events__c> eventListObtianed = new List<Events__c>{
             new Events__c(Date__c = System.Today()+4, Status__c = 'Scheduled', Schedule__c = schIns.Id, Instructor__c = contList[0].Id, SequenceNo__c = 1,
             Start_Time__c = '05:30 AM', End_Time__c = '07:40 AM')
         };
         insert eventListObtianed;     
        
        List<Schedule__c> instScheduleList = [SELECT Id, Schedule_Type__c, Project__c, Status__c, Prior_Schedule__c, Name FROM Schedule__c WHERE Schedule_Type__c = 'Replace Instructor'];
        
        Test.startTest();
        
        List<Events__c> requiredEventList = new List<Events__c> {
            new Events__c (Date__c = System.Today()+4, Schedule__c =instScheduleList[0].Prior_Schedule__c, SequenceNo__c = 1)};
        insert requiredEventList;   
        
        List<Schedule__c> instSubList = [SELECT Id, Schedule_Type__c, Project__c, Status__c, Prior_Schedule__c, Name FROM Schedule__c WHERE Schedule_Type__c = 'Substitute' AND Prior_Schedule__c != null];
        
        List<Events__c> requiredSubList = new List<Events__c> {
            new Events__c (Date__c = System.Today()+4, Schedule__c =instSubList[0].Prior_Schedule__c, SequenceNo__c = 1)};
        insert requiredSubList ;        
        
                
         List<Contact_Assignments__c> conAssList =  new List<Contact_Assignments__c> {
     
            new Contact_Assignments__c (Project__c=scheduleList[0].Project__c, Candidate_Name__c=contList[0].Id, RecordTypeId = staffRTId , Start_Date__c=System.today(),End_Date__c=System.today()+30,Status__c = 'Active'),
            new Contact_Assignments__c (Project__c=scheduleList[0].Project__c, Candidate_Name__c=contList[1].Id, RecordTypeId = studRTId , Start_Date__c=System.today(),End_Date__c=System.today()+30, Status__c = 'Active'),
            new Contact_Assignments__c (Project__c=ActtprojList [1].Id, Candidate_Name__c = contList[1].Id, Start_Date__c=System.today()+3, End_Date__c=System.today()+10, Status__c = 'Active', RecordTypeId = studRTId)
     
         };
         insert conAssList;  
         
         //for getconflict
         Events__c conflictEvent = new Events__c ( Schedule__c = scheduleList[0].Id, SequenceNo__c = 1);
        insert conflictEvent;
        
        eveInst.generateConflict(conflictEvent);
                
         List<Event_Conflict__c > eventConflictList = new List<Event_Conflict__c > {
             
             new Event_Conflict__c (External_Id__c = '1234599', Event__c = eventdupList[0].Id, Date__c = System.Today()+6, Conflict_Event__c = eventdupList[0].Id)
         };
        insert eventConflictList;      
         
        EventHandler.handleEventRecords(scheduleIdSet);       
        
         List<Events__c> eventResultList = [SELECT Date__c , Schedule__r.Project__c FROM Events__c WHERE Schedule__c IN :scheduleList];
         //system.assertEquals(15, eventResultList.size());
         
         Test.stopTest();
     }    
     
     public static testMethod void RoomConflict_Test() {
     
        List<Contact> contList = [SELECT Id, Name, Email FROM Contact WHERE Name IN ('Test Contact1', 'Test Contact2', 'Test Contact3')];
        
        List<Room__c> roomList = [SELECT Id, Name FROM Room__c WHERE Name IN('Room', 'Room 1')];
     
        Schedule__c priorSchedule =  new Schedule__c(Start_Date__c= System.Today()+3, End_Date__c = System.today()+10);
        insert priorSchedule;
        priorSchedule.Status__c = 'Active';
        update priorSchedule;
        
        List<AcctSeed__Project__c> ActtprojList = [SELECT Id, Name FROM AcctSeed__Project__c WHERE Id NOT IN :proIds LIMIT 3];
     
     List<Schedule__c> scheduledayList = new List<Schedule__c> {
                  
           new Schedule__c(Status__c = 'Active', Schedule_Type__c = 'Substitute', Prior_Schedule__c = priorSchedule.Id, Wednesday__c = true, Start_Date__c= System.Today()+3,End_Date__c = System.today()+10),
           new Schedule__c(Status__c = 'Active', Schedule_Type__c = 'Replace Instructor', Prior_Schedule__c = priorSchedule.Id, Thursday__c= true, Start_Date__c= System.Today()+3, End_Date__c = System.today()+10)
          
       };

       insert scheduledayList;
       
       scheduledayList[0].Status__c = 'Active';
       scheduledayList[1].Status__c = 'Active';
       scheduledayList[0].Start_Time__c ='03:30 AM';
       scheduledayList[0].End_Time__c = '05:30 PM';
       scheduledayList[0].Room__c = roomList[0].Id;
       scheduledayList[1].Room__c = roomList[0].Id;
       scheduledayList[1].Start_Time__c ='03:30 AM';
       scheduledayList[1].End_Time__c = '05:30 PM';
       
       update scheduledayList;
       
          
         // Get Room & Instrcutor related events to check conflicts
         
         Schedule__c schIns = new Schedule__c (Room__c = roomList [0].Id, Start_Date__c= System.Today()+6, End_Date__c = System.today()+10);
         insert schIns;         
         schIns.Project__c = ActtprojList[1].Id;
         
         update schIns;
        
         List<Events__c> eventListObtianed = new List<Events__c>{
             new Events__c(Date__c = System.Today()+6, Status__c = 'Scheduled', Schedule__c = schIns.Id, Instructor__c = contList[0].Id, SequenceNo__c = 1,
             Start_Time__c = '05:30 AM', End_Time__c = '07:40 AM', Room__c = roomList [0].Id)
         };
         insert eventListObtianed; 
         
         List<Event_Conflict__c > eventConflictList = new List<Event_Conflict__c > {
             
             new Event_Conflict__c (External_Id__c = '1234599', Event__c = eventListObtianed[0].Id, Date__c = System.Today()+6, Conflict_Event__c = eventListObtianed[0].Id)
         };
        insert eventConflictList;
        
        for(Schedule__c scInst : scheduledayList) {
             proIds.add(scInst.Project__c);
             scheduleIdSet.add(scInst.Id);
         } 
      
        EventHandler.handleEventRecords(scheduleIdSet);    
        
        List<Events__c> eventResultList = [SELECT Date__c , Schedule__r.Project__c FROM Events__c WHERE Schedule__c IN :scheduledayList];
        //system.assertEquals(1, eventResultList.size());
     }
     
    public static testMethod void projectEvent_Test() {
     
        List<Contact> contList = [SELECT Id, Name, Email FROM Contact WHERE Name IN ('Test Contact1', 'Test Contact2', 'Test Contact3')];
        
        List<Room__c> roomList = [SELECT Id, Name FROM Room__c WHERE Name IN('Room', 'Room 1')];  
       
        List<AcctSeed__Project_Task__c > projTask = [SELECT Id, Name, AcctSeed__Client_Contact__c, AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__c, Project_Task_Type__c, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c LIMIT 3];

        Schedule__c priorSchedule =  new Schedule__c(Start_Date__c= System.Today()+3, End_Date__c = System.today()+10);
        insert priorSchedule;
        priorSchedule.Status__c = 'Active';
        
        update priorSchedule;
        
        List<AcctSeed__Project__c> ActtprojList = [SELECT Id, Name FROM AcctSeed__Project__c WHERE Id NOT IN :proIds LIMIT 3];
     
     List<Schedule__c> scheduledayList = new List<Schedule__c> {
                  
           new Schedule__c(Status__c = 'Active', Schedule_Type__c = 'Substitute', Prior_Schedule__c = priorSchedule.Id, Wednesday__c = true, Start_Date__c= System.Today()+3,End_Date__c = System.today()+10),
           new Schedule__c(Status__c = 'Active', Schedule_Type__c = 'Replace Instructor', Prior_Schedule__c = priorSchedule.Id, Thursday__c= true, Start_Date__c= System.Today()+3, End_Date__c = System.today()+10)
          
       };

       insert scheduledayList;
       
       scheduledayList[0].Status__c = 'Active';
       scheduledayList[1].Status__c = 'Active';
       scheduledayList[0].Start_Time__c ='03:30 AM';
       scheduledayList[0].End_Time__c = '05:30 PM';
       scheduledayList[0].Project__c = projTask[0].AcctSeed__Project__c;
       scheduledayList[0].Room__c = roomList[0].Id;
       scheduledayList[1].Room__c = roomList[0].Id;
       scheduledayList[1].Start_Time__c ='03:30 AM';
       scheduledayList[1].End_Time__c = '05:30 PM';
       scheduledayList[1].Project__c = projTask[0].AcctSeed__Project__c;
       
       update scheduledayList;
       
            
        for(Schedule__c scInst : scheduledayList) {
            proIds.add(scInst.Project__c);
            scheduleIdSet.add(scInst.Id);       } 
            
            
           List<AcctSeed__Project__c> ActtSeedprojList = [SELECT Id, Name FROM AcctSeed__Project__c WHERE Id IN :proIds];
         // Get Room & Instrcutor related events to check conflicts
         
        Schedule__c scheduleProjEvent =  new Schedule__c(Start_Date__c= System.Today()+3, End_Date__c = System.today()+10, Project__c = ActtSeedprojList [0].Id);
        insert scheduleProjEvent ;    
         
          List<Events__c> eventListObtianed = new List<Events__c>{
             new Events__c(Date__c = System.Today()+7, Status__c = 'Scheduled', Schedule__c = scheduleProjEvent .Id, Instructor__c = contList[0].Id, SequenceNo__c = 1,
             Start_Time__c = '05:30 AM', End_Time__c = '07:40 AM', Room__c = roomList [0].Id)
         };
         insert eventListObtianed; 
       
        EventHandler.handleEventRecords(scheduleIdSet);    
        
        List<Events__c> eventResultList = [SELECT Date__c , Schedule__r.Project__c FROM Events__c WHERE Schedule__c IN :scheduledayList];
        //system.assertEquals(1, eventResultList.size());
     }
    
     public static testMethod void InstructorConflict_Test() {
     
         List<Contact> contList = [SELECT Id, Name, Email FROM Contact WHERE Name IN ('Test Contact1', 'Test Contact2', 'Test Contact3')];
        
        List<Room__c> roomList = [SELECT Id, Name FROM Room__c WHERE Name IN('Room', 'Room 1')];
     
        Schedule__c priorSchedule =  new Schedule__c(Start_Date__c= System.Today()+6, End_Date__c = System.today()+10);
        insert priorSchedule;
        priorSchedule.Status__c = 'Active';
        update priorSchedule;
        
        List<AcctSeed__Project__c> ActtprojList = [SELECT Id, Name FROM AcctSeed__Project__c WHERE Id NOT IN :proIds LIMIT 3];
     
     List<Schedule__c> scheduledayList = new List<Schedule__c> {
                  
           new Schedule__c(Status__c = 'Active', Schedule_Type__c = 'Substitute', Prior_Schedule__c = priorSchedule.Id, Wednesday__c = true, Start_Date__c= System.Today()+3,End_Date__c = System.today()+10),
           new Schedule__c(Status__c = 'Active', Schedule_Type__c = 'Replace Instructor', Prior_Schedule__c = priorSchedule.Id, Thursday__c= true, Start_Date__c= System.Today()+3, End_Date__c = System.today()+10)
          
       };

       insert scheduledayList;
       
       scheduledayList[0].Status__c = 'Active';       
       scheduledayList[0].Start_Time__c ='03:30 AM';
       scheduledayList[0].End_Time__c = '05:30 PM';
       scheduledayList[0].Room__c = roomList[0].Id;
       scheduledayList[0].Instructor__c = contList [0].Id;
       
       scheduledayList[1].Status__c = 'Active';
       scheduledayList[1].Room__c = roomList[0].Id;
       scheduledayList[1].Start_Time__c ='03:30 AM';
       scheduledayList[1].End_Time__c = '05:30 PM';
       scheduledayList[1].Instructor__c = contList [0].Id;
       
       update scheduledayList;
              
         // Get Room & Instrcutor related events to check conflicts
         
         Schedule__c schIns = new Schedule__c (Room__c = roomList [0].Id, Start_Date__c= System.Today()+6, End_Date__c = System.today()+10);
         insert schIns;         
         schIns.Project__c = ActtprojList[1].Id;
         
         update schIns;
        
         List<Events__c> eventListObtianed = new List<Events__c>{
             new Events__c(Date__c = System.Today()+6, Status__c = 'Scheduled', Schedule__c = schIns.Id, Instructor__c = contList[0].Id, SequenceNo__c = 1,
             Start_Time__c = '05:30 AM', End_Time__c = '07:40 AM')
         };
         insert eventListObtianed; 
        
        for(Schedule__c scInst : scheduledayList) {
             proIds.add(scInst.Project__c);
             scheduleIdSet.add(scInst.Id);
         } 
      
        EventHandler.handleEventRecords(scheduleIdSet);    
        
        List<Events__c> eventResultList = [SELECT Date__c , Schedule__r.Project__c FROM Events__c WHERE Schedule__c IN :scheduledayList];
        //system.assertEquals(1, eventResultList.size());
         
     }
  
     public static testMethod void createSubstitueEvents_Test() {
         
         Set<Date> eventDate = new Set<Date>();
         EventHandler eveInst = new EventHandler();
         Id studRTId = RecrdTypeMap.get('Contact_Assignments__c').get('Student');
         Id staffRTId = RecrdTypeMap.get('Contact_Assignments__c').get('Staff');
         Id projPlanned = RecrdTypeMap.get('Planned_Days_Off__c').get('Project_Planned_Days_Off');
         List<Schedule__c> scheduleList = [SELECT Id, Schedule_Type__c, Status__c, Project__c, Prior_Schedule__c, Name FROM Schedule__c WHERE Name IN('15-00687-SH1', '15-00687-SH1', 'scheduleWithoutEvent')];

         
        List<Contact> contList = [SELECT Id, Name, Email FROM Contact WHERE Name IN ('Test Contact1', 'Test Contact2', 'Test Contact3')];
        List<Room__c> roomList = [SELECT Id, Name FROM Room__c WHERE Name IN('Room', 'Room 1')];  
        
        List<Schedule__c> priorSchedules =  new List<Schedule__c> {
        
            new Schedule__c(Start_Date__c= System.Today(), End_Date__c = System.today()+10)           
        };
        
        insert priorSchedules;     
 
        scheduleList[0].Instructor__c = contList[0].Id;    
        scheduleList[0].Room__c = roomList[0].Id;    
        scheduleList[0].Prior_Schedule__c = priorSchedules[0].id;
        
        update scheduleList;
        
        List<Contact_Assignments__c> conAssList =  new List<Contact_Assignments__c> {
     
            new Contact_Assignments__c (Project__c=scheduleList[0].Project__c, Candidate_Name__c=contList[1].Id, RecordTypeId = staffRTId , Start_Date__c=System.today(),End_Date__c=System.today()+30, Status__c = 'Active'),
            new Contact_Assignments__c (Project__c=scheduleList[0].Project__c, Candidate_Name__c=contList[1].Id, RecordTypeId = studRTId , Start_Date__c=System.today(),End_Date__c=System.today()+30, Status__c = 'Active')

         };
         insert conAssList;      
         
        List<Planned_Days_Off__c> plannedList = new List<Planned_Days_Off__c> {
             
             new Planned_Days_Off__c(Contact__c = contList[0].Id, Status__c = 'Approved', RecordTypeId = projPlanned , Project__c = scheduleList[0].Project__c),
             new Planned_Days_Off__c(Contact__c = contList[1].Id, Status__c = 'Approved', RecordTypeId = projPlanned, Project__c = scheduleList[1].Project__c)
         };
         insert plannedList;  
         
         List<Events__c> eventList = [SELECT Date__c , Schedule__c FROM Events__c WHERE Schedule__c IN :scheduleList];
         delete eventList;
         
        
        eventDate.add(Date.valueOf(system.now()));
        
        Test.startTest();        
         eveInst.createSubstitueScheduleEvts(new Map<Id,Set<Date>>{scheduleList[0].Id => eventDate});
        Test.stopTest();
        
        List<Events__c> eventResultList = [SELECT Date__c , Schedule__r.Project__c FROM Events__c WHERE Schedule__c IN :scheduleList];
        //System.assertEquals( 1,eventResultList.size());
     }
     
     
     public static testMethod void createSubstitue_Test() {
         
         Set<Date> eventDate = new Set<Date>();
         EventHandler eveInst = new EventHandler();
         Id studRTId = RecrdTypeMap.get('Contact_Assignments__c').get('Student');
         Id staffRTId = RecrdTypeMap.get('Contact_Assignments__c').get('Staff');
         Id projPlanned = RecrdTypeMap.get('Planned_Days_Off__c').get('Project_Planned_Days_Off');
         List<Schedule__c> scheduleList = [SELECT Id, Schedule_Type__c, Status__c, Project__c, Prior_Schedule__c, Name FROM Schedule__c WHERE Name IN('15-00687-SH1', '15-00687-SH1', 'scheduleWithoutEvent')];

         
        List<Contact> contList = [SELECT Id, Name, Email FROM Contact WHERE Name IN ('Test Contact1', 'Test Contact2', 'Test Contact3')];
        List<Room__c> roomList = [SELECT Id, Name FROM Room__c WHERE Name IN('Room', 'Room 1')];  
        
        List<Schedule__c> priorSchedules =  new List<Schedule__c> {
        
            new Schedule__c(Start_Date__c= System.Today(), End_Date__c = System.today()+10)
           
        };
        
        insert priorSchedules;     
 
        scheduleList[0].Instructor__c = contList[0].Id;    
        scheduleList[0].Room__c = roomList[0].Id;    
        scheduleList[0].Prior_Schedule__c = priorSchedules[0].id;
        
        update scheduleList;
        
        List<Contact_Assignments__c> conAssList =  new List<Contact_Assignments__c> {
     
            new Contact_Assignments__c (Project__c=scheduleList[0].Project__c, Candidate_Name__c=contList[1].Id, RecordTypeId = staffRTId , Start_Date__c=System.today(),End_Date__c=System.today()+30, Status__c = 'Active'),
            new Contact_Assignments__c (Project__c=scheduleList[0].Project__c, Candidate_Name__c=contList[1].Id, RecordTypeId = studRTId , Start_Date__c=System.today(),End_Date__c=System.today()+30, Status__c = 'Active')

         };
         insert conAssList;      
         
        List<Planned_Days_Off__c> plannedList = new List<Planned_Days_Off__c> {
             
             new Planned_Days_Off__c(Contact__c = contList[0].Id, Status__c = 'Approved', RecordTypeId = projPlanned , Project__c = scheduleList[0].Project__c),
             new Planned_Days_Off__c(Contact__c = contList[1].Id, Status__c = 'Approved', RecordTypeId = projPlanned, Project__c = scheduleList[1].Project__c)
         };
         insert plannedList;       
        
        eventDate.add(Date.valueOf(system.now()));
         eveInst.createSubstitueScheduleEvts(new Map<Id,Set<Date>>{scheduleList[0].Id => eventDate});
        
        List<Events__c> eventResultList = [SELECT Date__c , Schedule__r.Project__c FROM Events__c WHERE Schedule__c IN :scheduleList];
        //System.assertEquals( 7,eventResultList.size());
    }
    
    private static testMethod void myTest1() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Student'];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Varied_Day__c, Travel_Required__c, Schedule_Type__c FROM Schedule__c LIMIT 1];
        schList[0].Varied_Day__c = FALSE;
        schList[0].Travel_Required__c = FALSE;
        schList[0].Schedule_Type__c = 'Regular';
        schList[0].Status__c = 'Active';
        update schList[0];
        
        List<Events__c> events = new List<Events__c>{
            new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 4,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = schList[0].Project__c,Status__c = 'Scheduled', Start_Time__c = '06:00 AM', End_Time__c = '06:45 PM'),
            new Events__c(Name = '15-00687-SH1-EV2',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = schList[0].Project__c,Status__c = 'Scheduled', Start_Time__c = '09:00 PM', End_Time__c = '09:45 PM')
        };
        insert events;
        
        List<Schedule__c> schList1 = [SELECT Id FROM Schedule__c WHERE Id = :schList[0].Id];
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = schList[0].Project__c,Candidate_Name__c = conList[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Status__c = 'Active', Assignment_Position__c = 'Student'),
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = schList[0].Project__c,Candidate_Name__c = conList[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Status__c = 'Active', Assignment_Position__c = 'Student')
        };
        
        Test.startTest();
        
            insert conAssignRecs;
            
            Id pdoRTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Training_Holidays').getRecordTypeId();
            
            Planned_Days_Off__c pdo = new Planned_Days_Off__c(Contact__c = conList[0].Id,Date__c=System.today(),Description__c='Test',Requested_Reschedule_Date__c=System.today()+15, Status__c = 'Approved', RecordTypeId = pdoRTId);
            insert pdo;
                    
            EventHandler.handleEventRecords(new Set<Id>{schList1[0].Id});
        Test.stopTest();
    }
    
    private static testMethod void myTest2(){
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Student'];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Varied_Day__c, Travel_Required__c, Schedule_Type__c FROM Schedule__c LIMIT 1];
        
        List<Room__c> rooms = [SELECT Id FROM Room__c];
        
        List<Events__c> events = new List<Events__c>{
            new Events__c(Name = '15-00687-SH1-EV1',Room__c = rooms[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 4,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = schList[0].Project__c,Status__c = 'Scheduled', Start_Time__c = '06:00 AM', End_Time__c = '06:45 PM'),
            new Events__c(Name = '15-00687-SH1-EV2',Room__c = rooms[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = schList[0].Project__c,Status__c = 'Scheduled', Start_Time__c = '09:00 PM', End_Time__c = '09:45 PM')
        };
        insert events;
        
        List<Events__c> eventRecs = [SELECT Id, Date__c, Start_Time__c, End_Time__c, Project__c, Schedule__c, Instructor__c, Room__c FROM Events__c WHERE Id IN : events];
        Map<Date, List<Events__c>> eveMap = new Map<Date, List<Events__c>>();
        eveMap.put(Date.Today(), eventRecs);
        
        EventHandler eveHan = new EventHandler();
        eveHan.checkEventConflicts(eventRecs, eveMap, eveMap, new Map<Id,Id>());
    }
    
    private static testMethod void myTest3(){
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Student'];
        
        List<Schedule__c> schList = [SELECT Id, Project__c FROM Schedule__c LIMIT 1];
                
        List<Events__c> events = new List<Events__c>{
            new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 4,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = schList[0].Project__c,Status__c = 'Scheduled', Start_Time__c = '06:00 AM', End_Time__c = '06:45 PM'),
            new Events__c(Name = '15-00687-SH1-EV2',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = schList[0].Project__c,Status__c = 'Scheduled', Start_Time__c = '09:00 PM', End_Time__c = '09:45 PM')
        };
        insert events;
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = schList[0].Project__c,Candidate_Name__c = conList[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Status__c = 'Active', Assignment_Position__c = 'Student'),
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = schList[0].Project__c,Candidate_Name__c = conList[0].Id,Start_Date__c = System.today(),End_Date__c=System.today()+30,Status__c = 'Active', Assignment_Position__c = 'Student')
        };
        
        Test.startTest();
        
            insert conAssignRecs;
            EventHandler eveHan = new EventHandler();
            eveHan.getStudentEvents(new Set<Id>{schList[0].Project__c}, new Set<Id>{}, NULL, NULL, new Set<Date>{Date.Today()});
            eveHan.getStudentEvents(new Set<Id>{schList[0].Project__c}, new Set<Id>{}, Date.Today(), Date.Today(), new Set<Date>{Date.Today()});
        Test.stopTest();
    }
    
    // To cover cancelPriorScheduleEvents method in EventHandler
    private static testMethod void myTest20(){
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Student'];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Varied_Day__c, Travel_Required__c, Schedule_Type__c FROM Schedule__c LIMIT 1];
        schList[0].Schedule_Type__c = 'Substitute';
        update schList[0];
        
        List<Events__c> events = [SELECT Id, Date__c FROM Events__c WHERE Schedule__c = :schList[0].Id];
        
        EventHandler eh = new EventHandler();
        eh.cancelPriorScheduleEventsList(new Map<Id,Set<Date>>{schList[0].Id => new Set<Date>{events[0].Date__c}});
    }
    
    // To cover updatePriorScheduleEventsToScheduled method in EventHandler
    private static testMethod void myTest5(){
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Student'];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Varied_Day__c, Travel_Required__c, Schedule_Type__c FROM Schedule__c LIMIT 1];
        
        List<Events__c> events = [SELECT Id, Date__c, Status__c FROM Events__c WHERE Schedule__c = :schList[0].Id];
        events[0].Status__c = 'Substituted';
        events[0].Date__c = Date.Today().addDays(1);
        update events[0];
        
        String dateString = String.valueOf(Date.Today())+'~'+String.valueOf(Date.Today().addDays(2));
        
        Map<Id,String> priorIdDatesString = new Map<Id,String>();
        priorIdDatesString.put(schList[0].Id, dateString);
        
        Test.startTest();
        
            EventHandler eh = new EventHandler();
            eh.updatePriorScheduleEventsToScheduled(priorIdDatesString);
        Test.stopTest();
    }
    
    // To cover sendAnEmailToLTSForApproval method in EventHandler
    private static testMethod void myTest6(){
    
        List<Schedule__c> schList = [SELECT Id, Project__c,Varied_Day__c, Travel_Required__c, Schedule_Type__c FROM Schedule__c LIMIT 1];
        
        List<Room__c> rooms = [SELECT Id FROM Room__c];
        
        List<Events__c> events = [SELECT Id, Date__c, Status__c, Instructor__c FROM Events__c WHERE Schedule__c = :schList[0].Id];
        
        String FirstName = UserInfo.getFirstName();
        String LastName = UserInfo.getLastName();
        String Name = UserInfo.getName();

        Contact c = new Contact(FirstName = FirstName, LastName = LastName);
        insert c;
        
        Test.startTest();
        
            Events__c reSche = new Events__c(Name = '15-00687-SH1-EV1',Room__c = rooms[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 4,Instructor__c = events[0].Instructor__c,
                Date__c = Date.Today().addDays(2),Project__c = schList[0].Project__c,Status__c = 'Scheduled', Start_Time__c = '06:00 AM', End_Time__c = '06:45 PM', 
                Parent_Event__c = events[0].Id, Approval_Status__c = 'Pending LTS Approval', Parent_Status_Changed_To__c = 'Rescheduled');
            insert reSche;
            
        Test.stopTest();
    }
    
    // To cover try-catch in sendAnEmailToLTSForApproval method in EventHandler
    private static testMethod void myTest6a(){
    
        List<Schedule__c> schList = [SELECT Id, Project__c,Varied_Day__c, Travel_Required__c, Schedule_Type__c FROM Schedule__c LIMIT 1];
        
        List<Room__c> rooms = [SELECT Id FROM Room__c];
        
        List<Events__c> events = [SELECT Id, Date__c, Status__c, Instructor__c FROM Events__c WHERE Schedule__c = :schList[0].Id];
        
        String FirstName = UserInfo.getFirstName();
        String LastName = UserInfo.getLastName();
        String Name = UserInfo.getName();

        Contact c = new Contact(FirstName = FirstName, LastName = LastName);
        insert c;
        
        Test.startTest();
        
            Events__c reSche = new Events__c(Name = '15-00687-SH1-EV1',Room__c = rooms[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 4,Instructor__c = events[0].Instructor__c,
                Project__c = schList[0].Project__c,Status__c = 'Scheduled', Start_Time__c = '06:00 AM', End_Time__c = '06:45 PM', 
                Parent_Event__c = events[0].Id, Approval_Status__c = 'Pending LTS Approval', Parent_Status_Changed_To__c = 'Rescheduled');
            insert reSche;
            
        Test.stopTest();
    }
    
    // To cover sendAnEmailToInstructorAfterLTSApproval method in EventHandler
    private static testMethod void myTest7(){
    
        List<Schedule__c> schList = [SELECT Id, Project__c,Varied_Day__c, Travel_Required__c, Schedule_Type__c FROM Schedule__c LIMIT 1];
        
        List<Room__c> rooms = [SELECT Id FROM Room__c];
        
        List<Events__c> events = [SELECT Id, Date__c, Status__c, Instructor__c FROM Events__c WHERE Schedule__c = :schList[0].Id];
        
        Test.startTest();            
                        
            Events__c reSche = new Events__c(Name = '15-00687-SH1-EV1',Room__c = rooms[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 4,Instructor__c = events[0].Instructor__c,
            Date__c = Date.Today().addDays(2),Project__c = schList[0].Project__c,Status__c = 'Scheduled', Start_Time__c = '06:00 AM', End_Time__c = '06:45 PM', 
            Parent_Event__c = events[0].Id, Approval_Status__c = 'Pending LTS Approval', Parent_Status_Changed_To__c = 'Rescheduled');
            insert reSche;
            
            List<Events__c> reScheEve = [SELECT Id, Approval_Status__c FROM Events__c WHERE Id = :reSche.Id];
            reScheEve[0].Approval_Status__c = 'LTS Approved';
            update reScheEve[0];
            
        Test.stopTest();
    }
    
    // To cover sendAnEmailToStudentAfterInsApproval method in EventHandler
    private static testMethod void myTest8(){
    
        List<Schedule__c> schList = [SELECT Id, Project__c,Varied_Day__c, Travel_Required__c, Schedule_Type__c FROM Schedule__c LIMIT 1];
        
        List<Room__c> rooms = [SELECT Id FROM Room__c];
        
        List<Events__c> events = [SELECT Id, Date__c, Status__c, Instructor__c FROM Events__c WHERE Schedule__c = :schList[0].Id];
        
        Test.startTest();            
                        
            Events__c reSche = new Events__c(Name = '15-00687-SH1-EV1',Room__c = rooms[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 4,Instructor__c = events[0].Instructor__c,
            Date__c = Date.Today().addDays(2),Project__c = schList[0].Project__c,Status__c = 'Scheduled', Start_Time__c = '06:00 AM', End_Time__c = '06:45 PM', 
            Parent_Event__c = events[0].Id, Approval_Status__c = 'LTS Approved', Parent_Status_Changed_To__c = 'Rescheduled');
            insert reSche;
            
            List<Events__c> reScheEve = [SELECT Id, Approval_Status__c FROM Events__c WHERE Id = :reSche.Id];
            reScheEve[0].Approval_Status__c = 'Instructor Approved';
            update reScheEve[0];
            
        Test.stopTest();
    }
    
    // To cover sendAnEmailToLTSAfterInsRejection method in EventHandler
    private static testMethod void myTest9(){
    
        List<Schedule__c> schList = [SELECT Id, Project__c,Varied_Day__c, Travel_Required__c, Schedule_Type__c FROM Schedule__c LIMIT 1];
        
        List<Room__c> rooms = [SELECT Id FROM Room__c];
        
        List<Events__c> events = [SELECT Id, Date__c, Status__c, Instructor__c FROM Events__c WHERE Schedule__c = :schList[0].Id];
        
        String FirstName = UserInfo.getFirstName();
        String LastName = UserInfo.getLastName();
        String Name = UserInfo.getName();
        
        Contact c = new Contact(FirstName = FirstName, LastName = LastName);
        insert c;

        Test.startTest();            
                        
            Events__c reSche = new Events__c(Name = '15-00687-SH1-EV1',Room__c = rooms[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 4,Instructor__c = events[0].Instructor__c,
            Date__c = Date.Today().addDays(2),Project__c = schList[0].Project__c,Status__c = 'Scheduled', Start_Time__c = '06:00 AM', End_Time__c = '06:45 PM', 
            Parent_Event__c = events[0].Id, Approval_Status__c = 'LTS Approved', Parent_Status_Changed_To__c = 'Rescheduled');
            insert reSche;
            
            List<Events__c> reScheEve = [SELECT Id, Approval_Status__c FROM Events__c WHERE Id = :reSche.Id];
            reScheEve[0].Approval_Status__c = 'Instructor Rejected';
            update reScheEve[0];
            
        Test.stopTest();
    }
    
    // To cover sendAnEmailToLTS_InstructorConflict method in EventHandler
    private static testMethod void myTest10(){
    
        List<Schedule__c> schList = [SELECT Id, Project__c,Varied_Day__c, Travel_Required__c, Schedule_Type__c FROM Schedule__c LIMIT 1];
        
        List<Room__c> rooms = [SELECT Id FROM Room__c];
        
        List<Events__c> events = [SELECT Id, Date__c, Status__c, Instructor__c FROM Events__c WHERE Schedule__c = :schList[0].Id];
                
        String FirstName = UserInfo.getFirstName();
        String LastName = UserInfo.getLastName();
        String Name = UserInfo.getName();
        
        Contact c = new Contact(FirstName = FirstName, LastName = LastName);
        insert c;
        
        Test.startTest();            
                        
            Events__c reSche = new Events__c(Name = '15-00687-SH1-EV1',Room__c = rooms[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 4,Instructor__c = events[0].Instructor__c,
            Date__c = Date.Today().addDays(2),Project__c = schList[0].Project__c,Status__c = 'Scheduled', Start_Time__c = '06:00 AM', End_Time__c = '06:45 PM', 
            Parent_Event__c = events[0].Id, Approval_Status__c = 'Pending LTS Approval', Parent_Status_Changed_To__c = 'Substituted');
            insert reSche;
            
        Test.stopTest();
    }
    
    // To cover sendAnEmailToStd_InstructorSubstituted method in EventHandler
    private static testMethod void myTest11(){
    
        List<Schedule__c> schList = [SELECT Id, Project__c,Varied_Day__c, Travel_Required__c, Schedule_Type__c FROM Schedule__c LIMIT 1];
        
        List<Room__c> rooms = [SELECT Id FROM Room__c];
        
        List<Events__c> events = [SELECT Id, Date__c, Status__c, Instructor__c FROM Events__c WHERE Schedule__c = :schList[0].Id];
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Id != :events[0].Instructor__c];
        
        Test.startTest();            
                        
            Events__c reSche = new Events__c(Name = '15-00687-SH1-EV1',Room__c = rooms[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 4,Instructor__c = events[0].Instructor__c,
            Date__c = Date.Today().addDays(2),Project__c = schList[0].Project__c,Status__c = 'Scheduled', Start_Time__c = '06:00 AM', End_Time__c = '06:45 PM', 
            Parent_Event__c = events[0].Id, Approval_Status__c = 'Pending LTS Approval', Parent_Status_Changed_To__c = 'Substituted');
            insert reSche;
            
            List<Events__c> reScheEve = [SELECT Id, Approval_Status__c, Instructor__c FROM Events__c WHERE Id = :reSche.Id];
            reScheEve[0].Approval_Status__c = 'LTS Approved';
            reScheEve[0].Instructor__c = conList[0].Id;
            update reScheEve[0];
            
        Test.stopTest();
    }
    
    // To cover sendAnEmailforRoomConflict method in EventHandler
    private static testMethod void myTest12(){
    
        List<Schedule__c> schList = [SELECT Id, Project__c,Varied_Day__c, Travel_Required__c, Schedule_Type__c FROM Schedule__c LIMIT 1];
        
        List<Room__c> rooms = [SELECT Id FROM Room__c];
        
        List<Events__c> events = [SELECT Id, Date__c, Status__c, Instructor__c FROM Events__c WHERE Schedule__c = :schList[0].Id];
        
        Events__c otherEve = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 4,
            Instructor__c = events[0].Instructor__c,Date__c = Date.Today().addDays(2),Project__c = schList[0].Project__c,
            Status__c = 'Scheduled',Start_Time__c = '01:00 PM',End_Time__c = '03:00 PM',Room__c = rooms[0].Id);
        insert otherEve;
        
        Test.startTest();            
                        
            Events__c reSche = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 4,
                Instructor__c = events[0].Instructor__c,Date__c = Date.Today().addDays(2),Project__c = schList[0].Project__c,
                Status__c = 'Scheduled',Start_Time__c = '02:00 PM',End_Time__c = '04:00 PM',Room__c = rooms[0].Id,
                Parent_Event__c = events[0].Id, Approval_Status__c = 'LTS Approved');
            insert reSche;
            
            List<Events__c> reScheEve = [SELECT Id, Approval_Status__c, Instructor__c FROM Events__c WHERE Id = :reSche.Id];
            reScheEve[0].Approval_Status__c = 'Instructor Approved';
            update reScheEve[0];
            
        Test.stopTest();
    }
    
    // To cover sendAnEmailforRoomConflict method in EventHandler
    private static testMethod void myTest12a(){
    
        List<Schedule__c> schList = [SELECT Id, Project__c,Varied_Day__c, Travel_Required__c, Schedule_Type__c FROM Schedule__c LIMIT 1];
        
        List<Room__c> rooms = [SELECT Id FROM Room__c];
        
        List<Events__c> events = [SELECT Id, Date__c, Status__c, Instructor__c FROM Events__c WHERE Schedule__c = :schList[0].Id];
        
        Events__c otherEve = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 4,
            Instructor__c = events[0].Instructor__c,Date__c = Date.Today().addDays(2),Project__c = schList[0].Project__c,
            Status__c = 'Scheduled',Start_Time__c = '02:00 PM',End_Time__c = '04:00 PM',Room__c = rooms[0].Id);
        insert otherEve;
        
        Test.startTest();            
                        
            Events__c reSche = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 4,
                Instructor__c = events[0].Instructor__c,Date__c = Date.Today().addDays(2),Project__c = schList[0].Project__c,
                Status__c = 'Scheduled',Start_Time__c = '01:00 PM',End_Time__c = '03:00 PM',Room__c = rooms[0].Id,
                Parent_Event__c = events[0].Id, Approval_Status__c = 'LTS Approved');
            insert reSche;
            
            List<Events__c> reScheEve = [SELECT Id, Approval_Status__c, Instructor__c FROM Events__c WHERE Id = :reSche.Id];
            reScheEve[0].Approval_Status__c = 'Instructor Approved';
            update reScheEve[0];
            
        Test.stopTest();
    }
    
    // LCR population when event creation
    private static testMethod void LCRPopulationTest_1(){
    
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),01);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'LCR Population Test Project 1',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
        
            AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
            insert projTask;
            
            List<Schedule__c> schList = new List<Schedule__c> {
                new Schedule__c(Name = '15-00687-SH1', Monday__c = true, Tuesday__c = true, Wednesday__c = true, Thursday__c = true, Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+20, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
            };
            insert schList;
            
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            
            AcctSeed__Cost_Rates__c lcr = new AcctSeed__Cost_Rates__c(Contact__c = stdCon[1].Id, Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 22,Status__c = 'Approved', Payroll_Item__c = 'R');
            insert lcr;
            
            // Insert Paper Timesheet custom setting
            List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'True')};
            Insert sysVal;
        
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Drafted_Labor_Cost_Rate__c = lcr.Id, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Instructor')
            };
            insert conAssignRecs;
            
            // Event creation
            ScheduleCmpLightningController.scheduleActivate(schList[0].Id);
            
        Test.stopTest();
        
        List<Events__c> events = [SELECT Id, Labor_Cost_Rate__c FROM Events__c WHERE Schedule__c = :schList[0].Id];
        System.assertEquals(lcr.Id, events[0].Labor_Cost_Rate__c);
    }
    
    // LCR population when Pay Rate Modification
    private static testMethod void LCRPopulationTest_2(){
    
        Account a = new Account(Name = 'DLS');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id lTProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),01);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'LCR Population Test Project 2',AcctSeed__Status__c = 'Active',RecordTypeId = lTProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, End_Date__c = projED);
        insert proj;
        
        AcctSeed__Project_Task__c projTask = new AcctSeed__Project_Task__c(Name = 'Test Task-Hindi',AcctSeed__Project__c=proj.Id,Project_Task_Type__c='Language Training', AcctSeed__Labor_GL_Account__c=glAccList[0].Id, Total_Qty_Planned__c = 100);
        insert projTask;
        
        List<Schedule__c> schList = new List<Schedule__c> {
            new Schedule__c(Name = '15-00687-SH1', Monday__c = true, Tuesday__c = true, Wednesday__c = true, Thursday__c = true, Project__c = proj.Id,Project_Task__c=projTask.Id, Total_Hours__c = 0,End_Date__c=System.Today()+20, Start_Date__c=System.Today(),Status__c= 'Drafted', Schedule_Type__c = 'Regular', Instructor__c = stdCon[1].Id)
        };
        insert schList;
        
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
    
        AcctSeed__Cost_Rates__c lcr = new AcctSeed__Cost_Rates__c(Contact__c = stdCon[1].Id, Rate_Type__c = 'LT without Prep',AcctSeed__Hourly_Cost__c = 22,Status__c = 'Approved', Payroll_Item__c = 'R');
        insert lcr;
        
        Test.startTest();
        
            // Insert Paper Timesheet custom setting
            List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'True')};
            Insert sysVal;
        
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Drafted_Labor_Cost_Rate__c = lcr.Id, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Instructor')
            };
            insert conAssignRecs;
            
            // Event creation
            ScheduleCmpLightningController.scheduleActivate(schList[0].Id);
            
            Pay_Rate_Modification_Handler.isFromCRModify = true;
            AcctSeed__Cost_Rates__c prm_LCR = new AcctSeed__Cost_Rates__c(Prior_Version__c = lcr.Id, Effective_Date__c = System.Today()+10, Contact__c = stdCon[1].Id, Rate_Type__c = 'LT without Prep',AcctSeed__Hourly_Cost__c = 22,Status__c = 'Approved', Payroll_Item__c = 'R');
            insert prm_LCR;
            
        Test.stopTest();
        
        Date effDate = System.Today()+10;
        List<Events__c> events = [SELECT Id, Labor_Cost_Rate__c FROM Events__c WHERE Schedule__c = :schList[0].Id AND Date__c > : effDate];
        System.assertEquals(prm_LCR.Id, events[0].Labor_Cost_Rate__c);
    }
    
    // LCR population when event creation for testing project
    private static testMethod void LCRPopulationTest_3(){
        
        Account a = new Account(Name = 'DLI');
        insert a;
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity LIMIT 1];
        
        List<Contact> stdCon = [SELECT Id, Name FROM Contact WHERE NAME LIKE '%Test%' LIMIT 2];
        
        Id testProjRTId = Schema.SObjectType.AcctSeed__Project__c .getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        Id usrId = UserInfo.getUserId();
        
        Date projSD = Date.newInstance(System.today().year(),System.today().month(),01);
        Date projED = Date.newInstance(System.today().year(),System.today().month()+2,15);
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name FROM AcctSeed__GL_Account__c LIMIT 2];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(AcctSeed__Account__c = a.Id, Name = 'LCR Population Test Project 3',AcctSeed__Status__c = 'Active',RecordTypeId = testProjRTId, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = projSD, Oral_Exam_Date_Time__c = projED, End_Date__c = projED);
        insert proj;
        
        Test.startTest(); 
        
            Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
            Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
            
            AcctSeed__Cost_Rates__c lcr = new AcctSeed__Cost_Rates__c(Contact__c = stdCon[1].Id, Rate_Type__c = 'DLI-21 SCA LT',AcctSeed__Hourly_Cost__c = 22,Status__c = 'Approved', Payroll_Item__c = 'R');
            insert lcr;
            
            // Insert Paper Timesheet custom setting
            List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='Paper Timesheet Value', Value__c = 'True')};
            Insert sysVal;
        
            List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
                new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = proj.Id, Candidate_Name__c = stdCon[0].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Student'),
                new Contact_Assignments__c(RecordTypeId = insRTId, Drafted_Labor_Cost_Rate__c = lcr.Id, Project__c = proj.Id, Candidate_Name__c = stdCon[1].Id, Start_Date__c = projSD, End_Date__c = projED, Opportunity_Name__c = opp[0].Id,Status__c = 'Active', Assignment_Position__c = 'Instructor')
            };
            insert conAssignRecs;
                        
            Events__c eve = new Events__c();
            eve.Date__c = projED;
            eve.Instructor__c = stdCon[1].Id;
            eve.Start_Time__c = '09:00 AM';
            eve.End_Time__c = '10:00 AM';
            eve.Id = null;
            eve.Project__c =  proj.Id;
            
            String result = EventTabController.createEventsForTestingProject(JSON.serialize(new List<Events__c>{eve}), '', false, false);
            
        Test.stopTest();
        
        List<Events__c> events = [SELECT Id, Labor_Cost_Rate__c FROM Events__c WHERE Project__c = :proj.Id];
        System.assertEquals(lcr.Id, events[0].Labor_Cost_Rate__c);
    }
}