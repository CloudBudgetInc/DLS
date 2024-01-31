@isTest
private class DailyRequestToInstructor_Schedule_Test{

    @testSetup static void setupMethod(){
    
        List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
        Test.startTest();
        List<Schedule__c> schList = TestClassUtil.createTestSchedule();
        Test.stopTest();
    }
    
    private static testMethod void myTest(){
            
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1'];
        System.debug('conList==='+conList);
        
        List<Schedule__c> schList = [SELECT Id, Project__c FROM Schedule__c LIMIT 1];
        System.debug('schList===='+schList);
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c WHERE Id =: schList[0].Project__c];
        System.debug('projs ======'+projs);
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Paper_Timesheet__c = FALSE;
        
        Test.startTest();
        
            update conAss[0]; 
                
            List<Events__c> events = new List<Events__c>{
                new Events__c(Name = '15-00687-SH1-EV1', Start_Time__c = '07:00 AM', End_Time__c = '07:30 AM', Schedule__c = schList[0].Id, SequenceNo__c = 1, Instructor__c = conList[0].Id, Date__c = Date.Today(), Project__c = schList[0].Project__c, Status__c = 'Scheduled'),
                new Events__c(Name = '15-00687-SH2-EV2', Start_Time__c = '08:00 AM', End_Time__c = '09:00 AM', Schedule__c = schList[0].Id, SequenceNo__c = 1, Instructor__c = conList[0].Id, Date__c = Date.Today(), Project__c = schList[0].Project__c, Status__c = 'Scheduled'),
                new Events__c(Name = '15-00687-SH2-EV3', Start_Time__c = '04:00 PM', End_Time__c = '08:45 PM', Schedule__c = schList[0].Id, SequenceNo__c = 1, Instructor__c = conList[0].Id, Date__c = Date.Today(), Project__c = schList[0].Project__c, Status__c = 'Scheduled')
            };
            insert events;
            
             try{
                 // Schedule coverage
                String CRON_EXP = '0 0 14 * * ?';
                DailyRequestToInstructor_Schedule sch = new DailyRequestToInstructor_Schedule();
                system.schedule('Daily Request To Instructor Schedule', CRON_EXP, sch);
                
            }Catch(Exception e){
                system.debug('Exception:'+e+e.getLineNumber());
            }
        Test.stopTest();
    }
}