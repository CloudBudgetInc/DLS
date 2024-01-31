@isTest
private class WelcomeBackEmailToDLSOnlineUser_Test{
    
    @testSetup static void setupMethod(){
        
        Test.startTest();
            List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
    }
    
    private static testMethod void myTest(){
    
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Account acc = new Account();
        acc.Name = 'WC Test Acc';
        insert acc;
        
        Contact c = new Contact();
        c.AccountId = acc.Id;
        c.LastName = 'WCLastName';
        c.Email = 'wcemailtest@gmail.com';
        c.RecordTypeId = candidateRTId;
        c.Active_DLS_Online_User__c = True;
        insert c;
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c, Start_Date__c, End_Date__c, Candidate_Name__c, Assignment_Position__c, Paper_Timesheet__c FROM Contact_Assignments__c WHERE Status__c IN ('Active', 'Planned') AND RecordType.DeveloperName IN ('Student') LIMIT 1];
        conAssigns[0].Start_Date__c = Date.Today()+7;
        conAssigns[0].End_Date__c = Date.Today()+60;
        conAssigns[0].Candidate_Name__c = c.Id;
        update conAssigns[0];
        
        Test.startTest();
        
            Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
                    
            User user = new User(alias = 'test123', email='wcemailtest@gmail.com',
                    emailencodingkey='UTF-8', lastname='WCLastName', languagelocalekey='en_US',
                    localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                    ContactId = c.Id,
                    timezonesidkey='America/Los_Angeles', username='wctester@noemail.com');
           
            insert user;
            
            WelcomeBackEmailToDLSOnlineUser.sendWelcomeBackEmail();
            
        Test.stopTest();
    }
}