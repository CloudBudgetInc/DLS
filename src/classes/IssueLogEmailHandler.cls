global class IssueLogEmailHandler implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
         
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        Issue_Log__c issueLog = new Issue_Log__c();      
        
        List<User> userList = [SELECT Id, Name FROM User WHERE Email = :email.fromAddress]; 
        
        if(userList.size() > 0) {
            issueLog.Submitted_by__c = userList[0].Id;
        }
        
        issueLog.Issue_Description__c = email.plainTextBody;  
        issueLog.Issue_Subject__c = email.subject;
        issueLog.Stage__c = 'Submitted';
        issueLog.Category__c = 'Uncategorized';
        
        System.debug('::::::issueLog::::::'+issueLog);
        
        try {
            insert issueLog;
            System.debug('::::::issueLog::::::'+issueLog);
            result.success = TRUE;
        } catch(Exception e) {
            result.success = FALSE;
        }       
        System.debug('::::::result::::::'+result);
        return result;
      }
}