public class ScheduleTriggerHandler {
    
    public static Boolean isFromScheduleComponent = false;
    // Added on Aug 03 2023 : W-007858 - LT Schedule Activation Created Duplicate LT Events            
    public static Boolean isFromPrepScheduleUpdate = False;
    
    public static void updateEvents(Map<Id, Schedule__c> schIdMap) {
        
        List<Events__c> eveList = new List<Events__c>();
        
        for(Events__c eve : [SELECT Id, Room__c, Instructor__c, Schedule__c FROM Events__c WHERE Schedule__c IN :schIdMap.keySet()]) {
            eve.Room__c = schIdMap.get(eve.Schedule__c).Room__c;
            eve.Instructor__c = schIdMap.get(eve.Schedule__c).Instructor__c;
            eveList.add(eve);
        }
        
        if(eveList.size() > 0) {
            update eveList;
        }
    }   
    
    // Method to delete the Cancelled / On Hold Schedule related event records
    // Added by NS on OCT 3 2018
    public void deleteScheduleEvents(Map<Id,Date> schIdCancelledDate){
        
        List<Events__c> eventRecords = new List<Events__c>();
        
        if(schIdCancelledDate.size() > 0) {
            for(Events__c eve : [SELECT Id,Name,Date__c,Schedule__c,Schedule__r.Status__c,Schedule__r.Start_Date__c FROM Events__c WHERE Schedule__c IN : schIdCancelledDate.keySet()]) {
            
                //IF schedule is cancelled before the actual class start, then whole events are not deleted. start date event is still in scheduled status
                // so included = if the map value is equal to start date of schedule
                if(eve.Schedule__r.Status__c == 'Canceled') {
                    
                    if(schIdCancelledDate.get(eve.Schedule__c) == eve.Schedule__r.Start_Date__c && eve.Date__c >= schIdCancelledDate.get(eve.Schedule__c)){
                        eventRecords.add(eve);
                    }else if(schIdCancelledDate.get(eve.Schedule__c) != eve.Schedule__r.Start_Date__c && eve.Date__c > schIdCancelledDate.get(eve.Schedule__c)){
                        eventRecords.add(eve);
                    }
                    
                }else if(eve.Date__c > schIdCancelledDate.get(eve.Schedule__c)){
                
                    eventRecords.add(eve);
                } 
            }
        }
        
        system.debug('::::::::deleteScheduleEvents::::::eventRecords::::'+eventRecords.size());
        
        if(eventRecords.size() > 0){
            delete eventRecords;
        }
    }
    
    
    public static Map<Id, Id> getConIdAndUserIdMap(Set<Id> conIds){
        
        Map<Id, Id> conIdAndUserId = new Map<Id, Id>();
        Set<String> profiles = new Set<String>{'Instructor Community', 'Student Community'};
        
        // To get Instructor / Student Community related user Ids
        for(User u : [
            SELECT Id, ContactId 
            FROM User 
            WHERE ContactId IN :conIds AND Profile.Name IN :profiles AND IsPortalEnabled = TRUE AND IsActive = TRUE AND ContactId != NULL
        ]){
        
            conIdAndUserId.put(u.ContactId, u.Id);
        }
        return conIdAndUserId ;
    }        
    
    /**********
        - Added By HL on June 28 2021
        - Work Item:W-006813 - Cancelled Substitute Schedule Not Changing Original Event Status Back to Scheduled
        - To update Prior Schedule Event's status as Scheduled if Substitute Schedule is Cancelled    
        ********/
    public static void updatePriorSchEveStatus(Map<Id, String> priorSchIdAndSDEDStr){
        
        if(priorSchIdAndSDEDStr != NULL && priorSchIdAndSDEDStr.size() >0){
            
            List<Events__c> updateEvents = new List<Events__c>();
            
            for(Events__c e : [SELECT Id, Schedule__c, Status__c, Date__c FROM Events__c WHERE Schedule__c IN : priorSchIdAndSDEDStr.keySet() AND Status__c = 'Substituted']){
            
                if(priorSchIdAndSDEDStr.containsKey(e.Schedule__c)){
                                        
                    Date startDate = Date.valueOf(priorSchIdAndSDEDStr.get(e.Schedule__c).split('~')[0]);
                    Date endDate = Date.valueOf(priorSchIdAndSDEDStr.get(e.Schedule__c).split('~')[1]);
                    
                    if(e.Date__c >= startDate && e.Date__c <= endDate){
                        e.Status__c = 'Scheduled';
                        updateEvents.add(e);
                    }
                }    
            }
            if(updateEvents != NULL && updateEvents.size() > 0){
                update updateEvents;    
            }
        }
    }  
    
