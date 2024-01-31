global class RemoteActionTkController {
    global static String makeError(String message, String errorCode) {
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('message', message);
        gen.writeStringField('errorCode', errorCode);
        gen.writeEndObject();
        gen.writeEndArray();
        
        return gen.getAsString();
    }
    
    global static String writeFields(String objtype, SObject obj, String fields) {
        Map<String, Object> fieldMap = null;
        try {
            fieldMap = (Map<String, Object>)JSON.deserializeUntyped(fields);
        } catch (JSONException je) {
            return makeError(je.getMessage(), 'JSON_PARSER_ERROR');
        }
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        
        Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
        try {
            for (String key : fieldMap.keySet()) {
                if (targetFields.get(key) == null) {
                    return '[{"message":"Field '+key+' does not exist on object type '+objtype+'","errorCode":"INVALID_FIELD"}]';
                }
                
                Object value = fieldMap.get(key);
                Schema.DisplayType valueType = targetFields.get(key).getDescribe().getType();
                
                if (value instanceof String && valueType != Schema.DisplayType.String) {
                    // Coerce an incoming String to the correct type
                    String svalue = (String)value;
                    
                    if (valueType == Schema.DisplayType.Date) {
                        obj.put(key, Date.valueOf(svalue));
                    } else if (valueType == Schema.DisplayType.Percent ||
                           valueType == Schema.DisplayType.Currency) {
                        obj.put(key, svalue == '' ? null : Decimal.valueOf(svalue));
                    } else if (valueType == Schema.DisplayType.Double) {
                        obj.put(key, svalue == '' ? null : Double.valueOf(svalue));
                    } else if (valueType == Schema.DisplayType.Integer) {
                        obj.put(key, Integer.valueOf(svalue));
                    } else {
                        obj.put(key, svalue);
                    }
                } else {
                    // Just try putting the incoming value on the object
                    obj.put(key, value);
                }
            }
        } catch (SObjectException soe) {
            return makeError(soe.getMessage(), 'INVALID_FIELD');
        }
        
        return null;
    }
    
    global static List<Object> picklistOptions(Schema.DescribeFieldResult field) {
        List<Object> picklistOptions = new List<Object>();
        Schema.DisplayType fieldType = field.getType();
        if (fieldType != Schema.DisplayType.Picklist &&
          fieldType != Schema.DisplayType.MultiPicklist &&
          fieldType != Schema.DisplayType.Combobox) {
            return picklistOptions;
        }
        List<Schema.PicklistEntry> picklistValues = field.getPicklistValues();
        for (Schema.PicklistEntry picklistValue: picklistValues) {
            Map<String, Object> picklistOption = new Map<String, Object>();
            picklistOption.put('value', picklistValue.getValue());
            picklistOption.put('label', picklistValue.getValue());
            picklistOption.put('active', picklistValue.isActive());
            picklistOption.put('defaultValue', picklistValue.isDefaultValue());
            picklistOptions.add(picklistOption);
        }
        return picklistOptions;
    }

    @remoteAction
    global static String describe(String objtype) {
        // Just enough to make the sample app work!
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        if (targetType == null) {
            return makeError('The requested resource does not exist', 'NOT_FOUND');
        }
        
        Schema.DescribeSObjectResult sobjResult = targetType.getDescribe();
        
        Map<String, Schema.SObjectField> fieldMap = sobjResult.fields.getMap();
        
        List<Object> fields = new List<Object>();
        for (String key : fieldMap.keySet()) {
            Schema.DescribeFieldResult descField = fieldMap.get(key).getDescribe();
            Map<String, Object> field = new Map<String, Object>();
            
            field.put('type', descField.getType().name().toLowerCase());
            field.put('name', descField.getName());
            field.put('label', descField.getLabel());
            List<String> references = new List<String>();
            for (Schema.sObjectType t: descField.getReferenceTo()) {
                references.add(t.getDescribe().getName());
            }
            if (!references.isEmpty()) {
                field.put('referenceTo', references);
            }
            field.put('picklistValues', picklistOptions(descField));

            fields.add(field);
        }
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('fields', fields);
        
        return JSON.serialize(result);
    }
    
    @remoteAction
    global static String create(String objtype, String fields) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        if (targetType == null) {
            return makeError('The requested resource does not exist', 'NOT_FOUND');
        }
        
        SObject obj = targetType.newSObject();

        String error = writeFields(objType, obj, fields);
        if (error != null) {
            return error;
        }

        try {
            insert obj;
        } catch (DMLException dmle) {
            String fieldNames = '';
            for (String field : dmle.getDmlFieldNames(0)) {
                if (fieldNames.length() > 0) {
                    fieldNames += ',';
                }
                fieldNames += '"'+field+'"';
            }
            return '[{"fields":['+fieldNames+'],"message":"'+dmle.getDmlMessage(0)+'","errorCode":"'+dmle.getDmlType(0).name()+'"}]';
        }
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('id', obj.id);
        result.put('errors', new List<String>());
        result.put('success', true);
        
        return JSON.serialize(result);
    }
    
    @remoteAction
    global static String retrieve(String objtype, String id, String fieldlist) {
        // TODO - handle null fieldlist - retrieve all fields
        Boolean containsId = false;
        for (String field : fieldlist.split(',')) {
            if (field.equalsIgnoreCase('id')){
                containsId = true;
                break;
            }
        }
        
        if (!containsId) {
            fieldlist = 'Id,'+fieldlist;
        }
        
        String soql = 'SELECT '+fieldlist+' FROM '+objtype+' WHERE Id = \''+id+'\'';
        List<sObject> records;
        try {
            records = Database.query(soql);
        } catch (QueryException qe) {
            return makeError(qe.getMessage(), 'INVALID_QUERY');
        }
        
        return JSON.serialize(records[0]);
    }
    
    @remoteAction
    global static String upser(String objtype, String externalIdField, String externalId, String fields) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        if (targetType == null) {
            return makeError('The requested resource does not exist', 'NOT_FOUND');
        }
        SObject obj = targetType.newSObject();
        obj.put(externalIdField, externalId);
        
        String error = writeFields(objType, obj, fields);
        if (error != null) {
            return error;
        }
        
        Schema.SObjectField sobjField = targetType.getDescribe().fields.getMap().get(externalIdField);
        
        Database.Upsert(obj, sobjField);
        
        return '';
    }

    @remoteAction
    global static String updat(String objtype, String id, String fields) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        if (targetType == null) {
            return makeError('The requested resource does not exist', 'NOT_FOUND');
        }
        
        SObject obj = targetType.newSObject(id);
        
        String error = writeFields(objType, obj, fields);
        if (error != null) {
            return error;
        }

        try {
            update obj;
        } catch (DMLException dmle) {
            String fieldNames = '';
            for (String field : dmle.getDmlFieldNames(0)) {
                if (fieldNames.length() > 0) {
                    fieldNames += ',';
                }
                fieldNames += '"'+field+'"';
            }
            return '[{"fields":['+fieldNames+'],"message":"'+dmle.getDmlMessage(0)+'","errorCode":"'+dmle.getDmlType(0).name()+'"}]';
        }
        
        return null;
    }

    @remoteAction
    global static String del(String objtype, String id) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objtype);
        if (targetType == null) {
            return makeError('The requested resource does not exist', 'NOT_FOUND');
        }
        
        SObject obj = targetType.newSObject(id);
        
        try {
            delete obj;
        } catch (DMLException dmle) {
            String fieldNames = '';
            for (String field : dmle.getDmlFieldNames(0)) {
                if (fieldNames.length() > 0) {
                    fieldNames += ',';
                }
                fieldNames += '"'+field+'"';
            }
            return '[{"fields":['+fieldNames+'],"message":"'+dmle.getDmlMessage(0)+'","errorCode":"'+dmle.getDmlType(0).name()+'"}]';
        }
        
        return null;
    }

    @remoteAction
    global static String query(String soql) {
        List<sObject> records;
        try {
            records = Database.query(soql);
        } catch (QueryException qe) {
            return makeError(qe.getMessage(), 'INVALID_QUERY');
        }
        
        Map<String, Object> result = new Map<String, Object>();
        result.put('records', records);
        result.put('totalSize', records.size());
        result.put('done', true);
        return JSON.serialize(result);
    }

    @remoteAction
    global static String search(String sosl) {
        List<List<SObject>> result;        
        try {
            result = Search.query(sosl);
        } catch (QueryException qe) {
            return makeError(qe.getMessage(), 'INVALID_SEARCH');
        } catch (SearchException se) {
            return makeError(se.getMessage(), 'INVALID_SEARCH');
        }
        
        return JSON.serialize(result);
    }
    
    @remoteAction
    global static String getPicklistValues(String objName,String fieldName) {
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objName);
        if (targetType == null) {
            return makeError('The requested resource does not exist', 'NOT_FOUND');
        } else {
            Schema.SObjectField targetFieldType = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName); 
            if(targetFieldType  == null) {
                return makeError('The requested field does not exist', 'NOT_FOUND');    
            }  
        }
        
        List<String> picklistOptions = new List<String>();
        Schema.DescribeFieldResult descRes = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName).getDescribe();        
        List<Schema.PicklistEntry> ple = descRes.getPicklistValues();
        for(Schema.PicklistEntry picklist: ple ) { 
             
            picklistOptions.add(picklist.getValue());  
        } 
        return JSON.serialize(picklistOptions);
          
    }
}