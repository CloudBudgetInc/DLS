/**********************************************************************
    Created by Shalini on Feb 16 2017: Service class used for Qualification_Bundle__c object
***********************************************************************/

public with sharing class QualificationBundleService {

    /**********************************************************************
        Created by Shalini on Feb 16 2017: This method returns list of Qualification_Bundle__c records  
        @fltrqryStr - Pass where Conditions
        @parentFields - Pass parent field names
        return - List of Qualification_Bundle__c records
    ***********************************************************************/ 
    
    public Static List<Qualification_Bundle__c> getQualificationBundles(String filterQrystr, String parentFields) {
       
        List<Qualification_Bundle__c> qualBundleList = new List<Qualification_Bundle__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Qualification_Bundle__c');
        String defaultQry = 'SELECT '+ fieldName + parentFields + ' FROM Qualification_Bundle__c';
        
        if(filterQrystr != Null && filterQrystr != ''){
            defaultQry += filterQrystr;
        }
       
        system.debug('QualificationBundleService:::::Bundles:::::::'+defaultQry);
        qualBundleList = Database.query(defaultQry);        
        return qualBundleList;              
    }
    
    /**********************************************************************
        Created by Sukanya on Feb 28 2017: This method returns list of Qualification_Bundle__c records with bundle Items  
        @fltrqryStr - Pass where Conditions
        @parentFields - Pass parent field names
        return - List of Qualification_Bundle__c & Bundle Items records
    ***********************************************************************/ 
    
    public Static List<Qualification_Bundle__c> getQualificationBundleswithBundleItems(String filterQrystr, String parentFields) {
       
        List<Qualification_Bundle__c> qualBundleList = new List<Qualification_Bundle__c>();
        
        String defaultQry = 'SELECT '+ 
            
            SObjectQueryService.getSObjectFieldsBySObjectName('Qualification_Bundle__c') +
            ',Contract__r.Name,'+
            '(SELECT '+ SObjectQueryService.getSObjectFieldsBySObjectName('Qualification_Bundle_Item__c') +
                ',Qualification__r.Type__c, Qualification__r.Value__c, Qualification__r.Condition__c '+
                'FROM Qualification_Bundle_Items__r)'+
            ' FROM Qualification_Bundle__c';
        
        if(filterQrystr != null && filterQrystr != '')
            defaultQry += filterQrystr;
       
        system.debug('QualificationBundleService:::::Bundles::with bundle:::Items:::::'+defaultQry);
        qualBundleList = Database.query(defaultQry);        
        return qualBundleList;              
    }

     /**********************************************************************
        Created by Sukanya on Feb 28, 2017: This method return newly created list of Qualification_Bundle__c records 
        @materialRequestList - List of Qualification Bundle records
        return - list of Qualification Bundle records
    ***********************************************************************/ 
    public static List<Qualification_Bundle__c> qualificationBundleCreation(List<Qualification_Bundle__c> bundleList) {
    
        if(bundleList != null && bundleList.size() > 0){
            insert bundleList;            
        }
        return bundleList;    
    } 
}