@isTest
public class MoodleLoginCtrl_Test {
     @testSetup static void setupMethod(){
        
        List<Contact> contacts = TestClassUtil.createTestContacts();
     }
    
    private static testMethod void moodleLoginTest(){
    
        Id p = [SELECT Id FROM Profile WHERE Name='Instructor Community'].Id;
        
        List<Contact> conList = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Candidate'];
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p, country='United States',IsActive =true,
                ContactId = conList[0].Id, 
                timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
       
        insert user;
        
        Test.startTest();
            System.runAs(user){
                MoodleLoginCtrl.getLoginDetialsForD2L();
                MoodleLoginCtrl.getCommunityUrl();
            }
        Test.stopTest();
    }
    
    private static testMethod void moodleLoginTest2(){
        
        Id p1 = [SELECT Id FROM Profile WHERE Name='Student Community'].Id;
        
        List<Contact> conList1 = [SELECT Id FROM Contact WHERE Email != NULL AND RecordType.DeveloperName = 'Student'];
        
        User user1 = new User(alias = 'test234', email='test123456@noemail.com',
                emailencodingkey='UTF-8', lastname='Student Testing', languagelocalekey='en_US',
                localesidkey='en_US', profileid = p1, country='United States',IsActive =true,
                ContactId = conList1[0].Id, 
                timezonesidkey='America/Los_Angeles', username='tester123@noemail.com');
       
        insert user1;
        
        System.runAs(user1){
            MoodleLoginCtrl.getCommunityUrl();
        }
        
    }
}