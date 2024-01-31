trigger QuoteLineSyncTrigger on QuoteLineItem (before insert, before update, after insert, after update) {
 
    if (TriggerStopper.stopQuoteLine) return;
        
    Set<String> quoteLineFields = QuoteSyncUtil.getQuoteLineFields();
    List<String> oppLineFields = QuoteSyncUtil.getOppLineFields();
    
    String qliFields = QuoteSyncUtil.getQuoteLineFieldsString();
    
    String oliFields = QuoteSyncUtil.getOppLineFieldsString();
            
    Set<Id> qliIds = new Set<Id>();
    
    // Custom code by NS - for Language field validation
    // Before trigger code for custom field sync operation if the QLI is created with Quote
    // Added on Jan 4 2018
    Set<Id> quoteIds_syncOverrideset = new Set<Id>();
    Map<String,OpportunityLineItem> key_OPLIMap = new Map<String,OpportunityLineItem>();
    Set<Id> oppIdSet = new Set<Id>();
    
    //Quote line item maximum discount allowed related calculation - added by NS on MAR 30 2018
    Map<Id,String> quoteId_OppBillingType = new Map<Id,String>();
    Set<Id> qli_PriceBookEntryIds = new Set<Id>();
    Set<Id> quoteIdsForDiscount = new Set<Id>();
    Map<Id,String> PBEId_ProdNameMap = new Map<Id,String>();
    Map<String,Decimal> productName_PriceMap = new Map<String,Decimal>();
    Map<Id,Quote> quoteId_QuoteRecMap = new Map<Id,Quote>();
    
    // Added variables to Map the CLIN record to the QLI - by GRK (April 3, 2018)
    Set<Id> gsaTransPBEIds = new Set<Id>();
    Set<Id> gsaLTPBEIds = new Set<Id>();
    Map<String,String> clinNameMapFromCS = new Map<String,String>();
    Map<String,Id> clinNameIdMap = new Map<String,String>();
    
    if (trigger.isBefore) { 
        if (QuoteSyncUtil.isRunningTest) {
            for (QuoteLineItem qli : trigger.new) {
                QuoteSyncUtil.populateRequiredFields(qli);
            }
        }
        
        // Added to Map the CLIN record to the QLI - by GRK (April 03, 2018)
        for(System_Values__c sv : [SELECT Id,Name,Value__c FROM System_Values__c WHERE Name LIKE '%OPLI/QLI - CLIN%']) {
            clinNameMapFromCS.put(sv.Value__c, sv.Name);
        }
        
        // Added to Map the CLIN record to the QLI - by GRK (April 03, 2018)
        if(clinNameMapFromCS != null && clinNameMapFromCS.size() > 0 ) {
            for(CLIN__c cl : [SELECT Id,Name FROM CLIN__c WHERE Name IN: clinNameMapFromCS.keyset()]) {
                String tmp = clinNameMapFromCS.containskey(cl.Name) ? clinNameMapFromCS.get(cl.Name).removeStart('OPLI/QLI - CLIN - ') : '' ;
                if(tmp != '')
                    clinNameIdMap.put(tmp, cl.Id);
            }
        }
        System.debug('clinNameIdMap::::::'+clinNameIdMap);
        for (QuoteLineItem qli : trigger.new) {
            system.debug(':::qli:::new::::::;'+qli);
            
            if(trigger.isInsert) {
                if(QuoteSyncUtil.quoteIds_ForQLI.contains(qli.QuoteId)) {
                    quoteIds_syncOverrideset.add(qli.QuoteId);
                }
            }
            qli_PriceBookEntryIds.add(qli.PricebookEntryId);
            quoteIdsForDiscount.add(qli.QuoteId);
        } 
        system.debug(':::quoteIds_syncOverrideset:::'+quoteIds_syncOverrideset);
        system.debug(':::::::quoteIdsForDiscount:::::::'+quoteIdsForDiscount);
        
        // GSA pricebook related product price value population in QLI GSA Sales Price field 
        // Added by NS on March 30 2018
        //Qry quote for opp information
        for(Quote quote : [SELECT Id,Name,OpportunityId,Opportunity.A_R_Type__c,Competitive_Bid__c,IsSyncing FROM Quote WHERE Id IN :quoteIdsForDiscount]){
            if(!quoteId_OppBillingType.containsKey(quote.Id)) {
                quoteId_OppBillingType.put(quote.Id,quote.Opportunity.A_R_Type__c);
            }
            
            if(!quoteId_QuoteRecMap.containsKey(quote.Id))
                quoteId_QuoteRecMap.put(quote.Id,quote);
        }
        system.debug(':::::::::quoteId_OppBillingType:::::::'+quoteId_OppBillingType);
        system.debug(':::::::::quoteId_QuoteRecMap:::::::'+quoteId_QuoteRecMap);
        
        //Qry qli price book entry related pricebook details
        for(PriceBookEntry pbe : [SELECT Id,Name,UnitPrice,Pricebook2Id,Pricebook2.Name,Product2Id,Product2.Name 
               FROM PricebookEntry WHERE Id IN :qli_PriceBookEntryIds]){
            if(!PBEId_ProdNameMap.containsKey(pbe.Id))
            PBEId_ProdNameMap.put(pbe.Id,pbe.Product2.Name);
            
            // Added to Map the CLIN record to the QLI - by GRK (April 03, 2018)
            if(pbe.Pricebook2.Name == ('GSA Translation Price Book')) {
                gsaTransPBEIds.add(pbe.Id);
            } else if ( pbe.Pricebook2.Name == 'GSA Language Training Price Book' ) {
                gsaLTPBEIds.add(pbe.Id);
            }
        }
       
        // Qry GSA Price Book related product informations
        for(PriceBookEntry pbe : [SELECT Id,Name,UnitPrice,Pricebook2Id,Pricebook2.Name,Product2Id,Product2.Name 
                                   FROM PricebookEntry 
                                   WHERE Id NOT IN :qli_PriceBookEntryIds AND Product2.Name IN :PBEId_ProdNameMap.values() AND Pricebook2.Name LIKE '%GSA%']){
           
           if(!productName_PriceMap.containsKey(pbe.Product2.Name))
               productName_PriceMap.put(pbe.Product2.Name,pbe.UnitPrice);
        }
        system.debug(':::::productName_PriceMap::::::'+productName_PriceMap);
        
        for(QuoteLineItem qli : trigger.new) {
            if(PBEId_ProdNameMap.containsKey(qli.PricebookEntryId) && productName_PriceMap.containsKey(PBEId_ProdNameMap.get(qli.PricebookEntryId))){
                if(trigger.isInsert) {
                    qli.GSA_List_Price__c = productName_PriceMap.get(PBEId_ProdNameMap.get(qli.PricebookEntryId));
                }
                
                if(trigger.isInsert || (trigger.isUpdate && qli.Quantity != null && qli.Quantity != Trigger.oldMap.get(qli.Id).Quantity)) {
                    
                    if(qli.Product_Family__c == 'Language Training' || qli.Product_Family__c == 'Interpretation' || qli.Product_Family__c == 'Translation') {
                        qli.Maximum_Discount_Allowed__c = 0;
                        
                        if((quoteId_OppBillingType.containsKey(qli.QuoteId) 
                            && quoteId_OppBillingType.get(qli.QuoteId) == '11005-Prepayment')){
                            qli.Maximum_Discount_Allowed__c = 10.5;
                        }
                        
                        if(qli.Quantity >= 48) {
                            qli.Maximum_Discount_Allowed__c += 2.25;
                        }
                        
                        if(qli.Quantity >= 48 && (quoteId_QuoteRecMap.containsKey(qli.QuoteId) 
                            && quoteId_QuoteRecMap.get(qli.QuoteId).Competitive_Bid__c)) {
                            qli.Maximum_Discount_Allowed__c += 2.25;
                        }
                    }
                }
            }
            
            if(trigger.isInsert) {
                // Added to Map the CLIN record to the QLI - by GRK (April 03, 2018)
                if( qli.CLIN_LU__c == null && qli.Product_Family__c == 'Translation' && gsaTransPBEIds.contains(qli.PricebookEntryId) ) {
                    qli.CLIN_LU__c = (clinNameIdMap != null && clinNameIdMap.containskey('Translation')) ? clinNameIdMap.get('Translation') : null;
                } else if ( qli.CLIN_LU__c == null && qli.Product_Family__c == 'Language Training' && gsaLTPBEIds.contains(qli.PricebookEntryId) ) { 
                    qli.CLIN_LU__c = (clinNameIdMap != null && clinNameIdMap.containskey('LT')) ? clinNameIdMap.get('LT') : null;
                } else if ( qli.CLIN_LU__c == null && qli.Product_Family__c == 'Interpretation' && gsaTransPBEIds.contains(qli.PricebookEntryId) ) {
                    qli.CLIN_LU__c = (clinNameIdMap != null && clinNameIdMap.containskey('LT')) ? clinNameIdMap.get('Interpretation') : null;
                }
                
                //For OPLI creation on already synced quote for new QLI creation 
                // To override the OPLI language required validation
                if(quoteId_QuoteRecMap.containsKey(qli.QuoteId) && quoteId_QuoteRecMap.get(qli.QuoteId).IsSyncing){
                    QuoteSyncUtil.quoteIds_ForOPLI.add(qli.QuoteId);
                }
            }
            
            // Update the "Does Not Trigger BOA Monitoring Requirements?" field based on the Sales Price & GSA List Price values
            if(qli.GSA_List_Price__c != null && qli.UnitPrice >= qli.GSA_List_Price__c){
                qli.Does_not_Trigger_BOA_Monitoring_Requirem__c = 'No';
            }
        }
       
       // QLI Sync related changes
       if(quoteIds_syncOverrideset.size() > 0 && trigger.isInsert) {
            //qry quote records for getting opp ids
            for(Quote quote : [SELECT Id,Name,OpportunityId,Opportunity.A_R_Type__c FROM Quote WHERE Id IN :quoteIds_syncOverrideset]){
                if(quote.OpportunityId != null) {
                    oppIdSet.add(quote.OpportunityId);
                }
            }
            system.debug(':::::oppIdSet::::'+oppIdSet);
            
            // Form OPLI map for custom field sync
            String opliQry = 'select Id, OpportunityId, PricebookEntryId, UnitPrice, Quantity, Discount, ServiceDate, SortOrder' + oliFields + ' from OpportunityLineItem where OpportunityId IN :oppIdSet';
            
            for(OpportunityLineItem opli : Database.query(opliQry)){
                String keyVal = opli.pricebookentryid+'-'+opli.UnitPrice+'-'+opli.Quantity+'-'+opli.Discount+'-'+opli.ServiceDate+'-'+opli.SortOrder;
                if(!key_OPLIMap.containsKey(keyVal)){
                    key_OPLIMap.put(keyVal,opli);
                }
            }
            
            system.debug(':::::key_OPLIMap::::'+key_OPLIMap);
            //before insert field mapping from OPLI for QLI
            for(QuoteLineItem qli : trigger.new) {
                if(trigger.isBefore && trigger.isInsert && QuoteSyncUtil.quoteIds_ForQLI.contains(qli.QuoteId)){
                    
                    String qlikey = qli.pricebookentryId+'-'+qli.UnitPrice+'-'+qli.Quantity+'-'+qli.Discount+'-'+qli.ServiceDate+'-'+qli.SortOrder;
                    
                    if(key_OPLIMap.containsKey(qlikey)){
                        for (String qliField : quoteLineFields) {
                            String oliField = QuoteSyncUtil.getQuoteLineFieldMapTo(qliField);
                            qli.put(qliField,key_OPLIMap.get(qlikey).get(oliField));
                            system.debug(':::::::qli:::value::before:change:'+qli);
                        }
                    }
                }
            }
        }else {
            return;
        }
    } 
    // End of our before insert logic
    
    
    if(quoteIds_syncOverrideset.size() == 0) {
    
        for (QuoteLineItem qli : trigger.new) {
            qliIds.add(qli.Id);
        }
        if(qliIds.size() > 0) {
            String qliQuery = 'select Id, QuoteId, PricebookEntryId, UnitPrice, Quantity, Discount, ServiceDate, SortOrder' + qliFields + ' from QuoteLineItem where Id IN :qliIds order by QuoteId, SortOrder ASC';
            //System.debug(':::::qliQuery:::'+qliQuery); 
                
            List<QuoteLineItem> qlis = Database.query(qliQuery);
            
            Map<Id, List<QuoteLineItem>> quoteToQliMap = new Map<Id, List<QuoteLineItem>>();
            
            for (QuoteLineItem qli : qlis) {    
                List<QuoteLineItem> qliList = quoteToQliMap.get(qli.QuoteId);
                if (qliList == null) {
                    qliList = new List<QuoteLineItem>();
                } 
                qliList.add(qli);  
                quoteToQliMap.put(qli.QuoteId, qliList);        
            }
        
            Set<Id> quoteIds = quoteToQliMap.keySet();
            Map<Id, Quote> quotes = new Map<Id, Quote>([select id, OpportunityId, isSyncing from Quote where Id in :quoteIds]);
            
            String oppIds = '';
            Set<Id> filterQuoteIds = new Set<Id>();
            for (Quote quote : quotes.values()) {
                // Only sync quote line item that are inserted for a new Quote or on a isSyncing Quote
                if ((trigger.isInsert && QuoteSyncUtil.isNewQuote(quote.Id)) || quote.isSyncing) {
                   if (oppIds != '') oppIds += ', ';
                   oppIds += '\'' + quote.OpportunityId + '\'';         
                } else {
                    filterQuoteIds.add(quote.Id);
                }
            }
            
            //System.debug('Filter quote ids: ' + filterQuoteIds);
            
            quoteIds.removeAll(filterQuoteIds);
            for (Id id : filterQuoteIds) {
               quotes.remove(id);
               quoteToQliMap.remove(id);
            } 
            
            if (oppIds != '') {   
                String oliQuery = 'select Id, OpportunityId, PricebookEntryId, UnitPrice, Quantity, Discount, ServiceDate, SortOrder' + oliFields + ' from OpportunityLineItem where OpportunityId in (' + oppIds + ') order by OpportunityId, SortOrder ASC';   
                //System.debug(':::::::oliQuery:::::'+oliQuery);    
                
                List<OpportunityLineItem> olis = Database.query(oliQuery);    
                
                Map<Id, List<OpportunityLineItem>> oppToOliMap = new Map<Id, List<OpportunityLineItem>>();
                
                for (OpportunityLineItem oli : olis) {
                    List<OpportunityLineItem> oliList = oppToOliMap.get(oli.OpportunityId);
                    if (oliList == null) {
                        oliList = new List<OpportunityLineItem>();
                    } 
                    oliList.add(oli);  
                    oppToOliMap.put(oli.OpportunityId, oliList);       
                } 
             
                Set<OpportunityLineItem> updateOlis = new Set<OpportunityLineItem>();
                Set<QuoteLineItem> updateQlis = new Set<QuoteLineItem>();
                      
                for (Quote quote : quotes.values()) {
                        
                    List<OpportunityLineItem> opplines = oppToOliMap.get(quote.OpportunityId);
                    
                    // for quote line insert, there will not be corresponding opp line
                    if (opplines == null) continue;        
        
                    Set<OpportunityLineItem> matchedOlis = new Set<OpportunityLineItem>();
                
                    for (QuoteLineItem qli : quoteToQliMap.get(quote.Id)) {
                    
                        boolean updateOli = false;
                        QuoteLineItem oldQli = null;
                        
                        if (trigger.isUpdate) {
                            oldQli = trigger.oldMap.get(qli.Id);
                            //System.debug('Old qli: ' + oldQli.UnitPrice + ', ' + oldQli.Quantity + ', ' + oldQli.Discount + ', ' + oldQli.ServiceDate);
                            //System.debug('New qli: ' + qli.UnitPrice + ', ' + qli.Quantity + ', ' + qli.Discount + ', ' + qli.ServiceDate);
                            
                            if (qli.UnitPrice == oldQli.UnitPrice
                                && qli.Quantity == oldQli.Quantity
                                && qli.Discount == oldQli.Discount
                                && qli.ServiceDate == oldQli.ServiceDate
                                && qli.SortOrder == oldQli.SortOrder 
                               )
                                updateOli = true;                       
                        }
                        
                                                                              
                        boolean hasChange = false;
                        boolean match = false;
                          
                        for (OpportunityLineItem oli : opplines) {          
                            if (oli.pricebookentryid == qli.pricebookentryId  
                                && oli.UnitPrice == qli.UnitPrice
                                && oli.Quantity == qli.Quantity
                                && oli.Discount == qli.Discount
                                && oli.ServiceDate == qli.ServiceDate
                                && oli.SortOrder == qli.SortOrder
                               ) {
                                
                                if (updateOlis.contains(oli) || matchedOlis.contains(oli)) continue;  
                                
                                matchedOlis.add(oli);                       
                                                       
                                for (String qliField : quoteLineFields) {
                                    String oliField = QuoteSyncUtil.getQuoteLineFieldMapTo(qliField);
                                    Object oliValue = oli.get(oliField);
                                    Object qliValue = qli.get(qliField);
                                    if (oliValue != qliValue) { 
                                                                                                        
                                        if (trigger.isInsert && (qliValue == null || (qliValue instanceof Boolean && !Boolean.valueOf(qliValue)))) {
                                        
                                            //System.debug('Insert trigger, isSyncing: ' + quote.isSyncing + ', new quote ids: ' + QuoteSyncUtil.getNewQuoteIds());
                                            
                                            // If it's a newly created Quote, don't sync the "Description" field value, 
                                            // because it's already copied from Opportunity Line Item on create. 
                                            if (quote.isSyncing || (QuoteSyncUtil.isNewQuote(quote.Id) && !qliField.equalsIgnoreCase('description'))) {                                     
                                                qli.put(qliField, oliValue);
                                                hasChange = true; 
                                            }    
                                           
                                        } else if (trigger.isUpdate && !updateOli /*&& oldQli != null*/) {
                                            //Object oldQliValue = oldQli.get(qliField);
                                            //if (qliValue == oldQliValue) {
                                                if (oliValue == null) qli.put(qliField, null);
                                                else qli.put(qliField, oliValue);
                                                hasChange = true;
                                            //}     
                                             
                                        } else if (trigger.isUpdate && updateOli) {
                                            if (qliValue == null) oli.put(oliField, null);
                                            else oli.put(oliField, qliValue);
                                            hasChange = true;  
                                        }
                                    }    
                                }
                                
                                if (hasChange) {
                                    if (trigger.isInsert || (trigger.isUpdate && !updateOli)) { 
                                        updateQlis.add(qli);
                                    } else if (trigger.isUpdate && updateOli) {                               
                                        updateOlis.add(oli);
                                    }                    
                                } 
                                
                                match = true;      
                                break;                          
                            } 
                        }
                        
                        // NOTE: this cause error when there is workflow field update that fired during record create
                        //if (trigger.isUpdate && updateOli) System.assert(match, 'No matching oppline');     
                    }
                }
             
                TriggerStopper.stopOpp = true;
                TriggerStopper.stopQuote = true;             
                TriggerStopper.stopOppLine = true;
                TriggerStopper.stopQuoteLine = true;    
                            
                if (!updateOlis.isEmpty()) { 
                    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                    oliList.addAll(updateOlis);
                                    
                    Database.update(olilist);              
                }
                
                if (!updateQlis.isEmpty()) {
                    List<QuoteLineItem> qliList = new List<QuoteLineItem>();   
                    qliList.addAll(updateQlis);
                                      
                    Database.update(qliList);            
                }
                
                if (Trigger.isInsert) {
                   QuoteSyncUtil.removeAllNewQuoteIds(quoteIds);
                }                             
                
                TriggerStopper.stopOpp = false;
                TriggerStopper.stopQuote = false;                
                TriggerStopper.stopOppLine = false;          
                TriggerStopper.stopQuoteLine = false; 
            }   
        } 
    } 
    
    //Added By HL on Dec 10 2020
    // Work Item : W-006146 - Service Item field to be auto-populate based "Language LU" field
    if(Trigger.isAfter && Trigger.isInsert){
        
        Set<Id> quoteIds = new Set<Id>();
        
        for(QuoteLineItem qli : Trigger.new){
        
            if(qli.QuoteId != NULL){
                quoteIds.add(qli.QuoteId);
            }
        }
        System.debug(':::quoteIds:::'+quoteIds);
        
        if(quoteIds != NULL && quoteIds.size() > 0){
        
            Set<String> serviceItemPickListValueSet = new Set<String>();
            for (Schema.PicklistEntry entry :  Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get('Service_Item__c').getDescribe().getPicklistValues()) {
                if (entry.isActive()) {
                    serviceItemPickListValueSet.add(entry.getValue());
                }
            }
        
            Map<Id, List<QuoteLineItem>> quoteIdAndQLIs = new Map<Id, List<QuoteLineItem>>();
            List<Quote> updateQuotes = new List<Quote>();
            Map<Id, String> quoteIdAndProdName = new Map<Id, String>();
            
           for(QuoteLineItem q : [SELECT Id, QuoteId, Product2.Name, Product_Family__c FROM QuoteLineItem 
                                   WHERE QuoteId IN : quoteIds AND Product2.Name != 'Language Training- Preparation' AND Product_Family__c IN ('Language Training', 'Language Testing')
                                   ORDER BY Product2.Family]){
           
               if(!quoteIdAndQLIs.containsKey(q.QuoteId)){
               
                   quoteIdAndQLIs.put(q.QuoteId, new List<QuoteLineItem>());
               }
               quoteIdAndQLIs.get(q.QuoteId).add(q);
           } 
           
           for(Id qId : quoteIdAndQLIs.keySet()){
           
               for(QuoteLineItem qli : quoteIdAndQLIs.get(qId)){
                                  
                   if(qli.Product_Family__c == 'Language Training'){
                               
                       String prodName = qli.Product2.Name;
                       String langName = '';
                       
                       if(prodName.contains('-')){
                           
                           langName = prodName.split('-')[1].trim();                                   
                           if(langName.contains('(')){
                               langName = langName.split(' ')[1].trim();
                               String target1 = '(';
                               String replacement1 = ' ';
                               langName = langName.replace(target1, replacement1);
                               String target2 = ')';
                               String replacement2 = ' ';
                               langName = langName.replace(target2, replacement2).trim();
                               System.debug('::::langName:::'+langName);
                           }
                       }
                       quoteIdAndProdName.put(qli.QuoteId, langName);
                       break;
                   }else if(qli.Product_Family__c == 'Language Testing'){
                   
                       quoteIdAndProdName.put(qli.QuoteId, 'Language Testing');
                       break;
                   }
               }
           }
           System.debug(':::::quoteIdAndProdName:::::::'+quoteIdAndProdName);
           
           if(quoteIdAndProdName != NULL && quoteIdAndProdName.size() > 0){
           
               for(Id qId : quoteIdAndProdName.keySet()){
               
                   for(String value : serviceItemPickListValueSet){
                   
                        if(quoteIdAndProdName.get(qId) != '' && value.contains(quoteIdAndProdName.get(qId))){
                            
                            Quote q = new Quote();
                            q.Id = qId;
                            q.Service_Item__c = value;
                            updateQuotes.add(q);
                            break;
                        }
                    }
               }
               System.debug(':::::updateQuotes:::::::'+updateQuotes);
               
               if(updateQuotes != NULL && updateQuotes.size() > 0){
                   
                   update updateQuotes;
               }
           }
        }
    }
}