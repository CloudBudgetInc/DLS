/**********************************************************************
    Created by Siva Prasanth KT on Mar 03, 2020  Service class used for Billing Line object 
***********************************************************************/
public Class BillingLineService{
    
   /**********************************************************************
    Created by Siva Prasanth on Mar 3, 2020 : Service Method using  
    @filterQry- Filter query String
    @parentFields- Parent Fields String.
    @projectIdIdSet- Set of Parent Id's 
    Returns - List of BillingLine.     
   ***********************************************************************/
    public Static List<AcctSeed__Billing_Line__c> getBillLineByParentIds(String filterQry,String parentFields,Set<Id> parentIdSet) {
        
        List<AcctSeed__Billing_Line__c> billingLineList = new List<AcctSeed__Billing_Line__c >();
        String qryString = '';
        
        qryString = 'SELECT '+ SObjectQueryService.getSObjectFieldsBySObjectName('AcctSeed__Billing_Line__c')+
                     parentFields+' FROM AcctSeed__Billing_Line__c';
        
        if(filterQry != null && filterQry != '' && parentIdSet!= null && parentIdSet.size() > 0){
            qryString += filterQry+' IN :parentIdSet';
        }else if(filterQry != null && filterQry != ''){
            qryString += filterQry;
        }
        
        System.debug('qryString:::'+qryString);             
        billingLineList = Database.Query(qryString);
        
        return billingLineList;
    }
}