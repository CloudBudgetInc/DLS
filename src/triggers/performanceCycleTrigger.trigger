trigger performanceCycleTrigger on Performance_Cycle__c (after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        Set<Id> performanceCycleIds = new Set<Id>();
        
        for(Performance_Cycle__c pc : Trigger.new){
            if(pc.Status__c == 'Deployed' && pc.Status__c != Trigger.oldMap.get(pc.Id).Status__c){
                performanceCycleIds.add(pc.Id);
            }
        }
        
        if(performanceCycleIds.size() > 0){
            
            FormResponseTriggerHandler.sendMailNotificationFuture(JSON.serialize([SELECT Id, Form_Feedback_Type__c, Feedback_From__c, Feedback_About__c FROM Form_Response__c WHERE Performance_Cycle__c IN :performanceCycleIds AND Form_Feedback_Type__c != 'Action Needed']));
        }
    }
}