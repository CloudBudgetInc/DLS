trigger knownLanguage_Trigger on Known_Language__c (before update) {
    
    if(trigger.isBefore && trigger.isUpdate){
    
        Map<String ,String> oldValueJson = new Map<String ,String>();
        
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get('Known_Language__c').getDescribe().fields.getMap();
        for(Known_Language__c lang : trigger.new){
            Known_Language__c oldLang = trigger.oldMap.get(lang.id);
            if(oldLang.Status__c == null && lang.Status__c == 'Instructor Modified'){
                for(Schema.SObjectField fieldName : fieldMap.Values()){
                    schema.describefieldresult dfield = fieldName.getDescribe();
                    if(dfield.isUpdateable() && dfield.getName() != 'Status__c'){
                        if(oldLang.get(dfield.getName()) != lang.get(dfield.getName())){
                            oldValueJson.put(dfield.getName() ,String.valueOf(oldLang.get(dfield.getName())));
                        }
                    }
                }
                if(oldValueJson.size() != 0){
                    lang.Old_Value_Json__c = JSON.serialize(oldValueJson);
                }
            }
        }
    }
}