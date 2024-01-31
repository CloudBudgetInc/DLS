// Created on 25 March 2016
// Created by Melbin
global class PlanedDaysController {
    
    //To Retrieve all the Planned_Days_Off__c records.
    @RemoteAction
    global static List<Planned_Days_Off__c> getPlannedOffs(Id contactId) {
        return [SELECT Date__c, Description__c, Requested_Reschedule_Date__c FROM Planned_Days_Off__c WHERE Contact__c = :contactId];
    }
    //To Storave the edited records
    @RemoteAction
    global static String saveModifiedPlannedOffs(String saveListJson, String removeListJson, Id ContactId) {
        Date minDate;
        Date maxDate;
        List<Case> caseList = new List<Case>();
        List<Planned_Days_Off__c> savePlannedOffsList = (List<Planned_Days_Off__c>) System.JSON.deserialize(saveListJson, List<Planned_Days_Off__c>.class);
        
        List<Planned_Days_Off__c> updateOffList = new List<Planned_Days_Off__c>();
        List<Planned_Days_Off__c> insertOffList = new List<Planned_Days_Off__c>();
        
        Set<Date> dateSet = new Set<Date>();
        for(Planned_Days_Off__c off : savePlannedOffsList) {
            dateSet.add(off.Date__c);
            dateSet.add(off.Requested_Reschedule_Date__c);
        }
        List<Events__c> eventList = getEventsOfContact(contactId, dateSet);
        
        for(Planned_Days_Off__c off : savePlannedOffsList) {
            Boolean flag = true;
            for(Events__c ev : eventList) {
               if(ev.Date__c == off.Date__c || ev.Date__c == off.Requested_Reschedule_Date__c) {
                   caseList.add(new Case(Status = 'New', Subject = 'Event Planned Off Request', ContactId = contactId, Description = 'Planned Off Date: ' + off.Date__c + 'Reschedule Request Date: ' + off.Requested_Reschedule_Date__c));
                   flag = false;
                   break;
               }
            }
            
            if(flag) {
                if(off.Id == null)
                    insertOffList.add(off);
                else
                    updateOffList.add(off);
            }
        }
        //Deserialize the string to removable record list.
        Set<Id> removePlannedOffsList = (Set<Id>) System.JSON.deserialize(removeListJson, Set<Id>.class);
        
        System.debug('insertOffList' + insertOffList);
        System.debug('updateOffList' + updateOffList);
        System.debug('caseList' + caseList);
        System.debug('removePlannedOffsList' + removePlannedOffsList);
        
        //Upsert the records
        if(insertOffList.size() > 0) insert insertOffList;
        if(updateOffList.size() > 0) update updateOffList;
        if(caseList.size() > 0) insert caseList;
        if(removePlannedOffsList.size() > 0) delete [SELECT Id FROM Planned_Days_Off__c WHERE Id IN :removePlannedOffsList];
        String returnString = 'There are ' + insertOffList.size() + ' records inserted, ' + updateOffList.size() + ' records updated, ' + removePlannedOffsList.size() + ' records deleted and ' + caseList.size() + ' cases created.';
        return returnString;
    }
    //Get the count of the events of an contact on particular day.
    @RemoteAction
    global static Integer getEventsCount(Long dateLong, Id contactId) {
        //Convert Long date To Date Object.
        Date day = DateTime.newInstance(dateLong).date();
        //getEventCountOn returns the count of events ofa day of an contct.
        return EventManagementController.getEventCountOn(day, contactId);
    }
    //getEventsListOn
    @RemoteAction
    global static List<Events__c> getEventsOn(Long dateLong, Id contactId) {
        //Convert Long Date to Date Object.
        Date day = DateTime.newInstance(dateLong).date();
        //getEventsListOn() return the Evetns on a day of a contact.
        return EventManagementController.getEventsListOn(day, contactId);
    }
    
    public static List<Events__c> getEventsOfContact(Id contactId, Set<Date> dateSet) {
        List<Contact_Assignments__c> contactAssignmnetsList;
        if(contactId != null)
            contactAssignmnetsList = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId];
        Set<Id> projectIdSet = new Set<Id>();
        System.debug('contactAssignmnetsList' + contactAssignmnetsList);
        if(contactAssignmnetsList != null)
            for(Contact_Assignments__c assignment : contactAssignmnetsList)
                projectIdSet.add(assignment.Project__c);
        System.debug('projectIdSet' + projectIdSet);
        List<Events__c> eventList;
        return eventList = [SELECT Id, Name, Start_Time__c, End_Time__c, Schedule__r.DLS_Ref__c, Date__c FROM Events__c WHERE Project__c IN :projectIdSet AND Status__c = 'Scheduled' AND Date__c IN :dateSet];
    }

    //public static void getPlannedDaysOff(Id contactId) {
    //    List<Planned_Days_Off__c> plannedOffList = [SELECT Date__c, Id, Requested_Reschedule_Date__c, Description__c FROM Planned_Days_Off__c WHERE Contact__c = :contactId];
    //    Set<Id> palnnedOffIdSet = new Set<Id>();
    //    for(Planned_Days_Off__c plannedOff : plannedOffList) {
    //        palnnedOffIdSet.add(plannedOff.Id);
    //    }
    //    
    //    List<Contact_Assignments__c> contactAssignmnetsList;
    //    if(contactId != null)
    //        contactAssignmnetsList = [SELECT Id, Name, Candidate_Name__c, Candidate_Name__r.Name, Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId];
    //    Set<Id> projectIdSet = new Set<Id>();
    //    System.debug('contactAssignmnetsList' + contactAssignmnetsList);
    //    if(contactAssignmnetsList != null)
    //        for(Contact_Assignments__c assignment : contactAssignmnetsList)
    //            projectIdSet.add(assignment.Project__c);
    //    System.debug('projectIdSet' + projectIdSet);
    //    List<Events__c> eventList;
    //    eventList = [SELECT Id, Name, Start_Time__c, End_Time__c, Schedule__r.DLS_Ref__c FROM Events__c WHERE Project__c IN :projectIdSet AND Status__c = 'Scheduled'];
    //    
    //    List<PlannedOff> processedOffs = new List<PlannedOff>();
    //    for(Planned_Days_Off__c plannedOff : plannedOffList) {
    //        PlannedOff off = new PlannedOff();
    //        off.description = plannedOff.Description__c;
    //        off.offDay = plannedOff.Date__c;
    //        off.rescheduleDate = plannedOff.Requested_Reschedule_Date__c;
    //        off.currentDayEvents = new List<Events__c>();
    //        off.rescheduleDayEvent = new List<Events__c>();
    //        for(Events__c ev : eventList) {
    //            
    //        }
    //    }
    //}
    
    class PlannedOff {
        public Planned_Days_Off__c record;
        public String description;
        public Date offDay;
        public Date rescheduleDate;
        public Date newOffDay;
        public Date newRescheduleDate;
        public List<Events__c> curentDayEvents;
        public List<Events__c> rescheduleDayEvent;
        public Boolean isNew;
        public String status;
        public Boolean hasCase;
    }
    
}