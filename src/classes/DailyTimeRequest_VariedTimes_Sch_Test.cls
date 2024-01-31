@isTest
private class DailyTimeRequest_VariedTimes_Sch_Test{

    @testSetup static void setupMethod(){
    
        List<Schedule__c> schList = TestClassUtil.createTestSchedule();
    }
    
    private static testMethod void myTest(){
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        conList[0].Beta_Group__c = TRUE;
        update conList[0];
        
        List<Schedule__c> schList = [SELECT Id, Project__c, Varied_Time__c FROM Schedule__c LIMIT 1];
        System.debug('schList===='+schList);
        schList[0].Varied_Time__c = TRUE;
        update schList[0];
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE Id =: schList[0].Project__c];
        System.debug('projs ======'+projs);
                
        List<Events__c> events = new List<Events__c>{
            new Events__c(Name = '15-00687-SH1-EV1', Schedule__c = schList[0].Id, SequenceNo__c = 1, Instructor__c = conList[0].Id, Date__c = Date.Today(), Project__c = schList[0].Project__c, Status__c = 'Scheduled'),
            new Events__c(Name = '15-00687-SH2-EV2', Schedule__c = schList[0].Id, SequenceNo__c = 1, Instructor__c = conList[0].Id, Date__c = Date.Today(), Project__c = schList[0].Project__c, Status__c = 'Scheduled'),
            new Events__c(Name = '15-00687-SH2-EV3', Schedule__c = schList[0].Id, SequenceNo__c = 1, Instructor__c = conList[0].Id, Date__c = Date.Today(), Project__c = schList[0].Project__c, Status__c = 'Scheduled')
        };
        insert events;
            
        Test.startTest();
        
             try{
                 // Schedule coverage
                String CRON_EXP = '0 0 17 * * ?';
                DailyTimeRequest_VariedTimes_Schedule sch = new DailyTimeRequest_VariedTimes_Schedule();
                system.schedule('Daily Time Entry Request for Varied Times schedules', CRON_EXP, sch);
                
            }Catch(Exception e){
                system.debug('Exception:'+e+e.getLineNumber());
            }
            
        Test.stopTest();
    }
}