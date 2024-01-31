@isTest
public class Test_timeSnapshot_Trigger {
    
    @testSetup static void setup(){
           List<AcctSeed__Time_Card_Day__c> timeCardDay = TestClassUtil.createTestTimeCardDay();
     }
     
     public static testMethod void testMethod1() {
         
         List<Opportunity> oppList = [SELECT Id,Name FROM Opportunity LIMIT 2];
         
         List<Contact> conList = [SELECT Id,Name FROM Contact LIMIT 2];
         
         List<AcctSeed__Time_Card_Day__c> timeCardDayList = [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Hours__c,Status__c,AcctSeed__Time_Card_Line__c,
                                                                     Total_Hours_Before_Approved__c,AcctSeed__Internal_Comment__c
                                                             FROM AcctSeed__Time_Card_Day__c 
                                                             LIMIT 3];
          
        
        List<Accounting_Seed_Time_Snapshot__c> timeSnapshotList = new List<Accounting_Seed_Time_Snapshot__c> {
                    new Accounting_Seed_Time_Snapshot__c(Time_Card_Day__c = timeCardDayList[0].Id, Date__c = timeCardDayList[0].AcctSeed__Date__c, Hours__c = timeCardDayList[0].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[0].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[0].Status__c,Time_Card_Line__c = timeCardDayList[0].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[0].Total_Hours_Before_Approved__c),
                    new Accounting_Seed_Time_Snapshot__c(Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c)
                };
        system.debug(':::::timeSnapshotList::::::::'+timeSnapshotList);
        try {
            system.debug(':::::timeSnapshotList::::::::'+timeSnapshotList);
            
            insert timeSnapshotList;
            
            update timeSnapshotList[0];
            
        }catch(Exception e) {
            system.debug(':::::::::erro::::::'+e.getMessage());
            Boolean expectedExceptionThrown;
            
            if(e.getMessage().contains('You can\'t update Time Snapshot Record')) {
                expectedExceptionThrown = true;
            }else if(e.getMessage().contains('You can\'t delete Time Snapshot Record')) {
                expectedExceptionThrown = true;
            }else if(e.getMessage().contains('Insufficient Privilege')) {
                expectedExceptionThrown = true;
            }
            
            System.AssertEquals(expectedExceptionThrown, true);
        }
     }
     
     
     public static testMethod void testMethod2(){
         
         List<Opportunity> oppList = [SELECT Id,Name FROM Opportunity LIMIT 2];
         
         List<Contact> conList = [SELECT Id,Name FROM Contact LIMIT 2];
         
         List<AcctSeed__Time_Card_Day__c> timeCardDayList = [SELECT Id,Name,AcctSeed__Date__c,AcctSeed__Hours__c,Status__c,AcctSeed__Time_Card_Line__c,
                                                                     Total_Hours_Before_Approved__c,AcctSeed__Internal_Comment__c
                                                             FROM AcctSeed__Time_Card_Day__c 
                                                             LIMIT 3];
         
        
        
        List<Accounting_Seed_Time_Snapshot__c> timeSnapshotList = new List<Accounting_Seed_Time_Snapshot__c> {
                    new Accounting_Seed_Time_Snapshot__c(Time_Card_Day__c = timeCardDayList[0].Id, Date__c = timeCardDayList[0].AcctSeed__Date__c, Hours__c = timeCardDayList[0].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[0].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[0].Status__c,Time_Card_Line__c = timeCardDayList[0].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[0].Total_Hours_Before_Approved__c),
                    new Accounting_Seed_Time_Snapshot__c(Time_Card_Day__c = timeCardDayList[1].Id, Date__c = timeCardDayList[1].AcctSeed__Date__c, Hours__c = timeCardDayList[1].AcctSeed__Hours__c,Internal_Comment__c = timeCardDayList[1].AcctSeed__Internal_Comment__c,TCD_Status__c = timeCardDayList[1].Status__c,Time_Card_Line__c = timeCardDayList[1].AcctSeed__Time_Card_Line__c,Total_Hours_Before_Approved__c = timeCardDayList[1].Total_Hours_Before_Approved__c)
                };
            
            system.debug(':::::timeSnapshotList::::::::'+timeSnapshotList);
        
        try {
            system.debug(':::::timeSnapshotList::::::::'+timeSnapshotList);
            insert timeSnapshotList;
            
            delete timeSnapshotList[0];
            
        }catch(Exception e) {
            system.debug(':::::::::erro::::::'+e.getMessage());
            Boolean expectedExceptionThrown;
            
            if(e.getMessage().contains('You can\'t update Time Snapshot Record')) {
                expectedExceptionThrown = true;
            }else if(e.getMessage().contains('You can\'t delete Time Snapshot Record')) {
                expectedExceptionThrown = true;
            }else if(e.getMessage().contains('Insufficient Privilege')) {
                expectedExceptionThrown = true;
            }
            
            System.AssertEquals(expectedExceptionThrown, true);
        }
     }
   

}