trigger Contract_Trigger on Contract (after update, before update, before insert) {
    // Developed to change the Email send behavior for Contract Modified email workflows. 
    if(trigger.isAfter && trigger.isUpdate) {
        SendEmailsForUpdatedFields_Handler se = new SendEmailsForUpdatedFields_Handler();
        //se.sendEmail('Contract',trigger.new,trigger.oldMap,'Contract Modified Notify Users');
    }
    
    // To update the Billing Address and Shipping Address of the Contract based on the Account. 
    Set<Id> acctIds = new Set<Id>();
    Map<Id,Account> acctRecMap = new Map<Id,Account>();
    List<Contract> contrList = new List<Contract>();
    
    if(trigger.isBefore) {
        for(Contract c : trigger.new) {
            if(trigger.isInsert && c.AccountId != null || ( trigger.isUpdate && trigger.OldMap.get(c.Id).AccountId != c.AccountId )) {
                acctIds.add(c.AccountId);
                contrList.add(c);
            }
        }
        
        if( acctIds != null && acctIds.size() > 0 ) {
            acctRecMap = new Map<Id, Account>([SELECT Id,Name, BillingCity, BillingStreet, BillingCountry, BillingState, BillingPostalCode FROM Account WHERE Id IN: acctIds]); 
        }
        
        for( Contract c : contrList) {
            if(c.AccountId != null && acctRecMap.containskey(c.AccountId)) {
            
                if(c.BillingCity == null && c.BillingStreet == null && c.BillingCountry == null && c.BillingState == null && c.BillingPostalCode == null) {
                    c.BillingCity = acctRecMap.get(c.AccountId).BillingCity;
                    c.BillingStreet = acctRecMap.get(c.AccountId).BillingStreet;
                    c.BillingCountry = acctRecMap.get(c.AccountId).BillingCountry;
                    c.BillingState = acctRecMap.get(c.AccountId).BillingState;
                    c.BillingPostalCode = acctRecMap.get(c.AccountId).BillingPostalCode;
                }
                
                if(c.ShippingCity == null && c.ShippingStreet == null && c.ShippingCountry == null && c.ShippingState == null && c.ShippingPostalCode == null) {
                    c.ShippingCity = acctRecMap.get(c.AccountId).BillingCity;
                    c.ShippingStreet = acctRecMap.get(c.AccountId).BillingStreet;
                    c.ShippingCountry = acctRecMap.get(c.AccountId).BillingCountry;
                    c.ShippingState = acctRecMap.get(c.AccountId).BillingState;
                    c.ShippingPostalCode = acctRecMap.get(c.AccountId).BillingPostalCode;
                }
            }
        }
    }
    
    // Added by HL on June 26 2019
    // Work Item : W-002071 - Automatically update Total Amount Funded field on Contract records
    
    if(Trigger.isBefore){
    
        if(Trigger.isUpdate){
        
            for(Contract c : Trigger.new){
                
                System.debug('NEW CONTRACT====='+c);
                Contract oldC = Trigger.oldMap.get(c.Id);
                System.debug('OLD CONTRACT====='+oldC );
                
                if(String.isNotBlank(c.Funding_Type__c)){
                
                    if(c.Funding_Type__c == 'Delivery Order (Child)'){
                    
                        if(c.APXT_Redlining__Contract_Family_Parent__c == NULL && c.Total_Amount_Funded_DOs__c != NULL && c.Total_Amount_Funded_DOs__c != oldC.Total_Amount_Funded_DOs__c ){
                        
                            c.Amount_Funded__c = c.Total_Amount_Funded_DOs__c;
                        }
                        
                        if(c.APXT_Redlining__Contract_Family_Parent__c != NULL && c.Total_Amount_Funded_All_CLINs__c != NULL && c.Total_Amount_Funded_All_CLINs__c != oldC.Total_Amount_Funded_All_CLINs__c){
                        
                            c.Amount_Funded__c = c.Total_Amount_Funded_All_CLINs__c;
                        }            
                            
                        if(c.APXT_Redlining__Contract_Family_Parent__c == NULL && c.APXT_Redlining__Contract_Family_Parent__c != oldC.APXT_Redlining__Contract_Family_Parent__c && c.Total_Amount_Funded_DOs__c != NULL){
                        
                            c.Amount_Funded__c = c.Total_Amount_Funded_DOs__c;
                        }
                        
                        if(c.APXT_Redlining__Contract_Family_Parent__c != NULL && c.APXT_Redlining__Contract_Family_Parent__c != oldC.APXT_Redlining__Contract_Family_Parent__c && c.Total_Amount_Funded_All_CLINs__c != NULL){
                        
                            c.Amount_Funded__c  = c.Total_Amount_Funded_All_CLINs__c;
                        }                                                
                    }
                    
                    if(c.Funding_Type__c == 'CLIN'){
                    
                        if(c.APXT_Redlining__Contract_Family_Parent__c == NULL && c.Total_Amount_Funded_All_CLINs__c != NULL && c.Total_Amount_Funded_All_CLINs__c != oldC.Total_Amount_Funded_All_CLINs__c){
                            
                            c.Amount_Funded__c = c.Total_Amount_Funded_All_CLINs__c;
                        }
                        
                        if(c.APXT_Redlining__Contract_Family_Parent__c == NULL && c.APXT_Redlining__Contract_Family_Parent__c != oldC.APXT_Redlining__Contract_Family_Parent__c && c.Total_Amount_Funded_All_CLINs__c != NULL){
                        
                            c.Amount_Funded__c = c.Total_Amount_Funded_All_CLINs__c;
                        }                        
                    }
                }
            }
        }
    }
}