global without sharing class EventTabController {
    
    public static Boolean isUpdateTestingProjectDates = false;
    @AuraEnabled
    public static eventDatePickListValWrapper getEventRecordsInitial(List<String> projId, String eveStatus) {
        
        Date stDate = System.today().toStartOfWeek().addDays(-7);
        Date enDate = stDate.addDays(20);
        Id objId = projId.size() > 0 ? (Id)projId[0] : null;
        String parentRTName;
        
        eventDatePickListValWrapper eveDtSta = new eventDatePickListValWrapper();
        
        eventsAndEventsIdsWrap eventsAndEventsIdsWrapObj = getEventRecords(projId, String.valueOf(stDate), String.valueOf(enDate), eveStatus, 'All');
        
        eveDtSta.eveList = eventsAndEventsIdsWrapObj.eveList;
        eveDtSta.eventsIdsHasLP = eventsAndEventsIdsWrapObj.eventsIdsHasLP;
        eveDtSta.startDate = stDate;
        eveDtSta.endDate = enDate;
        eveDtSta.statusValue = getPickListValues('Events__c', 'Status__c');
        eveDtSta.startTimeValue = getPickListValues('Events__c', 'Start_Time__c');
        eveDtSta.endTimeValue = getPickListValues('Events__c', 'End_Time__c');
        eveDtSta.parentType = String.valueOf(objId.getSobjectType());
        eveDtSta.caRecord = new Contact_Assignments__c();
        eveDtSta.caRecord.RecordTypeId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId(); 
        eveDtSta.caRecord.Status__c = 'Planned';        
        eveDtSta.caRecord.Assignment_Position__c = 'Instructor';                
        
        //Qry login user profile name
        List<User> User = [SELECT Id,Name,Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        eveDtSta.profileName = User[0].Profile.Name;
        eveDtSta.allowRoomEdit = FeatureManagement.checkPermission('Permission_to_Edit_Rooms');
        
        Boolean projectExist;
        
        if(String.valueOf(objId.getSobjectType()) == 'Opportunity'){
            
            List<Opportunity> oppRec = [SELECT Id, Location__c, End_Date__c, RecordType.DeveloperName, Default_Cost_Rate_Rate_Type__c, Oral_Exam__c FROM Opportunity WHERE Id = :objId];
            
            if(oppRec.size() > 0){
            
                DateTime oralExamDate = oppRec[0].Oral_Exam__c;
                parentRTName = oppRec[0].RecordType.DeveloperName;                
                eveDtSta.defaultCostRate = oppRec[0].Default_Cost_Rate_Rate_Type__c;
                eveDtSta.caRecord.Location__c = oppRec[0].Location__c;
                eveDtSta.caRecord.Opportunity_Name__c = oppRec[0].Id;
                
                if(oralExamDate != null){
                
                    eveDtSta.parentOralExamDate = Date.newinstance(oralExamDate.year(), oralExamDate.month(), oralExamDate.day());                    
                    eveDtSta.parentOralExamTime = formatOralExamDateTime(oralExamDate); 
                }
                
                List<AcctSeed__Project__c> pro = [SELECT Id,Name FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c = :objId];
                
                if(pro.size() > 0){
                    projectExist = true;
                }else {
                    projectExist = false;
                }
            }
            
        }else if(String.valueOf(objId.getSobjectType()) == 'AcctSeed__Project__c') {
            
            List<AcctSeed__Project__c> projectRec = [SELECT Id, Training_Location__c, End_Date__c, RecordType.DeveloperName, Default_Cost_Rate_Rate_Type__c, Oral_Exam_Date_Time__c FROM AcctSeed__Project__c WHERE Id = :objId];
            Map<String,String> projTaskIdMap = new Map<String,String>();
            projTaskIdMap.put('All','All');
            
            if(projectRec.size() > 0){
                DateTime oralExamDate = projectRec[0].Oral_Exam_Date_Time__c;
                parentRTName = projectRec[0].RecordType.DeveloperName;
                eveDtSta.defaultCostRate = projectRec[0].Default_Cost_Rate_Rate_Type__c;
                eveDtSta.caRecord.Location__c = projectRec[0].Training_Location__c;
                eveDtSta.caRecord.Project__c = projectRec[0].Id;
                        
                if(oralExamDate != null){
                    eveDtSta.parentOralExamDate = Date.newinstance(oralExamDate.year(), oralExamDate.month(), oralExamDate.day());                 
                    eveDtSta.parentOralExamTime = formatOralExamDateTime(oralExamDate); 
                }
            }
            
           for(AcctSeed__Project_Task__c pt : [SELECT Id,Name  FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :objId AND RecordType.DeveloperName != 'Material_Budget']) {
                
                if(!projTaskIdMap.containskey(pt.Id)){
                    projTaskIdMap.put(pt.Id,pt.Name);     
                }
            }
            
            eveDtSta.projTaskIdMap = projTaskIdMap;
            projectExist = true;
        }
        
        system.debug(':::::::::::eveDtSta.parentOralExamDate::::'+eveDtSta.parentOralExamDate);
        system.debug(':::::::::::eveDtSta.parentOralExamTime::::'+eveDtSta.parentOralExamTime);
        
        eveDtSta.projectExist = projectExist;
        eveDtSta.parentRTName =  parentRTName;
        
        return eveDtSta;
    } 
    
    @AuraEnabled
    public static eventsAndEventsIdsWrap getEventRecords(List<String> projId, String stDate, String enDate, String eventStatus, String selectedProTaskId) {
        
        eventsAndEventsIdsWrap eventsAndEventsIdsWrapObj = new eventsAndEventsIdsWrap();
        
        List<Events__c> eventList = new List<Events__c>();
        
        Set<String> proIdSet = new Set<String>();
        String queryStr;
        Date startDate;
        Date endDate;
        
        if(String.isNotBlank(stDate))
            startDate = Date.valueOf(stDate);
        
        if(String.isNotBlank(enDate))
            endDate = Date.valueOf(enDate);
        
        if(projId != null && projId.size() > 0) {
            
            Id objId = (Id)projId[0];
            if(String.valueOf(objId.getSobjectType()) == 'Opportunity') {
                Set<String> oppIds = new Set<String>();
                oppIds.addAll(projId);  // projId - Opportunity Id
                List<AcctSeed__Project__c> proList = [SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Opportunity__c IN :oppIds];
                
                if(proList.size() > 0) {
                    for(AcctSeed__Project__c pro : proList) {
                        proIdSet.add(pro.Id);
                    }
                }else {
                    proIdSet.add(objId);
                }
                
            } else {
                proIdSet.addAll(projId);
            } 
            
            queryStr = 'SELECT Id, Name, Date__c, Status__c, Room__c, Room__r.Name, Instructor__c, Instructor__r.Name, Start_Time__c, End_Time__c, Timezone__c, No_Student_Approval__c,Duration__c,Project_Task__c,Schedule__c,Project_Task__r.name,Schedule__r.Project_Task__r.Project_Task_Type__c, Meeting_URL__c'
                       +' FROM Events__c WHERE (Project__c IN :proIdSet OR Opportunity__c IN :proIdSet)';
            
            if(stDate != null && enDate != null) {            
                queryStr += ' AND Date__c >= :startDate AND Date__c <= :endDate'; 
            }else if(stDate != null){
                queryStr += ' AND Date__c >= :startDate'; 
            }else if(enDate != null){
                queryStr += ' AND Date__c <= :endDate'; 
            }
        }
        
        if(eventStatus != 'All') {
            queryStr += ' AND Status__c = :eventStatus';
        }
        
        if(selectedProTaskId != 'All' && String.isNotBlank(selectedProTaskId)) {
            queryStr += ' AND (Schedule__r.Project_Task__c = :selectedProTaskId OR Project_Task__c = :selectedProTaskId)';
        }
        
        
        eventsAndEventsIdsWrapObj.eveList = database.query(queryStr);
        
        List<Id> eventsIdsHasLP = new List<Id>();
        Map<Id, Events__c> eventIdWithRecMap = new Map<Id, Events__c>(eventsAndEventsIdsWrapObj.eveList);
        for(Lesson_Plan__c lp : [SELECT Id, Event__c FROM Lesson_Plan__c WHERE Event__c IN :eventIdWithRecMap.keySet()]){
            eventsIdsHasLP.add(lp.Event__c);
        }
        
        eventsAndEventsIdsWrapObj.eventsIdsHasLP = eventsIdsHasLP;
        
        return eventsAndEventsIdsWrapObj;
    } 
    
    @AuraEnabled
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        
        //return Staff_Daily_Timesheet_Ctrl.search(searchString,objectName,fieldName,condition,selectedIds);
        
        List<sObject> objRec = new List<sObject>();
        Set<Id> proIds = new Set<Id>();
        
        if(condition != null && condition != '') {
            for(String str : condition.split(', ')) {
                proIds.add(str);
            }
        }
        
        if(objectName == 'Contact') {
            objRec = [SELECT Id, Name FROM Contact WHERE Id IN (SELECT Candidate_Name__c FROM Contact_Assignments__c 
                        WHERE Candidate_Name__r.Name LIKE :'%'+searchString+'%' 
                            AND ((Project__c IN : proIds AND Status__c = 'Active') OR (Opportunity_Name__c IN :proIds AND Status__c = 'Planned')) 
                            AND RecordType.DeveloperName = 'Instructor')];
        } else if(objectName == 'Room__c') {
            objRec = [SELECT Id, Name FROM Room__c WHERE Name LIKE :'%'+searchString+'%'];
        }
        
        return objRec;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<sObject> getGenericLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(String.escapeSingleQuotes(searchString),objectName,fieldName,condition,selectedIds);
    } 
    
    @AuraEnabled
    public static List<Contact> getContactRecords(String conId) {
        return [SELECT Id, Name FROM Contact WHERE Id = :conId];
    }
    
    @AuraEnabled
    public static List<Room__c> getRoomRecords(String roomId) {
        return [SELECT Id, Name FROM Room__c WHERE Id = :roomId];
    }
    
    @AuraEnabled
    public static List<Acctseed__Project_Task__c> getProjTaskRecords(String projTaskId) {
        return [SELECT Id, Name FROM Acctseed__Project_Task__c WHERE Id = :projTaskId];
    }
    
    // Method to get the pick list values
    @AuraEnabled
    public static List<String> getPickListValues(String objName, String pickListName) {
    
        List<String> pickListValues = new List<String>();
        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        
        Schema.DescribeFieldResult picklistFieldDescribe = fieldMap.get(pickListName).getDescribe();
        for(Schema.PicklistEntry pickListVal : picklistFieldDescribe.getPicklistValues()){
            if(pickListVal.isActive()){
                pickListValues.add(pickListVal.getValue());
            }
        }
        
        return pickListValues;
    } 
    
    @AuraEnabled
    public static List<Events__c> saveEventRecords(String eventUpdateList, String event) { 
        
        List<Events__c> eveList = (List<Events__c>) System.JSON.deserialize(eventUpdateList, List<Events__c>.class);
        Events__c eve = (Events__c) System.JSON.deserialize(event, Events__c.class);
        
        for(Events__c events : eveList) {
            if(eve.Date__c != null) 
                events.Date__c = eve.Date__c;
            if(eve.Status__c != null && eve.Status__c != '') 
                events.Status__c = eve.Status__c;
            if(eve.Room__c != null) 
                events.Room__c = eve.Room__c;
            if(eve.Instructor__c != null) 
                events.Instructor__c = eve.Instructor__c;
            if(eve.Start_Time__c != null && eve.Start_Time__c != '') 
                events.Start_Time__c = eve.Start_Time__c;
            if(eve.End_Time__c != null && eve.End_Time__c != '') 
                events.End_Time__c = eve.End_Time__c;
            if(eve.Duration__c != null) 
                events.Duration__c = eve.Duration__c;
                
            events.No_Student_Approval__c = eve.No_Student_Approval__c;
        }
        
        update eveList;
        return eveList;
    }
    
    /*************************************************************************
    - Method to create event records for testing projects
    - Added by NS on March 17 2020
    *************************************************************************/
    @AuraEnabled
    public static String createEventsForTestingProject(String eventJSON, String caRec, Boolean isCreateCA, Boolean isUpdateTestingProDates){
    
        try {
        
            List<Events__c> newEventList = (List<Events__c>) System.JSON.deserialize(eventJSON, List<Events__c>.class);
            isUpdateTestingProjectDates = isUpdateTestingProDates;
            
            if(newEventList.size() > 0){
                
                List<Events__c> existingEvents = new List<Events__c>();
                String dlsClassNo = '';
                Date endDate;
                Id parentId;
                
                if(newEventList[0].Project__c != null){
                    
                    existingEvents = [SELECT Id,SequenceNo__c FROM Events__c WHERE Project__c = :newEventList[0].Project__c ORDER BY CreatedDate DESC LIMIT 1];
                
                    AcctSeed__Project__c pro = [SELECT Id,End_Date__c,DLS_Class__c FROM AcctSeed__Project__c WHERE Id = :newEventList[0].Project__c];
                    endDate = pro.End_Date__c;
                    dlsClassNo = pro.DLS_Class__c;
                    parentId = pro.Id;
                }else if(newEventList[0].Opportunity__c != null){
                    
                    existingEvents = [SELECT Id,SequenceNo__c FROM Events__c WHERE Opportunity__c = :newEventList[0].Opportunity__c ORDER BY CreatedDate DESC LIMIT 1];
                
                    Opportunity opp = [SELECT Id,End_Date__c,DLS_Class__c FROM Opportunity WHERE Id = :newEventList[0].Opportunity__c];
                    endDate = opp.End_Date__c;
                    dlsClassNo = opp.DLS_Class__c;
                    parentId = opp.Id;
                }
                
                
                Integer sequenceNo = 0;
                
                if(existingEvents.size() > 0){
                    sequenceNo = (Integer) existingEvents[0].SequenceNo__c;
                }
                
                if(newEventList.size() == 1){
                    newEventList[0].SequenceNo__c = (sequenceNo + 1);
                    newEventList[0].Name = dlsClassNo+'-EV'+(sequenceNo + 1);
                }
                
               
                if(isCreateCA) {
                    Contact_Assignments__c newInstructor = (Contact_Assignments__c) System.JSON.deserialize(caRec, Contact_Assignments__c.class);                    
                    newInstructor.Status__c = 'Active';
                    newInstructor.End_Date__c = endDate;
                    newInstructor.Assignment_Position__c = 'Tester';
                    
                    insert newInstructor;
                }
                
                insert newEventList;
                                
            }
        
            return 'SUCCESS';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static Boolean checkContactAssignmentExist(String contactId,String parentId){
        return ScheduleCmpLightningController.checkContactAssignmentExist(contactId,parentId);
    }
    
    public static String formatOralExamDateTime(DateTime oralExamDate){
        Integer minutes = Integer.valueOf(oralExamDate.format('mm'));
                    
        String minVal;
        
        if(minutes >= 0 && minutes < 15) minVal = '00';
        else if(minutes >= 15 && minutes < 30) minVal = '15';
        else if(minutes >= 30 && minutes < 45) minVal = '30';
        else if(minutes >= 45) minVal = '45';
        
        Integer hrs = Integer.valueOf(oralExamDate.format('h'));
        String hrsVal;
        
        if(hrs < 10){
            hrsVal = '0'+String.valueOf(hrs); 
        }else {
            hrsVal = String.valueOf(hrs);
        }
        
        return hrsVal+':'+minVal+' '+oralExamDate.format('a');
    }
    
    public class eventDatePickListValWrapper {
        @AuraEnabled public List<Events__c> eveList = new List<Events__c>();
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date endDate;
        @AuraEnabled public List<String> statusValue = new List<String>();
        @AuraEnabled public List<String> startTimeValue = new List<String>();
        @AuraEnabled public List<String> endTimeValue = new List<String>();
        @AuraEnabled public String parentType;
        
        @AuraEnabled public Date parentOralExamDate;
        @AuraEnabled public string parentOralExamTime;
        
        @AuraEnabled public String profileName;
        @AuraEnabled public Boolean allowRoomEdit;
        @AuraEnabled public Boolean projectExist;
        @AuraEnabled public string parentRTName;
        @AuraEnabled public String defaultCostRate;
        @AuraEnabled public Contact_Assignments__c caRecord;
        @AuraEnabled public List<Id> eventsIdsHasLP; //Added By Dhinesh - 1/3/2022 - Lesson Plan
        
        @AuraEnabled public Map<String,String> projTaskIdMap;
    }
    
    //Added By Dhinesh - 1/3/2022 - Lesson Plan
    public class eventsAndEventsIdsWrap{
        @AuraEnabled public List<Id> eventsIdsHasLP;
        @AuraEnabled public List<Events__c> eveList;
    }
}