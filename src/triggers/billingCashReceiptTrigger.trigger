trigger billingCashReceiptTrigger on AcctSeed__Billing_Cash_Receipt__c (after insert) {
    
    if(Trigger.isAfter && Trigger.isInsert){
        BillingCashReceiptTriggerHandler.createFundingAndFundingItems(Trigger.new);    
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        //Added By Dhinesh - W-006606 - To populate Total_Amount_Paid_Billing_Line__c, Most_Recent_Payment_Received_Date_Bill__c  - Fields in related Project Tasks once the payments are done
        BillingCashReceiptTriggerHandler.populateProjTaskRollupFields(Trigger.new);    
    }
}