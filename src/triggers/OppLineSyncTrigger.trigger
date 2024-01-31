trigger OppLineSyncTrigger on OpportunityLineItem (before insert, after insert, after update, before update) {
    
    if(Trigger.isBefore){
        
        // Added by HL on Oct 08 2019
        // Work Item : W-002992 - Revenue GL Account field auto-population on Opportunity Product Line Item and Project Task
        // Variables to populate Revenue GL Account and Inventory GL Account
        Map<Id, Product2> productRec;
        Set<Id> proIds = new Set<Id>();
        
        //Added on Mar 03 2022
        Set<Id> oppIds = new Set<Id>();
        
        if(Trigger.isInsert){
        
            for (OpportunityLineItem oli : trigger.new) {
                if(oli.Product2Id != NULL){
                    proIds.add(oli.Product2Id);
                    oppIds.add(oli.OpportunityId);
                }
            }
            System.debug(':::::oppIds:::'+oppIds);
            
            if(oppIds.size() > 0){
                //W-007385 - User Story - DODA CLINs are not auto-populating
                Map<Id, Opportunity> oppRec = new Map<Id, Opportunity>([SELECT Id, Name FROM Opportunity WHERE Id IN : oppIds AND Account.Name = 'DODA']);
                if(oppRec.size() > 0){
                    //Added by NS on Feb 16 2022 - W-007358
                    //Qry system value custom setting to get the clin mapping for OPLI based on product family
                    Map<String,String> productFamilyCLINName = new Map<String,String>();
                    Map<String,Id> clinNameIdMap = new Map<String,Id>();
                    
                    System_Values__c langTrainPrepTimeValue = System_Values__c.getValues('DODA CLIN for LT & Prep Time PTs');
                    System_Values__c materialBudgetValue = System_Values__c.getValues('DODA CLIN for Material PTs');
                    if(langTrainPrepTimeValue != NULL && langTrainPrepTimeValue.Value__c != NULL){
                        productFamilyCLINName.put('Language Training',langTrainPrepTimeValue.Value__c);
                    }
                    if(materialBudgetValue != NULL && materialBudgetValue.Value__c != NULL){
                        productFamilyCLINName.put('Material Budget',materialBudgetValue.Value__c);
                    }
                    
                    //Qry CLIN to get the ids
                    for(CLIN__c clin : [SELECT Id,Name FROM CLIN__c WHERE Name IN :productFamilyCLINName.values()]){
                        clinNameIdMap.put(clin.Name,clin.Id);
                    }
                    Map<Id, Product2> productMap = new Map<Id, Product2>([SELECT Id, Name, Family FROM Product2 WHERE Id IN : proIds]);
                    
                    for(OpportunityLineItem opli : trigger.new){
                        if(productMap.containsKey(opli.Product2Id)){
                            String clinName = productFamilyCLINName.containsKey(productMap.get(opli.Product2Id).Family) ? productFamilyCLINName.get(productMap.get(opli.Product2Id).Family) : '';
                            opli.CLIN_LU__c =  clinNameIdMap.containsKey(clinName) ? clinNameIdMap.get(clinName) : null;
                        }
                    }
                }                
            }
            
            if(proIds.size() > 0){
            
                productRec = new Map<Id, Product2>([SELECT Id, AcctSeed__Revenue_GL_Account__c, AcctSeed__Inventory_GL_Account__c FROM Product2 WHERE Id IN :proIds]);
            }
            
            for( OpportunityLineItem oli : trigger.new ) {
            
                if(oli.Product2Id != NULL && productRec != NULL && productRec.containsKey(oli.Product2Id)){
                    oli.Revenue_GL_Account__c = productRec.get(oli.Product2Id).AcctSeed__Revenue_GL_Account__c;
                    oli.Inventory_GL_Account__c = productRec.get(oli.Product2Id).AcctSeed__Inventory_GL_Account__c;
                }
            }
        }    
    }
    
    if (TriggerStopper.stopOppLine) return;
       
    Set<String> quoteLineFields = QuoteSyncUtil.getQuoteLineFields();
    List<String> oppLineFields = QuoteSyncUtil.getOppLineFields();
    
    String qliFields = QuoteSyncUtil.getQuoteLineFieldsString();
    
    String oliFields =  QuoteSyncUtil.getOppLineFieldsString();
    
    Set<Id> oliIds = new Set<Id>();
    
    // Custom code by NS - for Language field validation
    // Before trigger code for custom field sync operation if the QLI is created with Quote
    // Added on Jan 4 2018
    Set<Id> oppIds_syncOverrideset = new Set<Id>();
    Map<String,QuoteLineItem> key_QLIMap = new Map<String,QuoteLineItem>();
    Set<Id> quoteIdSet = new Set<Id>();
    
    // Added variables to Map the CLIN record to the QLI - by GRK (April 3, 2018)
    Set<Id> gsaTransPBEIds = new Set<Id>();
    Set<Id> gsaLTPBEIds = new Set<Id>();
    Set<Id> oli_PriceBookEntryIds = new Set<Id>();
    Map<String,String> clinNameMapFromCS = new Map<String,String>();
    Map<String,Id> clinNameIdMap = new Map<String,String>();
        
    if (trigger.isBefore && trigger.isInsert) {
        if (QuoteSyncUtil.isRunningTest) {
            for (OpportunityLineItem oli : trigger.new) {
                QuoteSyncUtil.populateRequiredFields(oli);
            }
        }
        
        // Added to Map the CLIN record to the QLI - by GRK (April 04, 2018)
        for(System_Values__c sv : [SELECT Id,Name,Value__c FROM System_Values__c WHERE Name LIKE '%OPLI/QLI - CLIN%']) {
            clinNameMapFromCS.put(sv.Value__c, sv.Name);
        }
        
        // Added to Map the CLIN record to the QLI - by GRK (April 04, 2018)
        if(clinNameMapFromCS != null && clinNameMapFromCS.size() > 0 ) {
            for(CLIN__c cl : [SELECT Id,Name FROM CLIN__c WHERE Name IN: clinNameMapFromCS.keyset()]) {
                String tmp = clinNameMapFromCS.containskey(cl.Name) ? clinNameMapFromCS.get(cl.Name).removeStart('OPLI/QLI - CLIN - ') : '' ;
                if(tmp != '')
                    clinNameIdMap.put(tmp, cl.Id);
            }
        }
        
        for(OpportunityLineItem oli : trigger.new) {
            oppIds_syncOverrideset.add(oli.OpportunityId);
            oli_PriceBookEntryIds.add(oli.PricebookEntryId);
        }
        system.debug('::::::oppIds_syncOverrideset::::'+oppIds_syncOverrideset);
        // Added to Map the CLIN record to the QLI - by GRK (April 04, 2018)
        for(PriceBookEntry pbe : [SELECT Id,Name,UnitPrice,Pricebook2Id,Pricebook2.Name,Product2Id,Product2.Name,
                Product2.AcctSeed__Revenue_GL_Account__c, Product2.AcctSeed__Inventory_GL_Account__c
               FROM PricebookEntry WHERE Id IN :oli_PriceBookEntryIds]){            
           
            if(pbe.Pricebook2.Name == ('GSA Translation Price Book')) {
                gsaTransPBEIds.add(pbe.Id);
            } else if ( pbe.Pricebook2.Name == 'GSA Language Training Price Book' ) {
                gsaLTPBEIds.add(pbe.Id);
            }
        }
        
        //Qry Opp records for getting quote ids related to Opps
        for(Opportunity opp : [SELECT Id,Name,SyncedQuoteID FROM Opportunity WHERE Id IN :oppIds_syncOverrideset]){
            if(opp.SyncedQuoteID != null && QuoteSyncUtil.quoteIds_ForOPLI.contains(opp.SyncedQuoteID)){
                quoteIdSet.add(opp.SyncedQuoteID);
            }else if(opp.SyncedQuoteID != null && !QuoteSyncUtil.quoteIds_ForOPLI.contains(opp.SyncedQuoteID)){
                QuoteSyncUtil.quoteIds_ForQLI.add(opp.SyncedQuoteID);    
            }
        }
        system.debug('::::quoteIdSet:::'+quoteIdSet);
        
        // Added to Map the CLIN record to the QLI - by GRK (April 04, 2018)
        for( OpportunityLineItem oli : trigger.new ) {
            if( oli.CLIN_LU__c == null ) {
                if( oli.Product_Family__c == 'Translation' && gsaTransPBEIds.contains(oli.PricebookEntryId) ) {
                    oli.CLIN_LU__c = (clinNameIdMap != null && clinNameIdMap.containskey('Translation')) ? clinNameIdMap.get('Translation') : null;
                } else if ( oli.Product_Family__c == 'Language Training' && gsaLTPBEIds.contains(oli.PricebookEntryId) ) { 
                    oli.CLIN_LU__c = (clinNameIdMap != null && clinNameIdMap.containskey('LT')) ? clinNameIdMap.get('LT') : null;
                } else if ( oli.Product_Family__c == 'Interpretation' && gsaTransPBEIds.contains(oli.PricebookEntryId) ) {
                    oli.CLIN_LU__c = (clinNameIdMap != null && clinNameIdMap.containskey('Interpretation')) ? clinNameIdMap.get('Interpretation') : null;
                }
            }
        }
        
        if(quoteIdSet.size() > 0) {
        
            // Qry QLI to form the map for custom field sync process
            String qliQuery = 'select Id, QuoteId, PricebookEntryId, UnitPrice, Quantity, Discount, ServiceDate, SortOrder' + qliFields + ' from QuoteLineItem where QuoteId IN :quoteIdSet';   
            for(QuoteLineItem qli : Database.query(qliQuery)){
                String qliKey = qli.pricebookentryid+'-'+qli.UnitPrice+'-'+qli.Quantity+'-'+qli.Discount+'-'+qli.ServiceDate+'-'+qli.SortOrder;
                if(!key_QLIMap.containsKey(qliKey)){
                    key_QLIMap.put(qliKey,qli);
                } 
            }
            system.debug('::::key_QLIMap::::'+key_QLIMap);
            
            for(OpportunityLineItem oli : trigger.new){
                String olikey = oli.pricebookentryId+'-'+oli.UnitPrice+'-'+oli.Quantity+'-'+oli.Discount+'-'+oli.ServiceDate+'-'+oli.SortOrder;
                    
                if(key_QLIMap.containsKey(olikey)){
                    for(String qliField : quoteLineFields){
                        String oliField = QuoteSyncUtil.getQuoteLineFieldMapTo(qliField);
                        oli.put(oliField,key_QLIMap.get(olikey).get(qliField));
                        system.debug(':::::::oli:::value::before:change:'+oli);
                    }
                }
            }
            
        } else {
            return;
        } 
    }
    // End of our custom code for sync process on before insert
    
    if(quoteIdSet.size() == 0 || trigger.isAfter) {
    
        for (OpportunityLineItem oli : trigger.new) {
            oliIds.add(oli.Id);
        }
        
        if(oliIds.size() > 0) {
            String oliQuery = 'select Id, OpportunityId, PricebookEntryId, UnitPrice, Quantity, Discount, ServiceDate, SortOrder' + oliFields + ' from OpportunityLineItem where Id IN :oliIds order by OpportunityId, SortOrder ASC';
            //System.debug(oliQuery); 
             
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
        
            Set<Id> oppIds = oppToOliMap.keySet();
            Map<Id, Opportunity> opps = new Map<Id, Opportunity>([select id, SyncedQuoteId from Opportunity where Id in :oppIds and SyncedQuoteId != null]);
            
            String quoteIds = '';
            for (Opportunity opp : opps.values()) {
                if (opp.SyncedQuoteId != null) {
                   if (quoteIds != '') quoteIds += ', ';
                   quoteIds += '\'' + opp.SyncedQuoteId + '\'';         
                }
            }
           
            if (quoteIds != '') {
                   
                String qliQuery = 'select Id, QuoteId, PricebookEntryId, UnitPrice, Quantity, Discount, ServiceDate, SortOrder' + qliFields + ' from QuoteLineItem where QuoteId in (' + quoteIds + ') order by QuoteId, SortOrder ASC';   
                //System.debug(qliQuery);    
                       
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
                     
                Set<QuoteLineItem> updateQlis = new Set<QuoteLineItem>();
                Set<OpportunityLineItem> updateOlis = new Set<OpportunityLineItem>();
                                
                for (Opportunity opp : opps.values()) {  
                
                    List<QuoteLineItem> quotelines = quoteToQliMap.get(opp.SyncedQuoteId);  
                    
                    // for opp line insert, there will not be corresponding quote line
                    if (quotelines == null) continue;      
                
                    Set<QuoteLineItem> matchedQlis = new Set<QuoteLineItem>();        
                
                    for (OpportunityLineItem oli : oppToOliMap.get(opp.Id)) {
         
                        boolean updateQli = false;
                        OpportunityLineItem oldOli = null;
                        
                        if (trigger.isUpdate) {
                            //System.debug('Old oli: ' + oldOli.UnitPrice + ', ' + oldOli.Quantity + ', ' + oldOli.Discount + ', ' + oldOli.ServiceDate);
                            //System.debug('New oli: ' + oli.UnitPrice + ', ' + oli.Quantity + ', ' + oli.Discount + ', ' + oli.ServiceDate);
                                         
                            oldOli = trigger.oldMap.get(oli.Id);
                            if (oli.UnitPrice == oldOli.UnitPrice
                                && oli.Quantity == oldOli.Quantity
                                && oli.Discount == oldOli.Discount
                                && oli.ServiceDate == oldOli.ServiceDate
                                && oli.SortOrder == oldOli.SortOrder 
                               )
                                updateQli = true;  
                        }
                                                           
                        boolean hasChange = false;
                        boolean match = false;
                                          
                        for (QuoteLineItem qli : quotelines) {       
                            if (oli.pricebookentryid == qli.pricebookentryId 
                                && oli.UnitPrice == qli.UnitPrice 
                                && oli.Quantity == qli.Quantity 
                                && oli.Discount == qli.Discount
                                && oli.ServiceDate == qli.ServiceDate
                                && oli.SortOrder == qli.SortOrder
                               ) {
                               
                                if (updateQlis.contains(qli) || matchedQlis.contains(qli)) continue;
                                
                                matchedQlis.add(qli);                                                    
                                                                                       
                                for (String qliField : quoteLineFields) {
                                    String oliField = QuoteSyncUtil.getQuoteLineFieldMapTo(qliField);
                                    Object oliValue = oli.get(oliField);                          
                                    Object qliValue = qli.get(qliField);
                                   
                                    if (oliValue != qliValue) { 
                                                                
                                        if (trigger.isInsert) {
                                            if (qliValue == null) oli.put(oliField, null);
                                            else oli.put(oliField, qliValue);
                                            hasChange = true;
        
                                        } else if (trigger.isUpdate && !updateQli /*&& oldOli != null*/) {
                                            //Object oldOliValue = oldOli.get(oliField); 
                                            //if (oliValue == oldOliValue) {                                    
                                                if (qliValue == null) oli.put(oliField, null);
                                                else oli.put(oliField, qliValue);
                                                hasChange = true;
                                            //}    
                                                                                
                                        } else if (trigger.isUpdate && updateQli) {
                                            if (oliValue == null) qli.put(qliField, null);
                                            else qli.put(qliField,  oliValue);
                                            hasChange = true;
                                        }
                                    }
                                }
                                if (hasChange) {
                                    if (trigger.isInsert || (trigger.isUpdate && !updateQli)) { 
                                        updateOlis.add(oli);
                                    } else if (trigger.isUpdate && updateQli) { 
                                        updateQlis.add(qli);
                                    }                    
                                }
                                
                                match = true;                       
                                break;                
                            } 
                        }
                                                                        
                        // NOTE: this cause error when there is workflow field update that fired during record create
                        //if (trigger.isUpdate && updateQli) System.assert(match, 'No matching quoteline');     
                    }
                }
        
                TriggerStopper.stopOpp = true;
                TriggerStopper.stopQuote = true;        
                TriggerStopper.stopOppLine = true;        
                TriggerStopper.stopQuoteLine = true;    
                            
                if (!updateOlis.isEmpty()) {  
                    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
                    oliList.addAll(updateOlis);
                                   
                    Database.update(oliList);              
                }
                
                if (!updateQlis.isEmpty()) { 
                    List<QuoteLineItem> qliList = new List<QuoteLineItem>();   
                    qliList.addAll(updateQlis);
                                  
                    Database.update(qliList);            
                }                             
                
                TriggerStopper.stopOpp = false;
                TriggerStopper.stopQuote = false;         
                TriggerStopper.stopOppLine = false;          
                TriggerStopper.stopQuoteLine = false; 
            }
        }
    }    
}