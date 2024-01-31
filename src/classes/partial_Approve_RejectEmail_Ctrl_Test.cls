@isTest
public class partial_Approve_RejectEmail_Ctrl_Test {
    @testSetup static void setup(){
        List<AcctSeed__Time_Card_Day__c> timecardList = TestClassUtil.createTestTimeCardDay();
        //List<AcctSeed__Time_Card__c> timecardList = TestClassUtil.createTestTimeCard();
        //List<Contact> conList = TestClassUtil.createTestContacts();          
    }
    public static testMethod void myTest() { 
        
        List<Contact> conList = [Select Id From Contact Limit 2];
        
        List<AcctSeed__Time_Card_Day__c> timecardList = [SELECT Id,Name,Status__c,Total_Hours_Before_Approved__c,AcctSeed__Internal_Comment__c,AcctSeed__Date__c, 
                                                    AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                    AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName
                                                    FROM AcctSeed__Time_Card_Day__c];                                                    
                                                
        system.debug('::timecardList::::timecardList'+timecardList);
        
        Test.StartTest();
            
            List<RecordType> rt = [SELECT Id,DeveloperName FROM RecordType WHERE SObjectType = 'Contact' And DeveloperName = 'DLS_Employee'];
            
            Contact con = new Contact();
            con.Id = timecardList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
            con.RecordTypeId = rt[0].Id;
            update con;
            
            List<AcctSeed__Time_Card__c> timecard1 = [Select Id,Intructor__c From AcctSeed__Time_Card__c Where Id = :timecardList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c];
            timecard1[0].Intructor__c = con.Id;
            update timecard1;
            
            timecardList[0].Status__c = 'Approved';
            update timecardList;
        
            partial_Approve_RejectEmail_Ctrl part = new partial_Approve_RejectEmail_Ctrl();
            part.setcontactId(timecardList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c);
            part.settimecardId(timecardList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c);
            part.getcontactId();
            part.gettimecardId();
            
            timecardList[0].Status__c = 'Approved';
            update timecardList;
            
            partial_Approve_RejectEmail_Ctrl part1 = new partial_Approve_RejectEmail_Ctrl();
            part1.setcontactId(timecardList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c);
            part1.settimecardId(timecardList[0].AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c);
            part1.getcontactId();
            part1.gettimecardId();
        
        Test.StopTest();
    }  
}