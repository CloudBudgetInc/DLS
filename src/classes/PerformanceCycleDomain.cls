public class PerformanceCycleDomain {
    public class formResAndPeers{
        @AuraEnabled public Form_Response__c formResponse;
        @AuraEnabled public List<Form_Response__c> peerSummaryFormResponses;
        @AuraEnabled public string contactFilter;
    }
    
    public class formResAndTemp{
        @AuraEnabled public FormResponseCtrl.formTemplateWrap formTemplateAndFormTempElements;
        @AuraEnabled public Form_Response__c formResponseAndFormResElements;
    }
    
    public class dlsEmpAndConFilter{
        @AuraEnabled public Map<String, List<Contact>> dlsEmp;
        @AuraEnabled public string contactFilter;
    }
}