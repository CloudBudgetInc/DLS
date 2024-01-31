trigger Account_Trigger on Account (before insert,before update) {
    Set<String> entitySet = new Set<String>{'C Corporation','S Corporation','Trust/estate','Insurance Agency','1099-Exempt Vendor'};
    
    if(trigger.isInsert && trigger.isBefore){
                
        for( Account a : trigger.new) {
            a.Geo_Code_Status__c = 'Not Processed';
            // Added on April 17, 2018 to update the AcctSeed__X1099_Vendor__c based on Entity field
            if(a.Entity_Type__c != null && !entitySet.contains(a.Entity_Type__c)) {
                a.AcctSeed__X1099_Vendor__c = true;
            }
        }
    }
    
    if(trigger.isUpdate && trigger.isBefore){
        Set<Id> acctBatchUpdIdSet = new Set<Id>();
        acctBatchUpdIdSet = AccountLatLongBatchClass.accIdStaticSet;
        System.debug('acctBatchUpdIdSet::::'+acctBatchUpdIdSet);
        for( Account ac : trigger.new) {
            // To update the status if any of the below field changes
            if(!acctBatchUpdIdSet.contains(ac.Id)) {
                if((trigger.oldMap.get(ac.Id).BillingStreet != trigger.newMap.get(ac.Id).BillingStreet) || 
                        (trigger.oldMap.get(ac.Id).BillingCity != trigger.newMap.get(ac.Id).BillingCity) ||
                        (trigger.oldMap.get(ac.Id).BillingState != trigger.newMap.get(ac.Id).BillingState) ||
                        (trigger.oldMap.get(ac.Id).BillingCountry != trigger.newMap.get(ac.Id).BillingCountry) ||
                        (trigger.oldMap.get(ac.Id).BillingPostalCode != trigger.newMap.get(ac.Id).BillingPostalCode) || 
                        (trigger.oldMap.get(ac.Id).Location_GeoCode__latitude__s != trigger.newMap.get(ac.Id).Location_GeoCode__latitude__s) ||
                        (trigger.oldMap.get(ac.Id).Location_GeoCode__longitude__s != trigger.newMap.get(ac.Id).Location_GeoCode__longitude__s)) {
                
                    ac.Geo_Code_Status__c = 'Not Processed';
                }
            }
            
            // Added on April 17, 2018 to update the AcctSeed__X1099_Vendor__c based on Entity field
            if( ac.Entity_Type__c != null && ac.Entity_Type__c != trigger.OldMap.get(ac.Id).Entity_Type__c ) {
                if(!entitySet.contains(ac.Entity_Type__c)) {
                    ac.AcctSeed__X1099_Vendor__c = true;
                } else if (entitySet.contains(ac.Entity_Type__c)) {
                    ac.AcctSeed__X1099_Vendor__c = false;
                }
            }
        }
    }
}