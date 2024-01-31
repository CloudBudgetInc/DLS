/**********************************************************************
    Created by Karthiga on Jan 18, 2017: Service class used for Events__c
***********************************************************************/

public with sharing Class EventService {
    
     /**********************************************************************
        Created by Karthiga on Jan 18 2017: 
        @oppProjId - Set of Parent Ids
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        return - List of Event
     ***********************************************************************/
    public Static List<Events__c> getEventByParentId(Set<Id> oppProjId,String filterQuery,String parentFields) {
        
        system.debug('::::oppProjId:::::::::'+oppProjId);
        
        List<Events__c> evntList = new List<Events__c>();
        String defaultEventQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Events__c')+
                                parentFields+                                       
                                ' FROM'+
                                        ' Events__c';
         
         
         if(oppProjId != null && oppProjId.size() > 0){
             defaultEventQry += ' WHERE'+
                                    ' ( Schedule__r.Project__c IN : oppProjId'+
                                    ' OR'+ 
                                    ' Schedule__r.Opportunity__c IN : oppProjId )';
         } else if(filterQuery != null && filterQuery != '') {
             defaultEventQry += ' WHERE';
         }
         
         if(filterQuery != null && filterQuery != ''){
             defaultEventQry += filterQuery;
         }
         
         System.debug('defaultEventQry :::::'+defaultEventQry);
         evntList = database.query(defaultEventQry);                           
         return evntList ;
    }
    
    /**********************************************************************
        Created by Arun on Jan 18 2017: 
        @projId - Set of Parent Ids
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        return - List of Event
     ***********************************************************************/
    public Static List<Events__c> getEventByProjIdsAndDates(Set<Id> projIdSet,Set<Date> dateSet, String filterQuery, String parentFields) {
        List<Events__c> evntList = new List<Events__c>();
        String defaultEventQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Events__c')+
                                parentFields+                                       
                                ' FROM'+
                                        ' Events__c'+
                                    ' WHERE'+
                                        ' Project__c IN : projIdSet'+
                                        ' AND'+ 
                                        ' Date__c IN : dateSet';
         if(filterQuery != '') {
             defaultEventQry += filterQuery;
         }
         System.debug('defaultEventQry :::::'+defaultEventQry);
         evntList = database.query(defaultEventQry);                           
         return evntList ;
    }
    
     /**********************************************************************
        Created by Vinitha on Jan 31 2017: 
        @parentIdSet - Set of parent Ids
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        return - List of Event
     ***********************************************************************/
    public Static List<Events__c> getEventByparentIds(Set<Id> parentIdSet,String filterQuery,String parentFields,String ParentcondField) {
        List<Events__c> eventList = new List<Events__c>();
        String defaultEventQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Events__c')+
                                parentFields+                                       
                                ' FROM'+
                                        ' Events__c';                                    
         if(filterQuery != null && filterQuery != '' && parentIdSet != null && parentIdSet.size() > 0) {
             defaultEventQry += filterQuery+ParentcondField+' IN :parentIdSet';
         }else {
             defaultEventQry += filterQuery;
         }
         System.debug('defaultEventQry  :::::'+defaultEventQry);
         eventList = database.query(defaultEventQry);                           
         return eventList;
    }
    
    
    /**********************************************************************
        Created by Kuppulakshmi on Feb 10 2017: This method return list of Event 
        @filterQry - pass where Condition
        @dateset - pass set of Data field
    ***********************************************************************/
    
    public Static List<Events__c> getEventsByDateANDScheduleId(String filterQry,Set<Date> dateSet,Set<Id> scheduleIdSet,Set<Id> eventIdSet,String ParentcondField,String ParentField){
        List<Events__c> eventList = new List<Events__c>();
        String defaultEventQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Events__c')+ParentField+
                                ' FROM'+
                                ' Events__c';  
        if(filterQry != null && filterQry != '') {
            defaultEventQry += filterQry ;
        }
        if(dateSet == null  && scheduleIdSet == null  && eventIdSet == null ){
            defaultEventQry += ' ORDER BY Date__c ASC LIMIT 5';
        }
        else{   
            if(dateSet != null && dateSet.size() > 0){
                defaultEventQry += ' IN :dateSet';
            }
            if(scheduleIdSet != null && scheduleIdSet.size()>0 && eventIdSet != null && eventIdSet.size()>0){
                defaultEventQry += ' IN :scheduleIdSet AND '+ParentcondField+' NOT IN :eventIdSet';
            }
            else if(eventIdSet != null && eventIdSet.size()>0){
                defaultEventQry += ' AND '+ ParentcondField+' NOT IN :eventIdSet ORDER BY Date__c ASC';
            }else if(scheduleIdSet != null && scheduleIdSet.size()>0){
                defaultEventQry += ' IN :scheduleIdSet';
            }
        }
        system.debug(':::defaultEventQry:::'+defaultEventQry);
        eventList = database.query(defaultEventQry);                           
        return eventList; 
    }
     /**********************************************************************
        Created by Kuppulakshmi on Feb 13 2017: This method return list of Event 
        @filterQry - pass where Condition
        @dateset - pass set of Data field
        @InstructorIdset - pass set of InstructorId
        @parentFields - pass parentField
    ***********************************************************************/
    
    public Static List<Events__c> getEventsByDateANDInstructorId(String filterQry,Set<Date> dateSet,Set<Id> InstructorIdset,String parentFields, String ParentcondField){
        List<Events__c> eventList = new List<Events__c>();
        String defaultEventQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Events__c')
                                +parentFields+
                                ' FROM'+
                                ' Events__c'; 
        if(filterQry != null && filterQry != '') {
            defaultEventQry += filterQry ;
        }
        if(dateSet != null && dateSet.size() > 0 && InstructorIdset != null && InstructorIdset.size()>0){
            defaultEventQry += ' AND '+ParentcondField +' IN :InstructorIdset AND Date__c IN :dateSet';
        }else{
            defaultEventQry += ' AND Date__c IN :dateSet';
        }
        system.debug(':::defaultEventQry:::'+defaultEventQry);
        eventList = database.query(defaultEventQry);                           
        return eventList;
    }
    public Static List<Events__c> getEventsByroomInstructorId(String filterQry,Set<Id>InstructorIdSet,Set<Id>roomIdset,String parentFields,Set<Date> dateSet){
        List<Events__c> eventList = new List<Events__c>();
        String defaultEventQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Events__c')+
                                parentFields+                                       
                                ' FROM'+
                                        ' Events__c';
                                        
         if(dateSet != null && dateSet.size() > 0){
             defaultEventQry += filterQry +' IN :dateSet';
         }
         if(InstructorIdSet != null && InstructorIdSet.size() > 0 && roomIdset != null && roomIdset.size()>0){
             defaultEventQry += ' AND (Room__c IN :roomIdSet OR Instructor__c IN :instructorIdSet)';
         }
         
        system.debug(':::defaultEventQry:::'+defaultEventQry);
        eventList = database.query(defaultEventQry);                           
        return eventList;
    }
     public Static Integer geteventcount(String filterQry,Set<Id> projectset){
         List<AggregateResult> eventList = new List<AggregateResult>();
         String defaultEventQry = 'SELECT Count() FROM Events__c';
         if(filterQry != null && filterQry!=''){
             defaultEventQry += filterQry;
         }
         if(projectset != null && projectset.size() > 0){
             defaultEventQry +=' IN :projectset';
         }
         system.debug(':::defaultEventQry:::'+defaultEventQry);
        Integer eventcount = database.countQuery(defaultEventQry); 
        //Integer eventcount = Integer.valueof(eventList[0].get('expr0'));                          
        return eventcount;
    }
     /**********************************************************************
        Created by Vinitha on Feb 10 2017: This method return list of Event after Insertion
        @InsertionList - list of Event for insertion
    ***********************************************************************/
     public Static List<Events__c> insertEvents(List<Events__c> InsertionList) {
        
        if(InsertionList != null && InsertionList.size() > 0) {
            insert InsertionList;
            return InsertionList;
        }
        return null;
    }
    
     /**********************************************************************
        Created by Vinitha on Feb 10 2017: This method return list of Event after update
        @updationList - list of Event for updation
    ***********************************************************************/
     public Static List<Events__c> updateEvents(List<Events__c> updationList) {
        
        if(updationList != null && updationList.size() > 0) {
            update updationList;
            return updationList;
        }
        return null;
    }
     
    /**********************************************************************
        Created by Shalini on May 19 2017: 
        @parentIdSet - Set of parent Ids
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        return - List of Event
     ***********************************************************************/
    public Static List<Events__c> getEventByparentIdsAndFilters(Set<Id> parentIdSet,String Parentcond,String parentFields,String filterQuery) {
        List<Events__c> eventList = new List<Events__c>();
        String defaultEventQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Events__c')+
                                parentFields+                                       
                                ' FROM'+
                                        ' Events__c';                                    
         if(Parentcond != null && Parentcond != '' && parentIdSet != null && parentIdSet.size() > 0) {
             defaultEventQry += Parentcond+' IN :parentIdSet';
         }else {
             defaultEventQry += filterQuery;
         }
         System.debug('defaultEventQry  :::::'+defaultEventQry);
         eventList = database.query(defaultEventQry);                           
         return eventList;
    }
    
    /**********************************************************************
        Created by NS on Sep 20 2018: 
        @projectIds - Set of project Ids
        @filterQuery - filter conditions
        @InstrcutorIds - instrcutor id set
        return - List of Event
     ***********************************************************************/  
    public Static List<Events__c> getEventByProject_InsIds(Date startDate,Date endDate,Set<Id> projectIds,Set<Id> instructorIds,Set<Id> scheduleIds,String parentFields,String filterQuery) {
        List<Events__c> eventList = new List<Events__c>();
        String defaultEventQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Events__c')+
                                parentFields+                                       
                                ' FROM'+
                                        ' Events__c';                                    
         Boolean includeWhere = true;
       
         if(String.isEmpty(filterQuery)){
             defaultEventQry += filterQuery;
             includeWhere = false;
         }
         
         if(includeWhere && startDate != null && endDate != null){
             defaultEventQry += ' AND Date__c >= '+startDate+' AND Date__c <= '+endDate+'';
         }else if(startDate != null && endDate != null) {
             defaultEventQry += ' WHERE Date__c >= '+startDate+' AND Date__c <= '+endDate+'';
             includeWhere = false;
         }
         
         if(!includeWhere && projectIds.size() > 0 && instructorIds.size() > 0){
         
             defaultEventQry += ' AND (Project__c IN :projectIds OR Instructor__c IN :instructorIds)';
             
         }else if(includeWhere && projectIds.size() > 0 && instructorIds.size() > 0) {
         
             defaultEventQry += ' WHERE Project__c IN :projectIds OR Instructor__c IN :instructorIds';
             includeWhere = false;
             
         }else if(includeWhere && projectIds.size() > 0){
         
             defaultEventQry += ' WHERE Project__c IN :projectIds';
             includeWhere = false;
             
         }else if(includeWhere && instructorIds.size() > 0) {
         
             defaultEventQry += ' WHERE Instructor__c IN :instructorIds';
             includeWhere = false;
             
         }
         
         if(includeWhere && scheduleIds.size() > 0)
             defaultEventQry += ' WHERE Schedule__c NOT IN :scheduleIds';
         else if(!includeWhere && scheduleIds.size() > 0)
             defaultEventQry += ' AND Schedule__c NOT IN :scheduleIds';
         
         
         System.debug(':query:formed:::'+defaultEventQry);
         eventList = database.query(defaultEventQry);                           
         return eventList;
    }
    
    /*****************************************************************************************************
    * Query all the Events with Status = Scheduled
    * For handling Substitute Events 
    ******************************************************************************************************/
    public static List<Events__c> getEventsBySchIdAndDateRange(Set<Id> schId, String startDate, String endDate, String parentFields, List<String> status) {
        List<Events__c> eventList = new List<Events__c>();
        String defaultEventQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Events__c')+
                                parentFields+                                       
                                ' FROM'+
                                        ' Events__c'; 
        if(schId.size() > 0) {
             defaultEventQry += ' WHERE Schedule__c IN :schId AND Status__c IN :status';
                 
            if(startDate != null && endDate != null) {
                 defaultEventQry += ' AND Date__c >= '+startDate+' AND Date__c <= '+endDate;
                 
            }
            defaultEventQry += ' ORDER BY Date__c';
        }
        System.debug('defaultEventQry::::getEventsBySchIdAndDateRange'+defaultEventQry);
        eventList = database.query(defaultEventQry);                           
        return eventList;
    }
}