global class dailyRemainder_Overdue implements Database.batchable<sObject>,Database.Stateful { 
    
    /***********************************************************************************
        - Send Email to the DLS Staff Employees
        - An e-mail notification to the employees who have not submitted (Not entered time) their timesheet on daily basis will be generated by Salesforce and send on the second day from the missed entry @ 01:00 pm ET
        - This batch called from DailyRemainder_Overdue_schedule
        - Email Templates for internal - Daily_Reminder_for_Overdue
        - Modified by NS on Mar 21 2018 - To send next day of the time entry 
        - Removed the Staff community remainder related code because separate batch class is included for this
    *****************************************************************************************/
    
    /*public void timeLogConvertTo(){
        dailyRemainder_Overdue overdue = new dailyRemainder_Overdue();
        database.executeBatch(overdue,5);
    }*/
    global List<Messaging.SingleEmailMessage> EmailToInstructorList;
    global Set<Id> contactIdSet = new Set<Id>();
    global Map<Id,String> conIdSupervisorEmailMap = new Map<Id,String>();
    //global Map<Id,Boolean> conIdBouncedFlag = new Map<Id,Boolean>();
    global Map<Id,Contact> conIdRecMap = new Map<Id,Contact>();
   
    global Database.QueryLocator start(Database.BatchableContext info){   
       
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        String  contactQry = '';
        
        if(todayVal.format('EEEE') != 'Saturday' && todayVal.format('EEEE') != 'Sunday') {
             system.debug(':::::todayVal.format!tuesday'+todayVal.format('EEEE'));             
             contactQry = 'SELECT Id,Name,IsEmailBounced, DLS_User__c, Supervisor_Name__r.Email FROM Contact WHERE RecordType.DeveloperName = \'DLS_Employee\' AND Active_DLS_Employee__c = true AND EE_Pay_Status__c != \'Contractor\' AND Email != null';
        
        }else if(Test.isRunningTest()){
            contactQry = 'SELECT Id,Name, DLS_User__c, Supervisor_Name__r.Email FROM Contact WHERE RecordType.DeveloperName = \'DLS_Employee\' AND Active_DLS_Employee__c = true AND Email != null LIMIT 0';
        }
       
        System.debug('::::::::contactQry::::::::::'+contactQry);
        return Database.getQueryLocator(contactQry);
    }
        
    global void execute(Database.BatchableContext info, List<Contact> contactList){
    
        system.debug(':::dailyRemainder_Overdue:::::contactList:::::'+contactList);
        
        // get day records which having these status values only
        Set<String> statusSet = new Set<String>{'Rejected','Unposted','Recalled','Reverted'}; 
      
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        Date previousDate;
        
        system.debug('::::::todayVal.format'+todayVal.format('EEEE'));
        
        if(todayVal.format('EEEE') == 'Monday')
            previousDate = system.today().addDays(-3);
        else
            previousDate = system.today().addDays(-1);
        
        Map<Id,List<AcctSeed__Time_Card_Day__c>> contactIdDayRecordsMap =  new Map<Id,List<AcctSeed__Time_Card_Day__c>>();
        Map<Id,Boolean> contactIdStatusMap = new Map<Id,Boolean>();
        Map<Id,Boolean> conIdactiveFlagMap = new Map<Id,Boolean>();
        
        if(todayVal.format('EEEE') != 'Saturday' && todayVal.format('EEEE') != 'Sunday') {
            
            for(Contact con : contactList) {
                if(!contactIdDayRecordsMap.containsKey(con.Id))
                    contactIdDayRecordsMap.put(con.Id,new List<AcctSeed__Time_Card_Day__c>{});
                
                //conIdBouncedFlag.put(con.Id,con.IsEmailBounced);  
                conIdRecMap.put(con.Id,con);
                
                // Work Item: W-007217 - Email to Supervisor when Employee has not Submitted Timesheet
                if(!conIdSupervisorEmailMap.containsKey(con.Id)){
                    conIdSupervisorEmailMap.put(con.Id,con.Supervisor_Name__r.Email);
                }   
            }
            
            for(AcctSeed__Time_Card_Day__c dayRec : [SELECT Id,Name,AcctSeed__Time_Card_Line__c,
                                                                AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,
                                                                AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.Email,
                                                                Status__c 
                                                    FROM AcctSeed__Time_Card_Day__c 
                                                    WHERE AcctSeed__Date__c = :previousDate 
                                                    AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c IN :contactIdDayRecordsMap.keySet()]) {
                
                if(contactIdDayRecordsMap.containsKey(dayRec.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c)) {
                    contactIdDayRecordsMap.get(dayRec.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c).add(dayRec);
                }                                                  
            }
            
            system.debug(':::::contactIdDayRecordsMap::::::'+contactIdDayRecordsMap);
            system.debug('::::::::conIdSupervisorEmailMap::::'+conIdSupervisorEmailMap);
            
            for(Id conId : contactIdDayRecordsMap.keySet()) {
                if(contactIdDayRecordsMap.get(conId) != null && contactIdDayRecordsMap.get(conId).size() > 0) {
                    
                    for(AcctSeed__Time_Card_Day__c dayRec : contactIdDayRecordsMap.get(conId)) {
                        
                        contactIdSet.add(conId);
                        if(!statusSet.contains(dayRec.Status__c) && !contactIdStatusMap.containsKey(conId)){
                            contactIdStatusMap.put(conId,true);
                        }
                    }
                }else {
                    contactIdSet.add(conId);
                }
            }
            
        }
        
        system.debug(':::::::::contactIdStatusMap:::::::'+contactIdStatusMap);
        system.debug(':::::before::::contactIdSet:::::::'+contactIdSet);
        system.debug(':::::before::::contactIdSet::size:::::'+contactIdSet.size());
        
        if(contactIdSet.size() > 0 && contactIdStatusMap.size() > 0) {
            contactIdSet.removeAll(contactIdStatusMap.keySet());
        }
        system.debug(':::::contactIdSet::::::::::::after::::'+contactIdSet.size());
        system.debug(':::::contactIdSet::::::::::::after::::'+contactIdSet);
    }
    global void finish(Database.BatchableContext info){ 
        
        EmailToInstructorList = new List<Messaging.SingleEmailMessage>();
        try {
        
            EmailTemplate templateId = [Select id from EmailTemplate WHERE DeveloperName = 'Daily_Reminder_for_Overdue'];
            system.debug('::dailyRemainder_Overdue::::::::templateId::::::::;;'+templateId);  
            
            EmailTemplate templateId_beforeDue = [Select id from EmailTemplate WHERE DeveloperName = 'Daily_Reminder_for_Overdue_10_AM'];
            system.debug('::Daily_Reminder_for_Overdue_10_AM::::::::templateId::::::::;;'+templateId_beforeDue); 
           
            EmailTemplate staffTemplateId = [Select id from EmailTemplate WHERE DeveloperName = 'Staff_Daily_Reminder_for_Overdue'];
            system.debug('::staffTemplateId::::::::templateId::::::::;;'+staffTemplateId); 
            
            EmailTemplate staffTemplateId_beforeDue = [Select id from EmailTemplate WHERE DeveloperName = 'Staff_Daily_Reminder_for_Overdue_10_AM'];
            system.debug('::staffTemplateId_beforeDue::::::::templateId::::::::;;'+staffTemplateId_beforeDue);
            
            
             // Qry system value custom setting to get org wide email address for timesheets
            System_Values__c sysVal = System_Values__c.getValues('Timesheet'); 
            String orgWideEmailId = '';
           
            if(sysVal != null && sysVal.Value__c != null) {
                orgWideEmailId = sysVal.Value__c;
            }
            
            system.debug(':::::::orgWideEmailId:::::'+orgWideEmailId);
            
            DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
            
            DateTime currentDt = datetime.now();
            String currentTime = currentDt.format('h:mm a');
            String time1 = '10:00 AM';
            String time2 = '12:00 PM';
                 
            if(contactIdSet != null && contactIdSet.size() > 0 && templateId != null) {
            
                Map<Id, Id> conIdAndUserId = new Map<Id, Id>();
                for(User u : [SELECT Id, ContactId FROM User WHERE ContactId IN : contactIdSet AND Profile.Name = 'Staff Community' AND IsActive = True]){
                    conIdAndUserId.put(u.ContactId, u.Id);                    
                }
                
                String mailContent = '<html>Hi Chris and April,<br/>The following contacts have bounced email ids, Please correct them: <br/>';
                Boolean hasBouncedEmail = false;
                
                for(Id contactId :contactIdSet){
                    
                    if(conIdRecMap.containsKey(contactId) && !conIdRecMap.get(contactId).IsEmailBounced) {
                            
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        if(orgWideEmailId != null) {
                            mail.setOrgWideEmailAddressId(orgWideEmailId);
                        }
                        mail.setTargetObjectId(contactId);
                        
                        if((currentTime >= time1 || currentTime >= time2) && currentTime < '14:00 PM'){
                        
                            if(conIdRecMap.get(contactId).DLS_User__c == NULL || conIdAndUserId.containsKey(contactId)){
                                mail.setTemplateID(staffTemplateId_beforeDue.Id);
                            }else{
                                mail.setTemplateID(templateId_beforeDue.Id);
                            }                            
                            
                        }else {
                        
                            if(conIdRecMap.get(contactId).DLS_User__c == NULL || conIdAndUserId.containsKey(contactId)){
                                mail.setTemplateID(staffTemplateId.Id);
                            }else{
                                mail.setTemplateID(templateId.Id);
                            }
                            
                            if(conIdSupervisorEmailMap.containsKey(contactId)) {
                                String ccadd = conIdSupervisorEmailMap.get(contactId);
                                mail.setCcAddresses(new List<String>{ccadd});
                            }
                        }                           
                        mail.setSaveAsActivity(true);
                                                
                        EmailToInstructorList.add(mail);
                        
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
            errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Daily Remainder for overdue of time submission Email send');  
        } 
    }   
}