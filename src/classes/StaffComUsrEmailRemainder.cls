/***********************************************************************************
    - Send Email to the Staff Community Users
    - Email remainder to send on Friday(If there is no time entry for the current week) & Monday(If they have time entry for lastweek & not submitted)
    - This batch called from 
    - Email Templates for Staff Community contact - Community_contact_weekly_remainder_FRI,Comm_con_weekly_remain_submit_time_MON
    - Developed by NS on Dec 11 2018 - Extracted this logic from dailyRemainder_Overdue batch 
*****************************************************************************************/
global class StaffComUsrEmailRemainder implements Database.batchable<sObject>,Database.Stateful { 
    
    global List<Messaging.SingleEmailMessage> EmailToInstructorList;
    global Set<Id> contactIdSet = new Set<Id>();
    global Map<Id,String> conIdSupervisorEmailMap = new Map<Id,String>();
    global Map<Id,Contact> conIdRecMap = new Map<Id,Contact>();
    
    global Database.QueryLocator start(Database.BatchableContext info){ 
        String  contactQry = '';
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        contactQry = 'SELECT Id,Name,IsEmailBounced FROM Contact WHERE RecordType.DeveloperName = \'DLS_Employee\' AND Active_DLS_Employee__c = true AND EE_Pay_Status__c != \'Contractor\' AND Email != null '+
                     'AND Id IN (SELECT ContactId FROM User WHERE IsActive = true AND IsPortalEnabled = true AND Staff_Access__c = true)';
        
        
        System.debug('::::::::contactQry::::::::::'+contactQry);
        return Database.getQueryLocator(contactQry);
    
    }
    
    global void execute(Database.BatchableContext info, List<Contact> contactList){
        
        
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        Date previousDate;
        
        if(todayVal.format('EEEE') == 'Monday') {
            previousDate = system.today().addDays(-3);
        } else if(todayVal.format('EEEE') == 'Friday') {
            previousDate = system.today();
        }else if(Test.isRunningTest()) {
            previousDate = system.today();
        }
        
        Date weekstdate = previousDate.toStartofWeek()+1;
        Date weekenddate = previousDate.toStartofWeek()+7;
        
        Map<Id,Boolean> contactIdIncludeForEmailMap =  new Map<Id,Boolean>();
        Map<Id,Boolean> conIdactiveFlagMap = new Map<Id,Boolean>();
        Set<Id> contactIds = new Set<Id>();
        
        for(Contact con : contactList) {
            contactIds.add(con.Id);
            conIdRecMap.put(con.Id,con);  
        }
     
        // Quried Contact Assignment to get active dls staff contact for Community mail sending
            
        for(Contact_Assignments__c conAss : [SELECT Id,Name,Candidate_Name__c 
                                                FROM Contact_Assignments__c 
                                                WHERE RecordType.DeveloperName = 'Staff' AND Status__c = 'Active' 
                                                    AND Candidate_Name__c IN : contactIds]) {
            
            if(!conIdactiveFlagMap.containsKey(conAss.Candidate_Name__c))
                conIdactiveFlagMap.put(conAss.Candidate_Name__c,true);
        }
        
        system.debug(':::::::::conIdactiveFlagMap:::::::::'+conIdactiveFlagMap);
        
        for(AcctSeed__Time_Card__c cardRec : [SELECT Id,Name,Intructor__c,Intructor__r.Supervisor_Name__r.Email,of_Pending_Time_Logs__c,of_Rejected_Hours__c,of_Submitted_Hours__c,of_Approved_Hours__c
                                                FROM AcctSeed__Time_Card__c 
                                                WHERE AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c >= :weekstdate AND AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c <= :weekenddate
                                                AND Intructor__c IN :contactIds]) {
            
            if(todayVal.format('EEEE') == 'Monday' || Test.isRunningTest()){
                if(cardRec.of_Pending_Time_Logs__c > 0) {
                    if(!contactIdIncludeForEmailMap.containsKey(cardRec.Intructor__c)) {
                        contactIdIncludeForEmailMap.put(cardRec.Intructor__c,true);
                    } 
                }
            }else if(todayVal.format('EEEE') == 'Friday' || Test.isRunningTest()){
                if(cardRec.of_Pending_Time_Logs__c == 0 && cardRec.of_Submitted_Hours__c == 0 
                    && cardRec.of_Approved_Hours__c == 0) {
                    
                    if(!contactIdIncludeForEmailMap.containsKey(cardRec.Intructor__c)) {
                        contactIdIncludeForEmailMap.put(cardRec.Intructor__c,true);
                    } 
                }
            }
            
            if(!conIdSupervisorEmailMap.containsKey(cardRec.Intructor__c)){
                conIdSupervisorEmailMap.put(cardRec.Intructor__c,cardRec.Intructor__r.Supervisor_Name__r.Email);
            }                                    
        }
        
        system.debug(':::::contactIdIncludeForEmailMap::::::'+contactIdIncludeForEmailMap);
        system.debug('::::::::conIdSupervisorEmailMap::::'+conIdSupervisorEmailMap);
        
         for(Id conId : contactIdIncludeForEmailMap.keySet()) {
            if(contactIdIncludeForEmailMap.get(conId) && conIdactiveFlagMap.containsKey(conId)) {
                contactIdSet.add(conId);
            }
        }
        
        system.debug(':::::::contactIdSet:::::'+contactIdSet);
        system.debug(':::::::contactIdSet:::::'+contactIdSet.size());
        
    }
    
    global void finish(Database.BatchableContext info){ 
    
         EmailToInstructorList = new List<Messaging.SingleEmailMessage>();
        try {
            
            
            EmailTemplate comm_Friday_Template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Community_contact_weekly_remainder_FRI'];
            system.debug('::::::comm_Friday_Template::::::'+comm_Friday_Template);
            
            EmailTemplate comm_Monday_Template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Comm_con_weekly_remain_submit_time_MON'];
            system.debug('::::::comm_Monday_Template::::::'+comm_Monday_Template);
            
            // Qry system value custom setting to get org wide email address for timesheets
            System_Values__c sysVal = System_Values__c.getValues('Timesheet'); 
            String orgWideEmailId = '';
           
            if(sysVal != null && sysVal.Value__c != null) {
                orgWideEmailId = sysVal.Value__c;
            }
            
            system.debug(':::::::orgWideEmailId:::::'+orgWideEmailId);
            
            DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
            
            if(contactIdSet != null && contactIdSet.size() > 0 ) {
                String mailContent = '<html>Hi Chris and April,<br/>The following contacts have bounced email ids, Please correct them: <br/>';
                Boolean hasBouncedEmail = false;
                
                    for(Id contactId :contactIdSet){
                        
                        if(conIdRecMap.containsKey(contactId) && !conIdRecMap.get(contactId).IsEmailBounced) {
                    
                            if((todayVal.format('EEEE') == 'Monday' || todayVal.format('EEEE') == 'Friday') || Test.isRunningTest()) {
                            
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                
                                if(orgWideEmailId != null) {
                                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                                }
                                
                                mail.setTargetObjectId(contactId);
                                
                                if(todayVal.format('EEEE') == 'Friday') {
                                    mail.setTemplateID(comm_Friday_Template.Id);
                                } else if(todayVal.format('EEEE') == 'Monday') {
                                    mail.setTemplateID(comm_Monday_Template.Id);
                                }
                            
                                mail.setSaveAsActivity(true);
                                if(conIdSupervisorEmailMap.containsKey(contactId)) {
                                    String ccadd = conIdSupervisorEmailMap.get(contactId);
                                    mail.setCcAddresses(new List<String>{ccadd});
                                }
                                    
                                EmailToInstructorList.add(mail);
                            
                            }
                            //System.Debug('Email::: ' + mail);
                        }else {
                        
                            mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRecMap.get(contactId).Id+'" target="_blank">'+conIdRecMap.get(contactId).Name+'</a><br/>';
                            hasBouncedEmail = true;
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
            
            if( EmailToInstructorList != null && EmailToInstructorList.size() > 0 ) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(EmailToInstructorList);
            } 
        }catch(Exception e) {
            
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Staff Community User Remainder for Friday / Monday Email');
        } 
    }
}