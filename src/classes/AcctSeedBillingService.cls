/**********************************************************************
    Created by Arun on Jan 24, 2017: Service class used for AcctSeed__Billing__c
***********************************************************************/

public with sharing Class AcctSeedBillingService {
    
     /**********************************************************************
        Created by Arun on Jan 24 2017: 
        @accId - Set of Account Ids
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        return - List of AcctSeed Billings.
     ***********************************************************************/
    public Static List<AcctSeed__Billing__c> getAcctSeedBillingsByAccId(Set<Id> accId,String filterQuery,String parentFields) {
        List<AcctSeed__Billing__c> acctBillingList = new List<AcctSeed__Billing__c>();
        String defaultAcctBillingQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Billing__c')+
                                parentFields+                                       
                                ' FROM'+
                                        ' AcctSeed__Billing__c'+
                                    ' WHERE'+
                                        ' AcctSeed__Customer__c IN :accId';
         if(filterQuery != '') {
             defaultAcctBillingQry += filterQuery;
         }
         System.debug('defaultAcctBillingQry :::::'+defaultAcctBillingQry );
         acctBillingList = database.query(defaultAcctBillingQry);                           
         return acctBillingList;
    }
}