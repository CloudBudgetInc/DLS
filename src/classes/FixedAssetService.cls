/***************************************************
    Developed by GRK on 16 Aug, 2018
******************************************************/
Public Class FixedAssetService {
    public Static List<AcctSeed__Fixed_Asset__c> getFixedAssets(Set<Id> parentIds,String filterQuery,String parentFields) {
        List<AcctSeed__Fixed_Asset__c> fAs = new List<AcctSeed__Fixed_Asset__c>();
        String defaultFAQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Fixed_Asset__c')+
                                parentFields+                                       
                            ' FROM'+
                                ' AcctSeed__Fixed_Asset__c';
                               
        if(filterQuery != null && filterQuery != '') {
            defaultFAQry += filterQuery;
        }
        
        if(parentIds != null && parentIds.size() > 0){
            defaultFAQry += ' IN :parentIds';
        }
        System.debug('defaultFAQry :::::'+defaultFAQry);
        fAs = database.query(defaultFAQry);                           
        return fAs;
    }
}