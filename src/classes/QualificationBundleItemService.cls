/**********************************************************************
    Created by Sukanya on Feb 28 2017: Service class used for Qualification_Bundle_Item__c object
***********************************************************************/

public with sharing class QualificationBundleItemService {

    /**********************************************************************
        Created by Sukanya on Feb 28 2017: This method returns list of Qualification_Bundle_Item__c records  
        @fltrqryStr - Pass where Conditions
        @parentFields - Pass parent field names
        return - List of Qualification_Bundle_Item__c records
    ***********************************************************************/  
    
    public Static List<Qualification_Bundle_Item__c> getQualificationBundleItems(String filterQrystr, String parentFields,Set<Id> qualificationIds) {
        
        List<Qualification_Bundle_Item__c> qualBundleItemList = new List<Qualification_Bundle_Item__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Qualification_Bundle_Item__c');
        String defaultQry = 'SELECT '+ fieldName + parentFields + ' FROM Qualification_Bundle_Item__c';
        
        if(filterQrystr != null && filterQrystr != ''){
            defaultQry += filterQrystr;
        }
        
        if(qualificationIds != null && qualificationIds.size() > 0) {
            defaultQry += 'AND Id NOT IN :qualificationIds';
        }
       
        system.debug('QualificationBundleService:::::BundleItems:::::::'+defaultQry);
        qualBundleItemList = Database.query(defaultQry);        
        return qualBundleItemList;              
    }
    
    /**********************************************************************
        Created by Sukanya on Feb 28, 2017: This method return newly created list of Qualification_Bundle_Item__c records 
        @materialRequestList - List of Qualification Bundle Item records
        return - list of Qualification Bundle Item records
    ***********************************************************************/ 
    public static List<Qualification_Bundle_Item__c> qualificationBundleItemsCreation(List<Qualification_Bundle_Item__c> bundleItemList) {
    
        if(bundleItemList != null && bundleItemList.size() > 0){
            insert bundleItemList;            
        }
        return bundleItemList;    
    } 
    
}