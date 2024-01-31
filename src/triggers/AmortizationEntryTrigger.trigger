// Trigger to populate the name with count for Amortization Entry records
// Developed by E. Keerthika on 16th, August 2018
// Modified by GRK on 17th, Sep 2018 to update the naming convention from "AE-01, AE-02" to "AE-{Accounting Period Name}"

trigger AmortizationEntryTrigger on AcctSeed__Scheduled_Revenue_Expense__c (before insert) {
    
    if(trigger.isInsert && trigger.isBefore) {

        Set<Id> faIds = new Set<Id>();
        Map<Id, String> fixedAssIdNameMap = new Map<Id, String>();
        
        for(AcctSeed__Scheduled_Revenue_Expense__c amoEnt : trigger.new) {
            if(amoEnt.AcctSeed__Fixed_Asset__c != null)
                faIds.add(amoEnt.AcctSeed__Fixed_Asset__c);
        }
        
        // Only if the Fixed asset is assigned
        if(faIds != null && faIds.size() > 0) {
            for(AcctSeed__Fixed_Asset__c fa : [SELECT Id,Name FROM AcctSeed__Fixed_Asset__c WHERE Id IN :faIds]) {
                fixedAssIdNameMap.put(fa.Id, fa.Name);
            }
        
            for(AcctSeed__Scheduled_Revenue_Expense__c amoEnt : trigger.new) {
                if(amoEnt.AcctSeed__Fixed_Asset__c != null && fixedAssIdNameMap.containsKey(amoEnt.AcctSeed__Fixed_Asset__c) ) {
                    String sizeString = fixedAssIdNameMap.get(amoEnt.AcctSeed__Fixed_Asset__c);
                    System.debug(':::1111:::'+amoEnt.AcctSeed__Fixed_Asset__c);
                    if(sizeString.length() > 65 ){
                        sizeString = sizeString.substring(0, 65);
                    }
                    amoEnt.Name = sizeString +'-AE-' + amoEnt.Accounting_Period_Name__c;
                }
            }
        }
    }
}