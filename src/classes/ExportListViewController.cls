public class ExportListViewController {
    
    public class OptionsValues{
        public String label;
        public String value;
    }
    
    public Class ExportInformation {
        @AuraEnabled public List<Contact> contactRecords;
        @AuraEnabled public String columnJson;
        @AuraEnabled public Map<String, String> fieldTypeMap;
    }
   
    @AuraEnabled
    public static String getListViewOptions() {
        
        List<OptionsValues> listOptions = new List<OptionsValues>();
        for(Export_List__mdt exportList : [SELECT Id,MasterLabel,DeveloperName,Object_Name__c FROM Export_List__mdt WHERE Object_Name__c = 'Contact' ORDER BY MasterLabel ASC]){
            OptionsValues option = new OptionsValues();
            option.label = exportList.MasterLabel;
            option.value = exportList.Id;
            
            listOptions.add(option);
        }
        
        return JSON.serialize(listOptions);
    }
    
    @AuraEnabled
    public static ExportInformation getListViewRecords(String queryId) {
        
        system.debug('::::::::queryId:::'+queryId);
        try{
            List<Contact> contactRecords = new List<Contact>();
            String columnNames = '';
            
            ExportInformation exportInfo = new ExportInformation();
            String contactQry = '';
            Map<String,String> fieldTypeMap = new Map<String, String>();
            
            if(String.isNotBlank(queryId)) {
                
                List<Export_List__mdt> queryRec = [SELECT Id, Condition__c, Field_Name__c, Object_Name__c FROM Export_List__mdt WHERE Id = :queryId];
                
                if(queryRec.size() > 0) {
                   columnNames = queryRec[0].Field_Name__c;
                   List<Object> fieldRecords = (List<Object>)JSON.deserializeUntyped(queryRec[0].Field_Name__c);
                   String fieldStr = '';
                   for(Object obj : fieldRecords) {
                       Map<String, Object> objMap = (Map<String, Object>)obj;
                       
                       if(fieldStr != '')
                           fieldStr += ',';
                       if(objMap.get('value') != null && objMap.get('value') != '') {
                           fieldStr += String.valueOf(objMap.get('value'));
                           fieldTypeMap.put(String.valueOf(objMap.get('value')), String.valueOf(objMap.get('dataType')));
                       }
                   }
                   contactQry = 'SELECT '+fieldStr+' FROM '+queryRec[0].Object_Name__c;
                   if(queryRec[0].Condition__c != null && queryRec[0].Condition__c != '') {
                       contactQry += ' WHERE '+queryRec[0].Condition__c;
                   }
                }
                
                exportInfo.contactRecords = database.query(contactQry);
                exportInfo.columnJson = columnNames;
                exportInfo.fieldTypeMap = fieldTypeMap;
                
                system.debug('::::::::::exportInfo:::'+exportInfo);
                
                return exportInfo;
            }
            
            return null;
            
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());    
        }
        
    }
}