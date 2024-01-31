@isTest
public class ZoomMeetingCreationAndDeletionBatch_Test {
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
        
        List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='No. of days to create Zoom meeting', Value__c = '1'),new System_Values__c(Name ='Batch size for zoom meeting deletion', Value__c = '20')};
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
        sch[0].Instructor__c = c.Id;        
        sch[0].Start_Date__c = System.today().addDays(-10);
        sch[0].End_Date__c = System.today().addDays(20);
        sch[0].Hours_Planned__c = 2;
        sch[0].Start_Time__c = '06:30 AM';
        sch[0].End_Time__c = '08:30 AM';
        
        Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
        update sch[0]; 
        
        Test.stopTest();         
    }
    
    private static testMethod void zoomMeetingCreationTest(){
        
        System.assertEquals(0, [SELECT Id FROM Events__c WHERE Is_Meeting_Created__c = true].size());
        
        Contact c = [SELECT Id, Zoom_Id__c, Zoom_User_Status__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];
        c.Zoom_User_Status__c='Active';
        c.Zoom_Id__c = 'testId1234';
        update c;
        
        Test.startTest();  
            Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
            ZoomMeetingCreation_Scheduler sc = new ZoomMeetingCreation_Scheduler();
            sc.execute(null);        
        Test.stopTest(); 
        
        System.assertEquals(true, [SELECT Id FROM Events__c WHERE Is_Meeting_Created__c = true].size() > 0);
    } 
    
    private static testMethod void zoomMeetingDeletionTest1(){
        
        Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
        
        Contact c = [SELECT Id, Zoom_Id__c, Zoom_User_Status__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];
        c.Zoom_User_Status__c='Active';
        c.Zoom_Id__c = 'testId1234';
        update c;
        
        List<Events__c> events = [SELECT Id, Is_Meeting_Created__c FROM Events__c WHERE Status__c = 'Scheduled' AND Date__c >= :System.today()];        
        events[0].Meeting_URL__c= 'https://zoom.us/testMeetingId'; 
        events[0].Is_Meeting_Created__c = true;
        events[0].Meeting_Id__c = 'meetingId';
        update events[0];
        
        Test.startTest();
            
            c.Email = 'testZoomMeetingDeletion1@dlsdc.com';
            update c;
        Test.stopTest();    
    }
    
    private static testMethod void zoomMeetingUpdationTest(){
        
        Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
        
        Contact c = [SELECT Id, Zoom_Id__c, Zoom_User_Status__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];
        c.Zoom_User_Status__c='Active';
        c.Zoom_Id__c = 'testId1234';
        update c;
        
        List<Events__c> events = [SELECT Id, Is_Meeting_Created__c FROM Events__c WHERE Status__c = 'Scheduled' AND Date__c >= :System.today()];        
        events[0].Meeting_URL__c= 'https://zoom.us/testMeetingId'; 
        events[0].Is_Meeting_Created__c = true;
        events[0].Meeting_Id__c = 'meetingId';
        update events[0];
        
        Test.startTest();
            events[0].Start_Time__c = '07:30 AM';
            update events[0];
        Test.stopTest();    
    }
    
    private static testMethod void zoomMeetingDeletionTest(){
        
        Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
        
        Contact c = [SELECT Id, Zoom_Id__c, Zoom_User_Status__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];
        c.Zoom_User_Status__c='Active';
        c.Zoom_Id__c = 'testId1234';
        update c;
        
        List<Events__c> events = [SELECT Id, Is_Meeting_Created__c FROM Events__c];        
        events[0].Meeting_URL__c= 'https://zoom.us/testMeetingId'; 
        events[0].Is_Meeting_Created__c = true;
        events[0].Meeting_Id__c = 'meetingId';
        update events[0];
        
        Test.startTest();
            
            delete events[0];
        Test.stopTest();    
    }
    
     private static testMethod void eventCancelTest(){
        
        Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
        
        Contact c = [SELECT Id, Zoom_Id__c, Zoom_User_Status__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];
        c.Zoom_User_Status__c='Active';
        c.Zoom_Id__c = 'testId1234';
        update c;
        
        List<Events__c> events = [SELECT Id, Meeting_URL__c, Meeting_Id__c, Status__c, Is_Meeting_Created__c FROM Events__c];        
        events[0].Meeting_URL__c= 'https://zoom.us/testMeetingId'; 
        events[0].Is_Meeting_Created__c = true;
        events[0].Meeting_Id__c = 'meetingId';
        events[0].Status__c = 'Canceled';
        
        
        Test.startTest();
            
            update events[0];
        Test.stopTest();  
        
        Events__c event = [SELECT Id, Meeting_URL__c, Meeting_Id__c, Status__c, Is_Meeting_Created__c FROM Events__c WHERE Id = :events[0].Id LIMIT 1];
        /*System.assertEquals(event.Is_Meeting_Created__c, true); 
        System.assertEquals(event.Meeting_Id__c, null); 
        System.assertEquals(event.Meeting_URL__c, null);*/ 
                                
    }
    
    private static testMethod void zoomMeetingCreationFromEventTest(){
        List<Events__c> events = [SELECT Id, Is_Meeting_Created__c FROM Events__c];
        
        Contact c = [SELECT Id, Zoom_Id__c, Zoom_User_Status__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];
        c.Zoom_User_Status__c='Active';
        c.Zoom_Id__c = 'testId1234';
        update c;
        
        Test.startTest();
             Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
            ZoomUtil.createMeetingForEvent(events[0].Id);
        Test.stopTest();
        
        Events__c eve = [SELECT Id, Is_Meeting_Created__c FROM Events__c WHERE Id = :events[0].Id LIMIT 1];
        System.assertEquals(true, eve.Is_Meeting_Created__c);
    }
}