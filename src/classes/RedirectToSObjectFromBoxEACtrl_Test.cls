@isTest
public class RedirectToSObjectFromBoxEACtrl_Test {
 	@testSetup 
    static void setupMethod(){
        
        Test.startTest();
            List<Opportunity> oppList = TestClassUtil.createTestOpportunities();   
        	box__FRUP__c fruprec = new box__FRUP__c(box__Record_ID__c=oppList[0].Id,box__Folder_ID__c ='123456');
        	insert fruprec;
        Test.stopTest();        
    }
    
    
    private static testMethod void myTest1(){
    
        PageReference tpageRef = Page.RedirectToSObjectFromBoxEA;
  		Test.setCurrentPage(tpageRef);

        ApexPages.currentPage().getParameters().put('parentId', '123456');
		RedirectToSObjectFromBoxEACtrl ctrl = new RedirectToSObjectFromBoxEACtrl(); 
        List<Opportunity> oppList = [SELECT Id FROM Opportunity];
        System.assertEquals(oppList[0].Id, ctrl.sObjectId);
        System.assertEquals(false, ctrl.showErrorMessage);
        
        ApexPages.currentPage().getParameters().put('parentId', '12345678');
		ctrl = new RedirectToSObjectFromBoxEACtrl();
        System.assertEquals(true, ctrl.showErrorMessage);
    }
}