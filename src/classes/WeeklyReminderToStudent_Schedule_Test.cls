@isTest
private class WeeklyReminderToStudent_Schedule_Test{

    @testSetup static void setupMethod(){
    
        
        List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
        
        Test.startTest();
            List<AcctSeed__Time_Card_Day__c> timeCardDayList = TestClassUtil.createTestTimeCardDay();
            List<Events__c> events = TestClassUtil.createTestEvent();
        Test.stopTest();
    }

    @isTest
    private static void myTest1(){
    
        Date currentWeekStart = System.today().toStartofWeek().addDays(1);
        Date currentWeekEnd = currentWeekStart.addDays(6);
        
        Date previouswkStart = currentWeekStart.addDays(-7);
        Date previouswkEnd = previouswkStart.addDays(6);
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
                    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        Test.startTest();
               
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Time_Approval_Preference__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            conAss[0].Time_Approval_Preference__c = 'Weekly';
            conAss[0].Paper_Timesheet__c = FALSE;
            update conAss[0]; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            System.debug('projects========'+projects);
                    
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
                
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = previouswkStart,Status__c = 'Draft');
            insert day;
            
            List<Schedule__c> schedule = [SELECT Id FROM Schedule__c WHERE Project_Task__c = :task[0].Id];
            
            List<Events__c> eve = [SELECT Id, No_Student_Approval__c FROM Events__c WHERE Schedule__c = :schedule[0].Id];
            eve[0].No_Student_Approval__c = FALSE;
            eve[0].Time_Card_Day__c = day.Id;
            update eve[0];
            
        Test.stopTest();
        
