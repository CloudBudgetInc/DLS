/*Created by SivaPrasanth on Dec 04 2019*/
public without sharing class ContactAffiliation_Ctrl {
    
    //This method return list of Contact Affiliation records and tab information.
    @AuraEnabled
    public static ContactAffilationTabInfo getTabInfo(String recId ,String sObjName) {
        List<String> defaultStatusSet = new List<String>{'All'};
        List<String> tabNames = new  List<String>();
        String recordTypeName = 'Client_Partner';

        ContactAffilationTabInfo contactAffiInfo = new ContactAffilationTabInfo();
   
        tabNames.add('Client/Partner');
        tabNames.add('DLS Staff');
        if(sObjName == 'Account') {
            tabNames.add('Student');																												
            tabNames.add('Instructor');
            
            contactAffiInfo = getContactAffiliationRecs(recId,sObjName,recordTypeName);
        } else if(sObjName == 'Contract') {
            contactAffiInfo = getContactAffiliationRecs(recId,sObjName,recordTypeName);
        }
        
        //Contact Affilation Status Field PickList Value Formation
        Schema.DescribeFieldResult fieldResult = Contact_Affiliation__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry f : ple) {
            defaultStatusSet.add(f.getValue());
        }
        
        contactAffiInfo.tabNames = tabNames;
        contactAffiInfo.defaultStatusPicklist = defaultStatusSet;
        
        return contactAffiInfo;
    }
    
    //This method return list of Contact Affiliation records.
    @AuraEnabled
    public static ContactAffilationTabInfo getContactAffiliationRecs(String recId ,String sObjName ,String recordTypeName) {
        List<Contact_Affiliation__c> contactAffilationRecs = new List<Contact_Affiliation__c>(); 
        
        if(sObjName == 'Account') {
            contactAffilationRecs  = [SELECT Id,Account__c,Contact__c,Name,Contact__r.Name,Contract__c,End_Date__c,Notes__c,Position__c,Start_Date__c,Status__c FROM Contact_Affiliation__c 
                                     	  WHERE RecordType.DeveloperName = :recordTypeName AND Account__c = :recId ORDER BY CreatedDate DESC];  
            
        } else if(sObjName == 'Contract') {
            contactAffilationRecs  = [SELECT Id,Account__c,Contact__c,Contact__r.Name,Name,Contract__c,End_Date__c,Notes__c,Position__c,Start_Date__c,Status__c FROM Contact_Affiliation__c
                                      	  WHERE RecordType.DeveloperName = :recordTypeName AND Contract__c = :recId ORDER BY CreatedDate DESC];  
            
        }
        ContactAffilationTabInfo contactAffiInfo = new ContactAffilationTabInfo();
        contactAffiInfo.contactAffilationRecs = contactAffilationRecs;
        
        return contactAffiInfo;
    }
    //This method to check  Contact Affilation Record Permission Access to perform DML.
    @AuraEnabled
    public static  Boolean contactAffilationRecAccess(String actionPerform){
        if(actionPerform == 'Edit'){
            return Schema.sObjectType.Contact_Affiliation__c.isUpdateable();
        }else if(actionPerform == 'Delete'){
            return Schema.sObjectType.Contact_Affiliation__c.isDeletable();
        }else if(actionPerform =='Create'){
            return Schema.sObjectType.Contact_Affiliation__c.isCreateable();
        }
        return null;
    }
    //Added by siva on Dec 05 2019
    //This method to delete  Contact Affilation Record.
    @AuraEnabled 
    public static String deleteConAffilationRec(String conAffilId){
        Contact_Affiliation__c conAffil = new  Contact_Affiliation__c (Id = conAffilId); 
        try{
            if(String.isNotBlank(conAffilId)){
                delete conAffil;
            }
        }catch(DmlException  e){
            throw new AuraHandledException(e.getMessage());
        }
        return 'Success';
    }
    //Added by siva on Dec 05 2019
    // This method to get Contact Affiliation Add/Edit information
    @AuraEnabled 
    public static ContactAffilationDetail getConAffilAddEditInformation(String cAId ,String recordTypeName ,String parentObjName ,String parentId){
        ContactAffilationDetail caDetail = new ContactAffilationDetail();
        Contact_Affiliation__c cARecord = new Contact_Affiliation__c();
        
        Id recordTypeId = Schema.SObjectType.Contact_Affiliation__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();     
        
        if(String.isNotBlank(cAId)){
            cARecord  = [SELECT Id,Account__c,Contact__c,Name,Contact__r.Name,Contract__c,End_Date__c,Notes__c,Position__c,Start_Date__c,Status__c FROM Contact_Affiliation__c 
                             WHERE Id = :cAId];  
        }else {
            if(parentObjName == 'Contract'){
                List<Contract> contractRec = [SELECT Id,EndDate,StartDate FROM Contract Where Id = :parentId];
                
                if(contractRec.size() > 0){
                    cARecord.Start_Date__c =   contractRec[0].StartDate;
                    cARecord.End_Date__c = contractRec[0].EndDate;
                    
                    if(String.isNotBlank(parentId)){
                        cARecord.Contract__c = parentId;
                    }
                    
                }
            }else if(parentObjName == 'Account'){
                
                if(String.isNotBlank(parentId)){
                    cARecord.Account__c = parentId;
                }
            }
            
            if(recordTypeName == 'Staff'){
                cARecord.Position__c = 'Staff';
            }else if(recordTypeName == 'Instructor'){
                cARecord.Position__c = 'Instructor';
            }else if(recordTypeName == 'Client_Partner'){
                cARecord.Position__c = 'Client';
            }else if(recordTypeName == 'Student'){
                cARecord.Position__c = 'Student';
            }
            cARecord.RecordTypeId = recordTypeId;
        }
        caDetail.cARecord = cARecord;
        
        if(!test.isRunningTest()){
            caDetail.statusValues = LibrarySearchController.getRecordTypeBased_PicklistValues('Contact_Affiliation__c','Status__c',recordTypeId);
            caDetail.positionValues = LibrarySearchController.getRecordTypeBased_PicklistValues('Contact_Affiliation__c','Position__c',recordTypeId);
        }
        
        return caDetail; 
    }
    // Method to upsert the Contact Affilation Record
    @AuraEnabled
    public static String upsertCARecord(String cARecordJSON) {
        List<Contact_Affiliation__c> cARecordsList = (List<Contact_Affiliation__c>) System.JSON.deserialize(cARecordJSON, List<Contact_Affiliation__c>.class);
        
        try{
            if(cARecordsList.size() > 0){
                upsert cARecordsList;
                return cARecordsList[0].Id;
            }
            return 'SUCCESS';
        }catch(DmlException e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class ContactAffilationTabInfo{
        @AuraEnabled
        public List<String> tabNames;
        @AuraEnabled
        public List<String> defaultStatusPicklist;
        @AuraEnabled
        public List<Contact_Affiliation__c> contactAffilationRecs;
    }
    public class ContactAffilationDetail{
        @AuraEnabled
        public String positionValues;
        @AuraEnabled
        public String statusValues;
        @AuraEnabled
        public Contact_Affiliation__c cARecord;
    }
}