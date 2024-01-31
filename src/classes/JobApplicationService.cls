/**********************************************************************
    Created by Vinitha on Jan 6 2017: Service class used for jobApplication object
***********************************************************************/
public with sharing class JobApplicationService {
    
         
    /**********************************************************************
        Created by Vinitha on Jan 6 2017: This method return list of jobAppliction
         @fltrqryStr - Pass where conditions
         return - list of jobApplication records
    ***********************************************************************/ 
    public static list<Job_Application__c> getJoblist(String fltrqryStr,Set<Id> jobIdSet) {
        
        List<Job_Application__c> applicationList = new List<Job_Application__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Job_Application__c');
        
        String defaultQry = 'SELECT ' +fieldName + ' FROM Job_Application__c';
        
        if(fltrqryStr != null && fltrqryStr != '' && jobIdSet != null && jobIdSet.size() > 0){
            defaultQry += fltrqryStr+ 'IN :jobIdSet';
        }
        system.debug('::defaultQry::'+defaultQry);
        applicationList = Database.query(defaultQry);
        
        /*if(jobPostIdSet != null && jobPostIdSet.size() > 0){
            
            applicationList = [
                            SELECT 
                                Id, 
                                Name,
                                Job_Posting__c,
                                Applicant__c,
                                Status__c
                            FROM 
                                Job_Application__c 
                            WHERE 
                                Job_Posting__c IN :jobPostIdSet
                            ];
        } */
       return applicationList; 
        
    }
    
    /*public static list<Job_Application__c> getjobposting(String fltrqryStr){
         List<Job_Application__c> applicationList = new List<Job_Application__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Job_Application__c');
        String defaultQry = 'SELECT ' +fieldName + ' FROM Job_Application__c';
        if(fltrqryStr != null && fltrqryStr != ''){
            defaultQry = defaultQry + fltrqryStr;
        }
        applicationList = Database.query(defaultQry);
        return applicationList;
    }*/
    
     /**********************************************************************
        Created by Vinitha on Jan 6 2017: This method return list of jobApplication with 2 conditions
         @contactId - Id of contact record ids
         @status1 - status1 to add at where condition ('Awarded')
         @status2 - status2 to add at where condition ('Applied')
         return - list of jobApplication records
    ***********************************************************************
    public static list<Job_Application__c> getJobbyParentIds(Id contactId, String status1, String status2) {
        
        List<Job_Application__c> applicationList = new List<Job_Application__c>();
        if(contactId != null && status1 != null){
            applicationList = [
                            SELECT 
                                Job_Posting__c 
                            FROM 
                                Job_Application__c 
                            WHERE 
                                Applicant__c = :contactId 
                            AND 
                                Status__c = :status1
                            ];
            
        } else if(contactId != null && status1 != null && status2 != null){
            
            applicationList = [
                        SELECT 
                            Job_Posting__c 
                        FROM 
                            Job_Application__c
                        WHERE 
                            Applicant__c = :contactId 
                        AND 
                            (
                                Status__c = :status1
                            OR 
                                Status__c = :status2
                            )
                        ];            
        }
        return applicationList;        
    }*/
    
    /**********************************************************************
        Created by Vinitha on Jan 6 2017: This method return list of jobAppliction 
         @jobApplist - List of job application records                
         return - list of jobApplication records
    ***********************************************************************/ 
    public static list<Job_Application__c> insertJobapplication(list<Job_Application__c> jobApplist) {
         
        if(jobApplist != null && jobApplist.size() > 0){                    
            insert jobApplist;            
        } 
        return jobApplist;
        
    }
    /**********************************************************************
        Created by Vinitha on Jan 6 2017: This method return list of jobAppliction 
         @jobApplist - List of job application records                
         return - list of jobApplication records
    ***********************************************************************/ 
    public static list<Job_Application__c> updateJobapplication(list<Job_Application__c> jobApplist) {
        
        if(jobApplist != null && jobApplist.size() > 0){            
            update jobApplist;                
        }
        return jobApplist;
    }
}