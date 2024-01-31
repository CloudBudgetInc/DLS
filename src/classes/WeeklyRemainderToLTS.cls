/***********************************************************************************
        - Send Email to the LTS
        - Work Item : W-001121
        - An Email notification to LTS for Weekly Timesheet Approval Remainder with link to LTS Timesheet Approval Page
        - This batch class runs weekly basis and Send @ 12:00PM on Monday 
        - This batch called from WeeklyRemainderToLTS_Schedule class
        - Html Email Body
        - Created by HL on Mar 18 2019
    *****************************************************************************************/
    
global class WeeklyRemainderToLTS implements Database.batchable<sObject>,Database.Stateful { 

    global List<Messaging.SingleEmailMessage> emailToSupervisorList;
    global Map<String, Decimal> projIdConIdAndSumofDuration = new Map<String, Decimal>();
    global Map<String, Decimal> projIdConIdAndSumofHrsApproved = new Map<String, Decimal>();
    global Map<Id, List<Contact_Assignments__c>> projIdAndInstructors = new Map<Id, List<Contact_Assignments__c>>();
    global Map<Id, Contact> conIdAndRec = new Map<Id, Contact>();
    global Map<Id, Set<Id>> supvsrIdAndProjIds = new Map<Id, Set<Id>>();
    global Set<Id> supvsrIds = new Set<Id>();
    
    global Database.QueryLocator start(Database.BatchableContext info){
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Set<String> conRTNames = new Set<String>{'DLS_Employee'};
        
        String  contactQry = '';   
                                     
        if(todayVal.format('EEEE') != 'Saturday' && !Test.isRunningTest()) {
             //contactQry = 'SELECT Id, Name, IsEmailBounced, Email FROM Contact WHERE RecordType.DeveloperName IN :conRTNames AND Email != NULL';
             contactQry = 'SELECT Id, Name, IsEmailBounced, Email FROM Contact WHERE RecordType.DeveloperName IN :conRTNames AND Email != NULL';
        
        }else if(Test.isRunningTest()){
            contactQry = 'SELECT Id, Name, IsEmailBounced, Email FROM Contact WHERE RecordType.DeveloperName IN :conRTNames AND Email != NULL LIMIT 1';
        }    
        
        return Database.getQueryLocator(contactQry);
    }
    
    global void execute(Database.BatchableContext info, List<Contact> contacts){
    
        Set<String> positions = new Set<String>{'Project Manager', 'Manager', 'Supervisor'};
        Set<String> langProjRTNames = new Set<String>{'Language_Training_Projects', 'DLI_W_LT_Projects', 'DODA_Projects', 'EFL_Projects', 'Linguist_Support_Projects', 'Testing_Projects', 'Translation_Projects', 'Interpretation_Projects'};
        Set<String> otherProjRTNames = new Set<String>{'CD_Projects', 'Admin_Projects'};
        Set<Id> conIds = new Set<Id>();
        Set<Id> instructorProjs = new Set<Id>();
        Set<Id> supervisorProjs = new Set<Id>();
        
        Date currentWeekStart = system.today().toStartofWeek().addDays(1);
        
        Date previouswkStart = currentWeekStart.addDays(-7);
        Date previouswkEnd = previouswkStart.addDays(6);
        System.debug('contacts=========='+contacts);
        
        Set<Id> icjProjIds = new Set<Id>();
        Set<Id> icjConIds = new Set<Id>();
        
        Map<Id, Id> conIdUserId = new Map<Id, Id>();
        List<Contact> insContacts = new List<Contact>();
        Set<String> caRTNames = new Set<String>{'Staff', 'Instructor'};
        
        if(contacts.size() > 0){
        
            for(Contact c  : contacts){
                conIds.add(c.Id);
                conIdAndRec.put(c.Id, c);
            }
            System.debug('conIds=========='+conIds);
            
            if(conIds.size() > 0){
            
            //Project's most recent Active LTS Contact Assignment Contact / Project Manager
                for(AcctSeed__Project__c proj : [
                    SELECT Id,
                        (
                            SELECT Id, Candidate_Name__c, Candidate_Name__r.Email, Candidate_Name__r.IsEmailBounced, Project__c  
                            FROM Contact_Assignments__r 
                            WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' AND Assignment_Position__c IN :positions ORDER BY CreatedDate DESC LIMIT 1
                        ) 
                    FROM AcctSeed__Project__c 
                    WHERE Id IN (SELECT Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c IN :conIds AND Status__c = 'Active' AND RecordType.DeveloperName = 'Staff')
                        AND RecordType.DeveloperName IN :langProjRTNames
                ]){
                
                    if(proj.Contact_Assignments__r.size() > 0){
                    
                        Contact_Assignments__c ca = proj.Contact_Assignments__r[0];
                        if(ca.Candidate_Name__c  != NULL && conIds.contains(ca.Candidate_Name__c )){
                        
                            supervisorProjs.add(proj.Id);
                            if(!supvsrIdAndProjIds.containsKey(ca.Candidate_Name__c)){
                                supvsrIdAndProjIds.put(ca.Candidate_Name__c, new Set<Id>());
                            }
                            supvsrIdAndProjIds.get(ca.Candidate_Name__c).add(proj.Id);
                            supvsrIds.add(ca.Candidate_Name__c);
                        }
                    }
                }
                System.debug('supervisorProjs==========='+supervisorProjs);
                    
                // Find the LTS(Supervisors) related to user Ids
                conIdUserId = PlannedDaysOffHandler.getContactRelatedUsers(conIds); 
                System.debug('conIdUserId ============='+conIdUserId );
            }
            
            if(conIdUserId != NULL && conIdUserId.size() > 0){
                // Get the instructors under the supervisor's user
                insContacts = [SELECT Id FROM Contact WHERE Supervisor_Name__c IN :conIdUserId .values()];
            }
            System.debug('insContacts ============'+insContacts);
            
            if(insContacts.size() > 0){
            
                // Find the Instructor/Staff CA, to get project Ids
                for(Contact_Assignments__c ca : [
                    SELECT Id, Project__c, Candidate_Name__c 
                    FROM Contact_Assignments__c 
                    WHERE Candidate_Name__c IN :insContacts AND Project__c != NULL AND Project__r.RecordType.DeveloperName IN :otherProjRTNames AND Status__c = 'Active'
                        AND RecordType.DeveloperName IN :caRTNames
                ]){
                
                    icjProjIds.add(ca.Project__c);
                    icjConIds.add(ca.Candidate_Name__c);
                }
            }
            System.debug('icjProjIds========='+icjProjIds);
            System.debug('icjConIds========='+icjConIds);
                
            if(supervisorProjs.size() > 0 || (icjProjIds.size() > 0 && icjConIds.size() > 0)){
                
                Set<Id> instructorIds = new Set<Id>();
                
                // Find the active instructors who having pending time logs 
                if(supervisorProjs.size() > 0){
                     
                    for(Contact_Assignments__c ca : [
                        SELECT Id, Project__c, Candidate_Name__c,  Project__r.Name, Candidate_Name__r.Name
                        FROM Contact_Assignments__c 
                        WHERE Candidate_Name__c IN (SELECT Intructor__c FROM AcctSeed__Time_Card__c WHERE of_Pending_Time_Logs__c != 0 AND of_Submitted_Hours__c = 0)
                            AND Project__c IN :supervisorProjs AND RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Paper_Timesheet__c = FALSE
                            ORDER BY Candidate_Name__r.Name ASC 
                    ]){
                    
                        if(!projIdAndInstructors.containsKey(ca.Project__c)){
                            projIdAndInstructors.put(ca.Project__c, new List<Contact_Assignments__c>()); 
                        }
                        projIdAndInstructors.get(ca.Project__c).add(ca);
                        instructorIds.add(ca.Candidate_Name__c);
                        instructorProjs.add(ca.Project__c);
                    }
                    System.debug('projIdAndInstructors============='+projIdAndInstructors);
                    System.debug('instructorIds============='+instructorIds);
                }
                
                if(icjProjIds.size() > 0 && icjConIds.size() > 0){
                
                    for(Contact_Assignments__c ca : [
                        SELECT Id, Project__c, Candidate_Name__c,  Project__r.Name, Candidate_Name__r.Name
                        FROM Contact_Assignments__c 
                        WHERE Candidate_Name__c IN (SELECT Intructor__c FROM AcctSeed__Time_Card__c WHERE of_Pending_Time_Logs__c != 0 AND of_Submitted_Hours__c = 0 AND Intructor__c IN :icjConIds)
                            AND Project__c IN :icjProjIds AND RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active' AND Paper_Timesheet__c = FALSE
                            ORDER BY Candidate_Name__r.Name ASC 
                    ]){
                    
                        if(!projIdAndInstructors.containsKey(ca.Project__c)){
                            projIdAndInstructors.put(ca.Project__c, new List<Contact_Assignments__c>()); 
                        }
                        projIdAndInstructors.get(ca.Project__c).add(ca);
                        instructorIds.add(ca.Candidate_Name__c);
                        instructorProjs.add(ca.Project__c);
                    }
                    System.debug('projIdAndInstructors============='+projIdAndInstructors);
                    System.debug('instructorIds============='+instructorIds);
                    
                    for(AcctSeed__Project__c proj : [
                        SELECT Id,
                            (
                                SELECT Id, Candidate_Name__c 
                                FROM Contact_Assignments__r 
                                WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' AND Assignment_Position__c IN :positions ORDER BY CreatedDate DESC LIMIT 1
                            ) 
                        FROM AcctSeed__Project__c 
                        WHERE Id IN : icjProjIds
                    ]){
            
                        if(proj.Contact_Assignments__r.size() > 0){
                        
                            Contact_Assignments__c ca = proj.Contact_Assignments__r[0];
                            if(ca.Candidate_Name__c  != NULL && conIds.contains(ca.Candidate_Name__c )){
                            
                                if(!supvsrIdAndProjIds.containsKey(ca.Candidate_Name__c)){
                                    supvsrIdAndProjIds.put(ca.Candidate_Name__c, new Set<Id>());
                                }
                                supvsrIdAndProjIds.get(ca.Candidate_Name__c).add(proj.Id);
                                supvsrIds.add(ca.Candidate_Name__c);
                            }
                        }
                    }
                    
                }
                
                // Find sum of duration and sum of hours before approved
                if(projIdAndInstructors.size() > 0 && instructorProjs.size() > 0 && instructorIds.size() > 0){     
                
                    for(AggregateResult arEve : [
                        SELECT Project__c, Instructor__c, SUM(Duration__c)dur
                        FROM Events__c 
                        WHERE Date__c >= :previouswkStart AND Date__c <= :previouswkEnd AND Project__c IN :instructorProjs AND Instructor__c IN :instructorIds AND Status__c != 'Canceled'
                          GROUP BY Project__c, Instructor__c
                    ]){
                    
                        String projIdConId = arEve.get('Project__c')+'+'+arEve.get('Instructor__c');
                        projIdConIdAndSumofDuration.put(projIdConId, (Decimal)arEve.get('dur')); 
                    }
                    System.debug('projIdConIdAndSumofDuration==='+projIdConIdAndSumofDuration);
                                           
                    for(AggregateResult arTcd : [
                        SELECT AcctSeed__Time_Card_Line__r.AcctSeed__Project__c proj, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c ins, SUM(Total_Hours_Before_Approved__c)hrsApp
                        FROM AcctSeed__Time_Card_Day__c
                        WHERE AcctSeed__Date__c >= :previouswkStart AND AcctSeed__Date__c <= :previouswkEnd AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c IN :instructorProjs
                            AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c IN :instructorIds
                            GROUP BY AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c
                    
                    ]){
                        String projIdConId = String.valueof(arTcd.get('proj'))+'+'+String.valueof(arTcd.get('ins'));
                        projIdConIdAndSumofHrsApproved.put(projIdConId, (Decimal)arTcd.get('hrsApp'));
                    }
                    System.debug('projIdConIdAndSumofHrsApproved==='+projIdConIdAndSumofHrsApproved);
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext info){
    
        emailToSupervisorList = new List<Messaging.SingleEmailMessage>();
        
        Date currentWeekStart = system.today().toStartofWeek().addDays(1);
        
        Date previouswkStart = currentWeekStart.addDays(-7);
        Date previouswkEnd = previouswkStart.addDays(6);
        
        String preStartStr = String.valueOf(previouswkStart);
        String preEndStr = String.valueOf(previouswkEnd);
        
        String preWkStart = preStartStr.split('-')[1]+'/'+preStartStr.split('-')[2]+'/'+preStartStr.split('-')[0];
        String preWkEnd = preEndStr.split('-')[1]+'/'+preEndStr.split('-')[2]+'/'+preEndStr.split('-')[0];
        
        try{
        
            List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
            
            String orgWideEmailId = '';
            
            if(orgWideEmail != NULL && orgWideEmail.size() > 0){
                orgWideEmailId = orgWideEmail[0].Id;
            }
            system.debug(':::::::orgWideEmailId:::::'+orgWideEmailId);
            
            if(supvsrIds.size() > 0){
            
                String mailContent = '<html>Hi Chris and April,<br/>The following contacts have bounced email ids, Please correct them: <br/>';
                Boolean hasBouncedEmail = false;
                
                for(Id conId : supvsrIds){
                
                    if(conIdAndRec.containsKey(conId)){
                    
                        if(!conIdAndRec.get(conId).IsEmailBounced){
                        
                            String htmlBody = '';
                            htmlBody = 'Hi ' +conIdAndRec.get(conId).Name+', <br/><br/>';
                            htmlBody += 'The following instructors are expected to submit timesheets for last week: '+ preWkStart +' - '+ preWkEnd;
                            htmlBody += ' but have not yet submitted:<br/>';
                            htmlBody += '<br/><table border="1" style="border-collapse: collapse"><tr><th width="25%" style="text-align: center; vertical-align: middle;">Project Name</th><th width="25%" style="text-align: center; vertical-align: middle;">Instructor Name</th><th width="25%" style="text-align: center; vertical-align: middle;">Scheduled Hours</th><th width="25%" style="text-align: center; vertical-align: middle;">Hours Entered for this Week</th></tr>';
                            Boolean isEmail = false;
                            
                            if(supvsrIdAndProjIds.containsKey(conId)){
                            
                                for(Id projId : supvsrIdAndProjIds.get(conId)){
                                                                                
                                    if(projIdAndInstructors.containsKey(projId )){
                                    
                                        // Instructors who have not submitted their timesheets 
                                        for(Contact_Assignments__c ins : projIdAndInstructors.get(projId)){
                                        
                                            String projIdConId = ins.Project__c+'+'+ins.Candidate_Name__c; 
                                            
                                            if(projIdConIdAndSumofDuration.containsKey(projIdConId) && (!projIdConIdAndSumofHrsApproved.containsKey(projIdConId) || (projIdConIdAndSumofHrsApproved.containsKey(projIdConId) && 
                                                projIdConIdAndSumofHrsApproved.get(projIdConId) < projIdConIdAndSumofDuration.get(projIdConId)))){
                                            
                                                isEmail = true;
                                                String projectName = ins.Project__r.Name;
                                                String instructorName = ins.Candidate_Name__r.Name;
                                                
                                                String scheduledHours = '0';
                                                if(projIdConIdAndSumofDuration.containsKey(projIdConId)){
                                                    scheduledHours = String.valueOf(projIdConIdAndSumofDuration.get(projIdConId));
                                                }
                                                
                                                String hoursApproved = '0';
                                                if(projIdConIdAndSumofHrsApproved.containsKey(projIdConId)){
                                                    hoursApproved = String.valueOf(projIdConIdAndSumofHrsApproved.get(projIdConId));
                                                }
                                                
                                                htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + projectName + '</td><td style="text-align: center; vertical-align: middle;">' + instructorName + '</td><td style="text-align: center; vertical-align: middle;">' + scheduledHours + '</td><td style="text-align: center; vertical-align: middle;">' + hoursApproved+ '</td></tr>';
                                            }
                                        }
                                    }
                                }
                            }
                            htmlBody += '</table><br/>';
                            htmlBody += 'Please follow up with the instructors who have not yet submitted their timesheets.<br/><br/>';
                            htmlBody += 'Thank you,<br/><br/>DLS Accounting Department<br/>System Generated Email<br/>';     
                                                           
                            if(isEmail){
                            
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                if(orgWideEmailId != NULL) {
                                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                                }
                                mail.subject = 'DLS Timekeeping – Status of Timesheet Submissions for '+ preWkStart +' - '+ preWkEnd;
                                mail.setHtmlBody(htmlBody);
                                mail.setTargetObjectId(conId);
                                mail.setSaveAsActivity(TRUE);
                                emailToSupervisorList.add(mail);
                            }
                        }else {
                                
                            mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdAndRec.get(conId).Id+'" target="_blank">'+conIdAndRec.get(conId).Name+'</a><br/>';
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
                    emailToSupervisorList.add(bouncedmail);
                }
            }
            System.debug('emailToSupervisorList::::'+emailToSupervisorList);
            System.debug('==================='+emailToSupervisorList != NULL && emailToSupervisorList.size() > 0);
            
            if(emailToSupervisorList.size() > 0 ) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToSupervisorList);
            }
        }catch(Exception e) {
        
            String errorMessage = '';
            errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
            
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Weekly Timesheet Approval Remainder for Project Manager');
        }
    }
}