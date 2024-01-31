trigger InventoryPurchaseItemTrigger on Inventory_Purchase_Item__c ( before insert, before update ) {
    
    Set<Id> ipIdSet = new Set<Id>();
    Set<Id> materialIdSet = new Set<Id>();
    Map<Id,Id> ipAndLoactionMap = new Map<Id,Id>();
    Map<String,Id> ipAndstockMap = new Map<String,Id>();
     
    //Added By Sangeetha G on June 12 2018 for Material Stock value population
    for( Inventory_Purchase_Item__c ipi : Trigger.new ) {
        
        materialIdSet.add( ipi.Materials__c );
        ipIdSet.add( ipi.Inventory_Purchase__c);
        
    }
    
    for( Inventory_Purchase__c ip : [ SELECT Id,Location__c FROM Inventory_Purchase__c WHERE Id IN :ipIdSet ]) {
        
        ipAndLoactionMap.put( ip.Id,ip.Location__c );
        
    }
    
    for( Materials_Stock__c stock : [ SELECT Id, Location__c, Materials__c FROM Materials_Stock__c
                                            WHERE Location__c IN : ipAndLoactionMap.values() AND Materials__c IN :materialIdSet]) {
    
        ipAndstockMap.put( stock.Location__c + '-' + stock.Materials__c, stock.Id );                                      
    
    }
    
    for( Inventory_Purchase_Item__c ipi : Trigger.new ) {
    
        if( ipi.Inventory_Purchase__c != null && ipAndLoactionMap!= null && ipAndLoactionMap.containsKey( ipi.Inventory_Purchase__c ) ) {
       
            if( ipAndstockMap!= null && ipAndstockMap.containsKey( ipAndLoactionMap.get( ipi.Inventory_Purchase__c ) + '-' + ipi.Materials__c) ){
                    
                ipi.Materials_Stock__c = ipAndstockMap.get( ipAndLoactionMap.get(ipi.Inventory_Purchase__c) + '-' + ipi.Materials__c);
            } else {
            
                ipi.Materials_Stock__c = null;
            }
        }
    }
}