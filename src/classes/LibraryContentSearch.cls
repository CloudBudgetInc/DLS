global without sharing class LibraryContentSearch {
    
    global Boolean instructorFlag {get; set;}
    global Id LoggedInContactId {get; set;}
    
    // Added by to handle the expception in Classic & Lightning Component
    public class AllException extends Exception {}
    
    global LibraryContentSearch() {
        instructorFlag = true;
        List<User> userList = SObjectQueryService.SObjectQuery('User',new Set<Id>{UserInfo.getUserId()},'');
        if(userList[0].UserType == 'Standard') {
            instructorFlag = false;
        }
        LoggedInContactId = userList[0].ContactId;
        System.debug('::::::::;;instructorFlag:::'+instructorFlag);
        System.debug('::::::::;;LoggedInContactId:::'+LoggedInContactId);
    }


    // Added by sukanya sep 2 2016
    // Method to create Materials Request record from Materials detail page in Internal Library Page
     @RemoteAction
    global static String CreateMaterialsRequests(String requestObjString) {
       Set<Id> matReqIds = new Set<Id>();     
       List<Materials_Request__c> materialsRequestList = (List<Materials_Request__c>) System.JSON.deserialize(requestObjString, List<Materials_Request__c>.class);
       system.debug('::::::::materialsRequestList:::::::'+materialsRequestList);
       
       List<Materials_Request__c> materialReqList = new List<Materials_Request__c>();
       
       try {
           if(materialsRequestList.size() > 0)
               materialReqList = MaterialRequestService.insertMaterialrequest(materialsRequestList);
              //insert materialsRequestList;
           
           if(materialReqList.size() == 1){
               matReqIds.add(materialReqList[0].Id);
           }
           
           system.debug(':::::::::::materialsRequestList:::::::'+materialsRequestList);
           return JSON.serialize(matReqIds);
       }catch(Exception e) {
            system.debug(':::::::e.getMessage():::::'+e.getMessage());
            throw new AllException(e.getMessage());
       }
    }


    // Added by sukanya on sep 28 2016 for look up for in libarry home page material request create
    
    @RemoteAction
    global static List<sObject> getLookupRecords(String objectName, String searchString, String condition) {
        List<sObject> lookupRecords = new List<sObject>();
        String query = 'SELECT Id, Name FROM ' + objectName;
        if(searchString != null && searchString != '') {
            query += ' WHERE Name LIKE \'%' + searchString + '%\'';
        }
        if(objectName == 'AcctSeed__Project__c' || objectName == 'Opportunity'){
            Set<Id> proIdSet = new Set<Id>();
            Set<Id> oppIdSet = new Set<Id>();
            Id userId = UserInfo.getUserId(); 
            List<User> userList = SObjectQueryService.SObjectQuery('User',new Set<Id>{userId},'');
            if(userList[0].Staff_Access__c == true && userList[0].Current_Previlege__c == 'Staff'){ 
                String parentField = 'Project__r.DLS_Class__c,Project__r.AcctSeed__Status__c,Candidate_Name__r.Name,Project__r.Name,Project__r.Start_Date__c,Project__r.End_Date__c ';
                List<Contact_Assignments__c> conassignList = ContactAssignmentService.getContactassignmentByprojectId(' WHERE (Project__c != null OR Opportunity_Name__c != null) AND RecordType.DeveloperName = \'Staff\' AND Candidate_Name__c ',parentField,new Set<Id>{userList[0].ContactId},'');
                for(Contact_Assignments__c ca : conassignList) {
                    if(ca.Project__c != null){
                        proIdSet.add(ca.Project__c);
                    }
                    if(ca.Opportunity_Name__c != null){
                        oppIdSet.add(ca.Opportunity_Name__c);
                    }
                }
                if(objectName == 'AcctSeed__Project__c'){
                    if(proIdSet != null && proIdSet.size() > 0){
                        if(searchString != null && searchString != '') {
                            query += ' AND Id IN :proIdSet';
                        } else {
                            query += ' WHERE Id IN :proIdSet';
                        }
                    }
                }
                if(objectName == 'Opportunity'){
                    if(oppIdSet != null && oppIdSet.size() > 0){
                        if(searchString != null && searchString != '') {
                            query += ' AND Id IN :oppIdSet';
                        } else {
                            query += ' WHERE Id IN :oppIdSet';
                        }
                    }
                } 
            }
        } else {
            if(condition != null && condition != '') {
                if(searchString != null && searchString != '') {
                    query += ' AND ' + condition;
                } else {
                    query += ' WHERE ' + condition;
                }
            }
        }
        query += ' LIMIT 10';
        System.debug('query log ' + query);
        if(objectName != 'Account' && objectName != 'Contact') {
            lookupRecords = Database.query(query);
        }else {
            String searchQry = 'FIND {'+searchString+'} IN NAME Fields Returning '+objectName+' (Id,Name';

            if(condition != null && condition != '') {
                searchQry = searchQry + ' WHERE '+condition+')';
            }else {
                searchQry = searchQry + ')';
            }
            
            searchQry += ' LIMIT 10';
            
            if(searchString != null) {
                lookupRecords = search.query(searchQry)[0];
            }
        }
        return lookupRecords;
    }

    /*********************************************************************
     - Qry the project related Material Project Task records
     - Added by sukanya on May 16 2018
    **********************************************************************/
    @RemoteAction
    global static List<AcctSeed__Project_Task__c> projectTasksBasedOnProject(String projectId){
        List<AcctSeed__Project_Task__c> projectTaskList = new List<AcctSeed__Project_Task__c>();
        projectTaskList = [SELECT Id,Name,AcctSeed__Project__c,AcctSeed__Project__r.Name,
                                AcctSeed__Project__r.Start_Date__c,AcctSeed__Project__r.End_Date__c,AcctSeed__Project__r.DLS_Class__c
                            FROM AcctSeed__Project_Task__c 
                            WHERE AcctSeed__Project__c = :projectId AND RecordType.DeveloperName = 'Material_Budget'];
        
        return projectTaskList;
    }
    
    /*********************************************************************
     - Qry the contact related Active Project records
     - Added by sukanya on May 17 2018
    **********************************************************************/
    @RemoteAction
    global static List<AcctSeed__Project__c> projectsBasedonContact(String contactId) {
        List<AcctSeed__Project__c> projectList = new List<AcctSeed__Project__c>();
        projectList = [SELECT Id,Name,DLS_Class__c,Start_Date__c,End_Date__c,Training_Location__c,Training_Location__r.Name
                        FROM AcctSeed__Project__c 
                        WHERE AcctSeed__Status__c IN ('Active','Order') AND Id IN (SELECT Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c = :contactId)];
        
        return projectList;
    }
    
}