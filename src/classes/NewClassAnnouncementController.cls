public with sharing class NewClassAnnouncementController {
    public static Boolean addStaffRecordTypeFilter = false;
    public class EmailContents {
        @AuraEnabled
        public List<OrgWideEmailAddress> orgWideEmailAddress;
        @AuraEnabled
        public Id relatedRecordId;
        @AuraEnabled
        public String relatedRecordName;
        @AuraEnabled
        public String additionalEmailIds;
        @AuraEnabled
        public String ccEmailIds;
        @AuraEnabled
        public String bccEmailIds;
        @AuraEnabled
        public String subject;
        @AuraEnabled
        public String htmlBodyContent;
        @AuraEnabled
        public bodyContent content;
        @AuraEnabled
        public String fromAddress;
        @AuraEnabled
        public List<Contact> toAddressContacts;
        @AuraEnabled
        public String toEmailIds;
        @AuraEnabled
        public User loggedInUser;
        @AuraEnabled public String fromUserName;
    }
    
    public Class bodyContent {
        @AuraEnabled
        public String studentName;
        @AuraEnabled
        public String instructorName;
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String languageName;
        @AuraEnabled
        public String locationName;
        @AuraEnabled
        public String stDate;
        @AuraEnabled
        public String endDate;
        @AuraEnabled
        public String hoursPerWeek;
        @AuraEnabled
        public String countryMap;
        @AuraEnabled
        public String notes;
        @AuraEnabled
        public Decimal materialBudget;
        @AuraEnabled
        public String recordUrl;
        @AuraEnabled
        public List<Schedule__c> scheduleRecords;
    }
    
    @AuraEnabled
    public static EmailContents getRelatedInformation(String projectId){
        EmailContents contentInfo = new EmailContents();
        
        bodyContent bodyContent = new bodyContent();
        bodyContent.recordUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/' + projectId;
        
        // Qry Contact Assignment records to forma the student & isntructor informations
        List<Contact_Assignments__c> caList = [
            SELECT Id, Name, Project__c, RecordTypeId, RecordType.DeveloperName, Candidate_Name__c, Candidate_Name__r.Name 
            FROM Contact_Assignments__c 
            WHERE Project__c = :projectId AND (Status__c = 'Active' OR Status__c = 'Planned') AND (RecordType.Developername = 'Instructor' OR RecordType.Developername = 'Student')
        ];
        String instructorName = '',studentName = '';
        for(Contact_Assignments__c ca : calist){
            if(ca.RecordType.Developername == 'Instructor'){
                if(instructorName != ''){
                    instructorName +=','+ca.Candidate_Name__r.Name;
                }else{
                    instructorName = ca.Candidate_Name__r.Name;
                }
            }
            if(ca.RecordType.Developername == 'Student'){
                if(studentName != ''){
                    studentName +=','+ca.Candidate_Name__r.Name;
                }else{
                    studentName = ca.Candidate_Name__r.Name;
                }
            }
        }
        
         for(AcctSeed__Project__c pr : [SELECT AcctSeed__Account__c, AcctSeed__Account__r.Name, Id, Name, Start_Date__c, End_Date__c, DLS_Class__c, Language__c, Language__r.Name, Students__c, Instructors__c 
                        ,Training_Location__c, Training_Location__r.Name, LTS_Notes__c, Hours_Week__c,Country_Map__c,Material_budget_Budgeted__c, (SELECT Id, Name, Start_Time__c, End_Time__c, Days__c FROM Schedules__r WHERE Project_Task__r.Name != 'Language Training- Preparation')
                        FROM AcctSeed__Project__c 
                            WHERE Id =: projectId
                   ]) {
                   bodyContent.studentName = studentName;
                   bodyContent.instructorName = instructorName;
                   bodyContent.accountName = pr.AcctSeed__Account__c != null ? pr.AcctSeed__Account__r.Name : '';
                   bodyContent.languageName = pr.Language__c != null ? pr.Language__r.Name : '';
                   bodyContent.locationName = pr.Training_Location__c != null ? pr.Training_Location__r.Name : '';
                   bodyContent.stDate = String.valueOf(pr.Start_Date__c).split('-')[1]+'/'+String.valueOf(pr.Start_Date__c).split('-')[2]+'/'+String.valueOf(pr.Start_Date__c).split('-')[0];
                   bodyContent.endDate = String.valueOf(pr.End_Date__c).split('-')[1]+'/'+String.valueOf(pr.End_Date__c).split('-')[2]+'/'+String.valueOf(pr.End_Date__c).split('-')[0];
                   bodyContent.hoursPerWeek = String.ValueOF(pr.Hours_Week__c);
                   bodyContent.notes = pr.LTS_Notes__c;
                   bodyContent.countryMap = pr.Country_Map__c;
                   bodyContent.materialBudget = pr.Material_budget_Budgeted__c;
                   if(pr.Schedules__r != null) {
                       bodyContent.scheduleRecords = pr.Schedules__r;
                   } 
                   contentInfo.relatedRecordId = projectId;
                   contentInfo.relatedRecordName = pr.Name;
             }
           
        System.debug('bodyContent::::'+bodyContent);
        contentInfo.subject = 'New Class Announcement '+bodyContent.studentName+' '+bodyContent.languageName+' starts on '+bodyContent.stDate;
        
        //Qry OWE address
        contentInfo.orgWideEmailAddress = [SELECT Address,DisplayName FROM OrgWideEmailAddress];
        contentInfo.fromAddress = contentInfo.orgWideEmailAddress[0].Id;
        
        List<User> usrRecord = [SELECT Id,Name,Email FROM User WHERE Id = :userinfo.getUserId()];
        contentInfo.loggedInUser = usrRecord[0];
        
        //Get Addtional To & CC email Address from systemvalue custom setting
        System_Values__c sysVal = System_Values__c.getValues('Class Announcement Additional To Ids'); 
        
        if(sysVal != null && sysVal.Value__c != null) {
            contentInfo.additionalEmailIds = sysVal.Value__c;
        }
        
        System_Values__c sysValCC = System_Values__c.getValues('Class Announcement CC Ids'); 
                
        if(sysValCC != null && sysValCC.Value__c != null) {
            contentInfo.ccEmailIds = sysValCC.Value__c;
        }
        
        List<User> logedInUser = [SELECT Id,Email FROM User WHERE Id = :userinfo.getuserid()];
        
        //Qry dls logo image
        List<Document> logoDoc = [SELECT Id,DeveloperName FROM Document WHERE DeveloperName = 'DLS_Logo1'];
        
        Id documentId;
        
        if(logoDoc.size() > 0){
            documentId = logoDoc[0].Id;
        }
        
        Id orgId = UserInfo.getOrganizationId();
        
        contentInfo.bccEmailIds = logedInUser[0].Email;
        contentInfo.content = bodyContent;
        
        //htmlbody content formation
        String htmlBody = '<html><img src="'+URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id=' + documentId+'&oid='+orgId+'" alt="Company Logo"/><br/>';
        htmlBody += '<div>'+bodyContent.studentName+' '+bodyContent.languageName+' starts on '+bodyContent.stDate+'</div>';
        htmlBody += '<a href="'+bodyContent.recordUrl+'" target="_blank">View Project</a>';
        htmlBody += '<div>Student Name: '+bodyContent.studentName+'</div>';
        htmlBody += '<div>Agency/Organization: '+bodyContent.accountName+'</div>';
        htmlBody += '<div>Location: '+bodyContent.locationName+'</div>';
        htmlBody += '<div>Language: '+bodyContent.languageName+'</div>';
        htmlBody += '<div>Instructor: '+bodyContent.instructorName+'</div>';
        htmlBody += '<div >Start Date: '+bodyContent.stDate+'</div>';
        htmlBody += '<div >End Date: '+bodyContent.endDate+'</div>';
        htmlBody += '<div>Hours/Week: '+bodyContent.hoursPerWeek+'</div>';
        htmlBody += '<div>Country Map: '+bodyContent.countryMap+'</div>';
        htmlBody += '<div>Materials Budget: '+bodyContent.materialBudget+'</div>';
        htmlBody += '<div>Notes: '+bodyContent.notes+'</div><br/>';
        
        htmlBody += '<table style="border:0;border-collapse: collapse;width: 75%;"><thead><th style="width:25%;border: 1px solid black;text-align: center;">Days</th><th style="width:25%;border: 1px solid black;text-align: center;">Start Time</th><th style="width:25%;border: 1px solid black;text-align: center;">End Time</th></thead><tbody>';
        
        for(Schedule__c sch : bodyContent.scheduleRecords){
            htmlBody += '<tr style="border: 1px solid black;"><td style="width: 25%;border: 1px solid black;text-align: center;">'+sch.Days__c+'</td><td style="width: 25%;border: 1px solid black;text-align: center;">'+sch.Start_Time__c+'</td><td style="width: 25%;border: 1px solid black;text-align: center;">'+sch.End_Time__c+'</td></td>';
        }
        
        htmlBody += '</tbody></table><br/><html>';
        
        contentInfo.htmlBodyContent = htmlBody;
        
        return contentInfo;
    }
    
    /******************************************************
     - Get Lookup search related records
     - Added by NS on Nov 16 2018
    *******************************************************/
    @AuraEnabled
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(searchString,objectName,fieldName,condition,selectedIds);
    }   
    
    @AuraEnabled
    public static string sendNewClassAnnouncementEmail(String contentJson,String fileName,String contentType,String base64Data){
        
        system.debug(':::::::::::contentJson::::::'+contentJson);
        
        List<EmailContents> contentList = (List<EmailContents>) System.JSON.deserialize(contentJson, List<EmailContents>.class);
        
        EmailContents updatedContentInfo = contentList[0];
        
        system.debug(':::::::::::updatedContentInfo::::::'+updatedContentInfo);
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        Set<String> toEmailIdsList = new Set<String>();
        
        if(updatedContentInfo.toAddressContacts != null && updatedContentInfo.toAddressContacts.size() > 0){
            Set<Id> contactIds = new Set<Id>();
            for(Contact con : updatedContentInfo.toAddressContacts){
                contactIds.add(con.Id);
            }
            for(Contact con : [SELECT Id,Email FROM Contact WHERE Id IN :contactIds]){
                toEmailIdsList.add(con.Email);
            }
        }
        
        if(updatedContentInfo.toEmailIds != null){
            List<String> toIds = updatedContentInfo.toEmailIds.split(';');
            toEmailIdsList.addAll(toIds);
        }
        
        if(updatedContentInfo.additionalEmailIds != null){
            List<String> addtionalAdd = updatedContentInfo.additionalEmailIds.split(';');
            toEmailIdsList.addAll(addtionalAdd);
        }
        
        List<String> toAddressList = new List<String>();
        toAddressList.addAll(toEmailIdsList);
        
        // CC Address
        List<String> ccAddress = new List<String>();
        
        if(updatedContentInfo.ccEmailIds.split(';').size() > 1){
            List<String> address = updatedContentInfo.ccEmailIds.split(';');
            ccAddress.addAll(address);
        }else if(String.isNotBlank(updatedContentInfo.ccEmailIds)){
            ccAddress.add(updatedContentInfo.ccEmailIds);
        }
        
        //BCC Address
        List<String> bccAddress = new List<String>();
        if(updatedContentInfo.bccEmailIds != null && updatedContentInfo.bccEmailIds.contains(';')){
            List<String> address = updatedContentInfo.bccEmailIds.split(';');
            bccAddress.addAll(address);
        }else if(String.isNotBlank(updatedContentInfo.bccEmailIds)){
            bccAddress.add(updatedContentInfo.bccEmailIds);
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setSubject(updatedContentInfo.subject);
        mail.sethtmlBody(updatedContentInfo.htmlBodyContent);
        mail.setToAddresses(toAddressList);
        if(bccAddress.size() > 0){
            mail.setBccAddresses(bccAddress);
        }
        if(ccAddress.size() > 0){
            mail.setCcAddresses(ccAddress);
        } 
        
        //set the Orgwide email id if the selected from address is not equal to logged in user
        if(updatedContentInfo.fromAddress != updatedContentInfo.loggedInUser.Id) {       
            mail.setOrgWideEmailAddressId(updatedContentInfo.fromAddress);
        }
        
        //Add Attachment
        if(base64Data != null && fileName != null) {
            List < Messaging.EmailFileAttachment > attachments = new List < Messaging.EmailFileAttachment > {};
            Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
            base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            attachment.setBody(EncodingUtil.base64Decode(base64Data));
            attachment.setFileName(fileName);
            attachments.add(attachment);
            
            mail.setFileAttachments(attachments);
        }
        
        mailList.add(mail);
        
        try {
            if(mailList.size() > 0 && !Test.isRunningTest()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
            }
            return 'SUCCESS';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*****************************************************************************
     - Method to construct the Email contents for Student Payment Remainder Button in Project
     - Added by NS on Jan 8 2019
    ******************************************************************************/
    @AuraEnabled
    public static EmailContents getStudentPaymentInformation(String projectId,String taskId){
        EmailContents eContents = new EmailContents();
        bodyContent bContent = new bodyContent();
        
        Set<Id> contactIds = new Set<Id>();
        String ccEmailIds = '';
        
        //Qry project related action Student CA to form the To Address values
        for(Contact_Assignments__c ca : [SELECT Id,Candidate_Name__c,Candidate_Name__r.Email,RecordType.DeveloperName FROM Contact_Assignments__c WHERE Project__c = :projectId AND Status__c = 'Active' AND RecordType.DeveloperName IN ('Student','Staff')]){
            if(ca.RecordType.DeveloperName == 'Student'){
                contactIds.add(ca.Candidate_Name__c);   
            }else if(ca.RecordType.DeveloperName == 'Staff'){
                ccEmailIds += ca.Candidate_Name__r.Email+';';
            }       
        }
        system.debug('::::::::::ccEmailIds::::'+ccEmailIds);
        
        //Qry task record to populate the hrs details
        List<AcctSeed__Project_Task__c> taskRecord = [SELECT Id,Name,Total_Qty_Paid__c,Total_Qty_Used__c,Total_Qty_Paid_Remaining__c FROM AcctSeed__Project_Task__c WHERE Id = :taskId];
        
        //Qry current project & task related most recent time card day date
        List<AcctSeed__Time_Card_Day__c> dayRecord = [SELECT Id,AcctSeed__Date__c FROM AcctSeed__Time_Card_Day__c
                                                            WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project__c = :projectId 
                                                                    AND AcctSeed__Time_Card_Line__r.AcctSeed__Project_Task__c = :taskId ORDER BY AcctSeed__Date__c DESC LIMIT 1];
        
        
        String qtyPaid = '';
        String qtyUsed = '';
        String paidRemaining = '';
        String recentTCDDate = '';
        
        if(taskRecord.size() > 0){
            qtyPaid = taskRecord[0].Total_Qty_Paid__c != null ? String.valueOf(taskRecord[0].Total_Qty_Paid__c) : '';
            
            qtyUsed = taskRecord[0].Total_Qty_Used__c != null ? String.valueOf(taskRecord[0].Total_Qty_Used__c) : '';
            
            paidRemaining = taskRecord[0].Total_Qty_Paid_Remaining__c != null ? String.valueOf(taskRecord[0].Total_Qty_Paid_Remaining__c) : '';
            
            if(String.isNotBlank(qtyPaid)){
                qtyPaid += '(Hrs)';
            }
            if(String.isNotBlank(qtyUsed)){
                qtyUsed += '(Hrs)';
            }
            if(String.isNotBlank(paidRemaining)){
                paidRemaining += '(Hrs)';
            }
        }
        
        if(dayRecord.size() > 0){
            String tcdDt = String.valueOf(dayRecord[0].AcctSeed__Date__c);
            recentTCDDate = tcdDt.split('-')[1]+'/'+tcdDt.split('-')[2]+'/'+tcdDt.split('-')[0];
        }
        
        List<Contact> toaddressContacts = [SELECT Id,Name,Email,FirstName FROM Contact WHERE Id IN :contactIds AND Email != null];
        eContents.toAddressContacts = toaddressContacts;
        
        List<AcctSeed__Project__c> projectRec = [SELECT Id,Name FROM AcctSeed__Project__c WHERE Id = :projectId];
        eContents.relatedRecordId = projectId;
        eContents.relatedRecordName = projectRec[0].Name;
        
        eContents.subject = 'Low Balance for Language Training Hours';
        
        List<User> usrRecord = [SELECT Id,Name,Email FROM User WHERE Id = :userinfo.getUserId()];
        eContents.fromAddress = usrRecord[0].Name;
        
        //Get Logged in user related contact record to fill the thank you content dynamically
        List<Contact> currentContact = [SELECT Id,Name,Title,Ext__c FROM Contact WHERE DLS_User__c = :userinfo.getUserId()];
        
        //Get CC email Address from systemvalue custom setting
        System_Values__c sysValCC = System_Values__c.getValues('Student payment remainder CC Ids'); 
                
        if(sysValCC != null && sysValCC.Value__c != null) {
            ccEmailIds += sysValCC.Value__c;
        }
        system.debug('::::::::ccEmailIds::after:CSvalue add::::'+ccEmailIds);
        eContents.ccEmailIds = ccEmailIds;
        
        bContent.studentName = '';
        if(toaddressContacts.size() > 0 && toaddressContacts.size() == 1){
            bContent.studentName = toaddressContacts[0].FirstName;
        }
        
        String conName = '';
        String title = '';
        String extension = '';
        
        if(currentContact.size() > 0){
            conName = currentContact[0].Name;
            title = currentContact[0].Title;
            extension = currentContact[0].Ext__c;
        }
        
        //htmlbody content formation
        String htmlBody = '<html>';
        htmlBody += '<div>Hello '+bContent.studentName+',</div><br/>';
        htmlBody += '<div>This is a reminder regarding payment for additional Language Training hours.</div><br/>';
        
        //Applied project task qty values in the content
        //Modified by NS on Sep 20 2019
        //Work Item no: W-002535
        if(String.isNotBlank(recentTCDDate)) {
            htmlBody += '<div>Below is the current balance as of <b>'+recentTCDDate+'</b></div><br/>';
        }else {
            htmlBody += '<div>Below is the current balance as of <b>*DATE*</b></div><br/>';
        }
        
        if(String.isNotBlank(qtyPaid)){
            htmlBody += '<div><b>Total Paid Hours: '+qtyPaid+'</b></div><br/>';
        }else {
            htmlBody += '<div><b>Total Paid Hours: *PAID*</b></div><br/>';
        }
        
        if(String.isNotBlank(qtyUsed)){
            htmlBody += '<div><b>Total Used Hours: '+qtyUsed+'</b></div><br/>';
        }else {
            htmlBody += '<div><b>Total Used Hours: *USED*</b></div><br/>';
        }
        
        if(String.isNotBlank(paidRemaining)){
        
            if(String.isNotBlank(recentTCDDate)){
                htmlBody += '<div><b>Remaining Hours: '+paidRemaining+'</b> (as of <b>'+recentTCDDate+'</b>)</div><br/>';
            }else {
                htmlBody += '<div><b>Remaining Hours: '+paidRemaining+'</b> (as of <b>*DATE*</b>)</div><br/>';
            }
        }else {
            
            if(String.isNotBlank(recentTCDDate)){
                htmlBody += '<div><b>Remaining Hours: *REMAINING*</b> (as of <b>'+recentTCDDate+'</b>)</div><br/>';
            }else {
                htmlBody += '<div><b>Remaining Hours: *REMAINING*</b> (as of <b>*DATE*</b>)</div><br/>';
            }
        }
        
        htmlBody += '<div>Please be informed that this balance does not reflect any hours that you may have taken this week.</div><br/>';
        //htmlBody += '<div>Please contact me at ext. 142 or please contact a member of the DLS accounting department at ext.119 (Penny) or ext. 146 (Shruti), also copied in this email, to make a payment.</div><br/>';
        // Added By HL on Jan 18 2021
        htmlBody += '<div>Please respond to this email with the exact number of hours you would like to purchase.</div><br/>';
        htmlBody += '<div>After the confirmation on how many hours you would like to purchase:</div><br/>';
        htmlBody += '<div><ul type="disc"><li>We will email the link and invoice.</li><li>Payment should be made through the link within 24 hours.</li>';
        htmlBody += '<li>The link will direct you to a new page to quickly and securely pay with a credit card.</li><li>The credit card receipt will be auto-emailed. This receipt will coincide with the itemized invoice.</li></ul></div><br/>';
        htmlBody += '<div>Please let us know if you have any questions about this process.</div><br/>';
        htmlBody += '<div>We appreciate your business and we hope you are enjoying your class!</div><br/><br/>';
        htmlBody += '<div>Thank you,</div>';
        htmlBody += '<div><b>'+conName+' | '+title+'</b></div>';
        htmlBody += '<div>Diplomatic Language Services<br/>1901 Fort Myer Dr., Ste. 600 | Arlington, VA 22209<br/>o: 703-243-4855 x'+extension+' | f: 703-243-2003 |</div>';
        
        htmlBody += '<html>';
        
        eContents.content = bContent;
        eContents.htmlBodyContent = htmlBody;
        
        return eContents;
    }
        
    /*****************************************************************************
     - Method to send Student Payment Remainder after content correction from user
     - Added by NS on Jan 8 2019
    ******************************************************************************/
    @AuraEnabled
    public static string sendStudentPaymentRemainderEmail(String contentJson){
        List<EmailContents> contentList = (List<EmailContents>) System.JSON.deserialize(contentJson, List<EmailContents>.class);
        EmailContents updatedContentInfo = contentList[0];
        system.debug(':::::::::::updatedContentInfo::::::'+updatedContentInfo);
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        //Form CC Email Address
        List<String> ccAddress = new List<String>();
        
        if(updatedContentInfo.ccEmailIds.split(';').size() > 1){
            List<String> address = updatedContentInfo.ccEmailIds.split(';');
            ccAddress.addAll(address);
        }else if(String.isNotBlank(updatedContentInfo.ccEmailIds)){
            ccAddress.add(updatedContentInfo.ccEmailIds);
        }
        
        Set<Id> contactIds = new Set<Id>();
        Map<Id,Contact> conIdcontactRec = new Map<Id,Contact>();
        
        String toEmailAddress = '';
        
        if(updatedContentInfo.toAddressContacts.size() > 0 && updatedContentInfo.toAddressContacts.size() > 1){
            for(Contact con : updatedContentInfo.toAddressContacts){
                contactIds.add(con.Id);
            }
            for(Contact con : [SELECT Id,Name,FirstName,Email FROM Contact WHERE Id IN :contactIds]){
                conIdcontactRec.put(con.Id,con);
            }
            
            for(Contact con : updatedContentInfo.toAddressContacts){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                if(toEmailAddress == null){
                    toEmailAddress = conIdcontactRec.get(con.Id).Email;
                }
                toEmailAddress += ', '+conIdcontactRec.get(con.Id).Email;
                
                String bodyContent = updatedContentInfo.htmlBodyContent;
                system.debug('::::::::bodyContent::::'+bodyContent);
                String studName = conIdcontactRec.get(con.Id).FirstName;
                String startingTxt = 'Hello '+studName+',';
                if(bodyContent.contains('Hello')){
                    bodyContent = bodyContent.replace('Hello ,',startingTxt);
                }
                system.debug(':::::::::::::bodyContent:::::'+bodyContent);
                mail.setSubject(updatedContentInfo.subject);
                mail.sethtmlBody(bodyContent);
                mail.setToAddresses(new List<String>{conIdcontactRec.get(con.Id).Email});
                mail.setSaveAsActivity(true);
                mail.setTargetObjectId(con.Id);
                
                if(ccAddress.size() > 0){
                    mail.setCcAddresses(ccAddress);
                } 
                mailList.add(mail);
            }
        }else if(updatedContentInfo.toAddressContacts.size() > 0 && updatedContentInfo.toAddressContacts.size() == 1){
        
            List<Contact> toContact = [SELECT Id,Name,Email FROM Contact WHERE Id = :updatedContentInfo.toAddressContacts[0].Id];
            
            toEmailAddress += ', '+toContact[0].Email;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject(updatedContentInfo.subject);
            mail.sethtmlBody(updatedContentInfo.htmlBodyContent);
            mail.setToAddresses(new List<String>{toContact[0].Email});
            if(ccAddress.size() > 0){
                mail.setCcAddresses(ccAddress);
            } 
            mail.setSaveAsActivity(true);
            mail.setTargetObjectId(toContact[0].Id);
            mailList.add(mail);
        }
        
        //system.debug(':::::::::mailList::::'+mailList);
        
        try {
            if(mailList.size() > 0 && !Test.isRunningTest()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
                
                List<RecordType> recordType = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Task' AND DeveloperName = 'Task'];
                
                //Created task record under project
                Task tsk = new Task();
                tsk.ActivityDate = system.today();
                tsk.Description = mailList[0].getHtmlBody().stripHtmlTags();
                tsk.Status = 'Completed';
                tsk.Priority = 'Normal';
                tsk.RecordTypeId = recordType[0].Id;
                tsk.WhatId = updatedContentInfo.relatedRecordId;
                tsk.Subject = updatedContentInfo.subject;
                
                insert tsk;
            }
            return 'SUCCESS';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /****************************************************************************************************************
    - Added by NS on Sep 20 2019
    - To get the project related service project task details for student payment reminder
    ******************************************************************************************************************/
    @AuraEnabled
    public static List<AcctSeed__Project_Task__c> getServiceProjectTasks(string projectId){
        
        Set<String> taskType = new Set<String>{'Language Training','Language Testing','Interpretation (per hr)','Curriculum Development',
                                            'Localization','Translation (per hr)','Translation','Preparation time','Linguist Support',
                                            'Linguist Support Services','Translation (per word)'};
        List<AcctSeed__Project_Task__c> taskRecords = new List<AcctSeed__Project_Task__c>();
        
        taskRecords = [SELECT Id,Name FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c = :projectId AND Project_Task_Type__c IN :taskType];
        
        return taskRecords;
    }
    
    /*****************************************************************************************************************
    - Added by NS on June 16 2020
    - To contruct the email contents for Send Materials Ordered Email action based on ordered material requests
    ******************************************************************************************************************/
    @AuraEnabled
    public static EmailContents getMaterialsOrderedInformation(String projectId){
        
        EmailContents mContents = new EmailContents();
        
        //Qry student CAs to get to address info
        Set<Id> contactIds = new Set<Id>();
        
        for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Status__c IN ('Active', 'Planned') AND Project__c = :projectId]){
            contactIds.add(ca.Candidate_Name__c);
        }
        
        List<Contact> toaddressContacts = [SELECT Id,Name,Email,FirstName FROM Contact WHERE Id IN :contactIds AND Email != null];
        mContents.toAddressContacts = toaddressContacts;
        
        List<AcctSeed__Project__c> projectRec = [SELECT Id,Name,Project_Manager__c,Project_Manager__r.Email FROM AcctSeed__Project__c WHERE Id = :projectId];
        mContents.relatedRecordId = projectId;
        mContents.relatedRecordName = projectRec[0].Name;
        
        mContents.ccEmailIds = projectRec[0].Project_Manager__c != null ? projectRec[0].Project_Manager__r.Email : '';
        
        mContents.subject = 'Your DLS Class Materials have been Ordered';
        
        List<User> usrRecord = [SELECT Id,Name,Email FROM User WHERE Id = :userinfo.getUserId()];
        mContents.fromAddress = usrRecord[0].Name;
        
        //Qry project related order material request records with ordered status
        List<Materials_Request__c> matRequests = [SELECT Id,Name,Materials_Name__c,Materials_Name__r.Name,Est_Arrival_Date__c,Date_Ordered__c FROM Materials_Request__c WHERE Project__c = :projectId AND Request_Status__c = 'Ordered'];
        
        //htmlbody content formation
        String htmlBody = '<html>';
        htmlBody += '<div>Dear Student,</div><br/>';
        htmlBody += '<div>The materials requested by your Language Training Supervisor have been ordered.</div><br/>';
        
        htmlBody += '<table style="border:0;border-collapse: collapse;width: 75%;"><thead><th style="width:25%;border: 1px solid black;text-align: center;">Material Title</th><th style="width:25%;border: 1px solid black;text-align: center;">Date Ordered</th><th style="width:25%;border: 1px solid black;text-align: center;">Estimated Delivery Date</th></thead><tbody>';
        
        for(Materials_Request__c matReq : matRequests){
            
            String orderedDt = String.valueOf(matReq.Date_Ordered__c).split('-')[1]+'/'+String.valueOf(matReq.Date_Ordered__c).split('-')[2]+'/'+String.valueOf(matReq.Date_Ordered__c).split('-')[0];
            
            String estArrDt = '';
            
            if(matReq.Est_Arrival_Date__c != null){
                estArrDt = String.valueOf(matReq.Est_Arrival_Date__c).split('-')[1]+'/'+String.valueOf(matReq.Est_Arrival_Date__c).split('-')[2]+'/'+String.valueOf(matReq.Est_Arrival_Date__c).split('-')[0];
            }
            
            htmlBody += '<tr style="border: 1px solid black;"><td style="width: 25%;border: 1px solid black;text-align: center;">'+matReq.Materials_Name__r.Name+'</td><td style="width: 25%;border: 1px solid black;text-align: center;">'+orderedDt+'</td><td style="width: 25%;border: 1px solid black;text-align: center;">'+estArrDt+'</td></td>';
        }
        
        htmlBody += '</tbody></table><br/>';
        
        htmlBody += 'You can check the status and any updates to the estimated delivery date of your materials by going to <a href="https://online.dlsdc.com/student/s/library" target="_blank">Click Here</a>. If you have questions about any materials, please reply to this email or contact your Language Training Supervisor.<br/><br/>';
        
        htmlBody += '<div>Happy Studying!</div><div>DLS Materials</div><html>';
        
        mContents.htmlBodyContent = htmlBody;
        
        return mContents;
    }
    
    /**************************************************************************************************
    - Method to send email to students after content updated from user for Send Materials Ordered Emails
    - Added by NS in 
    ***************************************************************************************************/
    @AuraEnabled
    public static string sendMaterialOrderEmail(string contentJson){
        
        List<EmailContents> contentList = (List<EmailContents>) System.JSON.deserialize(contentJson, List<EmailContents>.class);
        EmailContents updatedContentInfo = contentList[0];
        system.debug(':::::::::::updatedContentInfo::::::'+updatedContentInfo);
        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        //Form CC Email Address
        List<String> ccAddress = new List<String>();
        
        if(String.isNotBlank(updatedContentInfo.ccEmailIds)){
            ccAddress.add(updatedContentInfo.ccEmailIds);
        }
        
        Set<Id> contactIds = new Set<Id>();
        Map<Id,Contact> conIdcontactRec = new Map<Id,Contact>();
        
        String toEmailAddress = '';
        
        if(updatedContentInfo.toAddressContacts.size() > 0 && updatedContentInfo.toAddressContacts.size() > 1){
            for(Contact con : updatedContentInfo.toAddressContacts){
                contactIds.add(con.Id);
            }
            for(Contact con : [SELECT Id,Name,FirstName,Email FROM Contact WHERE Id IN :contactIds]){
                conIdcontactRec.put(con.Id,con);
            }
            
            for(Contact con : updatedContentInfo.toAddressContacts){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                String bodyContent = updatedContentInfo.htmlBodyContent;
                system.debug(':::::::::::::bodyContent:::::'+bodyContent);
                mail.setSubject(updatedContentInfo.subject);
                mail.sethtmlBody(bodyContent);
                mail.setToAddresses(new List<String>{conIdcontactRec.get(con.Id).Email});
                mail.setSaveAsActivity(true);
                mail.setTargetObjectId(con.Id);
                
                if(ccAddress.size() > 0){
                    mail.setCcAddresses(ccAddress);
                } 
                mailList.add(mail);
            }
        }else if(updatedContentInfo.toAddressContacts.size() > 0 && updatedContentInfo.toAddressContacts.size() == 1){
        
            List<Contact> toContact = [SELECT Id,Name,Email FROM Contact WHERE Id = :updatedContentInfo.toAddressContacts[0].Id];
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject(updatedContentInfo.subject);
            mail.sethtmlBody(updatedContentInfo.htmlBodyContent);
            mail.setToAddresses(new List<String>{toContact[0].Email});
            if(ccAddress.size() > 0){
                mail.setCcAddresses(ccAddress);
            } 
            mail.setSaveAsActivity(true);
            mail.setTargetObjectId(toContact[0].Id);
            mailList.add(mail);
        }
        
        system.debug(':::::::::mailList::::'+mailList);
        
        try {
            if(mailList.size() > 0 && !Test.isRunningTest()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);
            }
            return 'SUCCESS';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /*****************************************************************************
    - Method to construct the Email contents for Project On-Hold Student Remainder Button in Project
    - W-006829 - Added by Dhinesh on Aug 3 2021
    ******************************************************************************/
    @AuraEnabled
    public static EmailContents getOnHoldProjectAndStudentInformation(String projectId){
        EmailContents eContents = new EmailContents();
        bodyContent bContent = new bodyContent();
        addStaffRecordTypeFilter = true;
        Set<Id> contactIds = new Set<Id>();
        String ccEmailIds = 'accountinggroup@dlsdc.com;';
        
        //Qry project related action Student CA to form the To Address values
        for(Contact_Assignments__c ca : [SELECT Id,Candidate_Name__c,Candidate_Name__r.Email,RecordType.DeveloperName,Assignment_Position__c FROM Contact_Assignments__c WHERE Project__c = :projectId AND Status__c != 'Canceled' AND RecordType.DeveloperName IN ('Staff','Student')]){
            if(ca.RecordType.DeveloperName == 'Student'){
                contactIds.add(ca.Candidate_Name__c);   
            }else if(ca.RecordType.DeveloperName == 'Staff' && (ca.Assignment_Position__c == 'Project Manager' || ca.Assignment_Position__c == 'Coordinator')){
                ccEmailIds += ca.Candidate_Name__r.Email+';';
            }       
        }
        
        Decimal hrsRemainingFromProj = 0;
        Decimal amntRemainingFromProj = 0;
        Decimal amntRemainingFromProjMaterial = 0;
        Decimal totalhrsRemainingFromProj = 0;
        Decimal totalAmntRemainingFromProj = 0;
        Boolean showAdditionalStudentRow = false;
        Decimal amntRemainingFromProjAdditionalStudent = 0;
        Decimal hrsRemainingFromProjAdditionalStudent = 0;
        
        for(Acctseed__Project_Task__c projTask : [SELECT Id, Name, Project_Task_Type__c, Total_Qty_Paid_Remaining__c, Unit__c,
                                                  Parent_Project_Task__r.Total_Days_Used_for_Language_Training__c,
                                                  Parent_Project_Task__r.Total_Hours_Used_For_Language_Training__c, Rate__c,
                                                  Parent_Project_Task__r.Total_Qty_Paid_Remaining__c, Total_Amount_Paid_Remaining__c,
                                                  Total_Amount_Paid__c                                                                                                     
                                                  FROM AcctSeed__Project_Task__c 
                                                  WHERE AcctSeed__Project__c = :projectId AND Billable__c != false AND Project_Task_Type__c != 'Preparation time']){ //Modified By Dhinesh - 19/5/2023 - W-007794 - Added Billable and Task Type filters to exclude non-billable preparation hours
            if(projTask.Project_Task_Type__c == 'Material budget'){
                amntRemainingFromProjMaterial += projTask.Total_Amount_Paid_Remaining__c;                
            }else if(projTask.Name.contains('Additional')){
                showAdditionalStudentRow = true;
                if(projTask.Unit__c == 'Days'){
                    amntRemainingFromProjAdditionalStudent += (projTask.Total_Amount_Paid__c - (projTask.Parent_Project_Task__r.Total_Days_Used_for_Language_Training__c * projTask.Rate__c)).setScale(2);
                }else{
                    amntRemainingFromProjAdditionalStudent += (projTask.Total_Amount_Paid__c - (projTask.Parent_Project_Task__r.Total_Hours_Used_For_Language_Training__c * projTask.Rate__c)).setScale(2);
                }
                hrsRemainingFromProjAdditionalStudent += projTask.Parent_Project_Task__r.Total_Qty_Paid_Remaining__c;
            }else{
                hrsRemainingFromProj += projTask.Total_Qty_Paid_Remaining__c;                
                amntRemainingFromProj += projTask.Total_Amount_Paid_Remaining__c;
            }                        
        }
        
        totalhrsRemainingFromProj = hrsRemainingFromProj;
        totalAmntRemainingFromProj = amntRemainingFromProj + amntRemainingFromProjAdditionalStudent + amntRemainingFromProjMaterial;
        
        List<Contact> toaddressContacts = [SELECT Id,Name,Email,FirstName FROM Contact WHERE Id IN :contactIds AND Email != null];
        eContents.toAddressContacts = toaddressContacts;
        
        List<AcctSeed__Project__c> projectRec = [SELECT Id, Name, DLS_Ref__c, On_Hold_Date__c, Project_Manager__r.Name, Project_Manager__r.Email, Project_Manager__r.Title FROM AcctSeed__Project__c WHERE Id = :projectId];
        eContents.relatedRecordId = projectId;
        eContents.relatedRecordName = projectRec[0].Name;
        
        eContents.subject = 'Student On Hold Quarterly Reminder - '+projectRec[0].Name;
        
        List<User> usrRecord = [SELECT Id,Name,Email,Title FROM User WHERE Id = :userinfo.getUserId()];
        Map<Id,Id> userIdWithContactIdMap = PlannedDaysOffHandler.getUserRelatedContacts(new Set<Id>{userinfo.getUserId()});
        Contact con;
        if(userIdWithContactIdMap.size() > 0){
            for(Contact c : [SELECT Id, Title, Ext__c, Phone FROM Contact WHERE Id IN :userIdWithContactIdMap.values()]){
                con = c;
            }
        }
        eContents.fromAddress = usrRecord[0].Name;
        
        eContents.ccEmailIds = ccEmailIds;
        
        bContent.studentName = '';
        if(toaddressContacts.size() > 0 && toaddressContacts.size() == 1){
            bContent.studentName = toaddressContacts[0].Name;
        }
        
        //htmlbody content formation
        String htmlBody = '<html>';
        htmlBody += 'Hello '+bContent.studentName+',<br/><br/>';
        htmlBody += 'This email serves as a friendly reminder that you have the following funds remaining in your language training with DLS:<br/>';
        htmlBody += '<table style="border-collapse: collapse;"><tr><th style="border: 1px solid #ddd;padding: 10px;">Description</th><th style="border: 1px solid #ddd;padding: 10px;">Hours</th><th style="border: 1px solid #ddd;padding: 10px;">Amounts</th></tr>';
        htmlBody += '<tr><td style="border: 1px solid #ddd;padding: 10px;">Unused LT Hours Remaining</td><td style="border: 1px solid #ddd;padding: 10px;">'+hrsRemainingFromProj+'</td><td style="border: 1px solid #ddd;padding: 10px;">'+string.format('${0}', new string[]{amntRemainingFromProj.setScale(2).format()})+'</td></tr>';
        if(showAdditionalStudentRow){
            htmlBody += '<tr><td style="border: 1px solid #ddd;padding: 10px;">Unused LT Hours Remaining (Additional Student)</td><td style="border: 1px solid #ddd;padding: 10px;">'+hrsRemainingFromProjAdditionalStudent+'</td><td style="border: 1px solid #ddd;padding: 10px;">'+string.format('${0}', new string[]{amntRemainingFromProjAdditionalStudent.setScale(2).format()})+'</td></tr>';
        }
        htmlBody += '<tr><td style="border: 1px solid #ddd;padding: 10px;">Unused LT Materials Remaining</td><td style="border: 1px solid #ddd;padding: 10px;">-</td><td style="border: 1px solid #ddd;padding: 10px;">'+string.format('${0}', new string[]{amntRemainingFromProjMaterial.setScale(2).format()})+'</td></tr>';
        htmlBody += '<tr><td style="border: 1px solid #ddd;padding: 10px;">Total</td><td style="border: 1px solid #ddd;padding: 10px;">'+totalhrsRemainingFromProj+'</td><td style="border: 1px solid #ddd;padding: 10px;">'+string.format('${0}', new string[]{totalAmntRemainingFromProj.setScale(2).format()})+'</td></tr>';
        htmlBody += '</table>';
        htmlBody += '<br/>If you would like to resume training, please email ' +projectRec[0].Project_Manager__r.Name +' at '+projectRec[0].Project_Manager__r.Email+'.<br/>';
        htmlBody += 'If you would like a refund, please email accountinggroup@dlsdc.com. <br/>';        
        htmlBody += 'Please do not hesitate to email ' +projectRec[0].Project_Manager__r.Name +' if you have any concerns or questions regarding this information.<br/>';
        htmlBody += 'We appreciate your time and collaboration.<br/><br/>';
        htmlBody += usrRecord[0].Name+'<br/>';
        if(con != null){
            if(con.Title != null) htmlBody += con.Title+'<br/>'; 
            htmlBody += '(703) 243-4855';
            if(con.Ext__c != null) htmlBody += '-'+con.Ext__c;
        }  
        htmlBody += '<br/>Diplomatic Language Services<br/>1901 Fort Myer Dr., Ste. 600 | Arlington, VA 22209';
        htmlBody += '<html>';
        
        eContents.content = bContent;
        eContents.htmlBodyContent = htmlBody;
        
        return eContents;
    }
    
    /*****************************************************************************
     - Method to send Student On Hold Quarterly Reminder after content correction from user
     - W-006829 - Added by Dhinesh on Aug 3 2021
    ******************************************************************************/
    @AuraEnabled
    public static string sendStudentOnHoldQuarterlyReminderEmail(String contentJson){
        EmailContents updatedContentInfo = (EmailContents) System.JSON.deserialize(contentJson, EmailContents.class);        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        //Form CC Email Address
        List<String> ccAddress = new List<String>();
        
        if(updatedContentInfo.ccEmailIds.split(';').size() > 1){
            List<String> address = updatedContentInfo.ccEmailIds.split(';');
            ccAddress.addAll(address);
        }else if(String.isNotBlank(updatedContentInfo.ccEmailIds)){
            ccAddress.add(updatedContentInfo.ccEmailIds);
        }
        
        Set<Id> contactIds = new Set<Id>();
        Map<Id,Contact> conIdcontactRec = new Map<Id,Contact>();
        
        String toEmailAddress = '';
        
        if(updatedContentInfo.toAddressContacts.size() > 0 && updatedContentInfo.toAddressContacts.size() > 1){
            for(Contact con : updatedContentInfo.toAddressContacts){
                contactIds.add(con.Id);
            }
            for(Contact con : [SELECT Id,Name,FirstName,Email FROM Contact WHERE Id IN :contactIds]){
                conIdcontactRec.put(con.Id,con);
            }
            
            for(Contact con : updatedContentInfo.toAddressContacts){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                if(toEmailAddress == null){
                    toEmailAddress = conIdcontactRec.get(con.Id).Email;
                }
                toEmailAddress += ', '+conIdcontactRec.get(con.Id).Email;
                
                String bodyContent = updatedContentInfo.htmlBodyContent;                
                String studName = conIdcontactRec.get(con.Id).Name;
                String startingTxt = 'Hello '+studName+',';
                if(bodyContent.contains('Hello')){
                    bodyContent = bodyContent.replace('Hello ,',startingTxt);
                }                
                mail.setSubject(updatedContentInfo.subject);
                mail.sethtmlBody(bodyContent);
                mail.setToAddresses(new List<String>{conIdcontactRec.get(con.Id).Email});
                mail.setSaveAsActivity(true);
                mail.setTargetObjectId(con.Id);
                
                if(ccAddress.size() > 0){
                    mail.setCcAddresses(ccAddress);
                } 
                mailList.add(mail);
            }
        }else if(updatedContentInfo.toAddressContacts.size() > 0 && updatedContentInfo.toAddressContacts.size() == 1){
        
            List<Contact> toContact = [SELECT Id,Name,Email FROM Contact WHERE Id = :updatedContentInfo.toAddressContacts[0].Id];
            
            toEmailAddress += ', '+toContact[0].Email;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject(updatedContentInfo.subject);
            mail.sethtmlBody(updatedContentInfo.htmlBodyContent);
            mail.setToAddresses(new List<String>{toContact[0].Email});
            if(ccAddress.size() > 0){
                mail.setCcAddresses(ccAddress);
            } 
            mail.setSaveAsActivity(true);
            mail.setTargetObjectId(toContact[0].Id);
            mailList.add(mail);
        }
                
        try {
            if(mailList.size() > 0 && !Test.isRunningTest()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);                
            }
            return 'SUCCESS';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
    
    /*****************************************************************************
    - Method to construct the Email contents for Translator Payment Email Confirmation Button in CA
    - W-006998 - Added by Dhinesh on Sep 3 2021
    ******************************************************************************/
    @AuraEnabled
    public static EmailContents getTranslatorPaymentEmailConfirmationInformation(String caId){
        EmailContents eContents = new EmailContents();
        bodyContent bContent = new bodyContent();
        addStaffRecordTypeFilter = true;
        Set<Id> contactIds = new Set<Id>();
        String ccEmailIds = 'accountspayable@dlsdc.com;lredd@dlsdc.com;';
        
        Contact_Assignments__c ca = [SELECT Id,Name, Candidate_Name__c,Candidate_Name__r.Email,RecordType.DeveloperName,Assignment_Position__c FROM Contact_Assignments__c WHERE Id = :caId LIMIT 1];
        contactIds.add(ca.Candidate_Name__c);                       
        
        List<Contact> toaddressContacts = [SELECT Id,Name,Email,FirstName FROM Contact WHERE Id IN :contactIds AND Email != null];
        eContents.toAddressContacts = toaddressContacts;
        
        eContents.relatedRecordId = caId;
        eContents.relatedRecordName = ca.Name;
        
        eContents.subject = 'Payment Confirmation from Language Associates, LLC dba, DLS';
        
        List<User> usrRecord = [SELECT Id,Name,Email,Title FROM User WHERE Id = :userinfo.getUserId()];
        Map<Id,Id> userIdWithContactIdMap = PlannedDaysOffHandler.getUserRelatedContacts(new Set<Id>{userinfo.getUserId()});
        Contact con;
        if(userIdWithContactIdMap.size() > 0){
            for(Contact c : [SELECT Id, Title, Email, Ext__c, Phone FROM Contact WHERE Id IN :userIdWithContactIdMap.values()]){
                con = c;
            }
        }
        eContents.fromAddress = usrRecord[0].Name;
        
        eContents.ccEmailIds = ccEmailIds;
        
        bContent.studentName = '';
        if(toaddressContacts.size() > 0 && toaddressContacts.size() == 1){
            bContent.studentName = toaddressContacts[0].Name;
        }
        
        //htmlbody content formation
        String htmlBody = '<html>';
        htmlBody += '<div>Hello '+bContent.studentName+',</div><br/><br/>';
        htmlBody += 'A payment in the amount of $&emsp;has been processed from Language Associates, LLC dba, Diplomatic Language Services for your assignment.<br/><br/>';
        htmlBody += 'If you have any questions about the payment, don\'t hesitate to contact accountspayable@dlsdc.com.<br/><br/>';
        htmlBody += 'Thank you,<br/>';                
        htmlBody += usrRecord[0].Name;
        if(con != null){
            if(con.Title != null) htmlBody += '<br/>'+con.Title; 
            htmlBody += '<br/>1901 Fort Myer Drive, Suite 600 <br/>Arlington, VA 22209';
            htmlBody += '<br/>(703) 243-4855';
            if(con.Ext__c != null) htmlBody += '-'+con.Ext__c;
            htmlBody += '<br/>'+con.Email;
        }          
        htmlBody += '<html>';
        
        eContents.content = bContent;
        eContents.htmlBodyContent = htmlBody;
        
        return eContents;
    }
    
    /*****************************************************************************
     - Method to send Translator Payment Email Confirmation after content correction from user
     - W-006998 - Added by Dhinesh on Sep 3 2021
    ******************************************************************************/
    @AuraEnabled
    public static string sendTranslatorPaymentConfirmationEmail(String contentJson){
        EmailContents updatedContentInfo = (EmailContents) System.JSON.deserialize(contentJson, EmailContents.class);        
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        
        //Form CC Email Address
        List<String> ccAddress = new List<String>();
        
        if(updatedContentInfo.ccEmailIds.split(';').size() > 1){
            List<String> address = updatedContentInfo.ccEmailIds.split(';');
            ccAddress.addAll(address);
        }else if(String.isNotBlank(updatedContentInfo.ccEmailIds)){
            ccAddress.add(updatedContentInfo.ccEmailIds);
        }
        
        Set<Id> contactIds = new Set<Id>();
        Map<Id,Contact> conIdcontactRec = new Map<Id,Contact>();
        
        String toEmailAddress = '';
        
        if(updatedContentInfo.toAddressContacts.size() > 0 && updatedContentInfo.toAddressContacts.size() > 1){
            for(Contact con : updatedContentInfo.toAddressContacts){
                contactIds.add(con.Id);
            }
            for(Contact con : [SELECT Id,Name,FirstName,Email FROM Contact WHERE Id IN :contactIds]){
                conIdcontactRec.put(con.Id,con);
            }
            
            for(Contact con : updatedContentInfo.toAddressContacts){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                
                if(toEmailAddress == null){
                    toEmailAddress = conIdcontactRec.get(con.Id).Email;
                }
                toEmailAddress += ', '+conIdcontactRec.get(con.Id).Email;
                
                String bodyContent = updatedContentInfo.htmlBodyContent;                
                String studName = conIdcontactRec.get(con.Id).Name;
                String startingTxt = 'Hello '+studName+',';
                if(bodyContent.contains('Hello')){
                    bodyContent = bodyContent.replace('Hello ,',startingTxt);
                }                
                mail.setSubject(updatedContentInfo.subject);
                mail.sethtmlBody(bodyContent);
                mail.setToAddresses(new List<String>{conIdcontactRec.get(con.Id).Email});
                mail.setSaveAsActivity(true);
                mail.setTargetObjectId(con.Id);
                
                if(ccAddress.size() > 0){
                    mail.setCcAddresses(ccAddress);
                } 
                mailList.add(mail);
            }
        }else if(updatedContentInfo.toAddressContacts.size() > 0 && updatedContentInfo.toAddressContacts.size() == 1){
        
            List<Contact> toContact = [SELECT Id,Name,Email FROM Contact WHERE Id = :updatedContentInfo.toAddressContacts[0].Id];
            
            toEmailAddress += ', '+toContact[0].Email;
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject(updatedContentInfo.subject);
            mail.sethtmlBody(updatedContentInfo.htmlBodyContent);
            mail.setToAddresses(new List<String>{toContact[0].Email});
            if(ccAddress.size() > 0){
                mail.setCcAddresses(ccAddress);
            } 
            mail.setSaveAsActivity(true);
            mail.setTargetObjectId(toContact[0].Id);
            mailList.add(mail);
        }
                
        try {
            if(mailList.size() > 0 && !Test.isRunningTest()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mailList);                
            }
            return 'SUCCESS';
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    } 
}