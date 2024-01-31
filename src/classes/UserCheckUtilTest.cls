@isTest
public Class UserCheckUtilTest{
    @testSetup static void setup(){
    
        List<User> getEvents = TestClassUtil.createTestUsers();
        system.debug('getEvents::::'+getEvents);
        
       
    }
    public static testMethod void testUserCheckUtil() {
        Test.startTest();
        String UsrId = UserInfo.getUserId();
        List<User> userList = new List<User>();
        if(UsrId != null) {
        
            for(User usr :[SELECT Id, Name, Instructor_Access__c,Student_Access__c,Partner_Access__c,Client_Access__c FROM User WHERE Id =: UsrId]){
                usr.Instructor_Access__c = true;
                usr.Student_Access__c = true;
                usr.Partner_Access__c = true;
                usr.Client_Access__c = true;
                userList.add(usr);
            }
            if(userList != null && userList.size() > 0)
                update userList;
            
        }
        system.debug('userList:::'+userList);
        
        UserCheckUtil  usercheck = new UserCheckUtil();
        UserCheckUtil.getUserType();
        Test.stopTest();
        
    }
        
    }