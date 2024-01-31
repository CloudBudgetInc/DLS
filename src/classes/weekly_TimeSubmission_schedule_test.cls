@isTest
public class weekly_TimeSubmission_schedule_test {
    @testSetup static void setup(){
        List<User> getuser = TestClassUtil.createTestUsers();
        List<AcctSeed__Ledger__c> getLedger = TestClassUtil.createTestLedger();
        List<AcctSeed__Project_Task__c> projTask = TestClassUtil.createTestProjectTask();
        system.debug('getuser::::'+getuser);
    }
    
    public static testmethod void mytest() {
         
         List<User> userList = [SELECT Id FROM User LIMIT 1];
         List<Contact> conList = [SELECT Id FROM Contact LIMIT 1 ];
         List<AcctSeed__Ledger__c> ledgerList = [SELECT Id, Name FROM AcctSeed__Ledger__c WHERE AcctSeed__Type__c = 'Transactional' LIMIT 1];
         
         Id instructorTypeId;
          for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact']){
            if(rt.DeveloperName == 'DLS_Employee'){
                instructorTypeId = rt.Id;
            }
          }
          conList[0].RecordTypeId = instructorTypeId;
          conList[0].Email = 'test@gmail.com';
          conList[0].Active_DLS_Employee__c = true;
          update conList;
        
         Date currentWeekStart = system.today().toStartofWeek().addDays(1);
         Date currentWeekEnd = currentWeekStart.addDays(6);
        
         Date previousStart = currentWeekStart.addDays(-7);
         Date previousEnd = previousStart.addDays(6);
         
         Date accprdate = system.today();
         System.debug('::::::previousStart::'+previousStart);
         System.debug('::::::previousEnd::'+previousEnd);
         System.debug('::::::conList::'+conList);
         
         List<AcctSeed__Project_Task__c> task = [SELECT Id,AcctSeed__Project__c FROM AcctSeed__Project_Task__c LIMIT 1];
         
         String month;
         
         if(accprdate.month() < 10)
             month = '0'+accprdate.month();
         else
             month = String.valueOf(accprdate.month());
         
          AcctSeed__Accounting_Period__c accPeriod1 = new AcctSeed__Accounting_Period__c();
            accPeriod1.name = accprdate.year()+'-'+month;
            accPeriod1.AcctSeed__Start_Date__c = previousStart;
            accPeriod1.AcctSeed__End_Date__c = previousEnd;
            Insert accPeriod1;
        
         List<AcctSeed__Time_Card_Period__c> timeCardPeriod = new List<AcctSeed__Time_Card_Period__c> {
            new AcctSeed__Time_Card_Period__c(Name = system.today().year()+'-'+system.today().Month(),AcctSeed__End_Date__c = previousEnd,AcctSeed__Start_Date__c= previousStart)
         };
        insert timeCardPeriod;
        System.debug(':::timeCardPeriod:::'+timeCardPeriod);
        
        List<AcctSeed__Time_Card__c> timeCard = new List<AcctSeed__Time_Card__c> {
            new AcctSeed__Time_Card__c(AcctSeed__Employee__c=userList[0].Id,Intructor__c=conList[0].Id,AcctSeed__Time_Card_Period__c=timeCardPeriod[0].Id,AcctSeed__Ledger__c = ledgerList[0].Id)
        };
        insert timeCard;
        
        List<AcctSeed__Time_Card_Line__c> timeCardLine = new List<AcctSeed__Time_Card_Line__c> {
                new AcctSeed__Time_Card_Line__c(AcctSeed__Time_Card__c = timeCard[0].Id,Status__c = 'Draft',AcctSeed__Project_Task__c = task[0].Id,AcctSeed__Project__c = task[0].AcctSeed__Project__c)
            };
        insert timeCardLine;
        
        List<AcctSeed__Time_Card_Day__c> timeCardDay =  new List<AcctSeed__Time_Card_Day__c> {
                new AcctSeed__Time_Card_Day__c(AcctSeed__Time_Card_Line__c = timeCardLine[0].Id,Status__c = 'Draft',Total_Hours_Before_Approved__c = 2.00,AcctSeed__Hours__c = 2,AcctSeed__Date__c = system.today() )
            };
        insert timeCardDay;
        System.debug(':::timeCardDay:::'+timeCardDay[0]);
        System.debug(':::timeCardLine:::'+timeCardLine[0]);
        System.debug(':::timeCard:::'+timeCard[0]);
        System.debug(':::timeCard:::'+timeCard[0].of_Pending_Time_Logs__c);
        Test.startTest();
        
        System_Values__c sysval = new System_Values__c();
        sysval.Name = 'Timesheet';
        sysval.Value__c = 'test@gmail.com';  
        insert sysval;
        
        String CRON_EXP = '0 0 18 * * ?';                
        weekly_TimeSubmission_schedule sch = new weekly_TimeSubmission_schedule();
        system.schedule('Weekly Reminder for Timesheet Submission (Monday 6:00 pm ET)', CRON_EXP, sch);
        Test.stopTest();
    }
}