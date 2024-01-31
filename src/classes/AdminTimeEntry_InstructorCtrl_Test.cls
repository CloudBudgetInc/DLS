@isTest
private class AdminTimeEntry_InstructorCtrl_Test{

    @testSetup static void setupMethod(){
        
        Test.startTest();
            List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment(); 
            List<MTT_Location__c> location = TestClassUtil.createTestLocations();
        Test.stopTest();
        
        List<Attendance__c> stuAtn = TestClassUtil.createTestAttendance();
        List<AcctSeed__Cost_Rates__c> costRates = TestClassUtil.createTestCostRates();
        List<AcctSeed__Time_Card_Day__c>  tcd = TestClassUtil.createTestTimeCardDay();        
        List<System_Values__c> sysVal = new List<System_Values__c>{new System_Values__c(Name ='TimeLog_Locking_Date', Value__c = '2016-06-01')};
        insert sysVal;
        
    }
    
    // To cover getInitialFilterValues() method
    private static testMethod void myTest1(){
    
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' ORDER BY Name ASC LIMIT 1];
        System.debug('conList==='+conList);
        
        Map<Id,String> contactIdnameMap = new Map<Id,String>();
        contactIdnameMap.put(conList[0].Id, conList[0].Name);
        
        String s = AdminTimeEntry_InstructorCtrl.getInitialFilterValues(); 
        TimeCardDayDomain.AdminTimeEntryDetails det = (TimeCardDayDomain.AdminTimeEntryDetails)JSON.deserialize(s, TimeCardDayDomain.AdminTimeEntryDetails.class);
        //System.assertEquals(contactIdnameMap, det.contactIdnameMap); 
    }
    
    // To cover getLookupRecords() method
    private static testMethod void myTest2(){
    
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' ORDER BY Name ASC LIMIT 1];
        System.debug('conList==='+conList);
        
        List<sObject> objec = AdminTimeEntry_InstructorCtrl.getLookupRecords(conList[0].Name, 'Contact', 'Name', '', new List<String>{}); 
    }
    
    // To cover getProjectFilterDetail() method
    private static testMethod void myTest3(){
    
        Id stdId = NULL;
        Id insId = NULL;
        
        for(Contact c  : [SELECT Id, RecordType.DeveloperName FROM Contact WHERE RecordType.DeveloperName IN ('Student', 'Candidate')]){
            if(c.RecordType.DeveloperName == 'Candidate'){
                insId = c.Id;
            }
            if(c.RecordType.DeveloperName == 'Student'){
                stdId = c.Id;
            }
        }
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c FROM AcctSeed__Project__c LIMIT 1];
        System.debug('projs ======'+projs);
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        Date weekStart = Date.Today().toStartofWeek().addDays(1);
        Date weekEnd = weekStart.addDays(6);
        
