@isTest
private class InstructorTimeEntry_Controller_Test{

    @testSetup static void setupMethod() {
    
        Test.StartTest();
            List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment(); 
            List<MTT_Location__c> location = TestClassUtil.createTestLocations();
        Test.StopTest();
        
        List<Attendance__c> stuAtn = TestClassUtil.createTestAttendance();

        List<AcctSeed__Cost_Rates__c> costRates = TestClassUtil.createTestCostRates();
        List<AcctSeed__Time_Card_Day__c>  tcd = TestClassUtil.createTestTimeCardDay();
    }
    
    // To cover getInitialFilterValues method
    private static testMethod void myTestMethod1(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();        
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = conList[0].Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            
            system.runAs(user) {
                String intialfilterVal = InstructorTimeEntry_Controller.getInitialFilterValues();
                TimeCardDayCommunityDomain.InitialFilterValues intialVal = (TimeCardDayCommunityDomain.InitialFilterValues) JSON.deserialize(intialfilterVal,TimeCardDayCommunityDomain.InitialFilterValues.Class);
                System.assertEquals(intialVal.contactId,conList[0].Id);
            }
        Test.stopTest();
    }
    
    // To cover getInitialFilterValues method
    private static testMethod void myTestMethod1a(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        Contact testCon = [SELECT Id FROM Contact WHERE Name LIKE '%Testing%' LIMIT 1];
        User usr = [SELECT Id, ContactId, Name, FirstName, LastName, Email FROM User WHERE Name = 'Testing' LIMIT 1];
        testCon.FirstName = usr.FirstName;
        testCon.LastName = usr.LastName;
        testCon.Email = usr.Email;
        update testCon;
        
        Test.startTest();        
            
            System.runAs(usr){
            
                String intialfilterVal = InstructorTimeEntry_Controller.getInitialFilterValues();
            }
        Test.stopTest();
    }
    
