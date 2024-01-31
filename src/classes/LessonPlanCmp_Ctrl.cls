public class LessonPlanCmp_Ctrl {
    @AuraEnabled
    public static String getLessonPlansFromEventId(String eventId){
        lessonPlanAndLessonPlanHours result = new lessonPlanAndLessonPlanHours(); 
        result.errorMsg = '';
        List<Lesson_Plan__c> lessonPlans = LessonPlanService.getLessonPlanWithLessonPlanHours('Event__c = \''+eventId+'\'', ', Instructor__r.Name,RecordType.DeveloperName');
        if(lessonPlans != null && lessonPlans.size() > 0){
            result.lessonPlan = lessonPlans[0];
            
            Map<String, List<String>> fieldAPIWithMultiPicklistValuesMap = new Map<String, List<String>>();  
            fieldAPIWithMultiPicklistValuesMap.put('Skill_Focus__c', new List<String>());
            fieldAPIWithMultiPicklistValuesMap.put('Activities__c', new List<String>());
            
            Map<String, List<ListViewController.PicklistWrap>> fieldAPIWithPicklistValuesMap = new Map<String, List<ListViewController.PicklistWrap>>(); 
            ListViewController.PicklistWrap pickListVal = new ListViewController.PicklistWrap();
            pickListVal.label = '--Select--';
            pickListVal.value = '';        
            fieldAPIWithPicklistValuesMap.put('Assessment_Type__c', new List<ListViewController.PicklistWrap>());
            fieldAPIWithPicklistValuesMap.get('Assessment_Type__c').add(pickListVal);
            
            for(ListViewController.PicklistWrap picklist : ListViewController.getPickListValues('Lesson_Plan_Hour__c','Skill_Focus__c')){
                fieldAPIWithMultiPicklistValuesMap.get('Skill_Focus__c').add(picklist.value);            
            }
            for(ListViewController.PicklistWrap picklist : ListViewController.getPickListValues('Lesson_Plan_Hour__c','Activities__c')){
                fieldAPIWithMultiPicklistValuesMap.get('Activities__c').add(picklist.value);            
            }
            for(ListViewController.PicklistWrap picklist : ListViewController.getPickListValues('Lesson_Plan__c','Assessment_Type__c')){
                fieldAPIWithPicklistValuesMap.get('Assessment_Type__c').add(picklist);            
            }
            
            result.fieldAPIWithPicklistValuesMap = fieldAPIWithPicklistValuesMap;
            result.fieldAPIWithMultiPicklistValuesMap = fieldAPIWithMultiPicklistValuesMap;
        }else{
            result.errorMsg = 'Event doesn\'t have Lesson Plan.';
        }
        
        return JSON.serialize(result);
    }    
    
    @AuraEnabled
    public static String saveLessonPlansAndLessonPlanHrs(String lessonPlan, String lessonPlanHrs, String lessonPlanHrsToDelete){
        String result = 'success';
        update (Lesson_Plan__c) JSON.deserialize(lessonPlan, Lesson_Plan__c.class);
        upsert (List<Lesson_Plan_Hour__c>) JSON.deserialize(lessonPlanHrs, List<Lesson_Plan_Hour__c>.class);
        delete (List<Lesson_Plan_Hour__c>) JSON.deserialize(lessonPlanHrsToDelete, List<Lesson_Plan_Hour__c>.class);
        return result;
    }
    
    @AuraEnabled
    public static String getPreviousDayLessonPlanAndLessonPlanHrs(String lessonPlanStr){
        
        lessonPlanAndLessonPlanHoursCopy lessonPlanAndLessonPlanHoursCopyObj = new lessonPlanAndLessonPlanHoursCopy();
        
        Lesson_Plan__c lessonPlan = (Lesson_Plan__c) JSON.deserialize(lessonPlanStr, Lesson_Plan__c.class);
        Map<String, Lesson_Plan_Hour__c> lessonPlanHrNameWithRecMap = new Map<String, Lesson_Plan_Hour__c>();
        Map<String, Lesson_Plan_Hour__c> previousLessonPlanHrNameWithRecMap = new Map<String, Lesson_Plan_Hour__c>();
        for(Lesson_Plan_Hour__c lessonPlanHr : lessonPlan.Lesson_Plan_Hours__r){
            lessonPlanHrNameWithRecMap.put(lessonPlanHr.Name, lessonPlanHr);
        }
        Lesson_Plan__c previousLessonPlan = LessonPlanService.getPreviousLessonPlanWithLessonPlanHoursFromDateAndProjId(lessonPlan.Date__c, lessonPlan.Project__c,', Instructor__r.Name,RecordType.DeveloperName');
        for(Lesson_Plan_Hour__c lessonPlanHr : previousLessonPlan.Lesson_Plan_Hours__r){
            previousLessonPlanHrNameWithRecMap.put(lessonPlanHr.Name, lessonPlanHr);
        }
        if(previousLessonPlan != null){
            Lesson_Plan__c copyLessonPlan = lessonPlan.clone(true, true, false, false);
            copyLessonPlan.Assessment_Type__c = previousLessonPlan.Assessment_Type__c;
            copyLessonPlan.Assessment__c = previousLessonPlan.Assessment__c;
            copyLessonPlan.Homework__c = previousLessonPlan.Homework__c;
            copyLessonPlan.Materials__c = previousLessonPlan.Materials__c;
            copyLessonPlan.Objectives__c = previousLessonPlan.Objectives__c;
            copyLessonPlan.Topics__c = previousLessonPlan.Topics__c;            
            lessonPlanAndLessonPlanHoursCopyObj.lessonPlan = copyLessonPlan;
            List<Lesson_Plan_Hour__c> cpylessonPlanHours = new List<Lesson_Plan_Hour__c>();
            for(String lessonPlanHrName : previousLessonPlanHrNameWithRecMap.keySet()){
                Lesson_Plan_Hour__c lessonPlanHr = new Lesson_Plan_Hour__c();  
                Lesson_Plan_Hour__c preLessonPlanHr = previousLessonPlanHrNameWithRecMap.get(lessonPlanHrName);
                if(lessonPlanHrNameWithRecMap.containsKey(lessonPlanHrName)){
                    lessonPlanHr = lessonPlanHrNameWithRecMap.get(lessonPlanHrName).clone(true, true, false, false);
                    lessonPlanHr.Activities__c = preLessonPlanHr.Activities__c;
                    lessonPlanHr.Activity_Details__c = preLessonPlanHr.Activity_Details__c;
                    lessonPlanHr.Skill_Focus__c = preLessonPlanHr.Skill_Focus__c;                    
                }else{
                    lessonPlanHr = previousLessonPlanHrNameWithRecMap.get(lessonPlanHrName).clone(false, false, false, false);
                    lessonPlanHr.Lesson_Plan__c = copyLessonPlan.Id;
                }    
                cpylessonPlanHours.add(lessonPlanHr);                
            }
            lessonPlanAndLessonPlanHoursCopyObj.lessonPlanHours = cpylessonPlanHours;
        }
        
       return JSON.serialize(lessonPlanAndLessonPlanHoursCopyObj);
    }
    
    @AuraEnabled
    public static List<Lesson_plan__c> getLessonPlanList(String projectId, String communityName, Map<String, Date> filterDate){
        String filterStr = 'Project__c = \''+projectId+'\'';
        //Modified By Dhinesh - 10/10/2023 - W-007894 - Request to Add Date Filters to the Lesson Plan Section in DLS Online
        if(filterDate != null){
            if(filterDate.get('from') != null)
            	filterStr += ' AND Date__c >= '+ String.valueOf(filterDate.get('from')).removeEnd(' 00:00:00');
            if(filterDate.get('to') != null)
                filterStr += ' AND Date__c <= '+ String.valueOf(filterDate.get('to')).removeEnd(' 00:00:00');
        }
        
        if(communityName == 'student')
            filterStr +=' AND Share_with_my_student_s__c = true';
        
        return LessonPlanService.getLessonPlanWithLessonPlanHours(filterStr, ', Instructor__r.Name,RecordType.DeveloperName');
    }
    
    public class lessonPlanAndLessonPlanHours{
        @auraEnabled public Lesson_Plan__c lessonPlan;
        @auraEnabled public Map<String, List<String>> fieldAPIWithMultiPicklistValuesMap;
        @auraEnabled public Map<String, List<ListViewController.PicklistWrap>> fieldAPIWithPicklistValuesMap;
        @auraEnabled public String errorMsg;
    }

    public class lessonPlanAndLessonPlanHoursCopy{
        @auraEnabled public Lesson_Plan__c lessonPlan;
        @auraEnabled public List<Lesson_Plan_Hour__c> lessonPlanHours;
    }    
}