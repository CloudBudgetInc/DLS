/**
 * @description       : 
 * @author            : Vasanthram
 * @group             : 
 * @last modified on  : 09-21-2023
 * @last modified by  : Vasanthram
**/
global with sharing class ContactPlanned_DaysoffCtrl {
    
    public ContactPlanned_DaysoffCtrl() {
        
    }
    
    global class PlannedOff {
        
        public Map<String,Id> conRTNameIdMap;
        public Map<String,Id> plannedOffRTNameIdMap;
        public List<Planned_Days_Off__c> existingOff;
        public Contact contactRec;
        public List<String> typeValues;
        public List<String> leaveType;
        public String startDate; 
    }
    
    public ContactPlanned_DaysoffCtrl(ApexPages.StandardController controller){
        
    }
    
    
    //Modified By Dhinesh - 30-03-2022 - To Optimize the code and to fix the PDO displayed in the project detail page which are not related
    @RemoteAction
    global static PlannedOff plannedDaysOffInfo(String contactId,String projectId,String OppId,String fromDate,String toDate){
                
        List<Planned_Days_Off__c> plannedOff = new List<Planned_Days_Off__c>();
        List<Contact> conRecList = new List<Contact>();
        Map<String,Id> conRTNameIdMap = new Map<String,Id>();
        Map<String,Id> plannedOffRTNameIdMap = new Map<String,Id>();
        
        String startDate;
        String endDate;
        
        Date stDate;
        Date edDate;
        
        if(String.isNotBlank(fromDate)) {
            startDate = fromDate;
            stDate = Date.valueOf(fromDate);
        }
        
        if(String.isNotBlank(toDate)) {
            endDate = toDate;
            edDate = Date.valueOf(toDate);
        }
        
        String offQry = 'SELECT Id,Name,Date__c,Description__c,Requested_Reschedule_Date__c,From_Date__c,To_Date__c,Type__c,Leave_Type__c,Status__c,Contact__c,Contact__r.Name,RecordTypeId,RecordType.DeveloperName FROM Planned_Days_Off__c';
        
        String filter = '';
        
        if(contactId != '' && contactId != null) {
            filter = ' WHERE Contact__c = \''+contactId+'\'';
            
            filter += getPDODateFilterCondition(stDate, edDate);                        
            
            plannedOff = database.query(offQry+filter);
            conRecList = [SELECT Id,Name,RecordTypeId,RecordType.DeveloperName FROM Contact WHERE Id = :contactId];
        }else if(String.isNotEmpty(projectId) || String.isNotEmpty(OppId)) {
            
            String parentId = '';
            
            if(String.isNotEmpty(projectId))
                parentId = projectId;
            else if(String.isNotEmpty(OppId))
                parentId = OppId;
            
            Set<String> contactAssignmentRecordType = new Set<String>{'Student','Instructor','Staff'};
            String contactAssignmentQryStr = 'SELECT Project__c, Opportunity_Name__c, Candidate_Name__c FROM Contact_Assignments__c'+
                                             ' WHERE (Project__c = :parentId OR Opportunity_Name__c = :parentId)'+
                                             ' AND Status__c = \'Active\' AND RecordType.DeveloperName IN :contactAssignmentRecordType';
            
            //Modified By Dhinesh - W-005845 - Remove Project Manager Planned Days Off records from Language Training type Projects                                 
            if(String.isNotEmpty(projectId)){
                AcctSeed__Project__c proj = [SELECT Id, Start_Date__c, End_Date__c, RecordType.DeveloperName FROM AcctSeed__Project__c WHERE Id = :projectId LIMIT 1];
                Set<String> projectRecordTypeSet = new Set<String>{'Language_Training_Projects','DLI_W_LT_Projects','DODA_Projects'};
                if(projectRecordTypeSet.contains(proj.RecordType.DeveloperName)){
                    contactAssignmentRecordType.remove('Staff');
                }
                if(stDate == null && proj.Start_Date__c != null){
                    stDate = proj.Start_Date__c;
                }
                if(edDate == null && proj.End_Date__c != null){
                    edDate = proj.End_Date__c;
                }
            }
            if(String.isNotEmpty(OppId)){
                Opportunity opp = [SELECT Id, Start_Date__c, End_Date__c FROM Opportunity WHERE Id = :OppId LIMIT 1];               
                if(stDate == null && opp.Start_Date__c != null){
                    stDate = opp.Start_Date__c;
                }
                if(edDate == null && opp.End_Date__c != null){
                    edDate = opp.End_Date__c;
                }
            }
            
            Set<Id> contactIdSet = new Set<Id>();
            for(Contact_Assignments__c assignment : database.query(contactAssignmentQryStr)) {
                contactIdSet.add(assignment.Candidate_Name__c);
            }
            
            if(contactIdSet.size() > 0) {
                
                if(String.isNotEmpty(OppId)) {

                    filter =  ' WHERE ((Contact__c IN :contactIdSet AND All_Projects__c = true) OR Opportunity__c = :OppId)';                    
                }else if(String.isNotEmpty(projectId)){

                    filter =  ' WHERE ((Contact__c IN :contactIdSet  AND All_Projects__c = true) OR Project__c = :projectId)';
                }

                filter += getPDODateFilterCondition(stDate, edDate);

            }else{
                
                if(String.isNotEmpty(OppId)){
                    
                    filter = ' WHERE Opportunity__c = :OppId';
                }else if(String.isNotEmpty(projectId)) {
                    
                    filter = ' WHERE Project__c = :projectId';                            
                }

                filter += getPDODateFilterCondition(stDate, edDate);
            }  

            plannedOff = database.query(offQry+filter);          
        }else {
            
            String firstName = UserInfo.getFirstName();
            String lastName = UserInfo.getLastName();
            
            String fname = '%'+firstName+'%';
            String lName = '%'+lastName+'%';
            
            if(firstName != null && lastName != null){
                conRecList = [SELECT Id,Name,RecordTypeId,RecordType.DeveloperName FROM Contact WHERE FirstName LIKE :fname AND lastName LIKE :lName];
            }
            else if(lastName != null){
                conRecList = [SELECT Id,Name,RecordTypeId,RecordType.DeveloperName FROM Contact WHERE lastName LIKE :lName];
            }                           
                      
            if(conRecList.size() > 0){
                filter = ' WHERE Contact__c = \''+conRecList[0].Id+'\'';
                filter += getPDODateFilterCondition(system.today(), edDate);
                plannedOff = database.query(offQry+filter);
            }
        }
        
        for(RecordType rt : [SELECT Id,Name,DeveloperName,SobjectType FROM RecordType WHERE SobjectType IN ('Planned_Days_Off__c','Contact')]){
            if(rt.SobjectType == 'Contact') {
                if(!conRTNameIdMap.containsKey(rt.DeveloperName))
                    conRTNameIdMap.put(rt.DeveloperName,rt.Id);
                
            }else if(rt.SobjectType == 'Planned_Days_Off__c') {
                if(!plannedOffRTNameIdMap.containsKey(rt.DeveloperName))
                    plannedOffRTNameIdMap.put(rt.DeveloperName,rt.Id);
            }
        }        
        
        PlannedOff off = new PlannedOff();
        off.conRTNameIdMap = conRTNameIdMap;
        off.plannedOffRTNameIdMap = plannedOffRTNameIdMap;
        off.existingOff = plannedOff;
        off.contactRec = conRecList.size() > 0 ? conRecList[0] : null;
        off.typeValues = StudentTestResult_ReportPage_Controller.PicklistValues('Planned_Days_Off__c','Type__c');
        off.leaveType = StudentTestResult_ReportPage_Controller.PicklistValues('Planned_Days_Off__c','Leave_Type__c');
        off.startDate = String.valueOf(startDate);
        
        return off;
    }

    public static string getPDODateFilterCondition(Date stDate, Date edDate){
        
        String filter = '';

        if(stDate != null && edDate != null) {
                        
            filter += ' AND ((Date__c >= :stDate AND Date__c <= :edDate) OR (To_Date__c >= :stDate AND From_Date__c <= :edDate))';                        
        }else if(stDate != null) {
            
            filter +=  ' AND (Date__c >= :stDate OR To_Date__c >= :stDate)';
            
            
        }else if(edDate != null){
            
            filter +=  ' AND (Date__c <= :edDate OR From_Date__c <= :edDate)';    
        }

        filter +=  ' ORDER BY  Date__c DESC,From_Date__c DESC';

        return filter;
    }
    
    public static String returnFieldValues() {
        
        return 'Id,Name,Date__c,Description__c,Requested_Reschedule_Date__c,From_Date__c,To_Date__c,Type__c,Leave_Type__c,Status__c,Contact__c,Contact__r.Name,RecordTypeId,RecordType.DeveloperName';
    }
    
    @RemoteAction
    global static List<Planned_Days_Off__c> create_updatemethod(String plannedOffJson,Id conId,String requestOffJson, Boolean isCancelEvents) {
        
        List<Planned_Days_Off__c> modifiedList = (List<Planned_Days_Off__c>) System.JSON.deserialize(plannedOffJson, List<Planned_Days_Off__c>.class);
        List<Planned_Days_Off__c> requestList = (List<Planned_Days_Off__c>) System.JSON.deserialize(requestOffJson, List<Planned_Days_Off__c>.class);
        
        system.debug(':::::modifiedList:::'+modifiedList);
        system.debug(':::::requestList:::'+requestList);
        
        
        // Populate Contact related user values
        Set<Id> contactIds = new Set<Id>();
        
        Boolean allNew = true;
        
        for(Planned_Days_Off__c off : modifiedList){
            contactIds.add(off.Contact__c);
            
            if(off.Id != null)
                allNew = false;
            
        }
        
        // Request record creation related conditions check
        for(Planned_Days_Off__c off : requestList) {
            contactIds.add(off.Contact__c);
        }
        
        if(contactIds.size() > 0) {
            Map<Id,Id> conIdUserId = new Map<Id,Id>();
            conIdUserId = PlannedDaysOffHandler.getContactRelatedUsers(contactIds);
            
            for(Planned_Days_Off__c off : modifiedList){
                if(conIdUserId.containsKey(off.Contact__c))
                    off.User__c = conIdUserId.get(off.Contact__c);
                
                if(allNew)
                    off.Status__c = 'Approved';
            }
            
            for(Planned_Days_Off__c off : requestList) {
                if(conIdUserId.containsKey(off.Contact__c))
                    off.User__c = conIdUserId.get(off.Contact__c);
            }
        }
        
        if(requestList.size() > 0) {
            List<Contact> contactRec = [SELECT Id,Name,RecordType.DeveloperName FROM Contact WHERE Id = :requestList[0].Contact__c];
            List<User> userRec = [SELECT Id,Name,Profile.Name,ManagerId FROM User WHERE Id = :UserInfo.getUserId()];
            List<User> contactUser = [SELECT Id,Name,ManagerId FROM User WHERE Id = :requestList[0].User__c];
            
            system.debug('::::::::requestList:::::'+requestList);
            
            
            if(allNew && requestList.size() > 0 && contactRec[0].RecordType.DeveloperName == 'DLS_Employee' && (userRec[0].Id == requestList[0].User__c || userRec[0].Id != requestList[0].User__c) 
               && userRec.size() > 0 && userRec[0].Profile.Name != 'HR' && contactUser.size() > 0 && userRec[0].Id != contactUser[0].ManagerId) {
                   insert requestList;
               }else {
                   requestList = new List<Planned_Days_Off__c>();
               }
        }
        if((!allNew || (allNew && requestList.size() == 0))&& modifiedList.size() > 0) {
            system.debug('enter upsert');
            upsert modifiedList;

            // W-007883
            if(isCancelEvents) {
                PlannedDaysOffHandler.cancelInstructorPDORelatedEvents(modifiedList);
            }
        }

        return [SELECT Id,Name,Date__c,Description__c,Requested_Reschedule_Date__c,Type__c,Leave_Type__c,Status__c,Contact__c,Contact__r.Name,RecordTypeId,RecordType.DeveloperName,From_Date__c,To_Date__c FROM Planned_Days_Off__c WHERE Contact__c = :conId ];
    }
    
    @RemoteAction
    global static List<Planned_Days_Off__c> deleteDaysOff(String plannedOffJson,Boolean isStaff) {
        List<Planned_Days_Off__c> deletionList = (List<Planned_Days_Off__c>) System.JSON.deserialize(plannedOffJson, List<Planned_Days_Off__c>.class);
        
        // Planned days off delete is not going to done directly. Hr/Manager should approve the delete action
        // Modified by NS on July 26 2018
        if(deletionList.size() > 0) {
            //delete deletionList;
            
            if(isStaff) 
                update deletionList;
            else
                delete deletionList;
        }
        
        return [SELECT Id,Name,Date__c,Description__c,Requested_Reschedule_Date__c,Type__c,Leave_Type__c,Status__c,Contact__c,Contact__r.Name,RecordTypeId,RecordType.DeveloperName,From_Date__c,To_Date__c FROM Planned_Days_Off__c WHERE Contact__c = :deletionList[0].Contact__c];
    }
    
    @RemoteAction
    global static List<sObject> getLookupRecords(String objectName, String searchString, String condition){
        
        return TimeKeeping_Admin_Controller.getLookupRecords(objectName,searchString,condition);
    }
    
    //Method to the Contact details based on the Parent Id (Project/Opp) & type of PDO selected
    //Added by NS on Sep 14 2018
    @RemoteAction
    global static List<Contact> getRelatedContacts(String parentId,string parentType,String type){
        
        List<Contact> contactRecords = new List<Contact>();
        Set<Id> contactIds = new Set<Id>();
        
        for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c
                                         FROM Contact_Assignments__c 
                                         WHERE Status__c = 'Active' AND (Opportunity_Name__c = :parentId OR Project__c = :parentId) AND RecordType.DeveloperName = :type]){
                                             
                                             contactIds.add(ca.Candidate_Name__c);
                                         }
        
        if(contactIds.size() > 0)
            contactRecords = [SELECT Id,Name,RecordType.DeveloperName FROM Contact WHERE Id IN :contactIds];
        
        return contactRecords;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(String.escapeSingleQuotes(searchString),objectName,fieldName,condition,selectedIds);
    } 
    @AuraEnabled
    public Static String getPlannedDaysOffInfo(String conId,String proId,String oppId,String dt1,String dt2){
        
        PlannedOff planOff = new PlannedOff();
        system.debug(':::::st'+dt1+':::ed'+dt2+':::conId'+conId);
        planOff =  PlannedDaysOffInfo( conId, proId, oppId, dt1, dt2);
        system.debug('planOff::::'+planOff.existingOff);
        return JSON.serialize(planOff);
        
    }
    @AuraEnabled
    public static String getRelatedContactsPDO(String parentId,string parentType,String type){
        system.debug(':::::getRelated'+getRelatedContacts( parentId, parentType, type));
        
        try {
            return JSON.serialize(getRelatedContacts( parentId, parentType, type));
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
        
    }
    @AuraEnabled
    public static String create_updatemethodPDO(String plannedOffJson,Id conId,String requestOffJson, Boolean isCancelEvents) { 
        
        try {
            return JSON.serialize(create_updatemethod(plannedOffJson,conId,requestOffJson,isCancelEvents));
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    @AuraEnabled
    public static String deletePlannedDaysOff(String plannedOffJson,Boolean isStaff) {
        try {
            return JSON.serialize(deleteDaysOff(plannedOffJson,isStaff));
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static List<Contact> getContacts(String conId){
        List<Contact> contactRecords = new List<Contact>();
        
        if(conId != null){
            contactRecords = [SELECT Id,Name,RecordType.DeveloperName FROM Contact WHERE Id = :conId];
        }
        return contactRecords;
    }
    
}