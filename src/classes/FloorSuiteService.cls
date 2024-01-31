/**********************************************************************
    Created by Vinitha on Feb 14 2017: Service class used for Floor_Suite__c object
***********************************************************************/
public with sharing class FloorSuiteService {
    
     /**********************************************************************
        Created by Vinitha on Feb 14 2017: This method return list of FloorSuite 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of FloorSuite records
    ***********************************************************************/  
    
    public Static List<Floor_Suite__c> getFloorsuite(String filterQrystr, String parentFields,Set<Id> parentId,String limitQry) {
    
        List<Floor_Suite__c> floorsuiteList = new List<Floor_Suite__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Floor_Suite__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Floor_Suite__c';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Floor_Suite__c';
        }
        if(filterQrystr != null && filterQrystr != '' && parentId != null && parentId.size() > 0){
            defalutQry = defalutQry + filterQrystr + 'IN :parentId'+ limitQry;           
        } else if(filterQrystr != null && filterQrystr != '' ){
            defalutQry = defalutQry + filterQrystr + limitQry;
        } 
        
        floorsuiteList = Database.query(defalutQry);        
        return floorsuiteList;        
    
    }
}