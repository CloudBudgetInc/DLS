public class AttendanceTrigger_Handler{

    // To send an email notification to students when Immediately upon student hours save OR the Instructor edit the student hours
    public static void sendAnEmailToStudents(Map<Id, Attendance__c> attendanceIdAndRec, Set<Id> studentIds){
    
        if(attendanceIdAndRec != NULL && attendanceIdAndRec.size() > 0 && studentIds != NULL && studentIds.size() > 0){
            
            Map<Id, Attendance__c> attendanceRec = new Map<Id, Attendance__c>();
            Set<Date> attendaceDates = new Set<Date>();
            Set<Date> pdoDates = new Set<Date>();
            Set<Id> tcdIds = new Set<Id>();
            
            for(Attendance__c a : [SELECT Id, Student__c, Late_Cancellation__c, Date__c, Project_RecordType_Name__c, Time_Card_Day__c
                FROM Attendance__c 
                WHERE Id IN :attendanceIdAndRec.keySet() AND Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.No_Student_Approval__c = FALSE
                    AND Date__c != NULL
            ]){
                
                attendanceRec.put(a.Id, a);
                attendaceDates.add(a.Date__c);
                tcdIds.add(a.Time_Card_Day__c);
            }
            
            // Added for Work Item : W-003066 - Create DLI-W Planned Days Off records automatically for all Active DLI-W LT Projects
            for(Planned_Days_Off__c p : [SELECT Id, Date__c 
                FROM Planned_Days_Off__c
                WHERE RecordType.DeveloperName = 'DLI_W_LT_Training_Holidays' AND Project__c = NULL AND Contact__c = NULL
                    AND Opportunity__c = NULL AND Date__c IN : attendaceDates AND Type__c = 'DLI-W LT'
            ]){
                pdoDates.add(p.Date__c);
            }
            
            // Work Item : W-006419 - Add "No Student Approval" to the Event Edit Page
            Map<Id, Boolean> tcdIdAndNoStdApprovalFlag = timeCardRelated_Email_Controller.tcdIdAndNoStdApprovalFlag(tcdIds);
            System.debug('::::tcdIdAndNoStdApprovalFlag::::::'+tcdIdAndNoStdApprovalFlag);
            
            List<Messaging.SingleEmailMessage> emailToStudentList = new List<Messaging.SingleEmailMessage>();
            
            try{
                
                EmailTemplate template;
                
                if(Trigger.isInsert){
                    template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Student_Notification_Template'];
                }
                if(Trigger.isUpdate){
                    template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Student_Hours_Revised_Notification'];
                }
                System.debug('template==='+template) ;
                
                List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
        
                String orgWideEmailId = '';
                
                if(orgWideEmail != null && orgWideEmail.size() > 0){
                    orgWideEmailId = orgWideEmail[0].Id;
                }
                
                if(template != NULL){
                
                    Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :studentIds AND Id IN (SELECT Candidate_Name__c FROM Contact_Assignments__c WHERE Time_Approval_Preference__c = 'Daily')]);
                    System.debug('conIdRec::::'+conIdRec);
                    String mailContent = '<html>Hi Chris, April and Nafisa <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                    Boolean hasBouncedEmail = false;    
                    
                    for(Id aId : attendanceRec.keySet()){
                    
                        if(tcdIdAndNoStdApprovalFlag != NULL && tcdIdAndNoStdApprovalFlag.containsKey(attendanceRec.get(aId).Time_Card_Day__c) && 
                            !tcdIdAndNoStdApprovalFlag.get(attendanceRec.get(aId).Time_Card_Day__c)){
                        
                            if(attendanceRec.get(aId).Project_RecordType_Name__c != 'DLI_W_LT_Projects' || (attendanceRec.get(aId).Project_RecordType_Name__c == 'DLI_W_LT_Projects' && (!pdoDates.contains(attendanceRec.get(aId).Date__c) || (pdoDates.contains(attendanceRec.get(aId).Date__c) && attendanceRec.get(aId).Late_Cancellation__c == FALSE)))){
                        
                                if(conIdRec.containsKey(attendanceRec.get(aId).Student__c)){
                                
                                    if(!conIdRec.get(attendanceRec.get(aId).Student__c).IsEmailBounced){
                                    
                                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                        if(orgWideEmailId != NULL) {
                                        mail.setOrgWideEmailAddressId(orgWideEmailId);
                                        }
                                        mail.setTargetObjectId(attendanceRec.get(aId).Student__c);
                                        mail.setWhatId(aId);
                                        
                                        mail.setSaveAsActivity(TRUE);
                                        mail.setTemplateID(template.Id);
                                        emailToStudentList.add(mail);
                                    }else {
                                    
                                        mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(attendanceRec.get(aId).Student__c).Id+'" target="_blank">'+conIdRec.get(attendanceRec.get(aId).Student__c).Name+'</a><br/>';
                                        hasBouncedEmail = true;
                                    }
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
                        emailToStudentList.add(bouncedmail);
                    }
                }
                System.debug('emailToStudentList===='+emailToStudentList);
        
                if( emailToStudentList != NULL && emailToStudentList.size() > 0 ) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToStudentList);
                }
            }catch(Exception e) {
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Student Hours Approval Request for Students');
            } 
        }
    }
    
    // To send an email notification to instructor when student rejects their student hours
    public static void sendAnEmailToInstructors(Map<Id, Attendance__c> attendanceIdAndRec, Set<Id> instructorIds){
    
        if(attendanceIdAndRec != NULL && attendanceIdAndRec.size() > 0 && instructorIds != NULL && instructorIds.size() > 0){
            
            Map<Id, Attendance__c> attendanceRec = new Map<Id, Attendance__c>([SELECT Id, Time_Card_Day__r.AcctSeed__Date__c, DLS_Class__c, Instructor_Name__c, Student_Name__c, Time_Card_Period_Week_Range_Format__c, Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, Instructor__c, Rejection_Reason__c FROM Attendance__c WHERE Id IN :attendanceIdAndRec.keySet() AND Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.No_Student_Approval__c = FALSE]);
            List<Messaging.SingleEmailMessage> emailToInstructors = new List<Messaging.SingleEmailMessage>();
            
            
            try{
                
                List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
        
                String orgWideEmailId = '';
                
                if(orgWideEmail != NULL && orgWideEmail.size() > 0){
                    orgWideEmailId = orgWideEmail[0].Id;
                }
                
                if(attendanceRec.size() > 0){
                
                    Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced, RecordType.DeveloperName FROM Contact WHERE Id IN :instructorIds AND Id IN (SELECT Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Paper_Timesheet__c = FALSE)]);
            
                    String mailContent = '<html>Hi Chris, April and Nafisa <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                    Boolean hasBouncedEmail = false;    
                    
                    for(Id aId: attendanceRec.keySet()){
                    
                         if(conIdRec.containsKey(attendanceRec.get(aId).Instructor__c)){
                         
                             if(conIdRec.get(attendanceRec.get(aId).Instructor__c).Email == NULL || !conIdRec.get(attendanceRec.get(aId).Instructor__c).IsEmailBounced){
                    
                                String s = String.valueOf(attendanceRec.get(aId).Time_Card_Day__r.AcctSeed__Date__c);
                                String tcdDate = s.split('-')[1]+'/'+s.split('-')[2]+'/'+s.split('-')[0];
                                
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                if(orgWideEmailId != NULL) {
                                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                                }
                                mail.setTargetObjectId(attendanceRec.get(aId).Instructor__c);
                                mail.setWhatId(aId);                              
                                mail.setSaveAsActivity(TRUE);
                                
                                String weekRange = attendanceRec.get(aId).Time_Card_Period_Week_Range_Format__c;
                                String projId = attendanceRec.get(aId).Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
                                
                                String urlRedirectToInsPage = '';
                        
                                if(conIdRec.get(attendanceRec.get(aId).Instructor__c).RecordType.DeveloperName == 'Candidate'){
                                    urlRedirectToInsPage = '<a href="'+ System.Label.Instructor_Community_Site_Prefix + '/s/instructor-time-entry?week=' + weekRange + '&projectId='+ projId + '" target="_blank"> Click Here </a>';
                                }
                                
                                if(conIdRec.get(attendanceRec.get(aId).Instructor__c).RecordType.DeveloperName == 'DLS_Employee'){
                                    urlRedirectToInsPage = '<a href="'+ System.Label.Org_Prefix_Start_URL+'/lightning/n/'+ System.Label.Internal_Instructor_Time_Entry+'?c__week='+ weekRange + '&c__projectId='+ projId + '" target="_blank"> Click Here </a>';
                                }
                        
                                mail.subject = 'DLS Timekeeping – A student has rejected your time entry for their student hours for '+ tcdDate + ' for '+ attendanceRec.get(aId).DLS_Class__c;
                                
                                String htmlBody = '';
                                htmlBody += 'Hi '+ attendanceRec.get(aId).Instructor_Name__c + ', <br/><br/>';
                                htmlBody += 'Student '+ attendanceRec.get(aId).Student_Name__c + ' rejected the time entry you recorded for '+tcdDate;
                                htmlBody += ' for DLS Class #: '+ attendanceRec.get(aId).DLS_Class__c + ' for their student hours. ';
                                htmlBody += 'Please go to the Time Entry Page - ' + urlRedirectToInsPage + ' to correct your time entry. <br/><br/>';
                                // Added on June 23 2023 - W-007819 : Request to Grant Instructors Visibility to Student Time Entry "Rejection Reason"
                                htmlBody += 'Rejection Reason: ' + attendanceRec.get(aId).Rejection_Reason__c;
                                htmlBody += '<br/><br/>If you have any questions, please contact your supervisor or reply to - <a href="mailto:timesheets@dlsdc.com" target="_blank"> timesheets@dlsdc.com </a><br/><br/>';
                                htmlBody += 'Thank you,<br/><br/>DLS Accounting Department<br/>System Generated Email<br/>'; 
                                
                                mail.setHtmlBody(htmlBody);
                                emailToInstructors.add(mail);
                            }else {
                            
                                mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(attendanceRec.get(aId).Instructor__c).Id+'" target="_blank">'+conIdRec.get(attendanceRec.get(aId).Instructor__c).Name+'</a><br/>';
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
                        bouncedmail.setSubject('Bounced/Empty email contact information');
                        bouncedmail.sethtmlBody(mailContent);
                        emailToInstructors.add(bouncedmail);
                    }
                }
                System.debug('emailToInstructors===='+emailToInstructors);
        
                if( emailToInstructors != NULL && emailToInstructors.size() > 0 ) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToInstructors);
                }
            }catch(Exception e) {
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Student Hours Rejection Notification for Instructors'); 
            } 
        }
    }
    
    public static void populateRelatedCA(List<Attendance__c> newAttendanceList){
        Set<Id> timeCardDayIds = new Set<Id>();
        Set<Id> studentIds = new Set<Id>();
        
        for(Attendance__c att : newAttendanceList){
            if(att.Student__c != null){
                timeCardDayIds.add(att.Time_Card_Day__c);
                studentIds.add(att.Student__c);
            }
        }
        
        Map<Id, Id> timeCardDayIdWithProjectIdMap = new Map<Id, Id>();
        for(AcctSeed__Time_Card_Day__c tcd : [SELECT Id, AcctSeed__Time_Card_Line__r.AcctSeed__Project__c 
                                              FROM AcctSeed__Time_Card_Day__c 
                                              WHERE Id IN :timeCardDayIds]){
                                              
            timeCardDayIdWithProjectIdMap.put(tcd.Id, tcd.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c);                                          
        }
        
        Map<String, Id> studentIdAndProjIdWithCAIdMap = new Map<String, Id>();
        for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c, Project__c
                                         FROM Contact_Assignments__c
                                         WHERE Candidate_Name__c IN :studentIds AND Project__c IN :timeCardDayIdWithProjectIdMap.values()]){
            
            studentIdAndProjIdWithCAIdMap.put(ca.Candidate_Name__c+'~'+ca.Project__c, ca.Id);    
        }
        
        for(Attendance__c att : newAttendanceList){
        
            Id projId = timeCardDayIdWithProjectIdMap.get(att.Time_Card_Day__c);
            
            if(att.Student__c != null && projId != null && studentIdAndProjIdWithCAIdMap.get(att.Student__c+'~'+projId) != null){
                att.Contact_Assignment__c = studentIdAndProjIdWithCAIdMap.get(att.Student__c+'~'+projId);
            }
        }
    }
}