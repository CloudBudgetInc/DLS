trigger plannedDaysOff_Trigger on Planned_Days_Off__c (before insert,before update, after insert, after update) {
    
    /* Added by GRK to send Approval Request
     To send Approval Request to the Manager of the Contact for the following scenario
     1. When internal User creates Planned Days Off for themselves
     2. When internal User creates Planned Days Off for others internal User (Send Approval Request to the planned days off Contact's Manager)
     3. When internal User updates an Approved planned days off record
     4. When internal User tries to delete a record using the custom page, NS will update the Status as Delete and will be submitted for approval
     Skip for the following,
     1. When internal User creates planned days off for Instructor/ Student
     2. When HR Users / The contact's Manager creates the planned Days off*/
    
    PlannedDaysOffHandler handler = new PlannedDaysOffHandler();
    
    Set<Id> offIds = new Set<Id>();
    List<Approval.ProcessSubmitRequest> reqs = new List<Approval.ProcessSubmitRequest>();
    Set<Id> pdoDelList = new Set<Id>();
    Map<Id,String> rtIdName = handler.getPlannedOffRT();
  
    Set<Id> conIdsToPopulateUserIds = new Set<Id>();
    Map<Id, Id> conIdAndUserId = new Map<Id, Id>();    
    
    // To Make the DLI W LT Related holidays status as Approved on creation
    // Those records don't have any kind of parent values
    if(trigger.isInsert && trigger.isBefore) {
        for(Planned_Days_Off__c off : trigger.new){
            if(rtIdName.get(off.RecordTypeId) == 'DLI_W_LT_Training_Holidays' && off.Project__c == null && off.Opportunity__c == null && off.Contact__c == null){
                off.Status__c = 'Approved';
            }
            
            // Added by HL on Feb 24 2020
            // Work Item : W-004364 - Planned Days off Events still "Scheduled"
            if(rtIdName.get(off.RecordTypeId) != 'Request' && off.User__c == NULL && off.Contact__c != NULL){
                conIdsToPopulateUserIds.add(off.Contact__c);
            }
        }
    }
    System.debug(':::conIdsToPopulateUserIds::::'+conIdsToPopulateUserIds);
    
    if(conIdsToPopulateUserIds.size() > 0){
        conIdAndUserId = PlannedDaysOffHandler.getContactRelatedUsers(conIdsToPopulateUserIds);
    }
    System.debug('::::conIdAndUserId::::'+conIdAndUserId);
    
    if(Trigger.isInsert && Trigger.isBefore){
    
        for(Planned_Days_Off__c off : trigger.new){
        
            if(rtIdName.get(off.RecordTypeId) != 'Request' && off.User__c == NULL && off.Contact__c != NULL){
                
                if(conIdAndUserId != NULL && conIdAndUserId.containsKey(off.Contact__c)){
                
                    off.User__c = conIdAndUserId.get(off.Contact__c);
                }
            }    
        }
    }
    
    if( ( trigger.isInsert || trigger.isUpdate ) && trigger.isAfter) {
        
        // Variables to update event records
        List<Planned_Days_Off__c> pdoRecs = new List<Planned_Days_Off__c>();
        List<Planned_Days_Off__c> insPDOsToDeleteTask = new List<Planned_Days_Off__c>();
        
        Set<Id> projIds = new Set<Id>();
        Set<Date> pdoDates = new Set<Date>();
        String statusStr = '';
            
        List<Planned_Days_Off__c> pdoRecsByInternalUser = new List<Planned_Days_Off__c>();
        
        for(Planned_Days_Off__c off : trigger.new) { 
        
            if(Trigger.IsInsert || ( trigger.IsUpdate && trigger.oldMap.get(off.Id).Status__c != off.Status__c 
                && off.Status__c == 'Draft' && trigger.oldMap.get(off.Id).Status__c == 'Approved' ) ) {
                
                offIds.add(off.Id);
            }
            
            if(Trigger.IsUpdate && trigger.oldMap.get(off.Id).Status__c != off.Status__c && off.Status__c == 'Delete' 
                && (rtIdName.get(off.RecordTypeId) == 'Request' || rtIdName.get(off.RecordTypeId) == 'Student_Planned_Days_Off')) {
                
                pdoDelList.add(off.Id);
                
                if(rtIdName.get(off.RecordTypeId) == 'Request' && off.Type__c == 'Instructor'){
                    insPDOsToDeleteTask.add(off);    
                }
            }
            
            // Added by HL on Oct 04 2019
            // Work Item : W-003064 - Add ability for students and instructors to edit and delete Planned Days Off records in the community
            // Update event records Status as "Canceled" that are related to student Planned Day Off records which are approved
            // Added by HL on Feb 24 2020
            // Work Item : W-004364 - Planned Days off Events still "Scheduled" - added Parent_Planned_Day_Off__c condition
            if(Trigger.IsInsert && String.isNotBlank(off.Status__c) && off.Status__c == 'Approved' 
                && rtIdName.get(off.RecordTypeId) == 'Student_Planned_Days_Off' && off.Date__c != NULL
                && ((off.Parent_Planned_Day_Off__c == NULL && off.User__c != off.CreatedById) || off.Parent_Planned_Day_Off__c != NULL)){
                
                pdoRecs.add(off);
            }
            
            // Added By HL on June 02 2021
            // Work Item: W-006749 - Planned Days Off did not Cancel Events
            if(rtIdName.get(off.RecordTypeId) == 'Project_Planned_Days_Off' && off.Project__c != NULL && off.Date__c != NULL && 
                (Trigger.isInsert || (Trigger.isUpdate && trigger.oldMap.get(off.Id).Status__c != off.Status__c && 
                off.Status__c == 'Delete'))){
                
                projIds.add(off.Project__c);
                pdoDates.add(off.Date__c);
                
                if(Trigger.isInsert){
                    statusStr = 'Update Canceled';        
                }  
                if(Trigger.isUpdate){
                    statusStr = 'Update Scheduled';        
                }  
            }
            
            if(Trigger.isInsert && off.Parent_Planned_Day_Off__c == NULL && off.Status__c == 'Approved' && off.Project__c != NULL && (rtIdName.get(off.RecordTypeId) == 'Student_Planned_Days_Off' || rtIdName.get(off.RecordTypeId) == 'Instructor_Planned_Days_Off')){
                pdoRecsByInternalUser.add(off);
            }
        }
        
        if(pdoRecs.size() > 0){
            handler.updateEventRecsToCancelled(pdoRecs);
        }
    
        if(projIds != NULL && pdoDates != NULL && String.isNotBlank(statusStr)){
        
            handler.updateEventRecsForProjectPDO(projIds, pdoDates, statusStr);
        }
        
        if(pdoRecsByInternalUser.size() > 0 ){
            PlannedDaysOffHandler.pdoApprovalEmailByInternalUser(pdoRecsByInternalUser);
        }
        
        if(insPDOsToDeleteTask.size() > 0){
            PlannedDaysOffHandler.create_Update_DeleteTaskRelatedToProject(insPDOsToDeleteTask, False, False, True);
        }
    }
            
    if(!offIds.isEmpty()) {
        
        List<Planned_Days_Off__c> std_pdoRecs = new List<Planned_Days_Off__c>();
        List<Planned_Days_Off__c> updateDaysOffApprover = new List<Planned_Days_Off__c>();
        
        System.debug('offIds:::::'+offIds);
        
        for(Planned_Days_Off__c off : (List<Planned_Days_Off__c>)SObjectQueryService.SObjectQuery('Planned_Days_Off__c', offIds, ',Contact__r.RecordType.DeveloperName,Contact__r.Supervisor_Name__c,User__r.ManagerId, RecordType.DeveloperName, CreatedBy.Profile.Name, Project__r.Project_Manager__c')) {            
            
            // Status Draft check for Creation and Updation
            // Status Delete check for Planned Days Off record deletion.
            if( off.RecordType.DeveloperName == 'Request' && off.Status__c == 'Draft' && off.CreatedBy.Profile.Name != 'HR') {
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setObjectId(off.Id);
                
                Boolean includeForApproval = false;
                
                Planned_Days_Off__c newOff = new Planned_Days_Off__c();
                
                //Added by NS on July 25 2019
                //If the contact is DLS Employee RT then approver should be related user's manager
                if(off.Contact__r.RecordType.DeveloperName == 'DLS_Employee' && off.User__r.ManagerId != null && off.CreatedById != off.User__r.ManagerId){
                
                    req1.setNextApproverIds(new List<Id>{off.User__r.ManagerId});
                    
                    newOff.Approver_Name__c = off.User__r.ManagerId;
                    
                    includeForApproval = true;
                    if(off.Type__c == 'Student'){
                        std_pdoRecs.add(off);
                    }
                }
                
                //If the Contact is Student / Instructor then we look for Contact's Supervisor for approver
                if((off.Contact__r.RecordType.DeveloperName == 'Candidate' || off.Contact__r.RecordType.DeveloperName == 'Student') && off.Status__c != 'Delete'){
                    if(off.Project__c == NULL && off.All_Projects__c && off.Contact__r.Supervisor_Name__c != null){
                    
                        req1.setNextApproverIds(new List<Id>{off.Contact__r.Supervisor_Name__c});
                        
                        newOff.Approver_Name__c = off.Contact__r.Supervisor_Name__c;
                    
                        includeForApproval = true;
                        if(off.Type__c == 'Student'){
                            std_pdoRecs.add(off);
                        }
                    }
                    
                    if(off.Project__c != NULL && off.Project__r.Project_Manager__c != null){
                        req1.setNextApproverIds(new List<Id>{off.Project__r.Project_Manager__c});
                        
                        newOff.Approver_Name__c = off.Project__r.Project_Manager__c;
                    
                        includeForApproval = true;
                        if(off.Type__c == 'Student'){
                            std_pdoRecs.add(off);
                        }
                    }
                }
                
                if(includeForApproval){
                    
                    newOff.Id = off.Id;
                    updateDaysOffApprover.add(newOff);
                    
                    reqs.add(req1);
                }
            }
        }
        
        if( !reqs.isEmpty() ) {
        
            System.debug('reqs::::'+reqs);
            List<Approval.ProcessResult> result = Approval.process(reqs);
            System.debug('result :::::'+result);
            
            PlannedDaysOffHandler.sendStudentPDOEmailToInstructor(std_pdoRecs);
        }
        
        system.debug(':::::::updateDaysOffApprover:::::::'+updateDaysOffApprover.size());
        
        //Update approver name to use in report
        //Added by NS on Nov 28 2019
        if(updateDaysOffApprover.size() > 0){
            update updateDaysOffApprover;
        }
    }
    System.debug('::pdoDelList::'+pdoDelList);
    if(!pdoDelList.isEmpty()){
        
        List<Planned_Days_Off__c> updatePDOReqRecs = new List<Planned_Days_Off__c>();
        List<Planned_Days_Off__c> pdoRecsToUpdateEveRecs = new List<Planned_Days_Off__c>();
        
        // Work Item : W-003064 - Add ability for students and instructors to edit and delete Planned Days Off records in the community
        // Update event records Status as "Scheduled" that are related to student parent Planned Day Off records which status is updated to delete
        for(Planned_Days_Off__c pdo : [SELECT Id, Contact__c, Date__c, Project__c, All_Projects__c,Status__c 
                                        FROM Planned_Days_Off__c 
                                        WHERE (Id IN : pdoDelList OR Parent_Planned_Day_Off__c IN : pdoDelList)]){
                                        
            if(!pdoDelList.contains(pdo.Id) && pdo.Status__c != 'Delete'){
                pdo.Status__c = 'Delete';
                updatePDOReqRecs.add(pdo);
            }
            // To skip parent PDO record
            if(pdo.Contact__c != NULL && pdo.Date__c != NULL){
                pdoRecsToUpdateEveRecs.add(pdo);    
            }
        }
        System.debug('::updatePDOReqRecs::'+updatePDOReqRecs.size());
        System.debug('::pdoRecsToUpdateEveRecs::'+pdoRecsToUpdateEveRecs.size());
        
        if(pdoRecsToUpdateEveRecs.size() > 0){
            handler.updateEventRecsToScheduled(pdoRecsToUpdateEveRecs);
        }
        
        if(updatePDOReqRecs.size() > 0){
            update updatePDOReqRecs;    
        }
    }
    
    // Created actual Planne days off records based on request record approval
    // Added by NS on July 9 2018
    Set<Id> requestOffIds = new Set<Id>();
    Set<Id> pdoIds = new Set<Id>();
    List<Planned_Days_Off__c> pdoToCreateTask = new List<Planned_Days_Off__c>();
    
    // Variables to send an email notification to LTS / Project Manager or Contact Supervisor
    Id loggedInUserId = UserInfo.getuserId();
    List<Planned_Days_Off__c> editDelPDOReqs = new List<Planned_Days_Off__c>();
    Set<Id> parentPDOIds = new Set<Id>();
    
    if(trigger.isUpdate && trigger.isAfter) {
        
        Map<Id, Planned_Days_Off__c> old_PDORecValue = new Map<Id, Planned_Days_Off__c>();
        Map<Id, Planned_Days_Off__c> new_PDORecValue = new Map<Id, Planned_Days_Off__c>();
        
        List<Planned_Days_Off__c> notApprovedPDORecs = new List<Planned_Days_Off__c>();
        List<Planned_Days_Off__c> insPDOsToCreateTask = new List<Planned_Days_Off__c>();
        List<Planned_Days_Off__c> insPDOsToUpdateTask = new List<Planned_Days_Off__c>();
        
        for(Planned_Days_Off__c off : trigger.new){
        
            if(off.Status__c != Trigger.oldMap.get(off.Id).Status__c && off.Status__c == 'Approved' && rtIdName.get(off.RecordTypeId) == 'Request'){
                requestOffIds.add(off.Id);
            }
            
            // Added by HL on Sep 10 2019 - Send an email notification to instructor / student Upon LTS approval
            if(String.isNotBlank(off.Status__c) && off.Status__c != Trigger.oldMap.get(off.Id).Status__c && 
                Trigger.oldMap.get(off.Id).Status__c == 'Submitted for Approval' && (off.Status__c == 'Approved' || 
                off.Status__c == 'Not Approved') && off.Contact__c != NULL && 
                rtIdName.get(off.RecordTypeId) == 'Request'){
                
                if(off.Status__c == 'Approved'){
                    pdoIds.add(off.Id);
                    
                    if(off.Type__c == 'Instructor'){
                        insPDOsToCreateTask.add(off);
                    }
                }
                                
                // Added by HL on June 30 2022 - Send an email notification to instructors Upon LTS Rejection
                if(off.Status__c == 'Not Approved' && off.Type__c == 'Student'){
                    notApprovedPDORecs.add(off);
                }
                pdoToCreateTask.add(off);
            }
            
            if(off.Status__c == 'Approved' && off.From_Date__c != Trigger.oldMap.get(off.Id).From_Date__c && rtIdName.get(off.RecordTypeId) == 'Request' && off.Type__c == 'Instructor'){
                insPDOsToUpdateTask.add(off);
            }
                
            // Added by HL on Oct 19 2019
            // To send an email notification to LTS / Project Manager or Contact Supervisor Whenever a Planned Days Off record is edited or deleted
            if(off.User__c != NULL && off.User__c == loggedInUserId && (rtIdName.get(off.RecordTypeId) == 'Instructor_Planned_Days_Off' || rtIdName.get(off.RecordTypeId) == 'Student_Planned_Days_Off' || rtIdName.get(off.RecordTypeId) == 'Request') 
                && Trigger.oldMap.get(off.Id).Status__c == 'Approved'){
            
                if((off.Type__c != Trigger.oldMap.get(off.Id).Type__c || off.Description__c != Trigger.oldMap.get(off.Id).Description__c || 
                    off.From_Date__c != Trigger.oldMap.get(off.Id).From_Date__c || off.To_Date__c != Trigger.oldMap.get(off.Id).To_Date__c ||
                    off.Status__c != Trigger.oldMap.get(off.Id).Status__c || off.Date__c != Trigger.oldMap.get(off.Id).Date__c) || off.Status__c == 'Delete'){
                    
                    editDelPDOReqs.add(off);
                }
            }     
            // Added By HL on Oct 19 2021
            if(rtIdName.get(off.RecordTypeId) == 'Request' && off.Status__c == 'Approved' && (off.From_Date__c != Trigger.oldMap.get(off.Id).From_Date__c || 
                off.To_Date__c != Trigger.oldMap.get(off.Id).To_Date__c || off.All_Projects__c != Trigger.oldMap.get(off.Id).All_Projects__c || 
                off.Project__c != Trigger.oldMap.get(off.Id).Project__c)){
                
                old_PDORecValue.put(off.Id, Trigger.oldMap.get(off.Id));
                new_PDORecValue.put(off.Id, off);
            }
            
            //Added on Dec 03 2021
            if(Trigger.oldMap.get(off.Id).Status__c == 'Approved' && off.Status__c == 'Delete' && rtIdName.get(off.RecordTypeId) == 'Student_Planned_Days_Off'){
                parentPDOIds.add(off.Parent_Planned_Day_Off__c);      
            }
        }
        
        if(old_PDORecValue.size() > 0 && new_PDORecValue.size() > 0){
            PlannedDaysOffHandler.updateChildPDOAndEventRecs(old_PDORecValue, new_PDORecValue);    
        }
        
        if(parentPDOIds.size() > 0){
            PlannedDaysOffHandler.updateParentPDO(parentPDOIds);     
        }
        
        if(notApprovedPDORecs.size() > 0){
            handler.notApprovedEmailNotificationToInsStd(notApprovedPDORecs);
        }
        
        if(insPDOsToCreateTask.size() > 0){
            PlannedDaysOffHandler.create_Update_DeleteTaskRelatedToProject(insPDOsToCreateTask, True, False, False);
        }
        if(insPDOsToUpdateTask.size() > 0){
            PlannedDaysOffHandler.create_Update_DeleteTaskRelatedToProject(insPDOsToUpdateTask, False, True, False);
        }
    }
    System.debug('::::pdoToCreateTask:::::'+pdoToCreateTask);
    System.debug('::::editDelPDOReqs:::::'+editDelPDOReqs);
    
    if(requestOffIds.size() > 0){
        handler.createActualPlannedDaysOff(requestOffIds);
    }
    
    if(pdoIds.size() > 0){
        handler.emailNotificationToInsStd(pdoIds);
    }
    
    if(pdoToCreateTask.size() > 0){
        handler.createTaskForSubmittingIns_Std(pdoToCreateTask);
    }
    
    if(editDelPDOReqs.size() > 0){
        handler.sendEmailToLTSManagerSupr(editDelPDOReqs, Trigger.oldMap);
    }            
}