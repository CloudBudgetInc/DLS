@isTest
private class Mobile_InstructorTimeEntryCtrl_Test{ 

    @testSetup static void setupMethod() {
    
        Test.StartTest();
            List<Planned_Days_Off__c> pdo = TestClassUtil.createTestPlannedDaysOff(); 
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
                String intialfilterVal = Mobile_InstructorTimeEntryCtrl.getInitialFilterValues();
                TimeCardDayCommunityDomain.InitialFilterValues intialVal = (TimeCardDayCommunityDomain.InitialFilterValues) JSON.deserialize(intialfilterVal,TimeCardDayCommunityDomain.InitialFilterValues.Class);
                System.assertEquals(intialVal.contactId,conList[0].Id);
            }
         Test.stopTest();
    }
    
    // To cover getInitialFilterValues method
    private static testMethod void myTestMethod1a(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Standard User'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email=conList[0].Email, FirstName = conList[0].FirstName, 
                emailencodingkey='UTF-8', lastname=conList[0].LastName, languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='newtester@noemail.com');
       
        insert user;
        Test.startTest();     
            system.runAs(user) {
                Mobile_InstructorTimeEntryCtrl.getInitialFilterValues();
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
        conAss[0].Paper_Timesheet__c = FALSE;
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        
        
        List<Contact_Assignments__c> conAssTest = new List<Contact_Assignments__c>();
        
        for(Contact_Assignments__c c :[SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c, RecordType.DeveloperName
            FROM Contact_Assignments__c 
            WHERE RecordType.DeveloperName IN ('Instructor', 'Student', 'Staff') AND Status__c = 'Active' AND Project__c = : projects[0].Id 
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
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
        
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
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Location__c = loc.Id;
        timeCardLine.Completed__c = true;
        insert timeCardLine;
        
        System.runAs(user) {    
        
            String res = Mobile_InstructorTimeEntryCtrl.getProjectFilterValues(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id);
            TimeCardDayCommunityDomain.ProjectFilterInfo det = (TimeCardDayCommunityDomain.ProjectFilterInfo) JSON.deserialize(res,TimeCardDayCommunityDomain.ProjectFilterInfo.Class);
            System.assertEquals(projects[0].Id,det.projectFilter[0].projectId);
        }
        
        Test.stopTest();
    }
    
    // To cover getProjectFilterValues method
    private static testMethod void myTestMethod2b(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Test.startTest(); 
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        System.runAs(user) {    
        
            try{
                String res = Mobile_InstructorTimeEntryCtrl.getProjectFilterValues('test', 'test', conList[0].Id);
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }    
        Test.stopTest();    
    }
    
    // To cover getTimeRowsRelatedInformation method
    private static testMethod void myTestMethod3(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
                
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
                
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
        
        Test.startTest();
        
        Id usrId = UserInfo.getUserId();
        
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DLI_W_TO_Opportunities' LIMIT 1];
         
        String dliWProRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'My Test Project',AcctSeed__Status__c = 'Inquiry',RecordTypeId = dliWProRT, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert proj;
                
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 1];
        
        List<AcctSeed__Project_Task__c> task = new List<AcctSeed__Project_Task__c>{
            new AcctSeed__Project_Task__c(Name = 'Test Task1',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj.Id,Project_Task_Type__c = 'Preparation time',AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Rate__c = 41),
            new AcctSeed__Project_Task__c(Name = 'Test Task2',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj.Id,Project_Task_Type__c = 'Preparation time',AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Rate__c = 41)
        };
        insert task;
        
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        List<Contact_Assignments__c> cas = [SELECT Id, Name, Recordtype.DeveloperName, Candidate_Name__c, Candidate_Name__r.Name, Project__c,End_Date__C FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN ('Instructor', 'Student') AND Status__c = 'Active'];
        List<Contact_Assignments__c> updateCAs = new List<Contact_Assignments__c>();
        
        Id insCAId;
        String stdName;
        
        for(Contact_Assignments__c ca : cas){
            if(ca.Recordtype.DeveloperName == 'Instructor'){
                ca.Candidate_Name__c = conList[0].Id;
                ca.Project__c = task[0].AcctSeed__Project__c;
                ca.Status__c = 'Ended';
                ca.Rate_Card_Rate__c = cr[0].Id;
                ca.End_Date__C = Date.Today().addDays(-2);
                insCAId = ca.Id;
            }
            if(ca.Recordtype.DeveloperName == 'Student'){
                ca.Candidate_Name__c = conList[0].Id;
                ca.Project__c = task[0].AcctSeed__Project__c;
                
                stdName = ca.Candidate_Name__r.Name;
            }
            updateCAs.add(ca);
        }
        update updateCAs;       
                                
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 2];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = currst;
        schList[0].End_Date__c = currend;
        schList[0].Start_Time__c = '06:15 AM';
        schList[0].End_Time__c = '06:45 AM';
        schList[0].Instructor__c = conList[0].Id;
        schList[1].Status__c = 'Active';
        schList[1].Project__c = task[0].AcctSeed__Project__c;
        schList[1].Project_Task__c = task[1].Id;
        schList[1].Start_Date__c = currst;
        schList[1].End_Date__c = currend;
        schList[1].Start_Time__c = '06:15 AM';
        schList[1].End_Time__c = '06:45 AM';
        schList[1].Instructor__c = conList[0].Id;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = insCAId;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
            
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        //day.Status__c = 'Submitted';
        //update day;
         
        system.runAs(user) {
            String infor = Mobile_InstructorTimeEntryCtrl.getTimeRowsRelatedInformation(string.valueOf(currst),string.valueOf(currend),proj.Id, conList[0].Id, proj.Name, stdName);
            
            TimeCardDayCommunityDomain.WeekSummaryDetail weekDetail = (TimeCardDayCommunityDomain.WeekSummaryDetail)JSON.deserialize(infor, TimeCardDayCommunityDomain.WeekSummaryDetail.class);
        }
        Test.stopTest();
    }
    /*
    // To cover getTimeRowsRelatedInformation method
    private static testMethod void myTestMethod3b(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
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
        
        Test.startTest();
        
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
        
        Id insRt = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
                
        Contact_Assignments__c insConAss = new Contact_Assignments__c();
        insConAss.Candidate_Name__c = conList[0].Id;
        insConAss.Project__c = proj.Id;
        insConAss.Project_Task__c = task.Id;
        insConAss.Start_Date__c = currst;
        insConAss.End_Date__c = currend;
        insConAss.Status__c = 'Approved';
        insConAss.Rate_Card_Rate__c = cr[0].Id;
        insConAss.RecordTypeId = insRt;
        insert insConAss;
        
        //List<Contact_Assignments__c> insConAss1 = [SELECT Id, Rate_Card_Rate__c FROM Contact_Assignments__c WHERE Id =: insConAss.Id];
        insConAss.Rate_Card_Rate__c = null;
        update insConAss;
        
        List<Contact_Assignments__c> stdConAss = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        stdConAss[0].Candidate_Name__c = conList[0].Id;
        stdConAss[0].Project__c = task.AcctSeed__Project__c;
        update stdConAss; 
                        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task.AcctSeed__Project__c;
        schList[0].Project_Task__c = task.Id;
        schList[0].Start_Date__c = currst;
        schList[0].End_Date__c = currend;
        schList[0].Start_Time__c = '06:15 AM';
        schList[0].End_Time__c = '06:45 AM';
        schList[0].Instructor__c = conList[0].Id;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task.Id;
        timeCardLine.AcctSeed__Project__c = task.AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = insConAss.Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
            
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Draft');
        insert day;
        
        day.Status__c = 'Submitted';
        update day;
        
        List<Attendance__c> stuAtn = [SELECT Id,Name,Student__c,Instructor__c,Date__c,Duration__c,Student_Approval_Status__c FROM  Attendance__c LIMIT 2];
        
        system.runAs(user) {
            String infor = Mobile_InstructorTimeEntryCtrl.getTimeRowsRelatedInformation(string.valueOf(currst),string.valueOf(currend),proj.Id, conList[0].Id, proj.Name, conList[0].Name);
            TimeCardDayCommunityDomain.WeekSummaryDetail weekDetail = (TimeCardDayCommunityDomain.WeekSummaryDetail)JSON.deserialize(infor, TimeCardDayCommunityDomain.WeekSummaryDetail.class);
        }
        Test.stopTest();
    }
    */
    // To cover getTimeRowsRelatedInformation method
    private static testMethod void getTimeRowsRelatedInformation_Test_1(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
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
        
        Test.startTest();
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                
        Id usrId = UserInfo.getUserId();
                
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DLI_W_TO_Opportunities' LIMIT 1];
        
        String eflProRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('EFL_Projects').getRecordTypeId();
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'My Test Project',AcctSeed__Status__c = 'Inquiry',RecordTypeId = eflProRT, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert proj;
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 1];
                
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(Name = 'Language Training- Tamil',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj.Id,Project_Task_Type__c = 'Language Training',AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Rate__c = 41);
        insert task;
        
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        Id insRt = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
                
        Contact_Assignments__c insConAss = new Contact_Assignments__c();
        insConAss.Candidate_Name__c = conList[0].Id;
        insConAss.Project__c = proj.Id;
        insConAss.Project_Task__c = task.Id;
        insConAss.Start_Date__c = currst;
        insConAss.End_Date__c = currend;
        insConAss.Status__c = 'Approved';
        insConAss.Rate_Card_Rate__c = cr[0].Id;
        insConAss.RecordTypeId = insRt;
        insert insConAss;
        
        //List<Contact_Assignments__c> insConAss1 = [SELECT Id, Rate_Card_Rate__c FROM Contact_Assignments__c WHERE Id =: insConAss.Id];
        insConAss.Rate_Card_Rate__c = null;
        update insConAss;
        
        List<Contact_Assignments__c> stdConAss = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        stdConAss[0].Candidate_Name__c = conList[0].Id;
        stdConAss[0].Project__c = task.AcctSeed__Project__c;
        update stdConAss; 
                        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Draft';
        schList[0].Project__c = task.AcctSeed__Project__c;
        schList[0].Project_Task__c = task.Id;
        schList[0].Start_Date__c = currst;
        schList[0].End_Date__c = currend;
        schList[0].Start_Time__c = '06:15 AM';
        schList[0].End_Time__c = '06:45 AM';
        schList[0].Instructor__c = conList[0].Id;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task.Id;
        timeCardLine.AcctSeed__Project__c = task.AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = insConAss.Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
            
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Draft');
        insert day;
        
        day.Status__c = 'Submitted';
        update day;
        
        List<Attendance__c> stuAtn = [SELECT Id,Name,Student__c,Instructor__c,Date__c,Duration__c,Student_Approval_Status__c FROM  Attendance__c LIMIT 2];
        
        system.runAs(user) {
            String infor = Mobile_InstructorTimeEntryCtrl.getTimeRowsRelatedInformation(string.valueOf(currst),string.valueOf(currend),proj.Id, conList[0].Id, proj.Name, conList[0].Name);
            TimeCardDayCommunityDomain.WeekSummaryDetail weekDetail = (TimeCardDayCommunityDomain.WeekSummaryDetail)JSON.deserialize(infor, TimeCardDayCommunityDomain.WeekSummaryDetail.class);
        }
        Test.stopTest();
    }
    
    // To cover getTimeRowsRelatedInformation method
    private static testMethod void getTimeRowsRelatedInformation_Test_2(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
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
        
        Test.startTest();
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                
        Id usrId = UserInfo.getUserId();
                
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DLI_W_TO_Opportunities' LIMIT 1];
        
        String eflProRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('EFL_Projects').getRecordTypeId();
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'My Test Project',AcctSeed__Status__c = 'Inquiry',RecordTypeId = eflProRT, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert proj;
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 1];
                
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(Name = 'Fringe - Holiday',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj.Id,Project_Task_Type__c = 'Fringe',AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Rate__c = 41);
        insert task;
        
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        Id insRt = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
                
        Contact_Assignments__c insConAss = new Contact_Assignments__c();
        insConAss.Candidate_Name__c = conList[0].Id;
        insConAss.Project__c = proj.Id;
        insConAss.Project_Task__c = task.Id;
        insConAss.Start_Date__c = currst;
        insConAss.End_Date__c = currend;
        insConAss.Status__c = 'Approved';
        insConAss.Rate_Card_Rate__c = cr[0].Id;
        insConAss.RecordTypeId = insRt;
        insert insConAss;
        
        //List<Contact_Assignments__c> insConAss1 = [SELECT Id, Rate_Card_Rate__c FROM Contact_Assignments__c WHERE Id =: insConAss.Id];
        insConAss.Rate_Card_Rate__c = null;
        update insConAss;
        
        List<Contact_Assignments__c> stdConAss = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        stdConAss[0].Candidate_Name__c = conList[0].Id;
        stdConAss[0].Project__c = task.AcctSeed__Project__c;
        update stdConAss; 
                        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Draft';
        schList[0].Project__c = task.AcctSeed__Project__c;
        schList[0].Project_Task__c = task.Id;
        schList[0].Start_Date__c = currst;
        schList[0].End_Date__c = currend;
        schList[0].Start_Time__c = '06:15 AM';
        schList[0].End_Time__c = '06:45 AM';
        schList[0].Instructor__c = conList[0].Id;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task.Id;
        timeCardLine.AcctSeed__Project__c = task.AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = insConAss.Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
            
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Draft');
        insert day;
        
        day.Status__c = 'Submitted';
        update day;
        
        List<Attendance__c> stuAtn = [SELECT Id,Name,Student__c,Instructor__c,Date__c,Duration__c,Student_Approval_Status__c FROM  Attendance__c LIMIT 2];
        
        system.runAs(user) {
            String infor = Mobile_InstructorTimeEntryCtrl.getTimeRowsRelatedInformation(string.valueOf(currst),string.valueOf(currend),proj.Id, conList[0].Id, proj.Name, conList[0].Name);
            TimeCardDayCommunityDomain.WeekSummaryDetail weekDetail = (TimeCardDayCommunityDomain.WeekSummaryDetail)JSON.deserialize(infor, TimeCardDayCommunityDomain.WeekSummaryDetail.class);
        }
        Test.stopTest();
    }
    
     // To cover getProjectBasedSchedules method
    private static testMethod void myTestMethod4(){
    
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
        
            Mobile_InstructorTimeEntryCtrl.getProjectBasedSchedules(schList[0].Project__c, String.valueOf(schList[0].Start_Date__c), String.valueOf(schList[0].End_Date__c), con[0].Id);
        }
        Test.stopTest();
    }
    
    // To cover recallTimeEntries method
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
        //de.status = 'Recalled';
        de.status = 'Submitted';
        de.lineId = timeCardLine[0].Id;
        
        deList.add(de);
        
        system.runAs(user) {
            String res = Mobile_InstructorTimeEntryCtrl.recallTimeEntries(JSON.Serialize(deList), 'Group');
            System.assertEquals(res, 'SUCCESS');
        }
        
        Test.stopTest();
    }
    
    // To cover recallTimeEntries method
    private static testMethod void myTestMethod5a(){
    
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
        //de.status = 'Recalled';
        de.status = 'Submitted';
        de.studentApprovalStatus = 'Approved';
        de.lineId = timeCardLine[0].Id;
        
        deList.add(de);
        
        system.runAs(user) {
            String res = Mobile_InstructorTimeEntryCtrl.recallTimeEntries(JSON.Serialize(deList), 'test');
            System.assertEquals(res, 'SUCCESS');
        }
        
        Test.stopTest();
    }
    
    // To cover recallStudentEntries method
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
        
        System.runAs(user) {    
            String res = Mobile_InstructorTimeEntryCtrl.recallStudentEntries(JSON.serialize(studentEntries));
        }
        Test.stopTest();
    }
    
    // To cover recallStudentEntries method
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
        
        System.runAs(user) {    
            String res = Mobile_InstructorTimeEntryCtrl.recallStudentEntries(JSON.serialize(studentEntries));
            if(res == 'SUCCESS'){
                System.assertEquals('SUCCESS', res);
            }
        }
        Test.stopTest();
    }
    
    // To cover getProjectRelatedEvents method
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
        
        Mobile_InstructorTimeEntryCtrl.getProjectRelatedEvents(schList[0].Project__c, con[0].Id, String.valueOf(Date.Today().addDays(-1)), String.valueOf(Date.Today().addDays(-1)), JSON.Serialize(dayEntryList));
    }
    
    // To cover getExistingTCDsForOtherProjects method
    private static testMethod void myTestMethod9(){
    
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
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id != :conAss[0].Project__c];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
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
        
            Mobile_InstructorTimeEntryCtrl.getExistingTCDsForOtherProjects(conList[0].Id, String.valueOf(System.Today()), String.valueOf(System.Today()), proj[0].Id);
        }
        
    }
    
    // To cover saveTimeEntryRecords 
    // Create new TC, TCL, TCD record with PT != Preparation time
    private static testMethod void myTestMethod10(){
        
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
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c];
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        
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
        dayEntry.projectId = projects[0].Id;
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
            Mobile_InstructorTimeEntryCtrl.saveTimeEntryRecords(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), projects[0].Id, 'Submit', JSON.Serialize(stdEntryList), new List<String>{});
        }
        
        Test.stopTest();
        
    }
    
    //Create new TC, TCL, TCD record with PT = Preparation time
    private static testMethod void myTestMethod10a(){    // 1%
                
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
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c];
                               
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
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
        dayEntry.projectId = projects[0].Id;
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
            Mobile_InstructorTimeEntryCtrl.saveTimeEntryRecords(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), projects[0].Id, 'Submit', JSON.Serialize(stdEntryList), new List<String>{});
        }
        
        Test.stopTest();
        
    }
    
    // Already has TC, TCL
    // Update TCD with PT != Preparation time
    private static testMethod void myTestMethod10b(){
        
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
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
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
        dayEntry.lineId = timeCardLine.Id;
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
        dayEntry.projectId = projects[0].Id;
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
            Mobile_InstructorTimeEntryCtrl.saveTimeEntryRecords(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), projects[0].Id, 'Complete', JSON.Serialize(stdEntryList), new List<String>{});
        }
        
        Test.stopTest();
    }
    
    // Already has TC, TCL
    // Update TCD with PT != Preparation time
    private static testMethod void myTestMethod10c(){
        
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
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c];
        
        //List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        //System.debug('conList==='+conList);
        
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
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
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
        dayEntry.lineId = timeCardLine.Id;
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
        dayEntry.projectId = projects[0].Id;
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
            Mobile_InstructorTimeEntryCtrl.saveTimeEntryRecords(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), projects[0].Id, 'Complete', JSON.Serialize(stdEntryList), new List<String>{});
        }
        
        Test.stopTest();
    }
   
    // Has TC, TCL
    // Create new TCD with PT = Preparation time
    private static testMethod void myTestMethod10d(){
        
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
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c];
        
        //List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        //System.debug('conList==='+conList);
        
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
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        task[0].Project_Task_Type__c = 'Preparation time';
        update task;
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        System.debug('schList===='+schList);
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
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
        dayEntry.projectId = projects[0].Id;
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
            Mobile_InstructorTimeEntryCtrl.saveTimeEntryRecords(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), projects[0].Id, 'Submit', JSON.Serialize(stdEntryList), new List<String>{});
        }
        
        Test.stopTest();
    }
    
    // Has TCP, TC, TCL 
    // Create new TCD with PT != Preparation time
    private static testMethod void myTestMethod10e(){
                
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        System.debug('conList==='+conList);
        
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
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c];
        
        //List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        //System.debug('conList==='+conList);
        
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
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
                
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
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
        dayEntry.projectId = projects[0].Id;
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
            Mobile_InstructorTimeEntryCtrl.saveTimeEntryRecords(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), projects[0].Id, 'Submit', JSON.Serialize(stdEntryList), new List<String>{});
        }
        
        Test.stopTest();
    }
    
    private static testMethod void myTestMethod10f(){
        
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
        List<Attendance__c> attendanceList = [SELECT Id FROM Attendance__c];
        
        //List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        //System.debug('conList==='+conList);
        
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
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
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
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
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
        dayEntry.projectId = projects[0].Id;
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
            Mobile_InstructorTimeEntryCtrl.saveTimeEntryRecords(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, JSON.Serialize(dayEntryList), projects[0].Id, 'Submit', JSON.Serialize(stdEntryList), new List<String>{});
        }
        
        Test.stopTest();
        
    }
    
    // To cover getScheduledEvents method
    private static testMethod void myTestMethod11(){
        
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
            
            Mobile_InstructorTimeEntryCtrl.getScheduledEvents(String.valueOf(Date.Today()), String.valueOf(Date.Today().addDays(1)), task[0].AcctSeed__Project__c, conList[0].Id);
        }
        
        Test.stopTest();
    }
    
    // To cover completeTimeCardDayEnties method
    private static testMethod void myTestMethod12(){
    
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
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
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
        
            Mobile_InstructorTimeEntryCtrl.completeTimeCardDayEnties(JSON.serialize(dayEntries));
        }
        Test.stopTest();
    }
    
    // To cover mobileStudentTimeEntriesFormation method in TimeCardDayCommunityTranslator
    private static testMethod void mobileStudentTimeEntriesFormation_Test_1(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
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
        
        Test.startTest();
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                
        Id usrId = UserInfo.getUserId();
                
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DLI_W_TO_Opportunities' LIMIT 1];
        
        String eflProRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('EFL_Projects').getRecordTypeId();
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'My Test Project',AcctSeed__Status__c = 'Inquiry',RecordTypeId = eflProRT, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert proj;
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 1];
                
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(Name = 'Fringe - Holiday',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj.Id,Project_Task_Type__c = 'Fringe',AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Rate__c = 41);
        insert task;
        
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        Id insRt = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
                
        Contact_Assignments__c insConAss = new Contact_Assignments__c();
        insConAss.Candidate_Name__c = conList[0].Id;
        insConAss.Project__c = proj.Id;
        insConAss.Project_Task__c = task.Id;
        insConAss.Start_Date__c = currst;
        insConAss.End_Date__c = currend;
        insConAss.Status__c = 'Approved';
        insConAss.Rate_Card_Rate__c = cr[0].Id;
        insConAss.RecordTypeId = insRt;
        insert insConAss;
        
        //List<Contact_Assignments__c> insConAss1 = [SELECT Id, Rate_Card_Rate__c FROM Contact_Assignments__c WHERE Id =: insConAss.Id];
        insConAss.Rate_Card_Rate__c = null;
        update insConAss;
        
        List<Contact_Assignments__c> stdConAss = [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        stdConAss[0].Candidate_Name__c = conList[0].Id;
        stdConAss[0].Project__c = task.AcctSeed__Project__c;
        update stdConAss; 
                        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Draft';
        schList[0].Project__c = task.AcctSeed__Project__c;
        schList[0].Project_Task__c = task.Id;
        schList[0].Start_Date__c = currst;
        schList[0].End_Date__c = currend;
        schList[0].Start_Time__c = '06:15 AM';
        schList[0].End_Time__c = '06:45 AM';
        schList[0].Instructor__c = conList[0].Id;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task.Id;
        timeCardLine.AcctSeed__Project__c = task.AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = insConAss.Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
            
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Draft');
        insert day;
        
        day.Status__c = 'Submitted';
        update day;
        
        List<Attendance__c> stuAtn = [SELECT Id, Name, Rejection_Reason__c, Attendance__c, Recall_Reason__c, Comments__c, Student__r.Name, Time_Card_Day__r.Late_Cancellation__c, Time_Card_Day__c, Student__c, Instructor__c, Date__c, Duration__c, Student_Approval_Status__c, Event__c FROM  Attendance__c LIMIT 2];
        stuAtn[0].Date__c = System.Today();
        stuAtn[0].Student__c = conList[0].Id;
        update stuAtn[0];
        
        system.runAs(user) {
            TimeCardDayCommunityTranslator.mobileStudentTimeEntriesFormation(stdConAss, currst, currend, stuAtn, True, True);
        }
        Test.stopTest();
    }
    
    // To cover mobileStudentTimeEntriesFormation method in TimeCardDayCommunityTranslator
    private static testMethod void mobileStudentTimeEntriesFormation_Test_2(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
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
        
        Test.startTest();
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                
        Id usrId = UserInfo.getUserId();
                
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DLI_W_TO_Opportunities' LIMIT 1];
        
        String eflProRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('EFL_Projects').getRecordTypeId();
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'My Test Project',AcctSeed__Status__c = 'Inquiry',RecordTypeId = eflProRT, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert proj;
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 1];
                
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(Name = 'Fringe - Holiday',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj.Id,Project_Task_Type__c = 'Fringe',AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Rate__c = 41);
        insert task;
        
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        Id insRt = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
                
        Contact_Assignments__c insConAss = new Contact_Assignments__c();
        insConAss.Candidate_Name__c = conList[0].Id;
        insConAss.Project__c = proj.Id;
        insConAss.Project_Task__c = task.Id;
        insConAss.Start_Date__c = currst;
        insConAss.End_Date__c = currend;
        insConAss.Status__c = 'Approved';
        insConAss.Rate_Card_Rate__c = cr[0].Id;
        insConAss.RecordTypeId = insRt;
        insert insConAss;
        
        //List<Contact_Assignments__c> insConAss1 = [SELECT Id, Rate_Card_Rate__c FROM Contact_Assignments__c WHERE Id =: insConAss.Id];
        insConAss.Rate_Card_Rate__c = null;
        update insConAss;
        
        List<Contact_Assignments__c> stdConAss = [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        stdConAss[0].Candidate_Name__c = conList[0].Id;
        stdConAss[0].Project__c = task.AcctSeed__Project__c;
        update stdConAss; 
                        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Draft';
        schList[0].Project__c = task.AcctSeed__Project__c;
        schList[0].Project_Task__c = task.Id;
        schList[0].Start_Date__c = currst;
        schList[0].End_Date__c = currend;
        schList[0].Start_Time__c = '06:15 AM';
        schList[0].End_Time__c = '06:45 AM';
        schList[0].Instructor__c = conList[0].Id;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task.Id;
        timeCardLine.AcctSeed__Project__c = task.AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = insConAss.Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
            
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Draft');
        insert day;
                
        List<Attendance__c> stuAtn = [SELECT Id, Name, Rejection_Reason__c, Attendance__c, Recall_Reason__c, Comments__c, Student__r.Name, Time_Card_Day__r.Late_Cancellation__c, Time_Card_Day__c, Student__c, Instructor__c, Date__c, Duration__c, Student_Approval_Status__c, Event__c FROM  Attendance__c LIMIT 2];
        stuAtn[0].Date__c = System.Today();
        stuAtn[0].Time_Card_Day__c = day.Id;
        stuAtn[0].Student_Approval_Status__c = 'Approved';
        update stuAtn[0];
        
        system.runAs(user) {
            TimeCardDayCommunityTranslator.mobileStudentTimeEntriesFormation(stdConAss, currst, currend, stuAtn, True, True);
        }
        Test.stopTest();
    }
    
    // To cover mobileStudentTimeEntriesFormation method in TimeCardDayCommunityTranslator
    private static testMethod void mobileStudentTimeEntriesFormation_Test_3(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
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
        
        Test.startTest();
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                
        Id usrId = UserInfo.getUserId();
                
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DLI_W_TO_Opportunities' LIMIT 1];
        
        String eflProRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('EFL_Projects').getRecordTypeId();
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'My Test Project',AcctSeed__Status__c = 'Inquiry',RecordTypeId = eflProRT, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10));
        insert proj;
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 1];
                
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(Name = 'Fringe - Holiday',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj.Id,Project_Task_Type__c = 'Fringe',AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Rate__c = 41);
        insert task;
        
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        Id insRt = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
                
        Contact_Assignments__c insConAss = new Contact_Assignments__c();
        insConAss.Candidate_Name__c = conList[0].Id;
        insConAss.Project__c = proj.Id;
        insConAss.Project_Task__c = task.Id;
        insConAss.Start_Date__c = currst;
        insConAss.End_Date__c = currend;
        insConAss.Status__c = 'Approved';
        insConAss.Rate_Card_Rate__c = cr[0].Id;
        insConAss.RecordTypeId = insRt;
        insert insConAss;
        
        //List<Contact_Assignments__c> insConAss1 = [SELECT Id, Rate_Card_Rate__c FROM Contact_Assignments__c WHERE Id =: insConAss.Id];
        insConAss.Rate_Card_Rate__c = null;
        update insConAss;
        
        List<Contact_Assignments__c> stdConAss = [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        stdConAss[0].Candidate_Name__c = conList[0].Id;
        stdConAss[0].Project__c = task.AcctSeed__Project__c;
        update stdConAss; 
                        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Draft';
        schList[0].Project__c = task.AcctSeed__Project__c;
        schList[0].Project_Task__c = task.Id;
        schList[0].Start_Date__c = currst;
        schList[0].End_Date__c = currend;
        schList[0].Start_Time__c = '06:15 AM';
        schList[0].End_Time__c = '06:45 AM';
        schList[0].Instructor__c = conList[0].Id;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task.Id;
        timeCardLine.AcctSeed__Project__c = task.AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = insConAss.Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
            
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Draft');
        insert day;
                
        List<Attendance__c> stuAtn = [SELECT Id, Name, Rejection_Reason__c, Attendance__c, Recall_Reason__c, Comments__c, Student__r.Name, Time_Card_Day__r.Late_Cancellation__c, Time_Card_Day__c, Student__c, Instructor__c, Date__c, Duration__c, Student_Approval_Status__c, Event__c FROM  Attendance__c LIMIT 2];
        stuAtn[0].Date__c = System.Today();
        stuAtn[0].Time_Card_Day__c = day.Id;
        stuAtn[0].Student_Approval_Status__c = 'Approved';
        update stuAtn[0];
        
        Date currStart = system.today().toStartofWeek().addDays(1);
        
        Date previuosWkStart = currStart.addDays(-7);
        Date previuosWkEnd = currEnd.addDays(-7);
        
        Date isOlderThanLast2WeekStart = previuosWkStart.addDays(-14);
        Date isOlderThanLast2WeekEnd = currEnd.addDays(-14);
        
        system.runAs(user) {
            TimeCardDayCommunityTranslator.mobileStudentTimeEntriesFormation(stdConAss, isOlderThanLast2WeekStart, isOlderThanLast2WeekEnd, stuAtn, True, True);
        }
        Test.stopTest();
    }
    
    // To cover instructorTimeEntryRowWrapperFormation method in TimeCardDayCommunityTranslator
    private static testMethod void instructorTimeEntryRowWrapperFormation_Test(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
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
        
        Test.startTest();
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                
        Id usrId = UserInfo.getUserId();
                
        List<Opportunity> opp = [SELECT Id FROM Opportunity WHERE RecordType.DeveloperName = 'DLI_W_TO_Opportunities' LIMIT 1];
        
        String eflProRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('EFL_Projects').getRecordTypeId();
        AcctSeed__Project__c proj = new AcctSeed__Project__c(Name = 'My Test Project',AcctSeed__Status__c = 'Inquiry',RecordTypeId = eflProRT, Project_Manager__c = usrId, AcctSeed__Opportunity__c = opp[0].Id, Start_Date__c = System.today(), End_Date__c = System.today().addDays(10), Default_Cost_Rate_Rate_Type__c = 'LT with Prep');
        insert proj;
        
        List<AcctSeed__GL_Account__c> glAccList = [SELECT Id, Name, AcctSeed__Sub_Type_1__c, AcctSeed__Sub_Type_2__c, AcctSeed__Active__c, AcctSeed__Type__c FROM AcctSeed__GL_Account__c LIMIT 1];
                
        AcctSeed__Project_Task__c task = new AcctSeed__Project_Task__c(Name = 'Fringe - Holiday',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj.Id,Project_Task_Type__c = 'Fringe',AcctSeed__Labor_GL_Account__c = glAccList[0].Id, Rate__c = 41);
        insert task;
        
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];
        
        Id insRt = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
                
        Contact_Assignments__c insConAss = new Contact_Assignments__c();
        insConAss.Candidate_Name__c = conList[0].Id;
        insConAss.Project__c = proj.Id;
        insConAss.Project_Task__c = task.Id;
        insConAss.Start_Date__c = currst;
        insConAss.End_Date__c = currend;
        insConAss.Status__c = 'Approved';
        insConAss.Rate_Card_Rate__c = cr[0].Id;
        insConAss.RecordTypeId = insRt;
        insert insConAss;
        
        //List<Contact_Assignments__c> insConAss1 = [SELECT Id, Rate_Card_Rate__c FROM Contact_Assignments__c WHERE Id =: insConAss.Id];
        insConAss.Rate_Card_Rate__c = null;
        update insConAss;
        
        List<Contact_Assignments__c> stdConAss = [SELECT Id, Name, Status__c, Start_Date__c, End_Date__c, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        stdConAss[0].Candidate_Name__c = conList[0].Id;
        stdConAss[0].Project__c = task.AcctSeed__Project__c;
        update stdConAss; 
                        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Draft';
        schList[0].Project__c = task.AcctSeed__Project__c;
        schList[0].Project_Task__c = task.Id;
        schList[0].Start_Date__c = currst;
        schList[0].End_Date__c = currend;
        schList[0].Start_Time__c = '06:15 AM';
        schList[0].End_Time__c = '06:45 AM';
        schList[0].Instructor__c = conList[0].Id;
        update schList;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task.Id;
        timeCardLine.AcctSeed__Project__c = task.AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = insConAss.Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
            
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Draft');
        insert day;

        List<Planned_Days_Off__c> pdos = [SELECT Id, Date__c, Description__c, Contact__r.Name FROM Planned_Days_Off__c LIMIT 2];
        system.runAs(user) {
            TimeCardDayCommunityTranslator.instructorTimeEntryRowWrapperFormation(currst, currend, 'My Test Project', stdConAss[0].Candidate_Name__r.Name, '', new List<AcctSeed__Time_Card_Line__c>(), new List<Accounting_Seed_Time_Snapshot__c>(), new List<AcctSeed__Project_Task__c>{task}, new List<Contact_Assignments__c>(), new Map<Id,Integer>(), new Map<Id,String>(), new List<Contact_Assignments__History>(), new List<AcctSeed__Cost_Rates__c>(), new List<Contact_Assignments__c>(), new Map<Id,List<Attendance__c>>(),false,pdos, new Set<Date>(), new Map<Id,String>(),new  Map<Id,Map<String,List<String>>>());
        }
        Test.stopTest();
    }
    
    // To cover mobileNotesFormation method in TimeCardDayCommunityTranslator
    private static testMethod void mobileNotesFormation_Test_1(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
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
        
        Test.startTest();
        
        List<AcctSeed__Time_Card_Day__c> timeCardDayList = [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Hours__c,Status__c,AcctSeed__Time_Card_Line__c,
            Total_Hours_Before_Approved__c,AcctSeed__Internal_Comment__c
        FROM AcctSeed__Time_Card_Day__c LIMIT 3];
        
        List<Accounting_Seed_Time_Snapshot__c> timeSnapshotList = new List<Accounting_Seed_Time_Snapshot__c> {
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator', Reference_Id__c = 'Test', Note_Type__c = 'Instructor Daily Entry Recall', Time_Card_Day__c = timeCardDayList[0].Id, Date__c = timeCardDayList[0].AcctSeed__Date__c, Hours__c = timeCardDayList[0].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[0].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[0].Status__c,Time_Card_Line__c = timeCardDayList[0].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[0].Total_Hours_Before_Approved__c),
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator', Reference_Id__c = 'Test Partial Reject', Note_Type__c = 'Student Daily Entry Reject',Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c),
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator', Reference_Id__c = 'Test Partial Reject', Note_Type__c = 'Instructor Daily Entry Student Hours Mismatch',Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c)
        };
        
        system.runAs(user) {
            TimeCardDayCommunityTranslator.mobileNotesFormation(currst, currend, timeSnapshotList);
        }
        Test.stopTest();
    }
    
    // To cover mobileNotesFormation method in TimeCardDayCommunityTranslator
    private static testMethod void mobileNotesFormation_Test_2(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
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
        
        Test.startTest();
        
        List<AcctSeed__Time_Card_Day__c> timeCardDayList = [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Hours__c,Status__c,AcctSeed__Time_Card_Line__c,
            Total_Hours_Before_Approved__c,AcctSeed__Internal_Comment__c
        FROM AcctSeed__Time_Card_Day__c LIMIT 3];
        
        List<Accounting_Seed_Time_Snapshot__c> timeSnapshotList = new List<Accounting_Seed_Time_Snapshot__c> {
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator',  Note_Type__c = 'Instructor Daily Entry Recall', Time_Card_Day__c = timeCardDayList[0].Id, Date__c = timeCardDayList[0].AcctSeed__Date__c, Hours__c = timeCardDayList[0].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[0].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[0].Status__c,Time_Card_Line__c = timeCardDayList[0].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[0].Total_Hours_Before_Approved__c),
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator',  Note_Type__c = 'Student Daily Entry Reject',Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c),
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator',  Note_Type__c = 'Instructor Daily Entry Student Hours Mismatch',Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c)
        };
        
        system.runAs(user) {
            TimeCardDayCommunityTranslator.mobileNotesFormation(currst, currend, timeSnapshotList);
        }
        Test.stopTest();
    }
    
    // To cover weekSummaryDetailFormation method in TimeCardDayCommunityTranslator
    private static testMethod void weekSummaryDetailFormation_Test_1(){
            
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Date today = system.today();
        Date currst;
        
        //if today = sunday need to load the last week data - because saleforce start of the week is sunday
        if(today.toStartofWeek() == today) {
            currst = today.addDays(-1).toStartofWeek().addDays(1);
        }else {
            currst = today.toStartofWeek().addDays(1);
        } 
        Date currend = currst.addDays(6);
        
        Test.startTest();
            
            List<AcctSeed__Time_Card_Day__c> timeCardDayList = [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Hours__c,Status__c,AcctSeed__Time_Card_Line__c,
                Total_Hours_Before_Approved__c,AcctSeed__Internal_Comment__c
            FROM AcctSeed__Time_Card_Day__c LIMIT 3];
        
            List<Accounting_Seed_Time_Snapshot__c> timeSnapshotList = new List<Accounting_Seed_Time_Snapshot__c> {
                new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator',  Note_Type__c = 'Instructor Daily Entry Recall', Time_Card_Day__c = timeCardDayList[0].Id, Date__c = timeCardDayList[0].AcctSeed__Date__c, Hours__c = timeCardDayList[0].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[0].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[0].Status__c,Time_Card_Line__c = timeCardDayList[0].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[0].Total_Hours_Before_Approved__c),
                new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator',  Note_Type__c = 'Student Daily Entry Reject',Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c),
                new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator',  Note_Type__c = 'Instructor Daily Entry Student Hours Mismatch',Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c)
            };
            
            List<AcctSeed__Project_Task__c> taskRecords  = [SELECT Id, Name, AcctSeed__Project__r.Training_Location__c, AcctSeed__Project__r.Training_Location__r.Name, Project_Task_Type__c, AcctSeed__Project__c, Billable__c, Parent_Project_Task__c, RecordType.DeveloperName, AcctSeed__Project__r.Default_Cost_Rate_Rate_Type__c FROM AcctSeed__Project_Task__c LIMIT 2];
            
            List<AcctSeed__Time_Card_Line__c> lineList = [SELECT Id, Name, AcctSeed__Project_Task__c, Completed__c, Location__c, Location__r.Name FROM AcctSeed__Time_Card_Line__c LIMIT 2];
            
            List<Contact_Assignments__c> caRecord = [SELECT Id, Project_Task__c, Rate_Card_Rate__c, Oral_Exam_Date_Time__c, Start_Date__c, End_Date__c, Rate_Card_Rate__r.Payroll_Item__c, Rate_Card_Rate__r.Non_Billable_Payroll_Item__c FROM Contact_Assignments__c LIMIT 3];
        
            TimeCardDayCommunityTranslator.weekSummaryDetailFormation(currst, currend, '', '', '', lineList, timeSnapshotList, taskRecords, caRecord, new Map<Id,Integer>(), new Map<Id,String>(), new List<Contact_Assignments__History>(), new List<AcctSeed__Cost_Rates__c>(), new List<Contact_Assignments__c>(), new List<Attendance__c>(), false, new List<Planned_Days_Off__c>(), new Set<Date> (), new Map<Id,String>());
            
        Test.stopTest();
    }
    
    // To cover weekSummaryDetailFormation method in TimeCardDayCommunityTranslator
    private static testMethod void weekSummaryDetailFormation_Test_2(){
            
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        Date today = system.today();
        Date currst;
        
        //if today = sunday need to load the last week data - because saleforce start of the week is sunday
        if(today.toStartofWeek() == today) {
            currst = today.addDays(-1).toStartofWeek().addDays(1);
        }else {
            currst = today.toStartofWeek().addDays(1);
        } 
        Date currend = currst.addDays(6);
        
        Test.startTest();
            
            List<AcctSeed__Time_Card_Day__c> timeCardDayList = [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Hours__c,Status__c,AcctSeed__Time_Card_Line__c,
                Total_Hours_Before_Approved__c,AcctSeed__Internal_Comment__c
            FROM AcctSeed__Time_Card_Day__c LIMIT 3];
        
            List<Accounting_Seed_Time_Snapshot__c> timeSnapshotList = new List<Accounting_Seed_Time_Snapshot__c> {
                new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator',  Note_Type__c = 'Instructor Daily Entry Recall', Time_Card_Day__c = timeCardDayList[0].Id, Date__c = timeCardDayList[0].AcctSeed__Date__c, Hours__c = timeCardDayList[0].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[0].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[0].Status__c,Time_Card_Line__c = timeCardDayList[0].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[0].Total_Hours_Before_Approved__c),
                new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator',  Note_Type__c = 'Student Daily Entry Reject',Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c),
                new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator',  Note_Type__c = 'Instructor Daily Entry Student Hours Mismatch',Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c)
            };
            
            List<AcctSeed__Project_Task__c> taskRecords  = [SELECT Id, Name, AcctSeed__Project__r.Training_Location__c, AcctSeed__Project__r.Training_Location__r.Name, Project_Task_Type__c, AcctSeed__Project__c, Billable__c, Parent_Project_Task__c, RecordType.DeveloperName, AcctSeed__Project__r.Default_Cost_Rate_Rate_Type__c, Payroll_Item__c FROM AcctSeed__Project_Task__c LIMIT 2];
            taskRecords[0].Project_Task_Type__c = 'Fringe';
            update taskRecords[0];
            
            List<Planned_Days_Off__c> pdoList = [SELECT Id, Date__c, Contact__r.Name, Description__c FROM Planned_Days_Off__c LIMIT 4];
            List<AcctSeed__Time_Card_Line__c> lineList = [SELECT Id, Name, AcctSeed__Project_Task__c, Completed__c, Location__c, Location__r.Name FROM AcctSeed__Time_Card_Line__c LIMIT 2];
            
            List<Contact_Assignments__c> caRecord = [SELECT Id, Project_Task__c, Rate_Card_Rate__c, Oral_Exam_Date_Time__c, Start_Date__c, End_Date__c, Rate_Card_Rate__r.Payroll_Item__c, Rate_Card_Rate__r.Non_Billable_Payroll_Item__c FROM Contact_Assignments__c LIMIT 3];
        
            TimeCardDayCommunityTranslator.weekSummaryDetailFormation(currst, currend, '', '', '', lineList, timeSnapshotList, taskRecords, caRecord, new Map<Id,Integer>(), new Map<Id,String>(), new List<Contact_Assignments__History>(), new List<AcctSeed__Cost_Rates__c>(), new List<Contact_Assignments__c>(), new List<Attendance__c>(), false, pdoList, new Set<Date> (), new Map<Id,String>());
            
        Test.stopTest();
    }
    
    // To cover timeSubmissionTableFormation method in TimeCardDayCommunityTranslator
    private static testMethod void timeSubmissionTableFormation_Test(){
    
        List<AcctSeed__Time_Card_Day__c> timeCardDayList = [SELECT Id,Name, Week_Day__c, AcctSeed__Date__c, Start_Time1__c, End_Time1__c,
            Start_Time2__c, End_Time2__c, Total_Hours_Before_Approved__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.DLS_Class__c,
            AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name, AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c, Status__c,
            AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c, Student_Approval_Status__c, Submitted_Date_Time__c,
            AcctSeed__Time_Card_Line__r.Completed__c,AcctSeed__Time_Card_Line__r.Contact_Assignment__r.RecordType.DeveloperName 
            FROM AcctSeed__Time_Card_Day__c];
        
        List<AcctSeed__Project__c> projRecs = [SELECT Id, (SELECT Id, Candidate_Name__r.FirstName, Candidate_Name__r.LastName FROM Contact_Assignments__r) FROM AcctSeed__Project__c];
        
        TimeCardDayCommunityTranslator.timeSubmissionTableFormation(timeCardDayList, projRecs);
    }
    
    // To cover StuApprovalInstructorDayRowEntries method in TimeCardDayCommunityTranslator
    private static testMethod void StuApprovalInstructorDayRowEntries_Test(){
    
        List<AcctSeed__Project__c> projRecs = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c];
        
        List<User> users = [SELECT Id, ContactId FROM User];
        
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,
            AcctSeed__Project__c, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.Project_Task_Type__c, AcctSeed__Project_Task__r.Name,
            Location__r.Name, 
                (SELECT Id,Name, Week_Day__c, AcctSeed__Date__c, Start_Time1__c, End_Time1__c,
                Start_Time2__c, End_Time2__c, Total_Hours_Before_Approved__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.DLS_Class__c,
                AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name, AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c, Status__c,
                AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c, Student_Approval_Status__c, Submitted_Date_Time__c,
                AcctSeed__Time_Card_Line__r.Completed__c FROM AcctSeed__Time_Card_Days__r)
            FROM AcctSeed__Time_Card_Line__c];
        
        Test.startTest();
        
            List<Contact_Assignments__c> cas = [SELECT Id, Candidate_Name__r.FirstName, Candidate_Name__r.LastName FROM Contact_Assignments__c];
            
            List<Planned_Days_Off__c> pdos = [SELECT Id, Date__c FROM Planned_Days_Off__c];
            
            TimeCardDayCommunityTranslator.StuApprovalInstructorDayRowEntries(projRecs[0].Id, Date.Today().addDays(-2), Date.Today().addDays(10), '123/test' , new List<Accounting_Seed_Time_Snapshot__c>(), users, new Set<Id> {projRecs[0].Id}, lines, cas, pdos, new Map<Id, Boolean>());
       
       Test.stopTest();
    }
}