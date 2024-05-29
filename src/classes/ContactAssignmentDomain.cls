/**********************************************************************
Created by Karthiga on Feb 06, 2017: Domain class used for Contact Assignment object inner class formation
***********************************************************************/

global class ContactAssignmentDomain {
    
    /**********************************************************************
Created by Karthiga on Feb 06, 2017: Domain class used for AssignmentTabComponent inner class formation
***********************************************************************/
    global Class InstructorAssignInnerClass{
        //public Boolean isEdit {get; set;}
        //public Integer Index {get; set;}
        public Contact_Assignments__c conAssign {get; set;}
        public List<SelectOption> costRates {get; set;}
        public Decimal cRVal {get; set;}
        public Boolean hasOPLIPT {get; set;}
        public Boolean isAwarded {get; set;}
        //public Boolean AssignToActiveSchedules {get; set;}
    }
    
    /************************************************************
     - To use the following classes in CA Lightning Component class - ContactAssignmentLightningCtrl
    *************************************************************/
    public class CostRateDetails {
        
        @AuraEnabled
        public Boolean isFirstCR;
        @AuraEnabled
        public String costRateMessage;
        @AuraEnabled
        public Boolean createNewCR;
        @AuraEnabled
        public String defaultCR;
        @AuraEnabled
        public Boolean displayEffectiveDate;
        @AuraEnabled
        public Boolean isAlreadyCRExist;
        @AuraEnabled
        public String rateCardRate;
        @AuraEnabled
        public String draftedLaborCostRate; 
        @AuraEnabled
        public String costLabel;
        @AuraEnabled
        public String contactRTName;
        @AuraEnabled
        public Boolean createCAWithoutCR;
    }
    
    public class MultiplePayRateCostRate{
        
        @AuraEnabled
        public Boolean isSelectedVal;
        @AuraEnabled
        public String costRateMsg;
        @AuraEnabled
        public String crId;
        @AuraEnabled
        public Boolean isApproved;
        @AuraEnabled
        public String costRateName;
        @AuraEnabled
        public Decimal fullyLoadedAmt;
        @AuraEnabled
        public Decimal lcrmHourlyCost;
        @AuraEnabled
        public Decimal crHourlyFFPCost;
        @AuraEnabled
        public Decimal DLIGroupHCCost;
    }
    
    public class WrapperContactAssign{
        
        @AuraEnabled
        public List<String> wrapTabNames;
        @AuraEnabled
        public string wrapActiveTab;
        @AuraEnabled
        public List<ContactAssignmentWrapper> wrapConAssignList;
        @AuraEnabled
        public List<string> wrapStatuspickList; 
        @AuraEnabled
        public boolean wrapIsDisplayAction;
        @AuraEnabled
        public String wrapProjectId;
        @AuraEnabled
        public String costRate;
        @AuraEnabled
        public String parentRecordType;
        @AuraEnabled
        public String defaultCostRate;
        @AuraEnabled
        public Map<Id,String> opliMap; 
        @AuraEnabled
        public Map<String,Integer> cACostRAteChildCountMap; 
        @AuraEnabled
        public Boolean payRateModifyPermissionAccess; 
        @AuraEnabled
        public Map<Id,Integer> insIdWithSumTotalEventMap;        
    }
    public class GenOfferLetterWrapper {
        
        @AuraEnabled public String getServerUrlSessionId;
        @AuraEnabled public Map<String, Id> getQryMap;
        @AuraEnabled public  String  OffLetterTemId;
        @AuraEnabled public  String ConditionFailed;
        @AuraEnabled public  List<string> fieldsEmpty;
        @AuraEnabled public  Contact_Assignments__c contactAssigns;
        
    }
    //CAAddEditController
    public class CADetails {
        @AuraEnabled
        public Contact_Assignments__c caRecord;
        @AuraEnabled
        public Id oppId;
        @AuraEnabled
        public Id projectId;
        @AuraEnabled
        public String dliProjectType;
        @AuraEnabled
        public String projectLocation;
        @AuraEnabled
        public String defaultCostRate;
        @AuraEnabled
        public String parentRecordType;
        @AuraEnabled
        public String oppStageName;
        @AuraEnabled
        public Boolean displayCRPicklist;
        @AuraEnabled
        public PicklistValues pickValues;
        @AuraEnabled
        public Map<Id,String> opliMap;
        @AuraEnabled
        public Boolean isOPLIPT;
        @AuraEnabled
        public Boolean existingAwarded;
        @AuraEnabled
        public Boolean isNew;
        @AuraEnabled
        public Date parentStDate;
        @AuraEnabled
        public Date parentEdDate;
        @AuraEnabled
        public String cRId;
        @AuraEnabled
        public Boolean isCostRateTClTCD;
        @AuraEnabled
        public String profileName;
        @AuraEnabled
        public Decimal requestedHrWeek;
        @AuraEnabled
        public Boolean showSchObservation;
    }
    public class RateCostRate {  
        @AuraEnabled
        public Id cRID;
        @AuraEnabled
        public String costName;  
    }
    public class OPLIDetail {
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String name;
    }
    public class PicklistValues {
        @AuraEnabled
        public List<String> statusValues;
        @AuraEnabled
        public List<String> scoreValues;
        @AuraEnabled
        public List<String> positionValues;
        @AuraEnabled
        public List<String> projectTaskCRValuesWord;
        @AuraEnabled
        public List<AcctSeed__Cost_Rates__c> costRateRecords;
        @AuraEnabled
        public List<AcctSeed__Project_Task__c> taskRecords;
        @AuraEnabled
        public List<OPLIDetail> opliRecords;
        @AuraEnabled
        public List<RateCostRate> costRateLst;
        @AuraEnabled
        public List<String> quantityUnits;
        @AuraEnabled
        public List<String> rateCardList;
        @AuraEnabled
        public List<Integer> noOfLaptopIssues;
        @AuraEnabled
        public List<String> timeApprovalPreferences;
    }
    public class CAViewMoreWrapper {
        @AuraEnabled public List<Contact_Assignments__c> lstConAssignment;
        @AuraEnabled public List<Equipment_Assignment__c> lstEquiAssignment;
        @AuraEnabled public List<Contact_Assignments__c> lstConAssignContactCitizen;
        @AuraEnabled public Boolean showAccountField;
        @AuraEnabled public Boolean showObservationField;
    }
    
    public class CostRateCreationInputWrapper{
        public String costStr;  
        public String effectiveDate;    
        public Boolean createNonSCALT;
        public Boolean isOppInsCA;
        public String getHourlyCost;    
        public Decimal annualCost;
        public String taxType;  
        public Boolean ftSalRT;
        public Boolean isFirstCR;
        public Decimal salaryCostPerHour;
        public String selectedTIRateType;
        public Decimal perWordCost;
        public Decimal perTestCost;  
        public String getperFFP;
        public Decimal noHrsExcepted;
        public Decimal perHourCostInput;
    }
/**********************************************************************
Created by Jain S on April 01, 2019: Wrapper class used for Contact Assignment List view in instructor community Project detail view
***********************************************************************/
    public class CAListWrapper {
        public String contactId;
        public String contactName;
        public String caId;
        public String projectId;
        public Date startDate;
        public Date endDate;
        public String status;
        public String position;
        public String recordTypeName;
    }
     public class ContactAssignmentWrapper {
         @AuraEnabled
         public Contact_Assignments__c caRecs;
         @AuraEnabled
         public String oralExamDateTime;
     }
}