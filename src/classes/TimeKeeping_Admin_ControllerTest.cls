@isTest
public class TimeKeeping_Admin_ControllerTest {
    
    @testSetup static void setup(){
               
        List<Contact_Assignments__c> contactAssignmentsList = TestClassUtil.createTestContactAssignment(); 
        Test.StartTest();
            List<Events__c> eventList = TestClassUtil.createTestEvent(); 
            List<AcctSeed__Time_Card_Day__c> timecardlist = TestClassUtil.createTestTimeCardDay();
            //List<AcctSeed__Project_Task__c> prjtTask = TestClassUtil.createTestProjectTask();
        Test.StopTest();        
    }
   
    static testmethod void test1() {
    
        DateTime dT = System.now();
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        system.debug('::::::::::::;fff'+dT);
        system.debug('::::::::'+myDate.toStartofWeek().addDays(1));
        system.debug('::::::::'+myDate.toStartofWeek().addDays(7));
        
        Date weekStart = myDate.toStartofWeek().addDays(1);
        Date WeekEnd = myDate.toStartofWeek().addDays(7);
        
        Date startDate = weekStart;
        Date endDate = WeekEnd;
        
        String stDate = String.valueOf(weekStart);
        String edDate = String.valueOf(WeekEnd);
        
        system.debug(':::::::stDate:::::::'+stDate);
        system.debug(':::::::edDate:::::::'+edDate);
        
         List<Date> daysList = new List<Date>();
         
        while(startDate <= endDate) {
           daysList.add(startDate);
           startDate = startDate.addDays(1);
        }
        system.debug('::::::::daysList::::::'+daysList);
      
        List<Events__c> eventList = [SELECT Id, Name, Schedule__c, schedule__r.Project_Task__c FROM Events__c];
        
        List<AcctSeed__Time_Card_Line__c> timecardLine2 = [Select Id,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c From AcctSeed__Time_Card_Line__c];
        system.debug(':::timecardLine2::::'+timecardLine2[0].AcctSeed__Time_Card__r.Intructor__c);
        
        List<AcctSeed__Time_Card_Day__c> timecardDayList1 = [SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Hours__c, AcctSeed__Time_Card_Line__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Total_Hours_Before_Approved__c,Status__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Total_Hours__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c            
                                                                FROM AcctSeed__Time_Card_Day__c LIMIT 5];       
        system.debug(':::timecardDayList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c'+timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c);
        
        List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Name,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 5];
        
        List<AcctSeed__Project__c> projectList = [SELECT Id,Name,DLS_Class__c FROM AcctSeed__Project__c LIMIT 5];
        
        System_Values__c sysVal = new System_Values__c();
        sysVal.Name = 'TimeLog_Locking_Date';
        sysVal.Value__c = String.valueOf(system.today().addDays(-30));
        insert sysVal;

        List<RecordType> recList = [Select ID,DeveloperName From Recordtype Where sObjectType='Contact' AND DeveloperName='DLS_Employee'];
        system.debug('::::recList'+recList);
        Contact con = new Contact(LastName ='Test',RecordTypeId = recList[0].Id);
        insert con;
        //TimeKeeping_Admin_Controller.getWholeWeekRangeValues('Internal');
        //TimeKeeping_Admin_Controller.getspecificeWeekRecords(stDate,edDate,timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,'Internal');
        
        //TimeKeeping_Admin_Controller.getspecificeWeekRecords(stDate,edDate,con.Id,'Internal');
        //TimeKeeping_Admin_Controller.getExistingdayRecord(projectList[0].Id,projectTaskList[0].Id,timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,stDate,edDate,True,'ADM');
        
         Test.startTest(); 
        
        TimeCardDayDomain.TimeCardDay day = new TimeCardDayDomain.TimeCardDay();
       
        List<TimeCardDayDomain.TimeCardDay> timeCardDayInnerList = new List<TimeCardDayDomain.TimeCardDay>();
        List<TimeCardDayDomain.TimeCardDay> timeCardDayInnerList1 = new List<TimeCardDayDomain.TimeCardDay>();
        
        String selectedContact = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
       
        day.SelectedProject = projectTaskList[0].AcctSeed__Project__c;
        day.SelectedProTask = projectTaskList[0].Id;
        day.SelectedInstructor = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
        day.Hours1 = String.valueOf(timecardDayList1[0].Total_Hours_Before_Approved__c);
        day.Hours2 = String.valueOf(timecardDayList1[1].Total_Hours_Before_Approved__c);
        day.Hours3 = String.valueOf(timecardDayList1[2].Total_Hours_Before_Approved__c);
        day.Hours4 = '1';
        day.Hours5 = '2';
        day.Hours6 = '1';
        day.Hours7 = '3';
        day.Day1 = timecardDayList1[0].AcctSeed__Date__c;
        day.Day2 = timecardDayList1[1].AcctSeed__Date__c;
        day.Day3 = timecardDayList1[2].AcctSeed__Date__c;
        day.Day4 = daysList[0];
        day.Day5 = daysList[4];
        day.Day6 = daysList[5];
        day.Day7 = daysList[6];
        day.isBillable = FALSE;
        day.timeCardLineId = timecardDayList1[0].AcctSeed__Time_Card_Line__c;
        day.timeCardId = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c;
        day.TotalHours = 13.0;
        day.status3 = 'Approved';
        day.status2 = 'Approved';
        day.status1 = 'Approved';
        day.status4 = 'Approved';
        day.status5 = 'Approved';
        day.status6 = 'Approved';
        day.Hrs1Day1Id = timecardDayList1[0].Id;
        day.Hrs2Day2Id = timecardDayList1[1].Id;
        day.Hrs3Day3Id = timecardDayList1[2].Id;
        day.lateCancellation1 = FALSE;
        day.cancellationReason1 = 'Test';
        day.lateCancellation2 = FALSE;
        day.cancellationReason2 = 'Test';
        day.lateCancellation3 = FALSE;
        day.cancellationReason3 = 'Test';
       
        timeCardDayInnerList.add(day);
        List<Id> updateIdlist = new List<Id>();
        for(AcctSeed__Time_Card_Day__c timecard : timecardDayList1){
            updateIdlist.add(timecard.Id);
        }
        
        String jsontimeCardDay = JSON.serializePretty(timeCardDayInnerList);

