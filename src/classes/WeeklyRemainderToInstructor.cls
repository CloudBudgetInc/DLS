/***********************************************************************************
        - Send Email to the Instructors
        - Work Item : W-001111
        - An Email notification to Instructors for Weekly Reminder for Weekly Timesheet Submission. 
        - Only send if the Instructor did not complete the submit action by the due date and time (following Monday by 12:00PM)
        - This batch class runs weekly basis and Send @ 12:00 PM on Monday following timesheet week
        - This batch called from WeeklyRemainderToInstructor_Schedule
        - Html Email Body
        - Created by HL on Mar 07 2019
    *****************************************************************************************/
global class WeeklyRemainderToInstructor implements Database.batchable<sObject>,Database.Stateful { 
    
    global List<Messaging.SingleEmailMessage> emailToInstructorList;
    global Map<Id,Contact> conIdAndRec = new Map<Id,Contact>();
    global Set<Id> contactIdSet = new Set<Id>();
    global Map<Id, Id> insIdAndTCId = new Map<Id, Id>();
    
    global Database.QueryLocator start(Database.BatchableContext info){
        
        System.debug('WeeklyRemainderToInstructor =======');
        
        String  contactQry = '';         
        if(!Test.isRunningTest()){       
            //contactQry = 'SELECT Id,Name,IsEmailBounced, Email FROM Contact WHERE RecordType.DeveloperName = \'Candidate\' AND Email != null '+
             //        'AND Id IN (SELECT ContactId FROM User WHERE IsActive = true AND IsPortalEnabled = true AND Instructor_Access__c = true)';
                     
             contactQry = 'SELECT Id,Name,IsEmailBounced, Email FROM Contact WHERE (RecordType.DeveloperName = \'Candidate\' OR (RecordType.DeveloperName = \'DLS_Employee\' AND Active_DLS_Employee__c = TRUE)) AND Email != null '+
                     'AND Id IN (SELECT ContactId FROM User WHERE IsActive = true AND IsPortalEnabled = true AND Profile.Name = \'Instructor Community\')';
        }else if(Test.isRunningTest()){
        
            contactQry = 'SELECT Id,Name,IsEmailBounced, Email FROM Contact WHERE RecordType.DeveloperName = \'Candidate\' AND Email != null '+
                     'AND Id IN (SELECT ContactId FROM User WHERE IsActive = true AND IsPortalEnabled = true AND Instructor_Access__c = true) LIMIT 1';
        }
        
        
        System.debug('contactQry ==========='+contactQry);
        return Database.getQueryLocator(contactQry);
    }
        
    
    global void execute(Database.BatchableContext info, List<Contact> contactList){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        Date currentWeekStart = system.today().toStartofWeek().addDays(1);
        Date currentWeekEnd = currentWeekStart.addDays(6);
        
        Date previouswkStart = currentWeekStart.addDays(-7);
        Date previouswkEnd = previouswkStart.addDays(6);
        
        Map<Id,Boolean> contactIdIncludeForEmailMap =  new Map<Id,Boolean>();
        Map<Id,Boolean> conIdactiveFlagMap = new Map<Id,Boolean>();
        Set<Id> contactIds = new Set<Id>();
        
        if(contactList.size() > 0){
        
            for(Contact con : contactList) {
                contactIds.add(con.Id);
                conIdAndRec.put(con.Id,con);  
            }
            
            if(contactIds.size() > 0){
            
                // Quried Contact Assignment to get active dls Instructor contact for Community mail sending
                for(Contact_Assignments__c conAss : [SELECT Id,Name,Candidate_Name__c, Project__c 
                                                        FROM Contact_Assignments__c 
                                                        WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' 
                                                            AND Candidate_Name__c IN : contactIds AND Paper_Timesheet__c = FALSE]) {
                    if(!conIdactiveFlagMap.containsKey(conAss.Candidate_Name__c))
                        conIdactiveFlagMap.put(conAss.Candidate_Name__c,true);
                }
                System.debug('conIdactiveFlagMap========='+conIdactiveFlagMap+'conIdactiveFlagMap SIZE==='+conIdactiveFlagMap.size());
        
                for(AcctSeed__Time_Card__c c : [
                    SELECT Id, Intructor__c, of_Pending_Time_Logs__c, of_Submitted_Hours__c
                    FROM AcctSeed__Time_Card__c 
                    WHERE AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c  >= :previouswkStart AND AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c <= :previouswkEnd
                        AND Intructor__c IN :contactIds
                ]){
                
                    if(todayVal.format('EEEE') == 'Monday' || Test.isRunningTest()){
                    
                        if(c.of_Pending_Time_Logs__c > 0 && c.of_Submitted_Hours__c == 0) {
                        
                            if(!contactIdIncludeForEmailMap.containsKey(c.Intructor__c)) {
                                contactIdIncludeForEmailMap.put(c.Intructor__c,true);
                                insIdAndTCId.put(c.Intructor__c, c.Id);
                            } 
                        }
                    }
                }
                System.debug('contactIdIncludeForEmailMap==='+contactIdIncludeForEmailMap+'contactIdIncludeForEmailMap SIZE==='+contactIdIncludeForEmailMap.size());
                System.debug('insIdAndTCId==='+insIdAndTCId+'insIdAndTCIdSIZE==='+insIdAndTCId.size());
                
                if(contactIdIncludeForEmailMap.size () > 0 && conIdactiveFlagMap.size() > 0){
                
                    for(Id conId : contactIdIncludeForEmailMap.keySet()) {
                        if(contactIdIncludeForEmailMap.get(conId) && conIdactiveFlagMap.containsKey(conId)) {
                            contactIdSet.add(conId);
                        }
                    }
                }
                System.debug('contactIdSet==='+contactIdSet+'contactIdSet==='+contactIdSet.size());
            }
        }
    }
    
    global void finish(Database.BatchableContext info){
        
        emailToInstructorList = new List<Messaging.SingleEmailMessage>();
        
        Date currentWeekStart = System.today().toStartofWeek().addDays(1);
        
        Date preWeekStart = currentWeekStart.addDays(-7);
        Date preWeekEnd = preWeekStart.addDays(6);
        
        String preWkStStr = String.valueOf(preWeekStart);
        String preWkEdStr = String.valueOf(preWeekEnd);
        
        String preWkStart = preWkStStr.split('-')[1]+'/'+preWkStStr.split('-')[2]+'/'+preWkStStr.split('-')[0];
        String preWkEnd = preWkEdStr.split('-')[1]+'/'+preWkEdStr.split('-')[2]+'/'+preWkEdStr.split('-')[0];
        
        try{
                    
            List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
            
            String orgWideEmailId = '';
            
            if(orgWideEmail != null && orgWideEmail.size() > 0){
                orgWideEmailId = orgWideEmail[0].Id;
            }
            
            system.debug(':::::::orgWideEmailId:::::'+orgWideEmailId);
            
            DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
            
            if(contactIdSet.size() > 0 ) {
            
                String mailContent = '<html>Hi Chris, April and Nafisa ,<br/>The following contacts have bounced email ids, Please correct them: <br/>';
                Boolean hasBouncedEmail = false;
                
                for(Id contactId :contactIdSet){
                        
                    if(conIdAndRec.containsKey(contactId)){
                    
                        if(!conIdAndRec.get(contactId).IsEmailBounced) {
                            
                            if(todayVal.format('EEEE') == 'Monday' || Test.isRunningTest()) {
                            
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                if(orgWideEmailId != NULL) {
                                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                                }
                                mail.subject = 'DLS Timekeeping - Reminder for you to submit your time for last Week';
                                
                                String weekRange = preWkStart + ' to '+ preWkEnd;
                                String urlRedirectToInsPage = '<a href="'+ System.Label.Instructor_Community_Site_Prefix+'/s/time-submit?week='+ weekRange + '" target="_blank"> Click Here </a>';
    
                                String Message = 'Hi ' +conIdAndRec.get(contactId).Name+', <br/><br/>';
                                Message += 'This is a reminder to submit your time for last week '+ preWkStart + ' - ' + preWkEnd;
                                Message += '. DLS Timekeeping policy requires all employees to submit their timesheets by Monday at 12:00 PM. <br/><br/>';
                                Message += 'Please go to the Time Entry Page - '+ urlRedirectToInsPage+'  to complete your time entry.<br/><br/>';
                                Message += 'If you have any questions or require any assistance with completing your timesheet, please contact your LTS or reply to <a href="mailto:timesheets@dlsdc.com">timesheets@dlsdc.com</a> to request assistance. <br/><br/>';
                                Message += 'Thank you,<br/><br/>DLS Accounting Department<br/>System Generated Email<br/>'; 
                                
                                mail.setHtmlBody(Message);
                                mail.setTargetObjectId(contactId);
                                if(insIdAndTCId.containsKey(contactId)){
                                    mail.setWhatId(insIdAndTCId.get(contactId));
                                }
                                mail.setSaveAsActivity(TRUE);
                                emailToInstructorList.add(mail);         
                            }               
                        }else {
                        
                            mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdAndRec.get(contactId).Id+'" target="_blank">'+conIdAndRec.get(contactId).Name+'</a><br/>';
                            hasBouncedEmail = true;
                        }
                    }
                }
                
                mailContent += '<br/><p>This e-mail was auto generated. Please do not respond.</p>';
                mailContent += '</html>';
                
                if(hasBouncedEmail) {
                    
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
                    emailToInstructorList.add(bouncedmail);
                }
            }
            
            System.debug('emailToInstructorList==='+emailToInstructorList+'emailToInstructorList SIZE==='+emailToInstructorList.size());
            
            if( emailToInstructorList != NULL && emailToInstructorList.size() > 0 ) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToInstructorList);
            }
            
        }catch(Exception e) {
            
            String errorMessage = '';
            errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
            
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Weekly Time Entry Submission Reminder for Instructors');
        } 
    }
}