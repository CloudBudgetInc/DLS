/**
 * @description       : 
 * @author            : Dhinesh Kumar
 * @group             : 
 * @last modified on  : 03/14/2022
 * @last modified by  : Dhinesh Kumar
**/
@isTest(SeeAllData=True)
private class BookmarkHandler_Test {
    
    // For Getting UserName
    private static testMethod void testMethod1() {
        List<User> usr = (List<User>) JSON.deserialize(BookmarkHandler.getUserName(),List<User>.class);
        if(usr != null && usr.size() > 0) {
            System.assertEquals(userinfo.getName(), usr[0].Name);
        }
    }
    
    // For Quering BookMark Object based on Contact 
    private static testMethod void testMethod2() {
        List<Contact> conList = new List<Contact> {
            new Contact(LastName = 'Test Contact', EMail = 'contact@test.com')
        };
        insert conList;
        
        List<Bookmark__c> bmList = new List<Bookmark__c> {
            new Bookmark__c(Contact__c = conList[0].Id, User__c = userinfo.getuserid())
        };
        insert bmList;
        //BookmarkHandler.getBookMark(userinfo.getuserid()); // To Cover Catch block
        Bookmark__c  bm = BookmarkHandler.getBookMark(conList[0].Id,userinfo.getuserid());
        if(bm != null) {
            System.assertEquals(bmList[0].Id, bm.Id);
        }
        BookmarkHandler.getBookMark(conList[0].Id,null);
        BookmarkHandler.getLookupRecords('Test','User','Name','',new List<String>{});
        BookmarkHandler.getPicklistValues();
    }
    
    // For Inserting/Updating BookMark Object 
    private static testMethod void testMethod3() {
        List<Contact> conList = new List<Contact> {
            new Contact(LastName = 'Test Contact 1', EMail = 'contact1@test.com'),
            new Contact(LastName = 'Test Contact 2', EMail = 'contact2@test.com')
        };
        insert conList;
        
        List<Profile> profile = [SELECT Id,Name FROM Profile WHERE Name = 'System Administrator'];
        
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        String uniqueName = orgId + dateString;
        
        User tuser = new User(  firstname = 'Admin',
                            lastName = 'User',
                            email = uniqueName + '@test' + orgId + '.org',
                            Username = uniqueName + '@test' + orgId + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = profile[0].Id);
        insert tuser;
        
        List<Bookmark__c> bmList = new List<Bookmark__c> {
            new Bookmark__c(Contact__c = conList[1].Id,User__c = tuser.Id)
        };
        
        BookmarkHandler.upsertBookMark(bmList,conList[0].Id,'Please view the contact record that I have bookmarked for you',true,new List<String>{bmList[0].User__c});
       
    }
}