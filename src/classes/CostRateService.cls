/**********************************************************************
    Created by Vinitha on Feb 2 2017: Service class used for AcctSeed__Cost_Rates__c object
***********************************************************************/
public without sharing class CostRateService {
    
    /**********************************************************************
        Created by Vinitha on Feb 2 2017: This method return list of costRate 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of costRate records
    ***********************************************************************/  
    
    public Static List<AcctSeed__Cost_Rates__c> getCostrateRec(String filterQrystr, String parentFields) {
    
        List<AcctSeed__Cost_Rates__c> costRateList = new List<AcctSeed__Cost_Rates__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Cost_Rates__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM AcctSeed__Cost_Rates__c';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM AcctSeed__Cost_Rates__c';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        System.debug('defalutQry ============='+defalutQry );
        costRateList = Database.query(defalutQry);        
        return costRateList;        
    
    }
    
    /**********************************************************************
        Created by Karthiga on Feb 2 2017: This method return list of costRate 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        @parentIdSet - Set of Parent Id
        return - list of costRate records
    ***********************************************************************/  
    public Static List<AcctSeed__Cost_Rates__c> getCRByParentId(String filterQrystr, String parentFields,set<Id> parentIdSet) {
    
        List<AcctSeed__Cost_Rates__c> costRateList = new List<AcctSeed__Cost_Rates__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Cost_Rates__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM AcctSeed__Cost_Rates__c';
        if(parentFields != null && parentFields != ''){
            defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM AcctSeed__Cost_Rates__c';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        if(parentIdSet != null && parentIdSet.size() > 0){
            defalutQry += ' IN : parentIdSet';      
       } 
        costRateList = Database.query(defalutQry);        
        return costRateList;        
    }
     /**********************************************************************
        Created by SivaPrasanth on June 19 2020: This method return list of costRate 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        @parentIdSet - Set of Parent Id
  		@limitQry - limit condition
        return - list of costRate records
    ***********************************************************************/  
    public Static List<AcctSeed__Cost_Rates__c> getCostRateByParentId(String filterQrystr, String parentFields,Set<Id> parentIdSet,String limitQry) {
    
        List<AcctSeed__Cost_Rates__c> costRateList = new List<AcctSeed__Cost_Rates__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Cost_Rates__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM AcctSeed__Cost_Rates__c';
        
        if(parentFields != null && parentFields != ''){
            defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM AcctSeed__Cost_Rates__c';
        }
        
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        
        if(parentIdSet != null && parentIdSet.size() > 0){
            defalutQry += ' IN : parentIdSet';      
        }
        
        if(String.isNotBlank(limitQry)){
            defalutQry += limitQry;      
        } 
        costRateList = Database.query(defalutQry);        
        return costRateList;        
    }
}