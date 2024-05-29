public without sharing class EventApproval_Ctrl{
    
    //Get Events for the approval cmp
    
    @AuraEnabled
    public static List<EventDomain.EventCalendarInfo> getEventsForApproval(String contactId){
        return getEventsByDatesForApproval(null,null,contactId); 
    }
    @AuraEnabled
    public static List<EventDomain.EventCalendarInfo> getEventsByDatesForApproval(Date stDate,Date endDate,String contactId){
        String communityName = null;
        
        if(String.isNotBlank(contactId)){
            communityName = 'Internal';
        }else{
            contactId = EventCalendarController.getLoggedUserContactId();
            communityName   = EventCalendarController.getCommunityPathPrefix();
        }
        
        List<EventDomain.EventCalendarInfo> eventRecords = new List<EventDomain.EventCalendarInfo>();
        
        
        String eventQryStr = 'SELECT Id,Name,Date__c,Status__c,Start_Time__c,Day_of_Week__c,End_Time__c,Duration__c,Instructor__r.Name,Room__r.Name,Parent_Event__c,Parent_Event__r.Status__c,Project__c';
        eventQryStr += ',Project__r.DLS_Ref__c,Approval_Status__c,Parent_Status_Changed_To__c,Reject_Comment__c,Schedule__r.Project_Task__r.Name,Timezone__c,Schedule__r.Name,Room__c,End_Date_Time__c,Start_Date_Time__c  FROM Events__c';
        eventQryStr += ' WHERE Approver_Name__c = \''+contactId+'\' AND Status__c = \'Draft\' AND (Approval_Status__c = \'Pending LTS Approval\'  OR Approval_Status__c = \'LTS Approved\') AND Parent_Event__c != null';
        
        if(stDate != null && endDate != null) {
            eventQryStr += ' AND Date__c >= :stDate AND Date__c <= :endDate'; 
        }else if(stDate != null){
            eventQryStr += ' AND Date__c >= :stDate'; 
        }else if(endDate != null){
            eventQryStr += ' AND Date__c <= :endDate'; 
        }
        eventQryStr += ' ORDER BY Date__c';
        
        List<Events__c> eventList = Database.query(eventQryStr);
        Map<Id,String> proIdStudentNames = new Map<Id,String>();
        Set<Id> projectIds = new Set<Id>();
        TimezoneUtilClass utilCls = new TimezoneUtilClass();

        if(communityName == 'instructor' || communityName == 'Internal' || Test.isRunningTest()){
            
            for(Events__c eve : eventList){
                projectIds.add(eve.Project__c);
            }
            
            for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName 
                                                FROM Contact_Assignments__c 
                                                WHERE Project__c IN :projectIds AND RecordType.DeveloperName = 'Student' AND Status__c = 'Active']){
                
                String studentName = '';
                studentName = (ca.Candidate_Name__r.FirstName == null ? '' : ca.Candidate_Name__r.FirstName);
                studentName += (ca.Candidate_Name__r.LastName != null ? (' '+ca.Candidate_Name__r.LastName.subString(0,1))+'.' : '');
                                                    
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
            eventInfo.title = eve.Day_of_Week__c+' / '+eve.project__r.DLS_Ref__c+' / '+eve.Room__r.Name;
            eventInfo.duration = String.valueOf(eve.Duration__c);
            eventInfo.endDateTime = utilCls.getUserTimeZoneDateTime(eve.End_Date_Time__c);
            eventInfo.startDateTime = utilCls.getUserTimeZoneDateTime(eve.Start_Date_Time__c);
            eventInfo.startTime = utilCls.getTimeStringFromDatetime(eventInfo.startDateTime);
            eventInfo.endTime = utilCls.getTimeStringFromDatetime(eventInfo.endDateTime);
            
            if(eventInfo.startDateTime != null){
                eve.Date__c = date.newinstance(eventInfo.startDateTime.year(), eventInfo.startDateTime.month(), eventInfo.startDateTime.day());
            }
            
            if(eve.Date__c != null){
                eventInfo.dateStr = String.valueOf(eve.Date__c).split('-')[1]+'/'+String.valueOf(eve.Date__c).split('-')[2]+'/'+String.valueOf(eve.Date__c).split('-')[0];
            }
            eventInfo.eventDate = eve.Date__c;
            eventInfo.eventType = 'PendingApproval';
            eventInfo.color = '#6c757d'; 
            eventinfo.classColour = 'pendingApproval';
            eventInfo.instructor = eve.Instructor__r.Name;
            eventInfo.project = eve.Project__r.DLS_Ref__c;
            eventInfo.projectId = eve.Project__c;
            eventInfo.room = eve.Room__r.Name;
            eventInfo.roomId = eve.Room__c;
            eventInfo.schedule = eve.Schedule__r.Name;
            eventInfo.status = eve.Status__c;
            eventInfo.timezone = eve.Timezone__c;
            eventInfo.parentEventId = eve.Parent_Event__c;
            eventInfo.parentEventStatus= eve.Parent_Event__r.Status__c;
            eventInfo.approvalStatus = eve.Approval_Status__c;
            eventInfo.rejectComment = eve.Reject_Comment__c;
            eventInfo.projectTask = eve.Schedule__r.Project_Task__r.Name;
            eventInfo.dayOfWeek = eve.Day_of_Week__c;
            eventInfo.showPendingApprovalIcon = true;
            eventInfo.parentStatusChangeTo = eve.Parent_Status_Changed_To__c;

            
            if(communityName == 'instructor' || Test.isRunningTest()){
                eventInfo.studentNames = proIdStudentNames.containsKey(eve.Project__c) ? proIdStudentNames.get(eve.Project__c) : '';
            }
            
            eventRecords.add(eventInfo);
        }
        
        system.debug(':::::eventRecords::::::'+eventRecords);
        
        return eventRecords;
    }
    
    @AuraEnabled
    public static List<EventDomain.EventCalendarInfo> getParentEventDetail(String eventId,String projectId,String communityName){
        
        String studentName = '';
        TimezoneUtilClass utilCls = new TimezoneUtilClass();

        List<EventDomain.EventCalendarInfo> eventRecords = new List<EventDomain.EventCalendarInfo>();
        
        for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName 
                                                FROM Contact_Assignments__c 
                                                WHERE Project__c = :projectId AND RecordType.DeveloperName = 'Student' AND Status__c = 'Active']){
            
            if(String.isBlank(studentName)){
                studentName = (ca.Candidate_Name__r.FirstName == null ? '' : ca.Candidate_Name__r.FirstName);
                studentName += (ca.Candidate_Name__r.LastName != null ? (' '+ca.Candidate_Name__r.LastName.subString(0,1))+'.' : '');
            }else {
                studentName = ', ';
                studentName += (ca.Candidate_Name__r.FirstName == null ? '' : ca.Candidate_Name__r.FirstName);
                studentName += (ca.Candidate_Name__r.LastName != null ? (' '+ca.Candidate_Name__r.LastName.subString(0,1))+'.' : '');
            }
        }
    
        for(Events__c eve : [SELECT Id,Name,Date__c,Status__c,Start_Time__c,End_Time__c,Duration__c,Instructor__r.Name,Day_of_Week__c,
                                    Room__r.Name,Parent_Event__c,Project__c,Project__r.DLS_Ref__c,End_Date_Time__c,Start_Date_Time__c,
                                   Approval_Status__c,Reject_Comment__c,Schedule__r.Project_Task__r.Name 
                                FROM Events__c 
                                WHERE Id = :eventId]){
                                
            
            EventDomain.EventCalendarInfo eventInfo = new EventDomain.EventCalendarInfo();
            eventInfo.eventId = eve.Id;
            eventInfo.eventName = eve.Name;
            eventInfo.endDateTime = utilCls.getUserTimeZoneDateTime(eve.End_Date_Time__c);
            eventInfo.startDateTime = utilCls.getUserTimeZoneDateTime(eve.Start_Date_Time__c);
            eventInfo.startTime = utilCls.getTimeStringFromDatetime(eventInfo.startDateTime);
            eventInfo.endTime = utilCls.getTimeStringFromDatetime(eventInfo.endDateTime);
            eventInfo.title = eventInfo.startTime+'-'+eventInfo.endTime+' / '+eve.project__r.DLS_Ref__c+' / '+eve.Room__r.Name;
                                      
            if(eventInfo.startDateTime != null){
                 eve.Date__c = date.newinstance(eventInfo.startDateTime.year(), eventInfo.startDateTime.month(), eventInfo.startDateTime.day());
            }
            
            eventInfo.eventDate = eve.Date__c;
                                    
            if(eve.Date__c != null){
                eventInfo.dateStr = String.valueOf(eve.Date__c).split('-')[1]+'/'+String.valueOf(eve.Date__c).split('-')[2]+'/'+String.valueOf(eve.Date__c).split('-')[0];
            }
       
            eventInfo.duration = String.valueOf(eve.Duration__c);
            eventInfo.instructor = eve.Instructor__r.Name;
            eventInfo.project = eve.Project__r.DLS_Ref__c;
            eventInfo.room = eve.Room__r.Name;
            eventInfo.projectTask = eve.Schedule__r.Project_Task__r.Name;
            eventInfo.dayOfWeek = eve.Day_of_Week__c;

            
            if(communityName == 'instructor'){
                eventInfo.studentNames = studentName;
            }
            
            eventRecords.add(eventInfo);
        }
        
        system.debug(':::::eventRecords::parent:event:::'+eventRecords);
        
        return eventRecords;
    }
    // save pending event records
    @AuraEnabled
    public static void saveEventRecords(List<Events__c> newEventRecs){
        try{
            List<Events__c> eventList = new List<Events__c>();

            for(Events__c newEventRec : newEventRecs){
                if(String.isNotBlank(newEventRec.Parent_Event__c) && newEventRec.Approval_Status__c == 'Instructor Approved'){
                    Events__c oldEventRec = new Events__c();
                    
                    oldEventRec.Id = newEventRec.Parent_Event__c;

                    if(String.isNotBlank( newEventRec.Parent_Status_Changed_To__c)){
                        oldEventRec.Status__c = newEventRec.Parent_Status_Changed_To__c;
                    }
                    eventList.add(oldEventRec);
                }
                
                eventList.add(newEventRec);
            }
            
            if(eventList.size() > 0){
               update eventList;
            }
            
        }catch(Exception e) {
            ErrorHandler.publishErrorLog(new List<ErrorHandler.ErrorLogUtilDomain>{new ErrorHandler.ErrorLogUtilDomain('EventApproval_Ctrl','saveEventRecords','',e.getMessage()+' at line number '+e.getLineNumber(),JSON.serialize(newEventRecs),'Aura Component')});
            throw new AuraHandledException(e.getMessage());
        }        
    }

    //Get All pending events for apporoval - Added by Jain S.
    @AuraEnabled
    public static List<EventDomain.PendingEventsInfo> getPendingEventsForApproval(String contactId){
        String communityName = null;
        
        if(String.isNotBlank(contactId)){
            communityName = 'Internal';
        }else{
            contactId = EventCalendarController.getLoggedUserContactId();
            communityName   = EventCalendarController.getCommunityPathPrefix();
        }
        
        List<EventDomain.PendingEventsInfo> pendingEventRecords = new List<EventDomain.PendingEventsInfo>();
        TimezoneUtilClass utilCls = new TimezoneUtilClass();
                
        String eventQryStr = 'SELECT Id,Name,Date__c,Status__c,Start_Time__c,Day_of_Week__c,End_Time__c,Duration__c,Instructor__r.Name,Room__r.Name,Parent_Event__c,Project__c';
        eventQryStr += ',Project__r.DLS_Ref__c,Approval_Status__c,Parent_Status_Changed_To__c,Reject_Comment__c,Schedule__r.Project_Task__r.Name,Timezone__c,Schedule__r.Name,Room__c';
        eventQryStr += ',Parent_Event__r.Name,Parent_Event__r.Status__c,Parent_Event__r.Start_Time__c,Parent_Event__r.Day_of_Week__c,Parent_Event__r.End_Time__c,Parent_Event__r.Duration__c';
        eventQryStr += ',Parent_Event__r.Room__c,Parent_Event__r.Room__r.Name,Parent_Event__r.Date__c,Parent_Event__r.Approval_Status__c,Parent_Event__r.End_Date_Time__c,Parent_Event__r.Start_Date_Time__c,End_Date_Time__c,Start_Date_Time__c FROM Events__c';
        eventQryStr += ' WHERE Instructor__c = \''+contactId+'\' AND Status__c = \'Draft\'AND  Approval_Status__c = \'LTS Approved\' ';// AND Parent_Event__c != null ';(Approval_Status__c = \'Pending LTS Approval\'  OR
        eventQryStr += ' ORDER BY Date__c';
        
        List<Events__c> eventList = Database.query(eventQryStr);
        Map<Id,String> proIdStudentNames = new Map<Id,String>();
        Set<Id> projectIds = new Set<Id>();
        
        if(communityName == 'instructor' || Test.isRunningTest() || communityName == 'Internal'){
            
            for(Events__c eve : eventList){
                projectIds.add(eve.Project__c);
            }
            
            for(Contact_Assignments__c ca : [SELECT Id,Name,Project__c,RecordType.DeveloperName,Candidate_Name__r.FirstName,Candidate_Name__r.LastName 
                                                FROM Contact_Assignments__c 
                                                WHERE Project__c IN :projectIds AND RecordType.DeveloperName = 'Student' AND Status__c = 'Active']){
                
                String studentName = '';
                studentName = (ca.Candidate_Name__r.FirstName == null ? '' : ca.Candidate_Name__r.FirstName);
                studentName += (ca.Candidate_Name__r.LastName != null ? (' '+ca.Candidate_Name__r.LastName.subString(0,1))+'.' : '');
                                                    
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
            EventDomain.EventCalendarInfo parentEventInfo = new EventDomain.EventCalendarInfo();
            EventDomain.PendingEventsInfo pendingEventRecord = new EventDomain.PendingEventsInfo();
            eventInfo.eventId = eve.Id;
            eventInfo.eventName = eve.Name;
            eventInfo.title = eve.Day_of_Week__c+' / '+eve.project__r.DLS_Ref__c+' / '+eve.Room__r.Name;
           
            eventInfo.duration = String.valueOf(eve.Duration__c);
            eventInfo.endDateTime = utilCls.getUserTimeZoneDateTime(eve.End_Date_Time__c);
            eventInfo.startDateTime = utilCls.getUserTimeZoneDateTime(eve.Start_Date_Time__c);
            eventInfo.startTime = utilCls.getTimeStringFromDatetime(eventInfo.startDateTime);
            eventInfo.endTime = utilCls.getTimeStringFromDatetime(eventInfo.endDateTime);
            if(eventInfo.startDateTime != null){
                eve.Date__c = date.newinstance(eventInfo.startDateTime.year(), eventInfo.startDateTime.month(), eventInfo.startDateTime.day());
            }
            if(eve.Date__c != null){
                eventInfo.dateStr = String.valueOf(eve.Date__c).split('-')[1]+'/'+String.valueOf(eve.Date__c).split('-')[2]+'/'+String.valueOf(eve.Date__c).split('-')[0];
            }
            eventInfo.eventDate = eve.Date__c;
            eventInfo.eventType = 'PendingApproval';
            eventInfo.color = '#6c757d'; 
            eventinfo.classColour = 'pendingApproval';
            eventInfo.instructor = eve.Instructor__r.Name;
            eventInfo.project = eve.Project__r.DLS_Ref__c;
            eventInfo.projectId = eve.Project__c;
            eventInfo.room = eve.Room__r.Name;
            eventInfo.roomId = eve.Room__c;
            eventInfo.schedule = eve.Schedule__r.Name;
            eventInfo.status = eve.Status__c;
            eventInfo.timezone = eve.Timezone__c;
            eventInfo.parentEventId = eve.Parent_Event__c;
            eventInfo.approvalStatus = eve.Approval_Status__c;
            eventInfo.rejectComment = eve.Reject_Comment__c;
            eventInfo.projectTask = eve.Schedule__r.Project_Task__r.Name;
            eventInfo.dayOfWeek = eve.Day_of_Week__c;
            eventInfo.showPendingApprovalIcon = true;
            eventInfo.parentStatusChangeTo = eve.Parent_Status_Changed_To__c;
            eventInfo.parentEventStatus= eve.Parent_Event__r.Status__c;


            
            if(communityName == 'instructor' || Test.isRunningTest() || communityName == 'Internal'){
                eventInfo.studentNames = proIdStudentNames.containsKey(eve.Project__c) ? proIdStudentNames.get(eve.Project__c) : '';
            }
            
            if(eve.Parent_Event__c != null){
                //Parent Event formation
                parentEventInfo.eventId = eve.Id;
                parentEventInfo.eventName = eve.Name;
                parentEventInfo.title = eve.Day_of_Week__c+' / '+eve.project__r.DLS_Ref__c+' / '+eve.Room__r.Name;
                parentEventInfo.eventDate = eve.Parent_Event__r.Date__c;
                if(eve.Parent_Event__r.Date__c != null){
                    parentEventInfo.dateStr = String.valueOf(eve.Parent_Event__r.Date__c).split('-')[1]+'/'+String.valueOf(eve.Parent_Event__r.Date__c).split('-')[2]+'/'+String.valueOf(eve.Parent_Event__r.Date__c).split('-')[0];
                }
                parentEventInfo.duration = String.valueOf(eve.Parent_Event__r.Duration__c);
                parentEventInfo.endDateTime = utilCls.getUserTimeZoneDateTime(eve.Parent_Event__r.End_Date_Time__c);
                parentEventInfo.startDateTime = utilCls.getUserTimeZoneDateTime(eve.Parent_Event__r.Start_Date_Time__c);
                parentEventInfo.startTime = utilCls.getTimeStringFromDatetime(eventInfo.startDateTime);
                parentEventInfo.endTime = utilCls.getTimeStringFromDatetime(eventInfo.endDateTime);
                parentEventInfo.eventType = 'PendingApproval';
                parentEventInfo.color = '#49C0B6'; 
                parentEventInfo.classColour = 'pendingApproval';
                parentEventInfo.instructor = eve.Instructor__r.Name;
                parentEventInfo.project = eve.Project__r.DLS_Ref__c;
                parentEventInfo.projectId = eve.Project__c;
                parentEventInfo.room = eve.Parent_Event__r.Room__r.Name;
                parentEventInfo.roomId = eve.Parent_Event__r.Room__c;
                parentEventInfo.schedule = eve.Schedule__r.Name;
                parentEventInfo.status = eve.Parent_Event__r.Status__c;
                parentEventInfo.timezone = eve.Timezone__c;
                //eventInfo.parentEventId = eve.Parent_Event__c;
                parentEventInfo.approvalStatus = eve.Parent_Event__r.Approval_Status__c;
                //eventInfo.rejectComment = eve.Reject_Comment__c;
                parentEventInfo.projectTask = eve.Schedule__r.Project_Task__r.Name;
                parentEventInfo.dayOfWeek = eve.Parent_Event__r.Day_of_Week__c;
                //eventInfo.showPendingApprovalIcon = true;
                //eventInfo.parentStatusChangeTo = eve.Parent_Status_Changed_To__c;
                parentEventInfo.studentNames = eventInfo.studentNames;
                pendingEventRecord.parentEvent = parentEventInfo;
            }
            pendingEventRecord.selectedEvent = eventInfo;
            
            pendingEventRecords.add(pendingEventRecord);

        }
        
        system.debug(':::::pendingEventRecords::::::'+pendingEventRecords);
        return pendingEventRecords;
    }
}