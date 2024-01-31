@isTest
public class ZoomUserLicenseValidation_Scheduler_Test {
    
    @testSetup
    static void setupMethod(){
        
        List<Contact_Assignments__c> conAssign = TestClassUtil.createTestContactAssignment();               
        
        Floor_Suite__c fs = new Floor_Suite__c(Name = 'Zoom - Online');
        insert fs;
        
        Room__c room = new Room__c(Name = 'Zoom - Online', Room_Status__c = 'Active', Floor_Suite__c = fs.Id);
        insert room;
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        acc.Name = 'Softsquare ELT';
        update acc;
        
        Contact c = [SELECT Id FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];    
        
        List<System_Values__c> sysVal = new List<System_Values__c>{
            new System_Values__c(Name ='No. of days to create Zoom meeting', Value__c = '20'),
            new System_Values__c(Name ='Batch size for zoom meeting deletion', Value__c = '20'),
            new System_Values__c(Name ='Zoom User License Update Batch size', Value__c = '10'),
            new System_Values__c(Name ='Zoom User Validation Batch size', Value__c = '10')
        };
        insert sysVal;
        
        Test.startTest(); 
        
        List<Schedule__c> schedule = TestClassUtil.createTestSchedule();        
        
        Map<Id, AcctSeed__Project__c> projForUpdate = new Map<Id, AcctSeed__Project__c>();
        List<Schedule__c> sch = [SELECT Id, Status__c, Project__c,Project__r.AcctSeed__Account__c, Instructor__c FROM Schedule__c WHERE Status__c = 'Drafted'];
        for(Schedule__c s : sch){
            
            projForUpdate.put(s.Project__c, new AcctSeed__Project__c(Id = s.Project__c, AcctSeed__Account__c = acc.Id));
        }
        update projForUpdate.values();
        
        sch[0].Status__c = 'Active';
        sch[0].Room__c = room.Id;
        sch[0].Monday__c = true;
        sch[0].Tuesday__c = true;
        sch[0].Wednesday__c = true;
        sch[0].Thursday__c = true;
        sch[0].Friday__c = true; 
        sch[0].Saturday__c = true;
        sch[0].Sunday__c = true; 
        sch[0].Instructor__c = c.Id;        
        sch[0].Start_Date__c = System.today().addDays(-10);
        sch[0].End_Date__c = System.today().addDays(40);
        sch[0].Hours_Planned__c = 2;
        sch[0].Start_Time__c = '06:30 AM';
        sch[0].End_Time__c = '08:30 AM';
        
        Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
        update sch[0]; 
        
        Test.stopTest();         
    }
    
    private static testmethod void zoomUserLicenseValidationTest1(){
        
        Contact c = [SELECT Id, Zoom_Id__c, Zoom_User_Status__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];
        c.Zoom_User_Status__c='Active';
        c.Zoom_Id__c = 'testId1234';
        c.Virtual_Conference_License__c = 'Zoom - Pro';
        update c;
        
        Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
        
        List<Events__c> events = [SELECT Id, Project__c, Instructor__c, Start_Date_Time__c, Duration__c, Timezone__c, Is_Meeting_Created__c FROM Events__c WHERE Date__c = :System.now().addDays(-1).date()];
        EventDomain.EventCalendarInfo eveObj = new EventDomain.EventCalendarInfo();
        eveObj.projectId = events[0].Project__c;
        eveObj.instructorId = events[0].Instructor__c;
        eveObj.startDateTime = events[0].Start_Date_Time__c;
        eveObj.duration = String.valueOf(events[0].Duration__c);
        eveObj.timezone = events[0].Timezone__c;
        eveObj.eventId = events[0].Id;
        Test.startTest();  
            String result = EventListViewController.moveEventToOnline(JSON.serialize(eveObj));                    
            
            ZoomUserLicenseValidation_Scheduler sc = new ZoomUserLicenseValidation_Scheduler();
            sc.execute(null);        
        Test.stopTest(); 
    }
    
