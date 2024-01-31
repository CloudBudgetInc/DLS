/*******************************************************************************
- Created by NS on OCT 5 2018
- To Create Events from exisiting Active Schedule records under Active Projects
- Consider TCD records for pass date related event records creation

*******************************************************************************/

global class CreateEventsFromSchedule implements Database.batchable<sObject>,Database.Stateful { 

    // get parameter from constructor to create events based on a specific projects
    global Id projectId;
    
    public CreateEventsFromSchedule(Id proId) {
        system.debug(':::inside:::constructor::proId::::'+proId);
        
        projectId = proId;
    }

    global Database.QueryLocator start(Database.BatchableContext info){ 
        
        String schQry = '';
        
        if(projectId != null) {
            schQry = 'SELECT Id,Name,Start_Date__c,End_Date__c,Start_Time__c,End_Time__c,Instructor__c,Room__c,Exclude_Federal_Holidays__c,Friday__c,Hours_Planned__c,'
                                +'Meeting_URL__c,Monday__c,Opportunity__c,Prior_Schedule__c,Project__c,Project__r.RecordType.DeveloperName,Project_Task__c,Saturday__c,Schedule_Type__c,Status__c,Sunday__c,Thursday__c,'
                                +'Timezone__c,Training_Location_LU__c,Travel_In__c,Travel_Out__c,Travel_Required__c,Tuesday__c,Varied_Day__c,Varied_Time__c,Wednesday__c'
                                +' FROM Schedule__c '
                                +'WHERE Project__r.AcctSeed__Status__c = \'Active\' AND Status__c IN (\'Active\',\'Completed\') '
                                    +'AND Project_Task__r.Project_Task_Type__c IN (\'Language Training\',\'Preparation time\') '
                                    +'AND Travel_Required__c = false AND Project__c = :projectId';
        }else {
            schQry = 'SELECT Id,Name,Start_Date__c,End_Date__c,Start_Time__c,End_Time__c,Instructor__c,Room__c,Exclude_Federal_Holidays__c,Friday__c,Hours_Planned__c,'
                                +'Meeting_URL__c,Monday__c,Opportunity__c,Prior_Schedule__c,Project__c,Project__r.RecordType.DeveloperName,Project_Task__c,Saturday__c,Schedule_Type__c,Status__c,Sunday__c,Thursday__c,'
                                +'Timezone__c,Training_Location_LU__c,Travel_In__c,Travel_Out__c,Travel_Required__c,Tuesday__c,Varied_Day__c,Varied_Time__c,Wednesday__c'
                                +' FROM Schedule__c '
                                +'WHERE Project__r.AcctSeed__Status__c = \'Active\' AND Status__c IN (\'Active\',\'Completed\') '
                                    +'AND Project_Task__r.Project_Task_Type__c IN (\'Language Training\',\'Preparation time\') '
                                    +'AND Travel_Required__c = false';
        }
        
        System.debug('::::::::schQry::::::::::'+schQry);
        return Database.getQueryLocator(schQry);
    }
    
    global void execute(Database.BatchableContext info, List<Schedule__c> scheduleRecords){
        
        system.debug('::::::::::::::scheduleRecords:::::::::::'+scheduleRecords);
        Map<Id,Schedule__c> schIdRecMap = new Map<Id,Schedule__c>();
        Set<Id> instructorIds = new Set<Id>();
        Set<Id> projectIds = new Set<Id>();
        Set<Id> taskIds = new Set<Id>();
        Set<Id> roomIds = new Set<Id>();
        Date minStart;
        Date maxEnd;
        Map<String,AcctSeed__Time_Card_Day__c> tcdKeyDayRecMap = new Map<String,AcctSeed__Time_Card_Day__c>();
        List<Events__c> eventRecordsToInsert = new List<Events__c>();
        
        Set<String> dayStatus = new Set<String>{'Draft','Rejected','Approved','Admin Approved'};
        
        Map<Id,Boolean> projectIdFlag = new Map<Id,Boolean>();    // To Track the project have one / multiple student - if only one student- flag = true or if > 1 flag = false
        Map<Id,Id> projectIdStudentId = new Map<Id,Id>();    // To track project specific students if only one student present
        Map<Id,Date> parentIdOffDate = new Map<Id,Date>();    // To hold Student & Project Specific off informations
        Set<Date> DLIWLTHolidays = new Set<Date>();
        Set<Date> holidayDates = new Set<Date>();
        
        Map<Id,Set<Date>> schIdEventDates = new Map<Id,Set<Date>>();
        Map<Id,Decimal> schIdLastEveSeqNum = new Map<Id,Decimal>();
        Map<Id,Id> newSchIdOldSchId = new Map<Id,Id>();
        
        List<Events__c> oldEventsToInsert = new List<Events__c>();
        List<Events__c> futureEventsToInsert = new List<Events__c>();
        
        Map<Date,List<Events__c>> date_StudentEvents = new Map<Date,List<Events__c>>();
        Map<Date,List<Events__c>> date_RoomInstructorEvents = new Map<Date,List<Events__c>>();
        
        Date lastWeekstart = system.today().toStartofWeek().addDays(1).addDays(-7);
        Date currentWeekStart = system.today().toStartofWeek().addDays(1);
        
        for(Schedule__c sch : scheduleRecords){
            schIdRecMap.put(sch.Id,sch);
            
            if(sch.Project__c != null)
                projectIds.add(sch.Project__c);
            
            if(sch.Project_Task__c != null)
                taskIds.add(sch.Project_Task__c);
            
            if(sch.Instructor__c != null)
                instructorIds.add(sch.Instructor__c);   
            
            if(sch.Room__c != null)
                roomIds.add(sch.Room__c);
            
            if(minStart == null || minStart > sch.Start_Date__c){
                minStart = sch.Start_Date__c;
            }
            
            if(maxEnd == null || maxEnd < sch.End_Date__c){
                maxEnd = sch.End_Date__c;
            }  
            
            if(sch.Prior_Schedule__c != null)
                newSchIdOldSchId.put(sch.Id,sch.Prior_Schedule__c);  
        }
        
        //Qry TCD records for old event creation purpose
        for(AcctSeed__Time_Card_Day__c tcd : [SELECT Id,Name,AcctSeed__Date__c,Status__c,Total_Hours_Before_Approved__c,AcctSeed__Time_Card_Line__c,
                                                        AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,
                                                        AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c
                                                FROM AcctSeed__Time_Card_Day__c 
                                                WHERE AcctSeed__Date__c >= :minStart AND AcctSeed__Date__c <= :maxEnd 
                                                    AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c IN :instructorIds 
                                                    AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c IN :projectIds 
                                                    AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c IN :taskIds AND Status__c != 'Unposted']){
            
            String key = String.valueOf(tcd.AcctSeed__Date__c)+'~'+tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c+'~'+tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c+'~'+tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c;
            if(!tcdKeyDayRecMap.containsKey(key)){
                tcdKeyDayRecMap.put(key,tcd);
            }
        }
        
        system.debug(':::::tcdKeyDayRecMap::::'+tcdKeyDayRecMap);
        
        
        // Get Holiday & Planned days off informations
        //Qty Project related Student CA for Planned days off check
        for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c,Project__c,Project__r.Name,Project__r.Students__c FROM Contact_Assignments__c WHERE Project__c != null AND Project__c IN :projectIds AND RecordType.DeveloperName = 'Student' AND Status__c = 'Active']){

            projectIdStudentId.put(ca.Project__c,ca.Candidate_Name__c);
            if(!projectIdFlag.containsKey(ca.Project__c)){
                projectIdFlag.put(ca.Project__c,true);
            }else {
                projectIdFlag.put(ca.Project__c,false);
                projectIdStudentId.remove(ca.Project__c);
            }
        }
        
        // Qry student specific Planned days off records
        for(Planned_Days_Off__c off : [SELECT Id,Name,Contact__c,Date__c FROM Planned_Days_Off__c WHERE Contact__c IN :projectIdStudentId.values() AND Status__c = 'Approved']){
            parentIdOffDate.put(off.Contact__c,off.Date__c);
        }
        
        //Qry Project Specific && DLI W LT related Planned Days off records
        for(Planned_Days_Off__c off : [SELECT Id,Name,Project__c,RecordType.DeveloperName,Project__r.RecordType.DeveloperName,Date__c 
                                            FROM Planned_Days_Off__c 
                                            WHERE RecordType.DeveloperName IN ('DLI_W_LT_Training_Holidays','Project_Planned_Days_Off')]){
            
            if(off.RecordType.DeveloperName == 'Project_Planned_Days_Off' && projectIds.contains(off.Project__c)){
                parentIdOffDate.put(off.Project__c,off.Date__c);
            }
            
            if(off.RecordType.DeveloperName == 'DLI_W_LT_Training_Holidays'){
                DLIWLTHolidays.add(off.Date__c);
            }
        }
        
        //Qry current schedule related event records to avoid duplicate records creation
        for(Events__c eve : [SELECT Id,Name,Date__c,Status__c,Schedule__c,SequenceNo__c FROM Events__c WHERE Schedule__c IN :schIdRecMap.keySet()]){
            if(!schIdEventDates.containsKey(eve.Schedule__c)){
                schIdEventDates.put(eve.Schedule__c,new Set<Date>{eve.Date__c});
            }else {
                schIdEventDates.get(eve.Schedule__c).add(eve.Date__c);
            }
            
            if(!schIdLastEveSeqNum.containsKey(eve.Schedule__c)){
                schIdLastEveSeqNum.put(eve.Schedule__c,eve.SequenceNo__c);
            }else {
                if(schIdLastEveSeqNum.get(eve.Schedule__c) < eve.SequenceNo__c)
                    schIdLastEveSeqNum.put(eve.Schedule__c,eve.SequenceNo__c);
            }
        }
        system.debug('::::::schIdEventDates::::existing::events::info::'+schIdEventDates);
        system.debug(':::::::schIdLastEveSeqNum:::::'+schIdLastEveSeqNum);
        
        EventHandler eveHandle = new EventHandler();
        
        // Generate Event records from Schedule information
        for(Id schId : schIdRecMap.keySet()){           
            if(schIdRecMap.containsKey(schId)) {
                
                Schedule__c schRec = schIdRecMap.get(schId);                
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
                
                system.debug(':::::::::daysValues::::'+daysValues);
                system.debug(':::stDate::::::::endDate::::'+stDate+' , '+endDate);
                
                if(schIdEventDates.containsKey(schId))
                    sequenceNo = (Integer) schIdLastEveSeqNum.get(schId);
                
                while(stDate <= endDate) {                    
                    
                     //Check for existing events under this schdeule to avoid duplicate creation
                    if(!schIdEventDates.containsKey(schId) || (schIdEventDates.containsKey(schId) && !schIdEventDates.get(schId).contains(stDate))) {
                    
                        //if(daysValues.contains(eveHandle.getDayValue(stDate))) {
                            
                            //Check the current date is older the lastweek start date
                            String key = String.valueOf(stDate)+'~'+schRec.Instructor__c+'~'+schRec.Project__c+'~'+schRec.Project_Task__c;
                            if(stDate < lastWeekstart && tcdKeyDayRecMap.containsKey(key) 
                                && (tcdKeyDayRecMap.get(key).Status__c == 'Approved' || tcdKeyDayRecMap.get(key).Status__c == 'Admin Approved')){
                                
                                // Add Events to the list with all properties after event formation check for the conflicts
                                Events__c eve = new Events__c();
                                eve.Name = schRec.Name+'-EV'+(++sequenceNo);
                                eve.Date__c = stDate;
                                eve.Start_Time__c = schRec.Start_Time__c;
                                eve.End_Time__c = schRec.End_Time__c;
                                eve.Timezone__c = schRec.Timezone__c;
                                eve.Schedule__c = schRec.Id;
                                eve.Status__c = 'Completed';
                                eve.SequenceNo__c = sequenceNo;
                                eve.Duration__c = tcdKeyDayRecMap.get(key).Total_Hours_Before_Approved__c;
                                eve.Project__c = schRec.Project__c;
                                eve.Instructor__c = schRec.Instructor__c;
                                eve.Room__c = schRec.Room__c;
                                eve.Time_Card_Day__c = tcdKeyDayRecMap.get(key).Id;
                                
                                oldEventsToInsert.add(eve);
                                
                                stDate = stDate.addDays(1);
                                
                            }else if(stDate >= lastWeekstart){
                                
                                if((schRec.Exclude_Federal_Holidays__c && !holidayDates.contains(stDate)) || !schRec.Exclude_Federal_Holidays__c) {  
                                    
                                     Id studentId;
                                    if(projectIdFlag.containsKey(schRec.Project__c) && projectIdStudentId.containsKey(schRec.Project__c)){
                                        studentId = projectIdStudentId.get(schRec.Project__c);
                                    }
                                    
                                    if((parentIdOffDate.size() == 0 || (!parentIdOffDate.containsKey(schRec.Project__c) || parentIdOffDate.get(schRec.Project__c) != stDate)) 
                                        && (schRec.Project__r.RecordType.DeveloperName != 'DLI_W_LT_Projects' || (schRec.Project__r.RecordType.DeveloperName == 'DLI_W_LT_Projects' && !DLIWLTHolidays.contains(stDate))) 
                                        && ((parentIdOffDate.size() == 0 || (studentId != null && (!parentIdOffDate.containsKey(studentId) ||  parentIdOffDate.get(studentId) != stDate))))){
                             
                                        Events__c eve = new Events__c();
                                        //eve.Name = schRec.Name+'-EV'+(++sequenceNo);
                                        eve.Date__c = stDate;
                                        eve.Start_Time__c = schRec.Start_Time__c;
                                        eve.End_Time__c = schRec.End_Time__c;
                                        eve.Timezone__c = schRec.Timezone__c;
                                        eve.Schedule__c = schRec.Id;
                                        eve.SequenceNo__c = sequenceNo;
                                        eve.Duration__c = schRec.Hours_Planned__c;
                                        eve.Project__c = schRec.Project__c;
                                        eve.Instructor__c = schRec.Instructor__c;
                                        eve.Room__c = schRec.Room__c;
                                        
                                        Boolean includeOldEvent = false;
                                        
                                        if(stDate >= lastWeekstart && stDate < system.today()) {
                                            if(tcdKeyDayRecMap.containsKey(key) && dayStatus.contains(tcdKeyDayRecMap.get(key).Status__c)) {
                                                
                                                eve.Name = schRec.Name+'-EV'+(++sequenceNo);
                                                eve.Status__c = 'Completed';
                                                eve.Time_Card_Day__c = tcdKeyDayRecMap.get(key).Id;
                                                
                                                includeOldEvent = true;
                                                
                                            }else if(!schRec.Varied_Day__c /*&& !schRec.Varied_Time__c*/ && daysValues.contains(eveHandle.getDayValue(stDate))){
                                                
                                                eve.Name = schRec.Name+'-EV'+(++sequenceNo);
                                                eve.Status__c = 'Scheduled';
                                                includeOldEvent = true;
                                            }
                                        }else if(stDate >= system.today() && !schRec.Varied_Day__c /*&& !schRec.Varied_Time__c*/){
                                        
                                            eve.Name = schRec.Name+'-EV'+(++sequenceNo);
                                            eve.Status__c = 'Scheduled';
                                        }
                                        
                                        if(stDate >= lastWeekstart && stDate < system.today() && includeOldEvent){
                                        
                                            oldEventsToInsert.add(eve);
                                            
                                        }else if(!schRec.Varied_Day__c/*&& !schRec.Varied_Time__c*/ && daysValues.contains(eveHandle.getDayValue(stDate)) && stDate >= system.today()){
                                                
                                            futureEventsToInsert.add(eve);
                                        }
                                        
                                        stDate = stDate.addDays(1);
                                    }else {
                                        stDate = stDate.addDays(1);
                                    }
                                }else {
                                    stDate = stDate.addDays(1);
                                }
                           }else {
                               stDate = stDate.addDays(1);
                           }
                        /*}else {
                            stDate = stDate.addDays(1); 
                        }*/
                    }else {
                        stDate = stDate.addDays(1);
                    }
                }
            }
        }
        
        system.debug('::::::::oldEventsToInsert::::'+oldEventsToInsert.size());
        system.debug('::::::::::::futureEventsToInsert::::'+futureEventsToInsert.size());
        
        try {
            
            if(oldEventsToInsert.size() > 0){
                insert oldEventsToInsert;
            }
            
            if(futureEventsToInsert.size() > 0) {
                insert futureEventsToInsert;
                
                //Call conflict check method to create Event Conflict records
                // Get Student related Events
                date_StudentEvents = eveHandle.getStudentEvents(projectIds,schIdRecMap.keySet(),minStart,maxEnd,new Set<Date>{});
                
                //Get Room & Instrcutor related Events
                date_RoomInstructorEvents = eveHandle.getRoom_InstructorEvents(instructorIds,schIdRecMap.keySet(),roomIds,minStart,maxEnd,new Set<Date>()); 
                
                // Conflict check part & Email Content formation
                eveHandle.checkEventConflicts(futureEventsToInsert,date_StudentEvents,date_RoomInstructorEvents,newSchIdOldSchId);
            }
        }catch(Exception ex) {
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(ex.getMessage(),system.Label.TimeCardDayEmail,'Error on Existing Active Schedule Event Creation');  
        }
        
    }
    
    global void finish(Database.BatchableContext info){ 
    
    
    }
}