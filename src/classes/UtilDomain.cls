/**********************************************************************
    Created by Sukanya on Jan 11 2017: Domain class used for ContentVersion,Material object inner class formation
***********************************************************************/

global class UtilDomain {
    
    /**********************************************************************
        Created by Sukanya on Jan 11 2017: Domain class used for LibraryDetailController_Component data
    ***********************************************************************/
    global Class ContentandMaterialRecordsInfo {
        
        @AuraEnabled public List<User> userDetail;
        @AuraEnabled public List<ContentVersion> FavouriteContents;
        @AuraEnabled public List<Materials__c> FavouriteMaterials;
        @AuraEnabled public List<ContentVersion> TopRateContents;
        @AuraEnabled public List<Materials__c> TopRateMaterials;
        @AuraEnabled public List<ContentVersion> MatReqContents;
        @AuraEnabled public List<Materials__c> MatReqMaterials;
        @AuraEnabled public List<ContentVersion> MostReqContents;
        @AuraEnabled public List<Materials__c> MostReqMaterials;
        @AuraEnabled public List<RecordType> recordTypeDetail;
        @AuraEnabled public List<Materials_Request__c> materialRequestInternal;
        @AuraEnabled public List<Contact_Assignments__c> materialReqOppRelatedConAssign;
        @AuraEnabled public List<RecordType> materialReqRTList;
        @AuraEnabled public Integer RecordsCount;
        @AuraEnabled public List<Materials_Request__c> orderRequests;
        @AuraEnabled public List<Materials_Request__c> loanRequests;
    }
    
    /**********************************************************************
        Created by Sukanya on Jan 11 2017: Domain class used for LibraryDetailController_Component request creation data
    ***********************************************************************/
    
    global Class InternalProjectOppInfo {
        
        public List<AcctSeed__Project_Task__c> projectTaskList;
        public List<Contact_Assignments__c> projectContactAssignment;
        public List<OpportunityLineItem> oppLineList;
        public List<Contact_Assignments__c> oppContactAssignment;
    }
    
    /**********************************************************************
        Created by Sukanya on Jan 11 2017: Domain class used for MRequest_MFavou_MTrans_TopRated_Compon contentVersion & material data
    ***********************************************************************/
    
    global class contentMaterialInfo {
    
        public List<ContentVersion> contentList;
        public List<Materials__c> materialsList;
    }
    
     /**********************************************************************
        Created by Sukanya on Jan 11 2017: Domain class used for LibraryContentDetailController_Component Material request creation for ContentVersion
    ***********************************************************************/
    
    global class contentUserProjectInfo {
    
        public String contactId;
        public String contactType;
        public List<Contact_Assignments__c> projectContactAssignment;
    }
    
    /**********************************************************************
        Created by Sukanya on June 5 2017: Domain class used 
        for ConvertToProject time card period,time card, time card line,time card day
        inner class formation from time log records
    ***********************************************************************/
    
    global class tcdInnerCls {
        public AcctSeed__Time_Card_Day__c tcd;
        public String projTaskName;
        public Id ContId;
        public Boolean Billable;
        public String contName;
        public Boolean error;
        public Time_Log__c tlg;
        public String tcl;
        public String tc;
        
        public tcdInnerCls(AcctSeed__Time_Card_Day__c tcdt,Id cId,String CName, Boolean b, String ptNa, Time_Log__c tl) {
            tcd = tcdt;
            ContId = cId;
            error = false;
            contName = CName;
            Billable = b;
            projTaskName = ptNa;
            tlg = tl;
        }
    }
    
    /**********************************************************************
        Created by Sukanya on June 5 2017: Domain class used 
        for ConvertToProject to timeCard_Creation_FromCTP batch class parameter details
    ***********************************************************************/
    global class batchParameters {
        
        public Id oppId;
        public Map<String,String> contServItemPtName;
        public Map<String,Id> projectTaskNameWithProjectTaskId;
        
        public Set<Date> startdtSet;  // For Time Card Period Query Week Start Date Set
        public Set<Date> enddtSet;    // For Time Card Period Query Week End Date Set
        public Map<Date,Date> stdateandEnddtMap;
        public List<Date> tlDateSet;     // Time Log Dates     
        public Set<Date> monthStartdtSet; // For Accounting Period 
        public Set<Date> monthEnddtSet;   // For Accounting Period
        public Map<Id,Map<Date,Date>> contIdWithStAndEndDateMap;
        public Set<Id> ContIds;
        public Map<String,String> PayRollValuesMap;
        
        public Id newProjectId;
        public Set<Id> existingTLIds;
        public Set<Id> oppIds;
        public Set<Id> projectIds;
        public Map<Id,Id> oppIdProjectIdMap;
        public Map<String,Id> proId_TaskName_TaskId;
    }
    
    /**********************************************************************
        Created by Sukanya on June 8 2017: Domain class used 
        for ConvertToProject Events record updation
    ***********************************************************************/
    
    public Class EventInnerClass {
        public Events__c evt {get; set;} 
        public String ContactRecordType {get; set;}
        public Boolean error {get; set;}
        public Date oldDate {get; set;}
        public String errorMsg {get; set;}
        public List<events__c> evntList {get; set;}
        
        public EventInnerClass (Events__c ET, String rT, Date oldDt) {
            evt = ET;
            ContactRecordType = rt;
            oldDate = oldDt;
            error = false;
            errorMsg = '';
            evntList = new List<Events__c>();
        }      
    }  
    
    /**********************************************************************
        Created by Sukanya on June 14 2017: Error Class for Batch Exception Handling process
    ***********************************************************************/
    
    public class ErrorWrapper {
        public sObject record;
        public String message;
        public String objectType;
        
        public ErrorWrapper(sObject rec,String msg,String objType){
            record = rec;
            message = msg;
            objectType = objType;
        }
    }
    
    /******************************************************************************************************
    - Created to handle the 15MB size exceed error when querying all the records without any condition in Library Search
    - Added by NS on May 8 2019
    ******************************************************************************************************/
    global class SearchResultInfo {
    
        public List<ContentVersion> contentRecords;
        public List<Materials__c> materialRecords;
        public List<FilterDetails> formatValues;
        public List<FilterDetails> languageValues;
        public List<FilterDetails> seriesValues;
        public List<FilterDetails> dlsSectionValues;
        public Integer materialCVRecordsCnt;
    }
    
    public class FilterDetails {
    
        public String label;
        public String value;
    }
    
    /******************************************************************************************
    - Added by NS on June 24 2019
    - For Lightning Library Search cmp
    ******************************************************************************************/
    public class MRFilterDetails {
    
        public List<FilterDetails> locationValues;
        public List<FilterDetails> recordTypeValues;
        public Map<Id,String> rtIdDeveloperNameMap;
    }
    
}