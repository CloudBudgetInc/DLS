@isTest
private class MoodleCourseDeletion_Scheduler_Test{
    
    @isTest private static void deleteMoodleCourse_1(){
        
        Account acc = new Account(Name = 'DLS');
        insert acc;
        
        Id ltRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
    
        Date endDate = Date.Today().addYears(-1);
        
        AcctSeed__Project__c projs = new AcctSeed__Project__c();
        projs.AcctSeed__Account__c = acc.Id;
        projs.RecordTypeId = ltRTId;
        projs.Name = 'MCD Project 1';
        projs.Start_Date__c = endDate.addDays(-90);
        projs.End_Date__c = Date.Today();
        projs.Moodle_Course_Id__c = 'TC01';
        projs.AcctSeed__Status__c = 'Active';
        insert projs;
        
        projs.End_Date__c = endDate.addDays(-7);
        projs.AcctSeed__Status__c = 'Canceled';
        projs.Moodle_Sync_Status__c = 'Pending';
        update projs;
        
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new MoodleCourseDeletionMock.MoodleCourseDeletionMock1());

            MoodleCourseDeletion_Scheduler  sch2 = new MoodleCourseDeletion_Scheduler(); 
            String sch = '0 0 3 * * ?'; 
            system.schedule('Moodle Course Deletion Scheduler', sch, sch2);

