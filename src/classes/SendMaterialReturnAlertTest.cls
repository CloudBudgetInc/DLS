@isTest
public class SendMaterialReturnAlertTest {

    @testSetup static void setup(){ 
    
        List<Materials_Request__c> matReqs = TestClassUtil.createTestMaterialRequest();   
        Test.startTest();    
            List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
    }
    
    public static testMethod void myTest1() {
        
        Id loanReqRTId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Material_Loan_Request').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssign = [SELECT Id, Name, Start_Date__c, End_Date__c, Project__c, Candidate_Name__c FROM Contact_Assignments__c LIMIT 1];
        conAssign[0].End_Date__c = Date.Today();
        update conAssign[0];
        
        Test.startTest();
        
            List<AcctSeed__Project__c> projRec = [SELECT Id, Name, End_Date__c FROM AcctSeed__Project__c WHERE Id = :conAssign[0].Project__c];
            
            List<Materials_Request__c> matReqs = [SELECT Id, RecordTypeId, Project__c, Request_Status__c, Date_Loaned_Out__c FROM Materials_Request__c LIMIT 1];
            matReqs[0].RecordTypeId = loanReqRTId;
            matReqs[0].Project__c = projRec[0].Id;
            matReqs[0].Request_Status__c = 'Loaned Out';
            matReqs[0].Date_Loaned_Out__c = Date.Today();
            matReqs[0].Contact__c = conAssign[0].Candidate_Name__c;
            update matReqs;            
            
            SendMaterialReturnAlertSchedule sched = new SendMaterialReturnAlertSchedule();
            String sch = '0 0 8 * * ? ';
            String jobID = System.schedule('Send Return Material Alert', sch, sched);
            
        Test.stopTest();     
    }
    
    public static testMethod void myTest2() {
        
        Id loanReqRTId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Material_Loan_Request').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssign = [SELECT Id, Name, Start_Date__c, End_Date__c, Project__c, Candidate_Name__c FROM Contact_Assignments__c LIMIT 1];
        conAssign[0].End_Date__c = Date.Today().addDays(7);
        update conAssign[0];
        
        Test.startTest();
        
            MTT_Location__c loc = new MTT_Location__c(Name='DLS - Herndon');
            insert loc;
        
            List<AcctSeed__Project__c> projRec = [SELECT Id, Name, End_Date__c FROM AcctSeed__Project__c WHERE Id = :conAssign[0].Project__c];
            
            List<Materials_Request__c> matReqs = [SELECT Id, RecordTypeId, Project__c, Request_Status__c, Date_Loaned_Out__c FROM Materials_Request__c LIMIT 1];
            matReqs[0].RecordTypeId = loanReqRTId;
            matReqs[0].Project__c = projRec[0].Id;
            matReqs[0].Request_Status__c = 'Loaned Out';
            matReqs[0].Date_Loaned_Out__c = Date.Today();
            matReqs[0].Location__c = loc.Id;
            matReqs[0].Contact__c = conAssign[0].Candidate_Name__c;
            update matReqs;            
            
            SendMaterialReturnAlertSchedule sched = new SendMaterialReturnAlertSchedule();
            String sch = '0 0 8 * * ? ';
            String jobID = System.schedule('Send Return Material Alert', sch, sched);
            
        Test.stopTest();  
    }
    
    public static testMethod void myTest3() {
        
        Id loanReqRTId = Schema.SObjectType.Materials_Request__c.getRecordTypeInfosByDeveloperName().get('Material_Loan_Request').getRecordTypeId();
        
        List<Contact_Assignments__c> conAssign = [SELECT Id, Name, Start_Date__c, End_Date__c, Project__c, Candidate_Name__c FROM Contact_Assignments__c LIMIT 1];
        conAssign[0].End_Date__c = Date.Today().addDays(7);
        update conAssign[0];
        
        Test.startTest();
        
            MTT_Location__c loc = new MTT_Location__c(Name='DLS - Elkridge');
            insert loc;
        
            List<AcctSeed__Project__c> projRec = [SELECT Id, Name, End_Date__c FROM AcctSeed__Project__c WHERE Id = :conAssign[0].Project__c];
            
            List<Materials_Request__c> matReqs = [SELECT Id, RecordTypeId, Project__c, Request_Status__c, Date_Loaned_Out__c FROM Materials_Request__c LIMIT 1];
            matReqs[0].RecordTypeId = loanReqRTId;
            matReqs[0].Project__c = projRec[0].Id;
            matReqs[0].Request_Status__c = 'Loaned Out';
            matReqs[0].Date_Loaned_Out__c = Date.Today();
            matReqs[0].Location__c = loc.Id;
            matReqs[0].Contact__c = conAssign[0].Candidate_Name__c;
            update matReqs;            
            
            SendMaterialReturnAlertSchedule sched = new SendMaterialReturnAlertSchedule();
            String sch = '0 0 8 * * ? ';
            String jobID = System.schedule('Send Return Material Alert', sch, sched);
            
        Test.stopTest();
    }  
}