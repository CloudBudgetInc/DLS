@isTest
public class Test_SendFeedbackRemainderBatch {
    
    public static testmethod void testMethod1() {
        
        Account acc = new Account(name='Test Account',Type = 'Other',BillingStreet = '24 Jackson Road');
        Insert acc;
        
       /*** Opportunity opp = New Opportunity();
        opp.Name = 'Test Opportunity';
        opp.AccountId = acc.Id;
        opp.StageName = 'Gate 1';
        opp.CloseDate = date.valueof(system.today() + 20);
        insert opp; ***/
        
        //Added
        AcctSeed__Project__c pro = new AcctSeed__Project__c();
        pro.Name = 'Test Project';
        pro.AcctSeed__Status__c = 'Active';
        insert pro;
        //Ended
        
        Contact con = new Contact(LastName='Test Contact',AccountId=acc.Id,Email='test@test.com',MailingPostalCode = '60012');
        insert con;
        
        List<RecordType> recType = [SELECT Id,DeveloperName,SobjectType FROM RecordType WHERE SobjectType = 'Contact_Assignments__c' AND DeveloperName = 'Student']; 
        
        Contact_Assignments__c conAssign = new Contact_Assignments__c(Close_Getfeedback_sent__c = System.today()-5,Weekly_Getfeedback_sent__c=System.today()-2,Candidate_Name__c=con.Id,Start_Date__c=System.today(),End_Date__c=System.today()+30,RecordTypeId=recType[0].Id,Project__c=pro.Id);
        insert conAssign;
        
        sendFeedbackRemainderBatch send = new sendFeedbackRemainderBatch();
        Database.executeBatch(send, 10); 
    }
}