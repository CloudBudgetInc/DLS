/****************
    - Added by HL on Apr 10 2020
    - Work Item : W-005036 - Online timekeeping for UAE Instructors
    - Email reminder to send on Thursday(If there is no time entry for the current week) of every week @ 08:00 AM GST
    - Email Template : Dynamic HTML template
    - This scheduler runs on Gulf Standard Time
    - EST is 8 hours behind of GST, So this scheduler runs @ 12:00 AM EST
    - ************This scheduler will runs on Thursday of every week (End of the week)*********
    - Modified By HL on Feb 15, 2022 Work Item: W-007361 - Change Timekeeping Email Reminders for UAE Instructors
    - This scheduler will runs on Friday (Thursday modified into Friday)
    ******************/
    
public class WeeklyRequestToUAEInstructor implements Schedulable{

    public void execute(SchedulableContext sc) {
    
        List<Contact> contacts = new List<Contact>();
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        if(!Test.isRunningTest()){
        
            contacts = [SELECT Id, Name, Email, IsEmailBounced 
                            FROM Contact 
                            WHERE RecordType.DeveloperName = 'Candidate' AND Active_DLS_Online_User__c = TRUE AND Email != NULL AND 
                                Id IN (SELECT ContactId FROM User WHERE IsActive = TRUE AND IsPortalEnabled = TRUE)];    
        }else if(Test.isrunningTest()){
        
            contacts = [SELECT Id, Name, Email, IsEmailBounced 
                            FROM Contact 
                            WHERE RecordType.DeveloperName = 'Candidate' AND Active_DLS_Online_User__c = TRUE AND Email != NULL AND 
                                Id IN (SELECT ContactId FROM User WHERE IsActive = TRUE AND IsPortalEnabled = TRUE) LIMIT 1];
        } 
        System.debug('::::contacts::::'+contacts);
        System.debug('::::contacts::::'+contacts.size());
        
        if(contacts != NULL && contacts.size() > 0){
        
            Set<Id> allConIds = new Set<Id>();
            Map<Id, Contact> conIdRec = new Map<Id, Contact>();
            
            Map<Id,Boolean> conIdactiveFlagMap = new Map<Id,Boolean>();
            Map<Id,Boolean> contactIdIncludeForEmailMap =  new Map<Id,Boolean>();
            
            Map<Id,String> conIdSupervisorEmailMap = new Map<Id,String>();
            Set<Id> filteredConIds = new Set<Id>();
            Map<Id, Id> insIdAndTCId = new Map<Id, Id>();
            
            Map<String, Id> insIdProjIdAndProjId = new Map<String, Id>();
            Set<Id> insIds = new Set<Id>();
            Date previousDate = System.today();    // To avoid null pointer exception set initial value
            
            if(todayVal.format('EEEE') == 'Friday') {    // Thursday modified into Friday : Modified By HL on Feb 15, 2022
                previousDate = System.today();
            }else if(Test.isRunningTest()) {
                previousDate = system.today();
            }
            
            Date weekStDate = previousDate.toStartofWeek()+1;
            Date weekEdDate = weekstdate.addDays(6);
            
            for(Contact con : contacts) {
            
                allConIds.add(con.Id);
                conIdRec.put(con.Id,con);  
            }
            
            // Quried Contact Assignment to get active dls staff contact for Community mail sending
            
            for(Contact_Assignments__c conAss : [SELECT Id, Name, Candidate_Name__c, Project__c
                                                    FROM Contact_Assignments__c 
                                                    WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' 
                                                        AND Candidate_Name__c IN : allConIds AND Project__r.RecordType.DeveloperName = 'EFL_Projects']) {
                
                if(!conIdactiveFlagMap.containsKey(conAss.Candidate_Name__c))
                    conIdactiveFlagMap.put(conAss.Candidate_Name__c,true);
                    
                String insIdAndProjId = conAss.Candidate_Name__c+'-'+conAss.Project__c;
                if(!insIdProjIdAndProjId.containsKey(insIdAndProjId)){
                    insIdProjIdAndProjId.put(insIdAndProjId, conAss.Project__c);
                }
            }
            System.debug('::::conIdactiveFlagMap::::'+conIdactiveFlagMap);
            
            for(AcctSeed__Time_Card__c c : [SELECT Id, Name, Intructor__c, Intructor__r.Supervisor_Name__r.Email, of_Pending_Time_Logs__c, of_Submitted_Hours__c, of_Approved_Hours__c
                                                FROM AcctSeed__Time_Card__c 
                                                WHERE AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c >= :weekStDate AND AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c <= :weekEdDate
                                                    AND Intructor__c IN :allConIds]) {
                            
                if(c.of_Pending_Time_Logs__c == 0 && c.of_Submitted_Hours__c == 0 && 
                    c.of_Approved_Hours__c == 0) {
                    
                    if(!contactIdIncludeForEmailMap.containsKey(c.Intructor__c)) {
                        contactIdIncludeForEmailMap.put(c.Intructor__c,true);
                        insIdAndTCId.put(c.Intructor__c, c.Id);
                    } 
                }
                
                if(!conIdSupervisorEmailMap.containsKey(c.Intructor__c)){
                    conIdSupervisorEmailMap.put(c.Intructor__c,c.Intructor__r.Supervisor_Name__r.Email);
                } 
            }
            System.debug('::::contactIdIncludeForEmailMap:::::'+contactIdIncludeForEmailMap);
            
            for(String s : insIdProjIdAndProjId.keySet()){
            
                Id insId = s.split('-')[0];
                
                if(contactIdIncludeForEmailMap.containsKey(insId)){
                    if(contactIdIncludeForEmailMap.get(insId) && conIdactiveFlagMap.containsKey(insId)){
                        filteredConIds.add(insId);
                    }
                }else{
                    filteredConIds.add(insId);
                }
            }
            system.debug(':::::::filteredConIds:::::'+filteredConIds);
            system.debug(':::::::filteredConIds:::::'+filteredConIds.size());
            
            if(filteredConIds != NULL && filteredConIds.size() > 0){
            
                List<Messaging.SingleEmailMessage> sendEmailToInstructors = new List<Messaging.SingleEmailMessage>();
                
                try{
                    
                    System_Values__c sysVal = System_Values__c.getValues('Timesheet'); 
                    String orgWideEmailId = '';
                   
                    if(sysVal != null && sysVal.Value__c != null) {
                        orgWideEmailId = sysVal.Value__c;
                    }
                    
                    String curWkStStr = String.valueOf(weekStDate);
                    String curWkEdStr = String.valueOf(weekEdDate);
                    
                    String curWkStart = curWkStStr.split('-')[1]+'/'+curWkStStr.split('-')[2]+'/'+curWkStStr.split('-')[0];
                    String curWkEnd = curWkEdStr.split('-')[1]+'/'+curWkEdStr.split('-')[2]+'/'+curWkEdStr.split('-')[0];
                    
                    String weekRange = curWkStart + ' to '+ curWkEnd;
                    
                    String mailContent = '<html>Hi Chris and April,<br/>The following contacts have bounced email ids, Please correct them: <br/>';
                    Boolean hasBouncedEmail = false;
                    
                    for(String s : insIdProjIdAndProjId.keySet()){
                        
                        Id insId = s.split('-')[0];
                        Id projId = s.split('-')[1];
                        
                        if(filteredConIds.contains(insId)){
                        
                            if(conIdRec.containsKey(insId) && !conIdRec.get(insId).IsEmailBounced){
                            
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                
                                if(orgWideEmailId != null) {
                                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                                }
                                mail.setTargetObjectId(insId);
                                mail.setWhatId(insIdAndTCId.get(insId));
                                
                                String urLRedirectToInsPage = '<a href="'+System.Label.Instructor_Community_Site_Prefix+'/s/instructor-time-entry?week='+ weekRange + '&projectId='+ projId +'" target="_blank"> Click Here </a>';
                                
                                mail.subject = 'Weekly Reminder for Time Entry';
                                
                                String htmlBody = '';
                                htmlBody += 'Dear '+ conIdRec.get(insId).Name + ', <br/><br/>';
                                htmlBody += 'If you worked any hours during the current week, please remember to save and submit your time using the Instructor Time Entry page.<br/><br/>';
                                htmlBody += 'You can access this page using the following link: '+ urlRedirectToInsPage +'<br/><br/>';
                                htmlBody += 'Thank you,<br/>DLS Timekeeping System<br/>This e-mail was auto generated. Please do not respond.';
                                mail.setHtmlBody(htmlBody);
                                
                                /*
                                    if(conIdSupervisorEmailMap.containsKey(insId)) {
                                        String ccadd = conIdSupervisorEmailMap.get(insId);
                                        mail.setCcAddresses(new List<String>{ccadd});
                                    }
                                */
                                mail.setSaveAsActivity(TRUE);
                                sendEmailToInstructors.add(mail);
                            }else{
                            
                                mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(insId).Id+'" target="_blank">'+conIdRec.get(insId).Name+'</a><br/>';
                                hasBouncedEmail = true;
                            }   
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
                    errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Weekly Request Email To UAE Instructor');  
                }    
            }
        }
    }
}