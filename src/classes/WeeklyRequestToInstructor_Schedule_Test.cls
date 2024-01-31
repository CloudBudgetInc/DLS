@isTest
private class WeeklyRequestToInstructor_Schedule_Test{

    @testSetup static void setupMethod(){
       
        Test.startTest();
            List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
        
        List<Schedule__c> schedule = TestClassUtil.createTestScheduleWithOpportunity();
        List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
    }
    
    private static testMethod void sendAnEmailToInstructor(){
            
        DateTime currentTime =  DateTime.now();
        Date currentWeekStart = System.today().toStartofWeek().addDays(1);
        
        String period = 'AM';
        Integer hour = currentTime.hour();
        if(currentTime.hour() >= 12){
            hour = currentTime.hour() - 12;            
            period = 'PM';
        }
        if(hour == 0){
            hour = 12;
        }
        
        String startTime = hour+':00 '+period;
        String endTime = hour+':15 '+period;
                   
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com', IsActive = TRUE,Instructor_Access__c = TRUE);
       
        insert user;
        
        List<Schedule__c> schList = [SELECT Id, Project__c FROM Schedule__c LIMIT 1];
        System.debug('schList===='+schList);
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c, DLS_Class__c FROM AcctSeed__Project__c WHERE Id =: schList[0].Project__c];
        System.debug('projs ======'+projs);
        
        Test.startTest();
        
            Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Start_Time__c = startTime, End_Time__c = endTime, Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = currentWeekStart,Project__c = projs[0].Id,Status__c = 'Scheduled');
            insert event;
              
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            WeeklyRequestToInstructor_Schedule sch = new WeeklyRequestToInstructor_Schedule();
            system.schedule('Weekly Request To Instructor', CRON_EXP, sch);
           
        Test.stopTest();
    }
}