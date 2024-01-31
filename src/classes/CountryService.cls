/**********************************************************************
    Created by Vinitha on Feb 15 2017: Service class used for Country__c CustomSetting object
***********************************************************************/
public with sharing class CountryService {
    
     /**********************************************************************
        Created by Vinitha on Feb 15 2017: This method return list of Country
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of Country records
    ***********************************************************************/  
    
    public Static List<Country__c> getCountryRec(String filterQrystr, String parentFields) {
    
        List<Country__c> countryList = new List<Country__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Country__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Country__c';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Country__c';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        countryList = Database.query(defalutQry);        
        return countryList;     
    }
}