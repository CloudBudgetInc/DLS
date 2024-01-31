@isTest
private class CommunityCompVisibilityUtil_Ctrl_Test{
    
    @testSetup static void setupMethod(){
        
        List<Contact_Assignments__c> caList = TestClassUtil.createTestContactAssignment();
    }
    
     static testmethod void test1() {
    
        List<Community_Component_Visibility__mdt> cmpVisibleList = [SELECT Id,DeveloperName,Community_Type__c,Section_Name__c,Tab_Name__c,Visible__c FROM Community_Component_Visibility__mdt];
        system.debug('::::::::cmpVisibleList:::'+cmpVisibleList);
        
        Id p = [SELECT Id FROM Profile WHERE Name = 'Client Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id,Name,RecordType.DeveloperName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'USG_Client' LIMIT 1];
        
        User user = new User(alias = 'client12', email='client123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='client@noemail.com');
       
        Test.startTest();
        
        insert user;
        
        Id projDLIWRT = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('DLI_W_LT_Projects').getRecordTypeId();
        
        List<AcctSeed__Project__c> proj = [SELECT Id,Name,RecordTypeId,RecordType.DeveloperName FROM AcctSeed__Project__c LIMIT 1];
        
        proj[0].RecordTypeId = projDLIWRT;
        update proj;
              
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Candidate_Name__c,Candidate_Name__r.Name,Candidate_Name__r.RecordType.DeveloperName,Project__c,RecordType.DeveloperName,Project__r.RecordType.DeveloperName FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Client_Partner' LIMIT 1];
        
        conAssigns[0].Candidate_Name__c = conList[0].Id;
        conAssigns[0].Project__c = proj[0].Id;
        update conAssigns;
        
        System.runAs(user){
            Map<String, Map<String, Boolean>> tabNameWithSectionVisibiltyMap = CommunityComponentVisibilityUtil_Ctrl.getComponentVisibilities();
        }
        
        Test.stopTest();
    }

}