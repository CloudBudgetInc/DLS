@isTest
public class ZoomUserCreation_Scheduler_Test {
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
        
        Contact c = [SELECT Id, Active_DLS_Online_User__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];    
        c.Active_DLS_Online_User__c = false;
        update c;
        
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
        update sch[0]; 
        
        Test.stopTest();         
    }
    
    private static testmethod void ZoomUserCreationSchedulerTest(){
       
        Contact c = [SELECT Id, Active_DLS_Online_User__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];    
        c.Active_DLS_Online_User__c = true;
        update c;
        
        Test.startTest();
        	Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserUpdationAndMeetingCreationandDeletionMock());
        	ZoomUserCreation_Scheduler sch = new ZoomUserCreation_Scheduler();
			sch.execute(null);
        Test.stopTest();
    }
}