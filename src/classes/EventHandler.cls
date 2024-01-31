/*******************************************************************************
- class to create Event records based on the Schedule information
- This will be called from apex class, Trigger
- Created by NS on Sep 18 2018
*******************************************************************************/
public class EventHandler {

    public static Boolean isFromEve = FALSE;
    public static Boolean allowToUpdateInsCA =  False;
    
    public static void handleEventRecords(Set<Id> scheduleIds) {
        
        Map<Id,Id> substitutedId_ParentSchIds = new Map<Id,Id>();
        Map<Id,Id> replacedIns_SchChangeId_ParentSchIds = new Map<Id,Id>();
        Set<Id> scheuleIdsTocreateEvents = new Set<Id>();
        
        for(Schedule__c sch : [SELECT Id,Name,Schedule_Type__c,Prior_Schedule__c,Status__c,Varied_Day__c,Varied_Time__c,Travel_Required__c From Schedule__c WHERE Id IN :scheduleIds]){
            if(sch.Status__c == 'Active'){

                // To skip the event creation for Varied Day & Varied Time checked schedule records
                if(!sch.Varied_Day__c /*&& !sch.Varied_Time__c*/ && !sch.Travel_Required__c && sch.Schedule_Type__c != 'Substitute') {
                    scheuleIdsTocreateEvents.add(sch.Id);
                }

                if(sch.Schedule_Type__c == 'Substitute' && sch.Prior_Schedule__c != null) {
                    substitutedId_ParentSchIds.put(sch.Id,sch.Prior_Schedule__c);
                } else if((sch.Schedule_Type__c == 'Replace Instructor' || sch.Schedule_Type__c == 'Schedule Change' || sch.Schedule_Type__c == 'Room Change') && sch.Prior_Schedule__c != null) {
                    replacedIns_SchChangeId_ParentSchIds.put(sch.Id,sch.Prior_Schedule__c);
                }
            }
        }
        
        EventHandler eveHandler = new EventHandler();
        Savepoint sp = Database.setSavepoint(); 
        try {
            // Deleting old events based on the new schedule start & end date
            if(replacedIns_SchChangeId_ParentSchIds.size() > 0){
                eveHandler.deleteOldScheduleEvents(replacedIns_SchChangeId_ParentSchIds);
            }
            
            // Update old Schedule events status to "Substituted" 
            if(substitutedId_ParentSchIds.size() > 0){
                eveHandler.updateOldScheduleEventsStatus(substitutedId_ParentSchIds);
            }
            
            // Creating Events based on Schedule start & end date
            if(scheuleIdsTocreateEvents.size() > 0){
                eveHandler.createEvents(scheuleIdsTocreateEvents);
            }
                        
        }catch(Exception ex) {
            system.debug(':::::::::getMessage:::::'+ex.getMessage());
             Database.rollback(sp);
        }
    }
   
