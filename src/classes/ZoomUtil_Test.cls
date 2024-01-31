@isTest
private class ZoomUtil_Test {
    
    @testSetup
    static void setupMethod(){
        
        List<Contact_Assignments__c> conAssign = TestClassUtil.createTestContactAssignment();
        Contact c = [SELECT Id, DLS_Candidate_Rating__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];    
        c.DLS_Candidate_Rating__c = '5';
        update c;               
      
        Test.startTest();        
        List<Schedule__c> schedule = TestClassUtil.createTestSchedule();
        
        Floor_Suite__c fs = new Floor_Suite__c(Name = 'Zoom - Online');
        insert fs;
        
        Room__c room = new Room__c(Name = 'Zoom - Online', Room_Status__c = 'Active', Floor_Suite__c = fs.Id);
        insert room;
        
        Account acc = [SELECT Id FROM Account LIMIT 1];
        acc.Name = 'Softsquare ELT';
        update acc;
        
        Map<Id, AcctSeed__Project__c> projForUpdate = new Map<Id, AcctSeed__Project__c>();
        for(Schedule__c sch : [SELECT Id, Status__c, Project__c,Project__r.AcctSeed__Account__c, Instructor__c FROM Schedule__c WHERE Status__c = 'Drafted']){
            
            projForUpdate.put(sch.Project__c, new AcctSeed__Project__c(Id = sch.Project__c, AcctSeed__Account__c = acc.Id));
        }
        update projForUpdate.values();
        
        Test.stopTest(); 
        
    }
    
    private static testMethod void zoomUserCreationTest(){
        
        Contact c = [SELECT Id FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];    
        Account acc = [SELECT Id FROM Account WHERE Name = 'Softsquare ELT' LIMIT 1]; 
        
        List<Room__c> room = [SELECT Id,Name FROM Room__c WHERE Name = 'Zoom - Online'];
        
        List<Schedule__c> sch = [SELECT Id, Status__c, Project__c,Project__r.AcctSeed__Account__c, Instructor__c FROM Schedule__c WHERE Status__c = 'Drafted'];
        
        sch[0].Status__c = 'Active';
        sch[0].Room__c = room[0].Id;
        sch[0].Monday__c = true;
        sch[0].Tuesday__c = true;
        sch[0].Wednesday__c = true;
        sch[0].Thursday__c = true;
        sch[0].Friday__c = true;  
        sch[0].Instructor__c = c.Id;
        
        Test.startTest();  
            
            Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserCreationMock());
            update sch[0]; 
        
        Test.stopTest(); 
    }   
    
    private static testMethod void zoomUserCreationGlobalActionTest(){
        
        Contact c = [SELECT Id FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];                                   
        
        Test.startTest();  
            
            Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserCreationMock());        
            List<sObject> con = ZoomUtil.getLookupRecords('myFirstName','Contact','Name','',new List<String>());
            
            List<Id> instIds = new List<Id>{c.Id};
            String result = ZoomUtil.checkAndCreateZoomUsers(JSON.serialize(instIds));
            system.assertEquals('success', result);
        Test.stopTest(); 
    }   
    
    private static testMethod void zoomUserUpdationTest(){
        
        Contact c = [SELECT Id, Zoom_Id__c, DLS_Candidate_Rating__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];    
        Account acc = [SELECT Id FROM Account WHERE Name = 'Softsquare ELT' LIMIT 1]; 
        
        List<Room__c> room = [SELECT Id,Name FROM Room__c WHERE Name = 'Zoom - Online'];
        
        List<Schedule__c> sch = [SELECT Id, Status__c, Start_Date__c, End_Date__c, Project__c,Project__r.AcctSeed__Account__c, Instructor__c FROM Schedule__c WHERE Status__c = 'Drafted'];
        
        sch[0].Status__c = 'Active';
        sch[0].Room__c = room[0].Id;
        sch[0].Monday__c = true;
        sch[0].Tuesday__c = true;
        sch[0].Wednesday__c = true;
        sch[0].Thursday__c = true;
        sch[0].Friday__c = true;  
        sch[0].Instructor__c = c.Id;
        sch[0].Start_Date__c = System.today().addDays(-10);
        sch[0].End_Date__c = System.today().addDays(40);
        sch[0].Hours_Planned__c = 2;
        sch[0].Start_Time__c = '06:30 AM';
        sch[0].End_Time__c = '08:30 AM';
        
        System.assertEquals(0, [SELECT Id FROM Events__c].size());
        System.assertEquals(c.Zoom_Id__c, null);
        
        Test.startTest();  
            
            Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
            update sch[0]; 
        
        Test.stopTest(); 
        List<Events__c> events = [SELECT Id, Is_Meeting_Created__c FROM Events__c];
        c = [SELECT Id, Zoom_Id__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];    
        System.assertEquals(true, events.size() > 0);
        //System.assertEquals(c.Zoom_Id__c, 'testId1234');
        System.assertEquals(false, events[0].Is_Meeting_Created__c);
        
        c.DLS_Candidate_Rating__c = '1';
        update c;            
    }
    
    private static testMethod void createZoomUserAndUpdateContact_Test(){
    
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
            
            Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
            List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
            
            User user = new User(alias = 'test123', email='test123@noemail.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p, country='United States',IsActive =true,
            ContactId = conList[0].Id,
            timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            //insert user;
            
            ZoomUtil.createZoomUserAndUpdateContact(JSON.serialize(user), JSON.serialize(conList[0].Id));
        Test.stopTest();
    }
    
    private static testMethod void updateZoomUserLicenseAndUpdateContact_Test(){
    
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
            
            Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
            List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
            
            User user = new User(alias = 'test123', email='test123@noemail.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p, country='United States',IsActive =true,
            ContactId = conList[0].Id,
            timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            insert user;
            
            ZoomUtil.updateZoomUserLicenseAndUpdateContact(JSON.serialize(user.Id), JSON.serialize(user));
        Test.stopTest();
    }
    
    private static testMethod void getUserDetailsAndUpdateDetailsFuture_Test(){
        
        Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
            
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileid = p, country='United States',IsActive =true,
        ContactId = conList[0].Id,
        timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        insert user;
        
        ZoomUtil.getUserDetailsAndUpdateDetailsFuture('testId', JSON.serialize(user), JSON.serialize(conList[0].Id), true);
    }
    
    private static testMethod void getSoftsquareAccId_Test(){
        
        List<Account> acc = [SELECT Id, Name FROM Account WHERE Name = 'Softsquare ELT' LIMIT 1];
        
        ZoomUtil.getSoftsquareAccId();
    }
    
    private static testMethod void zoomUserDeletionTest(){
        
        Contact c = [SELECT Id, Zoom_Id__c,DLS_Candidate_Rating__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];            
        
        Test.startTest();  
            
            Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserExceptionMock());            
            c.DLS_Candidate_Rating__c = '1';
            update c;      
        Test.stopTest(); 
          
    }
    
}