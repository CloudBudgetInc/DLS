public with sharing class CommonUtil {

    @AuraEnabled
    public static String getPickListValues(String objName, List<String> fieldAPINames) {
    
        Map<String, List<UtilDomain.FilterDetails>> fieldAPINameWithPickListValues = new Map<String, List<UtilDomain.FilterDetails>>();
        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        UtilDomain.FilterDetails picklistvalue;

        for(String fieldAPIName : fieldAPINames){
            Schema.DescribeFieldResult picklistFieldDescribe = fieldMap.get(fieldAPIName).getDescribe();
            fieldAPINameWithPickListValues.put(fieldAPIName, new List<UtilDomain.FilterDetails>());
            for(Schema.PicklistEntry pickListVal : picklistFieldDescribe.getPicklistValues()){
                picklistvalue = new UtilDomain.FilterDetails();

                if(pickListVal.isActive()){
                    picklistvalue.label = pickListVal.getValue();
                    picklistvalue.value =  pickListVal.getLabel();

                    fieldAPINameWithPickListValues.get(fieldAPIName).add(picklistvalue);
                }
            }
        }
        
        return JSON.serialize(fieldAPINameWithPickListValues);
    }
    
    @AuraEnabled
    public static String getAllPickListValuesByObject(String objName) {
    
        Map<String, List<UtilDomain.FilterDetails>> fieldAPINameWithPickListValues = new Map<String, List<UtilDomain.FilterDetails>>();
        Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        UtilDomain.FilterDetails picklistvalue;

        for(Schema.SObjectField field : fieldMap.values()){
            
            String fieldAPIName = field.getDescribe().getName();
            System.debug('fieldAPIName::>'+fieldAPIName);
            Schema.DescribeFieldResult picklistFieldDescribe = fieldMap.get(fieldAPIName).getDescribe();
            
            if(picklistFieldDescribe.getType() == Schema.DisplayType.Picklist){
                fieldAPINameWithPickListValues.put(fieldAPIName, new List<UtilDomain.FilterDetails>());
                
                for(Schema.PicklistEntry pickListVal : picklistFieldDescribe.getPicklistValues()){
                    picklistvalue = new UtilDomain.FilterDetails();
                    
                    if(pickListVal.isActive()){
                        picklistvalue.label = pickListVal.getValue();
                        picklistvalue.value =  pickListVal.getLabel();

                        fieldAPINameWithPickListValues.get(fieldAPIName).add(picklistvalue);
                    }
                }
            }
        }
        
        return JSON.serialize(fieldAPINameWithPickListValues);
    }

    @AuraEnabled
    public static string getAllPicklistValuesByObjectAndRecordTypeId(String objectName, String recordTypeId){
        
        try {
            
            System.debug(recordTypeId);
            Map<String, List<UtilDomain.FilterDetails>> fieldAPINameWithPickListValues = new Map<String, List<UtilDomain.FilterDetails>>();
            UtilDomain.FilterDetails picklistvalue;
            
            String sessionId = UserInfo.getSessionId();
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            String host = System.Url.getSalesforceBaseURL().toExternalForm();
            String url = host+'/services/data/v42.0/ui-api/object-info/'+objectName+'/picklist-values/'+recordTypeId;        
            request.setEndpoint(url);
            request.setMethod('GET');  
            request.setHeader('Authorization', 'OAuth '+sessionId);
            HttpResponse response;        
            response = http.send(request); 
            Map<String, Object> metadata = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            Map<String, Object> meta = (Map<String, Object>) metadata.get('picklistFieldValues');
            for(String api : meta.keySet()) {
                Map<String, Object> obj = (Map<String, Object>) meta.get(api);
                System.debug(api);
                if(obj.containsKey('values')) {
                    fieldAPINameWithPickListValues.put(api, new List<UtilDomain.FilterDetails>());
                    for(Object o: (List<Object>)obj.get('values')) { 
                        picklistvalue = new UtilDomain.FilterDetails();                       
                        Map<String,Object> temp = (Map<String,Object>) o;
                        picklistvalue.label = (String) temp.get('label');
                        picklistvalue.value = (String) temp.get('value');
                        
                        fieldAPINameWithPickListValues.get(api).add(picklistvalue);
                    }
                }
            }
            
            return JSON.serialize(fieldAPINameWithPickListValues);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    
    public static Set < Id > fetchUserIdsOfPublicGroup( String groupName ) {
    
        Set < Id > userIds = new Set < Id >();
         
        for ( GroupMember objGM : [ SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName = :groupName AND Group.Type = 'Regular' ] ) {
            
            String strUserOrGroupId = objGM.UserOrGroupId;
            
            if ( strUserOrGroupId.startsWith( '005' ) )
                userIds.add( objGM.UserOrGroupId );            
        }
        
        return userIds;
    
    }
}