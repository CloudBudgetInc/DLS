/**********************************************************************
    Created by Karthiga on Feb 02, 2017: Service class used for OpportunityLineItem
***********************************************************************/
public with sharing class OpportunityLineItemService {
    /**********************************************************************
        Created by Karthiga on Jan 21 2017: 
        @oppId - Set of Opportunity Id's
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        return - List of OpportunityLineItem.
    ***********************************************************************/  
    
    public static List<OpportunityLineItem> getOPLIByOppId(Set<Id> oppId, String filterQuery,String parentFields) {
        List<OpportunityLineItem> opliList = new List<OpportunityLineItem>();
        String defaultOpliQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('OpportunityLineItem')+
                                parentFields+                                       
                                ' FROM'+
                                        ' OpportunityLineItem';
                                       
         if(filterQuery != '') {
             defaultOpliQry += filterQuery;
         }
         
         if(filterQuery == '' && oppId != null && oppId.size() > 0) {
             defaultOpliQry += ' WHERE OpportunityId IN : oppId';
         }else if(oppId != null && oppId.size() > 0) {
             defaultOpliQry += ' AND OpportunityId IN : oppId';
         }
         
         defaultOpliQry += ' ORDER BY CreatedDate';
         
         System.debug('defaultOpliQry :::::'+defaultOpliQry);
         opliList = database.query(defaultOpliQry);                           
         return opliList;
    }
    
    /**********************************************************************
        Created by Karthiga on May 20 2017: 
        @opliList - List of OPLI's to delete   
        return - String "Success" or the exception got.
    ***********************************************************************/ 
    public static String deleteOPLI(List<OpportunityLineItem> opliList) {
        String retn = '';
        try {
            if( opliList != null && opliList.size() > 0 ) {
                delete opliList;
                retn = 'Success';
            }
        } catch(Exception e) {
            System.debug('OpportunityLineItemService::::Exception'+e);
            retn = e.getMessage();
            return retn;
        }
        return retn;
    }
}