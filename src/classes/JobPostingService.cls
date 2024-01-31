/**********************************************************************
    Created by Vinitha on Jan 7 2017: Service class used for Job_Posting__c object
***********************************************************************/
public with sharing class JobPostingService {
    
     /**********************************************************************
        Created by Vinitha on Jan 7 2017: This method return list of jobPosting 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of jobPosting records
    ***********************************************************************/  
    
    public Static List<Job_Posting__c> getJobposting(String filterQrystr, String parentFields,Date today) {
        list<Job_Posting__c> jobList = new list<Job_Posting__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Job_Posting__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Job_Posting__c';
        system.debug(':::filterQrystr::'+filterQrystr);
        System.debug('::parentFields:::'+parentFields);
        System.debug('::defalutQry:::'+defalutQry);
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields + ' FROM Job_Posting__c';
        }
        if(filterQrystr != null && filterQrystr != '' && today != null){
            defalutQry = defalutQry + filterQrystr +'> :today';           
        } 
        System.debug('::defalutQry:::'+defalutQry);
        jobList = Database.query(defalutQry);        
        return jobList;        
    
    }
  
     /**********************************************************************
        Created by Vinitha on Jan 7 2017: This method return list of jobPosting with 2 conditions
         @today - date of today jobPosting record 
         @keyword - keyword to add at find query  
         return - list of jobPosting records
    ***********************************************************************/
    
    public static list<Job_Posting__c> getJoblist(Date today, String keyword) {
    
        list<Job_Posting__c> jobList = new list<Job_Posting__c>();
        if(keyword != null || today != null){
        
            jobList = [
                    FIND :keyword IN ALL FIELDS RETURNING
                        Job_Posting__c
                            (
                                Id,
                                Name,
                                Amount_of_Travel__c,
                                City__c, Account__c,
                                Account__r.Name,
                                Contact_Email__c,
                                Job_Description__c,
                                Locations__c,
                                Eduction_Level_Required__c,
                                How_to_Apply__c,
                                Job_Post_Expiration_Date__c,
                                Status__c,
                                Hours_Per_Week__c,
                                Job_Length__c,
                                Locations__r.Location_GeoCode__Latitude__s,
                                Locations__r.Location_GeoCode__Longitude__s,
                                Relocation__c, Language__c,
                                Pay_Details__c,
                                Year_of_Experiance__c,
                                CreatedDate,
                                Locations__r.Name,
                                GeoCode__Latitude__s,
                                GeoCode__Longitude__s,
                                Job_Title__c,
                                Job_Type__c,
                                Max_Salary__c,
                                Min_Salary__c,
                                Salary_Type__c,
                                Start_Date__c,
                                Travel_Required__c
                            WHERE
                                Job_Post_Expiration_Date__c >= :today
                            )
                    ][0];            
        } 
        return jobList;
    }
    
    /**********************************************************************
        Created by Vinitha on Jan 10 2017: This method return list of jobPosting 
        @fltrqryStr - pass where Conditions
        @parentFields - Pass parent field name
        return - list of jobPosting records
    ***********************************************************************/  
    
    public Static List<Job_Posting__c> getJobpostingByapplicant(String filterQrystr, String parentFields,Set<Id> contactId) {
        
        system.debug('::contactId::'+contactId);
        list<Job_Posting__c> jobList = new list<Job_Posting__c>();
        String fieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Job_Posting__c');
        String childObjfieldName = SObjectQueryService.getSObjectFieldsBySObjectName('Job_Application__c');
        String defalutQry = 'SELECT '+ fieldName +' FROM Job_Posting__c';
        system.debug(':::filterQrystr::'+filterQrystr);
        System.debug('::parentFields:::'+parentFields);
        System.debug('::defalutQry:::'+defalutQry);
        System.debug('::childObjfieldName:::'+childObjfieldName);
        if(parentFields != null && parentFields != ''){
           defalutQry = 'SELECT '+ fieldName +' ,'+ parentFields 
                           +', ('
                               +'SELECT '
                                    + childObjfieldName 
                                +' FROM Job_Requests__r'
                                +' WHERE Applicant__c '
                                +'IN :contactId'
                                +')'
                         +' FROM Job_Posting__c';
        }
        if(filterQrystr != null && filterQrystr != ''){
            defalutQry = defalutQry + filterQrystr;        
        } 
        System.debug('::defalutQry:::'+defalutQry);
        jobList = Database.query(defalutQry);        
        return jobList;  
    
    }
    
    /**********************************************************************
        Created by Vinitha on Jan 7 2017: This method return list of jobPosting with 1 conditions
        @jobPostlist - List of jobPosting record         
        return - list of jobPosting records
    ***********************************************************************/
    public static list<Job_Posting__c> updateJobpost(list<Job_Posting__c> jobPostlist) {
        
        if(jobPostlist != null && jobPostlist.size() > 0){
            update jobPostlist;            
        }
        return jobPostlist; 
    }
    
    
     /**********************************************************************
        Created by Vinitha on Jan 7 2017: This method return list of jobPosting with 2 conditions
        @jobId - Id of jobPosting record ids
        @contactId - Id of contact record ids
        return - list of jobPosting records
    ***********************************************************************/
    
    /*public static list<Job_Posting__c> getJobdetails(Set<Id> jobId, Set<Id> contactId) {
    
        list<Job_Posting__c> jobList = new list<Job_Posting__c>();
        if(jobId != null && contactId != null){
        
            jobList = [
                    SELECT
                        Id,
                        Name,
                        Amount_of_Travel__c,
                        City__c, Account__c,
                        Account__r.Name,
                        Contact_Email__c,
                        Job_Description__c,
                        Locations__c,
                        Eduction_Level_Required__c,
                        How_to_Apply__c,
                        Job_Post_Expiration_Date__c,
                        Status__c, Hours_Per_Week__c,
                        Job_Length__c,
                        Relocation__c, Language__c,
                        Pay_Details__c,
                        Year_of_Experiance__c,
                        CreatedDate, Locations__r.Name,
                        GeoCode__Latitude__s,
                        GeoCode__Longitude__s,
                        Job_Title__c,
                        Job_Type__c,
                        Max_Salary__c,
                        Min_Salary__c,
                        Salary_Type__c,
                        Start_Date__c,
                        Travel_Required__c,
                        Number_of_Openings__c,
                        Qualification__c,
                            (
                                SELECT
                                    Id,
                                    Status__c
                                FROM
                                    Job_Requests__r
                                WHERE
                                    Applicant__c = :contactId
                            )
                    FROM
                        Job_Posting__c
                    WHERE
                        Id = :jobId
                    ];            
        } 
        return jobList;        
    }*/
    
       /**********************************************************************
        Created by Vinitha on Jan 7 2017: This method return list of jobPosting with 2 conditions
         @today - date of today jobPosting record 
         return - list of jobPosting records
    ***********************************************************************/
    
    /*public static list<Job_Posting__c> getAwardedJobs(Date today) {
        
        list<Job_Posting__c> jobList = new list<Job_Posting__c>();
        if(today != null){
            
            jobList = [
                    SELECT
                        Id,
                        Name,
                        Amount_of_Travel__c,
                        City__c, Account__c,
                        Account__r.Name,
                        Contact_Email__c,
                        Job_Description__c,
                        Locations__c,
                        Eduction_Level_Required__c,
                        How_to_Apply__c,
                        Job_Post_Expiration_Date__c,
                        Status__c,
                        Hours_Per_Week__c,
                        Job_Length__c,
                        Locations__r.Location_GeoCode__Latitude__s,
                        Locations__r.Location_GeoCode__Longitude__s,
                        Relocation__c,
                        Language__c,
                        Pay_Details__c,
                        Year_of_Experiance__c,
                        CreatedDate,
                        Locations__r.Name,
                        GeoCode__Latitude__s,
                        GeoCode__Longitude__s,
                        Job_Title__c,
                        Job_Type__c,
                        Max_Salary__c,
                        Min_Salary__c,
                        Salary_Type__c,
                        Start_Date__c,
                        Travel_Required__c
                    FROM
                        Job_Posting__c
                    WHERE
                        Job_Post_Expiration_Date__c >= :today
                    ];                       
        }
        return jobList;         
    }
    */
    
    
 
}