    // Work Item: W-006965 - Substitute Schedule Contact Assignment
    // To update Substitute Schedule (Instructor)Contact Assignment's End Date as Substitute Schedule's End Date
    public static void update_SubstituteScheduleCA(Set<Id> projIds, Map<Id, Date> insIdAndEndDate){
    
        if(projIds != NULL && insIdAndEndDate != NULL){
        
            List<Contact_Assignments__c> updateCAs = new List<Contact_Assignments__c>();
            
            for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c, End_Date__c, Status__c 
                                                FROM Contact_Assignments__c 
                                                WHERE Candidate_Name__c IN : insIdAndEndDate.keySet() AND Project__c IN :projIds AND Status__c != 'Active' AND RecordType.DeveloperName = 'Instructor'
                                                     AND Assignment_Position__c IN ('Substitute Instructor','Instructor') AND Rate_Card_Rate__c != null AND Rate_Card_Rate__r.Status__c = 'Approved' ORDER BY End_Date__c DESC LIMIT 1]){
                if(insIdAndEndDate.containsKey(ca.Candidate_Name__c)){
                    if(ca.End_Date__c < insIdAndEndDate.get(ca.Candidate_Name__c)){
                        ca.End_Date__c = insIdAndEndDate.get(ca.Candidate_Name__c);
                    }   
                  //  if(ca.Status__c != 'Active'){
                        ca.Status__c = 'Active';
                 //   }
                    updateCAs.add(ca);
                }
            } 
            if(updateCAs.size() > 0){
               update updateCAs; 
            }
        } 
    }
    //Added By SivaPrasanth - #W-007667 - Create Preparation LT schedule from parent LT schedule.
    
    public static void createPrepScheduleFromLTSchedule(Set<Id> schIds,Set<Id> proIds,Set<Id> proTaskIds,Set<Id> schPriorIds){
        
        if(schIds.size() > 0 && proIds.size() > 0 && proTaskIds.size() > 0){
            
            Map<Id,Id> proTaskWithPrepPTMap = new Map<Id,Id>();
            Map<Id,Integer> proOppWithSchCnt = new Map<Id,Integer>();
            Map<Id,Set<Id>> schLTPrepPriorIds = new Map<Id,Set<Id>>();
            Map<String,List<Preparation_Schedule_Mapping__mdt>> prepSchMappings = new Map<String,List<Preparation_Schedule_Mapping__mdt>>();
            List<Preparation_Schedule_Mapping__mdt> prepSchMetaData = new List<Preparation_Schedule_Mapping__mdt>();
            List<ScheduleDomain.ScheduleDetail> prepSchWrapList = new List<ScheduleDomain.ScheduleDetail>();
            
            ScheduleTriggerHandler schHandler = new ScheduleTriggerHandler();
            EventHandler eveHandle = new EventHandler();
            
            proOppWithSchCnt = getExistingScheduleCounts('AcctSeed__Project__c',proIds);
            schLTPrepPriorIds = getLTPrepSchedulePriorIds(schPriorIds);
            
            for(Preparation_Schedule_Mapping__mdt psm :[SELECT Id,DeveloperName,Account_Type__c,After_Time__c,Before_Time__c,Create_at_LT_Schedule_Activate__c,Max_no_of_Hours__c,
                                                              Min_no_of_Hours__c,Preparation_Hours__c,Project_Type__c,Replace_Instructor__c,Schedule_Change__c,Substitute_Instructor__c
                                                        FROM Preparation_Schedule_Mapping__mdt ORDER BY DeveloperName ASC]){
                if(prepSchMappings.containsKey(psm.Account_Type__c)){
                    prepSchMappings.get(psm.Account_Type__c).add(psm);
                }else{
                    prepSchMappings.put(psm.Account_Type__c,new List<Preparation_Schedule_Mapping__mdt>{psm}); 
                }
                
            }
            
            for(AcctSeed__Project_Task__c prepPT : [SELECT Id,Parent_Project_Task__c FROM AcctSeed__Project_Task__c WHERE Parent_Project_Task__c IN :proTaskIds AND Project_Task_Type__c = 'Preparation time']){
                if(!proTaskWithPrepPTMap.containskey(prepPT.Parent_Project_Task__c)){
                    proTaskWithPrepPTMap.put(prepPT.Parent_Project_Task__c,prepPT.Id);
                }
            }
            
            if(schIds.size() > 0 && prepSchMappings.size() > 0){

                for(Schedule__c sch : ScheduleService.getScheduleRec(' WHERE Id ',',Project__r.Project_Type__c,Project__r.AcctSeed__Account__c,Project__r.AcctSeed__Account__r.Name,Project__r.Program_Iteration__c',schIds)){
                    
                    if(proTaskWithPrepPTMap.containsKey(sch.Project_Task__c) && proTaskWithPrepPTMap.get(sch.Project_Task__c) != null){
                        ScheduleDomain.ScheduleDetail prepSchWrap = new ScheduleDomain.ScheduleDetail();
                        
                        ScheduleDomain.Days dayVal = new  ScheduleDomain.Days();
                        dayVal.monday = sch.Monday__c;
                        dayVal.tuesday = sch.Tuesday__c;
                        dayVal.wednesday = sch.Wednesday__c;
                        dayVal.thursday = sch.Thursday__c;
                        dayVal.friday = sch.Friday__c;
                        dayVal.saturday = sch.Saturday__c;
                        dayVal.sunday = sch.Sunday__c;
                        
                        prepSchWrap.dayVal = dayVal;
                        prepSchWrap.scheduleId = null;
                        prepSchWrap.startDate = sch.Start_Date__c; 
                        prepSchWrap.startTime = sch.Start_Time__c;
                        prepSchWrap.endTime = sch.End_Time__c;
                        prepSchWrap.endDate = sch.End_Date__c;
                        prepSchWrap.timezone = sch.Timezone__c;
                        prepSchWrap.variedTime = sch.Varied_Time__c;
                        prepSchWrap.variedDay = sch.Varied_Day__c;
                        prepSchWrap.scheduleType = sch.Schedule_Type__c;
                        prepSchWrap.projectId = sch.Project__c;
                        prepSchWrap.oppId = sch.Opportunity__c;
                        prepSchWrap.opliId = sch.Opportunity_Product_Id__c;
                        prepSchWrap.projectTaskId = proTaskWithPrepPTMap.get(sch.Project_Task__c);
                        prepSchWrap.instructorId = sch.Instructor__c;
                        prepSchWrap.roomId = sch.Room__c;
                        prepSchWrap.travelInDate = sch.Travel_In__c;
                        prepSchWrap.travelOutDate = sch.Travel_Out__c;
                        prepSchWrap.isTravelRequired = sch.Travel_Required__c;
                        prepSchWrap.excludeFederalHoliday = sch.Exclude_Federal_Holidays__c;
                        prepSchWrap.breakTimeHrs = 0;
                        prepSchWrap.createZoomMeetings = false;
                        prepSchWrap.priorScheduleId = null;
                        prepSchWrap.parentScheduleId = sch.Id;
                        prepSchWrap.biWeekly = sch.Bi_Weekly__c;
                        
                        
                        if(sch.Project__c != null && sch.Project__r.AcctSeed__Account__c != null){
                            String proActualAccName = sch.Project__r.AcctSeed__Account__r.Name;
                            String proAccName = null;
                            
                            for(String accType : prepSchMappings.keySet()){
                                if(proActualAccName.contains(accType)){
                                    proAccName = accType;
                                    break;
                                }
                            }
                            
                            if(prepSchMappings.containsKey(proAccName)){
                                prepSchMetaData = prepSchMappings.get(proAccName); 
                            }else if(prepSchMappings.containsKey('Other')){
                                prepSchMetaData = prepSchMappings.get('Other'); 
                            }
                            
                            if(prepSchMetaData.size() > 0){
                                Boolean prepLT1 = false;
                                Boolean prepLT2 = false;
                                Boolean isActivePrepLT = false;
                                Decimal prepHrValue = null;
                                
                                for(Preparation_Schedule_Mapping__mdt prepSchMap : prepSchMetaData){
                                    Decimal prepHrs = (prepSchMap.Preparation_Hours__c != null) ? prepSchMap.Preparation_Hours__c : 0.00;
                                    Decimal minHrs = (prepSchMap.Min_no_of_Hours__c != null) ? prepSchMap.Min_no_of_Hours__c : null;
                                    Decimal maxHrs = (prepSchMap.Max_no_of_Hours__c != null) ? prepSchMap.Max_no_of_Hours__c : null;
                                    Boolean isPrepCreatable = false;
                                    
                                    if((minHrs == null || sch.Hours_Planned__c >= minHrs) && (maxHrs == null || sch.Hours_Planned__c <= maxHrs)){
                                        if(proAccName == prepSchMap.Account_Type__c && String.isBlank(prepSchMap.Project_Type__c)){
                                            isPrepCreatable = true;
                                        }else if(proAccName == prepSchMap.Account_Type__c && String.isNotBlank(prepSchMap.Project_Type__c)){
                                            if(prepSchMap.Project_Type__c == 'Ad-hoc' && sch.Project__r.Program_Iteration__c == null){
                                                isPrepCreatable = true;
                                            }else if(prepSchMap.Project_Type__c == sch.Project__r.Project_Type__c){
                                                isPrepCreatable = true;
                                            }
                                        }else if(!prepSchMappings.containsKey(proAccName)){
                                            isPrepCreatable = true; 
                                        }
                                        
                                        if(isPrepCreatable == true){
                                            isActivePrepLT = prepSchMap.Create_at_LT_Schedule_Activate__c;
                                            
                                            if(prepSchMap.After_Time__c == true && prepSchMap.Before_Time__c == true){
                                                prepHrs = (prepHrs/2);
                                            }
                                            if(prepSchMap.Before_Time__c == true){
                                                prepHrValue = prepHrs;
                                                prepLT1 = true;
                                            }
                                            if(prepSchMap.After_Time__c == true){
                                                prepHrValue = prepHrs;
                                                prepLT2 = true;
                                            }
                                            break;
                                        }
                                    }
                                }
                                
                                if(prepLT1 == true || prepLT2 == true){
                                    Integer minutes = null;
                                    prepSchWrap.totalHrsPerSession = prepHrValue;
                                    prepSchWrap.hoursPlanned = prepHrValue;
                                    
                                  //  if(isActivePrepLT){
                                    //    prepSchWrap.status = 'Active';
                                  //  }else{
                                        prepSchWrap.status = 'Drafted';
                                 //   }
                                    
                                    if(prepLT1 == true){
                                        if(sch.Id != null && schLTPrepPriorIds.containsKey(sch.Prior_Schedule__c)){
                                            List<Id> schLTPrepPriorIdSet1 = new List<Id>(schLTPrepPriorIds.get(sch.Prior_Schedule__c));
                                            if(schLTPrepPriorIdSet1.size() > 0){
                                                prepSchWrap.priorScheduleId = schLTPrepPriorIdSet1[0]; 
                                            }
                                        }
                                        
                                        prepSchWrap.endTime = sch.Start_Time__c; 
                                        minutes = eveHandle.convertToMinutes(sch.Start_Time__c) - Integer.valueOf((prepHrValue * 60));
                                        prepSchWrap.startTime = schHandler.convertToHours(minutes);
                                        
                                        if(proOppWithSchCnt.containsKey(sch.Project__c)){
                                            Integer proSchCnt = proOppWithSchCnt.get(sch.Project__c) + 1;
                                            prepSchWrap.scheduleName = sch.DLS_Ref__c +'-SH'+proSchCnt;
                                            proOppWithSchCnt.put(sch.Project__c,proSchCnt);                             
                                        }
                                        prepSchWrapList.add((ScheduleDomain.ScheduleDetail)JSON.deserialize(JSON.serialize(prepSchWrap), ScheduleDomain.ScheduleDetail.class));
                                        
                                    }
                                    
                                    if(prepLT2 == true){
                                        
                                        if(sch.Id != null && schLTPrepPriorIds.containsKey(sch.Prior_Schedule__c)){
                                            List<Id> schLTPrepPriorIdSet2 = new List<Id>(schLTPrepPriorIds.get(sch.Prior_Schedule__c));
                                            
                                            if(schLTPrepPriorIdSet2.size() > 1){
                                                prepSchWrap.priorScheduleId = schLTPrepPriorIdSet2[1];
                                            }
                                        }
                                        
                                        prepSchWrap.startTime = sch.End_Time__c; 
                                        minutes = eveHandle.convertToMinutes(sch.End_Time__c) + Integer.valueOf((prepHrValue * 60));
                                        prepSchWrap.endTime = schHandler.convertToHours(minutes);
                                        
                                        if(proOppWithSchCnt.containsKey(sch.Project__c)){
                                            Integer proSchCnt = proOppWithSchCnt.get(sch.Project__c) + 1;
                                            prepSchWrap.scheduleName = sch.DLS_Ref__c +'-SH'+proSchCnt;
                                            proOppWithSchCnt.put(sch.Project__c,proSchCnt);                             
                                        }
                                        prepSchWrapList.add((ScheduleDomain.ScheduleDetail)JSON.deserialize(JSON.serialize(prepSchWrap), ScheduleDomain.ScheduleDetail.class));
                                    }
                                }
                            }
                        }
                    }
                }
            }
            if(prepSchWrapList.size() > 0){
                Set<Id> createdSchIds = new Set<Id>();
                Set<String> schTypes = new Set<String>{'Schedule Change','Replace Instructor','Room Change','Move Online'};
               
                // these for subsitute schedules   
                Map<Id,Id> priorPrepSubSchIds = new Map<Id,Id>();
                Map<Id,Set<Id>> parentSchWithPrepschIds = new Map<Id,Set<Id>>(); 
                
                List<Schedule__c> updatePriorLTPrepEndDate = new List<Schedule__c>();
                List<Schedule__c> prepSchedulesInsert = ScheduleTranslator.OriginalScheduleRecFormationList(prepSchWrapList);

                Map<Id,String> prepLTSchType = new Map<Id,String>();
                Map<Id,Schedule__c> prepLTWithPriorPrepLT = new Map<Id,Schedule__c>();
                
                if(prepSchedulesInsert.size() > 0){
                    insert prepSchedulesInsert;
                    
                    // Create the events for LT Preparation Schedule
                    for(Schedule__c sch : prepSchedulesInsert){
                        
                        if(sch.Schedule_Type__c == 'Substitute') {
                            
                            if(!parentSchWithPrepschIds.containskey(sch.Parent_Schedule__c)){
                                parentSchWithPrepschIds.put(sch.Parent_Schedule__c,new Set<Id>{sch.Id});
                            }else{
                                parentSchWithPrepschIds.get(sch.Parent_Schedule__c).add(sch.Id);
                            }
                            
                            if(sch.Prior_Schedule__c != null){
                                if(!priorPrepSubSchIds.containsKey(sch.Id )){
                                    priorPrepSubSchIds.put(sch.Id,sch.Prior_Schedule__c);
                                }
                            }
                          
                        }else if(schTypes.contains(sch.Schedule_Type__c)){
                            
                            if(sch.Prior_Schedule__c != null){
                                
                                if(!prepLTSchType.containsKey(sch.Prior_Schedule__c)){
                                    prepLTSchType.put(sch.Prior_Schedule__c,sch.Schedule_Type__c);
                                }
                                
                                if(!prepLTWithPriorPrepLT.containsKey(sch.Prior_Schedule__c)){
                                    prepLTWithPriorPrepLT.put(sch.Prior_Schedule__c,sch);
                                }
                            }
                        }
                        createdSchIds.add(sch.Id);
                        sch.Status__c = 'Active';
                    }
                    
                   
                    // Update the Prior LT Prep End Date (for this type 'Schedule Change','Replace Instructor','Room Change','Move Online')
                    if((prepLTSchType.keySet()).size() > 0){
                        updatePriorLTPrepEndDate = [SELECT Id,Status__c,Start_Date__c,Schedule_Type__c,Cancellation_Reason__c,Cancellation_Date__c,End_Date__c,Parent_Schedule__r.End_Date__c,Parent_Schedule__c FROM Schedule__c WHERE Parent_Schedule__c != null AND Id IN :prepLTSchType.keySet() AND Project_Task_Stage__c = 'Preparation time'];
                        
                        if(updatePriorLTPrepEndDate.size() > 0){
                            for(Schedule__c  schLTPrep : updatePriorLTPrepEndDate){
                                
                                if(prepLTSchType.containsKey(schLTPrep.Id) && prepLTWithPriorPrepLT.containsKey(schLTPrep.Id)){
                                    String schType = prepLTSchType.get(schLTPrep.Id);
                                    Schedule__c newPrepLT = prepLTWithPriorPrepLT.get(schLTPrep.Id);
                                        
                                    if(schTypes.contains(schType)){
                                        if(newPrepLT.Start_Date__c <= schLTPrep.Start_Date__c){
                                            schLTPrep.Status__c = 'Canceled';
                                            schLTPrep.Cancellation_Reason__c = schLTPrep.Schedule_Type__c;
                                            schLTPrep.Cancellation_Date__c = System.Today();
                                        }else{
                                            if(schLTPrep.Parent_Schedule__c != null && schLTPrep.Parent_Schedule__r.End_Date__c != null){
                                                if(newPrepLT.Start_Date__c > schLTPrep.Start_Date__c){
                                                    schLTPrep.End_Date__c = (schLTPrep.Parent_Schedule__r.End_Date__c);
                                                    
                                                    if(schLTPrep.End_Date__c < System.today()){
                                                        schLTPrep.Status__c = 'Completed';
                                                    }
                                                }
                                            }
                                        } 
                                    }
                                }
                            }
                            update updatePriorLTPrepEndDate;
                        }
                    }
                    //Call the Event creation method with newly created Sustitute Schedule Id & eventdates

                    if(parentSchWithPrepschIds.size() > 0 || priorPrepSubSchIds.size() > 0){
                        EventHandler eveHandler = new EventHandler();
                        Map<Id,Set<Date>> prepSchWithEvtDts = new Map<Id,Set<Date>>();
                        Map<Id,Set<Date>> priorPrepSchWithEvtDts = new Map<Id,Set<Date>>();
                        
                        //Creating new events and schedule records for substitute
                        if(parentSchWithPrepschIds.size() > 0){
                            for(Events__c evt : [SELECT Id,Date__c,Schedule__c From Events__c WHERE Schedule__c IN :parentSchWithPrepschIds.keySet()]){
                                
                                if(parentSchWithPrepschIds.containsKey(evt.Schedule__c)){
                                    Set<Id> sch = parentSchWithPrepschIds.get(evt.Schedule__c);
                                    for(Id schId : sch){
                                        if(!prepSchWithEvtDts.containsKey(schId)){
                                            prepSchWithEvtDts.put(schId,new Set<Date>{date.ValueOf(evt.Date__c)});
                                        }else{
                                            prepSchWithEvtDts.get(schId).add(evt.Date__c);
                                        }
                                    }
                                }
                            }
                        }
                        System.debug('::prepSchWithEvtDts::'+prepSchWithEvtDts);
                        
                        //Updating Prior Schedule events with cancelled status
                        for(Id schId : prepSchWithEvtDts.keySet()){
                            if(priorPrepSubSchIds.containsKey(schId)){
                                String priorSch = priorPrepSubSchIds.get(schId);
                                if(!priorPrepSchWithEvtDts.containsKey(priorSch)){
                                    priorPrepSchWithEvtDts.put(priorSch,prepSchWithEvtDts.get(schId)); 
                                }
                            }
                        }
                        System.debug('::priorPrepSchWithEvtDts::'+priorPrepSchWithEvtDts);

                        
                        if(priorPrepSchWithEvtDts.size() > 0){
                            //Updating Prior Schedule events with cancelled status
                            eveHandler.cancelPriorScheduleEventsList(priorPrepSchWithEvtDts);
                        }
                        
                        if(prepSchWithEvtDts.size() > 0){
                            //Creating new events and schedule records for substitute
                            eveHandler.createSubstitueScheduleEvts(prepSchWithEvtDts);
                        }
                        
                    }
                    
                    //Active the new PREP LT Schedules
                    if(prepSchedulesInsert.size() > 0){
                        isFromPrepScheduleUpdate = True;
                        update prepSchedulesInsert;
                        
                        if(createdSchIds.size() > 0){
                            // Modified on July 21 2023 : W-007706 - Issue with Manage Project Status Button
                            // To fix "System.LimitException: Too many SOQL queries"
                            //EventHandler.handleEventRecords(createdSchIds);
                            
                            CreateEventRecords_Queueable createEventJob = new CreateEventRecords_Queueable(createdSchIds);
                            Id jobId = System.enqueueJob(createEventJob);
                        }
                    }
                }
            }
        }
    }
     //Minutes to Hours conversion
    public String convertToHours(Integer minutes) {
        String hourString = '';
        
        Integer days = minutes / 60 / 24 ;
        Integer hours = (minutes - days * 60 * 24) / 60 ;
        Integer mins = minutes - days * 60 * 24 - hours * 60 ;
        
        if(hours == 0){
            hourString = +'12:'+String.valueOf('0'+mins).right(2)+' AM';
        }else if(hours == 12){
            hourString = hours+':'+String.valueOf('0'+mins).right(2)+' PM';
        }else if(hours > 12 && hours < 24){
            hours = hours - 12;
            hourString = String.valueOf('0'+hours).right(2) +':'+ String.valueOf('0'+mins).right(2)+' PM';
        }else if(hours > 0 && hours < 12){ 
            hourString = String.valueOf('0'+hours).right(2) +':'+ String.valueOf('0'+mins).right(2)+' AM';
        }else if(hours < 0){
            hours = 12 + hours;
            if(mins < 0){
                mins = 60 + mins;
                hours = hours - 1;
            }
            hourString = String.valueOf('0'+hours).right(2)+':'+String.valueOf('0'+mins).right(2)+' PM';
        }
        return hourString;
    }
    
     /************************************************************
     - Qry recently created schedule record under that project/opp
     -  To get Schedule Count
    ************************************************************/
    public static Map<Id,Integer> getExistingScheduleCounts(String parentType,Set<Id> parentIds){
        Map<Id,Integer> proOppWithSchCnt = new Map<Id,Integer>();
        
        if(parentType == 'Opportunity'){
            for(Opportunity oppRec : [SELECT DLS_Class__c, (SELECT Name FROM Schedules__r) FROM Opportunity WHERE Id IN :parentIds]){
                
                if(!proOppWithSchCnt.containsKey(oppRec.Id)){
                    proOppWithSchCnt.put(oppRec.Id,(oppRec.Schedules__r.size()));
                }
            }
        }else if(parentType == 'AcctSeed__Project__c'){
            for(AcctSeed__Project__c projectRec : [SELECT DLS_Class__c, (SELECT Name FROM Schedules__r) FROM AcctSeed__Project__c WHERE Id IN :parentIds]){
               
                if(!proOppWithSchCnt.containsKey(projectRec.Id)){
                    proOppWithSchCnt.put(projectRec.Id,(projectRec.Schedules__r.size()));
                } 
            }
        }
     
        return proOppWithSchCnt;
    }
    
     /************************************************************
      Get LT prep schedule PriorIds
     ************************************************************/
    public static Map<Id,Set<Id>> getLTPrepSchedulePriorIds(Set<Id> priorIds){
        Map<Id,Set<Id>> priorSchIdWithprepSchId= new Map<Id,Set<Id>>();
        for(Schedule__c sch : [SELECT Id,Parent_Schedule__c FROM Schedule__c WHERE Parent_Schedule__c != null AND Parent_Schedule__c IN :priorIds AND Project_Task_Stage__c = 'Preparation time']){
            
            if(!priorSchIdWithprepSchId.containsKey(sch.Parent_Schedule__c)){
                priorSchIdWithprepSchId.put(sch.Parent_Schedule__c,new Set<Id>{sch.Id});
            }else{
                priorSchIdWithprepSchId.get(sch.Parent_Schedule__c).add(sch.Id);
            }
        }
        return priorSchIdWithprepSchId;
    }
    public static void cancelPrepLTRelLT(Set<Id> cancelRelSchLT){
        List<Schedule__c> prepSchLTs = [SELECT Id,Parent_Schedule__c,Parent_Schedule__r.Cancellation_Reason__c FROM Schedule__c WHERE Parent_Schedule__c != null AND Parent_Schedule__c IN :cancelRelSchLT AND Project_Task_Stage__c = 'Preparation time' AND Status__c != 'Canceled'];
        
        if(prepSchLTs.size() > 0){
            for(Schedule__c sch : prepSchLTs){
                sch.Status__c = 'Canceled';
                sch.Cancellation_Reason__c = sch.Parent_Schedule__r.Cancellation_Reason__c;
            }
            update prepSchLTs;
        }
    }
}