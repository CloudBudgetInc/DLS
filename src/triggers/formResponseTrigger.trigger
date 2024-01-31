trigger formResponseTrigger on Form_Response__c (after insert, after update) {
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        FormResponseTriggerHandler.createSharingRecordsForSelfAndPeerSummaryFeedback(Trigger.new, Trigger.oldMap);
    }
    
    // Added on Dec 21 2023 : W-007952 - Email's Sent for Performance Feedback
    if(Trigger.isAfter && Trigger.isInsert){
        
        Set<Id> performanceCycleIds = new Set<Id>();
        
        for(Form_Response__c fr : Trigger.new){
            if(fr.Performance_Cycle__c != null){
                performanceCycleIds.add(fr.Performance_Cycle__c);    
            }
        }
        if(!performanceCycleIds.isEmpty()){
            FormResponseTriggerHandler.sendMailNotificationFuture(JSON.serialize([SELECT Id, Form_Feedback_Type__c, Feedback_From__c, Feedback_About__c FROM Form_Response__c WHERE Id IN : Trigger.new AND Performance_Cycle__c IN : performanceCycleIds AND Performance_Cycle__r.Status__c = 'Deployed' AND Form_Feedback_Type__c != 'Action Needed']));
        }
    }
}