        Test.stopTest();
    }
    
    @isTest private static void deleteMoodleCourse_2(){
        
        Account acc = new Account(Name = 'DLI');
        insert acc;
        
        Id dliRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        Date endDate = Date.Today().addYears(-1);
        
        AcctSeed__Project__c projs = new AcctSeed__Project__c();
        projs.AcctSeed__Account__c = acc.Id;
        projs.RecordTypeId = dliRTId;
        projs.Name = 'MCD Project 2';
        projs.Start_Date__c = endDate.addDays(-90);
        projs.End_Date__c = Date.Today();
        projs.Moodle_Course_Id__c = 'TC02';
        projs.AcctSeed__Status__c = 'Active';
        insert projs;
        
        projs.End_Date__c = endDate.addDays(-7);
        projs.AcctSeed__Status__c = 'Canceled';
        projs.Moodle_Sync_Status__c = 'Failure';
        update projs;
        
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new MoodleCourseDeletionMock.MoodleCourseDeletionMock2());

            MoodleCourseDeletion_Scheduler  sch2 = new MoodleCourseDeletion_Scheduler(); 
            String sch = '0 0 3 * * ?'; 
            system.schedule('Moodle Course Deletion Scheduler', sch, sch2);

        Test.stopTest();
    }
    
    @isTest private static void deleteMoodleCourse_3(){
        
        Account acc = new Account(Name = 'DODA');
        insert acc;
        
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DODA_Projects').getRecordTypeId();
        
        Date endDate = Date.Today().addYears(-1);
        
        AcctSeed__Project__c projs = new AcctSeed__Project__c();
        projs.AcctSeed__Account__c = acc.Id;
        projs.RecordTypeId = dodaRTId;
        projs.Name = 'MCD Project 3';
        projs.Start_Date__c = endDate.addDays(-90);
        projs.End_Date__c = Date.Today();
        projs.Moodle_Course_Id__c = 'TC03';
        projs.AcctSeed__Status__c = 'Active';
        projs.Moodle_Sync_Status__c = 'Pending';
        insert projs;
        
        projs.End_Date__c = endDate.addDays(-7);
        projs.AcctSeed__Status__c = 'Canceled';
        projs.Moodle_Sync_Status__c = 'Failure';
        update projs;
        
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new MoodleCourseDeletionMock.MoodleCourseDeletionMock3());

            MoodleCourseDeletion_Scheduler  sch2 = new MoodleCourseDeletion_Scheduler(); 
            String sch = '0 0 3 * * ?'; 
            system.schedule('Moodle Course Deletion Scheduler', sch, sch2);

        Test.stopTest();
        List<AcctSeed__Project__c> myProj = [SELECT Id, Moodle_Sync_Status__c FROM AcctSeed__Project__c WHERE Id = : projs.Id];
    }
    
    @isTest private static void deleteMoodleCourse_4(){
        
        Account acc = new Account(Name = 'PVT');
        insert acc;
        
        Id ltRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        
        Date endDate = Date.Today().addYears(-1);
        
        AcctSeed__Project__c projs = new AcctSeed__Project__c();
        projs.AcctSeed__Account__c = acc.Id;
        projs.RecordTypeId = ltRTId;
        projs.Name = 'MCD Project 4';
        projs.Start_Date__c = endDate.addDays(-90);
        projs.End_Date__c = Date.Today();
        projs.Moodle_Course_Id__c = '1234';
        projs.AcctSeed__Status__c = 'Active';
        projs.Moodle_Sync_Status__c = 'Pending';
        insert projs;
        
        projs.End_Date__c = endDate.addDays(-7);
        projs.AcctSeed__Status__c = 'Ended';
        projs.Moodle_Sync_Status__c = 'Pending';
        update projs;
        
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new MoodleCourseDeletionMock.MoodleCourseDeletionMock4());

            MoodleCourseDeletion_Scheduler  sch2 = new MoodleCourseDeletion_Scheduler(); 
            String sch = '0 0 3 * * ?'; 
            system.schedule('Moodle Course Deletion Scheduler', sch, sch2);

        Test.stopTest();
    }
    
    @isTest private static void deleteMoodleCourse_5(){
        
        Account acc = new Account(Name = 'DLS');
        insert acc;
        
        Id ltRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        
        Date endDate = Date.Today().addYears(-1);
        
        AcctSeed__Project__c projs = new AcctSeed__Project__c();
        projs.AcctSeed__Account__c = acc.Id;
        projs.RecordTypeId = ltRTId;
        projs.Name = 'MCD Project 5';
        projs.Start_Date__c = endDate.addDays(-90);
        projs.End_Date__c = Date.Today();
        projs.Moodle_Course_Id__c = '5678';
        projs.AcctSeed__Status__c = 'Active';
        projs.Moodle_Sync_Status__c = 'Delete';
        insert projs;
        
        projs.End_Date__c = endDate.addDays(-7);
        projs.AcctSeed__Status__c = 'Canceled';
        projs.Moodle_Sync_Status__c = 'Delete';
        update projs;
        
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new MoodleCourseDeletionMock.MoodleCourseDeletionMock2());

            MoodleCourseDeletion_Scheduler  sch2 = new MoodleCourseDeletion_Scheduler(); 
            String sch = '0 0 3 * * ?'; 
            system.schedule('Moodle Course Deletion Scheduler', sch, sch2);

        Test.stopTest();
    }
    
    @isTest private static void deleteMoodleCourse_6(){
        
        Account acc = new Account(Name = 'DLS');
        insert acc;
        
        Id ltRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
        
        Date endDate = Date.Today().addYears(-1);
        
        AcctSeed__Project__c projs = new AcctSeed__Project__c();
        projs.AcctSeed__Account__c = acc.Id;
        projs.RecordTypeId = ltRTId;
        projs.Name = 'MCD Project 6';
        projs.Start_Date__c = endDate.addDays(-90);
        projs.End_Date__c = Date.Today();
        projs.Moodle_Course_Id__c = '9012';
        projs.AcctSeed__Status__c = 'Active';
        projs.Moodle_Sync_Status__c = 'Pending';
        insert projs;
        
        projs.End_Date__c = endDate.addDays(-7);
        projs.AcctSeed__Status__c = 'Canceled';
        projs.Moodle_Sync_Status__c = 'Pending';
        update projs;
        
        Test.startTest();
        
            Test.setMock(HttpCalloutMock.class, new MoodleCourseDeletionMock.MoodleCourseDeletionMock5());

            MoodleCourseDeletion_Scheduler  sch2 = new MoodleCourseDeletion_Scheduler(); 
            String sch = '0 0 3 * * ?'; 
            system.schedule('Moodle Course Deletion Scheduler', sch, sch2);

        Test.stopTest();
        
        List<AcctSeed__Project__c> myProj = [SELECT Id, Moodle_Sync_Status__c FROM AcctSeed__Project__c WHERE Id = : projs.Id];
    }
}