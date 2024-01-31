global without sharing class EventManagementController {

    global class StudentEvent { 
        Id studentId;
        String studentName;

        public StudentEvent(String studentName, Id studentId) {
            this.studentName = studentName;
            this.studentId = studentId;
        }
    }
    
    //To Get the Record Type for the Given Opportunity or Project
    @RemoteAction
    global static recordtypeWithProjectlist getRecordType(Id parentId, String parentType) {
        String recordTypeName = 'NOT_FOUND';
        List<AcctSeed__Project__c> proList = new List<AcctSeed__Project__c>();  // to store project related to opportunity which is launched currently
        String rateType;
        
        if(parentType == 'PROJECT') {
            List<AcctSeed__Project__c> projectList = [SELECT Id, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :parentId];
            projectList = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',new Set<Id>{parentId},',RecordType.DeveloperName');
            if(projectList != null && !projectList.isEmpty()) {
                recordTypeName = projectList[0].RecordType.DeveloperName;
                rateType = projectList[0].Default_Cost_Rate_Rate_Type__c;
            }
        } else if(parentType == 'OPPORTUNITY') {
            //List<Opportunity> oppList = [SELECT Id, RecordType.DeveloperName FROM Opportunity WHERE Id = :parentId];
            List<Opportunity> oppList = SObjectQueryService.SObjectQuery('Opportunity',new Set<Id>{parentId}, ',RecordType.DeveloperName');
            System.debug(':::::oppList::::::::'+oppList);
            proList = ProjectService.getproject(' WHERE AcctSeed__Opportunity__c','',new Set<Id>{parentId});
            if(!oppList.isEmpty()) {
                recordTypeName = oppList[0].RecordType.DeveloperName;
                rateType = oppList[0].Default_Cost_Rate_Rate_Type__c;
            }
        }
        
        recordtypeWithProjectlist rec = new recordtypeWithProjectlist();
        rec.recordTypeName = recordTypeName;
        rec.projectList = proList;
        rec.rateType = rateType;
        return rec;
    }
    
    @RemoteAction
    global static List<String> getPicklistValues(String objName,String fieldName){
        List<String> picklistOptions = SObjectQueryService.getPicklistValues(objName,fieldName);
        return picklistOptions;
    }
    
    global class recordtypeWithProjectlist{
        String recordTypeName;
        List<AcctSeed__Project__c> projectList; // to store project related to opportunity which is launched currently
        String rateType;
    }
    
    global class StudentClass {
        String studentName;
        Id studentId;
        Map<Id, Events__c> eventList;

        public StudentClass(String studentName, Id studentId) {
            this.studentId = studentId;
            this.studentName = studentName;
            this.eventList = new Map<Id, Events__c>();
        }

        public void add(Events__c event) {
            if(!this.eventList.containsKey(event.Id)) {
                this.eventList.put(event.Id, event);
            }
        }
    }
     //Update Data from Planned Days Editor
     @RemoteAction
     global static void updatePlannedDaysEditorData(String eventUpsertListJson, String eventDeleteListJson, String plannedDaysListJson, String plannedDaysDeleteListJson) {
         List<Events__c> eventUpsertList = (List<Events__c>) System.JSON.deserialize(eventUpsertListJson, List<Events__c>.class);
         Set<Id> eventDeleteList = (Set<Id>) System.JSON.deserialize(eventDeleteListJson, Set<Id>.class);
         List<Planned_Days_Off__c> plannedDaysList = (List<Planned_Days_Off__c>) System.JSON.deserialize(plannedDaysListJson, List<Planned_Days_Off__c>.class);
         Set<Id> plannedDaysDeleteList = (Set<Id>) System.JSON.deserialize(plannedDaysDeleteListJson, Set<Id>.class);

         upsert eventUpsertList;
         upsert plannedDaysList;
         //delete [SELECT Id FROM Events__c WHERE Id IN :eventDeleteList];
         if(eventDeleteList != null && eventDeleteList.size() > 0) {
             delete EventService.getEventByparentIds(eventDeleteList,' WHERE','',' Id');
         }
         //delete [SELECT Id FROM Planned_Days_Off__c WHERE Id IN :plannedDaysDeleteList];
         //List<Planned_Days_Off__c> plannedList = PlannedDaysOffService.getPlanneddaysBysds(plannedDaysDeleteList);
         List<Planned_Days_Off__c> plannedList = SObjectQueryService.SObjectQuery('Planned_Days_Off__c',plannedDaysDeleteList,'');
         PlannedDaysOffService.deletePlanneddaysOff(plannedList);
     }


    @RemoteAction
    global static Map<Id, StudentClass> getAllStudnetEvents() {
        //List<Contact_Assignments__c> contactAssignmnetsList = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE Candidate_Name__r.RecordType.DeveloperName = 'Student'];
        List<Contact_Assignments__c> contactAssignmnetsList = ContactAssignmentService.getContactassignmentRec(' WHERE Candidate_Name__r.RecordType.DeveloperName = \'Student\'','Candidate_Name__r.Name');
        Map<Id, List<StudentEvent>> projectsMap = new Map<Id, List<StudentEvent>>();
        for(Contact_Assignments__c cont : contactAssignmnetsList) {
            if(!projectsMap.containsKey(cont.Project__c)) {
                projectsMap.put(cont.Project__c, new List<StudentEvent>());
            }
            projectsMap.get(cont.Project__c).add(new StudentEvent(cont.Candidate_Name__r.Name, cont.Candidate_Name__c));
        }

       // List<Events__c> allEvents = [SELECT Id, Name, Start_Time__c, End_Time__c, Date__c, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__c, Project__r.Name, Status__c, Schedule__c, Schedule__r.Name, Schedule__r.DLS_Ref__c FROM Events__c];
        List<Events__c> allEvents = EventService.getEventByParentId(NULL,'',',Instructor__r.Name, Room__r.Name,Project__r.Name, Schedule__r.Name, Schedule__r.DLS_Ref__c ');
        Map<Id, StudentClass> studentEvents = new Map<Id, StudentClass>();

        for(Events__c event : allEvents) {
            if(projectsMap.containsKey(event.Project__c)) {
                for(StudentEvent student : projectsMap.get(event.Project__c)) {
                    if(!studentEvents.containsKey(student.studentId)) {
                        studentEvents.put(student.studentId, new StudentClass(student.studentName, student.studentId));
                    }
                    studentEvents.get(student.studentId).add(event);
                }
            }
        }

        return studentEvents;
    }


    @RemoteAction
    global static Integer createEvents(String eventString, Id scheduleId) {
        List<Events__c> events = (List<Events__c>) System.JSON.deserialize(eventString, List<Events__c>.class);
        upsert events;
        //update new Schedule__c(Id = ScheduleId, Status__c = 'Drafted'); // Commented on 28/Jun/2016
        //isConflictsInNewEventsForOpportunity(eventString, scheduleId); // Commented on 16 Nov, 2017 since the conflict is not needed for 2nd time
        //List<Schedule__c> scheduleList = [SELECT Total_Hours__c FROM Schedule__c WHERE Id = :scheduleId];
        List<Schedule__c> scheduleList = SObjectQueryService.SObjectQuery('Schedule__c',new Set<Id>{scheduleId},'');
        if(scheduleList.size() > 0) {
            if(scheduleList[0].Total_Hours__c != null) {
                return Integer.valueOf(scheduleList[0].Total_Hours__c);
            }
        }
        return 0;
    }

    @RemoteAction
    global static void updateEvents(String eventString, Id scheduleId, String removeEventsJSON, Id instructorId, Id roomId) {
        Boolean isProject = false;
        if(instructorId != null) {
            //List<Schedule__c> schList = [SELECT Id, Instructor__c FROM Schedule__c WHERE Id = :scheduleId];
            List<Schedule__c> schList = SObjectQueryService.SObjectQuery('Schedule__c',new Set<Id>{scheduleId},'');
            if(schList.size() > 0) {
                if(schList[0].Instructor__c == null) {
                    schList[0].Instructor__c = instructorId;
                    //update schList;
                    schList = ScheduleService.updateSchedule(schList);
                }
            }
        }
        if(instructorId != null) {
            setInstructorToSchedule(scheduleId, instructorId);
        }
        if(roomId != null) {
            setRoom(scheduleId, roomId);
        }
        List<Events__c> events = (List<Events__c>) System.JSON.deserialize(eventString, List<Events__c>.class);
        upsert events;
        delete (List<Events__c>) System.JSON.deserialize(removeEventsJSON, List<Events__c>.class);
    }

    @RemoteAction
    global static void removeEvents(String eventListJSON) {
        delete (List<Events__c>) System.JSON.deserialize(eventListJSON, List<Events__c>.class);
    }

    @RemoteAction
    global static void setRoom(Id schId, Id roomId) {
        //List<Schedule__c> schs = [SELECT Id, Room__c FROM Schedule__c WHERE Id = :schId];
        List<Schedule__c> schs = SObjectQueryService.SObjectQuery('Schedule__c',new Set<Id>{schId},'');
        for(Schedule__c s : schs) {
            s.Room__c = roomId;
        }
        //update schs;
        schs = ScheduleService.updateSchedule(schs);
        //Update all the child events with the new room.

        /*List<Events__c> updateEventList = EventService.getEventByparentIds(NULL,' WHERE Schedule__c = \''+schId+'\'','','');
        for(Events__c ev : updateEventList) {
            ev.Room__c = roomId;
        }
        update updateEventList;*/
    }

    @RemoteAction
    global static void setInstructor(Id schId, Id instructorId) {
        //List<Schedule__c> schs = [SELECT Id, Instructor__c, Start_Date__c, End_Date__c, Project_Task__c, Opportunity__c, Project__c FROM Schedule__c WHERE Id = :schId];
        List<Schedule__c> schs = SObjectQueryService.SObjectQuery('Schedule__c',new Set<Id>{schId},'');
        //Integer eventCount = [SELECT COUNT() FROM Events__c WHERE Schedule__c = :schId];
       Integer eventCount = EventService.geteventcount(' WHERE Schedule__c = \''+schId+'\'',NULL);
        //Check the gien schedule id is null or not.
        if(schId == null) {
            throw new InstructorAssignmentException('Schedule Id should not be null.');
        }
        //Check the given instructor Id is null or not.
        if(instructorId == null) {
            throw new InstructorAssignmentException('Instructor Id should not be null.');
        }
        Boolean isProject = false;
        Id parentId;
        Date startDate;
        Date endDate;
        Id projectTask;
        for(Schedule__c s : schs) {
            s.Instructor__c = instructorId;
            if(s.Project__c != null) {
                isProject = true;
                parentId = s.Project__c;
                startDate = s.Start_Date__c;
                endDate = s.End_Date__c;
                projectTask = s.Project_Task__c;
            } else {
                parentId = s.Opportunity__c;
                startDate = s.Start_Date__c;
                endDate = s.End_Date__c;
            }
        }
        //update schs;
        schs = ScheduleService.updateSchedule(schs);
        
        /*List<Events__c> events = [SELECT Id, Instructor__c FROM Events__c WHERE Schedule__c = :schId];
        //List<Events__c> events = EventService.getEventByparentIds(NULL,' WHERE Schedule__c = \''+schId+'\'','');
        for(Events__c ev : events) {
            ev.Instructor__c = instructorId;
        }
        update events;*/
        
       // List<Contact_Assignments__c> contactList = [SELECT Id FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Candidate_Name__c = :instructorId AND (Project__c = :parentId OR Opportunity_Name__c = :parentId)];
        List<Contact_Assignments__c> contactList = ContactAssignmentService.getContactassignmentRec(' WHERE RecordType.DeveloperName = \'Instructor\' AND Candidate_Name__c = \''+instructorId+'\' AND (Project__c = \''+parentId+'\' OR Opportunity_Name__c = \''+parentId+'\')','');
        if(contactList.size() == 0) {
            Contact_Assignments__c newInstructor = new Contact_Assignments__c();
            newInstructor.Candidate_Name__c = instructorId;
            newInstructor.Assignment_Position__c = 'Instructor';
            newInstructor.Status__c = 'Planned';
            newInstructor.Start_Date__c = startDate;
            newInstructor.End_Date__c = endDate;
            //List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact_Assignments__c' AND DeveloperName = 'Instructor'];
            List<RecordType> recordTypeList = SObjectQueryService.getRecTypeListBySobjTypeAndDevName(' AND DeveloperName','Contact_Assignments__c',new Set<String>{'Instructor'});
            id insRecordTypeId;
            if(recordTypeList.size() > 0) {
                insRecordTypeId = recordTypeList[0].Id;
            }
            if(isProject) {
                newInstructor.Project__c = parentId;
                newInstructor.Project_Task__c = projectTask;
            }else {
                newInstructor.Opportunity_Name__c = parentId;
            }
            newInstructor.RecordTypeId = insRecordTypeId;
            insert newInstructor;
        }
        //Update all the child events with the new Instructor.
        //List<Events__c> childEvents = [SELECT Id, Instructor__c FROM Events__c WHERE Schedule__c = :schId];
        
        /*List<Events__c> childEvents = EventService.getEventByparentIds(NULL,' WHERE Schedule__c = \''+schId+'\'','','');
        for(Events__c ev : childEvents) {
            ev.Instructor__c = instructorId;
        }
        update childEvents;*/
    }

    global static void setInstructorToSchedule(Id schId, Id instructorId) {
        //List<Schedule__c> schs = [SELECT Id, Instructor__c, Start_Date__c, End_Date__c, Project_Task__c, Opportunity__c, Project__c FROM Schedule__c WHERE Id = :schId];
        List<Schedule__c> schs = SObjectQueryService.SObjectQuery('Schedule__c',new Set<Id>{schId},'');
        Boolean isProject = false;
        Id opportunityId;
        Date startDate;
        Date endDate;
        Id projectId;
        Id projectTask;
        for(Schedule__c s : schs) {
            s.Instructor__c = instructorId;
            if(s.Project__c != null) {
                isProject = true;
                projectId = s.Project__c;
                startDate = s.Start_Date__c;
                endDate = s.End_Date__c;
                projectTask = s.Project_Task__c;
            }
            opportunityId = s.Opportunity__c;

        }
        //update schs;
        schs = ScheduleService.updateSchedule(schs);
       // List<Contact_Assignments__c> contactList = [SELECT Id FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Candidate_Name__c = :instructorId AND (Project__c = :projectId OR Opportunity_Name__c = :opportunityId)];
        List<Contact_Assignments__c> contactList = ContactAssignmentService.getContactassignmentRec(' WHERE RecordType.DeveloperName = \'Instructor\' AND Candidate_Name__c = \''+instructorId+'\' AND (Project__c = \''+projectId+'\' OR Opportunity_Name__c = \''+opportunityId+'\')','');
        if(contactList.size() == 0) {
            Contact_Assignments__c newInstructor = new Contact_Assignments__c();
            newInstructor.Candidate_Name__c = instructorId;
            newInstructor.Assignment_Position__c = 'Instructor';
            newInstructor.Status__c = 'Active';
            newInstructor.Start_Date__c = startDate;
            newINstructor.End_Date__c = endDate;
            //List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE sObjectType = 'Contact_Assignments__c' AND DeveloperName = 'Instructor'];
            List<RecordType> recordTypeList = SObjectQueryService.getRecTypeListBySobjTypeAndDevName(' AND DeveloperName','Contact_Assignments__c',new Set<String>{'Instructor'});
            id insRecordTypeId;
            if(recordTypeList.size() > 0) {
                insRecordTypeId = recordTypeList[0].Id;
            }
            if(isProject) {
                newInstructor.Project__c = projectId;
                newInstructor.Project_Task__c = projectTask;
                newInstructor.Opportunity_Name__c = opportunityId;
            }
            newInstructor.Opportunity_Name__c = opportunityId;
            newInstructor.RecordTypeId = insRecordTypeId;
            insert newInstructor;
        }
    }

    @RemoteAction
    global static void removeOpportunitySchedule(String scheduleId) {
        //delete [SELECT Id, Name FROM Events__c WHERE Schedule__c = :scheduleId];
        //delete [SELECT Id FROM Schedule__c WHERE Id = :scheduleId];
        //delete EventService.getEventByparentIds(NULL,' WHERE Schedule__c =\''+scheduleId+'\'','','');
        //delete EventService.getEventByparentIds(NULL,' WHERE Id =\''+scheduleId+'\'','','');
        delete SObjectQueryService.SObjectQuery('Schedule__c',new Set<Id>{scheduleId},'');
    }

    @RemoteAction
    global static Integer modifyOpportunitySchedule(Id scheduleId, String eventListJSON) {
        //delete [SELECT Id FROM Events__c WHERE Schedule__c = :scheduleId];
        delete EventService.getEventByparentIds(NULL,' WHERE Schedule__c =\''+scheduleId+'\'','','');
        insert (List<Events__c>) System.JSON.deserialize(eventListJSON, List<Events__c>.class);
        List<Events__c> evntList = (List<Events__c>) System.JSON.deserialize(eventListJSON, List<Events__c>.class);
        System.debug('evntList :::'+evntList);
        //if(evntList != null && evntList.size() >0) { Commented since the conflict check is not required after devent insertion.
        //    isConflictsInNewEventsForOpportunity(eventListJSON, scheduleId);
        //}
        //Find the new total hours of the schedule.
        //List<Schedule__c> scheduleList = [SELECT Total_Hours__c FROM Schedule__c WHERE Id = :scheduleId];
        List<Schedule__c> scheduleList = SObjectQueryService.SObjectQuery('Schedule__c',new Set<Id>{scheduleId},'');
        if(scheduleList.size() > 0) {
            if(scheduleList[0].Total_Hours__c != null) {
                return Integer.valueOf(scheduleList[0].Total_Hours__c);
            }
        }
        return 0;
    }

    @RemoteAction
    global static Id createTestEvent(String jsonEvent) {
        system.debug('jsonEvent'+jsonEvent);
        Events__c event = (Events__c) System.JSON.deserialize(jsonEvent, Events__c.class);
        insert event;
        return event.Id;
    }

    @RemoteAction
    global static List<Events__c> getStudentRelative(Id parentId, Id scheduleId) {
        //Get all the Student Id assigned in the current project
       
      // List<Contact_Assignments__c> studentList = [SELECT Candidate_Name__c FROM Contact_Assignments__c WHERE Project__c = :parentId AND Candidate_Name__r.RecordType.DeveloperName = 'Student'];
       List<Contact_Assignments__c> studentList = ContactAssignmentService.getContactassignmentRec(' WHERE Project__c = \''+parentId+'\' AND Candidate_Name__r.RecordType.DeveloperName = \'Student\'','');
        Set<Id> studentSet = new Set<Id>();
        for(Contact_Assignments__c student : studentList)
            studentSet.add(student.Candidate_Name__c);
        //Get all the project list assigned
       // List<Contact_Assignments__c> projectList = [SELECT Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c IN :studentSet AND Project__c != :parentId];
        List<Contact_Assignments__c> projectList = ContactAssignmentService.getContactAssignmentByContIds(studentSet,new Set<String>{},' AND Project__c != \''+parentId+'\'','');
        Set<Id> projectSet = new Set<Id>();
        for(Contact_Assignments__c project : projectList){
            projectSet.add(project.Project__c);
        }
        //Get the events for the students except the current project
        if(projectSet != NULL && projectSet.size() >0){
            //return [SELECT Id, Name, Start_Time__c, End_Time__c, Date__c, Timezone__c, Status__c, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Duration__c, Schedule__r.DLS_Ref__c FROM Events__c WHERE Project__c IN :projectSet];
            return EventService.getEventByparentIds(projectSet,' WHERE',',Instructor__r.Name,Room__r.Name,Schedule__r.DLS_Ref__c',' Project__c');
        }else {
            return null;
        }
    }

    @RemoteAction
    global static List<Events__c> getStudentEvents(Id studentId) {
       // List<Contact_Assignments__c> projectList = [SELECT Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :studentId];
        List<Contact_Assignments__c> projectList = ContactAssignmentService.getContactassignmentRec(' WHERE Candidate_Name__c = \''+studentId+'\'','');
        Set<Id> projectSet = new Set<Id>();
        for(Contact_Assignments__c project : projectList){
            projectSet.add(project.Project__c);
        }
       // return [SELECT Id, Name, Start_Time__c, End_Time__c, Date__c, Status__c, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Schedule__r.DLS_Ref__c, Duration__c, Project__c, Project__r.Name, Schedule__c, Schedule__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name FROM Events__c WHERE Project__c IN :projectSet];
        return EventService.getEventByparentIds(projectSet,' WHERE',',Instructor__r.Name,Room__r.Name,Schedule__r.DLS_Ref__c,Project__r.Name,Schedule__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name',' Project__c');
    }

    @RemoteAction
    global static void cancelSchedule(Id ScheduleId, string reason) {
        List<Schedule__c> scheduleList = SObjectQueryService.SObjectQuery('Schedule__c',new Set<Id>{scheduleId},'');
        for(Schedule__c sch : scheduleList) {
            sch.Status__c = 'Canceled';
            sch.Cancellation_Reason__c = reason;
        }
        scheduleList = ScheduleService.updateSchedule(scheduleList);

        //List<Events__c> eventList = [SELECT Id, Status__c FROM Events__c WHERE Schedule__c = :scheduleId AND Status__c = 'Scheduled'];
        /*List<Events__c> eventList = EventService.getEventByparentIds(NULL,' WHERE Schedule__c = \''+scheduleId+'\' AND Status__c = \'Scheduled\'','','');
        for(Events__c ev : eventList) {
            ev.Status__c = 'Cancelled';
        }
        update eventList;*/

    }

    @RemoteAction
    global static List<Planned_Days_Off__c> getPlannedAbsents(Id parentId, Boolean isParentIsProject) {
        List<Contact_Assignments__c> conts;
        if(isParentIsProject) {
            //conts = [SELECT Candidate_Name__c, Candidate_Name__r.Name, Candidate_Name__r.RecordType.DeveloperName FROM Contact_Assignments__c WHERE Project__c = :parentId AND Candidate_Name__r.RecordType.DeveloperName = 'Student'];
            conts = ContactAssignmentService.getContactassignmentRec(' WHERE Project__c = \''+parentId+'\' AND RecordType.DeveloperName = \'Student\'','Candidate_Name__r.Name, Candidate_Name__r.RecordType.DeveloperName');
        } else {
           // conts = [SELECT Candidate_Name__c, Candidate_Name__r.Name, Candidate_Name__r.RecordType.DeveloperName FROM Contact_Assignments__c WHERE Opportunity_Name__c = :parentId AND Candidate_Name__r.RecordType.DeveloperName = 'Student'];
            conts = ContactAssignmentService.getContactassignmentRec(' WHERE Opportunity_Name__c = \''+parentId+'\' AND RecordType.DeveloperName = \'Student\'','Candidate_Name__r.Name, Candidate_Name__r.RecordType.DeveloperName');
        }
        Set<Id> contactIds = new Set<Id>();
        for(Contact_Assignments__c cs : conts) {
            contactIds.add(cs.Candidate_Name__c);
        }
        //Used Service method for planned days query
        // Added by Sukanya
        //return [SELECT Description__c, Name, Id, Date__c, Requested_Reschedule_Date__c, Contact__c FROM Planned_Days_Off__c WHERE Contact__c IN :contactIds];
        
        // Modified thhe planned days off qry  based on new RT & functionality 
        // By NS on JAN 6 2018
        List<Planned_Days_Off__c> planList = new List<Planned_Days_Off__c>();
        
        if(contactIds.size() > 0 && contactIds.size() == 1) {
            planList = [SELECT Id,Name,Description__c,Date__c,Requested_Reschedule_Date__c,Contact__c,Opportunity__c,Project__c,Type__c  
                        FROM Planned_Days_Off__c 
                        WHERE RecordType.DeveloperName = 'Project_Planned_Days_Off' AND Type__c = 'Student' AND (Project__c = :parentId OR Opportunity__c = :parentId)];
        }
        
        Boolean applyProject_PDO = false;
        
        if(!isParentIsProject) {
            List<Opportunity> opp = [SELECT Id,Name,RecordType.DeveloperName,Project_Type__c 
                                        FROM Opportunity 
                                        WHERE Id = :parentId AND RecordType.DeveloperName = 'DLI_W_TO_Opportunities' AND (Project_Type__c = 'AFPAK' OR Project_Type__c = 'Resident LT')];
        
            if(opp != null && opp.size() > 0) {
                applyProject_PDO = true;
            }
        } else {
            List<AcctSeed__Project__c> pro = [SELECT Id,Name FROM AcctSeed__Project__c WHERE Id = :parentId AND RecordType.DeveloperName = 'DLI_W_LT_Projects'];
            
            if(pro != null && pro.size() > 0) {
                applyProject_PDO = true;
            }
        }
        
        if(applyProject_PDO) {
            List<Planned_Days_Off__c> projectPDO = [SELECT Id,Name,Date__c,Type__c,Project__c,Opportunity__c,Description__c,Requested_Reschedule_Date__c 
                                                    FROM Planned_Days_Off__c 
                                                    WHERE Contact__c = null AND RecordType.DeveloperName = 'Project_Planned_Days_Off' AND (Opportunity__c = :parentId OR Project__c = :parentId) 
                                                        AND Type__c = 'DLI-W LT'];
            if(projectPDO != null && projectPDO.size() > 0) {
                planList.addAll(projectPDO);
            }
        }
        
        //List<Planned_Days_Off__c> planList = PlannedDaysOffService.getPlanneddaysBycontact('  WHERE',contactIds,new Set<Date>{},'',false,'');
        return planList;
    }

    global class TotalOffs {
        Date ActivityDate;
        String Name;
        Date RescheduleDate;
        String Type = '';

        public TotalOffs(String Name, Date activityDate, String type, Date rescheduleDate) {
            this.Name = name;
            this.ActivityDate = activityDate;
            this.RescheduleDate = rescheduleDate;
            this.Type = type;
        }

        public TotalOffs(String name, Date activityDate, String type) {
            this.Name = name;
            this.ActivityDate = activityDate;
            this.Type = type;
        }
    }

    @RemoteAction
    global static List<TotalOffs> getAllOffs(Id parentId, Boolean isParentIsProject) {
        List<TotalOffs> offs = new List<TotalOffs>();
        for(Planned_Days_Off__c ps : getPlannedAbsents(parentId, isParentIsProject)) {
            if(ps.Date__c != null) {
                offs.add(new TotalOffs(ps.Description__c, ps.Date__c, 'OFF', ps.Requested_Reschedule_Date__c));
            }
        }
        
        /*for(Holiday h : [SELECT Name, ActivityDate FROM Holiday]) {
            offs.add(new TotalOffs(h.Name, h.ActivityDate, 'HOLIDAY'));
        }*/
        List<Holiday> holidayList = HolidayService.getHolidays();
        for(Holiday h : holidayList) {
            offs.add(new TotalOffs(h.Name, h.ActivityDate, 'HOLIDAY'));
        }
        return offs;
    }

    @RemoteAction
    global static String cancellEventByUserCommunity(Id eventId, Id contactId) {
        System.debug('Entered cancellEventByUserCommunity');
        UserCheckUtil.UserType type = getUserType();
        if(type.type != 'INSTRUCTOR') {
            //List<Events__c> eventList = [SELECT Id, Name, Project__r.DLS_Class__c, Schedule__r.Opportunity__r.DLS_Class__c, Start_Time__c, End_Time__c, Date__c FROM Events__c WHERE Id = :eventId];
            List<Events__c> eventList = EventService.getEventByparentIds(NULL,' WHERE Id = \''+eventId+'\'',',Project__r.DLS_Class__c, Schedule__r.Opportunity__r.DLS_Class__c','');
            String className;
            String onDate;
            String startTime;
            String endTime;
            if(eventList.size() > 0) {
                if(eventList[0].Project__r.DLS_Class__c != null) {
                    className = eventList[0].Project__r.DLS_Class__c;
                } else if(eventList[0].Schedule__r.Opportunity__r.DLS_Class__c != null){
                    className = eventList[0].Schedule__r.Opportunity__r.DLS_Class__c;
                }
                startTime = eventList[0].Start_Time__c;
                endTime = eventList[0].End_Time__c;
                onDate = eventList[0].Date__c.format();
            }
            Case newCase = new Case(Status = 'New', Subject = 'Event Cancel Request', ContactId = type.userContactId, Description = 'Cancel Event for DLS Class: #' + className + ' on ' + onDate + ' at ' + startTime + '-' + endTime + '.');
            insert newCase;
            System.debug('Case Created.');
            throw new EventCancelException('Case Created for cancelling this Event.');
            System.debug('Excpetion thrown');
        }
        System.debug('Going to cancel this event.');
        return cancellEventByUser(eventId, contactId);
    }


    @RemoteAction
    global static String cancellEventByUser(Id eventId, Id contactId) {
        //List<Events__c> evList = [SELECT Id, Cancelled_by__c, Date__c FROM Events__c WHERE Id = :eventId];
        List<Events__c> evList = EventService.getEventByparentIds(NULL,' WHERE Id = \''+eventId+'\'','','');
        Date today = Date.today();
        System.debug('LOG:TODAY: ' + today);
        String state = 'Canceled';
        for(Events__c ev : evList) {
            ev.Cancelled_by__c = contactId;
            System.debug('LOG:DATE ' + ev.Date__c);
            if(ev.Date__c >= today) {
                System.debug('LOG:DIFFERENCE IS ' + today.daysBetween(ev.Date__c));
                if(today.daysBetween(ev.Date__c) <= 1) {
                    System.debug('LOG:LATLY CANCELLED');
                    state = 'Late Cancellation';
                }
            }
            ev.Status__c = state;
        }
        update evList;
        sendEmailToSupervisorAndStudent(eventId, 'The event has been cancelled.');
        return state;
    }


    @RemoteAction
    global static String rescheduleEventCommunity(Id eventId, Id contactId, String rescheduleDateString, String newStartTime, String newEndTime, String type) {
        UserCheckUtil.UserType uType = getUserType();
        system.debug('uType::::'+uType);
        if(uType.type != 'INSTRUCTOR') {
            //List<Events__c> eventList = [SELECT Id, Name, Project__r.DLS_Class__c, Schedule__r.Opportunity__r.DLS_Class__c, Start_Time__c, End_Time__c, Date__c FROM Events__c WHERE Id = :eventId];
            List<Events__c> eventList = EventService.getEventByparentIds(NULL,' WHERE Id = \''+eventId+'\'',',Project__r.DLS_Class__c, Schedule__r.Opportunity__r.DLS_Class__c','');
            String className;
            String onDate;
            String startTime;
            String endTime;
            if(eventList.size() > 0) {
                if(eventList[0].Project__r.DLS_Class__c != null) {
                    className = eventList[0].Project__r.DLS_Class__c;
                } else if(eventList[0].Schedule__r.Opportunity__r.DLS_Class__c != null) {
                    className = eventList[0].Schedule__r.Opportunity__r.DLS_Class__c;
                }
                startTime = eventList[0].Start_Time__c;
                endTime = eventList[0].End_Time__c;
                onDate = eventList[0].Date__c.format();
            }
            Case newCase = new Case(Status = 'New', Subject = 'Event Reschedule Request', ContactId = uType.userContactId, Description = 'Event Rechedule Request for DLS Class: #' + className + ' on ' + onDate + ' at ' + startTime + '-' + endTime + ' to ' + rescheduleDateString + ', ' + newStartTime + '-' + newEndTime + '.');
            insert newCase;
            System.debug('Case Created.');
            throw new EventCancelException('Case Created To Reschedule this Event.');
            System.debug('Excpetion thrown');
        }
        return rescheduleEvent(eventId, contactId, rescheduleDateString, newStartTime, newEndTime, type);
    }


    @RemoteAction
    global static String rescheduleEvent(Id eventId, Id contactId, String rescheduleDateString, String startTime, String endTime, String type) {
        Date rescheduleDate = Date.valueOf(rescheduleDateString);
        List<Events__c> evList;
       // evList = [SELECT Id, Name, Cancelled_by__c, Duration__c, Event_Agenda__c, Instructor__c, Meeting_URL__c, Room__c, Date__c, Timezone__c, Total_Used_Hours__c, SequenceNo__c, Status__c, Schedule__c, Start_Time__c, End_Time__c, Project__c, Project__r.DLS_Class__c, Schedule__r.Opportunity__r.DLS_Class__c FROM Events__c WHERE Id = :eventId];
        evList = EventService.getEventByparentIds(NULL,' WHERE Id = \''+eventId+'\'',',Project__r.DLS_Class__c, Schedule__r.Opportunity__r.DLS_Class__c','');
        Date today = Date.today();
        System.debug('LOG:TODAY: ' + today);
        String state = 'COMPLETE';
        Boolean flag = false;
        Case newCase;
        Events__c event;
        if(evList.size() > 0) {
            event = evList.get(0);
        } else {
            return 'NO_EVENT_FOUND';
        }

        System.debug('LOG:DATE ' + event.Date__c);
        //if(event.Date__c >= today) {
            System.debug('LOG:DIFFERENCE IS ' + today.daysBetween(event.Date__c));
            if(today.daysBetween(event.Date__c) <= 7 && type == 'COMMUNITY') {
                //List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Id = :contactId];
                List<Contact> conList = SObjectQueryService.SObjectQuery('Contact',new Set<Id>{contactId},'');
                String contactName = '';

                String dlsClass = '';
                if(event.Project__c != null) {
                    dlsClass = event.Project__r.DLS_Class__c;
                } else if(event.Schedule__r.Opportunity__c != null) {
                    dlsClass = event.Schedule__r.Opportunity__r.DLS_Class__c;
                }

                if(conList.size() > 0) {
                    contactName = conList.get(0).Name;
                }
                
                newCase = new Case(Status = 'New', Subject = 'Event Reschedule Request', ContactId = contactId, Description = 'DLS Class#: ' + dlsClass + ' Event Number: ' + event.Name + 'Requested by: ' + contactName + ' Reschedule Date: ' + rescheduleDateString + ' Reschedule Start Time: ' + startTime + ' Reschedule End Time: ' + endTime);
                insert newCase;
                state = 'CASE';
            }else {
                state = 'CONFLICTED';
                if(isConflicted(rescheduleDate, startTime, endTime, event) == 'NO_CONFLICTS') {

                    Events__c newEvent = new Events__c();
                    newEvent.Date__c = rescheduleDate;
                    newEvent.Start_Time__c = startTime;
                    newEvent.End_Time__c = endTime;
                    newEvent.Cancelled_by__c = event.Cancelled_by__c;
                    newEvent.Duration__c = event.Duration__c;
                    newEvent.Event_Agenda__c = event.Event_Agenda__c;
                    newEvent.Instructor__c = event.Instructor__c;
                    newEvent.Meeting_URL__c = event.Meeting_URL__c;
                    newEvent.Project__c = event.Project__c;
                    newEvent.Room__c = event.Room__c;
                    newEvent.Schedule__c = event.Schedule__c;
                    newEvent.SequenceNo__c = event.SequenceNo__c;
                    newEvent.Status__c = event.Status__c;
                    newEvent.Timezone__c = event.Timezone__c;
                    newEvent.Total_Used_Hours__c = event.Total_Used_Hours__c;
                    newEvent.Name = event.Name;


                    event.Status__c = 'Rescheduled';
                    state = 'RESCHEDULED';

                    update event;
                    System.debug('****event****'+event);
                    System.debug('****newEvent****'+newEvent);
                    insert newEvent;
                    sendEmailToSupervisorAndStudent(eventId, 'The Event has been Rescheduled.');
                }
            }
        //}
        return state;
    }


    //
    //    Exception class used to throw Excpetion if any conflicts of events occured at the given date.
    //
    public class EventConflictException extends Exception {
        public String message;
    }


    public class EventCancelException extends Exception {
        public String message;
    }

    /*
     *  This Exception is thrown when assigning instructors to a schedule or any contact assignment
     */
    public class InstructorAssignmentException extends Exception {
        public String message;
        //public String exceptionCode;

        public InstructorAssignmentException(String message, String exceptionCode) {
            this.message = message;
            //this.exceptionCode = exceptionCode;
        }
    }

    //
    //Return a value which means the status of the result.
    //CONFLICT_HOLIDAYS - Conflict occured with the holidays.
    //CONFLICT_PLANNED_DAYS_OFF - Conflicted with the planned days off.
    //CONFLICT_EXISTING_EVENTS - Conflicted with the existing events.
    //NO_CONFLICTS - There is no conflicts.
    // startTime, endTime should be in the format of HH:MM AA
    //
    @RemoteAction
    global static String isConflicted(Date newDate, String startTime, String endTime, Events__c existingEvent) {
        //List<Holiday> holidayList = [SELECT Id, ActivityDate FROM Holiday WHERE ActivityDate = :newDate];
        List<Holiday> holidayList = HolidayService.getHolidayBydate(new Set<Date>{newDate});
        
        if(holidayList.size() > 0) {
            throw new EventConflictException('New Date conflicted with an holiday at ' + newDate.format() + '.');
        }
            //return 'CONFLICT_HOLIDAYS';
        List<Contact_Assignments__c> assignedContactsList = [SELECT Id, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE Project__c = :existingEvent.Project__c AND (RecordType.DeveloperName = 'Instructor' OR RecordType.DeveloperName = 'Student')];
        Set<Id> contactsSet = new Set<Id>();
        for(Contact_Assignments__c contact : assignedContactsList) {
            contactsSet.add(contact.Candidate_Name__c);
        }
        System.debug('contactSet ' + contactsSet);
        //List<Planned_Days_Off__c> plannedDaysOff = [SELECT Description__c, Name, Id, Date__c, Requested_Reschedule_Date__c, Contact__c FROM Planned_Days_Off__c WHERE Contact__c IN :contactsSet AND Date__c = :newDate];
        List<Planned_Days_Off__c> plannedDaysOff = PlannedDaysOffService.getPlanneddaysByconDates(contactsSet,new Set<Date>{newDate});
        
        if(plannedDaysOff.size() > 0) {
            //return 'CONFLICT_PLANNED_DAYS_OFF';
            throw new EventConflictException('New Date conflicted with a planned days off at ' + newDate.format() + '.');
        }
        List<Contact_Assignments__c> assignedProjectList = [SELECT Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c IN :contactsSet];
        Set<Id> projectIdSet = new Set<Id>();
        for(Contact_Assignments__c contact : assignedProjectList) {
            projectIdSet.add(contact.Project__c);
        }
        System.debug('assignedProjects' + projectIdSet);
        List<Events__c> eventList = [SELECT Id, Name, Date__c, Start_Time__c, End_Time__c, Status__c FROM Events__c WHERE Project__c IN :projectIdSet AND Date__c = :newDate AND Status__c = 'Scheduled'];
        //List<Events__c> eventList = EventService.getEventsByDateANDScheduleId(' WHERE Date__c = \''+String.ValueOf(newDate)+'\' AND Status__c = \'Scheduled\' AND Project__c',NULL,projectIdSet,NULL,'','');
        System.debug('eventList' + eventList);
        Integer startTime2 = convertToMinutes(startTime), endTime2 = convertToMinutes(endTime);
        for(Events__c event : eventList) {
            System.debug(existingEvent);
            System.debug(event);
            Integer startTime1 = convertToMinutes(event.Start_Time__c), endTime1 = convertToMinutes(event.End_Time__c);
            System.debug('startTime1 ' + startTime1);
            System.debug('endTime1 ' + endTime1);
            System.debug('startTime2 ' + startTime2);
            System.debug('endTime2 ' + endTime2);
            if((startTime1 >= startTime2 && startTime1 <= endTime2) || (endTime1 >= startTime2 && endTime1 <= endTime2)) {
                //return 'CONFLICT_EXISTING_EVENTS';
                throw new EventConflictException('Already an event ' + event.Name + ' is shceduled at this time.');
            }
        }

        return 'NO_CONFLICTS';
    }


    @RemoteAction
    global static List<Room__c> getNonConflictedRooms(Id scheduleId) {
        //List<Schedule__c> scheduleList = [SELECT Id, Name, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c WHERE Id = :scheduleId];
        List<Schedule__c> scheduleList = SObjectQueryService.SObjectQuery('Schedule__c',new Set<Id>{scheduleId},'');
        Date startDate;
        Date endDate;
        Integer startTime;
        Integer endTime;
        Map<Id, Id> roomsThatCantBeAssigned = new Map<Id, Id>();
        if(scheduleList.size() > 0) {
            startDate = scheduleList.get(0).Start_Date__c;
            endDate = scheduleList.get(0).End_Date__c;
            startTime = convertToMinutes(scheduleList.get(0).Start_Time__c);
            endTime = convertToMinutes(scheduleList.get(0).End_Time__c);
        }

        System.debug('Schedule start Date ' + startDate + ' end Date ' + endDate + ' : start time ' + startTime + ' : endTime ' + endTime);

        //List<Events__c> allPossibleEvents = [SELECT Id, Name, Date__c, Start_Time__c, End_Time__c, Room__c, Room__r.Name FROM Events__c WHERE Date__c >= :startDate AND Date__c <= :endDate AND Room__c != null AND Schedule__c != :scheduleId AND Status__c = 'Scheduled'];
          List<Events__c> allPossibleEvents = EventService.getEventByparentIds(NULL,' WHERE Date__c >= '+String.Valueof(startDate).split(' ')[0]+' AND Date__c <= '+String.Valueof(endDate).split(' ')[0]+' AND Room__c != null AND Schedule__c != \''+scheduleId+'\' AND Status__c = \'Scheduled\'',',Room__r.Name','');
            
        for(Events__c event : allPossibleEvents) {
            if(roomsThatCantBeAssigned.containsKey(event.Room__c) || (event.Room__c != null && event.Room__r.Name.toUpperCase() == 'ZOOM')) {
                continue;
            }
            Integer eventStartTime = convertToMinutes(event.Start_Time__c);
            Integer eventEndTime = convertToMinutes(event.End_Time__c);
            //System.debug('startTime ' + startTime + ' : endTime ' + endTime + ' : eventStartTime ' + eventStartTime + ' : eventEndTime ' + eventEndTime + ' : room Name ' + event.Room__r.Name);
            if((eventStartTime >= startTime && eventStartTime <= endTime) || (eventEndTime >= startTime && eventEndTime <= endTime)) {
                //System.debug('startTime ' + startTime + ' : endTime ' + endTime + ' : eventStartTime ' + eventStartTime + ' : eventEndTime ' + eventEndTime + ' : room Name ' + event.Room__r.Name);
                roomsThatCantBeAssigned.put(event.Room__c, event.Room__c);
            }
            //roomsThatCantBeAssigned.put(event.Room__c, event.Room__c);
        }

        System.debug('Rooms That Cant Be Assigned ' + roomsThatCantBeAssigned);

        //return [SELECT Id, Name, Location_n__r.Name FROM Room__c WHERE Id NOT IN : roomsThatCantBeAssigned.keySet()];
        return RoomService.getRoomRecByIdAndName(' WHERE Id NOT',roomsThatCantBeAssigned.keySet(),new Set<String>{},'Location_n__r.Name','');
    }


    //
    // Retrive List of InstructorWithConflicts instances, that stores all the instructor from an opportunity of an schedule with their event conflicts with the current method.
    // Parameters Id scheduleId - Id of the schedule.
    // Created 2016-02-27. Modified 2016-02-29.
    //
    @RemoteAction
    global static List<InstructorWithConflicts> getInstructorsWithConflicts(Id scheduleId, String projectRecordType) {
        //List<Schedule__c> scheduleList = [SELECT Id, Name, Project__c, Opportunity__c, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c WHERE Id = :scheduleId];
        List<Schedule__c> scheduleList = SObjectQueryService.SObjectQuery('Schedule__c',new Set<Id>{scheduleId},'');
        Id parentId;
        Set<Date> possibleDates = new Set<Date>(); //Push each date to the possibleDates Set to get only the events scheduled in other scheduleds to find the conflicts.
        if(scheduleList.size() > 0) {
            //Find the parent type.
            if(scheduleList[0].Project__c != null) {
                parentId = scheduleList[0].Project__c;
            } else if(scheduleList[0].Opportunity__c != null) {
                parentId = scheduleList[0].Opportunity__c;
            }
        }
        List<Contact_Assignments__c> assignedInstructorList;
        if(projectRecordType == 'Admin_Projects' || projectRecordType == 'Admin_Opportunities') {
            assignedInstructorList = [SELECT Candidate_Name__c, Candidate_Name__r.Name FROM Contact_Assignments__c WHERE (Project__c = :parentId OR Opportunity_Name__c = :parentId)];
        } else {
            assignedInstructorList = [SELECT Candidate_Name__c, Candidate_Name__r.Name FROM Contact_Assignments__c WHERE (Project__c = :parentId OR Opportunity_Name__c = :parentId) AND RecordType.DeveloperName = 'Instructor'];
        }
        
        Map<Id, InstructorWithConflicts> instructors = new Map<Id, InstructorWithConflicts>();
        for(Contact_Assignments__c con : assignedInstructorList) {
            if(!instructors.containsKey(con.Candidate_Name__c)) {
                instructors.put(con.Candidate_Name__c, new InstructorWithConflicts(con.Candidate_Name__c, con.Candidate_Name__r.Name));
            }
        }

        //Query the schedule Events.
        //List<Events__c> currentEventList = [SELECT Id, Name, Date__c, Start_Time__c, End_Time__c, Status__c, Instructor__c FROM Events__c WHERE Status__c = 'Scheduled' AND Schedule__c = :scheduleId];
        List<Events__c> currentEventList = EventService.getEventByparentIds(NULL,' WHERE Status__c = \'Scheduled\' AND Schedule__c = \''+scheduleId+'\'','','');
        //Push all events' date to the possibleDates set
        for(Events__c ev : currentEventList) {
            if(ev.Date__c != null) {
                possibleDates.add(ev.Date__c);
            }
        }
        //Query existing events.
        //List<Events__c> existingEventList = [SELECT Id, Name, Date__c, Start_Time__c, End_Time__c, Status__c, Instructor__c FROM Events__c WHERE Status__c = 'Scheduled' AND Schedule__c != :scheduleId AND Instructor__c IN :instructors.keySet() AND Date__c IN :possibleDates AND Instructor__c != null];
        List<Events__c> existingEventList = EventService.getEventsByDateANDInstructorId(' WHERE Status__c = \'Scheduled\' AND Schedule__c != \''+scheduleId+'\' AND Instructor__c != null',possibleDates,instructors.keySet(),'','Instructor__c');
       
        //Loop all the events.
        for(Events__c currentEvent : currentEventList) {
            Integer currentEventStartTime = convertToMinutes(currentEvent.Start_Time__c);
            Integer currentEventEndTime = convertToMinutes(currentEvent.End_Time__c);
            for(Events__c existingEvent : existingEventList) {
                Integer existingEventStartTime = convertToMinutes(existingEvent.Start_Time__c);
                Integer existingEventEndTime = convertToMinutes(existingEvent.End_Time__c);
                //Check the events conflicts with the given event set.
                if((existingEventStartTime >= currentEventStartTime && existingEventStartTime <= currentEventEndTime) || (existingEventEndTime >= currentEventStartTime && existingEventEndTime <= currentEventEndTime)) {
                    instructors.get(existingEvent.Instructor__c).addConflictedEvent(existingEvent);
                }
            }
        }

        return instructors.values();
    }

    public static Integer convertToMinutes(String hourString) {
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
        } else {
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


    @RemoteAction
    global static string sendEmailToSupervisorAndStudent(Id evntId, String mailSubject){

        Id parentId;
        Id instructorId;
        List<string> toAddress = new List<String>();
        //List<Events__c> evntList = [SELECT Id, Name, Start_Time__c, End_Time__c, Date__c, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__c, Project__r.Name, Status__c, Schedule__c, Schedule__r.Name, Schedule__r.DLS_Ref__c, Schedule__r.Opportunity__c FROM Events__c WHERE Id=:evntId];
        List<Events__c> evntList = EventService.getEventByparentIds(NULL,' WHERE Id = \''+evntId+'\'',',Instructor__r.Name, Room__r.Name,Project__r.Name,Schedule__r.Name, Schedule__r.DLS_Ref__c, Schedule__r.Opportunity__c','');
        String mailContent = '';

        if( evntList != null && evntList.size() > 0 ) {
            if(evntList[0].Project__c != null) {
                parentId = evntList[0].Project__c;
            } else if(evntList[0].Schedule__r.Opportunity__c != null){
                parentId = evntList[0].Schedule__r.Opportunity__c;
            }
            instructorId = evntList[0].Instructor__c;
            mailContent = 'Your request has been processed for the Event: '+evntList[0].Name;
            mailContent += ', Event Date: ' +evntList[0].Date__c;
            mailContent += ', Start Time: '+ evntList[0].Start_Time__c;
            mailContent += ', End Time: '+ evntList[0].End_Time__c + '\n';
        }

        for(Contact_Assignments__c con : [SELECT Id, Name, Project__c, Project__r.Name, Status__c, Candidate_Name__c, Candidate_Name__r.Email, RecordType.DeveloperName FROM Contact_Assignments__c WHERE (Project__c = :parentId OR Opportunity_Name__c = :parentId) AND Status__c = 'Active' AND (RecordType.DeveloperName = 'Staff' OR RecordType.DeveloperName = 'Student' OR RecordType.DeveloperName = 'Instructor')]){
            if(con.RecordType.DeveloperName == 'Instructor') {
                if(con.Candidate_Name__c != instructorId) {
                    continue;
                }
            }
            toAddress.add(con.Candidate_Name__r.Email);
        }
        System.debug('toAddress:::'+toAddress);
        List<Messaging.SingleEmailMessage> successMailMsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //mail.setToAddresses(new String[] {system.Label.TimeCardDayEmail});
        mail.setToAddresses(toAddress);
        mail.setSenderDisplayName('DLS Event Update');
        mail.setSubject(mailSubject);
        mail.setPlainTextBody(mailContent);
        successMailMsg.add(mail);
        try{
            if( successMailMsg != null && successMailMsg.size() > 0 ){
                Messaging.sendEmail(successMailMsg);
            }
        } catch (Exception ex){
            return 'Error:';
        }
        return 'Email Sent';
    }


    @RemoteAction
    global static String isConflictsInNewEventsOnSave(String newEventListJson) {
        List<Events__c> newEventList = (List<Events__c>) System.JSON.deserialize(newEventListJson, List<Events__c>.class);
        System.debug(newEventList);
        Id scheduleId;
        Set<Id> roomIdSet = new Set<Id>();
        Set<Id> instructorIdSet = new Set<Id>();
        Date startDate;
        Date endDate;
        String parentType;
        Id parentId;
        Set<Date> alottedDates = new Set<Date>();
        Set<Id> currentEventsIdSet = new Set<Id>();

        for(Events__c newEvent : newEventList) {
            //Collect the Ids if it have.
            if(newEvent.Id != null) {
                currentEventsIdSet.add(newEvent.Id);
            }
            if(newEvent.Room__c != null) {
                roomIdSet.add(newEvent.Room__c);
            }
            if(newEvent.Instructor__c != null) {
                instructorIdSet.add(newEvent.Instructor__c);
            }
            if(scheduleId == null) {
                if(newEvent.Schedule__c != null) {
                    scheduleId = newEvent.Schedule__c;
                }
            }

            if(newEvent.Date__c != null) {
                if(startDate == null) {
                    startDate = newEvent.Date__c;
                }
                if(endDate == null) {
                    endDate = newEvent.Date__c;
                }
                if(newEvent.Date__c < startDate) {
                    startDate = newEvent.Date__c;
                }
                if(newEvent.Date__c > endDate) {
                    endDate = newEvent.Date__c;
                }
                alottedDates.add(newEvent.Date__c);
            }
        }

        //List<Schedule__c> scheduleList = [SELECT Project__c, Opportunity__c, Name, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c WHERE Id = :scheduleId];
        List<Schedule__c> scheduleList = SObjectQueryService.SObjectQuery('Schedule__c',new Set<Id>{scheduleId},''); 
        if(scheduleList.size() > 0) {
            if(scheduleList[0].Project__c != null) {
                parentType = 'PROJECT';
                parentId = scheduleList[0].Project__c;
            } else if(scheduleList[0].Opportunity__c != null) {
                parentType = 'OPPORTUNITY';
                parentId = scheduleList[0].Opportunity__c;
            }
        }


        List<Contact_Assignments__c> studentList = new List<Contact_Assignments__c>();
        if(parentType == 'PROJECT' && parentId != null) {
            studentList = [SELECT Candidate_Name__c FROM Contact_Assignments__c WHERE Project__c = :parentId AND Candidate_Name__r.RecordType.DeveloperName = 'Student'];
        } else if(parentType == 'OPPORTUNITY' && parentId != null) {
            studentList = [SELECT Candidate_Name__c FROM Contact_Assignments__c WHERE Opportunity_Name__c = :parentId AND Candidate_Name__r.RecordType.DeveloperName = 'Student'];
        }
        Set<Id> studentIdSet = new Set<Id>();
        for(Contact_Assignments__c student : studentList) {
            studentIdSet.add(student.Candidate_Name__c);
        }

        //Find is there any holidays in the given dates. If yes throw an exception.
        //List<Holiday> holidayList = [SELECT Id, ActivityDate FROM Holiday WHERE ActivityDate IN :alottedDates];
        List<Holiday> holidayList = HolidayService.getHolidayBydate(alottedDates);
        if(holidayList.size() > 0) {
            throw new EventConflictException('Event Conflict with a holiday at ' + holidayList[0].ActivityDate + '.');
        }

        //Find is there any planned offs in the given data. If yes throw an exception.
        //List<Planned_Days_Off__c> plannedDaysOff = [SELECT Description__c, Name, Id, Date__c, Requested_Reschedule_Date__c, Contact__c FROM Planned_Days_Off__c WHERE (Contact__c IN :studentIdSet OR Contact__c IN :instructorIdSet) AND Date__c IN :alottedDates];
        List<Planned_Days_Off__c> plannedDaysOff = PlannedDaysOffService.getPlanneddaysByconDates(studentIdSet,instructorIdSet,alottedDates);
        
        if(plannedDaysOff.size() > 0) {
            throw new EventConflictException('Event Conflict with a planned days off at ' + plannedDaysOff[0].Date__c + '.');
        }

        //Get the relted student events.
        List<Events__c> studentEventList;
        if(parentType == 'PROJECT' && parentId != null) {
            List<Contact_Assignments__c> projectList = [SELECT Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c IN :studentIdSet AND Project__c != :parentId];
            Set<Id> projectIdSet = new Set<Id>();
            for(Contact_Assignments__c con : projectList) {
                projectIdSet.add(con.Project__c);
            }
            //studentEventList = [SELECT Id, Name, Schedule__c, Project__c, Date__c, Start_Time__c, End_Time__c, Room__r.Name FROM Events__c WHERE Schedule__r.Project__c IN :projectIdSet AND Date__c IN :alottedDates AND Status__c = 'Scheduled' AND Schedule__c != :scheduleId];
            studentEventList = EventService.getEventsByDateANDInstructorId(' WHERE Status__c = \'Scheduled\' AND Schedule__c != \''+scheduleId+'\'',alottedDates,projectIdSet, ',Room__r.Name','Schedule__r.Project__c');
        } else if(parentType == 'OPPORTUNITY' && parentId != null) {
            List<Contact_Assignments__c> opportunityList = [SELECT Opportunity_Name__c FROM Contact_Assignments__c WHERE Candidate_Name__c IN :studentIdSet AND Project__c != :parentId];
            Set<Id> opportunityIdSet = new Set<Id>();
            for(Contact_Assignments__c con : opportunityList) {
                opportunityIdSet.add(con.Opportunity_Name__c);
            }
            //studentEventList = [SELECT Id, Name, Schedule__c, Project__c, Date__c, Start_Time__c, End_Time__c, Room__r.Name FROM Events__c WHERE Schedule__r.Opportunity__c IN :OpportunityIdSet AND Date__c IN :alottedDates AND Status__c = 'Scheduled' AND Schedule__c != :scheduleId];
            studentEventList = EventService.getEventsByDateANDInstructorId(' WHERE Status__c = \'Scheduled\' AND Schedule__c != \''+scheduleId+'\'',alottedDates,OpportunityIdSet, ',Room__r.Name','Schedule__r.Opportunity__c');
        } else if(parentType == 'OPPORTUNITY') {
            
        }


        //Get the related room events.
        List<Events__c> roomAndInstructorEventList;
        if(parentType == 'PROJECT') {
            //roomAndInstructorEventList = [SELECT Id, Name, Schedule__c, Project__c, Date__c, Start_Time__c, End_Time__c, Room__r.Name, Instructor__c, Instructor__r.Name FROM Events__c WHERE (Room__c IN :roomIdSet OR Instructor__c IN :instructorIdSet) AND Date__c IN :alottedDates AND Status__c = 'Scheduled' AND Schedule__c != :scheduleId];
            roomAndInstructorEventList = EventService.getEventsByroomInstructorId(' WHERE Status__c = \'Scheduled\' AND Schedule__c != \''+scheduleId+'\' AND Date__c',instructorIdSet,roomIdSet,',Room__r.Name,Instructor__r.Name',alottedDates);
        }

        //Get the current project events.
        List<Events__c> relatedEventList;
        if(parentType == 'PROJECT') {
            //relatedEventList = [SELECT Id, Name, Schedule__c, Project__c, Date__c, Start_Time__c, End_Time__c FROM Events__c WHERE Schedule__r.Project__c = :parentId AND Date__c <= :startDate AND Date__c IN :alottedDates AND Status__c = 'Scheduled' AND Schedule__c != :scheduleId AND Id NOT IN :currentEventsIdSet];
            if(scheduleId != null) {
                relatedEventList = EventService.getEventsByDateANDScheduleId(' WHERE Schedule__r.Project__c = \''+parentId+'\' AND Date__c <= '+String.Valueof(startDate).split(' ')[0]+' AND Status__c = \'Scheduled\' AND Schedule__c != \''+scheduleId+'\' AND Date__c',alottedDates,NULL,currentEventsIdSet,'Id','');
            } else { 
                relatedEventList = EventService.getEventsByDateANDScheduleId(' WHERE Schedule__r.Project__c = \''+parentId+'\' AND Date__c <= '+String.Valueof(startDate).split(' ')[0]+' AND Status__c = \'Scheduled\' AND Date__c',alottedDates,NULL,currentEventsIdSet,'Id','');
            }
        }
        if(parentType == 'OPPORTUNITY') {
            //relatedEventList = [SELECT Id, Name, Schedule__c, Project__c, Date__c, Start_Time__c, End_Time__c FROM Events__c WHERE Schedule__r.Opportunity__c = :parentId AND Date__c <= :startDate AND Date__c IN :alottedDates AND Status__c = 'Scheduled' AND Schedule__c != :scheduleId AND Id NOT IN :currentEventsIdSet];
            if(scheduleId != null) {
                relatedEventList = EventService.getEventsByDateANDScheduleId(' WHERE Schedule__r.Opportunity__c = \''+parentId+'\' AND Date__c <= '+String.Valueof(startDate).split(' ')[0]+' AND Status__c = \'Scheduled\' AND Schedule__c != \''+scheduleId+'\' AND Date__c',alottedDates,NULL,currentEventsIdSet,'Id','');
            } else {
                relatedEventList = EventService.getEventsByDateANDScheduleId(' WHERE Schedule__r.Opportunity__c = \''+parentId+'\' AND Date__c <= '+String.Valueof(startDate).split(' ')[0]+' AND Status__c = \'Scheduled\' AND Date__c',alottedDates,NULL,currentEventsIdSet,'Id','');
            }
        }

        for(Events__c newEvent : newEventList) {
            Integer startTime = convertToMinutes(newEvent.Start_Time__c);
            Integer endTime = convertToMinutes(newEvent.End_Time__c);
            //Only check the room and instructor cconflicts if the parent is a project.
            if(parentType == 'PROJECT') {
                for(Events__c roomAndInstructorEvent : roomAndInstructorEventList) {
                    if(newEvent.Date__c == roomAndInstructorEvent.Date__c) {
                        Integer startTime1 = convertToMinutes(roomAndInstructorEvent.Start_Time__c), endTime1 = convertToMinutes(roomAndInstructorEvent.End_Time__c);
                        if(newEvent.Room__c == roomAndInstructorEvent.Room__c) {
                            if((startTime1 >= startTime && startTime1 <= endTime) || (endTime1 >= startTime && endTime1 <= endTime)) {
                                throw new EventConflictException('Already an event ' + roomAndInstructorEvent.Name + ' is shceduled at ' + roomAndInstructorEvent.Date__c + ' for a room ' + roomAndInstructorEvent.Room__r.Name + '.');
                            }
                        }
                        if(newEvent.Instructor__c == roomAndInstructorEvent.Instructor__c) {
                            if((startTime1 >= startTime && startTime1 <= endTime) || (endTime1 >= startTime && endTime1 <= endTime)) {
                                throw new EventConflictException('Already an event ' + roomAndInstructorEvent.Name + ' is shceduled at ' + roomAndInstructorEvent.Date__c + ' for the instructor ' + roomAndInstructorEvent.Instructor__r.Name + '.');
                            }
                        }
                    }
                }
            }

            //Check conflicts in current project events
            for(Events__c relatedEvent : relatedEventList) {
                Integer startTime1 = convertToMinutes(relatedEvent.Start_Time__c), endTime1 = convertToMinutes(relatedEvent.End_Time__c);
                if((startTime1 <= startTime && endTime1 >= startTime) || (endTime1 >= startTime && endTime1 <= endTime)) {
                    throw new EventConflictException('Already an event ' + relatedEvent.Name + ' is schedule at ' + relatedEvent.Date__c + ' for this ' + parentType.toLowerCase() + '.');
                }
            }

            //Check conflicts in related student events.
            for(Events__c studentEvent : studentEventList) {
                Integer startTime1 = convertToMinutes(studentEvent.Start_Time__c), endTime1 = convertToMinutes(studentEvent.End_Time__c);
                if((startTime1 <= startTime && endTime1 >= startTime) || (endTime1 >= startTime && endTime1 <= endTime)) {
                    throw new EventConflictException('Already an event ' + studentEvent.Name + ' is schedule at ' + studentEvent.Date__c + '.');
                }
            }
        }
        return 'NOT_CONFLICTED';
    }

    @RemoteAction
    global static Integer isConflictsInNewEvents(String newEventListJson, Id scheduleId, Id parentId, String parentType) {
        List<Events__c> newEventList = (List<Events__c>) System.JSON.deserialize(newEventListJson, List<Events__c>.class);
        Set<Id> roomIdSet = new Set<Id>();
        Set<Id> instructorIdSet = new Set<Id>();
        Date startDate;
        Date endDate;
        Set<Date> alottedDates = new Set<Date>();
        Integer count = 0;
        
        Set<Date> conflictSet = new Set<Date>();
        for(Events__c newEvent : newEventList) {
            if(newEvent.Room__c != null) {
                roomIdSet.add(newEvent.Room__c);
            }
            if(newEvent.Instructor__c != null) {
                instructorIdSet.add(newEvent.Instructor__c);
            }

            if(newEvent.Date__c != null) {
                if(startDate == null) {
                    startDate = newEvent.Date__c;
                }
                if(endDate == null) {
                    endDate = newEvent.Date__c;
                }
                if(newEvent.Date__c < startDate) {
                    startDate = newEvent.Date__c;
                }
                if(newEvent.Date__c > endDate) {
                    endDate = newEvent.Date__c;
                }

                alottedDates.add(newEvent.Date__c);

            }

        }


        if(scheduleId != null) {
            //List<Schedule__c> scheduleList = [SELECT Project__c, Opportunity__c, Name, Start_Date__c, End_Date__c, Start_Time__c, End_Time__c FROM Schedule__c WHERE Id = :scheduleId];
            List<Schedule__c> scheduleList = SObjectQueryService.SObjectQuery('Schedule__c',new Set<Id>{scheduleId},'');
            if(scheduleList.size() > 0) {
                if(scheduleList[0].Project__c != null) {
                    parentType = 'PROJECT';
                    parentId = scheduleList[0].Project__c;
                } else if(scheduleList[0].Opportunity__c != null) {
                    parentType = 'OPPORTUNITY';
                    parentId = scheduleList[0].Opportunity__c;
                }
            }
        }


        List<Contact_Assignments__c> studentList;
        if(parentType == 'PROJECT') {
            studentList = [SELECT Candidate_Name__c FROM Contact_Assignments__c WHERE Project__c = :parentId AND Candidate_Name__r.RecordType.DeveloperName = 'Student'];
        }else if(parentType == 'OPPORTUNITY') {
            studentList = [SELECT Candidate_Name__c FROM Contact_Assignments__c WHERE Opportunity_Name__c = :parentId AND Candidate_Name__r.RecordType.DeveloperName = 'Student'];
        }

        Set<Id> studentIdSet = new Set<Id>();
        for(Contact_Assignments__c student : studentList){
            studentIdSet.add(student.Candidate_Name__c);
        }

        //List<Holiday> holidayList = [SELECT Id, ActivityDate FROM Holiday WHERE ActivityDate IN :alottedDates];
        
        List<Holiday> holidayList = HolidayService.getHolidayBydate(alottedDates);
        for(Holiday hol : holidayList) {
            conflictSet.add(hol.ActivityDate);
        }

        //List<Planned_Days_Off__c> plannedDaysOff = [SELECT Description__c, Name, Id, Date__c, Requested_Reschedule_Date__c, Contact__c FROM Planned_Days_Off__c WHERE (Contact__c IN :studentIdSet OR Contact__c IN :instructorIdSet) AND Date__c IN :alottedDates];
        
        List<Planned_Days_Off__c> plannedDaysOff = PlannedDaysOffService.getPlanneddaysByconDates(studentIdSet,instructorIdSet,alottedDates);
        for(Planned_Days_Off__c off : plannedDaysOff) {
            conflictSet.add(off.Date__c);
        }


        List<Events__c> studentEventList = new List<Events__c>();

        if(parentType == 'PROJECT') {
            List<Contact_Assignments__c> projectList = [SELECT Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c IN :studentIdSet AND Project__c != :parentId];
            Set<Id> projectIdSet = new Set<Id>();
            for(Contact_Assignments__c con : projectList) {
                projectIdSet.add(con.Project__c);
            }
            //studentEventList = [SELECT Id, Name, Schedule__c, Project__c, Date__c, Start_Time__c, End_Time__c, Room__r.Name FROM Events__c WHERE Schedule__r.Project__c IN :projectIdSet AND Date__c IN :alottedDates AND Status__c = 'Scheduled' AND Schedule__c != :scheduleId];
            String tempSchId = scheduleId != null ? '\''+scheduleId+'\'': 'null';
            System.debug('projectIdSet::::::'+projectIdSet);
            System.debug('alottedDates::::::'+tempSchId+'::::'+alottedDates);
            if(projectIdSet != null && projectIdSet.size() > 0 ) {
                studentEventList = EventService.getEventsByDateANDInstructorId(' WHERE  Status__c = \'Scheduled\' AND Schedule__c != '+tempSchId,alottedDates,projectIdSet,',Room__r.Name','Schedule__r.Project__c');
            }
        } else if(parentType == 'OPPORTUNITY') {
            List<Contact_Assignments__c> opportunityList = [SELECT Opportunity_Name__c FROM Contact_Assignments__c WHERE Candidate_Name__c IN :studentIdSet AND Project__c != :parentId];
            Set<Id> opportunityIdSet = new Set<Id>();
            for(Contact_Assignments__c con : opportunityList) {
                opportunityIdSet.add(con.Opportunity_Name__c);
            }
            //studentEventList = [SELECT Id, Name, Schedule__c, Project__c, Date__c, Start_Time__c, End_Time__c, Room__r.Name FROM Events__c WHERE Schedule__r.Opportunity__c IN :OpportunityIdSet AND Date__c IN :alottedDates AND Status__c = 'Scheduled' AND Schedule__c != :scheduleId];
            System.debug('scheduleId ::::'+scheduleId);
            if(scheduleId != null) {
                studentEventList = EventService.getEventsByDateANDInstructorId(' WHERE  Status__c = \'Scheduled\' AND Schedule__c != \''+scheduleId+'\'',alottedDates,OpportunityIdSet,',Room__r.Name','Schedule__r.Opportunity__c');
            } else {
                studentEventList = EventService.getEventsByDateANDInstructorId(' WHERE Status__c = \'Scheduled\'',alottedDates,OpportunityIdSet,',Room__r.Name','Schedule__r.Opportunity__c');
            }
        }


        List<Events__c> roomAndInstructorEventList = new List<Events__c>();

        if(parentType == 'PROJECT' && instructorIdSet != null && instructorIdSet.size() > 0 && roomIdSet != null && roomIdSet.size() > 0 ) {
            //roomAndInstructorEventList = [SELECT Id, Name, Schedule__c, Project__c, Date__c, Start_Time__c, End_Time__c, Room__r.Name, Instructor__c, Instructor__r.Name FROM Events__c WHERE (Room__c IN :roomIdSet OR Instructor__c IN :instructorIdSet) AND Date__c IN :alottedDates AND Status__c = 'Scheduled' AND Schedule__c != :scheduleId];
            if(scheduleId != null) {
                roomAndInstructorEventList = EventService.getEventsByroomInstructorId(' WHERE Status__c = \'Scheduled\' AND Schedule__c != \''+scheduleId+'\' AND Date__c',instructorIdSet,roomIdSet,',Room__r.Name,Instructor__r.Name',alottedDates);
            } else {
                roomAndInstructorEventList = EventService.getEventsByroomInstructorId(' WHERE Status__c = \'Scheduled\' AND Schedule__c != '+scheduleId+' AND Date__c',instructorIdSet,roomIdSet,',Room__r.Name,Instructor__r.Name',alottedDates);
            }
        }
        
        List<Events__c> relatedEventList = new List<Events__c>();
        System.debug('alottedDates::::::'+alottedDates);
        System.debug('parentId::::::::'+parentId);
        if(parentType == 'PROJECT') {
            //relatedEventList = [SELECT Id, Name, Schedule__c, Project__c, Date__c, Start_Time__c, End_Time__c FROM Events__c WHERE Schedule__r.Project__c = :parentId AND Date__c <= :startDate AND Date__c IN :alottedDates AND Status__c = 'Scheduled' AND Schedule__c != :scheduleId];
            if(scheduleId != null) {
                relatedEventList = EventService.getEventsByDateANDScheduleId(' WHERE Schedule__r.Project__c = \''+parentId+'\' AND Date__c <= '+String.Valueof(startDate).split(' ')[0]+' AND Status__c = \'Scheduled\' AND Schedule__c != \''+scheduleId+'\' AND Date__c',alottedDates,NULL,NULL,'','');
            } else {
                relatedEventList = EventService.getEventsByDateANDScheduleId(' WHERE Schedule__r.Project__c = \''+parentId+'\' AND Date__c <= '+String.Valueof(startDate).split(' ')[0]+' AND Status__c = \'Scheduled\' AND Date__c',alottedDates,NULL,NULL,'','');
            }
        }
        if(parentType == 'OPPORTUNITY') {
            //relatedEventList = [SELECT Id, Name, Schedule__c, Project__c, Date__c, Start_Time__c, End_Time__c FROM Events__c WHERE Schedule__r.Opportunity__c = :parentId AND Date__c <= :startDate AND Date__c IN :alottedDates AND Status__c = 'Scheduled' AND Schedule__c != :scheduleId];
            if(scheduleId != null) {
                relatedEventList = EventService.getEventsByDateANDScheduleId(' WHERE Schedule__r.Opportunity__c = \''+parentId+'\' AND Date__c <= '+String.Valueof(startDate).split(' ')[0]+' AND Status__c = \'Scheduled\' AND Schedule__c != \''+scheduleId+'\' AND Date__c',alottedDates,NULL,NULL,'','');
            } else {
                relatedEventList = EventService.getEventsByDateANDScheduleId(' WHERE Schedule__r.Opportunity__c = \''+parentId+'\' AND Date__c <= '+String.Valueof(startDate).split(' ')[0]+' AND Status__c = \'Scheduled\' AND Date__c',alottedDates,NULL,NULL,'','');
            }
        }
        
        for(Events__c newEvent : newEventList) {
            Integer startTime = convertToMinutes(newEvent.Start_Time__c);
            Integer endTime = convertToMinutes(newEvent.End_Time__c);
            if(parentType == 'PROJECT') {
                for(Events__c roomAndInstructorEvent : roomAndInstructorEventList) {
                    if(newEvent.Room__c == roomAndInstructorEvent.Room__c) {
                        Integer startTime1 = convertToMinutes(roomAndInstructorEvent.Start_Time__c), endTime1 = convertToMinutes(roomAndInstructorEvent.End_Time__c);
                        if((startTime1 >= startTime && startTime1 <= endTime) || (endTime1 >= startTime && endTime1 <= endTime) && roomAndInstructorEvent.Date__c == newEvent.Date__c) {
                            conflictSet.add(newEvent.Date__c);
                        }
                    }
                    if(newEvent.Instructor__c == roomAndInstructorEvent.Instructor__c) {
                        Integer startTime1 = convertToMinutes(roomAndInstructorEvent.Start_Time__c), endTime1 = convertToMinutes(roomAndInstructorEvent.End_Time__c);
                        if((startTime1 >= startTime && startTime1 <= endTime) || (endTime1 >= startTime && endTime1 <= endTime) && roomAndInstructorEvent.Date__c == newEvent.Date__c) {
                            conflictSet.add(newEvent.Date__c);
                        }
                    }
                }
            }
            for(Events__c relatedEvent : relatedEventList) {
                Integer startTime1 = convertToMinutes(relatedEvent.Start_Time__c), endTime1 = convertToMinutes(relatedEvent.End_Time__c);
                if((startTime1 >= startTime && endTime1 >= startTime) || (endTime1 >= startTime && endTime1 <= endTime)) {
                    conflictSet.add(newEvent.Date__c);
                }
            }
            for(Events__c studentEvent : studentEventList) {
                Integer startTime1 = convertToMinutes(studentEvent.Start_Time__c), endTime1 = convertToMinutes(studentEvent.End_Time__c);
                if((startTime1 >= startTime && endTime1 >= startTime) || (endTime1 >= startTime && endTime1 <= endTime)) {
                    conflictSet.add(newEvent.Date__c);
                }
            }
        }
        return conflictSet.size();
    }

      //
      // Inner Class to store an instructor with all of his event conflicts.
      // Feb 27, 2016
      //
      global class InstructorWithConflicts {
          public Id instructorId;
          public List<Events__c> conflictedEventList;
          public String instructorName;

          public InstructorWithConflicts(Id instructorId, String instructorName) {
              this.instructorId = instructorId;
              this.instructorName = instructorName;
              conflictedEventList = new List<Events__c>();
          }

          public InstructorWithConflicts() {
              conflictedEventList = new List<Events__c>();
          }

          public void addConflictedEvent(Events__c event) {
              conflictedEventList.add(event);
          }

      }

      //  Added EventUpadation From Instructor AgendaBuilder page by Sukanya March 10 2016
      @RemoteAction
      global static void EventUpdationFromAgendaBuilder(String eventUpdationJson) {

          List<Events__c> eventUpdationList = (List<Events__c>) System.JSON.deserialize(eventUpdationJson, List<Events__c>.class);
          system.debug(':::::::::::eventUpdationList::::::::::;;;;;'+eventUpdationList);
          if(eventUpdationList.size() > 0) {
              update eventUpdationList;
          }
      }

       //
       //  Instructor Agenda Builder page action methods for Content Distribution Record Creation,Deletion by Sukanya 6 April 2016
       //

      @RemoteAction
      global static void ContentDistributionMethods(String contentCreationJson,String contentDeletionJson) {

          List<ContentDistribution> contentCreationList = (List<ContentDistribution>) System.JSON.deserialize(contentCreationJson, List<ContentDistribution>.class);
          List<ContentDistribution> contentDeletionList = (List<ContentDistribution>) System.JSON.deserialize(contentDeletionJson, List<ContentDistribution>.class);

          system.debug(':::::::::::contentCreationList::::::::::;;;;;'+contentCreationList);
          system.debug(':::::::::::contentDeletionList::::::::::;;;;;'+contentDeletionList);

          if(contentCreationList.size() > 0) {
              insert contentCreationList;
          }
          
          if(contentDeletionList.size() > 0) {
              delete contentDeletionList;
          }
      }

      //Get the count of events for a contact for a day.
      global static Integer getEventCountOn(Date day, Id contactId) {
          List<Contact_Assignments__c> contactAssignmnetsList = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId];
          Set<Id> projectIdSet = new Set<Id>();
          for(Contact_Assignments__c assignment : contactAssignmnetsList) {
              projectIdSet.add(assignment.Project__c);
          }
          //Integer eventCount = [SELECT COUNT() FROM Events__c WHERE Project__c IN :projectIdSet AND Date__c = :day];
          Integer eventCount = EventService.geteventcount(' WHERE Date__c = '+String.Valueof(day).split(' ')[0]+' AND Project__c ',projectIdSet);
          return eventCount;
      }

      //Get the Events of particular day of an contact
      global static List<Events__c> getEventsListOn(Date day, Id contactId) {
          List<Contact_Assignments__c> contactAssignmnetsList;
          System.debug('contactId' + contactId);
          if(contactId != null) {
              contactAssignmnetsList = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId];
          }
          
          Set<Id> projectIdSet = new Set<Id>();
          System.debug('contactAssignmnetsList' + contactAssignmnetsList);
          if(contactAssignmnetsList != null) {
              for(Contact_Assignments__c assignment : contactAssignmnetsList) {
                  projectIdSet.add(assignment.Project__c);
              }
          }
          System.debug('projectIdSet' + projectIdSet);
          List<Events__c> eventList;
          if(projectIdSet != null) {
              //eventList = [SELECT Id, Name, Start_Time__c, End_Time__c, Schedule__r.DLS_Ref__c, Date__c FROM Events__c WHERE Project__c IN :projectIdSet AND Date__c = :day AND Status__c = 'Scheduled'];
              eventList = EventService.getEventByparentIds(projectIdSet,' WHERE Date__c = '+String.Valueof(day).split(' ')[0]+' AND Status__c = \'Scheduled\'',',Schedule__r.DLS_Ref__c',' AND Project__c');
          }
          System.debug('eventList' + eventList);
          return eventList;
      }

      @RemoteAction
      global static List<Events__c> getContactAllEvents(Id contactId) {
          List<Contact_Assignments__c> contactAssignmnetsList;
          if(contactId != null) {
              contactAssignmnetsList = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId];
          }
          Set<Id> projectIdSet = new Set<Id>();
          if(contactAssignmnetsList != null) {
              for(Contact_Assignments__c assignment : contactAssignmnetsList) {
                  projectIdSet.add(assignment.Project__c);
              }
          }
          List<Events__c> eventList;
          if(projectIdSet != null) {
              //eventList = [SELECT Id, Name, Start_Time__c, End_Time__c, Schedule__r.DLS_Ref__c, Date__c, Timezone__c, Duration__c FROM Events__c WHERE Project__c IN :projectIdSet AND Status__c = 'Scheduled' AND Date__c > :System.today()];
              eventList = EventService.getEventByparentIds(projectIdSet,' WHERE Date__c > '+String.ValueOf(System.today()).split(' ')[0]+' AND Status__c = \'Scheduled\' ',', Schedule__r.DLS_Ref__c',' AND Project__c');
          }
          return eventList;
      }

      @RemoteAction
      global static List<Events__c> getCoContactAllEvents(Id contactId) {
          List<Contact_Assignments__c> contactAssignmnetsList;
          if(contactId != null) {
              contactAssignmnetsList = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId];
          }
          Set<Id> projectIdSet = new Set<Id>();
          if(contactAssignmnetsList != null) {
              for(Contact_Assignments__c assignment : contactAssignmnetsList) {
                  projectIdSet.add(assignment.Project__c);
              }
          }
          List<Events__c> eventList;

          System.debug(projectIdSet);
          Set<Id> coContactSet = new Set<Id>();
          List<Contact_Assignments__c> coContactAssignmnetsList = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE Project__c IN :projectIdSet];
          Set<Id> coContactProjectIdSet = new Set<Id>();
          for(Contact_Assignments__c assignment : coContactAssignmnetsList) {
              coContactSet.add(assignment.Candidate_Name__c);
          }

          List<Contact_Assignments__c> coContactContactAssignmentsPojectList = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c IN :coContactSet AND Project__c NOT IN :projectIdSet];
          for(Contact_Assignments__c assignment : coContactContactAssignmentsPojectList){
              coContactProjectIdSet.add(assignment.Project__c);
          }

          System.debug(coContactProjectIdSet);

          //eventList = [SELECT Id, Name, Start_Time__c, End_Time__c, Schedule__r.DLS_Ref__c, Date__c, Timezone__c, Duration__c FROM Events__c WHERE Project__c IN :coContactProjectIdSet AND Project__c NOT IN :projectIdSet AND Date__c >= :System.today()];
          if(coContactProjectIdSet != null && coContactProjectIdSet.size() > 0){
              eventList = EventService.getEventsByDateANDScheduleId(' WHERE Date__c >= '+String.valueOf(System.today()).split(' ')[0]+' AND Project__c',NULL,coContactProjectIdSet,projectIdSet,'Project__c',',Schedule__r.DLS_Ref__c');
          } else {
              eventList = EventService.getEventsByDateANDScheduleId(' WHERE Date__c >= '+String.valueOf(System.today()).split(' ')[0],NULL,coContactProjectIdSet,projectIdSet,'Project__c',',Schedule__r.DLS_Ref__c');
          }
          //eventList = EventService.getEventByparentIds(coContactProjectIdSet,' WHERE Date__c >= \''+System.today()+'\' AND Status__c = \'Scheduled\' AND Project__c','Schedule__r.DLS_Ref__c');
          System.debug(eventList);
          return eventList;
      }

      @RemoteAction
      global static List<Holiday> getHolidays() {
          //List<Holiday> holidayList = [SELECT Id, Name, ActivityDate FROM Holiday];
          
          List<Holiday> holidayList = HolidayService.getHolidays();
          return holidayList;
      }

      @RemoteAction
      global static List<Planned_Days_Off__c> getPlannedOffs(Id contactId) {
          //return [SELECT Id, Name, Date__c, Description__c, Requested_Reschedule_Date__c FROM Planned_Days_Off__c WHERE Contact__c = :contactId];
          //List<Planned_Days_Off__c> planDays = PlannedDaysOffService.getPlanneddaysBycontact(new Set<Id>{contactId});
          List<Planned_Days_Off__c> planDays = PlannedDaysOffService.getPlanneddaysBycontact(' WHERE',new Set<Id>{contactId},new Set<Date>{},'',false,'');
          return planDays;
      }

      //Created on 28-Apr, 2016 by Melbin
      //Method to get the usertype.
      @RemoteAction
      global static UserCheckUtil.UserType getUserType() {
          return UserCheckUtil.getUserType();
      }
      
      
      @RemoteAction
      global static List<Events__c> getTodayEvents() {
          //Query all the events which is schedulted today.
          //return [SELECT Name, Date__c, Event_Agenda__c, Start_Time__c, End_Time__c, Project__c, Schedule__c, Schedule__r.Name, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name, Schedule__r.DLS_Ref__c, Duration__c, Status__c, Meeting_URL__c, Timezone__c FROM Events__c  WHERE Date__C = :System.today() AND Status__c != 'Rescheduled'];
          return EventService.getEventByparentIds(NULL,' WHERE Date__C = '+String.valueOf(System.today()).split(' ')[0]+' AND Status__c != \'Rescheduled\'',',Schedule__r.Name,Instructor__r.Name,Room__r.Name, Project__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name, Schedule__r.DLS_Ref__c','');
      }

      @RemoteAction
      global static void updateAgenda(Id eventId, String agenda) {
          Events__c agendaEvent = new Events__c(Id = eventId);
          agendaEvent.Event_Agenda__c = agenda;
          update agendaEvent;
      }

      @RemoteAction
      global static String getTimzone() {
          //User currentUser = [SELECT TimeZoneSidKey FROM User WHERE Id = :UserInfo.getUserId() AND isActive = true];
          List<User> currentUser = UserService.getUserRec(' WHERE Id = \''+UserInfo.getUserId()+'\''+' AND isActive = true','');
          if(currentUser != null) {
              return currentUser[0].TimeZoneSidKey;
          }
          return null;
      }

      //Method to Change the state of a schedule to Active
      @RemoteAction
      global static void activateSchedule(Id scheduleId) {
          //List<Schedule__c> schList = [SELECT Id, Status__c FROm Schedule__c WHERE Id = :scheduleId];
          List<Schedule__c> schList = SObjectQueryService.SObjectQuery('Schedule__c',new Set<Id>{scheduleId},'');
          for(Schedule__c sch : schList) {
              sch.Status__c = 'Active';
          }
          //update schList;
          schList = ScheduleService.updateSchedule(schList);
          
          //Call EventHandler to create event records
          // Added by NS on Sep 24 2018
          EventHandler.handleEventRecords(new Set<Id>{scheduleId});
      }

      public static void testmet() {
          Date d = Date.valueOf('2016-07-04');
      }
      
      // Method to get Opportunity data for Client Community
      
      @RemoteAction
      global static List<Opportunity> getOpportunityDetails() {
      
           Date stDate = system.today().addMonths(1).toStartOfMonth();
           Date edDate = system.today().addMonths(13).toStartOfMonth().addDays(-1);
           Date currentyear = system.today().addYears(-1);
          
          //List<User> userList = [SELECT Id,Name,UserType,ContactId,AccountId,Instructor_Access__c,Partner_Access__c,Student_Access__c,Client_Access__c FROM User WHERE Id =:UserInfo.getUserId()]; 
          List<User> userList = SObjectQueryService.SObjectQuery('User',new Set<Id>{UserInfo.getUserId()},'');
          system.debug(':::::::userList::::::::::'+userList);
        
          /*List<Opportunity> oppList = [SELECT Id,Name,StageName,Authorization__c,Start_Date__c,End_Date__c,DLS_Class__c,Language__c,Location__c,Location__r.Name,
                                               SF182_Authorization__c,Student_Name__c,Student_Name__r.Name,Student_Name__r.Alias__c,Total_Hours_Paid_Auth_New__c,
                                               Hours_Used_Rollup__c,Hours_Remaining__c,Hours_As_Of__c,Last_Hours_Update__c,Paid_Hours_Exhausted_Date__c,
                                               Materials_Budget_Paid_New__c,Materials_Budget_Remaining_OLD__c,AccountId,Account.Name,Supervisor__c,Supervisor__r.Name,
                                               RecordTypeId,RecordType.DeveloperName,Candidate_Name__c,Candidate_Name__r.Name,Oral_Exam__c,Request_Date__c,
                                               Enrollment_Date__c,Proficiency_Testing_New__c,Quote_Date__c,Auth_Start_Date__c,Auth_End_Date__c,ILR_Midterm_Date__c,
                                               ILR_Final_Date__c,Send_Mid_Term_Report__c,Hours_Week__c,ILR_S_Goal__c,ILR_R_Goal__c,Program_type__c,AFPAK_Session__c,
                                               Room__c,Room__r.Name,Days__c,Days2__c,Start_Time1__c,Start_Time2__c,End_Time1__c,End_Time2__c,CloseDate
                                       FROM Opportunity
                                       WHERE RecordType.DeveloperName IN ('Testing_Opportunities','New_Classes_Opportunities') AND End_Date__c > :currentyear AND AccountId = :userList[0].AccountId];*/
                                       
          List<Opportunity> oppList = OpportunityService.getOpportunitiesByAccIdsAndRtDevNames(new Set<Id>{userList[0].AccountId},new Set<String>{'Testing_Opportunities','New_Classes_Opportunities'},'',',Location__r.Name,Student_Name__r.Name,Student_Name__r.Alias__c,Account.Name,Supervisor__r.Name,RecordType.DeveloperName,Candidate_Name__r.Name,Room__r.Name',currentyear);
          system.debug('::::::::oppList:::client:::'+oppList);
          system.debug('::::::::oppList:::else:client::'+oppList.size());
           
           return oppList;
      }
      
      // Below method to check the Schedule conflicts for Instructor / Room on Schedule update, instructor assign
      // Added by Sukanya on 20.11.2017 
        @RemoteAction
        global static Map<String,Integer> getConflictsonSchedules(String scheduleJson,string selectedInstructor,String parentType,String parentId,String parentRT,String daysOffJson) {
            
            List<Schedule__c> schedule = (List<Schedule__c>) System.JSON.deserialize(scheduleJson, List<Schedule__c>.class);
            system.debug('::::::*******:::::'+scheduleJson+'\n::***::'+selectedInstructor+'\n::**::'+parentType+'\n::**::'+parentId);
            
            List<Planned_Days_Off__c> daysOffFromUI = (List<Planned_Days_Off__c>) System.JSON.deserialize(daysOffJson, List<Planned_Days_Off__c>.class);
            
            Map<String,Integer> conflictType_Count = new Map<String,Integer>();
            
            Set<Id> stu_projectIds = new Set<Id>();
            Set<Id> stu_oppIds = new Set<Id>();
            Set<Id> studentIds = new Set<Id>();
            
            
            Schedule__c currRec = schedule.size() > 0 ? schedule[0]:null;
            Date currentStartDate = currRec.Start_Date__c;
            Date currentEndDate = currRec.End_Date__c;
            //Integer currStartTime = EventManagementController.convertToMinutes(currRec.Start_Time__c);
            //Integer currEndTime = EventManagementController.convertToMinutes(currRec.End_Time__c);
            
            Id selectedRoomId = currRec.Room__c;
            
            Id priorSchedule;
            if(currRec.Prior_Schedule__c != null) {
                priorSchedule = currRec.Prior_Schedule__c;
            }
            
            system.debug('::::::currRec:::::'+currRec);
            //system.debug(':::::currStartTime:::::'+currStartTime);
            //system.debug(':::::currEndTime:::::'+currEndTime);
            system.debug(':::::::selectedInstructor::::::'+selectedInstructor);
            
            List<Events__c> room_InsRelatedEvents = new List<Events__c>();
            List<Events__c> stu_relatedEvents = new List<Events__c>();
            
            // Get Instructor & Room related schedules
            
            if(selectedInstructor != null && selectedRoomId != null) {
               room_InsRelatedEvents = [SELECT Id,Name,Date__c, Start_Time__c,End_Time__c, Room__c, Room__r.Name,Project__r.Name,Instructor__c
                                                      FROM Events__c 
                                                      WHERE (Instructor__c = :selectedInstructor OR Room__c = :selectedRoomId) AND Schedule__c != :priorSchedule
                                                          AND Date__c >= :currentStartDate AND Date__c <= :currentEndDate AND Status__c = 'Scheduled' AND Room__r.Exclude_Conflict_Check__c = false];
            }else if(selectedInstructor != null && selectedInstructor != '') {
               room_InsRelatedEvents = [SELECT Id,Name,Date__c, Start_Time__c,End_Time__c, Room__c, Room__r.Name,Project__r.Name,Instructor__c
                                                      FROM Events__c 
                                                      WHERE Instructor__c = :selectedInstructor AND Schedule__c != :priorSchedule
                                                          AND Date__c >= :currentStartDate AND Date__c <= :currentEndDate AND Status__c = 'Scheduled' AND Room__r.Exclude_Conflict_Check__c = false];
            }else if(selectedRoomId != null) {
               room_InsRelatedEvents = [SELECT Id,Name,Date__c, Start_Time__c,End_Time__c, Room__c, Room__r.Name,Project__r.Name,Instructor__c
                                                      FROM Events__c
                                                      WHERE Room__c = :selectedRoomId AND Schedule__c != :priorSchedule
                                                          AND Date__c >= :currentStartDate AND Date__c <= :currentEndDate AND Status__c = 'Scheduled' AND Room__r.Exclude_Conflict_Check__c = false];
            }else {
                // Get current parent related schedules
                
                if(parentType == 'PROJECT') {
                    room_InsRelatedEvents = [SELECT Id,Name,Date__c, Start_Time__c,End_Time__c, Room__c, Room__r.Name,Project__r.Name,Instructor__c
                                          FROM Events__c
                                          WHERE Project__c = :parentId AND Schedule__c != :priorSchedule
                                              AND Date__c >= :currentStartDate AND Date__c <= :currentEndDate AND Status__c = 'Scheduled' AND Room__r.Exclude_Conflict_Check__c = false];
                }else if(parentType == 'OPPORTUNITY') {
                    /*ReletedSchedules = [SELECT Id,Name,Start_Date__c,End_Date__c, Start_Time__c, 
                                                                  End_Time__c, Room__c, Room__r.Name, Monday__c, Saturday__c, 
                                                                  Sunday__c, Thursday__c, Tuesday__c, Wednesday__c,Friday__c,
                                                                  Project__r.Name,Opportunity__c,Opportunity__r.Name
                                                          FROM Schedule__c 
                                                          WHERE Opportunity__c = :parentId 
                                                              AND End_Date__c >= :currentStartDate AND Start_Date__c <= :currentEndDate];*/
                }
            }
            
            system.debug(':::::::::room_InsRelatedEvents::size:::::'+room_InsRelatedEvents.size());
            
            // Get Student Related Schedules
            if(parentType == 'PROJECT') {
                
                // Qry current project related students
                for(Contact_Assignments__c stu : [SELECT Id,Name,Candidate_Name__c 
                                                    FROM Contact_Assignments__c 
                                                    WHERE Project__c = :parentId AND Candidate_Name__r.RecordType.DeveloperName = 'Student']) {
                    studentIds.add(stu.Candidate_Name__c);
                }
                
                //Qry student relted projects
                for(Contact_Assignments__c con : [SELECT Id,Project__c FROM Contact_Assignments__c 
                                                    WHERE Candidate_Name__c IN :studentIds AND Project__c != null AND Project__c != :parentId]) {
                    stu_projectIds.add(con.Project__c);
                }
                //Qry project related schedules
                if(stu_projectIds.size() > 0) {
                    stu_relatedEvents = [SELECT Id,Name,Date__c, Start_Time__c,End_Time__c, Room__c, Room__r.Name,Project__r.Name,Instructor__c
                                             FROM Events__c
                                             WHERE Project__c != :parentId  AND Project__c IN :stu_projectIds
                                             AND Date__c >= :currentStartDate AND Date__c <= :currentEndDate AND Room__r.Exclude_Conflict_Check__c = false];
                }   
                
            }else if(parentType == 'OPPORTUNITY') {
                
                // Qry current opportunity related students
                /*for(Contact_Assignments__c stu : [SELECT Id,Name,Candidate_Name__c 
                                                    FROM Contact_Assignments__c 
                                                    WHERE Opportunity_Name__c = :parentId AND Candidate_Name__r.RecordType.DeveloperName = 'Student']) {
                    studentIds.add(stu.Candidate_Name__c);
                }
                //Qry student relted Opportunities
                for(Contact_Assignments__c con : [SELECT Id,Opportunity_Name__c FROM Contact_Assignments__c WHERE Candidate_Name__c IN :studentIds AND Opportunity_Name__c != null AND Opportunity_Name__c != :parentId]) {
                    stu_oppIds.add(con.Opportunity_Name__c);
                }
                //Qry project related schedules
                if(stu_oppIds.size() > 0) {
                    stu_relatedEvents = [SELECT Id,Name,Date__c, Start_Time__c,End_Time__c, Room__c, Room__r.Name,Project__r.Name
                                             FROM Events__c
                                          WHERE Opportunity__c != :parentId  AND Opportunity__c IN :stu_oppIds
                                              AND End_Date__c >= :currentStartDate AND Start_Date__c <= :currentEndDate];
                }*/
            }
            
            system.debug('::::::stu_relatedEvents:::::size:::::'+stu_relatedEvents.size());
            
            // Holiday Conflict check
            //List<Holiday> holidayList = [SELECT Id, ActivityDate FROM Holiday WHERE ActivityDate >= :currentStartDate AND ActivityDate <= :currentEndDate];
            Set<Date> holidayDates = HolidayService.getHolidaysWithRecurrence(currentStartDate,currentEndDate);
            
            if(holidayDates.size() > 0) {
                if(!conflictType_Count.containsKey('Holiday')) {
                    conflictType_Count.put('Holiday',holidayDates.size());
                }
            }else {
                conflictType_Count.put('Holiday',0);
            }
            
            //Planned days off conflict check - 
            
            if(daysOffFromUI.size() == 0) {
            
                List<Planned_Days_Off__c> plannedDaysOff = new List<Planned_Days_Off__c>();
                List<Planned_Days_Off__c> insplannedDaysOff = new List<Planned_Days_Off__c>();
                
                Set<Id> conIds = new Set<Id>();
                // Exclude Student related Project Planned days off dates 
                //if the project have only one student on contact assignment level - for schedule & event creation  
                if(studentIds.size() > 0 && studentIds.size() == 1) {
                    conIds = studentIds;
                }
                
                // Not consider instructor related planned days off dates for schedule & event creation
                /*if(selectedInstructor != null && selectedInstructor != '')
                    conIds.add(selectedInstructor);*/
              
                //Student Planned days off  
                if(conIds.size() > 0) {
                    
                    plannedDaysOff = [SELECT Description__c, Name, Id, Date__c, Requested_Reschedule_Date__c, Contact__c 
                                        FROM Planned_Days_Off__c 
                                        WHERE Contact__c IN :conIds AND Date__c >= :currentStartDate AND Date__c <= :currentEndDate 
                                            AND RecordType.DeveloperName = 'Student_Planned_Days_Off' AND Status__c = 'Approved'
                                            AND Type__c = 'Student'];
                
                }
                
                // Instructor Planned Days Off
                if(String.isNotBlank(selectedInstructor)) {
                    insplannedDaysOff = [SELECT Description__c, Name, Id, Date__c, Requested_Reschedule_Date__c, Contact__c 
                                        FROM Planned_Days_Off__c 
                                        WHERE Contact__c = :selectedInstructor AND Date__c >= :currentStartDate AND Date__c <= :currentEndDate 
                                            AND RecordType.DeveloperName IN ('Instructor_Planned_Days_Off','Staff_Planned_Days_Off') AND Status__c = 'Approved'
                                            AND Type__c IN ('Instructor','Staff')];
                }
                
                // Qry Training Holidays for DLI-W LT Projects
                // Training Holiday planned days off does not have contact value
                Boolean applyTH_DLIOpp = false;
                
                // Applied Project specific Training Holiday Exclusion for DLI-W TO Opportunities which have project type as AFPAK / Resident LT
                
                if(parentType == 'OPPORTUNITY' && parentRT == 'DLI_W_TO_Opportunities') {
                    List<Opportunity> oppRec = [SELECT Id,Name,Project_Type__c FROM Opportunity WHERE Id = :parentId AND RecordType.DeveloperName = :parentRT];
                    
                    if(oppRec != null && oppRec.size() > 0 && 
                        (oppRec[0].Project_Type__c == 'AFPAK' || oppRec[0].Project_Type__c == 'Resident LT')) {
                        applyTH_DLIOpp = true;
                    }
                        
                }
                
                if(parentRT == 'DLI_W_LT_Projects' || applyTH_DLIOpp) {
                    List<Planned_Days_Off__c> trainingHolidayPDO = [SELECT Description__c, Name, Id, Date__c, Requested_Reschedule_Date__c 
                                                                    FROM Planned_Days_Off__c 
                                                                    WHERE Contact__c = null AND Date__c >= :currentStartDate AND Date__c <= :currentEndDate 
                                                                        AND RecordType.DeveloperName = 'Project_Planned_Days_Off' AND (Opportunity__c = :parentId OR Project__c = :parentId) 
                                                                        AND Type__c = 'DLI-W LT'];
                    
                    if(trainingHolidayPDO.size() > 0) {  
                        plannedDaysOff.addAll(trainingHolidayPDO);
                    }
                }
                
                if(plannedDaysOff.size() > 0){
                    if(!conflictType_Count.containsKey('StudentPlannedDaysOff')) {
                        conflictType_Count.put('StudentPlannedDaysOff',plannedDaysOff.size());
                    }
                }else {
                    conflictType_Count.put('StudentPlannedDaysOff',0);
                }
                
                if(insplannedDaysOff.size() > 0) {
                    if(!conflictType_Count.containsKey('InstructorPlannedDaysOff')) {
                        conflictType_Count.put('InstructorPlannedDaysOff',insplannedDaysOff.size());
                    }
                }else {
                    conflictType_Count.put('InstructorPlannedDaysOff',0);
                }
               
            }else {
                if(!conflictType_Count.containsKey('PlannedDaysOff')) {
                    conflictType_Count.put('PlannedDaysOff',daysOffFromUI.size());
                }
            }
            
            // Comparing the room / Instructor related schedule records wiht current schedules
            
            conflictType_Count.put('RoomEvent',0);
            conflictType_Count.put('InstructorEvent',0);
            conflictType_Count.put('StudentEvent',0);
            
            Set<String> daysValues = new Set<String>();
            if(currRec.Sunday__c) {
                daysValues.add('Sunday');
            }
            
            if(currRec.Monday__c) {
                daysValues.add('Monday');
            }
            
            if(currRec.Tuesday__c) {
                daysValues.add('Tuesday');
            }
            
            if(currRec.Wednesday__c) {
                daysValues.add('Wednesday');
            }
            
            if(currRec.Thursday__c) {
                daysValues.add('Thursday');
            }
            
            if(currRec.Friday__c) {
                daysValues.add('Friday');
            }
            
            if(currRec.Saturday__c) {
                daysValues.add('Saturday');
            }
            
            EventHandler eveHandle = new EventHandler();
            
            for(Events__c eve : room_InsRelatedEvents) {
              
                Integer st1,et1,st2,et2;
                    
                if(convertToMinutes(currRec.Start_Time__c) > convertToMinutes(eve.Start_Time__c)) {
                    st1 = eveHandle.convertToMinutes(eve.Start_Time__c);
                    et1 = eveHandle.convertToMinutes(eve.End_Time__c);
                    
                    st2 = eveHandle.convertToMinutes(currRec.Start_Time__c);
                    et2 = eveHandle.convertToMinutes(currRec.End_Time__c);
                    
                }else {
                    st2 = eveHandle.convertToMinutes(eve.Start_Time__c);
                    et2 = eveHandle.convertToMinutes(eve.End_Time__c);
                    
                    st2 = eveHandle.convertToMinutes(currRec.Start_Time__c);
                    et2 = eveHandle.convertToMinutes(currRec.End_Time__c);
                }
                
                if(daysValues.contains(eveHandle.getDayValue(eve.Date__c))) {
                    if(selectedRoomId != null && eve.Room__c != null && eve.Room__c == selectedRoomId) {
                        if(et2 >= et1 && st2 < et1) {
                            System.debug('::Room:::Conflict occured:::::');
                            if(!conflictType_Count.containsKey('RoomEvent')) {
                                conflictType_Count.put('RoomEvent', 0);
                            }
                            conflictType_Count.put('RoomEvent', conflictType_Count.get('RoomEvent') + 1);
                        }
                    }
                    
                    if(String.isNotBlank(selectedInstructor) && eve.Instructor__c != null && eve.Instructor__c == selectedInstructor) {
                        if(et2 >= et1 && st2 < et1) {
                            if(!conflictType_Count.containsKey('InstructorEvent')) {
                                System.debug('::instructor:::Conflict occured:::::');
                                conflictType_Count.put('InstructorEvent', 0);
                            }
                            conflictType_Count.put('InstructorEvent', conflictType_Count.get('InstructorEvent') + 1);
                        }
                    }
                }
            }
            
            // Camparing student related schedules with current schedule
            for(Events__c eve : stu_relatedEvents) {
              
                Integer st1,et1,st2,et2;
                    
                if(convertToMinutes(currRec.Start_Time__c) > convertToMinutes(eve.Start_Time__c)) {
                    st1 = eveHandle.convertToMinutes(eve.Start_Time__c);
                    et1 = eveHandle.convertToMinutes(eve.End_Time__c);
                    
                    st2 = eveHandle.convertToMinutes(currRec.Start_Time__c);
                    et2 = eveHandle.convertToMinutes(currRec.End_Time__c);
                    
                }else {
                    st2 = eveHandle.convertToMinutes(eve.Start_Time__c);
                    et2 = eveHandle.convertToMinutes(eve.End_Time__c);
                    
                    st2 = eveHandle.convertToMinutes(currRec.Start_Time__c);
                    et2 = eveHandle.convertToMinutes(currRec.End_Time__c);
                }
                
                if(daysValues.contains(eveHandle.getDayValue(eve.Date__c))) {
                    if(et2 >= et1 && st2 < et1) {
                        if(!conflictType_Count.containsKey('StudentEvent')) {
                            System.debug('::student::::Conflict occured::student:::');
                            conflictType_Count.put('StudentEvent', 0);
                        }
                        conflictType_Count.put('StudentEvent', conflictType_Count.get('StudentEvent') + 1);
                    }
                }
            }
            
            system.debug('::::::conflictType_Count::::::'+conflictType_Count);
            
            return conflictType_Count;
        }
      
      // These below methods are to call the EventDisplayComponent queries 
     // Added by Sukanya on Jan 5 2017
     
       // To get User Timezone
      @RemoteAction
      global static List<User> getUserdetails(string userId) {
           return EventDisplayComponent_Ctrl.getUserdetails(userId);
      }
      
      //To Get the Planned days off
      @RemoteAction
     global static List<Planned_Days_Off__c> getPlanneddaysOffdetails(string contactId) {
        return EventDisplayComponent_Ctrl.getPlanneddaysOffdetails(contactId);
     }
      
     // To get Contact Assignment details for Project,Project Task,Oppo
     @RemoteAction
     global static List<Contact_Assignments__c> getContactassignmentByParent(string parentId,String type) {
         if(type == 'project') {
             return EventDisplayComponent_Ctrl.getContactassignmentByProject(parentId);
         } else if(type == 'opportunity') {
             return EventDisplayComponent_Ctrl.getContactassignmentByOpportunity(parentId);
         } else if(type == 'projectTask') {
             return EventDisplayComponent_Ctrl.getContactassignmentByprojectTask(parentId);
         } else {
             return null;
         }
     }
   
    // To get Events details based on Project,Room,Opp,Instructor,Project Task
    @RemoteAction
    global static List<Events__c> getEventsByparentType(String parentId,String type,Integer monthcount1,Integer monthcount2) {
       
        if(type == 'project') {
           return EventDisplayComponent_Ctrl.getEventsByproject(parentId,monthcount1,monthcount2);
        } else if(type == 'room') {
           return EventDisplayComponent_Ctrl.getEventsByroom(parentId,monthcount1,monthcount2);
        } else if(type == 'opportunity') {
           return EventDisplayComponent_Ctrl.getEventsByopportunity(parentId,monthcount1,monthcount2);
        } else if(type == 'instructor') {
           return EventDisplayComponent_Ctrl.getEventsByInstructor(parentId,monthcount1,monthcount2);
        } else if(type == 'projectTask') {
           return EventDisplayComponent_Ctrl.getEventsByprojectTask(parentId,monthcount1,monthcount2);
        } else if(type == 'client') {
           return EventDisplayComponent_Ctrl.getEventsByclient(parentId,monthcount1,monthcount2);  
        } else if(type == 'staff') {
           return EventDisplayComponent_Ctrl.getEventsBystaff(parentId,monthcount1,monthcount2);      
        } else {
           return null;
        }
    }
    
    /**********************************************************************
    Created by Vinitha on Feb 1, 2017
    ***********************************************************************/
    @RemoteAction
     global static ProjectDomain.informationRelatedtoProject getProjectIdSet(Id projectId) {         
        
        system.debug('::::getProjectdetail::projectId:'+projectId);
        
        List<Events__c> eventliststu = new List<Events__c>();
        List<Events__c> eventliststu1 = new List<Events__c>();
        List<Events__c> eventlistins = new List<Events__c>();
        List<Events__c> eventlistins1 = new List<Events__c>();
        List<Attendance__c> attendList = new List<Attendance__c>();
        ProjectDomain.informationRelatedtoProject projectdetail = new ProjectDomain.informationRelatedtoProject();
        //Set<Id> recTypeId = new Set<Id>();
        Id userId = UserInfo.getUserId();         
        
        //Below query refferred for user object in ProjectDetailViewRouting_Component
        List<User> userList = SObjectQueryService.SObjectQuery('User',new Set<Id>{userId},'');
        
        if(userList != null && userList[0].ContactId != null) {
        
            //Below query refferred for AcctSeed__Project object in ProjectDetailViewRouting_Component
            List<AcctSeed__Project__c> acctProjectList = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',new Set<Id>{projectId},'');
            
            //Below query refferred for AcctSeed__Project_Task object in ProjectDetailViewRouting_Component
            List<AcctSeed__Project_Task__c> acctProjecttaskList = ProjectTaskService.getProjectTasksByProjIdsAndProjTaskTypes(new Set<Id>{projectId},new Set<String>{},'','');
            
            String conparentFields = 'Candidate_Name__r.Name,Candidate_Name__r.Email,Candidate_Name__r.Alias__c,Candidate_Name__r.Phone';
           
            //Below query refferred for Contact_Assignments object in ProjectDetailViewRouting_Component
            List<Contact_Assignments__c> conAssignListstaff = ContactAssignmentService.getContactassignmentByprojectId(' WHERE RecordType.DeveloperName = \'Staff\' AND Project__c ',conparentFields,new Set<Id>{projectId},'');
            
            String parentFields = 'Candidate_Name__r.Name, Candidate_Name__r.Alias__c';
            
            //Below query refferred for RecordType object in ProjectDetailViewRouting_Component
            String recTypeId;
            //List<RecordType> recTypeList = [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType = 'Contact_Assignments__c'];
            List<RecordType> recTypeList = SObjectQueryService.getRecTypeListBySobjTypeAndDevName('','Contact_Assignments__c',new Set<String>{});
            for(RecordType  rec : recTypeList){
                if(rec.DeveloperName == 'Client_Partner') {
                    recTypeId = rec.Id;   
                }            
            }
            
            //Below query referred for clientpart contact_Assignment object in ProjectDetailViewRouting_Component
            List<Contact_Assignments__c> conAssignList1 = ContactAssignmentService.getContactassignmentByprojectId(' WHERE RecordTypeId = \''+recTypeId+'\' AND Project__c ',parentFields,new Set<Id>{projectId},'');
            
            //Below query refferred for Contact object in ProjectDetailViewRouting_Component
            List<Contact> conList = ContactService.getContactByparentId(' WHERE RecordType.DeveloperName = \'Student\' AND Id ','',new Set<Id>{userList[0].ContactId});
            
            
            //Below query referred for Attendance object in ProjectDetailViewRouting_Component when attendList grater than Zero.
            //if(userList[0].ContactId != null)
            //attendList = AttendanceService.getAttendancesByparentIds(new Set<Id>{},' WHERE Contact__c = \''+userList[0].ContactId+'\' ORDER BY  Date__c DESC',',Event__r.Name,Contact__r.Name,Contact__r.Alias__c');
           
            //Below query referred for Attendance object in ProjectDetailViewRouting_Component when attendList equal to Zero.
            if(attendList.size() == 0){
                attendList = AttendanceService.getAttendancesByparentIds(new Set<Id>{},' WHERE Event__r.Project__c = \''+projectId+'\' ORDER BY  Date__c DESC',',Event__r.Name,Event__r.Project__c');
            }
            
            String timecardparentfields = ',AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c'
                                    +',AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c,'
                                    +'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c,'
                                    +'AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c';
            String timecardfiltercondition = ' WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__c = \''+projectId+'\' AND  AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c = \''+userList[0].ContactId+'\' ORDER BY AcctSeed__Date__c ASC';
            
            //Below query referred for AcctSeed__Time_Card_Day object in ProjectDetailViewRouting_Component.
            List<AcctSeed__Time_Card_Day__c> timecardList = TimeCardDayService.getDayWithParentFilterConditions(timecardfiltercondition,timecardparentfields,'',new Set<Id>{});
            
            //Below query referred for Assessment_Report object in ProjectDetailViewRouting_Component.
            List<Assessment_Report__c> assessReportList = AssessmentReportService.getAssessmentReportsByprojIds(new Set<Id>{projectId},'',',Student__r.Name, Student__r.Alias__c,Project__r.DLS_Class__c');
            
            Set<Id> contverId = new Set<Id>();
            String reqparentField = 'Project__r.DLS_Class__c,Material_Name__r.Name,Material_Name__r.Cost__c,Material_Name__r.Section__c,Material_Name__r.Last_Ordered__c';
            String filterQry = ' WHERE RecordType.DeveloperName = \'Material\' AND Project__c = \''+projectId+'\' AND Contact__c = \''+userList[0].ContactId+'\'';
            //Below query referred for Request object in ProjectDetailViewRouting_Component.
            List<Request__c> requestList = RequestService.getRequest(filterQry,reqparentField);
            for(Request__c req : requestList){
                contverId.add(req.ContentVersionId__c);    
            }
            //Below query referred for Request object in ProjectDetailViewRouting_Component.
            List<ContentVersion> converList = ContentVersionService.getContentVersionbyIds(contverId,new Set<Id>{});
            
            Set<Id> candidateNameSet = new Set<Id>();
            //Below query referred for Contact_Assignments object for recTypeDeveloperName equal to student in ProjectDetailViewRouting_Component.
            List<Contact_Assignments__c> conassListstu = ContactAssignmentService.getContactassignmentByprojectId(' WHERE RecordType.DeveloperName = \'Student\' AND Candidate_Name__c != \''+userList[0].ContactId+'\' AND Project__c ','Candidate_Name__r.Name,Candidate_Name__r.Alias__c,Candidate_Name__r.Email,Candidate_Name__r.Phone',new Set<Id>{projectId},'');
            for(Contact_Assignments__c conAss : conassListstu){
                candidateNameSet.add(conAss.Candidate_Name__c);
            }
            if(candidateNameSet != null && candidateNameSet.size() > 0){
                //Below Event object query for when status equal to cancelled this list refferred to ProjectDetailViewRouting_Component
                eventliststu = EventService.getEventByparentIds(candidateNameSet,' WHERE Instructor__c = \''+userList[0].ContactId+'\' AND Status__c = \'Canceled\' AND Project__c = \''+projectId+'\'','',' AND Cancelled_by__c');
                //Below Event object query for when status equal to latecancelled this list refferred to ProjectDetailViewRouting_Component
                eventliststu1 = EventService.getEventByparentIds(candidateNameSet,' WHERE Instructor__c = \''+userList[0].ContactId+'\' AND Status__c = \'Late Cancellation\' AND Project__c = \''+projectId+'\' ','',' AND Cancelled_by__c ');
            }
            
            Set<Id> candidateNameInsSet = new Set<Id>();
            //Below query referred for Contact_Assignments object for recTypeDeveloperName equal to instructor in ProjectDetailViewRouting_Component.
            List<Contact_Assignments__c> conassListins = ContactAssignmentService.getContactassignmentByprojectId(' WHERE RecordType.DeveloperName = \'Instructor\' AND Project__c ','Candidate_Name__r.Name,Candidate_Name__r.Alias__c,Candidate_Name__r.Email,Candidate_Name__r.Phone,Project_Task__r.Name',new Set<Id>{projectId},'');
            for(Contact_Assignments__c conas : conassListins){
                candidateNameInsSet.add(conas.Candidate_Name__c);
            }
            if(candidateNameInsSet != null && candidateNameInsSet.size() > 0){
                //Below Event object query for when status equal to cancelled this list refferred to ProjectDetailViewRouting_Component
                eventlistins = EventService.getEventByparentIds(candidateNameInsSet,' WHERE Instructor__c = \''+userList[0].ContactId+'\' AND Status__c = \'Canceled\' AND Project__c = \''+projectId+'\'','', ' AND Cancelled_by__c');
                //Below Event object query for when status equal to latecancelled this list refferred to ProjectDetailViewRouting_Component
                eventlistins1 = EventService.getEventByparentIds(candidateNameInsSet,' WHERE Instructor__c = \''+userList[0].ContactId+'\' AND Status__c = \'Late Cancellation\' AND Project__c = \''+projectId+'\'','',' AND Cancelled_by__c');
            }            
            projectdetail = ProjectTranslator.ProjectInfoMethod(acctProjectList,acctProjecttaskList,userList,conAssignListstaff,conassListins,conassListstu,conAssignList1,eventliststu,eventliststu1,eventlistins,eventlistins1,conList,requestList,converList,attendList,timecardList,assessReportList);            
        }  
        return projectdetail; 
     }
     
     /**********************************************************************
        Created by Vinitha on Feb 13, 2017: Apex controller class for this Signup_Zoom_Component
        to referred in MyProjectRouting, to Convert all force.query to Remote action on that component. 
    ***********************************************************************/

    @RemoteAction
    global static List<User> getUserRec(){
        Id userId = UserInfo.getUserId();            
        List<User> usrList = SObjectQueryService.SObjectQuery('User',new Set<Id>{userId},'');
        return usrList;        
    }
    
    /**********************************************************************
        Created by Vinitha on Feb 13, 2017: Apex controller class for this Signup_Zoom_Component
        to referred in MyProjectRouting, to Convert all force.update to Remote action on that component.                                         
    ***********************************************************************/
    @RemoteAction
    global static List<User> getUserupdate(String userJson){
        List<User> userList = (List<User>) System.JSON.deserialize(userJson, List<User>.class);
        List<User> usrList = UserService.updateUser(userList);
               
        return usrList;
    }
    
     /**********************************************************************
        Created by Vinitha on Feb 13, 2017: Apex controller class for this MyScheduleEventPage_Component
        to referred in MyProjectRouting, to Convert all force.update to Remote action on that component.                                         
    ***********************************************************************/
    @RemoteAction
    global static List<Events__c> geteventupdate(String eventJson){
        List<Events__c> eveList = (List<Events__c>) System.JSON.deserialize(eventJson, List<Events__c>.class);
        List<Events__c> eventList = EventService.updateEvents(eveList);
        return eventList;
    }
    
     /**********************************************************************
    Created by Vinitha on Feb 23, 2017: Apex controller class for this HomePageComponent,
    to Convert all force.query to Remote action on that component.                                         
    ***********************************************************************/
    global class innerclass{
        public List<Request__c> requestList;
        public List<Contact> contactList;
        public List<User> userList;
        public List<Events__c> EventList;
    }
    
    @RemoteAction
    global static innerclass getHomepagedetails(String type){
       
        Date dateToday = Date.today();
        String sMonth = String.valueof(dateToday.month());
        String sDay = String.valueof(dateToday.day());
        if(sMonth.length()==1){
          sMonth = '0' + sMonth;
        }
        if(sDay.length()==1){
          sDay = '0' + sDay;
        }
        String currentdate = String.valueof(dateToday.year()) +'-'+ sMonth +'-'+ sDay ;
        system.debug('::eventmanagementcontroller gethomepagedetails::currentdate'+currentdate);
              
       Id userId = UserInfo.getUserId();            
       List<User> usrList = SObjectQueryService.SObjectQuery('User',new Set<Id>{userId},'');
       Id conId = usrList[0].ContactId;
       List<Contact> conlist = SObjectQueryService.SObjectQuery('Contact',new Set<Id>{conId},'');
        
       List<Request__c> reqList = SObjectQueryService.SObjectQuery('Request__c',new Set<Id>{conId},''); 
       
       String parentField = ',Room__r.Name,Project__r.DLS_Class__c,Project__r.AcctSeed__Status__c,Schedule__r.Project_Task__c,Schedule__r.Project_Task__r.Name';
       //List<Events__c> evelist = [SELECT Id,Name,Instructor__c,End_Time__c,Date__c,Room__c,Room__r.Name,Project__r.DLS_Class__c,Start_Time__c,Status__c,Duration__c,Event_Agenda__c,Project__c,Project__r.AcctSeed__Status__c,Schedule__c,Schedule__r.Project_Task__c,Schedule__r.Project_Task__r.Name,Meeting_URL__c,Timezone__c FROM Events__c WHERE ( Project__r.AcctSeed__Status__c = 'Active' OR Project__r.AcctSeed__Status__c = 'Order') AND Instructor__c = :conId AND Date__c >= :currentDate AND Status__c = 'Scheduled' ORDER BY Date__c ASC LIMIT 5]; 
       List<Events__c> evelist = new List<Events__c>();
       Set<Id> activeProjectIds = new Set<Id>();
       if(conId != null) {
           if(usrList[0].Instructor_Access__c && type == 'INSTRUCTOR') {
               evelist = EventService.getEventByparentIds(new Set<Id>{},' WHERE ( Project__r.AcctSeed__Status__c = \'Active\' OR Project__r.AcctSeed__Status__c = \'Order\') AND Instructor__c = \''+conId+'\' AND Date__c >= '+currentDate+' AND Status__c = \'Scheduled\' ORDER BY Date__c ASC LIMIT 5',parentField,'');
           } else if (usrList[0].Staff_Access__c && type == 'STAFF') {
               String parentFields = 'Project__r.DLS_Class__c,Project__r.AcctSeed__Status__c,Candidate_Name__r.Name,Project__r.Name,Project__r.Start_Date__c,Project__r.End_Date__c ';
               List<Contact_Assignments__c> conassignList = ContactAssignmentService.getContactassignmentByprojectId(' WHERE Project__c != null AND RecordType.DeveloperName = \'Staff\' AND Candidate_Name__c ',parentFields,new Set<Id>{usrList[0].ContactId},''); 
               for(Contact_Assignments__c ca :  conassignList) {
                    if(ca.Project__r.AcctSeed__Status__c == 'Active' || ca.Project__r.AcctSeed__Status__c == 'Order') {
                        activeProjectIds.add(ca.Project__c);
    
                    }
                }
               
               if(activeProjectIds.size() > 0){
                   evelist = EventService.getEventByparentIdsAndFilters(activeProjectIds,' WHERE Project__c',parentField,' AND Instructor__c = \''+conId+'\' AND Date__c >= '+currentDate+' AND Status__c = \'Scheduled\' ORDER BY Date__c ASC LIMIT 5');
               } else {
                   evelist = EventService.getEventByparentIdsAndFilters(new Set<Id>(),'',parentField,' WHERE Instructor__c = \''+conId+'\' AND Date__c >= '+currentDate+' AND Status__c = \'Scheduled\' ORDER BY Date__c ASC LIMIT 5');
               }
           }
       }
       innerclass inr = new innerclass();
       inr.requestList = reqList;
       inr.contactList = conlist;
       inr.userList = usrList;
       inr.EventList = evelist;
       system.debug(':::eventmanagementcontroller gethomepagedetails evelist'+evelist);
       system.debug(':::eventmanagementcontroller gethomepagedetails inr'+inr);
       
       return inr;
    }
    
    @RemoteAction
    global static List<Contact> getContactRec(){
        
        Id userId = UserInfo.getUserId();            
        List<User> usrList = SObjectQueryService.SObjectQuery('User',new Set<Id>{userId},'');
        Id conId = usrList[0].ContactId;
        List<Contact> conList = SObjectQueryService.SObjectQuery('Contact',new Set<Id>{conId},'');
       
        return conList;
    }
    
    @RemoteAction
    global static List<sObject> getLookupRecords(String objectName, String searchString, String condition) {
        return TimeKeeping_Admin_Controller.getLookupRecords(objectName,searchString,condition);
    }
    
    @RemoteAction
    global static Map<Id,Integer> getRoomConflictDetails(String scheduleId) {
        
        system.debug(':::::::::scheduleId:::::'+scheduleId);
    
        Map<Id, Integer> roomConflictMap = new Map<Id, Integer>();
        List<Schedule__c> schRec = new List<Schedule__c>();
        List<Events__c> roomEvents = new List<Events__c>();
        Set<Id> roomIds = new Set<Id>();
        
        // Qry all room records for schedule conflict check
        for(Room__c room : [SELECT Id,Name FROM Room__c]){
            roomIds.add(room.Id);
        }
        
        system.debug(':::::::::roomIds::::::'+roomIds);
        
        schRec = [SELECT Id,Name,Start_Date__c,End_Date__c, Start_Time__c, End_Time__c, Room__c, Room__r.Name, 
                        Monday__c, Saturday__c, Sunday__c, Thursday__c, Tuesday__c, Wednesday__c,Friday__c,Project__r.Name 
                    FROM Schedule__c 
                    WHERE Id = :scheduleId AND (Room__c = null OR (Room__c != null AND Room__r.Name != 'Zoom'))];
                    
        Date startDate = Date.valueOf(schRec[0].Start_Date__c);
        Date endDate = Date.valueOf(schRec[0].End_Date__c);
        Integer startTime = EventManagementController.convertToMinutes(schRec[0].Start_Time__c);
        Integer endTime = EventManagementController.convertToMinutes(schRec[0].End_Time__c);
        
        
        roomEvents = [SELECT Id, Name, Date__c, Start_Time__c, End_Time__c, Room__c,Room__r.Name, Status__c 
                        FROM Events__c 
                        WHERE Date__c >= :startDate AND Date__c <= :endDate AND Room__r.Name != 'Zoom' 
                        AND Schedule__c != :scheduleId AND Room__c IN :roomIds AND Status__c = 'Scheduled' 
                        AND Project__r.AcctSeed__Status__c IN ('Active','Order')];
        
        system.debug('::::roomEvents::size::'+roomEvents.size());
        
        Set<String> daysValues = new Set<String>();
        if(schRec[0].Sunday__c) {
            daysValues.add('Sunday');
        }
        
        if(schRec[0].Monday__c) {
            daysValues.add('Monday');
        }
        
        if(schRec[0].Tuesday__c) {
            daysValues.add('Tuesday');
        }
        
        if(schRec[0].Wednesday__c) {
            daysValues.add('Wednesday');
        }
        
        if(schRec[0].Thursday__c) {
            daysValues.add('Thursday');
        }
        
        if(schRec[0].Friday__c) {
            daysValues.add('Friday');
        }
               
        if(schRec[0].Saturday__c) {
            daysValues.add('Saturday');
        }
        
        EventHandler eveHandle = new EventHandler();
               
        for(Events__c eve : roomEvents) {
            if(eve.Room__c != null) {
                if(eve.Start_Time__c == null || eve.End_Time__c == null) {
                    continue;
                }
                
                Integer eveStartTime = EventManagementController.convertToMinutes(eve.Start_Time__c);
                Integer eveEndTime = EventManagementController.convertToMinutes(eve.End_Time__c);
                
                if(daysValues.contains(eveHandle.getDayValue(eve.Date__c))) {
                    if(eveEndTime >= startTime && eveStartTime <= endTime) {
                        if(!roomConflictMap.containsKey(eve.Room__c)) {
                            System.debug('Conflict ' + eve.Room__r.Name);
                            roomConflictMap.put(eve.Room__c, 0);
                        }
                        roomConflictMap.put(eve.Room__c, roomConflictMap.get(eve.Room__c) + 1);
                    }
                }
            }
        }
        system.debug('***roomConflictMap****'+roomConflictMap);
        return roomConflictMap;
    }
    
    // To check whether the logged in user has the permission to Edit/Assign the Room
    @RemoteAction
    global static Boolean checkForRoomEditCP() {
        return FeatureManagement.checkPermission('Permission_to_Edit_Rooms');
    }
    
    // To store the prior schedule of the schedule where the schedule type is 'Replace Instructor', 'Schedule Change', 'Room Change' and 'Substitute'
    public static Set<Id> parentIds; 
    
    @RemoteAction
    global static Map<String,String> createScheduleForChange(String Schedule, String schType, String rateType, List<String> eventDates) {
        System.debug('Schedule::::::'+Schedule);
        List<Schedule__c> schList = new List<Schedule__c>();
        Schedule__c sch = (Schedule__c) System.JSON.deserialize(Schedule, Schedule__c.class);
        System.debug('eventDates::::'+eventDates);
        Map<String,String> result = new Map<String,String>();
        String returnStr ='';
        parentIds = new Set<Id>();
        
        if(schType != 'Substitute') {
            parentIds.add(sch.Id);
            schList.add(new Schedule__c(Id = sch.Id));
            if(schType == 'Schedule Change' || schType == 'Replace Instructor' || schType == 'Room Change') {
                Date tempDate = sch.Start_Date__c.addDays(-1);
                Datetime dt = DateTime.newInstance(tempDate, Time.newInstance(0, 0, 0, 0));
                // To check the End date is not in a working Day.
                while(dt.format('EEEE') == 'Saturday' || dt.format('EEEE') == 'Sunday') {
                    tempDate = tempDate.addDays(-1);
                    dt = DateTime.newInstance(tempDate, Time.newInstance(0, 0, 0, 0));
                }
                schList[0].End_Date__c = tempDate;
                if(schList[0].End_Date__c < System.Today()){
                    schList[0].Status__c = 'Completed';
                }
                
                ScheduleTriggerHandler.isFromScheduleComponent = true;
            }
            System.debug('schList:::::'+schList);
        }
        
        sch.Id = null; // To insert a new Schedule
         
        schList.add(sch);
        System.debug('schType:::::'+schType);
        System.debug('schList:::::'+schList);
        upsert schList;
        Id parentId;
        if(sch.Project__c != null) {
            parentId = sch.Project__c;
        } else {
            parentId = sch.Opportunity__c;
        }
        
        //Call the Event creation method with newly created Sustitute Schedule Id & eventdates
        // Added by NS on OCT 1 2018
        if(schType == 'Substitute' && schList.size() == 1 && schList[0].Schedule_Type__c == 'Substitute') {
            parentIds.add(sch.Id);
            Set<Date> eventDts = new Set<Date>();
            for(String str : eventDates){
                eventDts.add(Date.valueOf(str));
            }
            system.debug(':::::::::eventDts::::::'+eventDts);
            EventHandler eveHandler = new EventHandler();
            eveHandler.createSubstitueScheduleEvts(new Map<Id,Set<Date>>{schList[0].Id => eventDts});
        }
        
        returnStr = 'Schedule has been created succesfully';
        if(sch.Instructor__c != null) {
            List<Contact> conList = ContactService.getContactByparentId(' WHERE Id ', 'RecordType.DeveloperName', new Set<Id>{sch.Instructor__c});
            List<Contact_Assignments__c> contactList = ContactAssignmentService.getContactassignmentRec(' WHERE RecordType.DeveloperName = \'Instructor\' AND Candidate_Name__c = \''+sch.Instructor__c+'\' AND (Project__c = \''+parentId +'\' OR Opportunity_Name__c = \''+parentId +'\')','');
            List<AcctSeed__Cost_Rates__c> crList = new List<AcctSeed__Cost_Rates__c>();
            // To assign "FT Salary & Benefits" Cost Rate for DLS Employees
            if(conList != null && conList.size() >0 && conList[0].RecordType.DeveloperName == 'DLS_Employee') {
                rateType = 'FT Salary & Benefits';
            }
            if(String.isNotBlank(rateType)) {
                crList = CostRateService.getCRByParentId(' WHERE Status__c IN (\'Approved\') AND Rate_Type__c =\'' +rateType+ '\' AND Contact__c', '', new Set<Id>{sch.Instructor__c});
            }
            if(contactList.size() == 0) {
                Contact_Assignments__c newInstructor = new Contact_Assignments__c();
                newInstructor.Candidate_Name__c = sch.Instructor__c;
                if(schType == 'Substitute') {
                    newInstructor.Assignment_Position__c = 'Substitute Instructor';
                } else if(schType == 'Replace Instructor') {
                    newInstructor.Assignment_Position__c = 'Instructor'; 
                }
                newInstructor.Status__c = 'Active';
                newInstructor.Start_Date__c = sch.Start_Date__c;
                newInstructor.End_Date__c = sch.End_Date__c;
                if(sch.Project__c != null) {
                    newInstructor.Project__c = sch.Project__c;
                    newInstructor.Project_Task__c = sch.Project_Task__c;
                    if(crList != null && crList.size() > 0 ) {
                        newInstructor.Rate_Card_Rate__c = crList[0].Id;
                        returnStr = 'Schedule has been created succesfully and a Contact Assignment has been created and mapped to the Schedule.';
                    } else {
                        returnStr = 'Schedule has been created succesfully and a Contact Assignment has been created and mapped to the Schedule. Please create Cost Rate record and assign to the Instructor ' + (conList != null && conList.size() > 0 ? conList[0].Name : '');
                    }
                } else
                    newInstructor.Opportunity_Name__c = sch.Opportunity__c;
                
                newInstructor.RecordTypeId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByName().get('Instructor').getRecordTypeId();
                insert newInstructor;
            }
        }
        result.put('Message', returnStr);
        result.put('Id', sch.Id);
        system.debug('result:::'+result);
        return result;
    }
    /****************************************************************
    To create Events for the newly selected events for an existing Substitute Events
    ****************************************************************/
    @RemoteAction
    global Static Map<String,String> createEventsForSubstituteSchEdit(String schedule,List<String> newEventDates) {
        Schedule__c sch = (Schedule__c) System.JSON.deserialize(schedule, Schedule__c.class);
        Map<String,String> result = new Map<String,String>();
        String returnStr = 'Schedule has been updated succesfully and New events are created';
        system.debug('sch ::::'+sch);
        if(sch != null) {
            
            Set<Date> eventDts = new Set<Date>();
            for(String str : newEventDates){
                eventDts.add(Date.valueOf(str));
            }
            system.debug(':::::::::eventDts::::::'+eventDts);
            EventHandler eveHandler = new EventHandler();
            eveHandler.createSubstitueScheduleEvts(new Map<Id,Set<Date>>{sch.Id => eventDts});
            
            result.put('Message', returnStr);
            result.put('Id', sch.Id);
        } else {
            result.put('Message', 'No Substitute Schedule Record');
        }
        
        system.debug('result:::'+result);
        return result;
    }
    
    @RemoteAction
    global Static Map<String,List<Date>> getEventsForSch(String scheduleId, String sDate, String eDate, List<String> status) {
        //Schedule__c sch = (Schedule__c) System.JSON.deserialize(Schedule, Schedule__c.class);
        System.debug(sDate+'::::'+eDate);
        System.debug('status::::'+status);
        System.debug('ScheduleId:::::'+ScheduleId);
        Map<String, List<Date>> statusWithDates = new Map<String, List<Date>>();
        List<Events__c> events = EventService.getEventsBySchIdAndDateRange(new Set<Id>{scheduleId}, sDate, eDate ,'', status); //Date.newInstance(sD.year(),sD.month(),sD.day()), Date.newInstance(eD.year(),eD.month(),eD.day())
        for(Events__c e : events) {
            if(!statusWithDates.containskey(e.Status__c)) {
                statusWithDates.put(e.Status__c, new List<Date>{e.Date__c});
            }
            statusWithDates.get(e.Status__c).add(e.Date__c);
        }
        return statusWithDates;
    }
}