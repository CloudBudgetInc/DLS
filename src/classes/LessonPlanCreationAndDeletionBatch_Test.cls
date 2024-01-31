@isTest
public class LessonPlanCreationAndDeletionBatch_Test{
    @testSetup static void setup() {
    
        
        List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();
         List<Lesson_Plan__c> lp = [SELECT Id FROM Lesson_Plan__c];
            System.assertEquals(0, lp.size());
            
        Test.startTest();
            List<Events__c> eveLists = TestClassUtil.createTestEvent();
            List<Events__c> eveList = [SELECT Id, Name, Status__c FROM Events__c WHERE Status__c != 'Scheduled'];
       
            if(eveList.size() > 0) {
                
                eveList[0].Timezone__c = 'America/New_York';
                eveList[0].Date__c = System.today();
                eveList[1].Date__c = System.today();
                eveList[0].Duration__c = 2;
                eveList[0].Status__c = 'Scheduled';
                
                update eveList;                
            }
        Test.stopTest();
        
         lp = [SELECT Id FROM Lesson_Plan__c];
            System.assertEquals(true, lp.size() > 0);
    }
    
    private static testMethod void testMethod1() {
        List<Events__c> eveList = [SELECT Id, Name, Status__c FROM Events__c WHERE Status__c = 'Scheduled'];
       
        if(eveList.size() > 0) {
            
           
            Test.startTest();
                delete eveList;
            Test.stopTest();
            
            
            
        }
    }
}