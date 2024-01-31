@isTest
private class LessonPlanCmp_Ctrl_Test{

    @testSetup static void mySetupMethod(){
        
        List<Contact_Assignments__c> conAssigns = TestClassUtil.createTestContactAssignment();            
        Test.startTest();
            List<Events__c> eveLists = TestClassUtil.createTestEvent();
            List<Events__c> eveList = [SELECT Id, Name, Status__c FROM Events__c WHERE Status__c != 'Scheduled'];
            if(eveList.size() > 0) {
                
                eveList[0].Timezone__c = 'America/New_York';
                eveList[0].Date__c = System.today();
                eveList[1].Date__c = System.today().addDays(-2);
                eveList[0].Duration__c = 2;
                eveList[1].Duration__c = 2;
                eveList[0].Status__c = 'Scheduled';
                
                update eveList;                
            }
        Test.stopTest();
    }
    
    private static testMethod void testMethod1() {
    
        List<Events__c> eveList = [SELECT Id, Name, Status__c FROM Events__c WHERE Status__c = 'Scheduled' AND Date__c = :System.today() AND Duration__c = 2];
       
        if(eveList.size() > 0) {
            LessonPlanCmp_Ctrl.getLessonPlansFromEventId(eveList[0].Id);
        }
    }
    private static testMethod void testMethod2() {
    
        List<Events__c> eveList = [SELECT Id, Name, Status__c FROM Events__c WHERE Status__c = 'Scheduled' AND Date__c = :System.today() AND Duration__c = 2];
       
        if(eveList.size() > 0) {
             
            String result = LessonPlanCmp_Ctrl.getLessonPlansFromEventId(eveList[0].Id);
            LessonPlanCmp_Ctrl.lessonPlanAndLessonPlanHours wrap = (LessonPlanCmp_Ctrl.lessonPlanAndLessonPlanHours)JSON.deserialize(result, LessonPlanCmp_Ctrl.lessonPlanAndLessonPlanHours.class);
            Lesson_Plan__c lessonPlan = wrap.lessonPlan;
            List<Lesson_Plan_Hour__c> lpHours = [SELECT Id FROM Lesson_Plan_Hour__c WHERE Lesson_Plan__c =: lessonPlan.Id];
            LessonPlanCmp_Ctrl.saveLessonPlansAndLessonPlanHrs(JSON.serialize(lessonPlan), JSON.serialize(lpHours), JSON.serialize(lpHours));
        }
    }
    private static testMethod void testMethod3() {
    
        List<Events__c> eveList = [SELECT Id, Name, Status__c FROM Events__c WHERE Status__c = 'Scheduled' AND Date__c = :System.today() AND Duration__c = 2];
       
        if(eveList.size() > 0) {
             
            String result = LessonPlanCmp_Ctrl.getLessonPlansFromEventId(eveList[0].Id);
            LessonPlanCmp_Ctrl.lessonPlanAndLessonPlanHours wrap = (LessonPlanCmp_Ctrl.lessonPlanAndLessonPlanHours)JSON.deserialize(result, LessonPlanCmp_Ctrl.lessonPlanAndLessonPlanHours.class);
            Lesson_Plan__c lessonPlan = wrap.lessonPlan;
            LessonPlanCmp_Ctrl.getPreviousDayLessonPlanAndLessonPlanHrs(JSON.serialize(lessonPlan));
        }
    }    
    private static testMethod void testMethod4() {
    
        List<Events__c> eveList = [SELECT Id, Name, Status__c FROM Events__c WHERE Status__c = 'Scheduled' AND Date__c = :System.today() AND Duration__c = 2];
       
        if(eveList.size() > 0) {
             
            String result = LessonPlanCmp_Ctrl.getLessonPlansFromEventId(eveList[0].Id);
            LessonPlanCmp_Ctrl.lessonPlanAndLessonPlanHours wrap = (LessonPlanCmp_Ctrl.lessonPlanAndLessonPlanHours)JSON.deserialize(result, LessonPlanCmp_Ctrl.lessonPlanAndLessonPlanHours.class);
            Lesson_Plan__c lessonPlan = wrap.lessonPlan;
            LessonPlanCmp_Ctrl.getLessonPlanList(lessonPlan.Project__c, 'Student',new Map<String,Date>{'from'=>system.today(),'to'=>system.today().addDays(4)});
        }
    }
}