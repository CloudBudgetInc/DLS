@isTest
public class Staff_Daily_Timesheet_Ctrl_Test {
    
    @testsetup static void setup() {
        
        Test.startTest();            
            List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
        Test.stopTest();   
        List<Events__c> createTestEvent = TestClassUtil.createTestEvent();
        List<AcctSeed__Time_Card_Day__c > tcd = TestClassUtil.createTestTimeCardDay();
        List<MTT_Location__c> mttLoc = TestClassUtil.createTestLocations();
        List<AcctSeed__Cost_Rates__c> costRates = TestClassUtil.createTestCostRates(); 
    }
    
    public static testMethod void testMethod1() {
        
        List<contact> con = [SELECT Id, Name,Home_Department_Project__c FROM Contact LIMIT 2];
        List<User> usr = [SELECT Id,contactId,Name,LastName,FirstName FROM User WHERE Name = 'Testing' LIMIT 1];
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, RecordType.DeveloperName, Project__c, Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor'];
        
        if(con.size() > 0 && conAss.size() > 0 && usr.size() > 0) {
            
            Test.startTest();
            
            con[0].FirstName = usr[0].FirstName;
            con[0].LastName = usr[0].LastName;
            update con;
            
            conAss[0].Candidate_Name__c = con[0].Id;
            update conAss;
            
            List<System_Values__c> sys = new List<System_Values__c> {
                new System_Values__c(Name = 'TimeLog_Locking_Date', Value__c = '2016-06-01'),
                new System_Values__c(Name = 'Timekeeping Document Names', Value__c = 'Timekeeping Training Presentation, Timekeeping Policies & Procedures')
            };
            insert sys;
            
            System.runAs(usr[0]){
                String res1 = Staff_Daily_Timesheet_Ctrl.getInitialInformation();
                
                String stDate = String.valueof(System.today().toStartofWeek().addDays(1));
                List<String> stSplit = stDate.split(' ');
                List<String> stVal = stSplit[0].split('-');
                
                //Check wheather the expected week range is returned 
                system.assertEquals(true, res1.contains(stVal[1]+'/'+stVal[2]+'/'+stVal[0])); 
            }
            Test.stopTest();
        }
    }
    
    public static testMethod void testMethod2() {

        List<Contact> con = [SELECT Id, Name FROM Contact LIMIT 1];
        List<AcctSeed__Time_Card_Day__c> tcd = [SELECT Id, AcctSeed__Date__c, Name FROM AcctSeed__Time_Card_Day__c];
        List<AcctSeed__Time_Card__c> tc = [SELECT Id, Name FROM AcctSeed__Time_Card__c];
        List<AcctSeed__Time_Card_Line__c> tcl = [SELECT Id, Name, AcctSeed__Project_Task__c FROM AcctSeed__Time_Card_Line__c];
        List<Holiday> holydayList = [SELECT Id, ActivityDate FROM Holiday LIMIT 1];
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, RecordType.DeveloperName, Project__c, Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor'];
        
        String stDate = String.valueOf(System.today().toStartofWeek().addDays(7));
        String enDate = String.valueOf(Date.valueOf(stDate).addDays(6));
                
        Test.StartTest();
  
        String res2 = Staff_Daily_Timesheet_Ctrl.specificWeekInformation(stDate, enDate, con[0].Id);
        
        List<String> stSplit = stDate.split(' ');
        List<String> stVal = stSplit[0].split('-');
        
        // Check wheather the expected date is returned 
        system.assertEquals(true, res2.contains(stVal[1]+'/'+stVal[2]+'/'+stVal[0])); 
        Test.StopTest();
    } 
    

    public static testMethod void testMethod3() {
       
        List<contact> con = [SELECT Id, Name, Home_Department_Project__c FROM Contact LIMIT 1];
        Date myDate1 = System.today();
        List<AcctSeed__Time_Card_Day__c> timeCardDay = [SELECT Id, Name, Status__c FROM AcctSeed__Time_Card_Day__c LIMIT 2];  
      
        List<AcctSeed__Time_Card_Line__c> timeCardLine = [SELECT Id, Name, AcctSeed__Project_Task__c, AcctSeed__Time_Card_Line__c.Display_in_Future_Weeks__c FROM AcctSeed__Time_Card_Line__c LIMIT 2];  
               
        // Check wheather the expected values is returned 
        //System.assertEquals(true, res3.contains('dateVal')); 
        
        Test.startTest();
        TimeCardDayDomain.DayEntries de = new TimeCardDayDomain.DayEntries();
        List<TimeCardDayDomain.DayEntries> deList = new List<TimeCardDayDomain.DayEntries>();
     
        de.dayId = timeCardDay[0].Id;
        deList.add(de);
  
        String res4 = Staff_Daily_Timesheet_Ctrl.submitActionFunction(JSON.Serialize(deList));
        
        AcctSeed__Time_Card_Day__c tcdUp1 = [SELECT Id, Status__c FROM AcctSeed__Time_Card_Day__c WHERE Id = :timeCardDay[0].Id];
        
        // Time card day record status is upaded to Submitted
        System.assertEquals('Submitted', tcdUp1.status__c);
        
        deList = new List<TimeCardDayDomain.DayEntries>();
        
        de.status = 'Submitted';
        de.dayId = timeCardDay[0].Id;
        deList.add(de);
        
        String res5 = Staff_Daily_Timesheet_Ctrl.recallActionFunction(JSON.Serialize(deList));
        
        AcctSeed__Time_Card_Day__c tcdUp2 = [SELECT Id, Status__c FROM AcctSeed__Time_Card_Day__c WHERE Id = :timeCardDay[0].Id];
        
        // Time card day record status is upaded to Recalled
        System.assertEquals('Recalled', tcdUp2.status__c);
        
        deList = new List<TimeCardDayDomain.DayEntries>();
        de.lineId = timeCardLine[0].Id;
        de.isAvailable_FutureWeek = False;
        deList.add(de);
        
        String res6 = Staff_Daily_Timesheet_Ctrl.previousWeekLineUpdation(JSON.Serialize(deList));   
        
        // Time Card Line records are updated Successfully
        System.assertEquals('SUCCESS', res6);
        
       Test.stopTest(); 
    }     
    
