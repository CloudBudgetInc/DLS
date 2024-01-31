@isTest
private class WeeklyRequestToUAEInstructor_Test{

    @testSetup static void setupMethod(){
    
        List<Contact_Assignments__c> conAss = TestClassUtil.createTestContactAssignment();
        List<System_Values__c> sysVa = TestClassUtil.createSystemValues();
        
        Test.startTest();
            List<AcctSeed__Time_Card_Day__c> days = TestClassUtil.createTestTimeCardDay();
        Test.stopTest();
    }
    
    private static testMethod void sendEmailToUAEIns1(){
        
        Id canRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        
        Account a = new Account(Name = 'My Account');
        insert a;
        
        List<Contact> contacts = [SELECT Id, Name, Email, IsEmailBounced 
                            FROM Contact 
                            WHERE RecordType.DeveloperName = 'Candidate' AND Active_DLS_Online_User__c = TRUE AND Email != NULL AND 
                                Id IN (SELECT ContactId FROM User WHERE IsActive = TRUE AND IsPortalEnabled = TRUE) LIMIT 1];
                        
        Test.startTest();
                    
            List<Contact_Assignments__c> conAss = [SELECT Id, Name, Candidate_Name__c, Project__c, Start_Date__c, End_Date__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' LIMIT 1];
            conAss[0].Candidate_Name__c = contacts[0].Id;
            update conAss[0]; 
                
            Id eflRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('EFL_Projects').getRecordTypeId();
            
            List<AcctSeed__Project__c> proj = [SELECT Id, DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :conAss[0].Project__c];
            proj[0].RecordTypeId = eflRTId;
            update proj[0];
            
            String CRON_EXP = '0 0 14 * * ?';
            WeeklyRequestToUAEInstructor sch = new WeeklyRequestToUAEInstructor();
            system.schedule('Weekly Request To UAE Instructor', CRON_EXP, sch);
        Test.stopTest();    
    }
}