/*
* This trigger creates OpportunityContactRoles for every Contact Assignment's "Candidate Name"
* with role as Contact Assignment's "Assignment Position", if and only if already an OCR doesn't exist 
* with this opportunity id and candidateName combination.
* Helper Class - "ContactAssignmentTriggerHandler"
*/

trigger createOppContRoles on Contact_Assignments__c (after insert, after update, after delete, before insert, before update) {

    Set<Id> oppIdSet = new Set<Id>();
    List<Opportunity> updateOppList = new List<Opportunity>();
    List<Contact_Assignments__c> updateConAssignList = new List<Contact_Assignments__c>();
    Contact_Assignments__c ConAssignoldMap = new Contact_Assignments__c();
    
    // Project Manager Update Variables
    Set<Id> projIdSetToUpdatePM = new Set<Id>();
    Set<Id> contIdSetToUpdatePM = new Set<Id>();
    ContactAssignmentTriggerHandler c = new ContactAssignmentTriggerHandler();
    
    // Added by Sukanya on November 7 2016 for Contact field update from Opp Language field
    // When Contact Assignment insert/update - Status = 'Active', Opp.Language changes
    
    Set<Id> OppIdSetForContact = new Set<Id>();
    Set<Id> contactIdSet = new Set<Id>(); 
    
    // Added by Kuppulakshmi on Feb 28 for count of Active and Awarded Status
    // when Contact assignment Inserted if status ='Active' or 'Awarded' opp.of_Instructors_active__c,opp.of_Instructors_awarded__c changes
    //start
    String oppcon,procon; 
    Set<Id> oppIdforcount = new Set<Id>();
    Set<Id> projIdforcount = new Set<Id>();
    Set<Id> conprojIdforcount = new Set<Id>();
    Set<Id> conassIdforcount = new Set<Id>();
    Set<Id> conassprojIdforcount = new Set<Id>();
    Set<String> oppconsetforcount = new Set<String>();
    List<Opportunity> oppListforcount = new List<Opportunity>();
    List<AcctSeed__Project__c> projListforcount = new List<AcctSeed__Project__c>();
    Map<Id,Map<String,Integer>> oppconMapforcount = new Map<Id,Map<String,Integer>>();
    
    //Variables to update the CA Status on updation
    Map<Id, String> proIdStatusMap = new Map<Id, String>();
    Set<Id> proId = new Set<Id>();
    
    //Variables to update location of CA on insertion 
    Map<Id,Id> oppOrProWithLocation = new Map<Id,Id>();
    Set<Id> oppIds = new Set<Id>();
    Set<Id> proIds = new Set<Id>();
    
    //Variabled related to Project/ Opp Text field update
    // To cover delete scenario moved the variables from bottom to here
    Set<Id> proIdSet = new Set<Id>();
    Set<Id> conassignIdSet  = new Set<Id>();
    Set<Id> oppId = new Set<Id>();
    
    //Set to get the opp / proj start date
    Set<Id> projectIds = new Set<Id>();
    Set<Id> opportunityIds = new Set<Id>();
    
    //Get Paper timesheet value from System Values custom settings
    Boolean paperTimesheetFlag;
    Id instructorRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Instructor').getRecordTypeId();
    Id stdRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
    Id staffRTId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Staff').getRecordTypeId();
    
    Id testingOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Testing_Opportunities').getRecordTypeId();
    Id testingProjRTId = Schema.SObjectType.AcctSeed__Project__c.getRecordTypeInfosByDeveloperName().get('Testing_Projects').getRecordTypeId();
    
    // Variables to populate "Time_Approval_Preference__c" field
    Set<Id> conIds = new Set<Id>();
    Set<Id> prjIds = new Set<Id>();
    Map<Id, AcctSeed__Project__c> prjRec = new Map<Id, AcctSeed__Project__c>();
    Map<Id, Contact> conRec = new Map<Id, Contact>();
    
    // Variables to create Observation Report Assessment Report
    Set<Id> projObsIds = new Set<Id>();
    List<Contact_Assignments__c> cas = new List<Contact_Assignments__c>();
    
    Set<Id> oppIdsForContFieldUpdate = new Set<Id>();
    Set<Id> caToCheckAndCreateTasks = new Set<Id>();
    Set<Id> caToDeleteTasks = new Set<Id>();
    Set<Id> caIdsToUpdateTaskStatus = new Set<Id>();
    Id studentCARecordTypeId = Schema.SObjectType.Contact_Assignments__c.getRecordTypeInfosByDeveloperName().get('Student').getRecordTypeId();
    
    System_Values__c sysVal = System_Values__c.getValues('Paper Timesheet Value');
    if(sysVal != null && sysVal.Value__c != null) {
        paperTimesheetFlag = Boolean.valueOf(sysVal.Value__c);
    }
            
    // Variables to delete related opportunity contact roles when contact assignment is deleted under opportunity
    Set<Id> oppIdsToDeleteOCR = new Set<Id>();
    Set<Id> conIdsToDeleteOCR = new Set<Id>();
    
    /* //#W-007701 - User Story - Auto-Populate Account field on Contact Assignment
    Map<Id,Id> conIdWithAccIdMap = new Map<Id,Id>();
    Set<Id> contactIds = new Set<Id>(); */
    
    // Added on July 27 2023 - W-007850 - Request to Exclude Translators from EOT Getfeedback Email Notification on Translation Projects
    // EOT get feedback email will not send for testing and translation projects and other project's instructors with "Tester" position
    Set<String> projRTsToExcludeEOTGetFeedbackEmail = new Set<String>{'Testing_Projects', 'Translation_Projects'};
    
    Set<Id> projIdsForAccPop = new Set<Id>();
    Set<Id> oppIdsForAccPop = new Set<Id>();
    //Map<Id, Id> projIdAndAccId = new Map<Id, Id>();
    //Map<Id, Id> oppIdAndAccId = new Map<Id, Id>();
    Map<Id, Id> parentIdAndAccId = new Map<Id, Id>();
    
    if(Trigger.isDelete) {      
    
        for (Contact_Assignments__c ca : trigger.old) {            
                        
            if(ca.Candidate_Name__c != NULL && (ca.Status__c == 'Active' || ca.Status__c == 'Awarded')){
                
                if(ca.Opportunity_Name__c != NULL){
                
                    if(ca.RecordTypeId == instructorRTId){
                        oppIdforcount.add(ca.Opportunity_Name__c);
                        conprojIdforcount.add(ca.Opportunity_Name__c); 
                    }  
                }
                                        
                if(ca.Project__c != NULL){
                
                    if(ca.RecordTypeId == instructorRTId){
                        projIdforcount.add(ca.Project__c);
                        conprojIdforcount.add(ca.Project__c); 
                    }                                
                }
            }
            
            //Modified on July 14 2023 : W-007842 - Rollup Helper Issue on "All Active Instructors" Calculation on Projects
            // To fix "All Active Instructors" field population issue
            if(ca.Candidate_Name__c != NULL && (ca.Status__c == 'Active' || ca.Status__c == 'Planned')){
            
                conassignIdSet.add(ca.Id);
                if(ca.Project__c != null){
                    proIdSet.add(ca.Project__c);
                }
                if(ca.Opportunity_Name__c != null){
                    oppId.add(ca.Opportunity_Name__c); 
                }
            }
            
            if(ca.Opportunity_Name__c != null && ca.Candidate_Name__c != null){
                
                oppIdsToDeleteOCR.add(ca.Opportunity_Name__c);
                conIdsToDeleteOCR.add(ca.Candidate_Name__c);    
            }
        }// Added by Kuppulakshmi on Feb 28  end
    }else{
    
        List<Contact_Assignments__c> caListToCheckOralExamDateTimeUpdateError = new List<Contact_Assignments__c>();
        Set<Id> projIdSet = new Set<Id>();
        
        Map<Id, Contact_Assignments__c> conAssignMap = new Map<Id, Contact_Assignments__c>();
        Set<Id> instructorIdsToCheckZoomUser = new Set<Id>();
        
        ContactAssignmentTriggerHandler.isFromCATrigger = true;
        Pattern MyPattern = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/((19|20)\\d\\d)');  
        Pattern MyPattern2 = Pattern.compile('(0?[1-9]|1[012])/(0?[1-9]|[12][0-9]|3[01])/(\\d\\d)');      
        
        List<Contact_Assignments__c> insCAs_newHire = new List<Contact_Assignments__c>();
        Set<String> status_CancelOrientation = new Set<String>{'Canceled', 'Ended', 'On Hold'};
        Set<Id> insIds_newHire = new Set<Id>();
        
        Set<Id> endedInsIds = new Set<Id>();
        
        // Variables to create and update DLS Experience records when a new Instructor Contact Assignment is created or updated
        Set<Id> conIdsToCreateDLSExp = new Set<Id>();
        Set<String> positions = new Set<String>();
        Map<String, Contact_Assignments__c> conIdCAPosAndCA = new Map<String, Contact_Assignments__c>();
        List<Contact_Assignments__c> endedOnHoldCanceledCAs = new List<Contact_Assignments__c>();
        Set<Id> conIdsToUpdateDLSExp = new Set<Id>();
        Set<String> positionsForUpdate = new Set<String>();
        Set<Id> hiredConIds = new Set<Id>();
            
        for (Contact_Assignments__c ca : trigger.new) {
            
            // To Update the CA Status based on Project Status when Start Date is less than or equal to today - Added by E. Keerthika on 22nd, May 2018
            if(Trigger.isBefore) {
             
                if(Trigger.isUpdate && ca.Project__c != null && Trigger.oldMap.get(ca.Id).Project__c != ca.Project__c) {   
                    proId.add(ca.Project__c);
                }
                /*
                //#W-007701 - User Story - Auto-Populate Account field on Contact Assignment
                if(ca.Candidate_Name__c != null && ((Trigger.isInsert && String.isBlank(ca.Account__c)) || (Trigger.isUpdate && Trigger.oldMap.get(ca.Id).Candidate_Name__c != ca.Candidate_Name__c))){
                    contactIds.add(ca.Candidate_Name__c);
                }
                */
                System.debug('CA::OpportunityTrigger_Handler.accPopFromOppTrig:::'+OpportunityTrigger_Handler.accPopFromOppTrig);
                System.debug('CA::ProjectTrigger_Handler.accPopFromProjTrig:::'+ProjectTrigger_Handler.accPopFromProjTrig);
                System.debug('CA::ConvertToProject.accPopFromConToProj:::'+ConvertToProject.accPopFromConToProj);
                if(!OpportunityTrigger_Handler.accPopFromOppTrig && !ProjectTrigger_Handler.accPopFromProjTrig && !ConvertToProject.accPopFromConToProj && Trigger.isInsert && (ca.Opportunity_Name__c != null || ca.Project__c != null)){
                    
                    if(ca.Project__c != null){
                        projIdsForAccPop.add(ca.Project__c);
                    }else{
                        oppIdsForAccPop.add(ca.Opportunity_Name__c);
                    }
                }
                // Added by Shalini on June 20 2017 to update location of CA from Training location of Opp or Project for the first time
                if(Trigger.isInsert) {
                    if(ca.Opportunity_Name__c != null ) {
                        oppIds.add(ca.Opportunity_Name__c);
                    } else if (ca.Project__c != NULL) {
                        proIds.add(ca.Project__c);
                    }
                    
                    
                    //For Updating Paper Timesheet flag to true until live date (10/28/2019)
                    //Value is drived from System Values Custom Setting
                    //Added by NS on Aug 30 2019
                    
                    if(ca.RecordTypeId == instructorRTId){
                        ca.Paper_Timesheet__c = paperTimesheetFlag;
                    }
                }
                
                //For Start date required validation purpose
                if(ca.Project__c != null) {
                    projectIds.add(ca.Project__c);
                } else if(ca.Opportunity_Name__c != null) {
                    opportunityIds.add(ca.Opportunity_Name__c);
                }
                
                // Added by HL on Oct 11 2019
                // Work Item : W-002922 - Student Time Approval Preferences (Daily, Weekly, No Approval)
                // To populate "Time_Approval_Preference__c" field for Student Contact Assignment records
                if(Trigger.isInsert && ca.RecordTypeId == stdRTId){
                    
                    conIds.add(ca.Candidate_Name__c);
                    if(ca.Project__c != NULL){
                        prjIds.add(ca.Project__c);
                    }
                }
                
                /*********
                    - Added By HL on Mar 20 2020
                    - Work Item : W-002921 - Time Entry for Testing Projects
                    - To prevent the manual updation of Oral Exam Date & Time field because it is updated by related event
                    - W-007907 - Can't Update Examiner Contact Assignment 
                    - Added Position based condition to skip the validation for Examiner contact assignment
                    ********/
                if(!EventHandler.isFromEve && !EventHandler.allowToUpdateInsCA && ca.Project__c != null && ca.Oral_Exam_Date_Time__c != null && 
                    Trigger.isUpdate && Trigger.oldMap.get(ca.Id).Oral_Exam_Date_Time__c != ca.Oral_Exam_Date_Time__c && 
                    ContactAssignmentTriggerHandler.isFromCATrigger && !ContactAssignmentTriggerHandler.isFromCATriggerHandler && 
                    ca.Assignment_Position__c == 'Tester'){
                    
                    caListToCheckOralExamDateTimeUpdateError.add(ca);
                    projIdSet.add(ca.Project__c);                    
                }
                
                // To update the L/S/R Goal Score Applicable fields when we have values in Score Final and uncheck it when it is null
                if(Trigger.isInsert || ( Trigger.isUpdate && (ca.L_Score_Final__c != trigger.oldmap.get(ca.Id).L_Score_Final__c || ca.S_Score_Final__c != trigger.oldmap.get(ca.Id).S_Score_Final__c || ca.R_Score_Final__c != trigger.oldmap.get(ca.Id).R_Score_Final__c || ca.W_Score_Goal__c != trigger.oldmap.get(ca.Id).W_Score_Goal__c))) {
                    if(ca.L_Score_Final__c != null && ca.L_Goal_Score_Applicable__c != true) {
                        ca.L_Goal_Score_Applicable__c = true;
                    } else if (ca.L_Score_Final__c == null && ca.L_Goal_Score_Applicable__c == true) {
                        ca.L_Goal_Score_Applicable__c = false;
                    }
                    if(ca.R_Score_Final__c != null && ca.R_Goal_Score_Applicable__c != true) {
                        ca.R_Goal_Score_Applicable__c = true;
                    } else if (ca.R_Score_Final__c == null && ca.R_Goal_Score_Applicable__c == true) {
                        ca.R_Goal_Score_Applicable__c = false;
                    }
                    if(ca.S_Score_Final__c != null && ca.S_Goal_Score_Applicable__c != true) {
                        ca.S_Goal_Score_Applicable__c = true;
                    } else if (ca.S_Score_Final__c == null && ca.S_Goal_Score_Applicable__c == true) {
                        ca.S_Goal_Score_Applicable__c = false;
                    }
                    if(ca.W_Score_Goal__c != null && ca.W_Goal_Score_Applicable__c != true) {
                        ca.W_Goal_Score_Applicable__c = true;
                    } else if (ca.W_Score_Goal__c == null && ca.W_Goal_Score_Applicable__c == true) {
                        ca.W_Goal_Score_Applicable__c = false;
                    }
                }
                
                //Added By Dhinesh - 06/09/2021 - W-006998 - To populate Payment Date to today if null on Linguist Paid checked.
                if(ca.Linguist_Paid__c && (Trigger.isInsert || Trigger.oldMap.get(ca.Id).Linguist_Paid__c != ca.Linguist_Paid__c)){
                    ca.Payment_Date__c = ca.Payment_Date__c != null ? ca.Payment_Date__c : System.today();
                }   
                
                if(ca.Last_COVID_19_Vaccinated_Date_Conga__c != null && (Trigger.isInsert || (ca.Last_COVID_19_Vaccinated_Date_Conga__c != Trigger.oldMap.get(ca.Id).Last_COVID_19_Vaccinated_Date_Conga__c))){
          
                    
                    Matcher MyMatcher = MyPattern.matcher(ca.Last_COVID_19_Vaccinated_Date_Conga__c);
                    Matcher MyMatcher2 = MyPattern2.matcher(ca.Last_COVID_19_Vaccinated_Date_Conga__c);
                                        
                    if(MyMatcher.matches()){
                        List<String> dateTemp = ca.Last_COVID_19_Vaccinated_Date_Conga__c.split('/');
                        ca.Last_COVID_19_Vaccinated_Date__c = Date.newinstance(Integer.valueOf(dateTemp[2]), Integer.valueOf(dateTemp[0]), Integer.valueOf(dateTemp[1]));
                    }else if(MyMatcher2.matches()){
                        List<String> dateTemp = ca.Last_COVID_19_Vaccinated_Date_Conga__c.split('/');
                        ca.Last_COVID_19_Vaccinated_Date__c = Date.newinstance(Integer.valueOf('20'+dateTemp[2]), Integer.valueOf(dateTemp[0]), Integer.valueOf(dateTemp[1]));
                    }
                } 
                
                if(ca.Covid_19_Booster_Received_Date_Conga__c != null && (Trigger.isInsert || (ca.Covid_19_Booster_Received_Date_Conga__c != Trigger.oldMap.get(ca.Id).Covid_19_Booster_Received_Date_Conga__c))){
          
                    Matcher MyMatcher = MyPattern.matcher(ca.Covid_19_Booster_Received_Date_Conga__c);
                    Matcher MyMatcher2 = MyPattern2.matcher(ca.Covid_19_Booster_Received_Date_Conga__c);
                                        
                    if(MyMatcher.matches()){
                        List<String> dateTemp = ca.Covid_19_Booster_Received_Date_Conga__c.split('/');
                        ca.Covid_19_Booster_Received_Date__c = Date.newinstance(Integer.valueOf(dateTemp[2]), Integer.valueOf(dateTemp[0]), Integer.valueOf(dateTemp[1]));
                    }else if(MyMatcher2.matches()){
                        List<String> dateTemp = ca.Covid_19_Booster_Received_Date_Conga__c.split('/');
                        ca.Covid_19_Booster_Received_Date__c = Date.newinstance(Integer.valueOf('20'+dateTemp[2]), Integer.valueOf(dateTemp[0]), Integer.valueOf(dateTemp[1]));
                    }
                }            
                
                // Added on Nov 18 2022
                if(ca.Oral_Exam_Date_Time__c != null && (Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(ca.Id).Oral_Exam_Date_Time__c != ca.Oral_Exam_Date_Time__c))){
                    ca.Start_Date__c = Date.ValueOf(ca.Oral_Exam_Date_Time__c);
                }   
                 
                // W-007915 : Do not send EOT Instructor Survey when CA Status is changed from On Hold to Ended
                if(Trigger.isUpdate && ca.Project__c != null && !projRTsToExcludeEOTGetFeedbackEmail.contains(ca.Project_Record_Type_Developer_Name__c) && ca.RecordTypeId == instructorRTId && ca.Assignment_Position__c != 'Tester' && ca.Status__c != Trigger.oldMap.get(ca.Id).Status__c && ca.Status__c == 'Ended' && !ProjectTrigger_Handler.isFromProjectTrigger_SendGetFeedback && ca.Iscoursecompletefeedsend__c == False && 
                    Trigger.oldMap.get(ca.Id).Status__c != 'On Hold'){
                    endedInsIds.add(ca.Id);
                }                
            } //End of is Before
   
            if(Trigger.isAfter) {
            
                if (ca.Opportunity_Name__c != null && ca.Candidate_Name__c != null && (Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(ca.Id).Candidate_Name__c != ca.Candidate_Name__c)) && ca.Assignment_Position__c != null) {
                    
                    oppIdSet.add(ca.Opportunity_Name__c);
                    
                    if(Trigger.isUpdate && Trigger.oldMap.get(ca.Id).Candidate_Name__c != ca.Candidate_Name__c){
                    
                        oppIdsToDeleteOCR.add(ca.Opportunity_Name__c);
                        conIdsToDeleteOCR.add(Trigger.oldMap.get(ca.Id).Candidate_Name__c); 
                    }
                }
                
                // Project Manager field update Code
                if (ca.Project__c != null && ca.Candidate_Name__c != null && ca.Assignment_Position__c  != null && (Trigger.isInsert || (Trigger.oldMap.get(ca.Id).Candidate_Name__c != ca.Candidate_Name__c || (ca.Status__c == 'Active' && Trigger.oldMap.get(ca.Id).Status__c != ca.Status__c) || Trigger.oldMap.get(ca.Id).Assignment_Position__c != ca.Assignment_Position__c)) && 
                    (ca.Assignment_Position__c == 'Project Manager' || ca.Assignment_Position__c == 'Manager')){
                    projIdSetToUpdatePM.add(ca.Project__c);
                    contIdSetToUpdatePM.add(ca.Candidate_Name__c);
                } 
                if(ca.Opportunity_Name__c != null && ca.Candidate_Name__c != null 
                        && (Trigger.isInsert || ( trigger.isUpdate && Trigger.oldMap.get(ca.Id).Candidate_Name__c != ca.Candidate_Name__c)) 
                        && (ca.Status__c == 'Active' || ca.Status__c == 'Planned') ) {
                    
                        OppIdSetForContact.add(ca.Opportunity_Name__c);
                        contactIdSet.add(ca.Candidate_Name__c);
                }
                
                if(Trigger.isInsert && ca.Opportunity_Name__c != null && ca.Candidate_Name__c != null && ca.RecordTypeId == studentCARecordTypeId){
                        oppIdsForContFieldUpdate.add(ca.Opportunity_Name__c);
                }
                
                if(ca.RecordTypeId == instructorRTId && ((Trigger.isInsert && (ca.status__c == 'Active' || ca.Status__c == 'Awarded')) || (Trigger.isUpdate && Trigger.oldMap.get(ca.Id).Status__c != ca.Status__c && 
                    (Trigger.oldMap.get(ca.Id).Status__c != 'Active' && ca.Status__c == 'Active' || Trigger.oldMap.get(ca.Id).Status__c == 'Active' && ca.Status__c != 'Active' ||
                    Trigger.oldMap.get(ca.Id).Status__c != 'Awarded' && ca.Status__c == 'Awarded' || Trigger.oldMap.get(ca.Id).Status__c == 'Awarded' && ca.Status__c != 'Awarded'))) && 
                    ca.Candidate_Name__c != NULL){
                
                    if(ca.Opportunity_Name__c != NULL){
                        oppIdforcount.add(ca.Opportunity_Name__c);
                        conprojIdforcount.add(ca.Opportunity_Name__c);
                    } 
                    if(ca.Project__c != NULL){
                        projIdforcount.add(ca.Project__c);
                        conprojIdforcount.add(ca.Project__c);
                    }   
                }
                
                // To Create Observation Assessment Report when an instructor is activated
                if((Trigger.isInsert || Trigger.oldMap.get(ca.Id).Status__c != ca.Status__c) && ca.Schedule_Observation__c == 'Yes' && 
                    ca.RecordTypeId == instructorRTId && ca.status__c == 'Active' && ca.Project__c != NULL) {
                    projObsIds.add(ca.Project__c);
                    cas.add(ca);
                }
                
                
                //Added By Dhinesh - W-006595 - create task for ca based on Agreed_DLS_Policies_And_Procedures__c
                if(ca.RecordTypeId == studentCARecordTypeId && !ca.Agreed_DLS_Policies_And_Procedures__c && (Trigger.isInsert || ca.Status__c != Trigger.oldMap.get(ca.Id).Status__c)){
                    if(ca.Status__c == 'Planned' || ca.Status__c == 'Active'){
                        caToCheckAndCreateTasks.add(ca.Id);
                    }else if(ca.Status__c == 'Canceled' || ca.Status__c == 'Closed Lost'){
                        caToDeleteTasks.add(ca.Id);    
                    }                    
                }
                
                //Added By Dhinesh - 06/09/2021 - W-006595 - To update the task status when the Agreed_DLS_Policies_And_Procedures__c field is checked
                if(ca.RecordTypeId == studentCARecordTypeId && ca.Agreed_DLS_Policies_And_Procedures__c && (Trigger.isInsert || ca.Agreed_DLS_Policies_And_Procedures__c != Trigger.oldMap.get(ca.Id).Agreed_DLS_Policies_And_Procedures__c)){
                    caIdsToUpdateTaskStatus.add(ca.Id);
                }
                
                // Added By HL on May 20 2022 - W-007472: Language Testing Goals Field Population
                if(ca.RecordTypeId == studentCARecordTypeId && Trigger.isUpdate && (ca.L_Score_Final__c != Trigger.oldMap.get(ca.Id).L_Score_Final__c || ca.R_Score_Final__c != Trigger.oldMap.get(ca.Id).R_Score_Final__c ||
                    ca.S_Score_Final__c != Trigger.oldMap.get(ca.Id).S_Score_Final__c || ca.W_Score_Goal__c != Trigger.oldMap.get(ca.Id).W_Score_Goal__c)){
                    conAssignMap.put(ca.Id, ca);                    
                }
                
                //Added By Dhinesh - 05/09/2022 - W-007564 - Initiate Zoom User creation
                if(ca.RecordTypeId == instructorRTId && ca.Candidate_Name__c != null && (ca.Status__c == 'Active' || ca.Status__c == 'Planned') && (Trigger.isInsert || (ca.Status__c != Trigger.oldMap.get(ca.Id).Status__c || ca.Candidate_Name__c != Trigger.oldMap.get(ca.Id).Candidate_Name__c))){
                    instructorIdsToCheckZoomUser.add(ca.Candidate_Name__c);   
                }
                
                // Added on Apr 03 2023 - W-007730 - Email to HR to Cancel Orientation for New Hire (MAY-1-2023)
                if(Trigger.isUpdate && ca.RecordTypeId == instructorRTId && ca.Status__c != Trigger.oldMap.get(ca.Id).Status__c && status_CancelOrientation.contains(ca.Status__c) && ca.Start_Date__c > System.Today()){
                    insCAs_newHire.add(ca);
                    insIds_newHire.add(ca.Candidate_Name__c);
                }
                
                //To Create Experience Records based on new instructor record creation
                if(ca.RecordTypeId == instructorRTId && ca.Project__c != null && ca.Status__c == 'Active' && ca.Candidate_Name__c != null && ContactAssignmentTriggerHandler.insPosExpService.containsKey(ca.Assignment_Position__c) && (trigger.isInsert || (trigger.isUpdate && ca.Status__c != Trigger.OldMap.get(ca.Id).Status__c))) {
                    
                    conIdsToCreateDLSExp.add(ca.Candidate_Name__c);
                    positions.add(ca.Assignment_Position__c);
                    String conIdCAPos = ca.Candidate_Name__c + '-' + ContactAssignmentTriggerHandler.insPosExpService.get(ca.Assignment_Position__c);
                    conIdCAPosAndCA.put(conIdCAPos, ca);
                }
                
                if(trigger.isUpdate && ca.RecordTypeId == instructorRTId && ca.Status__c != Trigger.OldMap.get(ca.Id).Status__c && ContactAssignmentTriggerHandler.insPosExpService.containsKey(ca.Assignment_Position__c) && (ca.Status__c == 'Ended' || ca.Status__c == 'On Hold' || ca.Status__c == 'Canceled')) {
                    
                    conIdsToUpdateDLSExp.add(ca.Candidate_Name__c);
                    positionsForUpdate.add(ca.Assignment_Position__c);
                    endedOnHoldCanceledCAs.add(ca);                    
                }
                
                // W-007989 : Automation needed for new "Candidate Hiring Stage" field for "Hired" value
                // Auto-update the "Candidate Hiring Stage" to "Hired" when their first-ever Contact Assignment is created
                if(Trigger.isInsert && ca.RecordTypeId == instructorRTId && ca.Candidate_Name__c != null && ca.Project__c != null && (ca.Status__c == 'Planned' || ca.Status__c == 'Active')){
                    hiredConIds.add(ca.Candidate_Name__c);    
                }
            }
        } // end for trigger.new
        
        if(endedInsIds.size() > 0) {
            
            for( Contact_Assignments__History ch : [SELECT Id,OldValue,NewValue,ParentId,Field FROM Contact_Assignments__History WHERE ParentId IN :endedInsIds and Field ='Status__c']) {
                if(ch.NewValue == 'Ended') {
                    sendFeedbackFormHelper.duplicateEndedInsId.add(ch.parentId);
                }
            }
        }
        
        //Added By Dhinesh - 01/11/2021 - W-007174 - Change Oral Exam Date & Time Population for Test Type = Translation Billable
        if(projIdSet.size() > 0){
            Map<Id, Acctseed__Project__c> projectIdWithRecMap = new Map<Id, AcctSeed__Project__c>([SELECT Id, Test_Type__c FROM AcctSeed__Project__c WHERE Id IN :projIdSet]);
            for(Contact_Assignments__c ca : caListToCheckOralExamDateTimeUpdateError){
                if(projectIdWithRecMap.get(ca.Project__c).Test_Type__c != 'Translation Billable'){
                    ca.Oral_Exam_Date_Time__c.addError('You can\'t edit this field, please update related event if you want to update the Oral Exam Date & Time');
                }
            }
        }
        if(conAssignMap.size() > 0){
            ContactAssignmentTriggerHandler.updateLanguageTestingRecs(conAssignMap);    
        } 
        
        if(instructorIdsToCheckZoomUser.size() > 0){
            ContactAssignmentTriggerHandler.validateInstructorZoomUser(instructorIdsToCheckZoomUser);
        } 
        
        if(insCAs_newHire.size() > 0 && insIds_newHire.size() > 0){
            ContactAssignmentTriggerHandler.SendEmail_CancelOrientation_NewHire(insCAs_newHire, insIds_newHire);
        }
        
        if(conIdsToCreateDLSExp.size() > 0) {
            
            ContactAssignmentTriggerHandler.createDLSExperience(conIdsToCreateDLSExp, positions, conIdCAPosAndCA);
        }
        
        if(conIdsToUpdateDLSExp.size() > 0) {
            
            ContactAssignmentTriggerHandler.updateDLSExperience(conIdsToUpdateDLSExp,positionsForUpdate,endedOnHoldCanceledCAs);
        }
        
        if(hiredConIds.size() > 0){
            ContactAssignmentTriggerHandler.updateContactHiringStage(hiredConIds);
        }
    }
        
    //Added By Dhinesh - W-006595 - create task for ca based on Agreed_DLS_Policies_And_Procedures__c
    if(caToCheckAndCreateTasks.size() > 0 || caToDeleteTasks.size() > 0){
        Set<Id> caIds = new Set<Id>();
        caIds.addAll(caToCheckAndCreateTasks);
        caIds.addAll(caToDeleteTasks);
        
        List<Task> tasksToDelete = new List<Task>();  
        List<Task> tasksToCreate = new List<Task>();        
        
        for(Task task : [SELECT Id, WhatId FROM Task WHERE WhatId IN :caIds AND Subject = 'Student Policies & Procedures']){
            
            if(caToDeleteTasks.contains(task.WhatId))
                tasksToDelete.add(task);
                
            caToCheckAndCreateTasks.remove(task.WhatId);
        }
        
        for(Id caId : caToCheckAndCreateTasks){
            tasksToCreate.add(new Task(Subject = 'Student Policies & Procedures', Type = 'To Do', To_Do_Type__c = '40 - Student Policies & Procedures', Status = 'In Progress', WhatId = caId));
        }
        
        if(tasksToCreate.size() > 0 || tasksToDelete.size() > 0){
            //insert tasksToCreate;
            //delete tasksToDelete;
            // To fix the issue related to "System.DmlException: Delete failed : INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY" this deletion logic moved into Queueable class
            CreateAndDeleteTaskforCA deleteJob = new CreateAndDeleteTaskforCA(tasksToCreate, tasksToDelete);
            System.enqueueJob(deleteJob);
        }
    }
    
    if(caIdsToUpdateTaskStatus.size() > 0){
        List<Task> taskToUpdate = new List<Task>();  
        for(Task task : [SELECT Id, WhatId, Status FROM Task WHERE WhatId IN :caIdsToUpdateTaskStatus]){
            task.Status = 'Completed';
            taskToUpdate.add(task);
        }
        
        update taskToUpdate;
    }
    
    // Added by Kuppulakshmi on Feb 28 for count of Active and Awarded Status
    //start
    if((conprojIdforcount != NULL && conprojIdforcount.size()>0)){
        for(Contact_Assignments__c conassign : ContactAssignmentService.getContactAssignmentByParentIdsAndRTName(conprojIdforcount,new Set<String>{'Instructor'},' AND (Status__c = \'Awarded\' OR Status__c = \'Active\')',' ,Opportunity_Name__r.RecordType.DeveloperName,Project__r.RecordType.DeveloperName')){        
            if(conassign.Opportunity_Name__r.RecordType.DeveloperName == 'DLI_W_TO_Opportunities' || conassign.Opportunity_Name__r.RecordType.DeveloperName == 'MTT_Opportunities'){
                oppcon = String.Valueof(conAssign.Opportunity_Name__c)+String.Valueof(conAssign.Candidate_Name__c)+String.Valueof(conAssign.Status__c);
                if(!oppconsetforcount.contains(oppcon)){
                    conassIdforcount.add(conAssign.Id);
                    oppconsetforcount.add(oppcon);
                }
            }
            /*********
                - Modified By HL on Apr 07 2020
                - Work Item : W-005171 - Field: # of Instructors (active) not populating
                - To populate of_Instructors_active__c field value for all recordtype projects except for Admin_Projects
                *******/
            if(conassign.Project__r.RecordType.DeveloperName != 'Admin_Projects'){
                procon = String.Valueof(conAssign.Project__c)+String.Valueof(conAssign.Candidate_Name__c)+String.Valueof(conAssign.Status__c);
                if(!oppconsetforcount.contains(procon)){
                    conassprojIdforcount.add(conAssign.Id);
                    oppconsetforcount.add(procon);
                }
            }
        } 
    }// for avaoiding same opp&contact
        
    if(conassIdforcount != NULL && conassIdforcount.size()>0){
        //AggregateResult[] groupedResults = [SELECT Opportunity_Name__c Id,count(Id),Status__c sts FROM Contact_Assignments__c WHERE Id IN :conassIdforcount GROUP BY Opportunity_Name__c,Status__c];
        AggregateResult[] groupedResults = ContactAssignmentService.getAggregateresult('Opportunity_Name__c Id,count(Id),Status__c sts',conassIdforcount,'Opportunity_Name__c,Status__c');
        for (AggregateResult ar : groupedResults){
            if(!oppconMapforcount.containskey((Id)ar.get('Id'))){
                oppconMapforcount.put((Id)ar.get('Id'), new Map<String, Integer>{(String)ar.get('sts')=>(Integer) ar.get('expr0')});
            }else
                 oppconMapforcount.get((Id)ar.get('Id')).put((String)ar.get('sts'),(Integer) ar.get('expr0'));
        }
    }
    
    for(ID opporId: oppIdforcount){
        Opportunity oppupdate = new Opportunity(Id = opporId);
        oppupdate.of_Instructors_active__c = 0;
        oppupdate.of_Instructors_awarded__c = 0;
        if(oppconMapforcount.containsKey(opporId)){
            if(oppconMapforcount.get(opporId).containsKey('Awarded')){
                oppupdate.of_Instructors_awarded__c = oppconMapforcount.get(opporId).get('Awarded');
            }
            if(oppconMapforcount.get(opporId).containsKey('Active')){
                oppupdate.of_Instructors_active__c = oppconMapforcount.get(opporId).get('Active');
            } 
        } 
       oppListforcount.add(oppupdate);
    }
        
    if(conassprojIdforcount != NULL && conassprojIdforcount.size()>0){
        //AggregateResult[] groupedResults1 = [SELECT Project__c Id,count(Id),Status__c sts FROM Contact_Assignments__c WHERE Id IN :conassprojIdforcount GROUP BY Project__c,Status__c];
        AggregateResult[] groupedResults1 = ContactAssignmentService.getAggregateresult('Project__c Id,count(Id),Status__c sts',conassprojIdforcount,'Project__c,Status__c');
        for (AggregateResult ar : groupedResults1){
            if(!oppconMapforcount.containskey((Id)ar.get('Id'))){
                oppconMapforcount.put((Id)ar.get('Id'), new Map<String, Integer>{(String)ar.get('sts')=>(Integer) ar.get('expr0')});
            }else
                 oppconMapforcount.get((Id)ar.get('Id')).put((String)ar.get('sts'),(Integer) ar.get('expr0'));
        }
    }
    
    for(ID projId: projIdforcount){
            AcctSeed__Project__c project = new AcctSeed__Project__c(Id = projId);
            project.of_Instructors_active__c = 0;
            project.of_Instructors_awarded__c = 0;
            if(oppconMapforcount.containsKey(projId)){
                if(oppconMapforcount.get(projId).containsKey('Awarded')){
                    project.of_Instructors_awarded__c = oppconMapforcount.get(projId).get('Awarded');
                }
                if(oppconMapforcount.get(projId).containsKey('Active')){
                    project.of_Instructors_active__c = oppconMapforcount.get(projId).get('Active');
                } 
            } 
           projListforcount.add(project);
        }
    //end
    
    if (oppIdSet != null && oppIdSet.size() > 0) {
        createContactRoles_Util.createContactRoles(oppIdSet, false);    
    }
    
    if(oppIdsToDeleteOCR.size() > 0 && conIdsToDeleteOCR.size() > 0){
        createContactRoles_Util.deleteContactRoles(oppIdsToDeleteOCR, conIdsToDeleteOCR);
    }
    
    // Start Project Manager field update Code
    if (projIdSetToUpdatePM.size() > 0 && contIdSetToUpdatePM.Size() > 0 ) {
        c.updateProjManager(projIdSetToUpdatePM,contIdSetToUpdatePM);
    }
    
    // End Project Manager field update Code
    
    if(projObsIds.size() > 0 && cas.size() > 0 ) {
        System.debug('projObsIds:::::'+projObsIds);
        System.debug('cas::::'+cas);
        List<Assessment_Report__c> obsRpt = Assessment_Report_Helper.createObservationReportRecs(projObsIds,cas, new Map<Id, List<Date>>(), 'CATrigger');
        System.debug('obsRpt::::'+obsRpt);
        if(obsRpt != null && obsRpt.size() > 0) {
            Insert obsRpt;
        }
    }
    
    // To update Opportunities Contact field
    Schema.DescribeSObjectResult oppKey = Opportunity.sObjectType.getDescribe();
    String opportunityKeyPrefix = oppKey.getKeyPrefix();
    //Map<Id,List<Contact_Assignments__c>> oppIdWithContactAssignListMap = new Map<Id,List<Contact_Assignments__c>>();
    Set<Id> LTSContactIdSet = new Set<Id>();
    
    // Start of code for Text Fields Updation in Project 
    
    Set<Id> insIdsForOralExam = new Set<Id>();  
    Map<Id,DateTime> projIdOralDateMap = new Map<Id,DateTime>();
    List<Approval.ProcessSubmitRequest> approvalRequest = new List<Approval.ProcessSubmitRequest>();
    Set<Id> projIds = new Set<Id>();
    
     // Variables related to Moodle Integration
    Set<Id> filteredCAIds = new Set<Id>();
    List<Contact_Assignments__c> updateCAs = new List<Contact_Assignments__c>();
    
    // To update the Assessment Report LT Coordinator when a new LT Coordinator Staff Contact Assignment is added
    Map<Id,Id> ProjLTCoordId = new Map<Id,Id>();
    
    if(Trigger.isAfter) {
        
        Set<Id> conIdsToSendAnEmail = new Set<Id>();
        Map<Id, Id> conIdAndCAId = new Map<Id, Id>();
        
        Set<Id> insIdsToSendCompletedFeedback = new Set<Id>();
        List<Contact_Assignments__c> insCAsToSendCompletedFeedback = new List<Contact_Assignments__c>();
        
        if(Trigger.isInsert || Trigger.isUpdate){
        
            for(Contact_Assignments__c con : Trigger.new) {
            
                if(con.Project__c != null && con.Candidate_Name__c != null && (Trigger.isInsert || (Trigger.isUpdate && (Trigger.oldMap.get(con.Id).Status__c != con.Status__c || Trigger.oldMap.get(con.Id).Candidate_Name__c != con.Candidate_Name__c || Trigger.OldMap.get(con.Id).Project__c != con.Project__c)))) {
                    proIdSet.add(con.Project__c);
                    conassignIdSet.add(con.Id);    
                } 
                
                if(con.Opportunity_Name__c != null && con.Candidate_Name__c != null && (Trigger.isInsert || (Trigger.isUpdate && (Trigger.oldMap.get(con.Id).Status__c != con.Status__c || Trigger.oldMap.get(con.Id).Candidate_Name__c != con.Candidate_Name__c)))) {
                    oppId.add(con.Opportunity_Name__c);
                    conassignIdSet.add(con.Id); 
                } 
                
                //To update the Oral Exam Date & Time field for the Testing Opportunities.
                if(con.RecordTypeId == instructorRTId && con.Project__c != null && con.Oral_Exam_Date_Time__c != null && ((Trigger.isUpdate && 
                    Trigger.oldMap.get(con.Id).Oral_Exam_Date_Time__c != con.Oral_Exam_Date_Time__c && 
                    EventHandler.isFromEve && !ContactAssignmentTriggerHandler.insIdsForOralExam.contains(con.Id)) || Trigger.isInsert)) { //Added ContactAssignmentTriggerHandler.insIdsForOralExam by Dhinesh to skip CA updated in previous execution
                    insIdsForOralExam.add(con.Id);                        
                    projIdOralDateMap.put(con.Project__c,con.Oral_Exam_Date_Time__c);
                }
                
                // Added by HL on June 05 2019
                // Submit the Approval Request To HR
                System.debug('ContactAssignmentLightningCtrl.isFromCA==========='+ContactAssignmentLightningCtrl.isFromCA);
                if(Trigger.isUpdate && ContactAssignmentLightningCtrl.isFromCA == True){
                    
                    if(String.isNotBlank(con.Additional_Compensation_Status__c) && con.Additional_Compensation_Status__c == 'Draft'){
                    
                        if(String.isNotBlank(con.Additional_Compensation_Type__c) && ((con.Additional_Compensation_Type__c == 'End of Training Bonus' && con.Bonus_Amount__c != NULL) ||
                            (con.Additional_Compensation_Type__c == 'Client Site Travel Reimbursement' && con.Daily_Travel_Reimbursement_Amount__c != NULL))){
                            
                            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                            req.setProcessDefinitionNameOrId('Additional_Compensation_Approval_Process');
                            req.setObjectId(con.Id);
                            approvalRequest.add(req);
                        }
                    }
                }
                
                // Added by HL on Sep 19 2019
                // To update Instructor & Student Contact's Supervisor Name field with Project's Project Manager field based on CA creation / updation
                if((con.RecordTypeId == instructorRTId || con.RecordTypeId == stdRTId) && (con.Status__c == 'Active' || con.Status__c == 'Planned') && 
                    (Trigger.isInsert || (Trigger.isUpdate && ((con.Status__c != Trigger.oldMap.get(con.Id).Status__c) || 
                    (con.Paper_Timesheet__c != Trigger.oldMap.get(con.Id).Paper_Timesheet__c))))){
                
                    projIds.add(con.Project__c);
                }
                
                if(Trigger.isUpdate && (con.RecordTypeId == instructorRTId || con.RecordTypeId == stdRTId)
                    && (con.Moodle_Sync_Status__c != null && con.Moodle_Sync_Status__c != 'Pending') 
                    && (con.Start_Date__c != Trigger.oldMap.get(con.Id).Start_Date__c 
                    || (con.RecordTypeId == instructorRTId && con.End_Date__c != Trigger.oldMap.get(con.Id).End_Date__c) )){
                
                    filteredCAIds.add(con.Id);
                }
                
                // To update the Assessment Report LT Coordinator when a new LT Coordinator Staff Contact Assignment is added
                if(con.Project__c != null && con.Candidate_Name__c != null && con.RecordTypeId == staffRTId && con.Assignment_Position__c == 'Project Support' && con.Status__c == 'Active' && (Trigger.isInsert || (Trigger.isUpdate && Trigger.oldMap.get(con.Id).Status__c != con.Status__c || Trigger.OldMap.get(con.Id).Project__c != con.Project__c))) {
                    ProjLTCoordId.put(con.Project__c, con.Candidate_Name__c);
                }
                
                // To send an email to HR team about returned employees
                if(con.Candidate_Name__c != null && con.RecordTypeId == instructorRTId && (con.Status__c == 'Active' || 
                    con.Status__c == 'Planned') && (Trigger.isInsert || Trigger.oldMap.get(con.Id).Status__c != con.Status__c)){
                    
                    conIdsToSendAnEmail.add(con.Candidate_Name__c);
                    conIdAndCAId.put(con.Candidate_Name__c, con.Id);
                }
                
                if(Trigger.isUpdate && con.Project__c != null && !projRTsToExcludeEOTGetFeedbackEmail.contains(con.Project_Record_Type_Developer_Name__c) && con.RecordTypeId == instructorRTId && String.isNotBlank(con.Assignment_Position__c) && con.Assignment_Position__c != 'Tester' && Trigger.oldMap.get(con.Id).Status__c != con.Status__c && con.Status__c == 'Ended' && !sendFeedbackFormHelper.duplicateEndedInsId.contains(con.Id) && 
                    Trigger.oldMap.get(con.Id).Status__c != 'On Hold'){  
                    insIdsToSendCompletedFeedback.add(con.Candidate_Name__c);
                    insCAsToSendCompletedFeedback.add(con);
                }
            }
        }
        
        // To send an email to HR Team about instructors who haven’t worked for a year and has been assigned to the new project
        if(conIdsToSendAnEmail.size() > 0){
            ContactAssignmentTriggerHandler.employeeRehiringNotification(conIdsToSendAnEmail, conIdAndCAId);
        }
        
        if(insIdsToSendCompletedFeedback.size() > 0){
        
            // W-007898 : Request to Stop Instructor Surveys for UAE Projects
            // To exclude UAE instructors from sending Get Feedback survey email process
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Candidate_Name__c, Project__c FROM Contact_Assignments__c WHERE Id IN : insCAsToSendCompletedFeedback AND Project__r.QB_Classification__c != 'OF0UAE' AND (NOT (Project__r.Name LIKE '%UAE%'))];
            if(!conAssigns.isEmpty()){
                sendFeedbackFormHelper.sendInstructorCompletedFeedback(conAssigns, insIdsToSendCompletedFeedback, 'CourseEndGetfeedback_To_Instructor', 'Completed');
            }
        }
    }
    
    // To update the Assessment Report LT Coordinator when a new LT Coordinator Staff Contact Assignment is added
    if(ProjLTCoordId != null && ProjLTCoordId.size() > 0) {
        Assessment_Report_Helper.updateAssementReportLT(ProjLTCoordId);
    }
    
    if(filteredCAIds.size() > 0){
       ContactAssignmentTriggerHandler.updateMoodleSyncStatus(filteredCAIds);
    }
    
    if(projIds.size() > 0){
                
        Map<Id, Id> projIdAndProjManagerId = new Map<Id, Id>();
        
        for(AcctSeed__Project__c p : [SELECT Id, Project_Manager__c FROM AcctSeed__Project__c WHERE Id IN : projIds AND RecordType.DeveloperName != 'CD_Projects']){
            projIdAndProjManagerId.put(p.Id, p.Project_Manager__c);
        }
        
        if(projIdAndProjManagerId.size() > 0){
            ProjectTrigger_Handler.updateContactSupervisor(projIdAndProjManagerId);
        }
    }
    if(approvalRequest.size() > 0) {
        List<Approval.ProcessResult> result = Approval.process(approvalRequest);
    }
    
    if( conassignIdSet != null && conassignIdSet.size() > 0 ) {
        ContactAssignmentTriggerHandler.updateTextFields(proIdSet,conassignIdSet,oppId);
    } 
    if ( insIdsForOralExam != null && insIdsForOralExam.size() > 0 ) {
        ContactAssignmentTriggerHandler.updateOralExamDateTime(insIdsForOralExam ,projIdOralDateMap);
    }
    
    // End of code for Text Fields Updation in Project 
    
    //Commented to prevent the creation of unwanted opportunity contact roles under a opportunity
    /*
    //String oppId = '';
    if(trigger.isInsert || trigger.isUpdate){
        for (Contact_Assignments__c ca : trigger.new) {
            if((trigger.isInsert || (trigger.isUpdate && Trigger.oldMap.get(ca.Id).Status__c != ca.Status__c && ca.Status__c == 'Active')) && trigger.isAfter) {
                
                if(ca.Opportunity_Name__c != null && !oppIdWithContactAssignListMap.containskey(ca.Opportunity_Name__c)) {
                    oppIdWithContactAssignListMap.put(ca.Opportunity_Name__c,new List<Contact_Assignments__c> { ca });
                }
                if(ca.Assignment_Position__c == 'Project Manager') {
                    LTSContactIdSet.add(ca.Candidate_Name__c);
                }
                
                if(ca.Opportunity_Name__c != null)
                    oppIdWithContactAssignListMap.get(ca.Opportunity_Name__c).add(ca);
            }
        }
        
        if(oppIdWithContactAssignListMap != null && oppIdWithContactAssignListMap.size() > 0 ) {
            c.updateOpportunitiesContactFeilds(oppIdWithContactAssignListMap,LTSContactIdSet);
        }
    }
    */
    
    // Added by Sukanya on November 7 2016 for Contact Field update 
    // Call handler Class 
    if(OppIdSetForContact.size() > 0 && contactIdSet.size() > 0) {
        c.UpdateContactField(OppIdSetForContact,contactIdSet);
    }
    if(oppIdsForContFieldUpdate.size() > 0){
        c.updateContactMostRecentOppStatusfield(oppIdsForContFieldUpdate);
    }
    if(oppListforcount != null && oppListforcount.size() > 0){
        oppListforcount = OpportunityService.updateOpp(oppListforcount);
    }
    if(projListforcount != NULL && projListforcount.size() > 0){
        //update projListforcount;
        //projListforcount = ProjectService.updateProject(projListforcount);
        for(AcctSeed__Project__c pro : projListforcount) {
            if(!ContactAssignmentTriggerHandler.projMapToUpdate.containsKey(pro.Id)) {
                ContactAssignmentTriggerHandler.projMapToUpdate.put(pro.Id,pro);
            } else {
                ContactAssignmentTriggerHandler.projMapToUpdate.get(pro.Id).of_Instructors_awarded__c = pro.of_Instructors_awarded__c;
                ContactAssignmentTriggerHandler.projMapToUpdate.get(pro.Id).of_Instructors_active__c = pro.of_Instructors_active__c;
            }
        }
    }
    
    //Qry Project & Opportunity details for start date validation
    // Added by NS on Sep 20 2018
    Map<Id,Id> proIdAndRTId = new Map<Id,Id>();
    Map<Id,Id> oppIdAndRTId = new Map<Id,Id>();
    
    if(projectIds.size() > 0){
        for(AcctSeed__Project__c pro : [SELECT Id,Name,Start_Date__c, RecordTypeId FROM AcctSeed__Project__c WHERE Id IN :projectIds]){
            if(pro.Start_Date__c != null && !proIdAndRTId.containsKey(pro.Id)){
                proIdAndRTId.put(pro.Id, pro.RecordTypeId);
            }
        }
    }
    if(opportunityIds.size() > 0){
        for(Opportunity opp : [SELECT Id,Name,Start_Date__c, RecordTypeId FROM Opportunity WHERE Id IN :opportunityIds AND StageName != 'Inquiry - Responded']){
            if(opp.Start_Date__c != null && !oppIdAndRTId.containsKey(opp.Id)){
                oppIdAndRTId.put(opp.Id, opp.RecordTypeId);
            }
        }
    }
    
    if(Trigger.isBefore) {
     
        if(Trigger.isInsert && (conIds.size () > 0 || prjIds.size() > 0)){
    
            prjRec = new Map<Id, AcctSeed__Project__c>([SELECT Id, No_Student_Approval__c FROM AcctSeed__Project__c WHERE Id IN :prjIds]);
            conRec = new Map<Id, Contact>([SELECT Id, Time_Approval_Preference__c FROM Contact WHERE Id IN :conIds]);
        }
        
        //To Update the CA Status based on Project Status when Start Date is less than or equal to today
        if(Trigger.isUpdate && proId != null && proId.size() > 0) {
            for(AcctSeed__Project__c pro : [SELECT Id, Name, AcctSeed__Status__c FROM AcctSeed__Project__c WHERE Id IN :proId AND Start_Date__c <= :System.today()]) {
                proIdStatusMap.put(pro.Id, pro.AcctSeed__Status__c);
            }
        }   
        
        //to update location of CA from Training location of Opp or Project for the first time
        if(Trigger.isInsert) {
            List<Opportunity> oppolist = new List<Opportunity>();
            List<AcctSeed__Project__c> projList = new List<AcctSeed__Project__c>();
            if(oppIds != null && oppIds.size() > 0) {
                oppolist = [SELECT Id,Location__c FROM Opportunity WHERE Id IN :oppIds AND Location__c != null];
            } else if (proIds != null && proIds.size() > 0){
                projList = [SELECT Id,Training_Location__c FROM AcctSeed__Project__c WHERE Id IN :proIds AND Training_Location__c != null];
            }
                    
            for(Opportunity o : oppolist){
                if(!oppOrProWithLocation.containskey(o.Id)){
                    oppOrProWithLocation.put(o.Id,o.Location__c);
                }
            }
            
            for(AcctSeed__Project__c p : projList){
                if(!oppOrProWithLocation.containskey(p.Id)){
                    oppOrProWithLocation.put(p.Id,p.Training_Location__c);
                }
            }
        }        
        /*
        //#W-007701 - User Story - Auto-Populate Account field on Contact Assignment
        if((Trigger.isUpdate || Trigger.isInsert) && contactIds.size() > 0) {
            for(Contact con : [SELECT Id,Name,AccountId FROM Contact WHERE Id IN :contactIds AND AccountId != null]) {
                if(!conIdWithAccIdMap.containsKey(con.Id)){
                    conIdWithAccIdMap.put(con.Id,con.AccountId);
                }
            }
        }
        */
        if(projIdsForAccPop.size() > 0 || oppIdsForAccPop.size() > 0){ 
            if(projIdsForAccPop.size() > 0){
                for(AcctSeed__Project__c p : [SELECT Id, AcctSeed__Account__c FROM AcctSeed__Project__c WHERE Id IN : projIdsForAccPop]){
                    parentIdAndAccId.put(p.Id, p.AcctSeed__Account__c);
                }    
            }    
            if(oppIdsForAccPop.size() > 0){
                for(Opportunity o : [SELECT Id, AccountId FROM Opportunity WHERE Id IN : oppIdsForAccPop]){
                    parentIdAndAccId.put(o.Id, o.AccountId);
                }
            }        
        }
          
        for (Contact_Assignments__c ca : trigger.new) {
            
            //to update location of CA from Training location of Opp or Project for the first time
            if(Trigger.isInsert && oppOrProWithLocation.size() > 0) {
                if(ca.Opportunity_Name__c != null){
                    if(oppOrProWithLocation.containskey(ca.Opportunity_Name__c))  {
                        ca.Location__c = oppOrProWithLocation.get(ca.Opportunity_Name__c);
                    }
                } else if (ca.Project__c != NULL ) {
                    if(oppOrProWithLocation.containskey(ca.Project__c))  {
                        ca.Location__c = oppOrProWithLocation.get(ca.Project__c);
                    }
                } 
            }
            
            //To Update the CA Status based on Project Status when Start Date is less than or equal to today                                      
            if(Trigger.isUpdate && proIdStatusMap != null && proIdStatusMap.size() > 0) {
                if(proIdStatusMap.containsKey(ca.Project__c)) {
                    if(ca.Status__c == 'Planned'){
                        ca.Status__c = proIdStatusMap.get(ca.Project__c);
                    }
                }
            }
            
            //Start Date Required Valdiation moved from validaiton rule to trigger to avoid unwanted error on conversion, opp creation
            if(ca.Start_Date__c == null && ((proIdAndRTId.containsKey(ca.Project__c) && proIdAndRTId.get(ca.Project__c) != testingProjRTId) || 
                (oppIdAndRTId.containsKey(ca.Opportunity_Name__c) && oppIdAndRTId.get(ca.Opportunity_Name__c) != testingOppRTId)) && 
                (ca.Status__c == 'Planned' || ca.Status__c == 'Active' || ca.Status__c == 'Awarded')){
                ca.addError('Please Enter the value for Start Date');
            }
            
            //To populate "Time_Approval_Preference__c" field for Student Contact Assignment records
            if(Trigger.isInsert && ca.RecordTypeId == stdRTId){
            
                if(ca.Project__c != NULL && prjRec.containsKey(ca.Project__c)){
                
                    if(prjRec.get(ca.Project__c).No_Student_Approval__c){
                        ca.Time_Approval_Preference__c = 'No Approval';
                    }else{
                        ca.Time_Approval_Preference__c = conRec.containsKey(ca.Candidate_Name__c) ? conRec.get(ca.Candidate_Name__c).Time_Approval_Preference__c : '';
                    }
                }else if(conRec.containsKey(ca.Candidate_Name__c)){
                
                    ca.Time_Approval_Preference__c = conRec.get(ca.Candidate_Name__c).Time_Approval_Preference__c;
                }
            }
            /*
            - Commented on Apr 18 2024 : W-008024 - Student Contact Page Account Field Update Did Not Update on CA
            - Account population in contact assignment logic changed from Contact Assignment insertion/updation into Project/Opportunity insertion/updation
            //#W-007701 - User Story - Auto-Populate Account field on Contact Assignment
            //Added By Siva Prasanth KT
            if(ca.Candidate_Name__c != null && ((Trigger.isInsert && String.isBlank(ca.Account__c)) || (Trigger.isUpdate && Trigger.oldMap.get(ca.Id).Candidate_Name__c != ca.Candidate_Name__c))){
                if(conIdWithAccIdMap.containsKey(ca.Candidate_Name__c)){
                    Id accId = conIdWithAccIdMap.get(ca.Candidate_Name__c);
                    if(accId != null){
                        ca.Account__c = accId;
                    }
                }
            }
            */
            // W-008024 - Student Contact Page Account Field Update Did Not Update on CA
            // Update the account of contact assignments from their project/opportunity
            if(!OpportunityTrigger_Handler.accPopFromOppTrig && !ProjectTrigger_Handler.accPopFromProjTrig && !ConvertToProject.accPopFromConToProj && Trigger.isInsert && (ca.Opportunity_Name__c != null || ca.Project__c != null)){
                
                Id parentId = ca.Project__c != null ? ca.Project__c : ca.Opportunity_Name__c;
                if(parentId != null && parentIdAndAccId.containsKey(parentId) && parentIdAndAccId.get(parentId) != ca.Account__c){
                    ca.Account__c = parentIdAndAccId.get(parentId);
                } 
            }
        }        
    }
        
    // Added By HL
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            // To Share CostRate Records to Supervisor who are all not in HR, PayRoll and System Aministrator profile when the insertion of Instructor and Supervisor
            ContactAssignmentTriggerHandler.shareCostRateRecords(Trigger.new);  
            // To create AR automatically when new student is added inbetween an ongoing class 
            //ContactAssignmentTriggerHandler.createAReport(Trigger.new); 
        }
        
        if(Trigger.isUpdate){
            // To revoke the shared Cost Rate Records
            ContactAssignmentTriggerHandler.revokeSharingRecords(Trigger.new, Trigger.oldMap);  
            
            if(!ProjectTrigger_Handler.isFromProjectTrigger_StatusUpdate){
                // To cancel the Assessment Report when a student is cancelled 
                ContactAssignmentTriggerHandler.CancelAReport(Trigger.new, Trigger.oldMap);
            }
        }     
        
        // Added on Feb 19 2024   
        // Static variables updation at last
        if(!Trigger.isDelete){
        
            if(ContactAssignmentTriggerHandler.contactMapToUpdate.size() > 0){
                update ContactAssignmentTriggerHandler.contactMapToUpdate.values();
            }    
        }
    }    
    
    System.debug('::projMapToUpdate:**:'+ContactAssignmentTriggerHandler.projMapToUpdate);
     // To update the Project Records only once when the contact Assignment is updated or Added by GRK on March 16, 2018
    if(ContactAssignmentTriggerHandler.projMapToUpdate != null && ContactAssignmentTriggerHandler.projMapToUpdate.size() > 0 ) {
        Update ContactAssignmentTriggerHandler.projMapToUpdate.Values();
    }
}