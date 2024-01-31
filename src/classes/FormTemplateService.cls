public without sharing class FormTemplateService {
    
    public static Form_Template__c getFormTempWithFormTempElements(String filterQuery){
         
        Form_Template__c formTemp = new Form_Template__c();
        String qryStr = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Form_Template__c')+  
                                     ' ,(SELECT '+ SObjectQueryService.getSObjectFieldsBySObjectNameExceptBlob('Form_Template_Element__c')+
                                     ' FROM Form_Template_Elements__r ORDER BY Sequence__c ASC)'+
                                     ' FROM Form_Template__c';
                                    
        if(String.isNotBlank(filterQuery)) {
             qryStr += ' WHERE '+filterQuery;
        }
                
        List<Form_Template__c> formTempList = database.query(qryStr );
        if(formTempList.size() > 0){
            formTemp = formTempList[0];
        }     

        return formTemp;    
    }
}