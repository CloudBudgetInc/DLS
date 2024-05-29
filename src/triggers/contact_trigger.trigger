// This trigger is edited by Sukanya on Dec 8 2016 
// Added code to Update Supervisor field on Contact with Contact eqivalent Users Manager value

trigger contact_trigger on Contact (before insert,before update,after update) {
    
    Set<String> contactNameSet = new Set<String>();
    Map<String,Id> conNameUserIdMap = new Map<String,Id>();
    Map<String,Id> conNameSupervisorIdMap = new Map<String,Id>();
    List<User> userList = new List<User>();
    Set<String> firstnameSet = new Set<String>();
    Set<String> midnameSet = new Set<String>();
    Set<String> lastnameSet = new Set<String>();
    Map<String, Id> nameMap = new Map<String, Id>();    
    
    Id stdRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
    Id candidateRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('Candidate').getRecordTypeId();
    Id staffRecTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
    system.debug('staffRecTypeId'+staffRecTypeId);
    
    // Set for update Evaluate_Candidate_Profile_Rating__c field
    Set<String> fieldAPINames = new Set<String>{'email', 'mobilephone', 'mailingstreet', 'mailingcity', 'mailingstate', 'mailingpostalcode', 'mailingcountry', 
            'language_1__c', 'dls_candidate_rating__c', 'highest_degree__c', 'citizenship__c', 'country_of_citizenship__c', 'city_and_country_of_birth__c', 'experience_with_dli_students__c',
            'other_relevant_experience__c', 'of_known_languages__c', 'of_related_education__c', 'of_related_skills__c', 'of_related_work_experiences__c'}; 
    
    if(trigger.isBefore) {
        
        if(trigger.isInsert){
                    
            for( Contact c : trigger.new) {
                c.Geo_Code_Status__c = 'Not Processed';
                //System.debug('FName'+c.FirstName.length());
                //System.debug('LName'+c.LastName.length());
                if(c.FirstName != null && c.LastName != null && c.FirstName.length() >= 1 && c.LastName.length() >= 5)
                    c.Alias__c = c.FirstName.substring(0,1).toUpperCase() + c.LastName.substring(0,5).toUpperCase();
               
                // Populate value for Last_rating_update__c when DLS_Candidate_Rating__c is populated
                if(c.DLS_Candidate_Rating__c != null)
                    c.Last_rating_update__c = system.today();
                
                // Populated value for Last_Notes_Update__c when Candidate_Notes__c is populated
                if(c.Candidate_Notes__c != null)
                    c.Last_Notes_Update__c = system.today();
                
                // To Populate Instructor Status as Available for Candidates if Instructor Status is blank on creation
                if(c.RecordTypeId == candidateRTId && String.isBlank(c.Instructor_Status__c)){
                    c.Instructor_Status__c = 'Available';
                }  
                
                //To set default time approval preference as Daily fro student contacts
                //W-004938 - Time Approval preference not being filled in
                if(c.RecordTypeId == stdRTId && c.Time_Approval_Preference__c == null){
                    // Modified on Apr 22 2022
                    // Work Item: W-007441 - Student Timekeeping Approval Reminder and Process Changes (4.20.22)
                    // To update default Timekeeping Reminders to "Weekly" instead of "Daily"
                    c.Time_Approval_Preference__c = 'Weekly';
                }  
            }
        }
        
        if(trigger.isUpdate){
            Set<Id> contactBatchUpdIdSet = new Set<Id>();
            contactBatchUpdIdSet = ContactLatLongBatchClass.contactIdStaticSet;
            //System.debug('contact Static Id Set::::'+ContactLatLongBatchClass.contactIdStaticSet);
            System.debug('contactBatchUpdIdSet::::'+contactBatchUpdIdSet);
            for( Contact c : trigger.new) {
                // To update the status if any of the below field changes
                if(!contactBatchUpdIdSet.contains(c.Id)) {
                    if((trigger.oldMap.get(c.Id).MailingStreet != trigger.newMap.get(c.Id).MailingStreet) || 
                            (trigger.oldMap.get(c.Id).MailingCity != trigger.newMap.get(c.Id).MailingCity) ||
                            (trigger.oldMap.get(c.Id).MailingState != trigger.newMap.get(c.Id).MailingState) ||
                            (trigger.oldMap.get(c.Id).MailingCountry != trigger.newMap.get(c.Id).MailingCountry) ||
                            (trigger.oldMap.get(c.Id).MailingPostalCode != trigger.newMap.get(c.Id).MailingPostalCode) || 
                            (trigger.oldMap.get(c.Id).Location_GeoCode__latitude__s != trigger.newMap.get(c.Id).Location_GeoCode__latitude__s) ||
                            (trigger.oldMap.get(c.Id).Location_GeoCode__longitude__s != trigger.newMap.get(c.Id).Location_GeoCode__longitude__s)) {
                    
                        c.Geo_Code_Status__c = 'Not Processed';
                    }
                }
                if((c.FirstName != trigger.oldMap.get(c.Id).FirstName || c.LastName != trigger.oldMap.get(c.Id).LastName) && c.FirstName != null && c.LastName != null && c.FirstName.length() >= 1 && c.LastName.length() >= 5)
                    c.Alias__c = c.FirstName.substring(0,1).toUpperCase() + c.LastName.substring(0,5).toUpperCase();
                
              
                // Populate value for Last_rating_update__c when DLS_Candidate_Rating__c is updated
                if(c.DLS_Candidate_Rating__c != trigger.oldMap.get(c.Id).DLS_Candidate_Rating__c)
                    c.Last_rating_update__c = system.today();
                
                // Populated value for Last_Notes_Update__c when Candidate_Notes__c is updated
                if(c.Candidate_Notes__c != trigger.oldMap.get(c.Id).Candidate_Notes__c)
                    c.Last_Notes_Update__c = system.today();
                    
                // Added by HL
                // To update Evaluate_Candidate_Profile_Rating__c field for calculating Candidate_Profile_Complete__c
                
                Contact newCon = c;
                Contact oldCon = Trigger.oldMap.get(c.Id);
                
                if(c.Evaluate_Candidate_Profile_Rating__c){
                
                    for (String fieldName: fieldAPINames) {
                    
                        try {                         
                            if(newCon.get(fieldName) != oldCon.get(fieldName)){ 
                                
                                c.Evaluate_Candidate_Profile_Rating__c = FALSE;
                            } 
                        } catch (Exception e) { 
                            System.debug('Error: ' + e); 
                        } 
                    }
                }
                
                //Added By Dhinesh - 27-04-2021 - Zoom Integration
                if(c.Email != trigger.oldMap.get(c.Id).Email && c.RecordTypeId == candidateRTId && String.isNotEmpty(c.Zoom_Id__c)){
                    c.Zoom_Id__c = null;
                    c.Zoom_User_Status__c = null;
                    c.Virtual_Conference_License__c = null;
                    ContactTrigger_FutureHandler.contactIdsForZoomUserCreation.add(c.Id);
                }
                // May 21 2024 - W-008053 : Automatically Update "Experience with DLI Students?" Field to True
                if(!c.Experience_with_DLI_Students__c && c.DLI_Hours_in_Current_Year__c > 0 && (Trigger.oldMap.get(c.Id).DLI_Hours_in_Current_Year__c == null || Trigger.oldMap.get(c.Id).DLI_Hours_in_Current_Year__c == 0)){
                    c.Experience_with_DLI_Students__c = true;
                }
            }
            
            // Added By HL to update Contact_Record_Type__c field value in Cost Rate record when Contact RecordType is changed
            Map<Id, Id> conIdAndRecordTypeIdMap = new Map<Id, Id>();
            for(Contact c : trigger.new){
                if(c.RecordTypeId != Trigger.oldMap.get(c.Id).RecordTypeId){
                    conIdAndRecordTypeIdMap.put(c.Id, c.RecordTypeId);
                }
            }
            System.debug('conIdAndRecordTypeIdMap======'+conIdAndRecordTypeIdMap+'conIdAndRecordTypeIdMap SIZE==='+conIdAndRecordTypeIdMap.size());
            if(conIdAndRecordTypeIdMap.size() > 0){
                ContactTrigger_FutureHandler.toUpdateCostRateFieldValue(conIdAndRecordTypeIdMap);
            }
        }
        
        //Added by Shalni to update "First_Performance_Review_Date__c" for Offer Letter conga document
        if(Trigger.isInsert || Trigger.isUpdate){
            for(Contact con : Trigger.new){ 
                if(con.First_Performance_Review_Date__c == null && con.Original_Hire_Date__c != null){
                    con.First_Performance_Review_Date__c = con.Original_Hire_Date__c.addDays(91);
                }
                
                //W-002917 - populate Teaching in DLS Since field based on Orginal Hire date
                //Added by NS on Dec 11 2019
                if(con.Original_Hire_Date__c != null && (Trigger.isInsert 
                    || (Trigger.isUpdate && Trigger.oldMap.get(con.Id).Original_Hire_Date__c != con.Original_Hire_Date__c))){
                    
                    con.Teaching_in_DLS_since__c = con.Original_Hire_Date__c;
                }
            }
        }
    }
    
    /* Added by vinitha on August 29, 2017
    Map the user with contact using lookup to user field DLS User */
    
    if(trigger.isBefore && trigger.isInsert) {
        for(Contact con : Trigger.new){            
            firstnameSet.add(con.FirstName);  
            midnameSet.add(con.MiddleName);
            lastnameSet.add(con.LastName);    
        }
        
        if(firstnameSet.size() > 0 || lastnameSet.size() > 0  || midnameSet.size() > 0) {   
            for(User usr : UserService.getInternalUserRecord(firstnameSet,lastnameSet,midnameSet)){
                        
                if(usr.FirstName != null || usr.LastName != null || usr.MiddleName != null){
                    String usrname = usr.FirstName+'--'+usr.MiddleName+'--'+usr.LastName;
                    if(!nameMap.containsKey(usrname)){
                        nameMap.put(usrname,usr.Id);
                    }
                }
            }
        }
        
        if(nameMap.size() > 0) {
            for(Contact con : Trigger.new){  
                
                if(con.FirstName != null || con.LastName != null || con.MiddleName != null){
                    String conName = con.FirstName+'--'+con.MiddleName+'--'+con.LastName;
                    if(nameMap.containsKey(conName) && nameMap.get(conName) != null){
                        con.DLS_User__c = nameMap.get(conName);
                    }
                }
                system.debug(':::con.Related_User__c'+con.DLS_User__c);   
            }
        } 
    }
    
    if(Trigger.isAfter) {
       
        
        //Below Record Type related code is commented. because there is a option in apex to get the record type without quering using developer name
        // By NS on Sep 28 2018
        
        // Start of my added code
        /*System.debug(':::***:::loadResource:::'+ContactTrigger_FutureHandler.loadResource);
        if(ContactTrigger_FutureHandler.loadResource == false) {
            ContactTrigger_FutureHandler.loadResource = true;
            ContactTrigger_FutureHandler.getContactRTNameId();
        }
        
        if(ContactTrigger_FutureHandler.conRtMap.containsKey('DLS_Employee')) {
            staffRecTypeId = ContactTrigger_FutureHandler.conRtMap.get('DLS_Employee');
        }*/
        //System.debug(':::***:::staffRecTypeId:::'+staffRecTypeId);
        Map<Id, String> conIdAndTimeZone = new Map<Id, String>();
        Set<Id> conIdsToUpdateTaskRecs = new Set<Id>();
        
        //Variable to populate Time_Approval_Preference__c field in Student CA
        Map<Id, String> conIdAndTAP = new Map<Id, String>();
        
        Set<Id> conIdsToUpdateProjTextFields = new Set<Id>();
        Set<Id> conIdsToCreateAnnualReport = new Set<Id>();
        Set<String> instructorEmailsToUnlinkFromZoom = new Set<String>();
        
        for(Contact con : trigger.new) {
            
            if(Trigger.isInsert || ( trigger.isUpdate && trigger.oldmap.get(con.Id).Supervisor_Name__c != con.Supervisor_Name__c)) {
               
                if(con.RecordTypeId == staffRecTypeId && con.Supervisor_Name__c != null) {
                
                    String fName = con.FirstName;
                    String LName = con.LastName;
                    string name;
                    
                    if(fName != null && LName != null) {
                        name = fName+' '+LName;
                    } else if(fName != null) {
                        name = fName;
                    } else if(LName != null) {
                        name = LName;
                    }
                    
                    contactNameSet.add(name);
                    
                    if(!conNameSupervisorIdMap.containsKey(name))
                        conNameSupervisorIdMap.put(name,con.Supervisor_Name__c);
                }
            }
            
            if(Trigger.isUpdate){
            
                // Added by HL on Aug 22 2019
                // To update Time Zone in user records when populating Timezone field value in contact records
                if(String.isNotBlank(con.Timezone__c) && con.Timezone__c != Trigger.oldMap.get(con.Id).Timezone__c && con.RecordTypeId == stdRTId){
                
                    conIdAndTimeZone.put(con.Id, con.Timezone__c);
                }
                
                // Added by HL on Sep 11 2019
                // Update task records
                if(con.RecordTypeId == stdRTId && con.Agreed_DLS_Policies_And_Procedures__c != Trigger.oldMap.get(con.Id).Agreed_DLS_Policies_And_Procedures__c && con.Agreed_DLS_Policies_And_Procedures__c == TRUE ){
                    
                    conIdsToUpdateTaskRecs.add(con.Id);
                }
                
                // Added by HL on Oct 16 2019
                // Work Item : W-002922 - Student Time Approval Preferences (Daily, Weekly, No Approval)
                // To populate Time_Approval_Preference__c field in related Student Contact Assignment records whenever contact's Time_Approval_Preference__c field is changed
                
                if(con.RecordTypeId == stdRTId && String.isNotBlank(con.Time_Approval_Preference__c) && con.Time_Approval_Preference__c != Trigger.oldMap.get(con.Id).Time_Approval_Preference__c){
                    conIdAndTAP.put(con.Id, con.Time_Approval_Preference__c);
                }
                
                /************
                    - Added By HL on Apr 07 2020
                    - Work Item : W-005173 - Field: All Active Students - not updating when name is updated
                    - To update Instructors__c, Students__c and Staffs__c text fields under related project records whenever contact's name is changed
                    **********/
                if((con.RecordTypeId == stdRTId || con.RecordTypeId == candidateRTId || con.RecordTypeId == staffRecTypeId) && 
                    (con.FirstName != Trigger.oldMap.get(con.Id).FirstName || con.MiddleName != Trigger.oldMap.get(con.Id).MiddleName || con.LastName != Trigger.oldMap.get(con.Id).LastName)){
                
                    conIdsToUpdateProjTextFields.add(con.Id);
                }
                
                //Added By Dhinesh - 06/10/2021 - Annual Review Assessment Report
                if(con.DLI_Hours_in_Current_Year__c != Trigger.oldMap.get(con.Id).DLI_Hours_in_Current_Year__c && (Trigger.oldMap.get(con.Id).DLI_Hours_in_Current_Year__c == null || Trigger.oldMap.get(con.Id).DLI_Hours_in_Current_Year__c < 50) && con.DLI_Hours_in_Current_Year__c >= 50 && !con.Annual_Review_Completed_This_Year__c){
                    conIdsToCreateAnnualReport.add(con.Id);
                }
                
                //Added By Dhinesh - 19/10/2023 - W-007909 - Zoom - Unlink Users with a Candidate Rating Changed to 0 or 1
                if(con.RecordTypeId == candidateRTId && con.DLS_Candidate_Rating__c != Trigger.oldMap.get(con.Id).DLS_Candidate_Rating__c && (con.DLS_Candidate_Rating__c == '0' || con.DLS_Candidate_Rating__c == '1')){
                    instructorEmailsToUnlinkFromZoom.add(con.Email);
                }
            }
        }
        
        //Added By Dhinesh - 19/10/2023 - W-007909 - Zoom - Unlink Users with a Candidate Rating Changed to 0 or 1
        if(instructorEmailsToUnlinkFromZoom.size() > 0){
            ContactTrigger_FutureHandler.unlinkInstructors(instructorEmailsToUnlinkFromZoom);
        }
        
        if(conIdsToCreateAnnualReport.size() > 0){
            Assessment_Report_Helper.createAnnualInstructorPerformanceReviewReport(conIdsToCreateAnnualReport); 
        }
        
        System.debug(':::::conIdsToUpdateProjTextFields::::'+conIdsToUpdateProjTextFields);
        if(conIdsToUpdateProjTextFields.size() > 0){
            ContactTrigger_FutureHandler.updateProjectTextFields(conIdsToUpdateProjTextFields);
        }
        
        if(conIdAndTAP.size() > 0){
            
            List<Contact_Assignments__c> updateStdCAs = new List<Contact_Assignments__c>();
            
            for(Contact_Assignments__c c : [SELECT Id, Candidate_Name__c, Time_Approval_Preference__c FROM Contact_Assignments__c WHERE Candidate_Name__c IN :conIdAndTAP.keySet() AND Project__c != NULL AND Project__r.No_Student_Approval__c = FALSE AND RecordType.DeveloperName = 'Student' AND Status__c IN ('Planned', 'Active', 'Ended')]){
            
                if(conIdAndTAP.containsKey(c.Candidate_Name__c)){
                    
                    c.Time_Approval_Preference__c = conIdAndTAP.get(c.Candidate_Name__c);
                    updateStdCAs.add(c);
                }
            }
            if(updateStdCAs.size() > 0){
            
                update updateStdCAs;
            }
        }
        system.debug(':::::::contactNameSet::::::'+contactNameSet);
        system.debug(':::::::conNameSupervisorIdMap::::::'+conNameSupervisorIdMap);
        if(contactNameSet != null && contactNameSet.size() > 0) {
        
            for(User usr : [SELECT Id,Name,ManagerId FROM User WHERE Name IN :contactNameSet]){
                if(conNameSupervisorIdMap.containsKey(usr.Name) && usr.ManagerId != conNameSupervisorIdMap.get(usr.Name)) {
                    usr.ManagerId = conNameSupervisorIdMap.get(usr.Name);
                    userList.add(usr);
                }
            }
            system.debug(':::::userList::::'+userList);
            
            //Call future method to avoid Mixed DML Error
            
            if(userList.size() > 0) {
                
                //update userList;
                if(System.isBatch()){
                    ContactTrigger_FutureHandler.updateUserRecs(JSON.serialize(userList));
                }else{
                    ContactTrigger_FutureHandler.updateUserRecords(JSON.serialize(userList));
                }
            }        
        }
        //End of my added code
        
        // To update user Time Zone
        if(conIdAndTimeZone.size() > 0){
            ContactTrigger_FutureHandler.updateUserTimeZone(conIdAndTimeZone);
        }
        
        // To update task records
        if(conIdsToUpdateTaskRecs.size() > 0){
            
            List<Task> updateTaskList = new List<Task>();
            
            for(Task t : [SELECT Id, Status 
                FROM TASK 
                WHERE WhoId IN : conIdsToUpdateTaskRecs AND To_Do_Type__c = '40 - Student Policies & Procedures' AND Status = 'In Progress'
            ]){
            
                t.Status = 'Completed';
                updateTaskList.add(t);
            }
            System.debug(':::::updateTaskList::::::'+updateTaskList);
            
            if(updateTaskList.size() > 0){
            
                update updateTaskList;
            }
        }
        
        //Added By Dhinesh - 27-04-2021 - Zoom Integration
        if(ContactTrigger_FutureHandler.contactIdsForZoomUserCreation.size() > 0){
            ZoomUtil.checkAndCreateZoomUsers(JSON.serialize(ContactTrigger_FutureHandler.contactIdsForZoomUserCreation)); //Create Zoom User with updated email
            ContactTrigger_FutureHandler.updateZoomFieldsForOnlineEventsOnEmailChange(ContactTrigger_FutureHandler.contactIdsForZoomUserCreation); //update zoom related fields for future online events          
        }
    }
    
     // To Notify Pim user if contacts Name,Email, Mobile, Phone,Mailing address value changes
    if(trigger.isAfter && trigger.isUpdate) {
        ContactTrigger_FutureHandler.FieldchangeNotification(Trigger.New,Trigger.oldMap);
    }    
    
    /************
        - Added by HL on Sep 07 2019
        - Work Item :  W-001476 - Community User Login Experience (Login, Logout, New User Welcome Emails, Password Resets, etc.
        - This is for community user creation
        - If there is no email address on the Contact, create a User as soon as the email address is updated from blank. 
        ****************/
    if(Trigger.isAfter && Trigger.isUpdate){
        
        Set<Id> conIds = new Set<Id>();
        Map<Id, String> conIdAndEmail = new Map<Id, String>();
        
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        
        // Variables related to Moodle Integration
        Set<Id> filteredContactIds = new Set<Id>();
        
        for(Contact c : Trigger.new){
            
            if(c.Active_DLS_Online_User__c == FALSE && c.Email != Trigger.oldMap.get(c.Id).Email && String.isNotBlank(c.Email) && 
                Trigger.oldMap.get(c.Id).Email == NULL && (c.RecordTypeId == stdRTId || c.RecordTypeId == candidateRTId)){
            
                conIds.add(c.Id);
            }                        
            
            // Added by HL on Jan 14 2020
            if(c.Email != Trigger.oldMap.get(c.Id).Email && String.isNotBlank(c.Email) && String.isNotBlank(Trigger.oldMap.get(c.Id).Email) &&
                (c.RecordTypeId == stdRTId || c.RecordTypeId == candidateRTId)){
            
                conIdAndEmail.put(c.Id, c.Email);
            }
            
            //Added by HL on Mar 12 2020
            //Work Item : W-005025 - Account creation -few updates
            // To update Account's shipping address with the Contact's Mailing Address if it is changed by the user on the portal
            if((c.MailingStreet != Trigger.oldMap.get(c.Id).MailingStreet || c.MailingCity != Trigger.oldMap.get(c.Id).MailingCity||
                c.MailingState != Trigger.oldMap.get(c.Id).MailingState || c.MailingCountry != Trigger.oldMap.get(c.Id).MailingCountry ||
                c.MailingPostalCode != Trigger.oldMap.get(c.Id).MailingPostalCode || c.W_9_on_file__c != Trigger.oldMap.get(c.Id).W_9_on_file__c||
                c.PC_EE_ID__c != Trigger.oldMap.get(c.Id).PC_EE_ID__c || c.EE_Pay_Status__c != Trigger.oldMap.get(c.Id).EE_Pay_Status__c) && 
                c.AccountId != NULL && c.RecordTypeId == candidateRTId){
                
                Account a = new Account();
                a.Id = c.AccountId;
                
                if(c.MailingStreet != Trigger.oldMap.get(c.Id).MailingStreet){
                    a.ShippingStreet = c.MailingStreet;
                    a.BillingStreet = c.MailingStreet;
                }  
                if(c.MailingCity != Trigger.oldMap.get(c.Id).MailingCity){
                    a.ShippingCity = c.MailingCity;
                    a.BillingCity = c.MailingCity;
                }
                if(c.MailingState != Trigger.oldMap.get(c.Id).MailingState){
                    a.ShippingState = c.MailingState;
                    a.BillingState = c.MailingState;
                }
                if(c.MailingCountry != Trigger.oldMap.get(c.Id).MailingCountry){
                    a.ShippingCountry = c.MailingCountry;
                    a.BillingCountry = c.MailingCountry;
                }
                if(c.MailingPostalCode != Trigger.oldMap.get(c.Id).MailingPostalCode){
                    a.ShippingPostalCode = c.MailingPostalCode;
                    a.BillingPostalCode = c.MailingPostalCode;
                }  
                if(c.W_9_on_file__c != Trigger.oldMap.get(c.Id).W_9_on_file__c){
                    a.W_9_on_file__c = c.W_9_on_file__c;
                }
                if(c.PC_EE_ID__c != Trigger.oldMap.get(c.Id).PC_EE_ID__c){
                    a.PC_EE_ID__c = c.PC_EE_ID__c;
                }
                if(c.EE_Pay_Status__c != Trigger.oldMap.get(c.Id).EE_Pay_Status__c){
                    a.EE_Pay_Status__c = c.EE_Pay_Status__c;
                }
                
                accountsToUpdate.put(a.Id, a);
            }
            
            if(c.Moodle_User_Id__c != null && (c.FirstName != Trigger.oldMap.get(c.Id).FirstName || c.LastName != Trigger.oldMap.get(c.Id).LastName ||
                c.Email != Trigger.oldMap.get(c.Id).Email)){
            
                filteredContactIds.add(c.Id);
            }
        }
        System.debug('conIds===='+conIds+'conIds SIZE==='+conIds.size());
        System.debug('conIdAndEmail====SIZE==='+conIdAndEmail.size());
        System.debug('::::accountsToUpdate:::::'+accountsToUpdate);
        System.debug('::::filteredContactIds:::::'+filteredContactIds);
        
        if(conIds.size() > 0){
            // To avoid "DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa)" error this method is created
            ContactTrigger_FutureHandler.upsertUserRecs(conIds);
        }
        
        if(conIdAndEmail.size() > 0){
            ContactTrigger_FutureHandler.updateUserEmail(conIdAndEmail);
        }
        
        if(accountsToUpdate != NULl && accountsToUpdate.size() > 0){
        
            update accountsToUpdate.values();
        }
        
        if(filteredContactIds.size() > 0){
        
            ContactTrigger_FutureHandler.updateMoodleSyncStatus(filteredContactIds);
        }        
    }
}