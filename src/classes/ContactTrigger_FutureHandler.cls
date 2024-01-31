// This class called from Contact Trigger
// Created by Sukanya on DEC 22 2016

public class ContactTrigger_FutureHandler {
    
    public static Map<String, Id> conRtMap = new Map<String, Id>();
    public static Boolean loadResource = false;
    public static Boolean fromContactEmail = false;
    public static Set<Id> contactIdsForZoomUserCreation = new set<Id>();
    
    @future
    public static void updateUserRecords(String userJson ) {
     
        List<User> userList = (List<User>) System.JSON.deserialize(userJson, List<User>.class);
        system.debug('::::userList::::::::'+userList);
        
        if(userList != null && userList.size() > 0){
         update userList;
        }
    }
    
    // Added by Sukanya on April 18 2017
    // For Contact Supervisor field updation from User trigger
    
    @future
    public static void updateContactRecords(String contactJson) {
      
        List<Contact> contactList = (List<Contact>) System.JSON.deserialize(contactJson, List<Contact>.class);
        system.debug(':::::::contactList:::::::'+contactList);
        
        if(contactList != null && contactList.size() > 0) {
          update contactList;
        }
    }
    
   public class wrapper {
      String field;
      String oldVal;
      String newVal;
   } 
    
    public static void FieldchangeNotification(List<Contact> newConList, Map<Id,Contact> oldMap) {
        //System.debug(':::::newConList::::'+newConList);
        System.debug(':::::newConList::::'+newConList[0].Name+'::::Size:::'+newConList.size());
       
        Map<Id,List<wrapper>> conId_Field_values = new Map<Id,List<wrapper>>();
        Map<Id,Contact> conMap = new Map<Id,Contact>();
        
        // Work Item: W-007105 - Update Record Types to Contact Field Change Emails to HR
        //W-007175 - include Home Dept & Supervisor name field in notification
        Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
        Id staffRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
        
        Set<Id> supervisorIds = new Set<Id>();
        
        //get contact supervisor name if the supervisor name field is changed
        for(Contact con : newConList){
            
            if((con.RecordTypeId == candidateRTId || con.RecordTypeId == staffRecTypeId) 
                && con.Supervisor_Name__c != oldmap.get(con.Id).Supervisor_Name__c){
                
                if(!supervisorIds.contains(con.Supervisor_Name__c)){
                    supervisorIds.add(con.Supervisor_Name__c);
                }
                
                if(!supervisorIds.contains(oldmap.get(con.Id).Supervisor_Name__c)) {
                    supervisorIds.add(oldmap.get(con.Id).Supervisor_Name__c);
                }
            }
        }
        
        //query user record for supervisor name
        Map<Id,User> supervisorIdRecordMap = new Map<Id,User>([SELECT Id,Name FROM User WHERE Id IN :supervisorIds]);
    
        for(Contact con : newConList) {
            if(con.RecordTypeId == candidateRTId || con.RecordTypeId == staffRecTypeId){
                if(con.Name != oldmap.get(con.Id).Name || con.Email != oldmap.get(con.Id).Email 
                    || con.Phone != oldmap.get(con.Id).Phone || con.MobilePhone != oldmap.get(con.Id).MobilePhone
                    /*|| con.MailingCity != oldmap.get(con.Id).MailingCity || con.MailingState != oldmap.get(con.Id).MailingState
                    || con.MailingCountry != oldmap.get(con.Id).MailingCountry || con.MailingPostalCode != oldmap.get(con.Id).MailingPostalCode*/ 
                    || con.Home_Dept__c != oldmap.get(con.Id).Home_Dept__c || con.Supervisor_Name__c != oldmap.get(con.Id).Supervisor_Name__c){
                    
                    if(!conMap.containsKey(con.Id)) {
                        conMap.put(con.Id,con);
                    }
                    
                    conId_Field_values.put(con.Id,new List<wrapper>{});
                    
                    if(con.Name != oldMap.get(con.Id).Name) {
                        wrapper wr = new wrapper();
                        wr.field = 'Name';
                        wr.oldVal = oldMap.get(con.Id).Name;
                        wr.newVal = con.Name;
                        conId_Field_values.get(con.Id).add(wr);
                    }
                    
                    if(con.Email != oldMap.get(con.Id).Email) {
                        wrapper wr = new wrapper();
                        wr.field = 'Email';
                        wr.oldVal = oldMap.get(con.Id).Email;
                        wr.newVal = con.Email;
                        conId_Field_values.get(con.Id).add(wr);
                    }
                    
                    if(con.Phone != oldMap.get(con.Id).Phone) {
                        wrapper wr = new wrapper();
                        wr.field = 'Phone';
                        wr.oldVal = oldMap.get(con.Id).Phone;
                        wr.newVal = con.Phone;
                        conId_Field_values.get(con.Id).add(wr);
                    }
                        
                    if(con.MobilePhone != oldMap.get(con.Id).MobilePhone) {
                        wrapper wr = new wrapper();
                        wr.field = 'Mobile';
                        wr.oldVal = oldMap.get(con.Id).MobilePhone;
                        wr.newVal = con.MobilePhone;
                        conId_Field_values.get(con.Id).add(wr);
                    }
                    
                    /*if(con.MailingCity != oldMap.get(con.Id).MailingCity) {
                        wrapper wr = new wrapper();
                        wr.field = 'Mailing City';
                        wr.oldVal = oldMap.get(con.Id).MailingCity;
                        wr.newVal = con.MailingCity;
                        conId_Field_values.get(con.Id).add(wr);
                    }
                        
                    if(con.MailingState != oldMap.get(con.Id).MailingState) {
                        wrapper wr = new wrapper();
                        wr.field = 'Mailing State';
                        wr.oldVal = oldMap.get(con.Id).MailingState;
                        wr.newVal = con.MailingState;
                        conId_Field_values.get(con.Id).add(wr);
                    }
                        
                    if(con.MailingCountry != oldMap.get(con.Id).MailingCountry) {
                        wrapper wr = new wrapper();
                        wr.field = 'Mailing Country';
                        wr.oldVal = oldMap.get(con.Id).MailingCountry;
                        wr.newVal = con.MailingCountry;
                        conId_Field_values.get(con.Id).add(wr);
                    }
                    
                    if(con.MailingPostalCode != oldMap.get(con.Id).MailingPostalCode) {
                        wrapper wr = new wrapper();
                        wr.field = 'Mailing PostalCode';
                        wr.oldVal = oldMap.get(con.Id).MailingPostalCode;
                        wr.newVal = con.MailingPostalCode;
                        conId_Field_values.get(con.Id).add(wr);
                    }*/
                    
                     if(con.Home_Dept__c != oldMap.get(con.Id).Home_Dept__c) {
                        wrapper wr = new wrapper();
                        wr.field = 'Home Dept';
                        wr.oldVal = oldMap.get(con.Id).Home_Dept__c;
                        wr.newVal = con.Home_Dept__c;
                        conId_Field_values.get(con.Id).add(wr);
                    }
                    
                    if(con.Supervisor_Name__c != oldMap.get(con.Id).Supervisor_Name__c) {
                        wrapper wr = new wrapper();
                        wr.field = 'Supervisor Name';
                        wr.oldVal = supervisorIdRecordMap.containsKey(oldMap.get(con.Id).Supervisor_Name__c) ? supervisorIdRecordMap.get(oldMap.get(con.Id).Supervisor_Name__c).Name : null;
                        wr.newVal = supervisorIdRecordMap.containsKey(con.Supervisor_Name__c) ? supervisorIdRecordMap.get(con.Supervisor_Name__c).Name : null;
                        conId_Field_values.get(con.Id).add(wr);
                    }
                }  
            }
        }
        
        system.debug('::::::::conId_Field_values::::::'+conId_Field_values);
        system.debug('::::::::conMap::::::'+conMap.size());
        
        // Send Email to HR Usr - Pim 
        
        if(conMap.size() > 0) {
        
            // Modified by HL on Oct 31 2019
            // WorkItem - W-003476 : Contact information change email notifications
            Set<Id> userIds = new Set<Id>();
            
            System_Values__c sysVal = System_Values__c.getValues('Contact field change notify Usr Ids');  
            if (sysVal != null && sysVal.Value__c != null) {
                String usrIds = String.valueOf(sysVal.Value__c);
                
                if (String.isNotEmpty(usrIds)) {
                    if (usrIds.contains(',')) {
                        for(String str : usrIds.split(',')) {
                            if (!userIds.contains(Id.valueOf(str.trim()))){
                                userIds.add(Id.valueOf(str.trim()));
                            }
                        }
                    } else {
                        userIds.add(Id.valueOf(usrIds));
                    }
                } 
            } 
            System.debug(':::userIds:::SIZE'+userIds.size());
            
            List<User> sendingUsr = new List<User>();
                        
            sendingUsr = [SELECT Id,Name,Email FROM User WHERE Id IN :userIds];
            System.debug('sendingUsr:::'+sendingUsr.size());
        
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            String mailContent = '<html>Hi '; 
            if(sendingUsr.size() > 0)           
                //mailContent = mailContent + sendingUsr[0].Name;
                
            mailContent += ',<br/>The following Contact values have changed. Please have a look:  <br/>'; 
            mailContent += '<br/><table border="1" style="border-collapse: collapse;width:80%;"><thead><th>Contact Name</th><th>Details</th></thead><tbody>';    
            
            
            // W-007573: Contact Values Routing Issue
            //String orgUrl = URL.getSalesforceBaseUrl().toExternalForm();            
            String org_Prefix_URL = System.Label.Org_Prefix_Start_URL;
            
            for(Id conId : conMap.keySet()) {
                
                mailContent += '<tr><td width="20%"><a href="'+org_Prefix_URL+'/'+conId+'">'+conMap.get(conId).FirstName+' '+conMap.get(conId).LastName+'</a></td>'; 
                
                mailContent += '<td width="60%;"><table border="1" style="border-collapse: collapse;width: 100%;"><thead><th>Field</th><th>Old Value</th><th>New Value</th></thead><tbody>';
                
                for(wrapper wrp: conId_Field_values.get(conId)) {
                    
                    mailContent += '<tr><td >'+wrp.field+'</td>';
                    
                    if(wrp.oldVal != null)
                        mailContent += '<td>'+wrp.oldVal+'</td>';
                    else
                        mailContent += '<td></td>';
                        
                    if(wrp.newval != null)
                        mailContent += '<td>'+wrp.newVal+'</td>';
                    else
                        mailContent += '<td></td>';
                }
                mailContent += '</tr></tbody></table>';
            }
            
            mailContent += '</tbody></table><br/><p>This e-mail was auto generated. Please do not respond.</p><p>If you have questions, contact your Salesforce Administrator.</p>';
            mailContent += '</html>';
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            if(sendingUsr.size() > 0 && sendingUsr.size() > 1){
                mail.setToAddresses(new List<String>{sendingUsr[0].Email, sendingUsr[1].Email});
            }
            
            if(sendingUsr.size() > 0 && sendingUsr.size() == 1){
                mail.setToAddresses(new List<String>{sendingUsr[0].Email});
            }
            
            mail.setSubject('Contact values have changed. Please review it');
            mail.sethtmlBody(mailContent);
            mails.add(mail);
            System.debug('mails::::'+mails);
            if( mails != null && mails.size() > 0 && !Test.isRunningTest()) {
                //Messaging.sendEmail(mails);
                //Commented for testing purpose in sandbox and should be uncommented when we move to production
            }
        }
    }
    
