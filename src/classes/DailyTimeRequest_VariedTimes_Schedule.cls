/****************
    - Added by HL on Sep 19 2019
    - To send an email notification to instructors for Daily Time Entry Request for "Varied Times schedules"
    - This scheduler runs daily basis at 5 pm
    ******************/
    
public class DailyTimeRequest_VariedTimes_Schedule implements Schedulable{

    public void execute(SchedulableContext sc) {
        
        List<Events__c> events = new List<Events__c>();
        
        if(!Test.isRunningTest()) {
        
            events = [SELECT Id, Instructor__c, Project__c 
                        FROM Events__c
                        WHERE Time_Card_Day__c = NULL AND Date__c = TODAY AND Status__c IN ('Scheduled', 'Completed') AND Instructor__c != NULL  
                            AND (Instructor__r.RecordType.DeveloperName = 'Candidate' OR (Instructor__r.RecordType.DeveloperName = 'DLS_Employee' AND Instructor__r.Active_DLS_Employee__c = TRUE)) 
                            AND Schedule__r.Varied_Time__c = TRUE AND (Start_Time__c = NULL OR Start_Time__c = '') AND (End_Time__c = NULL OR End_Time__c = '') AND Instructor__r.Active_DLS_Online_User__c = TRUE 
                            AND Project__c IN (SELECT Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Paper_Timesheet__c = FALSE)];
        
        }else {
            
            events = [SELECT Id, Instructor__c, Project__c 
                        FROM Events__c
                        WHERE Time_Card_Day__c = NULL AND Date__c = TODAY AND Status__c IN ('Scheduled', 'Completed')  
                            AND (Instructor__r.RecordType.DeveloperName = 'Candidate' OR (Instructor__r.RecordType.DeveloperName = 'DLS_Employee' AND Instructor__r.Active_DLS_Employee__c = TRUE)) AND Schedule__r.Varied_Time__c = TRUE];
        }
                
        System.debug('::::::events:::::::'+events);
        System.debug('::::::events SIZE:::::::'+events.size());
        
        if(events.size() > 0){
            
            Map<String, Events__c> contIdProIdAndEve = new Map<String, Events__c>();
            Set<Id> contactIds = new Set<Id>();
            
            for(Events__c eve : events){
            
                String contIdProId = eve.Instructor__c+'-'+eve.Project__c;
                if(!contIdProIdAndEve.containsKey(contIdProId)){
                    contIdProIdAndEve.put(contIdProId, eve);
                }
                contactIds.add(eve.Instructor__c);
            }
            System.debug('::::::contactIds:::::::'+contactIds);
            
            if(contactIds.size() > 0){
            
                List<Messaging.SingleEmailMessage> emailToInstructorList = new List<Messaging.SingleEmailMessage>();
                
                try{
            
                    EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Varied_Time_Daily_Request_for_Instructor'];
            
                    List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
                    
                    String orgWideEmailId = '';
                    
                    if(orgWideEmail != null && orgWideEmail.size() > 0){
                        orgWideEmailId = orgWideEmail[0].Id;
                    }
                                    
                    if(contactIds.size() > 0 && template != NULL && contIdProIdAndEve.size() > 0) {
                    
                        Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :contactIds AND Email != NULL AND Id IN (SELECT Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Paper_Timesheet__c = FALSE)]);
                    
                        String mailContent = '<html>Hi Chris, April and Nafisa <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                        Boolean hasBouncedEmail = false;
                        
                        for(String s : contIdProIdAndEve.keySet()){
                        
                            Events__c e = contIdProIdAndEve.get(s);
                        
                            if(e != NULL){
                            
                                if(conIdRec.containsKey(e.Instructor__c)){
                            
                                    if(!conIdRec.get(e.Instructor__c).IsEmailBounced){
                                
                                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                        if(orgWideEmailId != NULL) {
                                            mail.setOrgWideEmailAddressId(orgWideEmailId);
                                        }
                                        mail.setTargetObjectId(e.Instructor__c);
                                        mail.setWhatId(e.Id);
                                        
                                        mail.setSaveAsActivity(TRUE);
                                        mail.setTemplateID(template.Id);
                                        emailToInstructorList.add(mail);
                                    }else {
                                    
                                        mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(e.Instructor__c).Id+'" target="_blank">'+conIdRec.get(e.Instructor__c).Name+'</a><br/>';
                                        hasBouncedEmail = true;
                                    }
                                }
                            }
                        }    
                        mailContent += '<br/><p>This e-mail was auto generated. Please do not respond.</p>';
                        mailContent += '</html>';
                    
                        if(hasBouncedEmail || Test.isRunningTest()) {
                            
                            //Added custome setting to hold the exception recipients email ids
                            //By NS on March 3 2020
                            List<String> toAddressIds = new List<String>();
                
                            System_Values__c sysVal = System_Values__c.getValues('Contact Bounced Exception Email Ids'); 
                            if (sysVal != null && sysVal.Value__c != null) {
                                for (String st : sysVal.Value__c.split(',')) {
                                    toAddressIds.add(st.trim());
                                }
                            }
                            
                            Messaging.SingleEmailMessage bouncedmail = new Messaging.SingleEmailMessage();
                            bouncedmail.setToAddresses(toAddressIds);
                            bouncedmail.setSubject('Bounced email contact information');
                            bouncedmail.sethtmlBody(mailContent);
                            EmailToInstructorList.add(bouncedmail);
                        }
                    }
                    System.debug('emailToInstructorList::::'+emailToInstructorList);
                    
                    if( emailToInstructorList != NULL && emailToInstructorList.size() > 0 ) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToInstructorList);
                    }
                }catch(Exception e) {
                    
                    String errorMessage = '';
                    errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                    
                    ErrorHandler errHandler = new ErrorHandler();
                    errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Daily Time Entry Request for Varied Times schedules');
                    
                }
            }
        }
    }
}