/**********************************************************************
    Created by Dhinesh on Aug 18, 2020: Service class used for AcctSeed__Cash_Receipt__c
***********************************************************************/

public with sharing Class AcctSeedCashReceiptService {
    
     /**********************************************************************
        Created by Dhinesh on Aug 18, 2020:         
        @filterStr - filter conditions
        @parentFields - parent fields to be queried
		@cashReceiptIds - filter based on ids
        return - List of AcctSeed Cash Receipt.
     ***********************************************************************/
    
    public static List<AcctSeed__Cash_Receipt__c> getAcctSeedCashReceiptsByIds(String filterStr, String parentFields, Set<Id> cashReceiptIds){
        String qryStr = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Cash_Receipt__c');
        
        if(String.isNotBlank(parentFields)){
            qryStr += (', '+parentfields);
        }
        
        qryStr += ' FROM AcctSeed__Cash_Receipt__c WHERE Id IN :cashReceiptIds';
       
        if(String.isNotBlank(filterStr)){
            qryStr += (' '+ filterStr);
        }
        System.debug('filterStr::>'+filterStr);
        return database.query(qryStr);
    }
}