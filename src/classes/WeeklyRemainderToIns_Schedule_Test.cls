@isTest
private class WeeklyRemainderToIns_Schedule_Test{
    
    @testSetup static void setupMethod(){
        
        List<AcctSeed__Ledger__c> ledger = TestClassUtil.createTestLedger();
        // Project task is not specified in CA, So that PT is queried
        List<AcctSeed__Project_Task__c> projTask = TestClassUtil.createTestProjectTask();    
        Test.startTest();
            List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
            List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
        Test.stopTest();
     }
     
     private static testmethod void sendEmailToInstructor() {
           
        List<Contact> conList = [SELECT Id, RecordTypeId, Email,FirstName,LastName,AccountId FROM Contact WHERE RecordType.DeveloperName = 'Candidate' LIMIT 1];
        
        String candidateRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        Contact con = new Contact(FirstName = 'Testing',LastName = 'Candidate 01',Email = 'test111119@gmail.com',AccountId = conList[0].AccountId,RecordTypeId = candidateRT);
        
        insert con;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',
                ContactId = con.Id,FirstName = con.FirstName,LastName = con.LastName,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com', IsActive = TRUE);
       
        insert user;
                                       
        Date currentWeekStart = system.today().toStartofWeek().addDays(1);
        Date currentWeekEnd = currentWeekStart.addDays(6);
        
        Date previouswkStart = currentWeekStart.addDays(-7);
        Date previouswkEnd = previouswkStart.addDays(6);
        String month;
        Date monthStart = previouswkStart.toStartofMonth();
        Date monthEnd = previouswkEnd.addMonths(1).toStartofMonth().addDays(-1);
        
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
        conAss[0].Candidate_Name__c = con.Id;
        update conAss[0]; 

        List<AcctSeed__Project__c> projects = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
        
        if(monthStart.month() < 10){
            month = '0'+monthStart.month();
        }else {
            month = String.valueOf(monthStart.month());
        }
        
        AcctSeed__Accounting_Period__c accPeriod = new AcctSeed__Accounting_Period__c();
        accPeriod.name = previouswkStart.year()+'-' +month;
        accPeriod.AcctSeed__Start_Date__c = monthStart;
        accPeriod.AcctSeed__End_Date__c = monthEnd;
        insert accPeriod;
        
        List<AcctSeed__Time_Card_Period__c> timeCardPeriod = new List<AcctSeed__Time_Card_Period__c> {
            new AcctSeed__Time_Card_Period__c(Name = 'Test TCP',AcctSeed__End_Date__c = previouswkEnd,AcctSeed__Start_Date__c= previouswkStart)
        };
        insert timeCardPeriod;
        
        List<AcctSeed__Ledger__c> ledgerList = [SELECT Id, Name, AcctSeed__Type__c FROM AcctSeed__Ledger__c WHERE AcctSeed__Type__c = 'Transactional' LIMIT 1];
        
        List<AcctSeed__Time_Card__c> timeCard = new List<AcctSeed__Time_Card__c> {
            new AcctSeed__Time_Card__c(Intructor__c = con.Id,AcctSeed__Employee__c = user.Id, AcctSeed__Time_Card_Period__c = timeCardPeriod[0].Id, AcctSeed__Ledger__c = ledgerList[0].Id)
        };
        
        insert timeCard;
               
        List<AcctSeed__Project_Task__c> task = [SELECT Id FROM AcctSeed__Project_Task__c LIMIT 1];
        
        AcctSeed__Time_Card_Line__c timeCardLine = new AcctSeed__Time_Card_Line__c();
        timeCardLine.AcctSeed__Project_Task__c = task[0].Id;
        timeCardLine.AcctSeed__Project__c = projects[0].Id;
        timeCardLine.AcctSeed__Billable__c = TRUE;
        timeCardLine.Payroll_Item__c = 'ADM';
        timeCardLine.Contact_Assignment__c = conAss[0].Id;
        timeCardLine.AcctSeed__Time_Card__c = timeCard[0].Id;
        insert timeCardLine;
         
        Test.startTest();
           
            AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine.Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = previouswkStart,Status__c = 'Approved');
            insert day;
                        
            List<AcctSeed__Time_Card_Day__c> timecardDay = [SELECT Id,AcctSeed__Date__c,Status__c,AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c WHERE AcctSeed__Date__c >= :previouswkStart OR AcctSeed__Date__c <= :previouswkEnd];
            timecardDay[0].Status__c = 'Recalled';
            timecardDay[0].Recall_Reason__c = 'Just test for Recalled';
            update timecardDay[0];
            
            List<AcctSeed__Time_Card_Day__c> tcDay= [SELECT Id,AcctSeed__Date__c,Status__c,AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c WHERE AcctSeed__Date__c >= :previouswkStart OR AcctSeed__Date__c <= :previouswkEnd];
            tcDay[0].Status__c = 'Rejected';
            tcDay[0].Recall_Reason__c = 'Just test for Rejected';
            update tcDay[0];
            
            //  Execute Batch
            WeeklyRemainderToInstructor rem = new WeeklyRemainderToInstructor();
            Database.executeBatch(rem, 1);
            
            // Schedule coverage
            String CRON_EXP = '0 0 12 * * ?';
            WeeklyRemainderToInstructor_Schedule sch = new WeeklyRemainderToInstructor_Schedule();
            system.schedule('Weekly Remainder for Instructor Com User on Monday (@12:00pm ET)', CRON_EXP, sch);
            
        Test.stopTest();
    }
}