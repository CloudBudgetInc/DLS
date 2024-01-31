@isTest
private class CreateLTRecordFromARFlow_Test{
    
    @testSetup static void setupMethod(){
    
        Test.startTest();
            List<Contact_Assignments__c> conAssList = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
    }
    
    private static testMethod void myTest(){
    
        Date reportDate = Date.Today()+7;
        
        List<Contact> conList = [SELECT Id, Name FROM Contact WHERE RecordType.DeveloperName IN ('Candidate', 'Student')];
        
        List<Account> accList = [SELECT Id,Name FROM Account WHERE Name = 'Test Account 2'];
        
        List<AcctSeed__Project__c> projList = [SELECT Id FROM AcctSeed__Project__c LIMIT 2];
        
        Test.startTest();
            
            Id testRTId = Schema.SObjectType.Assessment_Report__c.getRecordTypeInfosByDeveloperName().get('Test_Report').getRecordTypeId();
            List<Contact_Assignments__c> stdCA = [SELECT Id, Project__c, Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student'];
            stdCA[0].Candidate_Name__c = conList[1].Id;
            stdCA[0].Project__c = projList[0].Id;
            update stdCA[0];
            
            List<Assessment_Report__c> reports = new List<Assessment_Report__c>{
                new Assessment_Report__c(Test_Report_Type__c = 'Progress', RecordTypeId = testRTId, Name = 'My Test Report1', Report_Date__c = reportDate, Project__c=projList[0].Id, Instructor__c = conList[0].Id, Report_Type__c = 'DLI',Status__c = 'Scheduled',Language__c = 'Tamil',Student__c = conList[1].Id,Language_Proficiency_Score_Listening__c = '2+',Language_Proficiency_Score_Reading__c='1',Language_Proficiency_Score_Speaking__c='3')
            };
            insert reports;
            
            List<Assessment_Report__c> arRec = [SELECT Id, Status__c FROM Assessment_Report__c WHERE Id IN : reports];
            arRec[0].Status__c = 'Completed';
            //update arRec[0];
            
            Language_Testing__c ltRec = new Language_Testing__c();
            ltRec.Project__c = projList[0].Id;
            ltRec.Testee__c = conList[1].Id;
            ltRec.L_Score__c = '2+';
            ltRec.R_Score__c ='1';
            ltRec.S_Score__c ='3';
            ltRec.Test_Type__c = 'Progress';
            
            List<Language_Testing__c> languageTestingRecs = new List<Language_Testing__c>{ltRec};
            List<Id> studentIds = new List<Id>{conList[1].Id};
            List<Id> projectIds = new List<Id>{projList[0].Id};
        
            List<CreateLanguageTestingRecordFromARFlow.LanguageTestingParams> ltParamsList = new List<CreateLanguageTestingRecordFromARFlow.LanguageTestingParams>();
            CreateLanguageTestingRecordFromARFlow.LanguageTestingParams ltParams = new CreateLanguageTestingRecordFromARFlow.LanguageTestingParams();
            ltParams.languageTestingRecs = languageTestingRecs;
            ltParams.studentIds = studentIds;
            ltParams.projectIds = projectIds;
            ltParamsList.add(ltParams);
            CreateLanguageTestingRecordFromARFlow.invokeSubflow(ltParamsList);
                        
        Test.stopTest();
    }
}