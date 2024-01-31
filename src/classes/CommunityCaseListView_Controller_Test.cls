@isTest
public class CommunityCaseListView_Controller_Test {
    @testsetup static void setup() {
        Test.startTest();
        List<Case> caseLst = TestClassUtil.createTestCase();
        List<Contact> conLst = TestClassUtil.createTestContacts();
        Test.stopTest();
    } 
    // if login as Instructor Community User
    private static testMethod void testMethod1() {
        List<Case> caseLst = [SELECT Id,ContactId FROM Case LIMIT 1];
        List<Contact> conLst = [SELECT Id FROM Contact LIMIT 1];
        List<Profile> profileLst = [SELECT Id FROM Profile WHERE Name='Instructor Community'];
        
        if(profileLst.size() > 0 && conLst.size() > 0){
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profileLst[0].Id, country='United States',IsActive =true,
                                 ContactId = conLst[0].Id,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;
            
            caseLst[0].ContactId = conLst[0].Id;
            update caseLst;
            
            system.runas(user){
                CommunityCaseListView_Controller.CaseViewWrapper  caseWrap = CommunityCaseListView_Controller.getInitialCaseRecords();
                System.assertEquals(caseWrap.caseListRecords[0].Id,caseLst[0].Id);
            }
        }
    }
     // if login as Student Community User
      private static testMethod void testMethod2() {
        List<Case> caseLst = [SELECT Id,ContactId FROM Case LIMIT 1];
        List<Contact> conLst = [SELECT Id FROM Contact LIMIT 1];
        List<Profile> profileLst = [SELECT Id FROM Profile WHERE Name='Student Community'];
        
        if(profileLst.size() > 0 && conLst.size() > 0){
            User user = new User(alias = 'test123', email='test123@noemail.com',
                                 emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                                 localesidkey='en_US', profileid = profileLst[0].Id, country='United States',IsActive =true,
                                 ContactId = conLst[0].Id,
                                 timezonesidkey='America/Los_Angeles', username='tester@noemail.com');
            
            insert user;

            caseLst[0].ContactId = conLst[0].Id;
            update caseLst;
            system.runas(user){
              CommunityCaseListView_Controller.CaseViewWrapper  caseWrap = CommunityCaseListView_Controller.getInitialCaseRecords();
              System.assertEquals(caseWrap.caseListRecords[0].Id,caseLst[0].Id);
            }
        }
    }
}