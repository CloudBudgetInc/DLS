public without sharing Class ContactAssignmentTriggerHandler {
    /*
    * Method to update Project Manager field when a new Active LTS is created 
    */
    public Static Map<String,Id> conAssignRecordTypeMap = new Map<String,Id>();
    public Static Map<Id,AcctSeed__Project__c> projMapToUpdate = new Map<Id,AcctSeed__Project__c>();
    public Static Boolean isFromCATrigger = false;
    // Added By HL on Apr 22 2021
    // While inserting Instructor CA via Event creation, it will update remaining CA's(Student, Staff) Oral Exam Date & Time. So this flag is used to prevent FIELD_CUSTOM_VALIDATION_EXCEPTION in CA trigger
    public Static Boolean isFromCATriggerHandler = FALSE;
    public Static Boolean isFromCATriggerHandlerForTesting_Pros = FALSE;
    public Static Set<Id> insIdsForOralExam = new Set<Id>(); //Added By Dhinesh - 28/10/2021 - To add CA ids to skip CA update in next executio
    
    // Added by GRK to create or Update DLS Expereince records based on Contact Assignments
    public Static Map<String, String> insPosExpService = new Map<String, String>{'Instructor' => 'Language Training' ,'Substitute Instructor' => 'Language Training', 'EI' => 'Language Training', 'Tester' => 'Testing', 'Translator' => 'Translation'}; 

    
    public void updateProjManager(Set<Id> projIdSet , Set<Id> contIdSet) {
    
        Map<Id,Id> ContactIdWithUserIdMap = new Map<Id,Id>();
        List<AcctSeed__Project__c> projectList = new List<AcctSeed__Project__c>();
        System.debug('projIdSet::::'+projIdSet);
        System.debug('contIdSet::::'+contIdSet);
        for( User u : [Select Id,ContactId FROM User Where ContactId IN : contIdSet AND Profile.Name = 'Staff Community' AND IsActive = True]) {
            ContactIdWithUserIdMap.put(u.ContactId,u.Id);
        }
        
        // Qry DLS User value from contact records 
        for(Contact con : [SELECT Id,Name,DLS_User__c FROM Contact WHERE Id IN :contIdSet]){
            if(!ContactIdWithUserIdMap.containsKey(con.Id)) {
                ContactIdWithUserIdMap.put(con.Id,con.DLS_User__c);
            }
        }
        
        system.debug('::::::::::::ContactIdWithUserIdMap:::::'+ContactIdWithUserIdMap);
        
        if ( ContactIdWithUserIdMap != null && ContactIdWithUserIdMap.size() > 0 ) {
            
            for (AcctSeed__Project__c proj : [SELECT Id,Name,Project_Manager__c,Instructors__c,Students__c,Staffs__c,Oral_Exam_Date_Time__c,RecordType.DeveloperName,(SELECT Id,Candidate_Name__c,Project__c,Project__r.RecordType.DeveloperName,Assignment_Position__c FROM Contact_Assignments__r WHERE Candidate_Name__c IN : contIdSet AND Status__c = 'Active') FROM AcctSeed__Project__c WHERE Id IN : projIdSet]) {
                for (Contact_Assignments__c ca : proj.Contact_Assignments__r) {
                    if(ca.Project__r.RecordType.DeveloperName != 'Admin_Projects' && ca.Assignment_Position__c == 'Project Manager') {
                        proj.Project_Manager__c = ContactIdWithUserIdMap.get(ca.Candidate_Name__c);
                    } else if((ca.Project__r.RecordType.DeveloperName == 'Admin_Projects' || ca.Project__r.RecordType.DeveloperName == 'Translation_Projects')&& ca.Assignment_Position__c == 'Manager') {
                        proj.Project_Manager__c = ContactIdWithUserIdMap.get(ca.Candidate_Name__c);
                    }
                }
                //projectList.add(proj); 
                if(!projMapToUpdate.containsKey(proj.Id)) {
                
                    // W-007591: Project Fields All Active Students and All Active Instructors Not Populating
                    // Commented By HL - Oct 10 2022
                    // To fix "blank value updated for Instructors__c / Students__c / Staffs__c" fields while changing the position value for staff contact assignment
                    
                    //proj.Instructors__c = null;
                    //proj.Students__c = null;
                    //proj.Staffs__c  = null;
                    projMapToUpdate.put(proj.Id,proj);   
                } else {
                    projMapToUpdate.get(proj.Id).Project_Manager__c = proj.Project_Manager__c;
                    //projMapToUpdate.get(proj.Id).Instructors__c = null;
                    //projMapToUpdate.get(proj.Id).Students__c = null;
                    //projMapToUpdate.get(proj.Id).Staffs__c  = null;
                }
            }
            
            system.debug('::::::::::projMapToUpdate:::::::'+projMapToUpdate);
            
          //  if( projectList != null && projectList.size() > 0 ){
          //      Update projectList;
          //  }
        }       
    }
    
    //Added by Shalini to update "Instructors, Students, Staffs" fields of Project with Candidate Name of CA based on RecordTypes
    public static void updateTextFields(Set<Id> projIdSet, Set<Id> conassignIdSet, Set<Id> oppId) {
           
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Map<Id, AcctSeed__Project__c> proMap = new Map<Id, AcctSeed__Project__c>();
        
        if(projMapToUpdate != null && projMapToUpdate.size() > 0){
            for(Id proId : projMapToUpdate.keySet()){
                projMapToUpdate.get(proId).Instructors__c = null;
                projMapToUpdate.get(proId).Students__c = null;
                projMapToUpdate.get(proId).Staffs__c  = null;
            }
        }else{
            // Modified on July 14 2023 : W-007842 - Rollup Helper Issue on "All Active Instructors" Calculation on Projects
            // To fix "All Active Instructors" field population issue
            for(Id projId : projIdSet){
                AcctSeed__Project__c pro = new AcctSeed__Project__c(); 
                pro.Id = projId;
                pro.Instructors__c = null;
                pro.Students__c = null;
                pro.Staffs__c  = null;
                projMapToUpdate.put(projId,pro);
            }
        }
        System.debug('::projMapToUpdate::111::'+projMapToUpdate);
        
        // Modified by GRK on 3/6/2018 to add the Name of the Contacts for Order Status Project when it is planned for CA.
        List<Contact_Assignments__c> CAList = [SELECT Id, Candidate_Name__c,Candidate_Name__r.Name,RecordType.DeveloperName,Project__c,Project__r.RecordType.DeveloperName,
                                                    Project__r.Instructors__c,Project__r.Students__c,Project__r.Staffs__c,Assignment_Position__c,Opportunity_Name__c,
                                                    Opportunity_Name__r.All_Active_Instructors__c,Opportunity_Name__r.All_Active_Students__c 
                                                FROM Contact_Assignments__c 
                                                WHERE (Status__c = 'Active' OR ( Status__c = 'Planned' AND Project__r.AcctSeed__Status__c = 'Order') ) 
                                                    AND (Opportunity_Name__c IN :oppId OR (Project__c IN :projIdSet AND Project__r.RecordType.DeveloperName != 'Admin_Projects')) ORDER BY LastModifiedDate DESC];
        for(Contact_Assignments__c ca : CAList) {
            AcctSeed__Project__c pro = new AcctSeed__Project__c(); 
            Opportunity opp = new Opportunity();
            
            String contactName = ', '+ca.Candidate_Name__r.Name;
            
            if(ca.Project__c != null){
                if(!projMapToUpdate.containsKey(ca.Project__c)){
                    pro.Id = ca.Project__c; 
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
                        } else if(projMapToUpdate.get(ca.Project__c).Instructors__c == null){
                            projMapToUpdate.get(ca.Project__c).Instructors__c = ca.Candidate_Name__r.Name;
                        }
                    } else if(ca.RecordType.DeveloperName == 'Student') {
                        
                        if(projMapToUpdate.get(ca.Project__c).Students__c != null && (projMapToUpdate.get(ca.Project__c).Students__c.length() != 255 && (projMapToUpdate.get(ca.Project__c).Students__c.length() + contactName.length()) < 255)){
                            projMapToUpdate.get(ca.Project__c).Students__c += ', '+ca.Candidate_Name__r.Name;
                        } else if(projMapToUpdate.get(ca.Project__c).Students__c == null){
                            projMapToUpdate.get(ca.Project__c).Students__c = ca.Candidate_Name__r.Name;
                        }                        
                    } else if(ca.RecordType.DeveloperName == 'Staff') {
                        
                        if(projMapToUpdate.get(ca.Project__c).Staffs__c != null && (projMapToUpdate.get(ca.Project__c).Staffs__c.length() != 255 && (projMapToUpdate.get(ca.Project__c).Staffs__c.length() + contactName.length()) < 255)){
                            projMapToUpdate.get(ca.Project__c).Staffs__c += ', '+ca.Candidate_Name__r.Name;
                        } else if(projMapToUpdate.get(ca.Project__c).Staffs__c == null){
                            projMapToUpdate.get(ca.Project__c).Staffs__c = ca.Candidate_Name__r.Name;
                        }
                    }
                }
            }
            
            if(ca.Opportunity_Name__c != null){
                if(!oppMap.containsKey(ca.Opportunity_Name__c)){
                    opp.Id = ca.Opportunity_Name__c; 
                    if(ca.RecordType.DeveloperName == 'Instructor') {
                        opp.All_Active_Instructors__c = ca.Candidate_Name__r.Name;
                    } else if(ca.RecordType.DeveloperName == 'Student') {
                        opp.All_Active_Students__c = ca.Candidate_Name__r.Name;
                    } 
                    oppMap.put(ca.Opportunity_Name__c,opp);
                } else {
                    if(ca.RecordType.DeveloperName == 'Instructor') {
                        if(oppMap.get(ca.Opportunity_Name__c).All_Active_Instructors__c != null && (oppMap.get(ca.Opportunity_Name__c).All_Active_Instructors__c.length() != 255 && (oppMap.get(ca.Opportunity_Name__c).All_Active_Instructors__c.length() + contactName.length()) < 255)){
                            oppMap.get(ca.Opportunity_Name__c).All_Active_Instructors__c += ', '+ca.Candidate_Name__r.Name;
                        } else if(oppMap.get(ca.Opportunity_Name__c).All_Active_Instructors__c == null){
                            oppMap.get(ca.Opportunity_Name__c).All_Active_Instructors__c = ca.Candidate_Name__r.Name;
                        }
                    } else if(ca.RecordType.DeveloperName == 'Student') {
                        if(oppMap.get(ca.Opportunity_Name__c).All_Active_Students__c != null && (oppMap.get(ca.Opportunity_Name__c).All_Active_Students__c.length() != 255 && (oppMap.get(ca.Opportunity_Name__c).All_Active_Students__c.length() + contactName.length()) < 255)){
                            oppMap.get(ca.Opportunity_Name__c).All_Active_Students__c += ', '+ca.Candidate_Name__r.Name;
                        } else if(oppMap.get(ca.Opportunity_Name__c).All_Active_Students__c == null){
                            oppMap.get(ca.Opportunity_Name__c).All_Active_Students__c = ca.Candidate_Name__r.Name;
                        }
                    } 
                }
            }
        }
        if(oppMap.values() != null && oppMap.values().size() > 0){
            update oppMap.values();
            
        }
        System.debug('::projMapToUpdate:222::'+projMapToUpdate);
        //if(proMap.values() != null && proMap.values().size() > 0){
        //    update proMap.values();  
        //}
    }
    
    /***********************************************
    Developed the method by GRK
    To update the Oral Exam Date & Time field for the Testing Opportunities.
    ************************************************/
    public static void updateOralExamDateTime(Set<Id> conAsIds, Map<Id,DateTime> projIdDateMap) {
    
        List<AcctSeed__Project__c> projs = new List<AcctSeed__Project__c>();
        List<Contact_Assignments__c> conAss = new List<Contact_Assignments__c>();
        
        if(conAsIds != null && projIdDateMap != null) {
        
            insIdsForOralExam.addAll(conAsIds);
            
            for(AcctSeed__Project__c ap : [SELECT Id,Name,Oral_Exam_Date_Time__c,
                                                (SELECT Id,Name,Oral_Exam_Date_Time__c,RecordType.DeveloperName,Status__c,LastModifiedDate,End_Date__c,Project__c
                                                    FROM Contact_Assignments__r 
                                                    WHERE Id NOT IN: conAsIds) 
                                            FROM AcctSeed__Project__c 
                                            WHERE Id IN: projIdDateMap.keyset() AND RecordType.DeveloperName = 'Testing_Projects' AND Test_Type__c != 'Translation Billable']) {
                
                DateTime oralExamDateTime = projIdDateMap.get(ap.Id);   
                
                if(projIdDateMap.containskey(ap.Id) && ap.Oral_Exam_Date_Time__c != projIdDateMap.get(ap.Id)) {
                    if(projMapToUpdate.containskey(ap.Id)) {
                        projMapToUpdate.get(ap.Id).Oral_Exam_Date_Time__c = Datetime.newInstance(oralExamDateTime.year(), oralExamDateTime.month(), oralExamDateTime.day(), oralExamDateTime.hour(), oralExamDateTime.minute(), oralExamDateTime.second());
                    } else {
                        ap.Oral_Exam_Date_Time__c = Datetime.newInstance(oralExamDateTime.year(), oralExamDateTime.month(), oralExamDateTime.day(), oralExamDateTime.hour(), oralExamDateTime.minute(), oralExamDateTime.second());                        
                        projMapToUpdate.put(ap.Id,ap);
                    }
                }
                System.debug(':::projMapToUpdate::::'+projMapToUpdate);
                if(ap.Contact_Assignments__r != null) {
                
                    // W-007555 : Error Message Fires Upon Tester CA Creation on Testing Project
                    DateTime proj_OralExamDateTime = projMapToUpdate.get(ap.Id).Oral_Exam_Date_Time__c != null ? projMapToUpdate.get(ap.Id).Oral_Exam_Date_Time__c : (Datetime.newInstance(oralExamDateTime.year(), oralExamDateTime.month(), oralExamDateTime.day(), oralExamDateTime.hour(), oralExamDateTime.minute(), oralExamDateTime.second()));
                    
                    for(Contact_Assignments__c ca : ap.Contact_Assignments__r) {
                    
                        if(projIdDateMap.containskey(ap.Id) && ca.Oral_Exam_Date_Time__c != projIdDateMap.get(ap.Id)) {
                        
                            insIdsForOralExam.add(ca.Id);
                            //ca.Oral_Exam_Date_Time__c = ap.Oral_Exam_Date_Time__c;
                            //DateTime proj_OralExamDateTime = projMapToUpdate.get(ca.Project__c).Oral_Exam_Date_Time__c;
                            ca.Oral_Exam_Date_Time__c = Datetime.newInstance(proj_OralExamDateTime.year(), proj_OralExamDateTime.month(), proj_OralExamDateTime.day(), proj_OralExamDateTime.hour(), proj_OralExamDateTime.minute(), proj_OralExamDateTime.second());
                            ca.End_Date__c = Date.ValueOf(oralExamDateTime);
                            conAss.add(ca);
                            
                        }
                    }
                }
            }
            
            if(conAss != null && conAss.size() > 0) {
                isFromCATriggerHandler = TRUE;
                isFromCATriggerHandlerForTesting_Pros = TRUE;

                update conAss;
            }
        }
    }
    
    /************
        - Commented on Nov 24 2022
        - W-007633  Urgent: Contact Roles created for wrong Contacts
        - To prevent the creation of unwanted opportunity contact roles under a opportunity
        **************/
    /*
    public void updateOpportunitiesContactFeilds(Map<Id,List<Contact_Assignments__c>> oppIdWithCaListMap, Set<Id> LTSContactIdSet) {
        
        List<Opportunity> oppList = new List<Opportunity>();
        Map<String,Id> conNamewithIdMap = new Map<String,Id>();
        Map<Id,Id> ContIdWithUserIdMap = new Map<Id,Id>(); 
        
        if ( LTSContactIdSet != null && LTSContactIdSet.size() > 0 ) {
            for(Contact c : [SELECT Id,Name FROM Contact WHERE Id IN : LTSContactIdSet]) {
                conNamewithIdMap.put(c.Name,c.Id);
            }
        
            for(User u : [SELECT Id,Name FROM User WHERE Name IN : conNamewithIdMap.KeySet()]){
                ContIdWithUserIdMap.put(conNamewithIdMap.get(u.Name),u.Id);
            }
        }
        
        if(oppIdWithCaListMap != null && oppIdWithCaListMap.keyset().size() > 0 ) {
            
            for(Opportunity op : [SELECT Id,Name,Student_Name__c,Contracting_Officer__c,Agency_Contact__c,InstructorName__c,Supervisor__c,EI_lookup__c,X2nd_Instructor__c FROM Opportunity WHERE Id IN : oppIdWithCaListMap.keySet() AND StageName NOT IN ('Canceled','Ended')]) {
                Integer i = 0;
                for(Contact_Assignments__c c: oppIdWithCaListMap.get(op.Id)) {
                    if( c.Assignment_Position__c == 'Student' ) {
                        op.Student_Name__c = c.Candidate_Name__c; 
                    } else if (c.Assignment_Position__c == 'Client' ) {
                        op.Contracting_Officer__c = c.Candidate_Name__c;
                    } else if (c.Assignment_Position__c == 'Training Officer') {
                        op.Agency_Contact__c = c.Candidate_Name__c;
                    } else if (c.Assignment_Position__c == 'Instructor') {    // && op.InstructorName__c == null && i == 0
                        op.InstructorName__c = c.Candidate_Name__c;
                        i++;
                        //X2nd_Instructor__c
                    }
                    else if (c.Assignment_Position__c == 'Project Manager') {
                        op.Supervisor__c = ContIdWithUserIdMap.get(c.Candidate_Name__c);
                    } else if (c.Assignment_Position__c == 'EI') {
                        op.EI_lookup__c = c.Candidate_Name__c;
                    }
                        //else if (c.Assignment_Position__c == 'Instructor' && op.InstructorName__c != null && op.X2nd_Instructor__c == null && i == 0 ) {
                        //op.X2nd_Instructor__c = c.Candidate_Name__c;                                            
                        //} 
                }
                oppList.add(op);
            }
            if(oppList != null && oppList.size() > 0 ) {
                Update oppList;
            }
        }
    }
    */

    /**************
        - Added by Sukanya on November 7 2016 for Contact Most Recent Request Language Field updation
        - From Opportunity Language change,Contact Assignment insert / update with Active status
        
        - Modified By HL on Apr 06 2020
        - Work Item : W-005170 - Field: Most Recent Requested Language is not populating
        - Populate Contact's Most_Recent_Requested_Language__c field value with the Opportunity's Language LU's Name instead of Language's Name
        **************/
    public void UpdateContactField(Set<Id> oppIdSet,Set<Id> ContactIdSet) {
        
        Map<Id,String> contactIdOppLanguageMap = new Map<Id,String>();
        List<Contact> contactUpdateList = new List<Contact>();
                
        if(ContactIdSet != null && ContactIdSet.size() > 0) {
            for(Contact_Assignments__c contactAssign : [SELECT Id,Candidate_Name__c,Opportunity_Name__c,Opportunity_Name__r.Language_LU__r.Name 
                                                        FROM Contact_Assignments__c 
                                                        WHERE RecordType.DeveloperName = 'Student' AND Candidate_Name__c IN :ContactIdSet ORDER BY Opportunity_Name__r.CloseDate DESC] ) {
                
                if(oppIdSet != null && oppIdSet.size() > 0 && oppIdSet.contains(contactAssign.Opportunity_Name__c)) {
                    
                    if(!contactIdOppLanguageMap.containsKey(contactAssign.Candidate_Name__c))
                        contactIdOppLanguageMap.put(contactAssign.Candidate_Name__c,contactAssign.Opportunity_Name__r.Language_LU__r.Name);
                
                }
            }
        }else if(oppIdSet != null && oppIdSet.size() > 0) {
            for(Contact_Assignments__c contactAssign : [SELECT Id,Candidate_Name__c,Opportunity_Name__c,Opportunity_Name__r.Language_LU__r.Name 
                                                        FROM Contact_Assignments__c 
                                                        WHERE RecordType.DeveloperName = 'Student' AND Opportunity_Name__r.Language_LU__c != null AND Opportunity_Name__c IN :oppIdSet] ) {
               
                if(!contactIdOppLanguageMap.containsKey(contactAssign.Candidate_Name__c))
                    contactIdOppLanguageMap.put(contactAssign.Candidate_Name__c,contactAssign.Opportunity_Name__r.Language_LU__r.Name);
                
            }
        }
                
        for(Id ids : contactIdOppLanguageMap.keySet()) {
            Contact con = new Contact();
            con.Id = ids;
            con.Most_Recent_Requested_Language__c = contactIdOppLanguageMap.get(ids);
            contactUpdateList.add(con);
        }
        if(contactUpdateList.size() > 0) {
            update contactUpdateList;
        }
    }    
    
    public void updateContactMostRecentOppStatusfield(Set<Id> oppIdSet){
        
        List<Contact> contactsToUpdate = new List<Contact>();
        Contact newCon;
        
        for(Contact con : [SELECT Id,Name,Most_Recent_Opportunity_Status__c,
                           (   SELECT Id,Name,Opportunity_Name__c,Opportunity_Name__r.StageName FROM Candidate_Assignments__r 
                               WHERE RecordType.DeveloperName = 'Student' AND Opportunity_Name__c != null 
                               ORDER BY Opportunity_Name__r.CloseDate DESC, Opportunity_Name__r.Start_Date__c DESC LIMIT 1
                           ) FROM Contact 
                           WHERE Id IN (SELECT Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Student' AND Opportunity_Name__c IN :oppIdSet) 
                           AND RecordType.DeveloperName = 'Student']){
            
            if(con.Candidate_Assignments__r.size() > 0){
                
                newCon = new Contact();
                newCon.Id = con.Id;
                newCon.Most_Recent_Opportunity_Status__c = con.Candidate_Assignments__r[0].Opportunity_Name__r.StageName;
                
                contactsToUpdate.add(newCon);
                
            }
        }
   
        if(contactsToUpdate.size() > 0){
            update contactsToUpdate;
        }            
    }
    
    // When a Supervisor is assigned in Opportunity's Supervisor Field Level create a CA
    public List<Contact_Assignments__c> createLTSStaffConAssign(Set<Id> oppIdSet) {
        Set<String> userNames = new Set<String>();
        Map<String,Id> userNameContIdMap = new Map<String,Id>();
        List<Opportunity> oppList = new List<opportunity>();
        List<Contact_Assignments__c> insertCAList = new List<Contact_Assignments__c>();
        Map<Id,Set<Id>> oppIdWithConIdMap = new Map<Id,Set<Id>>();
        
        for(Opportunity op : [SELECT Id,Name,supervisor__c,supervisor__r.Name,Start_Date__c,End_Date__c,(SELECT Id,Name,Candidate_Name__c,RecordTypeId,RecordType.DeveloperName FROM All_Instructors__r WHERE RecordType.DeveloperName = 'Staff') FROM Opportunity WHERE Id IN: oppIdSet]) {
            userNames.add(op.supervisor__r.Name);
            oppList.add(op);
            for (Contact_Assignments__c ca : op.All_Instructors__r) {
                if(!oppIdWithConIdMap.Containskey(op.Id)) {  
                    oppIdWithConIdMap.put(op.Id, new Set<Id>());
                }
                oppIdWithConIdMap.get(op.Id).add(ca.Candidate_Name__c);
            }
        }
        for(Contact c : [SELECT Id,NAme FROM Contact WHERE Name IN: userNames]) {
            userNameContIdMap.put(c.Name,c.Id);
        }
        Id castaffRtId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByName().get('Staff').getRecordTypeId();
        
        for(Opportunity o : oppList) {                
            if(userNameContIdMap != null && userNameContIdMap.containskey(o.supervisor__r.Name) && ((oppIdWithConIdMap.containskey(o.Id) && !oppIdWithConIdMap.get(o.Id).contains(userNameContIdMap.get(o.supervisor__r.Name))) || !oppIdWithConIdMap.containskey(o.Id) )) {
                Contact_Assignments__c cA = new Contact_Assignments__c();
                cA.Candidate_Name__c = userNameContIdMap.get(o.supervisor__r.Name);
                cA.Status__c = 'Planned';
                cA.Start_Date__c = o.Start_Date__c;
                cA.End_Date__c = o.End_Date__c;
                cA.Assignment_Position__c = 'Project Manager';
                cA.RecordTypeId = castaffRtId;
                cA.Opportunity_Name__c = o.Id;
                insertCAList.add(cA);
            }
        } 
        //if( insertCAList != null && insertCAList.size() > 0) {
            //Insert insertCAList;
            return insertCAList;
        //}
    }
    // When a Instructor is assigned in Opportunity's Instructor Field Level create a CA
    public List<Contact_Assignments__c> createInsConAssign(Set<Id> oppIdSet) {
        List<Opportunity> oppList = new List<opportunity>();
        List<Contact_Assignments__c> insertCAList = new List<Contact_Assignments__c>();
        Map<Id,Set<Id>> oppIdWithInsConIdMap = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> oppIdWithStudConIdMap = new Map<Id,Set<Id>>();
        Map<Id,Set<Id>> oppIdWithCPConIdMap = new Map<Id,Set<Id>>();
        Map<String,Id> conAssignRTMap = new Map<String,Id>();
        
        if(conAssignRecordTypeMap != null && conAssignRecordTypeMap.size() > 0 ) {
            conAssignRTMap = conAssignRecordTypeMap;
        } else {
            getRecordTypeMap();
            conAssignRTMap = conAssignRecordTypeMap;
        }
        
        //for(RecordType rt : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SObjectType = 'Contact_Assignments__c']) {
        //    conAssignRTMap.put(rt.DeveloperName,rt.Id);
        //}
        
        for(Opportunity op : [SELECT Id,Name,supervisor__c,supervisor__r.Name,Student_Name__c,InstructorName__c,InstructorName__r.Name,Agency_Contact__c,Start_Date__c,End_Date__c,RecordType.DeveloperName,
                                        (SELECT Id,Name,Candidate_Name__c,RecordTypeId,RecordType.DeveloperName FROM All_Instructors__r WHERE (RecordType.DeveloperName = 'Instructor' OR RecordType.DeveloperName = 'Student' OR RecordType.DeveloperName = 'Client_Partner')) 
                            FROM Opportunity WHERE Id IN: oppIdSet]) {
            
            oppList.add(op);
            
            for (Contact_Assignments__c ca : op.All_Instructors__r) {
                if(ca.RecordType.DeveloperName == 'Instructor') {
                    if(!oppIdWithInsConIdMap.Containskey(op.Id)) {  
                        oppIdWithInsConIdMap.put(op.Id, new Set<Id>());
                    }
                    oppIdWithInsConIdMap.get(op.Id).add(ca.Candidate_Name__c);
                } 
                if(ca.RecordType.DeveloperName == 'Student') {
                    if(!oppIdWithStudConIdMap.Containskey(op.Id)) {  
                        oppIdWithStudConIdMap.put(op.Id, new Set<Id>());
                    }
                    oppIdWithStudConIdMap.get(op.Id).add(ca.Candidate_Name__c);
                }
                if(ca.RecordType.DeveloperName == 'Client_Partner') {
                    if(!oppIdWithCPConIdMap.Containskey(op.Id)) {  
                        oppIdWithCPConIdMap.put(op.Id, new Set<Id>());
                    }
                    oppIdWithCPConIdMap.get(op.Id).add(ca.Candidate_Name__c);
                }
            }
        }
        
        //Id caInsRtId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByName().get('Instructor').getRecordTypeId();
        
        for(Opportunity o : oppList) {    
                 
            if(o.InstructorName__c != null && ((oppIdWithInsConIdMap.containskey(o.Id) && !oppIdWithInsConIdMap.get(o.Id).contains(o.InstructorName__c)) || !oppIdWithInsConIdMap.containskey(o.Id) )) {
                
                Contact_Assignments__c cA = new Contact_Assignments__c();
                cA.Candidate_Name__c = o.InstructorName__c;
                
                if(o.RecordType.DeveloperName == 'DLI_W_TO_Opportunities'){
                    cA.Status__c = 'Proposed';
                }else {
                    cA.Status__c = 'Planned';
                }
                
                cA.Start_Date__c = o.Start_Date__c;
                cA.End_Date__c = o.End_Date__c;
                cA.Assignment_Position__c = 'Instructor';
                cA.RecordTypeId = conAssignRTMap.get('Instructor');
                cA.Opportunity_Name__c = o.Id;
                insertCAList.add(cA);
            }
            
            if(o.Student_Name__c != null && ((oppIdWithStudConIdMap.containskey(o.Id) && !oppIdWithStudConIdMap.get(o.Id).contains(o.Student_Name__c)) || !oppIdWithStudConIdMap.containskey(o.Id) )) {
                Contact_Assignments__c cA = new Contact_Assignments__c();
                cA.Candidate_Name__c = o.Student_Name__c;
                cA.Status__c = 'Planned';
                cA.Start_Date__c = o.Start_Date__c;
                cA.End_Date__c = o.End_Date__c;
                cA.Assignment_Position__c = 'Student';
                cA.RecordTypeId = conAssignRTMap.get('Student');
                cA.Opportunity_Name__c = o.Id;
                insertCAList.add(cA);
            }
            
            if(o.Agency_Contact__c != null && ((oppIdWithCPConIdMap.containskey(o.Id) && !oppIdWithCPConIdMap.get(o.Id).contains(o.Agency_Contact__c )) || !oppIdWithCPConIdMap.containskey(o.Id) )) {
                Contact_Assignments__c cA = new Contact_Assignments__c();
                cA.Candidate_Name__c = o.Agency_Contact__c ;
                cA.Status__c = 'Planned';
                cA.Start_Date__c = o.Start_Date__c;
                cA.End_Date__c = o.End_Date__c;
                cA.Assignment_Position__c = 'Training Officer';
                cA.RecordTypeId = conAssignRTMap.get('Client_Partner');
                cA.Opportunity_Name__c = o.Id;
                insertCAList.add(cA);
            }
        } 
        //if( insertCAList != null && insertCAList.size() > 0) {
            //Insert insertCAList;
            return insertCAList;
        //}
    }
    
    public void getRecordTypeMap() {
        for(RecordType rt : SObjectQueryService.getRecTypeListBySobjTypeAndDevName('','Contact_Assignments__c',new Set<String>())) {
            conAssignRecordTypeMap.put(rt.DeveloperName, rt.Id);
        }
    }
    
    // To update Opportunity_Product_Id__c of CA when OPLI related to that CA was deleted
    public static void removeOppProIdFromCA(Set<Id> opliIdSet){
        List<Contact_Assignments__c> caList = ContactAssignmentService.getContactassignmentByprojectId(' WHERE Opportunity_Product_Id__c ','',opliIdSet,'');
        if(caList.size() > 0){
            for(Contact_Assignments__c ca : caList){
                ca.Opportunity_Product_Id__c = null;
            }
            update caList;
        }
    }
    
    // Added By HL
    // To Share CostRate Records to Supervisor who are all not in HR, PayRoll and System Aministrator profile when the insertion of Instructor and Supervisor
    // Below used all Contacts are in 'DLS Staff" RecordType
    
    public static void shareCostRateRecords(List<Contact_Assignments__c> contactAssignments){
    
        Id supervisorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        Id instructorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        Id staffRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
                                
        //Added for Insertion of Instructor
        Map<Id, List<Contact_Assignments__c>> projIdAndInstructors = new Map<Id, List<Contact_Assignments__c>>();
        Set<Id> insConIds = new Set<Id>();
        Set<String> insStatus = new Set<String>{'Active','Awarded','Planned'};    //Instructor should have anyone of these Status__c
        Set<Id> costRateIds = new Set<Id>();
        
        //Added for Insertion of Supervisor
        Map<Id, List<Contact_Assignments__c>> projIdAndSupervisors = new Map<Id, List<Contact_Assignments__c>>();
        Set<Id> suprConIds = new Set<Id>();
        Set<String> suprStatus = new Set<String>{'Active','Planned'};    //Supervisor should have anyone of these Status__c
        Set<Id> costRateIds1 = new Set<Id>();
        
        for(Contact_Assignments__c ca : contactAssignments){
        
            if(ca.RecordTypeId == instructorRTId && insStatus.contains(ca.Status__c) && ca.Candidate_Name__c != NULL){
            
                insConIds.add(ca.Candidate_Name__c);
                if(ca.Rate_Card_Rate__c != NULL){
                    costRateIds.add(ca.Rate_Card_Rate__c);
                }else if(ca.Drafted_Labor_Cost_Rate__c != NULL){
                    costRateIds.add(ca.Drafted_Labor_Cost_Rate__c);
                }
                
                if(ca.Project__c != NULL && ca.Project_Task__c != NULL){
                        
                    if(!projIdAndInstructors.containsKey(ca.Project__c)){
                        projIdAndInstructors.put(ca.Project__c, new List<Contact_Assignments__c>());
                    }
                    projIdAndInstructors.get(ca.Project__c).add(ca);
                }else if(ca.Opportunity_Name__c != NULL && String.isNotBlank(ca.Opportunity_Product_Id__c)){
                
                    if(!projIdAndInstructors.containsKey(ca.Opportunity_Name__c)){
                        projIdAndInstructors.put(ca.Opportunity_Name__c, new List<Contact_Assignments__c>());
                    }
                    projIdAndInstructors.get(ca.Opportunity_Name__c).add(ca);
                }
            }
            if(ca.RecordTypeId == supervisorRTId && suprStatus.contains(ca.Status__c) && ca.Candidate_Name__c != NULL){
                
                suprConIds.add(ca.Candidate_Name__c);
                if(ca.Project__c != NULL && ca.Project_Task__c != NULL){
                        
                    if(!projIdAndSupervisors.containsKey(ca.Project__c)){
                        projIdAndSupervisors.put(ca.Project__c, new List<Contact_Assignments__c>());
                    }
                    projIdAndSupervisors.get(ca.Project__c).add(ca);
                }else if(ca.Opportunity_Name__c != NULL && String.isNotBlank(ca.Opportunity_Product_Id__c)){
                
                    if(!projIdAndSupervisors.containsKey(ca.Opportunity_Name__c)){
                        projIdAndSupervisors.put(ca.Opportunity_Name__c, new List<Contact_Assignments__c>());
                    }
                    projIdAndSupervisors.get(ca.Opportunity_Name__c).add(ca);
                }
            }
        }
        
        //when Instructor Inserted
        if(projIdAndInstructors.size() > 0){
            // To find Instructors CA
            Map<Id, Contact> staffContacts = new Map<Id, Contact>([SELECT Id FROM Contact WHERE Id IN :insConIds AND RecordTypeId = :staffRTId]);    
            Set<Id> projectIds = new Set<Id>();
            
            if(staffContacts.size() > 0){
                for(Id pId : projIdAndInstructors.keySet()){
                
                    for(Contact_Assignments__c ca : projIdAndInstructors.get(pId)){
                    
                        if(staffContacts.containsKey(ca.Candidate_Name__c)){
                        
                            if(ca.Project__c != NULL){
                                projectIds.add(ca.Project__c);
                            }else if(ca.Opportunity_Name__c != NULL){
                                projectIds.add(ca.Opportunity_Name__c);
                            }
                        }
                    }
                }
                if(projectIds.size() > 0){
                    Map<Id, List<Contact_Assignments__c>> pIdAndSupervisors = new Map<Id, List<Contact_Assignments__c>>();  
                    // To find out Supervisors related to Instructors CA
                    List<Contact_Assignments__c> supervisors = ContactAssignmentService.getContactassignmentByparentIds( projectIds, suprStatus, new Set<String>{'Staff'}, '');    
                    Set<Id> suprvsrConIds = new Set<Id>();
                    for(Contact_Assignments__c ca : supervisors){
                        suprvsrConIds.add(ca.Candidate_Name__c);
                        if(ca.Project__c != NULL){
                            if(!pIdAndSupervisors.containsKey(ca.Project__c)){
                                pIdAndSupervisors.put(ca.Project__c, new List<Contact_Assignments__c>());
                            }
                            pIdAndSupervisors.get(ca.Project__c).add(ca);
                        }else if(ca.Opportunity_Name__c != NULL){
                        
                            if(!pIdAndSupervisors.containsKey(ca.Opportunity_Name__c)){
                                pIdAndSupervisors.put(ca.Opportunity_Name__c, new List<Contact_Assignments__c>());
                            }
                            pIdAndSupervisors.get(ca.Opportunity_Name__c).add(ca);
                        }
                    }
                    if(pIdAndSupervisors.size() > 0){
                        // To get Cost Rate records except "FT Salary & Benefits"
                        List<AcctSeed__Cost_Rates__c> costRates = [SELECT Id, Contact__c, OwnerId FROM AcctSeed__Cost_Rates__c WHERE Id IN :costRateIds AND Rate_Type__c != 'FT Salary & Benefits'];    
                        Map<Id, List<AcctSeed__Cost_Rates__c>> conIdAndCostRates = new Map<Id, List<AcctSeed__Cost_Rates__c>>();
                        
                        Map<Id,Id> conIdAndUserId = new Map<Id,Id>();
                        conIdAndUserId = PlannedDaysOffHandler.getContactRelatedUsers(suprvsrConIds);    // Find the users related to Supervisor contact
                        for(AcctSeed__Cost_Rates__c cr : costRates){
                        
                            if(!conIdAndCostRates.containsKey(cr.Contact__c)){
                                conIdAndCostRates.put(cr.Contact__c, new List<AcctSeed__Cost_Rates__c>());
                            }
                            conIdAndCostRates.get(cr.Contact__c).add(cr);
                        }
                        
                        if(conIdAndCostRates.size() > 0){
                            List<AcctSeed__Cost_Rates__share> shareCostRateRecords = new List<AcctSeed__Cost_Rates__share>();
                            AcctSeed__Cost_Rates__share costRatesToShare;
                            Map<Id, User> userRec = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE Id IN :conIdAndUserId.values()]);    
                                                        
                            for(Id insP : projIdAndInstructors.keySet()){    // KEY : ProjectId(Instructors),  
                                for(Contact_Assignments__c ins : projIdAndInstructors.get(insP)){     // VALUES : CA(Instructors)
                                    if(pIdAndSupervisors.containsKey(insP)){
                                        for(Contact_Assignments__c supr : pIdAndSupervisors.get(insP)){    // VALUES : CA(Supervisor)
                                            for(AcctSeed__Cost_Rates__c cr : conIdAndCostRates.get(ins.Candidate_Name__c)){    // CostRates
                                                
                                                // Sharing records are created for current user to access Cost Rate records when they are not in HR, PayRoll and System Administrator profile
                                                if(conIdAndUserId.containsKey(supr.Candidate_Name__c) && 
                                                    cr.OwnerId != conIdAndUserId.get(supr.Candidate_Name__c) && 
                                                    userRec.get(conIdAndUserId.get(supr.Candidate_Name__c)).Profile.Name != 'HR' && 
                                                    userRec.get(conIdAndUserId.get(supr.Candidate_Name__c)).Profile.Name != 'PayRoll' &&
                                                    (userRec.get(conIdAndUserId.get(supr.Candidate_Name__c)).Profile.Name != 'System Administrator' || Test.isRunningTest())
                                                ){
                                                    costRatesToShare = new AcctSeed__Cost_Rates__share();
                                                    costRatesToShare.ParentId = cr.Id;
                                                    costRatesToShare.UserOrGroupId = conIdAndUserId.get(supr.Candidate_Name__c);
                                                    costRatesToShare.AccessLevel = 'Read';
                                                    costRatesToShare.RowCause = Schema.AcctSeed__Cost_Rates__share.RowCause.Manual;
                                                    shareCostRateRecords.add(costRatesToShare);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            Database.SaveResult[] sharedRec = Database.insert(shareCostRateRecords,false);
                        }
                    }
                }
            }
        }
        
        //when Supervisor Inserted
        if(projIdAndSupervisors.size() > 0){
        
            Set<String> insRT = new Set<String>{instructorRTId};
            // To find Instructors related to Staff CA
            List<Contact_Assignments__c> instructors =  ContactAssignmentService.getContactassignmentByparentIds( projIdAndSupervisors.keySet(), insStatus, new Set<String>{'Instructor'}, ', Candidate_Name__r.RecordTypeId, Rate_Card_Rate__r.Contact__c, Drafted_Labor_Cost_Rate__r.Contact__c, Rate_Card_Rate__r.OwnerId, Drafted_Labor_Cost_Rate__r.OwnerId, Rate_Card_Rate__r.Rate_Type__c, Drafted_Labor_Cost_Rate__r.Rate_Type__c');
            Map<Id, List<Contact_Assignments__c>> prjIdAndIns = new Map<Id, List<Contact_Assignments__c>>();
            Map<Id, List<AcctSeed__Cost_Rates__c>> conIdAndCostRates = new Map<Id, List<AcctSeed__Cost_Rates__c>>();
            
            for(Contact_Assignments__c ca : instructors){
                AcctSeed__Cost_Rates__c cr = new AcctSeed__Cost_Rates__c();
                if(ca.Candidate_Name__r.RecordTypeId == staffRTId){
                    if(ca.Rate_Card_Rate__c != NULL && ca.Rate_Card_Rate__r.Rate_Type__c != 'FT Salary & Benefits'){  
                        cr.Id = ca.Rate_Card_Rate__c;
                        cr.OwnerId = ca.Rate_Card_Rate__r.OwnerId;
                        if(!conIdAndCostRates.containsKey(ca.Rate_Card_Rate__r.Contact__c)){
                            conIdAndCostRates.put(ca.Rate_Card_Rate__r.Contact__c, new List<AcctSeed__Cost_Rates__c>());
                        }
                        conIdAndCostRates.get(ca.Rate_Card_Rate__r.Contact__c).add(cr);
                    }else if(ca.Drafted_Labor_Cost_Rate__c != NULL && ca.Drafted_Labor_Cost_Rate__r.Rate_Type__c != 'FT Salary & Benefits'){ 
                        cr.Id = ca.Drafted_Labor_Cost_Rate__c;
                        cr.OwnerId = ca.Drafted_Labor_Cost_Rate__r.OwnerId;
                        if(!conIdAndCostRates.containsKey(ca.Drafted_Labor_Cost_Rate__r.Contact__c)){
                            conIdAndCostRates.put(ca.Drafted_Labor_Cost_Rate__r.Contact__c, new List<AcctSeed__Cost_Rates__c>());
                        }
                        conIdAndCostRates.get(ca.Drafted_Labor_Cost_Rate__r.Contact__c).add(cr);
                    }
                    
                    if(ca.Project__c != NULL){
                        if(!prjIdAndIns.containsKey(ca.Project__c)){
                            prjIdAndIns.put(ca.Project__c, new List<Contact_Assignments__c>());
                        }
                        prjIdAndIns.get(ca.Project__c).add(ca);
                    }else if(ca.Opportunity_Name__c != NULL){
                    
                        if(!prjIdAndIns.containsKey(ca.Opportunity_Name__c)){
                            prjIdAndIns.put(ca.Opportunity_Name__c, new List<Contact_Assignments__c>());
                        }
                        prjIdAndIns.get(ca.Opportunity_Name__c).add(ca);
                    }
                }
            }
            
            if(prjIdAndIns.size() > 0 && conIdAndCostRates.size() > 0){
                           
                Map<Id,Id> conIdAndUserId = new Map<Id,Id>();
                conIdAndUserId = PlannedDaysOffHandler.getContactRelatedUsers(suprConIds); // Find the users related to Supervisor contact
                                                
                List<AcctSeed__Cost_Rates__share> shareCostRateRecords = new List<AcctSeed__Cost_Rates__share>();
                AcctSeed__Cost_Rates__share costRatesToShare;
                Map<Id, User> userRec = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE Id IN :conIdAndUserId.values()]);
                
                for(Id insP : prjIdAndIns.keySet()){    // KEY : ProjectId(Instructors),  
                
                    if(projIdAndSupervisors.containsKey(insP)){
                    
                        for(Contact_Assignments__c supr : projIdAndSupervisors.get(insP)){     // VALUES : CA(Supervisor)
                        
                            for(Contact_Assignments__c ins : prjIdAndIns.get(insP)){    // VALUES : CA(Instructors)
                            
                                if(conIdAndCostRates.containsKey(ins.Candidate_Name__c)){
                                
                                    for(AcctSeed__Cost_Rates__c cr : conIdAndCostRates.get(ins.Candidate_Name__c)){    // CostRates
                                    
                                        // Sharing records are created for current user to access Cost Rate records when they are not in HR, PayRoll and System Administrator profile
                                        if(conIdAndUserId.containsKey(supr.Candidate_Name__c) && 
                                            cr.OwnerId != conIdAndUserId.get(supr.Candidate_Name__c) && 
                                            userRec.get(conIdAndUserId.get(supr.Candidate_Name__c)).Profile.Name != 'HR' && 
                                            userRec.get(conIdAndUserId.get(supr.Candidate_Name__c)).Profile.Name != 'PayRoll' &&
                                            (userRec.get(conIdAndUserId.get(supr.Candidate_Name__c)).Profile.Name != 'System Administrator' || Test.isRunningTest())
                                        ){
                                            costRatesToShare = new AcctSeed__Cost_Rates__share();
                                            costRatesToShare.ParentId = cr.Id;
                                            costRatesToShare.UserOrGroupId = conIdAndUserId.get(supr.Candidate_Name__c);
                                            costRatesToShare.AccessLevel = 'Read';
                                            costRatesToShare.RowCause = Schema.AcctSeed__Cost_Rates__share.RowCause.Manual;
                                            shareCostRateRecords.add(costRatesToShare);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                Database.SaveResult[] sharedRec = Database.insert(shareCostRateRecords,false);
            }
        }
    }
    
    
    // Added By HL
    // To revoke the sharing records when CA's Status is updated as "Ended" on Instructors OR Supervisors
    public static void revokeSharingRecords(List<Contact_Assignments__c> newContactAssignments, Map<Id,Contact_Assignments__c> oldContactAssignments){
    
        String instructorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
        String supervisorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
        String staffRTId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('DLS_Employee').getRecordTypeId();
        
        Set<String> suprStatus = new Set<String>{'Active','Planned'};
        Set<String> insStatus = new Set<String>{'Active','Awarded','Planned'};
        
        List<Contact_Assignments__c> contactAssignments = new List<Contact_Assignments__c>();
        Set<Id> insConIds = new Set<Id>();
        Set<Id> suprConIds = new Set<Id>();
        Set<Id> costRateIds = new Set<Id>();
        Set<Id> suprProjIds = new Set<Id>();
        
        for(Contact_Assignments__c ca : newContactAssignments){
            
            Contact_Assignments__c oldCA = oldContactAssignments.get(ca.Id);
            if(ca.Status__c != NULL && ca.Status__c == 'Ended' && oldCA.Status__c != ca.Status__c){
            
                if(ca.RecordTypeId == instructorRTId && ca.Candidate_Name__c != NULL){
                
                    insConIds.add(ca.Candidate_Name__c);
                    contactAssignments.add(ca);
                }
                
                if(ca.RecordTypeId == supervisorRTId && ca.Candidate_Name__c != NULL){
                    suprConIds.add(ca.Candidate_Name__c);
                    if(ca.Project__c != NULL){
                        suprProjIds.add(ca.Project__c);
                    }else if(ca.Opportunity_Name__c != NULL){
                        suprProjIds.add(ca.Opportunity_Name__c);
                    }
                }
            }
        }
        
        // When Instructor's Status__c is updated as "Ended"
        if(insConIds.size() > 0){
        
            // Find Instructors CA related contact records
            Map<Id, Contact> staffContacts = new Map<Id, Contact>([SELECT Id FROM Contact WHERE Id IN :insConIds AND RecordTypeId = :staffRTId]);
            Set<Id> projectIds = new Set<Id>();
            
            if(staffContacts.size() > 0){
                for(Contact_Assignments__c ca : contactAssignments){
                
                    if(staffContacts.containsKey(ca.Candidate_Name__c)){
                        if(ca.Project__c != NULL){
                            projectIds.add(ca.Project__c);
                        }else if(ca.Opportunity_Name__c != NULL){
                            projectIds.add(ca.Opportunity_Name__c);
                        }
                        if(ca.Rate_Card_Rate__c != NULL){
                            costRateIds.add(ca.Rate_Card_Rate__c);
                        }else if(ca.Drafted_Labor_Cost_Rate__c != NULL){
                            costRateIds.add(ca.Drafted_Labor_Cost_Rate__c);
                        }
                    }
                }
                
                if(projectIds.size() > 0){
                    Set<String> suprRT = new Set<String>{supervisorRTId};
                    Set<Id> suprvsrConIds = new Set<Id>();
                    // To find out Supervisors related to Instructors CA
                    List<Contact_Assignments__c> supervisors = ContactAssignmentService.getContactassignmentByparentIds( projectIds, suprStatus, new Set<String>{'Staff'}, '');
                    
                    for(Contact_Assignments__c ca : supervisors){
                        suprvsrConIds.add(ca.Candidate_Name__c);
                    }
                    
                    Map<Id,Id> conIdAndUserId = new Map<Id,Id>();
                    conIdAndUserId = PlannedDaysOffHandler.getContactRelatedUsers(suprvsrConIds);    // Find the users related to Supervisor contact
                    
                    if(costRateIds.size() > 0 && conIdAndUserId.size() > 0){
                        List<AcctSeed__Cost_Rates__share> sharesToDelete = [
                            SELECT Id 
                            FROM AcctSeed__Cost_Rates__share 
                            WHERE ParentId IN :costRateIds AND UserOrGroupId IN :conIdAndUserId.values() AND RowCause = 'Manual'
                        ];
                        
                        if(!sharesToDelete.isEmpty()){
                            Database.Delete(sharesToDelete, false);
                        }
                    }
                }
            }
        }
        
        // When Supervisor's Status__c is updated as "Ended"
        if(suprProjIds.size() > 0){
            
            Set<String> insRT = new Set<String>{instructorRTId};
            Set<Id> insCRs = new Set<Id>();
            // Find Staff CA related Instructor Contact Assignment to get the Cost Rate records for revoke the Sharing
            List<Contact_Assignments__c> instructors =  ContactAssignmentService.getContactassignmentByparentIds( suprProjIds, insStatus, new Set<String>{'Instructor'}, ', Candidate_Name__r.RecordTypeId');
            
            for(Contact_Assignments__c ca : instructors){
                if(ca.Candidate_Name__r.RecordTypeId == staffRTId){
                    if(ca.Rate_Card_Rate__c != NULL){
                        insCRs.add(ca.Rate_Card_Rate__c);
                    }else if(ca.Drafted_Labor_Cost_Rate__c != NULL){
                        insCRs.add(ca.Drafted_Labor_Cost_Rate__c);
                    }
                }
            }
            
            Map<Id,Id> conIdAndUserId = new Map<Id,Id>();
            conIdAndUserId = PlannedDaysOffHandler.getContactRelatedUsers(suprConIds);    // Find the users related to Supervisor contact
            
            if(insCRs.size() > 0 && conIdAndUserId.size() > 0){
                List<AcctSeed__Cost_Rates__share> sharesToDelete = [
                    SELECT Id 
                    FROM AcctSeed__Cost_Rates__share 
                    WHERE ParentId IN :insCRs AND UserOrGroupId IN :conIdAndUserId.values() AND RowCause = 'Manual'
                ];
                
                if(!sharesToDelete.isEmpty()){
                    Database.Delete(sharesToDelete, false);
                }
            }
        }
    }  
    
    //To update moodle sync status to avoid record read only issue
    @future
    public static void updateMoodleSyncStatus(Set<Id> contactAssIds){
    
        List<Contact_Assignments__c> conAssForUpdate = new List<Contact_Assignments__c>();
        
        for(Id caId : contactAssIds){
            
            Contact_Assignments__c ca = new Contact_Assignments__c();
            ca.Id = caId;
            ca.Moodle_Sync_Status__c = 'Pending';
            
            conAssForUpdate.add(ca);
        }
        
        if(conAssForUpdate.size() > 0){
            
            update conAssForUpdate;
        }
    
    } 
    
    // To cancel the Progress report when the student is cancelled from the Project
    public static void CancelAReport(List<Contact_Assignments__c> newCAs, Map<Id,Contact_Assignments__c> oldCAs) {
    
        Set<Id> projIds = new Set<Id>();
        Id studRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        List<Assessment_Report__c> updateAR = new List<Assessment_Report__c>();
        Map<Id, Date> stdIdAndDate = new Map<Id, Date>();    // To cancel the remaining Assessment Report of this Contact
        Map<Id, String> stdIdAndStatus = new Map<Id, String>();
        
        for(Contact_Assignments__c ca : newCAs) {
            if(ca.RecordTypeId == studRTId && ca.Project__c != null && ca.Status__c != oldCAs.get(ca.Id).Status__c && (ca.Status__c == 'Canceled' || ca.Status__c == 'Ended')){
                projIds.add(ca.Project__c);
                stdIdAndDate.put(ca.Candidate_Name__c, ca.End_Date__c);
                stdIdAndStatus.put(ca.Candidate_Name__c, ca.Status__c);
            }
        }
        
        if(projIds.size() > 0){
            for(Assessment_Report__c ar: [SELECT Id, Student__c, Report_Date__c FROM Assessment_Report__c WHERE Project__c IN : projIds AND Student__c IN : stdIdAndDate.keySet() AND Status__c IN ('Draft','Scheduled')]){
                // For cancelled status update don't look at report date just cancel all the reports
                if(stdIdAndStatus.containsKey(ar.Student__c) && stdIdAndStatus.get(ar.Student__c) != 'Canceled'){
                    if(stdIdAndDate.containsKey(ar.Student__c) && ar.Report_Date__c > stdIdAndDate.get(ar.Student__c)){
                        ar.Status__c = 'Canceled';
                        updateAR.add(ar);
                    }
                }else{
                    ar.Status__c = 'Canceled';
                    updateAR.add(ar);
                }
            }
            //System.debug('updateAR::::::'+updateAR);
            if(updateAR.size() > 0) {
                update updateAR;
            }
        }
    } 
    
    // To Create Assessment Report when a new student is created in the Project, in which already the Assessment Report
    /* 
    public static void createAReport(List<Contact_Assignments__c> newCAs) {
        Id studRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
        Map<Id,Set<Id>> projCAMap = new Map<Id,Set<Id>>();
        Set<Id> createCAIds = new Set<Id>();
        Set<Id> projIds = new Set<Id>();
     
        List<Assessment_Report__c> existingARIds = new List<Assessment_Report__c>();
        
        for(Contact_Assignments__c ca : newCAs) {
            if(ca.RecordTypeId == studRTId && ca.Status__c == 'Active' && ca.Project__c != null) {
                if(!projCAMap.containskey(ca.Project__c)) {
                    projCAMap.put(ca.Project__c, new Set<Id>());
                }
                projCAMap.get(ca.Project__c).add(ca.Candidate_Name__c);
            }
        }
        
        System.debug('projCAMap:::::'+projCAMap);
        if(projCAMap != null && projCAMap.keyset().size() > 0 ) {
            for( Assessment_Report__c ar : [SELECT Id,Name,Student__c,Project__c,Status__c,Project__r.AcctSeed__Account__r.Name FROM Assessment_Report__c WHERE Project__c IN : projCAMap.keyset() ]) {
                // PVT check is to exclude the auto creation, since user is having button to create Assessment Report
                if(ar.Project__r.AcctSeed__Account__c != NULL && !ar.Project__r.AcctSeed__Account__r.Name.contains('PVT') && !projIds.contains(ar.Project__c)) {
                    projIds.add(ar.Project__c); // To find in Which projects we have already created the Assessment Reports and then create Reports when new student is added
                    if(projCAMap.containskey(ar.Project__C) && projCAMap.get(ar.Project__C) != null && projCAMap.get(ar.Project__C).size() > 0 ) {
                        createCAIds.addall(projCAMap.get(ar.Project__C));
                    }
                }
            }
        }
        
        System.debug('createCAIds:::::'+createCAIds);
        // To create Assessment Report when a new Student CA is added to Assessment Report created Project
        if(projIds.size() > 0 && createCAIds.size() > 0 ) {
            Assessment_Report_Helper.createAssessReport(projIds,createCAIds,'CATrigger');
        }
        
    }
    */
    
    // Added By HL on Jul 8 2021 - W-006583 : Notification to HR team about returned employees
    // To send an email to HR Team about instructors who haven’t worked for a year and has been assigned to the new project
    public static void employeeRehiringNotification(Set<Id> conIdsToSendAnEmail, Map<Id, Id> conIdAndCAId){
    
        if(conIdsToSendAnEmail != NULL && conIdsToSendAnEmail.size() > 0){
        
            Date year_back = Date.Today().addDays(-365);
            
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Id IN : conIdsToSendAnEmail AND Last_Time_Entered_Date__c <= :year_back AND Instructor_Status__c != 'Employed']);
            System.debug('::::::contactMap:::::'+contactMap);
            
            if(contactMap.size() > 0){
            
                try{
                    EmailTemplate empRehireTemp = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Employee_Rehiring_Email_Template'];
                    
                    List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
                        
                    String orgWideEmailId = '';
                    
                    if(orgWideEmail != null && orgWideEmail.size() > 0){
                        orgWideEmailId = orgWideEmail[0].Id;
                    }
                
                    List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
                    
                    for(Id conId : contactMap.keySet()){
                    
                        if(empRehireTemp != NULL){
                                
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            if(orgWideEmailId != null) {
                                mail.setOrgWideEmailAddressId(orgWideEmailId);
                            }
                            mail.setToAddresses(new List<String>{'hr@dlsdc.com'});
                            //mail.setToAddresses(new List<String>{'hemalatha@softsquare.biz'});
                            mail.setTemplateId(empRehireTemp.Id);
                            // To fix the issue related to "System.EmailException: REQUIRED_FIELD_MISSING, Missing targetObjectId with template:"
                            mail.setTargetObjectId(conId);
                            // This method would make sure email will not be sent to user
                            mail.setTreatTargetObjectAsRecipient(false);
                            // For Merge fields population
                            mail.setWhatId(conIdAndCAId.get(conId));
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
                    errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Employee Rehiring Notification To HR Team');
                } 
            }
        }    
    }
    
    public static void updateCAStatusOnOppClosedLost(Set<Id> oppIds){
    
        List<Contact_Assignments__c> conAssignmentToUpdate = new List<Contact_Assignments__c>();
        
        for(Contact_Assignments__c ca : [SELECT Id, Status__c FROM Contact_Assignments__c WHERE Opportunity_Name__c IN :oppIds AND RecordType.DeveloperName IN ('Student','Staff','Instructor')]){
            ca.Status__c = 'Closed Lost';
            conAssignmentToUpdate.add(ca);
        }
        
        if(conAssignmentToUpdate.size() > 0){
            update conAssignmentToUpdate;
        }
    }
    
    /***********
        - W-007472: Language Testing Goals Field Population
        - To update Goal fields (L_Goal__c / R_Goal__c / S_Goal__c / W_Goal__c) in Language Testing records when the Contact Assignment Goal fields are updated
        ****************/
    public static void updateLanguageTestingRecs(Map<Id, Contact_Assignments__c> conAssignMap){
        
        if(conAssignMap != null && conAssignMap.size() > 0){
            
            List<Language_Testing__c> updateLTRecs = new List<Language_Testing__c>();
            
            for(Language_Testing__c lt : [SELECT Id, Contact_Assignment__c, L_Goal__c, R_Goal__c, S_Goal__c, W_Goal__c FROM Language_Testing__c WHERE Contact_Assignment__c IN : conAssignMap.keySet()]){
            
                if(conAssignMap.containsKey(lt.Contact_Assignment__c)){
                    
                    Contact_Assignments__c caRec = conAssignMap.get(lt.Contact_Assignment__c);
                    
                    lt.L_Goal__c = (caRec.L_Score_Final__c != lt.L_Goal__c) ? caRec.L_Score_Final__c : lt.L_Goal__c;
                    lt.R_Goal__c = (caRec.R_Score_Final__c != lt.R_Goal__c) ? caRec.R_Score_Final__c : lt.R_Goal__c;
                    lt.S_Goal__c = (caRec.S_Score_Final__c != lt.S_Goal__c) ? caRec.S_Score_Final__c : lt.S_Goal__c;
                    lt.W_Goal__c = (caRec.W_Score_Goal__c != lt.W_Goal__c) ? caRec.W_Score_Goal__c : lt.W_Goal__c;
                    updateLTRecs.add(lt);
                }    
            }
            if(updateLTRecs.size() > 0){
                update updateLTRecs;
            }
        }
    }
    
    public static void validateInstructorZoomUser(Set<Id> instructorIdsToCheckZoomUser){
        Set<Id> instructorsNeedsZoomUser = new Set<Id>();
        for(Contact con: [SELECT Id FROM Contact WHERE Id IN :instructorIdsToCheckZoomUser AND Zoom_Id__c = null]){
            instructorsNeedsZoomUser.add(con.Id);
        }
        if(instructorsNeedsZoomUser.size() > 0)
            ZoomUtil.checkContactForZoomUserAndLicenseType(instructorsNeedsZoomUser, new Set<Id>());
    }
    
    /*************
        - Added on Apr 03 2023 - W-007730 - Email to HR to Cancel Orientation for New Hire (MAY-1-2023)
        - To send an email notification to HR team when a newly hired instructor has been cancelled on a Project
        *********************/
    public static void SendEmail_CancelOrientation_NewHire(List<Contact_Assignments__c> insCAs_newHire, Set<Id> insIds_newHire){
    
        if(insCAs_newHire.size() > 0){
            
            try{
                Set<Id> insIds_OldCAs = new Set<Id>();
                EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'To_Cancel_Orientation_for_New_Hire'];
                List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
                List<String> toAddresses = new List<String>();
                
                System_Values__c toAddress = System_Values__c.getValues('Cancel Orientation for New Hire'); 
                if (toAddress != null && toAddress.Value__c != null) {
                    for (String st : toAddress.Value__c.split(',')) {
                        toAddresses.add(st.trim());
                    }
                }
                
                for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c FROM Contact_Assignments__c WHERE Id NOT IN : insCAs_newHire AND Candidate_Name__c IN : insIds_newHire AND RecordType.DeveloperName = 'Instructor']){
                    insIds_OldCAs.add(ca.Candidate_Name__c);
                }
            
                for(Contact_Assignments__c ca : insCAs_newHire){
                    
                    if(!insIds_OldCAs.contains(ca.Candidate_Name__c)){
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setTemplateId(template.Id);
                        mail.setToAddresses(toAddresses);
                        // To fix the issue related to "System.EmailException: REQUIRED_FIELD_MISSING, Missing targetObjectId with template:"
                        mail.setTargetObjectId(ca.Candidate_Name__c);
                        // This method would make sure email will not be sent to contact
                        mail.setTreatTargetObjectAsRecipient(false);
                        mail.setWhatId(ca.Id);
                        sendEmailList.add(mail);
                    }    
                }
                System.debug(':sendEmailList:::'+sendEmailList);
                if(sendEmailList.size() > 0) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailList);
                }
            }catch(Exception e) {
                            
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Email to HR to Cancel Orientation for New Hire');
            }         
        }
    }
    
    // Work Item W-007862 
    public Static Void createDLSExperience(Set<Id> conIds, Set<String> caPositions, Map<String, Contact_Assignments__c> conIdCAPosAndCA) {
                
        if(conIdCAPosAndCA.size() > 0) {
        
            List<Experience__c> expToUpsert = new List<Experience__c>();
            Map<String,Experience__c> conIdServiceExperMap = new Map<String,Experience__c>();
            Map<String, Contact_Assignments__c> conIdCAPosAndCA_Old = new Map<String, Contact_Assignments__c>();
            Id workExpRTId = Schema.SObjectType.Experience__c.getRecordTypeInfosByDeveloperName().get('Professional_Work_Experience').getRecordTypeId();
            
            // To get the start date of 1'st contact assignment of the contacts
            for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c, Assignment_Position__c, Start_Date__c FROM Contact_Assignments__c WHERE Candidate_Name__c IN : conIds AND Project__c != null AND RecordType.DeveloperName = 'Instructor' AND Assignment_Position__c IN : caPositions ORDER BY Start_Date__c ASC]){
                
                String pos =  insPosExpService.containskey(ca.Assignment_Position__c) ? insPosExpService.get(ca.Assignment_Position__c) : '';
                
                String conIdAndPos = ca.Candidate_Name__c + '-' + pos;
                
                if(!conIdCAPosAndCA_Old.containsKey(conIdAndPos)){
                    conIdCAPosAndCA_Old.put(conIdAndPos, ca);
                }
            }
                    
            // To get the Contact's having DLS Expereince records
            for(Experience__c exp : [SELECT Id,Contact__c,End_Date__c,Services__c FROM Experience__c WHERE Contact__c IN: conIds AND (Name_of_Company__c LIKE '%DLS%' OR Name_of_Company__c LIKE '%Diplomatic Language Services%') AND RecordTypeId = : workExpRTId ]) {
                if(!conIdServiceExperMap.containskey(exp.Contact__c + '-' + exp.Services__c)) {
                    conIdServiceExperMap.put(exp.Contact__c + '-' + exp.Services__c, exp);
                }
            }
            System.debug('conIdServiceExperMap:::'+conIdServiceExperMap);
            
            // To Create Experience record for the (Contact without an DLS Experience record with same services)
            for(String conIdAndPos : conIdCAPosAndCA.keyset()) {
            
                Id conId = Id.valueOf(conIdAndPos.split('-')[0]);
                String position = conIdAndPos.split('-')[1];  
                                
                // Chcks whether this contact has DLS Experience record and create DLS Experience record when there is no Exp record
                if(!conIdServiceExperMap.containskey(conIdAndPos)) {
                    
                    Experience__c ex = new Experience__c();
                    ex.Contact__c = conId;
                    ex.Name_of_Company__c = 'DLS';
                    ex.RecordTypeId = workExpRTId;
                    ex.Start_Date__c = conIdCAPosAndCA_Old.containsKey(conIdAndPos) ? conIdCAPosAndCA_Old.get(conIdAndPos).Start_Date__c : conIdCAPosAndCA.get(conIdAndPos).Start_Date__c; // Contact Assignment Start Date
                    ex.Intensive_Proficiency_Oriented_Experienc__c = true;
                    if(position == 'Language Training') {
                        ex.Services__c = 'Language Training';
                        ex.Role_Title__c = 'Language Instructor';
                    } else if (position == 'Testing') {
                        ex.Services__c = 'Testing';
                        ex.Role_Title__c = 'Tester';
                    } else if (position == 'Translation') {
                        ex.Services__c = 'Translation';
                        ex.Role_Title__c = 'Translator';
                    }
                    ExpToUpsert.add(ex);
                
                } else {
                    // To Clear the End Date of the DLS Expereince when a new Project is assigned to the instructor
                    if(position == 'Language Training'){
                        
                        Experience__c exp = conIdServiceExperMap.get(conIdAndPos);
                        if(exp.Services__c == 'Language Training' && exp.End_Date__c != null) {
                            exp.End_Date__c = null;
                            ExpToUpsert.add(exp);
                        }
                    }
                }
            }
            
            if(ExpToUpsert.size() > 0) {
                System.debug('ExpToUpsert::::'+ExpToUpsert.size());
                Upsert ExpToUpsert;
            }
        }
    }
    
    // To update the End Date of the DLS Experience records with the Contact Assignments End Date
    public Static Void updateDLSExperience(Set<Id> conIds, Set<String> caPositions, List<Contact_Assignments__c> ended_OnHold_Canceled_CAs){
    
        if(!conIds.isEmpty()){
            
            Map<String,Experience__c> conIdServiceAndExp = new Map<String,Experience__c>();
            List<Experience__c> expToUpdate = new List<Experience__c>();
        
            Map<String, Contact_Assignments__c> conIdPosAndCA_Active = new Map<String, Contact_Assignments__c>();
            Map<String, Contact_Assignments__c> conIdPosAndCA_OnHold = new Map<String, Contact_Assignments__c>();
            Map<String, Contact_Assignments__c> conIdPosAndCA_Ended = new Map<String, Contact_Assignments__c>();
            
            for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c, Assignment_Position__c, Status__c, Start_Date__c, End_Date__c, Project__r.On_Hold_Date__c FROM Contact_Assignments__c WHERE Candidate_Name__c IN : conIds AND RecordType.DeveloperName = 'Instructor' AND Assignment_Position__c IN : caPositions AND Status__c IN ('Active', 'Ended', 'On Hold') ORDER BY End_Date__c DESC]){
                
                String pos =  insPosExpService.containskey(ca.Assignment_Position__c) ? insPosExpService.get(ca.Assignment_Position__c) : '';
                String conIdAndPos = ca.Candidate_Name__c + '-' + pos;
                
                if(ca.Status__c == 'Active' && !conIdPosAndCA_Active.containsKey(conIdAndPos)){
                    conIdPosAndCA_Active.put(conIdAndPos, ca);
                }
                if(ca.Status__c == 'Ended' && !conIdPosAndCA_Ended.containsKey(conIdAndPos)){
                    conIdPosAndCA_Ended.put(conIdAndPos, ca);
                }
                if(ca.Status__c == 'On Hold' && !conIdPosAndCA_OnHold.containsKey(conIdAndPos)){
                    conIdPosAndCA_OnHold.put(conIdAndPos, ca);
                }
            }
            
            // To form the Experience record map based on the Services type
            for(Experience__c exp : [SELECT Id,Contact__c,End_Date__c,Services__c FROM Experience__c WHERE Contact__c IN: conIds AND (Name_of_Company__c LIKE '%DLS%' OR Name_of_Company__c LIKE '%Diplomatic Language Services%') AND RecordType.DeveloperName = 'Professional_Work_Experience' ]){
                if(!conIdServiceAndExp.containskey(exp.Contact__c + '-' + exp.Services__c)) {
                    conIdServiceAndExp.put(exp.Contact__c + '-' + exp.Services__c, exp);
                }
            }
            
            for(Contact_Assignments__c ca : ended_OnHold_Canceled_CAs){
                
                String pos =  insPosExpService.containskey(ca.Assignment_Position__c) ? insPosExpService.get(ca.Assignment_Position__c) : '';
                String conIdPos = ca.Candidate_Name__c + '-' + pos;
                
                if(conIdServiceAndExp.containsKey(conIdPos)){
                    
                    Experience__c exp = conIdServiceAndExp.get(conIdPos);
                    
                    if(conIdPosAndCA_Active.containsKey(conIdPos) && exp.End_Date__c != null){
                            
                        exp.End_Date__c = null;
                        expToUpdate.add(exp); 
                    }else if(!conIdPosAndCA_Active.containsKey(conIdPos)){
                        
                        Date endDateVal;
                        
                        if(ca.Status__c == 'On Hold' && conIdPosAndCA_OnHold.containsKey(conIdPos)){
                        
                            endDateVal = conIdPosAndCA_OnHold.get(conIdPos).Project__r.On_Hold_Date__c != null ? conIdPosAndCA_OnHold.get(conIdPos).Project__r.On_Hold_Date__c : conIdPosAndCA_OnHold.get(conIdPos).End_Date__c;
                        }     
                        if((ca.Status__c == 'Canceled' || ca.Status__c == 'Ended') && conIdPosAndCA_Ended.containsKey(conIdPos)){
                            
                            endDateVal = conIdPosAndCA_Ended.get(conIdPos).End_Date__c;
                        }
                        if(endDateVal != null && (exp.End_Date__c == null || endDateVal != exp.End_Date__c)){
                            
                            exp.End_Date__c = endDateVal;
                            expToUpdate.add(exp); 
                        }                            
                    }
                }
            }
            System.debug(':::expToUpdate::::'+expToUpdate);
            if(!expToUpdate.isEmpty()){
                update expToUpdate;
            }
        }        
    }
}