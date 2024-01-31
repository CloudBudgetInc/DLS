/**********************************************************************
    Created by Arun on Jan 23, 2017: Service class used for Schedule__c
***********************************************************************/
public with sharing Class ScheduleService {
 
 /**********************************************************************
        Created by Arun on Jan 23 2017: 
        @conIdSet - Set of Contact Ids
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        return - List of Schedule
 ***********************************************************************/
 
    public Static List<Schedule__c> getSchedulesByContIds(Set<Id> conIdSet,String filterQuery,String parentFields) {
        List<Schedule__c> scheduleList = new List<Schedule__c>();
        String defaultScheduleQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Schedule__c')+
                                    parentFields+                                       
                                ' FROM'+
                                    ' Schedule__c';
                                   
         if(filterQuery != null && filterQuery != '') {
             defaultScheduleQry += filterQuery;
         }
         if(filterQuery == '' && conIdSet != null && conIdSet.size() > 0){
             defaultScheduleQry += ' WHERE Instructor__c IN :conIdSet';
         } else if(conIdSet != null && conIdSet.size() > 0){
             defaultScheduleQry += ' Instructor__c IN :conIdSet';
         }
         System.debug('defaultScheduleQry :::::'+defaultScheduleQry );
         scheduleList = database.query(defaultScheduleQry);                           
         return scheduleList;
    }
    
    /**********************************************************************
        Created by Shalini on Feb 14 2017: 
        @oppIdSet - Set of Opportunity Ids
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        return - List of Schedules
 ***********************************************************************/
    
    public Static List<Schedule__c> getSchedulesByOppIds(Set<Id> oppIdSet,String filterQuery,String parentFields) {
        List<Schedule__c> scheduleList = new List<Schedule__c>();
        String defaultScheduleQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Schedule__c')+
                                    parentFields+                                       
                                ' FROM'+
                                    ' Schedule__c';
                                   
         if(filterQuery != null && filterQuery != '') {
             defaultScheduleQry += filterQuery;
         }
         if(filterQuery == '' && oppIdSet != null && oppIdSet.size() > 0){
             defaultScheduleQry += ' WHERE Opportunity__c IN :oppIdSet';
         } else if(oppIdSet != null && oppIdSet.size() > 0){
             defaultScheduleQry += ' AND Opportunity__c IN :oppIdSet';
         }
         System.debug('defaultScheduleQry :::::'+defaultScheduleQry );
         scheduleList = database.query(defaultScheduleQry);                           
         return scheduleList;
    }
    
    /**********************************************************************
        Created by Shalini on Feb 14 2017: 
        @scheduleList - List of Schedules to update.
        return - List of Schedules.
    ***********************************************************************/  
    public static List<Schedule__c> updateSchedule(List<Schedule__c> scheduleList){
        if( scheduleList != null && scheduleList.size() > 0 ) {
            update scheduleList;
            
            return scheduleList;
        }
        return null;
    }
    
      /**********************************************************************
        Created by Vinitha on Feb 20 2017: This method return list of Schedule__c
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        @parentId - pass parentId field
        return - list of Schedule__c records
    ***********************************************************************/  
    
    public Static List<Schedule__c> getScheduleRec(String filterQrystr, String parentFields,Set<Id> parentId) {
    
        List<Schedule__c> scheduleList = new List<Schedule__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Schedule__c');
        String defalutQry = 'SELECT '+ fieldName + parentFields + ' FROM Schedule__c';
        
        if(filterQrystr != null && filterQrystr != '' && parentId != null && parentId.size() > 0){
            defalutQry = defalutQry + filterQrystr + 'IN :parentId';           
        } else if(filterQrystr != null && filterQrystr != '' ){
            defalutQry = defalutQry + filterQrystr;
        }
        System.debug(':::defalutQry::'+defalutQry);
        scheduleList = Database.query(defalutQry);        
        return scheduleList;        
    
    }
    

}