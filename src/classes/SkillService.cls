/**********************************************************************
    Created by Vinitha on Feb 2 2017: Service class used for Skill__c object
***********************************************************************/
public with sharing class SkillService {
    
     /**********************************************************************
        Created by Vinitha on Feb 2 2017: This method return list of Skill 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of Skill records
    ***********************************************************************/  
    
    public Static List<Skill__c> getSkillRec(String filterQrystr, String parentFields) {
    
        List<Skill__c> skillList = new List<Skill__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Skill__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Skill__c';
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName + parentFields + ' FROM Skill__c';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;           
        } 
        skillList = Database.query(defalutQry);        
        return skillList;        
    
    }
    /**********************************************************************
        Created by Kuppulakshmi on Mar 3 2017: This method return list of Skill 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        parentId - set of parentId
        return - list of Skill records
    ***********************************************************************/  
    public Static List<Skill__c> getSkillRecbyId(String filterQrystr, String parentFields,Set<Id> parentId) {
    
        List<Skill__c> skillList = new List<Skill__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Skill__c');
        String defalutQry = 'SELECT '+ fieldName +parentFields+' FROM Skill__c';
        if(parentId != null && parentId.size()>0){
           defalutQry += filterQrystr + ' IN :parentId';
        }
        System.debug('defalutQry::::'+defalutQry);
        skillList = Database.query(defalutQry);        
        return skillList;        
    
    }
}