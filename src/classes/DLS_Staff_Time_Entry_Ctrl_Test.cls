@isTest
public Class DLS_Staff_Time_Entry_Ctrl_Test{
    @testSetup static void setup(){
        List<Contact_Assignments__c> conAssignList = TestClassUtil.createTestContactAssignment();
        Test.startTest();
            List<Events__c> eventList = TestClassUtil.createTestEvent();
            List<AcctSeed__Time_Card_Day__c> cardDay = TestClassUtil.createTestTimeCardDay();        
        Test.stopTest();
    }
    public static testMethod void myTest(){
        
        Date myDate1 = System.today();
        
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        Date startDate1 = weekStart1;
        Date endDate1 = WeekEnd1;
        
        String stDate1 = String.valueOf(weekStart1);
        String edDate1 = String.valueOf(WeekEnd1);
        
        Date myDate = System.today().toStartOfMonth().addDays(1);//Dec 1
        Date weekStart = myDate.addMonths(-2);//Oct 1       
        Date WeekEnd = myDate.addMonths(-1).addDays(-1);// Oct 31
        
        String stDate = String.valueOf(weekStart);
        String edDate = String.valueOf(WeekEnd);
        
        String intermediateStDate = String.valueOf(myDate.toStartOfWeek().addDays(1));
        String intermediateEdDate = String.ValueOf(myDate.toStartOfWeek().addDays(7));
        
        String interStDate = String.ValueOf(myDate.addMonths(-3).toStartOfWeek().addDays(1));
        String interEdDate = String.ValueOf(myDate.addMonths(-3).toStartOfWeek().addDays(7));
        
        String interStDate1 = String.ValueOf(myDate.addMonths(-3).toStartOfWeek().addDays(8));
        String interEdDate1 = String.ValueOf(myDate.addMonths(-3).toStartOfWeek().addDays(14));
        
        List<Date> daysList = new List<Date>();
         
        while(startDate1 <= endDate1) {
           daysList.add(startDate1);
           startDate1 = startDate1.addDays(1);
        }
        
        // Declare value for static value in class
        DLS_Staff_Time_Entry_Ctrl.isGroupAction = false;
        
        List<AcctSeed__Time_Card_Day__c> timeCardEventList = [SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Hours__c, AcctSeed__Time_Card_Line__c,AcctSeed__Internal_Comment__c,LastModifiedDate,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,Total_Hours_Before_Approved__c,Status__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c, 
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Total_Hours__c, AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c
            
                                                                FROM AcctSeed__Time_Card_Day__c LIMIT 5];
        
       
        List<AcctSeed__Time_Card_Period__c> timePeriodList = [SELECT Id,Name,AcctSeed__End_Date__c, AcctSeed__Start_Date__c FROM AcctSeed__Time_Card_Period__c LIMIT 2];

        System_Values__c sysVal = new System_Values__c(Name='TimeLog_Locking_Date', Value__c = String.ValueOf(System.today()));
        insert sysVal;
        
        Contact testCon = [SELECT Id FROM Contact WHERE Name LIKE '%Testing%' LIMIT 1];
        User usr = [SELECT Id, ContactId, Name, FirstName, LastName, Email FROM User WHERE Name = 'Testing' LIMIT 1];
        testCon.FirstName = usr.FirstName;
        testCon.LastName = usr.LastName;
        testCon.Email = usr.Email;
        update testCon;

        AcctSeed__Project_Task__c task = [SELECT Id,AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Id = :timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c];
        List<AcctSeed__Time_Card_Line__c> timeCardLine = [SELECT Id,Payroll_Item__c FROM AcctSeed__Time_Card_Line__c];
        List<Events__c> event = [SELECT Id FROM Events__c LIMIT 3];
        
        List<AcctSeed__Time_Card_Day__c> timeCardDay = new List<AcctSeed__Time_Card_Day__c> {
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = system.today().addDays(1),Status__c = 'Draft'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 1.00,AcctSeed__Hours__c = 1,AcctSeed__Date__c = system.today().addDays(2),Status__c = 'Draft'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(3),Status__c = 'Draft'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(4),Status__c = 'Draft'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[1].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(4),Status__c = 'Draft')
        };
        
        List<Id> timecardId = new List<Id>();
        for(AcctSeed__Time_Card_Day__c at :timeCardEventList){
            timecardId.add(at.Id);        
        }
        
        task.Project_Task_Type__c = 'Fringe';
        task.Name = 'Bonus Leave Taken';
        update task;
        Test.startTest();
        Id projId = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c;
        Id taskId = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
        Id insId = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
        Boolean billable = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c;
        //String payRoll =  timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Payroll_Item__c;
        String payRoll = '';
        
        Integer i=0;
        for(AcctSeed__Time_Card_Day__c day : timeCardEventList){
        
            day.AcctSeed__Date__c = daysList.get(i);
            i++;
        }
        update timeCardEventList;
                
        DLS_Staff_Time_Entry_Ctrl.getExistingTimeCardRecords(projId, taskId,insId , stDate1, edDate1, billable,payRoll);
        
        for(AcctSeed__Time_Card_Day__c day : timeCardEventList){
            day.AcctSeed__Date__c = daysList.get(i);
            i++;
        }
        update timeCardEventList;
        
        DLS_Staff_Time_Entry_Ctrl.getExistingTimeCardRecords(projId, taskId,insId , stDate1, edDate1, billable,payRoll);
        
        timeCardEventList[0].AcctSeed__Date__c = daysList.get(i);
        update timeCardEventList;
        DLS_Staff_Time_Entry_Ctrl.getExistingTimeCardRecords(projId, taskId,insId , stDate1, edDate1, billable,payRoll);
        
        
        AcctSeed__Time_Card__c newcard = new AcctSeed__Time_Card__c();
        newcard.Id = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c;
        newCard.Intructor__c = testCon.Id;
        update newCard;
        
        System.runAs(usr){
            
            DLS_Staff_Time_Entry_Ctrl.getEmployeeRelatedInfo(stDate1, edDate1);
            task.Project_Task_Type__c = 'ADMINISTRATIVE';
            update task;
            i=0;
            for(AcctSeed__Time_Card_Day__c day : timeCardEventList){
            
                day.AcctSeed__Date__c = daysList.get(i);
                i++;
            }
            update timeCardEventList;
                        
            DLS_Staff_Time_Entry_Ctrl.getEmployeeRelatedInfo(stDate1, edDate1);
            
            
            for(AcctSeed__Time_Card_Day__c day : timeCardEventList){
                day.AcctSeed__Date__c = daysList.get(i);
                i++;
            }
            update timeCardEventList;
                          
            DLS_Staff_Time_Entry_Ctrl.getEmployeeRelatedInfo(stDate1, edDate1);
            DLS_Staff_Time_Entry_Ctrl.getSummaryTimeRecords(stDate1, edDate1);
            
            String jsonCardDay = JSON.Serialize(timeCardDay);
        //    DLS_Staff_Time_Entry_Ctrl.timeCardDayCreation(jsonCardDay,interStDate,interEdDate,'FromSave',timecardId,new List<AcctSeed__Time_Card_Line__c>{new AcctSeed__Time_Card_Line__c(Id = timeCardLine[0].Id,Display_in_Future_Weeks__c = false)});
            DLS_Staff_Time_Entry_Ctrl.timeCardDayCreation(jsonCardDay,stDate,edDate,'FromSubmit',timecardId,new List<AcctSeed__Time_Card_Line__c>{new AcctSeed__Time_Card_Line__c(Id = timeCardLine[0].Id,Display_in_Future_Weeks__c = false)});
            DLS_Staff_Time_Entry_Ctrl.timeCardDayCreation(jsonCardDay,intermediateStDate,intermediateEdDate,'FromRecall',timecardId,new List<AcctSeed__Time_Card_Line__c>{new AcctSeed__Time_Card_Line__c(Id = timeCardLine[0].Id,Display_in_Future_Weeks__c = false)});
            DLS_Staff_Time_Entry_Ctrl.getLookupRecords('Events__c','15-00','');
        }
        
        Test.stopTest();
    }
    
    static testMethod void myTest1(){
        
        Test.startTest(); 
        Date myDate = System.today().toStartOfMonth().addDays(1);//Dec 1
        
        String interStDate = String.ValueOf(myDate);
        String interEdDate = String.ValueOf(myDate.addMonths(1).addDays(-1));
        Date myDate1 = System.today();
        
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        Date startDate1 = weekStart1;
        Date endDate1 = WeekEnd1;
        
        String stDate1 = String.valueOf(weekStart1);
        String edDate1 = String.valueOf(WeekEnd1);
        List<Date> daysList = new List<Date>();
        
        Integer i = 0;
         
        while(startDate1 <= endDate1) {
           daysList.add(startDate1);
           startDate1 = startDate1.addDays(1);
        }
        
        // Declare value for static value in class
        DLS_Staff_Time_Entry_Ctrl.isGroupAction = false;
        
        Contact testCon = [SELECT Id FROM Contact WHERE Name LIKE '%Testing%' LIMIT 1];
        User usr = [SELECT Id, ContactId, Name, FirstName, LastName, Email FROM User WHERE Name = 'Testing' LIMIT 1];
        testCon.FirstName = usr.FirstName;
        testCon.LastName = usr.LastName;
        testCon.Email = usr.Email;
        update testCon;
        
        AcctSeed__Time_Card_Line__c timeCardLine = [SELECT Id FROM AcctSeed__Time_Card_Line__c LIMIT 1];
        List<Events__c> event = [SELECT Id FROM Events__c LIMIT 3];
        
        List<AcctSeed__Time_Card_Day__c> timeCardDay = new List<AcctSeed__Time_Card_Day__c> {
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = system.today().addDays(1),Status__c = 'Draft'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 1.00,AcctSeed__Hours__c = 1,AcctSeed__Date__c = system.today().addDays(2),Status__c = 'Draft'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(3),Status__c = 'Draft'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(4),Status__c = 'Draft')

        };
        insert timeCardDay;
        List<AcctSeed__Time_Card_Day__c> timeCardEventList = [SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Hours__c, AcctSeed__Time_Card_Line__c,AcctSeed__Internal_Comment__c,LastModifiedDate,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,Total_Hours_Before_Approved__c,Status__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                                       AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c, AcctSeed__Time_Card_Line__r.AcctSeed__Total_Hours__c, AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c
            
                                                                FROM AcctSeed__Time_Card_Day__c LIMIT 7];
        
        AcctSeed__Project_Task__c task = [SELECT Id,AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Id = :timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c];
        
        List<AcctSeed__Project__c> projectList = [SELECT  Id,Name FROM AcctSeed__Project__c LIMIT 3];
        List<AcctSeed__Project_Task__c> taskList = [SELECT Id,Name FROM AcctSeed__Project_Task__c LIMIT 4];
        
        DLS_Staff_Time_Entry_Ctrl.getSummaryTimeRecords(stDate1, edDate1);
        
        List<Id> cardDayId = new List<Id>();
        List<Id> cardeventId = new List<Id>();
        
        for(AcctSeed__Time_Card_Day__c at : timeCardDay){
            cardDayId.add(at.Id);
        }
        
        for(AcctSeed__Time_Card_Day__c at : timeCardEventList){
            cardeventId.add(at.Id);
        }
        
        System.runAs(usr){
            
            DLS_Staff_Time_Entry_Ctrl.getEmployeeRelatedInfo(stDate1, edDate1);
            task.Project_Task_Type__c = 'ADMINISTRATIVE';
            update task;
            i = 0;
            for(AcctSeed__Time_Card_Day__c day : timeCardEventList){
            
                day.AcctSeed__Date__c = daysList.get(i);
                i++;
            }
            //update timeCardEventList;
            DLS_Staff_Time_Entry_Ctrl.getEmployeeRelatedInfo(stDate1, edDate1);
            
            DLS_Staff_Time_Entry_Ctrl.getSummaryTimeRecords(stDate1, edDate1);
            
            List<TimeCardDayDomain.TimeCardDay> cardDayList = new List<TimeCardDayDomain.TimeCardDay>();
            
            TimeCardDayDomain.TimeCardDay cardDay1 = new TimeCardDayDomain.TimeCardDay();
            
            cardDay1.SelectedProject = projectList[1].Id;
            cardDay1.SelectedProTask = taskList[1].Id;
            cardDay1.SelectedInstructor = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
            cardDay1.isBillable = true;
            cardDay1.Hours1 = String.ValueOf(10.00);
            cardDay1.Hours2 = String.ValueOf(10.00);
            cardDay1.Hours3 = String.ValueOf(10.00);
            cardDay1.Hours4 = String.ValueOf(10.00);
            cardDay1.Hours5 = String.ValueOf(10.00);
            cardDay1.Hours6 = String.ValueOf(10.00);
            cardDay1.Hours7 = String.ValueOf(10.00);
            cardDay1.Day1 = daysList.get(0);
            cardDay1.Day2 = daysList.get(1);
            cardDay1.Day3 = daysList.get(2);
            cardDay1.Day4 = daysList.get(3);
            cardDay1.Day5 = daysList.get(4);
            cardDay1.Day6 = daysList.get(5);
            cardDay1.Day7 = daysList.get(6);
            cardDay1.IsAdminProTask = true;// if AcctSeed__Project_Task__r.Project_Task_Type__c == 'ADMINISTRATIVE' then IsAdminProTask = true;
            cardDay1.TaskName = 'Testing';
            cardDay1.ProjectName = 'Test Project';
            cardDay1.TaskType = 'ADMINISTRATIVE';
            cardDay1.payRollItem = 'ADM';
            //cardDay1.timeCardLineId = timeCardLine.Id;
            cardDayList.add(cardDay1);
            
            TimeCardDayDomain.TimeCardDay cardDay2 = new TimeCardDayDomain.TimeCardDay();
            cardDay2.SelectedProject = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
            cardDay2.SelectedProTask = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
            cardDay2.SelectedInstructor = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
            cardDay2.isBillable = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c;
            cardDay2.Hrs1Day1Id = timeCardEventList[0].Id;
            cardDay2.Hrs2Day2Id = timeCardEventList[1].Id;
            cardDay2.Hrs3Day3Id = timeCardEventList[2].Id;
            cardDay2.Hrs4Day4Id = timeCardDay[0].Id;
            cardDay2.Hrs5Day5Id = timeCardDay[1].Id;
            cardDay2.Hrs6Day6Id = timeCardDay[2].Id;
            cardDay2.Hrs7Day7Id = timeCardDay[3].Id;
            cardDay2.Hours1 = String.ValueOf(10.00);
            cardDay2.Hours2 = String.ValueOf(10.00);
            cardDay2.Hours3 = String.ValueOf(10.00);
            cardDay2.Hours4 = String.ValueOf(10.00);
            cardDay2.Hours5 = String.ValueOf(10.00);
            cardDay2.Hours6 = String.ValueOf(10.00);
            cardDay2.Hours7 = String.ValueOf(10.00);
            cardDay2.Day1 = daysList.get(0);
            cardDay2.Day2 = daysList.get(1);
            cardDay2.Day3 = daysList.get(2);
            cardDay2.Day4 = daysList.get(3);
            cardDay2.Day5 = daysList.get(4);
            cardDay2.Day6 = daysList.get(5);
            cardDay2.Day7 = daysList.get(6);
            cardDay2.IsAdminProTask = false;// if AcctSeed__Project_Task__r.Project_Task_Type__c == 'ADMINISTRATIVE' then IsAdminProTask = true;
            cardDay2.TaskName = 'Bonus Leave Taken';// Other name like 'Test'
            cardDay2.ProjectName = 'Test Project';
            cardDay2.TaskType = 'Fringe';
            cardDay2.payRollItem = 'BLT';
            cardDay2.timeCardLineId = timeCardEventList[0].AcctSeed__Time_Card_Line__c;
            cardDayList.add(cardDay2);
            
            String jsonCardDay = JSON.Serialize(cardDayList);
            //DLS_Staff_Time_Entry_Ctrl.timeCardDayCreation(jsonCardDay, stDate1, edDate1,'FromSubmit',cardDayId);
            cardDayList.clear();
            TimeCardDayDomain.TimeCardDay cardDay = new TimeCardDayDomain.TimeCardDay();
            cardDay.SelectedProject = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
            cardDay.SelectedProTask = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
            cardDay.SelectedInstructor = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
            cardDay.isBillable = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c;
            cardDay.Hrs1Day1Id = timeCardEventList[0].Id;
            cardDay.Hrs2Day2Id = timeCardEventList[1].Id;
            cardDay.Hrs3Day3Id = timeCardEventList[2].Id;
            cardDay.Hrs4Day4Id = timeCardDay[0].Id;
            cardDay.Hrs5Day5Id = timeCardDay[1].Id;
            cardDay.Hrs6Day6Id = timeCardDay[2].Id;
            cardDay.Hrs7Day7Id = timeCardDay[3].Id;
            cardDay.Hours1 = String.ValueOf(10.00);
            cardDay.Hours2 = String.ValueOf(10.00);
            cardDay.Hours3 = String.ValueOf(10.00);
            cardDay.Hours4 = String.ValueOf(10.00);
            cardDay.Hours5 = String.ValueOf(10.00);
            cardDay.Hours6 = String.ValueOf(10.00);
            cardDay.Hours7 = String.ValueOf(10.00);
            cardDay.Day1 = daysList.get(0);
            cardDay.Day2 = daysList.get(1);
            cardDay.Day3 = daysList.get(2);
            cardDay.Day4 = daysList.get(3);
            cardDay.Day5 = daysList.get(4);
            cardDay.Day6 = daysList.get(5);
            cardDay.Day7 = daysList.get(6);
            cardDay.IsAdminProTask = false;// if AcctSeed__Project_Task__r.Project_Task_Type__c == 'ADMINISTRATIVE' then IsAdminProTask = true;
            cardDay.TaskName = 'Bonus Leave Taken';// Other name like 'Test'
            cardDay.ProjectName = 'Test Project';
            cardDay.TaskType = 'Fringe';
            cardDay.payRollItem = 'BLT';
            cardDay.timeCardLineId = timeCardLine.Id;
            cardDayList.add(cardDay);
            
            jsonCardDay = JSON.Serialize(cardDayList);
            DLS_Staff_Time_Entry_Ctrl.timeCardDayCreation(jsonCardDay, stDate1, edDate1,'FromSubmit',cardeventId,new List<AcctSeed__Time_Card_Line__c>{new AcctSeed__Time_Card_Line__c(Id = timeCardLine.Id,Display_in_Future_Weeks__c = false)});
        }
    } 
    public static testMethod void myTest2(){
        Date myDate1 = System.today();
        
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        Date startDate1 = weekStart1;
        Date endDate1 = WeekEnd1;
        
        String stDate1 = String.valueOf(weekStart1);
        String edDate1 = String.valueOf(WeekEnd1);
        List<Date> daysList = new List<Date>();
         
        while(startDate1 <= endDate1) {
           daysList.add(startDate1);
           startDate1 = startDate1.addDays(1);
        }
        Test.startTest();
        
        // Declare value for static value in class
        DLS_Staff_Time_Entry_Ctrl.isGroupAction = false;
        
        List<TimeCardDayDomain.TimeCardDay> cardDayList = new List<TimeCardDayDomain.TimeCardDay>();
        User usr = [SELECT Id,contactId,Name FROM User WHERE Name = 'Testing' LIMIT 1];AcctSeed__Time_Card_Line__c timeCardLine = [SELECT Id FROM AcctSeed__Time_Card_Line__c LIMIT 1];
        List<Events__c> event = [SELECT Id FROM Events__c LIMIT 3];
        
        List<AcctSeed__Time_Card_Day__c> timeCardEventList = [SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Hours__c, AcctSeed__Time_Card_Line__c,AcctSeed__Internal_Comment__c,LastModifiedDate,
                                                                   AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,Total_Hours_Before_Approved__c,Status__c,
                                                                   AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                                   AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c, AcctSeed__Time_Card_Line__r.AcctSeed__Total_Hours__c, AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c
        
                                                            FROM AcctSeed__Time_Card_Day__c LIMIT 8];
           
        TimeCardDayDomain.TimeCardDay cardDay1 = new TimeCardDayDomain.TimeCardDay();
        System.runAs(usr){
            cardDay1.SelectedProject = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
            cardDay1.SelectedProTask = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
            cardDay1.SelectedInstructor = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
            cardDay1.isBillable = true;
            cardDay1.Hours1 = String.ValueOf(10.00);
            cardDay1.Hours2 = String.ValueOf(10.00);
            cardDay1.Hours3 = String.ValueOf(10.00);
            cardDay1.Hours4 = String.ValueOf(10.00);
            cardDay1.Hours5 = String.ValueOf(10.00);
            cardDay1.Hours6 = String.ValueOf(10.00);
            cardDay1.Hours7 = String.ValueOf(10.00);
            cardDay1.Day1 = daysList.get(0);
            cardDay1.Day2 = daysList.get(1);
            cardDay1.Day3 = daysList.get(2);
            cardDay1.Day4 = daysList.get(3);
            cardDay1.Day5 = daysList.get(4);
            cardDay1.Day6 = daysList.get(5);
            cardDay1.Day7 = daysList.get(6);
            cardDay1.IsAdminProTask = true;// if AcctSeed__Project_Task__r.Project_Task_Type__c == 'ADMINISTRATIVE' then IsAdminProTask = true;
            cardDay1.TaskName = 'Bonus Leave Taken';
            cardDay1.ProjectName = 'Test Project';
            cardDay1.TaskType = 'Fringe';
            cardDay1.payRollItem = 'BLT';
            cardDay1.timeCardLineId = timeCardEventList[0].AcctSeed__Time_Card_Line__c;
            cardDayList.add(cardDay1);
            
            TimeCardDayDomain.TimeCardDay cardDay = new TimeCardDayDomain.TimeCardDay();
            cardDay.SelectedProject = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
            cardDay.SelectedProTask = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
            cardDay.SelectedInstructor = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
            cardDay.isBillable = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c;
            cardDay.Hours1 = String.ValueOf(10.00);
            cardDay.Hours2 = String.ValueOf(10.00);
            cardDay.Hours3 = String.ValueOf(10.00);
            cardDay.Hours4 = String.ValueOf(10.00);
            cardDay.Hours5 = String.ValueOf(10.00);
            cardDay.Hours6 = String.ValueOf(10.00);
            cardDay.Hours7 = String.ValueOf(10.00);
            cardDay.Day1 = daysList.get(0);
            cardDay.Day2 = daysList.get(1);
            cardDay.Day3 = daysList.get(2);
            cardDay.Day4 = daysList.get(3);
            cardDay.Day5 = daysList.get(4);
            cardDay.Day6 = daysList.get(5);
            cardDay.Day7 = daysList.get(6);
            cardDay.IsAdminProTask = false;// if AcctSeed__Project_Task__r.Project_Task_Type__c == 'ADMINISTRATIVE' then IsAdminProTask = true;
            cardDay.TaskName = 'Bonus Leave Taken';// Other name like 'Test'
            cardDay.ProjectName = 'Test Project';
            cardDay.TaskType = 'Fringe';
            cardDay.payRollItem = 'BLT';
            cardDay.timeCardLineId = timeCardEventList[0].AcctSeed__Time_Card_Line__c;
            cardDayList.add(cardDay);
            
            List<AcctSeed__Time_Card_Day__c> timeCardDay = new List<AcctSeed__Time_Card_Day__c> {
                    new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = system.today().addDays(-1),Status__c = 'Draft'),
                    new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 1.00,AcctSeed__Hours__c = 1,AcctSeed__Date__c = system.today().addDays(-2),Status__c = 'Draft'),
                    new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(-3),Status__c = 'Draft'),
                    new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(5),Status__c = 'Draft')
    
            };
            //insert timeCardDay;
            
            List<Id> cardDayId = new List<Id>();
        
            for(AcctSeed__Time_Card_Day__c at : timeCardDay){
                cardDayId.add(at.Id);
            }
            
            TimeCardDayDomain.TimeCardDay cardDay2 = new TimeCardDayDomain.TimeCardDay();
            cardDay2.SelectedProject = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
            cardDay2.SelectedProTask = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
            cardDay2.SelectedInstructor = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
            cardDay2.isBillable = true;
            cardDay2.Hrs1Day1Id = timeCardEventList[0].Id;
            cardDay2.Hrs2Day2Id = timeCardEventList[1].Id;
            cardDay2.Hrs3Day3Id = timeCardEventList[2].Id;
            cardDay2.Hrs4Day4Id = timeCardDay[0].Id;
            cardDay2.Hrs5Day5Id = timeCardDay[1].Id;
            cardDay2.Hrs6Day6Id = timeCardDay[2].Id;
            cardDay2.Hrs7Day7Id = timeCardDay[3].Id;
            cardDay2.Hours1 = String.ValueOf(10.00);
            cardDay2.Hours2 = String.ValueOf(10.00);
            cardDay2.Hours3 = String.ValueOf(10.00);
            cardDay2.Hours4 = String.ValueOf(10.00);
            cardDay2.Hours5 = String.ValueOf(10.00);
            cardDay2.Hours6 = String.ValueOf(10.00);
            cardDay2.Hours7 = String.ValueOf(10.00);
            cardDay2.Day1 = daysList.get(0);
            cardDay2.Day2 = daysList.get(1);
            cardDay2.Day3 = daysList.get(2);
            cardDay2.Day4 = daysList.get(3);
            cardDay2.Day5 = daysList.get(4);
            cardDay2.Day6 = daysList.get(5);
            cardDay2.Day7 = daysList.get(6);
            cardDay2.IsAdminProTask = false;// if AcctSeed__Project_Task__r.Project_Task_Type__c == 'ADMINISTRATIVE' then IsAdminProTask = true;
            cardDay2.TaskName = 'Bonus Leave Taken';// Other name like 'Test'
            cardDay2.ProjectName = 'Test Project';
            cardDay2.TaskType = 'ADMINISTRATIVE';
            cardDay2.payRollItem = 'ADM';
            cardDay2.timeCardLineId = timeCardEventList[0].AcctSeed__Time_Card_Line__c;
            cardDayList.add(cardDay2);
            String jsonCardDay1 = JSON.Serialize(cardDayList);
            DLS_Staff_Time_Entry_Ctrl.timeCardDayCreation(jsonCardDay1, stDate1, edDate1,'FromSubmit',cardDayId,new List<AcctSeed__Time_Card_Line__c>{new AcctSeed__Time_Card_Line__c(Id = timeCardLine.Id,Display_in_Future_Weeks__c = false)});
            DLS_Staff_Time_Entry_Ctrl.timeCardDayCreation(jsonCardDay1, stDate1, edDate1,'FromSave',cardDayId,new List<AcctSeed__Time_Card_Line__c>{new AcctSeed__Time_Card_Line__c(Id = timeCardLine.Id,Display_in_Future_Weeks__c = false)});
            DLS_Staff_Time_Entry_Ctrl.timeCardDayCreation(jsonCardDay1, stDate1, edDate1,'FromRecall',cardDayId,new List<AcctSeed__Time_Card_Line__c>{new AcctSeed__Time_Card_Line__c(Id = timeCardLine.Id,Display_in_Future_Weeks__c = false)});
        }
    Test.stopTest();
    }
    public static testMethod void myTest3(){
        Date myDate1 = System.today();
        
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        Date startDate1 = weekStart1;
        Date endDate1 = WeekEnd1;
        
        String stDate1 = String.valueOf(weekStart1);
        String edDate1 = String.valueOf(WeekEnd1);
        List<Date> daysList = new List<Date>();
         
        while(startDate1 <= endDate1) {
           daysList.add(startDate1);
           startDate1 = startDate1.addDays(1);
        }
        Test.startTest();
        
        // Declare value for static value in class
        DLS_Staff_Time_Entry_Ctrl.isGroupAction = false;
        
        List<TimeCardDayDomain.TimeCardDay> cardDayList = new List<TimeCardDayDomain.TimeCardDay>();
        User usr = [SELECT Id,contactId,Name FROM User WHERE Name = 'Testing' LIMIT 1];AcctSeed__Time_Card_Line__c timeCardLine = [SELECT Id FROM AcctSeed__Time_Card_Line__c LIMIT 1];
        List<Events__c> event = [SELECT Id FROM Events__c LIMIT 3];
        
        List<AcctSeed__Time_Card_Day__c> timeCardEventList = [SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Hours__c, AcctSeed__Time_Card_Line__c,AcctSeed__Internal_Comment__c,LastModifiedDate,
                                                                   AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,Total_Hours_Before_Approved__c,Status__c,
                                                                   AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                                   AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c, AcctSeed__Time_Card_Line__r.AcctSeed__Total_Hours__c, AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c
        
                                                            FROM AcctSeed__Time_Card_Day__c LIMIT 8];
        
        List<Id> cardDayId = new List<Id>();
        
        for(AcctSeed__Time_Card_Day__c at : timeCardEventList){
            cardDayId.add(at.Id);
        }
                                             
        System.runAs(usr){
            TimeCardDayDomain.TimeCardDay cardDay1 = new TimeCardDayDomain.TimeCardDay();
            cardDay1.SelectedProject = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
            cardDay1.SelectedProTask = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
            cardDay1.SelectedInstructor = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
            cardDay1.isBillable = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c;
            cardDay1.Hours1 = String.ValueOf(10.00);
            cardDay1.Hours2 = String.ValueOf(10.00);
            cardDay1.Hours3 = String.ValueOf(10.00);
            cardDay1.Hours4 = String.ValueOf(10.00);
            cardDay1.Hours5 = String.ValueOf(10.00);
            cardDay1.Hours6 = String.ValueOf(10.00);
            cardDay1.Hours7 = String.ValueOf(10.00);
            cardDay1.Day1 = daysList.get(0);
            cardDay1.Day2 = daysList.get(1);
            cardDay1.Day3 = daysList.get(2);
            cardDay1.Day4 = daysList.get(3);
            cardDay1.Day5 = daysList.get(4);
            cardDay1.Day6 = daysList.get(5);
            cardDay1.Day7 = daysList.get(6);
            cardDay1.IsAdminProTask = false;// if AcctSeed__Project_Task__r.Project_Task_Type__c == 'ADMINISTRATIVE' then IsAdminProTask = true;
            cardDay1.TaskName = 'Bonus Leave Taken';// Other name like 'Test'
            cardDay1.ProjectName = 'Test Project';
            cardDay1.TaskType = 'ADMINISTRATIVE';
            cardDay1.payRollItem = 'ADM';
            cardDay1.timeCardLineId = timeCardLine.Id;
            cardDayList.add(cardDay1);
            
            List<AcctSeed__Time_Card_Day__c> timeCardDay = new List<AcctSeed__Time_Card_Day__c> {
                    new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = system.today().addDays(5),Status__c = 'Draft'),
                    new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 1.00,AcctSeed__Hours__c = 1,AcctSeed__Date__c = system.today().addDays(6),Status__c = 'Draft'),
                    new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(7),Status__c = 'Draft'),
                    new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(8),Status__c = 'Draft')
    
            };
            insert timeCardDay;
            
            TimeCardDayDomain.TimeCardDay cardDay = new TimeCardDayDomain.TimeCardDay();
            cardDay.SelectedProject = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
            cardDay.SelectedProTask = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
            cardDay.SelectedInstructor = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
            cardDay.isBillable = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c;
            cardDay.Hrs1Day1Id = timeCardEventList[0].Id;
            cardDay.Hrs2Day2Id = timeCardEventList[1].Id;
            cardDay.Hrs3Day3Id = timeCardEventList[2].Id;
            cardDay.Hrs4Day4Id = timeCardDay[0].Id;
            cardDay.Hrs5Day5Id = timeCardDay[1].Id;
            cardDay.Hrs6Day6Id = timeCardDay[2].Id;
            cardDay.Hrs7Day7Id = timeCardDay[3].Id;
            cardDay.Hours1 = String.ValueOf(10.00);
            cardDay.Hours2 = String.ValueOf(10.00);
            cardDay.Hours3 = String.ValueOf(10.00);
            cardDay.Hours4 = String.ValueOf(10.00);
            cardDay.Hours5 = String.ValueOf(10.00);
            cardDay.Hours6 = String.ValueOf(10.00);
            cardDay.Hours7 = String.ValueOf(10.00);
            cardDay.Day1 = daysList.get(0);
            cardDay.Day2 = daysList.get(1);
            cardDay.Day3 = daysList.get(2);
            cardDay.Day4 = daysList.get(3);
            cardDay.Day5 = daysList.get(4);
            cardDay.Day6 = daysList.get(5);
            cardDay.Day7 = daysList.get(6);
            cardDay.IsAdminProTask = false;// if AcctSeed__Project_Task__r.Project_Task_Type__c == 'ADMINISTRATIVE' then IsAdminProTask = true;
            cardDay.TaskName = 'Bonus Leave Taken';// Other name like 'Test'
            cardDay.ProjectName = 'Test Project';
            cardDay.TaskType = 'ADMINISTRATIVE';
            cardDay.payRollItem = 'ADM';
            cardDay.timeCardLineId = timeCardLine.Id;
            cardDayList.add(cardDay);
            
            String jsonCardDay = JSON.Serialize(cardDayList);
            DLS_Staff_Time_Entry_Ctrl.timeCardDayCreation(jsonCardDay, stDate1, edDate1,'FromSave',cardDayId,new List<AcctSeed__Time_Card_Line__c>{new AcctSeed__Time_Card_Line__c(Id = timeCardLine.Id,Display_in_Future_Weeks__c = false)});
            DLS_Staff_Time_Entry_Ctrl.timeCardDayCreation(jsonCardDay, stDate1, edDate1,'FromSubmit',cardDayId,new List<AcctSeed__Time_Card_Line__c>{new AcctSeed__Time_Card_Line__c(Id = timeCardLine.Id,Display_in_Future_Weeks__c = false)});
            DLS_Staff_Time_Entry_Ctrl.timeCardDayCreation(jsonCardDay, stDate1, edDate1,'FromRecall',cardDayId,new List<AcctSeed__Time_Card_Line__c>{new AcctSeed__Time_Card_Line__c(Id = timeCardLine.Id,Display_in_Future_Weeks__c = false)});
        }
    }
    public static testMethod void myTest4(){
        
        Date myDate = System.today().toStartOfMonth().addDays(1);//Dec 1
        
        Date weekStart = myDate.addMonths(-2);//Oct 1
        Date WeekEnd = myDate.addMonths(-1).addDays(-1);// Oct 31
        
        String stDate = String.valueOf(weekStart);
        String edDate = String.valueOf(WeekEnd);
        
        Date intermediateStDate = myDate.toStartOfWeek().addDays(1);
        Date intermediateEdDate = myDate.toStartOfWeek().addDays(7);
        if(intermediateStDate <= System.today() || intermediateEdDate >= System.today()){
            intermediateStDate = myDate.addMonths(1).toStartOfWeek().addDays(1);
            intermediateEdDate = myDate.addMonths(1).toStartOfWeek().addDays(7);
        }
        List<Date> daysList = new List<Date>();
         
        while(intermediateStDate <= intermediateEdDate) {
           daysList.add(intermediateStDate);
           intermediateStDate = intermediateStDate.addDays(1);
        }
        Test.startTest();
        
        // Declare value for static value in class
        DLS_Staff_Time_Entry_Ctrl.isGroupAction = false;
        
        List<TimeCardDayDomain.TimeCardDay> cardDayList = new List<TimeCardDayDomain.TimeCardDay>();
        User usr = [SELECT Id,contactId,Name FROM User WHERE Name = 'Testing' LIMIT 1];AcctSeed__Time_Card_Line__c timeCardLine = [SELECT Id FROM AcctSeed__Time_Card_Line__c LIMIT 1];
        List<Events__c> event = [SELECT Id FROM Events__c LIMIT 3];
        Contact con = [SELECT Id FROM Contact WHERE Name LIKE 'Testing'];
        List<AcctSeed__Time_Card_Day__c> timeCardEventList = [SELECT Id, Name, AcctSeed__Date__c, AcctSeed__Hours__c, AcctSeed__Time_Card_Line__c,AcctSeed__Internal_Comment__c,LastModifiedDate,
                                                                   AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Name,Total_Hours_Before_Approved__c,Status__c,
                                                                   AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                                   AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c, AcctSeed__Time_Card_Line__r.AcctSeed__Total_Hours__c, AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c
        
                                                            FROM AcctSeed__Time_Card_Day__c LIMIT 8];
        
        List<Id> cardDayId = new List<Id>();
        
        for(AcctSeed__Time_Card_Day__c at : timeCardEventList){
            cardDayId.add(at.Id);
        }       
        
        System.runAs(usr){
            TimeCardDayDomain.TimeCardDay cardDay = new TimeCardDayDomain.TimeCardDay();
            cardDay.SelectedProject = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
            cardDay.SelectedProTask = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
            cardDay.SelectedInstructor = con.Id;
            cardDay.isBillable = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c;
            cardDay.Hours1 = String.ValueOf(10.00);
            cardDay.Hours2 = String.ValueOf(10.00);
            cardDay.Hours3 = String.ValueOf(10.00);
            cardDay.Hours4 = String.ValueOf(10.00);
            cardDay.Hours5 = String.ValueOf(10.00);
            cardDay.Hours6 = String.ValueOf(10.00);
            cardDay.Hours7 = String.ValueOf(10.00);
            cardDay.Day1 = daysList.get(0);
            cardDay.Day2 = daysList.get(1);
            cardDay.Day3 = daysList.get(2);
            cardDay.Day4 = daysList.get(3);
            cardDay.Day5 = daysList.get(4);
            cardDay.Day6 = daysList.get(5);
            cardDay.Day7 = daysList.get(6);
            cardDay.IsAdminProTask = false;// if AcctSeed__Project_Task__r.Project_Task_Type__c == 'ADMINISTRATIVE' then IsAdminProTask = true;
            cardDay.TaskName = 'Bonus Leave Taken';// Other name like 'Test'
            cardDay.ProjectName = 'Test Project';
            cardDay.TaskType = 'Fringe';
            cardDay.payRollItem = 'BLT';
            cardDayList.add(cardDay);
            
            TimeCardDayDomain.TimeCardDay cardDay1 = new TimeCardDayDomain.TimeCardDay();
            cardDay1.SelectedProject = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
            cardDay1.SelectedProTask = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
            cardDay1.SelectedInstructor = con.Id;
            cardDay1.isBillable = timeCardEventList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c;
            cardDay1.Hours1 = String.ValueOf(10.00);
            cardDay1.Hours2 = String.ValueOf(10.00);
            cardDay1.Hours3 = String.ValueOf(10.00);
            cardDay1.Hours4 = String.ValueOf(10.00);
            cardDay1.Hours5 = String.ValueOf(10.00);
            cardDay1.Hours6 = String.ValueOf(10.00);
            cardDay1.Hours7 = String.ValueOf(10.00);
            cardDay1.Day1 = daysList.get(0);
            cardDay1.Day2 = daysList.get(1);
            cardDay1.Day3 = daysList.get(2);
            cardDay1.Day4 = daysList.get(3);
            cardDay1.Day5 = daysList.get(4);
            cardDay1.Day6 = daysList.get(5);
            cardDay1.Day7 = daysList.get(6);
            cardDay1.IsAdminProTask = false;// if AcctSeed__Project_Task__r.Project_Task_Type__c == 'ADMINISTRATIVE' then IsAdminProTask = true;
            cardDay1.TaskName = 'Bonus Leave Taken';// Other name like 'Test'
            cardDay1.ProjectName = 'Test Project';
            cardDay1.TaskType = 'ADMINISTRATIVE';
            cardDay.payRollItem = 'ADM';
            cardDayList.add(cardDay1);
            String jsonCardDay = JSON.Serialize(cardDayList);
            DLS_Staff_Time_Entry_Ctrl.timeCardDayCreation(jsonCardDay, String.ValueOf(intermediateStDate), String.ValueOf(intermediateEdDate),'FromSubmit',cardDayId,new List<AcctSeed__Time_Card_Line__c>{new AcctSeed__Time_Card_Line__c(Id = timeCardLine.Id,Display_in_Future_Weeks__c = false)});
            DLS_Staff_Time_Entry_Ctrl.timeCardDayCreation(jsonCardDay, String.ValueOf(intermediateStDate), String.ValueOf(intermediateEdDate),'FromSave',cardDayId,new List<AcctSeed__Time_Card_Line__c>{new AcctSeed__Time_Card_Line__c(Id = timeCardLine.Id,Display_in_Future_Weeks__c = false)});
            DLS_Staff_Time_Entry_Ctrl.timeCardDayCreation(jsonCardDay, String.ValueOf(intermediateStDate), String.ValueOf(intermediateEdDate),'FromRecall',cardDayId,new List<AcctSeed__Time_Card_Line__c>{new AcctSeed__Time_Card_Line__c(Id = timeCardLine.Id,Display_in_Future_Weeks__c = false)});
        }
    } 
}