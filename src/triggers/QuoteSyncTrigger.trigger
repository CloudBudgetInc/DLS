trigger QuoteSyncTrigger on Quote (before insert, before update, after insert, after update) {
    
    if (TriggerStopper.stopQuote) return;
    
    Set<String> quoteFields = QuoteSyncUtil.getQuoteFields();
    List<String> oppFields = QuoteSyncUtil.getOppFields();
    
    String quote_fields = QuoteSyncUtil.getQuoteFieldsString();
    
    String opp_fields = QuoteSyncUtil.getOppFieldsString();

    Map<Id, Id> startSyncQuoteMap = new Map<Id, Id>();
    String quoteIds = '';
    Map<Id,PriceBook2> pbIds = new Map<Id,PriceBook2>();
    PriceBook2 GSALTPB = new PriceBook2();
    PriceBook2 GSATransPB = new PriceBook2();
    Set<Id> gsaPBId = new Set<Id>();
    Map<Id,Opportunity> oppUpdateMap = new Map<Id,Opportunity>();
    // To update the QLI when the Competitive bid is selected in the Quote
    Set<Id> quoteId = new Set<Id>();
    List<QuoteLineItem> qlis = new List<QuoteLineItem>();
    
    // populate created by user value to Reviewed by field in quote - Added by NS on April 3 2018
    if(trigger.isBefore){
        for(PriceBook2 pb : [SELECT Id,Name,IsActive,IsStandard,Min_Education__c,Min_Experience__c FROM PriceBook2]) {
            pbIds.put(pb.Id, pb);
            if(pb.Name == 'GSA Language Training Price Book') {
                GSALTPB = pb;
            } else if(pb.Name == 'GSA Translation Price Book') {
                GSATransPB = pb;
            }
            if(pb.Name == 'GSA Language Training Price Book' || pb.Name == 'GSA Translation Price Book') {
                gsaPBId.add(pb.Id);
            }
        }
        for (Quote quote : trigger.new) {
            if(trigger.isInsert && quote.Reviewed_by__c == null) {
                quote.Reviewed_by__c = userinfo.getuserid();//quote.CreatedById;
            }
            // To Populate the Min Education and Experience values from the related Pricebooks - by GRK (03/04/2018)
            if(quote.Pricebook2Id != null && ( trigger.isInsert || (trigger.isUpdate && trigger.OldMap.get(quote.Id).Pricebook2Id != quote.Pricebook2Id))) {
                quote.Min_Education__c = pbIds.get(quote.Pricebook2Id).Min_Education__c;
                quote.Min_Experience__c = pbIds.get(quote.Pricebook2Id).Min_Experience__c;
                
                if(pbIds.containskey(quote.Pricebook2Id)) {
                    if(pbIds.get(quote.Pricebook2Id).Name.contains('Translation') && GSATransPB != null) {
                        quote.GSA_Min_Education__c = GSATransPB.Min_Education__c;
                        quote.GSA_Min_Experience__c = GSATransPB.Min_Experience__c;
                    } else if (!pbIds.get(quote.Pricebook2Id).Name.contains('Translation') && GSALTPB != null) {
                        quote.GSA_Min_Education__c = GSALTPB.Min_Education__c;
                        quote.GSA_Min_Experience__c = GSALTPB.Min_Experience__c;
                    }
                }
                
                
                // Updates the Opp QB contract Type of the Opportunity by GRK - (5/4/2018)
                if(gsaPBId.contains(quote.Pricebook2Id) && quote.Acct_Record_Type_Name__c == 'Accounts') {
                    Opportunity opp = new Opportunity(Id = quote.OpportunityId, QB_Contract_Type__c = 'FED:GSA');
                    if(oppUpdateMap != null && oppUpdateMap.containskey(opp.Id)) {
                        oppUpdateMap.get(opp.Id).QB_Contract_Type__c = 'FEd:GSA';
                    } else {
                        oppUpdateMap.put(opp.Id, Opp);    
                    }
                }               
            } 
        }
    }
    
    if(trigger.isAfter) {
        
        TriggerStopper.stopQuote = true; 
        
        for (Quote quote : trigger.new) {
            
            if (quote.isSyncing && !trigger.oldMap.get(quote.Id).isSyncing) {
                startSyncQuoteMap.put(quote.Id, quote.OpportunityId);
            }
            
            if (quoteIds != '') quoteIds += ', ';
            quoteIds += '\'' + quote.Id + '\'';
            
            // For QLI sync trigger usage - added by NS on JAN 4 2018
            QuoteSyncUtil.quoteIds_ForQLI.add(quote.Id);
            
            //For OPLI creation on start sync click from Quote
            if(quote.isSyncing)
                QuoteSyncUtil.quoteIds_ForOPLI.add(quote.Id);
                
            // When the competitive Bid is true update related QLI
            if(quote.Competitive_Bid__c == true && ( trigger.IsInsert || trigger.isUpdate && quote.Competitive_Bid__c != trigger.oldMap.get(quote.Id).Competitive_Bid__c ) ) {
                quoteId.add(quote.Id);
            }
        }
        
        // To update the related QuoteLineitem when the Quote's competitive Bid is selected.
        if( quoteId != null && quoteId.size() > 0 ) {
            for(QuoteLineItem qli : QuoteLineItemService.getQuoteLineItemsByquoteIds(quoteId, '',',Quote.Opportunity.A_R_Type__c,Quote.Competitive_Bid__c')) {
                Boolean ischanged = false;
                if(qli.Product_Family__c == 'Language Training' || qli.Product_Family__c == 'Interpretation' || qli.Product_Family__c == 'Translation') {
                    qli.Maximum_Discount_Allowed__c = 0;
                    
                    if(qli.Quote.Opportunity.A_R_Type__c == '11005-Prepayment'){
                        qli.Maximum_Discount_Allowed__c = 10.5;
                        ischanged = true;
                    }
                    
                    if(qli.Quantity >= 48) {
                        qli.Maximum_Discount_Allowed__c += 2.25;
                        ischanged = true;
                    }
                    
                    if(qli.Quantity >= 48 && qli.Quote.Competitive_Bid__c == true) {
                        qli.Maximum_Discount_Allowed__c += 2.25;
                        ischanged = true;
                    }
                }
                if(ischanged == true) {
                    qlis.add(qli);
                }
            }
            System.debug('qlis::::::'+qlis);
            if( qlis != null && qlis.size() > 0 ) {
                update qlis;
            }
        }
        
        String quoteQuery = 'select Id, OpportunityId, isSyncing' + quote_fields + ' from Quote where Id in (' + quoteIds + ')';
        //System.debug(quoteQuery);     
    
        List<Quote> quotes = Database.query(quoteQuery);
        
        String oppIds = '';    
        Map<Id, Quote> quoteMap = new Map<Id, Quote>();
        
        for (Quote quote : quotes) {
            if (trigger.isInsert || (trigger.isUpdate && quote.isSyncing)) {
                quoteMap.put(quote.OpportunityId, quote);
                if (oppIds != '') oppIds += ', ';
                oppIds += '\'' + quote.opportunityId + '\'';            
            }
        }
        
        if (oppIds != '') {
            String oppQuery = 'select Id, HasOpportunityLineItem' + opp_fields + ' from Opportunity where Id in (' + oppIds + ')';
            //System.debug(oppQuery);     
        
            List<Opportunity> opps = Database.query(oppQuery);
            List<Opportunity> updateOpps = new List<Opportunity>();
            List<Quote> updateQuotes = new List<Quote>();        
            
            for (Opportunity opp : opps) {
                Quote quote = quoteMap.get(opp.Id);
                
                // store the new quote Id if corresponding opportunity has line items
                if (trigger.isInsert && opp.HasOpportunityLineItem) {
                    QuoteSyncUtil.addNewQuoteId(quote.Id);
                }
                
                boolean hasChange = false;
                for (String quoteField : quoteFields) {
                    String oppField = QuoteSyncUtil.getQuoteFieldMapTo(quoteField);
                    Object oppValue = opp.get(oppField);
                    Object quoteValue = quote.get(quoteField);
                    if (oppValue != quoteValue) {                   
                        if (trigger.isInsert && (quoteValue == null || (quoteValue instanceof Boolean && !Boolean.valueOf(quoteValue)))) {
                            quote.put(quoteField, oppValue);
                            hasChange = true;                          
                        } else if (trigger.isUpdate) {
                            if (quoteValue == null) opp.put(oppField, null);
                            else opp.put(oppField, quoteValue);
                            hasChange = true;                          
                        }                    
                    }                     
                }    
                if (hasChange) {
                    if (trigger.isInsert) { 
                        updateQuotes.add(quote);
                    } else if (trigger.isUpdate) {
                        // Added to update the value in the existing list and removes from the map
                        if( oppUpdateMap.containskey(opp.Id) ) {
                            opp.QB_contract_Type__c = oppUpdateMap.get(opp.Id).QB_contract_Type__c;
                            oppUpdateMap.remove(opp.Id);
                        }
                        updateOpps.add(opp);               
                    }               
                }                                  
            }
            // To add the remaining Opportunity records 
            if(oppUpdateMap != null && oppUpdateMap.size() > 0) {
                updateOpps.add(oppUpdateMap.Values());
            }
            
            if (trigger.isInsert) {
                Database.update(updateQuotes);
            } else if (trigger.isUpdate) {
                TriggerStopper.stopOpp = true;            
                Database.update(updateOpps);
                TriggerStopper.stopOpp = false;              
            }    
        } else { // If it not synced update the opportunity for one time
            update oppUpdateMap.Values();
        }
           
        TriggerStopper.stopQuote = false; 
    }
}