        try{
        
            // Schedule coverage
            String CRON_EXP = '0 0 09 * * ?';
            WeeklyApprovalReminderToStd_Schedule sch = new WeeklyApprovalReminderToStd_Schedule();
            system.schedule('Weekly Approval Reminder To Student Schedule', CRON_EXP, sch);
        
        }Catch(Exception e){
            system.debug('Exception:'+e+e.getLineNumber());
        }
    }
    
    @isTest
    private static void myTest2(){
    
        Date currentWeekStart = System.today().toStartofWeek().addDays(1);
        Date currentWeekEnd = currentWeekStart.addDays(6);
        
        Date previouswkStart = currentWeekStart.addDays(-7);
        Date previouswkEnd = previouswkStart.addDays(6);
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
                    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        Test.startTest();
            
            Id pdoRTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Student_Planned_Days_Off').getRecordTypeId();
                
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Time_Approval_Preference__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            conAss[0].Time_Approval_Preference__c = 'Weekly';
            conAss[0].Paper_Timesheet__c = FALSE;
            conAss[1].Candidate_Name__c = conList[0].Id;
            conAss[1].Assignment_Position__c = 'Student';
            conAss[1].Time_Approval_Preference__c = 'Weekly';
            conAss[1].Paper_Timesheet__c = FALSE;
            update conAss; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            System.debug('projects========'+projects);
            
            List<AcctSeed__Project__c> projects1 = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id != :conAss[0].Project__c];
            
            Planned_Days_Off__c pdo = new Planned_Days_Off__c(Project__c = projects1[0].Id, RecordTypeId = pdoRTId, Contact__c = conList[0].Id, Date__c = currentWeekStart,Description__c = 'Test', Status__c = 'Approved');
            insert pdo;
            
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
                
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = previouswkStart,Status__c = 'Draft');
            insert day;
            
            List<Schedule__c> schedule = [SELECT Id FROM Schedule__c WHERE Project_Task__c = :task[0].Id];
            
            List<Events__c> eve = [SELECT Id, No_Student_Approval__c FROM Events__c WHERE Schedule__c = :schedule[0].Id];
            eve[0].No_Student_Approval__c = FALSE;
            eve[0].Time_Card_Day__c = day.Id;
            update eve[0];
            
        Test.stopTest();
        
        try{
        
            // Schedule coverage
            String CRON_EXP = '0 0 17 * * ?';
            WeeklyApprovalReminderToStd_Schedule sch = new WeeklyApprovalReminderToStd_Schedule();
            system.schedule('Weekly Approval Reminder To Student Schedule', CRON_EXP, sch);
        
        }Catch(Exception e){
            system.debug('Exception:'+e+e.getLineNumber());
        }
    }
    
    @isTest
    private static void myTest3(){
    
        Date currentWeekStart = System.today().toStartofWeek().addDays(1);
        Date currentWeekEnd = currentWeekStart.addDays(6);
        
        Date previouswkStart = currentWeekStart.addDays(-7);
        Date previouswkEnd = previouswkStart.addDays(6);
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        
        List<Contact> conToupdate = new List<Contact>();
        
        Id canRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        List<Contact> conList = [SELECT Id, RecordType.DeveloperName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName IN ('Candidate', 'Student')];
        
        for(Contact c : conList){
        
            if(c.RecordType.DeveloperName == 'Student'){
                c.RecordTypeId = canRTId;
                conToupdate.add(c);
            }
        }
        System.debug('conList==='+conList);
        
        Test.startTest();
        
            if(conToupdate.size () > 0){
                update conToupdate;
            }
                        
        //Test.startTest();
                            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Time_Approval_Preference__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            conAss[0].Time_Approval_Preference__c = 'Weekly';
            conAss[0].Paper_Timesheet__c = FALSE;
            conAss[1].Candidate_Name__c = conList[1].Id;
            conAss[1].Assignment_Position__c = 'Student';
            conAss[1].Time_Approval_Preference__c = 'Weekly';
            conAss[1].Paper_Timesheet__c = FALSE;
            update conAss; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            System.debug('projects========'+projects);
            
            Id pdoRTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Student_Planned_Days_Off').getRecordTypeId();
            
            Planned_Days_Off__c pdo = new Planned_Days_Off__c(Project__c = projects[0].Id, RecordTypeId = pdoRTId, Contact__c = conList[0].Id, Date__c = currentWeekStart,Description__c = 'Test', Status__c = 'Approved');
            insert pdo;
            
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
                
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = previouswkStart,Status__c = 'Draft');
            insert day;
            
            List<Schedule__c> schedule = [SELECT Id FROM Schedule__c WHERE Project_Task__c = :task[0].Id];
            
            List<Events__c> eve = [SELECT Id, No_Student_Approval__c FROM Events__c WHERE Schedule__c = :schedule[0].Id];
            eve[0].No_Student_Approval__c = FALSE;
            eve[0].Time_Card_Day__c = day.Id;
            update eve[0];
            
        Test.stopTest();
        
        try{
        
            // Schedule coverage
            String CRON_EXP = '0 0 17 * * ?';
            WeeklyApprovalReminderToStd_Schedule sch = new WeeklyApprovalReminderToStd_Schedule();
            system.schedule('Weekly Approval Reminder To Student Schedule', CRON_EXP, sch);
        
        }Catch(Exception e){
            system.debug('Exception:'+e+e.getLineNumber());
        }
    }
    
    @isTest
    private static void myTest4(){
    
        Date currentWeekStart = System.today().toStartofWeek().addDays(1);
        Date currentWeekEnd = currentWeekStart.addDays(6);
        
        Date previouswkStart = currentWeekStart.addDays(-7);
        Date previouswkEnd = previouswkStart.addDays(6);
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
                    
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        Test.startTest();
               
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Time_Approval_Preference__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN :projRTDevNames LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            conAss[0].Assignment_Position__c = 'Class Leader';
            conAss[0].Time_Approval_Preference__c = 'Weekly';
            conAss[0].Paper_Timesheet__c = FALSE;
            update conAss[0]; 
            System.debug('conAss========##'+conAss.size());
            
            List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            System.debug('projects========'+projects);
            
            Id pdoRTId = Schema.SObjectType.Planned_Days_Off__c.getRecordTypeInfosByDeveloperName().get('Student_Planned_Days_Off').getRecordTypeId();
            
            Planned_Days_Off__c pdo = new Planned_Days_Off__c(Project__c = NULL, All_Projects__c = TRUE, RecordTypeId = pdoRTId, Contact__c = conList[0].Id, Date__c = currentWeekStart,Description__c = 'Test', Status__c = 'Approved');
            insert pdo;
            
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            System.debug('timeCard========='+timeCard[0].Intructor__r.RecordType.DeveloperName);
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :projects[0].Id LIMIT 1];
            System.debug('task ====='+task);
                
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = projects[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = previouswkStart,Status__c = 'Draft');
            insert day;
            
            List<Schedule__c> schedule = [SELECT Id FROM Schedule__c WHERE Project_Task__c = :task[0].Id];
            
            List<Events__c> eve = [SELECT Id, No_Student_Approval__c FROM Events__c WHERE Schedule__c = :schedule[0].Id];
            eve[0].No_Student_Approval__c = FALSE;
            eve[0].Time_Card_Day__c = day.Id;
            update eve[0];
            
        Test.stopTest();
        
        try{
        
            // Schedule coverage
            String CRON_EXP = '0 0 17 * * ?';
            WeeklyApprovalReminderToStd_Schedule sch = new WeeklyApprovalReminderToStd_Schedule();
            system.schedule('Weekly Approval Reminder To Student Schedule', CRON_EXP, sch);
        
        }Catch(Exception e){
            system.debug('Exception:'+e+e.getLineNumber());
        }
    }
}