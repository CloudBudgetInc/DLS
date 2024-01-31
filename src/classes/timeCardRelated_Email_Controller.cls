public without sharing class timeCardRelated_Email_Controller {
    
    // Static set to hold classLeader Ids to ignore sending email through Attendance trigger because these students received email through time entry submission
    public static Set<Id> classLeaderIds = new Set<Id>();
    
    // Send Email to Instructor when Bonus Leave Earned Records are Approved / Rejected
    public static void bonusLeaveEarned_Email(List<AcctSeed__Time_Card_Day__c> newRecList,Map<Id,AcctSeed__Time_Card_Day__c> oldMap) {
        
        Set<Id> approvedDayIds = new Set<Id>();
        Set<Id> rejectedIds = new Set<Id>();
        
        Map<Id,Id> contactIdDayIdApproveMap = new Map<Id,Id>();
        Map<Id,Id> contactIdDayIdRejectMap = new Map<Id,Id>();
        
        if(Trigger.isUpdate){
            for (AcctSeed__Time_Card_Day__c day : newRecList) {
                
                if(oldMap != null) {
                    if(oldMap.get(day.Id).Id != day.Id || 
                        (oldMap.get(day.Id).Status__c != 'Approved' && oldMap.get(day.Id).Status__c != day.Status__c 
                        && day.Status__c == 'Approved')) {
                        
                        approvedDayIds.add(day.Id);
                    }
                    
                    if(oldMap.get(day.Id).Id != day.Id || 
                        (oldMap.get(day.Id).Status__c != 'Rejected' && oldMap.get(day.Id).Status__c != day.Status__c 
                        && day.Status__c == 'Rejected')) {
                        rejectedIds.add(day.Id);
                    }
                }
            }
            
            system.debug('::::approvedDayIds:::::'+approvedDayIds);
            system.debug('::::rejectedIds:::::'+rejectedIds);
            
            if(approvedDayIds.size() > 0) {
                for(AcctSeed__Time_Card_Day__c dayRec : [SELECT Id,Name,AcctSeed__Time_Card_Line__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,
                                                            AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,
                                                            AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c
                                                        FROM AcctSeed__Time_Card_Day__c 
                                                        WHERE Id IN :approvedDayIds AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'DLS_Employee' 
                                                                AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Active_DLS_Employee__c = true]) {
                    
                    if(dayRec.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name.contains('Bonus Leave Earned') 
                        && !contactIdDayIdApproveMap.containsKey(dayRec.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c)) {
                        
                        contactIdDayIdApproveMap.put(dayRec.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,dayRec.Id);
                    }
                }
            }
            
            if(rejectedIds.size() > 0) {
                for(AcctSeed__Time_Card_Day__c dayRec : [SELECT Id,Name,AcctSeed__Time_Card_Line__c,AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c,
                                                            AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name,
                                                            AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c
                                                        FROM AcctSeed__Time_Card_Day__c 
                                                        WHERE Id IN :rejectedIds AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'DLS_Employee'
                                                            AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Active_DLS_Employee__c = true]) {
                    
                    if(dayRec.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Name.contains('Bonus Leave Earned') 
                        && !contactIdDayIdRejectMap.containsKey(dayRec.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c)) {
                        
                        contactIdDayIdRejectMap.put(dayRec.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,dayRec.Id);
                    }
                }
            }
            
            // Bonus Leave Earned Approval
            EmailTemplate approveTemplateId = [Select id from EmailTemplate where DeveloperName = 'Bonus_Leave_Earned_Approval_Notification'];
            
            //Bonus Leave Earned Rejection
            EmailTemplate rejectTemplateId = [Select id from EmailTemplate where DeveloperName = 'Bonus_Leave_Earned_Rejection_Email'];
            
            List<Messaging.SingleEmailMessage> EmailList = new List<Messaging.SingleEmailMessage>();
            
            // Qry Timesheet OrgwideEmailAddress
            List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
            
            String orgWideEmailId = '';
            
            if(orgWideEmail != null && orgWideEmail.size() > 0){
                orgWideEmailId = orgWideEmail[0].Id;
            }
            
            system.debug(':::::::orgWideEmailId:::::'+orgWideEmailId);
            
            // Approval
            if(contactIdDayIdApproveMap != null && contactIdDayIdApproveMap.size() > 0 && approveTemplateId != null) {
                 
                 for(Id contactId :contactIdDayIdApproveMap.keySet()){
                     
                     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                     if(orgWideEmailId != null) {
                        mail.setOrgWideEmailAddressId(orgWideEmailId);
                     }
                     mail.setTargetObjectId(contactId);
                     mail.setWhatId(contactIdDayIdApproveMap.get(contactId));
                     mail.setTemplateID(approveTemplateId.Id);
                     mail.setSaveAsActivity(true);
                     EmailList.add(mail);
                    
                     //System.Debug('Email::: ' + mail);
                 }
             }
             System.debug('EmailList:::approve:'+EmailList);
             
             
             // Rejection
             if(contactIdDayIdRejectMap != null && contactIdDayIdRejectMap.size() > 0 && rejectTemplateId != null) {
                
                 for(Id contactId :contactIdDayIdRejectMap.keySet()){
                     
                     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                     if(orgWideEmailId != null) {
                        mail.setOrgWideEmailAddressId(orgWideEmailId);
                     }
                     mail.setTargetObjectId(contactId);
                     mail.setWhatId(contactIdDayIdRejectMap.get(contactId));
                     mail.setTemplateID(rejectTemplateId.Id);
                     mail.setSaveAsActivity(true);
                     EmailList.add(mail);
                    
                     //System.Debug('Email::: ' + mail);
                 }
             }
             System.debug('EmailList:::reject:'+EmailList);
             
            
             if( EmailList != null && EmailList.size() > 0 ) {
                 Messaging.SendEmailResult[] results = Messaging.sendEmail(EmailList);
             } 
        }
        
    }
    
    //Approve / Reject All Email send to Instructor
    public static void approve_RejectAll_EmailMethod(Set<Id> timeCarddayId,String typeOfaction) {
        
        Map<Id,Id> contactIdCardIdMap = new Map<Id,Id>();
        List<Messaging.SingleEmailMessage> EmailToInstructorList = new List<Messaging.SingleEmailMessage>();
        
        String rejectionReason = '';
        
        for(AcctSeed__Time_Card_Day__c day : [SELECT Id,Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                    AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,
                                                    AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Supervisor_Name__c,AcctSeed__Invoice_Comment__c 
                                                FROM AcctSeed__Time_Card_Day__c 
                                                WHERE Id IN :timeCarddayId AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'DLS_Employee'
                                                        AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Active_DLS_Employee__c = true]) {
                                                
             if(!contactIdCardIdMap.containsKey(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c)){
                 contactIdCardIdMap.put(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c);
             }
             
             rejectionReason = day.AcctSeed__Invoice_Comment__c;
        }   
        system.debug(':::::::contactIdCardIdMap::::::'+contactIdCardIdMap);
        
        Map<Id,Contact> contactIdRec = new Map<Id,Contact>();
        Map<Id,AcctSeed__Time_Card__c> cardIdRec = new Map<Id,AcctSeed__Time_Card__c>();
        
        if(typeOfaction == 'RejectAll'){
            
            contactIdRec = new Map<Id,Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :contactIdCardIdMap.keySet()]);
            cardIdRec = new Map<Id,AcctSeed__Time_Card__c>([SELECT Id,Time_Card_Period_Week_Range__c FROM AcctSeed__Time_Card__c WHERE Id IN :contactIdCardIdMap.values()]);
        }
        
        // Qry Email template
             
         EmailTemplate templateId;
         
         if(typeOfaction == 'ApproveAll') {
             templateId = [Select id from EmailTemplate WHERE DeveloperName = 'Approval_Notification_for_Timesheet'];
         } else if(typeOfaction == 'RejectAll') {
             templateId = [Select id from EmailTemplate WHERE DeveloperName = 'Rejection_Notification_for_Timesheet'];
         }
         
         system.debug('::approve_RejectAll_EmailMethod::::::::templateId::::::::;;'+templateId);
         
         // Qry Timesheet OrgwideEmailAddress
         String orgWideEmailId = '';
         
         List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
       
         if(orgWideEmail != null && orgWideEmail.size() > 0){
            orgWideEmailId = orgWideEmail[0].Id;
         }
        
         system.debug(':::::::orgWideEmailId:::::'+orgWideEmailId);        
         
         if(contactIdCardIdMap != null && contactIdCardIdMap.size() > 0 && templateId != null) {
             for(Id contactId : contactIdCardIdMap.keySet()){
                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                 if(orgWideEmailId != null) {
                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                 }
                 mail.setTargetObjectId(contactId);
                 mail.setWhatId(contactIdCardIdMap.get(contactId));
                 
                 if(typeOfaction == 'ApproveAll'){
                     mail.setTemplateID(templateId.Id);    
                 }else {
                     
                     Id cardId = contactIdCardIdMap.get(contactId);
                     
                     if(contactIdRec.containsKey(contactId)){
                         string htmlBody = '<html>Hi '+contactIdRec.get(contactId).Name+', <br/><br/>';
                         htmlBody += 'Your timesheet for the period '+cardIdRec.get(cardId).Time_Card_Period_Week_Range__c+' has been rejected.<br/><br/>';
                         htmlBody += 'Comment/Reason: '+rejectionReason+'.<br/><br/>';
                         
                         htmlBody += 'Please review and resubmit: <a href="'+System.Label.Org_Prefix_Start_URL+'/apex/DLS_Staff_Time_Entry_Page" target="_blank">Resubmit Time</a><br/><br/><br/>';
                         htmlBody += 'Regards,<br/>Time Reporting System<br/><br/>This e-mail was auto generated. Please do not respond.';
                         mail.setHtmlBody(htmlBody);
                     }
                 }
                 
                 mail.setSaveAsActivity(true);
                 EmailToInstructorList.add(mail);
                
                 //System.Debug('Email::: ' + mail);
             }
         }
         System.debug('EmailToInstructorList::::'+EmailToInstructorList);
        
         if( EmailToInstructorList != null && EmailToInstructorList.size() > 0 ) {
             Messaging.SendEmailResult[] results = Messaging.sendEmail(EmailToInstructorList);
         }
    }
    
    //Partial action Email send to Instructor
    public static void partial_approve_Reject_EmailMethod(Set<Id> timeCarddayId) {
        
        Map<Id,Id> contactIdCardIdMap = new Map<Id,Id>();
        List<Messaging.SingleEmailMessage> EmailToInstructorList = new List<Messaging.SingleEmailMessage>();
        
        for(AcctSeed__Time_Card_Day__c day : [SELECT Id,Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                    AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,
                                                    AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c
                                                FROM AcctSeed__Time_Card_Day__c 
                                                WHERE Id IN :timeCarddayId AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'DLS_Employee'
                                                    AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Active_DLS_Employee__c = true]) {
                                                
             if(!contactIdCardIdMap.containsKey(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c))
                 contactIdCardIdMap.put(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c);
        }   
        system.debug(':::::::contactIdCardIdMap::::::'+contactIdCardIdMap);
        
        EmailTemplate templateId = [Select id from EmailTemplate WHERE DeveloperName = 'Partially_Approved_Rejected_Notification'];
        
        system.debug('::partial_approve_Reject_EmailMethod::::::::templateId::::::::;;'+templateId); 
        
        // Qry Timesheet OrgwideEmailAddress
        String orgWideEmailId = '';
        
        List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
       
        if(orgWideEmail != null && orgWideEmail.size() > 0){
            orgWideEmailId = orgWideEmail[0].Id;
        }
        
        system.debug(':::::::orgWideEmailId:::::'+orgWideEmailId);             
         
         if(contactIdCardIdMap != null && contactIdCardIdMap.size() > 0 && templateId != null) {
         
             for(Id contactId : contactIdCardIdMap.keySet()){
             
                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                 if(orgWideEmailId != null) {
                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                 }
                 mail.setTargetObjectId(contactId);
                 mail.setWhatId(contactIdCardIdMap.get(contactId));
                 mail.setTemplateID(templateId.Id);
                 mail.setSaveAsActivity(true);
                 EmailToInstructorList.add(mail);
                
                 //System.Debug('Email::: ' + mail);
             }
         }
         System.debug('EmailToInstructorList::::'+EmailToInstructorList);
        
         if( EmailToInstructorList != null && EmailToInstructorList.size() > 0 ) {
             Messaging.SendEmailResult[] results = Messaging.sendEmail(EmailToInstructorList);
         }
    }
    
    // Revert notification email to corressponding Employees & their Supervisor
    // Modified notification email to corresponding Employees & their Supervisor
    
    public static void adminModification_Notifications(Set<Id> timeCarddayId,String actionType) {
    
        system.debug(':::adminModification_Notifications::::timeCarddayId:::::::'+timeCarddayId);
        
        Map<Id,Id> contactIdCardIdMap = new Map<Id,Id>();
        List<Messaging.SingleEmailMessage> EmailToInstructorList = new List<Messaging.SingleEmailMessage>();
        
        // Send Email to the corresponding Employee's Supervisor
        Map<String,Id> supervisorNamecardIdMap = new Map<String,Id>();
        Set<String> firstName = new Set<String>();
        Set<String> middleName = new Set<String>();
        Set<String> lastName = new Set<String>();
        Map<Id,Id> supervisorContact_cardIdMap = new Map<Id,Id>();
        
        for(AcctSeed__Time_Card_Day__c day : [SELECT Id,Name,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,
                                                    AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,
                                                    AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__c,
                                                    AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.FirstName,
                                                    AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.MiddleName,
                                                    AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.LastName,
                                                    AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__c
                                                
                                                FROM AcctSeed__Time_Card_Day__c 
                                                WHERE Id IN :timeCarddayId AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'DLS_Employee'
                                                    AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Active_DLS_Employee__c = true]) {
                                                
             if(!contactIdCardIdMap.containsKey(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c))
                 contactIdCardIdMap.put(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c);
            
            // For Supervisor Email notification purpose
               String fname = day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.FirstName;
               String mName = day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.MiddleName;
               String lName = day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.LastName;
             
             if(!supervisorNamecardIdMap.containsKey(fname+'-'+mName+'-'+lName))
                 supervisorNamecardIdMap.put(fname+'-'+mName+'-'+lName,day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c);
            
            firstName.add(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.FirstName);
            middleName.add(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.MiddleName);
            lastName.add(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.LastName);
            
        }   
        
        system.debug(':::adminModification_Notifications::::contactIdCardIdMap::::::'+contactIdCardIdMap);
        
        system.debug('::::::::supervisorNamecardIdMap::::::'+supervisorNamecardIdMap);
        system.debug('::::::::firstName::::::'+firstName);
        system.debug('::::::::middleName::::::'+middleName);
        system.debug('::::::::lastName::::::'+lastName);
        
        for(Contact con : [SELECT Id,FirstName,MiddleName,LastName FROM Contact WHERE FirstName IN : firstName AND MiddleName IN :middleName AND LastName IN : lastName]) {
            
            String conFName = con.FirstName;
            String conMName = con.MiddleName;
            String conLName = con.LastName;
            
            if(supervisorNamecardIdMap.containsKey(conFName+'-'+conMName+'-'+conLName) 
                && !supervisorContact_cardIdMap.containsKey(con.Id)) {
                supervisorContact_cardIdMap.put(con.Id,supervisorNamecardIdMap.get(conFName+'-'+conMName+'-'+conLName));
            }
        }
        
        system.debug('::::::::supervisorContact_cardIdMap:::::'+supervisorContact_cardIdMap);
        EmailTemplate templateId = new EmailTemplate();
        
        if(actionType == 'Revert Action') {
            templateId = [Select id from EmailTemplate WHERE DeveloperName = 'Revert_notification_to_Employee'];
        } else if(actionType == 'Save Action') {
            templateId = [Select id from EmailTemplate WHERE DeveloperName = 'Admin_Modification_Notify_Employees'];
        }
        
        system.debug(':adminModification_Notifications:::::::::templateId::::::::;;'+templateId); 
       
        // Qry Timesheet OrgwideEmailAddress
        String orgWideEmailId = '';
        
        List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
       
        if(orgWideEmail != null && orgWideEmail.size() > 0){
            orgWideEmailId = orgWideEmail[0].Id;
        }
        
        system.debug(':::::::orgWideEmailId:::::'+orgWideEmailId);         
         
         if(contactIdCardIdMap != null && contactIdCardIdMap.size() > 0 && templateId != null) {
         
             for(Id contactId : contactIdCardIdMap.keySet()){
             
                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                 if(orgWideEmailId != null) {
                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                 }
                 mail.setTargetObjectId(contactId);
                 mail.setWhatId(contactIdCardIdMap.get(contactId));
                 mail.setTemplateID(templateId.Id);
                 mail.setSaveAsActivity(true);
                 EmailToInstructorList.add(mail);
                
                 //System.Debug('Email::: ' + mail);
             }
         }
         System.debug('EmailToInstructorList::::'+EmailToInstructorList);
         System.debug('EmailToInstructorList:::size:'+EmailToInstructorList.size());
         
         // Added supervisor contact id to the send Email list
         
         EmailTemplate supervisorTemplate = new EmailTemplate();
         
         if(actionType == 'Revert Action') {
             supervisorTemplate = [Select id from EmailTemplate WHERE DeveloperName = 'Revert_notification_to_Supervisor'];
         } else if(actionType == 'Save Action') {
             supervisorTemplate = [Select id from EmailTemplate WHERE DeveloperName = 'Admin_Modification_Notify_to_Supervisor'];
         }
             
        system.debug(':adminModification_Notifications:::::::::supervisorTemplate::::::::;;'+supervisorTemplate); 
         
         if(supervisorContact_cardIdMap != null && supervisorContact_cardIdMap.size() > 0 && supervisorTemplate != null) {
             for(Id conId : supervisorContact_cardIdMap.keySet()){
             
                 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                 if(orgWideEmailId != null) {
                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                 }
                 mail.setTargetObjectId(conId);
                 mail.setWhatId(supervisorContact_cardIdMap.get(conId));
                 mail.setTemplateID(supervisorTemplate.Id);
                 mail.setSaveAsActivity(true);
                 EmailToInstructorList.add(mail);
             }
         }
         
         System.debug('EmailToInstructorList::added supervisor:contact:::'+EmailToInstructorList);
         System.debug('EmailToInstructorList:::supervisor:::contact:::size:'+EmailToInstructorList.size());
        
         if( EmailToInstructorList != null && EmailToInstructorList.size() > 0 ) {
             Messaging.SendEmailResult[] results = Messaging.sendEmail(EmailToInstructorList);
         }
    }
    
    /****************
        - Added by HL
        - Work Item : W-001120
        - To send an Email to Student
        - An Email notification to Student for Daily Time Entry Approval Request 
        - Immediately upon Instructor Time Card Day save
        - HTML Body
    ******************************/
    public static void dailyRequestToStudent(List<AcctSeed__Time_Card_Day__c> newDayRecs){
        
        Set<Id> dayIds = new Set<Id>();
        
        for (AcctSeed__Time_Card_Day__c day : newDayRecs) {
                            
            if(day.Student_Approval_Status__c == 'Submitted' && day.Late_Cancellation__c == FALSE){
                dayIds.add(day.Id);
            }
        }
        
        if(dayIds.size() > 0){
            
            Map<Id, Id> dayIdAndLeaderId = getClassLeaderforTCD(dayIds,false);
            
            if(dayIdAndLeaderId != NULL && dayIdAndLeaderId.size() > 0){
                
                Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :dayIdAndLeaderId.values()]);
                
                Map<Id, AcctSeed__Time_Card_Day__c> dayIdAndRec = new Map<Id, AcctSeed__Time_Card_Day__c>([
                    SELECT Id, AcctSeed__Date__c, DLS_Class__c, Start_Time1__c, End_Time1__c, Total_Hours_Before_Approved__c, 
                        Time_Card_Period_Week_Range_Format__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, 
                        AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c 
                    FROM AcctSeed__Time_Card_Day__c 
                    WHERE Id IN :dayIdAndLeaderId.keySet()]);
                
                // Work Item : W-006419 - Add "No Student Approval" to the Event Edit Page
                Map<Id, Boolean> tcdIdAndNoStdApprovalFlag = timeCardRelated_Email_Controller.tcdIdAndNoStdApprovalFlag(dayIdAndLeaderId.keySet());
                System.debug('::::tcdIdAndNoStdApprovalFlag::::::'+tcdIdAndNoStdApprovalFlag);

                List<Messaging.SingleEmailMessage> emailToStudentList = new List<Messaging.SingleEmailMessage>();
                
                String mailContent = '<html>Hi Chris, April and Nafisa <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                Boolean hasBouncedEmail = FALSE;

                try{
                    
                    List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
            
                    String orgWideEmailId = '';
                    
                    if(orgWideEmail != null && orgWideEmail.size() > 0){
                        orgWideEmailId = orgWideEmail[0].Id;
                    }
                                                            
                    for(Id dayId : dayIdAndLeaderId.keySet()){
                    
                        if(tcdIdAndNoStdApprovalFlag != NULL && tcdIdAndNoStdApprovalFlag.containsKey(dayId) && !tcdIdAndNoStdApprovalFlag.get(dayId)){
                        
                            //System.debug('::::::dayIdAndRec.get(dayId).Total_Hours_Before_Approved__c::::'+dayIdAndRec.get(dayId).Total_Hours_Before_Approved__c);
                            // Work Item : W-004360 - No email to student for 0 hours - non-DODA
                            if(dayIdAndRec.containsKey(dayId) && 
                                (dayIdAndRec.get(dayId).AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName == 'DODA_Projects' || 
                                (dayIdAndRec.get(dayId).AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName != 'DODA_Projects' && 
                                dayIdAndRec.get(dayId).Total_Hours_Before_Approved__c > 0))){
                            
                                if(conIdRec.containsKey(dayIdAndLeaderId.get(dayId))){
                                
                                    if(!conIdRec.get(dayIdAndLeaderId.get(dayId)).IsEmailBounced){
                                    
                                        String s = String.valueOf(dayIdAndRec.get(dayId).AcctSeed__Date__c);
                                        String dayDate = s.split('-')[1]+'/'+s.split('-')[2]+'/'+s.split('-')[0];
                                    
                                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                        if(orgWideEmailId != null) {
                                            mail.setOrgWideEmailAddressId(orgWideEmailId);
                                        }
                                        mail.setTargetObjectId(dayIdAndLeaderId.get(dayId));
                                        mail.setWhatID(dayId);
                                        
                                        mail.subject = 'DLS Timekeeping – Your instructor has submitted a time entry for your approval for ' + dayDate + ' for '+ dayIdAndRec.get(dayId).DLS_Class__c;
                                        
                                        String weekRange = dayIdAndRec.get(dayId).Time_Card_Period_Week_Range_Format__c;
                                        String projId = dayIdAndRec.get(dayId).AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
                                        String insId = dayIdAndRec.get(dayId).AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
                                        String urlRedirectToStdPage = '<a href="'+ System.Label.Student_Community_Site_Prefix +'/s/time-approval?week='+ weekRange + '&projectId='+ projId + '&instructorId='+ insId + '" target="_blank"> Click Here </a>';
                                        
                                        String htmlBody = '';
                                        htmlBody += 'Hi '+ conIdRec.get(dayIdAndLeaderId.get(dayId)).Name + ', <br/><br/>'; 
                                        htmlBody += 'This is a request to review and approve or reject the time entry that your instructor recently submitted for your class on '+ dayDate + ' from ' + dayIdAndRec.get(dayId).Start_Time1__c +' to '+ dayIdAndRec.get(dayId).End_Time1__c;
                                        htmlBody += '. Please go to the Time Approval Page - '+ urlRedirectToStdPage +'  to approve or reject this time.<br/><br/>';
                                        htmlBody += 'Thank you,<br/><br/>DLS Accounting Department<br/>System Generated Email';
                
                                        mail.setHtmlBody(htmlBody);
                                        mail.setSaveAsActivity(TRUE);
                                        emailToStudentList.add(mail);
                                    }else {
                                
                                        mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(dayIdAndLeaderId.get(dayId)).Id+'" target="_blank">'+conIdRec.get(dayIdAndLeaderId.get(dayId)).Name+'</a><br/>';
                                        hasBouncedEmail = TRUE;
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
                        emailToStudentList.add(bouncedmail);
                    }
                    System.debug(':::emailToStudentList:::'+emailToStudentList);
                    if(emailToStudentList.size() > 0) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToStudentList);
                    }
                }catch(Exception e) {
                    
                    ErrorHandler errHandler = new ErrorHandler();
                    errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Daily Time Entry Approval Request for Students');
                } 
            }
        }
    }
    
    /****************
        // Commented on Apr 21 2023
        // W-007768 - Instructor Time Entry - Remove Late Cancellation Checkbox, add new Attendance Controls (JUN-1-2023)
        // Late Cancellation Checkbox is removed from Instructor Time Entry page, so this email process is commented
        - Added by HL
        - Work Item : W-001120
        - To send an Email to Student
        - An Email notification to Student for Daily Time Entry Approval Request for Late Cancellation 
        - Immediately upon Instructor Time Card Entry save where Late Cancellation checkbox is checked
        - HTML Body
    
    public static void dailyReqToStudForLateCancellation(List<AcctSeed__Time_Card_Day__c> newDayRecs){
        
        Set<Id> dayIds = new Set<Id>();
        
        for (AcctSeed__Time_Card_Day__c day : newDayRecs) {
            System.debug('day.Late_Cancellation__c'+day.Late_Cancellation__c);
            if(day.Student_Approval_Status__c == 'Submitted' && day.Late_Cancellation__c == TRUE){
                dayIds.add(day.Id);
            }
        }
        System.debug('dayIds============**'+dayIds+'dayIds SIZE==='+dayIds.size());
        if(dayIds.size() > 0){
            
            Map<Id, Id> dayIdAndLeaderId = getClassLeaderforTCD(dayIds,false);
            
            if(dayIdAndLeaderId != NULL && dayIdAndLeaderId.size() > 0){
                
                Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :dayIdAndLeaderId.values()]);
                
                Map<Id, AcctSeed__Time_Card_Day__c> dayIdAndRec = new Map<Id, AcctSeed__Time_Card_Day__c>([
                    SELECT Id, AcctSeed__Date__c, DLS_Class__c, Start_Time1__c, End_Time1__c, 
                        Time_Card_Period_Week_Range_Format__c, Total_Hours_Before_Approved__c,
                        AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName,
                        AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, Instructor_Name__c, Cancellation_Reason__c 
                    FROM AcctSeed__Time_Card_Day__c 
                    WHERE Id IN :dayIdAndLeaderId.keySet()]);
                
                // Work Item : W-006419 - Add "No Student Approval" to the Event Edit Page
                Map<Id, Boolean> tcdIdAndNoStdApprovalFlag = timeCardRelated_Email_Controller.tcdIdAndNoStdApprovalFlag(dayIdAndLeaderId.keySet());
                System.debug('::::tcdIdAndNoStdApprovalFlag::::::'+tcdIdAndNoStdApprovalFlag);

                List<Messaging.SingleEmailMessage> emailToStudentList = new List<Messaging.SingleEmailMessage>();
                
                String mailContent = '<html>Hi Chris, April and Nafisa <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                Boolean hasBouncedEmail = FALSE;

                try{
                    
                    List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
            
                    String orgWideEmailId = '';
                    
                    if(orgWideEmail != null && orgWideEmail.size() > 0){
                        orgWideEmailId = orgWideEmail[0].Id;
                    }
                                                            
                    for(Id dayId : dayIdAndLeaderId.keySet()){
                        
                        if((tcdIdAndNoStdApprovalFlag != NULL && tcdIdAndNoStdApprovalFlag.containsKey(dayId) && 
                            !tcdIdAndNoStdApprovalFlag.get(dayId)) || Test.isRunningTest()){
                        
                            // Work Item : W-004360 - No email to student for 0 hours - non-DODA
                            if(dayIdAndRec.containsKey(dayId) && 
                                (dayIdAndRec.get(dayId).AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName == 'DODA_Projects' || 
                                (dayIdAndRec.get(dayId).AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName != 'DODA_Projects' && 
                                dayIdAndRec.get(dayId).Total_Hours_Before_Approved__c > 0))){
                        
                                if(conIdRec.containsKey(dayIdAndLeaderId.get(dayId))){
                                
                                    if(!conIdRec.get(dayIdAndLeaderId.get(dayId)).IsEmailBounced){
                                    
                                        String s = String.valueOf(dayIdAndRec.get(dayId).AcctSeed__Date__c);
                                        String dayDate = s.split('-')[1]+'/'+s.split('-')[2]+'/'+s.split('-')[0];
                                    
                                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                        if(orgWideEmailId != null) {
                                            mail.setOrgWideEmailAddressId(orgWideEmailId);
                                        }
                                        mail.setTargetObjectId(dayIdAndLeaderId.get(dayId));
                                        mail.setWhatID(dayId);
                                        
                                        mail.subject = 'DLS Timekeeping – Your instructor has submitted a time entry for a late cancellation your approval for ' + dayDate + ' for '+ dayIdAndRec.get(dayId).DLS_Class__c;
                                        
                                        String weekRange = dayIdAndRec.get(dayId).Time_Card_Period_Week_Range_Format__c;
                                        String projId = dayIdAndRec.get(dayId).AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
                                        String insId = dayIdAndRec.get(dayId).AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
                                        String urlRedirectToStdPage = '<a href="'+ System.Label.Student_Community_Site_Prefix +'/s/time-approval?week='+ weekRange + '&projectId='+ projId + '&instructorId='+ insId + '" target="_blank"> Click Here </a>';
                                        
                                        String htmlBody = '';
                                        htmlBody += 'Hi '+ conIdRec.get(dayIdAndLeaderId.get(dayId)).Name + ', <br/><br/>';
                                        htmlBody += 'This is a request to review and approve or reject the time entry that your instructor '+ dayIdAndRec.get(dayId).Instructor_Name__c +' recently submitted for your class on '+ dayDate + ' from ' + dayIdAndRec.get(dayId).Start_Time1__c +' to '+ dayIdAndRec.get(dayId).End_Time1__c;
                                        htmlBody += '. Please go to the Time Approval Page - '+ urlRedirectToStdPage +'  to approve or reject this time.<br/><br/>';
                                        htmlBody += 'The late cancellation reason provided by the instructor: ' + dayIdAndRec.get(dayId).Cancellation_Reason__c;
                                        htmlBody += '<br/><br/>Thank you,<br/><br/>DLS Accounting Department<br/>System Generated Email';
                
                                        mail.setHtmlBody(htmlBody);
                                        mail.setSaveAsActivity(TRUE);
                                        emailToStudentList.add(mail);
                                    }else {
                                
                                        mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(dayIdAndLeaderId.get(dayId)).Id+'" target="_blank">'+conIdRec.get(dayIdAndLeaderId.get(dayId)).Name+'</a><br/>';
                                        hasBouncedEmail = TRUE;
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
                        emailToStudentList.add(bouncedmail);
                    }

                    if(emailToStudentList.size() > 0) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToStudentList);
                    }
                }catch(Exception e) {
                    
                    ErrorHandler errHandler = new ErrorHandler();
                    errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Daily Time Entry Approval Request for Students for Late Cancellation');
                } 
            }
        }
    }
    
    */
    //Method to return Time Card Day Id and Its corresponding Student Leader Id  
    public static Map<Id, Id> getClassLeaderforTCD(Set<Id> dayIds,Boolean checkBothTAP){
        
        Map<Id, Id> dayIdAndLeaderId = new Map<Id, Id>();
                
        if(dayIds.size() > 0){
            
            Map<Id, List<AcctSeed__Time_Card_Day__c>> projIdAndDays = new Map<Id, List<AcctSeed__Time_Card_Day__c>>();
            Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects', 'ESL_LT_Projects'};
            Set<Date> tcdDateRanges = new Set<Date>();
            
            for(AcctSeed__Time_Card_Day__c day : 
                [
                    SELECT Id, AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, 
                        AcctSeed__Date__c, Late_Cancellation__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName
                    FROM AcctSeed__Time_Card_Day__c 
                    WHERE Id IN :dayIds AND Project_Task_Type__c != 'Preparation time' AND (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'Candidate' 
                        OR (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'DLS_Employee' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Active_DLS_Employee__c = TRUE))
                        AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName IN :projRTDevNames AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.No_Student_Approval__c = FALSE
                ]
            ){
            
                if(!projIdAndDays.containsKey(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c)){
                    projIdAndDays.put(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, new List<AcctSeed__Time_Card_Day__c>());
                }
                projIdAndDays.get(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c).add(day);
                tcdDateRanges.add(day.AcctSeed__Date__c);
            }
            
            if(projIdAndDays.size() > 0){
                
                Date weekStartDate;
                Date weekEndDate;
                
                Map<Id, Id> projIdAndLeader = getProjIdAndLeaderId(projIdAndDays.keySet(), tcdDateRanges, FALSE, weekStartDate, weekEndDate,checkBothTAP);
                System.debug(':::projIdAndLeader::::'+projIdAndLeader);
                
                Set<Date> pdoDates = new Set<Date>();
                
                // Added for Work Item : W-003066 - Create DLI-W Planned Days Off records automatically for all Active DLI-W LT Projects
                for(Planned_Days_Off__c p : [SELECT Id, Date__c 
                    FROM Planned_Days_Off__c
                    WHERE RecordType.DeveloperName = 'DLI_W_LT_Training_Holidays' AND Project__c = NULL AND Contact__c = NULL
                        AND Opportunity__c = NULL AND Date__c IN : tcdDateRanges AND Type__c = 'DLI-W LT'
                ]){
                    pdoDates.add(p.Date__c);
                }
                System.debug(':::pdoDates::::'+pdoDates);
                
                if(projIdAndLeader != NULL && projIdAndLeader.size() > 0){
                                        
                    for(Id projId : projIdAndDays.keySet()){
                    
                        for(AcctSeed__Time_Card_Day__c day : projIdAndDays.get(projId)){
                        
                            if(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName != 'DLI_W_LT_Projects' 
                                || (day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName == 'DLI_W_LT_Projects' 
                                    && (!pdoDates.contains(day.AcctSeed__Date__c) || (pdoDates.contains(day.AcctSeed__Date__c) && day.Late_Cancellation__c == FALSE)))){
                            
                                if(projIdAndLeader.containsKey(projId)){
                                    dayIdAndLeaderId.put(day.Id, projIdAndLeader.get(projId));
                                }
                            }
                        }
                    }
                }
            }
        }
        classLeaderIds.addAll(dayIdAndLeaderId.values());
        System.debug('classLeaderIds====='+classLeaderIds.size());
        return dayIdAndLeaderId;
    }
    
    /**************************************************************************
    - Added getClassLeaderforTCD method for LTS Approval page usage
    - When there is no time entry we need to display the student names based on event dates
    - Added by NS on Feb 20 2020
    ****************************************************************************/
    public static Map<Id, Id> getClassLeaderforLTSApproval(Set<Id> eventIds,Boolean checkBothTAP){
        
        Map<Id, Id> eventIdAndLeaderId = new Map<Id, Id>();
                
        if(eventIds.size() > 0){
            
            Map<Id, List<Events__c>> projIdAndEvents = new Map<Id, List<Events__c>>();
            Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects', 'ESL_LT_Projects'};
            Set<Date> eventDateRanges = new Set<Date>();
            
            for(Events__c eve : [SELECT Id,Project__c,Instructor__c,Date__c,Project__r.RecordType.DeveloperName
                                    FROM Events__c 
                                    WHERE Id IN :eventIds AND Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time' 
                                            AND (Instructor__r.RecordType.DeveloperName = 'Candidate' OR (Instructor__r.RecordType.DeveloperName = 'DLS_Employee' AND Instructor__r.Active_DLS_Employee__c = TRUE))
                                            AND Project__r.RecordType.DeveloperName IN :projRTDevNames AND Project__r.No_Student_Approval__c = FALSE]){
                
                if(!projIdAndEvents.containsKey(eve.Project__c)){
                    projIdAndEvents.put(eve.Project__c, new List<Events__c>());
                }
                projIdAndEvents.get(eve.Project__c).add(eve);
                eventDateRanges.add(eve.Date__c);
                
            }
            
            if(projIdAndEvents.size() > 0){
                
                Date weekStartDate;
                Date weekEndDate;
                
                Map<Id, Id> projIdAndLeader = getProjIdAndLeaderId(projIdAndEvents.keySet(), eventDateRanges, FALSE, weekStartDate, weekEndDate,checkBothTAP);
                System.debug(':::projIdAndLeader::::'+projIdAndLeader);
                
                Set<Date> pdoDates = new Set<Date>();
                
                // Added for Work Item : W-003066 - Create DLI-W Planned Days Off records automatically for all Active DLI-W LT Projects
                for(Planned_Days_Off__c p : [SELECT Id, Date__c 
                    FROM Planned_Days_Off__c
                    WHERE RecordType.DeveloperName = 'DLI_W_LT_Training_Holidays' AND Project__c = NULL AND Contact__c = NULL
                        AND Opportunity__c = NULL AND Date__c IN : eventDateRanges AND Type__c = 'DLI-W LT'
                ]){
                    pdoDates.add(p.Date__c);
                }
                System.debug(':::pdoDates::::'+pdoDates);
                
                if(projIdAndLeader != NULL && projIdAndLeader.size() > 0){
                                        
                    for(Id projId : projIdAndEvents.keySet()){
                    
                        for(Events__c eve : projIdAndEvents.get(projId)){
                        
                            if(eve.Project__r.RecordType.DeveloperName != 'DLI_W_LT_Projects' 
                                || (eve.Project__r.RecordType.DeveloperName == 'DLI_W_LT_Projects' 
                                    && !pdoDates.contains(eve.Date__c))){
                            
                                if(projIdAndLeader.containsKey(projId)){
                                    eventIdAndLeaderId.put(eve.Id, projIdAndLeader.get(projId));
                                }
                            }
                        }
                    }
                }
            }
        }
        system.debug(':::::::::eventIdAndLeaderId::::'+eventIdAndLeaderId);
        return eventIdAndLeaderId;
    }
    
    /****************
        - Added by HL
        - Work Item : W-001480
        - To send an Email to Student
        - An Email notification to Student When Instructor edits Time Entry - "re-approve / new approve "
        - HTML Body
    ******************************/
    
    public static void reORnewApprovalRequestToStudent(List<AcctSeed__Time_Card_Day__c> newDayRecs, Map<Id,AcctSeed__Time_Card_Day__c> oldDayRecs){
    
        Set<Id> dayIds = new Set<Id>();
        Map<String, String> fieldLabelAndfieldvalue = new Map<String, String>();
        Map<Id, Map<String, String>> dayIdAndfieldNamefieldValue = new Map<Id, Map<String, String>>();
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType daySchema = schemaMap.get('AcctSeed__Time_Card_Day__c');
        Map<String, Schema.SObjectField> fieldMap = daySchema.getDescribe().fields.getMap();
        Set<String> fieldAPINames = new Set<String>{'acctseed__date__c', 'end_time1__c', 'end_time2__c', 'acctseed__hours__c', 'acctseed__internal_comment__c', 'late_cancellation__c', 'recall_reason__c', 'start_time1__c', 'start_time2__c', 'student_approval_status__c', 'total_hours_before_approved__c', 'status__c'};
                
        for (AcctSeed__Time_Card_Day__c day : newDayRecs) {
                            
            if(day.Late_Cancellation__c == FALSE && ((day.Student_Approval_Status__c == 'Submitted' && oldDayRecs.get(day.Id).Student_Approval_Status__c != day.Student_Approval_Status__c) ||
                //(day.Student_Approval_Status__c == 'Submitted' && oldDayRecs.get(day.Id).Student_Approval_Status__c == day.Student_Approval_Status__c &&
                //(day.Status__c == 'Submitted' && oldDayRecs.get(day.Id).Status__c != day.Status__c ))
                (day.Student_Approval_Status__c == 'Submitted' && oldDayRecs.get(day.Id).Total_Hours_Before_Approved__c != day.Total_Hours_Before_Approved__c))
            ){
            
                dayIds.add(day.Id);
                                
                AcctSeed__Time_Card_Day__c newDay = day;
                AcctSeed__Time_Card_Day__c oldDay = oldDayRecs.get(day.Id);
    
                for (String fieldName: fieldMap.keySet()) {
    
                    if(fieldAPINames.contains(fieldName)){
                                            
                        try {                             
                            String oldAndNewvalue = '';
                            if(newDay.get(fieldName) != oldDay.get(fieldName)){ 
                                
                                oldAndNewvalue = oldDay.get(fieldName) + ','+ newDay.get(fieldName);
                                fieldLabelAndfieldvalue.put(fieldMap.get(fieldName).getDescribe().getLabel(), oldAndNewvalue);
                            } 
                        } catch (Exception e) { 
                            System.debug('Error: ' + e); 
                        } 
                    }
                }
                
                if(fieldLabelAndfieldvalue.size() > 0){
                
                    if(!dayIdAndfieldNamefieldValue.containsKey(day.Id)){
                        dayIdAndfieldNamefieldValue.put(day.Id, new Map<String, String>());
                    }
                    dayIdAndfieldNamefieldValue.get(day.Id).putAll(fieldLabelAndfieldvalue);
                }
            }
        }
        
        if(dayIds.size() > 0){
                    
            Map<Id, Id> dayIdAndLeaderId = getClassLeaderforTCD(dayIds,false);
            classLeaderIds.addAll(dayIdAndLeaderId.values());
            System.debug('classLeaderIds====='+classLeaderIds.size());
                        
            if(dayIdAndLeaderId != NULL && dayIdAndLeaderId.size() > 0){
                
                Map<Id, Contact> conRecMap = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :dayIdAndLeaderId.values() AND Email != NULL]);
                
                List<Messaging.SingleEmailMessage> emailToStudentList = new List<Messaging.SingleEmailMessage>();
                
                Map<Id, AcctSeed__Time_Card_Day__c> dayIdAndRec = new Map<Id, AcctSeed__Time_Card_Day__c>([
                    SELECT Id, AcctSeed__Date__c, Instructor_Name__c, 
                        Time_Card_Period_Week_Range_Format__c, Total_Hours_Before_Approved__c,
                        AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName,
                        AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c 
                    FROM AcctSeed__Time_Card_Day__c 
                    WHERE Id IN :dayIdAndLeaderId.keySet()]);
                
                // Work Item : W-006419 - Add "No Student Approval" to the Event Edit Page
                Map<Id, Boolean> tcdIdAndNoStdApprovalFlag = timeCardRelated_Email_Controller.tcdIdAndNoStdApprovalFlag(dayIdAndLeaderId.keySet());
                System.debug('::::tcdIdAndNoStdApprovalFlag::::::'+tcdIdAndNoStdApprovalFlag);

                try{
                    
                    List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
            
                    String orgWideEmailId = '';
                    
                    if(orgWideEmail != null && orgWideEmail.size() > 0){
                        orgWideEmailId = orgWideEmail[0].Id;
                    }
                    
                    String mailContent = '<html>Hi Chris, April and Nafisa <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                    Boolean hasBouncedEmail = FALSE;
                                 
                    for(Id dayId : dayIdAndLeaderId.keySet()){
                        
                        if(tcdIdAndNoStdApprovalFlag != NULL && tcdIdAndNoStdApprovalFlag.containsKey(dayId) && !tcdIdAndNoStdApprovalFlag.get(dayId)){
                        
                            // Work Item : W-004360 - No email to student for 0 hours - non-DODA
                            if(dayIdAndRec.containsKey(dayId) && 
                                (dayIdAndRec.get(dayId).AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName == 'DODA_Projects' || 
                                (dayIdAndRec.get(dayId).AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName != 'DODA_Projects' && 
                                dayIdAndRec.get(dayId).Total_Hours_Before_Approved__c > 0))){
                            
                                if(conRecMap.containsKey(dayIdAndLeaderId.get(dayId))){
                                
                                    if(!conRecMap.get(dayIdAndLeaderId.get(dayId)).IsEmailBounced){
                                    
                                        String s = String.valueOf(dayIdAndRec.get(dayId).AcctSeed__Date__c);
                                        String dayDate = s.split('-')[1]+'/'+s.split('-')[2]+'/'+s.split('-')[0];
                                        
                                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                        if(orgWideEmailId != null) {
                                            mail.setOrgWideEmailAddressId(orgWideEmailId);
                                        }
                                        mail.setTargetObjectId(dayIdAndLeaderId.get(dayId));
                                        mail.setWhatID(dayId);
                                        mail.subject = 'Your instructor '+dayIdAndRec.get(dayId).Instructor_Name__c+' has edited a time entry for '+dayDate+'. Please approve or reject';
                                        
                                        String weekRange = dayIdAndRec.get(dayId).Time_Card_Period_Week_Range_Format__c;
                                        String projId = dayIdAndRec.get(dayId).AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
                                        String insId = dayIdAndRec.get(dayId).AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
                                        String urlRedirectToStdPage = '<a href="'+ System.Label.Student_Community_Site_Prefix +'/s/time-approval?week='+ weekRange + '&projectId='+ projId + '&instructorId='+ insId + '" target="_blank"> Click Here </a>';
                                        
                                        String htmlBody = '';
                                        htmlBody = 'Hi ' +conRecMap.get(dayIdAndLeaderId.get(dayId)).Name+',<br/><br/><br/>';
                                        htmlBody += dayIdAndRec.get(dayId).Instructor_Name__c+' has edited a time entry for '+dayDate+'. Below are the details of the change: <br/><br/>';
                                        htmlBody += '<table border="1" style="border-collapse: collapse"><tr><th width="25%" style="text-align: center; vertical-align: middle;">Field Label</th><th width="25%" style="text-align: center; vertical-align: middle;">Old Value</th><th width="25%" style="text-align: center; vertical-align: middle;">New Value</th></tr>';
                                        
                                        //Table of fields that were changed with the old value and new value
                                        
                                        if(dayIdAndfieldNamefieldValue.containsKey(dayId)){
                                        
                                            for(String label : dayIdAndfieldNamefieldValue.get(dayId).keySet()){
                                            
                                                String fieldvalue = dayIdAndfieldNamefieldValue.get(dayId).get(label);
                                                htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + label  + '</td><td style="text-align: center; vertical-align: middle;">' + fieldvalue.split(',')[0] + '</td><td style="text-align: center; vertical-align: middle;">' + fieldvalue.split(',')[1] + '</td></tr>';
                                            }
                                        }
                                        htmlBody += '</table><br/>';
                                        htmlBody += 'Please '+ urlRedirectToStdPage +'  to approve or reject the time entry.<br/><br/>';
                                        htmlBody += 'Thank you,<br/><br/>DLS Timekeeping<br/>System Generated Email<br/>';
                                        mail.setHtmlBody(htmlBody);
                                        mail.setSaveAsActivity(true);
                                        emailToStudentList.add(mail);
                                    }else {
                                
                                        mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conRecMap.get(dayIdAndLeaderId.get(dayId)).Id+'" target="_blank">'+conRecMap.get(dayIdAndLeaderId.get(dayId)).Name+'</a><br/>';
                                        hasBouncedEmail = TRUE;
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
                        emailToStudentList.add(bouncedmail);
                    }
                    
                    if(emailToStudentList.size() > 0) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToStudentList);
                    }
                }catch(Exception e) {
                    
                    ErrorHandler errHandler = new ErrorHandler();
                    errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Daily Time Entry Approval Request for Students for Re/New Approval Request');
                } 
            }
        }
    }
    
    /****************
        - Added by HL
        - Work Item : W-001558
        - To send an Email to Instructor
        - An email notification to instructor when student reject the "time card day"
        - HTML Body
    ******************************/
    
    public static void studentRejectionNotification(List<AcctSeed__Time_Card_Day__c> newDays, Map<Id, AcctSeed__Time_Card_Day__c> oldDays){
    
        Set<Id> dayIds = new Set<Id>();
                
        for(AcctSeed__Time_Card_Day__c day : newDays){
        
            if(day.Late_Cancellation__c == FALSE && day.Student_Approval_Status__c != oldDays.get(day.Id).Student_Approval_Status__c && day.Student_Approval_Status__c == 'Rejected'){
            
                dayIds.add(day.Id);
            }
        }
        
        if(dayIds.size() > 0){
        
            Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects', 'ESL_LT_Projects'};
            
            Map<Id, Id> dayIdAndInsId = new Map<Id, Id>();
            Map<Id, AcctSeed__Time_Card_Day__c> dayIdAndRec = new Map<Id, AcctSeed__Time_Card_Day__c>();
                        
            for(AcctSeed__Time_Card_Day__c day : [
                SELECT Id, AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, DLS_Class__c,
                    AcctSeed__Date__c, Time_Card_Period_Week_Range_Format__c 
                FROM AcctSeed__Time_Card_Day__c 
                WHERE Id IN :dayIds AND Project_Task_Type__c != 'Preparation time' AND (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'Candidate' 
                    OR (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'DLS_Employee' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Active_DLS_Employee__c = TRUE)) 
                    AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName IN :projRTDevNames
            ]){
            
                dayIdAndInsId.put(day.Id, day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c);
                dayIdAndRec.put(day.Id, day);
            }
            
            if(dayIdAndInsId.size() > 0){
            
                Map<Id, Contact> conRecMap = new Map<Id, Contact>([SELECT Id, Name, Email, RecordType.DeveloperName FROM Contact WHERE Id IN :dayIdAndInsId.values() AND Email != NULL AND Id IN (SELECT Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Paper_Timesheet__c = FALSE)]);
                Map<Id, Events__c> dayIdAndEveRec = new Map<Id, Events__c>();
                
                for(Events__c e : [SELECT Id, Date__c, End_Time__c, Time_Card_Day__c FROM Events__c WHERE Time_Card_Day__c IN :dayIdAndInsId.keySet()]){
                    dayIdAndEveRec.put(e.Time_Card_Day__c, e);
                }
                
                if(conRecMap.size() > 0){
                
                    String stdName = UserInfo.getFirstName()+' '+ UserInfo.getLastName().LEFT(1);
                    List<Messaging.SingleEmailMessage> emailToInstructors = new List<Messaging.SingleEmailMessage>();
                
                    try{
                        
                        List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
                
                        String orgWideEmailId = '';
                        
                        if(orgWideEmail != null && orgWideEmail.size() > 0){
                            orgWideEmailId = orgWideEmail[0].Id;
                        }
                                                                    
                        for(Id dayId : dayIdAndInsId.keySet()){
                        
                            String s = String.valueOf(dayIdAndRec.get(dayId).AcctSeed__Date__c);
                            String dayDate = s.split('-')[1]+'/'+s.split('-')[2]+'/'+s.split('-')[0];
                            
                            String ss;
                            String endTime;
                            if(dayIdAndEveRec.containsKey(dayId)){
                                ss = String.valueOf(dayIdAndEveRec.get(dayId).Date__c);
                                endTime = dayIdAndEveRec.get(dayId).End_Time__c;
                            }else{
                                ss = String.valueOf(dayIdAndRec.get(dayId).AcctSeed__Date__c);
                                endTime = '';
                            }
                            String eveDate = ss.split('-')[1]+'/'+ss.split('-')[2]+'/'+ss.split('-')[0];
                                                        
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            if(orgWideEmailId != null) {
                                mail.setOrgWideEmailAddressId(orgWideEmailId);
                            }
                            mail.setTargetObjectId(dayIdAndInsId.get(dayId));
                            mail.subject = 'DLS Timekeeping – A student has rejected your time entry for '+dayDate+ ' for '+ dayIdAndRec.get(dayId).DLS_Class__c;
                            
                            String weekRange = dayIdAndRec.get(dayId).Time_Card_Period_Week_Range_Format__c;
                            String projId = dayIdAndRec.get(dayId).AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
                            String urlRedirectToInsPage = '';
                            
                            if(conRecMap.get(dayIdAndInsId.get(dayId)).RecordType.DeveloperName == 'Candidate'){
                                urlRedirectToInsPage = '<a href="'+ System.Label.Instructor_Community_Site_Prefix+'/s/instructor-time-entry?week='+ weekRange + '&projectId='+ projId + '" target="_blank"> Click Here </a>';
                            }
                            
                            if(conRecMap.get(dayIdAndInsId.get(dayId)).RecordType.DeveloperName == 'DLS_Employee'){
                                urlRedirectToInsPage = '<a href="'+ System.Label.Org_Prefix_Start_URL+'/lightning/n/'+ System.Label.Internal_Instructor_Time_Entry+'?c__week='+ weekRange + '&c__projectId='+ projId + '" target="_blank"> Click Here </a>';
                            }
                            
                            String htmlBody = '';
                            htmlBody += 'Hi ' +conRecMap.get(dayIdAndInsId.get(dayId)).Name+',<br/><br/><br/>';
                            htmlBody += 'Student '+stdName+' rejected the time entry you recorded for '+dayDate+' for '+dayIdAndRec.get(dayId).DLS_Class__c+' to enter your time for the class that ended '+eveDate+' @ '+endTime+'. ';
                            htmlBody += 'Please go to the Time Entry Page - '+ urlRedirectToInsPage+'  to correct your time entry.<br/><br/>';
                            htmlBody += 'Thank you,<br/><br/>DLS Accounting Department<br/>System Generated Email<br/>';
                            mail.setHtmlBody(htmlBody);
                            mail.setSaveAsActivity(true);
                            emailToInstructors.add(mail);
                        }
                        
                        if(emailToInstructors.size() > 0) {
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToInstructors);
                        }
                    }catch(Exception e) {
                        
                        ErrorHandler errHandler = new ErrorHandler();
                        errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Instructor notification when Student Reject the Time Entry');
                    } 
                }
            }
        }
    }
    
    /****************
        - Added by HL
        - Work Item : W-001558
        - To send an Email to Instructor
        - An email notification to instructor Immediately upon LTS / Supervisor Submit action when all entries are approved
        - HTML Body
    ******************************/
    //Added on Jan 21 2022 - W-007342 - Update Instructor Time Approval Email and Budget Columns in DLS Online
    public static void weeklyApprovedNotificationToInstructor(List<AcctSeed__Time_Card_Day__c> newDays, Map<Id, AcctSeed__Time_Card_Day__c> oldDays){
    
        if(newDays.size() > 0){
                        
            Set<Id> insIds = new Set<Id>();      
            Set<Id> lineIds = new Set<Id>();      
            String weekStartDate;
            String weekEndDate;
            String dlsClass;
            String allStudents;
            String supervisorName;
                        
            for(AcctSeed__Time_Card_Day__c day : [
                SELECT Id, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, DLS_Class__c, AcctSeed__Time_Card_Line__c, 
                    AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c,
                    AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c,
                    AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Students__c, AcctSeed__Hours__c,
                    AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Project_Manager__r.Name
                FROM AcctSeed__Time_Card_Day__c 
                WHERE Id IN :newDays AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'Candidate' AND Status__c = 'Approved']){
            
                insIds.add(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c);
                weekStartDate = String.valueOf(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c);
                weekEndDate = String.valueOf(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c);
                dlsClass = day.DLS_Class__c;
                allStudents = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Students__c;
                lineIds.add(day.AcctSeed__Time_Card_Line__c);
                supervisorName = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Project_Manager__r.Name;
            }
            
            if(insIds.size() > 0){
            
                Map<Id, Contact> conRecMap = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :insIds AND Email != NULL AND Id IN (SELECT Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Paper_Timesheet__c = FALSE)]);
                
                if(conRecMap.size() > 0){
                
                    String tcpWkStart = weekStartDate.split('-')[1]+'/'+weekStartDate.split('-')[2]+'/'+weekStartDate.split('-')[0];
                    String tcpWkEnd = weekEndDate.split('-')[1]+'/'+weekEndDate.split('-')[2]+'/'+weekEndDate.split('-')[0];
                    
                    String todayDate = String.valueOf(Date.Today());
                    String todayStr = todayDate.split('-')[1]+'/'+todayDate.split('-')[2]+'/'+todayDate.split('-')[0];

                    List<Messaging.SingleEmailMessage> emailToInstructors = new List<Messaging.SingleEmailMessage>();
                    
                    String mailContent = '<html>Hi Chris, April and Nafisa <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                    Boolean hasBouncedEmail = false;
                
                    try{
                        
                        List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
                
                        String orgWideEmailId = '';
                        
                        if(orgWideEmail != null && orgWideEmail.size() > 0){
                            orgWideEmailId = orgWideEmail[0].Id;
                        }
                                                                    
                        for(Id conId : conRecMap.keySet()){
                            
                            if(!conRecMap.get(conId).IsEmailBounced){
                                  
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                if(orgWideEmailId != null) {
                                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                                }
                                mail.setTargetObjectId(conId);
                                mail.subject = 'DLS Timekeeping – your supervisor has approved your timesheet for '+dlsClass+' for '+tcpWkStart+' to '+tcpWkEnd;
                                String htmlBody = '';
                                htmlBody += 'Hi ' +conRecMap.get(conId).Name+',<br/><br/>';
                                htmlBody += 'This is a courtesy notification to inform you that your supervisor '+supervisorName+' has approved your timesheet for Class #:'+dlsClass+' for the period '+tcpWkStart+' to '+tcpWkEnd+' with Student(s): ' + allStudents + '. No further action is required.<br/><br/>';
                                htmlBody += 'Thank you,<br/><br/>DLS Accounting Department<br/>System Generated Email<br/>';
                                mail.setHtmlBody(htmlBody);
                                mail.setSaveAsActivity(true);
                                emailToInstructors.add(mail);
                            }else {
                    
                                mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conRecMap.get(conId).Id+'" target="_blank">'+conRecMap.get(conId).Name+'</a><br/>';
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
                            emailToInstructors.add(bouncedmail);
                        }
                        
                        if(emailToInstructors.size() > 0) {
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToInstructors);
                        }
                    }catch(Exception e) {
                    
                        ErrorHandler errHandler = new ErrorHandler();
                        String errorMessage = 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                        errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Weekly Approved Notification To Instructor');
                    } 
                }
            }
        }
    }
    /*
    @future // To fix the issue related to "SendEmail failed. UNABLE_TO_LOCK_ROW"
    public static void weeklyApprovedNotificationToInstructor(Map<Id, Date> projtaskIdAndLastModifiedDate){
    
        if(projtaskIdAndLastModifiedDate.size() > 0){
            
            Set<Id> insIds = new Set<Id>();      
            Set<Id> lineIds = new Set<Id>();      
            String weekStartDate;
            String weekEndDate;
            
            Map<String, String> insIdDLSClassAndallStd = new Map<String, String>();
            Map<Id, Decimal> tclIdAndHousUsed = new Map<Id, Decimal>();
            
            Map<String, String> insIdDLSClassAndSupervisor = new Map<String, String>();
            // Work Item: W-007190 - Changes to Testing Project Time Approval Process
            Map<String, String> insIdDLSClassAndProjRTName = new Map<String, String>();
            Set<String> conIdsAndSubjects = new Set<String>();
            
            // Work Item: W-007182 - Stopping multiple system e-mails for UAE instructors
            for(Task t : [SELECT Id, WhoId, Description, Subject FROM Task WHERE Subject LIKE '%your supervisor has approved your timesheet%' AND CreatedDate = TODAY]){
                if(t.Description.contains('This is a courtesy notification to')){
                    String conIdAndSubject = t.WhoId+'-'+t.Subject;
                    conIdsAndSubjects.add(conIdAndSubject);
                }    
            }   
                     
            for(AcctSeed__Time_Card_Day__c day : [SELECT Id, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, DLS_Class__c, AcctSeed__Time_Card_Line__c, 
                                                        AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c,
                                                        AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c,
                                                        AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Students__c, AcctSeed__Hours__c, LastModifiedDate,
                                                        AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Project_Manager__r.Name, AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Project_Record_Type_Name__c
                                                    FROM AcctSeed__Time_Card_Day__c 
                                                    WHERE LastModifiedDate = TODAY AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'Candidate' AND 
                                                        Status__c = 'Approved' AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c IN : projtaskIdAndLastModifiedDate.keySet()]){
            
                if(projtaskIdAndLastModifiedDate.containsKey(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c) && 
                    projtaskIdAndLastModifiedDate.get(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c) == Date.valueOf(day.LastModifiedDate)){
                                                            
                        insIds.add(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c);
                        weekStartDate = String.valueOf(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c);
                        weekEndDate = String.valueOf(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c);
                        lineIds.add(day.AcctSeed__Time_Card_Line__c);
                    
                        String insIdAndDLSClass = day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c+'-'+day.DLS_Class__c;
                        if(!insIdDLSClassAndallStd.containsKey(insIdAndDLSClass)){
                            insIdDLSClassAndallStd.put(insIdAndDLSClass, day.AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.AcctSeed__Project__r.Students__c);
                            insIdDLSClassAndSupervisor.put(insIdAndDLSClass, day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Project_Manager__r.Name);
                            insIdDLSClassAndProjRTName.put(insIdAndDLSClass, day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.Project_Record_Type_Name__c);
                        }
                }                                            
            }            
            
            if(insIds.size() > 0){
            
                Map<Id, Contact> conRecMap = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :insIds AND Email != NULL AND Id IN (SELECT Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Paper_Timesheet__c = FALSE)]);
                Map<Id, List<AcctSeed__Time_Card_Line__c>> insIdAndLines = new Map<Id, List<AcctSeed__Time_Card_Line__c>>();
                
                for(AcctSeed__Time_Card_Line__c l : [SELECT Id, AcctSeed__Time_Card__r.Intructor__c, AcctSeed__Project_Task__r.Name, AcctSeed__Project_Task__r.LastModifiedDate,
                        AcctSeed__Project_Task__r.Total_Qty_Planned__c, AcctSeed__Project_Task__r.Total_Qty_Used__c, AcctSeed__Project_Task__r.Total_Qty_Paid_Remaining__c
                    FROM AcctSeed__Time_Card_Line__c
                    WHERE Id IN : lineIds
                ]){
                
                    if(!insIdAndLines.containsKey(l.AcctSeed__Time_Card__r.Intructor__c)){
                        insIdAndLines.put(l.AcctSeed__Time_Card__r.Intructor__c, new List<AcctSeed__Time_Card_Line__c>());
                    }
                    insIdAndLines.get(l.AcctSeed__Time_Card__r.Intructor__c).add(l);
                }
                
                if(conRecMap.size() > 0){
                
                    String tcpWkStart = weekStartDate.split('-')[1]+'/'+weekStartDate.split('-')[2]+'/'+weekStartDate.split('-')[0];
                    String tcpWkEnd = weekEndDate.split('-')[1]+'/'+weekEndDate.split('-')[2]+'/'+weekEndDate.split('-')[0];
                    
                    String todayDate = String.valueOf(Date.Today());
                    String todayStr = todayDate.split('-')[1]+'/'+todayDate.split('-')[2]+'/'+todayDate.split('-')[0];

                    List<Messaging.SingleEmailMessage> emailToInstructors = new List<Messaging.SingleEmailMessage>();
                    
                    String mailContent = '<html>Hi Chris, April and Nafisa <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                    Boolean hasBouncedEmail = false;
                
                    try{
                        
                        List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
                
                        String orgWideEmailId = '';
                        
                        if(orgWideEmail != null && orgWideEmail.size() > 0){
                            orgWideEmailId = orgWideEmail[0].Id;
                        }
                                                                    
                        for(String insIdDLSClass : insIdDLSClassAndallStd.keySet()){
                        
                            Id conId = insIdDLSClass.split('-')[0];
                            String dlsClass = insIdDLSClass.split('-')[1];
                            String supervisorName = insIdDLSClassAndSupervisor.get(insIdDLSClass);
                            
                            if(conRecMap.containsKey(conId)){
                            
                                if(!conRecMap.get(conId).IsEmailBounced){
                                      
                                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                    if(orgWideEmailId != null) {
                                        mail.setOrgWideEmailAddressId(orgWideEmailId);
                                    }
                                    mail.setTargetObjectId(conId);
                                    mail.subject = 'DLS Timekeeping – your supervisor has approved your timesheet for '+dlsClass+' for '+tcpWkStart+' to '+tcpWkEnd;
                                    String conIdAndSubject = conId+'-'+mail.subject; 
                                    if(!conIdsAndSubjects.contains(conIdAndSubject)){
                                        String htmlBody = '';
                                        htmlBody += 'Hi ' +conRecMap.get(conId).Name+',<br/><br/>';
                                        htmlBody += 'This is a courtesy notification to inform you that your supervisor '+supervisorName+' has approved your timesheet for '+dlsClass+' for the period '+tcpWkStart+' to '+tcpWkEnd+'. No further action is required.<br/><br/>';
                                        if(insIdDLSClassAndProjRTName.get(insIdDLSClass) != 'Testing_Projects'){
                                            htmlBody += 'Below is the current balance for DLS Class # '+ dlsClass + ' with Students: ' + insIdDLSClassAndallStd.get(insIdDLSClass) + ' as of '+ todayStr + '.<br/>';
                                        
                                            if(insIdAndLines.containsKey(conId)){
                                            
                                                htmlBody += '<br/><table border="1" style="border-collapse: collapse"><tr><th width="25%" style="text-align: center; vertical-align: middle;">Project Task</th><th width="25%" style="text-align: center; vertical-align: middle;">Hours Planned</th><th width="25%" style="text-align: center; vertical-align: middle;">Hours Used</th><th width="25%" style="text-align: center; vertical-align: middle;">Hours Paid Remaining</th></tr>';
                                                for(AcctSeed__Time_Card_Line__c l : insIdAndLines.get(conId)){
                                                    
                                                    htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + l.AcctSeed__Project_Task__r.Name  + '</td><td style="text-align: center; vertical-align: middle;">' + l.AcctSeed__Project_Task__r.Total_Qty_Planned__c + '</td><td style="text-align: center; vertical-align: middle;">' + l.AcctSeed__Project_Task__r.Total_Qty_Used__c + '</td><td style="text-align: center; vertical-align: middle;">' + l.AcctSeed__Project_Task__r.Total_Qty_Paid_Remaining__c + '</td></tr>';    
                                                }
                                                htmlBody += '</table><br/>';
                                            }
                                        }
                                        htmlBody += 'Thank you,<br/><br/>DLS Accounting Department<br/>System Generated Email<br/>';
                                        mail.setHtmlBody(htmlBody);
                                        mail.setSaveAsActivity(true);
                                        emailToInstructors.add(mail);
                                    }
                                }else {
                        
                                    mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conRecMap.get(conId).Id+'" target="_blank">'+conRecMap.get(conId).Name+'</a><br/>';
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
                            emailToInstructors.add(bouncedmail);
                        }
                        
                        if(emailToInstructors.size() > 0) {
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToInstructors);
                        }
                    }catch(Exception e) {
                    
                        ErrorHandler errHandler = new ErrorHandler();
                        errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Weekly Approved Notification To Instructor');
                    } 
                }
            }
        }
    }
    */
    /****************
        - Added by HL
        - Work Item : W-001558
        - To send an Email to Instructor
        - An email notification to instructor when LTS / Supervisor Submit action when all entries are Rejected
        - HTML Body
    ******************************/
    public static void weeklyRejectionNotificationtoInstructor(List<AcctSeed__Time_Card_Day__c> newDays, Map<Id, AcctSeed__Time_Card_Day__c> oldDays){
    
        Map<Id,String> tcdIdNoteType = new Map<Id,String>();
        Set<Id> dayIds = new Set<Id>();
        
        //Get the static map value from Event Reconciliation Controller
        if(tcdIdNoteType.size() == 0){
            tcdIdNoteType = EventReconciliationController.tcdIdNoteType;
        }
        
        for(AcctSeed__Time_Card_Day__c day : newDays){
        
            if(day.Late_Cancellation__c == FALSE && tcdIdNoteType.containsKey(day.Id) && tcdIdNoteType.get(day.Id) == 'Weekly Reject' && day.Status__c == 'Rejected' && day.Status__c != oldDays.get(day.Id).Status__c ){
            
                dayIds.add(day.Id);
            }
        }
        
        if(dayIds.size() > 0){
        
            Map<Id, List<AcctSeed__Time_Card_Day__c>> insIdAndRejectedDays = new Map<Id, List<AcctSeed__Time_Card_Day__c>>();
            Set<Id> insIds = new Set<Id>();            
            String weekStartDate;
            String weekEndDate;
            String dlsClass;
            String tcpWKRangeFormat;
            String projId;
            
            for(AcctSeed__Time_Card_Day__c day : [
                SELECT Id, AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, DLS_Class__c, AcctSeed__Invoice_Comment__c, AcctSeed__Date__c, 
                    AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c, Project_Task_Name__c,
                    AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c, Total_Hours_Before_Approved__c, Time_Card_Period_Week_Range_Format__c, 
                    AcctSeed__Time_Card_Line__r.AcctSeed__Project__c
                FROM AcctSeed__Time_Card_Day__c 
                WHERE Id IN :dayIds AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = 'Candidate' 
                    AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__c != NULL AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c != NULL
            ]){
            
                insIds.add(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c);
                weekStartDate = String.valueOf(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__Start_Date__c);
                weekEndDate = String.valueOf(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.AcctSeed__Time_Card_Period__r.AcctSeed__End_Date__c);
                dlsClass = day.DLS_Class__c;
                tcpWKRangeFormat = day.Time_Card_Period_Week_Range_Format__c;
                projId = day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
                
                if(!insIdAndRejectedDays.containsKey(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c)){
                    insIdAndRejectedDays.put(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, new List<AcctSeed__Time_Card_Day__c>());
                }
                insIdAndRejectedDays.get(day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c).add(day);
            }
            
            if(insIds.size() > 0){
            
                Map<Id, Contact> conRecMap = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :insIds AND Email != NULL AND Id IN (SELECT Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor' AND Paper_Timesheet__c = FALSE)]);
                
                if(conRecMap.size() > 0){
                
                    String supervisorName = UserInfo.getFirstName()+' '+ UserInfo.getLastName();
                    String tcpWkStart = weekStartDate.split('-')[1]+'/'+weekStartDate.split('-')[2]+'/'+weekStartDate.split('-')[0];
                    String tcpWkEnd = weekEndDate.split('-')[1]+'/'+weekEndDate.split('-')[2]+'/'+weekEndDate.split('-')[0];
                    
                    List<Messaging.SingleEmailMessage> emailToInstructors = new List<Messaging.SingleEmailMessage>();
                    
                    String mailContent = '<html>Hi Chris, April and Nafisa <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                    Boolean hasBouncedEmail = false;
                    
                    try{
                        
                        List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
                
                        String orgWideEmailId = '';
                        
                        if(orgWideEmail != null && orgWideEmail.size() > 0){
                            orgWideEmailId = orgWideEmail[0].Id;
                        }
                                                                    
                        for(Id conId : conRecMap.keySet()){
                        
                            if(!conRecMap.get(conId).IsEmailBounced){
                                                        
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                if(orgWideEmailId != null) {
                                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                                }
                                mail.setTargetObjectId(conId);
                                mail.subject = 'DLS Timekeeping – your supervisor has rejected your timesheet for '+dlsClass+' for '+tcpWkStart+' to '+tcpWkEnd;
                                
                                String htmlBody = '';
                                htmlBody += 'Hi ' +conRecMap.get(conId).Name+',<br/><br/>';
                                htmlBody += 'Your supervisor '+supervisorName+' has rejected your timesheet for the period '+tcpWkStart+' to '+tcpWkEnd+'. Below are the specific entries your supervisor has rejected and the reason for each rejection.';
                                htmlBody += 'Please go to the Time Entry Page - <a href="'+System.Label.Instructor_Community_Site_Prefix+'/s/instructor-time-entry?week='+ tcpWKRangeFormat + '&projectId='+ projId +'" target="_blank"> Click Here </a>  to correct these time entries and resubmit your timesheet. If you have any questions, please contact your supervisor.<br/>';
                                htmlBody += '<br/><table border="1" style="border-collapse: collapse"><tr><th width="25%" style="text-align: center; vertical-align: middle;">Date</th><th width="25%" style="text-align: center; vertical-align: middle;">Project Task</th><th width="25%" style="text-align: center; vertical-align: middle;">Hours</th><th width="25%" style="text-align: center; vertical-align: middle;">Reason for Rejection</th></tr>';
                                
                                for(AcctSeed__Time_Card_Day__c dayRec : insIdAndRejectedDays.get(conId)){
                                
                                    String dayDate = String.valueOf(dayRec.AcctSeed__Date__c);
                                    String dayDateStr = dayDate.split('-')[1]+'/'+dayDate.split('-')[2]+'/'+dayDate.split('-')[0];
                                    String projTask = dayRec.Project_Task_Name__c;
                                    String hours = String.valueOf(dayRec.Total_Hours_Before_Approved__c);
                                    String reasonForRejection = dayRec.AcctSeed__Invoice_Comment__c;
                                    htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + dayDateStr  + '</td><td style="text-align: center; vertical-align: middle;">' + projTask + '</td><td style="text-align: center; vertical-align: middle;">' + hours + '</td><td style="text-align: center; vertical-align: middle;">' + reasonForRejection + '</td></tr>';
                                }
                                htmlBody += '</table><br/><br/>';
                                htmlBody += 'Thank you,<br/><br/>DLS Accounting Department<br/>System Generated Email<br/>';
                                mail.setHtmlBody(htmlBody);
                                mail.setSaveAsActivity(true);
                                emailToInstructors.add(mail);
                            }else {
                    
                                mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conRecMap.get(conId).Id+'" target="_blank">'+conRecMap.get(conId).Name+'</a><br/>';
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
                            emailToInstructors.add(bouncedmail);
                        }
                        
                        if(emailToInstructors.size() > 0) {
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToInstructors);
                        }
                    }catch(Exception e) {
                        
                        ErrorHandler errHandler = new ErrorHandler();
                        errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Weekly Rejection Notification to Instructor');
                    } 
                }
            }
        }
    }
    
    /**************
        - Added by HL on Nov 05 2019
        - Method to return Project Id And Its Leader Id
        - TAP - Time Approval Preference
        *****************/
    public static Map<Id, Id> getProjIdAndLeaderId(Set<Id> projIds, Set<Date> tcdDateRanges, Boolean isWeeklyTAP, Date weekStartDate, Date weekEndDate,Boolean checkBothTAP){
    
        Map<Id, Id> projIdAndLeaderId  = new Map<Id, Id>();
        
        Map<Id, List<Contact_Assignments__c>> projIdAndLeaders = new Map<Id, List<Contact_Assignments__c>>();
        Map<Id, List<Contact_Assignments__c>> projIdAndAllStds = new Map<Id, List<Contact_Assignments__c>>();
        
        Map<Id, Boolean> projIdAndIsLeadAbsent = new Map<Id, Boolean>();
        Map<Id, Id> projIdAndStdId = new Map<Id, Id>();
        Set<Id> stdIds = new Set<Id>();
        
        Map<Id, Boolean> stdIdAndIsOff = new Map<Id, Boolean>();
        Map<Id, Map<Id, Boolean>> stdIdAndProjIdAndIsOff = new Map<Id, Map<Id, Boolean>>();
        
        String conAssignQry = 'SELECT Id, Candidate_Name__c, Assignment_Position__c, Project__c ';
        conAssignQry += 'FROM Contact_Assignments__c ';
        conAssignQry += 'WHERE Project__c IN :projIds AND RecordType.DeveloperName = \'Student\' AND Status__c = \'Active\' ';
        conAssignQry += 'AND Candidate_Name__c !=  NULL AND Candidate_Name__r.Email != NULL ';
        
        //To check both preference on LTS Approval page Send Reminder button usage
        if(checkBothTAP){
        
            conAssignQry += 'AND Time_Approval_Preference__c IN (\'Weekly\',\'Daily\') ';
            
        }else {
            
            if(isWeeklyTAP){
                conAssignQry += 'AND Time_Approval_Preference__c = \'Weekly\' ';
            }else{
                conAssignQry += 'AND Time_Approval_Preference__c = \'Daily\' ';
            }
        }
        
        conAssignQry += 'ORDER BY CreatedDate DESC';
        
        List<Contact_Assignments__c> contactAssignments = Database.Query(conAssignQry);
        System.debug(':::contactAssignments:::::::'+contactAssignments);
        
        for(Contact_Assignments__c c : contactAssignments){
        
            if(c.Assignment_Position__c == 'Class Leader'){
            
                if(!projIdAndLeaders.containsKey(c.Project__c)){
                    projIdAndLeaders.put(c.Project__c, new List<Contact_Assignments__c>());
                }
                projIdAndLeaders.get(c.Project__c).add(c);
            }
            if(!projIdAndAllStds.containsKey(c.Project__c)){
                projIdAndAllStds.put(c.Project__c, new List<Contact_Assignments__c>());
            }
            projIdAndAllStds.get(c.Project__c).add(c);
            stdIds.add(c.Candidate_Name__c);
        }
        System.debug('::stdIds:::'+stdIds);
        
        if(stdIds.size() > 0){
        
            String pdoQry = 'SELECT Id, Contact__c, Project__c, All_Projects__c ';
            pdoQry += 'FROM Planned_Days_Off__c ';
            pdoQry += 'WHERE Contact__c IN :stdIds AND Status__c = \'Approved\' AND RecordType.DeveloperName != \'Request\' ';
            
            if(isWeeklyTAP){
                pdoQry += 'AND Date__c >= :weekStartDate AND Date__c <= :weekEndDate ';
            }else{
                pdoQry += 'AND Date__c IN : tcdDateRanges ';
            }
            
            List<Planned_Days_Off__c> plannedDaysOff = Database.Query(pdoQry);
            
            for(Planned_Days_Off__c pdo : plannedDaysOff){
                          
                if(pdo.Project__c == NULL && pdo.All_Projects__c){
                
                    if(!stdIdAndIsOff.containsKey(pdo.Contact__c)){
                        stdIdAndIsOff.put(pdo.Contact__c, TRUE);
                    }
                }
                
                if(pdo.Project__c != NULL ){
                
                    if(!stdIdAndProjIdAndIsOff.containsKey(pdo.Contact__c)){
                        stdIdAndProjIdAndIsOff.put(pdo.Contact__c, new Map<Id, Boolean>());
                    }
                    stdIdAndProjIdAndIsOff.get(pdo.Contact__c).put(pdo.Project__c, TRUE);
                }
            }
            
            for(Id proId : projIds){
            
                if(projIdAndLeaders.containsKey(proId)){
                    // Here one record will come, because each project can have only one class leader
                    for(Contact_Assignments__c c  : projIdAndLeaders.get(proId)){
                        
                        if(stdIdAndIsOff.containsKey(c.Candidate_Name__c) || (stdIdAndProjIdAndIsOff.containsKey(c.Candidate_Name__c) && stdIdAndProjIdAndIsOff.get(c.Candidate_Name__c).containsKey(c.Project__c))){
                            projIdAndIsLeadAbsent.put(proId, TRUE);
                        }else{
                            projIdAndIsLeadAbsent.put(proId, FALSE);
                        }
                    }
                }
            }
            System.debug('::::projIdAndIsLeadAbsent:::'+projIdAndIsLeadAbsent);
            
            for(Id proId : projIds){
            
                if(projIdAndAllStds.containsKey(proId)){
                                        
                    for(Contact_Assignments__c c : projIdAndAllStds.get(proId)){
                    
                        if(c.Assignment_Position__c != 'Class Leader'){
                            
                            if(!stdIdAndIsOff.containsKey(c.Candidate_Name__c) && 
                                (!stdIdAndProjIdAndIsOff.containsKey(c.Candidate_Name__c) || 
                                    (stdIdAndProjIdAndIsOff.containsKey(c.Candidate_Name__c) &&
                                     !stdIdAndProjIdAndIsOff.get(c.Candidate_Name__c).containsKey(c.Project__c)))
                             ){                                    
                                projIdAndStdId.put(proId, c.Candidate_Name__c);
                                break;
                            }
                        }
                    }
                }
            }
            
            String leaderId = '';
            
            for(Id proId : projIds){
            
                if(projIdAndAllStds.containsKey(proId)){
                
                    if(projIdAndAllStds.get(proId).size() == 1){
                    
                        leaderId = projIdAndAllStds.get(proId)[0].Candidate_Name__c;
                        projIdAndLeaderId.put(proId, leaderId);
                        
                    }else if(projIdAndAllStds.get(proId).size() > 1){
                    
                        if(projIdAndIsLeadAbsent.containsKey(proId)){
                            
                            if(projIdAndIsLeadAbsent.get(proId) == TRUE){            // Class Leader is absent, So can take the next most recently created Active Student Contact Assignment 
                            
                                if(projIdAndStdId.containsKey(proId)){
                                
                                    leaderId = projIdAndStdId.get(proId);
                                    projIdAndLeaderId.put(proId, leaderId);
                                }
                            }else{
                            
                                if(projIdAndLeaders.containsKey(proId)){
                                
                                    leaderId = projIdAndLeaders.get(proId)[0].Candidate_Name__c;
                                    projIdAndLeaderId.put(proId, leaderId);
                                }
                            }
                        }
                    }
                }
            }
        }
        System.debug(':::projIdAndLeaderId::::'+projIdAndLeaderId);
        return projIdAndLeaderId;
    }
    
    /*********
        - Added by HL on Oct 22 2019
        - Work Item : W-002922 - Student Time Approval Preferences (Daily, Weekly, No Approval)
        - The Instructor Submits their Timesheet without Completing it first
        ***********/
    public static void sendEmailToStd(Set<Id> tcdIds){
        
        // W-004948 - Student Receiving "Reminder to Approve" emails after approving timesheet
        Boolean isCompleted = [SELECT Id, AcctSeed__Time_Card_Line__r.Completed__c FROM AcctSeed__Time_Card_Day__c WHERE Id IN : tcdIds LIMIT 1].AcctSeed__Time_Card_Line__r.Completed__c;
        timeCardRelated_Email_Controller.sendAnEmailToStudent(tcdIds, isCompleted);
    }
    
    /***************
        - Generic method to send an email to student
        - This method is called from timeCardRelated_Email_Controller, WeeklyTimeEntryRequestToStudent_Schedule, WeeklyTimeEntryReminderToStd_Schedule
        - Added by HL on Oct 21 2019
        - Work Item : W-002922 - Student Time Approval Preferences (Daily, Weekly, No Approval)
        - To send an email notification to student if they select "Weekly" Time Approval Preferences
        *************/
    public static void sendAnEmailToStudent(Set<Id> tcdIds, Boolean isCompleted){
    
        Boolean isGroupAction;
        String groupActionType;
                
        isGroupAction = InstructorTimeSubmitCtrl.isGroupAction != NULL ? InstructorTimeSubmitCtrl.isGroupAction:FALSE;
        groupActionType = InstructorTimeSubmitCtrl.groupActionType; 
        
        if(tcdIds.size() > 0 && isCompleted != NULL){
        
            Set<String> projRTDevNames = new Set<String>{'DODA_Projects', 'Language_Training_Projects', 'DLI_W_LT_Projects', 'ESL_LT_Projects'};
            
            String tcdQueryStr = 'SELECT Id, AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.DLS_Class__c, ';
            tcdQueryStr += 'Student_Approval_Status__c, Status__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__r.Project_Task_Type__c, Instructor_Name__c, AcctSeed__Date__c, ';
            tcdQueryStr += 'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c, Time_Card_Period_Week_Range_Format__c ';
            tcdQueryStr += 'FROM AcctSeed__Time_Card_Day__c ';
            tcdQueryStr += 'WHERE Id IN :tcdIds AND Project_Task_Type__c != \'Preparation time\' AND (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'Candidate\' OR (AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'DLS_Employee\' AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Active_DLS_Employee__c = TRUE)) ';
            tcdQueryStr += 'AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.RecordType.DeveloperName IN : projRTDevNames AND AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.No_Student_Approval__c = FALSE ';
            tcdQueryStr += 'AND Student_Approval_Status__c = \'Submitted\' ';
            if(isCompleted){
                tcdQueryStr += 'AND AcctSeed__Time_Card_Line__r.Completed__c = TRUE ';
            }else{
                tcdQueryStr += 'AND AcctSeed__Time_Card_Line__r.Completed__c = FALSE ';
            }
            
            if(isGroupAction != NULL && isGroupAction && groupActionType != NULL && groupActionType == 'Submitted'){
    
                tcdQueryStr += 'AND Status__c = \'Submitted\' ';
            }
            /*else{
                tcdQueryStr += 'AND Status__c != \'Submitted\' ';
            }
            */
            System.debug(':::::tcdQueryStr::::'+tcdQueryStr);
            
            List<AcctSeed__Time_Card_Day__c> days = Database.query(tcdQueryStr);
            System.debug('::::days::::::'+days);
            System.debug('::::days:: SIZE::::'+days.size());
            
            if(days.size() > 0){
            
                Map<Id, List<AcctSeed__Time_Card_Day__c>> projIdAndDays = new Map<Id, List<AcctSeed__Time_Card_Day__c>>();
                Map<Id,AcctSeed__Time_Card_Day__c> dayIdRecMap = new Map<Id,AcctSeed__Time_Card_Day__c>();
                Map<Id, String> projIdAndClassNo = new Map<Id, String>();
                Map<Id,Id> proIdInstructorId = new Map<Id,Id>();
                
                Map<Id, AcctSeed__Time_Card_Day__c> tcdMap = new Map<Id, AcctSeed__Time_Card_Day__c>(days);
                // Work Item : W-006419 - Add "No Student Approval" to the Event Edit Page
                Map<Id, Boolean> tcdIdAndNoStdApprovalFlag = timeCardRelated_Email_Controller.tcdIdAndNoStdApprovalFlag(tcdMap.keySet());
                System.debug('::::tcdIdAndNoStdApprovalFlag::::::'+tcdIdAndNoStdApprovalFlag);
                
                String instructorName = '';
                String weekRange = '';
                String instructorId = '';
                
                for(AcctSeed__Time_Card_Day__c day : days){
                
                    if(tcdIdAndNoStdApprovalFlag != NULL && tcdIdAndNoStdApprovalFlag.containsKey(day.Id) && !tcdIdAndNoStdApprovalFlag.get(day.Id)){
                    
                        if(!projIdAndDays.containsKey(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c)){
                            projIdAndDays.put(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, new List<AcctSeed__Time_Card_Day__c>());
                        }
                        projIdAndDays.get(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c).add(day);
                        
                        if(!dayIdRecMap.containsKey(day.Id)){
                            dayIdRecMap.put(day.Id,day);
                        }
                        
                        projIdAndClassNo.put(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__r.DLS_Class__c);
                        
                        if(!proIdInstructorId.containsKey(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c)){
                            proIdInstructorId.put(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c,day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c);
                        }
                        
                        //instructorName = day.Instructor_Name__c;
                        weekRange = day.Time_Card_Period_Week_Range_Format__c;
                        //instructorId = day.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c;
                    }
                }
                
                if(projIdAndDays.size() > 0){
                                    
                    String stDateVal = weekRange.split(' ')[0]; 
                    String edDateVal = weekRange.split(' ')[2];   
                                             
                    Date startOfWeekDate = Date.parse(stDateVal); 
                    Date endOfWeekDate = Date.parse(edDateVal); 
                    Map<Id, Id> projIdAndLeader = getProjIdAndLeaderId(projIdAndDays.keySet(), new Set<Date>(), TRUE, startOfWeekDate, endOfWeekDate, false);
                                        
                    if(projIdAndLeader != NULL && projIdAndLeader.size() > 0){
                                        
                        Map<String, Set<Id>> stdIdProjIdAndDays = new Map<String, Set<Id>>();
                        Map<Id, Id> dayIdAndLeaderId = new Map<Id, Id>();
                        
                        for(Id projId : projIdAndDays.keySet()){
                        
                            for(AcctSeed__Time_Card_Day__c day : projIdAndDays.get(projId)){
                            
                                if(projIdAndLeader.containsKey(projId)){
                                    dayIdAndLeaderId.put(day.Id, projIdAndLeader.get(projId));
                                    
                                    String stdIdProjId = projIdAndLeader.get(projId)+'-'+projId;
                                    
                                    if(!stdIdProjIdAndDays.containsKey(stdIdProjId)){
                                        stdIdProjIdAndDays.put(stdIdProjId, new Set<Id>{day.Id});
                                    }else {
                                        stdIdProjIdAndDays.get(stdIdProjId).add(day.Id);
                                    }
                                }
                            }
                        }
                        System.debug(':::stdIdProjIdAndDays::::'+stdIdProjIdAndDays);
                        System.debug(':::stdIdProjIdAndDays::: SIZE::::'+stdIdProjIdAndDays.size());
                        
                        Map<Id,Contact> studentIdRecMap = new Map<Id,Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :dayIdAndLeaderId.values()]);
                        
                        try{
                            
                            String weekStr = '';
                            String dateVal = weekRange.split(' ')[0];                            
                            Date startOfWeek = Date.parse(dateVal);                            
                            Date currentWeekStart = System.today().toStartofWeek().addDays(1);
                            
                            if(startOfWeek == currentWeekStart){
                                weekStr = 'current';
                            }else{
                                weekStr = 'previous';
                            }
                            
                            String dlsClassNo = '';                            
            
                            String mailContent = '<html>Hi Chris, April and Nafisa <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                            Boolean hasBouncedEmail = FALSE;
                            
                            List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
                
                            String orgWideEmailId = '';
                            
                            if(orgWideEmail != null && orgWideEmail.size() > 0){
                                orgWideEmailId = orgWideEmail[0].Id;
                            }
                        
                            List<Messaging.SingleEmailMessage> emailSendToStds = new List<Messaging.SingleEmailMessage>();
                            
                            for(String s : stdIdProjIdAndDays.keySet()){
                            
                                Id stdId = s.split('-')[0];
                                Id projId = s.split('-')[1];
                                
                                if(studentIdRecMap.containsKey(stdId)){
                                
                                    if(!studentIdRecMap.get(stdId).IsEmailBounced){
                                    
                                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                        if(orgWideEmailId != null) {
                                            mail.setOrgWideEmailAddressId(orgWideEmailId);
                                        }
                                        mail.setTargetObjectId(stdId);
                                        
                                        if(projIdAndClassNo.containsKey(projId)){
                                            dlsClassNo = projIdAndClassNo.get(projId);
                                        }
                                        
                                        String insId = '';
                                        if(proIdInstructorId.containsKey(projId)){
                                            insId = proIdInstructorId.get(projId);
                                        }
                                        
                                        mail.subject = 'DLS Timekeeping - Reminder to approve all instructor time entries for DLS Class #: '+dlsClassNo+' for the '+ weekStr+' week';
                                        
                                        String htmlBody = '';
                                        htmlBody += 'Hi '+studentIdRecMap.get(stdId).Name+ ', <br/><br/>';
                            
                                        String urlRedirectToStdPage = '<a href="'+ System.Label.Student_Community_Site_Prefix +'/s/time-approval?week='+weekRange+'&projectId='+projId+'&instructorId='+insId+'" target="_blank"> Click Here </a>';
                                        
                                        htmlBody += 'This is a reminder to review and approve or reject the instructor time entries your instructor recently submitted for your class. ';
                                        htmlBody += 'Please go to the Time Approval Page - '+ urlRedirectToStdPage +' to approve or reject these time entries.<br/><br/>';
                                        
                                        htmlBody += '<table border="1" style="border-collapse: collapse"><tr>';
                                        htmlBody += '<th width="25%" style="text-align: center; vertical-align: middle;">Class #</th>';
                                        htmlBody += '<th width="50%" style="text-align: center; vertical-align: middle;">Instructor Name</th>';
                                        htmlBody += '<th width="25%" style="text-align: center; vertical-align: middle;">Date</th></tr>';
                            
                                        for(Id dayId : stdIdProjIdAndDays.get(s)){
                                        
                                            Date dayDt = dayIdRecMap.get(dayId).AcctSeed__Date__c;
                                            String dt = String.valueOf(dayDt).split('-')[1]+'/'+String.valueOf(dayDt).split('-')[2]+'/'+String.valueOf(dayDt).split('-')[0];
                                            
                                            htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">'+dlsClassNo+'</td><td style="text-align: center; vertical-align: middle;">'+dayIdRecMap.get(dayId).Instructor_Name__c+'</td><td style="text-align: center; vertical-align: middle;">'+dt+'</td></tr>';
                                        }
                                        
                                        htmlBody += '</table><br/><br/>';
                                        htmlBody += 'If you have any questions or require any assistance, please contact your LTS or reply to timesheets@dlsdc.com to get help.<br/><br/>';
                                        htmlBody += 'Thank you,<br/><br/>DLS Accounting Department<br/>System Generated Email';
                                        
                                        mail.setHtmlBody(htmlBody);
                                        mail.setSaveAsActivity(TRUE);
                                        emailSendToStds.add(mail);                                                
                                    }else {
                    
                                        mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+studentIdRecMap.get(stdId).Id+'" target="_blank">'+studentIdRecMap.get(stdId).Name+'</a><br/>';
                                        hasBouncedEmail = TRUE;
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
                                emailSendToStds.add(bouncedmail);
                            }
                            System.debug(':::::::emailSendToStds:::'+emailSendToStds);
            
                            if(emailSendToStds != NULL && emailSendToStds.size() > 0){
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailSendToStds);
                            }
                        
                        }catch(Exception e) {
                            
                            String errorMessage = '';
                            errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                            
                            ErrorHandler errHandler = new ErrorHandler();
                            errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Sending Notification to Students If they select "Weekly" Time Approval Preference');
                        } 
                    }
                }
            }
        }
    }
    
    // Added By HL on Jan 29 2021
    // Method to return TCD Id and Its related event record
    public static Map<Id, Boolean> tcdIdAndNoStdApprovalFlag(Set<Id> tcdIds){
        
        Map<Id, Boolean> tcdIdAndNoStdAppFlag = new Map<Id, Boolean>();
        
        if(tcdIds != NULL && tcdIds.size() > 0){
        
            for(Id tcdId : tcdIds){
                tcdIdAndNoStdAppFlag.put(tcdId, false);
            }

            for(Events__c eve : [SELECT Id, Time_Card_Day__c, No_Student_Approval__c
                                    FROM Events__c 
                                    WHERE Time_Card_Day__c IN : tcdIds ORDER BY CreatedDate DESC]){
                                    
                
                    tcdIdAndNoStdAppFlag.put(eve.Time_Card_Day__c, eve.No_Student_Approval__c);                
            }            
        }
        return tcdIdAndNoStdAppFlag;
    }
    
    /***************
        - Generic method to send an email to student
        - This method is called from WeeklyStudentHoursApprovalRequest and WeeklyStudentHoursApprovalReminder schedulers
        - Added by HL on Apr 27 2022
        - Work Item: W-007441 - Student Timekeeping Approval Reminder and Process Changes (4.20.22)
        *************/
    public static void sendStudentHoursEmail(List<Attendance__c> attendanceRecs, String type){
    
        if(attendanceRecs != null && attendanceRecs.size() > 0){
        
            Set<Date> attendaceDates = new Set<Date>();
            Set<Id> tcdIds = new Set<Id>();
            Set<Date> pdoDates = new Set<Date>();
            Map<String, List<Attendance__c>> stdIdProjIdAndAttendanceRecs = new Map<String, List<Attendance__c>>();
            Set<Id> studentIds = new Set<Id>();
            
            for(Attendance__c a : attendanceRecs){
            
                String stdIdProjId = a.Student__c+'~'+a.Time_Card_Day__r.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c;
                attendaceDates.add(a.Date__c);
                tcdIds.add(a.Time_Card_Day__c);
                if(!stdIdProjIdAndAttendanceRecs.containsKey(stdIdProjId)){
                    stdIdProjIdAndAttendanceRecs.put(stdIdProjId, new List<Attendance__c>());
                }
                stdIdProjIdAndAttendanceRecs.get(stdIdProjId).add(a);
                studentIds.add(a.Student__c);
            }
            
             for(Planned_Days_Off__c p : [SELECT Id, Date__c 
                FROM Planned_Days_Off__c
                WHERE RecordType.DeveloperName = 'DLI_W_LT_Training_Holidays' AND Project__c = NULL AND Contact__c = NULL
                    AND Opportunity__c = NULL AND Date__c IN : attendaceDates AND Type__c = 'DLI-W LT'
            ]){
                pdoDates.add(p.Date__c);
            }
            
            Map<Id, Boolean> tcdIdAndNoStdApprovalFlag = timeCardRelated_Email_Controller.tcdIdAndNoStdApprovalFlag(tcdIds);
            System.debug('::::tcdIdAndNoStdApprovalFlag::::::'+tcdIdAndNoStdApprovalFlag);
            
            try{
                
                String mailContent = '<html>Hi Chris and April <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                Boolean hasBouncedEmail = FALSE;
                            
                Map<Id,Contact> studentIdRecMap = new Map<Id,Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :studentIds]);
                
                List<Messaging.SingleEmailMessage> emailToStudentList = new List<Messaging.SingleEmailMessage>();
                
                List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Timesheet'];
        
                String orgWideEmailId = '';
                
                if(orgWideEmail != null && orgWideEmail.size() > 0){
                    orgWideEmailId = orgWideEmail[0].Id;
                }
                                
                for(String stdIdProjId : stdIdProjIdAndAttendanceRecs.keySet()){
                    
                    Id studId = stdIdProjId.split('~')[0];
                    if(studentIdRecMap.containsKey(studId)){
                                
                        if(!studentIdRecMap.get(studId).IsEmailBounced){
                                    
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            if(orgWideEmailId != NULL) {
                                mail.setOrgWideEmailAddressId(orgWideEmailId);
                            }
                            mail.setTargetObjectId(studId);
                            
                            Attendance__c attendanceRec = stdIdProjIdAndAttendanceRecs.get(stdIdProjId)[0];
                            
                            String dlsClassNo = attendanceRec.DLS_Class__c;  
                            String weekRange = attendanceRec.Time_Card_Day__r.Time_Card_Period_Week_Range_Format__c;
                            
                            String weekStr = '';
                            String dateVal = weekRange.split(' ')[0];                            
                            Date startOfWeek = Date.parse(dateVal);    
                            Date currentWeekStart = System.today().toStartofWeek().addDays(1);                        
                            
                            if(startOfWeek == currentWeekStart){
                                weekStr = 'this';
                            }else{
                                weekStr = 'the previous';
                            }
                            
                            mail.subject = 'DLS Timekeeping - Reminder to approve all student time entries for DLS Class #: '+dlsClassNo+' for '+ weekStr+' week';
                            String htmlBody = '';
                            htmlBody += 'Hi '+ attendanceRec.Student__r.Name + ', <br/><br/>';
                            
                            String urlRedirectToStdPage = '<a href="'+ System.Label.Student_Community_Site_Prefix +'/s/time-approval?week='+weekRange+'&projectId='+stdIdProjId.split('~')[1]+'&instructorId='+attendanceRec.Instructor__c+'" target="_blank"> Click Here </a>'; 
                            
                            htmlBody += 'This is a reminder to review and approve or reject the student time entries your instructor recently submitted for your class. ';
                            htmlBody += 'Please go to the Time Approval Page - '+ urlRedirectToStdPage +' to approve or reject these time entries.<br/><br/>';
                            
                            htmlBody += '<table border="1" style="border-collapse: collapse"><tr>';
                            htmlBody += '<th width="25%" style="text-align: center; vertical-align: middle;">Class #</th>';
                            htmlBody += '<th width="50%" style="text-align: center; vertical-align: middle;">Instructor Name</th>';
                            htmlBody += '<th width="25%" style="text-align: center; vertical-align: middle;">Date</th></tr>';
                                            
                            for(Attendance__c a : stdIdProjIdAndAttendanceRecs.get(stdIdProjId)){
                            
                                if(tcdIdAndNoStdApprovalFlag != NULL && tcdIdAndNoStdApprovalFlag.containsKey(a.Time_Card_Day__c) && 
                                    !tcdIdAndNoStdApprovalFlag.get(a.Time_Card_Day__c)){
                            
                                    if(a.Project_RecordType_Name__c != 'DLI_W_LT_Projects' || (a.Project_RecordType_Name__c == 'DLI_W_LT_Projects' && (!pdoDates.contains(a.Date__c) || (pdoDates.contains(a.Date__c) && a.Late_Cancellation__c == FALSE)))){  
                                        
                                        Date dayDt = a.Date__c;
                                        String dt = String.valueOf(dayDt).split('-')[1]+'/'+String.valueOf(dayDt).split('-')[2]+'/'+String.valueOf(dayDt).split('-')[0];
                                        
                                        htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">'+dlsClassNo+'</td><td style="text-align: center; vertical-align: middle;">'+a.Instructor_Name__c+'</td><td style="text-align: center; vertical-align: middle;">'+dt+'</td></tr>';
                                    }
                                }
                            }   
                            mail.setHtmlBody(htmlBody);
                            mail.setSaveAsActivity(True);
                            emailToStudentList.add(mail);               
                        }else {
                    
                            mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+studentIdRecMap.get(studId).Id+'" target="_blank">'+studentIdRecMap.get(studId).Name+'</a><br/>';
                            hasBouncedEmail = TRUE;
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
                    emailToStudentList.add(bouncedmail);
                }
                //System.debug('::::::emailToStudentList::::::'+emailToStudentList);
        
                if( emailToStudentList != NULL && emailToStudentList.size() > 0 ) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToStudentList);
                }
            }catch(Exception e) {
            
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Weekly Student Hours Approval '+type);  
                
            }
        }
    }
}