    public static void getContactRTNameId() {
                
        for(RecordType rt : SObjectQueryService.getRecTypeListBySobjTypeAndDevName('','Contact',new Set<String>())) {
            conRtMap.put(rt.DeveloperName, rt.Id);
        }
    }
    
    // Added By HL to update Contact_Record_Type__c field value in Cost Rate record when Contact RecordType is changed
    public static void toUpdateCostRateFieldValue(Map<Id, Id> conIdAndRecordTypeIdMap){
    
        System.debug('conIdAndRecordTypeIdMap===='+conIdAndRecordTypeIdMap+'conIdAndRecordTypeIdMap SIZE====='+conIdAndRecordTypeIdMap.size());
        Map<Id, Id> conIdAndRecordTypeId = conIdAndRecordTypeIdMap;
        
        if(conIdAndRecordTypeId.size() > 0){
                
            Set<String> crStatus = new Set<String>{'Draft', 'Approved', 'Submitted for Approval'};
            Map<Id, List<AcctSeed__Cost_Rates__c>> conIdAndCostRates = new Map<Id, List<AcctSeed__Cost_Rates__c>>();
            
            Map<Id, RecordType> recordTypeMap = new Map<Id, RecordType>([SELECT Id, DeveloperName FROM RecordType WHERE Id IN :conIdAndRecordTypeId.values()]);
            List<AcctSeed__Cost_Rates__c> toUpdateCRs= new List<AcctSeed__Cost_Rates__c>();
            
            for(AcctSeed__Cost_Rates__c cr : [SELECT Id, Contact__c , Contact_Record_Type__c FROM AcctSeed__Cost_Rates__c WHERE Contact__c IN :conIdAndRecordTypeId.keySet() AND Status__c IN :crStatus]){
            
                if(conIdAndRecordTypeId.containsKey(cr.Contact__c)){
                        
                    cr.Contact_Record_Type__c = recordTypeMap.get(conIdAndRecordTypeId.get(cr.Contact__c)).DeveloperName;
                    toUpdateCRs.add(cr);
                    System.debug('CR====='+cr);
                }
            }
            System.debug('toUpdateCRs==='+toUpdateCRs+'toUpdateCRs SIZE====='+toUpdateCRs.size());
            if(toUpdateCRs.size() > 0){
                update toUpdateCRs;
            }
        }
    }
    
