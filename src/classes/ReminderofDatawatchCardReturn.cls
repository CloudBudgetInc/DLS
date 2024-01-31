/***********************************************************************************
        - Send Email to the Instructors 
        - Work Item : W-000934
        - An e-mail notification to the Instructors who have not returned their datawatch access card to the DLS-Rosslyn location when the projects have finished
        - This batch class runs daily basis and send an email on the 7days before Contact Assignment's End date
        - This batch called from 
        - Email Templates - 
        - Created by HL on Mar 16 2019 
    *****************************************************************************************/
    
global class ReminderofDatawatchCardReturn implements Database.batchable<sObject>,Database.Stateful { 

    global List<EmailMsgWrap> emailMsgWrapList = new List<EmailMsgWrap>();
    global String mailContent = '<html>Hi Chris and April,<br/>The following contacts have bounced email ids, Please correct them: <br/>';
    global Boolean hasBouncedEmail = false;
    
    class EmailMsgWrap{
    
        String targetObjId;
        String whatId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext info){ 
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> conRTNames = new Set<String>{'Candidate', 'Student'};
              
        String  equipAssignQry = '';
        if(todayVal.format('EEEE') != 'Saturday' && todayVal.format('EEEE') != 'Sunday' && !Test.isRunningTest()) {
             equipAssignQry = 'SELECT Id, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.IsEmailBounced, Contact__r.Last_End_Date_Rosslyn__c FROM Equipment_Assignment__c WHERE Contact__c != NULL AND Contact__r.Email != NULL AND Contact__r.RecordType.DeveloperName IN :conRTNames AND Equipment__r.Asset_Type__c = \'Rosslyn Datawatch\' AND Contact__r.Last_End_Date_Rosslyn__c !=  NULL AND Location__r.Name = \'DLS - Rosslyn\' AND Stage__c = \'Active\'';
        
        }else if(Test.isRunningTest()){
            equipAssignQry = 'SELECT Id, Contact__c, Contact__r.Name, Contact__r.Email, Contact__r.IsEmailBounced, Contact__r.Last_End_Date_Rosslyn__c FROM Equipment_Assignment__c WHERE Contact__c != NULL AND Contact__r.Email != NULL AND Contact__r.RecordType.DeveloperName IN :conRTNames AND Equipment__r.Asset_Type__c = \'Rosslyn Datawatch\' AND Contact__r.Last_End_Date_Rosslyn__c !=  NULL AND Location__r.Name = \'DLS - Rosslyn\' AND Stage__c = \'Active\' LIMIT 2';
        }
       
        return Database.getQueryLocator(equipAssignQry);
    }
    
    global void execute(Database.BatchableContext info, List<Equipment_Assignment__c> equipAssigns){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        if(equipAssigns.size() > 0){
            
            for(Equipment_Assignment__c ea : equipAssigns){
               
                if(!ea.Contact__r.IsEmailBounced){
                    Date curentDate = Date.Today();
                    Date emailSendBeforeSevDate = ea.Contact__r.Last_End_Date_Rosslyn__c.addDays(-7);
                    Date emailSendAfterSevDate = ea.Contact__r.Last_End_Date_Rosslyn__c;
                    
                    DateTime beforeSevenDay = DateTime.newInstance(emailSendBeforeSevDate, Time.newInstance(0, 0, 0, 0));
                    
                    DateTime afterSevenDay = DateTime.newInstance(emailSendAfterSevDate, Time.newInstance(0, 0, 0, 0));
                    
                    if(beforeSevenDay.format('EEEE') == 'Saturday'){
                    
                        emailSendBeforeSevDate = emailSendBeforeSevDate.addDays(-1);
                    }else if(beforeSevenDay.format('EEEE') == 'Sunday'){
                    
                        emailSendBeforeSevDate = emailSendBeforeSevDate.addDays(-2);
                    }
                    
                    if(afterSevenDay.format('EEEE') == 'Saturday'){
                    
                        emailSendAfterSevDate = emailSendAfterSevDate.addDays(2);
                    }else if(afterSevenDay.format('EEEE') == 'Sunday'){
                    
                        emailSendAfterSevDate = emailSendAfterSevDate.addDays(1);
                    }
                    
                    if(curentDate == emailSendBeforeSevDate || curentDate == emailSendAfterSevDate){
                        EmailMsgWrap wrap = new emailMsgWrap();
                        wrap.targetObjId = ea.Contact__c;
                        wrap.whatId = ea.Id;
                        emailMsgWrapList.add(wrap);
                    }
                }else{
                    
                    mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+ea.Contact__c+'" target="_blank">'+ea.Contact__r.Name+'</a><br/>';
                    hasBouncedEmail = true;
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext info){
                
        List<Messaging.SingleEmailMessage> emailToInstructorList = new List<Messaging.SingleEmailMessage>();
        
        mailContent += '<br/><p>This e-mail was auto generated. Please do not respond.</p>';
        mailContent += '</html>';
        
        if(hasBouncedEmail) {
            
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
            emailToInstructorList.add(bouncedmail);
        }
        
        if(emailMsgWrapList.size() > 0 || emailToInstructorList.size() > 0){
                    
            try{
            
                if(emailMsgWrapList.size() > 0){
                
                    EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Datawatch_Access_Card_Reminder'];
                    
                    List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'FEO@dlsdc.com'];
                    
                    String orgWideEmailId = '';
                    String bccAddress = '';
                    
                    if(orgWideEmail != null && orgWideEmail.size() > 0){
                        orgWideEmailId = orgWideEmail[0].Id;
                        bccAddress  = orgWideEmail[0].Address;
                    }
                
                    for(EmailMsgWrap w : emailMsgWrapList){
                    
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        if(orgWideEmailId != NULL) {
                            mail.setOrgWideEmailAddressId(orgWideEmailId);
                        }
                        mail.setTargetObjectId(w.targetObjId);
                        mail.setWhatId(w.whatId );
                        mail.setTemplateID(template.Id);
                        
                        if(bccAddress != NULL){
                            String bccAdd = bccAddress;
                            mail.setBccAddresses(new List<String>{bccadd});
                        }
                        mail.setSaveAsActivity(true);
                        emailToInstructorList.add(mail);
                    }
                }
                
                if( emailToInstructorList != NULL && emailToInstructorList.size() > 0 ) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToInstructorList);
                }
            }catch(Exception e) {
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Reminder of Datawatch Access Card Return for Instructors');
            }
        }
    }
}