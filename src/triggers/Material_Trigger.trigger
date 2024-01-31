/*
* Developed by Karthiga on April 05, 2017 To make the Material Title unique
*/
trigger Material_Trigger on Materials__c (before insert, before update) {
    
    
    Set<String> matNameSet = new Set<String>();
    Set<String> newNames = new Set<String>();
    
    if( trigger.isBefore ) {
        for(Materials__c m : trigger.new) {
            newNames.add(m.Name);
        }  
        
        for (Materials__c m : MaterialsService.getMaterialsbyName('',newNames)) {
            matNameSet.add(m.Name);
        }
        System.debug('matNameSet::::'+matNameSet);
        for(Materials__c m : trigger.new) {
            if(trigger.isInsert || (trigger.isUpdate && trigger.oldMap.get(m.Id).Name != m.Name)) {
                if(matNameSet != null && matNameSet.contains(m.Name)) {
                    m.Name.addError('Material Title should be unique');
                }
            }
        } 
    }
}