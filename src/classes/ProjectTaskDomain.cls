/**********************************************************************
    Created by Shalini on Jan 30 2017: Domain class used for Project Task object inner class formation
***********************************************************************/

global class ProjectTaskDomain {

    /**********************************************************************
        Modified by Shalini on Jan 30 2017: Domain class used for ProjectBudgetInfoComponent_Ctrl inner class formation
    ***********************************************************************/
    global class WrapperrecTypeProjectInfo {
        public List<RecordType> recTypes;
        public List<AcctSeed__Project_Task__c> projectTasks;
        public List<Materials_Request__c> materialRequestList;
        public List<RecordType> matReqRecTypes;
    }
    
    public class BudgetInformation{
        @AuraEnabled
        public List<ServiceInformation> serviceSectionInfo;
        @AuraEnabled
        public List<MaterialInformation> materialSectionInfo;
        @AuraEnabled
        public List<MaterialRequestInformation> materialRequestSectionInfo;
        @AuraEnabled
        public List<MaterialRequestInformation> materialLoanSectionInfo;
        @AuraEnabled
        public String projectRTName;
        @AuraEnabled
		public Boolean showBudgetSection;
    }
     /**********************************************************************
        Modified by Sivaprasanth on Apr 06 2019: Domain class used for BudgetCommunityListView  inner class formation
    ***********************************************************************/
    public class ServiceInformation{
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public String qtyPlanned;
        @AuraEnabled
        public String qtyScheduled;
        @AuraEnabled
        public String qtyUsed;
        @AuraEnabled
        public String qtyPlannedRemaining;
        @AuraEnabled
        public String remainingHourstobeScheduled;
        @AuraEnabled
        public ServiceInformation serviceInfoChildren;
        @AuraEnabled
        public Boolean isServicePTChild;
        @AuraEnabled public String qtyPaid;
        @AuraEnabled public String qtyPaidRemaining;
    }
    
    public class MaterialInformation{
        @AuraEnabled
        public String productName;
        @AuraEnabled
        public String qtyPlanned;
        @AuraEnabled
        public String price;
        @AuraEnabled
        public String extendedPrice;
        @AuraEnabled
        public String materialBudgetRequested;
        @AuraEnabled
        public String materialBudgetPaid;
        @AuraEnabled
        public String materialBudgetUsed;
        @AuraEnabled
        public String materialPaidRemaining;
    }
    public class MaterialRequestInformation{
        @AuraEnabled
        public String request;
        @AuraEnabled
        public String requestStatus;
        @AuraEnabled
        public String dateDelivered;
        @AuraEnabled
        public String materialTitle;
        @AuraEnabled
        public String materialSalesTax;
        @AuraEnabled
        public String qty;
        @AuraEnabled
        public String dlsTotal;
        @AuraEnabled
        public String contact;
        @AuraEnabled
        public String loanStatus;
        @AuraEnabled
        public String dateLoanedOut;
        @AuraEnabled
        public String dateReturned;
    }
}