    public static testMethod void testMethod4() {
       
        List<contact> con = [SELECT Id, Name FROM Contact WHERE Name = 'Test Contact1' LIMIT 1];
            
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        List<AcctSeed__Time_Card_Day__c> timeCardDay = [SELECT Id, Name, AcctSeed__Time_Card_Line__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c FROM AcctSeed__Time_Card_Day__c LIMIT 2];  
        List<AcctSeed__Time_Card_Line__c> timeCardLine = [SELECT Id, Name, AcctSeed__Time_Card__c, Location__c, AcctSeed__Billable__c, Payroll_Item__c, AcctSeed__Time_Card_Line__c.Display_in_Future_Weeks__c FROM AcctSeed__Time_Card_Line__c WHERE Id = :timeCardDay[0].AcctSeed__Time_Card_Line__c];  
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        AcctSeed__Time_Card_Period__c tcp = [SELECT Id,Name FROM AcctSeed__Time_Card_Period__c LIMIT 1];
        
        AcctSeed__Time_Card__c tc = [SELECT Id, Name, Intructor__c, AcctSeed__Time_Card_Period__c FROM AcctSeed__Time_Card__c WHERE Id = :timeCardLine[0].AcctSeed__Time_Card__c LIMIT 1];
        tc.AcctSeed__Time_Card_Period__c = tcp.Id;
        tc.Intructor__c = con[0].Id;
        update tc;
        
        Test.startTest();
        
        TimeCardDayDomain.DayEntries de = new TimeCardDayDomain.DayEntries();
        List<TimeCardDayDomain.DayEntries> deList = new List<TimeCardDayDomain.DayEntries>();
        
        timeCardLine[0].Payroll_Item__c = 'ADM';
        timeCardLine[0].Location__c = loc.Id;
        timeCardLine[0].AcctSeed__Billable__c = true;
        update timeCardLine;
        
        de.dayId = timeCardDay[0].Id;
        de.isUpdated = false;
        de.hours = 2.5;
        de.isBillable = true;
        de.dateVal = myDate1;
        de.isNew = true;
        de.projectId = timeCardDay[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
        de.taskId = timeCardDay[0].AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
        deList.add(de);
        
        String res7 = Staff_Daily_Timesheet_Ctrl.dmlOperationFunction(JSON.Serialize(deList),con[0].Id, String.valueOf(weekStart1), String.valueOf(WeekEnd1));
        
        // Time Card Day records are inserted Successfully
        System.assertEquals('SUCCESS',res7);
        
        tc.Intructor__c = null;
        update tc;
        
        de.dayId = timeCardDay[0].Id;
        de.isUpdated = true;
        de.hours = 2.5;
        de.isBillable = true;
        de.dateVal = myDate1;
        
        String res8 = Staff_Daily_Timesheet_Ctrl.dmlOperationFunction(JSON.Serialize(deList),con[0].Id, String.valueOf(weekStart1), String.valueOf(WeekEnd1));
        
        // Time Card Day records are updated Successfully
        System.assertEquals('SUCCESS',res8);
    } 
    
    // Method to cover timeCardDayFormation() in TimeCardDayTranslator
    public static testMethod void testMethod5() {
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek().addDays(1);
        Date WeekEnd1 = weekStart1.addDays(6);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        Test.startTest();
        
        insert user;
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
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
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(6)};
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
        
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(1), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(2), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(3), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(4), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(5), Status__c = 'Submitted'), 
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(6), Status__c = 'Submitted')
        };
        insert days;
        
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Project_Task__r.Name,
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Name, AcctSeed__Billable__c, AcctSeed__Project_Task__r.Project_Task_Type__c, Payroll_Item__c, 
            Location__c, Location__r.Name, 
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c, Labor_Cost_Rate__c, Contact_Assignment__c, Labor_Cost_Rate__r.Rate_Type__c, 
            Sequence_Number__c, 
                (SELECT Id, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, Status__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Days__r)
        FROM AcctSeed__Time_Card_Line__c
        WHERE Id = :timeCardLine.Id];
        
        System.debug('::::::lines:::::'+lines[0].AcctSeed__Time_Card_Days__r);
        
        System.runAs(user){
            TimeCardDayTranslator.timeCardDayFormation(lines, dateList, conList[0].Id);
        }
        
        Test.stopTest();
    }
    
    // Method to cover summaryFormatMethod() in TimeCardDayTranslator
    public static testMethod void testMethod6() {
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek().addDays(1);
        Date WeekEnd1 = weekStart1.addDays(6);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        Test.startTest();
        
        insert user;
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
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
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(-6)};
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
        
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(1), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(2), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(3), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(4), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(5), Status__c = 'Submitted'), 
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(6), Status__c = 'Submitted')
        };
        insert days;
        
        List<AcctSeed__Time_Card_Day__c> dayRec = [SELECT Id, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c WHERE Id NOT IN : days AND AcctSeed__Date__c = :System.today()];
        
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Project_Task__r.Name,
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Name, AcctSeed__Billable__c, AcctSeed__Project_Task__r.Project_Task_Type__c, Payroll_Item__c, 
            Location__c, Location__r.Name, 
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c, Labor_Cost_Rate__c, Contact_Assignment__c, Labor_Cost_Rate__r.Rate_Type__c, 
            Sequence_Number__c, 
                (SELECT Id, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, Status__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Days__r)
        FROM AcctSeed__Time_Card_Line__c
        WHERE (Id = :timeCardLine.Id OR Id = :dayRec[0].AcctSeed__Time_Card_Line__c)];
        
        System.debug('::::::lines:::::'+lines[0].AcctSeed__Time_Card_Days__r);
        
        System.runAs(user){
            TimeCardDayTranslator.summaryFormatMethod(lines, dateList);
        }
        
        Test.stopTest();
    }
      
    // Method to cover summaryShowdetailFormation() in TimeCardDayTranslator
    public static testMethod void testMethod7() {
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek().addDays(1);
        Date WeekEnd1 = weekStart1.addDays(6);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        Test.startTest();
        
        insert user;
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
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
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(-6)};
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
        
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted')
        };
        insert days;
        
        List<AcctSeed__Time_Card_Day__c> dayRec = [SELECT Id, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c WHERE Id NOT IN : days AND AcctSeed__Date__c = :System.today()];
        
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Project_Task__r.Name,
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Name, AcctSeed__Billable__c, AcctSeed__Project_Task__r.Project_Task_Type__c, Payroll_Item__c, 
            Location__c, Location__r.Name, 
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c, Labor_Cost_Rate__c, Contact_Assignment__c, Labor_Cost_Rate__r.Rate_Type__c, 
            Sequence_Number__c, 
                (SELECT Id, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, Status__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Days__r)
        FROM AcctSeed__Time_Card_Line__c
        WHERE (Id = :timeCardLine.Id OR Id = :dayRec[0].AcctSeed__Time_Card_Line__c)];
        
        System.debug('::::::lines:::::'+lines[0].AcctSeed__Time_Card_Days__r);
        
        System.runAs(user){
            TimeCardDayTranslator.summaryShowdetailFormation(lines, dateList);
        }
        
        Test.stopTest();
    }
    
    // Method to cover approvalPagetimeDaydetailMethod() in TimeCardDayTranslator
    public static testMethod void testMethod8() {
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek().addDays(1);
        Date WeekEnd1 = weekStart1.addDays(6);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        Test.startTest();
        
        insert user;
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
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
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(-6)};
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
        
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted')
        };
        insert days;
        
        List<AcctSeed__Time_Card_Day__c> dayRecs = [SELECT Id, AcctSeed__Time_Card_Line__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Name, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,
            AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name, AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.DLS_Class__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c, 
            AcctSeed__Date__c, Total_Hours_Before_Approved__c, Late_Cancellation__c, AcctSeed__Internal_Comment__c, 
            AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId, AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName, 
            AcctSeed__Time_Card_Line__r.AcctSeed__Billable__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Name, 
            AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName 
        FROM AcctSeed__Time_Card_Day__c WHERE Id IN : days];
        
        
        System.runAs(user){
            TimeCardDayTranslator.approvalPagetimeDaydetailMethod(dayRecs, dayRecs);
        }
        
        Test.stopTest();
    }
    
    // Method to cover getPreviousWeekTaskDetails() in TimeCardDayTranslator
    public static testMethod void testMethod9() {
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek().addDays(1);
        Date WeekEnd1 = weekStart1.addDays(6);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        Test.startTest();
        
        insert user;
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
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
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(-6)};
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
        
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(1), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(2), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(3), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(4), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(5), Status__c = 'Submitted'), 
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(6), Status__c = 'Submitted')
        };
        insert days;
                
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Project_Task__r.Name,
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Name, AcctSeed__Billable__c, AcctSeed__Project_Task__r.Project_Task_Type__c, Payroll_Item__c, 
            Location__c, Location__r.Name, Display_in_Future_Weeks__c, 
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c, Labor_Cost_Rate__c, Contact_Assignment__c, Labor_Cost_Rate__r.Rate_Type__c, 
            Sequence_Number__c, 
                (SELECT Id, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, Status__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Days__r)
        FROM AcctSeed__Time_Card_Line__c
        WHERE (Id = :timeCardLine.Id)];
        
        System.debug('::::::lines:::::'+lines[0].AcctSeed__Time_Card_Days__r);
        
        System.runAs(user){
            TimeCardDayTranslator.getPreviousWeekTaskDetails(lines, conList[0].Id);
        }
        
        Test.stopTest();
    }
    
    // Method to cover existingLineFormation_WithoutDay() in TimeCardDayTranslator
    public static testMethod void testMethod10() {
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek().addDays(1);
        Date WeekEnd1 = weekStart1.addDays(6);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        Test.startTest();
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
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
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
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(-6)};
        
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Project_Task__r.Name,
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Name, AcctSeed__Billable__c, AcctSeed__Project_Task__r.Project_Task_Type__c, Payroll_Item__c, 
            Location__c, Location__r.Name, Display_in_Future_Weeks__c, 
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c, Labor_Cost_Rate__c, Contact_Assignment__c, Labor_Cost_Rate__r.Rate_Type__c, 
            Sequence_Number__c, 
                (SELECT Id, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, Status__c, Total_Hours_Before_Approved__c FROM AcctSeed__Time_Card_Days__r)
        FROM AcctSeed__Time_Card_Line__c
        WHERE (Id = :timeCardLine.Id)];        
        System.runAs(user){
            TimeCardDayTranslator.existingLineFormation_WithoutDay(lines, dateList, conList[0].Id);
        }
        
        Test.stopTest();
    }
    
    // Method to cover daily_SummaryDetailsFormation() in TimeCardDayTranslator
    public static testMethod void testMethod11() {
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek().addDays(1);
        Date WeekEnd1 = weekStart1.addDays(6);
        
        List<Contact> conList = [SELECT Id, Home_Department_Project__c, Home_Department_Project__r.RecordType.DeveloperName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        Test.startTest();
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
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
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
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        timeCardLine.Display_in_Future_Weeks__c = TRUE;
        //timeCardLine.Sequence_Number__c = 2;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(-6)};
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
        
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(1), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(2), Status__c = 'Submitted')
        };
        insert days;
                
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Project_Task__r.Name,
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Name, AcctSeed__Billable__c, AcctSeed__Project_Task__r.Project_Task_Type__c, Payroll_Item__c, 
            Location__c, Location__r.Name, Display_in_Future_Weeks__c, 
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c, Labor_Cost_Rate__c, Contact_Assignment__c, Labor_Cost_Rate__r.Rate_Type__c, 
            Sequence_Number__c, AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,
                (SELECT Id, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, Status__c, Total_Hours_Before_Approved__c, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Days__r)
        FROM AcctSeed__Time_Card_Line__c
        WHERE (Id = :timeCardLine.Id)];
        
        System.debug('::::::lines:::::'+lines[0].AcctSeed__Time_Card_Days__r);
                
        System.runAs(user){
            //TimeCardDayTranslator.daily_SummaryDetailsFormation(lines, System.Today(), System.Today().addDays(2), conList, lines, projects, task, conAss, new List<Project_Task_Master__c>(), new Set<Date>());
        }
        
        Test.stopTest();
    }
    
    // Method to cover adminRowsFormation() in TimeCardDayTranslator
    public static testMethod void testMethod13() {
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek().addDays(1);
        Date WeekEnd1 = weekStart1.addDays(6);
        
        List<Contact> conList = [SELECT Id, Home_Department_Project__c, Home_Department_Project__r.RecordType.DeveloperName, EE_Pay_Status__c FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
        
        Test.startTest();
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, Payroll_Item__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0];
        
        List<AcctSeed__Project__c> projects = [SELECT Id, RecordType.DeveloperName, Name, Training_Location__c, Training_Location__r.Name FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
        
        conList[0].Home_Department_Project__c = projects[0].Id;
        update conList[0];
        
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Project_Task_Type__c, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, Payroll_Item__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        task[0].Project_Task_Type__c = 'ADMINISTRATIVE';
        task[0].Name = 'ADMINISTRATIVE';
        task[0].Payroll_Item__c = 'RNB';
        update task[0];
        
        List<Contact> conList1 = [SELECT Id, Home_Department_Project__c, Home_Department_Project__r.RecordType.DeveloperName, EE_Pay_Status__c FROM Contact WHERE Id = :conList[0].Id];
        
        List<AcctSeed__Project_Task__c> task1 = [SELECT Id, Project_Task_Type__c, AcctSeed__Project__c, Name,Payroll_Item__c FROM AcctSeed__Project_Task__c WHERE Id = :task[0].Id];
        
        System.runAs(user){
            TimeCardDayTranslator.adminRowsFormation(System.Today(), new Set<String>(), conList1, projects, task1, conAss, new List<Project_Task_Master__c>(), new Set<Date>(),5,5);
        }
        Test.stopTest();
    }
    
    // Method to cover entriesFormation() in TimeCardDayTranslator
    public static testMethod void testMethod14() {
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek().addDays(1);
        Date WeekEnd1 = weekStart1.addDays(6);
        
        List<Contact> conList = [SELECT Id, Home_Department_Project__c, Home_Department_Project__r.RecordType.DeveloperName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        Test.startTest();
        
        insert user;
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
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
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        timeCardLine.Display_in_Future_Weeks__c = TRUE;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(-6)};
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
        
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(1), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(2), Status__c = 'Submitted')
        };
        insert days;
                
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Project_Task__r.Name,
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Name, AcctSeed__Billable__c, AcctSeed__Project_Task__r.Project_Task_Type__c, Payroll_Item__c, 
            Location__c, Location__r.Name, Display_in_Future_Weeks__c, 
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c, Labor_Cost_Rate__c, Contact_Assignment__c, Labor_Cost_Rate__r.Rate_Type__c, 
            Sequence_Number__c, AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,
                (SELECT Id, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, Status__c, Total_Hours_Before_Approved__c, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Days__r)
        FROM AcctSeed__Time_Card_Line__c
        WHERE (Id = :timeCardLine.Id)];
        
        System.debug('::::::lines:::::'+lines[0].AcctSeed__Time_Card_Days__r);
                
        System.runAs(user){
            TimeCardDayTranslator.entriesFormation(lines, lines, projects, task, conAss, new List<Project_Task_Master__c>(), conList);
        }
        
        Test.stopTest();
    }
    
    // Method to cover previousWeekFormation() in TimeCardDayTranslator
    public static testMethod void testMethod15() {
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek().addDays(1);
        Date WeekEnd1 = weekStart1.addDays(6);
        
        List<Contact> conList = [SELECT Id, Home_Department_Project__c, Home_Department_Project__r.RecordType.DeveloperName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        Test.startTest();
        
        insert user;
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
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
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        timeCardLine.Display_in_Future_Weeks__c = TRUE;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(-6)};
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
        
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(1), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(2), Status__c = 'Submitted')
        };
        insert days;
                
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Project_Task__r.Name,
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Name, AcctSeed__Billable__c, AcctSeed__Project_Task__r.Project_Task_Type__c, Payroll_Item__c, 
            Location__c, Location__r.Name, Display_in_Future_Weeks__c, 
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c, Labor_Cost_Rate__c, Contact_Assignment__c, Labor_Cost_Rate__r.Rate_Type__c, 
            Sequence_Number__c, AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,
                (SELECT Id, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, Status__c, Total_Hours_Before_Approved__c, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Days__r)
        FROM AcctSeed__Time_Card_Line__c
        WHERE (Id = :timeCardLine.Id)];
        
        System.debug('::::::lines:::::'+lines[0].AcctSeed__Time_Card_Days__r);
                
        System.runAs(user){
            TimeCardDayTranslator.previousWeekFormation(lines, conList);
        }
        
        Test.stopTest();
    }
    
    // Method to cover notesFormation_Instructor() in TimeCardDayTranslator
    public static testMethod void testMethod16() {
    
        List<Opportunity> oppList = [SELECT Id,Name FROM Opportunity LIMIT 2];
        
        List<Contact> conList = [SELECT Id, Home_Department_Project__c, Home_Department_Project__r.RecordType.DeveloperName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
                
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<AcctSeed__Time_Card_Day__c> timeCardDayList = [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Hours__c,Status__c,AcctSeed__Time_Card_Line__c,
            Total_Hours_Before_Approved__c,AcctSeed__Internal_Comment__c
        FROM AcctSeed__Time_Card_Day__c LIMIT 3];
        
        List<Accounting_Seed_Time_Snapshot__c> timeSnapshotList = new List<Accounting_Seed_Time_Snapshot__c> {
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator', Reference_Id__c = 'Test', Note_Type__c = 'Instructor Daily Entry Recall', Time_Card_Day__c = timeCardDayList[0].Id, Date__c = timeCardDayList[0].AcctSeed__Date__c, Hours__c = timeCardDayList[0].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[0].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[0].Status__c,Time_Card_Line__c = timeCardDayList[0].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[0].Total_Hours_Before_Approved__c),
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator', Reference_Id__c = 'Test Partial Reject', Note_Type__c = 'Student Daily Entry Reject',Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c),
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator', Reference_Id__c = 'Test Partial Reject', Note_Type__c = 'Instructor Daily Entry Student Hours Mismatch',Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c)
        };
        
        System.runAs(user){
            TimeCardDayTranslator.notesFormation(timeSnapshotList);
        }
    }
    
    // Method to cover formatNotes() in TimeCardDayTranslator
    public static testMethod void testMethod17() {
    
        TimeCardDayTranslator.formatNotes('Cancellation Reason Notes:', 'Instructor Daily Entry Late Cancellation');
        TimeCardDayTranslator.formatNotes('Notes:', 'Instructor Daily Entry Student Hours Mismatch');
        TimeCardDayTranslator.formatNotes('Project Task:', 'Daily Entry Edit');
        TimeCardDayTranslator.formatNotes('Reason:', 'Student Daily Entry Reject');
        TimeCardDayTranslator.formatNotes('Project Task:', 'new test');
        TimeCardDayTranslator.formatNotes('Date:', 'Instructor Daily Entry Recall');
    }
    
    // Method to cover notesFormation_Instructor() in TimeCardDayTranslator
    public static testMethod void testMethod18() {
    
        List<Opportunity> oppList = [SELECT Id,Name FROM Opportunity LIMIT 2];
        
        List<Contact> conList = [SELECT Id, Home_Department_Project__c, Home_Department_Project__r.RecordType.DeveloperName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
                
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<AcctSeed__Time_Card_Day__c> timeCardDayList = [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Hours__c,Status__c,AcctSeed__Time_Card_Line__c,
            Total_Hours_Before_Approved__c,AcctSeed__Internal_Comment__c
        FROM AcctSeed__Time_Card_Day__c LIMIT 3];
        
        List<Accounting_Seed_Time_Snapshot__c> timeSnapshotList = new List<Accounting_Seed_Time_Snapshot__c> {
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator', Reference_Id__c = 'Test', Note_Type__c = 'Instructor Daily Entry Recall', Time_Card_Day__c = timeCardDayList[0].Id, Date__c = timeCardDayList[0].AcctSeed__Date__c, Hours__c = timeCardDayList[0].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[0].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[0].Status__c,Time_Card_Line__c = timeCardDayList[0].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[0].Total_Hours_Before_Approved__c),
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator', Reference_Id__c = 'Test Partial Reject', Note_Type__c = 'Student Daily Entry Reject',Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c),
            new Accounting_Seed_Time_Snapshot__c(CreatedDate = System.now(), Notes__c = 'test notes for TimeCardDayCommunityTranslator', Reference_Id__c = 'Test Partial Reject', Note_Type__c = 'Instructor Daily Entry Student Hours Mismatch',Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c)
        };
        
        System.runAs(user){
            TimeCardDayTranslator.notesFormation_Instructor(timeSnapshotList);
        }
    }
       
    // Method to cover approvalSummaryDetailFormation() in TimeCardDayTranslator
    public static testMethod void testMethod19() {
        
        Date myDate1 = System.today();
         
        Date weekStart1 = myDate1.toStartofWeek()+1;
        Date WeekEnd1 = myDate1.toStartofWeek()+7;
        
        List<Contact> conList = [SELECT Id, Home_Department_Project__c, Home_Department_Project__r.RecordType.DeveloperName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
                
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        Test.startTest();
        
        insert user;
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
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
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        timeCardLine.Display_in_Future_Weeks__c = TRUE;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(-6)};
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
        
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(1), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(2), Status__c = 'Submitted')
        };
        insert days;
                
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Project_Task__r.Name,
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Name, AcctSeed__Billable__c, AcctSeed__Project_Task__r.Project_Task_Type__c, Payroll_Item__c, 
            Location__c, Location__r.Name, Display_in_Future_Weeks__c, AcctSeed__Time_Card__r.Intructor__c, AcctSeed__Time_Card__r.Intructor__r.Name,
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c, Labor_Cost_Rate__c, Contact_Assignment__c, Labor_Cost_Rate__r.Rate_Type__c, 
            Sequence_Number__c, AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,
                (SELECT Id, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, AcctSeed__Invoice_Comment__c, Status__c, Total_Hours_Before_Approved__c, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Days__r)
        FROM AcctSeed__Time_Card_Line__c
        WHERE (Id = :timeCardLine.Id)];
        
        System.debug('::::::lines:::::'+lines[0].AcctSeed__Time_Card_Days__r);
                
        System.runAs(user){
            TimeCardDayTranslator.approvalSummaryDetailFormation(lines, Date.Today(), Date.Today().addDays(1));
        }
        
        Test.stopTest();
    }
    
    // Method to cover buttonDisplayFunction() in TimeCardDayTranslator
    public static testMethod void testMethod20() {
    
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        List<Contact> conList = [SELECT Id, Home_Department_Project__c, Home_Department_Project__r.RecordType.DeveloperName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
                
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        TimeCardDayDomain.DayEntries day1 = new TimeCardDayDomain.DayEntries();
        day1.status = 'Submitted';
        
        TimeCardDayDomain.DayEntries day2 = new TimeCardDayDomain.DayEntries();
        day2.status = 'Draft';
        
        TimeCardDayDomain.DayEntries day3 = new TimeCardDayDomain.DayEntries();
        day3.status = 'Reverted';
        
        TimeCardDayDomain.DayEntries day4 = new TimeCardDayDomain.DayEntries();
        day4.status = 'Rejected';
        
        TimeCardDayDomain.DayEntries day5 = new TimeCardDayDomain.DayEntries();
        day5.status = 'Recalled';
        
        List<TimeCardDayDomain.DayEntries> dayList = new List<TimeCardDayDomain.DayEntries>();
        dayList.add(day1);
        dayList.add(day2);
        dayList.add(day3);
        dayList.add(day4);
        dayList.add(day5);
        
        
        System.runAs(user){
            TimeCardDayTranslator.buttonDisplayFunction(dayList, currStart, currEnd);
        }
    }
       
    // Method to cover adminTimeEntryFormation() in TimeCardDayTranslator
    public static testMethod void testMethod21() {
    
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        Test.startTest();
        
        insert user;
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = currStart;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
                 
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
                
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = currStart;
        schList[0].End_Date__c = currEnd;
        schList[0].Instructor__c = conList[0].Id;
        schList[0].Start_Time__c = '03:00 PM';
        schList[0].End_Time__c = '05:00 PM';
        update schList;
        System.debug('schList===='+schList);
        
        List<Events__c> eve = [SELECT Id FROM Events__c LIMIT 1];
        eve[0].Schedule__c = schList[0].Id;
        eve[0].SequenceNo__c = 1;
        eve[0].Instructor__c = conList[0].Id;
        eve[0].Date__c = currStart;
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
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(-6)};
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
        
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = currStart, Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = currStart.addDays(1), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = currStart.addDays(2), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = currStart.addDays(3), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = currStart.addDays(4), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = currStart.addDays(5), Status__c = 'Submitted'), 
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = currStart.addDays(6), Status__c = 'Submitted')
        };
        insert days;
                
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Project_Task__r.Name,
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Name, AcctSeed__Billable__c, AcctSeed__Project_Task__r.Project_Task_Type__c, Payroll_Item__c, 
            Location__c, Location__r.Name, Display_in_Future_Weeks__c, AcctSeed__Time_Card__c,
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c, Labor_Cost_Rate__c, Contact_Assignment__c, Labor_Cost_Rate__r.Rate_Type__c, 
            Sequence_Number__c, 
                (SELECT Id, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, Status__c, Total_Hours_Before_Approved__c, Late_Cancellation__c,
                    Cancellation_Reason__c
                FROM AcctSeed__Time_Card_Days__r)
        FROM AcctSeed__Time_Card_Line__c
        WHERE (Id = :timeCardLine.Id)];
        
        System.debug('::::::lines:::::'+lines[0].AcctSeed__Time_Card_Days__r);
        
        System.runAs(user){
            TimeCardDayTranslator.adminTimeEntryFormation(lines, currStart, currEnd, String.valueOf(conList[0].Id));
        }
        
        Test.stopTest();
    }
   
    // Method to cover approvalSummarytableFormationmethod() in TimeCardDayTranslator
    public static testMethod void testMethod22() {
    
        Date currStart = system.today().toStartofWeek().addDays(1);
        Date currEnd = currStart.addDays(6);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        Test.startTest();
        
        insert user;
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = currStart;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
                 
        List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Labor_GL_Account__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
                
        List<Schedule__c> schList = [SELECT Id, Project__c,Status__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c LIMIT 1];
        schList[0].Status__c = 'Active';
        schList[0].Project__c = task[0].AcctSeed__Project__c;
        schList[0].Project_Task__c = task[0].Id;
        schList[0].Start_Date__c = currStart;
        schList[0].End_Date__c = currEnd;
        schList[0].Instructor__c = conList[0].Id;
        schList[0].Start_Time__c = '03:00 PM';
        schList[0].End_Time__c = '05:00 PM';
        update schList;
        System.debug('schList===='+schList);
        
        List<Events__c> eve = [SELECT Id FROM Events__c LIMIT 1];
        eve[0].Schedule__c = schList[0].Id;
        eve[0].SequenceNo__c = 1;
        eve[0].Instructor__c = conList[0].Id;
        eve[0].Date__c = currStart;
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
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(-6)};
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
        
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = currStart, Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = currStart.addDays(1), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = currStart.addDays(2), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = currStart.addDays(3), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = currStart.addDays(4), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = currStart.addDays(5), Status__c = 'Submitted'), 
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = currStart.addDays(6), Status__c = 'Submitted')
        };
        insert days;
                
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Project_Task__r.Name,
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Name, AcctSeed__Billable__c, AcctSeed__Project_Task__r.Project_Task_Type__c, Payroll_Item__c, 
            Location__c, Location__r.Name, Display_in_Future_Weeks__c, AcctSeed__Time_Card__c,AcctSeed__Time_Card__r.Intructor__c, AcctSeed__Time_Card__r.Intructor__r.Name,
            AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName, AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordTypeId, 
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c, Labor_Cost_Rate__c, Contact_Assignment__c, Labor_Cost_Rate__r.Rate_Type__c, 
            Sequence_Number__c, 
                (SELECT Id, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, Status__c, Total_Hours_Before_Approved__c, Late_Cancellation__c,
                    Cancellation_Reason__c
                FROM AcctSeed__Time_Card_Days__r)
        FROM AcctSeed__Time_Card_Line__c
        WHERE (Id = :timeCardLine.Id)];
        
        System.debug('::::::lines:::::'+lines[0].AcctSeed__Time_Card_Days__r);
        Map<Id,String> maptest = new Map<Id,String>();
        maptest.put(timeCardLine.Id, 'Instructor');
        
        System.runAs(user){
            TimeCardDayTranslator.approvalSummarytableFormationmethod(lines, maptest, currStart, currEnd);
        }
        
        Test.stopTest();
    }
    
    // Method to cover userSummaryformation() in TimeCardDayTranslator
    public static testMethod void testMethod23() {
    
        List<Contact> conList = [SELECT Id, Name, Total_Bonus_Leave_Balance_Hours__c, Bonus_Leave_Earned_Hours__c, 
            Bonus_Leave_Taken_Hours__c, Total_Vocation_Leave_Balance_Hours__c, Vocation_Leave_Earned__c, 
            Vocation_Leave_Taken__c, Total_Sick_Leave_Balance_Hours__c, Sick_Leave_Earned__c, Sick_Leave_Taken__c
        FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        System.runAs(user){
            TimeCardDayTranslator.userSummaryformation(conList, new List<AcctSeed__Time_Card_Line__c>(), new List<Date>(), Date.today());
        }
    }
    
    // Method to cover daily_SummaryDetailsFormation() in TimeCardDayTranslator
    public static testMethod void testMethod24() {
    
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek().addDays(1);
        Date WeekEnd1 = weekStart1.addDays(6);
        
        List<Contact> conList = [SELECT Id, Home_Department_Project__c, Home_Department_Project__r.RecordType.DeveloperName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        Test.startTest();
        
        insert user;
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
        System.debug('conAss========##'+conAss.size());
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
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
        
        List<AcctSeed__Cost_Rates__c> costRate = [SELECT Id, Contact__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'DLI-21 SCA LT' LIMIT 1];
        System.debug('costRate========'+costRate);
        costRate[0].Contact__c = conList[0].Id;
        update costRate[0];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        timeCardLine.Display_in_Future_Weeks__c = TRUE;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(-6)};
        
        List<AcctSeed__Time_Card_Day__c> days = new List<AcctSeed__Time_Card_Day__c>{
        
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(1), Status__c = 'Submitted'),
            new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today().addDays(2), Status__c = 'Submitted')
        };
        insert days;
                
        List<AcctSeed__Time_Card_Line__c> lines = [SELECT Id, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Project_Task__r.Name,
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Name, AcctSeed__Billable__c, AcctSeed__Project_Task__r.Project_Task_Type__c, Payroll_Item__c, 
            Location__c, Location__r.Name, Display_in_Future_Weeks__c, 
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c, Labor_Cost_Rate__c, Contact_Assignment__c, Labor_Cost_Rate__r.Rate_Type__c, 
            Sequence_Number__c, AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,
                (SELECT Id, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, Status__c, Total_Hours_Before_Approved__c, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Days__r)
        FROM AcctSeed__Time_Card_Line__c
        WHERE (Id = :timeCardLine.Id)];
        
        System.debug('::::::lines:::::'+lines[0].AcctSeed__Time_Card_Days__r);
        List<AcctSeed__Time_Card_Line__c> lines1 = [SELECT Id, Display_in_Future_Weeks__c FROM AcctSeed__Time_Card_Line__c WHERE Id != :timeCardLine.Id];
        lines1[0].Display_in_Future_Weeks__c = TRUE;
        update lines1[0];
        
        List<AcctSeed__Time_Card_Line__c> lines2 = [SELECT Id, AcctSeed__Project_Task__c, AcctSeed__Project_Task__r.AcctSeed__Project__c, AcctSeed__Project_Task__r.Name,
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Name, AcctSeed__Billable__c, AcctSeed__Project_Task__r.Project_Task_Type__c, Payroll_Item__c, 
            Location__c, Location__r.Name, Display_in_Future_Weeks__c, 
            AcctSeed__Project_Task__r.AcctSeed__Project__r.Training_Location__c, Labor_Cost_Rate__c, Contact_Assignment__c, Labor_Cost_Rate__r.Rate_Type__c, 
            Sequence_Number__c, AcctSeed__Project_Task__r.AcctSeed__Project__r.RecordType.DeveloperName,
                (SELECT Id, AcctSeed__Date__c, AcctSeed__Internal_Comment__c, Status__c, Total_Hours_Before_Approved__c, AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Days__r)
        FROM AcctSeed__Time_Card_Line__c
        WHERE (Id = :lines1[0].Id)];
        
        System.runAs(user){
            try{
                TimeCardDayTranslator.daily_SummaryDetailsFormation(lines, System.Today(), System.Today().addDays(2), conList, lines2, projects, task, conAss, new List<Project_Task_Master__c>(), new Set<Date>());
            }catch(Exception e){
                System.debug(':::::::'+e.getMessage());
            }
        }
        
        Test.stopTest();
    }
    
    // Method to cover employeeDetailsMethod() in TimeCardDayTranslator
    public static testMethod void testMethod25() {
    
        List<Contact> conList = [SELECT Id, Name, Home_Department_Project__c, Home_Department_Project__r.Name, 
            Supervisor_Name__c, Supervisor_Name_Formula__c, EE_Pay_Status__c, RecordType.DeveloperName, 
            PC_EE_ID__c
        FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        System.runAs(user){
            try{
                TimeCardDayTranslator.employeeDetailsMethod(new List<AcctSeed__Project_Task__c>(), new List<AcctSeed__Project__c>(), conList, new List<AcctSeed__Time_Card_Line__c>(),'',System.Today(),new List<Accounting_Seed_Time_Snapshot__c>(), new List<Date>(), new Set<Date>(), new List<AcctSeed__Time_Card_Line__c>(), new List<Document>(), new List<Contact_Assignments__c>(), new List<Contact_Assignments__c>(), new List<Project_Task_Master__c>());
            }catch(Exception e){
                System.debug(':::::::'+e.getMessage());
            }
        }
    }
    
    
    // Method to cover payrollItemFormation() in TimeCardDayTranslator
    public static testMethod void testMethod26() {
    
        List<Contact> conList = [SELECT Id
        FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<Project_Task_Master__c> projmaster = new List<Project_Task_Master__c>{
            
            new Project_Task_Master__c(Name = 'Test 1',Project_Type__c = 'Internal Cost Jobs',Unit__c = 'Hrs',Project_Task_Type__c = 'FMLA',Payroll_Item__c = 'R;RNB;BLE', Project_Task_Record_Type__c = 'Cost',Project_Record_Type__c = 'Admin_Projects'),
            new Project_Task_Master__c(Name = 'Test 2',Project_Type__c = 'Internal Cost Jobs',Unit__c = 'Hrs',Project_Task_Type__c = 'Fringe',Payroll_Item__c = 'R;RNB;BLE', Project_Task_Record_Type__c = 'Cost', Project_Record_Type__c = 'Admin_Projects'),
            new Project_Task_Master__c(Name = 'Test 3',Project_Type__c = 'DLS-Site Language Training; Client Site Language Training; FBI WO',Unit__c = 'Hrs',Project_Task_Type__c = 'Fringe',Payroll_Item__c = 'JUR', Project_Task_Record_Type__c = 'Cost', Project_Record_Type__c = 'Language_Training_Projects')
        };
        
        System.runAs(user){
            try{
                TimeCardDayTranslator.payrollItemFormation(projmaster);
            }catch(Exception e){
                System.debug(':::::::'+e.getMessage());
            }
        }
    }
    
    // Method to cover fringeRowsFormation() in TimeCardDayTranslator
    public static testMethod void testMethod27() {
        
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek().addDays(1);
        Date WeekEnd1 = weekStart1.addDays(6);
        
        List<Contact> conList = [SELECT Id
        FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        Test.startTest();
       
        insert user;
        
        List<Project_Task_Master__c> projmaster = new List<Project_Task_Master__c>{
            
            new Project_Task_Master__c(Name = 'Test 1',Project_Type__c = 'Internal Cost Jobs',Unit__c = 'Hrs',Project_Task_Type__c = 'FMLA',Payroll_Item__c = 'R;RNB;BLE', Project_Task_Record_Type__c = 'Cost',Project_Record_Type__c = 'Admin_Projects'),
            new Project_Task_Master__c(Name = 'Test 2',Project_Type__c = 'Internal Cost Jobs',Unit__c = 'Hrs',Project_Task_Type__c = 'Fringe',Payroll_Item__c = 'R;RNB;BLE', Project_Task_Record_Type__c = 'Cost', Project_Record_Type__c = 'Admin_Projects'),
            new Project_Task_Master__c(Name = 'Test 3',Project_Type__c = 'DLS-Site Language Training; Client Site Language Training; FBI WO',Unit__c = 'Hrs',Project_Task_Type__c = 'Fringe',Payroll_Item__c = 'JUR', Project_Task_Record_Type__c = 'Cost', Project_Record_Type__c = 'Language_Training_Projects')
        };
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
                         
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Project_Task_Type__c, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, Payroll_Item__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        task[0].Project_Task_Type__c = 'Fringe';
        task[0].Name = 'Holiday - PT';
        task[0].Payroll_Item__c = 'RNB';
        update task[0];
        
        List<AcctSeed__Project_Task__c> task1 = [SELECT Id, Project_Task_Type__c, AcctSeed__Project__c, Name,Payroll_Item__c FROM AcctSeed__Project_Task__c WHERE Id = :task[0].Id];
        
        conList[0].Home_Department_Project__c = projects[0].Id;
        update conList[0];
        
        List<Contact> conList1 = [SELECT Id, Home_Department_Project__c, Home_Department_Project__r.RecordType.DeveloperName, EE_Pay_Status__c FROM Contact WHERE Id = :conList[0].Id];
        
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
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        timeCardLine.Display_in_Future_Weeks__c = TRUE;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(-6)};
        
        TimeCardDayDomain.DayEntries adminRow = new TimeCardDayDomain.DayEntries();
        
        System.runAs(user){
            try{
                TimeCardDayTranslator.fringeRowsFormation(System.Today(), adminRow, new Set<String>(), conList1, projects, task1, conAss,projmaster, new Set<Date>(),8,8);
            }catch(Exception e){
                System.debug(':::::::'+e.getMessage());
            }
        }
    }
    
    // Method to cover fringeRowsFormation() in TimeCardDayTranslator
    public static testMethod void testMethod28() {
        
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek().addDays(1);
        Date WeekEnd1 = weekStart1.addDays(6);
        
        List<Contact> conList = [SELECT Id
        FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        Test.startTest();
        
        insert user;
        
        List<Project_Task_Master__c> projmaster = new List<Project_Task_Master__c>{
            
            new Project_Task_Master__c(Name = 'Test 1',Project_Type__c = 'Internal Cost Jobs',Unit__c = 'Hrs',Project_Task_Type__c = 'FMLA',Payroll_Item__c = 'R;RNB;BLE', Project_Task_Record_Type__c = 'Cost',Project_Record_Type__c = 'Admin_Projects'),
            new Project_Task_Master__c(Name = 'Test 2',Project_Type__c = 'Internal Cost Jobs',Unit__c = 'Hrs',Project_Task_Type__c = 'Fringe',Payroll_Item__c = 'R;RNB;BLE', Project_Task_Record_Type__c = 'Cost', Project_Record_Type__c = 'Admin_Projects'),
            new Project_Task_Master__c(Name = 'Test 3',Project_Type__c = 'DLS-Site Language Training; Client Site Language Training; FBI WO',Unit__c = 'Hrs',Project_Task_Type__c = 'Fringe',Payroll_Item__c = 'JUR', Project_Task_Record_Type__c = 'Cost', Project_Record_Type__c = 'Language_Training_Projects')
        };
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
                         
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Project_Task_Type__c, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, Payroll_Item__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        task[0].Project_Task_Type__c = 'Fringe';
        task[0].Name = 'Sick - PT';
        task[0].Payroll_Item__c = 'RNB';
        update task[0];
        
        List<AcctSeed__Project_Task__c> task1 = [SELECT Id, Project_Task_Type__c, AcctSeed__Project__c, Name,Payroll_Item__c FROM AcctSeed__Project_Task__c WHERE Id = :task[0].Id];
        
        conList[0].Home_Department_Project__c = projects[0].Id;
        update conList[0];
        
        List<Contact> conList1 = [SELECT Id, Home_Department_Project__c, Home_Department_Project__r.RecordType.DeveloperName, EE_Pay_Status__c FROM Contact WHERE Id = :conList[0].Id];
        
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
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        timeCardLine.Display_in_Future_Weeks__c = TRUE;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(-6)};
        
        TimeCardDayDomain.DayEntries adminRow = new TimeCardDayDomain.DayEntries();
        
        System.runAs(user){
            try{
                TimeCardDayTranslator.fringeRowsFormation(System.Today(), adminRow, new Set<String>(), conList1, projects, task1, conAss,projmaster, new Set<Date>(),8,8);
            }catch(Exception e){
                System.debug(':::::::'+e.getMessage());
            }
        }
    }
    
    // Method to cover fringeRowsFormation() in TimeCardDayTranslator
    public static testMethod void testMethod29() {
        
        Date myDate1 = System.today();
        Date weekStart1 = myDate1.toStartofWeek().addDays(1);
        Date WeekEnd1 = weekStart1.addDays(6);
        
        List<Contact> conList = [SELECT Id
        FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
         
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        Test.startTest();
        
        insert user;
        
        List<Project_Task_Master__c> projmaster = new List<Project_Task_Master__c>{
            
            new Project_Task_Master__c(Name = 'Test 1',Project_Type__c = 'Internal Cost Jobs',Unit__c = 'Hrs',Project_Task_Type__c = 'FMLA',Payroll_Item__c = 'R;RNB;BLE', Project_Task_Record_Type__c = 'Cost',Project_Record_Type__c = 'Admin_Projects'),
            new Project_Task_Master__c(Name = 'Test 2',Project_Type__c = 'Internal Cost Jobs',Unit__c = 'Hrs',Project_Task_Type__c = 'Fringe',Payroll_Item__c = 'R;RNB;BLE', Project_Task_Record_Type__c = 'Cost', Project_Record_Type__c = 'Admin_Projects'),
            new Project_Task_Master__c(Name = 'Test 3',Project_Type__c = 'DLS-Site Language Training; Client Site Language Training; FBI WO',Unit__c = 'Hrs',Project_Task_Type__c = 'Fringe',Payroll_Item__c = 'JUR', Project_Task_Record_Type__c = 'Cost', Project_Record_Type__c = 'Language_Training_Projects')
        };
        
        List<AcctSeed__Time_Card_Period__c> tcp = [SELECT Id FROM AcctSeed__Time_Card_Period__c LIMIT 1];
                
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        timeCard[0].Intructor__c = conList[0].Id;
        timeCard[0].AcctSeed__Time_Card_Period__c = tcp[0].Id;
        update timeCard;
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = conList[0].Id;
        conAss[0].Start_Date__c = weekStart1;
        conAss[0].End_Date__c = Date.Today();
        update conAss[0]; 
                
        MTT_Location__c loc = [SELECT Id, Name FROM MTT_Location__c LIMIT 1];
                
        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        System.debug('projects========'+projects);
                         
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Project_Task_Type__c, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName, Payroll_Item__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
        task[0].Project_Task_Type__c = 'Fringe';
        task[0].Name = 'Vacation - PT';
        task[0].Payroll_Item__c = 'RNB';
        update task[0];
        
        List<AcctSeed__Project_Task__c> task1 = [SELECT Id, Project_Task_Type__c, AcctSeed__Project__c, Name,Payroll_Item__c FROM AcctSeed__Project_Task__c WHERE Id = :task[0].Id];
        
        conList[0].Home_Department_Project__c = projects[0].Id;
        update conList[0];
        
        List<Contact> conList1 = [SELECT Id, Home_Department_Project__c, Home_Department_Project__r.RecordType.DeveloperName, EE_Pay_Status__c FROM Contact WHERE Id = :conList[0].Id];
        
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
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        timeCardLine.Completed__c = true;
        timeCardLine.Location__c = loc.Id;
        timeCardLine.Display_in_Future_Weeks__c = TRUE;
        insert timeCardLine;
        
        List<Date> dateList = new List<Date>{System.Today(), System.Today().addDays(1), System.Today().addDays(2), System.Today().addDays(3), System.Today().addDays(4), System.Today().addDays(5), System.Today().addDays(-6)};
        
        TimeCardDayDomain.DayEntries adminRow = new TimeCardDayDomain.DayEntries();
        
        System.runAs(user){
            try{
                TimeCardDayTranslator.fringeRowsFormation(System.Today(), adminRow, new Set<String>(), conList1, projects, task1, conAss,projmaster, new Set<Date>(),8,8);
            }catch(Exception e){
                System.debug(':::::::'+e.getMessage());
            }
        }
    }
    
    // Method to cover search() in Staff_Daily_Timesheet_Ctrl
    public static testMethod void testMethod30() {
    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
        List <SObject> lookuprecords1 = Staff_Daily_Timesheet_Ctrl.search('Test Contact1', 'Contact', 'Name', null, null); 
        
        List<Contact> conList1 = [SELECT Id FROM Contact WHERE Id NOT IN :conList];
        
        List <SObject> lookuprecords = Staff_Daily_Timesheet_Ctrl.search('Test Contact1', 'Contact', 'Name', 'Email != NULL', new List<String>{conList1[0].Id}); 
    }
}