trigger EquipmentTrigger on Equipment__c (before insert, before update, after update) {

    if(Trigger.isAfter){
    
        if(Trigger.isUpdate){
            
            Map<Id, Date> equipIdAndDisposedDate = new Map<Id, Date>();
            Map<Id,Equipment__c> equipMap = new Map<Id,Equipment__c>();
            List<AcctSeed__Fixed_Asset__c> fasToUpdate = new List<AcctSeed__Fixed_Asset__c>();
            for(Equipment__c e : Trigger.new){
            
                if(String.isNotBlank(e.Stage__c) && e.Stage__c == 'Disposed' && e.Stage__c != Trigger.oldMap.get(e.Id).Stage__c){
                    equipIdAndDisposedDate.put(e.Id, e.Date_Disposed__c);        
                }
                
                if(e.Stage__c != trigger.oldMap.get(e.Id).Stage__c || e.Date_Disposed__c != trigger.oldMap.get(e.Id).Date_Disposed__c || 
                    e.Date_Placed_in_Service__c != trigger.oldMap.get(e.Id).Date_Placed_in_Service__c || e.Date_Purchased_New__c != trigger.oldMap.get(e.Id).Date_Purchased_New__c ||
                        e.Assigned_Location__c != trigger.oldMap.get(e.Id).Assigned_Location__c) {
                    equipMap.put(e.Id,e);
                }
            }
            System.debug('equipIdAndDisposedDate==========='+equipIdAndDisposedDate+'equipIdAndDisposedDate SIZE======'+equipIdAndDisposedDate.size());
            
            if(equipIdAndDisposedDate.size() > 0){
            
                List<Equipment_Assignment__c> equipAssigns = [SELECT Id, Date_Returned__c, Stage__c, Equipment__c FROM Equipment_Assignment__c WHERE Equipment__c IN :equipIdAndDisposedDate.keySet() AND Stage__c = 'Active'];
                
                if(equipAssigns.size () > 0 ){
                    
                    List<Equipment_Assignment__c> toUpdateEquipAssigns = new List<Equipment_Assignment__c>();
                    
                    for(Equipment_Assignment__c ea : equipAssigns){
                    
                        ea.Date_Returned__c = equipIdAndDisposedDate.get(ea.Equipment__c);
                        ea.Stage__c = 'Ended';
                        toUpdateEquipAssigns.add(ea);
                    }
                    System.debug('toUpdateEquipAssigns======'+toUpdateEquipAssigns+'toUpdateEquipAssigns SIZE===='+toUpdateEquipAssigns.size());
                    
                    if(toUpdateEquipAssigns.size() > 0){
                        update toUpdateEquipAssigns;
                    }
                }
            }
            
            // W-002705 - on 19/09/2019 to update the FA when the value changes in Equipment
            if(equipMap.size() > 0) {
                for(AcctSeed__Fixed_Asset__c fa : FixedAssetService.getFixedAssets(equipMap.keyset(),' WHERE Equipment__c','')) {
                    Boolean isChanged = false;
                    if(equipMap.containskey(fa.Equipment__c)) {
                        Equipment__c equ = equipMap.get(fa.Equipment__c);
                        if(fa.Date_Disposed__c != equ.Date_Disposed__c) {
                            fa.Date_Disposed__c = equ.Date_Disposed__c;
                            isChanged = true;
                        }
                        if(fa.Date_Placed_in_Service__c != equ.Date_Placed_in_Service__c) {
                            fa.Date_Placed_in_Service__c = equ.Date_Placed_in_Service__c;
                            isChanged = true;
                        }
                        if(fa.Date_Purchased__c != equ.Date_Purchased_New__c) {
                            fa.Date_Purchased__c = equ.Date_Purchased_New__c;
                            isChanged = true;
                        }
                        if(fa.Location__c != equ.Assigned_Location__c) {
                            fa.Location__c = equ.Assigned_Location__c;
                            isChanged = true;
                        }
                        if(fa.Stage__c != equ.Stage__c) {
                            fa.Stage__c = equ.Stage__c;
                            isChanged = true;
                        }
                        if(isChanged == true) {
                            fasToUpdate.add(fa);
                        }
                    }
                }
                System.debug('fasToUpdate::::::'+fasToUpdate);
                if(fasToUpdate.size() > 0) {
                    update fasToUpdate;
                }
            }
        }
    }
    
    /****************
        - Added by HL on Sep 24 2019
        - Work Item : W-002719 - Require Equipment.Name field to be unique
        - To show the error message when create / update the equipment records which having the same name that already exist
    *************/
    if(Trigger.isBefore){
    
        if(Trigger.isInsert || Trigger.isUpdate){
            
            Set<String> newEquipAssetNames = new Set<String>();
            Set<String> oldEquipAssetNames = new Set<String>();
            Set<Id> oldEquipIds = new Set<Id>();
            
            for(Equipment__c e : Trigger.new){
            
                if(String.isNotBlank(e.Name)){
                    
                    newEquipAssetNames.add(e.Name.toLowerCase());
                    
                    if(Trigger.isUpdate){
                        oldEquipIds.add(e.Id);    
                    }
                }
            } 
            System.debug('::::newEquipAssetNames::::::'+newEquipAssetNames);   
            System.debug('::::newEquipAssetNames SIZE::::::'+newEquipAssetNames.size()); 
            
            if(newEquipAssetNames.size() > 0){
                            
                for(Equipment__c e : [SELECT Id, Name FROM Equipment__c WHERE Name IN :newEquipAssetNames AND Id NOT IN : oldEquipIds]){
                    oldEquipAssetNames.add(e.Name.toLowerCase());
                }
                System.debug('::::oldEquipAssetNames::::::'+oldEquipAssetNames);
                
                if(oldEquipAssetNames != NULL && oldEquipAssetNames.size() > 0){
                
                    for(Equipment__c e : Trigger.new){
                    
                        if(String.isNotBlank(e.Name) && oldEquipAssetNames.contains(e.Name.toLowerCase())){
                            e.Name.addError('Equipment Asset Name should be unique');
                        }    
                    }    
                }
            }
        }
    }
}