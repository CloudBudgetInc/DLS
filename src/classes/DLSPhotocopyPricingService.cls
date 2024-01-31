/**********************************************************************
    Created by Shalini on Feb 23 2017: Service class used for DLS_Photocopy_Pricing__c object
***********************************************************************/

public with sharing class DLSPhotocopyPricingService {

    /**********************************************************************
        Created by Shalini on Feb 2 2017: This method return list of DLS_Photocopy_Pricing__c
        return - list of DLS_Photocopy_Pricing__c records
    ***********************************************************************/ 
    
    public Static List<DLS_Photocopy_Pricing__c> getprice() {
        
        List<DLS_Photocopy_Pricing__c> priceList = new List<DLS_Photocopy_Pricing__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('DLS_Photocopy_Pricing__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM DLS_Photocopy_Pricing__c';
        
        system.debug(':::::defalutQry:::::::'+defalutQry);
        priceList = Database.query(defalutQry);
        system.debug(':::::priceList:::::::'+priceList);        
        return priceList;              
    }
}