        day.Hrs1Day1Id = null;
        TimeKeeping_Admin_Controller.dmlOperationFunction(jsontimeCardDay,stDate,edDate,updateIdlist,selectedContact,'From Revert','Test save');
        TimeKeeping_Admin_Controller.dmlOperationFunction(jsontimeCardDay,String.Valueof(system.Today().addDays(-20)),String.Valueof(system.Today().addDays(20)),updateIdlist,selectedContact,'From Save','Test save');
        String conditin = 'AcctSeed__Opportunity__c != null';
        TimeKeeping_Admin_Controller.getLookupRecords('AcctSeed__Project__c','',conditin);

        day.Hrs1Day1Id = null;
        TimeKeeping_Admin_Controller.dmlOperationFunction(jsontimeCardDay,String.Valueof(system.Today().addDays(-20)),String.Valueof(system.Today().addDays(20)),updateIdlist,selectedContact,'From Save','Test save');
        Test.stopTest(); 
    }
    
    static testmethod void testTimeKeeping1() {
    
        DateTime dT = System.now();
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        system.debug('::::::::::::;fff'+dT);
        system.debug('::::::::'+myDate.toStartofWeek().addDays(1));
        system.debug('::::::::'+myDate.toStartofWeek().addDays(7));
        
        Date weekStart = myDate.toStartofWeek().addDays(1);
        Date WeekEnd = myDate.toStartofWeek().addDays(7);
        
        Date startDate = weekStart;
        Date endDate = WeekEnd;
        
        String stDate = String.valueOf(weekStart);
        String edDate = String.valueOf(WeekEnd);
        
        system.debug(':::::::stDate:::::::'+stDate);
        system.debug(':::::::edDate:::::::'+edDate);
        
         List<Date> daysList = new List<Date>();
         
         while(startDate <= endDate) {
           daysList.add(startDate);
           startDate = startDate.addDays(1);
        }
        system.debug('::::::::daysList::::::'+daysList);
        
        Test.StartTest();
        
        List<AcctSeed__Time_Card_Day__c> timecardDayList = [SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Hours__c, AcctSeed__Time_Card_Line__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Total_Hours_Before_Approved__c,Status__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Total_Hours__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c
            
                                                                FROM AcctSeed__Time_Card_Day__c LIMIT 5];
       
        system.debug(':::::timecardDayList::::::'+timecardDayList);
       
        List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Name,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 5];
        
        system.debug(':::::projectTaskList::::::'+projectTaskList);
      
        TimeCardDayDomain.TimeCardDay day1 = new TimeCardDayDomain.TimeCardDay();
        
        List<OrgWideEmailAddress> owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
        system.debug('::::owa'+owa);
        
        System_Values__c sysVal1 = new System_Values__c();
        sysVal1.Name = 'Timesheet';
        sysVal1.Value__c = owa[0].Id;
        
        insert sysVal1;
        
        Id recId = [SELECT Id,Name, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'DLS_Employee'].Id;
        
        List<Contact> conList = [SELECT Id, Active_DLS_Employee__c,RecordType.DeveloperName FROM Contact WHERE Id = :timecardDayList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c];
        conList[0].Active_DLS_Employee__c = true;
        conList[0].RecordTypeId = recId;
        update conList; 
        
        String selectedContact = timecardDayList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
        
        List<TimeCardDayDomain.TimeCardDay> timeCardDayInnerList1 = new List<TimeCardDayDomain.TimeCardDay>();
        
        day1.SelectedProject = projectTaskList[0].AcctSeed__Project__c;
        day1.SelectedProTask = projectTaskList[0].Id;
        day1.SelectedInstructor = timecardDayList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
        day1.Hours1 = '1';
        day1.Hours2 = '2';
        day1.Hours3 = '3';
        day1.Hours4 = '1';
        day1.Hours5 = '2';
        day1.Hours6 = '1';
        day1.Hours7 = '3';
        day1.Day1 = daysList[1];
        day1.Day2 = daysList[2];
        day1.Day3 = daysList[3];
        day1.Day4 = daysList[0];
        day1.Day5 = daysList[4];
        day1.Day6 = daysList[5];
        day1.Day7 = daysList[6];
        day1.TaskType = 'Fringe';
        day1.Taskname = 'Bonus Leave Taken';        
        day1.TotalHours = 13.0;
        
        day1.Hrs4Day4Id = timecardDayList[0].Id;
        day1.Hrs5Day5Id = timecardDayList[1].Id;
        day1.Hrs6Day6Id = timecardDayList[2].Id;
        day1.isBillable = TRUE;
        day1.timeCardLineId = timecardDayList[0].AcctSeed__Time_Card_Line__c;
        day1.timeCardId = timecardDayList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c;
        
        day1.lateCancellation4 = FALSE;
        day1.cancellationReason4 = 'Test';
        day1.lateCancellation5 = FALSE;
        day1.cancellationReason5 = 'Test';
        day1.lateCancellation6 = FALSE;
        day1.cancellationReason6 = 'Test';
        
        timeCardDayInnerList1.add(day1);
        
        String jsontimeCardDay1 = JSON.serializePretty(timeCardDayInnerList1);
        List<Id> updateIdlist = new List<Id>();
        for(AcctSeed__Time_Card_Day__c timecard:timecardDayList){
            updateIdlist.add(timecard.Id);
        }
        TimeKeeping_Admin_Controller.dmlOperationFunction(jsontimeCardDay1,stDate,edDate,updateIdlist,selectedContact,'From Revert','Test Revert');
        
        List<TimeCardDayDomain.TimeCardDay> timeCardDayInnerList2 = new List<TimeCardDayDomain.TimeCardDay>();
        String jsontimeCardDay2 = JSON.serializePretty(timeCardDayInnerList2);
        TimeKeeping_Admin_Controller.dmlOperationFunction(jsontimeCardDay2,stDate,edDate,updateIdlist,selectedContact,'From Revert','Test Revert');
        
        Test.StopTest();
       
   }
   static testmethod void testTimeKeeping2() {
    
        DateTime dT = System.now();
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        system.debug('::::::::::::;fff'+dT);
        system.debug('::::::::'+myDate.toStartofWeek().addDays(1));
        system.debug('::::::::'+myDate.toStartofWeek().addDays(7));
        
        Date weekStart = myDate.toStartofWeek().addDays(1);
        Date WeekEnd = myDate.toStartofWeek().addDays(7);
        
        Date startDate = weekStart;
        Date endDate = WeekEnd;
        
        String stDate = String.valueOf(weekStart);
        String edDate = String.valueOf(WeekEnd);
        
        system.debug(':::::::stDate:::::::'+stDate);
        system.debug(':::::::edDate:::::::'+edDate);
        
         List<Date> daysList = new List<Date>();
         
         while(startDate <= endDate) {
           daysList.add(startDate);
           startDate = startDate.addDays(1);
        }
        system.debug('::::::::daysList::::::'+daysList);
        
        
        Test.StartTest();
        List<AcctSeed__Time_Card_Day__c> timecardDayList = [SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Hours__c, AcctSeed__Time_Card_Line__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Total_Hours_Before_Approved__c,Status__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Total_Hours__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c
            
                                                                FROM AcctSeed__Time_Card_Day__c LIMIT 5];
       
        system.debug(':::::timecardDayList::::::'+timecardDayList);
       
        List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Name,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 5];
        
        system.debug(':::::projectTaskList::::::'+projectTaskList);
        
        List<OrgWideEmailAddress> owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
        system.debug('::::owa'+owa);
        
        System_Values__c sysVal1 = new System_Values__c();
        sysVal1.Name = 'Timesheet';
        sysVal1.Value__c = owa[0].Id;
        
        insert sysVal1;
        
        Id recId = [SELECT Id,Name, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'DLS_Employee'].Id;
        
        List<Contact> conList = [SELECT Id, Active_DLS_Employee__c,RecordType.DeveloperName FROM Contact WHERE Id = :timecardDayList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c];
        conList[0].Active_DLS_Employee__c = true;
        conList[0].RecordTypeId = recId;
        update conList; 
        String selectedContact = timecardDayList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
       
        TimeCardDayDomain.TimeCardDay day = new TimeCardDayDomain.TimeCardDay();
        
        List<TimeCardDayDomain.TimeCardDay> timeCardDayInnerList = new List<TimeCardDayDomain.TimeCardDay>();
        
        day.SelectedProject = projectTaskList[0].AcctSeed__Project__c;
        day.SelectedProTask = projectTaskList[0].Id;
        day.SelectedInstructor = timecardDayList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
        day.Hours1 = '1';
        day.Hours2 = '2';
        day.Hours3 = '3';
        day.Hours4 = '1';
        day.Hours5 = '2';
        day.Hours6 = '1';
        day.Hours7 = '3';
        day.Day1 = daysList[1];
        day.Day2 = daysList[2];
        day.Day3 = daysList[3];
        day.Day4 = daysList[0];
        day.Day5 = daysList[4];
        day.Day6 = daysList[5];
        day.Day7 = daysList[6];
        
        day.TotalHours = 13.0;
        day.Hrs7Day7Id = timecardDayList[0].Id;
        day.isBillable = TRUE;
        day.timeCardLineId = timecardDayList[0].AcctSeed__Time_Card_Line__c;
        day.timeCardId = timecardDayList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c;
        day.lateCancellation7 = FALSE;
        day.cancellationReason7 = 'Test';
        
        timeCardDayInnerList.add(day);
        
        List<Id> updateIdlist = new List<Id>();
        for(AcctSeed__Time_Card_Day__c timecard:timecardDayList){
            updateIdlist.add(timecard.Id);
        }
        String jsontimeCardDay = JSON.serializePretty(timeCardDayInnerList);
        TimeKeeping_Admin_Controller.dmlOperationFunction(jsontimeCardDay,stDate,edDate,updateIdlist,selectedContact,'From Save','');
        Test.StopTest();
    }
    
    static testmethod void testTimeKeeping3() {
    
        DateTime dT = System.now();
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        system.debug('::::::::::::;fff'+dT);
        system.debug('::::::::'+myDate.toStartofWeek().addDays(1));
        system.debug('::::::::'+myDate.toStartofWeek().addDays(7));
        
        Date weekStart = myDate.toStartofWeek().addDays(1);
        Date WeekEnd = myDate.toStartofWeek().addDays(7);
        
        Date startDate = weekStart;
        Date endDate = WeekEnd;
        
        String stDate = String.valueOf(weekStart);
        String edDate = String.valueOf(WeekEnd);
        
        system.debug(':::::::stDate:::::::'+stDate);
        system.debug(':::::::edDate:::::::'+edDate);
        
         List<Date> daysList = new List<Date>();
         
         while(startDate <= endDate) {
           daysList.add(startDate);
           startDate = startDate.addDays(1);
        }
        system.debug('::::::::daysList::::::'+daysList);
        
        Test.StartTest();
        List<AcctSeed__Time_Card_Day__c> timecardDayList = [SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Hours__c, AcctSeed__Time_Card_Line__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Total_Hours_Before_Approved__c,Status__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Total_Hours__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c
            
                                                                FROM AcctSeed__Time_Card_Day__c LIMIT 5];
       
        system.debug(':::::timecardDayList::::::'+timecardDayList);
       
        List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Name,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 5];
        
        system.debug(':::::projectTaskList::::::'+projectTaskList);
        
        List<OrgWideEmailAddress> owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
        system.debug('::::owa'+owa);
        
        System_Values__c sysVal1 = new System_Values__c();
        sysVal1.Name = 'Timesheet';
        sysVal1.Value__c = owa[0].Id;
        
        insert sysVal1;
        
        Id recId = [SELECT Id,Name, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'DLS_Employee'].Id;
        
        List<Contact> conList = [SELECT Id, Active_DLS_Employee__c,RecordType.DeveloperName FROM Contact WHERE Id = :timecardDayList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c];
        conList[0].Active_DLS_Employee__c = true;
        conList[0].RecordTypeId = recId;
        update conList; 
        
        String selectedContact = timecardDayList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
        
        TimeCardDayDomain.TimeCardDay day2 = new TimeCardDayDomain.TimeCardDay();
        
        List<TimeCardDayDomain.TimeCardDay> timeCardDayInnerList2 = new List<TimeCardDayDomain.TimeCardDay>();
        
        day2.SelectedProject = projectTaskList[0].AcctSeed__Project__c;
        day2.SelectedProTask = projectTaskList[0].Id;
        day2.SelectedInstructor = timecardDayList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
        day2.Hours1 = '1';
        day2.Hours2 = '2';
        day2.Hours3 = '3';
        day2.Hours4 = '1';
        day2.Hours5 = '2';
        day2.Hours6 = '1';
        day2.Hours7 = '3';
        day2.Day1 = daysList[1];
        day2.Day2 = daysList[2];
        day2.Day3 = daysList[3];
        day2.Day4 = daysList[0];
        day2.Day5 = daysList[4];
        day2.Day6 = daysList[5];
        day2.Day7 = daysList[6];
        
        day2.TotalHours = 13.0;        
        day2.Hrs4Day4Id = timecardDayList[0].Id;
        day2.Hrs5Day5Id = timecardDayList[1].Id;
        day2.Hrs6Day6Id = timecardDayList[2].Id;
        day2.isBillable = FALSE;
        day2.lateCancellation4 = FALSE;
        day2.cancellationReason4 = 'Test';
        day2.lateCancellation5 = FALSE;
        day2.cancellationReason5 = 'Test';
        day2.lateCancellation6 = FALSE;
        day2.cancellationReason6 = 'Test';
        day2.timeCardLineId = timecardDayList[0].AcctSeed__Time_Card_Line__c;
        day2.timeCardId = timecardDayList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c;
        
        timeCardDayInnerList2.add(day2);
        List<Id> updateIdlist = new List<Id>();
        for(AcctSeed__Time_Card_Day__c timecard:timecardDayList){
            updateIdlist.add(timecard.Id);
        }
      
        
        String jsontimeCardDay2 = JSON.serializePretty(timeCardDayInnerList2);
        TimeKeeping_Admin_Controller.dmlOperationFunction(jsontimeCardDay2,String.valueof(system.Today().addDays(-30)),String.valueof(system.Today().addDays(30)),updateIdlist,selectedContact,'From Save','');
        TimeKeeping_Admin_Controller.dmlOperationFunction(jsontimeCardDay2,String.valueof(system.Today().addDays(-30)),String.valueof(system.Today().addDays(30)),updateIdlist,selectedContact,'From Revert','');
        Test.StopTest();
    }
    
    static testmethod void test5() {
    
        DateTime dT = System.now();
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        system.debug('::::::::::::;fff'+dT);
        system.debug('::::::::'+myDate.toStartofWeek().addDays(1));
        system.debug('::::::::'+myDate.toStartofWeek().addDays(7));
        
        Date weekStart = myDate.toStartofWeek().addDays(1);
        Date WeekEnd = myDate.toStartofWeek().addDays(7);
        
        Date startDate = weekStart;
        Date endDate = WeekEnd;
        
        String stDate = String.valueOf(weekStart);
        String edDate = String.valueOf(WeekEnd);
        
        system.debug(':::::::stDate:::::::'+stDate);
        system.debug(':::::::edDate:::::::'+edDate);
        
         List<Date> daysList = new List<Date>();
         
        while(startDate <= endDate) {
           daysList.add(startDate);
           startDate = startDate.addDays(1);
        }
        system.debug('::::::::daysList::::::'+daysList);
        
        
        
        List<Events__c> eventList = [SELECT Id, Name, Schedule__c, schedule__r.Project_Task__c FROM Events__c];
        
        List<AcctSeed__Time_Card_Line__c> timecardLine2 = [Select Id,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c From AcctSeed__Time_Card_Line__c];
        system.debug(':::timecardLine2::::'+timecardLine2[0].AcctSeed__Time_Card__r.Intructor__c);
        
        List<AcctSeed__Time_Card_Day__c> timecardDayList1 = [SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Hours__c, AcctSeed__Time_Card_Line__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Total_Hours_Before_Approved__c,Status__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Total_Hours__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c            
                                                                FROM AcctSeed__Time_Card_Day__c LIMIT 5];       
        system.debug(':::timecardDayList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c'+timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c);
        
        
        List<Accounting_Seed_Time_Snapshot__c> snapList = new List<Accounting_Seed_Time_Snapshot__c>{
            new Accounting_Seed_Time_Snapshot__c (Name='Test', Time_Card_Day__c = timecardDayList1[0].Id),
            new Accounting_Seed_Time_Snapshot__c (Name='Test1', Time_Card_Day__c = timecardDayList1[1].Id)
        };
        
        insert snapList;
        system.debug(':::snapList'+snapList);
        
        List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Name,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 5];
        
        system.debug(':::::projectTaskList::::::'+projectTaskList);
       
        List<AcctSeed__Project__c> projectList = [SELECT Id,Name,DLS_Class__c FROM AcctSeed__Project__c LIMIT 5];
        
        system.debug(':::::projectList::::::'+projectList);
        
        System_Values__c sysVal = new System_Values__c();
         sysVal.Name = 'TimeLog_Locking_Date';
         sysVal.Value__c = String.valueOf(system.today().addDays(-30));
         insert sysVal;
         
        Test.startTest();
        
        //AcctSeed__Accounting_Period__c accPeriodList = [SELECT Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c,AcctSeed__Status__c FROM AcctSeed__Accounting_Period__c WHERE AcctSeed__Start_Date__c =: stDate AND AcctSeed__End_Date__c =: monthEnd];
        //system.debug(':::accPeriodList'+accPeriodList);
        
        List<RecordType> recList = [Select ID,DeveloperName From Recordtype Where sObjectType='Contact' AND DeveloperName='DLS_Employee'];
        system.debug('::::recList'+recList);
        List<Contact> con = new List<Contact>{
            new Contact(LastName ='Test',RecordTypeId = recList[0].Id,Email = 'test@gmail.com'),
            new Contact(FirstName ='Contact',LastName ='Test',RecordTypeId = recList[0].Id,Email = 'test@gmail.com')
        };
        insert con;
        
        List<AcctSeed__Project_Task__c> projtaskList = [SELECT Id, AcctSeed__Project__c FROM AcctSeed__Project_Task__c Limit 2];
        
        List<Contact_Assignments__c> contAssignList = [SELECT Id, Name,Candidate_Name__c,Status__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor'];
        
        contAssignList[0].Project__c = projtaskList[0].AcctSeed__Project__c;        
        contAssignList[0].Candidate_Name__c = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
        update contAssignList;
        
        TimeKeeping_Admin_Controller.getWholeWeekRangeValues('Internal');
        TimeKeeping_Admin_Controller.getWholeWeekRangeValues('Instructor');
        TimeKeeping_Admin_Controller.getWholeWeekRangeValues('');
        TimeKeeping_Admin_Controller.getspecificeWeekRecords(stDate,edDate,timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,'Internal');

        TimeKeeping_Admin_Controller.getspecificeWeekRecords(stDate,edDate,timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,'Instructor');

        TimeKeeping_Admin_Controller.getspecificeWeekRecords(stDate,edDate,con[0].Id,'Internal');
        TimeKeeping_Admin_Controller.getspecificeWeekRecords(stDate,edDate,con[0].Id,'Instructor');
        TimeKeeping_Admin_Controller.getExistingdayRecord(projectList[0].Id,projectTaskList[0].Id,timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,stDate,edDate,True,'ADM');
        
        
        TimeKeeping_Admin_Controller.getContactRelatedUser(con[0].Id);
        TimeKeeping_Admin_Controller.getContactRelatedUser(con[1].Id);
        
        test.stopTest();
    }
    
    static testmethod void test2() {
    
        DateTime dT = System.now();
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        Date weekStart = myDate.toStartofWeek().addDays(1);
        Date WeekEnd = myDate.toStartofWeek().addDays(7);
        
        Date startDate = weekStart;
        Date endDate = WeekEnd;
        
        String stDate = String.valueOf(weekStart);
        String edDate = String.valueOf(WeekEnd);       
        
        List<Date> daysList = new List<Date>();
         
        while(startDate <= endDate) {
           daysList.add(startDate);
           startDate = startDate.addDays(1);
        }
        
        List<Events__c> eventList = [SELECT Id, Name, Schedule__c, schedule__r.Project_Task__c FROM Events__c];
        
        List<AcctSeed__Time_Card_Line__c> timecardLine2 = [Select Id,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c From AcctSeed__Time_Card_Line__c];
        
        List<AcctSeed__Time_Card_Day__c> timecardDayList1 = [SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Hours__c, AcctSeed__Time_Card_Line__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Total_Hours_Before_Approved__c,Status__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Total_Hours__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c            
                                                                FROM AcctSeed__Time_Card_Day__c LIMIT 5];       
        
        List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Name,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 5];
        
        List<AcctSeed__Project__c> projectList = [SELECT Id,Name,DLS_Class__c FROM AcctSeed__Project__c LIMIT 5];
        
        System_Values__c sysVal = new System_Values__c();
        sysVal.Name = 'TimeLog_Locking_Date';
        sysVal.Value__c = String.valueOf(system.today().addDays(-30));
        insert sysVal;
         
        Test.startTest();
        
        List<RecordType> recList = [Select ID,DeveloperName From Recordtype Where sObjectType='Contact' AND DeveloperName='DLS_Employee'];
        system.debug('::::recList'+recList);
        Contact con = new Contact(LastName ='Test',RecordTypeId = recList[0].Id);
        insert con;
        TimeCardDayDomain.TimeCardDay day = new TimeCardDayDomain.TimeCardDay();       
        List<TimeCardDayDomain.TimeCardDay> timeCardDayInnerList = new List<TimeCardDayDomain.TimeCardDay>();
        List<TimeCardDayDomain.TimeCardDay> timeCardDayInnerList1 = new List<TimeCardDayDomain.TimeCardDay>();
        
        List<OrgWideEmailAddress> owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
        system.debug('::::owa'+owa);
        
        System_Values__c sysVal1 = new System_Values__c();
        sysVal1.Name = 'Timesheet';
        sysVal1.Value__c = owa[0].Id;
        
        insert sysVal1;
        
        Id recId = [SELECT Id,Name, DeveloperName FROM RecordType WHERE SObjectType = 'Contact' AND DeveloperName = 'DLS_Employee'].Id;
        
        List<Contact> conList = [SELECT Id, Active_DLS_Employee__c,RecordType.DeveloperName FROM Contact WHERE Id = :timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c];
        conList[0].Active_DLS_Employee__c = true;
        conList[0].RecordTypeId = recId;
        update conList;       
        
        String selectedContact = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
       
        day.SelectedProject = projectTaskList[0].AcctSeed__Project__c;
        day.SelectedProTask = projectTaskList[0].Id;
        day.SelectedInstructor = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
        day.Hours1 = String.valueOf(timecardDayList1[0].Total_Hours_Before_Approved__c);
        day.Hours2 = String.valueOf(timecardDayList1[1].Total_Hours_Before_Approved__c);
        day.Hours3 = String.valueOf(timecardDayList1[2].Total_Hours_Before_Approved__c);
        day.Hours4 = '1';
        day.Hours5 = '2';
        day.Hours6 = '1';
        day.Hours7 = '3';
        day.Day1 = timecardDayList1[0].AcctSeed__Date__c;
        day.Day2 = timecardDayList1[1].AcctSeed__Date__c;
        day.Day3 = timecardDayList1[2].AcctSeed__Date__c;
        day.Day4 = daysList[0];
        day.Day5 = daysList[4];
        day.Day6 = daysList[5];
        day.Day7 = daysList[6];
        day.isBillable = FALSE;
        day.timeCardLineId = timecardDayList1[0].AcctSeed__Time_Card_Line__c;
        day.timeCardId = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c;
        day.TotalHours = 13.0;
        day.status3 = 'Approved';
        
        day.Hrs1Day1Id = null;
        day.Hrs2Day2Id = null;
        day.Hrs3Day3Id = null;
       
        timeCardDayInnerList.add(day);
        List<Id> updateIdlist = new List<Id>();
        for(AcctSeed__Time_Card_Day__c timecard : timecardDayList1){
            updateIdlist.add(timecard.Id);
        }
        
        String jsontimeCardDay = JSON.serializePretty(timeCardDayInnerList);
        
        TimeCardDayDomain.TimeCardDay day1 = new TimeCardDayDomain.TimeCardDay();
        day1.SelectedProject = projectTaskList[0].AcctSeed__Project__c;
        day1.SelectedProTask = projectTaskList[0].Id;
        day1.SelectedInstructor = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
        day1.Hours1 = String.valueOf(timecardDayList1[0].Total_Hours_Before_Approved__c);
        day1.Hours2 = String.valueOf(timecardDayList1[1].Total_Hours_Before_Approved__c);
        day1.Hours3 = String.valueOf(timecardDayList1[2].Total_Hours_Before_Approved__c);
        day1.Hours4 = '1';
        day1.Hours5 = '2';
        day1.Hours6 = '1';
        day1.Hours7 = '3';
        day1.Day1 = timecardDayList1[0].AcctSeed__Date__c;
        day1.Day2 = timecardDayList1[1].AcctSeed__Date__c;
        day1.Day3 = timecardDayList1[2].AcctSeed__Date__c;
        day1.Day4 = daysList[0];
        day1.Day5 = daysList[4];
        day1.Day6 = daysList[5];
        day1.Day7 = daysList[6];
        day1.isBillable = TRUE;
        day1.timeCardLineId = timecardDayList1[0].AcctSeed__Time_Card_Line__c;        
        day1.timeCardId = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c;
        
        day1.TotalHours = 13.0;
        day1.Hrs1Day1Id = null;
        day1.Hrs2Day2Id = null;
        day1.Hrs3Day3Id = null;
        timeCardDayInnerList1.add(day1);
        
        String jsontimeCardDay1 = JSON.serializePretty(timeCardDayInnerList1);
        
        TimeKeeping_Admin_Controller.dmlOperationFunction(jsontimeCardDay1,String.Valueof(system.Today().addDays(-20)),String.Valueof(system.Today().addDays(20)),updateIdlist,selectedContact,'From Save','Test Revert');
        TimeKeeping_Admin_Controller.dmlOperationFunction(jsontimeCardDay1,String.Valueof(system.Today().addDays(-20)),String.Valueof(system.Today().addDays(20)),updateIdlist,selectedContact,'From Revert','Test Revert');

        TimeKeeping_Admin_Controller.dmlOperationFunction(jsontimeCardDay1,String.Valueof(system.Today().addDays(-20)),String.Valueof(system.Today().addDays(20)),updateIdlist,selectedContact,'Test Revert','Test Revert');
        
        test.stopTest();
    } 
    
    // To increase the code coverage from 80%
    static testmethod void test3() {
    
        DateTime dT = System.now();
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        Date weekStart = myDate.toStartofWeek().addDays(1);
        Date WeekEnd = myDate.toStartofWeek().addDays(7);
        
        Date startDate = weekStart;
        Date endDate = WeekEnd;
        
        String stDate = String.valueOf(weekStart);
        String edDate = String.valueOf(WeekEnd);
        
        List<Date> daysList = new List<Date>();
         
        while(startDate <= endDate) {
            daysList.add(startDate);
            startDate = startDate.addDays(1);
        }
        
        List<TimeCardDayDomain.TimeCardDay> timeCardDayInnerList = new List<TimeCardDayDomain.TimeCardDay>();
        
        List<AcctSeed__Time_Card_Day__c> timecardDayList1 = [SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Hours__c, AcctSeed__Time_Card_Line__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Total_Hours_Before_Approved__c,Status__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Total_Hours__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c            
                                                                FROM AcctSeed__Time_Card_Day__c LIMIT 5]; 
        
        Test.startTest();
        
        String selectedContact = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
        
        TimeCardDayDomain.TimeCardDay day = new TimeCardDayDomain.TimeCardDay();
        
        List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Name,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 5];
        
        day.SelectedProject = projectTaskList[0].AcctSeed__Project__c;
        day.SelectedProTask = projectTaskList[0].Id;
        day.SelectedInstructor = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
        day.Hours1 = String.valueOf(timecardDayList1[0].Total_Hours_Before_Approved__c);
        day.Hours2 = String.valueOf(timecardDayList1[1].Total_Hours_Before_Approved__c);
        day.Hours3 = String.valueOf(timecardDayList1[2].Total_Hours_Before_Approved__c);
        day.Hours4 = '1';
        day.Hours5 = '2';
        day.Hours6 = '1';
        day.Hours7 = '3';
        day.Day1 = timecardDayList1[0].AcctSeed__Date__c;
        day.Day2 = timecardDayList1[1].AcctSeed__Date__c;
        day.Day3 = timecardDayList1[2].AcctSeed__Date__c;
        day.Day4 = daysList[0];
        day.Day5 = daysList[4];
        day.Day6 = daysList[5];
        day.Day7 = daysList[6];
        day.isBillable = FALSE;
        day.timeCardLineId = timecardDayList1[0].AcctSeed__Time_Card_Line__c;
        day.timeCardId = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c;
        day.TotalHours = 13.0;
        day.status3 = 'Approved';
        day.status2 = 'Approved';
        day.status1 = 'Approved';
        day.status4 = 'Approved';
        day.status5 = 'Approved';
        day.status6 = 'Approved';
        day.Hrs1Day1Id = null;
        day.Hrs2Day2Id = null;
        day.Hrs3Day3Id = null;
        day.Hrs7Day7Id = timecardDayList1[0].Id;
        day.lateCancellation7 = FALSE;
        day.cancellationReason7 = 'Test';
       
        timeCardDayInnerList.add(day);
        List<Id> updateIdlist = new List<Id>();
      
        String jsontimeCardDay = JSON.serializePretty(timeCardDayInnerList); 
                                                               
        TimeKeeping_Admin_Controller.dmlOperationFunction(jsontimeCardDay,stDate,edDate,updateIdlist,selectedContact,'From Revert','Test Revert');                                                        
            
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE LastName = 'Testing'];
       
        if(conList.size() > 0) {
            
            List<AcctSeed__Time_Card__c> tcList = [SELECT Id, Name, Intructor__c FROM AcctSeed__Time_Card__c WHERE Id = :timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Id];
            if(tcList.size() > 0) {
                tcList[0].Intructor__c = conList[0].Id;
            }
            update tcList;
            
            selectedContact = tcList[0].Intructor__c;
            TimeKeeping_Admin_Controller.dmlOperationFunction(jsontimeCardDay,stDate,edDate,updateIdlist,selectedContact,'From Save','Test Save');                                                        
            Test.stopTest();
        }
    } 
    
    static testmethod void test4() {
    
        DateTime dT = System.now();
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
      
        Date weekStart = myDate.toStartofWeek().addDays(1);
        Date WeekEnd = myDate.toStartofWeek().addDays(7);
        
        Date startDate = weekStart;
        Date endDate = WeekEnd;
        
        String stDate = String.valueOf(weekStart);
        String edDate = String.valueOf(WeekEnd);

        List<Date> daysList = new List<Date>();
         
        while(startDate <= endDate) {
           daysList.add(startDate);
           startDate = startDate.addDays(1);
        }
       
        List<Events__c> eventList = [SELECT Id, Name, Schedule__c, schedule__r.Project_Task__c FROM Events__c];
        
        List<AcctSeed__Time_Card_Line__c> timecardLine2 = [Select Id,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c From AcctSeed__Time_Card_Line__c];
        
        List<AcctSeed__Time_Card_Day__c> timecardDayList1 = [SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Hours__c, AcctSeed__Time_Card_Line__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Total_Hours_Before_Approved__c,Status__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Total_Hours__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c            
                                                                FROM AcctSeed__Time_Card_Day__c LIMIT 5];       
        
        List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Name,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 5];
        
        List<AcctSeed__Project__c> projectList = [SELECT Id,Name,DLS_Class__c FROM AcctSeed__Project__c LIMIT 5];
        
        System_Values__c sysVal = new System_Values__c();
         sysVal.Name = 'TimeLog_Locking_Date';
         sysVal.Value__c = String.valueOf(system.today().addDays(-30));
         insert sysVal;
         
        Test.startTest();
        
        List<RecordType> recList = [Select ID,DeveloperName From Recordtype Where sObjectType='Contact' AND DeveloperName='DLS_Employee'];
        
        Contact con = new Contact(LastName ='Test',RecordTypeId = recList[0].Id);
        insert con;
        
        List<TimeCardDayDomain.TimeCardDay> timeCardDayInnerList1 = new List<TimeCardDayDomain.TimeCardDay>();
        
        String selectedContact = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
      
        List<Id> updateIdlist = new List<Id>();
        for(AcctSeed__Time_Card_Day__c timecard : timecardDayList1){
            updateIdlist.add(timecard.Id);
        }
        

        TimeCardDayDomain.TimeCardDay day1 = new TimeCardDayDomain.TimeCardDay();
        day1.SelectedProject = projectTaskList[0].AcctSeed__Project__c;
        day1.SelectedProTask = projectTaskList[0].Id;
        day1.SelectedInstructor = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
        day1.Hours1 = String.valueOf(timecardDayList1[0].Total_Hours_Before_Approved__c);
        day1.Hours2 = String.valueOf(timecardDayList1[1].Total_Hours_Before_Approved__c);
        day1.Hours3 = String.valueOf(timecardDayList1[2].Total_Hours_Before_Approved__c);
        day1.Hours4 = '1';
        day1.Hours5 = '2';
        day1.Hours6 = '1';
        day1.Hours7 = '3';
        day1.Day1 = timecardDayList1[0].AcctSeed__Date__c;
        day1.Day2 = timecardDayList1[1].AcctSeed__Date__c;
        day1.Day3 = timecardDayList1[2].AcctSeed__Date__c;
        day1.Day4 = daysList[0];
        day1.Day5 = daysList[4];
        day1.Day6 = daysList[5];
        day1.Day7 = daysList[6];
        day1.isBillable = TRUE;
        day1.timeCardLineId = timecardDayList1[0].AcctSeed__Time_Card_Line__c;
        day1.TaskType = 'Fringe';
        day1.Taskname = 'Bonus Leave Taken';
        day1.timeCardId = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c;
        
        day1.TotalHours = 13.0;
        day1.Hrs1Day1Id = timecardDayList1[0].Id;
        day1.Hrs2Day2Id = timecardDayList1[1].Id;
        day1.Hrs3Day3Id = timecardDayList1[2].Id;
        day1.lateCancellation1 = FALSE;
        day1.cancellationReason1 = 'Test';
        day1.lateCancellation2 = FALSE;
        day1.cancellationReason2 = 'Test';
        day1.lateCancellation3 = FALSE;
        day1.cancellationReason3 = 'Test';
        
        timeCardDayInnerList1.add(day1);
        
        String jsontimeCardDay1 = JSON.serializePretty(timeCardDayInnerList1);
        
        TimeKeeping_Admin_Controller.dmlOperationFunction(jsontimeCardDay1,String.Valueof(system.Today().addDays(-20)),String.Valueof(system.Today().addDays(20)),updateIdlist,selectedContact,'From Revert','Test Revert');
        Test.stopTest();
    }
    
    static testmethod void test6() {
    
        DateTime dT = System.now();
        Date myDate = date.newinstance(dT.year(), dT.month(), dT.day());
        
        system.debug('::::::::::::;fff'+dT);
        system.debug('::::::::'+myDate.toStartofWeek().addDays(1));
        system.debug('::::::::'+myDate.toStartofWeek().addDays(7));
        
        Date weekStart = myDate.toStartofWeek().addDays(1);
        Date WeekEnd = myDate.toStartofWeek().addDays(7);
        
        Date startDate = weekStart;
        Date endDate = WeekEnd;
        
        String stDate = String.valueOf(weekStart);
        String edDate = String.valueOf(WeekEnd);
        
        system.debug(':::::::stDate:::::::'+stDate);
        system.debug(':::::::edDate:::::::'+edDate);
        
         List<Date> daysList = new List<Date>();
         
        while(startDate <= endDate) {
           daysList.add(startDate);
           startDate = startDate.addDays(1);
        }
        system.debug('::::::::daysList::::::'+daysList);
      
        List<Events__c> eventList = [SELECT Id, Name, Schedule__c, schedule__r.Project_Task__c FROM Events__c];
        
        List<AcctSeed__Time_Card_Line__c> timecardLine2 = [Select Id,AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c From AcctSeed__Time_Card_Line__c];
        system.debug(':::timecardLine2::::'+timecardLine2[0].AcctSeed__Time_Card__r.Intructor__c);
        
        List<AcctSeed__Time_Card_Day__c> timecardDayList1 = [SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Hours__c, AcctSeed__Time_Card_Line__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,Total_Hours_Before_Approved__c,Status__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Total_Hours__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c            
                                                                FROM AcctSeed__Time_Card_Day__c LIMIT 5];       
        system.debug(':::timecardDayList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c'+timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c);
        
        List<AcctSeed__Project_Task__c> projectTaskList = [SELECT Id,Name,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 5];
        
        List<AcctSeed__Project__c> projectList = [SELECT Id,Name,DLS_Class__c FROM AcctSeed__Project__c LIMIT 5];
        
        System_Values__c sysVal = new System_Values__c();
        sysVal.Name = 'TimeLog_Locking_Date';
        sysVal.Value__c = String.valueOf(system.today().addDays(-30));
        insert sysVal;

        List<RecordType> recList = [Select ID,DeveloperName From Recordtype Where sObjectType='Contact' AND DeveloperName='DLS_Employee'];
        system.debug('::::recList'+recList);
        Contact con = new Contact(LastName ='Test',RecordTypeId = recList[0].Id);
        insert con;
        
        Test.startTest(); 
        
        TimeCardDayDomain.TimeCardDay day = new TimeCardDayDomain.TimeCardDay();
       
        List<TimeCardDayDomain.TimeCardDay> timeCardDayInnerList = new List<TimeCardDayDomain.TimeCardDay>();
        List<TimeCardDayDomain.TimeCardDay> timeCardDayInnerList1 = new List<TimeCardDayDomain.TimeCardDay>();
        
        String selectedContact = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
       
        day.SelectedProject = projectTaskList[0].AcctSeed__Project__c;
        day.SelectedProTask = projectTaskList[0].Id;
        day.SelectedInstructor = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
        day.Hours1 = String.valueOf(timecardDayList1[0].Total_Hours_Before_Approved__c);
        day.Hours2 = String.valueOf(timecardDayList1[1].Total_Hours_Before_Approved__c);
        day.Hours3 = String.valueOf(timecardDayList1[2].Total_Hours_Before_Approved__c);
        day.Hours4 = '1';
        day.Hours5 = '2';
        day.Hours6 = '1';
        day.Hours7 = '3';
        day.Day1 = timecardDayList1[0].AcctSeed__Date__c;
        day.Day2 = timecardDayList1[1].AcctSeed__Date__c;
        day.Day3 = timecardDayList1[2].AcctSeed__Date__c;
        day.Day4 = daysList[0];
        day.Day5 = daysList[4];
        day.Day6 = daysList[5];
        day.Day7 = daysList[6];
        day.isBillable = FALSE;
        day.timeCardLineId = timecardDayList1[0].AcctSeed__Time_Card_Line__c;
        day.timeCardId = timecardDayList1[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c;
        day.TotalHours = 13.0;
        day.status3 = 'Approved';
        day.status2 = 'Approved';
        day.status1 = 'Approved';
        day.status4 = 'Approved';
        day.status5 = 'Approved';
        day.status6 = 'Approved';
        day.Hrs1Day1Id = timecardDayList1[0].Id;
        day.Hrs2Day2Id = timecardDayList1[1].Id;
        day.Hrs3Day3Id = timecardDayList1[2].Id;
        day.lateCancellation1 = FALSE;
        day.cancellationReason1 = 'Test';
        day.lateCancellation2 = FALSE;
        day.cancellationReason2 = 'Test';
        day.lateCancellation3 = FALSE;
        day.cancellationReason3 = 'Test';
       
        timeCardDayInnerList.add(day);
        List<Id> updateIdlist = new List<Id>();
        for(AcctSeed__Time_Card_Day__c timecard : timecardDayList1){
            updateIdlist.add(timecard.Id);
        }
        
        String jsontimeCardDay = JSON.serializePretty(timeCardDayInnerList);

        TimeKeeping_Admin_Controller.dmlOperationFunction(jsontimeCardDay,stDate,edDate,updateIdlist,selectedContact,'From Save','Test save');
        day.Hrs1Day1Id = null;
        TimeKeeping_Admin_Controller.dmlOperationFunction(jsontimeCardDay,stDate,edDate,updateIdlist,selectedContact,'From Save','Test save');
        TimeKeeping_Admin_Controller.getLookupRecords('AcctSeed__Project__c','Test','');
        String conditin = 'AcctSeed__Opportunity__c != null';
        TimeKeeping_Admin_Controller.getLookupRecords('AcctSeed__Project__c','Test',conditin);
   
    }
    
    // To call adminModification_Notifications method in timeCardRelated_Email_Controller for Revert Action 
    public static testMethod void myTestMethod1(){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, country='United States',
                timezonesidkey='America/Los_Angeles', username='timekeepingtester@noemail.com', IsActive = TRUE);
       
        insert user;
        
        List<Contact> conList1 = [SELECT Id, Supervisor_Name__c, Active_DLS_Employee__c  FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' AND LastName='StaffContact' LIMIT 1];
        conList1[0].Active_DLS_Employee__c = TRUE;
        conList1[0].Supervisor_Name__c = user.Id;
        update conList1[0];
        System.debug('conList1==='+conList1);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' AND Id =:conList1[0].Id];
        
        Test.startTest();
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
                  
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
        
        Set<Id> dayId = new Set<Id>();
        dayId.add(day.Id);
        try{
            timeCardRelated_Email_Controller.adminModification_Notifications(dayId, 'Revert Action');
        }catch(Exception e){
        
            System.debug('============'+e.getLineNUmber());
        }
        Test.stopTest();
    }
    
    // To call adminModification_Notifications method in timeCardRelated_Email_Controller for Revert Action 
    public static testMethod void myTestMethod2(){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p.Id, country='United States',
                timezonesidkey='America/Los_Angeles', username='admintester@noemail.com', IsActive = TRUE);
       
        insert user;
        
        List<Contact> conList1 = [SELECT Id, Supervisor_Name__c, Active_DLS_Employee__c  FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' AND LastName='StaffContact' LIMIT 1];
        conList1[0].Active_DLS_Employee__c = TRUE;
        conList1[0].Supervisor_Name__c = user.Id;
        update conList1[0];
        System.debug('conList1==='+conList1);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'DLS_Employee' AND Id =:conList1[0].Id];
        
        Test.startTest();
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Assignment_Position__c = 'Class Leader';
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
        
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        System.debug('task ====='+task);
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        update timeCard;
        System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
                  
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
        
        Set<Id> dayId = new Set<Id>();
        dayId.add(day.Id);
        try{
            timeCardRelated_Email_Controller.adminModification_Notifications(dayId, 'Save Action');
        }catch(Exception e){
        
            System.debug('============'+e.getLineNUmber());
        }
        Test.stopTest();
    }
}