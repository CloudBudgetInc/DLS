@isTest
private class RescheduleEventNeedInsApproval_Test{

    @testSetup static void setupMethod() {
    
        Test.startTest();
            List<Events__c> eventList =  TestClassUtil.createTestEvent();
        Test.stopTest();   
        List<Room__c> roomList = TestClassUtil.createTestRoom();
    }
    
    private static testMethod void myTest(){
    
        List<Schedule__c> schList = [SELECT Id, Project__c,Varied_Day__c, Travel_Required__c, Schedule_Type__c FROM Schedule__c LIMIT 1];
        
        List<Room__c> rooms = [SELECT Id FROM Room__c];
        
        List<Events__c> events = [SELECT Id, Date__c, Status__c, Instructor__c FROM Events__c WHERE Schedule__c = :schList[0].Id];
        
        Test.startTest();
        
            Events__c reSche = new Events__c(Name = '15-00687-SH1-EV1',Room__c = rooms[0].Id, Schedule__c = schList[0].Id,SequenceNo__c = 4,Instructor__c = events[0].Instructor__c,
                Date__c = Date.Today().addDays(2),Project__c = schList[0].Project__c,Status__c = 'Scheduled', Start_Time__c = '06:00 AM', End_Time__c = '06:45 PM', 
                Parent_Event__c = events[0].Id, Approval_Status__c = 'LTS Approved', Parent_Status_Changed_To__c = 'Rescheduled');
            insert reSche;
            
        Test.stopTest();
        
        // Schedule coverage
        String CRON_EXP = '0 0 10 * * ?';
        RescheduleEventNeedInsApproval sch = new RescheduleEventNeedInsApproval();
        system.schedule('Reschedule Event Need Ins Approval', CRON_EXP, sch);
    }
}