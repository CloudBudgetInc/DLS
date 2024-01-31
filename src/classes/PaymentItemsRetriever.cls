/*
    This class is intended for retrieving Funding Items for the funding record.
    implemented by softsquare on 9/30/2016 
    Modified on October 15, 2016 to display the UnitPrice and Total Price
*/
global class PaymentItemsRetriever{
    public Id PayId;
    public List<Payment_Item__c> paymentItemList = new List<Payment_Item__c>();
    public List<PaymentTransaction> PaymentTransactionList {get;set;}
    public String getPayId() {
        return PayId;
    }
    public PaymentItemsRetriever(){
        system.debug('::::::::::::');
    }
    public void setPayId(String t){
        PayId = t;   
        retrieveData();
        system.debug('testing this::::::'+paymentItemList); 
    }
    public class PaymentTransaction{
        public Integer SerialNumber{get;set;}
        public String Id {get;set;}
        public Decimal Quantity {get;set;}
        public String Products {get;set;}        
        public Decimal RateperQuantity {get;set;}
        public Decimal Amount {get;set;} 
        public Decimal unit {get;set;}   
        public Decimal totalAmt {get;set;}            
    }       
    public void retrieveData(){    
       PaymentTransactionList = new List<PaymentTransaction>(); 
       paymentItemList = new List<Payment_Item__c>();
       Set<Id> oppIds = new Set<Id>();
       Map<Id,List<OpportunityLineItem>> oppIdOplis = new Map<Id,List<OpportunityLineItem>>();
       
       for (Payment_Item__c paR : [SELECT Amount__c,Id, Name, Payment__c, Payment__r.Opportunity__c, Quantity__c, Product__r.Name, Project_Task__r.Name, Project_Task__r.Total_Qty_Planned__c, Project_Task__r.Total_Budgeted__c, Rate_per_Quantity__c FROM Payment_Item__c WHERE Payment__c=:PayId]) {
           paymentItemList.add(paR);
           oppIds.add(paR.Payment__r.Opportunity__c);
       }
       if(oppIds!=NULL && oppIds.size()>0){
           for (OpportunityLineItem opli : [ Select Id,Name,OpportunityId,Product2.Id,Product2.Name,UnitPrice,Quantity,TotalPrice FROM OpportunityLineItem WHERE OpportunityId IN : oppIds ]) {
               if(!oppIdOplis.containsKey(opli.OpportunityId)) {
                   oppIdOplis.put(opli.OpportunityId,new List<OpportunityLineItem>());
               }
               oppIdOplis.get(opli.OpportunityId).add(opli);
           }
       }
       System.debug('oppIdOplis::'+oppIdOplis);
       if(paymentItemList!=NULL && paymentItemList.size()>0){
           Integer i = 0;
           for(Payment_Item__c ptm : paymentItemList){
               i++;
               PaymentTransaction ptct = new PaymentTransaction();
               ptct.Id = ptm.Id;
               ptct.SerialNumber = i;
               ptct.Quantity = ptm.Quantity__c;
               //ptct.unit = 0;
               //ptct.totalAmt = 0;
               if(ptm.Product__r.Name!=NULL){
                   ptct.Products = ptm.Product__r.Name;
                   if(oppIdOplis != null && oppIdOplis.containskey(ptm.Payment__r.Opportunity__c) && oppIdOplis.get(ptm.Payment__r.Opportunity__c) != null) {
                       for(OpportunityLineItem opl : oppIdOplis.get(ptm.Payment__r.Opportunity__c) ) {
                           if(opl.Product2.Id == ptm.Product__c) {
                               ptct.unit = opl.Quantity;
                               ptct.totalAmt = opl.TotalPrice;
                           }
                       }
                   }
               }else{
                   ptct.Products = ptm.Project_Task__r.Name;
                   ptct.unit = ptm.Project_Task__r.Total_Qty_Planned__c;
                   ptct.totalAmt = ptm.Project_Task__r.Total_Budgeted__c;
               }               
               ptct.RateperQuantity = ptm.Rate_per_Quantity__c; 
               ptct.Amount = ptm.Amount__c;
               PaymentTransactionList.add(ptct);
           }   
       }    
    }    
    
}