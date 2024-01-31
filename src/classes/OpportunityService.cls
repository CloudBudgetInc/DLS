/**********************************************************************
    Created by Arun on Jan 19, 2017: Service class used for Opportunity
***********************************************************************/
public with sharing class OpportunityService {

/**********************************************************************
        Created by Arun on Jan 19 2017: 
        @accIdSet - Set of Account Id's.
        @rtDevNameSet - Set of Recordtype Developer Names 
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        @currentyear - Current year.
        return - List of Opportunities.
 ***********************************************************************/
    
    public static List<Opportunity> getOpportunitiesByAccIdsAndRtDevNames(Set<Id> accIdSet,Set<String> rtDevNameSet,String filterQuery,String  parentFields, Date currentyear) {
        
        List<Opportunity> oppList = new List<Opportunity>();
        String defaultOppQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Opportunity')+
                                parentFields+                                       
                                ' FROM'+
                                        ' Opportunity'+
                                    ' WHERE'+
                                        ' RecordType.DeveloperName IN : rtDevNameSet';
         if(filterQuery != '') {
             defaultOppQry += filterQuery;
         }
         if(currentyear != null) {
             
             defaultOppQry +=' AND End_Date__c > :currentyear';
         }
         if(accIdSet != null && accIdSet.size() > 0) {
             
             defaultOppQry += ' AND AccountId IN : accIdSet';
         }
         
         System.debug('defaultOppQry :::::'+defaultOppQry);
         oppList = database.query(defaultOppQry );                          
         return oppList;
         
    }
    
    public static List<Opportunity> getOpportunityByAccIds(Set<Id> accIdSet, String filterQuery,String  parentFields) {
        
        List<Opportunity> oppList = new List<Opportunity>();
        String defaultOppQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Opportunity')+
                                parentFields+                                       
                                ' FROM'+' Opportunity';
                                        
        if(accIdSet != Null && accIdSet.size() > 0){
            defaultOppQry += ' WHERE'+' AccountId IN :accIdSet';
        }                            
        if(filterQuery != '') {
             defaultOppQry += filterQuery;
        }
        
        System.debug('defaultOppQry :::::'+defaultOppQry);
        oppList = database.query(defaultOppQry );                           
        return oppList;
    }
    
 /**********************************************************************
        Created by Arun on Jan 19 2017: 
        @oppIdSet - Set of Opportunity Id's.
        @rtDevNameSet - Set of Recordtype Developer Names 
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        @currentyear - Current year.
        return - List of Opportunities.
 ***********************************************************************/
    
    public static List<Opportunity> getOpportunitiesByOppIdsAndRtDevNames(Set<Id> oppIdSet,Set<String> rtDevNameSet,String filterQuery,String  parentFields,Date currentyear) {
        
        List<Opportunity> oppList = new List<Opportunity>();
        String defaultOppQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Opportunity')+
                                parentFields+                                       
                                ' FROM'+
                                        ' Opportunity'+
                                    ' WHERE'+
                                        ' Id IN : oppIdSet'+
                                        ' AND'+ 
                                        ' RecordType.DeveloperName IN : rtDevNameSet';
         if(filterQuery != '') {
             defaultOppQry += filterQuery;
         }
         if(currentyear != Null ) {
             
             defaultOppQry +=' AND End_Date__c > :currentyear';
         }
         System.debug('defaultOppQry :::::'+defaultOppQry);
         oppList = database.query(defaultOppQry );                           
         return oppList;
         
    }
/**********************************************************************
        Created by Karthiga on Jan 21 2017: 
        @oppList - List Opportunity's to update.
        return - List of Opportunities.
 ***********************************************************************/  
    public static List<Opportunity> updateOpp(List<Opportunity> oppList){
        if( oppList != null && oppList.size() > 0 ) {
            update oppList;
            
            return oppList;
        }
        return null;
    }
    
    /**********************************************************************
        Created by Shalini on Feb 1 2017: This method returns list of OpportunityHistory object records
        @oppId - Id of Opportunity object
        @stages - Picklist values of Stage field 
        return - List of OpportunityHistory object 
     ***********************************************************************/
    
    public static List<OpportunityHistory> getOppHistoryListByOppIdAndStage(Set<Id> oppId, Set<String> stages){
        
        List<OpportunityHistory> opphistList = new List<OpportunityHistory>();
        try{
            String commaSepratedFields;
            String queryval;
            commaSepratedFields = SObjectQueryService.getSObjectFieldsBySObjectName('OpportunityHistory');
            if(oppId != Null && oppId.size() > 0 && stages != Null && stages.size() > 0){
                queryval = 'select ' + commaSepratedFields + ' from ' + 'OpportunityHistory' + 
                            ' WHERE OpportunityId IN :oppId'+
                            ' AND'+
                            ' StageName IN :stages';
                            
                opphistList = Database.query(queryval);
            }            
        }
        catch(exception e){
            system.debug('&&OpportunityService::OppHistory'+e.getMessage());
        }
        return opphistList;
    }
    
    /**********************************************************************
        Created by Shalini on Feb 7 2017: This method returns list of Opportunity object records
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        @startDate - Start Date
        @endDate - End Date
        return - List of Opportunities 
     ***********************************************************************/
    
    public static List<Opportunity> getOpportunitiesByStartAndEndDate(String filterQuery,String  parentFields,DateTime startDate,DateTime endDate) {
        
        List<Opportunity> oppList = new List<Opportunity>();
        String defaultOppQry = 'SELECT ' + 'Id,Name,DLS_Class__c,Stripped_Class_Number_This_Year__c,CreatedDate'/*SObjectQueryService.getSObjectFieldsBySObjectName('Opportunity')*/+
                                parentFields+                                       
                                ' FROM'+' Opportunity';
                                    
        if(filterQuery != '') {
         defaultOppQry += filterQuery;
        }
        if(startDate != Null && endDate != Null){
          defaultOppQry += ' WHERE CreatedDate >= :startDate ' + 
                           ' AND CreatedDate <= :endDate AND DLS_Class__c != null AND Stripped_Class_Number_This_Year__c > 0 ORDER BY Stripped_Class_Number_This_Year__c DESC LIMIT 1'; //ORDER BY CreatedDate Desc LIMIT 1'; //ORDER By DLS_Class__c Desc';
        }
        System.debug('defaultOppQry :::::'+defaultOppQry);
        oppList = database.query(defaultOppQry);                           
        return oppList;
         
    }
    
    /**********************************************************************
        Created by Shalini on Feb 8 2017: This method returns list of Opportunity object records
        @oppIdSet - Set of Opportunity Ids
        return - List of Opportunities 
     ***********************************************************************/
    
    public static List<Opportunity> getOpportunitiesByInnerQueries(Set<Id> oppIdSet){
        
        List<Opportunity> oppList = new List<Opportunity>();
        
        String oppFields = SObjectQueryService.getSObjectFieldsBySObjectName('Opportunity');
        
        
        String defaultOppQry = 'SELECT ' + oppFields+',RecordType.DeveloperName,Location__r.RecordType.DeveloperName,('+
                               'SELECT '+'Id,Name,End_Date__c,End_Time__c,Opportunity__c,Start_Date__c,Start_Time__c,Project_Task__c,Instructor__c,Timezone__c,Opportunity_Product_Id__c FROM Schedules__r),('+
                               'SELECT '+'Id,Name,UnitPrice,Quantity,Product2Id,Product2.Name,Product2.Family,Product2.Unit_Type__c,Product2.Language_LU__c,OpportunityId,CLIN_LU__c,Description FROM OpportunityLineItems),('+
                               'SELECT '+SObjectQueryService.getSObjectFieldsBySObjectName('Contact_Assignments__c')+',Candidate_Name__r.Name,RecordType.Name,RecordType.DeveloperName FROM All_Instructors__r),('+
                               'SELECT '+'Id,Name,Opportunity__c,Project_Task__c,Examiner__r.Name,Examiner__c,Goal_SLRW__c,Score_SLRW__c,Target_Language_LU__r.Name,Testee__c,Testee__r.Name,Tester__c,Tester__r.Name,Date_Time_Scheduled__c FROM Language_Testing__r),('+
                               'SELECT '+'Id,Name FROM Demo_FeedBack__r)'+
                               ' FROM Opportunity'+
                               ' WHERE Id IN :oppIdSet';
        System.debug('defaultOppQry :::::'+defaultOppQry);
        oppList = database.query(defaultOppQry);          
        system.debug(':::::getOpportunitiesByInnerQueries::::::oppList::::::'+oppList);                 
        return oppList;
    }
    
     /**********************************************************************
        Created by Shalini on Feb 9 2017: This method returns list of Opportunity object records
        @filterQuery - Filter conditions
        @oppId - Set of opportunity IDs
        @conAssignRecordTypeId - Set of contact assignment record type IDs
        @parentFields - parent fields to be queried
        return - List of Opportunities 
     ***********************************************************************/
    
    public static List<Opportunity> getOpportunitiesByInnerQueryOnAllInstructors(String filterQuery,Set<Id> oppId,Set<Id> conAssignRecordTypeId,String parentFields){
        List<Opportunity> oppList = new List<Opportunity>();
        String defaultOppQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Opportunity')+parentFields+',('+
                               'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Contact_Assignments__c')+',RecordType.DeveloperName'+ 
                               ' FROM  All_Instructors__r'; 
        if(conAssignRecordTypeId != Null && conAssignRecordTypeId.size() > 0){
            defaultOppQry += ' WHERE RecordTypeId = :conAssignRecordTypeId)'+
                             ' FROM Opportunity'+
                             ' WHERE Id IN :oppId';  
        }
        if(filterQuery != Null && filterQuery != ''){
            defaultOppQry += filterQuery +')'+
                             ' FROM Opportunity'+
                             ' WHERE Id IN :oppId';
        }
        System.debug('defaultOppQry :::::'+defaultOppQry);
        oppList = database.query(defaultOppQry);                           
        return oppList;     
    }
    
    //Commented this method because doesn't use any component.
    /**********************************************************************
        Created by Shalini on Feb 9 2017: This method returns list of Opportunity object records
        @oppId - Set of opportunity IDs
        @parentFields - parent fields to be queried
        return - List of Opportunities 
     ***********************************************************************/
    
    /*public static List<Opportunity> getOpportunitiesByInnerQueriesOnOCR(Set<Id> oppIdSet,String parentFields){
        
        List<Opportunity> oppList = new List<Opportunity>();
        String defaultOppQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Opportunity')+parentFields+',('+
                               'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('OpportunityContactRole')+' FROM OpportunityContactRoles),('+
                               'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Contact_Assignments__c')+' FROM All_Instructors__r),('+
                               'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Student_Assignment__c')+' FROM Student_Assignments__r)'+
                               ' FROM Opportunity'+
                               ' WHERE Id IN :oppIdSet'+
                               ' AND RecordType.DeveloperName IN (\'New_Classes_Opportunities\', \'AFPAK_Classes\')'+
                               ' AND RecordType.isActive = TRUE';
        System.debug('defaultOppQry :::::'+defaultOppQry);
        oppList = database.query(defaultOppQry);                           
        return oppList;
    }*/
    
}