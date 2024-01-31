@isTest
private class WeeklyReminderToUAEInstructor_Test{

    @testSetup static void setupMethod(){
    
        List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();        
        
        Test.startTest();
            List<System_Values__c> sysVa = TestClassUtil.createSystemValues();
            List<AcctSeed__Time_Card_Day__c> days = TestClassUtil.createTestTimeCardDay();
        Test.stopTest();
    }
    
    private static testMethod void sendEmailToUAEIns1(){
        
        Date currentWeekStart = System.today().toStartofWeek().addDays(1);
        
        Date previousStart = currentWeekStart.addDays(-7);
        Date previousEnd = previousStart.addDays(6);
        
        Id canRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        Account a = new Account(Name = 'My Account');
        insert a;
        
        Contact con = new Contact(AccountId = a.Id, LastName = 'My test con', Active_DLS_Online_User__c = TRUE, RecordTypeId = canRTId, Email = 'mytestcon@gmail.com');
        insert con;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Id = :con.Id];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        Test.startTest();
        
            User user = new User(alias = 'test123', email='test123@noemail.com',
                    emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = conList[0].Id,
                    timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
           
            insert user;
            
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = conList[0].Id;
            update conAss[0]; 
                
            Id eflRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('EFL_Projects').getRecordTypeId();
            
            List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            proj[0].RecordTypeId = eflRTId;
            update proj[0];
            
            List<AcctSeed__Project_Task__c> task = [SELECT Id FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :proj[0].Id LIMIT 1];
            
            Date myDate = date.today();
            Date weekStart = myDate.toStartofWeek()+1;
            Date weekEnd = myDate.toStartofWeek()+7;
        
            String month;
            date monthStart = previousStart.toStartofMonth();
            date monthEnd = previousStart.addMonths(1).toStartofMonth().addDays(-1);
            
            if(monthStart.month() < 10){
                month = '0'+monthStart.month();
            }else {
                month = String.valueOf(monthStart.month());
            }
        
            // Added / Commented to fix the issue related to FIELD_CUSTOM_VALIDATION_EXCEPTION in Accounting Period
            
                /*AcctSeed__Accounting_Period__c accPeriod = new AcctSeed__Accounting_Period__c();
                accPeriod.name = weekStart.year()+'-' +month;
                accPeriod.AcctSeed__Start_Date__c = monthStart;
                accPeriod.AcctSeed__End_Date__c = monthEnd;
                Insert accPeriod;*/
            
            AcctSeed__Time_Card_Period__c tcp = new AcctSeed__Time_Card_Period__c(Name = previousStart.year()+'-'+previousStart.Month(),AcctSeed__End_Date__c = previousEnd,AcctSeed__Start_Date__c= previousStart);
            insert tcp;
            
            List<AcctSeed__Time_Card__c> tc = [SELECT Id, AcctSeed__Employee__c,AcctSeed__Time_Card_Period__c, AcctSeed__Ledger__c FROM AcctSeed__Time_Card__c LIMIT 1];
            
            AcctSeed__Time_Card__c timeCard = new AcctSeed__Time_Card__c(AcctSeed__Employee__c = tc[0].AcctSeed__Employee__c, Intructor__c = conList[0].Id, AcctSeed__Time_Card_Period__c = tcp.Id, AcctSeed__Ledger__c = tc[0].AcctSeed__Ledger__c);
            insert timeCard;
        
            AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
            timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
            timeCardLine.AcctSeed__Project__c = proj[0].Id;
            timeCardLine.AcctSeed__Billable__c = TRUE;
            timeCardLine.Payroll_Item__c = 'ADM';
            timeCardLine.Contact_Assignment__c = conAss[0].Id;
            timeCardLine.AcctSeed__Time_Card__c = timeCard.Id;
            insert timeCardLine;
            
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = System.Today(), Status__c = 'Draft');
            insert day;
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            WeeklyReminderToUAEInstructor sch = new WeeklyReminderToUAEInstructor();
            system.schedule('Weekly Reminder To UAE Instructor', CRON_EXP, sch);
        Test.stopTest();    
    }
}