    // Added by HL to update Time Zone in user records when populating Timezone field value in contact records
    @future
    public static void updateUserTimeZone(Map<Id, String> conIdAndTimeZone) {
                   
        List<User> updateUserRecs = new List<User>();
        
        for(User u : [
            SELECT Id, Name, Email, TimeZoneSidKey, ContactId 
            FROM User 
            WHERE ContactId IN : conIdAndTimeZone.keySet() AND IsPortalEnabled = TRUE AND IsActive = TRUE
        ]){
        
            if(conIdAndTimeZone.containsKey(u.ContactId)){
                u.TimeZoneSidKey =  conIdAndTimeZone.get(u.ContactId);
                updateUserRecs.add(u);
            }  
        }
        System.debug('updateUserRecs========'+updateUserRecs+'updateUserRecs SIZE========'+updateUserRecs.size());
        
        if(updateUserRecs.size() > 0){
            update updateUserRecs;
        }
    }
    
    /*************
        - Added by HL On Oct 25
        - This method is created to avoid following error
        - "DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa)"
        ***************/
    @future
    public static void upsertUserRecs(Set<Id> conIds) {
    
        if(conIds != NULL && conIds.size() > 0){
            
            Set<Id> filteredConIds = new Set<Id>();
            
            for(Contact_Assignments__c c : [SELECT Id, Candidate_Name__c
                                            FROM Contact_Assignments__c
                                            WHERE Candidate_Name__c IN : conIds AND RecordType.DeveloperName IN ('Student','Instructor') AND Status__c IN ('Active','Planned') 
                                                AND Assignment_Position__c IN ('Instructor','EI','Substitute Instructor','Class Leader','Student') AND (NOT Candidate_Name__r.Name LIKE '%Student%')
                                                AND Project__r.QB_Classification__c != 'OF0MTT0PS' AND (NOT Project__r.Name LIKE '%Bah%') AND 
                                                Project__r.AcctSeed__Status__c IN ('Order','Active') AND 
                                                Project__r.Name NOT IN ('ELIZABETH HUML','MARA BOROUGHS','LEANN TAGWERKER','TRAVIS CUNNINGHAM','DLI Hausa-2018-Pena/Falanga','DLI Somali-2018-Deborah/Mickayla/Katie/Collin','Danielle Ward 2019') AND 
                                                Candidate_Name__r.Active_DLS_Online_User__c = FALSE AND Paper_Timesheet__c = FALSE AND Start_Date__c != NULL]){
                
                filteredConIds.add(c.Candidate_Name__c);
            }
            
            Set<Id> conIdsToCreateUser = new Set<Id>();
            Set<Id> conIdsToUpdateUser = new Set<Id>();
            List<UtilDomain.ErrorWrapper> errorWrapperList = new List<UtilDomain.ErrorWrapper>();
        
            Map<Id, Boolean> conIdAndIsUserExist = UserManagementUtil.checkAlreadyUserExist(filteredConIds);
            
            for(Id conId : conIdAndIsUserExist.keySet()){
                
                if(conIdAndIsUserExist.get(conId)){
                
                    conIdsToUpdateUser.add(conId);
                }else{
                    
                    conIdsToCreateUser.add(conId);
                }
            }
            System.debug('conIdsToUpdateUser====='+conIdsToUpdateUser+'conIdsToUpdateUser SIZE===='+conIdsToUpdateUser.size());
            System.debug('conIdsToCreateUser====='+conIdsToCreateUser+'conIdsToCreateUser SIZE===='+conIdsToCreateUser.size());
            
            if(conIdsToUpdateUser.size() > 0){
                
                List<UtilDomain.ErrorWrapper> errorInUserUpdation = UserManagementUtil.updateExistingUser(conIdsToUpdateUser);
                errorWrapperList.addAll(errorInUserUpdation);
            }
            
            if(conIdsToCreateUser.size() > 0){
                
                List<UtilDomain.ErrorWrapper> errorInUserCreation = UserManagementUtil.createUserForContact(conIdsToCreateUser);
                errorWrapperList.addAll(errorInUserCreation);
            }
        }
    }
    
