trigger cashReceiptTrigger on AcctSeed__Cash_Receipt__c (after update) {
    
    if(Trigger.isAfter && Trigger.isUpdate){
        
        //Added By Dhinesh - 30/10/2020 - W-005838 - To update funding and funding items if it's already exist for related Cash Receipt's Payment Reference        
        Map<String, AcctSeed__Cash_Receipt__c> payRefWithCashReceiptMap = new Map<String, AcctSeed__Cash_Receipt__c>();
        Set<Id> accountIds = new Set<Id>();
        
        for(AcctSeed__Cash_Receipt__c updatedCashReceipt : Trigger.new){
            
            if(updatedCashReceipt.AcctSeed__Receipt_Date__c != Trigger.oldMap.get(updatedCashReceipt.Id).AcctSeed__Receipt_Date__c){
                if(updatedCashReceipt.AcctSeed__Account__c != null)
                    accountIds.add(updatedCashReceipt.AcctSeed__Account__c);
                    
                payRefWithCashReceiptMap.put(updatedCashReceipt.AcctSeed__Payment_Reference__c, updatedCashReceipt);
            }
        }
        
        if(payRefWithCashReceiptMap.size() > 0){
            Map<Id, Account> accIdWithAccRecMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :accountIds]);
            
            AcctSeed__Cash_Receipt__c cashReceipt;
            List<Transaction__c> updateFundingRecords = new List<Transaction__c>();
             
            for(Transaction__c fund : [ SELECT Id, Transaction_Notes__c, Transaction_Date__c FROM Transaction__c 
                                        WHERE Transaction_Notes__c IN :payRefWithCashReceiptMap.keySet()]){
                
                cashReceipt = payRefWithCashReceiptMap.get(fund.Transaction_Notes__c);
                
                if(cashReceipt.AcctSeed__Account__c != null && accIdWithAccRecMap.get(cashReceipt.AcctSeed__Account__c).Name.startsWith('PVT')){
                    fund.Transaction_Date__c = cashReceipt.AcctSeed__Receipt_Date__c;
                    updateFundingRecords.add(fund);
                }        
            } 
            
            if(updateFundingRecords.size() > 0){
                update updateFundingRecords;
            }
        } 
    }
}