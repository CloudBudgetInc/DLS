/**********************************************************************
    Created by Arunkumar on Jan 6, 2017: Service Class used for Payment_Item__c
***********************************************************************/

/**********************************************************************
    Created by Arunkumar on Jan 6, 2017: Service Method using  
    @oppIdSet - Set of Opportunity Id's 
    Returns - List of Payment Items.
***********************************************************************/
public Class FundingItemService {
    public Static String fldStr = 'Amount__c,Payment__c,Product__c,Project_Task__c,Quantity__c,Rate_per_Quantity__c,Id,Name,Opportunity_Product_Id__c';
    
    public Static List<Payment_Item__c> getPaymentItemsByPaymentOpportunityIds(Set<Id> oppIdSet) {
        
        List<Payment_Item__c> paymentItemList = new List<Payment_Item__c>();
        
        if(oppIdSet != null && oppIdSet.size() > 0) {
            
            String payItemsQuery = 'SELECT '+
                        //SObjectQueryService.getSObjectFieldsBySObjectName('Payment_Item__c') +
                        //Edited to change Quantity__c into Total_Qty_Planned__c on dec-13-2017
                        fldStr +
                        ' ,Project_Task__r.Name,'+
                        ' Project_Task__r.Project_Task_Type__c,'+
                        ' Project_Task__r.Total_Budgeted__c,'+
                        ' Project_Task__r.Total_Spent__c,'+
                        ' Project_Task__r.Total_Amount_Paid__c,'+
                        ' Project_Task__r.Total_Qty_Planned__c,'+
                        ' Payment__r.Project__c,'+
                        ' Product__r.Name,'+
                        ' Product__r.Family,'+
                        ' payment__r.Name,'+
                        ' payment__r.Opportunity__c'+
                        ' FROM'+
                        ' Payment_Item__c WHERE payment__r.Opportunity__c IN :oppIdSet';
                        
            paymentItemList = Database.Query(payItemsQuery);
            System.debug('paymentItemList:::'+paymentItemList);                  
           
        }
        
        return paymentItemList;
    }
 
      //Commented this method because doesn't use any component.
    /**********************************************************************
        Created by Arunkumar on Jan 6, 2017: Service Method using  
        @paymentIdSet - Set of Payment Id's 
        Returns - List of Payment Items.
    ***********************************************************************/   

    public Static List<Payment_Item__c> getPaymentItemsByPaymentIds(String filterQry,Set<Id> paymentIdSet) {
        
        List<Payment_Item__c> paymentItemList = new List<Payment_Item__c>();
        
        if(filterQry != null && filterQry != '' && paymentIdSet != null && paymentIdSet.size() > 0) {
            
            String payItemsQuery = 'SELECT '+
                        SObjectQueryService.getSObjectFieldsBySObjectName('Payment_Item__c') +
                        ' ,Project_Task__r.Name,'+
                        ' Project_Task__r.Project_Task_Type__c,'+
                        ' Project_Task__r.Total_Budgeted__c,'+
                        ' Project_Task__r.Total_Spent__c,'+
                        ' Project_Task__r.Total_Amount_Paid__c,'+
                        ' Project_Task__r.Total_Qty_Planned__c,'+
                        ' Payment__r.Project__c,'+
                        ' Product__r.Name,'+
                        ' Product__r.Family,'+
                        ' Payment__r.Name,'+
                        ' payment__r.Opportunity__c,'+
                        ' Payment__r.Method_of_Payment__c,'+
                        ' Payment__r.Customer_Name__c,'+
                        ' Payment__r.Customer_Name__r.Name,'+
                        ' Payment__r.Transaction_Date__c,'+
                        ' Payment__r.Auth_last_4_digits__c,'+
                        ' Payment__r.Total_Amount__c,'+
                        ' Payment__r.Transaction_Notes__c,'+
                        ' Payment__r.Project__r.DLS_Ref__c'+
                        ' FROM'+
                        ' Payment_Item__c'+
                        filterQry+
                        ' IN :paymentIdSet';
                        
            paymentItemList = Database.Query(payItemsQuery);
            System.debug('paymentItemList:::'+paymentItemList);    
            System.debug('paymentIdSet::'+paymentIdSet);           
        }
        
        return paymentItemList;
    }
    
    /**********************************************************************
        Created by Arun on Jan 19 2017: 
        @projTaskIdSet - Set of Project Task Ids
        @filterQuery - filter conditions
        @parentFields - parent fields to be queried
        return - List of Payment Items.
     ***********************************************************************/
 
    public Static List<Payment_Item__c> getPaymentItemsByProjTaskIds(Set<Id> projTaskIdSet,String filterQuery,String parentFields) {
        List<Payment_Item__c> payItemList = new List<Payment_Item__c>();
        String defaultPayItemQry = 'SELECT ' + SObjectQueryService.getSObjectFieldsBySObjectName('Payment_Item__c')+
                                parentFields+                                       
                                ' FROM'+
                                        ' Payment_Item__c'+
                                    ' WHERE'+
                                        ' Project_Task__c IN :projTaskIdSet';
         if(filterQuery != '') {
             defaultPayItemQry += filterQuery;
         }
         System.debug('defaultPayItemQry :::::'+defaultPayItemQry);
         payItemList = database.query(defaultPayItemQry);                           
         return payItemList;
    }

    /**********************************************************************
        Created by Arunkumar on Jan 6, 2017: Service Method using 
        @paymentItems - Set of Payment Items.
        Returns - List of Updated PaymentItems.
    ***********************************************************************/ 
  
    public Static List<Payment_Item__c> updatePaymentItems(List<Payment_Item__c> paymentItems) {
        
        if(paymentItems != null && paymentItems.size() > 0) {
            
            Update paymentItems;
            return paymentItems;
        }
        
        return null;
    }
     
     //Commented this method because doesn't use any component.   
    /**********************************************************************
        Created by Arunkumar on Jan 6, 2017: Service Method using 
        @paymentItems - Set of Payment Items.
        Returns - List of Upserted PaymentItems.
    ***********************************************************************/ 
  
    /*public Static List<Payment_Item__c> upsertPaymentItems(List<Payment_Item__c> paymentItems) {
        
        if(paymentItems != null && paymentItems.size() > 0) {
            
            Upsert paymentItems;
            return paymentItems;
        }
        
        return null;
    }*/
}