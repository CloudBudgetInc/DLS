/**********************************************************************
    Created by Vinitha on Feb 14 2017: Service class used for Equipment_Assignment__c object
***********************************************************************/
public with sharing class EquipmentAssignmentService{
    
     /**********************************************************************
        Created by Vinitha on Feb 14 2017: This method return list of EquipmentAssignment 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of EquipmentAssignment records
    ***********************************************************************/  
    
    public Static List<Equipment_Assignment__c> getEquipmentassignment(String filterQrystr, String parentFields) {
    
        List<Equipment_Assignment__c> equipassList = new List<Equipment_Assignment__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Equipment_Assignment__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Equipment_Assignment__c';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Equipment_Assignment__c';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        System.debug('defalutQry::::'+defalutQry);
        equipassList = Database.query(defalutQry);        
        return equipassList;        
    
    }
}