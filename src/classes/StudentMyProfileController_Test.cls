@isTest
private class StudentMyProfileController_Test{

    @testSetup static void setupMethod(){
    
        List<Contact> contacts = TestClassUtil.createTestContacts();
    }
    
    // To cover getProfileInformation() method
    private static testMethod void myTest1(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
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
        
            String res = StudentMyProfileController.getProfileInformation();
            ContactDomain.ContactInfo info =  (ContactDomain.ContactInfo)JSON.deserialize(res, ContactDomain.ContactInfo.class);
            System.assertEquals(conList[0].Id, info.contactId);
        }
        
        //StudentMyProfileController.getProfileInformation();
    }
    
    // To cover updateContactRecord() method
    private static testMethod void myTest2(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        System.debug('p=========='+p);
        
        List<Contact> conList = [SELECT Id, LastName, Email FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        System.debug('conList==='+conList);
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id,
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        ContactDomain.ContactInfo c = new ContactDomain.ContactInfo();
        c.contactId = conList[0].Id;
        c.lastName = conList[0].LastName;
        
        System.runAs(user){
            
            StudentMyProfileController.updateContactRecord(JSON.serialize(c));
        }        
    }
}