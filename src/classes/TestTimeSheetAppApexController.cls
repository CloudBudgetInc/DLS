@isTest
private class TestTimeSheetAppApexController {
    @isTest static void testGetWorkItems() {
        List<agf__ADM_Work__c> testData = new List<agf__ADM_Work__c>();
        
        //Create test user that is not me!
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User usr = new User(LastName = 'Kilburne',
                           FirstName='Chris',
                           Alias = 'jliv',
                           Email = 'chris.kilburne@mbaoutcome.com',
                           Username = 'chris.kilburne@mbaoutcome.com.cdo',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr;

        //Create work items and insert to build test data
        //1-5 Assignee is current user
        for (Integer countOne = 1; countOne < 6; countOne++){
            agf__ADM_Work__c tempWorkItemSet1 = new agf__ADM_Work__c(agf__Assignee__c=UserInfo.getUserId(), 
                                                                     agf__Status__c = 'New', agf__Subject__c='Subject here' , 
                                                                     agf__Details__c='Description here');
            testData.add(tempWorkItemSet1);
        } 
        //6-10 QA is current user
        for (Integer countOne = 6; countOne < 11; countOne++){
            agf__ADM_Work__c tempWorkItemSet2 = new agf__ADM_Work__c(agf__Assignee__c= usr.Id, agf__QA_Engineer__c=UserInfo.getUserId(),
                                                                     agf__Status__c = 'New', agf__Subject__c='Subject here' , 
                                                                     agf__Details__c='Description here');
            testData.add(tempWorkItemSet2);
        }
        //11-15 Neither Assignee nor QA is current user
        for (Integer countOne = 11; countOne < 16; countOne++){
            agf__ADM_Work__c tempWorkItemSet3 = new agf__ADM_Work__c(agf__Assignee__c= usr.Id, agf__QA_Engineer__c=usr.Id,
                                                                     agf__Status__c = 'New', agf__Subject__c='Subject here' , 
                                                                     agf__Details__c='Description here');
            testData.add(tempWorkItemSet3);
        }
        //16-20 assignee is current user but status is closed
        for (Integer countOne = 16; countOne < 21; countOne++){
            agf__ADM_Work__c tempWorkItemSet4 = new agf__ADM_Work__c(agf__Assignee__c=UserInfo.getUserId(), 
                                                                     agf__Status__c = 'Closed', agf__Subject__c='Subject here' , 
                                                                     agf__Details__c='Description here');
            testData.add(tempWorkItemSet4);
        }
        //21-25 assignee is not current user, sharedforallemployees is true
        for (Integer countOne = 21; countOne < 26; countOne++){
            agf__ADM_Work__c tempWorkItemSet5 = new agf__ADM_Work__c(agf__Assignee__c= usr.Id, agf__QA_Engineer__c=usr.Id,
                                                                     agf__Status__c = 'New', agf__Subject__c='Subject here', 
                                                                     agf__Details__c='Description here',Shared_for_all_Employees__c=true );
            testData.add(tempWorkItemSet5);
        }
        
        insert testData;
        
        test.startTest();
        List<agf__ADM_Work__c> workItemsReceived = TimeSheetAppApexController.getWorkItems();
        test.stopTest();
        
        system.assertEquals(15, workItemsReceived.size());
    }
    @isTest static void testSetAllTimeInputs() {
        List<MBA_Timesheet__c> testTimeSheets = new List<MBA_Timesheet__c>();
        agf__ADM_Work__c testWork = new agf__ADM_Work__c(agf__Assignee__c=UserInfo.getUserId(), 
                                                         agf__Status__c = 'New', agf__Subject__c='Subject here', 
                                                         agf__Details__c='Description here' );
        insert testWork;
        for(Integer i=1; i<11; i++){
            MBA_Timesheet__c tempTime = new MBA_Timesheet__c(Name='Test Timesheet '+i, Description__c = 'Test description about the work item assigned for that team member. For agile timesheet test class purpose', 
                                                             Hours_Manual__c = i, Date_of_Work__c=Date.today(),
                                                             MBA_Work_Item_Lookup__c = testWork.Id);
            testTimeSheets.add(tempTime);
        }
        test.startTest();
        List<MBA_Timesheet__c> savedTimeSheets = TimeSheetAppApexController.setAllTimeInputs(testTimeSheets);
        test.stopTest();
        
        Id currUserId = UserInfo.getUserId();
        Integer tsCount = [SELECT count() FROM MBA_Timesheet__c WHERE MBA_Assignee__c = :currUserId];
        system.assertEquals(10, tsCount);
    }
    @isTest static void testGetTimeMethods(){
        agf__ADM_Work__c testWork = new agf__ADM_Work__c(agf__Assignee__c=UserInfo.getUserId(), 
                                                         agf__Status__c = 'New', agf__Subject__c='Subject here', 
                                                         agf__Details__c='Description here' );
        insert testWork;
        List<MBA_Timesheet__c> testTimeSheets = new List<MBA_Timesheet__c>();
        //today, this week, this month
        MBA_Timesheet__c todayTime = new MBA_Timesheet__c(Name='Test Timesheet today', Description__c = 'test description',
                                                             Hours_Manual__c = 1, Date_of_Work__c=Date.today(),
                                                             MBA_Work_Item_Lookup__c = testWork.Id, 
                                                             MBA_Assignee__c  = UserInfo.getUserId() );
        testTimeSheets.add(todayTime);        
        //yesterday=0
        //last week=0
        //last month
        Date todaysDate = Date.today();
        Date lastMonthDay = Date.newInstance(todaysDate.year(),todaysDate.month()-1, 1);
        MBA_Timesheet__c lastMonthTime = new MBA_Timesheet__c(Name='Test Timesheet last month', Description__c = 'test description', 
                                                             Hours_Manual__c = 2, Date_of_Work__c=lastMonthDay,
                                                             MBA_Work_Item_Lookup__c = testWork.Id,
                                                             MBA_Assignee__c  = UserInfo.getUserId() );
        testTimeSheets.add(lastMonthTime);
        
        test.startTest();
        insert testTimeSheets;
        List<MBA_Timesheet__c> todayTimeR = TimeSheetAppApexController.getTimeRecordsFromDb('Today');
        List<MBA_Timesheet__c> yesterdayTimeR = TimeSheetAppApexController.getTimeRecordsFromDb('Yesterday');
        List<MBA_Timesheet__c> thisWeekTimeR = TimeSheetAppApexController.getTimeRecordsFromDb('This Week');
        List<MBA_Timesheet__c> lastWeekTimeR = TimeSheetAppApexController.getTimeRecordsFromDb('Last Week');
        List<MBA_Timesheet__c> thisMonthTimeR = TimeSheetAppApexController.getTimeRecordsFromDb('This Month');
        List<MBA_Timesheet__c> lastMonthTimeR = TimeSheetAppApexController.getTimeRecordsFromDb('Last Month');
        List<double> timeTotals = TimeSheetAppApexController.getTimeTotalsFromDb();
        test.stopTest();
        
        system.debug('Time totals: ' + timeTotals);
        system.assertEquals('Test Timesheet today', todayTimeR[0].Name);
        system.assertEquals(0, yesterdayTimeR.size());
        system.assertEquals('Test Timesheet today', thisWeekTimeR[0].Name);
        system.assertEquals(0, lastWeekTimeR.size());
        system.assertEquals('Test Timesheet today', thisMonthTimeR[0].Name);
        system.assertEquals('Test Timesheet last month', lastMonthTimeR[0].Name);
        system.assertEquals(1, timeTotals[0]);
        system.assertEquals(2, timeTotals[5]);
    }
    @isTest static void testGetRecordToEditFromDb(){
        agf__ADM_Work__c testWork = new agf__ADM_Work__c(agf__Assignee__c=UserInfo.getUserId(), 
                                                         agf__Status__c = 'New', agf__Subject__c='Subject here', 
                                                         agf__Details__c='Description here');
        insert testWork;
        //today, this week, this month
        MBA_Timesheet__c todayTime = new MBA_Timesheet__c(Name='Test Timesheet today', Description__c = 'test description',
                                                             Hours_Manual__c = 1, Date_of_Work__c=Date.today(),
                                                             MBA_Work_Item_Lookup__c = testWork.Id, 
                                                             MBA_Assignee__c  = UserInfo.getUserId() );
        insert todayTime;
        String recordId = todayTime.Id;
        test.startTest();
        MBA_Timesheet__c returnedTS = TimeSheetAppApexController.getRecordToEditFromDb(recordId);
        test.stopTest();
            
        system.assertEquals(recordId, returnedTS.Id);
    }
    @isTest static void testSaveRecordToEditToDb() {
        agf__ADM_Work__c testWork = new agf__ADM_Work__c(agf__Assignee__c=UserInfo.getUserId(), 
                                                         agf__Status__c = 'New', agf__Subject__c='Subject here', 
                                                         agf__Details__c='Description here');
        insert testWork;
        //today, this week, this month
        MBA_Timesheet__c todayTime = new MBA_Timesheet__c(Name='Test Timesheet today', Description__c = 'test description',
                                                             Hours_Manual__c = 1, Date_of_Work__c=Date.today(),
                                                             MBA_Work_Item_Lookup__c = testWork.Id, 
                                                             MBA_Assignee__c  = UserInfo.getUserId() );
        insert todayTime;
        
        test.startTest();
        todayTime.Name = 'Test Timesheet today updated';
        TimeSheetAppApexController.saveRecordToEditToDB(todayTime);
        test.stopTest();
        
        Integer countTS = [SELECT count() FROM MBA_Timesheet__c WHERE Name = 'Test Timesheet today updated'];
        system.assertEquals(1, countTS);
    }
    @isTest static void testDeleteRecordFromDb (){
        agf__ADM_Work__c testWork = new agf__ADM_Work__c(agf__Assignee__c=UserInfo.getUserId(), 
                                                         agf__Status__c = 'New', agf__Subject__c='Subject here', 
                                                         agf__Details__c='Description here');
        insert testWork;
        //today, this week, this month
        MBA_Timesheet__c todayTime = new MBA_Timesheet__c(Name='Test Timesheet today', Description__c = 'test description', 
                                                             Hours_Manual__c = 1, Date_of_Work__c=Date.today(),
                                                             MBA_Work_Item_Lookup__c = testWork.Id,
                                                             MBA_Assignee__c  = UserInfo.getUserId() );
        insert todayTime;
        String recordId = todayTime.Id;
        test.startTest();
        TimeSheetAppApexController.deleteRecordFromDb(recordId);
        test.stopTest();
        MBA_Timesheet__c deletedRecord = [SELECT Id, IsDeleted FROM MBA_Timesheet__c 
                                          WHERE Id = :recordId AND IsDeleted = true ALL ROWS];
        Boolean isDeleted = deletedRecord.IsDeleted;
        
        system.assertEquals(true, isDeleted);
    }
}