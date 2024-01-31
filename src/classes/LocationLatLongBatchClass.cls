global class LocationLatLongBatchClass implements Database.batchable<sObject>,Database.AllowsCallouts{
    
    public Static Set<Id> locationIdStaticSet = new Set<Id>();
    global Database.QueryLocator start(Database.BatchableContext info){
       return Database.getQueryLocator('SELECt Id,Geo_Code_Status__c,Location_GeoCode__c,Street__c,City_and_State__c,Country__c,State__c,Zip_Code__c FROM MTT_Location__c WHERE Geo_Code_Status__c != \'Processed\' AND Geo_Code_Status__c != \'Invalid Address\' AND (Street__c != null OR City_and_State__c != null OR Country__c != null OR State__c != null OR Zip_Code__c != null)');
    }
       
    global void execute(Database.BatchableContext info, List<MTT_Location__c> scope){
        TimezoneUtilClass t = new TimezoneUtilClass();
        for(MTT_Location__c l : scope){
           // 1 - 5 Parameters Mailing Address
           // 6 th Parameter - Record Id
           // 7 th Parameter - Object Name
           // 8 - 10 Parameter Fields to be updated
           locationIdStaticSet.add(l.Id);
           t.updateLatLong(l.Street__c,l.City_and_State__c,l.State__c,l.Country__c,l.Zip_Code__c,l.Id,'MTT_Location__c','Location_GeoCode__latitude__s','Location_GeoCode__longitude__s','Geo_Code_Status__c');        
        }
    }  
     
    global void finish(Database.BatchableContext info){  
        if(!Test.isRunningTest()){
            AccountLatLongBatchClass l = new AccountLatLongBatchClass();
            Database.executeBatch(l,1);  
        }
    }
}