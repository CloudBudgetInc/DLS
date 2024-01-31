trigger HotelGeoStatusUpdate_Trigger on Hotel__c (before insert,before update) {
    if(trigger.isInsert && trigger.isBefore){
                
        for( Hotel__c h : trigger.new) {
            h.Geo_Code_Status__c = 'Not Processed';
        }
    }
    
    if(trigger.isUpdate && trigger.isBefore){
        Set<Id> hotelBatchUpdIdSet = new Set<Id>();
        hotelBatchUpdIdSet = HotelLatLongBatchClass.hotelIdStaticSet;
        System.debug('hotelBatchUpdIdSet::::'+hotelBatchUpdIdSet);
        for( Hotel__c ht : trigger.new) {
            // To update the status if any of the below field changes
            if(!hotelBatchUpdIdSet.contains(ht.Id)) {
                if((trigger.oldMap.get(ht.Id).Address__c != trigger.newMap.get(ht.Id).Address__c) || 
                        (trigger.oldMap.get(ht.Id).Hotel_GeoCode__latitude__s != trigger.newMap.get(ht.Id).Hotel_GeoCode__latitude__s) ||
                        (trigger.oldMap.get(ht.Id).Hotel_GeoCode__longitude__s != trigger.newMap.get(ht.Id).Hotel_GeoCode__longitude__s)) {
                
                    ht.Geo_Code_Status__c = 'Not Processed';
                }
            }
        }
    }
}