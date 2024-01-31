trigger RollupTransactionIntoOpportunityTrigger on Transaction__c (after insert, after update, after delete) {

  /*  List<Opportunity> oppList = new List<Opportunity>();
    Map<Id, Decimal> oppIdAndTravelIncMap = new Map<Id, Decimal>();
    Map<Id, Decimal> oppIdAndTravelDecMap = new Map<Id, Decimal>();
    Map<Id, Decimal> oppIdAndODCsIncMap = new Map<Id, Decimal>();
    Map<Id, Decimal> oppIdAndODCsDecMap = new Map<Id, Decimal>();
    Map<Id, Decimal> oppIdAndMatBudgetIncMap = new Map<Id, Decimal>();
    Map<Id, Decimal> oppIdAndMatBudgetDecMap = new Map<Id, Decimal>();
    Map<Id, Decimal> oppIdAndHrsPaidIncMap = new Map<Id, Decimal>();
    Map<Id, Decimal> oppIdAndHrsPaidDecMap = new Map<Id, Decimal>();    
    Map<Id, Decimal> oppIdAndprofTestingIncMap = new Map<Id, Decimal>();
    Map<Id, Decimal> oppIdAndprofTestingDecMap = new Map<Id, Decimal>();
    Set<Id> oppIdSet = new Set<Id>();
    Set<String> paymentTypeSet = new Set<String>{'Payment', 'Refund', 'Authorization / PO', 'Transfer'};
    
    if(trigger.isInsert || trigger.isUpdate) {      
    
        for(Transaction__c trans: trigger.new) {      
            
            if(trigger.isInsert || (trigger.isUpdate 
                                    && (trans.Hours_Paid__c != trigger.oldMap.get(trans.Id).Hours_Paid__c
                                    || trans.Materials_Amount__c != trigger.oldMap.get(trans.Id).Materials_Amount__c
                                    || trans.Travel_Amount__c != trigger.oldMap.get(trans.Id).Travel_Amount__c
                                    || trans.ODCs_Amount__c != trigger.oldMap.get(trans.Id).ODCs_Amount__c
                                    || trans.Type__c != trigger.oldMap.get(trans.Id).Type__c
                                    || trans.Proficiency_Testing__c != trigger.oldMap.get(trans.Id).Proficiency_Testing__c))) {
            
                oppIdSet.add(trans.Opportunity__c);
                
                Decimal travelAmt = (trans.Travel_Amount__c != NULL) ? trans.Travel_Amount__c : 0;
                Decimal ODCsAmt = (trans.ODCs_Amount__c != NULL) ? trans.ODCs_Amount__c : 0;
                Decimal materialAmt = (trans.Materials_Amount__c != NULL) ? trans.Materials_Amount__c : 0;
                Decimal hrsPaid = (trans.Hours_Paid__c != NULL) ? trans.Hours_Paid__c : 0;
                Decimal profTesting = (trans.Proficiency_Testing__c != NULL) ? trans.Proficiency_Testing__c : 0;                
                
                if(trans.Type__c != 'Auth. / PO Payment' && trans.Type__c != NULL && paymentTypeSet.contains(trans.Type__c)) {
                    System.debug('::enter::');
                    if(!oppIdAndTravelIncMap.containsKey(trans.Opportunity__c)) {
                        oppIdAndTravelIncMap.put(trans.Opportunity__c, travelAmt); 
                    } else {
                        oppIdAndTravelIncMap.put(trans.Opportunity__c, travelAmt + oppIdAndTravelIncMap.get(trans.Opportunity__c));    
                    }
                    
                    if(!oppIdAndODCsIncMap.containsKey(trans.Opportunity__c)) {
                        oppIdAndODCsIncMap.put(trans.Opportunity__c, ODCsAmt); 
                    } else {
                        oppIdAndODCsIncMap.put(trans.Opportunity__c, ODCsAmt + oppIdAndODCsIncMap.get(trans.Opportunity__c));    
                    }
                    
                    if(!oppIdAndMatBudgetIncMap.containsKey(trans.Opportunity__c)) {
                        oppIdAndMatBudgetIncMap.put(trans.Opportunity__c, materialAmt); 
                    } else {
                        oppIdAndMatBudgetIncMap.put(trans.Opportunity__c, materialAmt + oppIdAndMatBudgetIncMap.get(trans.Opportunity__c));    
                    }
                    
                    if(!oppIdAndHrsPaidIncMap.containsKey(trans.Opportunity__c)) {
                        oppIdAndHrsPaidIncMap.put(trans.Opportunity__c, hrsPaid); 
                    } else {
                        oppIdAndHrsPaidIncMap.put(trans.Opportunity__c, hrsPaid + oppIdAndHrsPaidIncMap.get(trans.Opportunity__c));    
                    }
                    
                    if(!oppIdAndprofTestingIncMap.containsKey(trans.Opportunity__c)) {
                        oppIdAndprofTestingIncMap.put(trans.Opportunity__c, profTesting); 
                    } else {
                        oppIdAndprofTestingIncMap.put(trans.Opportunity__c, profTesting + oppIdAndprofTestingIncMap.get(trans.Opportunity__c));    
                    }
                    
                    System.debug('::::::::::::oppIdAndTravelIncMap::::::::::::'+oppIdAndTravelIncMap);
                    System.debug('::::::::::::oppIdAndODCsIncMap::::::::::::'+oppIdAndODCsIncMap);
                    System.debug('::::::::::::oppIdAndMatBudgetIncMap::::::::::::'+oppIdAndMatBudgetIncMap);
                    System.debug('::::::::::::oppIdAndHrsPaidIncMap::::::::::::'+oppIdAndHrsPaidIncMap);
                    System.debug('::::::::::::oppIdAndprofTestingIncMap::::::::::::'+oppIdAndprofTestingIncMap);
                }
                
                if(trigger.isUpdate && 
                    ((trigger.oldMap.get(trans.Id).Type__c != NULL && paymentTypeSet.contains(trigger.oldMap.get(trans.Id).Type__c)) &&
                     (trans.Type__c != NULL && trans.Type__c == 'Auth. / PO Payment' || paymentTypeSet.contains(trans.Type__c)))) {
                    
                    Decimal oldTravelAmt = (trigger.oldMap.get(trans.Id).Travel_Amount__c != NULL) ? trigger.oldMap.get(trans.Id).Travel_Amount__c : 0;
                    Decimal oldODCsAmt = (trigger.oldMap.get(trans.Id).ODCs_Amount__c != NULL) ? trigger.oldMap.get(trans.Id).ODCs_Amount__c : 0;
                    Decimal oldMaterialAmt = (trigger.oldMap.get(trans.Id).Materials_Amount__c != NULL) ? trigger.oldMap.get(trans.Id).Materials_Amount__c : 0;
                    Decimal oldHrsPaid = (trigger.oldMap.get(trans.Id).Hours_Paid__c != NULL) ? trigger.oldMap.get(trans.Id).Hours_Paid__c : 0;
                    Decimal oldProfTesting = (trigger.oldMap.get(trans.Id).Proficiency_Testing__c != NULL) ? trigger.oldMap.get(trans.Id).Proficiency_Testing__c : 0;
                    
                    if(!oppIdAndTravelDecMap.containsKey(trans.Opportunity__c)) {
                        oppIdAndTravelDecMap.put(trans.Opportunity__c, oldTravelAmt); 
                    } else {
                        oppIdAndTravelDecMap.put(trans.Opportunity__c, oldTravelAmt + oppIdAndTravelDecMap.get(trans.Opportunity__c));    
                    }
                    
                    if(!oppIdAndODCsDecMap.containsKey(trans.Opportunity__c)) {
                        oppIdAndODCsDecMap.put(trans.Opportunity__c, oldODCsAmt); 
                    } else {
                        oppIdAndODCsDecMap.put(trans.Opportunity__c, oldODCsAmt + oppIdAndODCsDecMap.get(trans.Opportunity__c));    
                    }
                    
                    if(!oppIdAndMatBudgetDecMap.containsKey(trans.Opportunity__c)) {
                        oppIdAndMatBudgetDecMap.put(trans.Opportunity__c, oldMaterialAmt); 
                    } else {
                        oppIdAndMatBudgetDecMap.put(trans.Opportunity__c, oldMaterialAmt + oppIdAndMatBudgetDecMap.get(trans.Opportunity__c));    
                    }
                    
                    if(!oppIdAndHrsPaidDecMap.containsKey(trans.Opportunity__c)) {
                        oppIdAndHrsPaidDecMap.put(trans.Opportunity__c, oldHrsPaid); 
                    } else {
                        oppIdAndHrsPaidDecMap.put(trans.Opportunity__c, oldHrsPaid + oppIdAndHrsPaidDecMap.get(trans.Opportunity__c));    
                    } 
                    
                    if(!oppIdAndprofTestingDecMap.containsKey(trans.Opportunity__c)) {
                        oppIdAndprofTestingDecMap.put(trans.Opportunity__c, oldProfTesting); 
                    } else {
                        oppIdAndprofTestingDecMap.put(trans.Opportunity__c, oldProfTesting + oppIdAndprofTestingDecMap.get(trans.Opportunity__c));    
                    }             
                    System.debug('::::::::::::oppIdAndTravelDecMap::::::::::::'+oppIdAndTravelDecMap);
                    System.debug('::::::::::::oppIdAndODCsDecMap::::::::::::'+oppIdAndODCsDecMap);
                    System.debug('::::::::::::oppIdAndMatBudgetDecMap::::::::::::'+oppIdAndMatBudgetDecMap);
                    System.debug('::::::::::::oppIdAndHrsPaidDecMap::::::::::::'+oppIdAndHrsPaidDecMap);
                    System.debug('::::::::::::oppIdAndprofTestingDecMap::::::::::::'+oppIdAndprofTestingDecMap);
                }
            }   
        }
    }
    
    if(trigger.isDelete) {
    
        for(Transaction__c trans: trigger.old) {
        
            if(trans.Type__c != 'Auth. / PO Payment' && trans.Type__c != null && paymentTypeSet.contains(trans.Type__c)) {
        
                oppIdSet.add(trans.Opportunity__c);
                
                Decimal deletedTravelAmt = (trans.Travel_Amount__c != NULL) ? trans.Travel_Amount__c : 0;
                Decimal deletedODCsAmt = (trans.Travel_Amount__c != NULL) ? trans.ODCs_Amount__c : 0;
                Decimal deletedMaterialAmt = (trans.Materials_Amount__c != NULL) ? trans.Materials_Amount__c : 0;
                Decimal deletedHrsPaid = (trans.Hours_Paid__c != NULL) ? trans.Hours_Paid__c : 0;
                Decimal deletedProfTesting = (trans.Proficiency_Testing__c != NULL) ? trans.Proficiency_Testing__c : 0;
            
                if(!oppIdAndTravelDecMap.containsKey(trans.Opportunity__c)) {
                    oppIdAndTravelDecMap.put(trans.Opportunity__c, deletedTravelAmt); 
                } else {
                    oppIdAndTravelDecMap.put(trans.Opportunity__c, deletedTravelAmt + oppIdAndTravelDecMap.get(trans.Opportunity__c));    
                }
                
                if(!oppIdAndODCsDecMap.containsKey(trans.Opportunity__c)) {
                    oppIdAndODCsDecMap.put(trans.Opportunity__c, deletedODCsAmt); 
                } else {
                    oppIdAndODCsDecMap.put(trans.Opportunity__c, deletedODCsAmt + oppIdAndODCsDecMap.get(trans.Opportunity__c));    
                }
                
                if(!oppIdAndMatBudgetDecMap.containsKey(trans.Opportunity__c)) {
                    oppIdAndMatBudgetDecMap.put(trans.Opportunity__c, deletedMaterialAmt); 
                } else {
                    oppIdAndMatBudgetDecMap.put(trans.Opportunity__c, deletedMaterialAmt + oppIdAndMatBudgetDecMap.get(trans.Opportunity__c));    
                }
                
                if(!oppIdAndHrsPaidDecMap.containsKey(trans.Opportunity__c)) {
                    oppIdAndHrsPaidDecMap.put(trans.Opportunity__c, deletedHrsPaid); 
                } else {
                    oppIdAndHrsPaidDecMap.put(trans.Opportunity__c, deletedHrsPaid + oppIdAndHrsPaidDecMap.get(trans.Opportunity__c));    
                }
                
                if(!oppIdAndprofTestingDecMap.containsKey(trans.Opportunity__c)) {
                    oppIdAndprofTestingDecMap.put(trans.Opportunity__c, deletedProfTesting); 
                } else {
                    oppIdAndprofTestingDecMap.put(trans.Opportunity__c, deletedProfTesting + oppIdAndprofTestingDecMap.get(trans.Opportunity__c));    
                } 
            }
        } 
        System.debug('::::::::::::oppIdAndTravelDecMap::::::::::::'+oppIdAndTravelDecMap);
        System.debug('::::::::::::oppIdAndODCsDecMap::::::::::::'+oppIdAndODCsDecMap);
        System.debug('::::::::::::oppIdAndMatBudgetDecMap::::::::::::'+oppIdAndMatBudgetDecMap);
        System.debug('::::::::::::oppIdAndHrsPaidDecMap::::::::::::'+oppIdAndHrsPaidDecMap); 
        System.debug('::::::::::::oppIdAndprofTestingDecMap::::::::::::'+oppIdAndprofTestingDecMap);    
    }   
     
    System.debug(':::::::::::oppIdSet::::::::::'+oppIdSet); 
    
    for(Opportunity opp: [SELECT Total_Hours_Paid_Auth__c, Materials_Budget__c,  Proficiency_Testing__c, Total_Travel__c, Total_ODCs__c FROM Opportunity WHERE Id IN: oppIdSet]) {    
       
        opp.Total_Hours_Paid_Auth__c = (opp.Total_Hours_Paid_Auth__c != NULL) ? opp.Total_Hours_Paid_Auth__c : 0;
        opp.Materials_Budget__c = (opp.Materials_Budget__c != NULL) ? opp.Materials_Budget__c : 0;
        opp.Total_Travel__c = (opp.Total_Travel__c != NULL) ? opp.Total_Travel__c : 0;
        opp.Total_ODCs__c = (opp.Total_ODCs__c != NULL) ? opp.Total_ODCs__c : 0;
        opp.Proficiency_Testing__c = (opp.Proficiency_Testing__c != NULL) ? opp.Proficiency_Testing__c : 0;
        
        opp.Total_Hours_Paid_Auth__c += (oppIdAndHrsPaidIncMap.containsKey(opp.Id)) ? oppIdAndHrsPaidIncMap.get(opp.Id) : 0;
        opp.Materials_Budget__c += (oppIdAndMatBudgetIncMap.containsKey(opp.Id)) ? oppIdAndMatBudgetIncMap.get(opp.Id) : 0; 
        opp.Total_Travel__c += (oppIdAndTravelIncMap.containsKey(opp.Id)) ? oppIdAndTravelIncMap.get(opp.Id) : 0;
        opp.Total_ODCs__c += (oppIdAndODCsIncMap.containsKey(opp.Id)) ? oppIdAndODCsIncMap.get(opp.Id) : 0; 
        opp.Proficiency_Testing__c += (oppIdAndprofTestingIncMap.containsKey(opp.Id)) ? oppIdAndprofTestingIncMap.get(opp.Id) : 0; 
        opp.Total_Hours_Paid_Auth__c -= (oppIdAndHrsPaidDecMap.containsKey(opp.Id)) ? oppIdAndHrsPaidDecMap.get(opp.Id) : 0; 
        opp.Materials_Budget__c -= (oppIdAndMatBudgetDecMap.containsKey(opp.Id)) ? oppIdAndMatBudgetDecMap.get(opp.Id) : 0; 
        opp.Total_Travel__c -= (oppIdAndTravelDecMap.containsKey(opp.Id)) ? oppIdAndTravelDecMap.get(opp.Id) : 0; 
        opp.Total_ODCs__c -= (oppIdAndODCsDecMap.containsKey(opp.Id)) ? oppIdAndODCsDecMap.get(opp.Id) : 0; 
        opp.Proficiency_Testing__c -= (oppIdAndprofTestingDecMap.containsKey(opp.Id)) ? oppIdAndprofTestingDecMap.get(opp.Id) : 0;
        oppList.add(opp);        
    }
    
    System.debug(':::::::::::oppList::::::::::'+oppList);
    
    try {        
        if(oppList.size() > 0) {
            update oppList;
        } 
    } catch(DMLException e) {
            
        for (Integer i = 0; i < e.getNumDml(); i++) {
           addError(e.getDmlMessage(i));               
        }
    }*/
}