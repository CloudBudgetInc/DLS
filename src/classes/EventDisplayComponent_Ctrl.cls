//This class created to remove the queries in page controller
// Created by Sukanya on January 5 2017
global without sharing class EventDisplayComponent_Ctrl {

    
    //To Get the holidays
   /* public static List<Holiday> getHolidaysdetails() {
       return [SELECT Id,Name, ActivityDate FROM Holiday];
    }*/
   
    //To Get the Planned days off
    public static List<Planned_Days_Off__c> getPlanneddaysOffdetails(string contactId) {
       //return [SELECT Name, Id, Date__c, Description__c, Contact__c FROM Planned_Days_Off__c WHERE Contact__c = :contactId];
       // return plannedDaysoffService.getPlanneddaysBycontact(new Set<Id>{contactId});
        return PlannedDaysOffService.getPlanneddaysBycontact(' WHERE',new Set<Id>{contactId},new Set<Date>{},'',false,'');
    }
    
    // To get User Timezone
    public static List<User> getUserdetails(string userId) {
       
       //return [SELECT Id, Name, Contact.RecordType.DeveloperName, ContactId, Contact.Name, Instructor_Access__c, Student_Access__c, Partner_Access__c, Client_Access__c,TimeZoneSidKey FROM User WHERE Id = :userId];
       return SObjectQueryService.SObjectQuery('User',new Set<Id>{userId},',Contact.RecordType.DeveloperName,Contact.Name');
    }
    
    // To get Contact Assignment details for Project
    public static List<Contact_Assignments__c> getContactassignmentByProject(string parentId) {
       return [SELECT Candidate_Name__c, Candidate_Name__r.Name FROM Contact_Assignments__c WHERE Project__c = :parentId AND (RecordType.DeveloperName = 'Student' OR RecordType.DeveloperName = 'Instructor')];
    }
    
    // To get Contact Assignment details for Opportunity
    public static List<Contact_Assignments__c> getContactassignmentByOpportunity(string parentId) {
       return [SELECT Candidate_Name__c, Candidate_Name__r.Name FROM Contact_Assignments__c WHERE Opportunity_Name__c = :parentId AND (RecordType.DeveloperName = 'Student' OR RecordType.DeveloperName = 'Instructor')];
    }
    
    //To get Contact Assignment details for Project Task
    public static List<Contact_Assignments__c> getContactassignmentByprojectTask(string parentId) {
       return [SELECT Candidate_Name__c, Candidate_Name__r.Name FROM Contact_Assignments__c WHERE Project__c IN (SELECT AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE Id = :parentId) AND Candidate_Name__c != null];
    }
    
    // To get Events details based on Project
    public static List<Events__c> getEventsByproject(string parentId,Integer monthcount1,Integer monthcount2) {
        if(monthcount1 > 0 && monthcount2 == 0) {
           return Database.query('SELECT Name, Timezone__c, Date__c, Start_Time__c, End_Time__c, Project__c, Status__c, Schedule__c, Schedule__r.Name, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name, Schedule__r.DLS_Ref__c, Duration__c, Meeting_URL__c, Event_Agenda__c FROM Events__c  WHERE Project__c = \''+parentId+'\' AND Date__C >= LAST_N_MONTHS:'+monthcount1+' AND Status__c != \'Rescheduled\'');
        } else if(monthcount1 > 0 && monthcount2 > 0) {
           return Database.query('SELECT Name, Timezone__c, Date__c, Start_Time__c, End_Time__c, Project__c, Schedule__c, Schedule__r.Name, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name, Schedule__r.DLS_Ref__c, Duration__c, Status__c, Schedule__r.Project_Task__c, Schedule__r.Project_Task__r.Name, Meeting_URL__c, Event_Agenda__c FROM Events__c  WHERE Project__c = \''+parentId+'\' AND Date__c >= LAST_N_MONTHS:' + monthcount2 + ' AND Date__c < LAST_N_MONTHS:' + monthcount1 + ' AND Status__c != \'Rescheduled\'');
        }
        return null;
    }
    
    // To get Events details based on Room
    public static List<Events__c> getEventsByroom(string parentId,Integer monthcount1,Integer monthcount2) {
        if(monthcount1 > 0 && monthcount2 == 0) {
           return Database.query('SELECT Name, Timezone__c, Date__c, Start_Time__c, End_Time__c, Project__c, Status__c, Schedule__c, Schedule__r.Name, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name, Schedule__r.DLS_Ref__c, Duration__c, Meeting_URL__c, Event_Agenda__c FROM Events__c  WHERE Room__c = \''+parentId+'\' AND Date__C >= LAST_N_MONTHS:'+monthcount1+' AND Status__c != \'Rescheduled\'');
        }else if(monthcount1 > 0 && monthcount2 > 0){
           return Database.query('SELECT Name, Timezone__c, Date__c, Start_Time__c, End_Time__c, Project__c, Schedule__c, Schedule__r.Name, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name, Schedule__r.DLS_Ref__c, Duration__c, Status__c, Schedule__r.Project_Task__c, Schedule__r.Project_Task__r.Name, Meeting_URL__c, Event_Agenda__c FROM Events__c WHERE Room__c = \''+parentId+'\' AND Date__c >= LAST_N_MONTHS:' + monthcount2 + ' AND Date__c < LAST_N_MONTHS:' + monthcount1 + ' AND Status__c != \'Rescheduled\'');
        }
        return null;
    }
    
    // To get Events details based on Opportunity
    public static List<Events__c> getEventsByopportunity(string parentId,Integer monthcount1,Integer monthcount2) {
        if(monthcount1 > 0 && monthcount2 == 0) {
           return Database.query('SELECT Name, Timezone__c, Date__c, Start_Time__c, End_Time__c, Project__c, Status__c, Schedule__c, Schedule__r.Name, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name, Schedule__r.DLS_Ref__c, Duration__c, Meeting_URL__c, Event_Agenda__c FROM Events__c  WHERE Schedule__r.Opportunity__c = \''+parentId+'\' AND Date__C >= LAST_N_MONTHS:'+monthcount1+' AND Status__c != \'Rescheduled\'');
        } else if(monthcount1 > 0 && monthcount2 > 0) {
           return Database.query('SELECT Name, Timezone__c, Date__c, Start_Time__c, End_Time__c, Project__c, Schedule__c, Schedule__r.Name, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name, Schedule__r.DLS_Ref__c, Duration__c, Status__c, Schedule__r.Project_Task__c, Schedule__r.Project_Task__r.Name, Meeting_URL__c, Event_Agenda__c FROM Events__c  WHERE Schedule__r.Opportunity__c = \''+parentId+'\' AND Date__c >= LAST_N_MONTHS:' + monthcount2 + ' AND Date__c < LAST_N_MONTHS:' + monthcount1 + ' AND Status__c != \'Rescheduled\'');
        } 
        return null;
    }
    
    // To get Events details based on Instructor
    public static List<Events__c> getEventsByInstructor(string parentId,Integer monthcount1,Integer monthcount2) {
        if(monthcount1 > 0 && monthcount2 == 0){
           return Database.query('SELECT Name, Timezone__c, Date__c, Start_Time__c, End_Time__c, Project__c, Status__c, Schedule__c, Schedule__r.Name, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name, Schedule__r.DLS_Ref__c, Duration__c, Meeting_URL__c, Event_Agenda__c FROM Events__c  WHERE Instructor__c = \''+parentId+'\' AND Date__C >= LAST_N_MONTHS:'+monthcount1+' AND Status__c != \'Rescheduled\'');
        } else if(monthcount1 > 0 && monthcount2 > 0) {
           return Database.query('SELECT Name, Timezone__c, Date__c, Start_Time__c, End_Time__c, Project__c, Schedule__c, Schedule__r.Name, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name, Schedule__r.DLS_Ref__c, Duration__c, Status__c, Schedule__r.Project_Task__c, Schedule__r.Project_Task__r.Name, Meeting_URL__c, Event_Agenda__c FROM Events__c  WHERE Instructor__c = \''+parentId+'\' AND Date__c >= LAST_N_MONTHS:' + monthcount2 + ' AND Date__c < LAST_N_MONTHS:' + monthcount1 + ' AND Status__c != \'Rescheduled\'');
        }
        return null;
    }
    
    // To get Events details based on Instructor
    public static List<Events__c> getEventsByprojectTask(string parentId,Integer monthcount1,Integer monthcount2) {
        if(monthcount1 > 0 && monthcount2 == 0) {
           return Database.query('SELECT Name, Timezone__c, Date__c, Start_Time__c, End_Time__c, Project__c, Status__c, Schedule__c, Schedule__r.Name, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name, Schedule__r.DLS_Ref__c, Duration__c, Meeting_URL__c, Event_Agenda__c FROM Events__c  WHERE Schedule__r.Project_Task__c = \''+parentId+'\' AND Date__C >= LAST_N_MONTHS:'+monthcount1+' AND Status__c != \'Rescheduled\'');
        } else if(monthcount1 > 0 && monthcount2 > 0) {
           return Database.query('SELECT Name, Timezone__c, Date__c, Start_Time__c, End_Time__c, Project__c, Schedule__c, Schedule__r.Name, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name, Schedule__r.DLS_Ref__c, Duration__c, Status__c, Schedule__r.Project_Task__c, Schedule__r.Project_Task__r.Name, Meeting_URL__c, Event_Agenda__c FROM Events__c  WHERE Schedule__r.Project_Task__c = \''+parentId+'\' AND Date__c >= LAST_N_MONTHS:' + monthcount2 + ' AND Date__c < LAST_N_MONTHS:' + monthcount1 + ' AND Status__c != \'Rescheduled\'');
        }
        return null;
    }
    
     // To get Events details based on ContactAssignment
    public static List<Events__c> getEventsByclient(string parentId,Integer monthcount1,Integer monthcount2) {
        
        Set<Id> projectIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        
        for(Contact_Assignments__c conAss: [SELECT Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :parentId AND RecordType.DeveloperName = 'Client_Partner']) {
            if(conAss.Project__c != null)
                projectIds.add(conAss.Project__c);
        }
        
        for(Contact_Assignments__c conAss : [SELECT Opportunity_Name__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :parentId AND RecordType.DeveloperName = 'Client_Partner']) {
            if(conAss.Opportunity_Name__c != null)
                oppIds.add(conAss.Opportunity_Name__c);
        }
        
        if(monthcount1 > 0 && monthcount2 == 0) {
           return Database.query('SELECT Name, Date__c, Event_Agenda__c, Start_Time__c, End_Time__c, Project__c, Schedule__c, Schedule__r.Name, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name, Schedule__r.DLS_Ref__c, Duration__c, Status__c, Meeting_URL__c, Timezone__c FROM Events__c' 
                    + ' WHERE (Project__c IN :projectIds OR Schedule__r.Opportunity__c IN :oppIds)'
                    + ' AND Date__C >= LAST_N_MONTHS:'+ monthcount1 +' AND Status__c != \'Rescheduled\'');
        } else if(monthcount1 > 0 && monthcount2 > 0) {
           String qry = 'SELECT Name, Date__c, Event_Agenda__c, Start_Time__c, End_Time__c, Project__c, Schedule__c, Schedule__r.Name, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name, Schedule__r.DLS_Ref__c, Duration__c, Status__c, Meeting_URL__c, Timezone__c FROM Events__c' 
                    + ' WHERE (Project__c IN :projectIds OR Schedule__r.Opportunity__c IN :oppIds)'
                    + ' AND Date__c >= LAST_N_MONTHS:' + monthcount2 + ' AND Date__c < LAST_N_MONTHS:' + monthcount1 + ' AND Status__c != \'Rescheduled\'';
           system.debug(':::getEventsByclient:::::::qry::::::::::::'+qry);
           return Database.query(qry);
        }
        return null;
    }
    
     // To get Events details based on ContactAssignment
    public static List<Events__c> getEventsBystaff(string parentId,Integer monthcount1,Integer monthcount2) {
        
        Set<Id> projectIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        
        for(Contact_Assignments__c conAss: [SELECT Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :parentId AND RecordType.DeveloperName = 'Staff']) {
            if(conAss.Project__c != null)
                projectIds.add(conAss.Project__c);
        }
        
        for(Contact_Assignments__c conAss : [SELECT Opportunity_Name__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :parentId AND RecordType.DeveloperName = 'Staff']) {
            if(conAss.Opportunity_Name__c != null)
                oppIds.add(conAss.Opportunity_Name__c);
        }
        
        if(monthcount1 > 0 && monthcount2 == 0) {
           return Database.query('SELECT Name, Date__c, Event_Agenda__c, Start_Time__c, End_Time__c, Project__c, Schedule__c, Schedule__r.Name, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__r.Name, Schedule__r.Opportunity__c, Schedule__r.Project_Task__r.Name, Schedule__r.Opportunity__r.Name, Schedule__r.DLS_Ref__c, Duration__c, Status__c, Meeting_URL__c, Timezone__c FROM Events__c' 
                    + ' WHERE (Project__c IN :projectIds OR Schedule__r.Opportunity__c IN :oppIds)'
                    + ' AND Date__C >= LAST_N_MONTHS:'+ monthcount1 +' AND Status__c != \'Rescheduled\'');
      
        } else if(monthcount1 > 0 && monthcount2 > 0) {
           return Database.query('SELECT Name, Date__c, Event_Agenda__c, Start_Time__c, End_Time__c, Project__c, Schedule__c, Schedule__r.Name, Instructor__c, Instructor__r.Name, Room__c, Room__r.Name, Project__r.Name, Schedule__r.Project_Task__r.Name, Schedule__r.Opportunity__c, Schedule__r.Opportunity__r.Name, Schedule__r.DLS_Ref__c, Duration__c, Status__c, Meeting_URL__c, Timezone__c FROM Events__c' 
                    + ' WHERE (Project__c IN :projectIds OR Schedule__r.Opportunity__c IN :oppIds)'
                    + ' AND Date__c >= LAST_N_MONTHS:' + monthcount2 + ' AND Date__c < LAST_N_MONTHS:' + monthcount1 + ' AND Status__c != \'Rescheduled\'');
        }
        return null;
    }
}