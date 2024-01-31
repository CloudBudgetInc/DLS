/**********************************************************************
    Created by Shalini on Jan 30 2017: Translator class used for Opportunity object inner class formation
***********************************************************************/

global class OpportunityTranslator {

    /**********************************************************************
        Modified by Shalini on Jan 30 2017: Translator class used for OpportunityBudgetInfoComponent_Ctrl inner class formation
    ***********************************************************************/
    
    global static OpportunityDomain.WrapperOppBudgetInfo OppBudgetInfoMethod(List<Payment_Item__c> payItemList,List<Schedule__c> scheduleList,List<OpportunityLineItem> oppLineItemList,List<Opportunity> oppList,List<Materials_Request__c> materialRequests,List<AcctSeed__Project__c> projects,List<RecordType> matReqRecTypeList) {
     
     OpportunityDomain.WrapperOppBudgetInfo OppBudgetInfo = new OpportunityDomain.WrapperOppBudgetInfo();
     OppBudgetInfo.paymentItems = payItemList;
     OppBudgetInfo.schedules = scheduleList;
     OppBudgetInfo.oppLineItems = oppLineItemList;
     OppBudgetInfo.opportunities = oppList;
     OppBudgetInfo.materialRequestList = materialRequests;
     OppBudgetInfo.projectList =projects;
     OppBudgetInfo.matReqRecTypes = matReqRecTypeList;
     
     return OppBudgetInfo;
     
    }
}