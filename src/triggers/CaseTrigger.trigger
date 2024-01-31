trigger CaseTrigger on Case (after insert, before insert, after update, before update) {

    if(Trigger.isInsert){
    
        Map<Id, User> portalUserIdAndRec = new Map<Id, user>();
        Map<Id, User> internalUserIdAndRec = new Map<Id, user>();
        
        Set<Id> userIds  = new Set<Id>{UserInfo.getUserId()};
                
        for(User u : [SELECT Id, IsPortalEnabled FROM User WHERE Id IN :userIds]){
        
            if(u.IsPortalEnabled == FALSE){
                internalUserIdAndRec.put(u.Id, u);
            }
            if(u.IsPortalEnabled == TRUE){
                portalUserIdAndRec.put(u.Id, u);
            }
        }
        
        if(Trigger.isAfter) {
        
            List<Case> updateCases = new List<Case>();
            
            for(Case cs : Trigger.new) {
                
                if(CaseCreationController.isInvokeCaseAssign == TRUE || portalUserIdAndRec.containsKey(UserInfo.getUserId())){
                
                    /**Start of Code to initiate Case Assignment Rule **/
                    Database.DMLOptions dmo = new Database.DMLOptions();
                    dmo.AssignmentRuleHeader.useDefaultRule= TRUE;
                    dmo.EmailHeader.TriggerUserEmail = TRUE;
                    /**End of Code to initiate Case Assignment Rule **/
                    
                    Case c = new Case(Id = cs.Id);
                    c.setOptions(dmo);
                    updateCases.add(c);
                }
            }
            Database.update(updateCases);
            
        }
        
        // Added by HL on Apr 26 2019
        if(Trigger.isBefore){
        
            List<Case> cases = new List<Case>();
            
            for(Case c : Trigger.new){
                if(String.isBlank(c.Origin) || c.ContactId == NULL){
                    cases.add(c);
                }
            }
            
            if(cases.size() > 0){
                            
                if(internalUserIdAndRec.size() > 0){
                
                    Map<Id, Id> userIdConId = PlannedDaysOffHandler.getUserRelatedContacts(internalUserIdAndRec.keySet());
                    
                    for(Case c : cases){
                    
                        if(String.isBlank(c.Origin)){
                            c.Origin = 'Web';
                        }
                        if(c.ContactId == NULL){
                        
                            if(userIdConId.containsKey(UserInfo.getUserId())){
                                 c.ContactId = userIdConId.get(UserInfo.getUserId());
                            }
                        }
                    }
                }
            }
        }
    }
    
    if(Trigger.isUpdate){
        
        List<Case> updateCaseRecs = new List<Case>();
        
        for(Case c : Trigger.new){
            
            // Added By HL on May 28 2021
            // Work Item: W-006632 - Report for "Initial Case Response"
            // To calculate Case's initial response time after a user submits a Case
            if(Trigger.isAfter && c.Status != Trigger.oldMap.get(c.Id).Status && Trigger.oldMap.get(c.Id).Status == 'New'){
                
                Case updateCase = new Case();
                updateCase.Id = c.Id;
                
                // To construct the result as decimal value
                Decimal modifiedTime = c.LastModifiedDate.getTime();
                Decimal createdTime = c.CreatedDate.getTime();
                Decimal timeDiffInMilliSec = modifiedTime-createdTime;
                Decimal timeDiffInSec = timeDiffInMilliSec/1000;
                Decimal timeDiffInMin = timeDiffInSec/60;
                Decimal timeDiffInHour = timeDiffInMin/60;
                                                
                updateCase.Initial_Case_Response_Time__c = (timeDiffInHour).setScale(2);
                updateCaseRecs.add(updateCase);
            }
            //Work Item : W-007429 - Case Reminder Emails Not Sent to All Case Owners 
            if(Trigger.isBefore && c.Is_Send_Escalation_Reminder__c == Trigger.oldMap.get(c.Id).Is_Send_Escalation_Reminder__c && c.Is_Send_Escalation_Reminder__c){
                c.Is_Send_Escalation_Reminder__c = False;
            }
        }
        
        if(updateCaseRecs != NULL && updateCaseRecs.size() > 0){
            update updateCaseRecs;
        }
    }
}