    public void createEvents(Set<Id> scheduleIds){
        
        system.debug(':::::::::enter:::createEvents:::'+scheduleIds.size());
        
        List<Schedule__c> scheduleRecords = SObjectQueryService.SObjectQuery('Schedule__c',scheduleIds,',Project__r.RecordType.DeveloperName,Project_Task__r.Total_Hours__c');
        
        Map<Id,Schedule__c> scheduleIdRecMap = new Map<Id,Schedule__c>();
        Set<Id> projectId = new Set<Id>();
        Map<Id,Boolean> projectIdFlag = new Map<Id,Boolean>();    // To Track the project have one / multiple student - if only one student- flag = true or if > 1 flag = false
        Map<Id,Id> projectIdStudentId = new Map<Id,Id>();    // To track project specific students if only one student present
        Set<Date> plannedOffDates = new Set<Date>();    // To hold Student & Project Specific planned days off informations
        Map<Id,Decimal> taskIdTotalHrs = new Map<Id,Decimal>();
        Set<Id> taskId = new Set<Id>();
        Set<Date> DLIWLTHolidays = new Set<Date>();
        Set<Date> holidayDates = new Set<Date>();
        
        //To check event Conflict folllowing variabled are used
        Set<Id> instructorId = new Set<Id>();
        Date minimumStart;
        Date maxEndDate;
        Set<Id> roomIds = new Set<Id>();
        Map<Date,List<Events__c>> date_StudentEvents = new Map<Date,List<Events__c>>();
        Map<Date,List<Events__c>> date_RoomInstructorEvents = new Map<Date,List<Events__c>>();
        Map<Date,List<Events__c>> date_ProjectEvents = new Map<Date,List<Events__c>>();
        
        Map<Id,List<Events__c>> schIdEventRecords = new Map<Id,List<Events__c>>();
        
        // Map to hold the Project related Supervisor Contact info to send conflict informations
        Map<Id,Id> proIdSuperviosrContId = new Map<Id,Id>();
        Map<Id,String> proIdName = new Map<Id,String>();
        Map<Id,List<UtilDomain.ErrorWrapper>> schIdErrorWrapper = new Map<Id,List<UtilDomain.ErrorWrapper>>();
        Map<Id,Contact> conIdRecMap = new Map<Id,Contact>();
        
        //Check for existing events before creating new events under schedule record
        Map<Id,Set<Date>> schIdEventDates = new Map<Id,Set<Date>>();
        Map<Id,Decimal> schIdLastEveSeqNum = new Map<Id,Decimal>();
        Map<Id,String> proIdActiveStudentsNames = new Map<Id,String>();
        Map<Id,Id> newSchIdOldSchId = new Map<Id,Id>();
        
        for(Schedule__c sch : scheduleRecords){
            scheduleIdRecMap.put(sch.Id,sch);
            projectId.add(sch.Project__c);
            
            if(sch.Instructor__c != null) {
                instructorId.add(sch.Instructor__c);
            }
            
            //Qry related Project Task to know the Total Planned Hours
            if(sch.Project_Task__c != null){
                if(!taskIdTotalHrs.containsKey(sch.Project_Task__c)){
                    taskIdTotalHrs.put(sch.Project_Task__c,sch.Project_Task__r.Total_Hours__c);
                }
            }
                
            if(sch.Room__c != null) {
                roomIds.add(sch.Room__c);
            }
            
            if((minimumStart != null && minimumStart > sch.Start_Date__c) || minimumStart == null) {
                minimumStart = sch.Start_Date__c;
            }
            
            if((maxEndDate != null && maxEndDate < sch.End_Date__c) || maxEndDate == null) {
                maxEndDate = sch.End_Date__c;
            }
            
            if(sch.Prior_Schedule__c != null) {
                newSchIdOldSchId.put(sch.Id,sch.Prior_Schedule__c);
            }
        }
        
        /*for(Holiday hol : HolidayService.getHolidaysWithRecurrence(minimumStart,maxEndDate)){
            holidayDates.add(hol.ActivityDate);
        }*/
        holidayDates = HolidayService.getHolidaysWithRecurrence(minimumStart,maxEndDate);
        
        system.debug(':::::::holidayDates::::'+holidayDates);
        system.debug('::::::::::scheduleIdRecMap::::'+scheduleIdRecMap);
        system.debug(':::::::taskIdTotalHrs:::::'+taskIdTotalHrs);
        
        Set<Id> conIds = new Set<Id>();

        //Qty Project related Student CA for Planned days off check
        for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c,RecordType.DeveloperName,Project__c,Project__r.Name,Project__r.Students__c FROM Contact_Assignments__c WHERE Project__c != null AND Project__c IN :projectId AND RecordType.DeveloperName IN ('Student','Staff') AND Status__c = 'Active']){
            
            if(ca.RecordType.DeveloperName == 'Student'){
                
                projectIdStudentId.put(ca.Project__c,ca.Candidate_Name__c);
                if(!projectIdFlag.containsKey(ca.Project__c)){
                    projectIdFlag.put(ca.Project__c,true);
                }else {
                    projectIdFlag.put(ca.Project__c,false);
                    projectIdStudentId.remove(ca.Project__c);
                }
                
                if(!proIdActiveStudentsNames.containsKey(ca.Project__c)) {
                    proIdActiveStudentsNames.put(ca.Project__c,ca.Project__r.Students__c);
                }
                
                if(!proIdName.containsKey(ca.Project__c)) {
                    proIdName.put(ca.Project__c,ca.Project__r.Name);
                }
            }else  if(ca.RecordType.DeveloperName == 'Staff'){
                //Qry Project related recent supervisor contact from CA to send conflict information as mail

                if(!proIdSuperviosrContId.containsKey(ca.Project__c)) {
                    proIdSuperviosrContId.put(ca.Project__c,ca.Candidate_Name__c);
                }
                conIds.add(ca.Candidate_Name__c);
            }

        }
        
        system.debug('::::::::::projectIdFlag::::'+projectIdFlag);
        system.debug('::::::::::projectIdStudentId::::'+projectIdStudentId);
        system.debug('::::::::::proIdActiveStudentsNames::::'+proIdActiveStudentsNames);
        system.debug('::::::::::proIdName::::'+proIdName);
        system.debug('::::::::proIdSuperviosrContId::::'+proIdSuperviosrContId); 
        
        // Qry student specific Planned days off records
        //Qry Project Specific && DLI W LT related Planned Days off records 
        for(Planned_Days_Off__c off : [SELECT Id,Name,Project__c,Contact__c,Status__c,RecordType.DeveloperName,Project__r.RecordType.DeveloperName,Date__c 
                                            FROM Planned_Days_Off__c 
                                            WHERE (RecordType.DeveloperName IN ('DLI_W_LT_Training_Holidays','Project_Planned_Days_Off')) 
                                               OR (Contact__c IN :projectIdStudentId.values() AND Status__c = 'Approved')]){
            

            if((off.RecordType.DeveloperName == 'Project_Planned_Days_Off' && projectId.contains(off.Project__c)) 
                 ||((projectIdStudentId.values()).contains(off.Contact__c) && off.Status__c == 'Approved')){
                plannedOffDates.add(off.Date__c);
            }
            
            if(off.RecordType.DeveloperName == 'DLI_W_LT_Training_Holidays'){
                DLIWLTHolidays.add(off.Date__c);
            }
        }
        
        
        system.debug('::::::::plannedOffDates::::'+plannedOffDates);
        system.debug(':::::::DLIWLTHolidays::::'+DLIWLTHolidays);
        
        
        /*if(conIds.size() > 0){
            for(Contact con : [SELECT Id,Name,Email FROM Contact WHERE Id IN :conIds]){
                conIdRecMap.put(con.Id,con);
            }
        }*/
        
        
        //Qry current schedule related event records to avoid duplicate records creation
        for(Events__c eve : [SELECT Id,Name,Date__c,Status__c,Schedule__c,SequenceNo__c FROM Events__c WHERE Schedule__c IN :scheduleIds]){
            if(!schIdEventDates.containsKey(eve.Schedule__c)){
                schIdEventDates.put(eve.Schedule__c,new Set<Date>{eve.Date__c});
            }else {
                schIdEventDates.get(eve.Schedule__c).add(eve.Date__c);
            }
            
            if(!schIdLastEveSeqNum.containsKey(eve.Schedule__c)){
                schIdLastEveSeqNum.put(eve.Schedule__c,eve.SequenceNo__c);
            }else {
                if(schIdLastEveSeqNum.get(eve.Schedule__c) < eve.SequenceNo__c) {
                    schIdLastEveSeqNum.put(eve.Schedule__c,eve.SequenceNo__c);
                }
            }
            
           
        }
        system.debug('::::::schIdEventDates::::existing::events::info::'+schIdEventDates);
        system.debug(':::::::schIdLastEveSeqNum:::::'+schIdLastEveSeqNum);
        
        //Qry Existing Events based on the Project & Instrcutors to check the conflicts
        //existingEventsRecords = EventService.getEventByProject_InsIds(minimumStart,maxEndDate,projectId,instructorId);
        
        EventHandler eveHandle = new EventHandler();
        
       
        //Get Current Project related events
        // The below conflict check is not need, because project related schedules events are covered in student events section
        //date_ProjectEvents = eveHandle.getProjectEvents(projectId,scheduleIdRecMap.keySet(),minimumStart,maxEndDate,new Set<Date>());
        
        for(Id schId : scheduleIdRecMap.keySet()){
            if(scheduleIdRecMap.containsKey(schId)){
                Schedule__c schRec = scheduleIdRecMap.get(schId);                
                Date stDate = schRec.Start_Date__c;
                Date endDate = schRec.End_Date__c;
                Integer sequenceNo = 0;
                Set<String> daysValues = new Set<String>();
                if(schRec.Sunday__c) {
                    daysValues.add('Sunday');
                }
                
                if(schRec.Monday__c) {
                    daysValues.add('Monday');
                }
                
                if(schRec.Tuesday__c) {
                    daysValues.add('Tuesday');
                }
                
                if(schRec.Wednesday__c) {
                    daysValues.add('Wednesday');
                }
                
                if(schRec.Thursday__c) {
                    daysValues.add('Thursday');
                }
                
                if(schRec.Friday__c) {
                    daysValues.add('Friday');
                }
                
                if(schRec.Saturday__c) {
                    daysValues.add('Saturday');
                }
                Integer firstOccWeekNo;
                system.debug(':::::::::daysValues::::'+daysValues);
                system.debug(':::stDate::::::::endDate::::'+stDate+' , '+endDate);
                
                // To have continue sequence for newly creating events
                if(schIdEventDates.containsKey(schId)) {
                    sequenceNo = (Integer) schIdLastEveSeqNum.get(schId);
                }
                
                Boolean biweek = true;
                
                while(stDate <= endDate) {                    
                    DateTime stDateTime = DateTime.newInstance(stDate, Time.newInstance(0, 0, 0, 0));                    
                    Integer weekno = Integer.valueOf(stDateTime.Format('w')); 
                    String day = eveHandle.getDayValue(stDate);
                    
                    if(firstOccWeekNo == null && daysValues.contains(day)){
                        firstOccWeekNo = weekNo;
                    }
                    if(firstOccWeekNo != null && weekno != firstOccWeekNo){
                        
                        Integer no = weekno - firstOccWeekNo;                                               
                        biweek = (no != 0 && math.mod(no, 2) == 0) ? true : false;
                    }
                    //Check for existing events under this schdeule to avoid duplicate creation
                    if(!schIdEventDates.containsKey(schId) || (schIdEventDates.containsKey(schId) && !schIdEventDates.get(schId).contains(stDate))) {
                             
                        //check days matching
                        if(daysValues.contains(day)  && (!schRec.Bi_Weekly__c || (schRec.Bi_Weekly__c && biweek))) {
                            //system.debug(':::::::enter:1::if::');
                            //Holiday
                            
                            if((schRec.Exclude_Federal_Holidays__c && !holidayDates.contains(stDate)) || !schRec.Exclude_Federal_Holidays__c) {
                                //system.debug(':::::::enter:2::if::'+stDate);
                                //Planned Days off - for project & student specific planned days off
                                
                                /*Id studentId;
                                if(projectIdFlag.containsKey(schRec.Project__c) && projectIdStudentId.containsKey(schRec.Project__c)){
                                    studentId = projectIdStudentId.get(schRec.Project__c);
                                }*/
                                
                                if((plannedOffDates.size() == 0 || !plannedOffDates.contains(stDate)) 
                                    && (schRec.Project__r.RecordType.DeveloperName != 'DLI_W_LT_Projects' 
                                        || (schRec.Project__r.RecordType.DeveloperName == 'DLI_W_LT_Projects' && !DLIWLTHolidays.contains(stDate)))){
                                    
                                    //system.debug(':::::::enter:3::if::');
                                    // Add Events to the list with all properties after event formation check for the conflicts
                                    Events__c eve = new Events__c();
                                    eve.Name = schRec.Name+'-EV'+(++sequenceNo);
                                    eve.Date__c = stDate;
                                    eve.Start_Time__c = schRec.Start_Time__c;
                                    eve.End_Time__c = schRec.End_Time__c;
                                    eve.Project_Task__c = schRec.Project_Task__c;
                                    eve.Timezone__c = schRec.Timezone__c;
                                    eve.Schedule__c = schRec.Id;
                                    eve.Status__c = 'Scheduled';
                                    eve.SequenceNo__c = sequenceNo;
                                    eve.Duration__c = schRec.Hours_Planned__c;
                                    eve.Project__c = schRec.Project__c;
                                    eve.Instructor__c = schRec.Instructor__c;
                                    eve.Room__c = schRec.Room__c;
                                    
                                    if(!schIdEventRecords.containsKey(schId)) {
                                        schIdEventRecords.put(schId,new List<Events__c>{eve});
                                    } else {
                                        schIdEventRecords.get(schId).add(eve);
                                    }
                                    
                                    stDate = stDate.addDays(1);                                    
                                    
                                }else {
                                    stDate = stDate.addDays(1); 
                                    
                                }// End of Planned days off check
                            }else {
                                stDate = stDate.addDays(1); 
                            }// End of Holiday
                        }else {
                           stDate = stDate.addDays(1);   
                        }// End of days check
                    
                    }else {
                        stDate = stDate.addDays(1);
                    }// End of existing event check if
                    
                }// End of while loop
                system.debug(':::::::stDate:::::'+stDate);
                system.debug('::::::after:::while:loop:getCpuTime:::::'+Limits.getCpuTime());
            }
        }// End of for loop
        system.debug(':::::::::::schIdEventRecords::::::::'+schIdEventRecords);
        system.debug('::::::after:::for:loop:getCpuTime:::::'+Limits.getCpuTime());
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('2.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
        System.debug('3. Number of script statements used so far : ' + Limits.getDmlStatements());
        System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('5.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
        //system.debug(':::::::::schIdErrorWrapper::::::'+schIdErrorWrapper);
        
        // insert event records
        if(schIdEventRecords.values().size() > 0) {
            try {
                
                List<Events__c> newEventRecords = new List<Events__c>();
                
                for(Id schId : schIdEventRecords.keySet()){
                    newEventRecords.addAll(schIdEventRecords.get(schId));
                }
                
                system.debug(':::::::newEventRecords:::'+newEventRecords.size());
                
                if(newEventRecords.size() > 0) {
                    insert newEventRecords;
                    
                    //Call conflict check method to create Event Conflict records
                    // Get Student related Events
                    date_StudentEvents = eveHandle.getStudentEvents(projectId,scheduleIdRecMap.keySet(),minimumStart,maxEndDate,new Set<Date>{});
                    
                    //Get Room & Instrcutor related Events
                    date_RoomInstructorEvents = eveHandle.getRoom_InstructorEvents(instructorId,scheduleIdRecMap.keySet(),roomIds,minimumStart,maxEndDate,new Set<Date>()); 
                    
                    // Conflict check part & Email Content formation
                    eveHandle.checkEventConflicts(newEventRecords,date_StudentEvents,date_RoomInstructorEvents,newSchIdOldSchId);
                
                    //Send Email to the Project Manager about the conflict information
                    //eveHandle.sendConflictInformationEmail(schIdErrorWrapper,scheduleIdRecMap,proIdSuperviosrContId,proIdName,conIdRecMap);
                }
            
            }catch(Exception ex){
                system.debug('::::exception:::on::event::creation:::::::'+ex.getMessage());
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(ex.getMessage(),system.Label.TimeCardDayEmail,'Error on Event Creation');  
            }
        }
        
    }
    
    //Get Student specific events for conflict check
    public Map<Date,List<Events__c>> getStudentEvents(Set<Id> projectIds,Set<Id> scheduleIds,Date minDate,Date maxDate,Set<Date> eventDates) {
        Set<Id> studentIds = new Set<Id>();
        Set<Id> stuProjectIds = new Set<Id>();
        Map<Date,List<Events__c>> date_studentEvents = new Map<Date,List<Events__c>>();
        
        // get project related all student ids and  student related all project ids
        for(Contact_Assignments__c ca : [SELECT Candidate_Name__c,Project__c FROM Contact_Assignments__c WHERE ((Project__c IN :projectIds AND Candidate_Name__c != null) OR (Candidate_Name__c IN :studentIds AND Project__c != null)) AND RecordType.DeveloperName = 'Student' AND Status__c IN ('Active', 'Planned')]){
            if(projectIds.contains(ca.Project__c) && ca.Candidate_Name__c != null){
                studentIds.add(ca.Candidate_Name__c);
            }
            
            if(studentIds.contains(ca.Candidate_Name__c) && ca.Project__c != null){
                stuProjectIds.add(ca.Project__c);
            }
            
        }
        
        //Get Events based on the Student related Project Ids other than the current project ids
        
        if(minDate != null && maxDate != null) {
            for(Events__c eve : [SELECT Id, Name, Schedule__c, Project__c, schedule__r.Project__c, Date__c, Start_Time__c, End_Time__c, Room__r.Name 
                                FROM Events__c 
                                WHERE Project__c IN :stuProjectIds AND Schedule__c NOT IN :scheduleIds AND Date__c >= :minDate AND Date__c <= :maxDate AND Status__c = 'Scheduled' 
                                AND Start_Time__c != null AND End_Time__c != null]){
    
                if(!date_studentEvents.containsKey(eve.Date__c)){
                    date_studentEvents.put(eve.Date__c,new List<Events__c>{eve});
                }else {
                    date_studentEvents.get(eve.Date__c).add(eve);
                }                     
            }
        }else if(stuProjectIds.size() > 0 && eventDates.size() > 0){
            for(Events__c eve : [SELECT Id, Name, Schedule__c, Project__c, schedule__r.Project__c, Date__c, Start_Time__c, End_Time__c, Room__r.Name 
                                FROM Events__c 
                                WHERE Project__c IN :stuProjectIds AND Schedule__c NOT IN :scheduleIds AND Date__c IN :eventDates AND Status__c = 'Scheduled' 
                                AND Start_Time__c != null AND End_Time__c != null]){
    
                if(!date_studentEvents.containsKey(eve.Date__c)){
                    date_studentEvents.put(eve.Date__c,new List<Events__c>{eve});
                }else {
                    date_studentEvents.get(eve.Date__c).add(eve);
                }                     
            }
        }
        
        system.debug('::::::studentEvents:::::'+date_studentEvents.size());
        
        return date_studentEvents;
    }
    
    // Get Room & Instrcutor related events to check conflicts
    public Map<Date,List<Events__c>> getRoom_InstructorEvents(Set<Id> instructorIds,Set<Id> scheduleIds,Set<Id> roomIds,Date minDate,Date maxDate,Set<Date> eventDates){
        Map<Date,List<Events__c>> date_roomInsEvents = new Map<Date,List<Events__c>>();
        //Modified By Dhinesh - 23-02-2021 - Excluding the Zoom - Online Room to avoid non selective query error
        Id onlineRoomId;
            
        for(Room__c room : [SELECT Id,Name FROM Room__c WHERE Name = 'Zoom - Online']){
            onlineRoomId = room.Id;
        }
        
        if(onlineRoomId != null && roomIds != null){
            roomIds.remove(onlineRoomId);
        }
        
        if(minDate != null && maxDate != null) {
            //Modified By Dhinesh - 22-02-2021 - Splitted the SOQL into 2 with indexed Fields
            if(instructorIds != null && instructorIds.size() > 0){
                for(Events__c eve : [SELECT Id,Name,Schedule__c, Project__c, Date__c, Start_Time__c, End_Time__c,Instructor__c,Instructor__r.Name,Room__c,Room__r.Name 
                                    FROM Events__c 
                                    WHERE Instructor__c IN :instructorIds AND Date__c >= :minDate AND Date__c <= :maxDate
                                        AND Status__c = 'Scheduled' AND Schedule__c NOT IN :scheduleIds AND Room__r.Exclude_Conflict_Check__c = false AND Start_Time__c != null AND End_Time__c != null]) {
                    if(!date_roomInsEvents.containsKey(eve.Date__c)){
                        date_roomInsEvents.put(eve.Date__c,new List<Events__c>{eve});
                    }else {
                        date_roomInsEvents.get(eve.Date__c).add(eve);
                    }
                }
            }
            if(roomIds != null && roomIds.size() > 0){
                for(Events__c eve : [SELECT Id,Name,Schedule__c, Project__c, Date__c, Start_Time__c, End_Time__c,Instructor__c,Instructor__r.Name,Room__c,Room__r.Name 
                                    FROM Events__c 
                                    WHERE Room__c IN :roomIds AND Date__c >= :minDate AND Date__c <= :maxDate
                                        AND Status__c = 'Scheduled' AND Schedule__c NOT IN :scheduleIds AND Room__r.Exclude_Conflict_Check__c = false AND Start_Time__c != null AND End_Time__c != null]) {
                    if(!date_roomInsEvents.containsKey(eve.Date__c)){
                        date_roomInsEvents.put(eve.Date__c,new List<Events__c>{eve});
                    }else {
                        date_roomInsEvents.get(eve.Date__c).add(eve);
                    }
                }
            }
        }else if(eventDates.size() > 0) {
            //Modified By Dhinesh - 22-02-2021 - Splitted the SOQL into 2 with indexed Fields
            if(instructorIds != null && instructorIds.size() > 0){
                for(Events__c eve : [SELECT Id,Name,Schedule__c, Project__c, Date__c, Start_Time__c, End_Time__c,Instructor__c,Instructor__r.Name,Room__c,Room__r.Name 
                                    FROM Events__c 
                                    WHERE Instructor__c IN :instructorIds AND Date__c IN :eventDates
                                        AND Status__c = 'Scheduled' AND Schedule__c NOT IN :scheduleIds AND Room__r.Exclude_Conflict_Check__c = false AND Start_Time__c != null AND End_Time__c != null]) {
                    if(!date_roomInsEvents.containsKey(eve.Date__c)){
                        date_roomInsEvents.put(eve.Date__c,new List<Events__c>{eve});
                    }else {
                        date_roomInsEvents.get(eve.Date__c).add(eve);
                    }
                }
            }
            
            if(roomIds != null && roomIds.size() > 0){
                for(Events__c eve : [SELECT Id,Name,Schedule__c, Project__c, Date__c, Start_Time__c, End_Time__c,Instructor__c,Instructor__r.Name,Room__c,Room__r.Name 
                                    FROM Events__c 
                                    WHERE Room__c IN :roomIds AND Date__c IN :eventDates
                                        AND Status__c = 'Scheduled' AND Schedule__c NOT IN :scheduleIds AND Room__r.Exclude_Conflict_Check__c = false AND Start_Time__c != null AND End_Time__c != null]) {
                    if(!date_roomInsEvents.containsKey(eve.Date__c)){
                        date_roomInsEvents.put(eve.Date__c,new List<Events__c>{eve});
                    }else {
                        date_roomInsEvents.get(eve.Date__c).add(eve);
                    }
                }
            }
        
        }
        
        system.debug(':::::::date_roomInsEvents::::::'+date_roomInsEvents.size());
        
        return date_roomInsEvents;
    }
    
    // Get Project related Events to check conflicts
    /*public Map<Date,List<Events__c>> getProjectEvents(Set<Id> projectIds,Set<Id> scheduleIds,Date minDate,Date maxDate,Set<Date> eventDates) {
        Map<Date,List<Events__c>> date_projectEvents = new Map<Date,List<Events__c>>();
        
        if(minDate != null && maxDate != null) {
            for(Events__c eve : [SELECT Id, Name, Schedule__c, Project__c,Project__r.Name,Schedule__r.Project__c, Date__c, Start_Time__c, End_Time__c 
                                FROM Events__c 
                                WHERE Schedule__r.Project__c IN :projectIds AND  Date__c >= :minDate AND Date__c <= :maxDate 
                                    AND Status__c = 'Scheduled' AND Schedule__c NOT IN :scheduleIds AND Start_Time__c != null AND End_Time__c != null]) {
                                        
                if(!date_projectEvents.containsKey(eve.Date__c)){
                    date_projectEvents.put(eve.Date__c,new List<Events__c>{eve});
                }else {
                    date_projectEvents.get(eve.Date__c).add(eve);
                }                
            }
        }else if(eventDates.size() > 0){

            for(Events__c eve : [SELECT Id, Name, Schedule__c, Project__c,Project__r.Name,Schedule__r.Project__c, Date__c, Start_Time__c, End_Time__c 
                                FROM Events__c 
                                WHERE Schedule__r.Project__c IN :projectIds AND  Date__c IN :eventDates 
                                    AND Status__c = 'Scheduled' AND Schedule__c NOT IN :scheduleIds AND Start_Time__c != null AND End_Time__c != null]) {
                                        
                if(!date_projectEvents.containsKey(eve.Date__c)){
                    date_projectEvents.put(eve.Date__c,new List<Events__c>{eve});
                }else {
                    date_projectEvents.get(eve.Date__c).add(eve);
                }                
            }
        }
        
        system.debug(':::::date_projectEvents::::::::'+date_projectEvents);
        
        return date_projectEvents;
    }*/
    
    //Get Day value for a date
    public String getDayValue(Date eventDate){
        DateTime dt = DateTime.newInstance(eventDate, Time.newInstance(0, 0, 0, 0));
        String dayOfWeek = dt.format('EEEE');
        return dayOfWeek;
    }
    
    //Time to minute conversion
    public Integer convertToMinutes(String hourString) {
        String[] split1 = new String[]{};
        if(hourString != null) {
            split1 = hourString.split(' ');
        }
        
        String[] split2;
        Integer minutes = 0;
        
        if(split1.size() == 2) {
            split2 = split1[0].split(':');
        } else {
            return 0;
        }
        
        if(split2.size() != 2) {
            return 0;
        }else {
            if(split1[1] == 'AM') {
                minutes += Integer.valueOf(split2[0]) * 60;
                //minutes += (Integer) (split1[0]);
                if(split2[0] == '12') {
                    minutes = 0;
                }
                minutes += Integer.valueOf(split2[1]);
            } else if(split1[1] == 'PM') {
                Integer offset = 12;
                if(split2[0] == '12') {
                    offset = 0;
                }
                minutes = (Integer.valueOf(split2[0]) + offset) * 60;
                minutes += Integer.valueOf(split2[1]);
            }
        }
        
        return minutes;
    }
    
    //Conflict check Method for all type of events 
    public void checkEventConflicts(List<Events__c> eventRecords, Map<Date,List<Events__c>> studentEventMap, Map<Date,List<Events__c>> roomInsEventMap,Map<Id,Id> newSchIdOldSchId){
        
        //Map<Id,List<UtilDomain.ErrorWrapper>> schIdErrorWrapper = new Map<Id,List<UtilDomain.ErrorWrapper>>();
        
        system.debug('::::::::enter:::conflict::check:::method:::');
        system.debug('::::::::newSchIdOldSchId:::'+newSchIdOldSchId.size());
        
        Map<Id,Decimal> schIdEveSeqNum = new Map<Id,Decimal>();
        
        EventHandler eveHandle = new EventHandler();
        
        List<Event_Conflict__c> ConflictRecords = new List<Event_Conflict__c>();
        Map<String,Event_Conflict__c> externalIdConflictRec = new Map<String,Event_Conflict__c>();
        Set<Id> eventIds = new Set<Id>();
        
        Map<String,Event_Conflict__c> existingConflictMap = new Map<String,Event_Conflict__c>();
        List<Event_Conflict__c> conflictDeleteList = new List<Event_Conflict__c>();
        
        for(Events__c newEvent : eventRecords){
            eventIds.add(newEvent.Id);
        }
        system.debug('<<eventIds>>'+eventIds);
        //Query existing Event Conflict records
        for(Event_Conflict__c conflict : [SELECT Id,External_Id__c,Event__c,Conflict_Event__c,Date__c,Room_Conflict__c,Instructor_Conflict__c,Student_Conflict__c
                                            FROM Event_Conflict__c WHERE (Event__c IN :eventIds OR Conflict_Event__c IN :eventIds)]){
            
            existingConflictMap.put(conflict.External_Id__c,conflict);
        }
        
         
        for(Events__c newEvent : eventRecords){
        
            //Student Conflict check
            // If there is no start time & end time in new Event we cannot check conflict logic
            if(studentEventMap.containsKey(newEvent.Date__c) && newEvent.Start_Time__c != null && newEvent.End_Time__c != null){
                
                for(Events__c oldEvent : studentEventMap.get(newEvent.Date__c)){
                
                    Integer ST1,ET1,ST2,ET2;
                    
                    if(eveHandle.convertToMinutes(newEvent.Start_Time__c) > eveHandle.convertToMinutes(oldEvent.Start_Time__c)) {
                        ST1 = eveHandle.convertToMinutes(oldEvent.Start_Time__c);
                        ET1 = eveHandle.convertToMinutes(oldEvent.End_Time__c);
                        
                        ST2 = eveHandle.convertToMinutes(newEvent.Start_Time__c);
                        ET2 = eveHandle.convertToMinutes(newEvent.End_Time__c);
                        
                    }else {
                        ST1 = eveHandle.convertToMinutes(newEvent.Start_Time__c);
                        ET1 = eveHandle.convertToMinutes(newEvent.End_Time__c);
                        
                        ST2 = eveHandle.convertToMinutes(oldEvent.Start_Time__c);
                        ET2 = eveHandle.convertToMinutes(oldEvent.End_Time__c);
                    }
                    
                    if(ET2 >= ST1 && ST2 < ET1 && (newSchIdOldSchId.size() == 0 || (newSchIdOldSchId.containsKey(newEvent.Schedule__c) && newSchIdOldSchId.get(newEvent.Schedule__c) != oldEvent.Schedule__c))) {
                        //have conflict
                        
                        // Code to create Event Conflict records based on the conflict details
                        // Added by NS on OCT 8 2018
                        
                        system.debug(':::::::enter::student:conflict::::::');
                        
                        String key = String.valueOf(newEvent.Id)+String.valueOf(oldEvent.Id);
                        
                        Event_Conflict__c conflictRec = new Event_Conflict__c();
                        conflictRec.Event__c = newEvent.Id;
                        conflictRec.Date__c = newEvent.Date__c;
                        conflictRec.Project__c = newEvent.Project__c;
                        conflictRec.Schedule__c = newEvent.Schedule__c;
                        conflictRec.Conflict_Status__c = 'Identified as Conflict';
                        conflictRec.Instructor_Conflict__c = false;
                        conflictRec.Room_Conflict__c = false;
                        
                        
                        conflictRec.Conflict_Event__c = oldEvent.Id;
                        conflictRec.Student_Conflict__c = true;
                        conflictRec.External_Id__c = key;
                        
                        if(!externalIdConflictRec.containsKey(key)){
                            externalIdConflictRec.put(key,conflictRec);
                        }
                        
                    }// End of time comparison
                }// End of student events map for loop
            }// End of student date contains if
            
            
            // Room & Instructor Conflict check
            // If there is no start time & end time in new Event we cannot check conflict logic
            if(roomInsEventMap.containsKey(newEvent.Date__c) && newEvent.Start_Time__c != null && newEvent.End_Time__c != null) {
                for(Events__c oldEvent : roomInsEventMap.get(newEvent.Date__c)) {
                
                    Integer ST1,ET1,ST2,ET2;
                    
                    if(eveHandle.convertToMinutes(newEvent.Start_Time__c) > eveHandle.convertToMinutes(oldEvent.Start_Time__c)) {
                        ST1 = eveHandle.convertToMinutes(oldEvent.Start_Time__c);
                        ET1 = eveHandle.convertToMinutes(oldEvent.End_Time__c);
                        
                        ST2 = eveHandle.convertToMinutes(newEvent.Start_Time__c);
                        ET2 = eveHandle.convertToMinutes(newEvent.End_Time__c);
                        
                    }else {
                        ST1 = eveHandle.convertToMinutes(newEvent.Start_Time__c);
                        ET1 = eveHandle.convertToMinutes(newEvent.End_Time__c);
                        
                        ST2 = eveHandle.convertToMinutes(oldEvent.Start_Time__c);
                        ET2 = eveHandle.convertToMinutes(oldEvent.End_Time__c);
                    }
                                       
                    //Instructor Conflict
                    if(newEvent.Instructor__c == oldEvent.Instructor__c && newEvent.Instructor__c != null && oldEvent.Instructor__c != null){
                        if(ET2 >= ST1 && ST2 < ET1 && (newSchIdOldSchId.size() == 0 || (newSchIdOldSchId.containsKey(newEvent.Schedule__c) && newSchIdOldSchId.get(newEvent.Schedule__c) != oldEvent.Schedule__c))) {
                            //have conflict
                            
                            system.debug(':::::::enter::instructor:conflict:::::::::::');
                            
                            String inskey = String.valueOf(newEvent.Id)+String.valueOf(oldEvent.Id);
                            
                            Event_Conflict__c conflictRec = new Event_Conflict__c();
                            conflictRec.Event__c = newEvent.Id;
                            conflictRec.Date__c = newEvent.Date__c;
                            conflictRec.Project__c = newEvent.Project__c;
                            conflictRec.Schedule__c = newEvent.Schedule__c;
                            conflictRec.Conflict_Status__c = 'Identified as Conflict';
                            conflictRec.Student_Conflict__c = false;
                            conflictRec.Room_Conflict__c = false;
                            
                            
                            conflictRec.Conflict_Event__c = oldEvent.Id;
                            conflictRec.Instructor_Conflict__c = true;
                            conflictRec.External_Id__c = inskey;
                            
                            if(!externalIdConflictRec.containsKey(inskey)){
                            
                                externalIdConflictRec.put(inskey,conflictRec);
                                
                            }else if(externalIdConflictRec.containsKey(inskey)) {
                            
                                Event_Conflict__c eveConflict = externalIdConflictRec.get(inskey);
                                externalIdConflictRec.remove(inskey);
                                eveConflict.External_Id__c = inskey;
                                eveConflict.Instructor_Conflict__c = true;
                                
                                externalIdConflictRec.put(inskey,eveConflict);
                                
                            }
                        }
                        
                    }
                    
                    //Room Conflict
                    if(newEvent.Room__c == oldEvent.Room__c && newEvent.Room__c != null && oldEvent.Room__c != null){
                        if(ET2 >= ST1 && ST2 < ET1 && (newSchIdOldSchId.size() == 0 || (newSchIdOldSchId.containsKey(newEvent.Schedule__c) && newSchIdOldSchId.get(newEvent.Schedule__c) != oldEvent.Schedule__c))){
                            //have conflict
                            
                            system.debug(':::::::enter::room:conflict:::::::::');
                            
                            String roomkey = String.valueOf(newEvent.Id)+String.valueOf(oldEvent.Id);
                            
                            Event_Conflict__c conflictRec = new Event_Conflict__c();
                            conflictRec.Event__c = newEvent.Id;
                            conflictRec.Date__c = newEvent.Date__c;
                            conflictRec.Project__c = newEvent.Project__c;
                            conflictRec.Schedule__c = newEvent.Schedule__c;
                            conflictRec.Conflict_Status__c = 'Identified as Conflict';
                            conflictRec.Student_Conflict__c = false;
                            conflictRec.Instructor_Conflict__c = false;
                            
                            
                            conflictRec.Conflict_Event__c = oldEvent.Id;
                            conflictRec.Room_Conflict__c = true;
                            conflictRec.External_Id__c = roomkey;
                            
                            if(!externalIdConflictRec.containsKey(roomkey)){
                            
                                externalIdConflictRec.put(roomkey,conflictRec);
                                
                            }else if(externalIdConflictRec.containsKey(roomkey)) {
                            
                                Event_Conflict__c eveConflict = externalIdConflictRec.get(roomkey);
                                externalIdConflictRec.remove(roomkey);
                                eveConflict.External_Id__c = roomkey;
                                eveConflict.Room_Conflict__c = true;
                                
                                externalIdConflictRec.put(roomkey,eveConflict);
                                
                            }
                        }
                    }
                    
                    
                }// End of Room & Instructor Map for loop
            }// End of Room & Ins date contains if
            
        }// End of new Events for loop
        
        system.debug(':::::::externalIdConflictRec:::::'+externalIdConflictRec);
        system.debug(':::::::existingConflictMap:::::'+existingConflictMap);
        
        // created Event Conflict records
        
        for(String key : externalIdConflictRec.keySet()){
            ConflictRecords.add(externalIdConflictRec.get(key));
            
            if(existingConflictMap.containsKey(key)) {
                existingConflictMap.remove(key);
            }
        }
        
        //delete pending conflict records related to the events
        for(String oldKey : existingConflictMap.keySet()){
            conflictDeleteList.add(existingConflictMap.get(oldKey));
        }
        
        system.debug('::::::::::ConflictRecords:::::'+ConflictRecords);
        system.debug('::::::::::conflictDeleteList:::::'+conflictDeleteList);
        
        if(ConflictRecords.size() > 0){
            upsert ConflictRecords External_Id__c;
        }
        
        if(conflictDeleteList.size() > 0){
            delete conflictDeleteList;
        }
    }
    
    public Event_Conflict__c generateConflict(Events__c newEvent){
    
        Event_Conflict__c conflictRec = new Event_Conflict__c();
        conflictRec.Event__c = newEvent.Id;
        conflictRec.Date__c = newEvent.Date__c;
        conflictRec.Project__c = newEvent.Project__c;
        conflictRec.Schedule__c = newEvent.Schedule__c;
        conflictRec.Conflict_Status__c = 'Identified as Conflict';
        conflictRec.Student_Conflict__c = false;
        conflictRec.Instructor_Conflict__c = false;
        conflictRec.Room_Conflict__c = false;
        
        system.debug('::::::conflictRec:::'+conflictRec);
        
        return conflictRec;
    }
    
    // Method to send the Conflict information to project manager
    /*public void sendConflictInformationEmail(Map<Id,List<UtilDomain.ErrorWrapper>> schIdErrorWrapper,Map<Id,Schedule__c> schIdRecMap,Map<Id,Id> proIdConIdMap,Map<Id,String> proIdNameMap,Map<Id,Contact> conIdRecMap) {
        
        system.debug(':::::::::enter:::sendConflictInformationEmail:::');
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        Map<Id,String> proIdEmailContent = new Map<Id,String>();
        
        system.debug(':::::::::proIdNameMap::::::'+proIdNameMap);
        
        for(Id schId : schIdErrorWrapper.keySet()){
            
            Schedule__c schRec = schIdRecMap.get(schId);
            system.debug('::::::::schRec:::::'+schRec);
            
            String mailContent = '<html>Dear Softsquare,<br/>The following events have conflicts with other events:'; 
            mailContent += '<br/><table border="1" style="border-collapse: collapse"><thead><th>Project Name</th><th>Schedule Name</th><th>Description</th></thead><tbody>';  
            mailContent += '<tr><td width="25%"><a href="'+System.Label.Org_Prefix_Start_URL+'/'+schRec.Project__c+'" target="_blank">'+proIdNameMap.get(schRec.Project__c)+'</a></td><td width="25%"><a href="'+System.Label.Org_Prefix_Start_URL+'/'+schRec.Id+'" target="_blank">'+schRec.Name+'</a></td><td>'; 
            
            for(UtilDomain.ErrorWrapper val : schIdErrorWrapper.get(schId)){
                mailContent += val.record.get('Name')+' : '+val.message+'<br/>';
            }
            mailContent += '</td></tr></tbody></table><br/><p>This e-mail was auto generated. Please do not respond.</p><p>If you have questions, contact your Salesforce Administrator.</p>';
            mailContent += '</html>';
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            Contact con = conIdRecMap.get(proIdConIdMap.get(schRec.Project__c));
            
            //mail.setToAddresses(con.Email);
            mail.setToAddresses(new List<String> {'sukanyan@softsquare.biz'});
            mail.setSubject('Conflict detials on event creation');
            mail.sethtmlBody(mailContent);
            mails.add(mail);
        }
        
        system.debug('::::::::mails::::'+mails);
        if( mails != null && mails.size() > 0 && !Test.isRunningTest()) {
            Messaging.sendEmail(mails);
        }
    }*/
    
    
    // Method to delete the old schedule related event records based on the new schedule start & end date (Replace Instrutor & Schedule Change type)
    public void deleteOldScheduleEvents(Map<Id,Id> newSchId_ParentSchId){
        
        system.debug(':::deleteOldScheduleEvents::::newSchId_ParentSchId:::::'+newSchId_ParentSchId);
        
        Date startDate;
        Date endDate;
        Map<Id,String> oldSchIdNewSchDate = new Map<Id,String>();
        List<Events__c> eventsToDelete = new List<Events__c>();
        
        //Qry new Schdeule records for start & end date
        for(Schedule__c sch : [SELECT Id,Name,End_Date__c,Start_Date__c,Prior_Schedule__c 
                                    FROM Schedule__c 
                                    WHERE Id IN :newSchId_ParentSchId.keySet() AND Status__c = 'Active']){
            
            if(!oldSchIdNewSchDate.containsKey(sch.Prior_Schedule__c)){
                oldSchIdNewSchDate.put(sch.Prior_Schedule__c,sch.Start_Date__c+'~'+sch.End_Date__c);
            }
            
            if(startDate == null){
                startDate = sch.Start_Date__c;
            }else if(startDate > sch.Start_Date__c) {
                startDate = sch.Start_Date__c;
            }
            
            if(endDate == null){
                endDate = sch.End_Date__c;
            }else if(endDate < sch.Start_Date__c) {
                endDate = sch.End_Date__c;
            }
        }
        
        //Qry Events in between those 2 dates for deletion
        for(Events__c eve : [SELECT Id,Name,Date__c,Schedule__c,Status__c 
                                FROM Events__c 
                                WHERE Schedule__c IN :newSchId_ParentSchId.values() AND Date__c >= :startDate AND Date__c <= :endDate]){
            
            if(oldSchIdNewSchDate.containsKey(eve.Schedule__c)){
                Date stDate = Date.valueOf(oldSchIdNewSchDate.get(eve.Schedule__c).split('~')[0]);
                Date edDate = Date.valueOf(oldSchIdNewSchDate.get(eve.Schedule__c).split('~')[1]);
                
                if(eve.Date__c >= stDate && eve.Date__c <= edDate){
                    eventsToDelete.add(eve);
                }
            }
        }
        
        system.debug('::::deleteOldScheduleEvents:::eventsToDelete:::::'+eventsToDelete);
        
        if(eventsToDelete.size() > 0){
            delete eventsToDelete;
        }
    }
    
    
    // Make the old Schedule related event status as Substitute based on the new schedule records date
    // Update the new Schedule related events status as Scheduled
    public void updateOldScheduleEventsStatus(Map<Id,Id> newSchId_ParentSchId){
        
        system.debug(':::updateOldScheduleEventsStatus::::newSchId_ParentSchId:::::'+newSchId_ParentSchId);
        
        Date startDate;
        Date endDate;
        Map<Id,Set<Date>> oldSchId_EventsDate = new Map<Id,Set<Date>>();
        List<Events__c> eventsToUpdate = new List<Events__c>();
        
       
        // Get new schedule related events to make the status as Scheduled
        for(Events__c eve : [SELECT Id,Name,Date__c,Status__c,Schedule__c,Schedule__r.Prior_Schedule__c 
                                FROM Events__c 
                                WHERE Schedule__c IN :newSchId_ParentSchId.keySet() AND Status__c = 'Draft' AND Schedule__r.Prior_Schedule__c != null 
                                    AND Schedule__r.Status__c = 'Active' AND Schedule__r.Schedule_Type__c = 'Substitute']){
                                        
            if(!oldSchId_EventsDate.containsKey(eve.Schedule__r.Prior_Schedule__c)) {
                oldSchId_EventsDate.put(eve.Schedule__r.Prior_Schedule__c,new Set<Date>{eve.Date__c});
            } else {
                oldSchId_EventsDate.get(eve.Schedule__r.Prior_Schedule__c).add(eve.Date__c);
            }
            
            eve.Status__c = 'Scheduled';
            eventsToUpdate.add(eve);
        }


        //Qry old schedule related event records for status update
        for(Events__c eve : [SELECT Id,Name,Date__c,Status__c,Schedule__c 
                                FROM Events__c 
                                WHERE Schedule__c IN :newSchId_ParentSchId.values()]){
                                    
            if(oldSchId_EventsDate.containsKey(eve.Schedule__c) && oldSchId_EventsDate.get(eve.Schedule__c).contains(eve.Date__c)){
                eve.Status__c = 'Substituted';
                eventsToUpdate.add(eve);
            }
        }
     
        if(eventsToUpdate.size() > 0){
            update eventsToUpdate;
        }
    }
    
    // Method to delete the excess Events after the Schedule End date is reduced
    public void deleteExcessEventsRecords(Map<Id,Date> schIdEndDate){
    
        system.debug(':::deleteExcessEventsRecords::::schIdEndDate::::::'+schIdEndDate);
        
        List<Events__c> eventsListToDelete = new List<Events__c>();     
        
        if(schIdEndDate.keySet().size() > 0) {   
            for(Events__c eve : [SELECT Id,Name,Schedule__c,Date__c FROM Events__c WHERE Schedule__c IN :schIdEndDate.keySet()]){
                if(schIdEndDate.containsKey(eve.Schedule__c) && eve.Date__c > schIdEndDate.get(eve.Schedule__c)) {
                    
                    eventsListToDelete.add(eve);
                }
            }
            
            system.debug(':::deleteExcessEventsRecords::::eventsListToDelete:::::'+eventsListToDelete);
            
            if(eventsListToDelete.size() > 0){
                delete eventsListToDelete;
            }
        }
    }
    
    //Method to delete excess events based on the schedule start date is increased
    //Work Item : W-003760
    public void deleteOldEventRecords(Map<Id,Date> schIdStartDate){
    
        List<Events__c> eventsListToDelete = new List<Events__c>();     
        
        if(schIdStartDate.keySet().size() > 0) {   
            for(Events__c eve : [SELECT Id,Name,Schedule__c,Date__c FROM Events__c WHERE Schedule__c IN :schIdStartDate.keySet()]){
                if(schIdStartDate.containsKey(eve.Schedule__c) && eve.Date__c < schIdStartDate.get(eve.Schedule__c)) {
                    
                    eventsListToDelete.add(eve);
                }
            }
            
            system.debug(':::deleteOldEventsRecords::::eventsListToDelete:::::'+eventsListToDelete);
            
            if(eventsListToDelete.size() > 0){
                delete eventsListToDelete;
            }
        }
    }
    //Bulk Handling
    //Method to Create Substitute Schedules related event records on  schedules creation
    // Events are created with "Draft" status, when shedule is activated event status changed from "Draft" to "Scheduled"
    public void createSubstitueScheduleEvts(Map<Id,Set<Date>> schWithEvtDate){
        
        // Get Schedule record
        List<Schedule__c> scheduleRecords = SObjectQueryService.SObjectQuery('Schedule__c',schWithEvtDate.keySet(),',Project__r.RecordType.DeveloperName');
        
        Map<Id,Schedule__c> scheduleIdRecMap = new Map<Id,Schedule__c>();
        Set<Id> projectId = new Set<Id>();
        Map<Id,Boolean> projectIdFlag = new Map<Id,Boolean>();    // To Track the project have one / multiple student - if only one student- flag = true or if > 1 flag = false
        Map<Id,Id> projectIdStudentId = new Map<Id,Id>();    // To track project specific students if only one student present
        Set<Date> plannedOffDates = new Set<Date>();    // To hold Student & Project Specific planned days off informations
        Set<Date> DLIWLTHolidays = new Set<Date>();
        Set<Date> holidayDates = new Set<Date>();
        
        //To check event Conflict folllowing variabled are used
        Set<Id> instructorId = new Set<Id>();
        Set<Id> roomIds = new Set<Id>();
        Map<Date,List<Events__c>> date_StudentEvents = new Map<Date,List<Events__c>>();
        Map<Date,List<Events__c>> date_RoomInstructorEvents = new Map<Date,List<Events__c>>();
        Map<Date,List<Events__c>> date_ProjectEvents = new Map<Date,List<Events__c>>();
        
        Map<Id,List<Events__c>> schIdEventRecords = new Map<Id,List<Events__c>>();
        
        // Map to hold the Project related Supervisor Contact info to send conflict informations
        Map<Id,Id> proIdSuperviosrContId = new Map<Id,Id>();
        Map<Id,String> proIdName = new Map<Id,String>();
        Map<Id,List<UtilDomain.ErrorWrapper>> schIdErrorWrapper = new Map<Id,List<UtilDomain.ErrorWrapper>>();
        Map<Id,Contact> conIdRecMap = new Map<Id,Contact>();
        
        //Check for existing events before creating new events under schedule record
        Map<Id,Set<Date>> schIdEventDates = new Map<Id,Set<Date>>();
        Map<Id,Decimal> schIdLastEveSeqNum = new Map<Id,Decimal>();
        Map<Id,String> proIdActiveStudentsNames = new Map<Id,String>();
        Map<Id,Id> newSchIdOldSchId = new Map<Id,Id>();
        
        //For Holiday Dates formation
        Date minimumStart;
        Date maxEndDate;
        
        for(Schedule__c sch : scheduleRecords){
            scheduleIdRecMap.put(sch.Id,sch);
            projectId.add(sch.Project__c);
            
            if(sch.Instructor__c != null) {
                instructorId.add(sch.Instructor__c);
            }
                
            if(sch.Room__c != null) {
                roomIds.add(sch.Room__c);
            }
           
            if(sch.Prior_Schedule__c != null) {
                newSchIdOldSchId.put(sch.Id,sch.Prior_Schedule__c);
            }
            
            if((minimumStart != null && minimumStart > sch.Start_Date__c) || minimumStart == null) {
                minimumStart = sch.Start_Date__c;
            }
            
            if((maxEndDate != null && maxEndDate < sch.End_Date__c) || maxEndDate == null) {
                maxEndDate = sch.End_Date__c;
            }
        }
        
        /*for(Holiday hol : HolidayService.getHolidaysWithRecurrence(minimumStart,maxEndDate)){
            holidayDates.add(hol.ActivityDate);
        }*/
        holidayDates = HolidayService.getHolidaysWithRecurrence(minimumStart,maxEndDate);
        
        system.debug(':::::::holidayDates::::'+holidayDates);
        
        system.debug('::::::::::scheduleIdRecMap::::'+scheduleIdRecMap);
        
        //Qty Project related Student CA for Planned days off check
        for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c,Project__c,Project__r.Name,Project__r.Students__c FROM Contact_Assignments__c WHERE Project__c IN :projectId AND RecordType.DeveloperName = 'Student' AND Status__c = 'Active']){

            projectIdStudentId.put(ca.Project__c,ca.Candidate_Name__c);
            if(!projectIdFlag.containsKey(ca.Project__c)){
                projectIdFlag.put(ca.Project__c,true);
            }else {
                projectIdFlag.put(ca.Project__c,false);
                projectIdStudentId.remove(ca.Project__c);
            }
            
            if(!proIdActiveStudentsNames.containsKey(ca.Project__c)) {
                proIdActiveStudentsNames.put(ca.Project__c,ca.Project__r.Students__c);
            }
            
            if(!proIdName.containsKey(ca.Project__c)) {
                proIdName.put(ca.Project__c,ca.Project__r.Name);
            }

        }
        
        system.debug('::::::::::projectIdFlag::::'+projectIdFlag);
        system.debug('::::::::::projectIdStudentId::::'+projectIdStudentId);
        system.debug('::::::::::proIdActiveStudentsNames::::'+proIdActiveStudentsNames);
        system.debug('::::::::::proIdName::::'+proIdName);
        
        // Qry student specific Planned days off records
        for(Planned_Days_Off__c off : [SELECT Id,Name,Contact__c,Date__c FROM Planned_Days_Off__c WHERE Contact__c IN :projectIdStudentId.values() AND Status__c = 'Approved']){
            plannedOffDates.add(off.Date__c);
        }
        
        //Qry Project Specific && DLI W LT related Planned Days off records
        for(Planned_Days_Off__c off : [SELECT Id,Name,Project__c,RecordType.DeveloperName,Project__r.RecordType.DeveloperName,Date__c 
                                            FROM Planned_Days_Off__c 
                                            WHERE RecordType.DeveloperName IN ('DLI_W_LT_Training_Holidays','Project_Planned_Days_Off')]){
            
            if(off.RecordType.DeveloperName == 'Project_Planned_Days_Off' && projectId.contains(off.Project__c)){
                plannedOffDates.add(off.Date__c);
            }
            
            if(off.RecordType.DeveloperName == 'DLI_W_LT_Training_Holidays'){
                DLIWLTHolidays.add(off.Date__c);
            }
        }
        
        system.debug('::::::::plannedOffDates::::'+plannedOffDates);
        
        //Qry Project related recent supervisor contact from CA to send conflict information as mail
        Set<Id> conIds = new Set<Id>();
        for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c,Candidate_Name__r.Name,Project__c,Project__r.Name FROM Contact_Assignments__c WHERE Project__c != null AND Project__c IN :projectId AND Status__c = 'Active' AND RecordType.DeveloperName = 'Staff']){
            if(!proIdSuperviosrContId.containsKey(ca.Project__c)) {
                proIdSuperviosrContId.put(ca.Project__c,ca.Candidate_Name__c);
            }
                
            conIds.add(ca.Candidate_Name__c);
            
        }
        system.debug('::::::::proIdSuperviosrContId::::'+proIdSuperviosrContId);
        
        /*if(conIds.size() > 0){
            for(Contact con : [SELECT Id,Name,Email FROM Contact WHERE Id IN :conIds]){
                conIdRecMap.put(con.Id,con);
            }
        }*/
        
       
        //Qry current schedule related event records to avoid duplicate records creation
        for(Events__c eve : [SELECT Id,Name,Date__c,Status__c,Schedule__c,SequenceNo__c FROM Events__c WHERE Schedule__c IN :schWithEvtDate.keySet() AND Status__c = 'Scheduled']){
            if(!schIdEventDates.containsKey(eve.Schedule__c)){
                schIdEventDates.put(eve.Schedule__c,new Set<Date>{eve.Date__c});
            }else {
                schIdEventDates.get(eve.Schedule__c).add(eve.Date__c);
            }
            
            if(!schIdLastEveSeqNum.containsKey(eve.Schedule__c)){
                schIdLastEveSeqNum.put(eve.Schedule__c,eve.SequenceNo__c);
            }else {
                if(schIdLastEveSeqNum.get(eve.Schedule__c) < eve.SequenceNo__c) {
                    schIdLastEveSeqNum.put(eve.Schedule__c,eve.SequenceNo__c);
                }
            }

        }
        system.debug('::::::schIdEventDates::::existing::events::info::'+schIdEventDates);
        system.debug(':::::::schIdLastEveSeqNum:::::'+schIdLastEveSeqNum);
        
        EventHandler eveHandle = new EventHandler();
        
        //Get Current Project related events
        //date_ProjectEvents = eveHandle.getProjectEvents(projectId,scheduleIdRecMap.keySet(),null,null,EventDate);
        
        for(Id schId : scheduleIdRecMap.keySet()){
            if(scheduleIdRecMap.containsKey(schId)){
                Schedule__c schRec = scheduleIdRecMap.get(schId);
                Integer sequenceNo = 0;
                
                // To have continue sequence for newly creating events
                if(schIdEventDates.containsKey(schId)) {
                    sequenceNo = (Integer) schIdLastEveSeqNum.get(schId);
                }
                System.debug('::schWithEvtDate'+schWithEvtDate);
                if(schWithEvtDate.containsKey(schId)){
                    for(Date stDate : schWithEvtDate.get(schId)) {
                        system.debug(':::::::stDate:::::'+stDate);
                        
                        //Check for existing events under this schdeule to avoid duplicate creation
                        if(!schIdEventDates.containsKey(schId) || (schIdEventDates.containsKey(schId) && !schIdEventDates.get(schId).contains(stDate))) {
                            
                            //system.debug(':::::::enter:1::if::');
                            //Holiday
                            if((schRec.Exclude_Federal_Holidays__c && !holidayDates.contains(stDate)) || !schRec.Exclude_Federal_Holidays__c) {
                                //system.debug(':::::::enter:2::if::');
                                //Planned Days off - for project & student specific planned days off
                                
                                /*Id studentId;
                                if(projectIdFlag.containsKey(schRec.Project__c) && projectIdStudentId.containsKey(schRec.Project__c)){
                                studentId = projectIdStudentId.get(schRec.Project__c);
                                }*/
                                                                
                                if((plannedOffDates.size() == 0 || !plannedOffDates.contains(stDate)) 
                                   && (schRec.Project__r.RecordType.DeveloperName != 'DLI_W_LT_Projects' 
                                       || (schRec.Project__r.RecordType.DeveloperName == 'DLI_W_LT_Projects' && !DLIWLTHolidays.contains(stDate)))){
                                           
                                           //system.debug(':::::::enter:3::if::');
                                           // Add Events to the list with all properties after event formation check for the conflicts
                                           Events__c eve = new Events__c();
                                           eve.Name = schRec.Name+'-EV'+(++sequenceNo);
                                           eve.Date__c = stDate;
                                           eve.Start_Time__c = schRec.Start_Time__c;
                                           eve.End_Time__c = schRec.End_Time__c;
                                           eve.Timezone__c = schRec.Timezone__c;
                                           eve.Schedule__c = schRec.Id;
                                           
                                           if(schRec.Status__c == 'Active') {
                                               eve.Status__c = 'Scheduled';
                                           } else {
                                               eve.Status__c = 'Draft';
                                           }
                                           
                                           eve.SequenceNo__c = sequenceNo;
                                           eve.Duration__c = schRec.Hours_Planned__c;
                                           eve.Project__c = schRec.Project__c;
                                           eve.Project_Task__c = schRec.Project_Task__c;
                                           eve.Instructor__c = schRec.Instructor__c;
                                           eve.Room__c = schRec.Room__c;
                                           
                                           if(!schIdEventRecords.containsKey(schId)) {
                                               schIdEventRecords.put(schId,new List<Events__c>{eve});
                                           } else {
                                               schIdEventRecords.get(schId).add(eve);
                                           }
                                           
                                       }// End of Planned days off check
                                
                            }// End of Holiday
                            
                        }// End of existing event check if
                        
                    }// End of while loop
                }
                system.debug('::::::after:::while:loop:getCpuTime:::::'+Limits.getCpuTime());
            }
        }// End of for loop
        system.debug(':::::::::::schIdEventRecords::::::::'+schIdEventRecords);
        system.debug('::::::after:::for:loop:getCpuTime:::::'+Limits.getCpuTime());
        
        System.debug('1.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('2.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
        System.debug('3. Number of script statements used so far : ' + Limits.getDmlStatements());
        System.debug('4.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('5.Number of rows queried in this apex code so far: ' + Limits.getDmlRows());
        
        // insert event records
        if(schIdEventRecords.values().size() > 0) {
           // try {
                
                List<Events__c> newEventRecords = new List<Events__c>();
                
                for(Id schId : schIdEventRecords.keySet()){
                    newEventRecords.addAll(schIdEventRecords.get(schId));
                }
                
                system.debug(':::::::newEventRecords:::'+newEventRecords.size());
                
                if(newEventRecords.size() > 0) {
                    insert newEventRecords;
                    
                    Set<Date> eventDates = new Set<Date>();
                    for(Set<Date> eDt: schWithEvtDate.values()){
                        eventDates.addAll(eDt);
                    }
                    
                    // Get Student related Events
                    date_StudentEvents = eveHandle.getStudentEvents(projectId,scheduleIdRecMap.keySet(),null,null,eventDates);
                    
                    //Get Room & Instrcutor related Events
                    date_RoomInstructorEvents = eveHandle.getRoom_InstructorEvents(instructorId,scheduleIdRecMap.keySet(),roomIds,null,null,eventDates); 
                    
                    // Conflict check part & Email Content formation
                    eveHandle.checkEventConflicts(newEventRecords,date_StudentEvents,date_RoomInstructorEvents,newSchIdOldSchId);        
                    
                    //Send Email to the Project Manager about the conflict information
                    //eveHandle.sendConflictInformationEmail(schIdErrorWrapper,scheduleIdRecMap,proIdSuperviosrContId,proIdName,conIdRecMap);
                }
            
         /*   }catch(Exception ex){
                system.debug('::::exception:::on::event::creation:::::::'+ex.getMessage());
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(ex.getMessage(),system.Label.TimeCardDayEmail,'Error on Event Creation');  
            }*/
        }
        
       
    }
    
    // Delete event conflict records based on event actions (Delete, status change to Cancelled / Completed)
    // Added by NS on OCT 10 2018
    public void deleteConflictRecords(Set<Id> eventIds) {
        
        system.debug('::::deleteConflictRecords::::::::eventIds::::'+eventIds.size());
        
        if(eventIds.size() > 0) {
            List<Event_Conflict__c> ConflictRecords = [SELECT Id,Name,Event__c,Conflict_Event__c,Conflict_Status__c FROM Event_Conflict__c WHERE (Event__c IN :eventIds OR Conflict_Event__c IN :eventIds)];
            
            system.debug('::::deleteConflictRecords::ConflictRecords:::'+ConflictRecords.size());
            
            if(ConflictRecords.size() > 0){
                delete ConflictRecords;
            }
        }
    }
    
    // Create Event Conflict records when the event record field changes (Status,Instructor,Room,Date,Start & End time)
    // Added by NS on OCT 10 2018
    public void createEventConflictRecords(List<Events__c> eventRecords) {
        system.debug('::::::::enter::createEventConflictRecords::'+eventRecords.size());
        Set<Id> instructorIds = new Set<Id>();
        Set<Id> roomIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();
        Set<Id> scheduleIds = new Set<Id>();
        Set<Date> eventDates = new Set<Date>();
        
        Map<Date,List<Events__c>> date_StudentEvents = new Map<Date,List<Events__c>>();
        Map<Date,List<Events__c>> date_RoomInstructorEvents = new Map<Date,List<Events__c>>();
        Map<Id,Id> newSchIdOldSchId = new Map<Id,Id>();
        
        for(Events__c eve : eventRecords) {
            if(eve.Instructor__c != null) {
                instructorIds.add(eve.Instructor__c);
            }
            
            if(eve.Room__c != null) {
                roomIds.add(eve.Room__c);
            }
            
            if(eve.Project__c != null) {
                projectIds.add(eve.Project__c);
            }
            
            if(eve.Schedule__c != null) {
                scheduleIds.add(eve.Schedule__c);
            }
            
            if(eve.Date__c != null) {
                eventDates.add(eve.Date__c);
            }
        }
        
        for(Schedule__c sch : [SELECT Id,Name,Prior_Schedule__c FROM Schedule__c WHERE Id IN :scheduleIds]){
            if(sch.Prior_Schedule__c != null) {
                newSchIdOldSchId.put(sch.Id,sch.Prior_Schedule__c);
            }
        }
        
        EventHandler eveHandle = new EventHandler();
        // Get Student related Events
        date_StudentEvents = eveHandle.getStudentEvents(projectIds,scheduleIds,null,null,eventDates);
        
        //Get Room & Instrcutor related Events
        date_RoomInstructorEvents = eveHandle.getRoom_InstructorEvents(instructorIds,scheduleIds,roomIds,null,null,eventDates); 
        
        try {
            // Conflict check part & Email Content formation
            eveHandle.checkEventConflicts(eventRecords,date_StudentEvents,date_RoomInstructorEvents,newSchIdOldSchId);
        
        }catch(Exception ex){
            system.debug('::::exception:::on::event::conflict::creation:::::'+ex.getMessage());
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(ex.getMessage(),system.Label.TimeCardDayEmail,'Error on Event Conflict record creation when Event status updated to Scheduled');  
        }
    }
    //For Cancelling Bulk prior schedule events for substitute
    public void cancelPriorScheduleEventsList(Map<Id,Set<Date>> priorScheduleIdsWithDt)  {
        
        List<Events__c> eventRecordsTobeDeleted = new List<Events__c>();
        
        //Qry current schedule related event records to avoid duplicate records creation
        for(Events__c eve : [SELECT Id,Name,Date__c,Status__c,Schedule__c,SequenceNo__c FROM Events__c WHERE Schedule__c IN :priorScheduleIdsWithDt.keySet() AND Status__c = 'Scheduled']){
            if(priorScheduleIdsWithDt.containsKey(eve.Schedule__c)){
                Set<Date> evtDts = priorScheduleIdsWithDt.get(eve.Schedule__c);
                if(evtDts != null && evtDts.contains(eve.Date__c)) {
                    eve.Status__c = 'Canceled';
                    eventRecordsTobeDeleted.add(eve);
                }
            }
        }
        
        
        //Delete previous Events when substitute
        if(eventRecordsTobeDeleted.size() > 0) {
            update eventRecordsTobeDeleted;
        }
    }
    
    
    //Method to update prior schedule related events to scheduled based on substitute schedule end date update
    //W-004823 - a task
    //Added by NS on Jan 31 2020
    public void updatePriorScheduleEventsToScheduled(Map<Id,String> priorIdDatesString){
        
        //1st date in string will be new date of substitute schedule
        //2nd date in string will be old date of substitute schedule
        
        if(priorIdDatesString.size() > 0){
            
            List<Events__c> eventsToUpdate = new List<Events__c>();
            
            for(Events__c eve : [SELECT Id,Name,Date__c,Schedule__c,Status__c FROM Events__c 
                                    WHERE Schedule__c IN :priorIdDatesString.keySet() AND Status__c IN ('Canceled','Substituted')]){
            
                if(priorIdDatesString.containsKey(eve.Schedule__c)){
                    
                    Date currentEndDate = Date.valueOf(priorIdDatesString.get(eve.Schedule__c).split('~')[0]);
                    Date oldEndDate = Date.valueOf(priorIdDatesString.get(eve.Schedule__c).split('~')[1]);
                    
                    if(eve.Date__c > currentEndDate && eve.Date__c <= oldEndDate){
                        eve.Status__c = 'Scheduled';
                        eventsToUpdate.add(eve);
                    }
                }
            }
            
            system.debug(':::updatePriorScheduleEventsToScheduled:::::::eventsToUpdate::::'+eventsToUpdate);
            system.debug('::::updatePriorScheduleEventsToScheduled::::::eventsToUpdate:size:::'+eventsToUpdate.size());
            
            if(eventsToUpdate.size() > 0){
                update eventsToUpdate;
            }
        }
        
    }
    
    /*************
        - Added By HL on Aug 10 2020 
        - Work Item : W-003065 - Add ability for instructors and students to edit and reschedule events in the community
        - To send an email notification to LTS while Student editing (Reschedule) the event record
        **************/
    public void sendAnEmailToLTSForApproval(List<Events__c> eveRecsForSubmitAppPro){
    
        if(eveRecsForSubmitAppPro != NULL){
            
            try{
                                
                List<Messaging.SingleEmailMessage> sendEmailToApprovalProcess = new List<Messaging.SingleEmailMessage>();
                
                Map<Id, Events__c> eventRecMap = new Map<Id, Events__c>();
                Set<Id> projManagerIds = new Set<Id>();
                Map<Id,Id> usrIdConId = new Map<Id,Id>();
                
                for(Events__c e : [SELECT Id, Project__c, Project__r.DLS_Class__c, Date__c,  
                                        Instructor__c, Instructor__r.Name, Start_Time__c, End_Time__c, Duration__c, Room__r.Name, 
                                        Parent_Event__c, Parent_Event__r.Date__c, Parent_Event__r.Start_Time__c, Parent_Event__r.End_Time__c, 
                                        Parent_Event__r.Duration__c, Parent_Event__r.Room__r.Name, Project__r.Project_Manager__c, 
                                        Project__r.Project_Manager__r.Name, CreatedBy.Name
                                    FROM Events__c
                                    WHERE Id IN : eveRecsForSubmitAppPro AND Project__r.Project_Manager__c != NULL
                ]){
                
                    eventRecMap.put(e.Id, e);
                    projManagerIds.add(e.Project__r.Project_Manager__c);
                }
                System.debug('::::projManagerIds::::'+projManagerIds);
                
                if(projManagerIds != NULL && projManagerIds.size() > 0){
                
                    usrIdConId = PlannedDaysOffHandler.getUserRelatedContacts(projManagerIds);
                }
                System.debug('::::usrIdConId::::'+usrIdConId);
                
                List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
            
                String orgWideEmailId = '';
                
                if(orgWideEmail != NULL && orgWideEmail.size() > 0){
                    orgWideEmailId = orgWideEmail[0].Id;
                }
                
                for(Events__c e : eveRecsForSubmitAppPro){
                    
                    if(eventRecMap.containsKey(e.Id) && usrIdConId.containsKey(eventRecMap.get(e.Id).Project__r.Project_Manager__c)){
                                                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        mail.setTargetObjectId(usrIdConId.get(eventRecMap.get(e.Id).Project__r.Project_Manager__c));
                        
                        mail.setOrgWideEmailAddressId(orgWideEmailId);
                            
                        mail.setWhatId(e.Id);
                        
                        String s1 = String.valueOf(eventRecMap.get(e.Id).Date__c);
                        String newEveDate = s1.split('-')[1]+'/'+s1.split('-')[2]+'/'+s1.split('-')[0];
                                                
                        String url = '<a href="' + System.Label.Org_Prefix_Start_URL +'/lightning/o/Events__c/list?filterName='+ System.Label.Event_Pending_LTS_Approval_Filter_Id + '" target="_blank"> Click Here </a>';
                                                
                        String htmlBody = '';
                        htmlBody += 'Dear '+ eventRecMap.get(e.Id).Project__r.Project_Manager__r.Name + ', <br/><br/>';
                        
                        if(e.Parent_Event__c != NULL){
                        
                            String s2 = String.valueOf(eventRecMap.get(e.Id).Parent_Event__r.Date__c);
                            String oldEveDate = s2.split('-')[1]+'/'+s2.split('-')[2]+'/'+s2.split('-')[0];
                        
                            mail.subject = eventRecMap.get(e.Id).CreatedBy.Name + ' for Class #: ' + eventRecMap.get(e.Id).Project__r.DLS_Class__c + ' has submitted a reschedule request for ' + newEveDate;
                            htmlBody += 'A schedule change has been requested by '+eventRecMap.get(e.Id).CreatedBy.Name+'.';
                            htmlBody += '<br/><br/><table border="1" style="border-collapse: collapse"><tr><th width="25%" style="text-align: center; vertical-align: middle;">Field Label</th><th width="25%" style="text-align: center; vertical-align: middle;">Old Value</th><th width="25%" style="text-align: center; vertical-align: middle;">New Value</th></tr>';
                            htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Date'  + '</td><td style="text-align: center; vertical-align: middle;">' + oldEveDate + '</td><td style="text-align: center; vertical-align: middle;">' + newEveDate + '</td></tr>';
                            htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Start Time'  + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Parent_Event__r.Start_Time__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Start_Time__c + '</td></tr>';
                            htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'End Time'  + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Parent_Event__r.End_Time__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).End_Time__c + '</td></tr>';
                            htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Hours'  + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Parent_Event__r.Duration__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Duration__c + '</td></tr>';
                            htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Room'  + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Parent_Event__r.Room__r.Name + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Room__r.Name + '</td></tr>';
                            htmlBody += '</table><br/>';
                        }else{
                            mail.subject = eventRecMap.get(e.Id).CreatedBy.Name + ' for Class #: ' + eventRecMap.get(e.Id).Project__r.DLS_Class__c + ' has submitted a new event for ' + newEveDate;
                            htmlBody += 'A new event has been requested by '+eventRecMap.get(e.Id).CreatedBy.Name+'.';
                            htmlBody += '<br/><br/><table border="1" style="border-collapse: collapse"><tr><th width="15%" style="text-align: center; vertical-align: middle;">Date</th><th width="15%" style="text-align: center; vertical-align: middle;">Start Time</th><th width="15%" style="text-align: center; vertical-align: middle;">End Time</th><th width="15%" style="text-align: center; vertical-align: middle;">Hours</th><th width="15%" style="text-align: center; vertical-align: middle;">Room</th></tr>';
                            htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + newEveDate + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Start_Time__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).End_Time__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Duration__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Room__r.Name + '</td></tr>';
                            htmlBody += '</table><br/>';
                        }                        
                        
                        htmlBody += 'Please ' + url + ' to approve or reject.';
                        htmlBody += '<br/><br/><a href="'+ System.Label.Org_Prefix_Start_URL +'/lightning/r/AcctSeed__Project__c/' + eventRecMap.get(e.Id).Project__c +'/view" target="_blank"> Link to Project </a>';
                        htmlBody += '<br/><br/>This is a system generated email<br/>';
                        mail.setHtmlBody(htmlBody);
                        mail.setSaveAsActivity(TRUE);
                        sendEmailToApprovalProcess.add(mail);
                    }
                }  
                
                System.debug('sendEmailToApprovalProcess::::'+sendEmailToApprovalProcess);
            
                if(sendEmailToApprovalProcess != NULL && sendEmailToApprovalProcess.size() > 0) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailToApprovalProcess);
                }
            }catch(Exception e) {
                
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Sending an Email to LTS for Event Reschedule Submission');
            } 
        }
    }
    
    /*************
        - Added By HL on Aug 10 2020
        - Work Item : W-003065 - Add ability for instructors and students to edit and reschedule events in the community
        - To send an email notification to Instructor If LTS approved the Reschedule Event record
        **************/
    public void sendAnEmailToInstructorAfterLTSApproval(List<Events__c> eventRecs, Set<Id> createdByIds){
    
        System.debug('::::eventRecs::::'+eventRecs);
        System.debug('::::createdByIds::::'+createdByIds);
        
        if(eventRecs != NULL && createdByIds != NULL){
        
            try{
                                
                Map<Id, User> conIdAndUserRec = new Map<Id, User>();
                Map<Id, Id> userIdAndConId = new Map<Id, Id>();
                
                List<Messaging.SingleEmailMessage> sendEmailToInstructors = new List<Messaging.SingleEmailMessage>();
                
                for(User u : [SELECT Id, ContactId, Contact.Name, Contact.IsEmailbounced FROM User WHERE ContactId != NULL AND Id IN : createdByIds]){
                    
                    conIdAndUserRec.put(u.ContactId, u);
                    userIdAndConId.put(u.Id, u.ContactId);
                }
                System.debug('::::conIdAndUserRec::::'+conIdAndUserRec);
                
                Map<Id, Events__c> eventRecMap = new Map<Id, Events__c>([
                    SELECT Id, Project__c, Project__r.Project_Manager__c, Project__r.Project_Manager__r.Name, Project__r.DLS_Class__c, Date__c, 
                        Instructor__c, Instructor__r.Name, Instructor__r.IsEmailBounced, Start_Time__c, End_Time__c, Duration__c, Room__r.Name, 
                        Parent_Event__c, Parent_Event__r.Date__c, Parent_Event__r.Start_Time__c, Parent_Event__r.End_Time__c, 
                        Parent_Event__r.Duration__c, Parent_Event__r.Room__r.Name
                    FROM Events__c
                    WHERE Id IN : eventRecs
                ]);
                                                
                String mailContent = '<html>Hi Chris and April <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                Boolean hasBouncedEmail = false;
                
                List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
            
                String orgWideEmailId = '';
                
                if(orgWideEmail != NULL && orgWideEmail.size() > 0){
                    orgWideEmailId = orgWideEmail[0].Id;
                }
                
                for(Events__c e : eventRecs){
                
                    if((e.Instructor__c != NULL && userIdAndConId.containsKey(e.CreatedById)) || Test.isRunningTest()){
                        
                        if(!eventRecMap.get(e.Id).Instructor__r.IsEmailBounced){
                        
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            
                            mail.setTargetObjectId(e.Instructor__c);
                            if(orgWideEmailId != NULL) {
                                mail.setOrgWideEmailAddressId(orgWideEmailId);
                            }
                            mail.setWhatId(e.Id);
                            
                            String s1 = String.valueOf(eventRecMap.get(e.Id).Date__c);
                            String newEveDate = s1.split('-')[1]+'/'+s1.split('-')[2]+'/'+s1.split('-')[0];
                                                        
                            String url = '<a href="' + System.Label.Instructor_Community_Site_Prefix +'/s/schedules?eventId=' + e.Id + '" target="_blank"> Click Here </a>';
                            
                            String htmlBody = '';
                            htmlBody += 'Dear '+ eventRecMap.get(e.Id).Instructor__r.Name + ', <br/><br/>';
                            
                            if(e.Parent_Event__c != NULL){
                                
                                String s2 = String.valueOf(eventRecMap.get(e.Id).Parent_Event__r.Date__c);
                                String oldEveDate = s2.split('-')[1]+'/'+s2.split('-')[2]+'/'+s2.split('-')[0];
                            
                                mail.subject = 'Your Student '+ conIdAndUserRec.get(userIdAndConId.get(e.CreatedById)).Contact.Name +' for Class #: ' + eventRecMap.get(e.Id).Project__r.DLS_Class__c + ' has submitted a reschedule request for ' + newEveDate;
                                htmlBody += 'Your Student, '+ conIdAndUserRec.get(userIdAndConId.get(e.CreatedById)).Contact.Name +', for Class #: ' + eventRecMap.get(e.Id).Project__r.DLS_Class__c + ', has submitted a request to reschedule your class.';
                                htmlBody += 'Your LTS, '+eventRecMap.get(e.Id).Project__r.Project_Manager__r.Name +', has approved this request.';
                                htmlBody += '<br/><br/>Please see details of the rescheduled request below and ' + url +' to approve or reject.';
                                htmlBody += '<br/><br/><table border="1" style="border-collapse: collapse"><tr><th width="25%" style="text-align: center; vertical-align: middle;">Field Label</th><th width="25%" style="text-align: center; vertical-align: middle;">Old Value</th><th width="25%" style="text-align: center; vertical-align: middle;">New Value</th></tr>';
                                htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Date'  + '</td><td style="text-align: center; vertical-align: middle;">' + oldEveDate + '</td><td style="text-align: center; vertical-align: middle;">' + newEveDate + '</td></tr>';
                                htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Start Time'  + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Parent_Event__r.Start_Time__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Start_Time__c + '</td></tr>';
                                htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'End Time'  + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Parent_Event__r.End_Time__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).End_Time__c + '</td></tr>';
                                htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Hours'  + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Parent_Event__r.Duration__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Duration__c + '</td></tr>';
                                htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Room'  + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Parent_Event__r.Room__r.Name + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Room__r.Name + '</td></tr>';
                                htmlBody += '</table><br/>';
                            }else{
                            
                                mail.subject = 'Your Student '+ conIdAndUserRec.get(userIdAndConId.get(e.CreatedById)).Contact.Name +' for Class #: ' + eventRecMap.get(e.Id).Project__r.DLS_Class__c + ' has submitted a new event for ' + newEveDate;
                                htmlBody += 'Your Student, '+ conIdAndUserRec.get(userIdAndConId.get(e.CreatedById)).Contact.Name +', for Class #: ' + eventRecMap.get(e.Id).Project__r.DLS_Class__c + ', has submitted a request for new event for your class.';
                                htmlBody += 'Your LTS, '+eventRecMap.get(e.Id).Project__r.Project_Manager__r.Name +', has approved this request.';
                                htmlBody += '<br/><br/>Please see details of the requested new event below and ' + url +' to approve or reject.';
                                htmlBody += '<br/><br/><table border="1" style="border-collapse: collapse"><tr><th width="15%" style="text-align: center; vertical-align: middle;">Date</th><th width="15%" style="text-align: center; vertical-align: middle;">Start Time</th><th width="15%" style="text-align: center; vertical-align: middle;">End Time</th><th width="15%" style="text-align: center; vertical-align: middle;">Hours</th><th width="15%" style="text-align: center; vertical-align: middle;">Room</th></tr>';
                                htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + newEveDate + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Start_Time__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).End_Time__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Duration__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Room__r.Name + '</td></tr>';
                                htmlBody += '</table><br/>';
                            }
                            htmlBody += '<br/>This is a system generated email<br/>';
                            mail.setHtmlBody(htmlBody);
                            mail.setSaveAsActivity(TRUE);
                            sendEmailToInstructors.add(mail);
                            
                        }else {
                        
                            mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+e.Instructor__c+'" target="_blank">'+eventRecMap.get(e.Id).Instructor__r.Name+'</a><br/>';
                            hasBouncedEmail = true;
                        }
                    }
                }
                mailContent += '<br/><p>This e-mail was auto generated. Please do not respond.</p>';
                mailContent += '</html>';
                
                if(hasBouncedEmail || Test.isRunningTest()) {
                        
                    // Added custom setting to hold the exception recipients email ids
                    List<String> toAddressIds = new List<String>();
        
                    System_Values__c sysVal = System_Values__c.getValues('Contact Bounced Exception Email Ids'); 
                    if (sysVal != null && sysVal.Value__c != null) {
                        for (String st : sysVal.Value__c.split(',')) {
                            toAddressIds.add(st.trim());
                        }
                    }
                    
                    Messaging.SingleEmailMessage bouncedmail = new Messaging.SingleEmailMessage();
                    bouncedmail.setToAddresses(toAddressIds);
                    bouncedmail.setSubject('Bounced email contact information');
                    bouncedmail.sethtmlBody(mailContent);
                    sendEmailToInstructors.add(bouncedmail);
                }
                
                System.debug('sendEmailToInstructors::::'+sendEmailToInstructors);
                System.debug('sendEmailToInstructors::::'+sendEmailToInstructors.size());
            
                if(sendEmailToInstructors != NULL && sendEmailToInstructors.size() > 0) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailToInstructors);
                }
            }catch(Exception e) {
                
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Sending an Email to Instructor after LTS approval regarding Event Reschedule');
            } 
        }
    }
    
    /*************
        - Added By HL on Aug 11 2020 
        - Work Item : W-003065 - Add ability for instructors and students to edit and reschedule events in the community
        - To send an email notification to Student If Instructor approved the Reschedule Event record
        **************/
    public void sendAnEmailToStudentAfterInsApproval(List<Events__c> eventRecs, Set<Id> createdByIds){
    
        if(eventRecs != NULL && createdByIds != NULL){
        
            try{
            
                Map<Id, User> conIdAndUserRec = new Map<Id, User>();
                Map<Id, Id> userIdAndConId = new Map<Id, Id>();
                
                List<Messaging.SingleEmailMessage> sendEmailToStudents = new List<Messaging.SingleEmailMessage>();
                
                for(User u : [SELECT Id, ContactId, Contact.Name, Contact.IsEmailbounced FROM User WHERE ContactId != NULL AND Id IN : createdByIds]){
                    
                    conIdAndUserRec.put(u.ContactId, u);
                    userIdAndConId.put(u.Id, u.ContactId);
                }
                System.debug('::::conIdAndUserRec::::'+conIdAndUserRec);
                                                
                String mailContent = '<html>Hi Chris and April <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                Boolean hasBouncedEmail = false;
                
                List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
            
                String orgWideEmailId = '';
                
                if(orgWideEmail != NULL && orgWideEmail.size() > 0){
                    orgWideEmailId = orgWideEmail[0].Id;
                }
                
                EmailTemplate approvedTemp = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Event_Reschedule_Approved_Template'];
                
                for(Events__c e : eventRecs){
                
                    if((userIdAndConId.containsKey(e.CreatedById) && approvedTemp != NULL) || Test.isRunningTest()){
                    
                        if((!conIdAndUserRec.get(userIdAndConId.get(e.CreatedById)).Contact.IsEmailBounced) || Test.isRunningTest()){
                        
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setTargetObjectId(userIdAndConId.get(e.CreatedById));
                            
                            if(orgWideEmailId != NULL) {
                                mail.setOrgWideEmailAddressId(orgWideEmailId);
                            }
                            mail.setWhatId(e.Id);
                            mail.setTemplateID(approvedTemp.Id);
                            mail.setSaveAsActivity(TRUE);    
                            sendEmailToStudents.add(mail);
                        }else {
                        
                            mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdAndUserRec.get(userIdAndConId.get(e.CreatedById)).ContactId+'" target="_blank">'+conIdAndUserRec.get(userIdAndConId.get(e.CreatedById)).Contact.Name+'</a><br/>';
                            hasBouncedEmail = true;
                        }
                    }
                }
                mailContent += '<br/><p>This e-mail was auto generated. Please do not respond.</p>';
                mailContent += '</html>';
                
                if(hasBouncedEmail || Test.isRunningTest()) {
                        
                    // Added custom setting to hold the exception recipients email ids
                    List<String> toAddressIds = new List<String>();
        
                    System_Values__c sysVal = System_Values__c.getValues('Contact Bounced Exception Email Ids'); 
                    if (sysVal != null && sysVal.Value__c != null) {
                        for (String st : sysVal.Value__c.split(',')) {
                            toAddressIds.add(st.trim());
                        }
                    }
                    
                    Messaging.SingleEmailMessage bouncedmail = new Messaging.SingleEmailMessage();
                    bouncedmail.setToAddresses(toAddressIds);
                    bouncedmail.setSubject('Bounced email contact information');
                    bouncedmail.sethtmlBody(mailContent);
                    sendEmailToStudents.add(bouncedmail);
                }
                
                System.debug('sendEmailToStudents::::'+sendEmailToStudents);
                System.debug('sendEmailToStudents::::'+sendEmailToStudents.size());
            
                if(sendEmailToStudents != NULL && sendEmailToStudents.size() > 0) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailToStudents);
                }
            }catch(Exception e) {
                
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Event Reschedule Mail Sending process to Student after Instructor approval');
            } 
        }
    }
    
    /*************
        - Added By HL on Aug 12 2020 
        - Work Item : W-003065 - Add ability for instructors and students to edit and reschedule events in the community
        - To send an email notification to LTS If Instructor rejected the Reschedule Event record
        **************/
    public void sendAnEmailToLTSAfterInsRejection(List<Events__c> eventRecs){
    
        if(eventRecs != NULL){
        
            try{
                            
                Map<Id, Events__c> eventRecMap = new Map<Id, Events__c>();
                Set<Id> projManagerIds = new Set<Id>();
                Map<Id,Id> usrIdConId = new Map<Id,Id>();
                
                for(Events__c e : [SELECT Id, Project__r.Project_Manager__c FROM Events__c WHERE Id IN : eventRecs AND Project__r.Project_Manager__c != NULL]){
                
                    eventRecMap.put(e.Id, e);
                    projManagerIds.add(e.Project__r.Project_Manager__c);
                }
                System.debug('::::projManagerIds::::'+projManagerIds);
                
                if(projManagerIds != NULL && projManagerIds.size() > 0){

                    usrIdConId = PlannedDaysOffHandler.getUserRelatedContacts(projManagerIds);
                }
                System.debug('::::usrIdConId::::'+usrIdConId);
                
                List<Messaging.SingleEmailMessage> sendEmailToLTS = new List<Messaging.SingleEmailMessage>();
            
                List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
                
                String orgWideEmailId = '';
                
                if(orgWideEmail != NULL && orgWideEmail.size() > 0){
                    orgWideEmailId = orgWideEmail[0].Id;
                }
            
                EmailTemplate rejectionTemp = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Event_Reschedule_Rejection_Template'];
                
                for(Events__c e : eventRecs){
                        
                    if(eventRecMap.containsKey(e.Id) && usrIdConId.containsKey(eventRecMap.get(e.Id).Project__r.Project_Manager__c) && 
                        rejectionTemp != NULL){
                    
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        mail.setTargetObjectId(usrIdConId.get(eventRecMap.get(e.Id).Project__r.Project_Manager__c));
                        
                        if(orgWideEmailId != NULL) {
                            mail.setOrgWideEmailAddressId(orgWideEmailId);
                        }
                        mail.setWhatId(e.Id);
                        mail.setTemplateID(rejectionTemp.Id);
                        mail.setSaveAsActivity(FALSE);    
                        sendEmailToLTS.add(mail);                
                    }
                }
                System.debug('sendEmailToLTS::::'+sendEmailToLTS);
                System.debug('sendEmailToLTS::::'+sendEmailToLTS.size());
        
                if(sendEmailToLTS != NULL && sendEmailToLTS.size() > 0) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailToLTS);
                }
            }catch(Exception e) {
                
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Event Reschedule Mail Sending process to LTS after Instructor Rejection');
            }
        }
    }
    
    /*************
        - Added By HL on Aug 14 2020 
        - Work Item : W-003065 - Add ability for instructors and students to edit and reschedule events in the community
        - To send an email notification to LTS If the Instructor has conflict while rescheduling an event record
        **************/
    public void sendAnEmailToLTS_InstructorConflict(List<Events__c> eveRecsForInsSubstitution){
    
        System.debug('::::::eveRecsForInsSubstitution::::'+eveRecsForInsSubstitution);
        
        if(eveRecsForInsSubstitution != NULL){
        
            try{
                            
                Map<Id, Events__c> eventRecMap = new Map<Id, Events__c>();
                Set<Id> projManagerIds = new Set<Id>();
                Map<Id,Id> usrIdConId = new Map<Id,Id>();
                
                for(Events__c e : [SELECT Id, Project__r.Project_Manager__c FROM Events__c WHERE Id IN : eveRecsForInsSubstitution AND Project__r.Project_Manager__c != NULL]){
                
                    eventRecMap.put(e.Id, e);
                    projManagerIds.add(e.Project__r.Project_Manager__c);
                }
                System.debug('::::projManagerIds::::'+projManagerIds);
                
                if(projManagerIds != NULL && projManagerIds.size() > 0){

                    usrIdConId = PlannedDaysOffHandler.getUserRelatedContacts(projManagerIds);
                }
                System.debug('::::usrIdConId::::'+usrIdConId);
                
                List<Messaging.SingleEmailMessage> sendEmailToLTS = new List<Messaging.SingleEmailMessage>();
            
                List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
                
                String orgWideEmailId = '';
                
                if(orgWideEmail != NULL && orgWideEmail.size() > 0){
                    orgWideEmailId = orgWideEmail[0].Id;
                }
            
                EmailTemplate needInsSubstituteTemp = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Need_Substitute_Instructor_Email_to_LTS'];
                
                for(Events__c e : eveRecsForInsSubstitution){
                        
                    if(eventRecMap.containsKey(e.Id) && usrIdConId.containsKey(eventRecMap.get(e.Id).Project__r.Project_Manager__c) &&
                        needInsSubstituteTemp != NULL){
                    
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTargetObjectId(usrIdConId.get(eventRecMap.get(e.Id).Project__r.Project_Manager__c));
                        
                        if(orgWideEmailId != NULL) {
                            mail.setOrgWideEmailAddressId(orgWideEmailId);
                        }
                        mail.setWhatId(e.Id);
                        mail.setTemplateID(needInsSubstituteTemp.Id);
                        mail.setSaveAsActivity(FALSE);    
                        sendEmailToLTS.add(mail);                
                    }
                }
                System.debug('sendEmailToLTS::::'+sendEmailToLTS);
                System.debug('sendEmailToLTS::::'+sendEmailToLTS.size());
        
                if(sendEmailToLTS != NULL && sendEmailToLTS.size() > 0) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailToLTS);
                }
            }catch(Exception e) {
                
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Event Reschedule Mail Sending process to LTS, If the Instructor has conflict');
            }
        }
    }
    
    /*************
        - Added By HL on Aug 14 2020 
        - Work Item : W-003065 - Add ability for instructors and students to edit and reschedule events in the community
        - To send an email notification to Student If the Instructor is Substituted while rescheduling an event record
        **************/
    public void sendAnEmailToStd_InstructorSubstituted(List<Events__c> eventRecs, Set<Id> createdByIds){
    
        
        System.debug(':::::eventRecs::::::'+eventRecs);  
        
        if(eventRecs != NULL && createdByIds != NULL){
        
            try{
            
                Map<Id, Events__c> eventRecMap = new Map<Id, Events__c>([SELECT Id, Name FROM Events__c WHERE Id IN : eventRecs]);    
                
                Map<Id, User> conIdAndUserRec = new Map<Id, User>();
                Map<Id, Id> userIdAndConId = new Map<Id, Id>();
                                
                for(User u : [SELECT Id, ContactId, Contact.Name, Contact.IsEmailbounced FROM User WHERE ContactId != NULL AND Id IN : createdByIds]){
                    
                    conIdAndUserRec.put(u.ContactId, u);
                    userIdAndConId.put(u.Id, u.ContactId);
                }
                System.debug('::::conIdAndUserRec::::'+conIdAndUserRec);
                
                List<Messaging.SingleEmailMessage> sendEmailToStudents = new List<Messaging.SingleEmailMessage>();
            
                List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
                
                String orgWideEmailId = '';
                
                if(orgWideEmail != NULL && orgWideEmail.size() > 0){
                    orgWideEmailId = orgWideEmail[0].Id;
                }
            
                EmailTemplate insSubstitutedTemp = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Instructor_Substituted_Email_To_Student'];
                
                String mailContent = '<html>Hi Chris and April <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                Boolean hasBouncedEmail = false;

                for(Events__c e : eventRecs){
                                        
                    if((eventRecMap.containsKey(e.Id) & userIdAndConId.containsKey(e.CreatedById) && insSubstitutedTemp != NULL) || Test.isRunningTest()){
                        
                        if((!conIdAndUserRec.get(userIdAndConId.get(e.CreatedById)).Contact.IsEmailBounced) || Test.isRunningTest()){
                            
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setTargetObjectId(conIdAndUserRec.get(userIdAndConId.get(e.CreatedById)).ContactId);
                            
                            if(orgWideEmailId != NULL) {
                                mail.setOrgWideEmailAddressId(orgWideEmailId);
                            }
                            mail.setWhatId(e.Id);
                            mail.setTemplateID(insSubstitutedTemp.Id);
                            mail.setSaveAsActivity(TRUE);    
                            sendEmailToStudents.add(mail);      
                        }else{
                        
                            mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdAndUserRec.get(userIdAndConId.get(e.CreatedById)).ContactId+'" target="_blank">'+conIdAndUserRec.get(userIdAndConId.get(e.CreatedById)).Contact.Name+'</a><br/>';
                            hasBouncedEmail = true;
                        }
                    }        
                }
                
                if(hasBouncedEmail || Test.isRunningTest()){
                
                    // Added custom setting to hold the exception recipients email ids
                    List<String> toAddressIds = new List<String>();
        
                    System_Values__c sysVal = System_Values__c.getValues('Contact Bounced Exception Email Ids'); 
                    if (sysVal != null && sysVal.Value__c != null) {
                        for (String st : sysVal.Value__c.split(',')) {
                            toAddressIds.add(st.trim());
                        }
                    }
                    
                    Messaging.SingleEmailMessage bouncedmail = new Messaging.SingleEmailMessage();
                    bouncedmail.setToAddresses(toAddressIds);
                    bouncedmail.setSubject('Bounced email contact information');
                    bouncedmail.sethtmlBody(mailContent);
                    sendEmailToStudents.add(bouncedmail);
                }
                System.debug('sendEmailToStudents::::'+sendEmailToStudents);
                System.debug('sendEmailToStudents::::'+sendEmailToStudents.size());
        
                if(sendEmailToStudents != NULL && sendEmailToStudents.size() > 0) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailToStudents);
                }
            }catch(Exception e) {
                
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Event Reschedule Mail Sending process to Student, If the Instructor is Substituted');
            }
        }  
    }
    
    // To check Room Conflict for Reschedule Event Records
    public Map<Id, String> checkRoomConflict(List<Events__c> eventRecs, Set<Id> parentEveIds, Set<Date> eveDates, Set<Id> roomIds){
    
        Map<Id, String> eveIdAndConflictLocation = new Map<Id, String>();
         //Modified By Dhinesh - 16-03-2021 - Excluding the Zoom - Online Room to avoid non selective query error
        Id onlineRoomId;
            
        for(Room__c room : [SELECT Id,Name FROM Room__c WHERE Name = 'Zoom - Online']){
            onlineRoomId = room.Id;
        }
        
        if(onlineRoomId != null && roomIds != null){
            roomIds.remove(onlineRoomId);
        }
        
        if(eventRecs != NULL && eveDates != NULL && roomIds != NULL && roomIds.size() > 0){
                    
            EventHandler eveHandle = new EventHandler();
            Events__c currentEve = eventRecs[0];
            
            /*
            [SELECT Id, Name, Date__c, Start_Time__c, End_Time__c, Instructor__c, Room__c, Room__r.Location_n__r.Name
                FROM Events__c 
                WHERE Status__c = 'Scheduled' AND Id NOT IN : eventRecs AND Id NOT IN :parentEveIds AND 
                    Date__c IN : eveDates AND Room__c IN : roomIds AND Start_Time__c != NULL AND 
                    End_Time__c != NULL AND Room__r.Location_n__c != NULL]
            */
            String eveStr = 'SELECT Id, Name, Date__c, Start_Time__c, End_Time__c, Instructor__c, Room__c, Room__r.Location_n__r.Name';
            eveStr += ' FROM Events__c';
            eveStr += ' WHERE  Room__c IN : roomIds AND Id NOT IN : eventRecs AND Status__c = \'Scheduled\' AND Date__c IN : eveDates AND';
            eveStr += ' Start_Time__c != NULL AND End_Time__c != NULL AND Room__r.Location_n__c != NULL';
            
            if(parentEveIds != NULL){
                eveStr += ' AND Id NOT IN :parentEveIds';   
            }
            System.debug(':::eveStr::::'+eveStr);
            
            List<Events__c> oldEvents = Database.Query(eveStr);
            System.debug(':::oldEvents::::'+oldEvents);
            
            if(oldEvents != NULL && oldEvents.size() > 0){
            
                for(Events__c oldEvent : oldEvents){
                        
                    Integer ST1,ET1,ST2,ET2;
                    if(eveHandle.convertToMinutes(currentEve.Start_Time__c) > eveHandle.convertToMinutes(oldEvent.Start_Time__c)) {
                    
                        ST1 = eveHandle.convertToMinutes(oldEvent.Start_Time__c);
                        ET1 = eveHandle.convertToMinutes(oldEvent.End_Time__c);
                        
                        ST2 = eveHandle.convertToMinutes(currentEve.Start_Time__c);
                        ET2 = eveHandle.convertToMinutes(currentEve.End_Time__c);
                    
                    }else {
                        
                        ST1 = eveHandle.convertToMinutes(currentEve.Start_Time__c);
                        ET1 = eveHandle.convertToMinutes(currentEve.End_Time__c);
                        
                        ST2 = eveHandle.convertToMinutes(oldEvent.Start_Time__c);
                        ET2 = eveHandle.convertToMinutes(oldEvent.End_Time__c);
                    }    
                    
                    if(ET2 >= ST1 && ST2 < ET1){
                    
                        eveIdAndConflictLocation.put(currentEve.Id, oldEvent.Room__r.Location_n__r.Name);
                    }
                }
            }
        }
        System.debug('::::eveIdAndConflictLocation:::::'+eveIdAndConflictLocation);
        return eveIdAndConflictLocation;
    }
    
    /***********
        - Added By HL on Aug 19 2020
        - Work Item : W-003065 - Add ability for instructors and students to edit and reschedule events in the community
        - To send an email notification to related users If there are Room Conflicts for DLS-Rosslyn, DLS-Herndon and DLS-Elkridge while rescheduling an event record
        ************/
    public void sendAnEmailforRoomConflict(List<Events__c> eventRecs, Set<Id> parentEveIds, Set<Date> eveDates, Set<Id> roomIds){
    
        if(eventRecs != NULL && eveDates != NULL && roomIds != NULL){
        
            try{
            
                List<Messaging.SingleEmailMessage> sendEmailToUsers = new List<Messaging.SingleEmailMessage>();
                
                Map<Id, Events__c> eventRecMap = new Map<Id, Events__c>([
                    SELECT Id, Project__c, Project__r.Project_Manager__c, Project__r.Project_Manager__r.Name, Project__r.DLS_Class__c, Date__c, 
                        Instructor__c, Instructor__r.Name, Instructor__r.IsEmailBounced, Start_Time__c, End_Time__c, Duration__c, Room__r.Name, 
                        Parent_Event__c, Parent_Event__r.Date__c, Parent_Event__r.Start_Time__c, Parent_Event__r.End_Time__c, 
                        Parent_Event__r.Duration__c, Parent_Event__r.Room__r.Name, CreatedBy.Name, Room__c
                    FROM Events__c
                    WHERE Id IN : eventRecs
                ]);
                
                Map<Id, String> eveIdAndConflictLocation = checkRoomConflict(eventRecs, parentEveIds, eveDates, roomIds);
                Map<String, String> userNameAndUserEmail = new Map<String, String>();
                
                for(User u : [SELECT Id, Name, Email FROM User WHERE Name IN ('Bethany Zimmerman', 'Janet Chou', 'Valerie Matagne')]){
                    
                    userNameAndUserEmail.put(u.Name, u.Email);
                }
                
                System.debug(':::userNameAndUserEmail::::'+userNameAndUserEmail);
                
                List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
                
                String orgWideEmailId = '';
                
                if(orgWideEmail != NULL && orgWideEmail.size() > 0){
                    orgWideEmailId = orgWideEmail[0].Id;
                }
                
                if(eveIdAndConflictLocation != NULL && eveIdAndConflictLocation.size() > 0 ){
                
                    for(Events__c e : eventRecs){
                    
                        if(eveIdAndConflictLocation.containsKey(e.Id)){
                        
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            
                            String s1 = String.valueOf(eventRecMap.get(e.Id).Date__c);
                            String newEveDate = s1.split('-')[1]+'/'+s1.split('-')[2]+'/'+s1.split('-')[0];
                            
                            String htmlBody = '';
                                  
                            if(e.Parent_Event__c != NULL){
                            
                                String s2 = String.valueOf(eventRecMap.get(e.Id).Parent_Event__r.Date__c);
                                String oldEveDate = s2.split('-')[1]+'/'+s2.split('-')[2]+'/'+s2.split('-')[0];
                                
                                mail.subject = 'Schedule Change made for Class #: ' + eventRecMap.get(e.Id).Project__r.DLS_Class__c + ' for '+ newEveDate;
                                htmlBody += ' A Schedule Change has been requested by ' + eventRecMap.get(e.Id).CreatedBy.Name + ' and approved by ' +eventRecMap.get(e.Id).Instructor__r.Name+'.';
                                htmlBody += '<br/><br/><table border="1" style="border-collapse: collapse"><tr><th width="25%" style="text-align: center; vertical-align: middle;">Field Label</th><th width="25%" style="text-align: center; vertical-align: middle;">Old Value</th><th width="25%" style="text-align: center; vertical-align: middle;">New Value</th></tr>';
                                htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Date'  + '</td><td style="text-align: center; vertical-align: middle;">' + oldEveDate + '</td><td style="text-align: center; vertical-align: middle;">' + newEveDate + '</td></tr>';
                                htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Start Time'  + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Parent_Event__r.Start_Time__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Start_Time__c + '</td></tr>';
                                htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'End Time'  + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Parent_Event__r.End_Time__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).End_Time__c + '</td></tr>';
                                htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Hours'  + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Parent_Event__r.Duration__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Duration__c + '</td></tr>';
                                htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + 'Room'  + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Parent_Event__r.Room__r.Name + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Room__r.Name + '</td></tr>';
                                htmlBody += '</table><br/>'; 
                            }else{
                            
                                mail.subject = 'Room Needed: New event made for Class #: ' + eventRecMap.get(e.Id).Project__r.DLS_Class__c + ' for '+ newEveDate;
                                htmlBody += ' A new event has been requested by ' + eventRecMap.get(e.Id).CreatedBy.Name + ' and approved by ' +eventRecMap.get(e.Id).Instructor__r.Name+'.';
                                htmlBody += '<br/><br/><table border="1" style="border-collapse: collapse"><tr><th width="15%" style="text-align: center; vertical-align: middle;">Date</th><th width="15%" style="text-align: center; vertical-align: middle;">Start Time</th><th width="15%" style="text-align: center; vertical-align: middle;">End Time</th><th width="15%" style="text-align: center; vertical-align: middle;">Hours</th><th width="15%" style="text-align: center; vertical-align: middle;">Room</th></tr>';
                                htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + newEveDate + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Start_Time__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).End_Time__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Duration__c + '</td><td style="text-align: center; vertical-align: middle;">' + eventRecMap.get(e.Id).Room__r.Name + '</td></tr>';
                                htmlBody += '</table><br/>'; 
                            }                            
                                                        
                            htmlBody += '<b> There is a conflict for Room ' + eventRecMap.get(e.Id).Room__r.Name + '. Please reschedule this event in a new room and notify the Student and Instructor.</b>';
                            htmlBody += '<br/><br/><a href="'+ System.Label.Org_Prefix_Start_URL +'/lightning/r/AcctSeed__Project__c/' + eventRecMap.get(e.Id).Project__c +'/view" target="_blank"> Link to Project </a>';
                            htmlBody += '<br/><br/><a href="'+ System.Label.Org_Prefix_Start_URL +'/lightning/n/Room_Search' + '" target="_blank"> Link to Room Schedule Object </a>';
                            htmlBody += '<br/><br/>This is a system generated email<br/>';
                            
                            if(orgWideEmailId != NULL) {
                                mail.setOrgWideEmailAddressId(orgWideEmailId);
                            }
                                
                            mail.setWhatId(e.Id);
                            mail.setHtmlBody(htmlBody);
                            mail.setSaveAsActivity(FALSE);
                                
                            if(eveIdAndConflictLocation.get(e.Id) == 'DLS - Rosslyn' || Test.isRunningTest()){
                            
                                mail.setToAddresses(new List<String>{'feo@dlsdc.com'}); 
                                //mail.setToAddresses(new List<String>{'hemalatha@softsquare.biz'});
                                sendEmailToUsers.add(mail);
                            }
                            
                            if((eveIdAndConflictLocation.get(e.Id) == 'DLS - Herndon' && userNameAndUserEmail.containsKey('Bethany Zimmerman') &&
                                userNameAndUserEmail.containsKey('Janet Chou')) || Test.isRunningTest()){
                            
                                mail.setToAddresses(new List<String>{userNameAndUserEmail.get('Bethany Zimmerman'), userNameAndUserEmail.get('Janet Chou')});
                                //mail.setToAddresses(new List<String>{'hemalatha@softsquare.biz', 'sukanyan@softsquare.biz'});                                                                
                                sendEmailToUsers.add(mail);
                            }
                            
                            if((eveIdAndConflictLocation.get(e.Id) == 'DLS - Elkridge' && userNameAndUserEmail.containsKey('Valerie Matagne')) || Test.isRunningTest()){
                            
                                mail.setToAddresses(new List<String>{userNameAndUserEmail.get('Valerie Matagne')});
                                //mail.setToAddresses(new List<String>{'hemalatha@softsquare.biz'});
                                sendEmailToUsers.add(mail);
                            }
                        }
                    }
                    System.debug('sendEmailToUsers::::'+sendEmailToUsers);
                    System.debug('sendEmailToUsers::::'+sendEmailToUsers.size());
            
                    if(sendEmailToUsers != NULL && sendEmailToUsers.size() > 0) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailToUsers);
                    }
                }
            }catch(Exception e) {
                
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Event Reschedule Mail Sending process to Users, If there are Room Conflicts');
            }
        }
    }  
    
    /******
        - Added By HL on Mar 19 2020
        - To update parent object's records when Event's Date and StartTime is updated
        *****/
    public void updateParentRecords(Map<Id, DateTime> projIdAndOralExamDateTime, Set<Id> instructorIds){
        if(projIdAndOralExamDateTime != NULL && projIdAndOralExamDateTime.size() > 0 && 
            instructorIds != NULL && instructorIds.size() > 0){
            
            Map<Id, DateTime> oppIdAndOralExamDateTime = new Map<Id, DateTime>();
            List<Contact_Assignments__c> updateConAssigns = new List<Contact_Assignments__c>();
            List<Opportunity> updateOpps = new List<Opportunity>();
            Map<Id, Opportunity> updateOppRecs = new Map<Id, Opportunity>();
    
            for(Contact_Assignments__c c : [SELECT Id, Oral_Exam_Date_Time__c, Project__c, Project__r.Oral_Exam_Date_Time__c,
                    Project__r.AcctSeed__Opportunity__c, Project__r.AcctSeed__Opportunity__r.Oral_Exam__c, End_Date__c, Project__r.Test_Type__c 
                FROM Contact_Assignments__c 
                WHERE Project__c IN : projIdAndOralExamDateTime.keySet() AND Candidate_Name__c IN : instructorIds AND 
                    Project__r.RecordType.DeveloperName = 'Testing_Projects' AND 
                    Status__c IN ('Active', 'Planned') AND RecordType.DeveloperName = 'Instructor']){
                
                if(projIdAndOralExamDateTime.containsKey(c.Project__c)){
                    DateTime oralExamDateTime = projIdAndOralExamDateTime.get(c.Project__c);                    
                    if((c.Project__r.Oral_Exam_Date_Time__c != projIdAndOralExamDateTime.get(c.Project__c)) || 
                        c.Oral_Exam_Date_Time__c == NULL){
                         
                        c.Oral_Exam_Date_Time__c = Datetime.newInstance(oralExamDateTime.year(), oralExamDateTime.month(), oralExamDateTime.day(), oralExamDateTime.hour(), oralExamDateTime.minute(), oralExamDateTime.second());
                        c.End_Date__c = Date.ValueOf(projIdAndOralExamDateTime.get(c.Project__c));
                        updateConAssigns.add(c);
                    }
                    // Added on June 27 2023 - W-007822 : Changes to the Testing Project Event/CA/Project Oral Exam Date & Time
                    // To skip project, opportunity and other contact assignment's (Student/Staff) oral exam date & time field updation when second event is created
                    if(EventTabController.isUpdateTestingProjectDates){
                        if(c.Project__r.AcctSeed__Opportunity__c != NULL && c.Project__r.Test_Type__c != 'Translation Billable'){
                            if(c.Project__r.AcctSeed__Opportunity__r.Oral_Exam__c != projIdAndOralExamDateTime.get(c.Project__c)){
                                Opportunity opp = new Opportunity();
                                opp.Id = c.Project__r.AcctSeed__Opportunity__c;
                                opp.Oral_Exam__c = c.Oral_Exam_Date_Time__c;
                                updateOppRecs.put(opp.Id, opp);
                            }
                        }
                    }
                }
            }
            if(updateConAssigns != NULL && updateConAssigns.size() > 0){
                // If second event is created, then it will update only event and instructor contact assignment
                // Project, Opportunity and Other Contact Assignments will update if user checked "Update all Contact Assignment & Project Dates" checkbox upon event creation or updation
                if(EventTabController.isUpdateTestingProjectDates){
                    isFromEve = TRUE;
                }
                allowToUpdateInsCA = True;
                update updateConAssigns;
            }
            if(updateOppRecs != NULL && updateOppRecs.size() > 0){
                isFromEve = TRUE;
                update updateOppRecs.values();
            }
        }
    }   
}