/*****************

- Added by HL on Aug 30 2019
- Here to send all communities related email notification regarding Community User Login Experience (Login, Logout, New User Welcome Emails, Password Resets, etc.) 
- Work Item :  W-001476 - Community User Login Experience (Login, Logout, New User Welcome Emails, Password Resets, etc.
***************/
public class UserManagementUtil{

    // To fix "System.LimitException: Too many queueable jobs added to the queue" issue
    public static Boolean fromExistingUserUpdate = False;
    
    // To fix "System is unchecking the Active DLS Online Checkbox on Active Instructor & Student" and prevent contact field updation while sending reminder email to create password
    public static Boolean skipContactUpdateFromPwdReminder = False;
    
    public static List<User> getUsersToCreatePassword(){
    
        List<User> users = new List<User>();
        
        Map<Id, AcctSeed__Project__c> projMap;
        
        if(!Test.isRunningTest()) {
            projMap = new Map<Id, AcctSeed__Project__c>([SELECT Id FROM AcctSeed__Project__c 
                                                            WHERE AcctSeed__Status__c IN ('Order', 'Active') AND Start_Date__c = TOMORROW 
                                                                AND End_Date__c >= 2019-10-28 AND Name NOT IN ('ELIZABETH HUML','MARA BOROUGHS','LEANN TAGWERKER','TRAVIS CUNNINGHAM','DLI Hausa-2018-Pena/Falanga','DLI Somali-2018-Deborah/Mickayla/Katie/Collin','Danielle Ward 2019') 
                                                                AND QB_Classification__c != 'OF0MTT0PS' AND (NOT Name LIKE '%Boll%')]);
        }else {
            projMap = new Map<Id, AcctSeed__Project__c>([SELECT Id FROM AcctSeed__Project__c WHERE AcctSeed__Status__c IN ('Order', 'Active') AND Start_Date__c = TOMORROW]);
        }
        
        System.debug('::::::::::projMap::::::::'+projMap);
        System.debug(':::::::projMap::::SIZE:::::::::'+projMap.size());
        
        if(projMap.size() > 0){
        
            Set<Id> conIds = new Set<Id>();
            
            // Added on July 29 2022 - Work Item: W-007477 - LMS Access for DLI-W Academic Advisors (AUG-1-2022)
            Set<String> caPositionSet = new Set<String>{'Instructor','EI','Substitute Instructor','Class Leader','Student','Training Officer','Client','Coordinator','Billing Contact','Academic Adviser','COR','Contracting POC','Technical POC', 'KO'};
            Set<String> caRecordTypeSet = new Set<String>{'Instructor', 'Student', 'Client_Partner'};
        
            if(!Test.isRunningTest()) {
            
                for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c FROM Contact_Assignments__c
                                                    WHERE RecordType.DeveloperName IN : caRecordTypeSet AND Status__c IN ('Active', 'Planned') 
                                                        AND Project__c IN : projMap.keySet() AND Paper_Timesheet__c = FALSE
                                                        AND Candidate_Name__r.Active_DLS_Online_User__c = TRUE AND Assignment_Position__c IN : caPositionSet 
                                                        AND End_Date__c >= 2019-10-28 AND Candidate_Name__r.Name != 'Inna Golovakha' AND (NOT Candidate_Name__r.Name LIKE '%Instructor%') 
                                                        AND (NOT Candidate_Name__r.Name LIKE '%Student%')]){
                    conIds.add(ca.Candidate_Name__c);
                }
            
            }else {
            
                for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c FROM Contact_Assignments__c
                                                    WHERE RecordType.DeveloperName IN : caRecordTypeSet AND Status__c IN ('Active', 'Planned') 
                                                        AND Project__c IN : projMap.keySet() AND Paper_Timesheet__c = FALSE
                                                        AND Candidate_Name__r.Active_DLS_Online_User__c = TRUE]){
                    conIds.add(ca.Candidate_Name__c);
                }
            }
            
            System.debug('::::::::::::conIds::::::::::::'+conIds.size());
            
            if(conIds.size() > 0){
            
                for(User u : [SELECT Id, Name, Profile.Name, ContactId, Email, LastPasswordChangeDate, CreatedDate, IsActive 
                    FROM User 
                    WHERE IsActive = True AND IsPortalEnabled = TRUE AND ContactId IN :conIds 
                        AND Profile.Name IN ('Student Community', 'Instructor Community', 'Client Community') 
                ]){
                
                    DateTime tempDate  = u.CreatedDate.addMinutes(1);
                    
                    if(u.LastPasswordChangeDate == NULL || u.CreatedDate == u.LastPasswordChangeDate || tempDate > u.LastPasswordChangeDate){
                        users.add(u);
                        u.IsActive = false;
                    }
                }
                System.debug('::::::users:::::::'+users.size());
                
                //W-004816
                //Reminder mail does not have passowrd set link. So we are deactivate user to get the password set link in email
                if(users.size() > 0){
                    
                    skipContactUpdateFromPwdReminder = True;
                    update users;
                    
                    return users;
                }
            }
        }
        return users;
    }
    
    public static void reminderToCreatePassword(List<User> users){
        
        system.debug(':::::enter:::reminderToCreatePassword::::::'+users.size());
        
        if(users!= NULL && users.size() > 0){
        
            try{
                
                /*EmailTemplate stdTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Reminder_to_create_password_for_Student'];
                EmailTemplate insTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Reminder_to_create_password_for_Instructor'];
                
                List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
                
                List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
            
                String orgWideEmailId = '';
                
                if(orgWideEmail != NULL && orgWideEmail.size() > 0){
                    orgWideEmailId = orgWideEmail[0].Id;
                }
                
                for(User u : users){
                
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    if(orgWideEmailId != NULL) {
                        mail.setOrgWideEmailAddressId(orgWideEmailId);
                    }
                    mail.setTargetObjectId(u.Id);
                    
                    if(u.Profile.Name == 'Student Community' && stdTemplate != null){
                        mail.setTemplateId(stdTemplate.Id);
                    } 
                    if(u.Profile.Name == 'Instructor Community' && insTemplate != null){
                        mail.setTemplateId(insTemplate.Id);
                    }
                    
                    mail.saveAsActivity = FALSE;
                    mailsToSend.add(mail);
                }
                System.debug(':::::::::mailsToSend::::::::::'+mailsToSend);
                System.debug('::::::::::::::::mailsToSend SIZE:::::::::::'+mailsToSend.size());
                
                if(mailsToSend.size() > 0) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(mailsToSend);
                }*/
                
                //W-004816
                //Reminder mail does not have passowrd set link. So we are activate user to get the password set link in email
                
                List<User> usersToActivate = new List<User>();
                for(User usr : users){
                    usr.IsActive = true;
                    usersToActivate.add(usr);
                }
                
                system.debug(':::::::::usersToActivate:::::::'+usersToActivate);
                
                if(usersToActivate.size() > 0){
                
                    skipContactUpdateFromPwdReminder = True;
                    update usersToActivate;
                }
                    
            }catch(Exception e) {
                    
                List<Messaging.SingleEmailMessage> ErrorMailMsg = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                mail.setToAddresses(new String[] {system.Label.TimeCardDayEmail});
                mail.setSubject('Error on Reminder to create password'); 
                mail.setPlainTextBody(e.getMessage());
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
    
    public static Map<Id, Boolean> checkAlreadyUserExist(Set<Id> conIds){
        
        Map<Id, User> conIdAndUser = new Map<Id, User>();
        Map<Id, Boolean> conIdAndIsUserExist = new Map<Id, Boolean>();
        
        if(conIds != NULL && conIds.size() > 0){
        
            for(User u : [
                SELECT Id, ContactId
                FROM User 
                WHERE ContactId IN :conIds AND IsPortalEnabled = TRUE 
            ]){
            
                conIdAndUser.put(u.ContactId, u);
            }
            
            system.debug(':::::::::conIdAndUser:::'+conIdAndUser.size());
            
            for(Id conId : conIds){
                
                if(conIdAndUser.containsKey(conId)){
                
                    conIdAndIsUserExist.put(conId, TRUE);
                }else{
                    
                    conIdAndIsUserExist.put(conId, FALSE);
                }
            }
            System.debug('::::::::::::conIdAndIsUserExist SIZE:::::::::::'+conIdAndIsUserExist.size());
        } 
        return conIdAndIsUserExist;
    }
    
    public static List<UtilDomain.ErrorWrapper> createUserForContact(Set<Id> conIds){
        
        System.debug(':::::createUserForContact::::::conIds::::::::'+conIds.size());
        
        List<UtilDomain.ErrorWrapper> errorWrapperList = new List<UtilDomain.ErrorWrapper>();
        
        if(conIds != NULL && conIds.size() > 0){
            
            List<User> createUserRecords = new List<User>();
            
            Id instructorProfileId;
            Id studentProfileId;
            Id clientProfileId;
            
            for(Profile pro : [SELECT Id,Name FROM Profile WHERE Name IN ('Instructor Community','Student Community', 'Client Community')]){
                if(pro.Name == 'Instructor Community'){
                    instructorProfileId = pro.Id;
                }else if(pro.Name == 'Student Community'){
                    studentProfileId = pro.Id;
                }else if(pro.Name == 'Client Community'){
                    clientProfileId = pro.Id;
                }
            }
            
            system.debug('::::::::instructorProfileId.size()::::::'+instructorProfileId);
            system.debug('::::::::::studentProfileId.size()::::::'+studentProfileId);
        
            //Get the contacts that need to create new users & form user instances
            for(Contact c : [SELECT Id,Name,FirstName,MiddleName,LastName,Email,RecordType.DeveloperName FROM Contact WHERE Id IN :conIds]){
                
                Contact conRecord = c;
                
                String nickName = '';
                String nick;
                String aliasName;
                String last;
                
                if(conRecord.Email != NULL && conRecord.Email.contains('@'))
                    nickName = conRecord.Email.Split('@')[0];
                    
                if(nickName.contains('.')){
                    nick = nickName.Split('\\.')[0];
                }else if(nickName.contains('_')){
                    nick = nickName.Split('_')[0];
                }else {
                    nick = nickName;
                }
                
                nick += String.valueOf(Math.round(Math.random()*1000));
                
                String fname = conRecord.FirstName;
                System.debug('::::fname :::'+fname );
                String lname = conRecord.LastName;
                
                if(lname.length() <= 4){
                    last = lname;
                }else{
                    last = lname.substring(0,4);
                }
                
                if(String.isNotBlank(fname)){
                    aliasName = fname.substring(0,1)+last;
                }else {
                    aliasName = last;
                }
                
                User usr = new User();
                
                usr.Email = conRecord.Email;
                usr.Username = conRecord.Email;
                usr.CommunityNickname = nick;
                usr.ContactId = c.Id;
                usr.IsActive = true;
                usr.EmailEncodingKey = 'ISO-8859-1';
                usr.FirstName = conRecord.FirstName;
                usr.LastName = conRecord.LastName;
                usr.Alias = aliasName;
                usr.LanguageLocaleKey = 'en_US';
                usr.LocaleSidKey = 'en_US';
                usr.TimeZoneSidKey = 'America/New_York';
                
                if(conRecord.RecordType.DeveloperName == 'Candidate'){
                    usr.ProfileId = instructorProfileId;
                }else if(conRecord.RecordType.DeveloperName == 'Student'){
                    usr.ProfileId = studentProfileId;
                }else if(conRecord.RecordType.DeveloperName == 'Commercial_Client' || conRecord.RecordType.DeveloperName == 'USG_Client'){
                    usr.ProfileId = clientProfileId;
                }
                
                createUserRecords.add(usr);
            }
            System.debug('::::::::::::;createUserRecords SIZE:::::::::'+createUserRecords.size());
            
            //Perform dml action to upsert users
            if(createUserRecords.size() > 0) {
            
                //insert the user records
                Database.SaveResult[] srList = Database.Insert(createUserRecords,false);
                
                for(Integer i = 0; i < srList.size(); i++) {
                
                    String errMsg = '';
                    
                    System.debug('createUserRecords:::::::'+createUserRecords[i]);
                    
                    User usr = createUserRecords[i];
                    
                    if (!srList[i].isSuccess()) {
                    
                        system.debug('USER ID::::::::'+usr.Id);
                        
                        if(srList[i].getId() == NULL) {
                        
                            system.debug('USER::::::::::'+usr);
                            
                            Contact con = new Contact();
                            con.Id = usr.ContactId;
                            con.FirstName = usr.FirstName;
                            con.LastName = usr.LastName;
                            
                            for(Database.Error err : srList[i].getErrors()) {
                                System.debug(':::::error:::' + err.getMessage());
                                errMsg += err.getMessage();
                            }
                            
                            UtilDomain.ErrorWrapper errWrapper = new UtilDomain.ErrorWrapper(con,errMsg,'User');
                            errorWrapperList.add(errWrapper);
                        }
                    }
                }
            }
        }
        return errorWrapperList;
    }
    
    public static List<UtilDomain.ErrorWrapper> updateExistingUser(Set<Id> conIds){
    
        System.debug(':::::::conIds SIZE:::::::::'+conIds.size());
        List<UtilDomain.ErrorWrapper> errorWrapperList = new List<UtilDomain.ErrorWrapper>();
        
        if(conIds != NULL && conIds.size() > 0){
        
            Map<Id, Contact> conIdRecordMap = new Map<Id, Contact>([SELECT Id,Name,FirstName,MiddleName,LastName,Email,RecordType.DeveloperName FROM Contact WHERE Id IN : conIds]);     
            List<User> userRecordsForUpdate = new List<User>();
            
            Id instructorProfileId;
            Id studentProfileId;
            Id clientProfileId;
            
            for(Profile pro : [SELECT Id,Name FROM Profile WHERE Name IN ('Instructor Community','Student Community', 'Client Community')]){
                if(pro.Name == 'Instructor Community'){
                    instructorProfileId = pro.Id;
                }else if(pro.Name == 'Student Community'){
                    studentProfileId = pro.Id;
                }else if(pro.Name == 'Client Community'){
                    clientProfileId = pro.Id;
                }
            }
            
            for(User usr : [
                SELECT Id,FirstName,MiddleName,LastName,Email,ContactId,Contact.RecordType.DeveloperName,Profile.Name,IsActive 
                FROM User 
                WHERE ContactId IN :conIds AND IsPortalEnabled = TRUE 
            ]){
                
                if(conIdRecordMap.containsKey(usr.ContactId)){
                
                    Boolean includeUser = FALSE;
                    
                    if(usr.Email != conIdRecordMap.get(usr.ContactId).Email){
                        usr.Email = conIdRecordMap.get(usr.ContactId).Email;
                        includeUser = TRUE;
                    }
                    
                    if(usr.Contact.RecordType.DeveloperName == 'Candidate' && usr.Profile.Name != 'Instructor Community'){
                        usr.ProfileId = instructorProfileId;
                        includeUser = TRUE;
                    }
                    
                    if(usr.Contact.RecordType.DeveloperName == 'Student' && usr.Profile.Name != 'Student Community'){
                        usr.ProfileId = studentProfileId;
                        includeUser = TRUE;
                    }
                    
                    if((usr.Contact.RecordType.DeveloperName == 'Commercial_Client' || usr.Contact.RecordType.DeveloperName == 'USG_Client') && usr.Profile.Name != 'Client Community'){
                        usr.ProfileId = clientProfileId;
                        includeUser = TRUE;
                    }
                    
                    if(!usr.IsActive){
                        usr.IsActive = true;
                        includeUser = TRUE;
                    }else {
                        usr.IsActive = false;
                    }
                    
                    if(includeUser){
                        userRecordsForUpdate.add(usr);
                    }
                }
            } 
            System.debug(':::::::::::::userRecordsForUpdate SIZE::::::::'+userRecordsForUpdate.size()); 
            
            //Perform dml action to update users
            if(userRecordsForUpdate.size() > 0) {
            
                fromExistingUserUpdate = True;
                
                //Update the user records
                Database.SaveResult[] srList = Database.update(userRecordsForUpdate,false);
                
                for(Integer i = 0; i < srList.size(); i++) {
                
                    String errMsg = '';
                    
                    System.debug('userRecordsForUpdate::::::::::'+userRecordsForUpdate[i]);
                    
                    User usr = userRecordsForUpdate[i];
                    
                    if (!srList[i].isSuccess()) {
                    
                        system.debug('USER ID:::::::::::'+usr.Id);
                        
                        if(srList[i].getId() == NULL) {
                        
                            system.debug('USER::::::::'+usr);
                            
                            Contact con = new Contact();
                            con.Id = usr.ContactId;
                            con.FirstName = usr.FirstName;
                            con.LastName = usr.LastName;
                            
                            for(Database.Error err : srList[i].getErrors()) {
                                System.debug('::error:::::::::' + err.getMessage());
                                errMsg += err.getMessage();
                            }
                            
                            UtilDomain.ErrorWrapper errWrapper = new UtilDomain.ErrorWrapper(con,errMsg,'User');
                            errorWrapperList.add(errWrapper);
                        }
                    }
                }
                
                fromExistingUserUpdate = False;
                
                //activate the user records after proper values update
                for(User usr : userRecordsForUpdate){
                    if(!usr.IsActive){
                        usr.IsActive = true;
                    }
                }
                
                Database.SaveResult[] resultList = Database.update(userRecordsForUpdate,false);
                
                for(Integer i = 0; i < resultList.size(); i++) {
                
                    String errMsg = '';
                    
                    System.debug('userRecordsForUpdate::::::::::'+userRecordsForUpdate[i]);
                    
                    User usr = userRecordsForUpdate[i];
                    
                    if (!resultList[i].isSuccess()) {
                    
                        system.debug('USER ID:::::::::::'+usr.Id);
                        
                        if(resultList[i].getId() == NULL) {
                        
                            system.debug('USER::::::::'+usr);
                            
                            Contact con = new Contact();
                            con.Id = usr.ContactId;
                            con.FirstName = usr.FirstName;
                            con.LastName = usr.LastName;
                            
                            for(Database.Error err : resultList[i].getErrors()) {
                                System.debug('::error:::::::::' + err.getMessage());
                                errMsg += err.getMessage();
                            }
                            
                            UtilDomain.ErrorWrapper errWrapper = new UtilDomain.ErrorWrapper(con,errMsg,'User');
                            errorWrapperList.add(errWrapper);
                        }
                    }
                }
            }
        }
        return errorWrapperList;
    }
    
    public static void createTaskForContact(Set<Id> conIds,List<Contact> contactForUpdate){
    
        System.debug('::::::::conIds SIZz::::::::'+conIds.size());
        
        List<Task> taskList = new List<Task>();
        
        if(conIds != NULL && conIds.size() > 0){
            
            Set<Id> conIdsHaveTask = new Set<Id>();
            
            for(Task t : [SELECT Id, WhoId FROM TASK WHERE WhoId IN : conIds AND Type = 'To Do']){
            
                if(!conIdsHaveTask.contains(t.WhoId)){
                    conIdsHaveTask.add(t.WhoId);
                }
            }
            System.debug('::::::::::conIdsHaveTask:::::::::::::'+conIdsHaveTask);
            System.debug('::::::::conIdsHaveTask::::::size::::'+conIdsHaveTask.size());
            
            for(Contact c : [SELECT Id,RecordType.DeveloperName FROM Contact WHERE Id IN :conIds]){
                
                if(!conIdsHaveTask.contains(c.Id)){
                
                    if(c.RecordType.DeveloperName == 'Candidate'){
                    
                        List<Task> insTaskList = new List<Task>{
                            new Task(Subject = 'Watch Timekeeping Training Video', Type = 'To Do', To_Do_Type__c = '10 - Watch Timekeeping Training Video', Status = 'In Progress', WhoId = c.Id),
                            new Task(Subject = 'Review and complete your Profile', Type = 'To Do', To_Do_Type__c = '20 - Review and complete your Profile', Status = 'In Progress', WhoId = c.Id)
                        };  
                        taskList.addAll(insTaskList);  
                    }
                
                    if(c.RecordType.DeveloperName == 'Student'){
                    
                        List<Task> stdTaskList = new List<Task>{
                            new Task(Subject = 'Watch Timekeeping Approval Training Video', Type = 'To Do', To_Do_Type__c = '30 - Watch Timekeeping Approval Training Video', Status = 'In Progress', WhoId = c.Id),
                            //Commented By Dhinesh - W-006595 - create task for ca based on Agreed_DLS_Policies_And_Procedures__c
                            //new Task(Subject = 'Student Policies & Procedures', Type = 'To Do', To_Do_Type__c = '40 - Student Policies & Procedures', Status = 'In Progress', WhoId = c.Id),
                            new Task(Subject = 'Confirm your Contact Information', Type = 'To Do', To_Do_Type__c = '50 - Confirm your Contact Information', Status = 'In Progress', WhoId = c.Id),
                            new Task(Subject = 'Check out the Student Language Studies Program', Type = 'To Do', To_Do_Type__c = '60 - Check out the Student Language Studies Program', Status = 'In Progress', WhoId = c.Id)
                        };  
                        taskList.addAll(stdTaskList);  
                    }
                }
            }  
            System.debug(':::::::::taskList SIZE:::::::::::'+taskList.size());
        }
        
        if(taskList.size() > 0 || contactForUpdate.size() > 0){
                
            // instantiate a new instance of the Queueable class
            CreateTaskforContact insertJob = new CreateTaskforContact(taskList,contactForUpdate);
            // enqueue the job for processing
            ID jobID = System.enqueueJob(insertJob);
            System.debug('jobID::'+jobID);
        }
    }
    
    @future
    public static void updateUserRecs(Map<Id, String> conIdAndEmail,Boolean fromContactEmailUpdate) {
        
        System.debug(':::::::::::::fromContactEmailUpdate::::::::::'+fromContactEmailUpdate);
        
        List<UtilDomain.ErrorWrapper> errorWrapperList = new List<UtilDomain.ErrorWrapper>();
        
        if(conIdAndEmail != NULL && conIdAndEmail.size() > 0 ){
            
            List<User> updateUserList = new List<User>();
            
            for(User u : [SELECT Id, ContactId, Email,Username FROM User 
                            WHERE IsActive = TRUE AND IsPortalEnabled = TRUE AND ContactId IN :conIdAndEmail.keySet() 
                                AND Profile.Name IN ('Student Community', 'Instructor Community', 'Client Community')]){   
                
                if(u.ContactId != NULL && conIdAndEmail.containsKey(u.ContactId)){
                    
                    User usr = new User();
                    usr.Id = u.Id;
                    usr.Email = conIdAndEmail.get(u.ContactId);
                    usr.Username = conIdAndEmail.get(u.ContactId);
                    updateUserList.add(usr);
                }    
            }
            System.debug(':::::updateUserList:::::'+updateUserList);
            
            if(updateUserList.size() > 0){
                
                ContactTrigger_FutureHandler.fromContactEmail = fromContactEmailUpdate;
                
                update updateUserList;
            }
        }
    }
    
    /***********
        - Added By HL on Aug 03 2020
        - To update fields related to Moodle under Project, Contact Assignment and Contact Objects
        **********/
    public static void updateMoodleRelatedFields(List<Contact_Assignments__c> filteredCAs, Set<Id> filteredProjIds, Set<Id> filteredConIds) {
    
        //System.debug(':::::filteredCAs:::::'+filteredCAs);
        
        if(filteredCAs != NULL && filteredCAs.size() > 0 && filteredProjIds != NULL && filteredProjIds.size() > 0 && 
            filteredConIds != NULL && filteredConIds.size() > 0){
        
            Set<String> stdPositions = new Set<String>{'Student', 'Class Leader'};
            Set<String> insPositions = new Set<String>{'Instructor', 'EI'};
            Set<String> projectTypes = new Set<String>{'SLP-PT','SLP-FT','JMAS','IND'};
            Set<string> syncStatusExclude = new Set<String>{'Completed','Pending'};
            
            // To prevent duplicate value inclusion
            Map<Id, Contact_Assignments__c> updateCAs = new Map<Id, Contact_Assignments__c>();
            Map<Id, AcctSeed__Project__c> updateProjs = new Map<Id, AcctSeed__Project__c>();
            Map<Id, Contact> updateCons = new Map<Id, Contact>();
            
            Map<Id, List<Materials_Request__c>> projIdAndMatReqs = new Map<Id, List<Materials_Request__c>>();
            Map<Id, Boolean> conIdAndIsPortalEnabled = new Map<Id, Boolean>();
            
            Integer currentYear = System.Today().year();
            System.debug(':::currentYear:::'+currentYear);
                
            Map<Id, String> projIdAndAllStdFirstName = new Map<Id, String>();
            // Map to store all related Student's FirstName
            projIdAndAllStdFirstName = UserManagementUtil.getAllStdFirstNameForProject(filteredProjIds);
            //System.debug(':::projIdAndAllStdFirstName::::::'+projIdAndAllStdFirstName);
            
            for(Materials_Request__c mr : [SELECT Id, Materials_Name__r.Name, Project__c 
                                            FROM Materials_Request__c 
                                            WHERE Project__c IN :filteredProjIds AND Request_Status__c IN ('Requested by LTS','Ordered','Delivered') AND 
                                                Materials_Name__c != NULL]){
            
                if(mr.Materials_Name__r.Name.contains('LMS Enrollment')){
                
                    if(!projIdAndMatReqs.containsKey(mr.Project__c)){
                        projIdAndMatReqs.put(mr.Project__c, new List<Materials_Request__c>());    
                    }
                    projIdAndMatReqs.get(mr.Project__c).add(mr);
                }        
            }
            //System.debug(':::::projIdAndMatReqs::::'+projIdAndMatReqs);
            
            for(User u : [SELECT Id, ContactId, IsPortalEnabled FROM User WHERE ContactId IN : filteredConIds]){
                conIdAndIsPortalEnabled.put(u.ContactId, u.IsPortalEnabled);
            }
            //System.debug(':::::conIdAndIsPortalEnabled::::'+conIdAndIsPortalEnabled);
            
            // Added on July 29 2022 - Work Item: W-007477 - LMS Access for DLI-W Academic Advisors (AUG-1-2022)
            Set<String> client_PartnerPositions = new Set<String>{'Training Officer','Client','Coordinator','Billing Contact','Academic Adviser','COR','Contracting POC','Technical POC', 'KO'};
        
            for(Contact_Assignments__c ca : filteredCAs){
            
                // SLP Course Creation and Course Creation
                // Modified on Mar 21 2024 - Modified Start Date condition from 19 days to 30 days for SLP projects  : W-008013 - Update to SLP Moodle Course Creation (Only)
                if(!updateProjs.containsKey(ca.Project__c) && ((ca.Project__r.RecordType.DeveloperName == 'DODA_Projects' && 
                    String.isNotBlank(ca.Project__r.Project_Type__c) &&  projectTypes.contains(ca.Project__r.Project_Type__c) && 
                    (ca.Project__r.Program_Iteration__c != NULL || ca.Project__r.Project_Type__c == 'IND') &&  
                    ca.Project__r.Start_Date__c <= Date.Today().addDays(30) &&
                    ca.Project__r.Moodle_Course_Id__c == NULL && projIdAndMatReqs.containsKey(ca.Project__c)) 
                    || 
                    (ca.Project__r.RecordType.DeveloperName != 'DODA_Projects' && 
                    ca.Project__r.Start_Date__c <= Date.Today().addDays(12) && ca.Project__r.Moodle_Course_Id__c == NULL && 
                    projIdAndMatReqs.containsKey(ca.Project__c)))){
                
                        AcctSeed__Project__c updateProj = new AcctSeed__Project__c();
                        updateProj.Id = ca.Project__c;
                        updateProj.Moodle_Sync_Status__c = 'Pending';
                        updateProj.Materials_Request__c = projIdAndMatReqs.get(ca.Project__c)[0].Id;
                        if(projIdAndAllStdFirstName != NULL && projIdAndAllStdFirstName.containsKey(ca.Project__c)){
                            updateProj.Course_Name__c = ca.Project__r.DLS_Class__c +'-'+projIdAndAllStdFirstName.get(ca.Project__c)+'-'+ca.Project__r.Language__r.Name+'-'+currentYear;
                        }
                        updateProjs.put(updateProj.Id, updateProj);
                }
                
                // SLP Student User Creation
                if(ca.Project__r.RecordType.DeveloperName == 'DODA_Projects' && 
                    String.isNotBlank(ca.Project__r.Project_Type__c) && projectTypes.contains(ca.Project__r.Project_Type__c) && 
                    (ca.Project__r.Program_Iteration__c != NULL || ca.Project__r.Project_Type__c == 'IND') &&  
                    ca.Project__r.Moodle_Course_Id__c != NULL && ca.Start_Date__c <= Date.Today().addDays(14) && 
                    ca.RecordType.DeveloperName == 'Student' && stdPositions.contains(ca.Assignment_Position__c) &&
                    ca.Candidate_Name__r.Moodle_User_Id__c == NULL && conIdAndIsPortalEnabled.containsKey(ca.Candidate_Name__c) && 
                    projIdAndMatReqs.containsKey(ca.Project__c)){
                
                        Contact updateCon = new Contact();
                        updateCon.Id = ca.Candidate_Name__c;
                        updateCon.Moodle_Sync_Status__c = 'Pending';
                        updateCon.Materials_Request__c = projIdAndMatReqs.get(ca.Project__c)[0].Id;
                        updateCon.Moodle_User_Status__c = 'New';
                        
                        updateCons.put(updateCon.Id, updateCon);
                }
                
                // Added By HL on Oct 07 2020
                // SLP Student User Reactivation
                if(ca.Project__r.RecordType.DeveloperName == 'DODA_Projects' && 
                    String.isNotBlank(ca.Project__r.Project_Type__c) && projectTypes.contains(ca.Project__r.Project_Type__c) && 
                    (ca.Project__r.Program_Iteration__c != NULL || ca.Project__r.Project_Type__c == 'IND') && 
                    ca.Project__r.Moodle_Course_Id__c != NULL && ca.Start_Date__c <= Date.Today().addDays(14) && 
                    ca.RecordType.DeveloperName == 'Student' && stdPositions.contains(ca.Assignment_Position__c) &&
                    ca.Candidate_Name__r.Moodle_User_Id__c != NULL && conIdAndIsPortalEnabled.containsKey(ca.Candidate_Name__c) && 
                    projIdAndMatReqs.containsKey(ca.Project__c) && String.isNotBlank(ca.Candidate_Name__r.Moodle_User_Status__c) && 
                    ca.Candidate_Name__r.Moodle_User_Status__c == 'Suspended'){
                
                        Contact updateCon = new Contact();
                        updateCon.Id = ca.Candidate_Name__c;
                        updateCon.Moodle_Sync_Status__c = 'Pending';
                        updateCon.Materials_Request__c = projIdAndMatReqs.get(ca.Project__c)[0].Id;
                        updateCon.Moodle_User_Status__c = 'Activate';
                        
                        updateCons.put(updateCon.Id, updateCon);
                }
                              
                // Instructor User Creation and Substitute Instructor User Creation
                if(ca.Project__r.Moodle_Course_Id__c != NULL && ca.RecordType.DeveloperName == 'Instructor' && 
                    ((ca.Start_Date__c <= Date.Today().addDays(7) && insPositions.contains(ca.Assignment_Position__c)) || 
                    (ca.Start_Date__c <= Date.Today().addDays(7) && ca.Assignment_Position__c == 'Substitute Instructor')) && 
                    ca.Candidate_Name__r.Moodle_User_Id__c == NULL && conIdAndIsPortalEnabled.containsKey(ca.Candidate_Name__c) &&
                    projIdAndMatReqs.containsKey(ca.Project__c)){
                    
                        Contact updateCon = new Contact();
                        updateCon.Id = ca.Candidate_Name__c;
                        updateCon.Moodle_Sync_Status__c = 'Pending';
                        updateCon.Materials_Request__c = projIdAndMatReqs.get(ca.Project__c)[0].Id;
                        updateCon.Moodle_User_Status__c = 'New';
                        
                        updateCons.put(updateCon.Id, updateCon);
                }
                
                // Added By HL on Oct 07 2020
                // Instructor User Reactivation and Substitute Instructor User Reactivation
                if(ca.Project__r.Moodle_Course_Id__c != NULL && ca.RecordType.DeveloperName == 'Instructor' && 
                    ((ca.Start_Date__c <= Date.Today().addDays(7) && insPositions.contains(ca.Assignment_Position__c)) || 
                    (ca.Start_Date__c <= Date.Today().addDays(7) && ca.Assignment_Position__c == 'Substitute Instructor')) && 
                    ca.Candidate_Name__r.Moodle_User_Id__c != NULL && conIdAndIsPortalEnabled.containsKey(ca.Candidate_Name__c) &&
                    projIdAndMatReqs.containsKey(ca.Project__c) && String.isNotBlank(ca.Candidate_Name__r.Moodle_User_Status__c) && 
                    ca.Candidate_Name__r.Moodle_User_Status__c == 'Suspended'){
                    
                        Contact updateCon = new Contact();
                        updateCon.Id = ca.Candidate_Name__c;
                        updateCon.Moodle_Sync_Status__c = 'Pending';
                        updateCon.Materials_Request__c = projIdAndMatReqs.get(ca.Project__c)[0].Id;
                        updateCon.Moodle_User_Status__c = 'Activate';
                        
                        updateCons.put(updateCon.Id, updateCon);
                }
                
                // Student User Creation
                if(ca.Project__r.RecordType.DeveloperName != 'DODA_Projects' && 
                    ca.Project__r.Moodle_Course_Id__c != NULL && ca.RecordType.DeveloperName == 'Student' && 
                    stdPositions.contains(ca.Assignment_Position__c) && ca.Start_Date__c <= Date.Today().addDays(7) && 
                    ca.Candidate_Name__r.Moodle_User_Id__c == NULL && conIdAndIsPortalEnabled.containsKey(ca.Candidate_Name__c) && 
                    projIdAndMatReqs.containsKey(ca.Project__c)){
                
                        Contact updateCon = new Contact();
                        updateCon.Id = ca.Candidate_Name__c;
                        updateCon.Moodle_Sync_Status__c = 'Pending';
                        updateCon.Materials_Request__c = projIdAndMatReqs.get(ca.Project__c)[0].Id;
                        updateCon.Moodle_User_Status__c = 'New';
                        
                        updateCons.put(updateCon.Id, updateCon);                        
                }
                
                // Added By HL on Oct 07 2020
                // Student User Reactivation
                if(ca.Project__r.RecordType.DeveloperName != 'DODA_Projects' && 
                    ca.Project__r.Moodle_Course_Id__c != NULL && ca.RecordType.DeveloperName == 'Student' && 
                    stdPositions.contains(ca.Assignment_Position__c) && ca.Start_Date__c <= Date.Today().addDays(3) && 
                    ca.Candidate_Name__r.Moodle_User_Id__c != NULL && conIdAndIsPortalEnabled.containsKey(ca.Candidate_Name__c) && 
                    projIdAndMatReqs.containsKey(ca.Project__c) && String.isNotBlank(ca.Candidate_Name__r.Moodle_User_Status__c) && 
                    ca.Candidate_Name__r.Moodle_User_Status__c == 'Suspended'){
                
                        Contact updateCon = new Contact();
                        updateCon.Id = ca.Candidate_Name__c;
                        updateCon.Moodle_Sync_Status__c = 'Pending';
                        updateCon.Materials_Request__c = projIdAndMatReqs.get(ca.Project__c)[0].Id;
                        updateCon.Moodle_User_Status__c = 'Activate';
                        
                        updateCons.put(updateCon.Id, updateCon);                        
                }
                
                // SLP Student Course Enrolment
                if(ca.Project__r.RecordType.DeveloperName == 'DODA_Projects' && 
                    String.isNotBlank(ca.Project__r.Project_Type__c) && projectTypes.contains(ca.Project__r.Project_Type__c) && 
                    (ca.Project__r.Program_Iteration__c != NULL || ca.Project__r.Project_Type__c == 'IND') && 
                    ca.Project__r.Moodle_Course_Id__c != NULL && ca.Start_Date__c <= Date.Today().addDays(14) && 
                    ca.RecordType.DeveloperName == 'Student' && stdPositions.contains(ca.Assignment_Position__c) &&
                    !syncStatusExclude.contains(ca.Moodle_Sync_Status__c) && ca.Candidate_Name__r.Moodle_User_Id__c != NULL &&
                    String.isNotBlank(ca.Candidate_Name__r.Moodle_User_Status__c) && ca.Candidate_Name__r.Moodle_User_Status__c == 'Active'){
                
                        ca.Moodle_Sync_Status__c = 'Pending';
                        updateCAs.put(ca.Id, ca);
                }
                
                // Instructor Course Enrolment and Substitute Instructor Course Enrolment
                if(ca.Project__r.Moodle_Course_Id__c != NULL && ca.RecordType.DeveloperName == 'Instructor' && 
                    ((ca.Start_Date__c <= Date.Today().addDays(7) && insPositions.contains(ca.Assignment_Position__c)) || 
                    (ca.Start_Date__c <= Date.Today().addDays(7) && ca.Assignment_Position__c == 'Substitute Instructor')) &&
                    !syncStatusExclude.contains(ca.Moodle_Sync_Status__c) && ca.Candidate_Name__r.Moodle_User_Id__c != NULL &&
                    String.isNotBlank(ca.Candidate_Name__r.Moodle_User_Status__c) && ca.Candidate_Name__r.Moodle_User_Status__c == 'Active'){
                
                        ca.Moodle_Sync_Status__c = 'Pending';
                        updateCAs.put(ca.Id, ca);
                }
                
                // Student Course Enrolment
                if(ca.Project__r.RecordType.DeveloperName != 'DODA_Projects' && 
                    ca.Project__r.Moodle_Course_Id__c != NULL && ca.RecordType.DeveloperName == 'Student' && 
                    stdPositions.contains(ca.Assignment_Position__c) && ca.Start_Date__c <= Date.Today().addDays(7) &&
                    !syncStatusExclude.contains(ca.Moodle_Sync_Status__c) && ca.Candidate_Name__r.Moodle_User_Id__c != NULL &&
                    String.isNotBlank(ca.Candidate_Name__r.Moodle_User_Status__c) && ca.Candidate_Name__r.Moodle_User_Status__c == 'Active'){
                
                        ca.Moodle_Sync_Status__c = 'Pending';
                        updateCAs.put(ca.Id, ca);
                }
                
                // DLI User Creation
                if(ca.Project__r.RecordType.DeveloperName == 'DLI_W_LT_Projects' && ca.Project__r.Moodle_Course_Id__c != NULL && 
                    ca.RecordType.DeveloperName == 'Client_Partner' && ca.Start_Date__c <= Date.Today() && 
                    client_PartnerPositions.contains(ca.Assignment_Position__c) && 
                    ca.Candidate_Name__r.Moodle_User_Id__c == NULL && conIdAndIsPortalEnabled.containsKey(ca.Candidate_Name__c) &&
                    projIdAndMatReqs.containsKey(ca.Project__c)){
                    
                        Contact updateCon = new Contact();
                        updateCon.Id = ca.Candidate_Name__c;
                        updateCon.Moodle_Sync_Status__c = 'Pending';
                        updateCon.Materials_Request__c = projIdAndMatReqs.get(ca.Project__c)[0].Id;
                        updateCon.Moodle_User_Status__c = 'New';
                        
                        updateCons.put(updateCon.Id, updateCon);
                }
                
                // DLI User Course Enrolment
                if(ca.Project__r.RecordType.DeveloperName == 'DLI_W_LT_Projects' && 
                    ca.Project__r.Moodle_Course_Id__c != NULL && ca.RecordType.DeveloperName == 'Client_Partner' && 
                    client_PartnerPositions.contains(ca.Assignment_Position__c) && ca.Start_Date__c <= Date.Today() &&
                    !syncStatusExclude.contains(ca.Moodle_Sync_Status__c) && ca.Candidate_Name__r.Moodle_User_Id__c != NULL &&
                    String.isNotBlank(ca.Candidate_Name__r.Moodle_User_Status__c) && ca.Candidate_Name__r.Moodle_User_Status__c == 'Active'){
                
                        ca.Moodle_Sync_Status__c = 'Pending';
                        updateCAs.put(ca.Id, ca);
                }
            }
            System.debug(':::::updateCAs:::::'+updateCAs+':::updateCAs::SIZE::'+updateCAs.size());
            System.debug(':::::updateProjs:::::'+updateProjs+'::::updateProjs::SIZE:::'+updateProjs.size());
            System.debug(':::::updateCons:::::'+updateCons+':::::updateCons::SIZE:::'+updateCons.size());
            
            if(updateCAs.size() > 0 || updateProjs.size() > 0 || updateCons.size() > 0){
                
                // instantiate a new instance of the Queueable class
                UpdateMoodleRelatedFieldsQueue insertJob = new UpdateMoodleRelatedFieldsQueue(updateCAs,updateProjs, updateCons);
                // enqueue the job for processing
                ID jobID = System.enqueueJob(insertJob);
                //System.debug('jobID::'+jobID);
            }
            
        }
    } 
    
    // Added By HL on Aug 21 2020
    public static Map<Id, String> getAllStdFirstNameForProject(Set<Id> projIds) {
    
        // Map to store all related Student's FirstName
        Map<Id, String> projIdAndAllStdFirstName = new Map<Id, String>();
            
        if(projIds != NULL && projIds.size() > 0){
                            
            for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__r.FirstName, Project__c
                                                FROM Contact_Assignments__c 
                                                WHERE Project__c IN : projIds AND RecordType.DeveloperName = 'Student' AND 
                                                    Status__c IN ('Planned','Active')]){
                                        
                String allStdFirstName = '';
                
                if(!projIdAndAllStdFirstName.containsKey(ca.Project__c)){
                    
                    allStdFirstName = ca.Candidate_Name__r.FirstName;
                    projIdAndAllStdFirstName.put(ca.Project__c, allStdFirstName);
                }else{    
                    
                    allStdFirstName = projIdAndAllStdFirstName.get(ca.Project__c);
                    allStdFirstName += '/ '+ ca.Candidate_Name__r.FirstName;
                    projIdAndAllStdFirstName.put(ca.Project__c, allStdFirstName);
                }
            }
            System.debug(':::projIdAndAllStdFirstName::::'+projIdAndAllStdFirstName);
        }
        return projIdAndAllStdFirstName;
    }
}