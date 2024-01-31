@isTest
private class DailyRemainder_Overdue_schedule_Test {
    @testSetup static void setup(){
        
        List<System_Values__c> sysValuesList = TestClassUtil.createSystemValues();
        List<AcctSeed__Time_Card__c> getcards = TestClassUtil.createTestTimeCard();
        List<AcctSeed__Project_Task__c> projTask = TestClassUtil.createTestProjectTask();
         Test.startTest();
            List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
         Test.stopTest();
     }
     static testmethod void test() {
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        Date PrevDate;
        
         if(todayVal.format('EEEE') == 'Monday')
            PrevDate = system.today().addDays(-3);
        else
            PrevDate = system.today().addDays(-1);
                
        List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' AND Candidate_Name__c != Null];
        
        Id instructorTypeId;
        
        Test.startTest();
           for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact']){        
                if(rt.DeveloperName == 'DLS_Employee'){
                    instructorTypeId = rt.Id;
                }
            }
            //List<Contact> conList = new List<Contact> {new Contact(LastName = 'Test Contact', Active_DLS_Employee__c = True, Email = 'test@gmail.com',RecordTypeId = instructorTypeId)};
            //insert conList;
            
            List<Contact> conList = [SELECT Id,RecordTypeId,Email,Active_DLS_Employee__c FROM Contact LIMIT 1];
            
            conList[0].RecordTypeId = instructorTypeId;
            conList[0].Email = 'test@gmail.com';
            conList[0].Active_DLS_Employee__c = true;
            update conList; 
            
            System.debug('::::::conList::'+conList);
            List<AcctSeed__Time_Card__c> timeCard = [SELECT Id, AcctSeed__Employee__c,Intructor__c,AcctSeed__Time_Card_Period__c FROM AcctSeed__Time_Card__c LIMIT 1];
            timeCard[0].Intructor__c = conList[0].Id;
            update timeCard;
            
            List<AcctSeed__Time_Card_Line__c> timeCardLine = new List<AcctSeed__Time_Card_Line__c>();
            List<AcctSeed__Project_Task__c> task = [SELECT Id,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 1];
            
            timeCardLine = new List<AcctSeed__Time_Card_Line__c> {
                new AcctSeed__Time_Card_Line__c(AcctSeed__Time_Card__c = timeCard[0].Id,AcctSeed__Project_Task__c = task[0].Id,AcctSeed__Project__c = task[0].AcctSeed__Project__c)    
            };
            insert timeCardLine;
            
            List<AcctSeed__Time_Card_Day__c> timeCardDays = new List<AcctSeed__Time_Card_Day__c>();
            timeCardDays = new List<AcctSeed__Time_Card_Day__c> {
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = system.today().addDays(-3),Status__c = 'Submitted'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 1.00,AcctSeed__Hours__c = 1,AcctSeed__Date__c = system.today().addDays(-1),Status__c = 'Approved'),
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Total_Hours_Before_Approved__c = 3.00,AcctSeed__Hours__c = 3,AcctSeed__Date__c = system.today().addDays(-2),Status__c = 'Draft')
            };
            
            insert timeCardDays;
            system.debug('::timeCardDays::'+timeCardDays);

            List<AcctSeed__Time_Card_Day__c> timecardDay = [SELECT Id,AcctSeed__Date__c,Status__c,AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c WHERE AcctSeed__Date__c = :PrevDate];
            
            if(timecardDay.size() > 0) {
                timecardDay[0].Status__c = 'Rejected';
                update timecardDay;
                
                system.debug('timecardDay::::'+timecardDay);
                update timecardDay;
            }
            
            // For batch coverage
            //dailyRemainder_Overdue batch = new dailyRemainder_Overdue();
            //database.executeBatch(batch,1); 
            
            // Schedule coverage
            String CRON_EXP = '0 0 11 * * ?';
            DailyRemainder_Overdue_schedule sch = new DailyRemainder_Overdue_schedule();
            system.schedule('Daily Reminder for Overdue Daily Time Entry (Every day @11:00am ET)', CRON_EXP, sch);
        Test.stopTest();      
    }
}