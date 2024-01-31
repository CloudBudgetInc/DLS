@isTest
private class DeleteEntitySubscription_Schedule_Test{

    private static testMethod void myTest(){
    
        Id stdConRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        
        Account a = new Account(Name = 'Test Account');
        insert a;
        
        Contact c = new Contact(AccountId= a.Id, LastName = 'My New Contact', Email = 'mynewfeedcon@gmail.com', RecordTypeId = stdConRTId);
        insert c;
        
        Id p = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
        emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
        localesidkey='en_US', profileId = p, country='United States',IsActive =true,
        ContactId = c.Id, 
        timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
        
        Test.startTest();
        
            insert user;
                                    
            System.runAs(user){
                
                agf__ADM_Work__c work = new agf__ADM_Work__c(agf__Closed_On__c = System.now(), agf__Status__c = 'Closed');
                insert work;
                         
                Network networkRec = [SELECT Id from Network WHERE Name = 'Student'];
   
                EntitySubscription es = new EntitySubscription(NetworkId = networkRec.Id, ParentId = work.Id, SubscriberId = Userinfo.getUserID());
                insert es;                
            }
            
            // Schedule coverage
            String CRON_EXP = '0 0 14 * * ?';
            DeleteEntitySubscription_Schedule sch = new DeleteEntitySubscription_Schedule();
            system.schedule('Delete Entity Subscription Schedule', CRON_EXP, sch);
                
        Test.stopTest();
    }
}