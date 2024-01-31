trigger skillTrigger on Skill__c (before update) {
    
    if(trigger.isBefore && trigger.isUpdate){
    
        Map<String ,String> oldValueJson = new Map<String ,String>();
        
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get('Skill__c').getDescribe().fields.getMap();
        for(Skill__c skil : trigger.new){
            
            Skill__c  oldskil = trigger.oldMap.get(skil.id);
            if(oldskil.Status__c == null && skil.Status__c == 'Instructor Modified'){
                for(Schema.SObjectField fieldName : fieldMap.Values()){
                    schema.describefieldresult dfield = fieldName.getDescribe();
                    if(dfield.isUpdateable() && dfield.getName() != 'Status__c'){
                        if(oldskil.get(dfield.getName()) != skil.get(dfield.getName())){
                            oldValueJson.put(dfield.getName() ,String.valueOf(oldskil.get(dfield.getName())));
                        }
                    }
                }
                if(oldValueJson.size() != 0){
                    skil.Old_Value_Json__c = JSON.serialize(oldValueJson);
                }
            }
        }
    }
}