    // Added by HL on Jan 14 2020
    public static void updateUserEmail(Map<Id, String> conIdAndEmail) {
        
        Map<Id,String> filteredEmailMap = conIdAndEmail;
        List<User> userForEmail = new List<User>();
        Map<String,Id> emailContactIdMap = new Map<String,Id>();
        Map<Id,User> contactIdUserRec = new Map<Id,User>();
        
        List<UtilDomain.ErrorWrapper> errorWrapperList = new List<UtilDomain.ErrorWrapper>();
        
        if(conIdAndEmail != NULL && conIdAndEmail.size() > 0){
        
            for(Id conId : conIdAndEmail.keySet()){
                emailContactIdMap.put(conIdAndEmail.get(conId),conId);
            }
            
            system.debug(':::::::::emailContactIdMap::::'+emailContactIdMap.size());
            
            for(User usr : [SELECT Id,Email,Name,UserName,ContactId FROM User WHERE ContactId IN :conIdAndEmail.keySet()]){
                contactIdUserRec.put(usr.ContactId,usr);
            }
            
            system.debug(':::::::::contactIdUserRec::::'+contactIdUserRec);
        
            //Qry current contact & email related existing user & send email if already same email exist for other users
            
            for(User usr : [SELECT Id,Email,Name,UserName,ContactId FROM User WHERE UserName IN :conIdAndEmail.values()]){
                
                if(emailContactIdMap.containsKey(usr.UserName) && usr.ContactId != emailContactIdMap.get(usr.UserName) 
                    && contactIdUserRec.containsKey(emailContactIdMap.get(usr.UserName))){
                
                    filteredEmailMap.remove(emailContactIdMap.get(usr.UserName));
                    userForEmail.add(contactIdUserRec.get(emailContactIdMap.get(usr.UserName)));
                }
            }
            
            system.debug('::::::::::filteredEmailMap:::'+filteredEmailMap.size());
            system.debug('::::::::::userForEmail:::'+userForEmail.size());
        }      
        
        
        //Send email to users already have same user name
        if(userForEmail.size() > 0){
                
            String errMsg = 'The username already exists in this or another Salesforce organization. Usernames must be unique across all Salesforce organizations.';
            
            for(User usr : userForEmail){
                UtilDomain.ErrorWrapper errWrapper = new UtilDomain.ErrorWrapper(usr,errMsg,'User');
                errorWrapperList.add(errWrapper);
            }
            
            
            if(errorWrapperList.size() > 0){
            
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
               
                //Form Email contents
                String mailContent = '<html>Hello, <br/><br/>The following community users have issue while updating their username and email. Please handle those records manually:'; 
                mailContent += '<br/><br/><table border="1" style="border-collapse: collapse"><thead><th>Name</th><th>Error Description</th></thead><tbody>';    
                
                Set<String> keyStrSet = new Set<String>();
                
                for(UtilDomain.ErrorWrapper val : errorWrapperList) {
                    
                    
                    mailContent += '<tr><td width="25%"><a href="'+System.Label.Org_Prefix_Start_URL+'/'+val.record.get('Id')+'" target="_blank">'+val.record.get('Name')+'</a></td><td width="75%">'+ val.message +'</td></tr>'; 
                }
                
                mailContent += '</tbody></table><br/><p>This e-mail was auto generated. Please do not respond.</p><p>If you have questions, contact your Salesforce Administrator.</p>';
                mailContent += '</html>';
                
                
                //Send Email
                
                //Added custome setting to hold the exception recipients email ids
                //By NS on March 3 2020
                List<String> toAddressIds = new List<String>();

                System_Values__c sysVal = System_Values__c.getValues('User field update exception mail'); 
                if (sysVal != null && sysVal.Value__c != null) {
                    for (String st : sysVal.Value__c.split(',')) {
                        toAddressIds.add(st.trim());
                    }
                }
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddressIds);
                mail.setSubject('Error when community user updates user email & username');
                mail.sethtmlBody(mailContent);
                mails.add(mail);
                
                if( mails != null && mails.size() > 0 && !Test.isRunningTest()) {
                    Messaging.sendEmail(mails);
                }
            }
        }  
        
