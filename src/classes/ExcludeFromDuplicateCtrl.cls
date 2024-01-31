public class ExcludeFromDuplicateCtrl {
	
    public String query{get; set;}
    
    public ExcludeFromDuplicateCtrl(){
        
        query = JSON.serialize(ApexPages.currentPage().getParameters());
        System.debug('query'+ApexPages.currentPage().getParameters());
    }
    
    @AuraEnabled
    public static String getFileDetails(String queryStr){
        
        String result ='';        
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(URL.getOrgDomainUrl().toExternalForm()+'/services/data/v42.0/wave/query');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setHeader('Content-Type','application/json');
        request.setBody(queryStr);
        Http http = new Http();
        HttpResponse response = http.send(request);
        result = response.getBody();
        
        return result;
    }
    
    @AuraEnabled
    public static String excludeFilesFromDuplicates(String selectedRowsStr){
        String result = '';        
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(Label.ExcludeDuplicateFile_BaseURL+'/api/box/upsert/non-duplicate');
        request.setMethod('POST');
        request.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
        request.setHeader('Content-Type','application/json');
        request.setTimeout(120000);
        request.setBody(selectedRowsStr);
        Http http = new Http();
        HttpResponse response = http.send(request);
        result = response.getBody();
        
        return result;        
    }
    
    @auraEnabled
    public static Map<String, String> getRelatedSalesforceId(List<String> parentIds){
        
        Map<String, String> parentIdWithRelatedSalesforceId = new Map<String, String>();
        for(box__FRUP__c frupRec : [SELECT Id, box__Record_ID__c, box__Folder_ID__c FROM box__FRUP__c WHERE box__Folder_ID__c IN :parentIds]){
            parentIdWithRelatedSalesforceId.put(frupRec.box__Folder_ID__c, frupRec.box__Record_ID__c);
        }
        
        return parentIdWithRelatedSalesforceId;
    }
    
    @auraEnabled
    public static Map<String, String> getOrgBaseURLAndUserDetailsMap(){
        User usr = [SELECT Id, Name, Email FROM USER WHERE Id = :UserInfo.getUserId()];
        Map<String, String> wrapMap = new Map<String, String>();
        wrapMap.put('userDetails', JSON.serialize(usr));
        wrapMap.put('baseUrl', URL.getOrgDomainUrl().toExternalForm());
        
        return wrapMap;
    }
}