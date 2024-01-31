/**********************************************************************
    Created by Arunkumar on Jan 07,2017 : Service Class used for Experience__c
***********************************************************************/
public with Sharing class ExperienceService {

/**********************************************************************
    Created by Arunkumar on Jan 9, 2017: Service Method using  
    @rtDevnameSet - Set of RecordType DeveloperName's.
    @conIdSet - Set of ContactId's.
    Returns - List of Experiences.     
***********************************************************************/    
    public static List<Experience__c> getExperiencesByRecordTypeDeveloperNameAndContactIdset(set<String> rtDevnameSet, Set<Id> conIdSet) {
    
        List<Experience__c> experienceList = new List<Experience__c>();
        
        if((rtDevnameSet!= null && rtDevnameSet.size() > 0) && (conIdSet!= null && conIdSet.size() > 0)) {
            
            String ExpQry = 'SELECT '+
                        SObjectQueryService.getSObjectFieldsBySObjectName('Experience__c') +', RecordType.DeveloperName'+
                        ' FROM'+
                        ' Experience__c  WHERE RecordType.DeveloperName IN :rtDevnameSet AND Contact__c IN :conIdSet';
                        
            experienceList = Database.Query(ExpQry);
            System.debug('ExpQry :::'+ExpQry);                  
            
        }
        
        return experienceList;
    }

/**********************************************************************
    Created by Arunkumar on Jan 9, 2017: Service Method using  
    @FilterCondition - Filter Condition String.
    Returns - List of Experiences.     
***********************************************************************/  
    
    public static List<Experience__c> getExperiencesByFilterQuery(String FilterCondition) {
        
        List<Experience__c> experienceList = new List<Experience__c>();
        
        String filterQuery = 'SELECT '+
                        SObjectQueryService.getSObjectFieldsBySObjectName('Experience__c') +', RecordType.DeveloperName'+
                        ' FROM'+
                        ' Experience__c ';
                        
        if(FilterCondition != Null) {
            
             
            filterQuery = filterQuery + FilterCondition;
            System.debug('filterQuery:::::'+filterQuery);
        }
        experienceList = Database.query(filterQuery);
             
        return experienceList;
    }

/**********************************************************************
    Created by Arunkumar on Jan 9, 2017: Service Method using  
    @rtDevnameSet - Set of RecordType DeveloperName's.
    @expIdSet - Set of Experience Id's.
    Returns - List of Experiences.     
***********************************************************************/  

    public static List<Experience__c> getExperiencesByRTDevNameAndExpIdset(set<String> rtDevnameSet, Set<Id> expIdSet) {
    
        List<Experience__c> experienceList = new List<Experience__c>();
        
        if((rtDevnameSet!= null && rtDevnameSet.size() > 0) && (expIdSet!= null && expIdSet.size() > 0)) {
            
            String ExpQry = 'SELECT '+
                        SObjectQueryService.getSObjectFieldsBySObjectName('Experience__c') +', RecordType.DeveloperName'+
                        ' FROM'+
                        ' Experience__c  WHERE RecordType.DeveloperName IN :rtDevnameSet AND Id IN :expIdSet';
                        
            experienceList = Database.Query(ExpQry);
            System.debug('ExpQry :::'+ExpQry);                  
            
            
        }
        
        return experienceList;
    }
    
/**********************************************************************
    Created by Arunkumar on Jan 9, 2017: Service Method using  
    @rtDevnameSet - Set of RecordType DeveloperName's.
    @expIdSet - Set of Experience Id's.
    Returns - List of Experiences.     
***********************************************************************/  

    public static List<Experience__c> getExperiencesByDegreeLevelList(List<String> DegreeLevelList) {
    
        List<Experience__c> experienceList = new List<Experience__c>();
        
        if((DegreeLevelList!= null && DegreeLevelList.size() > 0)) {
            
            String ExpQry = 'SELECT '+
                        SObjectQueryService.getSObjectFieldsBySObjectName('Experience__c') +', RecordType.DeveloperName'+
                        ' FROM'+
                        ' Experience__c  WHERE Degree_Level__c IN :DegreeLevelList';
                        
            experienceList = Database.Query(ExpQry);
            System.debug('ExpQry :::'+ExpQry);                  
            
        }
        
        return experienceList;
    }

/**********************************************************************
    Created by Arunkumar on Jan 9, 2017: Service Method using  
    @ContIdSet - Set of Contact Id's.
    Returns - List of Experiences.     
***********************************************************************/  

    public static List<Experience__c> getExperiencesByRtIdSetAndContIdSet(Set<Id> RtIdSet, Set<Id> ContIdSet) {
    
        List<Experience__c> experienceList = new List<Experience__c>();
        
        if((RtIdSet!= null && RtIdSet.size() > 0) && (ContIdSet!= null && ContIdSet.size() > 0)) {
            
            String ExpQry = 'SELECT '+
                        SObjectQueryService.getSObjectFieldsBySObjectName('Experience__c') +', RecordType.DeveloperName'+
                        ' FROM'+
                        ' Experience__c WHERE RecordTypeId IN :RtIdSet AND Contact__c IN :ContIdSet';
                        
            experienceList = Database.Query(ExpQry);
            System.debug('ExpQry :::'+ExpQry);                  
            
        }
        
        return experienceList;
    }
    
/**********************************************************************
    Created by Arunkumar on Jan 10, 2017: Service Method using  
    @expList- List of Experiences.
    Returns - List of Inserted Experiences.   
***********************************************************************/

    public Static List<Experience__c> insertExperiences(List<Experience__c> expList) {
        
        if(expList != null && expList.size() > 0) {
            
            Insert expList;
            return expList;
        }
        
        return null;
    }
/**********************************************************************
    Created by Arunkumar on Jan 10, 2017: Service Method using  
    @expList- List of Experiences.
    Returns - List of updated Experiences.   
***********************************************************************/

    public Static List<Experience__c> updateExperiences(List<Experience__c> expList) {
        
        if(expList != null && expList.size() > 0) {
            
            Update expList;
            return expList;
        }
        
        return null;
    }

/**********************************************************************
    Created by Arunkumar on Jan 10, 2017: Service Method using  
    @expList- List of Experiences.
    Returns - List of upserted Experiences.   
***********************************************************************/

    public Static List<Experience__c> upsertExperiences(List<Experience__c> expList) {
        
        if(expList != null && expList.size() > 0) {
            
            Upsert expList;
            return expList;
        }
        
        return null;
    }
}