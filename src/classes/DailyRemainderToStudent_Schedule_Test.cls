@isTest
private class DailyRemainderToStudent_Schedule_Test{

    @testSetup static void setupMethod(){
    
        List<System_Values__c> sysValuesList = TestClassUtil.createSystemValues();
        
        Test.startTest();
            List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
        
        List<Events__c> events = TestClassUtil.createTestEvent();
        List<AcctSeed__Time_Card__c> getcards = TestClassUtil.createTestTimeCard();
    }
    
    private static testMethod void sendAnEmailToStudents(){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        Date PrevDate;
        
         if(todayVal.format('EEEE') == 'Monday')
            PrevDate = system.today().addDays(-3);
        else
            PrevDate = system.today().addDays(-1);
            
            List<Contact> conList = [SELECT Id, Beta_Group__c, Active_DLS_Online_User__c FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Name = 'Test Contact1' LIMIT 1];
            conList[0].Beta_Group__c = TRUE;
            conList[0].Time_Approval_Preference__c = 'Daily';
            conList[0].Active_DLS_Online_User__c = TRUE;
            update conList[0];
            System.debug('conList==='+conList);
            
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c, Intructor__r.RecordType.DeveloperName FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            
            List<AcctSeed__Time_Card_Line__c> timeCardLine = new List<AcctSeed__Time_Card_Line__c>();
            List<AcctSeed__Project_Task__c> task = [SELECT Id, AcctSeed__Project__c,AcctSeed__Project__r.AcctSeed__Opportunity__c, AcctSeed__Project__r.RecordType.DeveloperName FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__r.RecordType.DeveloperName = 'Language_Training_Projects' AND Project_Task_Type__c != 'Preparation time' LIMIT 1];
            
            timeCardLine = new List<AcctSeed__Time_Card_Line__c> {
                new AcctSeed__Time_Card_Line__c(AcctSeed__Time_Card__c = timeCard[0].Id,AcctSeed__Project_Task__c = task[0].Id, AcctSeed__Project__c = task[0].AcctSeed__Project__c)    
            };
            insert timeCardLine;
            
            List<Schedule__c> schedule = [SELECT Id FROM Schedule__c WHERE Project_Task__c = :task[0].Id];            
            Test.startTest();
            
                Id studId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
                Id staffId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
                Contact_Assignments__c conAss1 = new Contact_Assignments__c(RecordTypeId = staffId, Project__c=task[0].AcctSeed__Project__c,Candidate_Name__c=conList[0].Id,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=task[0].AcctSeed__Project__r.AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Project Manager');
                insert conAss1;
                
                Contact_Assignments__c conAss2 = new Contact_Assignments__c(RecordTypeId = studId, Project__c=task[0].AcctSeed__Project__c,Candidate_Name__c=conList[0].Id,Start_Date__c=System.today(),End_Date__c=System.today()+30,Opportunity_Name__c=task[0].AcctSeed__Project__r.AcctSeed__Opportunity__c,Status__c = 'Active', Assignment_Position__c = 'Class Leader');
                insert conAss2;
                
                AcctSeed__Time_Card_Day__c day = new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = PrevDate,Student_Approval_Status__c = 'Submitted');
                insert day;
                
                List<Events__c> eve = [SELECT Id, No_Student_Approval__c FROM Events__c WHERE Schedule__c = :schedule[0].Id];
                eve[0].No_Student_Approval__c = FALSE;
                eve[0].Time_Card_Day__c = day.Id;
                update eve[0];
                
                // Schedule coverage
                String CRON_EXP = '0 0 14 * * ?';
                DailyRemainderToStudent_Schedule sch = new DailyRemainderToStudent_Schedule();
                system.schedule('DailyRemainderToStudent', CRON_EXP, sch);
                
                DailyTimeEntryRemainderToStudent testRem = new DailyTimeEntryRemainderToStudent();
                Database.ExecuteBatch(testRem);
                
            Test.stopTest();
    }
}