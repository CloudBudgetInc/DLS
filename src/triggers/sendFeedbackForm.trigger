trigger sendFeedbackForm on Opportunity (after Update) {

    Opportunity oldMapOpportunity = new Opportunity();
    Set<Id> oppIdForWeeklyFeedback = new Set<Id>();
    Set<Id> oppIdForCompleteFeedback = new Set<Id>();
    
    if(trigger.isAfter && trigger.isUpdate) {
        System.debug(':::Enter after Update Trigger1111:::');
        if(sendFeedbackFormHelper.triggerExecution) {
            
            System.debug(':::Enter after Update Trigger:::'+sendFeedbackFormHelper.triggerExecution);
            Set<Id> recTypeIds = new Set<Id>();
            //for(RecordType rec :[SELECT Id,Name,DeveloperName FROM RecordType WHERE SObjectType='Opportunity' AND DeveloperName IN ('Online_Class_Opportunities','New_Classes_Opportunities')]) {
            //    recTypeIds.add(rec.Id); 
            //}
            
            Map<String,Id> oppRecTypeMapTemp = new Map<String,Id>();
            OpportunityTrigger_Handler oTH = new OpportunityTrigger_Handler();
            
            if( OpportunityTrigger_Handler.oppRecTypeMap != null && OpportunityTrigger_Handler.oppRecTypeMap.size() > 0 ) {
                oppRecTypeMapTemp = OpportunityTrigger_Handler.oppRecTypeMap;        
            } else {
                oTH.getRecordTypeMap();
                oppRecTypeMapTemp = OpportunityTrigger_Handler.oppRecTypeMap;
            }
            
            if( oppRecTypeMapTemp != null && oppRecTypeMapTemp.size() > 0 ) {
                for(String s : oppRecTypeMapTemp.keyset()) {
                    if((s == 'DLI_W_TO_Opportunities' || s == 'New_Classes_Opportunities' || s == 'ODNI_CLP_Opportunities') && oppRecTypeMapTemp.containskey(s)) {
                        recTypeIds.add(oppRecTypeMapTemp.get(s));
                    }
                }
            }
            
            // Commented on May 16 2023
            // To prevent "student and instructor get feedback email not sending" issue when project is ended
            //sendFeedbackFormHelper.triggerExecution = false;
            for(Opportunity opp : trigger.new) {
                if(recTypeIds.contains(opp.RecordTypeId)) {
                    System.debug(':::Trigger:::');
                    oldMapOpportunity = Trigger.oldMap.get(opp.Id);
                    
                    /*if(oldMapOpportunity.Hours_Used_Rollup__c != opp.Hours_Used_Rollup__c) {
                        if(opp.Hours_Used_Rollup__c != null && opp.Hours_Week__c != null) {
                            if(opp.Last_Notified_Hour__c == null) {
                                opp.Last_Notified_Hour__c = 0;
                            }
                            
                            if(opp.Last_Notified_Hour__c == 0 && (Math.round(opp.Hours_Used_Rollup__c) > Math.round(opp.Hours_Week__c) * 2)) {
                                                                
                                Integer modVal = Math.mod((Math.round(opp.Hours_Used_Rollup__c) - Math.round(opp.Last_Notified_Hour__c)),Math.round(opp.Hours_Week__c));
                                System.debug(':::modVal:::' + modVal);
                                if((modVal/2) >= 0) {
                                    opp.Last_Notified_Hour__c = opp.Hours_Used_Rollup__c;
                                    oppIdForWeeklyFeedback.add(opp.Id);
                                }
                            }
                        }    
                    }*/
                   
                    if(oldMapOpportunity.StageName != opp.StageName && opp.StageName == 'Ended') {
                        oppIdForCompleteFeedback.add(opp.Id);
                    }
                }
            }
            System.debug(':::oppIdForCompleteFeedback:::' + oppIdForCompleteFeedback);
            System.debug(':::oppIdForWeeklyFeedback:::' + oppIdForWeeklyFeedback);
            //if(oppIdForWeeklyFeedback.size() > 0) sendFeedbackFormHelper.sendEmail(oppIdForWeeklyFeedback,trigger.new);
            //if(oppIdForCompleteFeedback.size() > 0) sendFeedbackFormHelper.sendEmailForCompleted(oppIdForCompleteFeedback,trigger.new);
        }
    }
}