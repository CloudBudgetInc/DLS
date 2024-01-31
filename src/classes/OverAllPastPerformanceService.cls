/**********************************************************************
    Created by Vinitha on Jan 6 2017: Service class used for Overall_Past_Performance__c object
***********************************************************************/
public with sharing class OverAllPastPerformanceService {

    /**********************************************************************
        Created by Vinitha on Jan 6 2017: This method return list of OverAllPastPerformance with one condition
         @LanguageSet - set of OverAllPastPerformance record ids         
         return - list of OverAllPastPerformance records
    ***********************************************************************/

    public Static List<Overall_Past_Performance__c> getOverallBylanguage(String filterQry,String parentFields, Set<String> LanguageSet) {
        list<Overall_Past_Performance__c> overAllrecords = new list<Overall_Past_Performance__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Overall_Past_Performance__c');
        String defaultQry = 'SELECT '+fieldName +' FROM Overall_Past_Performance__c' ;         

        if(parentFields != null && parentFields != ''){
           defaultQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Overall_Past_Performance__c';
        }

        if(filterQry != null && filterQry != '' && LanguageSet != null && LanguageSet.size() > 0){
            defaultQry = defaultQry + filterQry+'IN :LanguageSet';            
        }              
        overAllrecords = Database.query(defaultQry);           
        return overAllrecords;
    }   
}