    private static testmethod void zoomUserLicenseValidationTest2(){
        
        Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
        
        List<Events__c> events = [SELECT Id, Project__c, Schedule__c, Instructor__c, Instructor__r.LastName, Instructor__r.Email, Start_Date_Time__c, Duration__c, Timezone__c, Is_Meeting_Created__c FROM Events__c WHERE Date__c = :System.now().addDays(2).date()];
        EventDomain.EventCalendarInfo eveObj = new EventDomain.EventCalendarInfo();
        eveObj.projectId = events[0].Project__c;
        eveObj.instructorId = events[0].Instructor__c;
        eveObj.startDateTime = events[0].Start_Date_Time__c;
        eveObj.duration = String.valueOf(events[0].Duration__c);
        eveObj.timezone = events[0].Timezone__c;
        eveObj.eventId = events[0].Id;
        
        Contact c = new Contact();
        c.Id = events[0].Instructor__c;
        c.Active_DLS_Online_User__c = True;
        update c;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        User user = new User(alias = 'test123', email=events[0].Instructor__r.Email,
            emailencodingkey='UTF-8', lastname= events[0].Instructor__r.LastName, languagelocalekey='en_US',
            localesidkey='en_US', profileid = p, country='United States',IsActive =true,
            ContactId = events[0].Instructor__c,
            timezonesidkey='America/Los_Angeles', username=events[0].Instructor__r.Email);
       
        insert user;
        
        Test.startTest();  
        String result = EventListViewController.moveEventToOnline(JSON.serialize(eveObj));        
                 
        Test.stopTest(); 
    }
    
    private static testmethod void zoomUserLicenseValidationTest3(){
        
        Contact c = [SELECT Id, Zoom_Id__c, Zoom_User_Status__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];
        c.Zoom_User_Status__c='Active';
        c.Zoom_Id__c = 'testId1234';
        c.Virtual_Conference_License__c = 'Zoom - Pro';
        update c;
        
        Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
        
        List<Events__c> events = [SELECT Id, Schedule__c, Project__c, Instructor__c, Start_Date_Time__c, Duration__c, Timezone__c, Is_Meeting_Created__c FROM Events__c WHERE Date__c = :System.now().addDays(-1).date()];
        EventDomain.EventCalendarInfo eveObj = new EventDomain.EventCalendarInfo();
        eveObj.projectId = events[0].Project__c;
        eveObj.instructorId = events[0].Instructor__c;
        eveObj.startDateTime = events[0].Start_Date_Time__c;
        eveObj.duration = String.valueOf(events[0].Duration__c);
        eveObj.timezone = events[0].Timezone__c;
        eveObj.eventId = events[0].Id;
        
        List<Schedule__c> sch = [SELECT Id, Instructor__c, Project__r.Number_of_Students_Active__c FROM Schedule__c WHERE Id = :events[0].Schedule__c];
        sch[0].Instructor__c = c.Id;
        sch[0].Create_Zoom_Meetings__c = True;
        sch[0].Varied_Day__c = True;
        sch[0].Start_Date__c = Date.Today().addDays(-2);
        sch[0].Status__c = 'Active';
        update sch[0];
        
        
        Test.startTest();  
            String result = EventListViewController.moveEventToOnline(JSON.serialize(eveObj));                    
            
            ZoomUserLicenseValidation_Scheduler sc = new ZoomUserLicenseValidation_Scheduler();
            sc.execute(null);        
        Test.stopTest(); 
    }
    
