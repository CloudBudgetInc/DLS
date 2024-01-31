/*******************************************************************************
- class to send remainder for submitting Performance feedback
- Created by Dhinesh - W-006625
- Scheduled on Daily basis
*******************************************************************************/
public class FeedbackRemainderMail_Scheduler implements Schedulable, Database.AllowsCallouts, Database.Batchable<Form_Response__c> {
  
    public void execute(SchedulableContext SC) {
        Database.executebatch(new FeedbackRemainderMail_Scheduler());
    }
   
    public Iterable<Form_Response__c> start(Database.Batchablecontext BC){
        
        return [SELECT Id, Feedback_From__c, Feedback_About__c, Form_Feedback_Type__c FROM Form_Response__c WHERE Status__c NOT IN ('Submitted','Declined') AND Is_Due_Date_Reminder__c = true AND Form_Feedback_Type__c != 'Action Needed'];    
    }

    public void execute(Database.BatchableContext BC, List<Form_Response__c> formResponses){  
    
         FormResponseTriggerHandler.sendMailNotification(JSON.serialize(formResponses));
    }

    public void finish(Database.BatchableContext info){
        
    }

}