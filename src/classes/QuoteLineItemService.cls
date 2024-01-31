/**********************************************************************
    Created by Arun on Jan 23, 2017: Service class used for QuoteLineItem
***********************************************************************/

public with sharing Class QuoteLineItemService {
    
 /**********************************************************************
    Created by Arun on Jan 23 2017: 
    @quoteIdSet - Set of Opportunity Ids
    @filterQuery - filter conditions
    @parentFields - parent fields to be queried
    return - List of QuoteLineItem
 ***********************************************************************/
    public Static List<QuoteLineItem> getQuoteLineItemsByquoteIds(Set<Id> quoteIdSet,String filterQuery,String parentFields) {
        List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
        String defaultQuoteLineItemQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('QuoteLineItem')+
                                parentFields+                                  
                                ' FROM'+
                                        ' QuoteLineItem'+
                                ' WHERE'+
                                    ' QuoteId IN :quoteIdSet';
                                    
         if(filterQuery != '') {
             defaultQuoteLineItemQry += defaultQuoteLineItemQry ;
         }
         System.debug('defaultQuoteLineItemQry :::::'+defaultQuoteLineItemQry);
         quoteLineItemList = database.query(defaultQuoteLineItemQry);                           
         return quoteLineItemList;
    }
}