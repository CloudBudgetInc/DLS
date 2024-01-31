public class LessonPlanService {
    public static List<Lesson_Plan__c> getLessonPlanWithLessonPlanHours(String filterQuery, String parentFields){
         
        Lesson_Plan__c lessonPlan = new Lesson_Plan__c();
        String qryStr = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Lesson_Plan__c')+  (String.isNotBlank(parentFields) ? parentFields : '') +
                                     ' ,(SELECT '+ SObjectQueryService.getSObjectFieldsBySObjectNameExceptBlob('Lesson_Plan_Hour__c')+
                                     ' FROM Lesson_Plan_Hours__r  ORDER BY Name ASC)'+
                                     ' FROM Lesson_Plan__c';
                                    
        if(String.isNotBlank(filterQuery)) {
             qryStr += ' WHERE '+filterQuery;
        }                        

        return  database.query(qryStr);    
    }
    
    public static List<Lesson_Plan__c> getweeklyLessonPlansWithLessonPlanHours(Date weekStart, Date weekEnd, String filterQuery, String parentFields){
         
        String qryStr = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Lesson_Plan__c')+  (String.isNotBlank(parentFields) ? parentFields : '') +
                                     ' ,(SELECT '+ SObjectQueryService.getSObjectFieldsBySObjectNameExceptBlob('Lesson_Plan_Hour__c')+
                                     ' FROM Lesson_Plan_Hours__r ORDER BY Name ASC)'+
                                     ' FROM Lesson_Plan__c';
         
        qryStr += ' WHERE Date__c >= :weekStart AND Date__c <= :weekEnd';                          
        
        if(String.isNotBlank(filterQuery)) {
             qryStr += ' AND '+filterQuery;
        }
        
        qryStr += ' ORDER BY Date__c ASC';
        
        return database.query(qryStr);    
    }
    
    public static Lesson_Plan__c getPreviousLessonPlanWithLessonPlanHoursFromDateAndProjId(Date lessonPlanDate, String projectId, String parentFields){
         
        Lesson_Plan__c lessonPlan = new Lesson_Plan__c();
        String qryStr = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Lesson_Plan__c')+  (String.isNotBlank(parentFields) ? parentFields : '') +
                                     ' ,(SELECT '+ SObjectQueryService.getSObjectFieldsBySObjectNameExceptBlob('Lesson_Plan_Hour__c')+
                                     ' FROM Lesson_Plan_Hours__r  ORDER BY Name ASC)'+
                                     ' FROM Lesson_Plan__c';
                                    
        qryStr += ' WHERE Date__c < :lessonPlanDate AND Event__c != null AND Date__c != null';
        
        if(String.isNotBlank(projectId)){
            qryStr += ' AND Project__c = :projectId';
        }
        
        qryStr +=  ' ORDER BY Date__c DESC LIMIT 1';
              
        List<Lesson_Plan__c> lessonPlanList = database.query(qryStr);
        if(lessonPlanList.size() > 0){
            lessonPlan = lessonPlanList[0];
        }     

        return lessonPlan;    
    }
}