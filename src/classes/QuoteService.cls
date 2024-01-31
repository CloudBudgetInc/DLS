/**********************************************************************
    Created by Arun on Jan 23, 2017: Service class used for Quote
***********************************************************************/

public with sharing Class QuoteService {
    
     /**********************************************************************
        Created by Arun on Jan 23 2017: 
        @oppIdSet - Set of Opportunity Ids
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        return - List of Quotes
     ***********************************************************************/
    public Static List<Quote> getQuoteAndQuoteDocumentsByOppIds(Set<Id> oppIdSet,String filterQuery,String parentFields) {
        List<Quote> quoteList = new List<Quote>();
        String defaultQuoteQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Quote')+
                                parentFields+
                                    ' ,( SELECT '+ SObjectQueryService.getSObjectFieldsBySObjectNameExceptBlob('QuoteDocument') +
                                     ' FROM QuoteDocuments '+
                                     ' ORDER BY CreatedDate DESC '+
                                     ' LIMIT 1)'+                                      
                                ' FROM'+
                                        ' Quote'+
                                ' WHERE'+
                                    ' OpportunityId IN :oppIdSet';
                                    
         if(filterQuery != '') {
             defaultQuoteQry += defaultQuoteQry ;
         }
         System.debug('defaultQuoteQry :::::'+defaultQuoteQry );
         quoteList = database.query(defaultQuoteQry);                           
         return quoteList;
    }
}