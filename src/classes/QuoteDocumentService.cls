/**********************************************************************
    Created by Arun on Jan 23, 2017: Service class used for QuoteDocument
***********************************************************************/

public with sharing Class QuoteDocumentService {
    
 /**********************************************************************
    Created by Arun on Jan 23 2017: 
    @quoteIdSet - Set of Opportunity Ids
    @filterQuery - filter conditions
    @parentFields - parent fields to be queried
    return - List of QuoteLineItem
 ***********************************************************************/
    public Static List<QuoteDocument> getQuoteDocumentsByquoteIds(Set<Id> quoteIdSet,String filterQuery,String parentFields) {
        List<QuoteDocument> quoteDocumentList = new List<QuoteDocument>();
        String defaultQuoteDocumentQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('QuoteDocument')+
                                parentFields+                                  
                                ' FROM'+
                                        ' QuoteDocument'+
                                ' WHERE'+
                                    ' QuoteId IN :quoteIdSet';
                                    
         if(filterQuery != '') {
             defaultQuoteDocumentQry += defaultQuoteDocumentQry ;
         }
         System.debug('defaultQuoteDocumentQry :::::'+defaultQuoteDocumentQry );
         quoteDocumentList = database.query(defaultQuoteDocumentQry);                           
         return quoteDocumentList;
    }
}