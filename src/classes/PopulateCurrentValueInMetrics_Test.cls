@isTest
private class PopulateCurrentValueInMetrics_Test{

    @testSetup static void setupMethod(){  
         
        List<Metric__c> metrics = TestClassUtil.createMetrics();
        List<Goals_Metrics_Mapping__c> goalAndMetricMapping = TestClassUtil.createGoalAndMetricMapping();
        List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
        Test.startTest();
            List<AcctSeed__Time_Card__c> timeCard = TestClassUtil.createTestTimeCard();
            List<Events__c> events = TestClassUtil.createTestEvent();
        Test.stopTest();
        List<AcctSeed__Accounting_Variable__c> glAccVar = TestClassUtil.createAccountingVariable();
    }
    
    private static testMethod void myTest_1(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c ORDER BY CreatedDate ASC];
        List<Metric__c> metrics = [SELECT Id, Name FROM Metric__c ORDER BY CreatedDate ASC];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN: projRTDevNames AND Assignment_Position__c = 'Instructor' LIMIT 1];
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Name, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c();
        proj.Id = task[0].AcctSeed__Project__c;
        proj.QB_Classification__c = 'OF0MTT0PS';
        proj.AcctSeed__Account__c = a.Id;
        update proj;
        
        Test.startTest();
                        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = proj.Id;
            timeCardLine.AcctSeed__Billable__c = True;
            timeCardLine.Payroll_Item__c = 'BLE';
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            insert timeCardLine;
                
            Date endDate_LastMonth = Date.today().toStartOfMonth()-1;
            Date startDate_LastMonth = endDate_LastMonth.toStartOfMonth();
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = startDate_LastMonth,Status__c = 'Submitted');
            insert day;
            
            String CRON_EXP = '0 0 0 * * ?';
            PopulateCurrentValueInMetrics_Scheduler sch = new PopulateCurrentValueInMetrics_Scheduler();
            System.schedule('Populate Current Value In Metrics Scheduler', CRON_EXP, sch);
        
        Test.stopTest();        
    }
    
    private static testMethod void myTest_1a(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c ORDER BY CreatedDate ASC];
        List<Metric__c> metrics = [SELECT Id, Name FROM Metric__c ORDER BY CreatedDate ASC];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN: projRTDevNames AND Assignment_Position__c = 'Instructor' LIMIT 1];
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Name, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c();
        proj.Id = task[0].AcctSeed__Project__c;
        proj.QB_Classification__c = 'OF0MTT0PS';
        proj.AcctSeed__Account__c = a.Id;
        update proj;
        
        Test.startTest();
                        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = proj.Id;
            timeCardLine.AcctSeed__Billable__c = True;
            timeCardLine.Payroll_Item__c = 'BLE';
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            insert timeCardLine;
                
            Integer lastYear = Date.today().year()-1;
            Date sd_LY = Date.newinstance(lastYear, 12, 01);
            Date ed_LY = Date.newinstance(lastYear, 12, 31);
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = sd_LY,Status__c = 'Submitted');
            insert day;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMetrics_Batch(null, null, sd_LY, ed_LY.addMonths(1)));
        
        Test.stopTest();        
    }
    
    private static testMethod void myTest_2(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c];
        List<Metric__c> metrics = [SELECT Id, Name FROM Metric__c];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Name, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c();
        proj.Id = task[0].AcctSeed__Project__c;
        proj.QB_Classification__c = 'OF0MTT0PS';
        proj.AcctSeed__Account__c = a.Id;
        update proj;
        
        Test.startTest();
        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'BLE';
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            insert timeCardLine;
                
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = Date.Today(),Status__c = 'Submitted');
            insert day;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMetrics_Batch(goals[0].Id, metrics[0].Id, null, null));
            
        Test.stopTest();
    }
    
    private static testMethod void myTest_3(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c ORDER BY CreatedDate ASC];
        List<Metric__c> metrics = [SELECT Id, Name FROM Metric__c ORDER BY CreatedDate ASC];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN: projRTDevNames AND Assignment_Position__c = 'Instructor' LIMIT 1];
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Name, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c();
        proj.Id = task[0].AcctSeed__Project__c;
        proj.QB_Classification__c = 'OF0MTT0PS';
        proj.AcctSeed__Account__c = a.Id;
        update proj;
        
        
        Test.startTest();
        
            AcctSeed__Accounting_Variable__c glav2 = new AcctSeed__Accounting_Variable__c(Name = 'LNG', AcctSeed__Type__c = 'GL Account Variable 2', AcctSeed__Active__c = true);
            insert glav2;
            
            AcctSeed__Project_Task__c taskRec = new AcctSeed__Project_Task__c();
            taskRec.Id = task[0].Id;
            taskRec.AcctSeed__GL_Account_Variable_2__c = glav2.Id;
            update taskRec;
            
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = proj.Id;
            timeCardLine.AcctSeed__Billable__c = True;
            timeCardLine.Payroll_Item__c = 'BLE';
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            insert timeCardLine;
            
            Date endDate_LastMonth = Date.today().toStartOfMonth()-1;
            Date startDate_LastMonth = endDate_LastMonth.toStartOfMonth();
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = startDate_LastMonth,Status__c = 'Submitted');
            insert day;
                        
            String CRON_EXP = '0 0 0 * * ?';
            PopulateCurrentValueInMetrics_Scheduler sch = new PopulateCurrentValueInMetrics_Scheduler();
            System.schedule('Populate Current Value In Metrics Scheduler', CRON_EXP, sch);
            
        Test.stopTest();        
    }
    
    private static testMethod void myTest_4(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c ORDER BY CreatedDate ASC LIMIT 1];
        List<Metric__c> metrics = [SELECT Id, Name FROM Metric__c WHERE Goal__c IN :goals LIMIT 1];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN: projRTDevNames AND Assignment_Position__c = 'Instructor' LIMIT 1];
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Name, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
        List<Account> acc = [SELECT Id FROM Account LIMIT 1];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c();
        proj.Id = task[0].AcctSeed__Project__c;
        proj.QB_Classification__c = 'ON0LT0ARL';
        proj.AcctSeed__Account__c = acc[0].Id;
        update proj;
        
        Test.startTest();
                        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = proj.Id;
            timeCardLine.AcctSeed__Billable__c = True;
            timeCardLine.Payroll_Item__c = 'BLE';
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            Date endDate_LastMonth = Date.today().toStartOfMonth()-1;
            Date startDate_LastMonth = endDate_LastMonth.toStartOfMonth();
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = startDate_LastMonth,Status__c = 'Submitted');
            insert day;
            
            String CRON_EXP = '0 0 0 * * ?';
            PopulateCurrentValueInMetrics_Scheduler sch = new PopulateCurrentValueInMetrics_Scheduler();
            System.schedule('Populate Current Value In Metrics Scheduler', CRON_EXP, sch);
        
        Test.stopTest();        
    }
    
    private static testMethod void myTest_5(){
    
        Integer cy = Date.today().year();
        String currentYear = String.valueOf(cy);
        String name = currentYear+' Proforma Actual - LT - ARL/(DC)';
        
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name = :name ORDER BY CreatedDate ASC LIMIT 1];
        List<Metric__c> metrics = [SELECT Id, Name FROM Metric__c WHERE Goal__c IN :goals LIMIT 1];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c WHERE Account_Condition__c = 'NOT CONTAINS' AND Name = 'Proforma Actual - LT - ARL/(DC)' ORDER BY CreatedDate ASC];
        
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN: projRTDevNames AND Assignment_Position__c = 'Instructor' LIMIT 1];
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Name, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
        List<Account> acc = [SELECT Id FROM Account LIMIT 1];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c();
        proj.Id = task[0].AcctSeed__Project__c;
        proj.QB_Classification__c = 'ON0LT0ARL';
        proj.AcctSeed__Account__c = acc[0].Id;
        update proj;
        
        Test.startTest();
                        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = proj.Id;
            timeCardLine.AcctSeed__Billable__c = True;
            timeCardLine.Payroll_Item__c = 'BLE';
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            Date endDate_LastMonth = Date.today().toStartOfMonth()-1;
            Date startDate_LastMonth = endDate_LastMonth.toStartOfMonth();
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = startDate_LastMonth,Status__c = 'Submitted');
            insert day;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMetrics_Batch(goals[0].Id, metrics[0].Id, null, null));
            
        Test.stopTest();        
    }
    
    private static testMethod void myTest_3a(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c ORDER BY CreatedDate ASC];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c, Due_Date__c FROM Metric__c ORDER BY CreatedDate ASC];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN: projRTDevNames AND Assignment_Position__c = 'Instructor' LIMIT 1];
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Name, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
        
        Account a = new Account(Name = 'DLS');
        insert a;
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c();
        proj.Id = task[0].AcctSeed__Project__c;
        proj.QB_Classification__c = 'OF0MTT0PS';
        proj.AcctSeed__Account__c = a.Id;
        update proj;
        
        
        Test.startTest();
        
            AcctSeed__Accounting_Variable__c glav2 = new AcctSeed__Accounting_Variable__c(Name = 'LNG', AcctSeed__Type__c = 'GL Account Variable 2', AcctSeed__Active__c = true);
            insert glav2;
            
            AcctSeed__Project_Task__c taskRec = new AcctSeed__Project_Task__c();
            taskRec.Id = task[0].Id;
            taskRec.AcctSeed__GL_Account_Variable_2__c = glav2.Id;
            update taskRec;
            
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = proj.Id;
            timeCardLine.AcctSeed__Billable__c = True;
            timeCardLine.Payroll_Item__c = 'BLE';
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            insert timeCardLine;
            
            Date endDate_LastMonth = Date.today().toStartOfMonth()-1;
            Date startDate_LastMonth = endDate_LastMonth.toStartOfMonth();
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = metrics[0].Start_Date__c,Status__c = 'Submitted');
            insert day;
                        
            Database.ExecuteBatch(new PopulateCurrentValueInMetrics_Batch(null, null, metrics[0].Start_Date__c, metrics[0].Due_Date__c));
            
        Test.stopTest();        
    }
    
    private static testMethod void myTest_5a(){
    
        Integer cy = Date.today().year();
        String currentYear = String.valueOf(cy);
        String name = currentYear+' Proforma Actual - LT - ARL/(DC)';
        
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name = :name ORDER BY CreatedDate ASC LIMIT 1];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c, Due_Date__c FROM Metric__c WHERE Goal__c IN :goals LIMIT 1];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c WHERE Account_Condition__c = 'NOT CONTAINS' AND Name = 'Proforma Actual - LT - ARL/(DC)' ORDER BY CreatedDate ASC];
        
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN: projRTDevNames AND Assignment_Position__c = 'Instructor' LIMIT 1];
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Name, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
        List<Account> acc = [SELECT Id FROM Account LIMIT 1];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c();
        proj.Id = task[0].AcctSeed__Project__c;
        proj.QB_Classification__c = 'ON0LT0ARL';
        proj.AcctSeed__Account__c = acc[0].Id;
        update proj;
        
        Test.startTest();
                        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = proj.Id;
            timeCardLine.AcctSeed__Billable__c = True;
            timeCardLine.Payroll_Item__c = 'BLE';
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            Date endDate_LastMonth = Date.today().toStartOfMonth()-1;
            Date startDate_LastMonth = endDate_LastMonth.toStartOfMonth();
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = metrics[0].Start_Date__c,Status__c = 'Submitted');
            insert day;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMetrics_Batch(null, null, metrics[0].Start_Date__c, metrics[0].Due_Date__c));
            
        Test.stopTest();        
    }
    
    private static testMethod void myTest_6(){
    
        Integer cy = Date.today().year();
        String currentYear = String.valueOf(cy);
        String name = currentYear+' Proforma Actual - LT - ARL/(DC)';
        
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name = :name ORDER BY CreatedDate ASC LIMIT 1];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c, Due_Date__c FROM Metric__c WHERE Goal__c IN :goals LIMIT 1];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c WHERE Account_Condition__c = 'NOT CONTAINS' AND Name = 'Proforma Actual - LT - ARL/(DC)' ORDER BY CreatedDate ASC];
        
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN: projRTDevNames AND Assignment_Position__c = 'Instructor' LIMIT 1];
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Name, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
        List<Account> acc = [SELECT Id FROM Account LIMIT 1];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c();
        proj.Id = task[0].AcctSeed__Project__c;
        proj.QB_Classification__c = 'ON0LT0ARL';
        proj.AcctSeed__Account__c = acc[0].Id;
        update proj;
        
        Test.startTest();
                        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = proj.Id;
            timeCardLine.AcctSeed__Billable__c = True;
            timeCardLine.Payroll_Item__c = 'BLE';
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            Date endDate_LastMonth = Date.today().toStartOfMonth()-1;
            Date startDate_LastMonth = endDate_LastMonth.toStartOfMonth();
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = metrics[0].Start_Date__c,Status__c = 'Submitted');
            insert day;
            
            Goal_Metric_Util.refreshMetric(metrics[0].Id, null, null);    
        Test.stopTest();        
    }
    
    private static testMethod void myTest_6a(){
    
        Integer cy = Date.today().year();
        String currentYear = String.valueOf(cy);
        String name = currentYear+' Proforma Actual - LT - ARL/(DC)';
        
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name = :name ORDER BY CreatedDate ASC LIMIT 1];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c, Due_Date__c FROM Metric__c WHERE Goal__c IN :goals LIMIT 1];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c WHERE Account_Condition__c = 'NOT CONTAINS' AND Name = 'Proforma Actual - LT - ARL/(DC)' ORDER BY CreatedDate ASC];
        
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects'};
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__r.RecordType.DeveloperName IN: projRTDevNames AND Assignment_Position__c = 'Instructor' LIMIT 1];
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Name, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
        List<Account> acc = [SELECT Id FROM Account LIMIT 1];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c();
        proj.Id = task[0].AcctSeed__Project__c;
        proj.QB_Classification__c = 'ON0LT0ARL';
        proj.AcctSeed__Account__c = acc[0].Id;
        update proj;
        
        Test.startTest();
                        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = proj.Id;
            timeCardLine.AcctSeed__Billable__c = True;
            timeCardLine.Payroll_Item__c = 'BLE';
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            insert timeCardLine;
            
            Date endDate_LastMonth = Date.today().toStartOfMonth()-1;
            Date startDate_LastMonth = endDate_LastMonth.toStartOfMonth();
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = metrics[0].Start_Date__c,Status__c = 'Submitted');
            insert day;
            
            Goal_Metric_Util.refreshMetric(null, Date.Today().addDays(-15), Date.Today());    
        Test.stopTest();        
    }
    
    // CA Position / Project RecordType
    private static testMethod void myTest_7(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name lIKE '%Proforma Actual - Testing' ORDER BY CreatedDate ASC LIMIT 1];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c, Due_Date__c FROM Metric__c WHERE Goal__c IN :goals LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Name, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
        
        Id testRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c();
        proj.Id = task[0].AcctSeed__Project__c;
        proj.QB_Classification__c = 'OF0MTT0PS';
        proj.RecordTypeId = testRTId;
        update proj;
        
        Test.startTest();
        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'BLE';
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            insert timeCardLine;
                
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = metrics[0].Start_Date__c,Status__c = 'Submitted');
            insert day;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMetrics_Batch(goals[0].Id, metrics[0].Id, null, null));
            
        Test.stopTest();
    }
    
    private static testMethod void myTest_8(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name lIKE '%Proforma Actual GLAV - LT - DODA PS' ORDER BY CreatedDate ASC LIMIT 1];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c, Due_Date__c FROM Metric__c WHERE Goal__c IN :goals LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        List<AcctSeed__Project_Task__c> task = [SELECT Id, Name, AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Project_Task_Type__c != 'Preparation time' AND AcctSeed__Project__c = :conAss[0].Project__c LIMIT 1];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c WHERE Name = 'Proforma Actual GLAV - LT - DODA PS'];
        
        AcctSeed__Project__c proj = new AcctSeed__Project__c();
        proj.Id = task[0].AcctSeed__Project__c;
        proj.QB_Classification__c = 'OF0MTT0PS';
        update proj;
        
        Test.startTest();
            List<AcctSeed__Accounting_Variable__c> glVar = [SELECT Id, Name FROM AcctSeed__Accounting_Variable__c WHERE Name = 'LT - DODA' LIMIT 1];
            
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = task[0].AcctSeed__Project__c;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'BLE';
            timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            insert timeCardLine;
                
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(GL_Variable_2__c = glVar[0].Id, AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = metrics[0].Start_Date__c,Status__c = 'Submitted');
            insert day;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMetrics_Batch(goals[0].Id, metrics[0].Id, null, null));
            
        Test.stopTest();
    }
    
    private static testMethod void marketingMetrics_Test_1(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Registrar%'];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            String CRON_EXP = '0 0 0 * * ?';
            PopulateCurrentValueInMetrics_Scheduler sch = new PopulateCurrentValueInMetrics_Scheduler();
            System.schedule('Populate Current Value In Metrics Scheduler', CRON_EXP, sch);
        
        Test.stopTest();        
    }
    
    private static testMethod void marketingMetrics_Test_2(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Closure Rate per Year%'];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMarketingMetrics(goals[0].Id, metrics[0].Id, null, null));
        
        Test.stopTest();        
    }
    
    private static testMethod void marketingMetrics_Test_3(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Registrar # of Inquiries%'];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMarketingMetrics(goals[0].Id, metrics[0].Id, null, null));
        
        Test.stopTest();        
    }
    
    private static testMethod void marketingMetrics_Test_4(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Registrar # of Enrollments%'];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMarketingMetrics(goals[0].Id, metrics[0].Id, null, null));
        
        Test.stopTest();        
    }
    
    private static testMethod void marketingMetrics_Test_5(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Registrar Value of Inquiries%'];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMarketingMetrics(goals[0].Id, metrics[0].Id, null, null));
        Test.stopTest();        
    }
    
    
    private static testMethod void marketingMetrics_Test_6(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Registrar Value of Enrollments%'];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMarketingMetrics(goals[0].Id, metrics[0].Id, null, null));
        
        Test.stopTest();        
    }
    
    private static testMethod void marketingMetrics_Test_7(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Registrar Avg Hourly Rate of Enrollments%'];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMarketingMetrics(goals[0].Id, metrics[0].Id, null, null));
        
        Test.stopTest();        
    }
    
    private static testMethod void marketingMetrics_Test_8(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Registrar%'];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            Integer lastYear = Date.today().year()-1;
            Date sd_LY = Date.newinstance(lastYear, 12, 01);
            Date ed_LY = Date.newinstance(lastYear, 12, 31);
            
            Database.ExecuteBatch(new PopulateCurrentValueInMarketingMetrics(null, null, sd_LY, ed_LY.addMonths(1)));
        Test.stopTest();        
    }
    
    
    private static testMethod void marketingMetrics_Test_9(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Closure Rate per QTR%'];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            Goal_Metric_Util.refreshMetric(metrics[0].Id, null, null);
        Test.stopTest();        
    }
    
    private static testMethod void marketingMetrics_Test_9a(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c LIMIT 1];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();           
            Goal_Metric_Util.refreshMetric(metrics[0].Id, null, null);
        Test.stopTest();        
    }
    
    private static testMethod void marketingMetrics_Test_10(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Registrar # of Inquiries%'];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            Integer lastYear = Date.today().year()-1;
            Date sd_LY = Date.newinstance(lastYear, 12, 01);
            Date ed_LY = Date.newinstance(lastYear, 12, 31);
            Date ed_CY = Date.newinstance(lastYear+1, 12, 31);
            
            Goal_Metric_Util.refreshMetric(null, ed_LY, ed_CY);
        Test.stopTest();        
    }
    
    private static testMethod void marketingMetrics_Test_11(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Registrar # of Enrollments%'];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            Id goalId;
            Id metricId;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMarketingMetrics(goalId, metricId, null, null));
        Test.stopTest();        
    }
    
    private static testMethod void marketingMetrics_Test_12(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Registrar # of Enrollments%'];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            Integer lastYear = Date.today().year()-1;
            Date sd_LY = Date.newinstance(lastYear, 12, 01);
            Date ed_LY = Date.newinstance(lastYear, 12, 31);
            Date ed_CY = Date.newinstance(lastYear+1, 12, 31);
            
            Id goalId;
            Id metricId;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMarketingMetrics(goalId, metricId, ed_LY, ed_CY));
        Test.stopTest();        
    }
    
    private static testMethod void marketingMetrics_Test_13(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Registrar # of Enrollments%' LIMIT 1];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            Integer cy = Date.today().year();
            Date sd_cy = Date.newinstance(cy, 01, 01);
            Date ed_cy = Date.newinstance(cy, 12, 31);
            
            Id goalId;
            Id metricId;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMarketingMetrics(goalId, metricId, sd_cy, ed_cy));
        Test.stopTest();        
    }
    
    private static testMethod void marketingMetrics_Test_14(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Registrar # of Enrollments%' LIMIT 1];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            Integer cy = Date.today().year();
            Date sd_cy = Date.newinstance(cy, 01, 01);
            Date ed_cy = Date.newinstance(cy, 12, 31);
            
            Id goalId;
            Id metricId;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMarketingMetrics(goals[0].Id, metricId, null, null));
        Test.stopTest();        
    }
    
    private static testMethod void marketingMetrics_Test_14a(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Registrar # of Inquiries%' LIMIT 1];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            Integer cy = Date.today().year();
            Date sd_cy = Date.newinstance(cy, 01, 01);
            Date ed_cy = Date.newinstance(cy, 12, 31);
            
            Id goalId;
            Id metricId;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMarketingMetrics(goals[0].Id, metricId, null, null));
        Test.stopTest();        
    }
    
    private static testMethod void marketingMetrics_Test_15(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Registrar # of Enrollments%' LIMIT 1];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            Date endDate_LastMonth = Date.today().toStartOfMonth()-1;        
            Date startDate_LastMonth = endDate_LastMonth.toStartOfMonth();
            
            Id metricId;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMarketingMetrics(goals[0].Id, metricId, startDate_LastMonth, endDate_LastMonth));
        Test.stopTest();        
    }
    
    private static testMethod void marketingMetrics_Test_15a(){
    
        List<Goal__c> goals = [SELECT Id, Name FROM Goal__c WHERE Name LIKE '%Registrar # of Inquiries%' LIMIT 1];
        List<Metric__c> metrics = [SELECT Id, Name, Start_Date__c FROM Metric__c WHERE Goal__c IN : goals ];
        List<Goals_Metrics_Mapping__c> mappingRecs = [SELECT Id FROM Goals_Metrics_Mapping__c ORDER BY CreatedDate ASC];
        
        Test.startTest();
           
            List<Opportunity> opps = [SELECT Id, Name FROM Opportunity]; 
            
            Decimal hr = 100;
            List<Opportunity> updateOpps = new List<Opportunity>();
            for(Opportunity opp : opps){
                opp.Enrollment_Date__c = metrics[0].Start_Date__c;
                opp.Hourly_Rate__c = hr;
                hr += 10;
                updateOpps.add(opp);
            }
            update updateOpps;
            
            Date endDate_LastMonth = Date.today().toStartOfMonth()-1;        
            Date startDate_LastMonth = endDate_LastMonth.toStartOfMonth();
            
            Id metricId;
            
            Database.ExecuteBatch(new PopulateCurrentValueInMarketingMetrics(goals[0].Id, metricId, startDate_LastMonth, endDate_LastMonth));
        Test.stopTest();        
    }
}