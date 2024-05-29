@isTest
public with sharing class StaffTimeEntryController_Test {

    @testSetup static void setupMethod() {
    
        Test.StartTest();
            List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment(); 
            List<MTT_Location__c> location = TestClassUtil.createTestLocations();
        Test.StopTest();
        
        List<AcctSeed__Cost_Rates__c> costRates = TestClassUtil.createTestCostRates();
        List<AcctSeed__Time_Card_Day__c>  tcd = TestClassUtil.createTestTimeCardDay();

        List<Project_Task_Master__c> projmaster = new List<Project_Task_Master__c>{
            
            new Project_Task_Master__c(Name = 'Test 1',Billable__c = false,Display_In_Time_Card__c = true,Project_Type__c = 'Internal Cost Jobs',Unit__c = 'Hrs',Project_Task_Type__c = 'Fringe',Internal_Staff_Entry_Sort_Order__c=1,Sort_Order__c = 4,Payroll_Item__c = 'S', Project_Task_Record_Type__c = 'Cost',Project_Record_Type__c = 'Testing_Projects'),
            new Project_Task_Master__c(Name = 'Test 3',Billable__c = true,Display_In_Time_Card__c = true,Project_Type__c = 'DLS-Site Language Training; Client Site Language Training; FBI WO',Unit__c = 'Hrs',Project_Task_Type__c = 'ADMINISTRATIVE',Internal_Staff_Entry_Sort_Order__c=3,Sort_Order__c = 3,Payroll_Item__c = 'JUR', Project_Task_Record_Type__c = 'Cost', Project_Record_Type__c = 'Testing_Projects')
        };
        insert projmaster; 
    }

    // To cover getFilterInfo method
    private static testMethod void getFilterInfo_Test(){
    
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
                String intialfilterVal = StaffTimeEntryController.getFilterInfo();
                TimeCardDayCommunityDomain.InitialFilterValues intialVal = (TimeCardDayCommunityDomain.InitialFilterValues) JSON.deserialize(intialfilterVal,TimeCardDayCommunityDomain.InitialFilterValues.Class);
                System.assertEquals(intialVal.contactId,conList[0].Id);
            }
        Test.stopTest();
    }

    // To cover getProjectsByWeekrange method
    private static testMethod void getProjectsByWeekrange_Test(){
    
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
                
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];

        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c, Project__r.DLS_Ref__c, Include_Fringe__c, Rate_Card_Rate__c  FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Rate_Card_Rate__c = cr[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 

        String startDateFormat = Datetime.newInstance(weekStart1.year(), weekStart1.month(), weekStart1.day()).format('MM/dd/yyyy');
        String endDateFormat = Datetime.newInstance(WeekEnd1.year(), WeekEnd1.month(), WeekEnd1.day()).format('MM/dd/yyyy');
        String weekRange =  startDateFormat + ' to ' + endDateFormat;

        System.runAs(user) {    
        
            try{
                String res = StaffTimeEntryController.getProjectsByWeekrange(conList[0].Id, weekRange);
                StaffTimeEntryDomain.projectAndCAInfo resMAp = (StaffTimeEntryDomain.projectAndCAInfo) JSON.deserialize(res, StaffTimeEntryDomain.projectAndCAInfo.class);
                System.assertEquals(resMAp.projectIdWithCAMap.size() > 0,true);
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        
        Test.stopTest();
    }

    // To Cover getProjTaskAndTimeEnteredDetails Method
    private static testMethod void getProjTaskAndTimeEnteredDetails_Test(){

        Date myDate1 = System.today();
        Date startDate = myDate1.toStartofWeek()+1;
        Date endDate = myDate1.toStartofWeek()+7;
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND LastName='Test Contact1' LIMIT 1];
        
        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];

        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c, Project__r.DLS_Ref__c, Include_Fringe__c, Rate_Card_Rate__c  FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Rate_Card_Rate__c = cr[0].Id;
        conAss[0].Start_Date__c = startDate;
        conAss[0].End_Date__c = endDate;
        update conAss[0]; 

        for (Contact_Assignments__c cona : conAss) {
            system.debug('contactAssignment'+cona);
        }
        system.debug('contact'+conList);

        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;

        Id testRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
  
                
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        proj[0].RecordTypeId = testRTId;
        update proj[0];

        List<Project_Task_Master__c> projmaster = [SELECT Id,Name,Billable__c,Display_In_Time_Card__c, Payroll_Item__c,
                                            Project_Record_Type__c,Project_Task_Record_Type__c,Project_Task_Type__c, Project_Type__c,Unit__c,Sort_Order__c 
                                            FROM Project_Task_Master__c];
        projmaster[0].Project_Record_Type__c = testRTId;
        projmaster[0].Sort_Order__c = 1;
        update projmaster;

        List<AcctSeed__Project_Task__c> task = [SELECT Id,Name, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND Project_Task_Type__c != 'Fringe' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        task[0].Name = 'Test 3';
        task[0].Project_Task_Type__c = 'ADMINISTRATIVE';
        update task;
        
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

        String startDateFormat = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day()).format('MM/dd/yyyy');
        String endDateFormat = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day()).format('MM/dd/yyyy');
        String weekRange = startDateFormat + ' to ' + endDateFormat;
        Test.startTest();
        String  insRowDetailJson = StaffTimeEntryController.getProjTaskAndTimeEnteredDetails(conAss[0].Project__c, weekRange, JSON.serialize(conAss[0]));
        TimeCardDayCommunityDomain.InstructorRowDetails instructorRowDetails =  (TimeCardDayCommunityDomain.InstructorRowDetails) JSON.deserialize(insRowDetailJson,TimeCardDayCommunityDomain.InstructorRowDetails.Class);
        System.assertEquals(instructorRowDetails.entries.size() > 0,true);
        Test.stopTest();
    }

    // To Cover saveStaffTimeEntries Method

    private static testMethod void saveStaffTimeEntries_Test(){

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
        Date startDate = myDate1.toStartofWeek()+1;
        Date endDate = myDate1.toStartofWeek()+7;
        String startDateFormat = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day()).format('MM/dd/yyyy');
        String endDateFormat = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day()).format('MM/dd/yyyy');
        String weekRange = startDateFormat + ' to ' + endDateFormat;
        
        AcctSeed__Time_Card_Period__c tcp = [SELECT Id,Name FROM AcctSeed__Time_Card_Period__c LIMIT 1];

        AcctSeed__Time_Card_Day__c day1 = [SELECT ID, AcctSeed__Date__c, AcctSeed__Time_Card_Period__c,AcctSeed__Time_Card_Line__c, Start_Time1__c, End_Time1__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Day__c LIMIT 1];

        List<AcctSeed__Cost_Rates__c> cr = [SELECT Id,Name,Payroll_Item__c,Non_Billable_Payroll_Item__c, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' LIMIT 1];
        cr[0].Contact__c = conList[0].Id;
        update cr[0];

        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c, Project__r.DLS_Ref__c, Include_Fringe__c, Rate_Card_Rate__c  FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Rate_Card_Rate__c = cr[0].Id;
        conAss[0].Start_Date__c = startDate;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 

        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
 
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];

        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];        
        
         AcctSeed__Project_Task__c task1 = new AcctSeed__Project_Task__c(Name = 'Fringe - Holiday',AcctSeed__Client_Contact__c = conList[0].Id,AcctSeed__Project__c = proj[0].Id,Project_Task_Type__c = 'Fringe', Rate__c = 41);
        insert task1;
        
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
        dayEntry.costrateId = cr[0].Id;
        dayEntry.taskId = task[0].Id;
        dayEntry.projectId = task[0].AcctSeed__Project__c;
        dayEntry.payrollItem = 'R';
        dayEntry.locationId = loc.Id;
        dayEntry.contactAssignId = conAss[0].Id;
        dayEntry.sequenceNumber = 1234;
        dayEntry.isUpdated = FALSE;
                
        dayEntryList.add(dayEntry);              

        system.runAs(user) {

            try{
                String res = StaffTimeEntryController.saveStaffTimeEntries(weekRange, conList[0].Id, JSON.serialize(dayEntryList), conAss[0].Project__c);
                System.assertEquals('success', res);
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        Test.stopTest();
    }

    // To cover completeTimeEntries method
    private static testMethod void completeTimeEntries_Test(){
    
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
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        
        
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
                List<AcctSeed__Time_Card_Line__c> res = StaffTimeEntryController.completeTimeEntries(JSON.serialize(dayEntries));
                System.assertEquals(true, res.size() > 0);
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        
        Test.stopTest();
    }

    // To cover recallExistingTimeEntries Method
    private static testMethod void recallExistingTimeEntries_Test(){
    
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
                String res = StaffTimeEntryController.recallExistingTimeEntries(JSON.Serialize(deList), 'Group');
                
                List<AcctSeed__Time_Card_Day__c> days = [SELECT ID, Status__c, Start_Time2__c, End_Time2__c, AcctSeed__Date__c, AcctSeed__Time_Card_Line__c, Start_Time1__c, End_Time1__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Day__c];
                
                System.assertEquals(res,'SUCCESS');

            }catch(DmlException e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        
        Test.stopTest();
    }
     // To cover getSummaryTimeRecords Method
    private static testMethod void getSummaryTimeRecords(){
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
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        
        List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        proj[0].Training_Location__c = loc.Id;
        update proj[0];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :proj[0].Id LIMIT 1];
        
        
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
               Decimal hours = StaffTimeEntryController.getSummaryTimeRecords(''+System.Today(),''+WeekEnd1,conList[0].Id);
                System.assertEquals(hours, 4);
            }catch(Exception e){
            
                System.debug('EXception===='+e.getMessage());
            }
        }
        Test.stopTest();
    }
                        
    

}