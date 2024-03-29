/****************
    - Added by HL on Apr 10 2020
    - Work Item : W-005036 - Online timekeeping for UAE Instructors
    - An email notification to the UAE Instructors who have not submitted their timesheet on weekly basis will be generated by Salesforce and send @ 01:00 PM GST on Sunday of each next week
    - Email Template : Dynamic HTML template
    - This scheduler runs on Gulf Standard Time
    - EST is 8 hours behind of GST, So this scheduler runs @ 05:00 AM EST
    - ***********This scheduler will runs on Sunday of every week (Start of the week)**************
    - Modified By HL on Feb 15, 2022 Work Item: W-007361 - Change Timekeeping Email Reminders for UAE Instructors
    - This scheduler will runs on Monday (Sunday modified into Monday)
    ******************/
    
public class WeeklyReminderToUAEInstructor implements Schedulable{

    public void execute(SchedulableContext sc) {
    
        Date currentWeekStart = System.today().toStartofWeek().addDays(1);
        
        Date previousStart = currentWeekStart.addDays(-7);
        Date previousEnd = previousStart.addDays(6);
        
        List<AcctSeed__Time_Card__c> timeCardRecs = new List<AcctSeed__Time_Card__c>();
        
        if(!Test.isRunningTest()){
        
            timeCardRecs = [SELECT Id, Intructor__c
                                FROM AcctSeed__Time_Card__c
                                WHERE of_Pending_Time_Logs__c != 0 AND Intructor__r.RecordType.DeveloperName = 'Candidate' AND Intructor__r.Active_DLS_Online_User__c = TRUE AND 
                                    Intructor__r.Email != null AND AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c = :previousStart AND 
                                    AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c = :previousEnd AND
                                    Id IN (SELECT AcctSeed__Time_Card__c FROM AcctSeed__Time_Card_Line__c WHERE AcctSeed__Project__r.RecordType.DeveloperName = 'EFL_Projects')];        
        }else if(Test.isRunningTest()){
        
            timeCardRecs = [SELECT Id, Intructor__c
                                FROM AcctSeed__Time_Card__c
                                WHERE of_Pending_Time_Logs__c != 0 AND Intructor__r.RecordType.DeveloperName = 'Candidate' AND Intructor__r.Active_DLS_Online_User__c = TRUE AND 
                                    Intructor__r.Email != null AND AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c = :previousStart AND 
                                    AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c = :previousEnd AND 
                                    Id IN (SELECT AcctSeed__Time_Card__c FROM AcctSeed__Time_Card_Line__c WHERE AcctSeed__Project__r.RecordType.DeveloperName = 'EFL_Projects') LIMIT 1];
        }
        System.debug('::::timeCardRecs:::::'+timeCardRecs);
        System.debug('::::timeCardRecs:::::'+timeCardRecs.size());
        
        if(timeCardRecs != NULL && timeCardRecs.size() > 0){
        
            Map<Id, Id> insIdAndTCId = new Map<Id, Id>();
            
            for(AcctSeed__Time_Card__c c : timeCardRecs){
            
                if(!insIdAndTCId.containsKey(c.Intructor__c)){
                
                    insIdAndTCId.put(c.Intructor__c, c.Id);
                }
            }
            System.debug('::::insIdAndTCId:::::'+insIdAndTCId);
            
            if(insIdAndTCId != NULL && insIdAndTCId.size() > 0){
            
                List<Messaging.SingleEmailMessage> sendEmailToInstructors = new List<Messaging.SingleEmailMessage>();
                            
                try{
                    
                    Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :insIdAndTCId.keySet() AND Email != NULL]);
                    System.debug('conIdRec========='+conIdRec+'conIdRec SIZE========'+conIdRec.size());
                        
                    System_Values__c sysVal = System_Values__c.getValues('Timesheet'); 
                    String orgWideEmailId = '';
                   
                    if(sysVal != null && sysVal.Value__c != null) {
                        orgWideEmailId = sysVal.Value__c;
                    }
                    
                    String preWkStStr = String.valueOf(previousStart);
                    String preWkEdStr = String.valueOf(previousEnd);
                    
                    String preWkStart = preWkStStr.split('-')[1]+'/'+preWkStStr.split('-')[2]+'/'+preWkStStr.split('-')[0];
                    String preWkEnd = preWkEdStr.split('-')[1]+'/'+preWkEdStr.split('-')[2]+'/'+preWkEdStr.split('-')[0];
                    
                    String nxtWkStStr = String.valueOf(currentWeekStart);
                    String nxtWkStart = nxtWkStStr.split('-')[1]+'/'+nxtWkStStr.split('-')[2]+'/'+nxtWkStStr.split('-')[0];
                    
                    String weekRange = preWkStart + ' to '+ preWkEnd;
                    String urlRedirectToInsPage = '<a href="'+ System.Label.Instructor_Community_Site_Prefix+'/s/time-submit?week='+ weekRange + '" target="_blank"> Review & Submit </a>';
                    
                    String mailContent = '<html>Hi Chris and April,<br/>The following contacts have bounced email ids, Please correct them: <br/>';
                    Boolean hasBouncedEmail = false;
                    
                    for(Id insId : insIdAndTCId.keySet()){
                    
                        if(conIdRec.containsKey(insId) && !conIdRec.get(insId).IsEmailBounced){
                        
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            
                            if(orgWideEmailId != null) {
                                mail.setOrgWideEmailAddressId(orgWideEmailId);
                            }
                            mail.setTargetObjectId(insId);
                            mail.setWhatId(insIdAndTCId.get(insId));
                            
                            mail.subject = 'Weekly Reminder for Timesheet Submission';
                            
                            String htmlBody = '';
                            htmlBody += 'Dear '+ conIdRec.get(insId).Name + ', <br/><br/>';
                            htmlBody += 'This is a reminder that your timesheet for last week '+  preWkStart + ' - ' + preWkEnd;
                            htmlBody += ' was due for submission on '+ nxtWkStart + ' @ 12:00 pm ET. Please, go to the '+ urlRedirectToInsPage;
                            htmlBody += ' to complete and submit your timesheet. For DLS to pay all instructors on time and accurately,';
                            htmlBody += ' we need for your entries to be on time and accurate.<br/><br/>';
                            htmlBody += 'If you have any questions regarding your timesheet in general please contact your supervisor.<br/><br/>';
                            htmlBody += 'Regards,<br/>Time Reporting System<br/>This e-mail was auto generated. Please do not respond.';
                            
                            mail.setHtmlBody(htmlBody);
                            mail.setSaveAsActivity(TRUE);
                            sendEmailToInstructors.add(mail);
                        }else{
                        
                            mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(insId).Id+'" target="_blank">'+conIdRec.get(insId).Name+'</a><br/>';
                            hasBouncedEmail = true;
                        }    
                    }
                    mailContent += '<br/><p>This e-mail was auto generated. Please do not respond.</p>';
                    mailContent += '</html>';
                    
                    if(hasBouncedEmail || Test.isRunningTest()) {
                    
                        //Added custome setting to hold the exception recipients email ids
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
                        sendEmailToInstructors.add(bouncedmail);
                    }
                    System.debug('::::::sendEmailToInstructors::::::::'+sendEmailToInstructors);
                    
                    if( sendEmailToInstructors != null && sendEmailToInstructors.size() > 0 ) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailToInstructors);
                    }
                }catch(Exception e) {
            
                    ErrorHandler errHandler = new ErrorHandler();
                    errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Weekly Reminder To UAE Instructor Email send');  
                } 
            }
        }
    }
}