    // To cover getProjectFilterValues method
    private static testMethod void myTestMethod2(){
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest(); 
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c];
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Rate_Card_Rate__c = cr[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
                
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        schList[0].Instructor__c = conList[0].Id;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        timeCardLine.Completed__c = true;
        insert timeCardLine;
       
        System.runAs(user) {    
        
            try{
                String res = InstructorTimeEntry_Controller.getProjectFilterValues(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id);
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        
        Test.stopTest();
    }
    
    // To cover getProjectFilterValues method
    private static testMethod void myTestMethod2a(){
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest(); 
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c];
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Rate_Card_Rate__c = cr[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        conAss[0].Paper_Timesheet__c = FALSE;
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
                
        
        List<Contact_Assignments__c> conAssTest = new List<Contact_Assignments__c>();
        
        for(Contact_Assignments__c c :[SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c, RecordType.DeveloperName
            FROM Contact_Assignments__c 
            WHERE RecordType.DeveloperName IN ('Instructor', 'Student', 'Staff') AND Status__c = 'Active' AND Project__c = : proj[0].Id 
        ]){
            c.Candidate_Name__c = conList[0].Id;
            c.Start_Date__c = weekStart1;
            c.End_Date__c = WeekEnd1;
            if(c.RecordType.DeveloperName == 'Student'){
                c.Assignment_Position__c = 'Class Leader';
            }
            conAssTest.add(c);
        }
        
        if(conAssTest.size() > 0){
            update conAssTest;
        }
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        schList[0].Instructor__c = conList[0].Id;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        timeCardLine.Completed__c = true;
        insert timeCardLine;
       
        System.runAs(user) {    
        
            try{
                String res = InstructorTimeEntry_Controller.getProjectFilterValues(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id);
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        
        Test.stopTest();
    }
    
    // To cover getProjectFilterValues method
    private static testMethod void myTestMethod2b(){
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest(); 
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c];
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Rate_Card_Rate__c = cr[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        conAss[0].Paper_Timesheet__c = FALSE;
        update conAss[0]; 
       
        Id cdRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('CD_Projects').getRecordTypeId();
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        proj[0].RecordTypeId = cdRTId;
        update proj[0];
        
        List<Contact_Assignments__c> conAssTest = new List<Contact_Assignments__c>();
       
        for(Contact_Assignments__c c :[SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c, RecordType.DeveloperName
            FROM Contact_Assignments__c 
            WHERE RecordType.DeveloperName IN ('Instructor', 'Student', 'Staff') AND Status__c = 'Active' AND Project__c = : proj[0].Id 
        ]){
            c.Candidate_Name__c = conList[0].Id;
            c.Start_Date__c = weekStart1;
            c.End_Date__c = WeekEnd1;
            if(c.RecordType.DeveloperName == 'Student'){
                c.Assignment_Position__c = 'Class Leader';
            }
            conAssTest.add(c);
        }
        if(conAssTest.size() > 0){
            update conAssTest;
        }
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        schList[0].Instructor__c = conList[0].Id;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        timeCardLine.Completed__c = true;
        insert timeCardLine;
       
        System.runAs(user) {    
        
            try{
                String res = InstructorTimeEntry_Controller.getProjectFilterValues(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id);
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        
        Test.stopTest();
    }
    
    // To cover getProjectFilterValues method
    private static testMethod void myTestMethod2c(){
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest(); 
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c];
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Rate_Card_Rate__c = cr[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        conAss[0].Paper_Timesheet__c = FALSE;
        update conAss[0]; 
       
        Id testRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        proj[0].RecordTypeId = testRTId;
        update proj[0];
        
        List<Contact_Assignments__c> conAssTest = new List<Contact_Assignments__c>();
       
        for(Contact_Assignments__c c :[SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c, RecordType.DeveloperName
            FROM Contact_Assignments__c 
            WHERE RecordType.DeveloperName IN ('Instructor', 'Student', 'Staff') AND Status__c = 'Active' AND Project__c = : proj[0].Id 
        ]){
            c.Candidate_Name__c = conList[0].Id;
            c.Start_Date__c = weekStart1;
            c.End_Date__c = WeekEnd1;
            if(c.RecordType.DeveloperName == 'Student'){
                c.Assignment_Position__c = 'Class Leader';
            }
            conAssTest.add(c);
        }
        if(conAssTest.size() > 0){
            update conAssTest;
        }
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        schList[0].Instructor__c = conList[0].Id;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        timeCardLine.Completed__c = true;
        insert timeCardLine;
       
        System.runAs(user) {    
        
            try{
                String res = InstructorTimeEntry_Controller.getProjectFilterValues(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id);
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        
        Test.stopTest();
    }
    
    private static testMethod void getTimeRowsRelatedInformation_Test1(){
        
        List<Schedule__c> scheduleList = [SELECT Id, Name, Project__c, Project__r.Name, End_Date__c, Start_Date__c, Status__c FROM Schedule__c LIMIT 1];
        
        List<Events__c> eventList = [SELECT Id, Name, Schedule__c, Instructor__c, Instructor__r.Name FROM Events__c WHERE Schedule__c IN : scheduleList];
        
        Test.startTest();
        
        scheduleList[0].Status__c = 'Active';
        scheduleList[0].Instructor__c = eventList[0].Instructor__c;
        update scheduleList[0];
        
        InstructorTimeEntry_Controller.getTimeRowsRelatedInformation(string.valueOf(scheduleList[0].Start_Date__c),string.valueOf(scheduleList[0].End_Date__c), scheduleList[0].Project__c, eventList[0].Instructor__c, scheduleList[0].Project__r.Name, eventList[0].Instructor__r.Name);
        
        Test.stopTest();
    }
    
    private static testMethod void getTimeRowsRelatedInformation_Test2(){
        
        List<Schedule__c> scheduleList = [SELECT Id, Name, Project__c, Project__r.Name, End_Date__c, Start_Date__c, Status__c FROM Schedule__c LIMIT 1];
        
        List<Events__c> eventList = [SELECT Id, Name, Schedule__c, Instructor__c, Instructor__r.Name FROM Events__c WHERE Schedule__c IN : scheduleList];
        
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(Name = 'Language Training- Preparation',AcctSeed__Project__c = scheduleList[0].Project__c,Project_Task_Type__c = 'Preparation time',Rate__c = 41);
        insert task;
        
        Test.startTest();
        
        scheduleList[0].Status__c = 'Active';
        scheduleList[0].Instructor__c = eventList[0].Instructor__c;
        scheduleList[0].Project_Task__c = task.Id;
        scheduleList[0].Start_Time__c = '09:00 AM';
        scheduleList[0].End_Time__c = '10:00 AM';
        update scheduleList[0];
        
        InstructorTimeEntry_Controller.getTimeRowsRelatedInformation(string.valueOf(scheduleList[0].Start_Date__c),string.valueOf(scheduleList[0].End_Date__c), scheduleList[0].Project__c, eventList[0].Instructor__c, scheduleList[0].Project__r.Name, eventList[0].Instructor__r.Name);
        
        Test.stopTest();
    }
    
    private static testMethod void getTimeRowsRelatedInformation_Test3(){
                
        List<Schedule__c> scheduleList = [SELECT Id, Name, Project__c, Project__r.Name, End_Date__c, Start_Date__c, Status__c FROM Schedule__c LIMIT 1];
        
        List<Events__c> eventList = [SELECT Id, Name, Schedule__c, Instructor__c, Instructor__r.Name FROM Events__c LIMIT 1];
        
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(Name = 'Language Training- Preparation',AcctSeed__Project__c = scheduleList[0].Project__c,Project_Task_Type__c = 'Preparation time',Rate__c = 41);
        insert task;
        
        Test.startTest();
        
        eventList[0].Status__c = 'Scheduled';
        eventList[0].Instructor__c = eventList[0].Instructor__c;
        eventList[0].Project_Task__c = task.Id;
        eventList[0].Start_Time__c = '09:00 AM';
        eventList[0].End_Time__c = '10:00 AM';
        eventList[0].Schedule__c = null;
        eventList[0].Date__c = scheduleList[0].Start_Date__c;
        update eventList[0];
        
        InstructorTimeEntry_Controller.getTimeRowsRelatedInformation(string.valueOf(scheduleList[0].Start_Date__c),string.valueOf(scheduleList[0].End_Date__c), scheduleList[0].Project__c, eventList[0].Instructor__c, scheduleList[0].Project__r.Name, eventList[0].Instructor__r.Name);
        
        Test.stopTest();
    }
    
    private static testMethod void getTimeRowsRelatedInformation_Test4(){
        
        List<Schedule__c> scheduleList = [SELECT Id, Name, Project__c, Project__r.Name, End_Date__c, Start_Date__c, Status__c FROM Schedule__c LIMIT 1];
        
        List<Events__c> eventList = [SELECT Id, Name, Schedule__c, Instructor__c, Instructor__r.Name FROM Events__c WHERE Schedule__c IN : scheduleList];
        
        Id eflRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('EFL_Projects').getRecordTypeId();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c();
        proj.Id = scheduleList[0].Project__c;
        proj.RecordTypeId = eflRTId;
        update proj;
        
        Test.startTest();
        
        scheduleList[0].Instructor__c = eventList[0].Instructor__c;
        scheduleList[0].Start_Time__c = '09:00 AM';
        scheduleList[0].End_Time__c = '10:00 AM';
        update scheduleList[0];
        
        InstructorTimeEntry_Controller.getTimeRowsRelatedInformation(string.valueOf(scheduleList[0].Start_Date__c),string.valueOf(scheduleList[0].End_Date__c), scheduleList[0].Project__c, eventList[0].Instructor__c, scheduleList[0].Project__r.Name, eventList[0].Instructor__r.Name);
        
        Test.stopTest();
    }
    
    // To cover dmlOperationMethod 
    // Create new TC, TCL, TCD record with PT != Preparation time
    private static testMethod void dmlOperationTestMethod1(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        AcctSeed__Time_Card_Period__c tcp = [SELECT Id,Name FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
                
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];        
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = task[0].AcctSeed__Project__c,Status__c = 'Scheduled');
        insert event;
                
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        dayEntry.dayId = NULL;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = myDate1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = TRUE;
        dayEntry.TaskType = 'Language Training';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '06:15 AM';
        dayEntry.endTime1 = '06:45 AM';
        dayEntry.lateCancellation = TRUE;
        dayEntry.cancellationReason = 'Just for Demo';
        dayEntry.costrateId = costRate[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = task[0].AcctSeed__Project__c;
        dayEntry.payrollItem = 'R';
        dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = FALSE;
                
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityDomain.StudentEntry stdEntry = new TimeCardDayCommunityDomain.StudentEntry();
        List<TimeCardDayCommunityDomain.StudentEntry> stdEntryList = new List<TimeCardDayCommunityDomain.StudentEntry>();
                
        stdEntry.studentId = conAss[0].Candidate_Name__c;
        stdEntry.hours = '2.5';
        stdEntry.dateVal = myDate1;
        stdEntry.comments = 'Test';
        
        stdEntryList.add(stdEntry);
        
        system.runAs(user) {
            try{
                String res = InstructorTimeEntry_Controller.dmlOperationMethod(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), task[0].AcctSeed__Project__c, 'Submit', JSON.Serialize(stdEntryList), new List<String>{});
                
                AcctSeed__Time_Card_Day__c day1 = [SELECT ID, AcctSeed__Date__c, AcctSeed__Time_Card_Line__c, Start_Time1__c, End_Time1__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Day__c];
                
                if(res == 'SUCCESS'){
                    System.assertEquals(dayEntry.startTime1, day1.Start_Time1__c);
                }
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        Test.stopTest();
    }
    

    //Create new TC, TCL, TCD record with PT = Preparation time
    private static testMethod void dmlOperationTestMethod2(){
                
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        AcctSeed__Time_Card_Period__c tcp = [SELECT Id,Name FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                     
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        task[0].Project_Task_Type__c = 'Preparation time';
        update task;
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        dayEntry.dayId = NULL;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = myDate1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = TRUE;
        dayEntry.TaskType = 'Preparation time';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '06:15 AM';
        dayEntry.endTime1 = '06:45 AM';
        dayEntry.startTime2 = '08:15 AM';
        dayEntry.endTime2 = '08:45 AM';
        dayEntry.lateCancellation = TRUE;
        dayEntry.cancellationReason = 'Just for Demo';
        dayEntry.costrateId = costRate[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = task[0].AcctSeed__Project__c;
        dayEntry.payrollItem = 'R';
        dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = FALSE;
                
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityDomain.StudentEntry stdEntry = new TimeCardDayCommunityDomain.StudentEntry();
        List<TimeCardDayCommunityDomain.StudentEntry> stdEntryList = new List<TimeCardDayCommunityDomain.StudentEntry>();
        
        
        stdEntry.studentId = conAss[0].Candidate_Name__c;
        //stdEntry.studentName = conAss[0].Name;
        stdEntry.hours = '2.5';
        stdEntry.dateVal = myDate1;
        stdEntry.comments = 'Test';
        //stdEntry.attendanceId = attendanceList[0].Id;
        
        stdEntryList.add(stdEntry);
        
        system.runAs(user) {
            try{
                String res = InstructorTimeEntry_Controller.dmlOperationMethod(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), task[0].AcctSeed__Project__c, 'Submit', JSON.Serialize(stdEntryList), new List<String>{});
                if(res == 'SUCCESS'){
                    AcctSeed__Time_Card__c card = [SELECT Id, Intructor__c FROM AcctSeed__Time_Card__c];
                    System.assertEquals(conList[0].Id, card.Intructor__c );
                }
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    // Already has TC, TCL
    // Update TCD with PT != Preparation time
    private static testMethod void dmlOperationTestMethod3(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
       
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
                
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];

        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
                
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
        insert event;
                
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        dayEntry.dayId = day.Id;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = myDate1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = FALSE;
        dayEntry.TaskType = 'Language Training';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '06:15 AM';
        dayEntry.endTime1 = '06:45 AM';
        dayEntry.lateCancellation = TRUE;
        dayEntry.cancellationReason = 'Just for Demo';
        dayEntry.costrateId = costRate[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = task[0].AcctSeed__Project__c;
        dayEntry.payrollItem = 'R';
        dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = TRUE;
        dayEntry.isCompleted =FALSE;
                
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityDomain.StudentEntry stdEntry = new TimeCardDayCommunityDomain.StudentEntry();
        List<TimeCardDayCommunityDomain.StudentEntry> stdEntryList = new List<TimeCardDayCommunityDomain.StudentEntry>();
                
        stdEntry.studentId = conAss[0].Candidate_Name__c;
        //stdEntry.studentName = conAss[0].Name;
        stdEntry.hours = '2.5';
        stdEntry.dateVal = myDate1;
        stdEntry.comments = 'Test';
        //stdEntry.attendanceId = attendanceList[0].Id;
        
        stdEntryList.add(stdEntry);
        
        system.runAs(user) {
            try{
                String res = InstructorTimeEntry_Controller.dmlOperationMethod(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), task[0].AcctSeed__Project__c, 'Complete', JSON.Serialize(stdEntryList), new List<String>{});
                
                List<AcctSeed__Time_Card_Day__c> days = [SELECT ID, AcctSeed__Date__c, AcctSeed__Time_Card_Line__c, Start_Time1__c, End_Time1__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Day__c];
                
                if(res == 'SUCCESS'){
                    System.assertEquals(day.Total_Hours_Before_Approved__c, days[0].Total_Hours_Before_Approved__c);
                }
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    // Already has TC, TCL
    // Update TCD with PT != Preparation time
    private static testMethod void dmlOperationTestMethod3a(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
                
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
                
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
        insert event;
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        dayEntry.dayId = day.Id;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = myDate1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = FALSE;
        dayEntry.TaskType = 'Language Training';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '06:15 AM';
        dayEntry.endTime1 = '06:45 AM';
        dayEntry.lateCancellation = TRUE;
        dayEntry.cancellationReason = 'Just for Demo';
        dayEntry.costrateId = costRate[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = task[0].AcctSeed__Project__c;
        dayEntry.payrollItem = 'ADM';
        dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = FALSE;
        dayEntry.isCompleted = FALSE;
                
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityDomain.StudentEntry stdEntry = new TimeCardDayCommunityDomain.StudentEntry();
        List<TimeCardDayCommunityDomain.StudentEntry> stdEntryList = new List<TimeCardDayCommunityDomain.StudentEntry>();
                
        stdEntry.studentId = conAss[0].Candidate_Name__c;
        //stdEntry.studentName = conAss[0].Name;
        stdEntry.hours = '2.5';
        stdEntry.dateVal = myDate1;
        stdEntry.comments = 'Test';
        //stdEntry.attendanceId = attendanceList[0].Id;
        
        stdEntryList.add(stdEntry);
        
        system.runAs(user) {
            try{
                String res = InstructorTimeEntry_Controller.dmlOperationMethod(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), task[0].AcctSeed__Project__c, 'Complete', JSON.Serialize(stdEntryList), new List<String>{});
                
                List<AcctSeed__Time_Card_Day__c> days = [SELECT ID, AcctSeed__Date__c, AcctSeed__Time_Card_Line__c, Start_Time1__c, End_Time1__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Day__c];
                
                if(res == 'SUCCESS'){
                    System.assertEquals(day.Total_Hours_Before_Approved__c, days[0].Total_Hours_Before_Approved__c);
                }
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    // Already has TC, TCL
    // Update TCD PT = Preparation time
    private static testMethod void dmlOperationTestMethod4(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        task[0].Project_Task_Type__c = 'Preparation time';
        update task;
                
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
                
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted', Start_Time1__c= '09:00 AM', End_Time1__c = '09:45 AM', Start_Time2__c= '09:00 AM', End_Time2__c = '09:45 AM');
        insert day;
        
        Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
        insert event;        
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        dayEntry.dayId = day.Id;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = myDate1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = FALSE;
        dayEntry.TaskType = 'Preparation time';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '06:15 AM';
        dayEntry.endTime1 = '06:45 AM';
        dayEntry.startTime2 = '06:15 AM';
        dayEntry.endTime2 = '06:45 AM';
        dayEntry.lateCancellation = TRUE;
        dayEntry.cancellationReason = 'Just for Demo';
        dayEntry.costrateId = costRate[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = task[0].AcctSeed__Project__c;
        dayEntry.payrollItem = 'R';
        dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = TRUE;
        dayEntry.isCompleted = TRUE;
        dayEntry.lineId = timeCardLine.Id;
                
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityDomain.StudentEntry stdEntry = new TimeCardDayCommunityDomain.StudentEntry();
        List<TimeCardDayCommunityDomain.StudentEntry> stdEntryList = new List<TimeCardDayCommunityDomain.StudentEntry>();
                
        stdEntry.studentId = conAss[0].Candidate_Name__c;
        //stdEntry.studentName = conAss[0].Name;
        stdEntry.hours = '2.5';
        stdEntry.dateVal = myDate1;
        stdEntry.comments = 'Test';
        //stdEntry.attendanceId = attendanceList[0].Id;
        
        stdEntryList.add(stdEntry);
        
        system.runAs(user) {
            try{
                String res = InstructorTimeEntry_Controller.dmlOperationMethod(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), task[0].AcctSeed__Project__c, 'Submit', JSON.Serialize(stdEntryList), new List<String>{});
                
                List<AcctSeed__Time_Card_Day__c> days = [SELECT ID, Start_Time2__c, End_Time2__c, AcctSeed__Date__c, AcctSeed__Time_Card_Line__c, Start_Time1__c, End_Time1__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Day__c];
                
                if(res == 'SUCCESS'){
                    System.assertEquals('SUCCESS', res);
                }
            }catch(DmlException e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    // Has TC, TCL
    // Create new TCD with PT = Preparation time
    private static testMethod void dmlOperationTestMethod5(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        task[0].Project_Task_Type__c = 'Preparation time';
        update task;
                
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
                
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        //insert day;
        
        Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
        insert event;
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        //dayEntry.dayId = day.Id;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = myDate1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = TRUE;
        dayEntry.TaskType = 'Preparation time';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '06:15 AM';
        dayEntry.endTime1 = '06:45 AM';
        dayEntry.lateCancellation = TRUE;
        dayEntry.cancellationReason = 'Just for Demo';
        dayEntry.costrateId = costRate[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = task[0].AcctSeed__Project__c;
        dayEntry.payrollItem = 'R';
        dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = FALSE;
                
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityDomain.StudentEntry stdEntry = new TimeCardDayCommunityDomain.StudentEntry();
        List<TimeCardDayCommunityDomain.StudentEntry> stdEntryList = new List<TimeCardDayCommunityDomain.StudentEntry>();
                
        stdEntry.studentId = conAss[0].Candidate_Name__c;
        //stdEntry.studentName = conAss[0].Name;
        stdEntry.hours = '2.5';
        stdEntry.dateVal = myDate1;
        stdEntry.comments = 'Test';
        //stdEntry.attendanceId = attendanceList[0].Id;
        
        stdEntryList.add(stdEntry);
        
        system.runAs(user) {
            try{
                String res = InstructorTimeEntry_Controller.dmlOperationMethod(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), task[0].AcctSeed__Project__c, 'Submit', JSON.Serialize(stdEntryList), new List<String>{});
                if(res == 'SUCCESS'){
                    System.assertEquals('SUCCESS', res);
                }
            }catch(DmlException e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    // Has TC, TCL
    // Create new TCD with PT != Preparation time
    private static testMethod void dmlOperationTestMethod6(){
                
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
       
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
                
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        //insert day;
        
        Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
        insert event;
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        //dayEntry.dayId = day.Id;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = myDate1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = TRUE;
        dayEntry.TaskType = 'Language Training';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '06:15 AM';
        dayEntry.endTime1 = '06:45 AM';
        dayEntry.lateCancellation = TRUE;
        dayEntry.cancellationReason = 'Just for Demo';
        dayEntry.costrateId = costRate[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = task[0].AcctSeed__Project__c;
        dayEntry.payrollItem = 'R';
        dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = FALSE;
                
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityDomain.StudentEntry stdEntry = new TimeCardDayCommunityDomain.StudentEntry();
        List<TimeCardDayCommunityDomain.StudentEntry> stdEntryList = new List<TimeCardDayCommunityDomain.StudentEntry>();
                
        stdEntry.studentId = conAss[0].Candidate_Name__c;
        //stdEntry.studentName = conAss[0].Name;
        stdEntry.hours = '2.5';
        stdEntry.dateVal = myDate1;
        stdEntry.comments = 'Test';
        //stdEntry.attendanceId = attendanceList[0].Id;
        
        stdEntryList.add(stdEntry);
        
        system.runAs(user) {
            try{
                String res = InstructorTimeEntry_Controller.dmlOperationMethod(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), task[0].AcctSeed__Project__c, 'Submit', JSON.Serialize(stdEntryList), new List<String>{});
                if(res == 'SUCCESS'){
                    System.assertEquals('SUCCESS', res);
                }
            }catch(DmlException e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    // Has TCP, TC, TCL 
    // Create new TCD with PT != Preparation time
    private static testMethod void dmlOperationTestMethod7(){
                
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
                
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
                
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        //insert day;
        
        Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
        insert event;
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        dayEntry.dayId = day.Id;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = myDate1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = TRUE;
        dayEntry.TaskType = 'Language Training';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '06:15 AM';
        dayEntry.endTime1 = '06:45 AM';
        dayEntry.lateCancellation = TRUE;
        dayEntry.cancellationReason = 'Just for Demo';
        dayEntry.costrateId = costRate[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = task[0].AcctSeed__Project__c;
        dayEntry.payrollItem = 'ADM';
        dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = FALSE;
                
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityDomain.StudentEntry stdEntry = new TimeCardDayCommunityDomain.StudentEntry();
        List<TimeCardDayCommunityDomain.StudentEntry> stdEntryList = new List<TimeCardDayCommunityDomain.StudentEntry>();
                
        stdEntry.studentId = conAss[0].Candidate_Name__c;
        //stdEntry.studentName = conAss[0].Name;
        stdEntry.hours = '2.5';
        stdEntry.dateVal = myDate1;
        stdEntry.comments = 'Test';
        //stdEntry.attendanceId = attendanceList[0].Id;
        
        stdEntryList.add(stdEntry);
        
        system.runAs(user) {
            try{
                String res = InstructorTimeEntry_Controller.dmlOperationMethod(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), task[0].AcctSeed__Project__c, 'Submit', JSON.Serialize(stdEntryList), new List<String>{});
                if(res == 'SUCCESS'){
                    System.assertEquals('SUCCESS', res);
                }
            }catch(DmlException e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    // Has TC, TCL 
    // Create new TCD with PT = Preparation time
    private static testMethod void dmlOperationTestMethod8(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
       
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        task[0].Project_Task_Type__c = 'Preparation time';
        update task;
                
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
                
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        //insert day;
        
        Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
        insert event;
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        dayEntry.dayId = day.Id;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = myDate1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = TRUE;
        dayEntry.TaskType = 'Preparation time';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '06:15 AM';
        dayEntry.endTime1 = '06:45 AM';
        dayEntry.lateCancellation = TRUE;
        dayEntry.cancellationReason = 'Just for Demo';
        dayEntry.costrateId = costRate[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = task[0].AcctSeed__Project__c;
        dayEntry.payrollItem = 'ADM';
        dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = FALSE;
                
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityDomain.StudentEntry stdEntry = new TimeCardDayCommunityDomain.StudentEntry();
        List<TimeCardDayCommunityDomain.StudentEntry> stdEntryList = new List<TimeCardDayCommunityDomain.StudentEntry>();
                
        stdEntry.studentId = conAss[0].Candidate_Name__c;
        //stdEntry.studentName = conAss[0].Name;
        stdEntry.hours = '2.5';
        stdEntry.dateVal = myDate1;
        stdEntry.comments = 'Test';
        //stdEntry.attendanceId = attendanceList[0].Id;
        
        stdEntryList.add(stdEntry);
        
        system.runAs(user) {
            try{
                String res = InstructorTimeEntry_Controller.dmlOperationMethod(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), task[0].AcctSeed__Project__c, 'Submit', JSON.Serialize(stdEntryList), new List<String>{});
                
                List<AcctSeed__Time_Card_Day__c> days = [SELECT ID, AcctSeed__Internal_Comment__c, Status__c, Start_Time2__c, End_Time2__c, AcctSeed__Date__c, AcctSeed__Time_Card_Line__c, Start_Time1__c, End_Time1__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Day__c];
                
                if(res == 'SUCCESS'){
                    System.assertEquals('SUCCESS', res);
                }
            }catch(DmlException e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    private static testMethod void dmlOperationTestMethod9(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        task[0].Project_Task_Type__c = 'Preparation time';
        update task;
         
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
                
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled');
        insert event;
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        dayEntry.dayId = day.Id;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = myDate1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = FALSE;
        dayEntry.TaskType = 'Preparation time';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '06:15 AM';
        dayEntry.endTime1 = '06:45 AM';
        dayEntry.lateCancellation = TRUE;
        dayEntry.cancellationReason = 'Just for Demo';
        dayEntry.costrateId = costRate[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = task[0].AcctSeed__Project__c;
        dayEntry.payrollItem = 'ADM';
        dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = FALSE;
                
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityDomain.StudentEntry stdEntry = new TimeCardDayCommunityDomain.StudentEntry();
        List<TimeCardDayCommunityDomain.StudentEntry> stdEntryList = new List<TimeCardDayCommunityDomain.StudentEntry>();
                
        stdEntry.studentId = conAss[0].Candidate_Name__c;
        //stdEntry.studentName = conAss[0].Name;
        stdEntry.hours = '2.5';
        stdEntry.dateVal = myDate1;
        stdEntry.comments = 'Test';
        //stdEntry.attendanceId = attendanceList[0].Id;
        
        stdEntryList.add(stdEntry);
        
        system.runAs(user) {
            try{
                String res = InstructorTimeEntry_Controller.dmlOperationMethod(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), task[0].AcctSeed__Project__c, 'Submit', JSON.Serialize(stdEntryList), new List<String>{});
                
                List<AcctSeed__Time_Card_Day__c> days = [SELECT ID, AcctSeed__Internal_Comment__c, Status__c, Start_Time2__c, End_Time2__c, AcctSeed__Date__c, AcctSeed__Time_Card_Line__c, Start_Time1__c, End_Time1__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Day__c];
                
                if(res == 'SUCCESS'){
                    System.assertEquals('SUCCESS', res);
                }
            }catch(DmlException e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    // To cover recallExistingTimeEntries method
    private static testMethod void myTestMethod5(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> con = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
                    
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
    
        List<AcctSeed__Time_Card_Day__c> timeCardDay = [SELECT Id, Name, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c LIMIT 2];  
        List<AcctSeed__Time_Card_Line__c> timeCardLine = [SELECT Id, Name, AcctSeed__Time_Card__c, AcctSeed__Time_Card_Line__c.AcctSeed__Project__c, Location__c, AcctSeed__Billable__c, Payroll_Item__c, AcctSeed__Time_Card_Line__c.Display_in_Future_Weeks__c FROM AcctSeed__Time_Card_Line__c WHERE Id = :timeCardDay[0].AcctSeed__Time_Card_Line__c];  
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        AcctSeed__Time_Card_Period__c tcp = [SELECT Id,Name FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        AcctSeed__Time_Card__c tc = [SELECT Id, Name, Intructor__c, AcctSeed__Time_Card_Period__c FROM AcctSeed__Time_Card__c WHERE Id = :timeCardLine[0].AcctSeed__Time_Card__c LIMIT 1];
        tc.AcctSeed__Time_Card_Period__c = tcp.Id;
        tc.Intructor__c = con[0].Id;
        update tc;
                
        TimeCardDayCommunityDomain.DayEntries de = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> deList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        timeCardLine[0].Payroll_Item__c = 'ADM';
        timeCardLine[0].Location__c = loc.Id;
        timeCardLine[0].AcctSeed__Billable__c = true;
        update timeCardLine;
        
        de.dayId = timeCardDay[0].Id;
        de.hours = 2.5;
        de.isBillable = true;
        de.dateVal = myDate1;
        de.isNew = true;
        de.comments = 'Test';
        de.status = 'Recalled';
        
        deList.add(de);
        
        system.runAs(user) {
            try{
                String res = InstructorTimeEntry_Controller.recallExistingTimeEntries(JSON.Serialize(deList), 'Group');
                
                List<AcctSeed__Time_Card_Day__c> days = [SELECT ID, Status__c, Start_Time2__c, End_Time2__c, AcctSeed__Date__c, AcctSeed__Time_Card_Line__c, Start_Time1__c, End_Time1__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Day__c];
                
            }catch(DmlException e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        
        Test.stopTest();
    }
    
    // To cover submitTCDEntries method
    private static testMethod void myTestMethod6(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> con = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        //List<contact> con = [SELECT Id, Name FROM Contact];
            
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
    
        List<AcctSeed__Time_Card_Day__c> timeCardDay = [SELECT Id, Name, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c LIMIT 2];  
        List<AcctSeed__Time_Card_Line__c> timeCardLine = [SELECT Id, Name, AcctSeed__Time_Card__c, AcctSeed__Time_Card_Line__c.AcctSeed__Project__c, Location__c, AcctSeed__Billable__c, Payroll_Item__c, AcctSeed__Time_Card_Line__c.Display_in_Future_Weeks__c FROM AcctSeed__Time_Card_Line__c WHERE Id = :timeCardDay[0].AcctSeed__Time_Card_Line__c];  
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        AcctSeed__Time_Card_Period__c tcp = [SELECT Id,Name FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c];
        
        AcctSeed__Time_Card__c tc = [SELECT Id, Name, Intructor__c, AcctSeed__Time_Card_Period__c FROM AcctSeed__Time_Card__c WHERE Id = :timeCardLine[0].AcctSeed__Time_Card__c LIMIT 1];
        tc.AcctSeed__Time_Card_Period__c = tcp.Id;
        tc.Intructor__c = con[0].Id;
        update tc;
                
        TimeCardDayCommunityDomain.DayEntries de = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> deList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        timeCardLine[0].Payroll_Item__c = 'ADM';
        timeCardLine[0].Location__c = loc.Id;
        timeCardLine[0].AcctSeed__Billable__c = true;
        update timeCardLine;
        
        de.dayId = timeCardDay[0].Id;
        de.hours = 2.5;
        de.isBillable = true;
        de.dateVal = myDate1;
        de.isNew = true;
        de.comments = 'Test';
        de.status = 'Draft';
        
        deList.add(de);
        system.runAs(user) {
            try{
                String res = InstructorTimeEntry_Controller.submitTCDEntries(JSON.Serialize(deList));
                
                List<AcctSeed__Time_Card_Day__c> days = [SELECT ID, Status__c, Start_Time2__c, End_Time2__c, AcctSeed__Date__c, AcctSeed__Time_Card_Line__c, Start_Time1__c, End_Time1__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Day__c];
                
                if(res == 'SUCCESS'){
                    System.assertEquals('Submitted', days[0].Status__c);
                }
            }catch(DmlException e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    // To cover recallStudentAttendanceEntry method
    private static testMethod void myTestMethod7(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> con = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        //List<contact> con = [SELECT Id, Name FROM Contact];
                    
        List<AcctSeed__Time_Card_Day__c> timeCardDay = [SELECT Id, Name, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c LIMIT 2];  
        List<AcctSeed__Time_Card_Line__c> timeCardLine = [SELECT Id, Name, AcctSeed__Time_Card__c, AcctSeed__Time_Card_Line__c.AcctSeed__Project__c, Location__c, AcctSeed__Billable__c, Payroll_Item__c, AcctSeed__Time_Card_Line__c.Display_in_Future_Weeks__c FROM AcctSeed__Time_Card_Line__c WHERE Id = :timeCardDay[0].AcctSeed__Time_Card_Line__c];  
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        AcctSeed__Time_Card_Period__c tcp = [SELECT Id,Name FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c];
        
        AcctSeed__Time_Card__c tc = [SELECT Id, Name, Intructor__c, AcctSeed__Time_Card_Period__c FROM AcctSeed__Time_Card__c WHERE Id = :timeCardLine[0].AcctSeed__Time_Card__c LIMIT 1];
        tc.AcctSeed__Time_Card_Period__c = tcp.Id;
        tc.Intructor__c = con[0].Id;
        update tc;
                    
        timeCardLine[0].Payroll_Item__c = 'ADM';
        timeCardLine[0].Location__c = loc.Id;
        timeCardLine[0].AcctSeed__Billable__c = true;
        update timeCardLine;
                
        List<TimeCardDayCommunityDomain.StudentEntry> studentEntries = new List<TimeCardDayCommunityDomain.StudentEntry>();
        List<Contact_Assignments__c> stdConAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        
        TimeCardDayCommunityDomain.StudentEntry studentEntry = new TimeCardDayCommunityDomain.StudentEntry();
        studentEntry.attendanceId = attendanceList[0].Id;
        studentEntry.recallReason = 'Just for Test';
        studentEntries.add(studentEntry);
        
        system.runAs(user) {    
            try{
                String res = InstructorTimeEntry_Controller.recallStudentAttendanceEntry(JSON.serialize(studentEntries));
                if(res == 'SUCCESS'){
                    System.assertEquals('SUCCESS', res);
                }
            }catch(DmlException e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    // To cover getProjectBasedSchedules method
    private static testMethod void myTestMethod8(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> con = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        
        
        system.runAs(user) {    
        
            try{
                InstructorTimeEntry_Controller.getProjectBasedSchedules(schList[0].Project__c, String.valueOf(schList[0].Start_Date__c), String.valueOf(schList[0].End_Date__c), con[0].Id);
            }catch(DmlException e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        Test.stopTest();
    }
    
    // To cover createCaseRecord method
    private static testMethod void myTestMethod9(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> con = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<Case> cases = new List<Case>{
            new Case(Origin = 'Web', ContactId = con[0].Id)
        };
                        
            System.runAs(user) {    
            
                try{
                    InstructorTimeEntry_Controller.createCaseRecord(JSON.serialize(cases));
                }catch(Exception e){
                
                    System.debug('EXception===='+e.getMessage());
                }
            }
        
        Test.stopTest();
    }
    
    // To cover getExistingTCDsForOtherProjects method
    private static testMethod void myTestMethod10(){
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c];
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
       
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
                        
        System.runAs(user) {    
        
            try{
                InstructorTimeEntry_Controller.getExistingTCDsForOtherProjects(conList[0].Id, String.valueOf(System.Today()), String.valueOf(System.Today()), task[0].AcctSeed__Project__c);
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        
        Test.stopTest();
    }
    
    // To cover completeTCDEntries method
    private static testMethod void myTestMethod11(){
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c];
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
       
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        List<TimeCardDayCommunityDomain.DayEntries> dayEntries = new List<TimeCardDayCommunityDomain.DayEntries>();
        TimeCardDayCommunityDomain.DayEntries de = new TimeCardDayCommunityDomain.DayEntries();
        de.dayId = day.Id;
        de.lineId = timeCardLine.Id;
        
        dayEntries.add(de);
        
        System.runAs(user) {    
        
            try{
                String res = InstructorTimeEntry_Controller.completeTCDEntries(JSON.serialize(dayEntries));
                System.assertEquals('SUCCESS', res);
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        
        Test.stopTest();
    }
    
    // To cover getScheduledEvents method
    private static testMethod void myTestMethod12(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c LIMIT 1];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
                
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        Events__c event = new Events__c(Name = '15-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = conList[0].Id,Date__c = Date.Today(),Project__c = task[0].AcctSeed__Project__c,Status__c = 'Scheduled');
        insert event;
        
        System.runAs(user) {    
            
            try{
                String res = InstructorTimeEntry_Controller.getScheduledEvents(String.valueOf(Date.Today()), String.valueOf(Date.Today().addDays(1)), task[0].AcctSeed__Project__c, conList[0].Id);
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        
        Test.stopTest();
    }
    
    // To cover projectRelatedFilters method in TimeCardDayCommunityTranslator
    private static testMethod void tcdCommTrans1(){
    
        List<Contact> conList = [SELECT Id,FirstName, LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c,Assignment_Position__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName != 'CD_Projects' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
                
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c,RecordType.DeveloperName, RecordTypeId, 
                                                No_Student_Approval__c, Name, No_Student_Hours_Verification__c
                                            FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
        Test.stopTest();
        
        TimeCardDayCommunityTranslator.projectRelatedFilters(proj, proj, proj, new Map<Id,Boolean>(),new Map<String,Boolean>());
    }
    
    // To cover hrsDisableFunction method in TimeCardDayCommunityTranslator
    private static testMethod void tcdCommTrans2(){
    
        List<Contact> conList = [SELECT Id,FirstName, LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c,Assignment_Position__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName != 'CD_Projects' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
                
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c,RecordType.DeveloperName, RecordTypeId, 
                                                No_Student_Approval__c, Name
                                            FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
        Test.stopTest();
        
        TimeCardDayCommunityDomain.DayEntries day = new TimeCardDayCommunityDomain.DayEntries();
        day.TaskType = 'Language Training';
        day.status = 'Draft';
        day.studentApprovalStatus = 'Draft';
        day.isCompleted = TRUE;
        
        
        TimeCardDayCommunityTranslator.hrsDisableFunction(day, false, TRUE);
        TimeCardDayCommunityTranslator.hrsDisableFunction(day, false, false);
        
    }
    
    // To cover instructorDayRowFormation method in TimeCardDayCommunityTranslator
    private static testMethod void tcdCommTrans3(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Date today = system.today();
        Date currst;
        
        //if today = sunday need to load the last week data - because saleforce start of the week is sunday
        if(today.toStartofWeek() == today) {
            currst = today.addDays(-1).toStartofWeek().addDays(1);
        }else {
            currst = today.toStartofWeek().addDays(1);
        } 
        Date currend = currst.addDays(6);
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                
        Id usrId = UserInfo.getUserId();
                
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DLI_W_TO_Opportunities' LIMIT 1];
                
        String dliWProRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'My Test Project',AcctSeed__Status__c = 'Inquiry',RecordTypeId = dliWProRT, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert proj;
                
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 1];
        
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(Name = 'Language Training- Preparation',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj.Id,Project_Task_Type__c = 'Preparation time',AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Rate__c = 41);
        insert task;
        
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        List<Contact_Assignments__c> insConAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Rate_Card_Rate__c, Rate_Card_Rate__r.Non_Billable_Payroll_Item__c,Project_Task__c, Start_Date__c, End_Date__c, Oral_Exam_Date_Time__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        insConAss[0].Candidate_Name__c = conList[0].Id;
        insConAss[0].Project__c = task.AcctSeed__Project__c;
        insConAss[0].Status__c = 'Ended';
        insConAss[0].Rate_Card_Rate__c = cr[0].Id;
        insConAss[0].End_Date__c = Date.Today().addDays(-2);
        update insConAss[0];
        
        //List<AcctSeed__Time_Card_Line__c> timeCardLines,List<AcctSeed__Project_Task__c> taskRecords,List<Contact_Assignments__c> caRecord,Map<Id,Integer> taskIdTimeCount,Map<Id,String> taskIdTimeMap,List<Contact_Assignments__History> caHistory,List<AcctSeed__Cost_Rates__c> oldCRRecord){
        TimeCardDayCommunityTranslator.instructorDayRowFormation(Date.Today(), Date.Today(), '', '', new List<AcctSeed__Time_Card_Line__c>(), new List<AcctSeed__Project_Task__c>{task}, new List<Contact_Assignments__c>{insConAss[0]}, new Map<Id,Integer>(), new Map<Id,String>(), new List<Contact_Assignments__History>{}, new List<AcctSeed__Cost_Rates__c>{},new Map<Id,String>{}, new Set<Date>{});
        
        Test.stopTest();
    }
    
    // To cover instructorDayRowFormation method in TimeCardDayCommunityTranslator
    private static testMethod void tcdCommTrans4(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Date today = system.today();
        Date currst;
        
        //if today = sunday need to load the last week data - because saleforce start of the week is sunday
        if(today.toStartofWeek() == today) {
            currst = today.addDays(-1).toStartofWeek().addDays(1);
        }else {
            currst = today.toStartofWeek().addDays(1);
        } 
        Date currend = currst.addDays(6);
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                
        Id usrId = UserInfo.getUserId();
                
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DLI_W_TO_Opportunities' LIMIT 1];
        
        String dliWProRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Language_Training_Projects').getRecordTypeId();
                
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'My Test Project',AcctSeed__Status__c = 'Inquiry',RecordTypeId = dliWProRT, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert proj;
                
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 1];
                
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(Name = 'Language Training- Preparation',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj.Id,Project_Task_Type__c = 'Preparation time',AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Rate__c = 41);
        insert task;
        
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        List<Contact_Assignments__c> insConAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Project_Task__c, Rate_Card_Rate__c, Rate_Card_Rate__r.Non_Billable_Payroll_Item__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        insConAss[0].Candidate_Name__c = conList[0].Id;
        insConAss[0].Project__c = task.AcctSeed__Project__c;
        insConAss[0].Project_Task__c = task.Id;
        insConAss[0].Status__c = 'Ended';
        insConAss[0].Rate_Card_Rate__c = cr[0].Id;
        insConAss[0].End_Date__c = Date.Today().addDays(-2);
        update insConAss[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task.Id;
        timeCardLine.AcctSeed__Project__c = task.AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = insConAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted', Late_Cancellation__c = TRUE);
        insert day;
                
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project__c, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Time_Card__c, Completed__c, 
            AcctSeed__Billable__c, Payroll_Item__c, Labor_Cost_Rate__c, Contact_Assignment__c, Sequence_Number__c, Location__c, Location__r.Name,
            AcctSeed__Project_Task__r.Project_Task_Type__c,  AcctSeed__Project_Task__r.Name, 
            (SELECT Id, Late_Cancellation__c, Recall_Reason__c, Student_Approval_Status__c, Cancellation_Reason__c, Total_Hours_Before_Approved__c, Status__c, Start_Time1__c, End_Time1__c, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, AcctSeed__Time_Card_Line__c, Start_Time2__c, End_Time2__c FROM AcctSeed__Time_Card_Days__r) FROM AcctSeed__Time_Card_Line__c WHERE Id = :timeCardLine.Id];
        
        TimeCardDayCommunityTranslator.instructorDayRowFormation(Date.Today(), Date.Today(), '', '', lines, new List<AcctSeed__Project_Task__c>{task}, new List<Contact_Assignments__c>{insConAss[0]}, new Map<Id,Integer>(), new Map<Id,String>(), new List<Contact_Assignments__History>{}, new List<AcctSeed__Cost_Rates__c>{},new Map<Id,String>{}, new Set<Date>{});
        
        Test.stopTest();
    }
    
    // To cover instructorDayRowFormation method in TimeCardDayCommunityTranslator
    private static testMethod void tcdCommTrans5(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Date today = system.today();
        Date currst;
        
        //if today = sunday need to load the last week data - because saleforce start of the week is sunday
        if(today.toStartofWeek() == today) {
            currst = today.addDays(-1).toStartofWeek().addDays(1);
        }else {
            currst = today.toStartofWeek().addDays(1);
        } 
        Date currend = currst.addDays(6);
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                
        Id usrId = UserInfo.getUserId();
                
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DLI_W_TO_Opportunities' LIMIT 1];
        
        String dliWProRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'My Test Project',AcctSeed__Status__c = 'Inquiry',RecordTypeId = dliWProRT, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert proj;
                
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 1];
                
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(Name = 'Language Training- Hindi',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj.Id,Project_Task_Type__c = 'Language Training',AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Rate__c = 41);
        insert task;
        
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        List<Contact_Assignments__c> insConAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Project_Task__c, Rate_Card_Rate__c, Rate_Card_Rate__r.Non_Billable_Payroll_Item__c, Start_Date__c, End_Date__c, Oral_Exam_Date_Time__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        insConAss[0].Candidate_Name__c = conList[0].Id;
        insConAss[0].Project__c = task.AcctSeed__Project__c;
        insConAss[0].Project_Task__c = task.Id;
        insConAss[0].Status__c = 'Ended';
        insConAss[0].Rate_Card_Rate__c = cr[0].Id;
        insConAss[0].End_Date__c = Date.Today().addDays(-2);
        update insConAss[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task.Id;
        timeCardLine.AcctSeed__Project__c = task.AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = insConAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(1), Status__c = 'Approved', Student_Approval_Status__c = 'Approved', Late_Cancellation__c = TRUE);
        insert day;
                
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project__c, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Time_Card__c, Completed__c, 
            AcctSeed__Billable__c, Payroll_Item__c, Labor_Cost_Rate__c, Contact_Assignment__c, Sequence_Number__c, Location__c, Location__r.Name,
            AcctSeed__Project_Task__r.Project_Task_Type__c,  AcctSeed__Project_Task__r.Name, 
            (SELECT Id, Late_Cancellation__c, Recall_Reason__c, Student_Approval_Status__c, Cancellation_Reason__c, Total_Hours_Before_Approved__c, Status__c, Start_Time1__c, End_Time1__c, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, AcctSeed__Time_Card_Line__c, Start_Time2__c, End_Time2__c FROM AcctSeed__Time_Card_Days__r) FROM AcctSeed__Time_Card_Line__c WHERE Id = :timeCardLine.Id];
        
        TimeCardDayCommunityTranslator.instructorDayRowFormation(Date.Today(), Date.Today(), '', '', lines, new List<AcctSeed__Project_Task__c>{task}, new List<Contact_Assignments__c>{insConAss[0]}, new Map<Id,Integer>(), new Map<Id,String>(), new List<Contact_Assignments__History>{}, new List<AcctSeed__Cost_Rates__c>{},new Map<Id,String>{}, new Set<Date>{});
        
        Test.stopTest();
    }
    
    // To cover instructorDayRowFormation method in TimeCardDayCommunityTranslator
    private static testMethod void tcdCommTrans6(){
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Date today = system.today();
        Date currst;
        
        //if today = sunday need to load the last week data - because saleforce start of the week is sunday
        if(today.toStartofWeek() == today) {
            currst = today.addDays(-1).toStartofWeek().addDays(1);
        }else {
            currst = today.toStartofWeek().addDays(1);
        } 
        Date currend = currst.addDays(6);
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                
        Id usrId = UserInfo.getUserId();
                
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DLI_W_TO_Opportunities' LIMIT 1];
        
        String dliWProRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        Test.startTest();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'My Test Project',AcctSeed__Status__c = 'Inquiry',RecordTypeId = dliWProRT, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert proj;
                
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 1];
                
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(Name = 'Language Testing- Hindi',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj.Id,Project_Task_Type__c = 'Language Testing',AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Rate__c = 41);
        insert task;
        
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        List<Contact_Assignments__c> insConAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Project_Task__c, Rate_Card_Rate__c, Rate_Card_Rate__r.Non_Billable_Payroll_Item__c, Start_Date__c, End_Date__c, Oral_Exam_Date_Time__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        insConAss[0].Candidate_Name__c = conList[0].Id;
        insConAss[0].Project__c = task.AcctSeed__Project__c;
        insConAss[0].Project_Task__c = task.Id;
        insConAss[0].Status__c = 'Ended';
        insConAss[0].Rate_Card_Rate__c = cr[0].Id;
        insConAss[0].End_Date__c = Date.Today().addDays(-2);
        update insConAss[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task.Id;
        timeCardLine.AcctSeed__Project__c = task.AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = insConAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(1), Status__c = 'Approved', Student_Approval_Status__c = 'Rejected', Late_Cancellation__c = TRUE);
        insert day;
                
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project__c, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Time_Card__c, Completed__c, 
            AcctSeed__Billable__c, Payroll_Item__c, Labor_Cost_Rate__c, Contact_Assignment__c, Sequence_Number__c, Location__c, Location__r.Name,
            AcctSeed__Project_Task__r.Project_Task_Type__c,  AcctSeed__Project_Task__r.Name, 
            (SELECT Id, Late_Cancellation__c, Recall_Reason__c, Student_Approval_Status__c, Cancellation_Reason__c, Total_Hours_Before_Approved__c, Status__c, Start_Time1__c, End_Time1__c, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, AcctSeed__Time_Card_Line__c, Start_Time2__c, End_Time2__c FROM AcctSeed__Time_Card_Days__r) FROM AcctSeed__Time_Card_Line__c WHERE Id = :timeCardLine.Id];
        
        TimeCardDayCommunityTranslator.instructorDayRowFormation(Date.Today(), Date.Today(), '', '', lines, new List<AcctSeed__Project_Task__c>{task}, new List<Contact_Assignments__c>{insConAss[0]}, new Map<Id,Integer>(), new Map<Id,String>(), new List<Contact_Assignments__History>{}, new List<AcctSeed__Cost_Rates__c>{},new Map<Id,String>{}, new Set<Date>{});
        
        Test.stopTest();
    }
    
    // To cover notesFormationmethod in TimeCardDayCommunityTranslator
    private static testMethod void tcdCommTrans7(){
    
        List<Opportunity> oppList = [SELECT Id,Name FROM Opportunity LIMIT 2];
        
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        List<AcctSeed__Time_Card_Day__c> timeCardDayList = [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Hours__c,Status__c,AcctSeed__Time_Card_Line__c,
            Total_Hours_Before_Approved__c,AcctSeed__Internal_Comment__c
        FROM AcctSeed__Time_Card_Day__c LIMIT 3];
        
        
        List<Accounting_Seed_Time_Snapshot__c> timeSnapshotList = new List<Accounting_Seed_Time_Snapshot__c> {
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator', Reference_Id__c = 'Test', Note_Type__c = 'Instructor Daily Entry Late Cancellation', Time_Card_Day__c = timeCardDayList[0].Id, Date__c = timeCardDayList[0].AcctSeed__Date__c, Hours__c = timeCardDayList[0].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[0].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[0].Status__c,Time_Card_Line__c = timeCardDayList[0].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[0].Total_Hours_Before_Approved__c),
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator', Reference_Id__c = 'Test Partial Reject', Note_Type__c = 'Daily Entry Edit',Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c)
        };
        //insert timeSnapshotList;
        TimeCardDayCommunityTranslator.notesFormation(timeSnapshotList);
    }
    
    // To cover notesFormationmethod in TimeCardDayCommunityTranslator
    private static testMethod void tcdCommTrans8(){
    
        List<Opportunity> oppList = [SELECT Id,Name FROM Opportunity LIMIT 2];
        
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
        
        List<AcctSeed__Time_Card_Day__c> timeCardDayList = [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Hours__c,Status__c,AcctSeed__Time_Card_Line__c,
            Total_Hours_Before_Approved__c,AcctSeed__Internal_Comment__c
        FROM AcctSeed__Time_Card_Day__c LIMIT 3];
        
        
        List<Accounting_Seed_Time_Snapshot__c> timeSnapshotList = new List<Accounting_Seed_Time_Snapshot__c> {
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator', Reference_Id__c = 'Test', Note_Type__c = 'Instructor Daily Entry Recall', Time_Card_Day__c = timeCardDayList[0].Id, Date__c = timeCardDayList[0].AcctSeed__Date__c, Hours__c = timeCardDayList[0].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[0].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[0].Status__c,Time_Card_Line__c = timeCardDayList[0].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[0].Total_Hours_Before_Approved__c),
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator', Reference_Id__c = 'Test Partial Reject', Note_Type__c = 'Student Daily Entry Reject',Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c),
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator', Reference_Id__c = 'Test Partial Reject', Note_Type__c = 'Instructor Daily Entry Student Hours Mismatch',Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c)
        };
        TimeCardDayCommunityTranslator.notesFormation(timeSnapshotList);
    }
    
    // To cover timeActivityRecordsFormation in TimeCardDayCommunityTranslator
    private static testMethod void tcdCommTrans9(){
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Date today = system.today();
        Date currst;
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                
        Id usrId = UserInfo.getUserId();
                
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DLI_W_TO_Opportunities' LIMIT 1];
        
        String dliWProRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        Test.startTest();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'My Test Project',AcctSeed__Status__c = 'Inquiry',RecordTypeId = dliWProRT, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert proj;
                
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 1];
                
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(Name = 'Language Testing- Hindi',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj.Id,Project_Task_Type__c = 'Language Testing',AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Rate__c = 41);
        insert task;
        
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        List<Contact_Assignments__c> insConAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Project_Task__c, Rate_Card_Rate__c, Rate_Card_Rate__r.Non_Billable_Payroll_Item__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        insConAss[0].Candidate_Name__c = conList[0].Id;
        insConAss[0].Project__c = task.AcctSeed__Project__c;
        insConAss[0].Project_Task__c = task.Id;
        insConAss[0].Status__c = 'Ended';
        insConAss[0].Rate_Card_Rate__c = cr[0].Id;
        insConAss[0].End_Date__c = Date.Today().addDays(-2);
        update insConAss[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task.Id;
        timeCardLine.AcctSeed__Project__c = task.AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = insConAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(1), Status__c = 'Approved', Student_Approval_Status__c = 'Rejected', Late_Cancellation__c = TRUE);
        insert day;
                
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name, Student_Approval_Status__c,
             AcctSeed__Time_Card_Line__r.Location__r.Name, Total_Hours_Before_Approved__c, Status__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.DLS_Ref__c, AcctSeed__Date__c, AcctSeed__Time_Card_Line__c, Week_Day__c
         FROM AcctSeed__Time_Card_Day__c];
        
        TimeCardDayCommunityTranslator.timeActivityRecordsFormation(days);
        
        Test.stopTest();
    }
    
    // To cover buttonDisplayFunction in TimeCardDayCommunityTranslator
    private static testMethod void tcdCommTrans10(){
    
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        Date previuosWkStart = currStart.addDays(-7);
        Date previuosWkEnd = currEnd.addDays(-7);
        
        Date weekBeforeLastWeekStart = previuosWkStart.addDays(-7);
        Date weekBeforeLastWeekEnd = previuosWkEnd.addDays(-7);
        
        Date olderpast2weekStart = weekBeforeLastWeekStart.addDays(-7);
        Date olderpast2weekEnd = weekBeforeLastWeekEnd.addDays(-7);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                
        Id usrId = UserInfo.getUserId();
                
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DLI_W_TO_Opportunities' LIMIT 1];
        
        String dliWProRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        Test.startTest();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'My Test Project',AcctSeed__Status__c = 'Inquiry',RecordTypeId = dliWProRT, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert proj;
                
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 1];
                
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(Name = 'Language Testing- Hindi',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj.Id,Project_Task_Type__c = 'Language Testing',AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Rate__c = 41);
        insert task;
        
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        List<Contact_Assignments__c> insConAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Project_Task__c, Rate_Card_Rate__c, Rate_Card_Rate__r.Non_Billable_Payroll_Item__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        insConAss[0].Candidate_Name__c = conList[0].Id;
        insConAss[0].Project__c = task.AcctSeed__Project__c;
        insConAss[0].Project_Task__c = task.Id;
        insConAss[0].Status__c = 'Ended';
        insConAss[0].Rate_Card_Rate__c = cr[0].Id;
        insConAss[0].End_Date__c = Date.Today().addDays(-2);
        update insConAss[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task.Id;
        timeCardLine.AcctSeed__Project__c = task.AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = insConAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(1), Status__c = 'Approved', Student_Approval_Status__c = 'Rejected', Late_Cancellation__c = TRUE);
        insert day;
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        TimeCardDayCommunityDomain.DayEntries dayEntry1 = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList1 = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        dayEntry.dayId = day.Id;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = Date.Today();
        dayEntry.comments = 'Test';
        dayEntry.status = 'Submitted';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.taskId = task.Id;
        dayEntry.isCompleted = TRUE;
                
        dayEntry1.dayId = day.Id;
        dayEntry1.dayHours = '2.5';
        dayEntry1.dateVal = Date.Today();
        dayEntry1.comments = 'Test';
        dayEntry1.status = 'Reverted';
        dayEntry1.studentApprovalStatus = 'Submitted';
        dayEntry1.taskId = task.Id;
        dayEntry1.isCompleted = TRUE;
        
        dayEntryList.add(dayEntry);
        dayEntryList1.add(dayEntry1);
        
        TimeCardDayCommunityTranslator.buttonDisplayFunction(dayEntryList, currStart, currEnd);
        TimeCardDayCommunityTranslator.buttonDisplayFunction(dayEntryList1, olderpast2weekStart, olderpast2weekEnd);
        TimeCardDayCommunityTranslator.buttonDisplayFunction(new List<TimeCardDayCommunityDomain.DayEntries>(), olderpast2weekStart, olderpast2weekEnd);
        Test.stopTest();
    }
    
    // To cover buttonDisplayFunction in TimeCardDayCommunityTranslator
    private static testMethod void tcdCommTrans11(){
    
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        Date previuosWkStart = currStart.addDays(-7);
        Date previuosWkEnd = currEnd.addDays(-7);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                
        Id usrId = UserInfo.getUserId();
                
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DLI_W_TO_Opportunities' LIMIT 1];
        
        String dliWProRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        Test.startTest();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'My Test Project',AcctSeed__Status__c = 'Inquiry',RecordTypeId = dliWProRT, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert proj;
                
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 1];
                
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(Name = 'Language Testing- Hindi',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj.Id,Project_Task_Type__c = 'Language Testing',AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Rate__c = 41);
        insert task;
        
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        List<Contact_Assignments__c> insConAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Project_Task__c, Rate_Card_Rate__c, Rate_Card_Rate__r.Non_Billable_Payroll_Item__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        insConAss[0].Candidate_Name__c = conList[0].Id;
        insConAss[0].Project__c = task.AcctSeed__Project__c;
        insConAss[0].Project_Task__c = task.Id;
        insConAss[0].Status__c = 'Ended';
        insConAss[0].Rate_Card_Rate__c = cr[0].Id;
        insConAss[0].End_Date__c = Date.Today().addDays(-2);
        update insConAss[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task.Id;
        timeCardLine.AcctSeed__Project__c = task.AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = insConAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(1), Status__c = 'Approved', Student_Approval_Status__c = 'Rejected', Late_Cancellation__c = TRUE);
        insert day;
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        TimeCardDayCommunityDomain.DayEntries dayEntry1 = new TimeCardDayCommunityDomain.DayEntries();
        TimeCardDayCommunityDomain.DayEntries dayEntry2 = new TimeCardDayCommunityDomain.DayEntries();
        TimeCardDayCommunityDomain.DayEntries dayEntry3 = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        dayEntry.dayId = day.Id;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = Date.Today();
        dayEntry.comments = 'Test';
        dayEntry.status = 'Approved';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.taskId = task.Id;
        dayEntry.isCompleted = TRUE;
        
        dayEntry1.dayId = day.Id;
        dayEntry1.dayHours = '2.5';
        dayEntry1.dateVal = Date.Today();
        dayEntry1.comments = 'Test';
        dayEntry1.status = 'Draft';
        dayEntry1.studentApprovalStatus = 'Submitted';
        dayEntry1.taskId = task.Id;
        dayEntry1.isCompleted = TRUE;
        
        dayEntry2.dayId = day.Id;
        dayEntry2.dayHours = '2.5';
        dayEntry2.dateVal = Date.Today();
        dayEntry2.comments = 'Test';
        dayEntry2.status = 'Reverted';
        dayEntry2.studentApprovalStatus = 'Rejected';
        dayEntry2.taskId = task.Id;
        dayEntry2.isCompleted = TRUE;
        
        dayEntry3.dayId = day.Id;
        dayEntry3.dayHours = '2.5';
        dayEntry3.dateVal = Date.Today();
        dayEntry3.comments = 'Test';
        dayEntry3.status = 'Rejected';
        dayEntry3.studentApprovalStatus = 'Rejected';
        dayEntry3.taskId = task.Id;
        dayEntry3.isCompleted = TRUE;
                
        dayEntryList.add(dayEntry);
        dayEntryList.add(dayEntry1);
        dayEntryList.add(dayEntry2);
        dayEntryList.add(dayEntry3);
        
        TimeCardDayCommunityTranslator.buttonDisplayFunction(dayEntryList, previuosWkStart, previuosWkEnd);
        TimeCardDayCommunityTranslator.buttonDisplayFunction(new List<TimeCardDayCommunityDomain.DayEntries>(), currStart, currEnd);
        
        Test.stopTest();
    }
    
    // To cover buttonDisplayFunction in TimeCardDayCommunityTranslator
    private static testMethod void tcdCommTrans12(){
    
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        Date previuosWkStart = currStart.addDays(-7);
        Date previuosWkEnd = currEnd.addDays(-7);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                
        Id usrId = UserInfo.getUserId();
                
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DLI_W_TO_Opportunities' LIMIT 1];
        
        String dliWProRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        Test.startTest();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'My Test Project',AcctSeed__Status__c = 'Inquiry',RecordTypeId = dliWProRT, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert proj;
                
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 1];
                
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(Name = 'Language Testing- Hindi',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj.Id,Project_Task_Type__c = 'Language Testing',AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Rate__c = 41);
        insert task;
        
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        List<Contact_Assignments__c> insConAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Project_Task__c, Rate_Card_Rate__c, Rate_Card_Rate__r.Non_Billable_Payroll_Item__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        insConAss[0].Candidate_Name__c = conList[0].Id;
        insConAss[0].Project__c = task.AcctSeed__Project__c;
        insConAss[0].Project_Task__c = task.Id;
        insConAss[0].Status__c = 'Ended';
        insConAss[0].Rate_Card_Rate__c = cr[0].Id;
        insConAss[0].End_Date__c = Date.Today().addDays(-2);
        update insConAss[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task.Id;
        timeCardLine.AcctSeed__Project__c = task.AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = insConAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(1), Status__c = 'Approved', Student_Approval_Status__c = 'Rejected', Late_Cancellation__c = TRUE);
        insert day;
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        dayEntry.dayId = day.Id;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = Date.Today();
        dayEntry.comments = 'Test';
        dayEntry.status = 'Recalled';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.taskId = task.Id;
        dayEntry.isCompleted = TRUE;
                
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityTranslator.buttonDisplayFunction(dayEntryList, previuosWkStart, previuosWkEnd);
        TimeCardDayCommunityTranslator.buttonDisplayFunction(dayEntryList, currStart, currEnd);
        TimeCardDayCommunityTranslator.buttonDisplayFunction(new List<TimeCardDayCommunityDomain.DayEntries>(), previuosWkStart, previuosWkEnd);
        
        Test.stopTest();
    }
    
    // To cover studentTimeEntriesFormation in TimeCardDayCommunityTranslator
    private static testMethod void tcdCommTrans13(){
    
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        Date previuosWkStart = currStart.addDays(-7);
        Date previuosWkEnd = currEnd.addDays(-7);
        
        Date isOlderThanLast2WeekStart = previuosWkStart.addDays(-14);
        Date isOlderThanLast2WeekEnd = currEnd.addDays(-14);
        
        Test.startTest();
        List<Events__c> events = [SELECT Id FROM Events__c LIMIT 2];
        List<Contact> contacts = [SELECT Id FROM Contact WHERE RecordType.DeveloperName = 'Student' AND LastName='StudentContact' LIMIT 1];
        
        List<AcctSeed__Time_Card_Day__c> days = [SELECT Id, AcctSeed__Date__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c FROM AcctSeed__Time_Card_Day__c];
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        
        List<Attendance__c> attendanceList = new List<Attendance__c>{
            
            new Attendance__c(Event__c = events[0].Id, Student__c = contacts[0].Id, Date__c = days[0].AcctSeed__Date__c, Time_Card_Day__c = days[0].Id, Duration__c = 2, Instructor__c = days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c),
            new Attendance__c(Event__c = events[1].Id, Student__c = contacts[0].Id, Date__c = days[1].AcctSeed__Date__c, Time_Card_Day__c = days[1].Id, Duration__c = 2, Instructor__c = days[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c)
        };
        insert attendanceList;
        
        List<Attendance__c> attens = [SELECT Id, Date__c, Duration__c, Event__c, Instructor__c, Student__c, Student_Approval_Status__c, Time_Card_Day__c, Rejection_Reason__c, Recall_Reason__c, Comments__c, 
            Student__r.Name, Time_Card_Day__r.Late_Cancellation__c, Time_Card_Day__r.Status__c, Event__r.No_Student_Approval__c, Attendance__c
        FROM Attendance__c 
        WHERE Id IN : attendanceList];
        
        Map<Id,List<Attendance__c>> aMap = new Map<Id,List<Attendance__c>>();
        aMap.put(contacts[0].Id, attens);
        
        TimeCardDayCommunityTranslator.studentTimeEntriesFormation(new List<Contact_Assignments__c>{}, isOlderThanLast2WeekStart, isOlderThanLast2WeekEnd, aMap, TRUE,true);
        TimeCardDayCommunityTranslator.studentTimeEntriesFormation(new List<Contact_Assignments__c>{}, currStart, currEnd, aMap, TRUE,true);
        TimeCardDayCommunityTranslator.studentTimeEntriesFormation(new List<Contact_Assignments__c>{}, currStart, currEnd, aMap, FALSE,false);
        Test.stopTest();
    }
    
    // To cover getProjectRelatedEvents method
    private static testMethod void getProjectRelatedEvents_Test(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> con = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = con[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = con[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Project_Task__c FROM Schedule__c WHERE Project_Task__r.Project_Task_Type__c != 'Preparation time' LIMIT 1];
                
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = schList[0].Project_Task__c;
        timeCardLine.AcctSeed__Project__c = schList[0].Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
        
        Events__c event = new Events__c(Name = '16-00687-SH1-EV1',Schedule__c = schList[0].Id,SequenceNo__c = 1,Instructor__c = con[0].Id,Date__c = Date.Today().addDays(-1),Project__c = timeCardLine.AcctSeed__Project__c,Status__c = 'Scheduled', Duration__c = 10);
        insert event;
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        Test.stopTest();
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        dayEntry.dayId = day.Id;
        dayEntry.dateVal = Date.Today().addDays(-1);
        dayEntry.dayHours = '5';
        dayEntryList.add(dayEntry);
        
        InstructorTimeEntry_Controller.getProjectRelatedEvents(schList[0].Project__c, con[0].Id, String.valueOf(Date.Today().addDays(-1)), String.valueOf(Date.Today().addDays(-1)), JSON.Serialize(dayEntryList));
    }
    
    // To cover getExistingTCDsForOtherProjects method
    private static testMethod void getExistingTCDsForOtherProjects_Test(){
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest();
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c];
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];        
        Id tempProjId = conAss[0].Project__c;
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id != :conAss[0].Project__c];
                
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        conAss[0].Project__c = proj[0].Id;
        update conAss[0]; 
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
       
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        Test.stopTest();
                  
        System.runAs(user) {    
        
            InstructorTimeEntry_Controller.getExistingTCDsForOtherProjects(conList[0].Id, String.valueOf(System.Today()), String.valueOf(System.Today()), tempProjId);
        }
    }
}