        //user update invocation
        if(filteredEmailMap.size() > 0){
            UserManagementUtil.updateUserRecs(filteredEmailMap,true);
        }
    }
    
    /***********
        - Added By HL on Apr 07 2020
        - Work Item : W-005173 - Field: All Active Students - not updating when name is updated
        - To update Instructors__c, Students__c and Staffs__c text fields under related project records whenever contact's name is changed
        **********/    
    public static void updateProjectTextFields(Set<Id> conIdsToUpdateProjTextFields){
            
        if(conIdsToUpdateProjTextFields != NULL && conIdsToUpdateProjTextFields.size() > 0){
        
            Set<Id> projIds = new Set<Id>();
            
            for(Contact_Assignments__c c : [SELECT Id, Project__c 
                                    FROM Contact_Assignments__c 
                                    WHERE Candidate_Name__c IN : conIdsToUpdateProjTextFields AND RecordType.DeveloperName IN ('Instructor', 'Student', 'Staff') AND 
                                        (Status__c = 'Active' OR (Status__c = 'Planned' AND Project__r.AcctSeed__Status__c = 'Order')) AND 
                                        Project__c != NULL AND Project__r.RecordType.DeveloperName != 'Admin_Projects']){
            
                projIds.add(c.Project__c);
            }
            System.debug(':::::projIds::::::'+projIds);
            
            if(projIds.size() > 0){
            
                List<Contact_Assignments__c> conAssigns = [SELECT Id, Candidate_Name__c, Candidate_Name__r.Name, RecordType.DeveloperName, 
                    Project__c, Project__r.Instructors__c, Project__r.Students__c, Project__r.Staffs__c
                FROM Contact_Assignments__c 
                WHERE (Status__c = 'Active' OR (Status__c = 'Planned' AND Project__r.AcctSeed__Status__c = 'Order')) AND
                    Project__c IN : projIds AND Project__r.RecordType.DeveloperName != 'Admin_Projects' AND RecordType.DeveloperName IN ('Instructor', 'Student', 'Staff')
                    ORDER BY LastModifiedDate DESC];
                    
                System.debug(':::::::conAssigns::::::::::'+conAssigns);
                
                if(conAssigns != NULL && conAssigns.size() > 0){
                    
                    Map<Id,AcctSeed__Project__c> projMapToUpdate = new Map<Id,AcctSeed__Project__c>();
                    
                    for(Contact_Assignments__c ca : conAssigns){
                    
                        String contactName = ', '+ca.Candidate_Name__r.Name;
                        AcctSeed__Project__c pro = new AcctSeed__Project__c();
                        pro.Id = ca.Project__c;
                                                
                        if(!projMapToUpdate.containsKey(ca.Project__c)){
                            
                            pro.Instructors__c = null;
                            pro.Students__c = null;
                            pro.Staffs__c = null;
                            
                            if(ca.RecordType.DeveloperName == 'Instructor') {
                                pro.Instructors__c = ca.Candidate_Name__r.Name;
                            } else if(ca.RecordType.DeveloperName == 'Student') {
                                pro.Students__c = ca.Candidate_Name__r.Name;                                
                            } else if(ca.RecordType.DeveloperName == 'Staff') {
                                pro.Staffs__c = ca.Candidate_Name__r.Name;
                            }
                            projMapToUpdate.put(ca.Project__c,pro);
                            
                        } else {
                                                    
                            if(ca.RecordType.DeveloperName == 'Instructor') {
                            
                                if(projMapToUpdate.get(ca.Project__c).Instructors__c != null && (projMapToUpdate.get(ca.Project__c).Instructors__c.length() != 255 && (projMapToUpdate.get(ca.Project__c).Instructors__c.length() + contactName.length()) < 255)){
                                
                                    projMapToUpdate.get(ca.Project__c).Instructors__c += ', '+ca.Candidate_Name__r.Name;
                                    
                                }else if(projMapToUpdate.get(ca.Project__c).Instructors__c == null){
                                
                                    projMapToUpdate.get(ca.Project__c).Instructors__c = ca.Candidate_Name__r.Name;
                                }
                                projMapToUpdate.put(ca.Project__c,projMapToUpdate.get(ca.Project__c));
                            } else if(ca.RecordType.DeveloperName == 'Student') {
                                
                                if(projMapToUpdate.get(ca.Project__c).Students__c != null && (projMapToUpdate.get(ca.Project__c).Students__c.length() != 255 && (projMapToUpdate.get(ca.Project__c).Students__c.length() + contactName.length()) < 255)){
                                
                                    projMapToUpdate.get(ca.Project__c).Students__c += ', '+ca.Candidate_Name__r.Name;
                                    
                                }else if(projMapToUpdate.get(ca.Project__c).Students__c == null){
                                
                                    projMapToUpdate.get(ca.Project__c).Students__c = ca.Candidate_Name__r.Name;
                                }
                                                                
                                projMapToUpdate.put(ca.Project__c,projMapToUpdate.get(ca.Project__c));
                            } else if(ca.RecordType.DeveloperName == 'Staff') {
                                
                                if(projMapToUpdate.get(ca.Project__c).Staffs__c != null && (projMapToUpdate.get(ca.Project__c).Staffs__c.length() != 255 && (projMapToUpdate.get(ca.Project__c).Staffs__c.length() + contactName.length()) < 255)){
                                
                                    projMapToUpdate.get(ca.Project__c).Staffs__c += ', '+ca.Candidate_Name__r.Name;
                                }else if(projMapToUpdate.get(ca.Project__c).Staffs__c == null){
                                
                                    projMapToUpdate.get(ca.Project__c).Staffs__c = ca.Candidate_Name__r.Name;
                                }
                                projMapToUpdate.put(ca.Project__c,projMapToUpdate.get(ca.Project__c));
                            }
                        }
                    }
                    System.debug('::::::projMapToUpdate:::::'+projMapToUpdate);
                    
                    if(projMapToUpdate != NULL && projMapToUpdate.size() > 0){
                    
                        update projMapToUpdate.values();
                    }
                }
            }
        }
    }
    
    
    //Method to update moodle sync status on contact update
    @future
    public static void updateMoodleSyncStatus(Set<Id> contactIds) {
      
        List<Contact> contactList = new List<Contact>();
        
        for(Id conId : contactIds){
            Contact con = new Contact();
            con.Id = conId;
            con.Moodle_Sync_Status__c = 'Pending';
            
            contactList.add(con);
        }
        
        if(contactList.size() > 0) {
          update contactList;
        }
    }
    
    @future
    public static void updateZoomFieldsForOnlineEventsOnEmailChange(Set<Id> contactIdsForZoomUserCreation){
        
        List<Events__c> eventsForUpdate = new List<Events__c>();
        for(Events__c eve : [SELECT Id, Meeting_URL__c, Meeting_Id__c, Is_Meeting_Created__c FROM Events__c WHERE Instructor__c IN :contactIdsForZoomUserCreation AND Is_Meeting_Created__c = true AND Status__c = 'Scheduled' AND Date__c >= :System.today()]){
            eve.Meeting_URL__c = null;
            eve.Meeting_Id__c = null;
            eve.Is_Meeting_Created__c = false;
            eventsForUpdate.add(eve);
        }
        
        update eventsForUpdate;
    }
    
    @future(callout=true)
    public static void unlinkInstructors(Set<String> instructorEmailsToUnlinkFromZoom){
        List<ErrorHandler.ErrorLogUtilDomain> errorLogs = new List<ErrorHandler.ErrorLogUtilDomain>();
        for(String insEmail: instructorEmailsToUnlinkFromZoom){
            try{
                ZoomUtil.unlinkUser(insEmail);
            }catch(Exception exe){
                
                String result = exe.getMessage();                
                errorLogs.add(new ErrorHandler.ErrorLogUtilDomain('ContactTrigger_FutureHandler','unlinkInstructors','',result+' at line number '+exe.getLineNumber(),insEmail,'Trigger'));
            }
        }
        
        if(errorLogs.size() > 0)
            ErrorHandler.publishErrorLog(errorLogs);
        
    }
}