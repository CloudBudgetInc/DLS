trigger updateContentVersionNumberOfDownload on Request__c (After Insert) {
    
    Map<Id, List<Request__c>> contentVersionIdAndListOfRequests = new Map<Id, List<Request__c>>();
    List<ContentVersion> contentVersions = new List<ContentVersion>();
    
    if(trigger.isInsert && trigger.isAfter) {
        for(Request__c request : trigger.new) {
            if(request.ContentVersionId__c != Null && ((request.ContentVersionId__c).length() == 15 || (request.ContentVersionId__c).length() == 18)) {
                if(!contentVersionIdAndListOfRequests.containsKey(request.ContentVersionId__c)) {
                    contentVersionIdAndListOfRequests.put(request.ContentVersionId__c, new List<Request__c>());
                }
                contentVersionIdAndListOfRequests.get(request.ContentVersionId__c).add(request);
            }
        }
        
        if(contentVersionIdAndListOfRequests.size() > 0) {
            contentVersions = [SELECT Id, Number_of_Downloads__c FROM ContentVersion WHERE Id IN :contentVersionIdAndListOfRequests.KeySet()];
            if(contentVersions.size() > 0) { 
                for(ContentVersion content : contentVersions) {
                    if((contentVersionIdAndListOfRequests.get(content.Id)).size() > 0) {
                        if(content.Number_of_Downloads__c != Null) {
                            content.Number_of_Downloads__c = content.Number_of_Downloads__c + (contentVersionIdAndListOfRequests.get(content.Id)).size();
                        } else {
                            content.Number_of_Downloads__c = (contentVersionIdAndListOfRequests.get(content.Id)).size();
                        }
                    } 
                }
            }
        }
    }
    System.debug(':::Trigger.new:::' + Trigger.new);
    System.debug(':::contentVersionIdAndListOfRequests:::' + contentVersionIdAndListOfRequests);
    System.debug(':::contentVersions:::' + contentVersions);
    
    if(contentVersions.size() > 0) {
        update contentVersions;
    }
}