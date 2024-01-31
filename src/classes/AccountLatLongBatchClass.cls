global class AccountLatLongBatchClass implements Database.batchable<sObject>,Database.AllowsCallouts{
    
    public Static Set<Id> accIdStaticSet = new Set<Id>();
    global Database.QueryLocator start(Database.BatchableContext info){
       return Database.getQueryLocator('SELECT Id,Geo_Code_Status__c,BillingCity,BillingStreet,BillingState,BillingCountry,BillingPostalCode,BillingAddress FROM Account WHERE Geo_Code_Status__c != \'Processed\' AND Geo_Code_Status__c != \'Invalid Address\' AND (BillingStreet != null OR BillingCity != null OR BillingState != null OR BillingCountry != null OR BillingPostalCode != null) LIMIT 10');
    }
       
    global void execute(Database.BatchableContext info, List<Account> scope){
        TimezoneUtilClass t = new TimezoneUtilClass();
        for(Account acc : scope){
           // 1 - 5 Parameters Mailing Address
           // 6 th Parameter - Record Id
           // 7 th Parameter - Object Name
           // 8 - 10 Parameter Fields to be updated
           accIdStaticSet.add(acc.Id);
           t.updateLatLong(acc.BillingStreet,acc.BillingCity,acc.BillingState,acc.BillingCountry,acc.BillingPostalCode,acc.Id,'Account','Location_GeoCode__latitude__s','Location_GeoCode__longitude__s','Geo_Code_Status__c');        
        }
    }  
     
    global void finish(Database.BatchableContext info){ 
    
        HotelLatLongBatchClass h = new HotelLatLongBatchClass();
        Database.executeBatch(h,1);   
    }
}