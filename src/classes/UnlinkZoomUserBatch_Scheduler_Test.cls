@isTest
public class UnlinkZoomUserBatch_Scheduler_Test {
    @testSetup
    static void setupMethod(){
        
        List<Contact_Assignments__c> conAssign = TestClassUtil.createTestContactAssignment();
        Contact c = [SELECT Id, Last_End_Date__c, Zoom_User_Status__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];    
        c.Last_End_Date__c = System.today().addDays(-400);
        c.Zoom_User_Status__c = 'Active';
        update c;      
    }
    
    private static testMethod void zoomUserDeletionTest(){
        
        Contact c = [SELECT Id, Zoom_Id__c,Unlink_Zoom_User__c FROM Contact WHERE email = 'myInsttestemail789@gmail.com'][0];            
        
        Test.startTest();  
            
            Test.setMock(HttpCalloutMock.class, new ZoomUtilMock.ZoomUserExceptionMock());            
            UnlinkZoomUserBatch_Scheduler s=new UnlinkZoomUserBatch_Scheduler();
            s.execute(null) ;      
        Test.stopTest(); 
          
    }
}