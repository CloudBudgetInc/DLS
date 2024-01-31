@isTest
public class Test_timeLogSnapshotRec_Trigger {
    
    @testSetup static void setup(){
           List<Opportunity> opportunity = TestClassUtil.createTestOpportunities();
           List<Contact> conList = TestClassUtil.createTestContacts();
     }
     
     public static testMethod void testMethod1(){
         
         List<Opportunity> oppList = [SELECT Id,Name FROM Opportunity LIMIT 2];
         
         List<Contact> conList = [SELECT Id,Name FROM Contact LIMIT 2];
         
         System_Values__c sysVal = new System_Values__c();
         sysVal.Name = 'TimeLog_Locking_Date';
         sysVal.Value__c = String.valueOf(system.today().addDays(-30));
         
         insert sysVal;
         
         List<Time_Log__c> timelogList = new List<Time_Log__c> {
            new Time_Log__c(Opportunity__c = oppList[0].Id, Contact__c = conList[0].Id, Date__c = Date.today().addDays(-20), Hours__c = 1,Billable_Work__c = true,Unposted__c = false),
            new Time_Log__c(Opportunity__c = oppList[0].Id, Contact__c = conList[0].Id, Date__c = Date.today().addDays(-19), Hours__c = 2,Billable_Work__c = false,Unposted__c = false)
        };
        
        List<Profile> Profile = [SELECT Id FROM Profile WHERE Name = 'Timekeeping'];
        
        String un = String.valueOf(System.now().millisecond())+'@dlsTestOrg.dlsdc';
        String en = String.valueOf(System.now().millisecond())+'@dlsTestOrg.com';
        
        User usr = new User(Alias = 'standt', Email='test@gmail.com',EmailEncodingKey='UTF-8', LastName='Testing', 
            LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = Profile[0].Id, contact=conList[0], 
            TimeZoneSidKey='America/Los_Angeles', UserName=un);
            
        insert usr;
        
        try {
            
            System.runAs(usr) {
    
                insert timelogList;
                
                List<Time_Log_Snapshot__c> timeLogSnapshot = new List<Time_Log_Snapshot__c>{
                       new Time_Log_Snapshot__c(Billable_Work__c = timelogList[0].Billable_Work__c,Date__c = timelogList[0].Date__c,Time_Log__c = timelogList[0].Id,Unposted__c = timelogList[0].Unposted__c),
                       new Time_Log_Snapshot__c(Billable_Work__c = timelogList[1].Billable_Work__c,Date__c = timelogList[1].Date__c,Time_Log__c = timelogList[1].Id,Unposted__c = timelogList[1].Unposted__c)
                };
                
                insert timeLogSnapshot;
                
                update timeLogSnapshot[0];
            }
            
        }catch(Exception e) {
            system.debug(':::::::::erro::::::'+e.getMessage());
            Boolean expectedExceptionThrown;
            
            if(e.getMessage().contains('You can\'t update Time Log Snapshot Record')) {
                expectedExceptionThrown = true;
            }else if(e.getMessage().contains('You can\'t delete Time Log Snapshot Record')) {
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
         
         System_Values__c sysVal = new System_Values__c();
         sysVal.Name = 'TimeLog_Locking_Date';
         sysVal.Value__c = String.valueOf(system.today().addDays(-30));
         
         insert sysVal;
         
         List<Time_Log__c> timelogList = new List<Time_Log__c> {
            new Time_Log__c(Opportunity__c = oppList[0].Id, Contact__c = conList[0].Id, Date__c = Date.today().addDays(-20), Hours__c = 1,Billable_Work__c = true,Unposted__c = false),
            new Time_Log__c(Opportunity__c = oppList[0].Id, Contact__c = conList[0].Id, Date__c = Date.today().addDays(-19), Hours__c = 2,Billable_Work__c = false,Unposted__c = false)
        };
        
        List<Profile> Profile = [SELECT Id FROM Profile WHERE Name = 'Timekeeping'];
        
        String un = String.valueOf(System.now().millisecond())+'@dlsTestOrg.dlsdc';
        String en = String.valueOf(System.now().millisecond())+'@dlsTestOrg.com';
        
        User usr = new User(Alias = 'standt', Email='test@gmail.com',EmailEncodingKey='UTF-8', LastName='Testing', 
            LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = Profile[0].Id, contact=conList[0], 
            TimeZoneSidKey='America/Los_Angeles', UserName=un);
            
        insert usr;
        
        
        try {
            
            System.runAs(usr) {
                insert timelogList;
            
                List<Time_Log_Snapshot__c> timeLogSnapshot = new List<Time_Log_Snapshot__c>{
                       new Time_Log_Snapshot__c(Billable_Work__c = timelogList[0].Billable_Work__c,Date__c = timelogList[0].Date__c,Time_Log__c = timelogList[0].Id,Unposted__c = timelogList[0].Unposted__c),
                       new Time_Log_Snapshot__c(Billable_Work__c = timelogList[1].Billable_Work__c,Date__c = timelogList[1].Date__c,Time_Log__c = timelogList[1].Id,Unposted__c = timelogList[1].Unposted__c)
                };
                
                insert timeLogSnapshot;
                
                delete timeLogSnapshot[0];
            }
            
        }catch(Exception e) {
            system.debug(':::::::::erro::::::'+e.getMessage());
            Boolean expectedExceptionThrown;
            
            if(e.getMessage().contains('You can\'t update Time Log Snapshot Record')) {
                expectedExceptionThrown = true;
            }else if(e.getMessage().contains('You can\'t delete Time Log Snapshot Record')) {
                expectedExceptionThrown = true;
            }else if(e.getMessage().contains('Insufficient Privilege')) {
                expectedExceptionThrown = true;
            }
            
            System.AssertEquals(expectedExceptionThrown, true);
        }
     }
   

}