public  without sharing class CommunityCaseListView_Controller {
    
    @AuraEnabled
    public static CaseViewWrapper getInitialCaseRecords() {
        
        CaseViewWrapper caseWrap = new CaseViewWrapper();
        List<String> filterPickList = new List<String>{'All Cases','Open Cases','Closed Cases'};
        List<Case> caseLst = new List<Case>();
        Id usrId = UserInfo.getUserId();
        List<User> userLst = [Select ContactId from User where Id = :usrId];
        if( userLst != null && userLst.size() > 0 ){
            if(userLst[0].ContactId != null){
                caseLst = [SELECT Id,CaseNumber,ContactId,Contact_Name__c,Status,Subject,Priority,CreatedDate,IsClosedOnCreate FROM Case WHERE ContactId =: userLst[0].ContactId];
            }
        }
        caseWrap.filterPickList = filterPickList;
        caseWrap.caseListRecords = caseLst;
        caseWrap.communityName =  EventCalendarController.getCommunityPathPrefix();
        return caseWrap;
    }
    
    public class CaseViewWrapper{
        @AuraEnabled
        public List<String> filterPickList;
        @AuraEnabled
        public List<Case> caseListRecords;
        @AuraEnabled
        public String communityName;
    }
    
    
}