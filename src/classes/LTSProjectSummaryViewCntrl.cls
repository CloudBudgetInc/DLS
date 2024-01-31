/*********************************************************************************
Created by GRK on July 17, 2017: for Page LTSProjectSummaryView
*********************************************************************************/

global Class LTSProjectSummaryViewCntrl {
    //public List<caWrapper> wrapList{get; set;}
    
    @RemoteAction
    global static List<sObject> getLookupRecords(String objectName, String searchString, String condition) {
        return SObjectQueryService.getLookupRecords(objectName,searchString,condition);
    }
    
    @RemoteAction
    global static List<Saved_Search__c> getSavedSearch() {
        List<Saved_Search__c> ssList = [SELECT Id,Name,Filter_Value__c FROM Saved_Search__c];
        system.debug('ssList::::::'+ssList);
        return ssList;
        
    }
    
    // To update the project status - added by E.Keerthika on 2nd, May 2018
    @RemoteAction
    global static List<AcctSeed__Project__c> updateProStatus(String updatePro) {
        
        List<AcctSeed__Project__c> proUpdateList = (List<AcctSeed__Project__c>) System.JSON.deserialize(updatePro, List<AcctSeed__Project__c>.class);
        ProjectService.updateProject(proUpdateList);
        return proUpdateList;
    }
    
    @RemoteAction
    global static List<Saved_Search__c> SaveSearches(String ssList) {
        List<Saved_Search__c> saveList = (List<Saved_Search__c>) System.JSON.deserialize(ssList, List<Saved_Search__c>.class);
        try{
            Upsert saveList;
            return saveList;
        } catch(Exception e) {
            system.debug('saveList ::::::'+saveList);
            return saveList;
        }
        
    }
    
    @RemoteAction
    global static List<String> getPicklistVal(String obj, String field) {
        return SObjectQueryService.getPicklistValues(obj,field);
    }
    
    @RemoteAction
    global static List<Contact> updateContact(string Conts) {
        List<Contact> conList = (List<Contact>) System.JSON.deserialize(Conts, List<Contact>.class);
        try {
            update conList;
            //return 'Success';
        } catch (Exception e) {
            system.debug('Exception:::LTSProjectSummaryViewCntrl :::'+e);
            //return 'Failure';
            
        }
        return conList;
    }
    
    /** created by Karthiga on Aug 23, 2017
    * for Deleting a saved search Record
    * @ssId = Id of the Saved Search Record to be deleted
    **/
    @RemoteAction
    global static String deleteSavedSearch(String ssId){
        System.Debug('ssId::::::'+ssId);
        try{
            Saved_Search__c ssToDel = new Saved_Search__c(Id=ssId);
            Delete ssToDel;
            return 'Success';
        } catch (Exception ex) {
            System.debug('Error Occured::LTSProjectSummaryViewCntrl::deleteSavedSearch'+ex);
            return 'Failed';
        }
    }
    
    @RemoteAction
    global static List<caWrapper> downloadCsvFile(List<String> projectId,String recordType){
        system.debug('projectId::::::::::::'+projectId);
        List<caWrapper> wrapList = new List<caWrapper>();
        Set<Id> caSet = new Set<Id>();
        for(Contact_Assignments__c  ca:[
                                        SELECT Id, Candidate_Name__c, Candidate_Name__r.FirstName, Candidate_Name__r.LastName, Candidate_Name__r.Email, RecordTypeId, RecordType.DeveloperName, Candidate_Name__r.Account.Name
                                        FROM Contact_Assignments__c 
                                        WHERE Project__c =:projectId AND Status__c = 'Active' AND RecordType.DeveloperName = :recordType]){
            
            if(!caSet.contains(ca.Candidate_Name__c)){                
                caWrapper wrap = new caWrapper();
                wrap.firstname = ca.Candidate_Name__r.FirstName;
                wrap.lastname = ca.Candidate_Name__r.LastName;
                wrap.email = ca.Candidate_Name__r.Email;
                wrap.recordType = ca.RecordType.DeveloperName;
                if(ca.RecordType.DeveloperName == 'Student'){
                    wrap.accName = ca.Candidate_Name__r.Account.Name;
                }
                wrapList.add(wrap);
                caSet.add(ca.Candidate_Name__c); 
            }            
        }
        
        //system.debug('wrapList::::::'+wrapList);
        //system.debug('wrapList.size:::'+wrapList.size());
        return wrapList;
    }
    
    /*****************************************************************************8
    - Method to get the Project records based on the filter information form LTSProjectSummaryView for print view table formation
    - Added by NS on July 20 2018
    ******************************************************************************/
    @RemoteAction
    global static List<AcctSeed__Project__c> projectRecordsForPrintView(String accountId,String contactId,String CAPosition,String CARTId,List<String> CAStatus,String locationId,List<String> projectStatus,String sortingFieldName,String sortingOrder){
        
        List<AcctSeed__Project__c> projectRecords = new List<AcctSeed__Project__c>();
        String proQry = 'SELECT Id,Name,RecordType.Name,DLS_Ref__c,Start_Date__c,Program_type__c,End_Date__c,AcctSeed__Status__c,Hours_Remaining__c,'+
                             ' Project_Manager__c, Project_Manager__r.Name,Total_Program_Hours__c,Hours_Week__c,Students__c,Staffs__c,Instructors__c,'+
                             'All_Active_Rooms__c,Room__c,Room__r.Name,AcctSeed__Account__c,AcctSeed__Account__r.Name,Language__c,Language__r.Name,'+
                             'Training_Location__c,Training_Location__r.Name '+
                             'FROM AcctSeed__Project__c WHERE ';
         
         String filter = '';
         //Account filter
         if(!String.isEmpty(accountId) && String.isEmpty(filter)) {
             filter = 'AcctSeed__Account__c = \''+accountId+'\'';
         }
         
         // Location filter
         if(!String.isEmpty(locationId)) {
             if(!String.isEmpty(filter)) {
                 filter += 'AND Training_Location__c = \''+locationId+'\'';
             }else {
                 filter = 'Training_Location__c = \''+locationId+'\'';
             }
         }
         
         // Project Status filter
         if(projectStatus != null && projectStatus.size() > 0) {
             Set<String> statusSet = new Set<String>();
             statusSet.addAll(projectStatus);
             
             if(!String.isEmpty(filter)) {
                 filter += ' AND AcctSeed__Status__c IN :statusSet';
             }else {
                 filter = 'AcctSeed__Status__c IN :statusSet';
             }
         }
         
         String CACondition = 'SELECT Project__c FROM Contact_Assignments__c WHERE ';
         Boolean conditionAdded = false;
         if(!String.isEmpty(contactId)) {
             CACondition += 'Candidate_Name__c = \''+contactId+'\'';
             conditionAdded = true;
         }
         
         if(!String.isEmpty(CARTId) && CARTId != 'All') {
             if(conditionAdded) {
                 CACondition += ' AND RecordTypeId = \''+CARTId+'\'';
             } else {
                 CACondition += 'RecordTypeId = \''+CARTId+'\'';
                 conditionAdded = true;
             }
         }
         
         if(!String.isEmpty(CAPosition) && CAPosition != 'All') {
             if(conditionAdded) {
                 CACondition += ' AND Assignment_Position__c = \''+CAPosition+'\'';
             } else {
                 CACondition += 'Assignment_Position__c = \''+CAPosition+'\'';
                 conditionAdded = true;
             }
         }
         
         if(CAStatus != null && CAStatus.size() > 0) {
             Set<String> caStatusSet = new Set<String>();
             caStatusSet.addAll(CAStatus);
             
             if(conditionAdded) {
                 CACondition += ' AND Status__c IN :caStatusSet';
             } else {
                 CACondition += 'Status__c IN :caStatusSet';
                 conditionAdded = true;
             }
         }
         
         system.debug('::::::CACondition::::'+CACondition);
         
         if(CAPosition != 'All' || CARTId != 'All' || CAStatus.size() > 0 || !String.isEmpty(contactId)) {
             if(!String.isEmpty(filter)) {
                 filter += ' AND Id IN (' + CACondition + ')';
             }else {
                 filter = 'Id IN (' + CACondition + ')';
             }
         }
         
         system.debug(':::::::filter::::'+filter);
         
         proQry = proQry + filter;
         
         system.debug('::::::::sortingFieldName:::::'+sortingFieldName);
         system.debug('::::::::sortingOrder:::::'+sortingOrder);
         
         if(String.isNotBlank(sortingFieldName) && String.isNotBlank(sortingOrder)){
             proQry += 'ORDER BY '+sortingFieldName+' '+sortingOrder +' NULLS LAST';
         }
         
         system.debug(':::::::::proQry:::::;;'+proQry);
         
         projectRecords = Database.query(proQry);
         
         system.debug(':::::::projectRecords::::::'+projectRecords.size());
         
         return projectRecords;
        
    }
    
    // To get the count of the Active instructor and student based on the project - Added by E.Keerthika on 30th, November 2018
    @RemoteAction
    global static Map<String, Integer> getActiveStudentInstructorCount(List<Id> proIds) {
        
        Map<String, Integer> countMap = new Map<String, Integer>{'Instructor' => 0, 'Student' => 0};
        
        if(proIds.size() > 0) {
            Set<Id> proIdsSet = new Set<Id>(proIds);
            List<Contact_Assignments__c> conAssList = [SELECT Id, Name, RecordType.DeveloperName FROM Contact_Assignments__c WHERE Project__c IN :proIdsSet AND RecordType.DeveloperName IN ('Instructor', 'Student') AND Status__c = 'Active'];
            for(Contact_Assignments__c conAss : conAssList) {
                if(conAss.RecordType.DeveloperName == 'Instructor') {
                    countMap.put('Instructor', countMap.get('Instructor')+1);
                    
                } else if(conAss.RecordType.DeveloperName == 'Student') {
                    countMap.put('Student', countMap.get('Student')+1);
                }
            }
        }
        return countMap;
    }
    
    global class caWrapper{
        public String firstname;
        public String lastName;
        public String email;
        public String recordType;
        public String accName;
    }
    
}