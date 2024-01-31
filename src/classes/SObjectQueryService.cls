/**********************************************************************
    Created by Karthiga on Jan 10, 2017: Service class used for Sobject
***********************************************************************/
public class SObjectQueryService {
    
    /**********************************************************************
        Created by Karthiga on Jan 10 2017: This method return list of SObjects
        @ObjectName - API Name of any object
        @idValues - Id of the records   
        @parentFields - commaSeperated Parent Fields (Note always pass the string with comma Start eg: ,Account.Name,Account.Phone)     
        return - list of SObject
     ***********************************************************************/
    public static List<SObject> SObjectQuery(String ObjectName, set<Id> idValues, String parentFields) {
        
        LisT<sObject> lstOfSelectedObjectRecords = new LisT<sObject>();
        system.debug('valuess'+idValues);
        try{
            String queryval;
            String SobjectApiName = ObjectName;
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
            String commaSepratedFields = '';
            for(String fieldName : fieldMap.keyset()){
                if (String.valueOf(fieldMap.get(fieldName).getDescribe().getType()) != 'base64' && String.valueOf(fieldMap.get(fieldName).getDescribe().getType()) != 'ADDRESS' && String.valueOf(fieldMap.get(fieldName).getDescribe().getType()) != 'LOCATION') {
                    if(commaSepratedFields == null || commaSepratedFields == ''){
                        commaSepratedFields = fieldName;
                    }else{
                        commaSepratedFields = commaSepratedFields + ', ' + fieldName;
                    }
                }
            }
            queryval = 'select ' + commaSepratedFields + parentFields + ' from ' + SobjectApiName+' WHERE ID IN :idValues';
            System.debug('queryval :::'+queryval );
            lstOfSelectedObjectRecords = Database.query(queryval);
        }
        catch(exception e){
            system.debug('&&&&'+e.getMessage());
        }
        return lstOfSelectedObjectRecords;
    }
    
    /**********************************************************************
        Created by Karthiga on Jan 10 2017: This method return comma separated field name as a String
        @ObjectName - API Name of any object
        return - string (all the fields as comma separated)
     ***********************************************************************/
    public static String getSObjectFieldsBySObjectName(String ObjectName){
        //System.debug('ObjectName:::'+ObjectName);
        String commaSepratedFields = '';
        try{
            String queryval;
            String SobjectApiName = ObjectName;            
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();          
            //System.debug('schemaMap:::'+schemaMap);
            //System.debug('fieldMap:::'+fieldMap);
            for(String fieldName : fieldMap.keyset()){
                if (String.valueOf(fieldMap.get(fieldName).getDescribe().getType()) != 'base64' && String.valueOf(fieldMap.get(fieldName).getDescribe().getType()) != 'ADDRESS' && String.valueOf(fieldMap.get(fieldName).getDescribe().getType()) != 'LOCATION') {
                    if(commaSepratedFields == null || commaSepratedFields == ''){
                        commaSepratedFields = fieldName;
                    }else{
                        commaSepratedFields = commaSepratedFields + ', ' + fieldName;
                    }
                }
            }
        }
        catch(exception e){
            system.debug('SObjectQueryService::::fieldsByObjName'+e.getMessage());
        }
        return commaSepratedFields;
    } 
    
    public static String getSObjectFieldsBySObjectNameExceptBlob(String ObjectName){
        
        String commaSepratedFields = '';
        try{
            String queryval;
            String SobjectApiName = ObjectName;
            Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();          
            for(String fieldName : fieldMap.keyset()){
                if (String.valueOf(fieldMap.get(fieldName).getDescribe().getType()) != 'base64' && String.valueOf(fieldMap.get(fieldName).getDescribe().getType()) != 'ADDRESS' && String.valueOf(fieldMap.get(fieldName).getDescribe().getType()) != 'LOCATION') {
                    if(commaSepratedFields == null || commaSepratedFields == ''){
                        commaSepratedFields = fieldName;
                    }else{
                        commaSepratedFields = commaSepratedFields + ', ' + fieldName;
                    }
                }
            }
        }
        catch(exception e){
            system.debug('&&&&'+e.getMessage());
        }
        return commaSepratedFields;
    } 
    
    /*****************************************************************************
    Created by Karthiga, on 23 Jan,2017 
    @objName - Api name of any Sobject
    @fieldName - Api name of the picklist field
    returns - list of String
    *****************************************************************************/
    public static List<String> getPicklistValues(String objName,String fieldName) {
        
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(objName);
        if (targetType == null) {
            return new List<String>{'The requested resource does not exist'};
        } else {
            Schema.SObjectField targetFieldType = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName); 
            if(targetFieldType  == null) {
                return new List<String>{'The requested field does not exist'};    
            }  
        }
        
