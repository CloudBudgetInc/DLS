// To populate the Material Stock information in Materials - To display the stock in hand values in Materials level.
// To restruct the user from creation MS duplicate record with same material & location combination
// Created by NS on July 16 2018
trigger MaterialStockTrigger on Materials_Stock__c (before insert,after insert) {
    
    Map<Id,Id> rosslynStock = new Map<Id,Id>();
    Map<Id,Id> elkridgeStock = new Map<Id,Id>();
    Map<Id,Id> herndonStock = new Map<Id,Id>();
    //Work Item: W-007197 - Create New Material Fields Related to Material Stock Records for "DLS - Online"
    Map<Id,Id> onlineStock = new Map<Id,Id>();
    
    Set<Id> materialsIds = new Set<Id>();
    List<Materials__c> materialsUpdate = new List<Materials__c>();
    Map<Id,Id> locIdMaterialId = new Map<Id,Id>();
    Map<String,Boolean> locMaterialIdFlag = new Map<String,Boolean>();
    
    if(trigger.isBefore && trigger.isInsert){
        for(Materials_Stock__c stock : Trigger.new){
            if(!locIdMaterialId.containsKey(stock.Location__c)) {
                locIdMaterialId.put(stock.Location__c,stock.Materials__c);
            }
        }
    }
    
    if(locIdMaterialId.size() > 0){
    
        for(Materials_Stock__c stock : [SELECT Id,Name,Materials__c,Location__c 
                                            FROM Materials_Stock__c 
                                            WHERE Location__c IN :locIdMaterialId.keySet() AND Materials__c IN :locIdMaterialId.values()]){
            
            String key = stock.Location__c+'-'+stock.Materials__c;
            if(!locMaterialIdFlag.containsKey(key)){
               locMaterialIdFlag.put(key,true); 
            }
        }
    }
    system.debug(':::::::locMaterialIdFlag::::'+locMaterialIdFlag);
    
    if(trigger.isBefore && trigger.isInsert){
        for(Materials_Stock__c stock : Trigger.new){
            if(locMaterialIdFlag.containsKey(stock.Location__c+'-'+stock.Materials__c)) {
                stock.addError('Same combination of Material Stock already exist. Please use that');
            }
        }
    }
    
    
    if(trigger.isAfter && trigger.isInsert){
        for(Materials_Stock__c stock : Trigger.new){
            if(stock.Materials__c != null)
                materialsIds.add(stock.Materials__c);
            
            if(stock.Location_Name__c.contains('DLS - Rosslyn') || stock.Location_Name__c.contains('DLS - Arlington')) {
                if(!rosslynStock.containsKey(stock.Materials__c)){
                    rosslynStock.put(stock.Materials__c,stock.Id);
                }
            }
            
            if(stock.Location_Name__c.contains('DLS - Elkridge')) {
                if(!elkridgeStock.containsKey(stock.Materials__c)){
                    elkridgeStock.put(stock.Materials__c,stock.Id);
                }
            }
            
            if(stock.Location_Name__c.contains('DLS - Herndon')) {
                if(!herndonStock.containsKey(stock.Materials__c)){
                    herndonStock.put(stock.Materials__c,stock.Id);
                }
            }
            if(stock.Location_Name__c.contains('DLS - Online')) {
                if(!onlineStock.containsKey(stock.Materials__c)){
                    onlineStock.put(stock.Materials__c,stock.Id);
                }
            }
        }
    }
    
    system.debug('::::::::rosslynStock:::::'+rosslynStock);
    system.debug('::::::::elkridgeStock:::::'+elkridgeStock);
    system.debug('::::::::herndonStock:::::'+herndonStock);
    system.debug('::::::::materialsIds:::::'+materialsIds.size());
    
    if(materialsIds.size() > 0) {
        for(Materials__c mat : [SELECT Id,Name,ARL_Materials_Stock__c,ELK_Materials_Stock__c,HRN_Materials_Stock__c,ONL_Materials_Stock__c FROM Materials__c WHERE Id IN :materialsIds]){
            
            if(rosslynStock.containsKey(mat.Id) && mat.ARL_Materials_Stock__c == null){
                mat.ARL_Materials_Stock__c = rosslynStock.get(mat.Id);
            }
            
            if(elkridgeStock.containsKey(mat.Id) && mat.ELK_Materials_Stock__c == null){
                mat.ELK_Materials_Stock__c = elkridgeStock.get(mat.Id);
            }
            
            if(herndonStock.containsKey(mat.Id) && mat.HRN_Materials_Stock__c == null){
                mat.HRN_Materials_Stock__c = herndonStock.get(mat.Id);
            }
            if(onlineStock.containsKey(mat.Id) && mat.ONL_Materials_Stock__c == null){
                mat.ONL_Materials_Stock__c = onlineStock.get(mat.Id);
            }
            
            materialsUpdate.add(mat);    
        }
        
        system.debug(':::::::::materialsUpdate::::'+materialsUpdate.size());
        
        if(materialsUpdate.size() > 0) {
            update materialsUpdate;
        }
    }
}