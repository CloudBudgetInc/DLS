public class BillingTriggerHandler{
    public static void populateIsBillPostedFieldInRelatedBillingLines(Map<Id, Boolean> billingMap){
        List<AcctSeed__Billing_Line__c> billingLinesToUpdate = new List<AcctSeed__Billing_Line__c>();
        for(AcctSeed__Billing_Line__c bl: [SELECT Id, AcctSeed__Billing__c, Is_Bill_Posted__c 
                                                FROM AcctSeed__Billing_Line__c 
                                                WHERE AcctSeed__Billing__c IN :billingMap.keySet()]){
            
            bl.Is_Bill_Posted__c = billingMap.get(bl.AcctSeed__Billing__c);                               
            billingLinesToUpdate.add(bl);
        }
        
        update billingLinesToUpdate;
    }
}