        List<String> picklistOptions = new List<String>();
        Schema.DescribeFieldResult descRes = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName).getDescribe();        
        List<Schema.PicklistEntry> ple = descRes.getPicklistValues();
        for(Schema.PicklistEntry picklist: ple ) { 
             
            picklistOptions.add(picklist.getValue());  
        } 
        return picklistOptions;
          
    }
    
    /**********************************************************************
        Created by Shalini on Feb 1 2017: This method returns list of RecordType object records
        @ObjectName - API Name of any object
        @devNameSet - DeveloperName of Record Types
        return - List of RecordType object 
     ***********************************************************************/
     
    public static List<RecordType> getRecTypeListBySobjTypeAndDevName(String filterQrystr,String ObjectName, set<String> devNameSet){
        
        List<RecordType> recTypeList = new LisT<RecordType>();
        system.debug('devNameSet'+devNameSet);
        try{
            String commaSepratedFields;
            String queryval;
            commaSepratedFields = getSObjectFieldsBySObjectName('RecordType');
            queryval = 'SELECT ' + commaSepratedFields + ' FROM ' + 'RecordType';
            if(ObjectName != Null && ObjectName != ''){    
                queryval += ' WHERE SobjectType = :ObjectName';
            }
            System.debug('queryval :::'+queryval );
            if(filterQrystr != null && filterQrystr != '' && devNameSet != null && devNameSet.size() > 0){
                queryval += filterQrystr + ' IN :devNameSet';
            }
            recTypeList = Database.query(queryval);
        }
        catch(exception e){
            system.debug('&&&&'+e.getMessage());
        }
        return recTypeList;
    }
    
    /**********************************************************************
        Created by Shalini on Feb 22 2017: This method returns Id of Custom Field
        return - Id of Custom Field 
        Modified by Karthiga on June 6 2017: This method usue the newly created Custom Settings to get the field Id
        @process - Process for which the Field is needed.
        @objName - Set of String (APi Name of Object)
        return - List of Field_ID_Mapping__c
    ***********************************************************************/
    
    public static List<Field_ID_Mapping__c> getCustomFieldIdMap(Set<String> process, Set<string> objName) {
        String qry = 'SELECT Id,Name,Field_API_Name__c,Object_API_Name__c,Process__c,Value__c  FROM Field_ID_Mapping__c WHERE Process__c IN : process';
        if( objName != null && objName.size() > 0 ) {
            qry += ' AND Object_API_Name__c IN :objName';
        }
        return Database.query(qry);
    }
    
    /**********************************************************************
        Created by Sukanya on May 29 2017: Method to update system values
        @systemValueJson - Json of system values
    ***********************************************************************/
    @future 
    public static void updateSystemValues(String systemValueJson){
        
        List<System_Values__c> systemValueList = (List<System_Values__c>) System.JSON.deserialize(systemValueJson, List<System_Values__c>.class);
        system.debug('::::::::systemValueList:::::::'+systemValueList);
        
        if(systemValueList.size() > 0)
            upsert systemValueList;
    }
    
    /**********************************************************************
    Created by GRK on July 17, 2017: method to return list of records for Lookup search in Many Pages
    @objectName - Name of the Object for generic search
    @searchString - searching Text
    @condition - condition to query records
    ***********************************************************************/
    public static List<sObject> getLookupRecords(String objectName, String searchString, String condition) {
            List<sObject> lookupRecords = new List<sObject>();
            String query = 'SELECT Id, Name FROM ' + objectName;
            if(searchString != null && searchString != '') {
                query += ' WHERE Name LIKE \'%' + searchString + '%\'';
            }
            if(objectName == 'AcctSeed__Project__c' || objectName == 'Opportunity'){
                Set<Id> proIdSet = new Set<Id>();
                Set<Id> oppIdSet = new Set<Id>();
                Id userId = UserInfo.getUserId(); 
                List<User> userList = SObjectQueryService.SObjectQuery('User',new Set<Id>{userId},'');
                if(userList[0].Staff_Access__c == true && userList[0].Current_Previlege__c == 'Staff'){ 
                    String parentField = 'Project__r.DLS_Class__c,Project__r.AcctSeed__Status__c,Candidate_Name__r.Name,Project__r.Name,Project__r.Start_Date__c,Project__r.End_Date__c ';
                    List<Contact_Assignments__c> conassignList = ContactAssignmentService.getContactassignmentByprojectId(' WHERE (Project__c != null OR Opportunity_Name__c != null) AND RecordType.DeveloperName = \'Staff\' AND Candidate_Name__c ',parentField,new Set<Id>{userList[0].ContactId},'');
                    for(Contact_Assignments__c ca : conassignList) {
                        if(ca.Project__c != null){
                            proIdSet.add(ca.Project__c);
                        }
                        if(ca.Opportunity_Name__c != null){
                            oppIdSet.add(ca.Opportunity_Name__c);
                        }
                    }
                    if(objectName == 'AcctSeed__Project__c'){
                        if(proIdSet != null && proIdSet.size() > 0){
                            if(searchString != null && searchString != '') {
                                query += ' AND Id IN :proIdSet';
                            } else {
                                query += ' WHERE Id IN :proIdSet';
                            }
                        }
                    }
                    if(objectName == 'Opportunity'){
                        if(oppIdSet != null && oppIdSet.size() > 0){
                            if(searchString != null && searchString != '') {
                                query += ' AND Id IN :oppIdSet';
                            } else {
                                query += ' WHERE Id IN :oppIdSet';
                            }
                        }
                    } 
                }
            } else {
                if(condition != null && condition != '') {
                    if(searchString != null && searchString != '') {
                        query += ' AND ' + condition;
                    } else {
                        query += ' WHERE ' + condition;
                    }
                }
            }
            query += ' LIMIT 10';
            System.debug('query log ' + query);
            lookupRecords = Database.query(query);
            return lookupRecords;
        }
        
        
        // To get pickList values
    
    @RemoteAction   
    public static List<String> PicklistValues(String ObjectApi_name,String Field_name) { 

        List<String> lstPickvals=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue());//add the value  to our final list
        }
        return lstPickvals;
    } 
}