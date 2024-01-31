@isTest
private class Test_IssueLogEmailHandler {

    static testMethod void IssueLogEmailHandlerTestMethod() {   
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        email.subject = 'Test Email Subject';
        email.plainTextBody = 'Test Email Plain Text Body';
        email.fromAddress = 'test@testmail.com';
        
        IssueLogEmailHandler issueLogHandler = new IssueLogEmailHandler();
        issueLogHandler.handleInboundEmail(email, envelope);
    }
}