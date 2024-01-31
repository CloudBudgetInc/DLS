@isTest
public class WeeklyStatusEmail_schedule_Test {
    @testSetup static void setup(){
        List<AcctSeed__Time_Card_Day__c> getdays = TestClassUtil.createTestTimeCardDay();
        system.debug('getdays::::'+getdays);
    }
     static testmethod void test() {
         List<Contact> conList = [SELECT Id,RecordTypeId,FirstName,LastName,MiddleName FROM Contact LIMIT 1];
         Id instructorTypeId;
         
        Test.startTest();
            
          List<User> usrList = [SELECT Id,Name,FirstName,MiddleName,LastName FROM User WHERE IsActive = true LIMIT 1];
          
          for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Contact']){
            if(rt.DeveloperName == 'DLS_Employee'){
                instructorTypeId = rt.Id;
            }
          }
          
          conList[0].RecordTypeId = instructorTypeId;
          conList[0].Supervisor_Name__c = usrList[0].Id;
          update conList;
          
          List<AcctSeed__Time_Card_Day__c> timecardDay = [SELECT Id,AcctSeed__Date__c,Status__c,AcctSeed__Time_Card_Line__c FROM AcctSeed__Time_Card_Day__c LIMIT 3];
          
          timecardDay[0].AcctSeed__Date__c = system.today().addDays(-7);
          timecardDay[0].Status__c = 'Submitted';
          
          timecardDay[1].AcctSeed__Date__c = system.today().addDays(-6);
          timecardDay[2].AcctSeed__Date__c = system.today().addDays(-5);
          
          update timecardDay;
          
            String CRON_EXP = '0 0 14 * * ?';
            WeeklyStatusEmail_schedule sch = new WeeklyStatusEmail_schedule();
            system.schedule('Weekly Timesheet Status E-mail to Supervisor (Monday @ 5:00 pm ET)', CRON_EXP, sch);
        Test.stopTest();
    }
}