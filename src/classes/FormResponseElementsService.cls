public  without sharing class FormResponseElementsService {

    public static List<Form_Response_Element__c> getFormResElementsByQuestion(String filterQuery, Set<Id> questionIds){
         
        
        String qryStr = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Form_Response_Element__c')+                                      
                        ' FROM Form_Response_Element__c';
        
        if(String.isNotBlank(filterQuery) || (questionIds != null && questionIds.size() > 0)){
            qryStr += ' WHERE ';
        }                
        if(String.isNotBlank(filterQuery)) {
            qryStr += filterQuery;
        }
        if(questionIds != null && questionIds.size() > 0){
            qryStr += ' Question__c IN :questionIds';
        }
         
        return database.query(qryStr );
    }
}