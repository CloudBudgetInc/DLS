/***********************************************************************************
        - Send Email to the Instructors
        - Work Item : W-001111
        - An e-mail notification to the instructors who have not entered their time on daily basis 
        - This batch class runs daily basis and send an email on the next day from the date of actual time entry @ 08.00 am, @ 12:00 pm and @ 04:00 pm
        - Sent at last end time of the event for that date
        - This batch called from DailyRemainderToInstructor_Schedule 
        - HTML Body
        - Created by HL on Mar 05 2019 
    *****************************************************************************************/

global class DailyTimeEntryRemainderToInstructor implements Database.batchable<sObject>,Database.Stateful { 

    global List<Messaging.SingleEmailMessage> emailToInstructorList;    
    
    global Map<Id, Set<Id>> projIdAndInstructorIds = new Map<Id, Set<Id>>();
    global Map<String, Events__c> conIdProjIdAndEve = new Map<String, Events__c>();
    global Set<Id> contactIds = new Set<Id>();
    global Set<Id> projIds = new Set<Id>();
    
    global Database.QueryLocator start(Database.BatchableContext info){   
                
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> eventStatus = new Set<String>{'Scheduled', 'Completed'};
        
        Date previousDate;
        if(todayVal.format('EEEE') == 'Monday'){
            previousDate = system.today().addDays(-3);
        }
        else{
            previousDate = system.today().addDays(-1);
        }
        
        String  projectQry = '';
        
        if(todayVal.format('EEEE') != 'Saturday' && todayVal.format('EEEE') != 'Sunday' && !Test.isRunningTest()) {
             
             projectQry = 'SELECT Id FROM AcctSeed__Project__c WHERE Id IN (SELECT Project__c FROM Events__c WHERE Time_Card_Day__c = NULL AND Date__c = :previousDate AND Status__c IN :eventStatus AND Project__c != NULL AND Instructor__c != NULL AND Schedule__c != NULL AND Instructor__r.Active_DLS_Online_User__c = TRUE) '
                             +'AND Id IN (SELECT Project__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = \'Instructor\' AND Paper_Timesheet__c = FALSE)';
        
        }else if(Test.isRunningTest()){
            projectQry = 'SELECT Id FROM AcctSeed__Project__c WHERE Id IN (SELECT Project__c FROM Events__c WHERE Time_Card_Day__c = NULL AND Date__c = :previousDate AND Status__c IN :eventStatus AND Project__c != NULL AND Instructor__c != NULL AND Schedule__c != NULL) LIMIT 2';
        }
       
        System.debug('projectQry===='+projectQry);
        return Database.getQueryLocator(projectQry);
    }
    
    global void execute(Database.BatchableContext info, List<AcctSeed__Project__c > projects){
    
        System.debug('projects============='+projects+'projects SIZE======'+projects.size());
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Date previousDate;
        if(todayVal.format('EEEE') == 'Monday'){
            previousDate = system.today().addDays(-3);
        }else{
            previousDate = system.today().addDays(-1);
        }
        
        Set<String> eventStatus = new Set<String>{'Scheduled', 'Completed'};
        Map<String,Boolean> conIdProIdPaperTimesheetFlag = new Map<String,Boolean>();
        
        if(projects.size() > 0){
        
            //Check for the instructors whos paper timesheet flag is flase, then send reminder notification
            for(Contact_Assignments__c ca : [SELECT Id,Project__c,Candidate_Name__c,Paper_Timesheet__c FROM Contact_Assignments__c 
                                                    WHERE Project__c IN :projects AND RecordType.DeveloperName = 'Instructor' AND Paper_Timesheet__c = false]){
                
                String key = ca.Candidate_Name__c+'-'+ca.Project__c;
                if(!conIdProIdPaperTimesheetFlag.containsKey(key)){
                    conIdProIdPaperTimesheetFlag.put(key,ca.Paper_Timesheet__c);
                }
            }
        
            for(Events__c eve : [SELECT Id, Instructor__c, Project__c, End_Time__c, Project__r.DLS_Ref__c, Project__r.Students__c
                                    FROM Events__c 
                                    WHERE Time_Card_Day__c = NULL AND Date__c = :previousDate AND Status__c IN :eventStatus AND Project__c IN :projects AND Instructor__c != NULL AND 
                                        Instructor__r.RecordType.DeveloperName = 'Candidate'
            ]){
                String contIdProId = eve.Instructor__c+'-'+eve.Project__c;
                
                if(!conIdProjIdAndEve.containsKey(contIdProId) && conIdProIdPaperTimesheetFlag.containsKey(contIdProId) 
                    && !conIdProIdPaperTimesheetFlag.get(contIdProId)){
                    
                    conIdProjIdAndEve.put(contIdProId, eve);
                    contactIds.add(eve.Instructor__c);
                    projIds.add(eve.Project__c);
                }
            }
            System.debug('conIdProjIdAndEve======'+conIdProjIdAndEve+'conIdProjIdAndEve SIZE=========='+conIdProjIdAndEve.size());
            
            //check if the time card day have values for the same date with 0 hrs
            //if time is entered with 0 hrs then remove that key value pair
            for(AcctSeed__Time_Card_Day__c day : [SELECT Id,Name,AcctSeed__Date__c,Total_Hours_Before_Approved__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,
                                                            AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c 
                                                    FROM AcctSeed__Time_Card_Day__c 
                                                    WHERE AcctSeed__Date__c = :previousDate AND 
                                                        Id NOT IN (SELECT Time_Card_Day__c FROM  Events__c WHERE Date__c = :previousDate AND Status__c IN ('Scheduled','Completed'))]){
   
                String key = day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c+'-'+day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
                if(conIdProjIdAndEve.containsKey(key)){
                    conIdProjIdAndEve.remove(key);
                }
            }
            
            //Added on Jan 30 2020
            // Work Item : W-004821 - Instructor notified to enter time, with a late cancel entry 
            // To prevent send an email notification to Instructor if they havn't enter time for preparation hours for Late Cancellation
            for(AcctSeed__Time_Card_Day__c day : [SELECT Id,Name,AcctSeed__Date__c,Total_Hours_Before_Approved__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,
                                                            AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c 
                                                    FROM AcctSeed__Time_Card_Day__c 
                                                    WHERE AcctSeed__Date__c = :previousDate AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c IN : projIds AND
                                                        AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c = 'Language Training' AND Late_Cancellation__c = TRUE AND
                                                        Id IN (SELECT Time_Card_Day__c FROM  Events__c WHERE Date__c = :previousDate AND Status__c IN ('Scheduled','Completed'))]){
   
                String key = day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c+'-'+day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
                if(conIdProjIdAndEve.containsKey(key)){
                    conIdProjIdAndEve.remove(key);
                }
            }
        }
        System.debug('conIdProjIdAndEve======'+conIdProjIdAndEve+'conIdProjIdAndEve SIZE=========='+conIdProjIdAndEve.size());
        System.debug('contactIds============'+contactIds+'contactIds SIZE======='+contactIds.size()); 
        System.debug('projIds============'+projIds+'projIds SIZE======='+projIds.size()); 
    }
    
    global void finish(Database.BatchableContext info){
    
        emailToInstructorList = new List<Messaging.SingleEmailMessage>();
        try{
        
            List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
            
            String orgWideEmailId = '';
            
            if(orgWideEmail != null && orgWideEmail.size() > 0){
                orgWideEmailId = orgWideEmail[0].Id;
            }
            
            system.debug(':::::::orgWideEmailId:::::'+orgWideEmailId);
            
            EventHandler eveHandle = new EventHandler();
            
            DateTime currentDt = system.now();
            Integer currentTime = eveHandle.convertToMinutes(currentDt.format('h:mm a','America/New_York'));

            Integer time1 = eveHandle.convertToMinutes('08:00 AM');
            Integer time2 = eveHandle.convertToMinutes('12:00 PM');
            Integer time3 = eveHandle.convertToMinutes('04:00 PM');
            
            if(contactIds.size() > 0) {
                
                Date currentWeekStart = System.today().toStartofWeek().addDays(1);
                Date currentWeekEnd = currentWeekStart.addDays(6);
                
                String cwStartStr = String.valueOf(currentWeekStart);
                String cwEndStr = String.valueOf(currentWeekEnd);
                
                String stDate = cwStartStr.split('-')[1]+'/'+cwStartStr.split('-')[2]+'/'+cwStartStr.split('-')[0];
                String endDate = cwEndStr.split('-')[1]+'/'+cwEndStr.split('-')[2]+'/'+cwEndStr.split('-')[0];
                
                String tcpWKRangeFormat = stDate+' to '+endDate;
                System.debug(tcpWKRangeFormat);

                Set<String> positions = new Set<String>{'Project Manager', 'Manager', 'Supervisor'};
                Map<Id, String> projIdAndSupervisorEmail = new Map<Id, String>();
                
                Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :contactIds AND Email != NULL]);
                System.debug('conIdRec========='+conIdRec+'conIdRec SIZE========'+conIdRec.size());
                
                for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c, Candidate_Name__r.Email, Project__c FROM Contact_Assignments__c 
                                                    WHERE Project__c IN :projIds AND RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' AND Assignment_Position__c IN :positions]){
                    
                    if(ca.Candidate_Name__c != NULL && ca.Candidate_Name__r.Email != NULL){
                        projIdAndSupervisorEmail.put(ca.Project__c, ca.Candidate_Name__r.Email);
                    }
                }
                System.debug('projIdAndSupervisorEmail======'+projIdAndSupervisorEmail);
                
                DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
                Date previousDate;
                if(todayVal.format('EEEE') == 'Monday'){
                    previousDate = system.today().addDays(-3);
                }else{
                    previousDate = system.today().addDays(-1);
                }
        
                String yesDay = String.valueOf(previousDate);
                String yesterday = yesDay.split('-')[1]+'/'+yesDay.split('-')[2]+'/'+yesDay.split('-')[0];
                
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
                        
                            String projId = e.Project__c;
                            String urLRedirectToInsPage = '<a href="'+System.Label.Instructor_Community_Site_Prefix+'/s/instructor-time-entry?week='+ tcpWKRangeFormat + '&projectId='+ projId +'" target="_blank"> Click Here </a>';
                        
                            String htmlBody = '';
                            htmlBody += 'Hi '+ conIdRec.get(e.Instructor__c).Name + ', <br/><br/>';
                        
                            if((currentTime >= time1 && currentTime < time2 && currentTime < time3) || Test.isRunningTest()){    // 8.00 AM content
                                
                                mail.subject = 'DLS Timekeeping - Reminder to enter your time for '+ yesterday + ' for DLS Class #: '+ e.Project__r.DLS_Ref__c;
                                
                                htmlBody += 'This is a reminder to enter your time for the class: '+ e.Project__r.DLS_Ref__c +' scheduled for yesterday ' + yesterday + ' with the following student(s): '+ e.Project__r.Students__c + '<br/><br/>'; 
                                htmlBody += 'Please go to the Time Entry Page - '+ urLRedirectToInsPage +' to complete your time entry. If you did not have class, please enter 0.00 for this dateon your timesheet.<br/><br/>';
                            
                            
                            }
                            
                            if((currentTime >= time2 && currentTime < time3) || Test.isRunningTest()){    //12.00 PM content
                                
                                mail.subject = 'DLS Timekeeping - Your time entry is now due for '+ yesterday + ' for DLS Class #: '+ e.Project__r.DLS_Ref__c;
                                
                                htmlBody += 'This is a reminder to enter your time for the class: '+ e.Project__r.DLS_Ref__c +' scheduled for yesterday ' +     yesterday + ' with the following student(s): '+ e.Project__r.Students__c + '<br/><br/>'; 
                                htmlBody += 'Please go to the Time Entry Page - '+ urLRedirectToInsPage +' to complete your time entry. If you did not have class, please enter 0.00 for this date on your timesheet.  DLS Timekeeping Policy requires all employees to enter their time for the previous day by <b>12:00PM</b><br/><br/>';
                            
                            }
                            
                            if(currentTime >= time3 || Test.isRunningTest()){    // For 4.00 pm reminder content
                            
                                mail.subject = 'DLS Timekeeping - Your time entry is now overdue for '+ yesterday +' for DLS Class #: ' + e.Project__r.DLS_Ref__c;
                                
                                htmlBody += 'We are expecting a time entry for the class: '+ e.Project__r.DLS_Ref__c + ' scheduled for yesterday ' + yesterday + '. <br/> DLS Timekeeping Policy requires all employees to enter their time for the previous day by <b>12:00PM.</b><br/><br/>';
                                htmlBody += 'Please go to the Time Entry Page - '+urLRedirectToInsPage+' to complete your time entry as soon as possible. If you did not have class, please enter 0.00 for this date on your timesheet.<br/><br/>';
                                
                                htmlBody += 'It is important for DLS employees to enter time on a daily basis so that our company is in compliance with our contract regulations and can pay employees on-time and correctly. If you are having any difficulty entering your time using DLS Online, please contact your Language Training Supervisor or the DLS Online Support Team at <a href="mailto:support@dlsdc.com" target="_blank"> support@dlsdc.com </a> <br/><br/>';
                                
                                //W-004246 - to remove the cc address
                                /*if(projIdAndSupervisorEmail.containsKey(e.Project__c)) {
                                    String ccadd = projIdAndSupervisorEmail.get(e.Project__c);
                                    mail.setCcAddresses(new List<String>{ccadd});
                                }*/
                            }     
                            
                            htmlBody += '<br/>Thank you,<br/><br/><br/>DLS Accounting Department<br/>System Generated Email<br/>';
                            
                            mail.setHtmlBody(htmlBody);
                            mail.setSaveAsActivity(TRUE);
                            emailToInstructorList.add(mail);
                        }else {
                    
                            mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(e.Instructor__c).Id+'" target="_blank">'+conIdRec.get(e.Instructor__c).Name+'</a><br/>';
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
            
            if(emailToInstructorList != NULL && emailToInstructorList.size() > 0) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToInstructorList);
            }
        }catch(Exception e) {
            
            String errorMessage = '';
            errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
            
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Daily Time Entry Reminder for Instructors');  
            
        }
    } 
}