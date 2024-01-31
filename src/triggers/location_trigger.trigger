trigger location_trigger on MTT_Location__c (before insert,before update) {
    
    if(trigger.isInsert && trigger.isBefore){
        for( MTT_Location__c l : trigger.new) {
            l.Geo_Code_Status__c = 'Not Processed';
        }
    }
    if(trigger.isUpdate && trigger.isBefore){
        Set<Id> locationBatchUpdatedIdSet = new Set<Id>();
        locationBatchUpdatedIdSet = LocationLatLongBatchClass.locationIdStaticSet;
        System.debug('locationBatchUpdatedIdSet::::'+locationBatchUpdatedIdSet);
        
        for( MTT_Location__c l : trigger.new) {
            // To update the status if any of the below field changes
            if(!locationBatchUpdatedIdSet.contains(l.Id)) {
                
                if((trigger.oldMap.get(l.Id).Street__c != trigger.newMap.get(l.Id).Street__c) || 
                        (trigger.oldMap.get(l.Id).City_and_State__c != trigger.newMap.get(l.Id).City_and_State__c) ||
                        (trigger.oldMap.get(l.Id).State__c != trigger.newMap.get(l.Id).State__c) ||
                        (trigger.oldMap.get(l.Id).Country__c != trigger.newMap.get(l.Id).Country__c) ||
                        (trigger.oldMap.get(l.Id).Zip_Code__c != trigger.newMap.get(l.Id).Zip_Code__c) ||
                        (trigger.oldMap.get(l.Id).Location_GeoCode__latitude__s != trigger.newMap.get(l.Id).Location_GeoCode__latitude__s) ||
                        (trigger.oldMap.get(l.Id).Location_GeoCode__longitude__s != trigger.newMap.get(l.Id).Location_GeoCode__longitude__s)){
                        
                    l.Geo_Code_Status__c = 'Not Processed';
                }
            }
        }
    }
}