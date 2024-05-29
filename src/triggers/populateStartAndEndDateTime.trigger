trigger populateStartAndEndDateTime on Events__c (before insert, before update,before delete,after update, after insert, after delete) {
    
    if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {      
        TimezoneUtilClass utilCls = new TimezoneUtilClass();
        for (Events__c evtRec : trigger.new) {  
            if (evtRec.Timezone__c != NULL && evtRec.Timezone__c != '' && evtRec.Date__c != NULL && (Trigger.isInsert || 
                (Trigger.isUpdate && (evtRec.Start_Time__c != Trigger.oldMap.get(evtRec.Id).Start_Time__c || evtRec.End_Time__c != Trigger.oldMap.get(evtRec.Id).End_Time__c || 
                evtRec.Timezone__c != Trigger.oldMap.get(evtRec.Id).Timezone__c || evtRec.Date__c != Trigger.oldMap.get(evtRec.Id).Date__c)))) {    
                       
                evtRec.Start_Date_Time__c = (evtRec.Start_Time__c != NULL && evtRec.Start_Time__c != '') ? utilCls.getDateTimeInGMT(evtRec.Timezone__c, evtRec.Date__c, evtRec.Start_Time__c, false) : evtRec.Start_Date_Time__c;
                evtRec.End_Date_Time__c = (evtRec.End_Time__c != NULL && evtRec.End_Time__c != '') ? utilCls.getDateTimeInGMT(evtRec.Timezone__c, evtRec.Date__c, evtRec.End_Time__c, true) : evtRec.End_Date_Time__c;
            }
        }
    }
    
    Set<Id> idsForConflictDelete = new Set<Id>();
    List<Events__c> updatedEventRecords = new List<Events__c>();
    Set<Id> eventIds = new Set<Id>();
    List<Events__c> eventsForZoomMeetingDeletion = new List<Events__c>(); //Added By Dhinesh - W-006013 - Zoom Integration - to delete the meeting when the events deleted or canceled
    List<Events__c> eventsForZoomMeetingUpdation = new List<Events__c>();
    Set<Id> eventIdstoDeleteLessonPlans = new Set<Id>(); //Added By Dhinesh - 22/02/2022 - Lesson Plan
    
    if(trigger.isBefore && trigger.isDelete) {
        for(Events__c eve : trigger.old){
            idsForConflictDelete.add(eve.Id);
            eventIdstoDeleteLessonPlans.add(eve.Id); //Added By Dhinesh - 22/02/2022 - Lesson Plan
        } 
    }
    //Added By Dhinesh - W-006013 - Zoom Integration - to delete the meeting when the events deleted or canceled
    if(trigger.isAfter && trigger.isDelete){
        Id onlineRoomId = ZoomUtil.getOnlineRoomId();
        for(Events__c eve : trigger.old){
        
            if(eve.Is_Meeting_Created__c){
            
                eventsForZoomMeetingDeletion.add(eve);
            }
        }
    }
        
    //Variables for To send an email notification to Instructor If LTS approved the Reschedule Event record
    List<Events__c> ltsApprovedEveRecs = new List<Events__c>();
    Set<Id> ltsApprovedCreatedByIds = new Set<Id>();
    
    //Variables for To send an email notification to Student If Instructor approved the Reschedule Event record
    List<Events__c> insApprovedEveRecs = new List<Events__c>();
    Set<Id> insApprovedCreatedByIds = new Set<Id>();
    
    //Variables for To send an email notification to LTS If Instructor rejected the Reschedule Event record
    List<Events__c> insRejectedEveRecs = new List<Events__c>();
    
    //Variables for To send an email notification to Student If the Instructor is Substituted while rescheduling an event record
    List<Events__c> insSubstitutedEveRecs = new List<Events__c>();
    Set<Id> insSubstitutedCreatedByIds = new Set<Id>();
    
    //Variables for To send an email notification to related users If there are Room Conflicts for DLS-Rosslyn, DLS-Herndon and DLS-Elkridge while rescheduling an event record
    List<Events__c> roomConflictEveRecs = new List<Events__c>();
    Set<Id> roomConflictParentEveIds = new Set<Id>();
    Set<Date> roomConflictEveDates = new Set<Date>();
    Set<Id> conflictRoomIds = new Set<Id>();
    
    EventHandler eveHandler = new EventHandler();
    TimezoneUtilClass utilCls = new TimezoneUtilClass();         
    
    //Added By HL
    Map<Id, DateTime> projIdAndOralExamDateTime = new Map<Id, DateTime>();
    Set<Id> instructorIds = new Set<Id>();
    //Added By Dhinesh - 10/02/2023 - Update Instructor zoom lincense when the event future event is rescheduled to today
    Set<Id> instructorsNeedsProZoomUser = new Set<Id>();
    
    // To delete the conflict records on Event status changes (Cancelled & Completed)
    if(trigger.isAfter && trigger.isUpdate){
        
        Id onlineRoomId = ZoomUtil.getOnlineRoomId();
                
        for(Events__c eve : trigger.new){
        
            if(eve.Status__c != trigger.oldMap.get(eve.Id).Status__c && (eve.Status__c == 'Canceled' || eve.Status__c == 'Completed')) {
                idsForConflictDelete.add(eve.Id);
            }
            
            if(eve.Status__c != trigger.oldMap.get(eve.Id).Status__c && eve.Status__c == 'Scheduled' && !eventIds.contains(eve.Id)) {
                updatedEventRecords.add(eve);
                eventIds.add(eve.Id);
            }
            
            //Added By Dhinesh - W-006013 - Zoom Integration - to delete the meeting when the events deleted or canceled
            if(eve.Status__c != trigger.oldMap.get(eve.Id).Status__c && eve.Status__c == 'Canceled' && eve.Is_Meeting_Created__c) {
                eventsForZoomMeetingDeletion.add(eve);
            }
            
            if(eve.Is_Meeting_Created__c && (eve.Start_Date_Time__c != trigger.oldMap.get(eve.Id).Start_Date_Time__c || eve.End_Date_Time__c != trigger.oldMap.get(eve.Id).End_Date_Time__c )){
                DateTime eveStartDateTime = eve.Start_Date_Time__c;
                if(date.newinstance(eveStartDateTime.year(), eveStartDateTime.month(), eveStartDateTime.day()) == System.today()){
                    instructorsNeedsProZoomUser.add(eve.Instructor__c);
                }
                eventsForZoomMeetingUpdation.add(eve);
            }
            
            if((eve.Room__c != null && eve.Room__c != trigger.oldMap.get(eve.Id).Room__c) || (eve.Start_Time__c != null && eve.Start_Time__c != trigger.oldMap.get(eve.Id).Start_Time__c) 
                || (eve.End_Time__c != null && eve.End_Time__c != trigger.oldMap.get(eve.Id).End_Time__c) || (eve.Instructor__c != null && eve.Instructor__c != trigger.oldMap.get(eve.Id).Instructor__c)
                || (eve.Date__c != null && eve.Date__c != trigger.oldMap.get(eve.Id).Date__c)){
                
                if(!eventIds.contains(eve.Id))
                    updatedEventRecords.add(eve);
            }
            
            // To send an email notification to Instructor If LTS approved the Reschedule Event record
            if((eve.Parent_Event__c != NULL || (eve.Parent_Event__c == NULL && eve.Is_Request_Event__c)) && eve.Approval_Status__c != trigger.oldMap.get(eve.Id).Approval_Status__c && 
                trigger.oldMap.get(eve.Id).Approval_Status__c == 'Pending LTS Approval' && 
                eve.Approval_Status__c == 'LTS Approved'){
                
                ltsApprovedEveRecs.add(eve);
                ltsApprovedCreatedByIds.add(eve.CreatedById);
            }
            
            // To send an email notification to Student If Instructor approved the Reschedule Event record
            if((eve.Parent_Event__c != NULL || (eve.Parent_Event__c == NULL && eve.Is_Request_Event__c)) && eve.Approval_Status__c != trigger.oldMap.get(eve.Id).Approval_Status__c && 
                trigger.oldMap.get(eve.Id).Approval_Status__c == 'LTS Approved' && eve.Approval_Status__c == 'Instructor Approved'){
                
                insApprovedEveRecs.add(eve);
                insApprovedCreatedByIds.add(eve.CreatedById);
            }
            
            // To send an email notification to LTS If Instructor rejected the Reschedule Event record
            if((eve.Parent_Event__c != NULL || (eve.Parent_Event__c == NULL && eve.Is_Request_Event__c)) && eve.Approval_Status__c != trigger.oldMap.get(eve.Id).Approval_Status__c && 
                trigger.oldMap.get(eve.Id).Approval_Status__c == 'LTS Approved' && eve.Approval_Status__c == 'Instructor Rejected'){
                
                insRejectedEveRecs.add(eve);
            }
            
            // To send an email notification to Student If the Instructor is Substituted while rescheduling an event record
            if((eve.Parent_Event__c != NULL || (eve.Parent_Event__c == NULL && eve.Is_Request_Event__c)) && eve.Instructor__c != trigger.oldMap.get(eve.Id).Instructor__c && 
                eve.Approval_Status__c != trigger.oldMap.get(eve.Id).Approval_Status__c && 
                trigger.oldMap.get(eve.Id).Approval_Status__c == 'Pending LTS Approval' && 
                eve.Approval_Status__c == 'LTS Approved' && eve.Parent_Status_Changed_To__c == 'Substituted'){
            
                insSubstitutedEveRecs.add(eve);
                insSubstitutedCreatedByIds.add(eve.CreatedById);
            }
            
            //To send an email notification to related users If there are Room Conflicts for DLS-Rosslyn, DLS-Herndon and DLS-Elkridge while rescheduling an event record
            if((eve.Parent_Event__c != NULL || (eve.Parent_Event__c == NULL && eve.Is_Request_Event__c)) && eve.Approval_Status__c != trigger.oldMap.get(eve.Id).Approval_Status__c &&
                trigger.oldMap.get(eve.Id).Approval_Status__c == 'LTS Approved' && 
                eve.Approval_Status__c == 'Instructor Approved' && eve.Room__c != NULL){
            
                roomConflictEveRecs.add(eve);
                if(eve.Parent_Event__c != NULL){
                    roomConflictParentEveIds.add(eve.Parent_Event__c);
                }
                roomConflictEveDates.add(eve.Date__c);
                conflictRoomIds.add(eve.Room__c);
            }
            
            // Added By HL on Mar 18 2020
            // To update Oral_Exam_Date_Time__c field for Contact Assignment and Opportunity when Date__c or Start_Time__c field of Event record is updated if Event's project recordtype Testing Project
            if(eve.Project_RecordType_Name__c == 'Testing_Projects' && eve.Instructor__c != NULL && 
                eve.Project__c != NULL && String.isNotBlank(eve.Status__c) && eve.Status__c == 'Scheduled' && 
                eve.Date__c != null && eve.Start_Time__c != null && ((eve.Date__c != trigger.oldMap.get(eve.Id).Date__c)|| 
                (eve.Start_Time__c != trigger.oldMap.get(eve.Id).Start_Time__c))){
                                            
                projIdAndOralExamDateTime.put(eve.Project__c, utilCls.getDateTimeInGMT(eve.Timezone__c, eve.Date__c, eve.Start_Time__c, false));
                instructorIds.add(eve.Instructor__c);
            }
        }        
    }
    
    system.debug('::::event::trigger::idsForConflictDelete:::'+idsForConflictDelete.size());
    system.debug('event:::trigger::updatedEventRecords::::::::'+updatedEventRecords.size());
        
    if(idsForConflictDelete.size() > 0){
        eveHandler.deleteConflictRecords(idsForConflictDelete);
    }
    
    if(updatedEventRecords.size() > 0){
        eveHandler.createEventConflictRecords(updatedEventRecords);
    }
    
    if(ltsApprovedEveRecs.size() > 0 && ltsApprovedCreatedByIds.size() > 0){
        eveHandler.sendAnEmailToInstructorAfterLTSApproval(ltsApprovedEveRecs, ltsApprovedCreatedByIds);
    }
    
    if(insApprovedEveRecs.size() > 0 && insApprovedCreatedByIds.size() > 0){
        eveHandler.sendAnEmailToStudentAfterInsApproval(insApprovedEveRecs, insApprovedCreatedByIds);
    }
    
    if(insRejectedEveRecs.size() > 0){
        eveHandler.sendAnEmailToLTSAfterInsRejection(insRejectedEveRecs);
    }
    
    if(insSubstitutedEveRecs.size() > 0 && insSubstitutedCreatedByIds.size() > 0){
        eveHandler.sendAnEmailToStd_InstructorSubstituted(insSubstitutedEveRecs, insSubstitutedCreatedByIds);
    }
    
    if(roomConflictEveRecs.size() > 0 && roomConflictEveDates.size() > 0 && conflictRoomIds.size() > 0){
        if(roomConflictParentEveIds.size() > 0){
            eveHandler.sendAnEmailforRoomConflict(roomConflictEveRecs, roomConflictParentEveIds, roomConflictEveDates, conflictRoomIds);
        }else{
            eveHandler.sendAnEmailforRoomConflict(roomConflictEveRecs, null, roomConflictEveDates, conflictRoomIds);
        }
    }
    
    // To send an email when the event is created for Substitute and Extended schedule
    if(trigger.isAfter && trigger.isInsert) {
        Map<Id, List<Events__c>> schIdEveMap = new Map<Id, List<Events__c>>();
        
        List<Events__c> eveRecsForSubmitAppPro = new List<Events__c>();
        List<Events__c> eveRecsForInsSubstitution = new List<Events__c>();
        
        for(Events__c eve : trigger.new) {
              
            if(eve.Schedule__c != null) {
                
                if(!schIdEveMap.containsKey(eve.Schedule__c)) {
                    schIdEveMap.put(eve.Schedule__c, new List<Events__c>{eve});
                } else {
                    schIdEveMap.get(eve.Schedule__c).add(eve);
                }
            }
            
            // Added By HL on August 10 2020
            // Work Item : W-003065 - Add ability for instructors and students to edit and reschedule events in the community
            // Work Item: W-006142 - Request an Event feature for Student Community
            if((eve.Parent_Event__c != NULL || (eve.Parent_Event__c == NULL && eve.Is_Request_Event__c)) && String.isNotBlank(eve.Approval_Status__c) && 
                eve.Approval_Status__c == 'Pending LTS Approval' && String.isNotBlank(eve.Parent_Status_Changed_To__c) &&
                eve.Parent_Status_Changed_To__c == 'Rescheduled'){
            
                eveRecsForSubmitAppPro.add(eve);
            }
            
            // Added By HL on Aug 14 2020
            // To send an email notification to LTS If the Instructor has conflict while rescheduling an event record
            if((eve.Parent_Event__c != NULL || (eve.Parent_Event__c == NULL && eve.Is_Request_Event__c)) && String.isNotBlank(eve.Approval_Status__c) && 
                eve.Approval_Status__c == 'Pending LTS Approval' && String.isNotBlank(eve.Parent_Status_Changed_To__c) &&
                eve.Parent_Status_Changed_To__c == 'Substituted'){
            
                eveRecsForInsSubstitution.add(eve);
            }
            
            // Added By HL on Apr 15 2021
            // To update Oral_Exam_Date_Time__c field for Contact Assignment and Opportunity when Event record is created if Event's project recordtype Testing Project
            if(eve.Project_RecordType_Name__c == 'Testing_Projects' && eve.Instructor__c != NULL && eve.Project__c != NULL && 
                String.isNotBlank(eve.Status__c) && eve.Status__c == 'Scheduled' && 
                eve.Date__c != null && eve.Start_Time__c != null){
                                
                projIdAndOralExamDateTime.put(eve.Project__c, utilCls.getDateTimeInGMT(eve.Timezone__c, eve.Date__c, eve.Start_Time__c, false));
                instructorIds.add(eve.Instructor__c);
            }
            
            //Modified By Dhinesh - 12/07/2023 - W-007840 - To handle zoom license upgrade if the event created for today
            if(eve.Start_Date_Time__c != null && Date.newinstance(eve.Start_Date_Time__c.year(), eve.Start_Date_Time__c.month(), eve.Start_Date_Time__c.day()) == System.today()){
                instructorsNeedsProZoomUser.add(eve.Instructor__c);                
            }
        }
        
        if(schIdEveMap != null && schIdEveMap.size() > 0) {
            SendEmailsForUpdatedFields_Handler sendMail = new SendEmailsForUpdatedFields_Handler();
            //sendMail.sendMailForSubSchedule(schIdEveMap);
            //sendMail.sendMailForExtendedSchedule(schId);
        }
        
        if(eveRecsForSubmitAppPro != NULL && eveRecsForSubmitAppPro.size() > 0){
        
            eveHandler.sendAnEmailToLTSForApproval(eveRecsForSubmitAppPro);
        }
        
        if(eveRecsForInsSubstitution != NULL && eveRecsForInsSubstitution.size() > 0){
        
            eveHandler.sendAnEmailToLTS_InstructorConflict(eveRecsForInsSubstitution);
        }
    }
    
    //Added By Dhinesh - W-006013 - Zoom Integration - to delete the meeting when the events deleted or canceled
    if(eventsForZoomMeetingDeletion.size() > 0){
        System_Values__c sysVal = System_Values__c.getValues('Batch size for zoom meeting deletion');
        ZoomMeetingDeletionBatch meetingDeletionBatch = new ZoomMeetingDeletionBatch(JSON.serialize(eventsForZoomMeetingDeletion), Trigger.isUpdate);
        database.executeBatch(meetingDeletionBatch, Integer.valueOf(sysVal.Value__c));
    }   
    
    if(projIdAndOralExamDateTime != NULL && projIdAndOralExamDateTime.size() > 0){
        eveHandler.updateParentRecords(projIdAndOralExamDateTime, instructorIds);  
    } 
    
    //Modified By Dhinesh - 12/07/2023 - W-007840 - To handle zoom license upgrade if the event created for today
    if(instructorsNeedsProZoomUser.size() > 0){
        ZoomUtil.checkContactForZoomUserAndLicenseType(instructorsNeedsProZoomUser,instructorsNeedsProZoomUser);
    }
    
    if(eventsForZoomMeetingUpdation.size() > 0){        
        ZoomUtil.UpdateZoomMeetings(JSON.serialize(eventsForZoomMeetingUpdation));
    }
    
    
    //Added By Dhinesh - 22/02/2022 - Lesson Plan
    Set<Id> eventIdsToCreateLessonPlan = new Set<Id>();
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        
        Map<Id, Date> eveIdAndDate = new Map<Id, Date>();
        
        for(Events__c eve : trigger.new){
            
            //Modified by Dhinesh - 17/2/2023 - W-007719 - Fix Lesson Plans created without Instructors            
            if(eve.Status__c == 'Scheduled' && eve.Instructor__c != null && (Trigger.isInsert || (Trigger.oldMap.get(eve.Id).Status__c != eve.Status__c || Trigger.oldMap.get(eve.Id).Instructor__c != eve.Instructor__c))){
                eventIdsToCreateLessonPlan.add(eve.Id);
            }
            
            // May 21 2024 - W-008056 : Request to Update Lesson Plan Date When Related Event Date isChanged
            if(Trigger.isUpdate && eve.Status__c == 'Scheduled' && eve.Instructor__c != null && eve.Date__c != Trigger.oldMap.get(eve.Id).Date__c){
                eveIdAndDate.put(eve.Id, eve.Date__c);        
            }
        }
        
        if(eveIdAndDate.size() > 0){
            EventHandler.updateLessonPlanDate(eveIdAndDate);
        }
    }
    
    if(eventIdsToCreateLessonPlan.size() > 0){
        LessonPlanCreationBatch st = new LessonPlanCreationBatch(eventIdsToCreateLessonPlan);
        database.executeBatch(st, 200);
    }
    
    if(eventIdstoDeleteLessonPlans.size() > 0){
        Map<Id, Lesson_Plan__c> lessonPlanMap = new Map<Id, Lesson_Plan__c>([SELECT Id FROM Lesson_Plan__c WHERE Event__c IN :eventIdstoDeleteLessonPlans]);
        if(lessonPlanMap.size() > 0){
            LessonPlanDeletionBatch st = new LessonPlanDeletionBatch(lessonPlanMap.keySet());
            database.executeBatch(st, 200);
        }
    }
}