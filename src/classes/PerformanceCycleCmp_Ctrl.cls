public without sharing  class PerformanceCycleCmp_Ctrl {

    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
    
        List<sObject> lookupRecords = new List<sObject>();
        String query = 'SELECT Id, Name FROM ' + objectName;
        if(fieldName != null && fieldName != '' && searchString != null && searchString != '') {
            query += ' WHERE '+fieldName+' LIKE \'%' + searchString + '%\'';
        }
        system.debug('condition'+condition);
        if(condition != null && condition != '') {
            if(searchString != null && searchString != '') {
                
                query += ' AND ' + condition;
            } else {
                
                query += ' WHERE ' + condition;
            }
        }
        
        if(selectedIds != null && selectedIds.size() > 0) {
            query += ' AND Id NOT IN :selectedIds';
        }
        
        query += ' LIMIT 10';
        System.debug('query log ' + query);
        
        lookupRecords = Database.query(query);
        
        return lookupRecords;
    }  
    
    @AuraEnabled
    public static PerformanceCycleDomain.formResAndPeers getFormResponseRecord(Id recordId){
    
        PerformanceCycleDomain.formResAndPeers formResAndPeersWrap = new PerformanceCycleDomain.formResAndPeers();
        formResAndPeersWrap.formResponse =  [SELECT Id, Question_Set__c, Performance_Cycle__c, Question_Set__r.Feedback_Type__c, Feedback_About__c,Feedback_About__r.Name, Feedback_From__c, Feedback_From__r.Supervisor_Name__c, Is_Feedback_For_Me__c, Is_Feedback_By_Me__c FROM Form_Response__c WHERE Id = :recordId LIMIT 1];
        formResAndPeersWrap.peerSummaryFormResponses = [SELECT Id, Question_Set__c, Status__c, Performance_Cycle__c, Question_Set__r.Feedback_Type__c, Feedback_From__c, Feedback_From__r.Name, Feedback_About__c, Feedback_About__r.Name FROM Form_Response__c WHERE Feedback_About__c = :formResAndPeersWrap.formResponse.Feedback_About__c AND Performance_Cycle__c = :formResAndPeersWrap.formResponse.Performance_Cycle__c AND Question_Set__r.Feedback_Type__c = 'Peer Summary'];
        formResAndPeersWrap.contactFilter = 'RecordType.DeveloperName = \'DLS_Employee\'';
        Id userProfileId = UserInfo.getProfileId();
        String profileName = [Select Name from Profile where Id = :userProfileId][0].Name;
        if(!(profileName == 'HR' || profileName == 'System Administrator')){
            formResAndPeersWrap.contactFilter += ' AND DLS_User__c != \''+Userinfo.getUserId()+'\'';
        }
        if(formResAndPeersWrap.peerSummaryFormResponses.size() > 0){
            formResAndPeersWrap.contactFilter += ' AND Id NOT IN ';
            List<Id> conIds = new List<Id>();
            for(Form_Response__c formRes : formResAndPeersWrap.peerSummaryFormResponses){
                conIds.add(formRes.Feedback_From__c);
            }  
            formResAndPeersWrap.contactFilter += '(\''+String.join(conIds, '\',\'')+'\')';
        }
        return formResAndPeersWrap;
    }
    
    @AuraEnabled
    public static Map<String, String> createPeerFormResponse(List<Id> selectedEmployeeIds, String formResStr){
    
        Map<String, String> resultMap = new Map<String, String>{'result' => 'success', 'message' => 'Form Response created successfully!'};
        
        try{
            Form_Response__c formRes = (Form_Response__c) JSON.deserialize(formResStr, Form_Response__c.class);            
            List<Form_Response__c> formResList = new List<Form_Response__c>();
            List<Contact> employees = [SELECT Id, Name, Supervisor_Name__c FROM Contact WHERE Id IN :selectedEmployeeIds];                   
            NewClassAnnouncementController.addStaffRecordTypeFilter = true;
            Map<Id, Id> conIdWithUserIdMap = new Map<Id, Id>();//PlannedDaysOffHandler.getContactRelatedUsers((new Map<Id, Contact>(employees)).keySet());
            for(Contact con : [SELECT Id, Name, Supervisor_Name__c,DLS_User__c,DLS_User__r.Profile.Name FROM Contact WHERE Id IN :selectedEmployeeIds]){
                conIdWithUserIdMap.put(con.Id, (con.DLS_User__r.Profile.Name != 'Staff Community' ? con.DLS_User__c : con.Supervisor_Name__c));
            }  
            
            for(Question_Set__c questionSet : [SELECT Id, Performance_Cycle__c, Feedback_Type__c, Form_Template__c, Due_Date__c FROM Question_Set__c WHERE Performance_Cycle__c = :formRes.Performance_Cycle__c AND Feedback_Type__c = 'Peer Summary']){
                
                for(Contact emp : employees){
                    formResList.add(
                        new Form_Response__c(
                            Name = 'Feedback about '+formRes.Feedback_About__r.Name,
                            Form_Feedback_Type__c = questionSet.Feedback_Type__c,
                            Form_Template__c = questionSet.Form_Template__c,
                            Performance_Cycle__c = formRes.Performance_Cycle__c,
                            Question_Set__c = questionSet.Id,
                            Feedback_About__c = formRes.Feedback_About__c,
                            Feedback_From__c = emp.Id, 
                            Status__c = 'Draft',
                            Due_Date__c = questionSet.Due_Date__c,
                            OwnerId = conIdWithUserIdMap.get(emp.Id) != null ? conIdWithUserIdMap.get(emp.Id) : UserInfo.getUserId()
                        )
                    );
                }
            }
            
            if(formResList.size() > 0){
                insert formResList;
            }else{
                resultMap.put('message', 'Peer Summary Question set is not available for the related Performance Cycle');
                resultMap.put('result', 'error');
            }
        }catch(Exception exe){
            resultMap.put('message', exe.getMessage());
            resultMap.put('result', 'error');
        }
        
        return resultMap;
    }
    
    @AuraEnabled
    public static Map<String, String> createEmpFormResponse(List<Id> selectedEmployeeIds, Id recordId){
    
        Map<String, String> resultMap = new Map<String, String>{'result' => 'success', 'message' => 'Form Response created successfully!'};
        
        try{
            List<Form_Response__c> formResList = new List<Form_Response__c>();
            Set<Id> supervisorIds = new Set<Id>();
            List<Contact> employees = new List<Contact>();
            Map<Id, Id> conIdWithUserIdMap = new Map<Id, Id>();
            
            for(Contact con : [SELECT Id, Name, Supervisor_Name__c,DLS_User__c,DLS_User__r.Profile.Name FROM Contact WHERE Id IN :selectedEmployeeIds]){
                supervisorIds.add(con.Supervisor_Name__c);
                conIdWithUserIdMap.put(con.Id, (con.DLS_User__r.Profile.Name != 'Staff Community' ? con.DLS_User__c : con.Supervisor_Name__c));
                employees.add(con);
            }        
            NewClassAnnouncementController.addStaffRecordTypeFilter = true;
            Map<Id, Id> supervisorConIdMap = PlannedDaysOffHandler.getUserRelatedContacts(supervisorIds);
            //Map<Id, Id> conIdWithUserIdMap = PlannedDaysOffHandler.getContactRelatedUsers((new Map<Id, Contact>(employees)).keySet());
            
            for(Question_Set__c questionSet : [SELECT Id, Performance_Cycle__c, Feedback_Type__c, Form_Template__c, Due_Date__c FROM Question_Set__c WHERE Performance_Cycle__c = :recordId AND Feedback_Type__c IN ('Self Summary','Manager Summary', 'Action Needed')]){
                
                for(Contact emp : employees){
                    if(questionSet.Feedback_Type__c != 'Manager Summary' || (questionSet.Feedback_Type__c == 'Manager Summary' && emp.Supervisor_Name__c != null && supervisorConIdMap.get(emp.Supervisor_Name__c) != null)){
                        formResList.add(
                            new Form_Response__c(
                                Name = 'Feedback about '+emp.Name,
                                Form_Feedback_Type__c = questionSet.Feedback_Type__c,
                                Form_Template__c = questionSet.Form_Template__c,
                                Performance_Cycle__c = recordId,
                                Question_Set__c = questionSet.Id,
                                Feedback_About__c = emp.Id,
                                Feedback_From__c = questionSet.Feedback_Type__c == 'Self Summary' ? emp.Id : supervisorConIdMap.get(emp.Supervisor_Name__c),
                                Status__c = 'Draft',
                                Due_Date__c = questionSet.Due_Date__c,
                                OwnerId = (questionSet.Feedback_Type__c == 'Self Summary' && conIdWithUserIdMap.get(emp.Id) != null ? conIdWithUserIdMap.get(emp.Id) : (emp.Supervisor_Name__c != null ? emp.Supervisor_Name__c : UserInfo.getUserId()))
                            )
                        );
                    }
                }
            }
            
            if(formResList.size() > 0){
                insert formResList;
            }else{
                resultMap.put('message', 'Self Summary/Manager Summary Question set is not available for the related Performance Cycle');
                resultMap.put('result', 'error');
            }
        }catch(Exception exe){
            resultMap.put('message', exe.getMessage());
            resultMap.put('result', 'error');
        }
        
        return resultMap;
    }
    
    @AuraEnabled
    public static PerformanceCycleDomain.dlsEmpAndConFilter getEmployees(Id recordId){
        
        PerformanceCycleDomain.dlsEmpAndConFilter dlsEmpAndConFilter = new PerformanceCycleDomain.dlsEmpAndConFilter();
        Map<String, List<Contact>> employeeMap = new Map<String, List<Contact>>();
        List<Contact> allActiveEmployees = [SELECT Id, Name, Supervisor_Name__r.Name FROM Contact WHERE RecordType.DeveloperName = 'DLS_Employee' AND Active_DLS_Employee__c = true];
        List<Contact> newHiredEmployees = [SELECT Id, Name, Supervisor_Name__r.Name FROM Contact WHERE RecordType.DeveloperName = 'DLS_Employee' AND Active_DLS_Employee__c = true AND Original_Hire_Date__c = LAST_90_Days];
        employeeMap.put('active', allActiveEmployees);
        employeeMap.put('new', newHiredEmployees);
        dlsEmpAndConFilter.dlsEmp = employeeMap;
        List<Form_Response__c> formResList = [SELECT Id, Question_Set__c, Status__c, Performance_Cycle__c, Question_Set__r.Feedback_Type__c, Feedback_From__c, Feedback_From__r.Name, Feedback_About__c, Feedback_About__r.Name FROM Form_Response__c WHERE Performance_Cycle__c = :recordId AND Question_Set__r.Feedback_Type__c = 'Self Summary'];
        dlsEmpAndConFilter.contactFilter = 'RecordType.DeveloperName = \'DLS_Employee\'';
        if(formResList.size() > 0){
            dlsEmpAndConFilter.contactFilter += ' AND Id NOT IN ';
            List<Id> conIds = new List<Id>();
            for(Form_Response__c formRes : formResList){
                conIds.add(formRes.Feedback_From__c);
            }  
            dlsEmpAndConFilter.contactFilter += '(\''+String.join(conIds, '\',\'')+'\')';
        }
        
        return dlsEmpAndConFilter;
    }    
    
    @AuraEnabled
    public static PerformanceCycleDomain.formResAndTemp getAllFormResElementsAndFormTempElements(Id formResponseId){
    
        PerformanceCycleDomain.formResAndTemp formResEleAndTempElementsWrap = new  PerformanceCycleDomain.formResAndTemp();
        formResEleAndTempElementsWrap.formResponseAndFormResElements = FormResponseService.getFormResWithFormResElements(' Id = \''+formResponseId+'\'', ',Feedback_About__r.Name');
        formResEleAndTempElementsWrap.formTemplateAndFormTempElements = FormResponseCtrl.getFormTemplate(formResEleAndTempElementsWrap.formResponseAndFormResElements.Form_Template__c);
        
        return formResEleAndTempElementsWrap;
    }
    
    @AuraEnabled
    public static string saveFormResAndFormResElements(String formResponseElementsStr, String formResponseStr){
    
        String result = 'success';
        try{
            List<Form_Response_Element__c> formResponseElements = (List<Form_Response_Element__c>) JSON.deserialize(formResponseElementsStr, List<Form_Response_Element__c>.class);
            Form_Response__c formResponse = (Form_Response__c) JSON.deserialize(formResponseStr, Form_Response__c.class);
                
            update formResponse;
            
            if(formResponseElements.size() > 0){
                upsert formResponseElements; 
            }
        }catch(Exception exe){
            result = exe.getMessage();
        }
        
        return result;
    }
}