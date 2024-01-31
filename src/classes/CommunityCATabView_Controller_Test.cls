@isTest
private class CommunityCATabView_Controller_Test{

    @testSetup static void setupMethod(){
    
        List<Contact_Assignments__c> contactAssignList = TestClassUtil.createTestContactAssignment();       
    }
    
    // To cover getCARecord() method
    private static testMethod void myTest1(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c LIMIT 1];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        
        Test.startTest();
        
        insert user;
        
        System.runAs(user){
            List<String> CATabList = new List<String>{'Student', 'Instructor', 'Supervisor/LTS'};
            String res = CommunityCATabView_Controller.getCARecord(conAssigns[0].Project__c);
            CommunityCATabView_Controller.ContactAssignmentWrapper w = (CommunityCATabView_Controller.ContactAssignmentWrapper)JSON.deserialize(res, CommunityCATabView_Controller.ContactAssignmentWrapper.class);
            System.assertEquals(CATabList, w.CATabList);
        }
        
        Test.stopTest();
    }
    
    // To cover getCARecord() method
    private static testMethod void myTest2(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c LIMIT 1];
        
        Id cdRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('CD_Projects').getRecordTypeId();
        
        List<AcctSeed__Project__c> project = [SELECT Id, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :conAssigns[0].Project__c];
        project[0].RecordTypeId = cdRTId;
        update project[0];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        
        Test.startTest();
        
        insert user;
        
        System.runAs(user){
        
            CommunityCATabView_Controller.getCARecord(conAssigns[0].Project__c);
        }
        
        Test.stopTest();
    }
    
    // To cover getCARecord() method
    private static testMethod void myTest3(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c LIMIT 1];
        
        Id cdRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Admin_Projects').getRecordTypeId();
        
        List<AcctSeed__Project__c> project = [SELECT Id, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :conAssigns[0].Project__c];
        project[0].RecordTypeId = cdRTId;
        update project[0];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        
        Test.startTest();
        
        insert user;
        
        System.runAs(user){
        
            CommunityCATabView_Controller.getCARecord(conAssigns[0].Project__c);
        }
        
        Test.stopTest();
    }
    
    // To cover getCARecord() method
    private static testMethod void myTest4(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c LIMIT 1];
        
        Id cdRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Translation_Projects').getRecordTypeId();
        
        List<AcctSeed__Project__c> project = [SELECT Id, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :conAssigns[0].Project__c];
        project[0].RecordTypeId = cdRTId;
        update project[0];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        
        Test.startTest();
        
        insert user;
        
        System.runAs(user){
        
            CommunityCATabView_Controller.getCARecord(conAssigns[0].Project__c);
        }
        
        Test.stopTest();
    }
    
    // To cover getCARecord() method
    private static testMethod void myTest5(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c LIMIT 1];
        
        Id cdRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('MTT_Projects').getRecordTypeId();
        
        List<AcctSeed__Project__c> project = [SELECT Id, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :conAssigns[0].Project__c];
        project[0].RecordTypeId = cdRTId;
        project[0].Project_Type__c = 'MTT';
        project[0].TO__c = 'Test';
        update project[0];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        
        Test.startTest();
        
        insert user;
        
        System.runAs(user){
        
            CommunityCATabView_Controller.getCARecord(conAssigns[0].Project__c);
        }
        
        Test.stopTest();
    }
    
    // To cover getCARecordByStatus() method
    private static testMethod void myTest6(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c LIMIT 1];
        
        Id cdRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('MTT_Projects').getRecordTypeId();
        
        List<AcctSeed__Project__c> project = [SELECT Id, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :conAssigns[0].Project__c];
        project[0].RecordTypeId = cdRTId;
        project[0].Project_Type__c = 'MTT';
        project[0].TO__c = 'Test';
        update project[0];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.stopTest();
        
        System.runAs(user){
        
            String res = CommunityCATabView_Controller.getCARecordByStatus(conAssigns[0].Project__c, 'Active');
            List<ContactAssignmentDomain.CAListWrapper> wrap = (List<ContactAssignmentDomain.CAListWrapper>) JSON.deserialize(res, List<ContactAssignmentDomain.CAListWrapper>.class);
            //System.assertEquals(conAssigns[0].Project__c, wrap[0].projectId);
        }
    }
    
    // To cover getCARecordByStatus() method
    private static testMethod void myTest7(){
    
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c FROM Contact_Assignments__c LIMIT 1];
        
        Id cdRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('MTT_Projects').getRecordTypeId();
        
        List<AcctSeed__Project__c> project = [SELECT Id, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :conAssigns[0].Project__c];
        project[0].RecordTypeId = cdRTId;
        project[0].Project_Type__c = 'MTT';
        project[0].TO__c = 'Test';
        update project[0];
        
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        Test.startTest();
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate' AND Email = 'test1@test.com'];
        System.debug('conList==='+conList);
        String contactId;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.stopTest();
        
        System.runAs(user){
        
            String res = CommunityCATabView_Controller.getCARecordByStatus(conAssigns[0].Project__c, null);
            List<ContactAssignmentDomain.CAListWrapper> wrap = (List<ContactAssignmentDomain.CAListWrapper>) JSON.deserialize(res, List<ContactAssignmentDomain.CAListWrapper>.class);
            //System.assertEquals('Active', wrap[0].status);
        }
    }
}