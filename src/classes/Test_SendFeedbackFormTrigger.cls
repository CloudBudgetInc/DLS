@isTest
public class Test_SendFeedbackFormTrigger {
    
    @testSetup static void setup(){
        List<Contact_Assignments__c> contactAssignments = TestClassUtil.createTestContactAssignment();
    }
    
    public static testmethod void testMethod1() {
       
        /*
        Account acc = new Account(name='Test Account',Type = 'Other',BillingStreet = '24 Jackson Road');
        Insert acc;
        
        Opportunity opp = New Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Gate 1';
        opp.CloseDate = date.valueof(system.today() + 20);
        insert opp; 
        
        Contact con = new Contact(LastName='Test Contact',AccountId=acc.Id,Email='test@test.com',MailingPostalCode = '60012');
        insert con;
        
        List<RecordType> recType = [SELECT Id,DeveloperName,SobjectType FROM RecordType WHERE SobjectType = 'Contact_Assignments__c' AND DeveloperName = 'Student']; 
        
        Contact_Assignments__c conAssign = new Contact_Assignments__c(Candidate_Name__c=con.Id,Start_Date__c=System.today(),End_Date__c=System.today()+30,RecordTypeId=recType[0].Id,Opportunity_Name__c=opp.Id);
        insert conAssign;
        
        opp.Hours_Used__c = 5;
        opp.Hours_Week__c = 5;
        opp.StageName = 'Ended';
        update opp;
        */
        
        Test.StartTest();
        try {
            List<Contact_Assignments__c> assignments = [SELECT Id,Name,Candidate_Name__c,Opportunity_Name__c,Status__c FROM Contact_Assignments__c LIMIT 3];
            
            List<Contact> contactList = [SELECT Id,Name,Email FROM Contact WHERE Name LIKE 'Test Contact%' LIMIT 2];
            
            System.debug('contactList : ' + contactList);
            
            List<Opportunity> oppList = [SELECT Id,Name,Start_Date__c,End_Date__c,AccountId,Hours_Used_Rollup__c,Last_Notified_Hour__c,StageName,Hours_Week__c FROM Opportunity LIMIT 2];
            
            system.debug(':::::oppList[0]:::'+oppList[0]);
            
            List<Time_Log__c> timelogList = new List<Time_Log__c> {
                new Time_Log__c(Opportunity__c = oppList[0].Id, Contact__c = contactList[0].Id, Date__c = Date.today().addDays(-20), Hours__c = 8,Billable_Work__c = true,Unposted__c = false),
                new Time_Log__c(Opportunity__c = oppList[0].Id, Contact__c = contactList[0].Id, Date__c = Date.today().addDays(-19), Hours__c = 7,Billable_Work__c = true,Unposted__c = false)
            };
            System.debug('timelogList : ' + timelogList);
            insert timelogList;
            
            
            system.debug(':::::::oppList[0]::::update:::'+oppList[0]);
        }catch(Exception e) {
            system.debug(':::::::::e:::::::'+e);
        }
        Test.StopTest(); 
    } 
    
    public static testmethod void testMethod2() {
        // Set<Id> oppIdSet = new Set<Id>();
        Set<Id> proIdSet = new Set<Id>(); 
        Test.StartTest();
        try {
            List<Contact_Assignments__c> assignments = [SELECT Id,Name,Candidate_Name__c,Opportunity_Name__c,Status__c FROM Contact_Assignments__c LIMIT 3];
            
            List<Contact> contactList = [SELECT Id,Name,Email FROM Contact WHERE Name LIKE 'Test Contact%' LIMIT 2];
            
            System.debug('contactList : ' + contactList);
            
       /***     List<Opportunity> oppList = [SELECT Id,Name,Start_Date__c,End_Date__c,AccountId,Hours_Used_Rollup__c,StageName,Hours_Week__c FROM Opportunity LIMIT 2];
            
            system.debug('::::oppList[0]::::'+oppList[0]);
           
            for(Opportunity opp : oppList) {
                oppIdSet.add(opp.Id);
            }
            
            sendFeedbackFormHelper.sendEmailForCompleted(oppIdSet,oppList);
            sendFeedbackFormHelper.sendEmail(oppIdSet,oppList); ***/
            
            List<AcctSeed__Project__c> proList = [SELECT Id,Name,Start_Date__c,End_Date__c FROM AcctSeed__Project__c LIMIT 2];
                       
            for(AcctSeed__Project__c pro : proList) {
                proIdSet.add(pro.Id);
            }
            
            sendFeedbackFormHelper.sendEmailForCompleted(proIdSet,proList);
            sendFeedbackFormHelper.sendEmail(proIdSet,proList);
            
        }catch(Exception e) {
            system.debug(':::::::::e:::::::'+e);
        }
       Test.StopTest(); 
        
    }
}