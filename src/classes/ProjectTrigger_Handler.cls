/*******************************************
 - Created by Karthiga on April 04, 2017
 - Used for Project Trigger process
 *******************************************/
 
public class ProjectTrigger_Handler {
    
    public Static List<RecordType> rtList = new List<RecordType>();
    public Static List<Opportunity_Project_Mapping__c> oppProMapList = new List<Opportunity_Project_Mapping__c>();
    
    public Static Boolean loadResource = false;
    /*********
        - We had a logic to update assessment reports when project is ended or cancelled and also implemented a logic 
            to update assessment reports when contact assignment is ended or cancelled (via contact assignment tab)., 
            So prevent recursive updation "isFromProjectTrigger_StatusUpdate" flag is used.
        **********/
    public static Boolean isFromProjectTrigger_StatusUpdate = False;
    /**********            
        - When the project is ended, all the related CAs will end, so both student and instructor will receive get feedback email
        - At the same time the instructor get feedback email will send if the contact assignment is ended., So we have implemented separate method for this
        - To prevent recursive email sending process "isFromProjectTrigger_SendGetFeedback" flag is used
        ******/
    public static Boolean isFromProjectTrigger_SendGetFeedback = False;
    
    public static void getProRecordType() {
        rtList = SObjectQueryService.getRecTypeListBySobjTypeAndDevName('','AcctSeed__Project__c',new Set<String>());
    }
    
    public static void getOppProMappingRec(String condition) {
        
        String queryVal = 'SELECT Id,Name,Project_Value__c,Value_Type__c,Default_CR_Rate_Type__c FROM Opportunity_Project_Mapping__c';
        
        if(condition != null && condition != '') {
            queryVal += condition;
        }
        
        oppProMapList = database.query(queryVal);
    }
    
