@isTest
private class AssessmentReportEmailToInstructor_Test{

    @testSetup static void setupMethod(){
        
        Test.startTest();
            List<AcctSeed__Project__c> projects = TestClassUtil.createTestProject();
            List<Contact> conList = TestClassUtil.createTestContacts();
        Test.stopTest();
        List<System_Values__c> sysVal = TestClassUtil.createSystemValues();
    }
    
    private static testMethod void myTest1(){
    
        Date reportDate = Date.Today()+7;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName IN ('Candidate', 'Student')];
        
        List<Account> accList = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 2'];
        
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 2];
        
        Test.startTest();
                    
            // For more than one project scenario, I have inserted AR here
            List<Assessment_Report__c> reports = new List<Assessment_Report__c>{
                new Assessment_Report__c(Name = 'My Test Report1', Report_Date__c = reportDate, Project__c=projList[0].Id, Instructor__c = conList[0].Id, Report_Type__c = 'DLI',Status__c = 'Scheduled',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[1].Id,Sponser__c = accList[0].Id, Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10),
                new Assessment_Report__c(Name = 'My Test Report2', Report_Date__c = reportDate, Project__c=projList[1].Id, Instructor__c = conList[0].Id, Status__c = 'Scheduled',Language__c = 'English',Student__c = conList[0].Id,Training_officer__c = conList[1].Id,Sponser__c = accList[0].Id,Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+20)
            };
            insert reports;
            
            AssessmentReportEmailToInstructor.sendAnEmailInstructor();
            
        Test.stopTest();
    }
    
    private static testMethod void myTest2(){
    
        Date reportDate = Date.Today()+7;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName IN ('Candidate', 'Student')];
        
        List<Account> accList = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 2'];
        
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 2];
        
        Test.startTest();
            
            Id testRTId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Test_Report').getRecordTypeId();
    
            // For more than one project scenario, I have inserted AR here
            List<Assessment_Report__c> reports = new List<Assessment_Report__c>{
                new Assessment_Report__c(Test_Report_Type__c = 'Progress', RecordTypeId = testRTId, Name = 'My Test Report1', Report_Date__c = reportDate, Project__c=projList[0].Id, Instructor__c = conList[0].Id, Report_Type__c = 'DLI',Status__c = 'Scheduled',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[1].Id,Sponser__c = accList[0].Id, Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
            };
            insert reports;
            
            AssessmentReportEmailToInstructor.sendAnEmailInstructor();
            
        Test.stopTest();
    }
    
    private static testMethod void myTest3(){
    
        Date reportDate = Date.Today()+7;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName IN ('Candidate', 'Student')];
        
        List<Account> accList = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 2'];
        
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 2];
        
        Test.startTest();
            
            Id testRTId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Test_Report').getRecordTypeId();
    
            // For more than one project scenario, I have inserted AR here
            List<Assessment_Report__c> reports = new List<Assessment_Report__c>{
                new Assessment_Report__c(Test_Report_Type__c = 'Progress', RecordTypeId = testRTId, Name = 'My Test Report1', Report_Date__c = reportDate, Project__c=projList[0].Id, Tester__c = conList[0].Id, Report_Type__c = 'DLI',Status__c = 'Scheduled',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[1].Id,Sponser__c = accList[0].Id, Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
            };
            insert reports;
            
            AssessmentReportEmailToInstructor.sendAnEmailInstructor();
            
        Test.stopTest();
    }
}