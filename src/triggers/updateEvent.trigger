trigger updateEvent on Schedule__c(after insert, after update, before insert, before update, before delete, after delete) {
      
    // Added by E. Keerthika to send the mail when the scheduled is created without the type as 'Regular' on 21st, August 2018
    if(trigger.isAfter && trigger.isInsert) {
       
        Map<String, List<Schedule__c>> schTypeRecMap = new Map<String, List<Schedule__c>>();
        Set<Id> parSchId = new Set<Id>();
        for(Schedule__c sch : trigger.new) {
           
            if(sch.Prior_Schedule__c != null && sch.Schedule_Type__c != null && sch.Schedule_Type__c != 'Regular') {
                if(!schTypeRecMap.containsKey(sch.Schedule_Type__c)) {
                    schTypeRecMap.put(sch.Schedule_Type__c, new List<Schedule__c>());
                }
                schTypeRecMap.get(sch.Schedule_Type__c).add(sch);
                parSchId.add(sch.Prior_Schedule__c);
            }
        }
        
        if(schTypeRecMap != null && schTypeRecMap.size() > 0 && parSchId != null && parSchId.size() > 0) {
            try {
                SendEmailsForUpdatedFields_Handler se = new SendEmailsForUpdatedFields_Handler();
                se.sendMailSchUpdate(schTypeRecMap, parSchId, null);
            } catch(exception ex) {
                System.debug(':::EXCEPTION:::'+ex.getMessage());
            }
        }
       
    }
    
    if (trigger.isBefore && (trigger.isInsert || trigger.isUpdate)) {  
    
        TimezoneUtilClass utilCls = new TimezoneUtilClass();
        Set<String> daysSet = new Set<String>(); 
        Map<String,String> dayFullNameMap = new Map<String,String>{'M' => 'Mondays', 'T' => 'Tuesdays', 'W' => 'Wednesdays', 'Th' => 'Thursdays', 'F' => 'Fridays', 'Sat' => 'Saturdays', 'S' => 'Sundays'};
        
        Set<Id> roomIds = new Set<Id>();
        Map<Id,Id> roomIdLocationId = new Map<Id,Id>();
        Set<Id> locationIds = new Set<Id>();
        Map<Id,String> locationIdNameMap = new Map<Id,String>();
        
        Set<Id> proIdsForLocation = new Set<Id>();
        Set<Id> oppIdsForLocation = new Set<Id>();//Modified by Dhinesh - W-006636 - Room population for opportunity related schedules
        Set<Id> nonDLSSiteProIds = new Set<Id>();
        Set<Id> onlineProIds = new Set<Id>();
        Map<String,Id> keyRoomId = new Map<String,Id>();
        //Set<Id> checkStudentAvaiableONActivation = new Set<Id>();
        
        for (Schedule__c sch : trigger.new) {
            daysSet = new Set<String>(); 
            if (sch.Timezone__c != NULL && sch.Timezone__c != '') { 
                sch.Start_Date_Time__c = (sch.Start_Date__c != NULl && sch.Start_Time__c != NULL && sch.Start_Time__c != '') ? utilCls.getDateTimeInGMT(sch.Timezone__c, sch.Start_Date__c, sch.Start_Time__c, false) : sch.Start_Date_Time__c;
                sch.End_Date_Time__c = (sch.End_Date__c != NULl && sch.End_Time__c != NULL && sch.End_Time__c != '') ? utilCls.getDateTimeInGMT(sch.Timezone__c, sch.End_Date__c, sch.End_Time__c, true) : sch.End_Date_Time__c;
            }
            
            // To populate value in Days field
            String days;
            if (Trigger.isInsert || (Trigger.IsUpdate && ( trigger.oldMap.get(sch.Id).Monday__c != sch.Monday__c || trigger.oldMap.get(sch.Id).Tuesday__c != sch.Tuesday__c ||
                     trigger.oldMap.get(sch.Id).Wednesday__c != sch.Wednesday__c || trigger.oldMap.get(sch.Id).Thursday__c != sch.Thursday__c || trigger.oldMap.get(sch.Id).Friday__c != sch.Friday__c || 
                          trigger.oldMap.get(sch.Id).Saturday__c != sch.Saturday__c || trigger.oldMap.get(sch.Id).Sunday__c != sch.Sunday__c))) {
                          
                if (sch.Monday__c) daysSet.add('M');
                if (sch.Tuesday__c) daysSet.add('T'); 
                if (sch.Wednesday__c) daysSet.add('W');
                if (sch.Thursday__c) daysSet.add('Th');
                if (sch.Friday__c) daysSet.add('F');
                if (sch.Saturday__c) daysSet.add('Sat');
                if (sch.Sunday__c) daysSet.add('S');
            }
            //System.debug('DaysSet::::'+daysSet); 
            if( daysSet != null && daysSet.size() > 0 ) {
                Integer i = 0;
                sch.Days__c = '';
                if ((daysSet.Contains('M') && daysSet.Contains('T') && daysSet.Contains('W') && daysSet.Contains('Th') && daysSet.Contains('F')) && (!daysSet.Contains('Sat') && !daysSet.Contains('S'))) {
                    
                    sch.Days__c = 'M-F';
                    sch.Days_for_FBI_WOR_Form_Hide__c = 'Monday - Friday';
                } else {
                    for (String d : daysSet) {
                        if ( i == 0 ) {
                            sch.Days_for_FBI_WOR_Form_Hide__c = dayFullNameMap.get(d);
                            sch.Days__c += d;
                        } else {
                            sch.Days_for_FBI_WOR_Form_Hide__c = sch.Days_for_FBI_WOR_Form_Hide__c +', '+ dayFullNameMap.get(d);
                            sch.Days__c = sch.Days__c + ';' + d;
                        }
                        i = i+1;
                    }
                }
            }
            
            // Update Cancelled Date field based on the status change
            // Added by NS on OCT 3 2018
            if((trigger.isInsert || (trigger.isUpdate && (trigger.oldMap.get(sch.Id).Status__c != sch.Status__c))) && sch.Status__c == 'Canceled' && sch.Cancellation_Date__c == null){
                sch.Cancellation_Date__c = system.today();
            }
            
            // Added by NS on OCT 12 2018
            // To populate the Training Location lookup values based on the Room selected
            if((trigger.isInsert || (trigger.isUpdate && (trigger.oldMap.get(sch.Id).Room__c != sch.Room__c))) && sch.Room__c != null ){
                roomIds.add(sch.Room__c);
            }
            
            // To populate online value in training location pikclist value if the location lookup is DLS - Online
            if((trigger.isInsert || (trigger.isUpdate && (trigger.oldMap.get(sch.Id).Training_Location_LU__c != sch.Training_Location_LU__c))) && sch.Training_Location_LU__c != null) {
                locationIds.add(sch.Training_Location_LU__c);
            }
            
            //To populate schedule location based on related projects location type on creation
            //W-004825
            if(trigger.isInsert && sch.Project__c != null){
                proIdsForLocation.add(sch.Project__c);
            }
            
            if(trigger.isInsert && sch.Opportunity__c != null){
                oppIdsForLocation.add(sch.Opportunity__c);
            }       
            
            /*if(sch.Project__c != null && sch.Status__c == 'Active' && (trigger.isInsert || (trigger.isUpdate && trigger.oldMap.get(sch.Id).Status__c != sch.Status__c))) {
                  checkStudentAvaiableONActivation.add(sch.Project__c);
            }*/
        }
        
        /*if(checkStudentAvaiableONActivation.size() > 0){
            Set<Id> projectHasStudent = new Set<Id>();
            for(Contact_Assignments__c conAss : [SELECT Id, Project__c FROM Contact_Assignments__c WHERE Project__c IN :checkStudentAvaiableONActivation AND RecordType.DeveloperName = 'Student' AND Status__c IN ('Active', 'Planned')]){
                projectHasStudent.add(conAss.Project__c);
            }
            
            for(Schedule__c sch : trigger.new){
               
                if(!projectHasStudent.contains(sch.Project__c)){
                    sch.addError('Schedule cannot be activated since student not available for the project.');
                }
            } 
        }*/
        
        if(roomIds.size() > 0){
            for(Room__c room : [SELECT Id,Name,Location_n__c FROM Room__c WHERE Id IN :roomIds AND Location_n__c != null]){
                if(!roomIdLocationId.containsKey(room.Id))
                    roomIdLocationId.put(room.Id,room.Location_n__c);
            }
        }
        
        if(locationIds.size() > 0){
            for(MTT_Location__c loc : [SELECT Id,Name FROM MTT_Location__c WHERE Id IN :locationIds]){
                locationIdNameMap.put(loc.Id,loc.Name);
            }
        }
        
        //Qry projects location
        //W-004825
        if(proIdsForLocation.size() > 0){
            
            for(AcctSeed__Project__c pro :  [SELECT Id,Name,Training_Location__c,Training_Location__r.Name,Training_Location__r.RecordType.DeveloperName 
                                                FROM AcctSeed__Project__c WHERE Id IN :proIdsForLocation]){
            
                if(pro.Training_Location__c != null && pro.Training_Location__r.RecordType.DeveloperName != 'DLS_Site'){
                    nonDLSSiteProIds.add(pro.Id);
                }
                
                if(pro.Training_Location__c != null && pro.Training_Location__r.Name == 'DLS - Online'){
                    onlineProIds.add(pro.Id);
                }
            }                                    
        }
        
        //Modified by Dhinesh - W-006636 - Room population for opportunity related schedules
        if(oppIdsForLocation.size() > 0){
            for(Opportunity opp :  [SELECT Id,Name,Location__c,Location__r.Name,Location__r.RecordType.DeveloperName 
                                                FROM Opportunity WHERE Id IN :oppIdsForLocation]){
            
                if(opp.Location__c != null && opp.Location__r.RecordType.DeveloperName != 'DLS_Site'){
                    nonDLSSiteProIds.add(opp.Id);
                }
                
                if(opp.Location__c != null && opp.Location__r.Name == 'DLS - Online'){
                    onlineProIds.add(opp.Id);
                }
            }   
        }
        
        for(Room__c room : [SELECT Id,Name FROM Room__c WHERE Name IN ('Client-Site','Zoom - Online')]){
            keyRoomId.put(room.Name,room.Id);
        }
            
        // For Training Location LU & Picklist value population
        for (Schedule__c sch : trigger.new) {
            if((trigger.isInsert || (trigger.isUpdate && (trigger.oldMap.get(sch.Id).Room__c != sch.Room__c))) && sch.Room__c != null){
                if(roomIdLocationId.containsKey(sch.Room__c) && roomIdLocationId.get(sch.Room__c) != null){
                    sch.Training_Location_LU__c = roomIdLocationId.get(sch.Room__c);
                }
            }
            
            if((trigger.isInsert || (trigger.isUpdate && (trigger.oldMap.get(sch.Id).Training_Location_LU__c != sch.Training_Location_LU__c))) && sch.Training_Location_LU__c != null) {
               if(locationIdNameMap.containsKey(sch.Training_Location_LU__c) && locationIdNameMap.get(sch.Training_Location_LU__c) == 'DLS - Online')
                sch.Training_Location__c = 'Online';
            }
            
            //Added sch.Room__c == null condition By Dhinesh - 20-10-2021 - W-007103 - ignore the schedule room population if the physical room assigned
            //W-004825
            if(trigger.isInsert && sch.Project__c != null){
                
                if(nonDLSSiteProIds.contains(sch.Project__c) && sch.Room__c == null){
                    sch.Room__c = keyRoomId.containsKey('Client-Site') ? keyRoomId.get('Client-Site') : null;
                }
                
                if(onlineProIds.contains(sch.Project__c) && sch.Room__c == null){
                    sch.Room__c = keyRoomId.containsKey('Zoom - Online') ? keyRoomId.get('Zoom - Online') : null;
                }
            }
            
            //Modified by Dhinesh - W-006636 - Room population for opportunity related schedules
            if(trigger.isInsert && sch.Opportunity__c != null && sch.Project__c == null){
                
                if(nonDLSSiteProIds.contains(sch.Opportunity__c) && sch.Room__c == null){
                    sch.Room__c = keyRoomId.containsKey('Client-Site') ? keyRoomId.get('Client-Site') : null;
                }
                
                if(onlineProIds.contains(sch.Opportunity__c) && sch.Room__c == null){
                    sch.Room__c = keyRoomId.containsKey('Zoom - Online') ? keyRoomId.get('Zoom - Online') : null;
                }
            }
        }
    } 
    
    // Logic to update the All_Active_Rooms__c field in Project Object.   
    Set<Id> projIds = new Set<Id>();
    List<AcctSeed__Project__c> projsToUpd = new List<AcctSeed__Project__c>();
    Map<Id,String> projIdRoomStrMap = new Map<Id,String>();
    
    // To Create / Delete Events based on the Schedule End Date change
    // Added by NS on Sep 25 2018
    Map<Id,Date> schIdEndDate = new Map<Id,Date>();
    Set<Id> schIds = new Set<Id>();
    Map<Id,Date> schIdStartDate = new Map<Id,Date>();
    
    //Ids to delete cancelled / On Hold / Completed schedule status related event records
    Map<Id,Date> cancelOnHoldSchIdsDate = new Map<Id,Date>();
    
    //W-004823
    Map<Id,String> priorSchIdEndDateString = new Map<Id,String>();
    
    if(trigger.isAfter && (trigger.isUpdate || trigger.isDelete)) {
        
        // For update thr are possibilities of the following,
        // the Room changes from null to value, old Value to new Value or old value to null
        // the Project assigned newly or Changes
        // the Status will be changed to Active or someother. 
        if( trigger.isUpdate ) {
            
            List<Schedule__c> newSchList = new List<Schedule__c>();
            Map<Id,Schedule__c> oldSchMap = new Map<Id,Schedule__c>();
            Set<Id> parId = new Set<Id>();
            Map<Id, Schedule__c> schIdMap = new Map<Id, Schedule__c>();
            Map<String, List<Schedule__c>> extendedSchMap = new Map<String, List<Schedule__c>>{'Extended' => new List<Schedule__c>()};
            Map<Id, Schedule__c> afterEventCreationExSchMap = new Map<Id, Schedule__c>();
            Map<Id,Schedule__c> oldExtendedSchMap = new Map<Id,Schedule__c>();
            
            //To Create Assessment Report after First Schedule Activation
            Set<Id> schIdsForAss = new Set<Id>();
            Set<Id> actProjIds = new Set<Id>();
            Set<Id> arProjIds = new Set<Id>();
            
            // To update the Instructor in the Assessment Report when the Instructor is updated in the Schedule
            Map<Id, Id> priorSchIdAndInsId = new Map<Id, Id>();
                        
            //Added By Dhinesh - W-006013 - Zoom Integration - to check the zoom user license type when project changed to active or ended
            Set<Id> instructorIdsForZoomUserCheck = new Set<Id>();
            Id onlineRoomId = ZoomUtil.getOnlineRoomId();
            
            Map<Id, String> priorSchIdAndSDEDStr = new Map<Id, String>();
            Map<Id, Date> insIdAndEndDate = new Map<Id, Date>();
            Set<Id> projIdsToUpdateCAs = new Set<Id>();
            Set<Id> pre = new Set<Id>();
            
            //Added By SivaPrasanth - #W-007667
            Set<Id> schRelProIds = new Set<Id>();
            Set<Id> schRelProTaskIds = new Set<Id>();
            Set<Id> schLTIds = new Set<Id>();
            Set<Id> schLTPriorIds = new Set<Id>();
            Set<Id> cancelRelSchLT = new Set<Id>();

            
            for(Schedule__c sc : trigger.new) {
            
                Boolean parSch = false;
                parId = EventManagementController.parentIds;
                
                // W-007736 - (Urgent) Room Change Action on Schedule Creates Duplicate Prep Schedules
                if(sc.Project_Task_Stage__c == 'Language Training' && (trigger.oldMap.get(sc.Id).Status__c != sc.Status__c && sc.Status__c == 'Canceled')){
                    cancelRelSchLT.add(sc.Id);
                }
                
                 //Added By SivaPrasanth - #W-007667 - Create Preparation LT schedule from parent LT schedule.
                if(sc.Project_Task_Stage__c == 'Language Training' && (trigger.oldMap.get(sc.Id).Status__c != sc.Status__c && sc.Status__c == 'Active')){
                    schLTIds.add(sc.Id);
                  
                    if(sc.Project__c != null){
                        schRelProIds.add(sc.Project__c);
                    }
                    if(sc.Project_Task__c != null){
                        schRelProTaskIds.add(sc.Project_Task__c);
                    }
                    if(sc.Prior_Schedule__c != null){
                        schLTPriorIds.add(sc.Prior_Schedule__c);
                    }
                }
                
                // To avoid sending mail for the updation of parent schedule (When schedule or instructor is changed)
                if(parId != null && parId.size() > 0 && parId.contains(sc.Id)) {
                    parSch = true;
                }
                
                // Only for Extended schedule type
                if(sc.Schedule_Type__c == 'Extended' && trigger.oldMap.get(sc.Id).End_Date__c != sc.End_Date__c) { //&& trigger.oldMap.get(sc.Id).Schedule_Type__c != 'Extended' 
                    extendedSchMap.get('Extended').add(sc);
                    oldExtendedSchMap.put(sc.Id, trigger.Oldmap.get(sc.Id));
                }
                
                // To update the Event Room and Instructor if the Room and Instructor of the schedule is changed added by E. Keerthika on 25-09-2018
                if((trigger.oldMap.get(sc.Id).Instructor__c == null && trigger.oldMap.get(sc.Id).Instructor__c != sc.Instructor__c) || 
                  (trigger.oldMap.get(sc.Id).room__c == null && trigger.oldMap.get(sc.Id).room__c != sc.room__c)) {
                    schIdMap.put(sc.Id, sc);
                }
               
                if(!parSch) {
                    
                    if( sc.Project__c != null && ( ( sc.Room__c != trigger.oldMap.get(sc.Id).Room__c && sc.Status__c == 'Active') || sc.Project__c != trigger.oldMap.get(sc.Id).Project__c || (sc.Room__c != null && sc.Status__c != trigger.oldMap.get(sc.Id).Status__c ) ) ) {
                        projIds.add(sc.Project__c);
                    }
                    
                    // Added to skip the email sending process for the below locations
                    if(sc.Opp_Proj_Location__c != 'DLS - Herndon' && sc.Opp_Proj_Location__c != 'DLS - Elkridge' && !oldExtendedSchMap.containsKey(sc.Id) && !SendEmailsForUpdatedFields_Handler.extendedSchIdWithMailContentMap.containsKey(sc.Id)) {
                        newSchList.add(sc);
                        oldSchMap.put(sc.Id, trigger.Oldmap.get(sc.Id));
                    }
                }
                
                //if the start date is changed & new start date is greater than old one the delete excess events
                //work item no: W-003760
                if(sc.Status__c == 'Active' && sc.Start_Date__c > trigger.oldMap.get(sc.Id).Start_Date__c){
                    schIdStartDate.put(sc.Id,sc.Start_Date__c);
                }
                
                //check for the end date change
                // End date is changed other than the Schedule component we are doing the delete event action.  
                // Added "isFromPrepScheduleUpdate" condition on Aug 03 2023 : W-007858 - LT Schedule Activation Created Duplicate LT Events            
                if(sc.Status__c == 'Active' && CustomButtonService.isFromManageProjectStatus && sc.Status__c != trigger.oldMap.get(sc.Id).Status__c && !ScheduleTriggerHandler.isFromPrepScheduleUpdate){
                     schIds.add(sc.Id);
                }
                if(sc.Status__c == 'Active' && sc.End_Date__c > trigger.oldMap.get(sc.Id).End_Date__c 
                    && !sc.Varied_Day__c /*&& !sc.Varied_Time__c */&& !sc.Travel_Required__c){
                    
                    schIds.add(sc.Id);
                    
                }else if(sc.Status__c == 'Active' && sc.End_Date__c < trigger.oldMap.get(sc.Id).End_Date__c && !ScheduleTriggerHandler.isFromScheduleComponent){
                    schIdEndDate.put(sc.Id,sc.End_Date__c);
                }else if(sc.Status__c == 'Completed' && sc.End_Date__c != trigger.oldMap.get(sc.Id).End_Date__c && CustomButtonService.isFromManageProjectStatus){    // Added by NS on May 10 2019, to delete events after current end dates
                    schIdEndDate.put(sc.Id,sc.End_Date__c);
                }
                
                // after event creation when the schedule date is extended 
                if((SendEmailsForUpdatedFields_Handler.extendedSchIdWithMailContentMap.containsKey(sc.Id) && sc.Schedule_Type__c == 'Extended' 
                        && sc.Total_Events__c != Trigger.oldMap.get(sc.Id).Total_Events__c && sc.Total_Hours__c != Trigger.oldMap.get(sc.Id).Total_Hours__c) || Test.isRunningTest()) {
                    afterEventCreationExSchMap.put(sc.Id, sc);
                }
                // To update Prior Schedule Event's status as Scheduled if Substitute Schedule is Cancelled
                if(sc.Status__c == 'Canceled' && sc.Status__c != Trigger.oldMap.get(sc.Id).Status__c && 
                    sc.Schedule_Type__c == 'Substitute' && sc.Prior_Schedule__c != NULL){
                    
                    priorSchIdAndSDEDStr.put(sc.Prior_Schedule__c,(sc.Start_Date__c+'~'+sc.End_Date__c));    
                }
                //for cancelled schedule related changes
                if(sc.Status__c == 'Canceled' && sc.Status__c != trigger.oldMap.get(sc.Id).Status__c){
                    //If the schedule is already started then consider the Canceled date for event delete action
                    //If not consider start date of schedule, beacuse new schedule is created with same date interval
                    if(sc.Start_Date__c >= System.today() && (sc.Cancellation_Reason__c == 'Schedule Change' 
                        || sc.Cancellation_Reason__c == 'Replace Instructor' || sc.Cancellation_Reason__c == 'Room Change')){
                        cancelOnHoldSchIdsDate.put(sc.Id,sc.Start_Date__c);
                    }else {
                        cancelOnHoldSchIdsDate.put(sc.Id,sc.Cancellation_Date__c);
                    }
                }
                
                //For On Hold Schedule records changes
                if(sc.Status__c == 'On Hold' && sc.Status__c != trigger.oldMap.get(sc.Id).Status__c){
                    cancelOnHoldSchIdsDate.put(sc.Id,sc.On_Hold_Date__c);
                }
                
                //For Completed schedule records changes from schedule complete action
                if(sc.Status__c == 'Completed' && sc.Status__c != trigger.oldMap.get(sc.Id).Status__c && sc.End_Date__c != trigger.oldMap.get(sc.Id).End_Date__c){
                    cancelOnHoldSchIdsDate.put(sc.Id,sc.End_Date__c);
                }
                
                //If subsitute schedule end date is updated & then update their prior shedule events to scheduled for those particular dates
                //W-004823 - a task
                if(sc.Schedule_Type__c == 'Substitute' && trigger.oldMap.get(sc.Id).End_Date__c != sc.End_Date__c 
                    && trigger.oldMap.get(sc.Id).End_Date__c > sc.End_Date__c){
                    
                    priorSchIdEndDateString.put(sc.Prior_Schedule__c,(sc.End_Date__c+'~'+trigger.oldMap.get(sc.Id).End_Date__c));
                }
                
                //To Create Assessment Report after First Schedule Activation
                if(sc.Status__c == 'Active' && sc.Instructor__c != null && 
                   ((trigger.oldMap.get(sc.Id).Instructor__c == null) || 
                    ((sc.Varied_Day__c && trigger.oldMap.get(sc.Id).Status__c != sc.Status__c) || 
                     (!sc.Varied_Day__c && trigger.oldMap.get(sc.Id).Total_Hours__c != sc.Total_Hours__c 
                     && trigger.oldMap.get(sc.Id).Total_Hours__c == 0 && sc.Total_Hours__c > 0)
                    )) 
                  ){
                    schIdsForAss.add(sc.Id);
                    actProjIds.add(sc.Project__c);
                }
                
                // To update the Instructor in the Assessment Report when the Instructor is updated in the Schedule
                if(sc.Prior_Schedule__c != NULL && sc.Instructor__c != NULL && sc.Schedule_Type__c == 'Replace Instructor' && sc.Status__c == 'Active' && trigger.oldMap.get(sc.Id).Status__c != sc.Status__c && sc.Project__c != NULL){
                    
                    priorSchIdAndInsId.put(sc.Prior_Schedule__c, sc.Instructor__c);
                }
                
                //Added By Dhinesh - W-006013 - Zoom Integration - to check the zoom user license type when project changed to active or ended
                if(sc.Project_Task_Stage__c != 'Preparation time' && sc.Project__c != null && sc.Instructor__c != null && sc.Instructor_Contact_Record_Type__c != 'DLS_Employee' && ((onlineRoomId != null && onlineRoomId == sc.Room__c) || sc.Create_Zoom_Meetings__c) && sc.Status__c == 'Active' && (trigger.oldMap.get(sc.Id).Room__c != sc.Room__c || trigger.oldMap.get(sc.Id).Status__c != sc.Status__c || sc.Instructor__c != trigger.oldMap.get(sc.Id).Instructor__c)){
                    instructorIdsForZoomUserCheck.add(sc.Instructor__c);                    
                }
                // To update Substitute Schedule (Instructor)Contact Assignment's End Date as Substitute Schedule's End Date
                if(sc.Prior_Schedule__c != NULL && sc.Instructor__c != NULL && sc.Schedule_Type__c == 'Substitute' && sc.Status__c == 'Active' && trigger.oldMap.get(sc.Id).Status__c != sc.Status__c && sc.Project__c != NULL && sc.End_Date__c != NULL){
                    
                    insIdAndEndDate.put(sc.Instructor__c, sc.End_Date__c);
                    projIdsToUpdateCAs.add(sc.Project__c);
                }
            }
            
            if(insIdAndEndDate.size() > 0 && projIdsToUpdateCAs.size() > 0){
                ScheduleTriggerHandler.update_SubstituteScheduleCA(projIdsToUpdateCAs, insIdAndEndDate);
            }
            //Added By Dhinesh - W-006013 - Zoom Integration - to check the zoom user license type when project changed to active or ended
            if(instructorIdsForZoomUserCheck.size() > 0){
                
                ProjectTrigger_Handler.checkZoomUserLicenseTypesForInstructor(instructorIdsForZoomUserCheck);
            }
            
            if(schIdMap != null && schIdMap.size() > 0) {
                ScheduleTriggerHandler.updateEvents(schIdMap); 
            }
            
            // W-007736 - (Urgent) Room Change Action on Schedule Creates Duplicate Prep Schedules
            if(cancelRelSchLT.size() > 0){
                ScheduleTriggerHandler.cancelPrepLTRelLT(cancelRelSchLT);
            }

            //Added By SivaPrasanth - #W-007667 - Create Preparation LT schedule from parent LT schedule.
            if(schLTIds.size() > 0 && schRelProTaskIds.size() > 0 && schRelProIds.size() > 0){
                System.debug('Trigger is fired:::');
                ScheduleTriggerHandler.createPrepScheduleFromLTSchedule(schLTIds,schRelProIds,schRelProTaskIds,schLTPriorIds);
            }
                        
            if(newSchList != null && newSchList.size() > 0) {
                try {
                    SendEmailsForUpdatedFields_Handler se = new SendEmailsForUpdatedFields_Handler();
                    se.sendEmail('Schedule__c',newSchList,oldSchMap,'Schedule Update Notify Mail');
                } catch(exception ex) {
                    System.debug('::EXCEPTION::'+ex.getMessage());
                }
            }
                        
            // Only for Extended schedule type
            if(extendedSchMap != null && extendedSchMap.size() > 0 && oldExtendedSchMap != null && oldExtendedSchMap.size() > 0) {
                try {
                    SendEmailsForUpdatedFields_Handler se = new SendEmailsForUpdatedFields_Handler();
                    se.sendMailSchUpdate(extendedSchMap, null, oldExtendedSchMap);
                } catch(exception ex) {
                    System.debug(':::EXCEPTION:::'+ex.getMessage());
                }
            }
                        
            if(afterEventCreationExSchMap != null && afterEventCreationExSchMap.size() > 0) {
                try {
                    SendEmailsForUpdatedFields_Handler se = new SendEmailsForUpdatedFields_Handler();
                    se.sendMailForExtendedSchedule(afterEventCreationExSchMap);
                } catch(exception ex) {
                    System.debug(':::EXCEPTION:::'+ex.getMessage());
                }
            }
            
            //To Create Assessment Report when the First Schedule is Activated
            Map<Id,List<Id>> projSchIdsMap = new Map<Id,List<Id>>(); // To store all the Active Schedules we have in this Project
            Map<Id,List<Id>> projAssessmentReportIdsMap = new Map<Id,List<Id>>(); // Added By Dhinesh - 17/11/2021 - To Store all training reports we have in this project
            Set<Id> finalARProjdIds = new Set<Id>();
            
            if(actProjIds != NULL && actProjIds.size() > 0){
                for(Schedule__c sc : [SELECT Id,Name,Status__c,Project__c,Project_Task__c, Project_Task__r.Project_Task_Type__c,Project__r.AcctSeed__Account__c,Project__r.AcctSeed__Account__r.Name FROM Schedule__c WHERE Project__c IN: actProjIds and Status__c != 'Drafted' AND Project_Task__r.Project_Task_Type__c = 'Language Training' ORDER BY CreatedDate DESC]) {
                    //if(sc.Project__r.AcctSeed__Account__c != null && !sc.Project__r.AcctSeed__Account__r.Name.contains('PVT')) { // To exclude automatic AR Creation for PVT Projects
                        if(!projSchIdsMap.containskey(sc.Project__c)) {
                            projSchIdsMap.put(sc.Project__c, new List<Id>());
                        }
                        projSchIdsMap.get(sc.Project__c).add(sc.Id);
                    //}
                }
                
                for(Assessment_Report__c trainingReport : [SELECT Id, Project__c,Language_Training_Status__c FROM Assessment_Report__c WHERE Project__c IN :actProjIds AND RecordType.DeveloperName IN ('Language_Training_Progress','DLI_W_Progress','APMO_Progress','DLI_W_Progress_2022') AND Status__c IN ('Draft','Scheduled')]){
                    if(!projAssessmentReportIdsMap.containskey(trainingReport.Project__c)) {
                        projAssessmentReportIdsMap.put(trainingReport.Project__c, new List<Id>());
                    }
                    projAssessmentReportIdsMap.get(trainingReport.Project__c).add(trainingReport.Id);
                    
                    if(trainingReport.Language_Training_Status__c == 'Final'){
                        finalARProjdIds.add(trainingReport.Project__c);
                    }
                }
            }
            
            // To loop through all the Active schedules in the Project 
            for(Id pro : projSchIdsMap.keySet()) {
            
                List<Id> activeSchIds = projSchIdsMap.get(pro);
                //To Check the Project has only one active Schedule for the Language Training PT
                if(activeSchIds.size() == 1 || (activeSchIds.size() > 1 && (!projAssessmentReportIdsMap.containsKey(pro) || (projAssessmentReportIdsMap.containsKey(pro) && !finalARProjdIds.contains(pro))))){
                    
                    Id schId = activeSchIds[0];
                    
                    // The Active Schedule we have is the Schedule that is activated recently
                    if(schIdsForAss.contains(schId)){
                        arProjIds.add(pro);
                    }
                }
            }
            System.debug('::arProjIds:::'+arProjIds);
            if(arProjIds.size() > 0) {                
                
                Assessment_Report_Helper.createAssessReport(arProjIds, 'ScheduleTrigger', new Map<String, String>(), new Map<Id,Assessment_Report__c>());
            }
            
            if(priorSchIdAndInsId.size() > 0){
                Assessment_Report_Helper.updateARInstructor(priorSchIdAndInsId);
            }
            
            if(priorSchIdAndSDEDStr.size() > 0){
                ScheduleTriggerHandler.updatePriorSchEveStatus(priorSchIdAndSDEDStr);    
            }
        }
        
        // On Schedule deletion with the Room value and related to a Project and with Status = Active, the Active Room text will change.
        if( trigger.isDelete ) {
            for(Schedule__c sc : trigger.old) {
                if( sc.Room__c != null && sc.Project__c != null && sc.Status__c == 'Active' ) {
                    projIds.add(sc.Project__c);
                }
            }
        }
        
        if(!projIds.isEmpty()) {
            for(Schedule__c sch : ScheduleService.getScheduleRec(' WHERE Room__c != null AND Status__c = \'Active\' AND Project__c ', ', Room__r.Name', projIds )) {
                if(!projIdRoomStrMap.containskey(sch.Project__c)) {
                    projIdRoomStrMap.put(sch.Project__c, sch.Room__r.Name);
                } else {
                    Set<String> roomNameSet = new Set<String>(projIdRoomStrMap.get(sch.Project__c).split(','));
                    if( roomNameSet == null || ( roomNameSet != null && !roomNameSet.contains(sch.Room__r.Name) ) )
                        projIdRoomStrMap.put(sch.Project__c, projIdRoomStrMap.get(sch.Project__c) + ',' + sch.Room__r.Name);
                }
            }
        }
        
        for( Id recId : projIds ) {
            AcctSeed__Project__c pro = new AcctSeed__Project__c();
            pro.Id = recId;
            pro.All_Active_Rooms__c = projIdRoomStrMap.containskey(recId) ? projIdRoomStrMap.get(recId) : '';
            projsToUpd.add(pro);
        }
        
        if(!projsToUpd.isEmpty()) {
            update projsToUpd;
        }
        
        // Call Event Handler Methods to create / delete Event records based on the schedule end date changes
        EventHandler eve = new EventHandler();
        if(schIds.size() > 0){
            //Modified By Dhinesh - 21-09-2021 - W-006989 - Substitute Schedule Events "Draft" but should be "Scheduled"
            //eve.createEvents(schIds);
            // Modified on July 21 2023 : W-007706 - Issue with Manage Project Status Button
            // To fix "System.LimitException: Too many SOQL queries"
            //EventHandler.handleEventRecords(schIds);
            
            CreateEventRecords_Queueable createEventJob = new CreateEventRecords_Queueable(schIds);
            Id jobId = System.enqueueJob(createEventJob);
        }
        if(schIdEndDate.size() > 0){
            eve.deleteExcessEventsRecords(schIdEndDate);
        }
        
        if(schIdStartDate.size() > 0){
            eve.deleteOldEventRecords(schIdStartDate);
        }
        
        //Call handler method to delete cancelled / On Hold schedule related events
        if(cancelOnHoldSchIdsDate.size() > 0){
            ScheduleTriggerHandler handler = new ScheduleTriggerHandler();
            handler.deleteScheduleEvents(cancelOnHoldSchIdsDate);
        }
        
        //call handler to update the prior schedule events
        //W-004823 - a task
        if(priorSchIdEndDateString.size() > 0){
            eve.updatePriorScheduleEventsToScheduled(priorSchIdEndDateString);
        }
    }
    
    //Before Delete trigger to add the validation for schedule delete action
    //get value from system value custom setting to check whether validation need to be checked are not
    //Added custom setting to have controll without changing the code By NS on Sep 26
    
    Boolean enableDeleteValidaiton;
    System_Values__c sysVal = System_Values__c.getValues('Enable Schedule Delete Validation');
    if(sysVal != null && sysVal.Value__c != null) {
        enableDeleteValidaiton = Boolean.valueOf(sysVal.Value__c);
    }
    
    if(trigger.isBefore && trigger.isDelete && enableDeleteValidaiton){
        for(Schedule__c sch : trigger.old){
            if(sch.Status__c != 'Drafted') {
                sch.addError('You cannot delete Schedule record.');
            }
        }
    }            
}