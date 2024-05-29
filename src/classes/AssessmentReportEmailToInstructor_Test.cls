@isTest
private class AssessmentReportEmailToInstructor_Test{

    @testSetup static void setupMethod(){
    
         List<Assessment_Report__c> assessmentReports = TestClassUtil.createTestAssessmentReport();
         
         List<System_Values__c> sysVal = TestClassUtil.createSystemValues();
    }
    
    private static testMethod void myTest1(){
    
        Date reportDate = Date.Today()+7;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact LIMIT 2];
                
        List<Assessment_Report__c> assessmentReports = [SELECT Id, Report_Date__c, Project__c, Status__c, Instructor__c FROM Assessment_Report__c LIMIT 2];
        assessmentReports[0].Report_Date__c = reportDate;
        assessmentReports[0].Status__c = 'Scheduled';
        assessmentReports[0].Instructor__c = conList[0].Id;
        assessmentReports[1].Report_Date__c = reportDate;
        assessmentReports[1].Status__c = 'Scheduled';
        assessmentReports[1].Instructor__c = conList[1].Id;
        
        Test.startTest();
        
            List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c WHERE Id = :assessmentReports[0].Project__c];
            
            update assessmentReports[0];
            
            AssessmentReportEmailToInstructor.sendAnEmailInstructor();
        
        Test.stopTest();
    }
    
    private static testMethod void myTest2(){
    
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
    
    private static testMethod void myTest3(){
    
        Date reportDate = Date.Today()+7;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName IN ('Candidate', 'Student')];
        
        List<Account> accList = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 2'];
        
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 2];
        projList[0].AcctSeed__Account__c = accList[0].Id;
        update projList[0];
        
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
    
    // To send an email notification to the students to complete their DLI W Self Assessment Test Report(s) before 7 days of Its Report_Date__c
    private static testMethod void myTest4(){
    
        Date reportDate = Date.Today()+7;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName IN ('Candidate', 'Student')];
        
        List<Account> accList = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 2'];
        
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 2];
        
        Test.startTest();
            
            Id dliSelfRTId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('DLI_W_Self_Assessment_Test_Report').getRecordTypeId();
    
            // For more than one project scenario, I have inserted AR here
            List<Assessment_Report__c> reports = new List<Assessment_Report__c>{
                new Assessment_Report__c(RecordTypeId = dliSelfRTId, Name = 'My Test DLI Self AR Report1', Report_Date__c = reportDate, Project__c=projList[0].Id, Instructor__c = conList[0].Id, Report_Type__c = 'DLI',Status__c = 'Scheduled',Language__c = 'Tamil',Student__c = conList[0].Id,Training_officer__c = conList[1].Id,Sponser__c = accList[0].Id, Evaluation_Period_From__c = System.today(),Evaluation_Period_To__c = System.today()+10)
            };
            insert reports;
            
            AssessmentReportEmailToInstructor.sendAnEmailInstructor();
            
        Test.stopTest();
    }
}