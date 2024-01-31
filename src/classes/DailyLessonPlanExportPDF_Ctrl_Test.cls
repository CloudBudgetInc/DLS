@isTest
public class DailyLessonPlanExportPDF_Ctrl_Test{
    @testSetup static void setup() {
    
        List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();
         
        Test.startTest();
            List<Events__c> eveLists = TestClassUtil.createTestEvent();            
        Test.stopTest();        
    }
    
    private static testMethod void testMethod1() {
        List<Events__c> eveList = [SELECT Id, Name, Status__c FROM Events__c WHERE Status__c != 'Scheduled'];
        
        Test.startTest();
            if(eveList.size() > 0) {
                
                eveList[0].Timezone__c = 'America/New_York';
                eveList[0].Date__c = System.today();
                eveList[1].Date__c = System.today();
                eveList[0].Duration__c = 2;
                eveList[0].Status__c = 'Scheduled';
                
                update eveList;                
            }
        Test.stopTest();
        List<Lesson_Plan__c> lp = [SELECT Id, Status__c FROM Lesson_Plan__c WHERE Event__c = :eveList[0].Id];
        lp[0].Status__c = 'Completed';
        update lp;
        ApexPages.currentPage().getParameters().put('lessonPlanId', String.valueOf(lp[0].Id));
        ApexPages.currentPage().getParameters().put('communityname', 'instructor');
        DailyLessonPlanExportPDF_Ctrl lpExport = new DailyLessonPlanExportPDF_Ctrl();
    }
    
    private static testMethod void testMethod2() {
        List<Lesson_Plan__c> lp = [SELECT Id, Status__c FROM Lesson_Plan__c];
        lp[0].Status__c = 'Completed';
        lp[0].Share_with_my_student_s__c = true;
        update lp;
        ApexPages.currentPage().getParameters().put('lessonPlanId', String.valueOf(lp[0].Id));
        ApexPages.currentPage().getParameters().put('communityname', 'student');
        DailyLessonPlanExportPDF_Ctrl lpExport = new DailyLessonPlanExportPDF_Ctrl();
    }
}