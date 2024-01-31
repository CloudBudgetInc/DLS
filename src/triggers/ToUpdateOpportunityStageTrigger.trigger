/**
    Update Opportunity Stage Name as 'Order' When first payment is created
**/
trigger ToUpdateOpportunityStageTrigger on Transaction__c (after insert, before delete) {
    
    Set<Id> oppIdSet = new Set<Id>();
    //Map<Id,List<Transaction__c>> oppIdAndPaymentListMap = new Map<Id,List<Transaction__c>>();
    Set<Id> prePayIds = new Set<Id>();
    List<Opportunity> opportunityToUpdate = new List<Opportunity>();
    Set<Id> fundIdSet = new Set<Id>();
    
    if(trigger.isInsert && trigger.isAfter) {      
    
        for( Transaction__c trans: trigger.new ) {
          
            if(trans.Opportunity__c != null && trans.Project__c == null){
              oppIdSet.add(trans.Opportunity__c);
              prePayIds.add(trans.Id);
            }
        }
        
        if( oppIdSet != null && oppIdSet.size() > 0 ) {
            
            for (Transaction__c t : [SELECT Id,Name,Opportunity__c FROM Transaction__c WHERE Opportunity__c IN :oppIdSet AND Id NOT IN :prePayIds]) {
                
                /*if(oppIdAndPaymentListMap != null && oppIdAndPaymentListMap.size() > 0 && oppIdAndPaymentListMap.containsKey(t.Opportunity__c)){
                    
                    oppIdAndPaymentListMap.get(t.Opportunity__c).add(t);
                    if(oppIdSet.size() > 0 && oppIdSet.contains(t.Opportunity__c)) {
                        oppIdSet.remove(t.Opportunity__c);
                    }
                } else {
                    
                    oppIdAndPaymentListMap.put(t.Opportunity__c,new List<Transaction__c>{t});
                }*/ 
                oppIdSet.remove(t.Opportunity__c);
            } 
            
            if(oppIdSet.size() > 0){
                
                //W-006824 - different stage name for DLI-W TO Opp - Added by NS on July 12                
                for(Opportunity opp : [SELECT Id,Name,StageName,RecordType.DeveloperName FROM Opportunity WHERE Id IN: oppIdSet]) {
                    
                    if(opp.StageName != 'Active') {
                        
                        if(opp.RecordType.DeveloperName != 'DLI_W_TO_Opportunities'){
                            opp.StageName = 'Order';
                        }else {
                            opp.StageName = 'Closed Won';
                        }
                        
                    }
                    opp.CloseDate = system.today(); // By GRK on May 2,2016
                    opportunityToUpdate.add(opp);
                }    
                
                if( opportunityToUpdate != null && opportunityToUpdate.size() > 0 ) {
                    Update opportunityToUpdate;
                } 
            }
        }
    }
    
    // To fire Rollup Helper of PaymentItem when we delete Payment. 
    if(Trigger.isBefore && Trigger.isDelete){
        for( Transaction__c trans: Trigger.old ) {
            fundIdSet.add(trans.Id);
        }
    }
    List<Payment_Item__c> fundItemList = FundingItemService.getPaymentItemsByPaymentIds(' WHERE Payment__c ',fundIdSet);
    
    if(fundItemList.size() > 0){
        delete fundItemList;
    }    
}