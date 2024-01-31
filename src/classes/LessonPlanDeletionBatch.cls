public class LessonPlanDeletionBatch implements Database.Batchable<sObject>, Database.Stateful{
    
    public Set<Id> lessonPlanIds;
    
    public LessonPlanDeletionBatch(Set<Id> lessonPlanIds){
        
        this.lessonPlanIds = lessonPlanIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
          
        return Database.getQueryLocator('SELECT Id FROM Lesson_Plan__c WHERE Id IN :lessonPlanIds');
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> lessonPlanList){
        delete  lessonPlanList;       
    }
    
    public void finish(Database.BatchableContext BC){
    }
}