    //Method to update Instructor & Student Contact's Supervisor Name field based on the Project Manager field update
    //Planned Days Off Instructor / Student approval process use this supervisor name field as Approver. So we automated the population
    //Added by NS on July 25 2019
    public static void updateContactSupervisor(Map<Id,Id> proIdManagerId) {
        
        
        //Qry the project related student / Instructor related Most recent project
        Set<Id> studentIds = new Set<Id>();
        Set<Id> instructorIds = new Set<Id>();
        List<Contact> contactRecordForUpdate = new List<Contact>();
        
        for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c,RecordType.DeveloperName 
                                                FROM Contact_Assignments__c 
                                                WHERE Project__c IN :proIdManagerId.keySet() AND Status__c IN ('Active','Planned') 
                                                        AND RecordType.DeveloperName IN ('Instructor','Student')]){
            if(ca.RecordType.DeveloperName == 'Instructor'){
                instructorIds.add(ca.Candidate_Name__c);
            }else if(ca.RecordType.DeveloperName == 'Student'){
                studentIds.add(ca.Candidate_Name__c);
            }
        }
        
        system.debug('::::::::::instructorIds::::'+instructorIds);
        system.debug('::::::::::studentIds::::'+studentIds);
        
        for(Contact con : [SELECT Id,Name,Supervisor_Name__c,RecordType.DeveloperName, Account.Name,
                                (SELECT Id,Candidate_Name__c,Project__c,Start_Date__c,RecordType.DeveloperName FROM Candidate_Assignments__r 
                                        WHERE Project__c != NULL AND Start_Date__c != NULL AND RecordType.DeveloperName IN ('Instructor','Student') AND Status__c IN ('Active','Planned') ORDER BY Start_Date__c DESC LIMIT 1) 
                            FROM Contact WHERE Id IN :instructorIds OR Id IN :studentIds]){
        
            if(con.Candidate_Assignments__r.size() > 0){
                
                // Work Item : W-005849 - Supervisor Incorrectly Changed for Staff Member
                if((con.Candidate_Assignments__r[0].RecordType.DeveloperName == 'Instructor' && 
                    (con.RecordType.DeveloperName != 'DLS_Employee' || (con.RecordType.DeveloperName == 'DLS_Employee' && con.Account.Name != null && !con.Account.Name.contains('DLS')))) || 
                    con.Candidate_Assignments__r[0].RecordType.DeveloperName == 'Student'){
                                        
                    if(proIdManagerId.containsKey(con.Candidate_Assignments__r[0].Project__c)){
                    
                        Contact conRec = new Contact();
                        conRec.Id = con.Id;
                        conRec.Supervisor_Name__c = proIdManagerId.get(con.Candidate_Assignments__r[0].Project__c);
                        
                        contactRecordForUpdate.add(conRec);
                    }
                }
            }
        }
        
        system.debug('::::::::::::contactRecordForUpdate::::'+contactRecordForUpdate);
        
        if(contactRecordForUpdate.size() > 0){
            update contactRecordForUpdate;
        }
    }
    
    // Added by HL on Oct 14 2019
    // To send an email notification to Accounting Group when Project Name field is changed
    public static void toSendAnEmailToAccGrp(List<AcctSeed__Project__c> newProj, Map<Id,AcctSeed__Project__c> oldProj) {
            
        Set<Id> projIds = new Set<Id>();
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType projSchema = schemaMap.get('AcctSeed__Project__c');
        Map<String, Schema.SObjectField> fieldMap = projSchema.getDescribe().fields.getMap();
        
        Set<String> fieldAPINames = new Set<String>{'name', 'dls_class__c', 'training_location__c', 'qb_classification__c', 'hourly_rate__c', 'billing_type__c'};
        Map<String, String> fieldLabelAndfieldvalue;
        Map<Id, Map<String, String>> projIdAndfieldNamefieldValue = new Map<Id, Map<String, String>>();
        Set<Id> locIds = new Set<Id>();
        
        for(AcctSeed__Project__c p : newProj){
        
            AcctSeed__Project__c oldP = oldProj.get(p.Id);
                            
            fieldLabelAndfieldvalue = new Map<String, String>();
            projIds.add(p.Id);
                
            for (String fieldName: fieldAPINames) {
    
                try {                             
                    String oldAndNewvalue = '';
                    if(p.get(fieldName) != oldP.get(fieldName)){ 
                        
                        oldAndNewvalue = oldP.get(fieldName) + ','+ p.get(fieldName);
                        fieldLabelAndfieldvalue.put(fieldMap.get(fieldName).getDescribe().getLabel(), oldAndNewvalue);
                        
                        if(fieldName == 'training_location__c'){
                            
                            if(p.get(fieldName) != null && p.get(fieldName) != ''){
                                locIds.add(String.valueOf(p.get(fieldName)));
                            }
                            if(oldP.get(fieldName) != null && oldP.get(fieldName) != ''){
                                locIds.add(String.valueOf(oldP.get(fieldName)));
                            }
                        }
                    } 
                } catch (Exception e) { 
                    System.debug('Error: ' + e); 
                } 
            }
                
            if(fieldLabelAndfieldvalue != NULL && fieldLabelAndfieldvalue.size() > 0){
        
                if(!projIdAndfieldNamefieldValue.containsKey(p.Id)){
                    projIdAndfieldNamefieldValue.put(p.Id, new Map<String, String>());
                }
                projIdAndfieldNamefieldValue.get(p.Id).putAll(fieldLabelAndfieldvalue);
            }
        }
        System.debug('::::projIds::::'+projIds);
        
        if(projIds.size() > 0){
        
            List<Messaging.SingleEmailMessage> emailToAccountingGroup = new List<Messaging.SingleEmailMessage>();
                        
            Map<Id, AcctSeed__Project__c> projIdAndRec = new Map<Id, AcctSeed__Project__c>([SELECT Id, Name, DLS_Class__c, LastModifiedBy.Name, LastModifiedDate FROM AcctSeed__Project__c WHERE Id IN :projIds]);
            Map<Id, String> locIdAndName = new Map <Id, String>();
            System.debug('::locIds::'+locIds);
            if(locIds != NULL && locIds.size() > 0){
                
                for(MTT_Location__c l : [SELECT Id, Name FROM MTT_Location__c WHERE Id IN : locIds]){
                
                    locIdAndName.put(l.Id, l.Name);
                }
            }
            System.debug(':::locIdAndName:::::'+locIdAndName);
            
            try{
                
                if(projIdAndRec != NULL && projIdAndRec.size() > 0){
                
                    for(Id proId : projIdAndRec.keySet()){
                    
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(new List<String>{'accountinggroup@dlsdc.com'});
                        //mail.setToAddresses(new List<String>{'karthiga@softsquare.biz','hemalatha@softsquare.biz'});
                        mail.setWhatID(proId);
                        mail.subject = 'Project fields has been changed';
                        
                        String htmlBody = '';
                        htmlBody += 'Accounting Team,<br/>';
                        htmlBody += '<br/>Following fields on the following project record has been changed: <br/>';
                        htmlBody += '<br/><a href="'+System.Label.Org_Prefix_Start_URL+'/'+projIdAndRec.get(proId).Id+'" target="_blank">'+'URL'+'</a><br/>';
                        
                        //Table of fields that were changed with the old value and new value
                        if(projIdAndfieldNamefieldValue.size() > 0 && projIdAndfieldNamefieldValue.containsKey(proId)){
                        
                            htmlBody += '<br/><table border="1" style="border-collapse: collapse"><tr><th width="15%" style="text-align: center; vertical-align: middle;">DLS Class #</th><th width="15%" style="text-align: center; vertical-align: middle;">Edited By</th><th width="15%" style="text-align: center; vertical-align: middle;">Edit Date</th><th width="15%" style="text-align: center; vertical-align: middle;">Field / Event</th><th width="15%" style="text-align: center; vertical-align: middle;">Old Value</th><th width="15%" style="text-align: center; vertical-align: middle;">New Value</th></tr>';
                            
                            for(String label : projIdAndfieldNamefieldValue.get(proId).keySet()){
                            
                                String fieldvalue = projIdAndfieldNamefieldValue.get(proId).get(label);
                                String oldValue = '';
                                String newValue = '';
                                
                                oldValue = fieldvalue.split(',')[0];
                                newValue = fieldvalue.split(',')[1];
                                system.debug(':::oldValue::::'+oldValue);
                                system.debug(':::newValue::::'+newValue);
                                
                                if(label == 'Training Location'){
                                
                                    if(oldValue != 'null' && oldValue != ''){
                                        if(locIdAndName.containsKey(oldValue)){
                                            oldValue = locIdAndName.get(oldValue);
                                        }
                                    }
                                    if(newValue != 'null' && newValue != ''){
                                        if(locIdAndName.containsKey(newValue)){
                                            newValue = locIdAndName.get(newValue);
                                        }
                                    }
                                }
                                htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + projIdAndRec.get(proId).DLS_Class__c + '</td><td style="text-align: center; vertical-align: middle;">' + projIdAndRec.get(proId).LastModifiedBy.Name + '</td><td style="text-align: center; vertical-align: middle;">' + projIdAndRec.get(proId).LastModifiedDate.format('MM/dd/yyyy HH:mm')  + '</td><td style="text-align: center; vertical-align: middle;">' + label  + '</td><td style="text-align: center; vertical-align: middle;">' + oldValue + '</td><td style="text-align: center; vertical-align: middle;">' + newValue + '</td></tr>';
                            }
                            htmlBody += '</table><br/>';
                        }
                        
                        htmlBody += 'Please contact the “Edited By” user if you have any questions or concerns. <br/>';
                        htmlBody += '<br/>System Generated Email';
                        mail.setHtmlBody(htmlBody);
                        mail.setSaveAsActivity(false);
                        emailToAccountingGroup.add(mail);
                    }
                    
                    if(emailToAccountingGroup != NULL && emailToAccountingGroup.size() > 0) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToAccountingGroup);
                    }
                }
            }catch(Exception e) {
    
                List<Messaging.SingleEmailMessage> ErrorMailMsg = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                mail.setToAddresses(new String[] {system.Label.TimeCardDayEmail});
                mail.setSubject('Error on Email Notification To Accounting Group whenever DLS Class # / Project Name field is changed in project record'); 
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                mail.setPlainTextBody(errorMessage);
                ErrorMailMsg.add(mail);
                try{
                    if( ErrorMailMsg != NULL && ErrorMailMsg.size() > 0 ){
                        Messaging.sendEmail(ErrorMailMsg); 
                    }
                } catch (Exception ex){
                    system.debug('Ex::::'+ex);
                }    
            } 
        }
    }
    
    // W-005871 PT Rate and GL Variable 1 to update the Project task when Project QB Classification and Hourly Rate is updated
    public static void updateProjectTask(List<AcctSeed__Project__c> newList, Map<Id,AcctSeed__Project__c> oldMap) {
        Map<Id, String> projIdAndClassification = new Map<Id, String>();
        Map<String, Id> accVarNameAndId = new Map<String, Id>();
        Map<Id, Decimal> projIdAndHourlyRate = new Map<Id, Decimal>();
        Set<Id> projIds = new Set<Id>();
        List<AcctSeed__Project_Task__c> projTasks = new List<AcctSeed__Project_Task__c>();
        Map<Id, Id> projIdAndGLAV2IdMap = new Map<Id, Id>();
        
        for(AcctSeed__Project__c p : newList) {
                    
            if(String.isNotBlank(p.QB_Classification__c) && p.QB_Classification__c != oldMap.get(p.Id).QB_Classification__c) {
                projIds.add(p.Id);
                projIdAndClassification.put(p.Id, p.QB_Classification__c);
            }
            
            if( p.Hourly_Rate__c != oldMap.get(p.Id).Hourly_Rate__c ){
                projIds.add(p.Id);
                projIdAndHourlyRate.put(p.Id, p.Hourly_Rate__c);
            }
            
            projIdAndGLAV2IdMap.put(p.Id, p.GL_Variable_2__c);
        }
        
        if(projIdAndClassification != NULL && projIdAndClassification.size() > 0) {
        
            for(AcctSeed__Accounting_Variable__c a : [SELECT Id, Name FROM AcctSeed__Accounting_Variable__c WHERE Name IN : projIdAndClassification.values() AND AcctSeed__Type__c = 'GL Account Variable 1' AND AcctSeed__Active__c = TRUE]){
            
                accVarNameAndId.put(a.Name, a.Id);
            }
        }
        
        for(AcctSeed__Project_Task__c pt : [SELECT Id,Name,Rate__c,AcctSeed__GL_Account_Variable_1__c,Project_Task_Type__c,AcctSeed__Project__c FROM AcctSeed__Project_Task__c WHERE AcctSeed__Project__c IN: projIds]) {
            if( projIdAndClassification.containsKey(pt.AcctSeed__Project__c) && accVarNameAndId.containsKey(projIdAndClassification.get(pt.AcctSeed__Project__c))) {
                pt.AcctSeed__GL_Account_Variable_1__c = accVarNameAndId.get(projIdAndClassification.get(pt.AcctSeed__Project__c));
            }
            
            if( projIdAndHourlyRate.containskey(pt.AcctSeed__Project__c) && (pt.Project_Task_Type__c == 'Language Training' || pt.Project_Task_Type__c == 'Preparation time') && !pt.Name.contains('Additional')) {
                pt.Rate__c = projIdAndHourlyRate.get(pt.AcctSeed__Project__c);
            }
            
            pt.AcctSeed__GL_Account_Variable_2__c = projIdAndGLAV2IdMap.get(pt.AcctSeed__Project__c);
            UpdateContAssignStatusAsEnded.projTaskStaticIdSet.contains(pt.Id);
            projTasks.add(pt);
        }
        
        if( projTasks.size() > 0 ) {
            System.debug('projTasks::::'+projTasks);
            update projTasks;
        }
    }
    
    //Added By Dhinesh - W-006013 - Zoom Integration - to check the zoom user license type when project changed to active or ended
    public static void checkZoomUserLicenseTypesForInstructor(Set<Id> instructorsNeedsZoomUser){
        
        Set<Id> instructorsNeedsProZoomUser = new Set<Id>();
        Id onlineRoomId = ZoomUtil.getOnlineRoomId();
        
        //Modified By Dhinesh - 15/7/2022 - W-007513 - Zoom License Agreement changes
        for(Schedule__c sch : [SELECT Id, Instructor__c FROM Schedule__c
                               WHERE Instructor__c IN :instructorsNeedsZoomUser AND (Room__c = :onlineRoomId OR Create_Zoom_Meetings__c = true) AND Status__c = 'Active' 
                               AND Project_Task__r.Project_Task_Type__c != 'Preparation time' AND Varied_Day__c = true AND Start_Date__c <= TODAY AND End_Date__c >= TODAY]){
            
          instructorsNeedsProZoomUser.add(sch.Instructor__c);
        }
        
        for(Events__c event : [SELECT Id, Instructor__c FROM Events__c
                                            WHERE Instructor__c IN :instructorsNeedsZoomUser AND Date__c = :System.today() AND (Room__c = :onlineRoomId OR Schedule__r.Create_Zoom_Meetings__c = true) AND Status__c = 'Scheduled' 
                                           AND (Project_Task__r.Project_Task_Type__c != 'Preparation time' OR Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time')]){
            
            instructorsNeedsProZoomUser.add(event.Instructor__c);     
        }
        
        if(instructorsNeedsZoomUser.size() > 0)
            ZoomUtil.checkContactForZoomUserAndLicenseType(instructorsNeedsZoomUser, instructorsNeedsProZoomUser);      
    }
    
    // Added By HL - W-006626 - Refund Calculation Worksheet (JUL-1-2021)
    // To send an email to Project Manager and LT Coordinator when the Late Cancellation is Yes and the Number of Hrs Charge field value gets filled in the project record.
    public static void sendPaperTimesheetEmailOnLC(Set<Id> projIds){
    
        if(projIds != NULL && projIds.size() > 0){
            
            Map<Id, Id> projIdAndPMId = new Map<Id, Id>();
            Map<Id, List<String>> proIdAndToAddresses = new Map<Id, List<String>>();
            Set<String> projIdAndPosSet = new Set<String>();
            
            for(Contact_Assignments__c c : [SELECT Id, Project__c, Candidate_Name__r.Email, Candidate_Name__c, Assignment_Position__c
                                            FROM Contact_Assignments__c
                                            WHERE Project__c IN : projIds AND Record_Type_Developer_Name__c = 'Staff' AND
                                                Assignment_Position__c IN ('Project Manager', 'Project Support') AND 
                                                Candidate_Name__r.Email != NULL 
                                                    ORDER BY CreatedDate DESC]){
                
                String projIdAndPos = c.Project__c+c.Assignment_Position__c;
                if(!projIdAndPosSet.contains(projIdAndPos)){
                
                    if(!proIdAndToAddresses.containsKey(c.Project__c)){
                        
                        proIdAndToAddresses.put(c.Project__c, new List<String>());                    
                    }  
                    proIdAndToAddresses.get(c.Project__c).add(c.Candidate_Name__r.Email); 
                    projIdAndPMId.put(c.Project__c, c.Candidate_Name__c);  
                    projIdAndPosSet.add(projIdAndPos);      
                }
            }
            System.debug('::::proIdAndToAddresses:::'+proIdAndToAddresses);
            
            if(proIdAndToAddresses != NULL && proIdAndToAddresses.size() > 0){
            
                try{
                
                    EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Late_Cancellation_Email_To_Project_Manager_and_LT_Coordinator'];
                    
                    List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
                
                    String orgWideEmailId = '';
                    
                    if(orgWideEmail != null && orgWideEmail.size() > 0){
                        orgWideEmailId = orgWideEmail[0].Id;
                    }
                
                    List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
                    
                    for(Id projId : proIdAndToAddresses.keySet()){
                        
                        if(template != NULL){
                        
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            if(orgWideEmailId != null) {
                                mail.setOrgWideEmailAddressId(orgWideEmailId);
                            }
                            mail.setToAddresses(proIdAndToAddresses.get(projId));
                            mail.setTemplateId(template.Id);
                            // To fix the issue related to "System.EmailException: REQUIRED_FIELD_MISSING, Missing targetObjectId with template:"
                            mail.setTargetObjectId(projIdAndPMId.get(projId));
                            // This method would make sure email will not be sent to user
                            mail.setTreatTargetObjectAsRecipient(false);
                            // For Merge fields population
                            mail.setWhatId(projId);
                            sendEmailList.add(mail);
                        }
                    }
                    System.debug('::::sendEmailList::::'+sendEmailList);
            
                    if( sendEmailList != NULL && sendEmailList.size() > 0 ) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailList);
                    }
                }catch(Exception e) {
                            
                    String errorMessage = '';
                    errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                    
                    ErrorHandler errHandler = new ErrorHandler();
                    errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Sending Late Cancellation Email To Project Manager and Project Support');
                } 
            }
        }
    }
    
    @future
    public static void sendProjectEndedMailToAccountingGroup(String projectsEndedToSendMailStr, String oldProjectsEndedToSendMailMapStr){
        
        try{
            List<Acctseed__Project__c> projectsEndedToSendMail = (List<Acctseed__Project__c>) JSON.deserialize(projectsEndedToSendMailStr, (List<Acctseed__Project__c>.class));
            Map<Id, Acctseed__Project__c> oldProjectsEndedToSendMailMap = (Map<Id, Acctseed__Project__c>) JSON.deserialize(oldProjectsEndedToSendMailMapStr, (Map<Id, Acctseed__Project__c>.class));
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Set<Id> accIds = new Set<Id>(); 
            Set<Id> userIds = new Set<Id>();            
            
            for(Acctseed__Project__c proj : projectsEndedToSendMail){
                if(proj.AcctSeed__Account__c != null)
                    accIds.add(proj.AcctSeed__Account__c);
                userIds.add(proj.LastModifiedById);
            }
            
            if(accIds.size() > 0){
                Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id IN :accIds]);
                Map<Id, User> userMap = new Map<Id, User>([SELECT Id, Name FROM User WHERE Id IN :userIds]);
                List<String> toEmailAddress = new List<String>{'accountinggroup@dlsdc.com'};
                                
                for(Acctseed__Project__c proj : projectsEndedToSendMail){
                
                    if(proj.AcctSeed__Account__c != null && accountMap.get(proj.AcctSeed__Account__c).Name.startsWithIgnoreCase('PVT')){
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        
                        String subject = 'Project Status field has been changed';
                        
                        String mailContent = '<html>Accounting Team,<br/><br/>';
                        mailContent += 'The Project Status on the following project record has been changed:<br/> ';
                        mailContent += System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+proj.Id;
                        mailContent += '<br/><br/><table style="border-collapse: collapse;"><tr><th style="border: 1px solid #ddd;padding: 10px;">DLS Class #</th><th style="border: 1px solid #ddd;padding: 10px;">Edited By</th><th style="border: 1px solid #ddd;padding: 10px;">Edit Date</th><th style="border: 1px solid #ddd;padding: 10px;">Field / Event</th><th style="border: 1px solid #ddd;padding: 10px;">Old Value</th><th style="border: 1px solid #ddd;padding: 10px;">New Value</th></tr>';
                        mailContent += '<tr><td style="border: 1px solid #ddd;padding: 10px;">'+proj.DLS_Ref__c+'</td><td style="border: 1px solid #ddd;padding: 10px;">'+userMap.get(proj.LastModifiedById).Name+'</td><td style="border: 1px solid #ddd;padding: 10px;">'+proj.LastModifiedDate.format('MM/dd/YYYY hh:mm a')+'</td><td style="border: 1px solid #ddd;padding: 10px;">Project Status</td><td style="border: 1px solid #ddd;padding: 10px;">'+oldProjectsEndedToSendMailMap.get(proj.Id).Acctseed__Status__c+'</td><td style="border: 1px solid #ddd;padding: 10px;">'+proj.Acctseed__Status__c+'</td></tr>';
                        mailContent += '</table><br/><br/>';
                        mailContent += 'Please contact the '+userMap.get(proj.LastModifiedById).Name+' user if you have any questions or concerns.<br/> <br/>';
                        mailContent += 'System Generated Email';         
                        mailContent += '</html>';
    
                        mail.setToAddresses(toEmailAddress);
                        mail.setSubject(subject);
                        mail.sethtmlBody(mailContent);
                        mails.add(mail);
                    }
                }                
                if( mails != null && mails.size() > 0 && !Test.isRunningTest()) {
                    Messaging.sendEmail(mails);
                }
            }
        }catch(Exception e) {
                            
            String errorMessage = '';
            errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
            
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on send Project Ended Mail To Accounting Group');
        } 
        
    }
        
    public static void updateChildRecords_MPD(){
        
        //System.debug('::opp_MPD::::'+ManageProjectDatescontroller.opp_MPD);
        //System.debug('::conAssign_MPD::::'+ManageProjectDatescontroller.conAssign_MPD);
        //System.debug('::projTask_MPD::::'+ManageProjectDatescontroller.projTask_MPD);
        //System.debug('::schedule_MPD::::'+ManageProjectDatescontroller.schedule_MPD);
        //System.debug('::insertPDO_MPD::::'+ManageProjectDatescontroller.insertPDO_MPD);
        //System.debug('::deletePDO_MPD::::'+ManageProjectDatescontroller.deletePDO_MPD);
        //System.debug('::assessRep_MPD::::'+ManageProjectDatescontroller.assessRep_MPD);
        
        if(ManageProjectDatescontroller.opp_MPD.size() > 0){
            update ManageProjectDatescontroller.opp_MPD;
        }
        if(ManageProjectDatescontroller.conAssign_MPD.size() > 0){
            upsert ManageProjectDatescontroller.conAssign_MPD;
        }
        if(ManageProjectDatescontroller.projTask_MPD.size() > 0){
            update ManageProjectDatescontroller.projTask_MPD;
        }
        if(ManageProjectDatescontroller.schedule_MPD.size() > 0){
            update ManageProjectDatescontroller.schedule_MPD;
        }
        if(ManageProjectDatescontroller.insertPDO_MPD.size() > 0){
            insert ManageProjectDatescontroller.insertPDO_MPD;
        }
        if(ManageProjectDatescontroller.deletePDO_MPD.size() > 0){
            delete ManageProjectDatescontroller.deletePDO_MPD;
        }
        if(ManageProjectDatescontroller.assessRep_MPD.size() > 0){
            update ManageProjectDatescontroller.assessRep_MPD;
        }
    }
    
    @future
    public static void updateCongaSignTransaction_CTP(Map<Id, Id> oppIdAndProjId){
        
        List<APXT_CongaSign__Transaction__c> cst = [SELECT Id, Name, Parent_006__c FROM APXT_CongaSign__Transaction__c WHERE Parent_006__c = : oppIdAndProjId.keySet() AND APXT_CongaSign__Status__c IN ('SENT', 'COMPLETE')];
        
        if(cst.size() > 0){

            List<APXT_CongaSign__Transaction__c> updateCST = new List<APXT_CongaSign__Transaction__c>();
            
            for(APXT_CongaSign__Transaction__c t : cst){
                
                t.Parent_a48__c = oppIdAndProjId.containsKey(t.Parent_006__c) ? oppIdAndProjId.get(t.Parent_006__c) : null;
                updateCST.add(t);
            }
            
            if(updateCST.size() > 0){
                update updateCST;
            }
        }
    }
    
    public static void sendLowHoursBalanceEmail(List<Acctseed__Project__c> projects, Map<Id, Id> projIdAndPIId){
        
        Map<Id, String> projIdAndStdInsNames = new Map<Id, String>();
        Map<Id, List<String>> projIdAndStdInsEmails = new Map<Id, List<String>>();
        Map<Id, Date> projIdAndLastApprovedTCDDate = new Map<Id, Date>();
        Map<Id, String> projIdAndPMName = new Map<Id, String>();
        List<Acctseed__Project__c> projsToSendLowHoursBalEmail = new List<Acctseed__Project__c>();
        Set<String> projectTypes = new Set<String>{'SLP-FT', 'SLP-PT', 'PLP'};
      
        Map<Id, Program_Iteration__c> proIterationMap = new Map<Id, Program_Iteration__c>([SELECT Id, Project_Type__c FROM Program_Iteration__c WHERE Id IN : projIdAndPIId.values()]);
                
        for(Acctseed__Project__c pro : projects){
            if(!pro.Account_Name__c.contains('DODA') || (pro.Account_Name__c.contains('DODA') && (!projIdAndPIId.containsKey(pro.Id) || (projIdAndPIId.containsKey(pro.Id) && 
                proIterationMap.containsKey(projIdAndPIId.get(pro.Id)) && !projectTypes.contains(proIterationMap.get(projIdAndPIId.get(pro.Id)).Project_Type__c))))){
                
                projsToSendLowHoursBalEmail.add(pro);
            }
        }
        
        if(projsToSendLowHoursBalEmail.size() > 0){
        
            for(Contact_Assignments__c ca : [SELECT Id, Project__c, Project__r.Instructors__c, Project__r.Students__c, Candidate_Name__r.Email, Project__r.Project_Manager__r.Name FROM Contact_Assignments__c WHERE Project__c IN : projsToSendLowHoursBalEmail AND Candidate_Name__r.Email != null AND Candidate_Name__r.IsEmailBounced = false AND Status__c = 'Active' AND RecordType.DeveloperName IN ('Instructor', 'Student')]){
                
                if(!projIdAndStdInsNames.containsKey(ca.Project__c)){
                    String stdAndInsNames = ca.Project__r.Students__c + ' and ' + ca.Project__r.Instructors__c;
                    projIdAndStdInsNames.put(ca.Project__c, stdAndInsNames);
                    projIdAndPMName.put(ca.Project__c, ca.Project__r.Project_Manager__r.Name);
                } 
                
                if(!projIdAndStdInsEmails.containsKey(ca.Project__c)){
                    projIdAndStdInsEmails.put(ca.Project__c, new List<String>());
                }
                projIdAndStdInsEmails.get(ca.Project__c).add(ca.Candidate_Name__r.Email);
            }
            
            for(AcctSeed__Time_Card_Day__c day : [SELECT Id, AcctSeed__Date__c, AcctSeed__Time_Card_Line__r.AcctSeed__Project__c FROM AcctSeed__Time_Card_Day__c WHERE AcctSeed__Time_Card_Line__r.AcctSeed__Project__c IN : projsToSendLowHoursBalEmail AND Status__c = 'Approved' ORDER BY AcctSeed__Date__c DESC]){
                
                if(!projIdAndLastApprovedTCDDate.containsKey(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c)){
                    projIdAndLastApprovedTCDDate.put(day.AcctSeed__Time_Card_Line__r.AcctSeed__Project__c, day.AcctSeed__Date__c);
                }
            }
        
            List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        
            try{
                for(Acctseed__Project__c proj : projsToSendLowHoursBalEmail){
                    
                    if(projIdAndStdInsEmails.containsKey(proj.Id) && projIdAndStdInsEmails.get(proj.Id).size() > 0){
                    
                        String tcdDate_Str = projIdAndLastApprovedTCDDate.containsKey(proj.Id) ? String.valueOf(projIdAndLastApprovedTCDDate.get(proj.Id)) : '';
                        String tcdDate = tcdDate_Str != '' ? (tcdDate_Str.split('-')[1]+'/'+tcdDate_Str.split('-')[2]+'/'+tcdDate_Str.split('-')[0]) : '';
                        
                        String projED_Str = String.valueOf(proj.End_Date__c);
                        String projED = projED_Str.split('-')[1]+'/'+projED_Str.split('-')[2]+'/'+projED_Str.split('-')[0];
                                                
                        String subjectStr = 'Low Hours Remaining for DLS Class #' + proj.DLS_Ref__c;
                        String htmlBody = '';
                        htmlBody += 'Dear '+ projIdAndStdInsNames.get(proj.Id) + ', <br/><br/>';
                        htmlBody += 'As of ' + tcdDate + ', your <b>Hours Remaining are ' + proj.Hours_Remaining__c + '</b>, and your class End Date is ' + projED + '.<br/><br/>';
                        htmlBody += '<b>Please ensure you do not exceed the number of remaining hours.</b><br/><br/>';
                        htmlBody += 'Please let me know if you have any questions.<br/>';
                        htmlBody += projIdAndPMName.get(proj.Id);
            
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setToAddresses(projIdAndStdInsEmails.get(proj.Id));
                        mail.setSubject(subjectStr);
                        mail.sethtmlBody(htmlBody);
                        sendEmailList.add(mail);
                    }
                }
                if(sendEmailList.size() > 0 ){
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailList);
                }
            }catch(Exception e){
                
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                    
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,System.Label.TimeCardDayEmail,'Error on Sending Low Hours Balance Email');
            } 
        }
    }
    
    public static String getOrgWideEmailId(String displayName){
    
        List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = : displayName];
        String orgWideEmailId = '';
        if(!orgWideEmail.isEmpty()){
            orgWideEmailId = orgWideEmail[0].Id;
        }
        return orgWideEmailId;
    }
    
    public static String getEmailTemplateId(String developerName){
    
        List<EmailTemplate> template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = : developerName];
        String templateId = '';
        if(!template.isEmpty()){
            templateId = template[0].Id;
        }
        return templateId;
    }
    
    public static Messaging.SingleEmailMessage getSingleEmail(String orgWideEmailId, String targetObjId, List<String> toAddresses, List<String> cCAddresses, String emailTemplateId, String whatId, String htmlBody, String subject, Boolean saveAsActivity, Boolean treatTargetObjAsRecipient){
                 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        if(String.isNotBlank(orgWideEmailId)) {
            mail.setOrgWideEmailAddressId(orgWideEmailId);
        }
        if(String.isNotBlank(targetObjId)){
            mail.setTargetObjectId(targetObjId);
        }
        if(toAddresses != null && toAddresses.size() > 0){
            mail.setToAddresses(toAddresses);
        }
        if(cCAddresses != null && cCAddresses.size() > 0){
            mail.setCcAddresses(cCAddresses);
        }
        if(String.isNotBlank(emailTemplateId)){
            mail.setTemplateId(emailTemplateId);
        }
        if(String.isNotBlank(htmlBody)){
             mail.setHtmlBody(htmlBody);
        }
        if(String.isNotBlank(subject)){
             mail.setSubject(subject);
        }
        if(String.isNotBlank(whatId)){
            mail.setWhatId(whatId);
        }
        mail.setSaveAsActivity(saveAsActivity);
        mail.setTreatTargetObjectAsRecipient(treatTargetObjAsRecipient);
                                    
        return mail;
    }
}