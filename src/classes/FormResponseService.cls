public class FormResponseService {
    public static Form_Response__c getFormResWithFormResElements(String filterQuery, String parentFields){
         
        Form_Response__c formRes = new Form_Response__c();
        String qryStr = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Form_Response__c')+  (String.isNotBlank(parentFields) ? parentFields : '') +
                                     ' ,(SELECT '+ SObjectQueryService.getSObjectFieldsBySObjectNameExceptBlob('Form_Response_Element__c')+
                                     ' FROM Form_Response_Elements__r ORDER BY Question__r.Sequence__c ASC)'+
                                     ' FROM Form_Response__c';
                                    
        if(String.isNotBlank(filterQuery)) {
             qryStr += ' WHERE '+filterQuery;
        }
                
        List<Form_Response__c> formResList = database.query(qryStr );
        if(formResList.size() > 0){
            formRes = formResList[0];
        }     

        return formRes;    
    }
    
    public static List<Form_Response__c> getFormResWithFormResElements(String filterQuery, String parentFields, String formResEleParentFields){
         
        String qryStr = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Form_Response__c')+  (String.isNotBlank(parentFields) ? parentFields : '') +
                                     ' ,(SELECT '+ SObjectQueryService.getSObjectFieldsBySObjectNameExceptBlob('Form_Response_Element__c')+ (String.isNotBlank(formResEleParentFields) ? formResEleParentFields : '') +
                                     ' FROM Form_Response_Elements__r ORDER BY Question__r.Sequence__c ASC)'+
                                     ' FROM Form_Response__c';
                                    
        if(String.isNotBlank(filterQuery)) {
             qryStr += ' WHERE '+filterQuery;
        }
                
        List<Form_Response__c> formResList = database.query(qryStr );
        
        return formResList;    
    }
}