public class TaskandSubTaskService { 
 
    public static List<TeamforcePro__Tasks__c> getTeamworkDetail() {
        
        List<TeamforcePro__Tasks__c> teamworkList = new List<TeamforcePro__Tasks__c>();
        
        Id userId = UserInfo.getUserId();
        
        String fieldName = 'Id, Name, TeamforcePro__Task_List__c, TeamforcePro__Task_List__r.Name, TeamforcePro__Due_Date__c,TeamforcePro__Completed__c,'
                            +'TeamforcePro__Priority__c, TeamforcePro__Teamwork_TSK_URL__c, TeamforcePro__Assigned_To_LookUp__r.User__c, Priority_Formula__c';
        String defaultOppQry = 'SELECT ' + fieldName +' FROM TeamforcePro__Tasks__c'                                                             
                                    +' WHERE TeamforcePro__Assigned_To_LookUp__r.User__c = :userId'
                                    +' AND TeamforcePro__Completed__c != true';
         
         System.debug('defaultOppQry :::::'+defaultOppQry);
         teamworkList = database.query(defaultOppQry );                          
         return teamworkList;         
    }
    
    public static List<TeamforcePro__Teamwork_Sub_Task__c> getTeamworkSubTaskDetail() {
        
        List<TeamforcePro__Teamwork_Sub_Task__c> teamsubtaskList = new List<TeamforcePro__Teamwork_Sub_Task__c>();
        
        Id userId = UserInfo.getUserId();
        
        String fieldName = 'Id, Name, TeamforcePro__Teamwork_Task__c, TeamforcePro__Teamwork_Task__r.Name, TeamforcePro__Task_List__c, TeamforcePro__Task_List__r.Name,'
                            +'TeamforcePro__Due_Date__c, TeamforcePro__Priority__c, TeamforcePro__Completed__c, Priority_Formula__c,'
                            +'TeamforcePro__Teamwork_SUBTSK_URL__c, TeamforcePro__Assigned_To_LookUp__r.User__c';
        String defaultOppQry = 'SELECT ' + fieldName +' FROM TeamforcePro__Teamwork_Sub_Task__c'                                                             
                                    +' WHERE TeamforcePro__Assigned_To_LookUp__r.User__c = :userId'
                                    +' AND TeamforcePro__Completed__c != true';
         
         System.debug('defaultOppQry :::::'+defaultOppQry);
         teamsubtaskList = database.query(defaultOppQry );                          
         return teamsubtaskList;         
    }
}