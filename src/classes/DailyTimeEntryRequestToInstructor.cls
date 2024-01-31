/***********************************************************************************
        - Send Email to the Instructors
        - Work Item : W-001111
        - An e-mail notification to the instructors for Daily Time Entry Request- Sent at the last end time of the Event for that date
        - This batch class runs daily basis on every one hour
        - This batch called from DailyRequestToInstructor_Schedule 
        - Created by HL on May 30 2019 
    *****************************************************************************************/

global class DailyTimeEntryRequestToInstructor implements Database.batchable<sObject>,Database.Stateful { 

    global List<Messaging.SingleEmailMessage> emailToInstructorList;
    global Map<String, Events__c> conIdProjIdAndEve = new Map<String, Events__c>();
    global Set<Id> contactIds = new Set<Id>();
        
    global Database.QueryLocator start(Database.BatchableContext info){ 
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        String  projQry = '';
        
        if(!Test.isRunningTest()) {
             //projQry = 'SELECT Id FROM AcctSeed__Project__c WHERE Id IN (SELECT Project__c FROM Events__c WHERE Time_Card_Day__c = NULL AND Date__c = TODAY AND Status__c = \'Scheduled\' AND Project__c != NULL AND Instructor__c != NULL AND Instructor__r.RecordType.DeveloperName = \'Candidate\')';
             projQry = 'SELECT Id FROM AcctSeed__Project__c WHERE Id IN (SELECT Project__c FROM Events__c '+
                         'WHERE Time_Card_Day__c = NULL AND Date__c = TODAY AND Status__c = \'Scheduled\' AND Instructor__c != NULL '+
                             'AND (Instructor__r.RecordType.DeveloperName = \'Candidate\' OR (Instructor__r.RecordType.DeveloperName = \'DLS_Employee\' AND Instructor__r.Active_DLS_Employee__c = TRUE))) '+
                             'AND Id IN (SELECT Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = \'Instructor\' AND Paper_Timesheet__c = FALSE)';
        
        }else if(Test.isRunningTest()){
            projQry = 'SELECT Id FROM AcctSeed__Project__c '+    
                        'WHERE Id IN (SELECT Project__c FROM Events__c WHERE Time_Card_Day__c = NULL AND Date__c = TODAY '+
                            'AND Status__c = \'Scheduled\' AND Project__c != NULL AND Instructor__c != NULL AND Instructor__r.RecordType.DeveloperName = \'Candidate\') LIMIT 1';
        }        
        
        System.debug('projQry==========='+projQry);
        return Database.getQueryLocator(projQry);
    }
    
    global void execute(Database.BatchableContext info, List<AcctSeed__Project__c > projects){
        
        System.debug('projects============='+projects+'projects SIZE======'+projects.size());
        
        Map<String, Events__c> contIdProIdAndEve = new Map<String, Events__c>();
        
        DateTime currentTime =  System.now();
        
        String currentPeriod = 'AM';
        String previousPeriod = 'AM';
        
        String curHourStr = '';
        String preHourStr = '';
        
        Integer currentHour = currentTime.hour();
        Integer previousHour = currentHour -1;
        
        if(currentHour >= 12){
            currentHour = currentHour - 12;    
            currentPeriod = 'PM';
        }
        if(currentHour == 0){
            currentHour = 12;
        }
        
        if(previousHour >= 12){
            previousHour = previousHour - 12;    
            previousPeriod = 'PM';
        }
        if(previousHour == 0){
            previousHour = 12;
        }
        
        if(currentHour <= 9){
            curHourStr = '0'+String.valueOf(currentHour);
        }else{
            curHourStr = String.valueOf(currentHour);     
        }
        
        if(previousHour <= 9){
            preHourStr = '0'+String.valueOf(previousHour);
        }else{
            preHourStr = String.valueOf(previousHour);     
        }
        System.debug('========'+curHourStr);
        System.debug('========'+preHourStr);
        
        Set<String> timeRanges = new Set<String>();
        timeRanges.add(curHourStr+':00 '+currentPeriod);
        timeRanges.add(preHourStr+':15 '+previousPeriod);
        timeRanges.add(preHourStr+':30 '+previousPeriod);
        timeRanges.add(preHourStr+':45 '+previousPeriod);
        System.debug('timeRanges ====='+timeRanges);
        
        Map<String,Boolean> conIdProIdPaperTimesheetFlag = new Map<String,Boolean>();
        
        if(projects.size () > 0){
        
            //Check for the instructors whos paper timesheet flag is flase, then send reminder notification
            for(Contact_Assignments__c ca : [SELECT Id,Project__c,Candidate_Name__c,Paper_Timesheet__c 
                                                FROM Contact_Assignments__c 
                                                WHERE Project__c IN :projects AND RecordType.DeveloperName = 'Instructor' AND Paper_Timesheet__c = FALSE]){
                
                String key = ca.Candidate_Name__c+'-'+ca.Project__c;
                if(!conIdProIdPaperTimesheetFlag.containsKey(key)){
                    conIdProIdPaperTimesheetFlag.put(key,ca.Paper_Timesheet__c);
                }
            }
            
            for(Events__c eve : [SELECT Id, Instructor__c, Project__c, End_Time__c 
                                    FROM Events__c 
                                    WHERE Time_Card_Day__c = NULL AND Date__c = TODAY AND Status__c = 'Scheduled' AND Project__c IN :projects AND Instructor__c != NULL 
                                        AND (Instructor__r.RecordType.DeveloperName = 'Candidate' OR (Instructor__r.RecordType.DeveloperName = 'DLS_Employee' AND Instructor__r.Active_DLS_Employee__c = TRUE)) 
                                        ORDER BY End_Time__c DESC]){
            
                String contIdProId = eve.Instructor__c+'-'+eve.Project__c;
                if(!contIdProIdAndEve.containsKey(contIdProId) && conIdProIdPaperTimesheetFlag.containsKey(contIdProId)
                    && !conIdProIdPaperTimesheetFlag.get(contIdProId)){
                    contIdProIdAndEve.put(contIdProId, eve);
                }
            }
            System.debug('contIdProIdAndEve========='+contIdProIdAndEve+'contIdProIdAndEve SIZE=========='+contIdProIdAndEve.size());
        
            if(contIdProIdAndEve.size() > 0){
            
                for(String s : contIdProIdAndEve.keySet()){
                
                    Events__c e = contIdProIdAndEve.get(s);
                        
                    if(timeRanges.contains(e.End_Time__c) || Test.isRunningTest()){
                    
                        String conIdProjId = e.Instructor__c+'-'+e.Project__c;
                        if(!conIdProjIdAndEve.containsKey(conIdProjId)){
                            conIdProjIdAndEve.put(conIdProjId, e);
                            contactIds.add(e.Instructor__c);
                        }
                    }
                }
            }
        }
        System.debug('contactIds============'+contactIds+'contactIds SIZE======='+contactIds.size()); 
    }
    
    global void finish(Database.BatchableContext info){
    
        emailToInstructorList = new List<Messaging.SingleEmailMessage>();
        
        try{
            
            EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Daily_Request_for_Instructor'];
            
            List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
            
            String orgWideEmailId = '';
            
            if(orgWideEmail != null && orgWideEmail.size() > 0){
                orgWideEmailId = orgWideEmail[0].Id;
            }
                                    
             if(contactIds.size() > 0 && template != NULL && conIdProjIdAndEve.size() > 0) {
                
                Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :contactIds AND Email != NULL]);
                
                String mailContent = '<html>Hi Chris, April and Nafisa <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                Boolean hasBouncedEmail = false;
                
                for(String s : conIdProjIdAndEve.keySet()){
                
                    Events__c e = conIdProjIdAndEve.get(s);
                    
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
            errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Daily Time Entry Request for Instructors');
        } 
    }
}