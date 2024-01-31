global class ContactLatLongBatchClass implements Database.batchable<sObject>,Database.AllowsCallouts{
    
    public Static Set<Id> contactIdStaticSet = new Set<Id>();
    global Database.QueryLocator start(Database.BatchableContext info){
       return Database.getQueryLocator('SELECt Id,Geo_Code_Status__c,Location_GeoCode__c,MailingCity,MailingStreet,MailingState,MailingCountry,MailingPostalCode,MailingAddress FROM Contact WHERE Geo_Code_Status__c != \'Processed\' AND Geo_Code_Status__c != \'Invalid Address\' AND (MailingStreet != null OR MailingCity != null OR MailingState != null OR MailingCountry != null OR MailingPostalCode != null) LIMIT 10');
    }
       
    global void execute(Database.BatchableContext info, List<Contact> scope){
        TimezoneUtilClass t = new TimezoneUtilClass();
        for(Contact a : scope){
            // 1 - 5 Parameters Mailing Address
            // 6 th Parameter - Record Id
            // 7 th Parameter - Object Name
            // 8 - 10 Parameter Fields to be updated
            contactIdStaticSet.add(a.Id);
            t.updateLatLong(a.MailingStreet,a.MailingCity,a.MailingState,a.MailingCountry,a.MailingPostalCode,a.Id,'Contact','Location_GeoCode__latitude__s','Location_GeoCode__longitude__s','Geo_Code_Status__c');        
            
        }
        system.debug('contactIdStaticSet Inside Class::::'+contactIdStaticSet);
    }  
     
    global void finish(Database.BatchableContext info){    
        if(!Test.isRunningTest()){
            LocationLatLongBatchClass l = new LocationLatLongBatchClass();
            Database.executeBatch(l,1);
        }
    }
}