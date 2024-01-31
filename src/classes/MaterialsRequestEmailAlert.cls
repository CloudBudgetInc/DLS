/**************************************************************
 - Created by NS on Dec 04 2019
 - Work Item: W-004237
 - Send an email alert to users Tameem Sameem and Noorzai when the field "Est. Arrival Date" is 1 days past and the Request Status is "Ordered"
 - Email on every day @9.00AM

***************************************************************/
public class MaterialsRequestEmailAlert implements Schedulable {

    
    public void execute(SchedulableContext SC){
        
        
        Set<Id> userIds = new Set<Id>();
        List<String> userEmails = new List<String>();
            
        System_Values__c sysVal = System_Values__c.getValues('Material Request Email Alert User Ids'); 
         
        if (sysVal != null && sysVal.Value__c != null) {
        
            String usrIds = String.valueOf(sysVal.Value__c);
            
            if (String.isNotEmpty(usrIds)) {
                if (usrIds.contains(',')) {
                    for(String str : usrIds.split(',')) {
                        if (!userIds.contains(Id.valueOf(str.trim()))){
                            userIds.add(Id.valueOf(str.trim()));
                        }
                    }
                } else {
                    userIds.add(Id.valueOf(usrIds));
                }
            } 
        } 
        System.debug(':::userIds:::'+userIds);
        
        for(User usr : [SELECT Id,Name,Email FROM User WHERE Id IN :userIds]){
            
            userEmails.add(usr.Email);
        }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(Materials_Request__c request : [SELECT Id,Name,Project__c,Project__r.Name,Est_Arrival_Date__c 
                                            FROM Materials_Request__c 
                                            WHERE Est_Arrival_Date__c = YESTERDAY AND Request_Status__c = 'Ordered' AND RecordType.DeveloperName = 'Project_Materials_Request']){
            
            String arriavalDt = String.valueOf(request.Est_Arrival_Date__c).split('-')[1]+'/'+String.valueOf(request.Est_Arrival_Date__c).split('-')[2]+'/'+String.valueOf(request.Est_Arrival_Date__c).split('-')[0];
            
            String mailContent = '<html>Hello,<br/><br/>The Material Request <a href='+URL.getSalesforceBaseUrl().toExternalForm()+'/'+request.Id+'>'+request.Name+'</a> for Project: '; 
            
            mailContent += '<a href='+URL.getSalesforceBaseUrl().toExternalForm()+'/'+request.Project__c+'>'+request.Project__r.Name+'</a>';
            
            mailContent += ' has a Request Status of Ordered and is past it\'s Est. Arrival Date of '+arriavalDt+'.';
            
            mailContent += '<br/><br/>Please follow up with the delivery carrier or the intended recipient to get an updated status for delivery.<br/>';
            
            mailContent += '<br/><br/>Thank you.<br/>This is an system generated email.';
            
           
            //Send Email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(userEmails);
            mail.setSubject('Material Request '+request.Name+' is Past it\'s Est. Arrival Date');
            mail.sethtmlBody(mailContent);
            mails.add(mail);
        }
        
        system.debug(':::::::mails::::'+mails);  
        
        try {
        
            if( mails != null && mails.size() > 0 && !Test.isRunningTest()) {
                Messaging.sendEmail(mails);
            } 
        
        }catch(Exception ex){
        
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(ex.getMessage(),system.Label.TimeCardDayEmail,'Error on Material Request Past it\'s Est. Arrival Date scheduler');  
        }                                              
        
    }
}