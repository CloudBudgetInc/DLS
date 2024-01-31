/**********************************************************************
    Created by Arunkumar on Jan 17, 2017: Service class used for AcctSeed__Project_Task__c 
***********************************************************************/

public without sharing Class ProjectTaskService {
    
/**********************************************************************
    Created by Arunkumar on Jan 17, 2017: Service Method using  
    @projIdSet - Set of AcctSeed Project Id's
    @projTaskTypeSet - Set of ProjectTask Type
    @filterqry - Filter query String
    @parentFields - Parent Fields String. 
    Returns - List of AcctSeedProjectTask.     
***********************************************************************/

    public Static List<AcctSeed__Project_Task__c> getProjectTasksByProjIdsAndProjTaskTypes(Set<Id> projIdSet, Set<String> projTaskTypeSet, String filterqry, string parentFields) {
        
         list<AcctSeed__Project_Task__c> acctSeedProjTasks = new list<AcctSeed__Project_Task__c>();
         String acctSeedProjTaskQry = 'SELECT '+
                                        SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Project_Task__c')+
                                        parentFields+                                       
                                    ' FROM'+
                                        ' AcctSeed__Project_Task__c'+
                                    ' WHERE'+
                                        ' AcctSeed__Project__c IN : projIdSet';
         if(projTaskTypeSet != null && projTaskTypeSet.size() > 0){
             acctSeedProjTaskQry += ' AND'+ 
                                        ' Project_Task_Type__c IN : projTaskTypeSet';
         }
                                        
         if(filterqry != '') {
             acctSeedProjTaskQry += filterqry;
         }
         System.debug('acctSeedProjTaskQry :::::'+acctSeedProjTaskQry );
         acctSeedProjTasks = database.query(acctSeedProjTaskQry);                           
         return acctSeedProjTasks;
    }
    
    /**********************************************************************
    Created by Sukanya on Feb 2, 2017: Service Method using  
    @projectIdSet - Set of AcctSeed Project Id's
    @languageSet - Set of Languages
    @filterqry - Filter query String
    @parentFields - Parent Fields String. 
    Returns - List of AcctSeedProjectTask.     
***********************************************************************/
    
    public Static List<AcctSeed__Project_Task__c> getProjecttasksByfilters(Set<Id> projectIdSet, Set<String> languageSet, String filterqry, string parentFields) {
        
        List<AcctSeed__Project_Task__c> projectTaskList = new List<AcctSeed__Project_Task__c>();
         
        String taskQry = 'SELECT '+
                          SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Project_Task__c')+
                          parentFields+                                       
                          ' FROM'+
                          ' AcctSeed__Project_Task__c';
        
        if(filterqry != '') {
            taskQry += filterqry;
        }                                
        
        if(filterqry == '' && projectIdSet != null && projectIdSet.size() > 0) {
            taskQry += ' WHERE AcctSeed__Project__c IN : projectIdSet';
        }else {
            taskQry += ' AND AcctSeed__Project__c IN : projectIdSet';
        }
        
        if(languageSet != null && languageSet.size() > 0){
            taskQry += ' AND Language__c IN : languageSet';
        }
         
        System.debug('taskQry :::::'+taskQry );
         
        projectTaskList = database.query(taskQry);                           
        return projectTaskList;
    }
    
    /**********************************************************************
    Created by Shalini on Feb 6, 2017: Service Method using  
    @filterQrystr - Filter query String
    @parentfields - Parent Fields String.
    @projectTaskId - Set of AcctSeed Project Task Id's 
    Returns - List of AcctSeedProjectTask.     
***********************************************************************/
    
    public Static List<AcctSeed__Project_Task__c> getProjectTaskByInnerQueryOnConAssign(String filterQrystr,String parentfields,Set<Id> projectTaskId) {
       
        List<AcctSeed__Project_Task__c> projTaskList = new List<AcctSeed__Project_Task__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Project_Task__c');
        String defalutQry = 'SELECT '+ fieldName + parentfields 
                               +', ('
                                   +'SELECT '
                                        + ' Id,Name,RecordTypeId,RecordType.DeveloperName'
                                    +' FROM Contact_Assignments__r'
                                    +' WHERE Project_Task__c != Null'
                                    +' AND'
                                    +' RecordType.DeveloperName = \''+'Client_Partner'+'\''
                                    +' AND'
                                    +' Status__c != \''+'Ended'+'\''
                                    +')'
                             +' FROM AcctSeed__Project_Task__c';
        
        if(projectTaskId.size() > 0 && projectTaskId != Null){
            defalutQry += ' WHERE Id IN :projectTaskId'; 
        }
        
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry += filterQrystr;
        }
        System.debug('::defalutQry:::'+defalutQry);
        projTaskList = Database.query(defalutQry);        
        return projTaskList;  
    
    }
    
    /**********************************************************************
        Created by Shalini on Feb 6 2017: This method return list of AcctSeed__Project_Task__c 
        @projTaskList - List of AcctSeed__Project_Task__c records
        return - List of AcctSeed__Project_Task__c records
    ***********************************************************************/
     
    public static List<AcctSeed__Project_Task__c> upsertProjectTask(List<AcctSeed__Project_Task__c> projTaskList) {
    
        if(projTaskList != null && projTaskList.size() > 0){
            upsert projTaskList;            
        }
        return projTaskList;    
    }
    
    /**********************************************************************
    Created by Shalini on Feb 6, 2017: Service Method using  
    
    @parentfields - Parent Fields String.
    @projectId - Set of AcctSeed Project Id's 
    @StartDate - Start Date
    @EndDate - End Date
    @conId - Contact Id
    Returns - List of AcctSeedProjectTask.     
***********************************************************************/
    
    public Static List<AcctSeed__Project_Task__c> getProjectTaskByInnerQueryOnTimeCardLineDetails(String parentfields,Set<Id> projectId,Date StartDate,Date EndDate,Id conId) {
       
        List<AcctSeed__Project_Task__c> projTaskList = new List<AcctSeed__Project_Task__c>();
        
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Project_Task__c');
        String defalutQry = 'SELECT '+ fieldName + parentfields 
                               +', ('
                                   +'SELECT '
                                        + ' Id,Name,AcctSeed__Billable__c'
                                    +' FROM AcctSeed__Time_Card_Line_Details__r'
                                    +' WHERE AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c >= :StartDate'
                                    +' AND'
                                    +' AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c <= :EndDate'
                                    +' AND'
                                    +' AcctSeed__Time_Card__r.Intructor__c = :conId'
                                    +')'
                             +' FROM AcctSeed__Project_Task__c';
        
        if(projectId.size() > 0 && projectId != Null){
            defalutQry += ' WHERE AcctSeed__Project__c IN :projectId'; 
        }
        
        
        System.debug('::defalutQry:::'+defalutQry);
        projTaskList = Database.query(defalutQry);        
        return projTaskList;  
    
    }
    
     /**********************************************************************
        Created by Vinitha on Feb 17 2017: This method return list of AcctSeed__Project__c
        @parentFields - Pass parent field name
        @filterQry - pass where conditions
        @parentId - pass parentId 
        return - list of AcctSeed__Project__c records
    ***********************************************************************/  
    
    public Static List<AcctSeed__Project_Task__c> getProjectTaskRecbyParentId(String parentFields,String filterQry,Set<Id> parentId,String limitQry) {
    
        List<AcctSeed__Project_Task__c> protaskList = new List<AcctSeed__Project_Task__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Project_Task__c');
        String defalutQry;
        
        defalutQry = 'SELECT '+ fieldName + 
                         parentFields + 
                         ' FROM AcctSeed__Project_Task__c';
        if(filterQry != null && filterQry != '' && parentId != null && parentId.size() > 0){
            defalutQry += filterQry + 'IN :parentId' + limitQry;
        } else if(filterQry != null && filterQry != ''){
            defalutQry += filterQry + limitQry;
        }
        
        protaskList = Database.query(defalutQry);        
        return protaskList;        
    
    }
    
    /**********************************************************************
        Created by Vinitha on May 22 2017: 
        @opliList - List of ProjectTask to delete   
        return - String "Success" or the exception got.
    ***********************************************************************/ 
    public static String deleteProjectTask(List<AcctSeed__Project_Task__c> projecttaskList) {
        String retn = '';
        try {
            if( projecttaskList != null && projecttaskList.size() > 0 ) {
                delete projecttaskList;
                retn = 'Success';
            }
        } catch(Exception e) {
            System.debug('ProjectTaskService::::Exception'+e);
            retn = e.getMessage();
            return retn;
        }
        return retn;
    }


}