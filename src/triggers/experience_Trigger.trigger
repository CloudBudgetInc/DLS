trigger experience_Trigger on Experience__c (before update) {
    
    if(trigger.isBefore && trigger.isUpdate){
    
        Map<String ,String> oldValueJson = new Map<String ,String>();
        
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map <String, Schema.SObjectField> fieldMap = schemaMap.get('Experience__c').getDescribe().fields.getMap();
        for(Experience__c exp : trigger.new){
            
            Experience__c oldexp = trigger.oldMap.get(exp.id);
            if(oldexp.Status__c == null && exp.Status__c == 'Instructor Modified'){
                for(Schema.SObjectField fieldName : fieldMap.Values()){
                    schema.describefieldresult dfield = fieldName.getDescribe();
                    if(dfield.isUpdateable() && dfield.getName() != 'Status__c'){
                        if(oldexp.get(dfield.getName()) != exp.get(dfield.getName())){
                            oldValueJson.put(dfield.getName() ,String.valueOf(oldexp.get(dfield.getName())));
                        }
                    }
                }
                if(oldValueJson.size() != 0){
                    exp.Old_Value_Json__c = JSON.serialize(oldValueJson);
                }
            }
        }
    }
}