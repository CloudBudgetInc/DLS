/**********************************************************************
    Created by Arunkumar on Jan 5, 2017: Service class used for Transaction__c  
***********************************************************************/

public with sharing Class FundingService {

/**********************************************************************
    Created by Arunkumar on Jan 5, 2017: Service Method using  
    @oppIdSet - Set of Opportunity Id's
    Returns - List of Transactions and Related Attachments.   
***********************************************************************/
  //SObjectQueryService is not Used in Attachment Object Because of 'Binary fields cannot be selected in join queries' issue.
    
    public Static List<Transaction__c> getTransactionsAndAttachmentByOpportunityId(Set<Id> oppIdSet) {
        
        List<Transaction__c> transList = new List<Transaction__c>();
        
        if(oppIdSet != null && oppIdSet.size() > 0) {
            
            String transQuery = 'SELECT '+
                        SObjectQueryService.getSObjectFieldsBySObjectName('Transaction__c') +', ('+ 
                            'SELECT  Id, Name, BodyLength, ContentType, Description, IsPrivate, OwnerId, ParentId FROM Attachments ORDER BY createdDate DESC LIMIT 1)'+
                        ' FROM'+
                        ' Transaction__c WHERE Opportunity__c IN :oppIdSet';
            
            System.debug('transQuery:::'+transQuery);             
            transList = Database.Query(transQuery);
                             
        }
        
        return transList;
    }

/**********************************************************************
    Created by Arunkumar on Jan 5, 2017: Service Method using  
    @oppIdSet - Set of Opportunity Id's
    Returns - List of Transactions.     
***********************************************************************/

    public Static List<Transaction__c> getTransactionsByOpportunityId(Set<Id> oppIdSet) {
        
        List<Transaction__c> transList = new List<Transaction__c>();
        
        if(oppIdSet != null && oppIdSet.size() > 0) {
            
            String transQuery = 'SELECT '+
                        SObjectQueryService.getSObjectFieldsBySObjectName('Transaction__c') +
                        ' FROM'+
                        ' Transaction__c WHERE Opportunity__c IN :oppIdSet';
            
            System.debug('transQuery:::'+transQuery);             
            transList = Database.Query(transQuery);
            
        }
        
        return transList;
    }

/**********************************************************************
    Created by Arunkumar on Jan 5, 2017: Service Method using  
    @transList - List of Transactions
    Returns - List of updated Transactions.   
***********************************************************************/

    public Static List<Transaction__c> updateTransactions(List<Transaction__c> transList) {
        
        if(transList != null && transList.size() > 0) {
            
            Update transList;
            return transList;
        }
        
        return null;
    }
    
/**********************************************************************
    Created by Arunkumar on Jan 5, 2017: Service Method using  
    @transList - List of Transactions
    Returns - List of Upserted Transactions.   
***********************************************************************/

    public Static List<Transaction__c> upsertTransactions(List<Transaction__c> transList) {
        
        if(transList != null && transList.size() > 0) {
            
            Upsert transList;
            return transList;
        }
        
        return null;
    }
}