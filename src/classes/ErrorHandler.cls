/************************************************************
 - Class to hanlder all kind of error handling
 - Send the exception as Email to the custom label email address
 - Created by NS on April 24 2018
*************************************************************/
public class ErrorHandler {

    public void sendExceptionEmail(String errorMsg,String toAddress,String subject){
        
        List<Messaging.SingleEmailMessage> ErrorMailMsg = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setToAddresses(new String[] {toAddress});
        mail.setSubject(subject); 
        mail.setPlainTextBody(errorMsg);
        mail.setSaveAsActivity(false);
        
        ErrorMailMsg.add(mail);
        
        try{
            if( ErrorMailMsg != null && ErrorMailMsg.size() > 0 ){
                Messaging.sendEmail(ErrorMailMsg); 
            }
        } catch (Exception ex){
            system.debug('Ex::::'+ex);
        }    
    }
        
    public static void publishErrorLog(List<ErrorLogUtilDomain> errorLogUtilDomainList){
        
        List<Log_Error__e> errorLogEvents = new List<Log_Error__e>();
        
        for(ErrorLogUtilDomain domain : errorLogUtilDomainList){
            errorLogEvents.add(
                new Log_Error__e(
                    Method_Name__c = domain.methodName,
                    Description__c = domain.Description,
                    JSON_Response__c = domain.JSONResponse,
                    Component_Name__c = domain.componentName,
                    Object__c = domain.ObjectName,
                    Component_Type__c = domain.componentType
                )
            );
        }
        
        List<Database.SaveResult> results = EventBus.publish(errorLogEvents);
    }
    
    @InvocableMethod
    public static void publishErrorLog_Flow(List<ErrorLogUtilDomain_Flow> flowErrorLogUtilDomainList){
        
        List<Log_Error__e> errorLogEvents = new List<Log_Error__e>();
        
        for(ErrorLogUtilDomain_Flow domain : flowErrorLogUtilDomainList){
            errorLogEvents.add(
                new Log_Error__e(
                    Component_Name__c = domain.classOrTriggerName,
                    Method_Name__c = domain.methodName,
                    Description__c = domain.Description
                )
            );
        }
        
        List<Database.SaveResult> results = EventBus.publish(errorLogEvents);
    }
    
    public static Messaging.SingleEmailMessage getBouncedEmail(String contactDetailStr){
    
        String mailContent = '<html>Hi Chris and April, <br/><br/><br/>The following contacts have bounced email ids, Please correct them: <br/>';
        mailContent += contactDetailStr;
        mailContent += '<br/><p>This e-mail was auto generated. Please do not respond.</p>';
        mailContent += '</html>';
        
        List<String> toAddressIds = new List<String>();
            
        System_Values__c sysVal1 = System_Values__c.getValues('Contact Bounced Exception Email Ids'); 
        if (sysVal1 != null && sysVal1.Value__c != null) {
            for (String st : sysVal1.Value__c.split(',')) {
                toAddressIds.add(st.trim());
            }
        }
        
        Messaging.SingleEmailMessage bouncedmail = new Messaging.SingleEmailMessage();
        bouncedmail.setToAddresses(toAddressIds);
        bouncedmail.setSubject('Bounced email contact information');
        bouncedmail.sethtmlBody(mailContent);
                
        return bouncedmail;
    }
    
    Public Class ErrorLogUtilDomain{
        
        public String methodName;
        public String componentName;
        public String ObjectName;
        public String Description;
        public String JSONResponse;
        public string componentType;
        
        public ErrorLogUtilDomain(String componentName, String methodName, String ObjectName, String Description, String JSONResponse, String componentType){
            this.componentName = componentName;
            this.methodName = methodName;
            this.ObjectName = ObjectName;
            this.Description = Description;
            this.JSONResponse = JSONResponse;
            this.componentType = componentType;            
        }
    }    
    
    Public Class ErrorLogUtilDomain_Flow{
        
        @InvocableVariable
        public String classOrTriggerName;
        @InvocableVariable
        public String methodName;
        @InvocableVariable
        public String Description;
    }
}