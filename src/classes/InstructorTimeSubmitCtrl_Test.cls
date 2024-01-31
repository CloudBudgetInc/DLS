@isTest
private class InstructorTimeSubmitCtrl_Test{

    @testSetup static void setupMethod(){
        
        List<AcctSeed__Time_Card_Day__c>  tcd = TestClassUtil.createTestTimeCardDay();
        Test.startTest();
            List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment();
            List<Attendance__c> stuAtn = TestClassUtil.createTestAttendance();
        Test.stopTest();
    }
    
    // To cover getWeekRangeFilterValues() method
    private static testMethod void myTest1(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id, Name, PC_EE_ID__c FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        System.runAs(user){
        
            String employeeName = conList[0].Name+' - '+conList[0].PC_EE_ID__c;
            
            String res = InstructorTimeSubmitCtrl.getWeekRangeFilterValues();
            TimeCardDayCommunityDomain.InitialFilterValues initialFilter = (TimeCardDayCommunityDomain.InitialFilterValues)JSON.deserialize(res, TimeCardDayCommunityDomain.InitialFilterValues.class);
            System.assertEquals(employeeName, initialFilter.employeeName);
        }
    }
    
    // To cover getCompletedTCDRecords() method
    private static testMethod void myTest2(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id, Name, PC_EE_ID__c FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        Test.startTest();
      
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        update schList;
        System.debug('schList===='+schList);
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
       
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(5), Status__c = 'Submitted');
        insert day;
        
        System.runAs(user){
                    
            String res = InstructorTimeSubmitCtrl.getCompletedTCDRecords(String.valueOf(System.Today().addDays(5)), String.valueOf(System.Today().addDays(5)));
            TimeCardDayCommunityDomain.ReviewSubmitTCDDetails det = (TimeCardDayCommunityDomain.ReviewSubmitTCDDetails)JSON.deserialize(res, TimeCardDayCommunityDomain.ReviewSubmitTCDDetails.class);
            List<TimeCardDayCommunityDomain.DayEntries> entries = det.entries;
            
            if(entries.size() > 0){
                System.assertEquals(projects[0].Id, entries[0].projectId);
            }
            
        }
        
        Test.stopTest();
    }
    
    // To cover submitSelectedWeekTimeEntries() method
    private static testMethod void myTest3(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id, Name, PC_EE_ID__c FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        Test.startTest();
      
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c, Project_Task_Type__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        update schList;
        System.debug('schList===='+schList);
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
       
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(5), Status__c = 'Draft');
        insert day;
        
        List<TimeCardDayCommunityDomain.DayEntries> dayRecords = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        TimeCardDayCommunityDomain.DayEntries de = new TimeCardDayCommunityDomain.DayEntries();
        de.dayId = day.Id;
        de.status = 'Draft';
        de.studentApprovalStatus = 'Rejected';
        de.taskType = task[0].Project_Task_Type__c ;
        dayRecords.add(de);
        
        System.runAs(user){
                    
            String res = InstructorTimeSubmitCtrl.submitSelectedWeekTimeEntries(JSON.serialize(dayRecords));
            System.assertEquals('SUCCESS', res);
        }
        
        Test.stopTest();
    }
}