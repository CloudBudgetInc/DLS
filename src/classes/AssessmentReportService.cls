/**********************************************************************
    Created by Arun on Jan 20, 2017: Service class used for Assessment_Report__c
***********************************************************************/
public with sharing Class AssessmentReportService {

    public static Boolean sortByReportDate = false;
    
/**********************************************************************
    Created by Arun on Jan 20 2017: 
    @filterQuery - filter conditions
    @parentFields - parent fields to be queried
    return - List of AssessmentReports.
 ***********************************************************************/
 
    public Static List<Assessment_Report__c> getAssessmentReports(String filterQuery , String parentFields) {
        
        List<Assessment_Report__c> assReportList = new List<Assessment_Report__c>();
        String defaultAssReportQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Assessment_Report__c')+
                                parentFields+  
                                    ' ,(SELECT '+ SObjectQueryService.getSObjectFieldsBySObjectNameExceptBlob('Attachment')+
                                        ' FROM Attachments ORDER By createdDate DESC LIMIT 1 )'+
                                ' FROM'+
                                        ' Assessment_Report__c';
                                    
        if(filterQuery != '') {
             defaultAssReportQry += ' WHERE '+filterQuery;
        }
        
        if(sortByReportDate){
            defaultAssReportQry += ' ORDER BY Report_Date__c ASC';
        }
        
        System.debug('defaultAssReportQry :::::'+defaultAssReportQry );
        assReportList = database.query(defaultAssReportQry );                           
        return assReportList;    
    }

/**********************************************************************
    Created by Arun on Jan 20 2017: 
    @projAccIdSet - Set of Project AcctSeed Account Ids
    @filterQuery - filter conditions
    @parentFields - parent fields to be queried
    return - List of AssessmentReports.
 ***********************************************************************/
 
    public Static List<Assessment_Report__c> getAssessmentReportsByprojAccIds(Set<Id> projAccIdSet, String filterQuery , String parentFields) {
        
        List<Assessment_Report__c> assReportList = new List<Assessment_Report__c>();
        String defaultAssReportQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Assessment_Report__c')+
                                parentFields+  
                                    ' ,(SELECT '+ SObjectQueryService.getSObjectFieldsBySObjectNameExceptBlob('Attachment')+
                                        ' FROM Attachments ORDER By createdDate DESC LIMIT 1 )'+
                                ' FROM'+
                                        ' Assessment_Report__c'+
                                ' WHERE'+
                                    ' Project__r.AcctSeed__Account__c IN :projAccIdSet';
                                    
        if(filterQuery != '') {
             defaultAssReportQry += filterQuery;
        }
        
        System.debug('defaultAssReportQry :::::'+defaultAssReportQry );
        assReportList = database.query(defaultAssReportQry );                           
        return assReportList;    
    }
    
    /**********************************************************************
    Created by Arun on Jan 20 2017: 
    @projIdSet - Set of Project Ids
    @filterQuery - filter conditions
    @parentFields - parent fields to be queried
    return - List of AssessmentReports.
 ***********************************************************************/
 
    public Static List<Assessment_Report__c> getAssessmentReportsByprojIds(Set<Id> projIdSet, String filterQuery , String parentFields) {
        
        List<Assessment_Report__c> assReportList = new List<Assessment_Report__c>();
        String defaultAssReportQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Assessment_Report__c')+
                                parentFields+  
                                    ' ,(SELECT '+ SObjectQueryService.getSObjectFieldsBySObjectNameExceptBlob('Attachment')+
                                        ' FROM Attachments ORDER By createdDate DESC LIMIT 1 )'+
                                ' FROM'+
                                        ' Assessment_Report__c'+
                                ' WHERE'+
                                    ' Project__c IN :projIdSet';
                                    
        if(filterQuery != '') {
             defaultAssReportQry += filterQuery;
        }
        
        System.debug('defaultAssReportQry :::::'+defaultAssReportQry );
        assReportList = database.query(defaultAssReportQry );                           
        return assReportList;    
    }
    
     /**********************************************************************
        Created by Vinitha on Jan 7 2017: This method return list of AssessmentReport 
        @assessmentList - List of AssessmentReport records
        return - list of AssessmentReport records
    ***********************************************************************/ 
    public static list<Assessment_Report__c> insertAssessmentReport(list<Assessment_Report__c> assessmentList) {
    
        if(assessmentList != null && assessmentList.size() > 0){
            insert assessmentList;            
        }
        return assessmentList;    
    }
    /**********************************************************************
        Created by Vinitha on Jan 7 2017: This method return list of AssessmentReport 
        @assessmentList - List of AssessmentReport records
        return - list of AssessmentReport records
    ***********************************************************************/ 
    public static list<Assessment_Report__c> updateAssessmentReport(list<Assessment_Report__c> assessmentList) {
    
        if(assessmentList != null && assessmentList.size() > 0){
            update assessmentList;            
        }
        return assessmentList;    
    } 
    
    
}