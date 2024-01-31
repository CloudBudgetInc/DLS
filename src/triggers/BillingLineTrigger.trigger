trigger BillingLineTrigger on AcctSeed__Billing_Line__c (after update, before insert, before update) {
    
    if(Trigger.isAfter && Trigger.isUpdate){
        //Added By Dhinesh - W-006606 - To populate Total_Amount_Paid_Billing_Line__c, Most_Recent_Payment_Received_Date_Bill__c  - Fields in related Project Tasks for prepayments on Convert to Projects
        BillingLineTriggerHandler.populateProjTaskContractRollupFields(Trigger.new, Trigger.oldMap);
    }
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        BillingLineTriggerHandler.populateCLINField(Trigger.new, Trigger.oldMap);  
        if(Trigger.isInsert){
            BillingLineTriggerHandler.populateGLAV2Field(Trigger.new);
        } 
        BillingLineTriggerHandler.populateIsBillPosted(Trigger.new);     
    }
}