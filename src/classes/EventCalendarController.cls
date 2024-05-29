public without sharing class EventCalendarController{
    
    @AuraEnabled
    public static List<EventDomain.EventCalendarInfo> getEventRecordList(String year1,String year2,List<String> statusValues,String contactId) {
        String communityName = null;
        Map<Id,Date> transferedCAWithDatesMap = new Map<Id,Date>();
        
        if(String.isNotBlank(contactId)){
            communityName = 'Internal';// for Internal 
        }else{
            communityName = getCommunityPathPrefix();
            contactId = getLoggedUserContactId(); // Get Currently logged user's contact Id
        }
        
        String recordTypeName = '';
        Set<String> recordTypeNames = new Set<String>();
        
        system.debug(':::::contactId:::'+contactId);
        system.debug('::::::::year:::values::'+year1+'::::'+year2);
        system.debug('::::::::statusValues:::::'+statusValues);
        
        if(communityName == 'instructor' || (communityName == null && Test.isRunningTest())){
            recordTypeNames.add('Instructor');
            recordTypeName = 'Instructor';
        }else if(communityName == 'student'){
            recordTypeNames.add('Student');
            recordTypeName = 'Student';
        }else if(communityName == 'client'){
            recordTypeNames.add('Client_Partner');
            recordTypeName = 'Client_Partner';
        }else if(communityName == 'Internal' || Test.isRunningTest()){
            recordTypeNames.add('Student');
            recordTypeNames.add('Instructor');
            recordTypeName = 'Internal';
        }
        
        String stDate1;
        String endDate1;
        
        String stDate2;
        String endDate2;
        
        String dt1;
        String dt2;
        
        if(String.isNotBlank(year1)){
            stDate1 = year1+'-01-01';
            endDate1 = year1+'-12-31';
        }
        
        if(String.isNotBlank(year2)){
            stDate2 = year2+'-01-01';
            endDate2 = year2+'-12-31';
        }
        
        if(String.isNotBlank(year1) && String.isNotBlank(year2)) {
            if(Integer.valueOf(year1) < Integer.valueOf(year2)){
                dt1 = stDate1;
                dt2 = endDate2;
            }else {
                dt1 = stDate1;
                dt2 = endDate2;
            }
        }else if(String.isNotBlank(year1)){
            dt1 = stDate1;
            dt2 = endDate1;
        }else if(String.isNotBlank(year2)){
            dt1 = stDate2;
            dt2 = endDate2;
        }else {
            dt1 = system.today().year()+'-01-01';
            dt2 = system.today().year()+'-12-31';
        }
        
        Set<Id> projectIds = new Set<Id>();
        Set<Id> studentIds = new Set<Id>();

        Map<Id,String> proIdStudentNames = new Map<Id,String>();
        
        if((String.isNotBlank(contactId) && communityName == 'student') || (String.isBlank(communityName) && Test.isRunningTest())){
            for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,End_Date__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName,Status__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId AND RecordType.DeveloperName IN :recordTypeNames AND Project__c != null]){
                projectIds.add(ca.Project__c);
                
                String studentName = ca.Candidate_Name__r.FirstName+' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.';
                
                if(!proIdStudentNames.containsKey(ca.Project__c)){
                    proIdStudentNames.put(ca.Project__c,studentName);
                }else {
                    String existingName = proIdStudentNames.get(ca.Project__c);
                    
                    proIdStudentNames.put(ca.Project__c,(existingName+', '+studentName));
                }
                
                if(ca.Status__c == 'Transferred'){
                    if(!transferedCAWithDatesMap.containsKey(ca.Project__c)){
                        transferedCAWithDatesMap.put(ca.Project__c,ca.End_Date__c);
                    }
                }
            }
        }else {
            
            //Get Student Names for Instructor View
            for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId AND RecordType.DeveloperName IN :recordTypeNames AND Project__c != null]){
                if(ca.RecordType.DeveloperName == 'Student'){
                    studentIds.add(ca.Project__c);
                }
                projectIds.add(ca.Project__c);
            }
            
            for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,Status__c,End_Date__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Project__c IN :projectIds]){
                String studentName = '';
                
                studentName = (ca.Candidate_Name__r.FirstName == null ? '' : ca.Candidate_Name__r.FirstName);
                studentName += (ca.Candidate_Name__r.LastName != null ? ' '+ca.Candidate_Name__r.LastName.subString(0,1)+'.' : '');
                
                if(!proIdStudentNames.containsKey(ca.Project__c)){
                    proIdStudentNames.put(ca.Project__c,studentName);
                }else {
                    String existingName = proIdStudentNames.get(ca.Project__c);
                    
                    proIdStudentNames.put(ca.Project__c,(existingName+', '+studentName));
                }
                
                if(ca.Status__c == 'Transferred' && communityName == 'Internal' && studentIds.size() > 0 && studentIds.contains(ca.Project__c)){
                    if(!transferedCAWithDatesMap.containsKey(ca.Project__c)){
                        transferedCAWithDatesMap.put(ca.Project__c,ca.End_Date__c);
                    }
                }
            }
            
        }
        System.debug('recordTypeNames::::'+recordTypeNames);
        System.debug('contact Id::::'+contactId);
        system.debug('::::::::::proIdStudentNames:::'+proIdStudentNames);
        
        String eventQryStr = 'SELECT Id, Name, Agenda_Sequence_No__c, Cancelled_by__c, ContentVersionId__c, Date__c, Duration__c, End_Date_Time__c'; 
        eventQryStr += ', End_Time__c, Event_Agenda__c, Instructor__c, IsEvent__c, Language__c, Reject_Comment__c, Meeting_URL__c, Project__c, Room__c, Schedule__c, SequenceNo__c';
        eventQryStr += ', Instructor__r.Name, Project__r.Name, Project__r.Project_Manager__c, Project__r.Project_Manager__r.Name, Room__r.Name, Schedule__r.Name,Parent_Event__r.Status__c, Cancelled_by__r.Name, project__r.DLS_Ref__c,Approver_Name__c';
        eventQryStr += ', Start_Date_Time__c, Start_Time__c, Status__c, Time_Card_Day__c, Timezone__c, Total_Used_Hours__c,Day_of_Week__c,Approval_Status__c';
        eventQryStr += ',Schedule__r.Project_Task__c,Schedule__r.Project_Task__r.Name,Project_Task__r.Name, Project_Task__r.Project_Task_Type__c, Schedule__r.Project_Task__r.Project_Task_Type__c,Parent_Event__c,Schedule__r.Meeting_URL__c, Project__r.AcctSeed__Account__c, Project__r.AcctSeed__Account__r.Name, Project__r.RecordType.DeveloperName, Project__r.Project_Type__c, Instructor__r.FirstName, Instructor__r.LastName, Schedule__r.Create_Zoom_Meetings__c  FROM Events__c';
        
        
        if(((communityName == 'instructor' || communityName == 'Internal') && String.isNotBlank(contactId)) || communityName == 'student' || communityName == 'client'){
            eventQryStr += ' WHERE ';
            
            if((communityName == 'instructor' ||  communityName == 'Internal') || Test.isRunningTest()){
                if(communityName == 'Internal'){
                    eventQryStr += '(';
                }
                eventQryStr += '(Instructor__c = :contactId AND Approval_Status__c != \'Instructor Rejected\' AND ((Approval_Status__c = null AND Status__c != \'Draft\') OR (Approval_Status__c != null)))';
            }
            
            if(communityName == 'Internal' && studentIds.size() > 0){
                if(communityName == 'Internal'){
                    eventQryStr +=  ' OR ';
                }  
                eventQryStr += ' (Project__c IN :studentIds AND (Project_Task__r.Project_Task_Type__c != \'Preparation time\' OR Schedule__r.Project_Task__r.Project_Task_Type__c != \'Preparation time\')) ';
            }
            
            if((communityName == 'student' || communityName == 'client') && projectIds.size() > 0){
                eventQryStr += ' (Project__c IN :projectIds AND (Project_Task__r.Project_Task_Type__c != \'Preparation time\' OR Schedule__r.Project_Task__r.Project_Task_Type__c != \'Preparation time\')) ';
                                                                   
            }
            
            if(communityName == 'Internal'){
                eventQryStr += ')';
            }
            
            if(dt1 != null && dt2 != null){
                eventQryStr += ' AND Date__c >= '+dt1+' AND Date__c <= '+dt2+'';  
            }
            
            if(statusValues.size() > 0){
                eventQryStr += ' AND Status__c IN :statusValues ';
            }
            
            eventQryStr += ' AND Approval_Status__c != \'LTS Rejected\'';
        }
        system.debug('::::::::::eventQryStr:::'+eventQryStr);
        
        List<Events__c> eventRecords = database.query(eventQryStr);
        
          system.debug('::::::::::eventRecords:::'+eventRecords.size());
        
        //Get Holiday Records based on the date range
        
        List<Holiday> holidays = HolidayService.getHolidayRecordsWithRecurrence(Date.valueOf(dt1),Date.valueOf(dt2));
        System.debug('events::::'+eventQryStr);
        
        //Get Planned Days Off records
        List<Planned_Days_Off__c> plannedLeaves1 = new List<Planned_Days_Off__c>();
        List<Planned_Days_Off__c> plannedLeaves2 = new List<Planned_Days_Off__c>();
        
        List<String> filterRecordTypes = new List<String>{'Request','DLI-W LT Training Holidays'};
        List<String> statusFilters = new List<String>{'Approved','Submitted for Approval'};
        //Set<Id> projectIdSet = new Set<Id>();
        Set<Id> contactIDs = new Set<Id>();
        
        /*if(String.isNotBlank(contactId) && (communityName == 'student' || communityName == 'instructor')) {
            for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,Project__r.DLS_Ref__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId AND RecordType.DeveloperName = :recordTypeName AND Project__c != null]){
                if(ca.Project__c != null){
                    projectIdSet.add(ca.Project__c);
                }
            }
        }*/ 
        
        if(projectIDs.size() > 0 && (recordTypeName == 'Instructor' || recordTypeName == 'Student' || recordTypeName == 'Internal')){ 
            
            Set<String> rtType = new Set<String>();
            
            if(recordTypeName == 'Student'){
                rtType.add('Instructor');
            }else if(recordTypeName == 'Instructor'){
                rtType.add('Student');
            }else if(recordTypeName == 'Internal'){
                rtType.add('Student');
                rtType.add('Instructor');
            }
            
            for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,Project__r.DLS_Ref__c,RecordType.DeveloperName,Candidate_Name__c,Candidate_Name__r.FirstName,Candidate_Name__r.LastName 
                                             FROM Contact_Assignments__c 
                                             WHERE RecordType.DeveloperName IN :rtType AND Status__c != 'Ended' AND 
                                             Project__c IN :projectIDs]){                
                if(ca.Candidate_Name__c != null){
                    contactIDs.add(ca.Candidate_Name__c);
                } 
            }
        }
        String plannedQuery1;
        String plannedQuery2;
        
        plannedQuery1 = 'SELECT Id,name,Description__c,Contact__c,Contact__r.Name,Leave_Type__c,Project__c,Project__r.DLS_Ref__c,Project__r.name ,Date__c, Type__c,Status__c '+
                'FROM Planned_Days_Off__c WHERE Contact__c = :contactId AND Status__c IN :statusFilters';
        
        
        if(recordTypeName == 'Student'){
            filterRecordTypes .add('Student_Planned_Days_Off');
            //get logged Contact related Planned Days Off records
            
            plannedQuery1 += ' AND RecordType.DeveloperName = \'Student_Planned_Days_Off\'';
            
        }else if(recordTypeName == 'Instructor'){
            filterRecordTypes.add('Instructor_Planned_Days_Off');
            //get logged Contact related Planned Days Off records
            
            plannedQuery1 += ' AND RecordType.DeveloperName = \'Instructor_Planned_Days_Off\''; 
        }else if(recordTypeName == 'Internal'){
            plannedQuery1 += ' AND (RecordType.DeveloperName = \'Instructor_Planned_Days_Off\' OR  RecordType.DeveloperName = \'Student_Planned_Days_Off\')'; 
        }
        
        //get Planned Days Off records except logged Contact related planned Days Off records
        plannedQuery2 = 'SELECT Id,name,Description__c,Contact__c,Contact__r.Name,Leave_Type__c,Project__c,Project__r.DLS_Ref__c,Project__r.name ,Date__c, Type__c,Status__c '+
            'FROM Planned_Days_Off__c WHERE RecordType.DeveloperName Not IN :filterRecordTypes AND Status__c IN :statusFilters AND Contact__c IN :contactIDs';
        
        if(dt1 != null && dt2 != null){
            plannedQuery1 += ' AND Date__c >= '+dt1+' AND Date__c <= '+dt2+''; 
            plannedQuery2 += ' AND Date__c >= '+dt1+' AND Date__c <= '+dt2+'';
        }
        
        plannedLeaves1 = database.query(plannedQuery1);
        plannedLeaves2 = database.query(plannedQuery2);
        plannedLeaves1.addAll(plannedLeaves2);
        
        // Currently Event Approval process only for Instructor
        List<EventDomain.EventCalendarInfo> pendingApprovalEvtList = new List<EventDomain.EventCalendarInfo>();
        if(communityName == 'instructor' || communityName == 'Internal'){            
            pendingApprovalEvtList = EventApproval_Ctrl.getEventsForApproval(contactId);
        }
        
        String childEventRelParentIdsJSON = EventListViewController.getChildEventRelParentIds(eventRecords);
        
        Set<Id> childEventRelParentIds = (Set<Id>) JSON.deserialize(childEventRelParentIdsJSON, Set<Id>.class);
        
        List<EventDomain.EventCalendarInfo> eventWrapList = EventTranslator.eventCalendarInfo(eventRecords,holidays,proIdStudentNames,plannedLeaves1,null,null,childEventRelParentIds,transferedCAWithDatesMap);
        
        if(pendingApprovalEvtList.size() > 0){
            eventWrapList.addAll(pendingApprovalEvtList);
        }
        return eventWrapList;
    }
    
    public static String getLoggedUserContactId() {
        return [Select Id,ContactId FROM User where Id =: userInfo.getUserId()].ContactId;
    }
    
    @AuraEnabled
    public static String getCommunityPathPrefix() {
        
        String communityName = '';
        List<Network> networkRecord = [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId()];
        
        if(networkRecord.size() > 0){
            communityName = networkRecord[0].UrlPathPrefix;
        }
        
        return communityName;
    }
    
    @AuraEnabled
    public static List<String> getTimeValues() {
        return ScheduleCmpLightningController.getPickListValues('AcctSeed__Time_Card_Day__c','Start_Time1__c');
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(String.escapeSingleQuotes(searchString),objectName,fieldName,condition,selectedIds);
    } 
    
    //Method to check conflict for event reschedule
    @AuraEnabled
    public static EventDomain.EventConflictInfo getEventConflictInfo(String eventJSON,String communityName){
        
        EventDomain.EventConflictInfo evtConflict = new EventDomain.EventConflictInfo();
        List<EventDomain.EventCalendarInfo> eventList = (List<EventDomain.EventCalendarInfo>)System.JSON.deserialize(eventJSON, List<EventDomain.EventCalendarInfo>.class); 
        evtConflict.isAllowForReschedule = false;
        
        system.debug(':::::::eventList:::'+eventList);
        
        EventDomain.EventCalendarInfo eventInfo = new EventDomain.EventCalendarInfo();
        
        if(eventList.size() > 0){
            eventInfo = eventList[0];
        }
        
        Map<String,List<EventDomain.EventConflictDetail>> conflictDetailMap = new Map<String,List<EventDomain.EventConflictDetail>>();
        
        EventHandler eveHandle = new EventHandler();
        TimezoneUtilClass utilCls = new TimezoneUtilClass();

        Id currentProId = eventInfo.projectId;
        String contactId = getLoggedUserContactId();
        
        Set<Id> studentIds = new Set<Id>();
        Set<Id> instructorIds = new Set<Id>();
        
        Set<Id> stuProjectIds = new Set<Id>();
        Set<Id> insProjectIds = new Set<Id>();
        Map<Id,Set<Id>> proIdStudentIds = new Map<Id,Set<Id>>();
        
        Map<Id,Contact> conIdRecMap = new Map<Id,Contact>();
        
        System.debug('ET::'+eventInfo.endTime);
        
        if(communityName == 'instructor'){
            instructorIds.add(contactId);
            
            for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c FROM Contact_Assignments__c 
                                            WHERE Project__c = :currentProId AND RecordType.DeveloperName = 'Student' AND Status__c = 'Active']){
                studentIds.add(ca.Candidate_Name__c);
            }
        }else {
            
            //get current related student / instructor details from CA
            for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c,RecordType.DeveloperName FROM Contact_Assignments__c 
                                                WHERE Project__c = :currentProId AND RecordType.DeveloperName IN ('Student','Instructor') AND Status__c = 'Active']){
                
                if(ca.RecordType.DeveloperName == 'Student'){
                    studentIds.add(ca.Candidate_Name__c);
                }
                
                if(ca.RecordType.DeveloperName == 'Instructor'){
                    instructorIds.add(ca.Candidate_Name__c);    
                }
            }
        }
        
        conIdRecMap = new Map<Id,Contact>([SELECT Id,Name,FirstName,LastName FROM Contact WHERE Id IN :studentIds OR Id IN :instructorIds]);
        
        Set<Id> eventIdsForExclude = new Set<Id>();
        
        //Qry these student & instructor related other projects
        for(Contact_Assignments__c ca : [SELECT Id,Project__c,Candidate_Name__c FROM Contact_Assignments__c 
                                            WHERE Candidate_Name__c IN :studentIds AND RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__c != null]){
            
            stuProjectIds.add(ca.Project__c);
            
            if(!proIdStudentIds.containsKey(ca.Project__c)){
                proIdStudentIds.put(ca.Project__c,new Set<Id>{ca.Candidate_Name__c});
            }else {
                proIdStudentIds.get(ca.Project__c).add(ca.Candidate_Name__c);
            }
        }
        
        system.debug('::::::::::stuProjectIds::::'+stuProjectIds);
        
        for(Contact_Assignments__c ca : [SELECT Id,Project__c,Candidate_Name__c FROM Contact_Assignments__c 
                                            WHERE Candidate_Name__c IN :instructorIds AND RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Project__c != null]){
            
            insProjectIds.add(ca.Project__c);
        }
        
        system.debug('::::::::::insProjectIds::::'+insProjectIds);
        
        //Qry student project related other events
        for(Events__c oldEvent : [SELECT Id,Name,Date__c,Start_Time__c,End_Date_Time__c,Start_Date_Time__c,End_Time__c,Instructor__c,Room__c,Project__c,Instructor__r.Name, Project__r.DLS_Ref__c
                                    FROM Events__c WHERE Project__c IN :stuProjectIds AND Status__c = 'Scheduled' 
                                        AND Id != :eventInfo.eventId AND Date__c = :eventInfo.eventDate AND Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time' AND Start_Time__c != null 
                                        AND End_Time__c != null]){
            
            Integer ST1,ET1,ST2,ET2;
              
           if(oldEvent.Start_Date_Time__c != null){
                oldEvent.Start_Date_Time__c = utilCls.getUserTimeZoneDateTime(oldEvent.Start_Date_Time__c);
                oldEvent.Start_Time__c = utilCls.getTimeStringFromDatetime(oldEvent.Start_Date_Time__c);
                oldEvent.Date__c = date.newinstance(oldEvent.Start_Date_Time__c.year(), oldEvent.Start_Date_Time__c.month(), oldEvent.Start_Date_Time__c.day());
           }
                                            
           if(oldEvent.End_Date_Time__c != null){                                  
               oldEvent.End_Time__c = utilCls.getTimeStringFromDatetime(oldEvent.End_Date_Time__c);
               oldEvent.End_Date_Time__c = utilCls.getUserTimeZoneDateTime(oldEvent.End_Date_Time__c);
           }

            
            if(eveHandle.convertToMinutes(eventInfo.startTime) > eveHandle.convertToMinutes(oldEvent.Start_Time__c)) {
                ST1 = eveHandle.convertToMinutes(oldEvent.Start_Time__c);
                ET1 = eveHandle.convertToMinutes(oldEvent.End_Time__c);
                
                ST2 = eveHandle.convertToMinutes(eventInfo.startTime);
                ET2 = eveHandle.convertToMinutes(eventInfo.endTime);
            
            }else {
                ST1 = eveHandle.convertToMinutes(eventInfo.startTime);
                ET1 = eveHandle.convertToMinutes(eventInfo.endTime);
                
                ST2 = eveHandle.convertToMinutes(oldEvent.Start_Time__c);
                ET2 = eveHandle.convertToMinutes(oldEvent.End_Time__c);
            }
            
            if(ET2 >= ST1 && ST2 < ET1){
                
                String oldEveDt = String.valueOf(oldEvent.Date__c).split('-')[1]+'/'+String.valueOf(oldEvent.Date__c).split('-')[2]+'/'+String.valueOf(oldEvent.Date__c).split('-')[0];
                
                EventDomain.EventConflictDetail conDetail = new EventDomain.EventConflictDetail();
                conDetail.eventDate = oldEveDt;
                conDetail.startTime = oldEvent.Start_Time__c;
                conDetail.endTime = oldEvent.End_Time__c;
                
                String stuName = '';
                
                if(proIdStudentIds.containsKey(oldEvent.Project__c)){
                    for(Id stuId : proIdStudentIds.get(oldEvent.Project__c)){
                        if(conIdRecMap.containsKey(stuId)){
                            
                            if(String.isBlank(stuName)){
                                stuName = (conIdRecMap.get(stuId).FirstName == null ? '' : conIdRecMap.get(stuId).FirstName);
                                stuName += (conIdRecMap.get(stuId).LastName != null ? ' '+conIdRecMap.get(stuId).LastName.subString(0,1)+'.' : '');
                            }else {
                                stuName += ', '+(conIdRecMap.get(stuId).FirstName == null ? '' : conIdRecMap.get(stuId).FirstName); 
                                stuName += (conIdRecMap.get(stuId).LastName != null ? ' '+conIdRecMap.get(stuId).LastName.subString(0,1)+'.' : '');
                            }
                        }
                    }
                }
                
                conDetail.personName = stuName;
                conDetail.dlsClass = oldEvent.Project__r.DLS_Ref__c;
                    
                if(!eventIdsForExclude.contains(oldEvent.Id)){
                    eventIdsForExclude.add(oldEvent.Id);
                }
                
                system.debug(':::::::::::eventId::::::'+oldEvent.Id);
                
                if(!conflictDetailMap.containsKey('Student/Instructor Conflict')) {
                    conflictDetailMap.put('Student/Instructor Conflict',new List<EventDomain.EventConflictDetail>{conDetail});
                }else {
                    conflictDetailMap.get('Student/Instructor Conflict').add(conDetail);
                }
                
            }
            
        }
        
        
        //Qry intructor project related other events
        for(Events__c oldEvent : [SELECT Id,Name,Date__c,Start_Time__c,End_Time__c,Start_Date_Time__c,End_Date_Time__c,Instructor__c,Instructor__r.Name,Room__c, Project__r.DLS_Ref__c 
                                    FROM Events__c WHERE Project__c IN :insProjectIds AND Status__c = 'Scheduled' 
                                        AND Id != :eventInfo.eventId AND Id NOT IN :eventIdsForExclude AND Date__c = :eventInfo.eventDate AND Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time' AND Start_Time__c != null 
                                        AND End_Time__c != null]){
            
            Integer ST1,ET1,ST2,ET2;
            
            if(oldEvent.Start_Date_Time__c != null){
                oldEvent.Start_Date_Time__c = utilCls.getUserTimeZoneDateTime(oldEvent.Start_Date_Time__c);
                oldEvent.Start_Time__c = utilCls.getTimeStringFromDatetime(oldEvent.Start_Date_Time__c);
                oldEvent.Date__c = date.newinstance(oldEvent.Start_Date_Time__c.year(), oldEvent.Start_Date_Time__c.month(), oldEvent.Start_Date_Time__c.day());
           }
                                            
           if(oldEvent.End_Date_Time__c != null){                                  
               oldEvent.End_Time__c = utilCls.getTimeStringFromDatetime(oldEvent.End_Date_Time__c);
               oldEvent.End_Date_Time__c = utilCls.getUserTimeZoneDateTime(oldEvent.End_Date_Time__c);
           }                                
              
            if(eveHandle.convertToMinutes(eventInfo.startTime) > eveHandle.convertToMinutes(oldEvent.Start_Time__c)) {
                ST1 = eveHandle.convertToMinutes(oldEvent.Start_Time__c);
                ET1 = eveHandle.convertToMinutes(oldEvent.End_Time__c);
                
                ST2 = eveHandle.convertToMinutes(eventInfo.startTime);
                ET2 = eveHandle.convertToMinutes(eventInfo.endTime);
            
            }else {
                ST1 = eveHandle.convertToMinutes(eventInfo.startTime);
                ET1 = eveHandle.convertToMinutes(eventInfo.endTime);
                
                ST2 = eveHandle.convertToMinutes(oldEvent.Start_Time__c);
                ET2 = eveHandle.convertToMinutes(oldEvent.End_Time__c);
            }
                                            
            if(ET2 >= ST1 && ST2 < ET1){
                
                String oldEveDt = String.valueOf(oldEvent.Date__c).split('-')[1]+'/'+String.valueOf(oldEvent.Date__c).split('-')[2]+'/'+String.valueOf(oldEvent.Date__c).split('-')[0];
                
                EventDomain.EventConflictDetail conDetail = new EventDomain.EventConflictDetail();
                conDetail.eventDate = oldEveDt;
                conDetail.startTime = oldEvent.Start_Time__c;
                conDetail.endTime = oldEvent.End_Time__c;
                conDetail.personName = oldEvent.Instructor__r.Name;
                conDetail.dlsClass = oldEvent.Project__r.DLS_Ref__c;
                
                if(!eventIdsForExclude.contains(oldEvent.Id)){
                    eventIdsForExclude.add(oldEvent.Id);
                }
                
                system.debug(':::::::::::eventId::::::'+oldEvent.Id);
                 
                if(!conflictDetailMap.containsKey('Student/Instructor Conflict')) {
                    conflictDetailMap.put('Student/Instructor Conflict',new List<EventDomain.EventConflictDetail>{conDetail});
                }else {
                    conflictDetailMap.get('Student/Instructor Conflict').add(conDetail);
                }
            }
        }
        
        system.debug('::::::::::conflictDetailMap::::'+conflictDetailMap);
        // Removed Zoom from Room conflict check
        if(eventInfo.room != 'Zoom - Online'){
            //Qry events that are related to current room for conflict
            for(Events__c oldEvent : [SELECT Id,Name,Date__c,Start_Time__c,Start_Date_Time__c,End_Time__c,End_Date_Time__c,Instructor__c,Room__c,Room__r.Name, Project__r.DLS_Ref__c FROM Events__c 
                                        WHERE Status__c = 'Scheduled' //AND Id != :eventInfo.eventId AND Id NOT IN :eventIdsForExclude 
                                         AND Date__c = :eventInfo.eventDate AND Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time' AND Room__c = :eventInfo.roomId
                                         AND Start_Time__c != null AND End_Time__c != null]){
                
                Integer ST1,ET1,ST2,ET2;
                                             
                 if(oldEvent.Start_Date_Time__c != null){
                    oldEvent.Start_Date_Time__c = utilCls.getUserTimeZoneDateTime(oldEvent.Start_Date_Time__c);
                    oldEvent.Start_Time__c = utilCls.getTimeStringFromDatetime(oldEvent.Start_Date_Time__c);
                    oldEvent.Date__c = date.newinstance(oldEvent.Start_Date_Time__c.year(), oldEvent.Start_Date_Time__c.month(), oldEvent.Start_Date_Time__c.day());
                 }
                                            
                if(oldEvent.End_Date_Time__c != null){                                  
                   oldEvent.End_Time__c = utilCls.getTimeStringFromDatetime(oldEvent.End_Date_Time__c);
                   oldEvent.End_Date_Time__c = utilCls.getUserTimeZoneDateTime(oldEvent.End_Date_Time__c);
                }
                                             
                if(eveHandle.convertToMinutes(eventInfo.startTime) > eveHandle.convertToMinutes(oldEvent.Start_Time__c)) {
                    ST1 = eveHandle.convertToMinutes(oldEvent.Start_Time__c);
                    ET1 = eveHandle.convertToMinutes(oldEvent.End_Time__c);
                    
                    ST2 = eveHandle.convertToMinutes(eventInfo.startTime);
                    ET2 = eveHandle.convertToMinutes(eventInfo.endTime);
                    
                }else {
                    ST1 = eveHandle.convertToMinutes(eventInfo.startTime);
                    ET1 = eveHandle.convertToMinutes(eventInfo.endTime);
                    
                    ST2 = eveHandle.convertToMinutes(oldEvent.Start_Time__c);
                    ET2 = eveHandle.convertToMinutes(oldEvent.End_Time__c);
                }
                
                System.debug('InstructtorEvent'+ET2+'ET1'+ET2+'ST1'+ST1+'ST2'+ST2+oldEvent.End_Time__c);
                
                if(ET2 >= ST1 && ST2 < ET1){
                    
                    String oldEveDt = String.valueOf(oldEvent.Date__c).split('-')[1]+'/'+String.valueOf(oldEvent.Date__c).split('-')[2]+'/'+String.valueOf(oldEvent.Date__c).split('-')[0];
                    
                    EventDomain.EventConflictDetail conDetail = new EventDomain.EventConflictDetail();
                    conDetail.eventDate = oldEveDt;
                    conDetail.startTime = oldEvent.Start_Time__c;
                    conDetail.endTime = oldEvent.End_Time__c;
                    conDetail.roomName = oldEvent.Room__r.Name;
                    conDetail.dlsClass = oldEvent.Project__r.DLS_Ref__c;
                    
                    system.debug(':::::::::::eventId::::::'+oldEvent.Id);
                    
                    if(!conflictDetailMap.containsKey('Room Conflict')) {
                        conflictDetailMap.put('Room Conflict',new List<EventDomain.EventConflictDetail>{conDetail});
                    }else {
                        conflictDetailMap.get('Room Conflict').add(conDetail);
                    }
                    
                }
            }
       }
        system.debug(':::::after:::::conflictDetailMap::::'+conflictDetailMap);
        evtConflict.EventConflicts = conflictDetailMap;
        
        if(eventList.size() > 0){
            
            BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name = 'Community'];
            List<Events__c> evt = [SELECT Id,Timezone__c,Date__c,Start_Time__c FROM Events__c WHERE Id = :eventList[0].eventId];
            system.debug('::::::evt::::'+evt);
            
            if(evt.size() > 0){
                
                Datetime targetTime = utilCls.getDateTimeInGMT(evt[0].Timezone__c, evt[0].Date__c, evt[0].Start_Time__c, false);
                
                system.debug(':::::::::targetTime:::::'+targetTime);
                system.debug('::::::::current:time::::'+system.now());
                
                Decimal diffDate = 0.00;
                
                Long differenceDate = BusinessHours.diff(bh.id,system.now(),targetTime);
                
                System.debug(':::::differenceDate::::::'+differenceDate/(3600000*24.0));
                
                diffDate = differenceDate/(3600000*24.0).setScale(2);
                
                Long mins = differenceDate / 60000;
                Long hours = mins / 60;
                Long Days = (hours /24);
                
                if(days >= 1 /*|| system.Today() == evt[0].Date__c*/){
                    evtConflict.isAllowForReschedule = false;
                }else{
                    evtConflict.isAllowForReschedule = true;
                }  
            }else{
                evtConflict.isAllowForReschedule = false;
            }
        }
        return evtConflict;
    }    
    //Method to create reschedule event
    @AuraEnabled
    public static string createRescheduledEvent(String newEventJSON){
        
        try {
            List<Events__c> newEventList = (List<Events__c>)System.JSON.deserialize(newEventJSON, List<Events__c>.class); 
            List<Events__c> eventList = new  List<Events__c>();
            TimezoneUtilClass utilCls = new TimezoneUtilClass();

            system.debug('::::::::::newEventList:::::'+newEventList);
            
            Id scheduleId = newEventList[0].Schedule__c;
            
            Integer sequenceNo = 0;
            String scheduleName = '';
            
            Id userId = UserInfo.getUserId();
            
            Map<Id, Id> projIdAndLeaderId = new Map<Id, Id>();
            List<User> userRec =  [SELECT Id, Contact.RecordType.DeveloperName FROM User WHERE Id = :userId];
            
            if(userRec.size() > 0 && userRec[0].Contact.RecordType.DeveloperName == 'Candidate'){
                projIdAndLeaderId = timeCardRelated_Email_Controller.getProjIdAndLeaderId(new Set<Id>{newEventList[0].Project__c},new Set<Date>{newEventList[0].Date__c},false,null,null,true);
            }
            
            List<Events__c> existingEvents = [SELECT Id,SequenceNo__c,Schedule__r.Name FROM Events__c WHERE Schedule__c = :scheduleId ORDER BY SequenceNo__c DESC LIMIT 1];
            
            List<AcctSeed__Project__c> projects = [SELECT Id, Project_Manager__c  FROM AcctSeed__Project__c WHERE Id = :newEventList[0].Project__c];
            
            if(existingEvents.size() > 0){
                sequenceNo = ((Integer) existingEvents[0].SequenceNo__c) + 1;
                scheduleName = existingEvents[0].Schedule__r.Name;
            }else {
                sequenceNo = 1;
            }
            
            if(userRec[0].Contact.RecordType.DeveloperName == 'Student'){
                newEventList[0].Approver_Name__c = newEventList[0].Instructor__c;
            }else {
                newEventList[0].Approver_Name__c = projIdAndLeaderId.containsKey(newEventList[0].Project__c) ? projIdAndLeaderId.get(newEventList[0].Project__c) : null;
            }
            // Convert user TimeZone to Est('America/New_York') TimeZone
            if(newEventList[0].Start_Time__c != null){
                Datetime targetSTTime = utilCls.getDateTimeInGMT(UserInfo.getTimeZone().getID(), newEventList[0].Date__c, newEventList[0].Start_Time__c, false);
                DateTime stTime = utilCls.convertTimeZoneDateTime(targetSTTime,'America/New_York');
                newEventList[0].Start_Time__c = utilCls.getTimeStringFromDatetime(stTime);
                
                if(stTime != null){
                    newEventList[0].Date__c = date.newinstance(stTime.year(),stTime.month(), stTime.day());
                }
            }
            
            if(newEventList[0].End_Time__c != null){
                Datetime targetEdTime = utilCls.getDateTimeInGMT(UserInfo.getTimeZone().getID(), newEventList[0].Date__c, newEventList[0].End_Time__c, true);
                DateTime edTime = utilCls.convertTimeZoneDateTime(targetEdTime,'America/New_York');
                newEventList[0].End_Time__c = utilCls.getTimeStringFromDatetime(edTime);
            }
            
            newEventList[0].Name = scheduleName+'EV'+sequenceNo;
            newEventList[0].SequenceNo__c = sequenceNo;
            newEventList[0].Approval_Status__c = 'Pending LTS Approval';
            newEventList[0].Status__c = 'Draft';
            newEventList[0].Supervisor__c = projects.size() > 0 ? projects[0].Project_Manager__c  : null;
            
            system.debug(':::::::::newEventList:::::'+newEventList);
            
           
            
            if(newEventList.size() > 0){
                eventList.addAll(newEventList);
                
                // Change the Parent Event status as Submitted for Reschedule
                if(String.isNotBlank(newEventList[0].Parent_Event__c)){
                    Events__c oldEvt = new Events__c(Id = newEventList[0].Parent_Event__c, Status__c = 'Submitted for Reschedule');
                    eventList.add(oldEvt); 
                }
            }
            
            if(eventList.size() > 0){
                upsert eventList;
            }
            
            return 'SUCCESS';
        }catch(Exception ex){
            ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('EventCalendarController','createRescheduledEvent','',ex.getMessage()+' at line number '+ex.getLineNumber(),newEventJSON, 'Aura Component')});
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    //Get Events for the approval cmp
   /* @AuraEnabled
    public static String getEventsForApproval(){
    
        String contactId = getLoggedUserContactId();
        
        List<EventDomain.EventCalendarInfo> eventRecords = new List<EventDomain.EventCalendarInfo>();
        
        String communityName = getCommunityPathPrefix();
        
        List<Events__c> eventList = [SELECT Id,Name,Date__c,Status__c,Start_Time__c,End_Time__c,Duration__c,Instructor__r.Name,
                                    Room__r.Name,Parent_Event__c,Project__c,Project__r.DLS_Ref__c,Approval_Status__c,Reject_Comment__c 
                                FROM Events__c 
                                WHERE Approver_Name__c = :contactId AND Status__c = 'Draft' AND Approval_Status__c IN ('Submitted for Approval')];
        
        Map<Id,String> proIdStudentNames = new Map<Id,String>();
        Set<Id> projectIds = new Set<Id>();
        
        if(communityName == 'instructor'){
            
            for(Events__c eve : eventList){
                projectIds.add(eve.Project__c);
            }
            
            for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName 
                                                FROM Contact_Assignments__c 
                                                WHERE Project__c IN :projectIds AND RecordType.DeveloperName = 'Student' AND Status__c = 'Active']){
                
                String studentName = ca.Candidate_Name__r.FirstName+'.'+ca.Candidate_Name__r.LastName.subString(0,1);
                
                if(!proIdStudentNames.containsKey(ca.Project__c)){
                    proIdStudentNames.put(ca.Project__c,studentName);
                }else {
                    String existingName = proIdStudentNames.get(ca.Project__c);
                    
                    proIdStudentNames.put(ca.Project__c,(existingName+', '+studentName));
                }
            }    
        }
        
        for(Events__c eve : eventList){
            
            EventDomain.EventCalendarInfo eventInfo = new EventDomain.EventCalendarInfo();
            eventInfo.eventId = eve.Id;
            eventInfo.eventName = eve.Name;
            eventInfo.title = eve.Start_Time__c+'-'+eve.End_Time__c+' / '+eve.project__r.DLS_Ref__c+' / '+eve.Room__r.Name;
            eventInfo.eventDate = eve.Date__c;
            if(eve.Date__c != null){
                eventInfo.dateStr = String.valueOf(eve.Date__c).split('-')[1]+'/'+String.valueOf(eve.Date__c).split('-')[2]+'/'+String.valueOf(eve.Date__c).split('-')[0];
            }
            eventInfo.duration = String.valueOf(eve.Duration__c);
            eventInfo.endTime = eve.End_Time__c;
            eventInfo.startTime = eve.Start_Time__c;
            eventInfo.instructor = eve.Instructor__r.Name;
            eventInfo.project = eve.Project__r.DLS_Ref__c;
            eventInfo.room = eve.Room__r.Name;
            eventInfo.parentEventId = eve.Parent_Event__c;
            eventInfo.approvalStatus = eve.Approval_Status__c;
            eventInfo.rejectComment = eve.Reject_Comment__c;
            
            if(communityName == 'instructor'){
                eventInfo.studentNames = proIdStudentNames.containsKey(eve.Project__c) ? proIdStudentNames.get(eve.Project__c) : null;
            }
            
            eventRecords.add(eventInfo);
        }
        
        system.debug(':::::eventRecords::::::'+eventRecords);
        
        return JSON.serialize(eventRecords);
    }*/
    // save pending event records
    @AuraEnabled
    public static void saveEventRecs(List<Events__c> newEventRecs){
        EventApproval_Ctrl.saveEventRecords(newEventRecs);
    }
    @AuraEnabled
    public static List<EventDomain.PendingEventsInfo> getEventsForApproval(String contactId){
        return EventApproval_Ctrl.getPendingEventsForApproval(contactId);
    }
    
    @AuraEnabled
    public static Map<String, EventDomain.EventCalendarInfo> getDetailsForRequestEvent(){
        String contactId = getLoggedUserContactId(); // Get Currently logged user's contact Id
        Set<Id> projectIds = new Set<Id>();
        Map<String, EventDomain.EventCalendarInfo> projectRefWithNewReqEvent = new Map<String, EventDomain.EventCalendarInfo>();
        
        for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId AND RecordType.DeveloperName = 'Student' AND Status__c = 'Active' AND Project__c != null AND Project__r.AcctSeed__Account__r.Name = 'Softsquare ELT' AND Candidate_Name__r.Account.Name = 'Softsquare ELT']){
            projectIds.add(ca.Project__c);            
        }
        
        for(Schedule__c sch : [SELECT Id, Instructor__c, Instructor__r.Name, Project_Task__r.Name, Room__c, Room__r.Name, Project__c, Project__r.DLS_Ref__c, Project__r.Project_Manager__r.Name,Timezone__c FROM Schedule__c WHERE Project__c IN :projectIds AND Status__c = 'Active' AND Project_Task__r.Project_Task_Type__c != 'Preparation time']){
            EventDomain.EventCalendarInfo eventInfo = new EventDomain.EventCalendarInfo();
            eventInfo.instructor = sch.Instructor__r.Name;
            eventInfo.instructorId = sch.Instructor__c;
            eventInfo.project = sch.project__r.DLS_Ref__c;
            eventInfo.projectId = sch.Project__c;
            eventInfo.room = sch.Room__r.Name;
            eventInfo.roomId = sch.Room__c;
            eventInfo.scheduleId = sch.Id;           
            eventInfo.LTSName = sch.Project__r.Project_Manager__c != null ? sch.Project__r.Project_Manager__r.Name : '';
            eventInfo.projectTask = sch.Project_Task__r.Name;
            eventInfo.timezone = sch.Timezone__c;
            projectRefWithNewReqEvent.put(sch.project__r.DLS_Ref__c, eventInfo);
        }
        
        return projectRefWithNewReqEvent;        
    }
}