    private static testmethod void zoomUserLicenseValidationTest4(){
        
        Contact c = [SELECT Id, Zoom_Id__c, Zoom_User_Status__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];
        c.Zoom_User_Status__c='Active';
        c.Zoom_Id__c = 'testId1234';
        c.Virtual_Conference_License__c = 'Zoom - Pro';
        update c;
        
        Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
        
        List<Events__c> events = [SELECT Id, Schedule__c, Project__c, Instructor__c, Start_Date_Time__c, Duration__c, Timezone__c, Is_Meeting_Created__c FROM Events__c WHERE Date__c = :System.now().addDays(-1).date()];
        EventDomain.EventCalendarInfo eveObj = new EventDomain.EventCalendarInfo();
        eveObj.projectId = events[0].Project__c;
        eveObj.instructorId = events[0].Instructor__c;
        eveObj.startDateTime = events[0].Start_Date_Time__c;
        eveObj.duration = String.valueOf(events[0].Duration__c);
        eveObj.timezone = events[0].Timezone__c;
        eveObj.eventId = events[0].Id;
        
        Id testProjRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
    
        AcctSeed__Project__c pro = new AcctSeed__Project__c();
        pro.Id = events[0].Project__c;
        pro.RecordTypeId = testProjRTId;
        update pro;
        
        List<Contact_Assignments__c> ca = [SELECT Id FROM Contact_Assignments__c WHERE Status__c = 'Active' LIMIT 1];
        ca[0].Candidate_Name__c = c.Id;
        ca[0].Assignment_Position__c = 'Examiner';
        ca[0].Project__c = pro.Id;
        update ca[0];
        
        Test.startTest();  
            String result = EventListViewController.moveEventToOnline(JSON.serialize(eveObj));                    
            
            ZoomUserLicenseValidation_Scheduler sc = new ZoomUserLicenseValidation_Scheduler();
            sc.execute(null);        
        Test.stopTest(); 
    }
    
    private static testmethod void zoomUserLicenseValidationTest5(){
        
        Contact c = [SELECT Id, Zoom_Id__c, Zoom_User_Status__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];
        c.Zoom_User_Status__c='Active';
        c.Zoom_Id__c = 'testId1234';
        c.Virtual_Conference_License__c = 'Zoom - Pro';
        c.Active_DLS_Online_User__c = True;
        update c;
        
        Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
        
        List<Events__c> events = [SELECT Id, Project__c, Instructor__c, Start_Date_Time__c, Duration__c, Timezone__c, Is_Meeting_Created__c FROM Events__c WHERE Date__c = :System.now().addDays(-1).date()];
        EventDomain.EventCalendarInfo eveObj = new EventDomain.EventCalendarInfo();
        eveObj.projectId = events[0].Project__c;
        eveObj.instructorId = events[0].Instructor__c;
        eveObj.startDateTime = events[0].Start_Date_Time__c;
        eveObj.duration = String.valueOf(events[0].Duration__c);
        eveObj.timezone = events[0].Timezone__c;
        eveObj.eventId = events[0].Id;
        Test.startTest();  
            String result = EventListViewController.moveEventToOnline(JSON.serialize(eveObj));                    
            
            ZoomUserLicenseValidation_Scheduler sc = new ZoomUserLicenseValidation_Scheduler();
            sc.execute(null);        
        Test.stopTest(); 
    }
    
    // Error Handling
    private static testmethod void zoomUserLicenseValidationTest6(){
        
        Contact c = [SELECT Id, Zoom_Id__c, Zoom_User_Status__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];
        c.Zoom_User_Status__c='Active';
        c.Zoom_Id__c = null;
        c.Virtual_Conference_License__c = 'Zoom - Pro';
        c.Active_DLS_Online_User__c = True;
        update c;
                
        Test.startTest();  
            Database.ExecuteBatch(new ZoomUserLicenseUpdationBatch(new List<Id>{c.Id}, new List<Id>{}, True));   
        Test.stopTest(); 
    }
    
    // Error Handling
    private static testmethod void zoomUserLicenseValidationTest7(){
        
        Contact c = [SELECT Id, Zoom_Id__c, Zoom_User_Status__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];
        c.Zoom_User_Status__c='Active';
        c.Zoom_Id__c = null;
        c.Virtual_Conference_License__c = 'Zoom - Pro';
        c.Active_DLS_Online_User__c = True;
        update c;
                
        Test.startTest();  
            Database.ExecuteBatch(new ZoomUserLicenseUpdationBatch(new List<Id>{c.Id}, new List<Id>{}, False));   
        Test.stopTest(); 
    }
}