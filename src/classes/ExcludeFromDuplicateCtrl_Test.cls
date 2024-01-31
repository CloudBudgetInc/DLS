@isTest
public class ExcludeFromDuplicateCtrl_Test {
	
    @testSetup 
    static void setupMethod(){
        
        Test.startTest();
            List<Opportunity> oppList = TestClassUtil.createTestOpportunities();   
        	box__FRUP__c fruprec = new box__FRUP__c(box__Record_ID__c=oppList[0].Id,box__Folder_ID__c ='123456');
        	insert fruprec;
        Test.stopTest();        
    }
    
    private static testMethod void myTest1(){
    
        PageReference tpageRef = Page.ExcludeFromDuplicate;
  		Test.setCurrentPage(tpageRef);

        ApexPages.currentPage().getParameters().put('query', '123456');
		ExcludeFromDuplicateCtrl ctrl = new ExcludeFromDuplicateCtrl(); 
        Map<String, String> parentIdWithRelatedSalesforceId = ExcludeFromDuplicateCtrl.getRelatedSalesforceId(new List<String>{'123456'});
		System.assertEquals(parentIdWithRelatedSalesforceId.size(), 1); 
        Map<String, String> baseUrlAndUserDetailsMap = ExcludeFromDuplicateCtrl.getOrgBaseURLAndUserDetailsMap();
    }
    
    private static testMethod void myTest2(){
    
        Test.setMock(HttpCalloutMock.class, new ExcludeFromDuplicateCtrlMock.MockHttpResponseGenerator()); 
        Test.startTest();
		String result = ExcludeFromDuplicateCtrl.excludeFilesFromDuplicates('{"created_at":"2020-03-20T00:00:00.000Z","file_type":"pdf","item_id":"637902071808","item_name":"$10.77-03.17.2020-Uber-Nikita Koves.pdf","item_type":"File","itemname_size":"$10.77-03.17.2020-Uber-Nikita Koves.pdf - 20889.6","owner_login":"lweaver@dlsdc.com","parent_id":"75776863020","size":20889.6}');
        Test.stopTest();
    }
    
    private static testMethod void myTest3(){
    
        Test.setMock(HttpCalloutMock.class, new ExcludeFromDuplicateCtrlMock.MockHttpResponseGenerator1());  
        Test.startTest();
		String result = ExcludeFromDuplicateCtrl.getFileDetails('{"created_at":"2020-03-20T00:00:00.000Z","file_type":"pdf","item_id":"637902071808","item_name":"$10.77-03.17.2020-Uber-Nikita Koves.pdf","item_type":"File","itemname_size":"$10.77-03.17.2020-Uber-Nikita Koves.pdf - 20889.6","owner_login":"lweaver@dlsdc.com","parent_id":"75776863020","size":20889.6}');         
        Test.stopTest();
    }
}