/*
* Developed by Karthiga on April 06, 2017 to shows the total value of the Contract based on the total value
* of all Contract Modifications dated before this modification in Total_Contract_Value_before__c 
*/
trigger Contract_modification_Trigger on Contract_Modification__c (before insert,after update) {
    Set<Id> contIdSet = new Set<Id>();
    List<contract> contrList = new List<Contract>();
    Map<Id,Decimal> contractIdWithTotalAmtMap = new Map<Id,Decimal>();
    if (trigger.isInsert && trigger.isbefore) {
        for ( Contract_Modification__c cm : trigger.new) {
            contIdSet.add(cm.Contract_Number__c);
        }

        if( contIdSet != null && contIdSet.size() > 0 ) {
            contrList = SObjectQueryService.SObjectQuery('Contract',contIdSet,'');

            for ( Contract c : contrList ) {
                contractIdWithTotalAmtMap.put(c.Id,c.Total_Amount_Funded_Modifications__c);
            }
        }
        
        if(contractIdWithTotalAmtMap != null && contractIdWithTotalAmtMap.size() > 0 ) {
            for(Contract_Modification__c cm : trigger.new) {
                cm.Total_Contract_Value_before__c = contractIdWithTotalAmtMap.containskey(cm.Contract_Number__c) ? contractIdWithTotalAmtMap.get(cm.Contract_Number__c) : 0;
            }
        }
    }
    
    //Added by Vinitha on April 20
    //Send Email Alert When edit the contract modification record.
    if(trigger.isAfter && trigger.isUpdate) {
        SendEmailsForUpdatedFields_Handler se = new SendEmailsForUpdatedFields_Handler();
        se.sendEmail('Contract_Modification__c',trigger.new,trigger.oldMap,'Contract Modified Notify Users');
    }
}