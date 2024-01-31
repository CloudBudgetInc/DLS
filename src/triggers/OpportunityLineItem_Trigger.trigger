/***********************************************************************************
Created By Karthiga on 02 Feb,2017 to update the fields in Opportunity for TOEP form
************************************************************************************/

trigger OpportunityLineItem_Trigger on OpportunityLineItem (after insert,after update,after delete) {
    
    List<Opportunity> oppList = new List<Opportunity>();
    List<OpportunityLineItem> opList = new List<OpportunityLineItem>();
    Set<Id> oppIdSet = new Set<Id>();
    Set<Id> deletedOPLI = new Set<Id>(); // To store deleted OPLI Ids
    Map<Id,List<OpportunityLineItem>> oppWithOPLIMap = new Map<Id,List<OpportunityLineItem>>();
    
    // Variables to update the Billing Line records
    Set<Id> oppIds = new Set<Id>();
    Map<Id,OpportunityLineItem> OPLIMap = new Map<Id,OpportunityLineItem>();
    List<AcctSeed__Billing_Line__c> billLines = new List<AcctSeed__Billing_Line__c>();
    
    if( trigger.isafter) {
        if(trigger.isInsert || trigger.isUpdate) {
            for(OpportunityLineItem opli : trigger.new) {
                System.debug('opli::::'+opli);
                if( ( trigger.isInsert && (opli.CLIN_LU__c != null || opli.UnitPrice != null) ) || (trigger.isUpdate && (trigger.oldMap.get(opli.Id).CLIN_LU__c != opli.CLIN_LU__c || trigger.oldMap.get(opli.Id).UnitPrice != opli.UnitPrice || trigger.oldMap.get(opli.Id).Quantity != opli.Quantity )) ) {
                    oppIdSet.add(opli.OpportunityId);
                }
                // Added by GRK to update the Billing Line when the Qty or UnitPrice is updated in the OPLI
                if(trigger.isupdate && (trigger.oldMap.get(opli.Id).UnitPrice != opli.UnitPrice || trigger.oldMap.get(opli.Id).Quantity != opli.Quantity) ) {
                    oppIds.add(opli.OpportunityId);
                    OPLIMap.put(opli.Id, opli);
                }
            }
        } else if(trigger.isDelete) {
            for(OpportunityLineItem opli : trigger.old) {
                oppIdSet.add(opli.OpportunityId);
                deletedOPLI.add(opli.Id);
            }
        }
        
        if(deletedOPLI != null && deletedOPLI.size() > 0){
            ContactAssignmentTriggerHandler.removeOppProIdFromCA(deletedOPLI);
        }
        
        if( oppIdSet != null && oppIdSet.size() > 0 ) {
            
            opList = OpportunityLineItemService.getOPLIByOppId(oppIdSet,'',',CLIN_LU__r.Name,Product2.Family,Product2.RecordType.DeveloperName,Product2.Name,Opportunity.Pricebook2.Name');       
            
            List<Opportunity> updateOppList = new List<Opportunity>();
            Set<String> excludeProductNameSet = new Set<String>{'In House Testing-LT', 'GSA Additional Student', 'ADMINISTRATIVE', 'Additional Student', 'Subject Matter Expert', 'Fringe','Preparation', 'Registration Fee - On-Site'};
            
            for ( OpportunityLineItem o : opList ) {
                if(!oppWithOPLIMap.containskey(o.OpportunityId)) {
                    oppWithOPLIMap.put(o.OpportunityId,new List<OpportunityLineItem>());
                }
                oppWithOPLIMap.get(o.OpportunityId).add(o);
                
                
                if(o.Product2Id != null && Trigger.newMap != null  && Trigger.newMap.get(o.Id) != null && 
                   (o.Product2.RecordType.DeveloperName == 'Language_Training' && o.Product2.Family == 'Language Training') && 
                   ((trigger.isInsert && o.UnitPrice != null) || (Trigger.isUpdate && Trigger.oldMap.get(o.Id).UnitPrice != Trigger.newMap.get(o.Id).UnitPrice)) && 
                   (o.Opportunity.Pricebook2.Name != 'FSI Price Book' || (o.Opportunity.Pricebook2.Name == 'FSI Price Book' && (o.Product2.Name.contains('Language Instructor') || o.Product2.Name.contains('Distance Learning'))))){ 
                   
                    Boolean updateOppHrsrate = true;
                    for(String excludeProductName : excludeProductNameSet){
                    
                        if(o.Product2.Name.containsIgnoreCase(excludeProductName)){
                            updateOppHrsrate = false;
                            break; 
                        }
                    }
                    
                    if(updateOppHrsrate){
                        updateOppList.add(new Opportunity(Id = o.OpportunityId, Hourly_Rate__c = Trigger.newMap.get(o.Id).UnitPrice));
                    }
                }
            }
            
            if(updateOppList.size() > 0){
                update updateOppList;
            }
            
            for(Id opId : oppWithOPLIMap.keySet()) {
                Opportunity opp = new Opportunity(Id = opId);
                Map<String,Map<String,Decimal>> tempMap = new Map<String,Map<String,Decimal>>(); // First Key - Product Family, Second Key - Combination of CLIN Name and UnitPrice, Value - Quantity
                
                for( OpportunityLineItem i : oppWithOPLIMap.get(opid)) {
                    if( i.CLIN_LU__c != null ) {
                        if( i.Product2.Family != 'Travel' && i.Product2.Family != 'ODC') {
                            if(!tempMap.containskey(i.Product2.Family)) {
                                tempMap.put(i.Product2.Family,new Map<String,Decimal>{i.CLIN_LU__r.Name + '~~' + i.UnitPrice => i.Quantity});
                            } else if(tempMap.get(i.Product2.Family).containsKey(i.CLIN_LU__r.Name + '~~' + i.UnitPrice)) {
                                Decimal intn = tempMap.get(i.Product2.Family).get(i.CLIN_LU__r.Name + '~~' + i.UnitPrice) + i.Quantity;
                                tempMap.get(i.Product2.Family).put(i.CLIN_LU__r.Name  + '~~' + i.UnitPrice,intn);
                            } else if(!tempMap.get(i.Product2.Family).containsKey(i.CLIN_LU__r.Name + '~~' + i.UnitPrice)) {
                                tempMap.get(i.Product2.Family).put(i.CLIN_LU__r.Name  + '~~' + i.UnitPrice,i.Quantity);
                            }
                        } else {
                            if(!tempMap.containskey(i.Product2.Family)) {
                                tempMap.put(i.Product2.Family,new Map<String,Decimal>{i.CLIN_LU__r.Name => i.TotalPrice});
                            } else if(tempMap.get(i.Product2.Family).containsKey(i.CLIN_LU__r.Name)) {
                                Decimal intn = tempMap.get(i.Product2.Family).get(i.CLIN_LU__r.Name) + i.TotalPrice;
                                tempMap.get(i.Product2.Family).put(i.CLIN_LU__r.Name,intn);
                            } else if(!tempMap.get(i.Product2.Family).containsKey(i.CLIN_LU__r.Name)) {
                                tempMap.get(i.Product2.Family).put(i.CLIN_LU__r.Name,i.TotalPrice);
                            }
                        }
                        //} else if(!tempMap.get(i.Product2.Family).containsKey(i.CLIN_LU__r.Name)) {
                        //    tempMap.get(i.Product2.Family).put(i.CLIN_LU__r.Name,i.TotalPrice);
                        //}
                    }                
                }

                if(tempMap.containskey('Language Training') ) {
                    for(String str : tempMap.get('Language Training').keySet()) {
                        if(opp.Language_Training_CLIN__c != null) {
                            opp.Language_Training_CLIN__c += str.split('~~')[0] + ': ($'+ str.split('~~')[1] + '/hrs X '+Integer.ValueOf(tempMap.get('Language Training').get(str)) + 'hrs.) \n';
                        } else {
                            opp.Language_Training_CLIN__c = str.split('~~')[0] + ': ($'+ str.split('~~')[1] + '/hrs X '+Integer.ValueOf(tempMap.get('Language Training').get(str)) + 'hrs.) \n';
                        }
                    }
                }

                if(tempMap.containskey('Material Budget') ) {
                    for(String str : tempMap.get('Material Budget').keySet()) {
                        if( opp.Materials_CLIN__c != null ) {
                            opp.Materials_CLIN__c += str.split('~~')[0] + ': ($'+ str.split('~~')[1] + ') \n';
                        } else {
                            opp.Materials_CLIN__c = str.split('~~')[0] + ': ($'+ str.split('~~')[1] + ') \n';
                        }
                    }
                }

                if(tempMap.containskey('Travel') ) {
                    System.debug('tempMap.get(Travel):::::'+tempMap.get('Travel'));
                    for(String str : tempMap.get('Travel').keySet()) {
                        if( opp.Travels_CLIN__c != null ) {
                            opp.Travels_CLIN__c += str + ': ($'+ tempMap.get('Travel').get(str) +') \n';
                        } else {
                            opp.Travels_CLIN__c = str + ': ($'+ tempMap.get('Travel').get(str) + ') \n';
                        }
                    }
                }
                
                if(tempMap.containskey('ODC') ) {
                    System.debug('tempMap.get(ODC):::::'+tempMap.get('ODC'));
                    for(String str : tempMap.get('ODC').keySet()) {
                        if( opp.ODC_CLIN__c != null ) {
                            opp.ODC_CLIN__c += str + ': ($'+ tempMap.get('ODC').get(str) +') \n';
                        } else {
                            opp.ODC_CLIN__c = str + ': ($'+ tempMap.get('ODC').get(str) + ') \n';
                        }
                    }
                }

                if(opp.Language_Training_CLIN__c != null || opp.Materials_CLIN__c != null || opp.Travels_CLIN__c != null || opp.ODC_CLIN__c != null) {
                    oppList.add(opp);
                }                              
            }

            if( oppList != null && oppList.size() > 0 ) {
                List<Opportunity> oppList1 = OpportunityService.updateOpp(oppList);
            }
            
            // To update the Billing Line records associated to the Opportunity and Opportunity Line Item
            if( oppIds != null && oppIds.size() > 0 && OPLIMap.size() > 0 ) {
                for(AcctSeed__Billing_Line__c bl : [SELECT Id,AcctSeed__Rate__c,AcctSeed__Hours_Units__c,AcctSeed__Opportunity_Product_Id__c FROM AcctSeed__Billing_Line__c WHERE AcctSeed__Billing__r.AcctSeed__Opportunity__c IN: oppIds AND AcctSeed__Opportunity_Product_Id__c IN: OPLIMap.keyset()]) {
                    
                    OpportunityLineItem oli = OPLIMap.get(bl.AcctSeed__Opportunity_Product_Id__c );
                    
                    if(bl.AcctSeed__Rate__c != oli.UnitPrice){
                        bl.AcctSeed__Rate__c = oli.UnitPrice;
                    }
                    
                    if(bl.AcctSeed__Hours_Units__c != oli.Quantity) {
                        bl.AcctSeed__Hours_Units__c = oli.Quantity;
                    }
                    billLines.add(bl);
                }
                if(billLines.size() > 0) {
                    System.debug('billLines::::'+billLines);
                    update billLines;
                }
            }
        }
        System.debug('oppList::::'+oppList);
    }
}