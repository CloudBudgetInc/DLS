@isTest
private class Suspend_Ins_Std_User_Salesforce_Test{
    
    @testSetup static void setupMethod(){
    
        List<Contact_Assignments__c> conassigns = TestClassUtil.createTestContactAssignment();
    }
    
    private static testMethod void myTest1(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        Account a  = new Account(Name = 'Test Sus Acc');
        insert a;
        
        Contact c = new Contact(LastName = 'Test Sus Con', Email = 'testsuscon@gmail.com', Accountid = a.Id);
        insert c;
        
         Test.startTest();    
             
            User user = new User(alias = 'suscon', email = 'testsuscon@gmail.com',
                    emailencodingkey = 'UTF-8', lastname = 'Test Sus Con', languagelocalekey = 'en_US',
                    localesidkey = 'en_US', profileid = p, country = 'United States',IsActive = True,
                    ContactId = c.Id,
                    timezonesidkey = 'America/Los_Angeles', username = 'testsuscon@gmail.com');
           
            insert user;
        
            String CRON_EXP = '0 0 0 * * ?';
            Suspend_Ins_Std_User_Salesforce sch = new Suspend_Ins_Std_User_Salesforce();
            System.schedule('Suspend Ins Std User Salesforce', CRON_EXP, sch);
            
        Test.stopTest();
    }
    
    private static testMethod void myTest2(){
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        Account a  = new Account(Name = 'Test Sus Acc');
        insert a;
        
        Contact c = new Contact(LastName = 'Test Sus Con', Email = 'testsuscon@gmail.com', Accountid = a.Id);
        insert c;
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN ('Student') AND Status__c IN ('Planned','Active')];
        conAssigns[0].Candidate_Name__c = c.Id;
        update conAssigns[0];
        
        Test.startTest();    
             
            User user = new User(alias = 'suscon', email = 'testsuscon@gmail.com',
                    emailencodingkey = 'UTF-8', lastname = 'Test Sus Con', languagelocalekey = 'en_US',
                    localesidkey = 'en_US', profileid = p, country = 'United States',IsActive = True,
                    ContactId = c.Id,
                    timezonesidkey = 'America/Los_Angeles', username = 'testsuscon@gmail.com');
           
            insert user;
        
            String CRON_EXP = '0 0 0 * * ?';
            Suspend_Ins_Std_User_Salesforce sch = new Suspend_Ins_Std_User_Salesforce();
            System.schedule('Suspend Ins Std User Salesforce', CRON_EXP, sch);
            
        Test.stopTest();
    }    
}