/**********************************************************************
    Created by Vinitha on Jan 10 2017: Service class used for Action_Plan__c object
***********************************************************************/
public with sharing class ActionPlanService {

     /**********************************************************************
        Created by Vinitha on Jan 10 2017: This method return list of actionPlan 
        @fltrqryStr - pass where Conditions
        return - list of actionPlan records
    ***********************************************************************/ 
    
    public Static List<Action_Plan__c> getActionplan(String filterQrystr) {
     
        List<Action_Plan__c> actionPlanlist= new List<Action_Plan__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Action_Plan__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Action_Plan__c';        
        system.debug(':::::::defaultQry:::::::'+defalutQry);
        system.debug(':::::::filterQrystr:::::::'+filterQrystr);
        
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;            
        }              
        
        actionPlanlist = Database.query(defalutQry);        
        return actionPlanlist;   
    } 
    
    
     /**********************************************************************
        Created by Vinitha on Jan 10 2017: This method return list of actionPlan 
        @assessId - Id of actionPlan records
        return - list of actionPlan records
    ***********************************************************************/    
    /*public static list<Action_Plan__c> getActionplan(String assessId) {
        
        List<Action_Plan__c> ActionPlanCreationList = new List<Action_Plan__c>();
        if(assessId != null){            
            ActionPlanCreationList = [
                                SELECT
                                    Id,
                                    Assessment_Report__c,
                                    From_Date__c,
                                    To_Date__c,Activity__c
                                FROM
                                    Action_Plan__c
                                WHERE
                                    Assessment_Report__c = :assessId
                                ];
        }
        return ActionPlanCreationList; 
    }  */  
    
    /**********************************************************************
        Created by Vinitha on Jan 10 2017: This method return list of actionPlan 
        @actionPlanlist - List of actionPlan records
        return - list of actionPlan records
    ***********************************************************************/ 
    public static list<Action_Plan__c> insertActionplan(List<Action_Plan__c> actionPlanlist) {
    
        if(actionPlanlist != null && actionPlanlist.size() > 0){
            insert actionPlanlist;            
        }
        return actionPlanlist;    
    } 
    /**********************************************************************
        Created by Vinitha on Jan 10 2017: This method return list of actionPlan 
        @actionPlanlist - List of actionPlan records
        return - list of actionPlan records
    ***********************************************************************/ 
    public static list<Action_Plan__c> updateActionplan(List<Action_Plan__c> actionPlanlist) {
    
        if(actionPlanlist != null && actionPlanlist.size() > 0){
            update actionPlanlist;            
        }
        return actionPlanlist;    
    }
    /**********************************************************************
        Created by Vinitha on Jan 10 2017: This method return list of actionPlan 
        @actionPlanlist - List of actionPlan records
        return - list of actionPlan records
    ***********************************************************************/ 
    public static list<Action_Plan__c> deleteActionplan(List<Action_Plan__c> actionPlanlist) {
    
        if(actionPlanlist != null && actionPlanlist.size() > 0){
            delete actionPlanlist;            
        }
        return actionPlanlist;    
    } 
    
}