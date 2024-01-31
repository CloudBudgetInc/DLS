/***********************************************************************************
        - Send Email to the Students
        - Work Item : W-001120
        - An Email notification to Student for Daily Time Entry Approval Remainder (if overdue) 
        - Only Send if time entry has not yet been approved @ 10.00 am and @ 2.00 pm                    
        - This batch called from DailyRemainderToStudent_Schedule
        - HTML Body
        - Created by HL on Mar 07 2019
    *****************************************************************************************/

global class DailyTimeEntryRemainderToStudent implements Database.batchable<sObject>,Database.Stateful { 

    global List<Messaging.SingleEmailMessage> emailToStudentList;
    global Map<Id, Contact> conIdRec = new Map<Id, Contact>();
    global Map<Id, String> cardIdAndSupervisorCCEmail = new Map<Id, String>();
    global Map<Id, Id> allDayIdAndLeaderId = new Map<Id, Id>();
    
    global Database.QueryLocator start(Database.BatchableContext info){
    
        Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects', 'ESL_LT_Projects'};
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Date previousDate;
        if(todayVal.format('EEEE') == 'Monday'){
            previousDate = system.today().addDays(-3);
        }
        else{
            previousDate = system.today().addDays(-1);
        }
        
        String dayQry;
        
        //dayQry = 'SELECT Id, AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c FROM AcctSeed__Time_Card_Day__c WHERE Student_Approval_Status__c = \'Submitted\' AND Project_Task_Type__c != \'Preparation time\' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'Candidate\' AND AcctSeed__Date__c = :previousDate AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c != NULL AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName IN :projRTDevNames';
        
        dayQry = 'SELECT Id, AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c FROM AcctSeed__Time_Card_Day__c '
                    +'WHERE Student_Approval_Status__c = \'Submitted\' AND Project_Task_Type__c != \'Preparation time\' AND (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'Candidate\' '
                        +'OR (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'DLS_Employee\' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Active_DLS_Employee__c = TRUE)) '
                        +'AND AcctSeed__Date__c = :previousDate AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c != NULL AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName IN :projRTDevNames '
                        +'AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.No_Student_Approval__c = FALSE AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Active_DLS_Online_User__c = TRUE';
        
        System.debug('::::::::dayQry::::::::::'+dayQry);
        return Database.getQueryLocator(dayQry);
    }
    
    global void execute(Database.BatchableContext info, List<AcctSeed__Time_Card_Day__c> timeCardDays){
    
        Map<Id, List<AcctSeed__Time_Card_Day__c>> projIdAndDays = new Map<Id, List<AcctSeed__Time_Card_Day__c>>();
        Map<Id, String> projIdAndSupervisorEmail = new Map<Id, String>();
        
        if(timeCardDays.size() > 0){
        
            
            Set<String> positions = new Set<String>{'Project Manager', 'Manager', 'Supervisor'};
            Set<Id> dayIds = new Set<Id>();
            
            for(AcctSeed__Time_Card_Day__c day : timeCardDays){
            
                if(!projIdAndDays.containsKey(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c)){
                    projIdAndDays.put(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, new List<AcctSeed__Time_Card_Day__c>());
                }
                projIdAndDays.get(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c).add(day);
                dayIds.add(day.Id);
            }
            System.debug('dayIds ==========='+dayIds+'dayIds SIZE==========='+dayIds.size());
            
            Map<Id, Id> dayIdAndLeaderId = timeCardRelated_Email_Controller.getClassLeaderforTCD(dayIds,false);
            System.debug('dayIdAndLeaderId ========='+dayIdAndLeaderId );
            
            if(dayIdAndLeaderId != NULL && dayIdAndLeaderId.size() > 0){
            
                allDayIdAndLeaderId.putAll(dayIdAndLeaderId);
                                
                Map<Id, Contact> conRecMap = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :dayIdAndLeaderId.values() AND Email != NULL]);
                conIdRec.putAll(conRecMap);
            }
            System.debug('allDayIdAndLeaderId==========='+allDayIdAndLeaderId);
            System.debug('conIdRec========='+conIdRec);
            
            if(projIdAndDays.size() > 0){
            
                for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c, Candidate_Name__r.Email, Project__c FROM Contact_Assignments__c WHERE Project__c IN :projIdAndDays.keySet() AND RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' AND Assignment_Position__c IN :positions]){
                    if(ca.Candidate_Name__c != NULL && ca.Candidate_Name__r.Email != NULL){
                        projIdAndSupervisorEmail.put(ca.Project__c, ca.Candidate_Name__r.Email);
                    }
                }
                System.debug('projIdAndSupervisorEmail============'+projIdAndSupervisorEmail);
            
                for(Id projId : projIdAndDays.keySet()){
                
                    for(AcctSeed__Time_Card_Day__c  day : projIdAndDays.get(projId)){
                    
                        if(projIdAndSupervisorEmail.containsKey(projId)){
                            cardIdAndSupervisorCCEmail.put(day.Id, projIdAndSupervisorEmail.get(projId));
                        }
                    }
                }
                System.debug('cardIdAndSupervisorCCEmail============='+cardIdAndSupervisorCCEmail);
            }
        }
    }
    
    global void finish(Database.BatchableContext info){
    
        emailToStudentList = new List<Messaging.SingleEmailMessage>();
        
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
            
            Integer time1 = eveHandle.convertToMinutes('10:05 AM');
            Integer time2 = eveHandle.convertToMinutes('02:05 PM');
            
            if(conIdRec.size() > 0 && allDayIdAndLeaderId.size() > 0) {
            
                Map<Id, AcctSeed__Time_Card_Day__c> dayIdAndRec = new Map<Id, AcctSeed__Time_Card_Day__c>([
                    SELECT Id, AcctSeed__Date__c, Instructor_Name__c, DLS_Class__c, 
                        Time_Card_Period_Week_Range_Format__c, Total_Hours_Before_Approved__c, 
                        AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName,
                        AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, Start_Time1__c, End_Time1__c 
                    FROM AcctSeed__Time_Card_Day__c 
                    WHERE Id IN :allDayIdAndLeaderId.keySet()]);
                
                // Work Item : W-006419 - Add "No Student Approval" to the Event Edit Page
                Map<Id, Boolean> tcdIdAndNoStdApprovalFlag = timeCardRelated_Email_Controller.tcdIdAndNoStdApprovalFlag(allDayIdAndLeaderId.keySet());
                System.debug('::::tcdIdAndNoStdApprovalFlag::::::'+tcdIdAndNoStdApprovalFlag);
                
                String mailContent = '<html>Hi Chris and April,<br/>The following contacts have bounced email ids, Please correct them: <br/>';
                Boolean hasBouncedEmail = false;
                    
                for(Id dayId : allDayIdAndLeaderId.keySet()){
                    
                    if(tcdIdAndNoStdApprovalFlag != NULL && tcdIdAndNoStdApprovalFlag.containsKey(dayId) && !tcdIdAndNoStdApprovalFlag.get(dayId)){
                    
                        // Work Item : W-004360 - No email to student for 0 hours - non-DODA
                        if(dayIdAndRec.containsKey(dayId) && 
                            (dayIdAndRec.get(dayId).AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName == 'DODA_Projects' || 
                            (dayIdAndRec.get(dayId).AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName != 'DODA_Projects' && 
                            dayIdAndRec.get(dayId).Total_Hours_Before_Approved__c > 0))){
        
                            if(conIdRec.containsKey(allDayIdAndLeaderId.get(dayId))) {
                            
                                if(dayIdAndRec.containsKey(dayId) && !conIdRec.get(allDayIdAndLeaderId.get(dayId)).IsEmailBounced){
                                
                                    AcctSeed__Time_Card_Day__c dayRec = dayIdAndRec.get(dayId);
                                    Contact stdRec = conIdRec.get(allDayIdAndLeaderId.get(dayId));
                                    
                                    String s = '';
                                    String dayDate = '';
                                    
                                    if(dayRec.AcctSeed__Date__c != NULL){
                                        
                                        s = String.valueOf(dayRec.AcctSeed__Date__c);
                                        dayDate = s.split('-')[1]+'/'+s.split('-')[2]+'/'+s.split('-')[0];
                                    }
                                    
                                    String startTime1 = (String.isNotBlank(dayRec.Start_Time1__c) ? dayRec.Start_Time1__c : 'None');
                                    String endTime1 = (String.isNotBlank(dayRec.End_Time1__c) ? dayRec.End_Time1__c : 'None');
            
                                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                    if(orgWideEmailId != NULL) {
                                        mail.setOrgWideEmailAddressId(orgWideEmailId);
                                    }
                                    mail.setTargetObjectId(allDayIdAndLeaderId.get(dayId));
                                    mail.setWhatId(dayId);
                                    
                                    mail.subject = 'Reminder to approve time entered by '+ dayRec.Instructor_Name__c + ' for Date: '+ dayDate + ' for DLS Class #: ' +dayRec.DLS_Class__c;
                                    
                                    String weekRange = dayRec.Time_Card_Period_Week_Range_Format__c;
                                    String projId = dayRec.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
                                    String insId = dayRec.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
                                    String urlRedirectToStdPage = '<a href="'+ System.Label.Student_Community_Site_Prefix +'/s/time-approval?week='+ weekRange + '&projectId='+ projId + '&instructorId='+ insId + '" target="_blank"> Click Here </a>';
                                    
                                    String htmlBody = '';
                                    
                                    htmlBody += 'Hi '+ stdRec.Name + ', <br/><br/>'; 
                                    htmlBody += 'This is a request to review and approve or reject the time entry that your instructor recently submitted for your class on '+ dayDate + ' from ' + startTime1 +' to '+ endTime1;
                                    htmlBody += '. Please go to the Time Approval Page - '+ urlRedirectToStdPage +' to approve or reject this time.<br/><br/>';
                                    htmlBody += 'If you have any questions or require any assistance, please contact your LTS or reply to <a href="'+ 'mailto:timesheets@dlsdc.com' + '" target="_blank"> timesheets@dlsdc.com </a> to get help. <br/><br/>';
                                    htmlBody += 'Thank you,<br/><br/>DLS Accounting Department<br/>System Generated Email';
                                    
                                    if((currentTime >= time1 && currentTime < time2) || Test.isRunningTest()){
                                        mail.setHtmlBody(htmlBody);
                                    }else {
                                    
                                        mail.setHtmlBody(htmlBody);
                                        
                                        //W-004246 - to remove the cc address
                                        /*if(cardIdAndSupervisorCCEmail.containsKey(dayId)) {
                                            String ccadd = cardIdAndSupervisorCCEmail.get(dayId);
                                            mail.setCcAddresses(new List<String>{ccadd});
                                        }*/
                                    }                           
                                    mail.setSaveAsActivity(TRUE);
                                    
                                    emailToStudentList.add(mail);
                                }else {
                                
                                    mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(allDayIdAndLeaderId.get(dayId)).Id+'" target="_blank">'+conIdRec.get(allDayIdAndLeaderId.get(dayId)).Name+'</a><br/>';
                                    hasBouncedEmail = true;
                                }
                            }
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
                    emailToStudentList.add(bouncedmail);
                }
            }
            System.debug('emailToStudentList======'+emailToStudentList);
            
            if(emailToStudentList != NULL && emailToStudentList.size() > 0){
                Messaging.sendEmailResult[] results = Messaging.sendEmail(emailToStudentList);
            }
            
        }catch(Exception e) {
            
            String errorMessage = '';
            errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
            
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Daily Time Entry Reminder for Students');
        }
    }
}