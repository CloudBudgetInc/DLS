@isTest
private class InstructorMyProfileController_Test{

    @testSetup static void setupMethod(){
    
        List<Known_Language__c> knowledges = TestClassUtil.createTestKnownLanguages();
        List<Skill__c> skills = TestClassUtil.createTestSkill();
        List<Experience__c> experiences = TestClassUtil.createTestExperience();
    }
    
    // To cover getProfileInformation() method
    private static testMethod void myTest1(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<Known_Language__c> langs  = [SELECT Id, Contact__c FROM Known_Language__c];

        
        List<Skill__c> skills = [SELECT Id, Contact__c FROM Skill__c];
        skills[0].Contact__c = conList[0].Id;
        update skills[0];
        
        List<Experience__c> exp = [SELECT Id, Contact__c FROM Experience__c WHERE RecordType.DeveloperName = 'Professional_Work_Experience'];
        exp[0].Contact__c = conList[0].Id;
        exp[0].End_Date__c = null;
        update exp[0];
        
        System.runAs(user){
        
            String res = InstructorMyProfileController.getProfileInformation();
            InstructorMyProfileController.MyProfileWrapper info =  (InstructorMyProfileController.MyProfileWrapper)JSON.deserialize(res, InstructorMyProfileController.MyProfileWrapper.class);
            ContactDomain.ContactInfo conInfo = info.contactRec;
            System.assertEquals(conList[0].Id, conInfo.contactId);
        }
        
        InstructorMyProfileController.getProfileInformation();
    }
    
    // To cover getProfileInformation() method
    private static testMethod void myTest2(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        System.runAs(user){
        
            String res = InstructorMyProfileController.getProfileInformation();
            InstructorMyProfileController.MyProfileWrapper info =  (InstructorMyProfileController.MyProfileWrapper)JSON.deserialize(res, InstructorMyProfileController.MyProfileWrapper.class);
            ContactDomain.ContactInfo conInfo = info.contactRec;
            System.assertEquals(conList[0].Id, conInfo.contactId);
        }
        
        InstructorMyProfileController.getProfileInformation();
    }
    
    // To cover updateStatus() method
    private static testMethod void myTest3(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<Experience__c> exp = [SELECT Id, Contact__c FROM Experience__c WHERE RecordType.DeveloperName = 'Professional_Work_Experience'];
        exp[0].Contact__c = conList[0].Id;
        exp[0].End_Date__c = null;
        update exp[0];
        
        System.runAs(user){
        
            InstructorMyProfileController.updateStatus(exp[0].Id, 'editicon');
            
        }
    }
    
    // To cover updateStatus() method
    private static testMethod void myTest4(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        List<Experience__c> exp = [SELECT Id, Contact__c FROM Experience__c WHERE RecordType.DeveloperName = 'Professional_Work_Experience'];
        exp[0].Contact__c = conList[0].Id;
        exp[0].End_Date__c = null;
        update exp[0];
        
        System.runAs(user){
        
            InstructorMyProfileController.updateStatus(exp[0].Id, 'deleteicon');
            
        }
    }
    
    // To cover updateContactRecord() method
    private static testMethod void myTest5(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id,LastName FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        System.runAs(user){
            
            ContactDomain.ContactInfo conRecord = new ContactDomain.ContactInfo();
            conRecord.contactId = conList[0].Id;
            conRecord.lastName = conList[0].LastName;
            String res = InstructorMyProfileController.updateContactRecord(JSON.serialize(conRecord));
            System.assertEquals(res, '');
        }
    }
    // to get lookup records and upsert Skill
    private static testMethod void myTest6(){
        List<Skill__c> skillList = [SELECT Id FROM SKILL__c];
        
        Skill__c skillRec = new Skill__c(Skill__c = 'Language Training');
        InstructorMyProfileController.upsertSkill(JSON.serialize(new List<Skill__c>{skillRec}));
        InstructorMyProfileController.getLookupRecords('english','Language__c','Name','',new List<String>());
        
        List<Skill__c> skillRecList = [SELECT Id FROM SKILL__c];
        System.assertEquals(skillList.size()+1,skillRecList.size());           
    }
}