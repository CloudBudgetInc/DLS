global class HotelLatLongBatchClass implements Database.batchable<sObject>,Database.AllowsCallouts {
    
    public Static Set<Id> hotelIdStaticSet = new Set<Id>();
    global Database.QueryLocator start(Database.BatchableContext info){
       return Database.getQueryLocator('SELECT Id,Geo_Code_Status__c,Hotel_GeoCode__c,Address__c FROM Hotel__c WHERE Geo_Code_Status__c != \'Processed\' AND Geo_Code_Status__c != \'Invalid Address\' AND Address__c != null');
    }
       
    global void execute(Database.BatchableContext info, List<Hotel__c> scope){
        TimezoneUtilClass t = new TimezoneUtilClass();
        for(Hotel__c hotel : scope){
           // 1 - 5 Parameters Mailing Address
           // 6 th Parameter - Record Id
           // 7 th Parameter - Object Name
           // 8 - 10 Parameter Fields to be updated
           hotelIdStaticSet.add(hotel.Id);
           t.updateLatLong(hotel.Address__c,'','','','',hotel.Id,'Hotel__c','Hotel_GeoCode__latitude__s','Hotel_GeoCode__longitude__s','Geo_Code_Status__c');        
        }
    }  
     
    global void finish(Database.BatchableContext info){    
    }
}