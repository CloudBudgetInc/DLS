public class MaterialsHandler {

    public static String appendZeroleft(Integer finalCount,Integer digitCnt) { 
        String sizeList;
        String zerosFormat;
        
        for(Integer k = 0;k < digitCnt;k++){
            if(zerosFormat != null){
                zerosFormat += '0';
            }else {
                zerosFormat = '0';
            }
        }
        system.debug(':::::::zerosFormat::;;'+zerosFormat);
        
        Integer n = finalCount,i;
        for(i = 0;n != 0;i++){
           n = n/10;
        }
        system.debug(':::i:::'+i);
        
        if(i < digitCnt)
            sizeList = zerosFormat.right(digitCnt - i) + String.ValueOf(finalCount);
        else
            sizeList = String.ValueOf(finalCount);
        
        system.debug(':::::sizeList:::'+sizeList);
        return sizeList;
    }  
    
    /**********************************************************
     - Method to Create Materials Stock, Inventory Purchase & Inventory Purhcase Item records
     - When Order Materials Request record status changed to Delivered only for DLS Library Projects (Facilities Projects)
     - Added by NS on Sep 5 2018
    ***********************************************************/
    public static Map<String,Id> createMissingStockRecords(List<Materials_Request__c> materialRequests) {
        system.debug(':::::::::materialRequests::::'+materialRequests);
        List<Materials_Stock__c> stockRecords = new List<Materials_Stock__c>();
        
        Map<Id,Id> locIdMatIdMap = new Map<Id,Id>();
        Map<String,Id> existingStockMap = new Map<String,Id>();
        Map<String,Materials_Request__c> matLocMRMap = new Map<String,Materials_Request__c>();
        
        
        Map<String,Inventory_Purchase__c> locMaterialInventoryMap = new Map<String,Inventory_Purchase__c>();
        Map<String,Inventory_Purchase_Item__c> locMaterialInvenItemMap = new Map<String,Inventory_Purchase_Item__c>();
        List<Inventory_Purchase_Item__c> purchaseItems = new List<Inventory_Purchase_Item__c>();
                
        for(Materials_Request__c mr : materialRequests){
                locIdMatIdMap.put(mr.Location__c,mr.Materials_Name__c);
                
                String key = mr.Location__c+'-'+mr.Materials_Name__c;
                if(!matLocMRMap.containsKey(key)) {
                    matLocMRMap.put(key,mr);
                }
        }
        
        //system.debug(':::::::::matLocMRMap:::::'+matLocMRMap);
        //system.debug(':::::::::locIdMatIdMap:::::'+locIdMatIdMap);
        
        for(Materials_Stock__c ms : [SELECT Id,Name,Materials__c,Location__c FROM Materials_Stock__c 
                                            WHERE Location__c IN :locIdMatIdMap.keySet() AND Materials__c IN :locIdMatIdMap.values()]){
            
            existingStockMap.put(ms.Location__c+'-'+ms.Materials__c,ms.Id);
        }
        
        system.debug('::::::::existingStockMap::::'+existingStockMap);
        
        // Create Materials Stock records
        if(existingStockMap.size() > 0) {
        
            for(Id locId : locIdMatIdMap.keySet()){
                String key = locId+'-'+locIdMatIdMap.get(locId);
                if(!existingStockMap.containsKey(key)) {
                    
                    Materials_Stock__c stock = new Materials_Stock__c();
                    stock.Materials__c = locIdMatIdMap.get(locId);
                    stock.Location__c = locId;
                    
                    stockRecords.add(stock);
                }
            }
        }else {
            for(Id locId : locIdMatIdMap.keySet()){
                Materials_Stock__c stock = new Materials_Stock__c();
                stock.Materials__c = locIdMatIdMap.get(locId);
                stock.Location__c = locId;
                
                stockRecords.add(stock);
            }
        }
        
        if(stockRecords.size() > 0) {
            insert stockRecords;
            
            for(Materials_Stock__c ms : stockRecords){
                String key = ms.Location__c+'-'+ms.Materials__c;
                if(!existingStockMap.containsKey(key)){
                    existingStockMap.put(key,ms.Id);
                }
            }
        }
        
        // Create Inventory Purchase & Inventory Purchase Item records for each material request
        // Not checking for existing records
        // Based on the Request Type we will update the Inventory Purchase Item Type value
        // Inventory Purchase Item type field will determine the field (Pruchased Qty Library / Order) for Stock level qty reflection
        for(String keyVal : matLocMRMap.keySet()){
        
            String locId = keyVal.split('-')[0];
            String materialId = keyVal.split('-')[1];
            
            //Inventory records
            Inventory_Purchase__c inventory = new Inventory_Purchase__c();
            inventory.Location__c = locId;
            inventory.Date__c = system.today();
            inventory.Vendor__c = matLocMRMap.get(keyVal).Vendor_Name__c;
            
            locMaterialInventoryMap.put(keyVal,inventory);
            
            //Inventory Item records
            Inventory_Purchase_Item__c item = new Inventory_Purchase_Item__c();
            item.Materials__c = materialId;
            item.Price__c = matLocMRMap.get(keyVal).Item_Price_Formula__c;
            item.Quantity__c = matLocMRMap.get(keyVal).Qty__c;
            item.Type__c = matLocMRMap.get(keyVal).Request_type__c;
            
            locMaterialInvenItemMap.put(keyVal,item);
        }
        
        if(locMaterialInventoryMap.values().size() > 0){
            insert locMaterialInventoryMap.values();
            
            for(string key : locMaterialInvenItemMap.keySet()){
                Inventory_Purchase_Item__c item = locMaterialInvenItemMap.get(key);
                item.Inventory_Purchase__c = locMaterialInventoryMap.get(key).Id;
                
                purchaseItems.add(item);
            }
            
            if(purchaseItems.size() > 0){
                insert purchaseItems;
            }
        }
        
        return existingStockMap;
        
    }    
}