trigger billingTrigger on AcctSeed__Billing__c (after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        Map<Id, Boolean> billingMap = new Map<Id, Boolean>();
        for(AcctSeed__Billing__c billing : Trigger.new){
            if(billing.AcctSeed__Status__c != Trigger.oldMap.get(billing.Id).AcctSeed__Status__c || Test.isRunningTest()){
                
                billingMap.put(billing.Id, billing.AcctSeed__Status__c == 'Posted');
            }
        }
        if(billingMap.size() > 0)
        	BillingTriggerHandler.populateIsBillPostedFieldInRelatedBillingLines(billingMap);
    }
}