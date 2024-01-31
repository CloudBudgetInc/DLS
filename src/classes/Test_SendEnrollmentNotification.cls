@isTest
private class Test_SendEnrollmentNotification {

    static testMethod void SendEnrollmentNotificationTestMethod() { 
    
        Contact con = new Contact(LastName = 'Chris Bellas', Email = 'testcon1@gmail.com');
        insert con;
        
        Opportunity opp = new Opportunity(Name = 'testopp1', StageName = 'Qualification', CloseDate = Date.today(), Student_Name__c = con.Id,Start_Date__c = system.today());
        insert opp; 
        
        SendEnrollmentNotification.submit(opp.Id);   
    }
}