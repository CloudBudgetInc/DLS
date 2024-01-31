Public Class FormResponseTriggerHandler{    
    public static void sendMailNotification(String formResponsesStr){
        List<Form_Response__c> formResponses = (List<Form_Response__c>) JSON.deserialize(formResponsesStr, List<Form_Response__c>.Class);
        
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where DisplayName = 'HR'];
        Map<String, EmailTemplate> summaryWithTemplateId = new Map<String, EmailTemplate>();
        for(EmailTemplate template: [SELECT Id, DeveloperName, Subject FROM EmailTemplate WHERE DeveloperName IN ('Performance_Cycle_Self_Summary_Template','Performance_Cycle_Peer_Summary_Template','Performance_Cycle_Manager_Summary_Temp')]){
            List<String> tempList = template.DeveloperName.split('_');
            summaryWithTemplateId.put(tempList[2]+' '+tempList[3], template);
        }
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
        for(Form_Response__c formRes : formResponses){
            if(formRes.Feedback_About__c != null && formRes.Feedback_From__c != null){               
                    
                Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
                
                message.setTargetObjectId(formRes.Feedback_From__c); 
                message.setTemplateID(summaryWithTemplateId.get(formRes.Form_Feedback_Type__c).Id); 
                message.setWhatId(formRes.Id); 
                message.setSaveAsActivity(true); 
                message.setOrgWideEmailAddressId(owea.get(0).Id);
                messages.add(message);                               
            }
        }
        
        if(!Test.isRunningTest() && messages.size() > 0){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug('The email failed to send: ' +  results[0].errors[0].message);
            }
        } 
    }
    
    @future
    public static void sendMailNotificationFuture(String formResponsesStr){
        sendMailNotification(formResponsesStr);
    }
    
    //Added By Dhinesh - 02/11/2021 - to create sharing records For Self Summary -> Manager, Peer Summary -> Manager, Feedback about if Is Share to Employee is true
    public static void createSharingRecordsForSelfAndPeerSummaryFeedback(List<Form_Response__c> newFormResponseList, Map<Id, Form_Response__c> oldFormResponceMap){
        Map<Id, Form_Response__c> formResponseToCreateMangerShare = new Map<Id, Form_Response__c>();
        Map<Id, Form_Response__c> formResponseToCreateEmpShare = new Map<Id, Form_Response__c>();
        Map<Id, Form_Response__c> formResponseToDeleteEmpShare = new Map<Id, Form_Response__c>();
        Set<Id> employeeIds = new Set<Id>();
        Set<Id> employeeIdsToDeleteShare = new Set<Id>();
        Set<Id> supervisorIds = new Set<Id>();        
        List<Form_Response__Share> formResShrList = new List<Form_Response__Share>();            
        
        for(Form_Response__c formRes : newFormResponseList){
            
            if(formRes.Form_Feedback_Type__c == 'Self Summary' && oldFormResponceMap == null){
                formResponseToCreateMangerShare.put(formRes.Id, formRes);
                employeeIds.add(formRes.Feedback_About__c);
            }else if(formRes.Form_Feedback_Type__c == 'Peer Summary'){
                if(oldFormResponceMap == null){
                    formResponseToCreateMangerShare.put(formRes.Id, formRes);
                    employeeIds.add(formRes.Feedback_About__c);
                }
                if(formRes.Is_Share_with_Employee__c && (oldFormResponceMap == null || !oldFormResponceMap.get(formRes.Id).Is_Share_with_Employee__c)){
                    formResponseToCreateEmpShare.put(formRes.Id, formRes);
                    employeeIds.add(formRes.Feedback_About__c);
                }
                if(!formRes.Is_Share_with_Employee__c && oldFormResponceMap != null && oldFormResponceMap.get(formRes.Id).Is_Share_with_Employee__c){
                    formResponseToDeleteEmpShare.put(formRes.Id, formRes);
                    employeeIdsToDeleteShare.add(formRes.Feedback_About__c);
                }
            }
        }
        
        if(formResponseToCreateMangerShare.size() > 0){
            Map<Id, Id> contactIdWithSupervisorIdMap = new Map<Id, Id>();
            for(Contact con : [SELECT Id, Name, Supervisor_Name__c FROM Contact WHERE Id IN :employeeIds AND Supervisor_Name__c != null]){
                contactIdWithSupervisorIdMap.put(con.Id, con.Supervisor_Name__c);            
            }        
                        
            for(Form_Response__c formRes: formResponseToCreateMangerShare.values()){
            
                if(contactIdWithSupervisorIdMap.get(formRes.Feedback_About__c) != null){
                    Form_Response__Share formResShr  = new Form_Response__Share();            
                    formResShr.ParentId = formRes.Id;            
                    formResShr.UserOrGroupId = contactIdWithSupervisorIdMap.get(formRes.Feedback_About__c);            
                    formResShr.AccessLevel = 'Read';
                    formResShrList.add(formResShr);
                }        
            }
        }
        
        if(formResponseToCreateEmpShare.size() > 0){       
            Map<Id, Id> conIdWithUserIdMap = PlannedDaysOffHandler.getContactRelatedUsers(employeeIds);
            
            for(Form_Response__c formRes: formResponseToCreateEmpShare.values()){
            
                if(conIdWithUserIdMap.get(formRes.Feedback_About__c) != null){
                    Form_Response__Share formResShr  = new Form_Response__Share();            
                    formResShr.ParentId = formRes.Id;            
                    formResShr.UserOrGroupId = conIdWithUserIdMap.get(formRes.Feedback_About__c);            
                    formResShr.AccessLevel = 'Read';
                    formResShrList.add(formResShr);
                }        
            }
        }
        
        if(formResShrList.size() > 0){
            Database.SaveResult[] shareResults = Database.insert(formResShrList,false);
            for (Database.SaveResult sr : shareResults) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully inserted sharing: ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }
        if(formResponseToDeleteEmpShare.size() > 0){
            Map<Id, Id> conIdWithUserIdMap = PlannedDaysOffHandler.getContactRelatedUsers(employeeIdsToDeleteShare);
            
            List<Form_Response__Share> formResponseShareToDelete = [SELECT Id, parentId, UserOrGroupId FROM Form_Response__Share WHERE parentId IN :formResponseToDeleteEmpShare.keySet() AND UserOrGroupId IN :conIdWithUserIdMap.values()];
            if(formResponseShareToDelete.size() > 0){
                delete formResponseShareToDelete;
            }
        }
    }
}