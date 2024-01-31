/**********************************************************************
    Created by Shalini on Jan 30 2017: Domain class used for Opportunity object inner class formation
***********************************************************************/

global class OpportunityDomain {

    /**********************************************************************
        Modified by Shalini on Jan 30 2017: Domain class used for OpportunityBudgetInfoComponent_Ctrl inner class formation
        Modified by Sukanya in Feb 1 2017: To add Materials_Request__c list 
    ***********************************************************************/
    global Class WrapperOppBudgetInfo {
            
            public List<Payment_Item__c> paymentItems;
            public List<Schedule__c> schedules;
            public List<OpportunityLineItem> oppLineItems;
            public List<Opportunity> opportunities;
            public List<Materials_Request__c> materialRequestList;
            public List<AcctSeed__Project__c> projectList;
            public List<RecordType> matReqRecTypes;
    }
}