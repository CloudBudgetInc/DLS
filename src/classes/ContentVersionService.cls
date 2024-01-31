/**********************************************************************
    Created by Sukanya on Jan 7 2017: Service class used for ContentVersion object
***********************************************************************/
public class ContentVersionService {
     
     /**********************************************************************
        Created by Sukanya on Jan 6 2017: This method return list of ContentVersion records
        @contentRecIdSet - set of ContentVersion records Ids
        return - list of ContentVersion records
    ***********************************************************************/
    
    public static list<ContentVersion> getContentVersionbyIds(Set<Id> contentRecIdSet,Set<Id> parentId) {
     
         list<ContentVersion> contentRecData = new list<ContentVersion>();
         String fieldName = SObjectQueryService.getSObjectFieldsBySObjectNameExceptBlob ('ContentVersion');
         if(contentRecIdSet != null && contentRecIdSet.size() > 0) {
              String defaultQry = 'SELECT '
                                     + fieldName 
                                     + ',ContentDocument.ParentId,ContentDocument.Title'
                                + ' FROM'
                                     +' ContentVersion'
                                +' WHERE'
                                    +' ContentDocumentId != null' 
                                +' AND'
                                    +' IsLatest = true'
                                +' AND'
                                    +' PublishStatus =\'p\''
                                +' AND'
                                    +' Id IN :contentRecIdSet'; 
            contentRecData = Database.query(defaultQry);           
        }else if(parentId != null && parentId.size() > 0) {
            contentRecData = [
                                 SELECT 
                                     Id,
                                     OwnerId,
                                     ContentDocument.ParentId,
                                     Title
                                 FROM
                                     ContentVersion
                                 WHERE
                                     ContentDocument.ParentId IN :parentId
                             ];
        }
        
        return contentRecData;
     }
     
     /**********************************************************************
        Created by Sukanya on Jan 6 2017: This method return list of ContentVersion with 2 conditions
         Number of request/ Average rating with some number count
         @contentRecIdSet - set of ContentVersion record ids
         @fieldName - field name to add at where condition (Number of Request / Average rating)
         @limitCcount - count for fieldName values
         return - list of ContentVersion records
    ***********************************************************************/
    
     public static list<ContentVersion> getContentVersionbyIds(Set<Id> contentRecIdSet,String fieldName,Integer limitCount) {
         list<ContentVersion> contentRecData = new list<ContentVersion>();
         String ObjfieldName = SObjectQueryService.getSObjectFieldsBySObjectNameExceptBlob ('ContentVersion');
         if(contentRecIdSet !=null && contentRecIdSet.size() > 0) {
             contentRecData = Database.query('SELECT '+ObjfieldName
                                                  +', ContentDocument.ParentId,ContentDocument.Title,Language_LU__r.Name'
                                                  +' FROM ContentVersion'
                                                  +' WHERE ContentDocumentId != null AND IsLatest = true AND PublishStatus =\'p\' AND Id IN :contentRecIdSet AND '+fieldName+' > '+limitCount);
        }
        return contentRecData;
     }
     
     /**********************************************************************
        Created by Sukanya on Jan 10 2017: This method return list of ContentVersion with n conditions
         @filterQry - where condition is received 
         return - list of ContentVersion records
    ***********************************************************************/
     
     public static list<ContentVersion> getContentVersionbyFilters(String filterQry) {
     
         list<ContentVersion> contentVersiondata = new list<ContentVersion>();
         String ObjfieldName = SObjectQueryService.getSObjectFieldsBySObjectNameExceptBlob ('ContentVersion');

         String contentVersionqry = 'SELECT '+ObjfieldName
                                  +', ContentDocument.ParentId,ContentDocument.Title,Language_LU__r.Name'
                                  +' FROM ContentVersion'
                                  +' WHERE ContentDocumentId != null AND IsLatest = true AND PublishStatus =\'p\'';
                                      
         if(filterQry != null && filterQry != '') {
             contentVersionqry = contentVersionqry + filterQry;
         }
         contentVersiondata = Database.query(contentVersionqry);
         
        return contentVersiondata;
     }
     
      /**********************************************************************
        Created by Sukanya on Jan 10 2017: This method return list of ContentVersion with n conditions
         @searchInput - keyword string for search
         @filterCondition - where condition add to query
         return - list of list of Sobject records
         
         SOSL - QRY
    ***********************************************************************/
    
    public static List<List<SObject>> getContentVersionbySearchParamter(String searchInput,String filterCondition) {
        
        List<List<SObject>> resultData = new List<List<SObject>>();
        
        String searchQry = 'FIND {'+searchInput+'} IN NAME Fields Returning ContentVersion (PublishStatus,Title,Description,ContentDocumentId,RatingCount,ContentDocument.ParentId,Author__c,Book_Series__c,Cost__c,Language_LU__c,Language_LU__r.Name,Copyright__c,FileType,Average_Rating__c,Number_of_Downloads__c,Rating__c,Sum_Of_Rating__c,CreatedDate';
        
        if(filterCondition != null && filterCondition != '') {
            searchQry = searchQry + filterCondition;
        }
        
        if(searchInput != null) {
            resultData = search.query(searchQry);
        }
        return resultData;
    }
}