@isTest
public Class Test_Language_Testing_CreatePge_Ctrl{
    @testSetup static void setup(){
        Test.startTest();
        List<Contact_Assignments__c> contactAssignmentList = TestClassUtil.createTestContactAssignment();
        Test.stopTest();
        List<Language_Testing__c> langTestList = TestClassUtil.createTestLanguageTesting();
        
    }
    public static testMethod void testMethod1(){
         
        Test.startTest();

        List<Language_Testing__c> langTestList = [SELECT Id, Name, Project_Task__c, Testee__c, S_Goal__c, L_Goal__c, R_Goal__c, W_Goal__c,Target_Language__c FROM Language_Testing__c LIMIT 2];
        List<Opportunity> oppRec = [SELECT Id,Name,AccountId,Account.Name FROM Opportunity LIMIT 2];
        List<Contact_Assignments__c> contactArgList = [SELECT Id,Name,Opportunity_Name__c,Candidate_Name__c,Candidate_Name__r.Name,RecordType.DeveloperName FROM Contact_Assignments__c WHERE RecordType.DeveloperName IN ('Instructor','Staff','Student')];
                
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');

        String parent = contactArgList[0].Candidate_Name__c;
        
        Attachment attachment = new Attachment();
        attachment.Name = 'Signature';
        attachment.body = bodyBlob;
        attachment.parentId = parent;
        attachment.ContentType = '.txt';
        insert attachment;
        
        String exmainerId;
        
        for(contact_Assignments__c conass : contactArgList) {
            if(conass.RecordType.DeveloperName == 'Staff')
                exmainerId = conass.Candidate_Name__c;
        }
        
        langTestList[0].Examiner__c = exmainerId;
        langTestList[0].Opportunity__c = oppRec[0].Id;
        
        update langTestList[0];
        
        String languageTestingId = langTestList[0].Id;
        
        Language_Testing_CreatePge_Ctrl.getExistingLanguageTesting(languageTestingId);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(langTestList[0]);
        Language_Testing_CreatePge_Ctrl inst = new Language_Testing_CreatePge_Ctrl(sc);
        
        Language_Testing__c langTest1 = new Language_Testing__c(S_Goal__c = '2+', Opportunity__c = oppRec[0].Id);
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(langTest1);
        Language_Testing_CreatePge_Ctrl inst1 = new Language_Testing_CreatePge_Ctrl(sc1);
        
        Language_Testing_CreatePge_Ctrl.getRelatedInfomation(oppRec[0].Id);
        
        String languageTestString = JSON.serialize(langTestList);
        Language_Testing_CreatePge_Ctrl.LanguageTestCreateOrUpdate(languageTestString);   
        
        Language_Testing_CreatePge_Ctrl.getTesteeDetails(oppRec[0].Id);
        
        Test.stopTest();
      
    }
    
    public static testMethod void testMethod2(){
        Test.startTest();
        Language_Testing_CreatePge_Ctrl.getSelectOptionValues(); 
        Language_Testing_CreatePge_Ctrl.getLookupRecords('Account','Test','');
        Language_Testing_CreatePge_Ctrl.getLookupRecords('Contact','Test','RecordType.DeveloperName=\'Candidate\'');
        Language_Testing_CreatePge_Ctrl.getLookupRecords('Contact','','RecordType.DeveloperName=\'Candidate\'');
        Test.stopTest();
    }
}