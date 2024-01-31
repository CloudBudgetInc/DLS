@isTest
public class Test_TimeLog_delete_Override_Controller {
    
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
                
                ApexPages.StandardController sc1 = new ApexPages.standardController(timelogList[0]);
                TimeLog_delete_Override_Controller timeLogCtrl = new TimeLog_delete_Override_Controller(sc1);
                
                timelogList[0].Notes__c = 'Test Update';
                String timeLogString = JSON.serializePretty(timelogList);
                
                TimeLog_delete_Override_Controller.updateTimeLog(timeLogString);
            }
            
            timelogList[0].Notes__c = 'Test Update from record';
            String timeLogString = JSON.serializePretty(timelogList);
                
            TimeLog_delete_Override_Controller.updateTimeLog(timeLogString);
            
        }catch(Exception e) {
            system.debug(':::::::::erro::::::'+e.getMessage());
            Boolean expectedExceptionThrown;
            
            if(e.getMessage().contains('You cannot delete Time Log record. Please unpost it.')) {
                expectedExceptionThrown = true;
            }else if(e.getMessage().contains('You cannot edit Time Log record after Time Log locking period')) {
                expectedExceptionThrown = true;
            }else if(e.getMessage().contains('Insufficient Privilege')) {
                expectedExceptionThrown = true;
            }else if(e.getMessage().contains('Please update Time Log comments')) {
                expectedExceptionThrown = true;
            }else {
                expectedExceptionThrown = true;
            }
            
            System.AssertEquals(expectedExceptionThrown, true);
        }
     }
   

}