        Date caFilterDate = weekStart.addDays(-14);
                
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projs[0].Id, Candidate_Name__c = insId, Start_Date__c = caFilterDate, End_Date__c = weekEnd, Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Instructor'),
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = projs[0].Id, Candidate_Name__c = stdId, Start_Date__c = caFilterDate, End_Date__c = weekEnd, Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Student')
        };
        
        Test.StartTest();
        
            insert conAssignRecs; 
            
        String s = AdminTimeEntry_InstructorCtrl.getProjectFilterDetail(String.valueOf(weekStart), String.valueOf(weekEnd), String.valueOf(insId));
        List<TimeCardDayCommunityDomain.ProjectStudentInfo> projInfo = (List<TimeCardDayCommunityDomain.ProjectStudentInfo>)JSON.deserialize(s, List<TimeCardDayCommunityDomain.ProjectStudentInfo>.class);
        System.assertEquals(projs[0].Id, projInfo[0].projectId);
        
        Test.stopTest();
    }
    
    // To cover getProjectFilterDetail() method
    private static testMethod void myTest3a(){
    
        Id stdId = NULL;
        Id insId = NULL;
        
        for(Contact c  : [SELECT Id, RecordType.DeveloperName FROM Contact WHERE RecordType.DeveloperName IN ('Student', 'Candidate')]){
            if(c.RecordType.DeveloperName == 'Candidate'){
                insId = c.Id;
            }
            if(c.RecordType.DeveloperName == 'Student'){
                stdId = c.Id;
            }
        }
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        Id cdRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('CD_Projects').getRecordTypeId();
        
        Test.StartTest();
        
        List<AcctSeed__Project__c> projs = [SELECT Id, AcctSeed__Opportunity__c, Training_Location__c, RecordTypeId FROM AcctSeed__Project__c LIMIT 1];
        projs[0].Training_Location__c = loc.Id;
        projs[0].RecordTypeId = cdRTId;
        update projs[0];
        System.debug('projs ======'+projs);
        
        Id insRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        Date weekStart = Date.Today().toStartofWeek().addDays(1);
        Date weekEnd = weekStart.addDays(6);
        
        Date caFilterDate = weekStart.addDays(-14);
                
        List<Contact_Assignments__c> conAssignRecs = new List<Contact_Assignments__c>{
            new Contact_Assignments__c(RecordTypeId = insRTId, Project__c = projs[0].Id, Candidate_Name__c = insId, Start_Date__c = caFilterDate, End_Date__c = weekEnd, Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Instructor'),
            new Contact_Assignments__c(RecordTypeId = stdRTId, Project__c = projs[0].Id, Candidate_Name__c = stdId, Start_Date__c = caFilterDate, End_Date__c = weekEnd, Opportunity_Name__c = projs[0].AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Student')
        };
                
        insert conAssignRecs; 
            
        String s = AdminTimeEntry_InstructorCtrl.getProjectFilterDetail(String.valueOf(weekStart), String.valueOf(weekEnd), String.valueOf(insId));
        List<TimeCardDayCommunityDomain.ProjectStudentInfo> projInfo = (List<TimeCardDayCommunityDomain.ProjectStudentInfo>)JSON.deserialize(s, List<TimeCardDayCommunityDomain.ProjectStudentInfo>.class);
        System.assertEquals(projs[0].Id, projInfo[0].projectId);
        
        Test.stopTest();
    }
    
    // To cover getContactRelatedUser() method
    private static testMethod void myTest4(){
    
        List<Contact> conList = [SELECT Id, FirstName, LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' ORDER BY Name ASC LIMIT 1];
        System.debug('conList==='+conList);
        
        Id p = [SELECT Id FROM Profile WHERE Name='Standard User'].Id;
        System.debug('p=========='+p);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname=conList[0].LastName, languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                timezonesidkey='America/Los_Angeles', username='adminusr@ssemail.com');
       
        insert user;
        
        Boolean b = AdminTimeEntry_InstructorCtrl.getContactRelatedUser(conList[0].Id);
        System.assertEquals(TRUE, b);
    }
    
    // To cover getContactRelatedUser() method
    private static testMethod void myTest4a(){
    
        List<Contact> conList = [SELECT Id, FirstName, LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' ORDER BY Name ASC LIMIT 1];
        conList[0].FirstName = 'AdminCon';
        update conList[0];
        System.debug('conList==='+conList);
        
        Test.startTest();
        
        Id p = [SELECT Id FROM Profile WHERE Name='Standard User'].Id;
        System.debug('p=========='+p);
        
        User user = new User(alias='test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', FirstName='AdminCon', LastName=conList[0].LastName, languagelocalekey='en_US',
                localesidkey='en_US', profileid=p, country='United States',IsActive=true,
                timezonesidkey='America/Los_Angeles', username='newadminusr@ssemail.com');
       
        insert user;        
        Boolean b = AdminTimeEntry_InstructorCtrl.getContactRelatedUser(conList[0].Id);
        Test.stopTest();
    }
    
    // To cover getSpecificWeekTCDDetials() method
    private static testMethod void myTest5(){
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        List<Contact> conList = [SELECT Id, FirstName, LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        conList[0].FirstName = 'AdminCon';
        update conList[0];
        
        String studentNames = 'AdminCon'+'.'+conList[0].LastName.subString(0,1);
        
        Test.startTest();
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c, Name FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        System.debug('projects========'+projects);
                
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        task[0].Project_Task_Type__c = 'Preparation time';
        update task[0];
        System.debug('task ====='+task);
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        schList[0].Instructor__c = conList[0].Id;
        schList[0].Start_Time__c = '03:00 PM';
        schList[0].End_Time__c = '05:00 PM';
        update schList;
        System.debug('schList===='+schList);
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        insert timeCardLine;
        
        AdminTimeEntry_InstructorCtrl.getSpecificWeekTCDDetials(String.valueOf(weekStart1), String.valueOf(WeekEnd1), projects[0].Id, conList[0].Id, studentNames);
        
        Test.stopTest();
    }
    
    // To cover getSpecificWeekTCDDetials() method
    private static testMethod void myTest5a(){
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        List<Contact> conList = [SELECT Id, FirstName, LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        conList[0].FirstName = 'AdminCon';
        update conList[0];
        
        String studentNames = 'AdminCon'+'.'+conList[0].LastName.subString(0,1);
        
        Test.startTest();
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<AcctSeed__Project_Task__c> tasks = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Language Training' LIMIT 2];
        tasks[0].Project_Task_Type__c = 'Preparation time';
        tasks[1].Project_Task_Type__c = 'Preparation time';
        update tasks;
        System.debug('tasks ====='+tasks);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Id IN : tasks];
        
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c, RecordTypeId, Name FROM AcctSeed__Project__c WHERE Id = :task[0].AcctSeed__Project__c];
        proj[0].RecordTypeId = dodaRTId ;
        update proj[0];
        
        List<AcctSeed__Project__c> p = [SELECT Id, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        System.debug('RecordType.DeveloperName:::'+p[0].RecordType.DeveloperName);
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        conAss[0].Project__c = task[0].AcctSeed__Project__c;
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<Schedule__c> schList = new List<Schedule__c>();
        
        for(Schedule__c s : [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c LIMIT 2]){
            s.Status__c = 'Active';
            s.Project__c = task[0].AcctSeed__Project__c;
            s.Project_Task__c = task[0].Id;
            s.Start_Date__c = weekStart1;
            s.End_Date__c = WeekEnd1;
            s.Instructor__c = conList[0].Id;
            s.Start_Time__c = '10:00 AM';
            s.End_Time__c = '02:00 PM';
            schList.add(s);
        }
        update schList;
        System.debug('schList===='+schList);
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        insert timeCardLine;
        
        List<Events__c> events = [SELECT Id FROM Events__c LIMIT 2];
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Draft');
        insert day;
        
        Id pdoRTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Training_Holidays').getRecordTypeId();
        
        Planned_Days_Off__c pdo = new Planned_Days_Off__c(RecordTypeId = pdoRTId, Type__c = 'DLI-W LT', Contact__c = conList[0].Id,Date__c=weekStart1,Description__c='Test',Requested_Reschedule_Date__c=System.today()+15, Status__c = 'Approved');
        insert pdo;
                
        List<Attendance__c> attendanceList = new List<Attendance__c>{
            
            new Attendance__c(Event__c = events[0].Id, Student__c = conList[0].Id, Date__c = weekStart1, Time_Card_Day__c = day.Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = conList[0].Id),
            new Attendance__c(Event__c = events[1].Id, Student__c = conList[0].Id, Date__c = WeekEnd1, Time_Card_Day__c = day.Id, Student_Approval_Status__c = 'Submitted', Duration__c = 2, Instructor__c = conList[0].Id)
        };
        insert attendanceList;
            
        String s = AdminTimeEntry_InstructorCtrl.getSpecificWeekTCDDetials(String.valueOf(weekStart1), String.valueOf(WeekEnd1), task[0].AcctSeed__Project__c, conList[0].Id, studentNames);
        
        Test.stopTest();
    }
    
    // To cover newRowDetailFormation() method
    private static testMethod void myTest6(){
    
        
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        List<Contact> conList = [SELECT Id, FirstName, LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        conList[0].FirstName = 'AdminCon';
        update conList[0];
        
        String studentNames = 'AdminCon'+'.'+conList[0].LastName.subString(0,1);
        
        Test.startTest();
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<AcctSeed__Project_Task__c> tasks = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Language Training' LIMIT 2];
        tasks[0].Project_Task_Type__c = 'Preparation time';
        tasks[1].Project_Task_Type__c = 'Preparation time';
        update tasks;
        System.debug('tasks ====='+tasks);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Id IN : tasks];
        
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c, RecordTypeId, Name FROM AcctSeed__Project__c WHERE Id = :task[0].AcctSeed__Project__c];
        proj[0].RecordTypeId = dodaRTId ;
        update proj[0];
        
        List<AcctSeed__Project__c> p = [SELECT Id, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        System.debug('RecordType.DeveloperName:::'+p[0].RecordType.DeveloperName);
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        conAss[0].Project__c = task[0].AcctSeed__Project__c;
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<Schedule__c> schList = new List<Schedule__c>();
        
        for(Schedule__c s : [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c LIMIT 2]){
            s.Status__c = 'Active';
            s.Project__c = task[0].AcctSeed__Project__c;
            s.Project_Task__c = task[0].Id;
            s.Start_Date__c = weekStart1;
            s.End_Date__c = WeekEnd1;
            s.Instructor__c = conList[0].Id;
            s.Start_Time__c = '10:00 AM';
            s.End_Time__c = '02:00 PM';
            schList.add(s);
        }
        update schList;
        System.debug('schList===='+schList);
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        insert timeCardLine;
        
        Map<String, Object> obj = new Map<String, Object>();
        obj.put('project', task[0].AcctSeed__Project__c);
        obj.put('startDate', weekStart1);
        obj.put('endDate', WeekEnd1);
        obj.put('contactId', conList[0].Id);
        obj.put('task', task[0].Id);
        obj.put('seqNum', 2); 
        
        String s = AdminTimeEntry_InstructorCtrl.newRowDetailFormation(JSON.serialize(obj));
        TimeCardDayCommunityDomain.InstructorDayDetails newRow = (TimeCardDayCommunityDomain.InstructorDayDetails)JSON.deserialize(s, TimeCardDayCommunityDomain.InstructorDayDetails.class);
        System.assertEquals(task[0].AcctSeed__Project__c, newRow.dayEntries[0].projectId);
        Test.stopTest();
    }
    
    // To cover newRowDetailFormation() method
    private static testMethod void myTest6a(){
    
        
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        List<Contact> conList = [SELECT Id, FirstName, LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        conList[0].FirstName = 'AdminCon';
        update conList[0];
        
        String studentNames = 'AdminCon'+'.'+conList[0].LastName.subString(0,1);
        
        Test.startTest();
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<AcctSeed__Project_Task__c> tasks = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Language Training' LIMIT 2];
        tasks[0].Project_Task_Type__c = 'Preparation time';
        tasks[1].Project_Task_Type__c = 'Preparation time';
        update tasks;
        System.debug('tasks ====='+tasks);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Id IN : tasks];
        
        Id dodaRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c, RecordTypeId, Name FROM AcctSeed__Project__c WHERE Id = :task[0].AcctSeed__Project__c];
        proj[0].RecordTypeId = dodaRTId ;
        update proj[0];
        
        List<AcctSeed__Project__c> p = [SELECT Id, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        System.debug('RecordType.DeveloperName:::'+p[0].RecordType.DeveloperName);
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        conAss[0].Project__c = task[0].AcctSeed__Project__c;
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<Schedule__c> schList = new List<Schedule__c>();
        
        for(Schedule__c s : [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c LIMIT 2]){
            s.Status__c = 'Active';
            s.Project__c = task[0].AcctSeed__Project__c;
            s.Project_Task__c = task[0].Id;
            s.Start_Date__c = weekStart1;
            s.End_Date__c = WeekEnd1;
            s.Instructor__c = conList[0].Id;
            s.Start_Time__c = '02:00 PM';
            s.End_Time__c = '05:00 PM';
            schList.add(s);
        }
        update schList;
        System.debug('schList===='+schList);
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        insert timeCardLine;
        
        Map<String, Object> obj = new Map<String, Object>();
        obj.put('project', task[0].AcctSeed__Project__c);
        obj.put('startDate', weekStart1);
        obj.put('endDate', WeekEnd1);
        obj.put('contactId', conList[0].Id);
        obj.put('task', task[0].Id);
        obj.put('seqNum', 2); 
        
        String s = AdminTimeEntry_InstructorCtrl.newRowDetailFormation(JSON.serialize(obj));
        TimeCardDayCommunityDomain.InstructorDayDetails newRow = (TimeCardDayCommunityDomain.InstructorDayDetails)JSON.deserialize(s, TimeCardDayCommunityDomain.InstructorDayDetails.class);
        System.assertEquals(task[0].AcctSeed__Project__c, newRow.dayEntries[0].projectId);
        
        Test.stopTest();
    }
    
    // To cover getExistingTCDsForOtherProjects() method
    private static testMethod void myTestMethod7(){
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
        
        Test.startTest();
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                       
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
        
        List<AcctSeed__Project__c> projects1 = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id != :conAss[0].Project__c];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
      
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
       
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
       
        String s = AdminTimeEntry_InstructorCtrl.getExistingTCDsForOtherProjects(conList[0].Id, String.valueOf(System.Today()), String.valueOf(System.Today()), projects1[0].Id);
        Map<Date,List<TimeCardDayCommunityDomain.DayEntries>> dateEntryMap = (Map<Date,List<TimeCardDayCommunityDomain.DayEntries>>)JSON.deserialize(s, Map<Date,List<TimeCardDayCommunityDomain.DayEntries>>.class);
        System.assertEquals(2.00, Decimal.valueOf(dateEntryMap.get(System.Today())[0].dayHours));
        
        Test.stopTest();
    }
    /*
    // To cover dmlOperationMethod() method
    private static testMethod void myTestMethod8(){
    
        Date myDate1 = System.today().addDays(7);
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        List<Contact> conList = [SELECT Id, FirstName, LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
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
        Test.startTest();
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        //List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        //System.debug('projects========'+projects);
                 
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        schList[0].Instructor__c = conList[0].Id;
        schList[0].Start_Time__c = '03:00 PM';
        schList[0].End_Time__c = '05:00 PM';
        update schList;
        System.debug('schList===='+schList);
        
        List<Events__c> eve = [SELECT Id FROM Events__c LIMIT 1];
        eve[0].Schedule__c = schList[0].Id;
        eve[0].SequenceNo__c = 1;
        eve[0].Instructor__c = conList[0].Id;
        eve[0].Date__c = weekStart1;
        eve[0].Project__c = task[0].AcctSeed__Project__c;
        eve[0].Status__c = 'Scheduled';
        update eve[0];
        System.debug('event ========='+eve[0]);
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        dayEntry.dayId = NULL;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = weekStart1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = TRUE;
        dayEntry.TaskType = 'Language Training';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '03:15 PM';
        dayEntry.endTime1 = '04:45 PM';
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
        dayEntry.hideFromStudent = FALSE;
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityDomain.StudentEntry stdEntry = new TimeCardDayCommunityDomain.StudentEntry();
        List<TimeCardDayCommunityDomain.StudentEntry> stdEntryList = new List<TimeCardDayCommunityDomain.StudentEntry>();
                
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        stdEntry.studentId = conList[0].Id;
        stdEntry.hours = '2.5';
        stdEntry.dateVal = weekStart1;
        stdEntry.comments = 'Test';
        stdEntry.dayId = day.Id;
        stdEntry.isNew = TRUE;
        stdEntryList.add(stdEntry);
        
        AdminTimeEntry_InstructorCtrl.dmlOperationMethod(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, task[0].AcctSeed__Project__c, 'Revert', JSON.Serialize(dayEntryList), JSON.Serialize(stdEntryList), 'mytest comments', new List<String>{});
        Test.stopTest();
    }
    
    // To cover dmlOperationMethod() method
    private static testMethod void myTestMethod8a(){
       
        List<Contact> conList = [SELECT Id, FirstName, LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id, AcctSeed__Start_Date__c, AcctSeed__End_Date__c FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        Date myDate1 = System.today();
        Date weekStart1 = tcp[0].AcctSeed__Start_Date__c;
        Date WeekEnd1 = tcp[0].AcctSeed__End_Date__c;
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
        Test.startTest();
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        //List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        //System.debug('projects========'+projects);
           
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        schList[0].Instructor__c = conList[0].Id;
        schList[0].Start_Time__c = '03:00 PM';
        schList[0].End_Time__c = '05:00 PM';
        update schList;
        System.debug('schList===='+schList);
        
        List<Events__c> eve = [SELECT Id FROM Events__c LIMIT 1];
        eve[0].Schedule__c = schList[0].Id;
        eve[0].SequenceNo__c = 1;
        eve[0].Instructor__c = conList[0].Id;
        eve[0].Date__c = weekStart1;
        eve[0].Project__c = task[0].AcctSeed__Project__c;
        eve[0].Status__c = 'Scheduled';
        update eve[0];
        System.debug('event ========='+eve[0]);
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = weekStart1, Status__c = 'Submitted');
        insert day;
        
        dayEntry.dayId = day.Id;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = weekStart1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = FALSE;
        dayEntry.TaskType = 'Language Training';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '03:15 PM';
        dayEntry.endTime1 = '04:45 PM';
        dayEntry.lateCancellation = TRUE;
        dayEntry.cancellationReason = 'Just for Demo';
        dayEntry.costrateId = costRate[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = task[0].AcctSeed__Project__c;
        dayEntry.payrollItem = 'ADM';
        dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = TRUE;
        dayEntry.hideFromStudent = FALSE;
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityDomain.StudentEntry stdEntry = new TimeCardDayCommunityDomain.StudentEntry();
        List<TimeCardDayCommunityDomain.StudentEntry> stdEntryList = new List<TimeCardDayCommunityDomain.StudentEntry>();
                        
        stdEntry.studentId = conList[0].Id;
        stdEntry.hours = '4.0';
        stdEntry.dateVal = weekStart1;
        stdEntry.comments = 'Test';
        stdEntry.dayId = day.Id;
        stdEntry.isNew = TRUE;
        stdEntryList.add(stdEntry);
                
        AdminTimeEntry_InstructorCtrl.dmlOperationMethod(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, task[0].AcctSeed__Project__c, 'Revert', JSON.Serialize(dayEntryList), JSON.Serialize(stdEntryList), 'mytest comments', new List<String>{});
        Test.stopTest();
    }
    
    // To cover dmlOperationMethod() method
    private static testMethod void myTestMethod8b(){
       
        List<Contact> conList = [SELECT Id, FirstName, LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id, AcctSeed__Start_Date__c, AcctSeed__End_Date__c FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        Date myDate1 = System.today();
        Date weekStart1 = tcp[0].AcctSeed__Start_Date__c;
        Date WeekEnd1 = tcp[0].AcctSeed__End_Date__c;
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
        Test.startTest();
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        //List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :proj[0].Id];
        //System.debug('projects========'+projects);
           
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        schList[0].Instructor__c = conList[0].Id;
        schList[0].Start_Time__c = '03:00 PM';
        schList[0].End_Time__c = '05:00 PM';
        update schList;
        System.debug('schList===='+schList);
        
        List<Events__c> eve = [SELECT Id FROM Events__c LIMIT 1];
        eve[0].Schedule__c = schList[0].Id;
        eve[0].SequenceNo__c = 1;
        eve[0].Instructor__c = conList[0].Id;
        eve[0].Date__c = weekStart1;
        eve[0].Project__c = task[0].AcctSeed__Project__c;
        eve[0].Status__c = 'Scheduled';
        update eve[0];
        System.debug('event ========='+eve[0]);
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = weekStart1, Status__c = 'Submitted');
        insert day;
        
        dayEntry.dayId = day.Id;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = weekStart1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = FALSE;
        dayEntry.TaskType = 'Preparation time';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '03:15 PM';
        dayEntry.endTime1 = '04:45 PM';
        dayEntry.lateCancellation = TRUE;
        dayEntry.cancellationReason = 'Just for Demo';
        dayEntry.costrateId = costRate[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = task[0].AcctSeed__Project__c;
        dayEntry.payrollItem = 'ADM';
        dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = TRUE;
        dayEntry.hideFromStudent = FALSE;
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityDomain.StudentEntry stdEntry = new TimeCardDayCommunityDomain.StudentEntry();
        List<TimeCardDayCommunityDomain.StudentEntry> stdEntryList = new List<TimeCardDayCommunityDomain.StudentEntry>();
                        
        stdEntry.studentId = conList[0].Id;
        stdEntry.hours = '4.0';
        stdEntry.dateVal = weekStart1;
        stdEntry.comments = 'Test';
        stdEntry.dayId = day.Id;
        stdEntry.isNew = TRUE;
        stdEntryList.add(stdEntry);
               
        String s = AdminTimeEntry_InstructorCtrl.dmlOperationMethod(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, task[0].AcctSeed__Project__c, 'Revert', JSON.Serialize(dayEntryList), JSON.Serialize(stdEntryList), 'mytest comments', new List<String>{});
        System.assertEquals('SUCCESS', s);
        Test.stopTest(); 
    }
    */
    // To cover dmlOperationMethod() method
    private static testMethod void myTestMethod8c(){
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        List<Contact> conList = [SELECT Id, FirstName, LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        costRate[0].Contact__c = conList[0].Id;
        costRate[0].Rate_Type__c = 'DLI-21 SCA LT';
        update costRate[0];
        
        Test.startTest();  
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0];
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];        
                                        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        schList[0].Instructor__c = conList[0].Id;
        schList[0].Start_Time__c = '03:00 PM';
        schList[0].End_Time__c = '05:00 PM';
        update schList;
        
        List<Events__c> eve = [SELECT Id FROM Events__c LIMIT 1];
        eve[0].Schedule__c = schList[0].Id;
        eve[0].SequenceNo__c = 1;
        eve[0].Instructor__c = conList[0].Id;
        eve[0].Date__c = weekStart1;
        eve[0].Project__c = task[0].AcctSeed__Project__c;
        eve[0].Status__c = 'Scheduled';
        update eve[0];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        insert timeCardLine;
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
                
        dayEntry.dayId = day.Id;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = weekStart1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = FALSE;
        dayEntry.TaskType = 'Language Training';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '03:15 PM';
        dayEntry.endTime1 = '04:45 PM';
        dayEntry.lateCancellation = TRUE;
        dayEntry.cancellationReason = 'Just for Demo';
        dayEntry.costrateId = costRate[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = task[0].AcctSeed__Project__c;
        dayEntry.payrollItem = 'R';
        //dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = FALSE;
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityDomain.StudentEntry stdEntry = new TimeCardDayCommunityDomain.StudentEntry();
        List<TimeCardDayCommunityDomain.StudentEntry> stdEntryList = new List<TimeCardDayCommunityDomain.StudentEntry>();        
        
        stdEntry.studentId = conList[0].Id;
        stdEntry.hours = '2.5';
        stdEntry.dateVal = weekStart1;
        stdEntry.comments = 'Test';
        stdEntry.dayId = day.Id;
        stdEntry.isNew = TRUE;
        stdEntryList.add(stdEntry);
                
        String s = AdminTimeEntry_InstructorCtrl.dmlOperationMethod(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, task[0].AcctSeed__Project__c, 'Revert', JSON.Serialize(dayEntryList), JSON.Serialize(stdEntryList), 'mytest comments', new List<String>{});
        System.assertEquals('SUCCESS', s);
        
        Test.stopTest();        
    }
    
    // To cover dmlOperationMethod() method
    private static testMethod void myTestMethod8e(){
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        List<Contact> conList = [SELECT Id, FirstName, LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
                
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
        
        Test.startTest();
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c, Name FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
                
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        schList[0].Instructor__c = conList[0].Id;
        schList[0].Start_Time__c = '03:00 PM';
        schList[0].End_Time__c = '05:00 PM';
        update schList;
        System.debug('schList===='+schList);
        
        List<Events__c> eve = [SELECT Id FROM Events__c LIMIT 1];
        eve[0].Schedule__c = schList[0].Id;
        eve[0].SequenceNo__c = 1;
        eve[0].Instructor__c = conList[0].Id;
        eve[0].Date__c = weekStart1;
        eve[0].Project__c = task[0].AcctSeed__Project__c;
        eve[0].Status__c = 'Scheduled';
        update eve[0];
        System.debug('event ========='+eve[0]);
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Contact__c = conList[0].Id;
        costRate[0]. Rate_Type__c = 'DLI-21 SCA LT';
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        insert timeCardLine;
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        dayEntry.dayId = day.Id;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = weekStart1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = TRUE;
        dayEntry.TaskType = 'Language Training';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '03:15 PM';
        dayEntry.endTime1 = '04:45 PM';
        dayEntry.lateCancellation = TRUE;
        dayEntry.cancellationReason = 'Just for Demo';
        dayEntry.costrateId = costRate[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = projects[0].Id;
        dayEntry.payrollItem = 'R';
        //dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = FALSE;
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityDomain.StudentEntry stdEntry = new TimeCardDayCommunityDomain.StudentEntry();
        List<TimeCardDayCommunityDomain.StudentEntry> stdEntryList = new List<TimeCardDayCommunityDomain.StudentEntry>();        
        
        stdEntry.studentId = conList[0].Id;
        stdEntry.hours = '2.5';
        stdEntry.dateVal = weekStart1;
        stdEntry.comments = 'Test';
        stdEntry.dayId = day.Id;
        stdEntry.isNew = TRUE;
        stdEntryList.add(stdEntry);
                
        String s = AdminTimeEntry_InstructorCtrl.dmlOperationMethod(String.valueOf(weekStart1), String.valueOf(WeekEnd1), conList[0].Id, projects[0].Id, 'Revert', JSON.Serialize(dayEntryList), JSON.Serialize(stdEntryList), 'mytest comments', new List<String>{});
        System.assertEquals('SUCCESS', s);
        
        Test.stopTest();
    }
    
    // To cover dmlOperationMethod() method
    private static testMethod void myTestMethod8d(){
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek()+60;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        List<Contact> conList = [SELECT Id, FirstName, LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id, AcctSeed__Start_Date__c, AcctSeed__End_Date__c FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c, Name FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
                
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c  LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Rate_Type__c = 'DLI-21 SCA LT';
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        dayEntry.dayId = NULL;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = weekStart1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = TRUE;
        dayEntry.TaskType = 'Language Training';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '03:15 PM';
        dayEntry.endTime1 = '04:45 PM';
        dayEntry.lateCancellation = TRUE;
        dayEntry.cancellationReason = 'Just for Demo';
        dayEntry.costrateId = costRate[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = projects[0].Id;
        dayEntry.payrollItem = 'R';
        //dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = FALSE;
        dayEntryList.add(dayEntry);
        
        TimeCardDayCommunityDomain.StudentEntry stdEntry = new TimeCardDayCommunityDomain.StudentEntry();
        List<TimeCardDayCommunityDomain.StudentEntry> stdEntryList = new List<TimeCardDayCommunityDomain.StudentEntry>();        
        
        stdEntry.studentId = conList[0].Id;
        stdEntry.hours = '2.5';
        stdEntry.dateVal = weekStart1;
        stdEntry.comments = 'Test';
        //stdEntry.dayId = day.Id;
        stdEntry.isNew = TRUE;
        stdEntryList.add(stdEntry);
   
        try{     
            String s = AdminTimeEntry_InstructorCtrl.dmlOperationMethod(String.valueOf(tcp[0].AcctSeed__Start_Date__c), String.valueOf(tcp[0].AcctSeed__End_Date__c), conList[0].Id, projects[0].Id, 'Revert', JSON.Serialize(dayEntryList), JSON.Serialize(stdEntryList), 'mytest comments', new List<String>{});
        }catch(Exception e){
            
            System.debug(':::::'+e.getMessage());
        }
        //System.assertEquals('SUCCESS', s);
        Test.stopTest();
    }
    
    // To cover revertTCDEntries() method
    private static testMethod void myTestMethod9(){
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        List<Contact> conList = [SELECT Id, FirstName, LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
                
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
        
        Test.startTest();
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c, Name FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
                
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = weekStart1;
        schList[0].End_Date__c = WeekEnd1;
        schList[0].Instructor__c = conList[0].Id;
        schList[0].Start_Time__c = '03:00 PM';
        schList[0].End_Time__c = '05:00 PM';
        update schList;
        System.debug('schList===='+schList);
        
        List<Events__c> eve = [SELECT Id FROM Events__c LIMIT 1];
        eve[0].Schedule__c = schList[0].Id;
        eve[0].SequenceNo__c = 1;
        eve[0].Instructor__c = conList[0].Id;
        eve[0].Date__c = weekStart1;
        eve[0].Project__c = task[0].AcctSeed__Project__c;
        eve[0].Status__c = 'Scheduled';
        update eve[0];
        System.debug('event ========='+eve[0]);
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Contact__c = conList[0].Id;
        costRate[0].Rate_Type__c = 'DLI-21 SCA LT';
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        insert timeCardLine;
        
        TimeCardDayCommunityDomain.DayEntries dayEntry = new TimeCardDayCommunityDomain.DayEntries();
        List<TimeCardDayCommunityDomain.DayEntries> dayEntryList = new List<TimeCardDayCommunityDomain.DayEntries>();
        
        AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted');
        insert day;
        
        dayEntry.dayId = day.Id;
        dayEntry.lineId = timeCardLine.Id;
        dayEntry.dayHours = '2.5';
        dayEntry.dateVal = weekStart1;
        dayEntry.comments = 'Test';
        dayEntry.status = 'Draft';
        dayEntry.isBillable = TRUE;
        dayEntry.isNew = TRUE;
        dayEntry.TaskType = 'Language Training';
        dayEntry.studentApprovalStatus = 'Submitted';
        dayEntry.startTime1 = '03:15 PM';
        dayEntry.endTime1 = '04:45 PM';
        dayEntry.lateCancellation = TRUE;
        dayEntry.cancellationReason = 'Just for Demo';
        dayEntry.costrateId = costRate[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = projects[0].Id;
        dayEntry.payrollItem = 'R';
        //dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = FALSE;
        dayEntryList.add(dayEntry);
        
        String s  = AdminTimeEntry_InstructorCtrl.revertTCDEntries(JSON.Serialize(dayEntryList), 'mytest comments');
        System.assertEquals('success', s);
        
        Test.stopTest();
    }
}