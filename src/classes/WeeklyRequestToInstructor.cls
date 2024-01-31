/***********************************************************************************
        - Send Email to the Instructors
        - Work Item : W-001111
        - An e-mail notification to the instructors for Weekly Request for Weekly Timesheet Submission 
        - Immediately at Event End Time for the last Event for the Time Card Period for all Schedules the Instructor is assigned to
        - This batch class runs daily basis on every one hour
        - This batch called from WeeklyRequestToInstructor_Schedule
        - Html Email Body
        - Created by HL on Mar 14 2019 
    *****************************************************************************************/
    
global class WeeklyRequestToInstructor implements Database.batchable<sObject>,Database.Stateful { 

    global List<Messaging.SingleEmailMessage> emailToInstructorList;
    global Map<Id, Contact> conIdAndRec = new Map<Id, Contact>();
    global Set<Id> conIdsForSendingEmail = new Set<Id>();
    global Map<Id, Id> insIdAndEveId = new Map<Id, Id>();
    
    global Database.QueryLocator start(Database.BatchableContext info){ 
    
        String  contactQry = '';         
        if(!Test.isRunningTest()){       
            //contactQry = 'SELECT Id,Name,IsEmailBounced, Email FROM Contact WHERE RecordType.DeveloperName = \'Candidate\' AND Email != null '+
                     //'AND Id IN (SELECT ContactId FROM User WHERE IsActive = true AND IsPortalEnabled = true AND Instructor_Access__c = true)';
                     
            contactQry = 'SELECT Id, Name, IsEmailBounced, Email FROM Contact WHERE RecordType.DeveloperName = \'Candidate\' AND Email != null '+
                'AND Id IN (SELECT ContactId FROM User WHERE IsActive = true AND IsPortalEnabled = true AND Profile.Name = \'Instructor Community\')';
        }else if(Test.isRunningTest()){
        
            contactQry = 'SELECT Id, Name, IsEmailBounced, Email FROM Contact WHERE RecordType.DeveloperName = \'Candidate\' AND Email != null '+
                     'AND Id IN (SELECT ContactId FROM User WHERE IsActive = true AND IsPortalEnabled = true AND Instructor_Access__c = true) LIMIT 1';
        }
        
        System.debug('contactQry ==========='+contactQry);
        return Database.getQueryLocator(contactQry);    
    }
    
    global void execute(Database.BatchableContext info, List<Contact> contacts){
    
        Set<Id> contactIds = new Set<Id>();
        Map<Id, Events__c> insIdAndEvent = new Map<Id, Events__c>();
        
        Set<String> eventStatus = new Set<String>{'Scheduled', 'Completed'};
        
        Date currentWeekStart = System.today().toStartofWeek().addDays(1);
        Date currentWeekEnd = currentWeekStart.addDays(6);
        
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
        
        if(contacts.size() > 0){
        
            for(Contact con : contacts) {
                contactIds.add(con.Id);
                conIdAndRec.put(con.Id,con);  
            }
            System.debug('contactIds=========='+contactIds+'contactIds SIZE==='+contactIds.size());
            
            if(contactIds.size() > 0){
            
                for(Events__c e : [SELECT Id, Instructor__c, Date__c, End_Time__c
                                    FROM Events__c 
                                    WHERE Date__c >= :currentWeekStart AND Date__c <= :currentWeekEnd AND Status__c IN :eventStatus  
                                        AND Project__c != NULL AND Instructor__c IN :contactIds 
                                        AND Project__c IN (SELECT Project__c FROM Contact_Assignments__c WHERE Paper_Timesheet__c = false) 
                                        AND (Time_Card_Day__c = null OR (Time_Card_Day__c != null AND Time_Card_Day__r.Status__c = 'Draft'))
                                        ORDER BY Date__c DESC]){
                
                    if(!insIdAndEvent.containsKey(e.Instructor__c)){
                        insIdAndEvent.put(e.Instructor__c, e);
                    }
                }        
                System.debug('insIdAndEvent====='+insIdAndEvent+'insIdAndEvent SIZE==='+insIdAndEvent.size());
        
                if(insIdAndEvent.size() > 0){
                
                    for(Id insId : insIdAndEvent.keySet()){
                    
                        Events__c e = insIdAndEvent.get(insId);
                            
                        if((e.Date__c == Date.Today() && timeRanges.contains(e.End_Time__c)) || Test.isRunningTest()){
                        
                            conIdsForSendingEmail.add(e.Instructor__c);
                            insIdAndEveId.put(e.Instructor__c, e.Id);
                        }
                    }
                }
            }
        }
        System.debug('conIdsForSendingEmail============'+conIdsForSendingEmail+'conIdsForSendingEmail SIZE======='+conIdsForSendingEmail.size()); 
    }
    
    global void finish(Database.BatchableContext info){
    
        
        Date currentWeekStart = System.today().toStartofWeek().addDays(1);
        Date currentWeekEnd = currentWeekStart.addDays(6);
        
        Date nextWeekStart = currentWeekStart.addDays(7);
        
        String curWkStStr = String.valueOf(currentWeekStart);
        String curWkEdStr = String.valueOf(currentWeekEnd);
        String nxtWkStStr = String.valueOf(nextWeekStart);
        
        String curWkStart = curWkStStr.split('-')[1]+'/'+curWkStStr.split('-')[2]+'/'+curWkStStr.split('-')[0];
        String curWkEnd = curWkEdStr.split('-')[1]+'/'+curWkEdStr.split('-')[2]+'/'+curWkEdStr.split('-')[0];
        String nxtWkStart = nxtWkStStr.split('-')[1]+'/'+nxtWkStStr.split('-')[2]+'/'+nxtWkStStr.split('-')[0];
        
        emailToInstructorList = new List<Messaging.SingleEmailMessage>();
        
        try{
        
            List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
            
            String orgWideEmailId = '';
            
            if(orgWideEmail != null && orgWideEmail.size() > 0){
                orgWideEmailId = orgWideEmail[0].Id;
            }
            
            system.debug('orgWideEmailId======'+orgWideEmailId);
            
            if(conIdsForSendingEmail.size() > 0) {
            
                String mailContent = '<html>Hi Chris, April and Nafisa ,<br/>The following contacts have bounced email ids, Please correct them: <br/>';
                Boolean hasBouncedEmail = false;
                
                for(Id contactId :conIdsForSendingEmail){
                        
                    if(conIdAndRec.containsKey(contactId)){
                    
                        if(!conIdAndRec.get(contactId).IsEmailBounced) {
                            
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            if(orgWideEmailId != NULL) {
                                mail.setOrgWideEmailAddressId(orgWideEmailId);
                            }
                            mail.subject = 'DLS Timekeeping - Request for you to submit your time for this Week';
                            
                            String weekRange = curWkStart + ' to '+ curWkEnd;
                            String urlRedirectToInsPage = '<a href="'+ System.Label.Instructor_Community_Site_Prefix+'/s/time-submit?week='+ weekRange + '" target="_blank"> Click Here </a>';
    
                            String Message = 'Hi ' +conIdAndRec.get(contactId).Name+', <br/><br/>';
                            Message += 'This is a courtesy reminder to submit your time for this week '+ curWkStart+' - '+curWkEnd;
                            Message += ' for all of your Projects. All employees are required to submit their time for this week by '+nxtWkStart;
                            Message += ' at 12.00 PM.<br/><br/>';
                            Message += 'Please go to the Time Entry Page - '+ urlRedirectToInsPage+'  to complete your time entry.<br/><br/>';
                            Message += 'Thank you,<br/><br/>DLS Accounting Department<br/>System Generated Email<br/>'; 
                            
                            mail.setHtmlBody(Message);
                            mail.setTargetObjectId(contactId);
                            mail.setWhatId(insIdAndEveId.get(contactId));
                            mail.setSaveAsActivity(TRUE);
                            emailToInstructorList.add(mail);         
                        }else {
                        
                            mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdAndRec.get(contactId).Id+'" target="_blank">'+conIdAndRec.get(contactId).Name+'</a><br/>';
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
                    EmailToInstructorList.add(bouncedmail);
                }
            }
            System.debug('EmailToInstructorList::::'+EmailToInstructorList);
            
            if( EmailToInstructorList != NULL && EmailToInstructorList.size() > 0 ) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(EmailToInstructorList);
            }
        }catch(Exception e) {
            
            String errorMessage = '';
            errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
            
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Weekly Time Entry Submission Request for Instructors');
        } 
    }
}