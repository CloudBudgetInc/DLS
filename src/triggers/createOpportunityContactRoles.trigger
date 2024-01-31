/*
* This trigger creates OpportunityContactRoles for the following fields "Student Name","Contracting Officer",
* "Agency Contact", "Instructor Name",
* with role as "Student/COR/Training Officer/Instructor/EI/Instructor 2", if and only if already an OCR doesn't 
* exist with this opportunity id and contact(Student Name/Contracting Officer/Agency Contact/Instructor Name) combination.
*/

trigger createOpportunityContactRoles on Opportunity (before insert, after insert, after update, before update) {

    //Set<Id> oppIdSet = new Set<Id>();
    Set<Id> opportunityIdSet = new Set<Id>();
    Set<Id> reducedIdSet = new Set<Id>();
    List<Opportunity> oppList = new List<Opportunity>();
    Set<String> langSet = new Set<String>();
    Map<String,Overall_Past_Performance__c> langWithPastperfMap = new Map<String,Overall_Past_Performance__c>();
    ContactAssignmentTriggerHandler conAssignClass = new ContactAssignmentTriggerHandler(); 
    
    // Added By HL on May 13 2020
    List<Opportunity> oppRecsToUpdate = new List<Opportunity>();
    Set<Id> languageIds = new Set<Id>();
    
    // Added by HL on Mar 19 2020
    Id testOppRTId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Testing_Opportunities').getRecordTypeId();
    Set<Id> oppIds = new Set<Id>();
    Map<Id, Id> oppIdAndProjId = new Map<Id, Id>();
    
    Set<Id> oppIdsForContFieldUpdate = new Set<Id>();
    
    // Variables to delete old contact assignments when opportunity's lookup field is updated., then it will delete related opportunity contact roles
    // Contact Lookup (A to B) is updated --> Delete A's CA --> So that it will delete --> A' OCR
    Set<Id> oppIdsToDeleteCA = new Set<Id>();
    Set<Id> conIdsToDeleteCA = new Set<Id>();
    Map<Id, Id> oppIdAndUserId = new Map<Id, Id>();
    
    for (Opportunity opp : trigger.new) {
    
        if (trigger.isAfter && ( ( opp.Student_Name__c != NULL && (Trigger.isInsert || Trigger.oldMap.get(opp.Id).Student_Name__c != opp.Student_Name__c)) ||
             ( opp.Contracting_Officer__c != NULL && (Trigger.isInsert || Trigger.oldMap.get(opp.Id).Contracting_Officer__c != opp.Contracting_Officer__c)) ||
             ( opp.Agency_Contact__c != NULL && (Trigger.isInsert || Trigger.oldMap.get(opp.Id).Agency_Contact__c != opp.Agency_Contact__c)) ||
             ( opp.InstructorName__c != NULL && (Trigger.isInsert || Trigger.oldMap.get(opp.Id).InstructorName__c != opp.InstructorName__c)) ||
             ( opp.Supervisor__c != NULL && (Trigger.isInsert || Trigger.oldMap.get(opp.Id).Supervisor__c != opp.Supervisor__c)) ||
             ( opp.EI_lookup__c != NULL && (Trigger.isInsert || Trigger.oldMap.get(opp.Id).EI_lookup__c != opp.EI_lookup__c)) ||
             ( opp.X2nd_Instructor__c != NULL && (Trigger.isInsert || Trigger.oldMap.get(opp.Id).X2nd_Instructor__c != opp.X2nd_Instructor__c)) 
           )) {
           
            //oppIdSet.add(opp.Id);
                        
            if(Trigger.isUpdate){
            
                oppIdsToDeleteCA.add(opp.Id);
                
                if(Trigger.oldMap.get(opp.Id).Student_Name__c != opp.Student_Name__c && Trigger.oldMap.get(opp.Id).Student_Name__c != null){
                    conIdsToDeleteCA.add(Trigger.oldMap.get(opp.Id).Student_Name__c);
                }
                if(Trigger.oldMap.get(opp.Id).Contracting_Officer__c != opp.Contracting_Officer__c && Trigger.oldMap.get(opp.Id).Contracting_Officer__c != null){
                    conIdsToDeleteCA.add(Trigger.oldMap.get(opp.Id).Contracting_Officer__c);
                }
                if(Trigger.oldMap.get(opp.Id).Agency_Contact__c != opp.Agency_Contact__c && Trigger.oldMap.get(opp.Id).Agency_Contact__c != null){
                    conIdsToDeleteCA.add(Trigger.oldMap.get(opp.Id).Agency_Contact__c);
                }
                if(Trigger.oldMap.get(opp.Id).InstructorName__c != opp.InstructorName__c && Trigger.oldMap.get(opp.Id).InstructorName__c != null){
                    conIdsToDeleteCA.add(Trigger.oldMap.get(opp.Id).InstructorName__c);
                }
                if(Trigger.oldMap.get(opp.Id).Supervisor__c != opp.Supervisor__c && Trigger.oldMap.get(opp.Id).Supervisor__c != null){
                    oppIdAndUserId.put(opp.Id, Trigger.oldMap.get(opp.Id).Supervisor__c);
                }
                if(Trigger.oldMap.get(opp.Id).EI_lookup__c != opp.EI_lookup__c && Trigger.oldMap.get(opp.Id).EI_lookup__c != null){
                    conIdsToDeleteCA.add(Trigger.oldMap.get(opp.Id).EI_lookup__c);
                }
                if(Trigger.oldMap.get(opp.Id).X2nd_Instructor__c != opp.X2nd_Instructor__c && Trigger.oldMap.get(opp.Id).X2nd_Instructor__c != null){
                    conIdsToDeleteCA.add(Trigger.oldMap.get(opp.Id).X2nd_Instructor__c);
                }
            }    
        }

        if(trigger.isbefore && (trigger.isInsert || (trigger.isUpdate && trigger.oldmap.get(opp.Id).Language__c != opp.Language__c))) {
            langSet.add(opp.Language__c);
        }
        
        // Added By HL on May 13 2020
        // To populate Language__c field value based on Language_LU__c value
        if(Trigger.isBefore && opp.Language_LU__c != NULL && (Trigger.isInsert || (Trigger.isUpdate && opp.Language_LU__c != Trigger.oldMap.get(opp.Id).Language_LU__c))){
            
            oppRecsToUpdate.add(opp);
            languageIds.add(opp.Language_LU__c);
        }
        
        // Added By HL on Mar 19 2020
        if(Trigger.isBefore && Trigger.isUpdate){
        
            if(!EventHandler.isFromEve && opp.RecordTypeId == testOppRTId && opp.Oral_Exam__c != Trigger.oldMap.get(opp.Id).Oral_Exam__c){
            
                oppIds.add(opp.Id);
            }
        }
        
    } // end for trigger.new
    System.debug('::::languageIds::::'+languageIds);
    
    if(oppIds != NULL && oppIds.size() > 0){
    
        for(AcctSeed__Project__c p : [SELECT Id, AcctSeed__Opportunity__c 
                                        FROM AcctSeed__Project__c 
                                        WHERE AcctSeed__Opportunity__c IN : oppIds AND RecordType.DeveloperName = 'Testing_Projects']){
        
            oppIdAndProjId.put(p.AcctSeed__Opportunity__c, p.Id);
        }    
    }
    System.debug('::::oppIdAndProjId::::::'+oppIdAndProjId);
    
    if(languageIds != NULL && languageIds.size() > 0){
    
        Map<Id, Language__c> languageRecs = new Map<Id, Language__c>([SELECT Id, Name FROM Language__c WHERE Id IN :languageIds]);
        System.debug('::::languageRecs::::'+languageRecs);
        
        for(Opportunity opp : oppRecsToUpdate){
        
            if(languageRecs != NULL && languageRecs.containsKey(opp.Language_LU__c)){
                
                opp.Language__c = languageRecs.get(opp.Language_LU__c).Name;
            }
        }
    }
    
    /** Added By Shalini on Jan 31 2017
    *Auto-populate Enrollment Date field on Opportunity using Today's date, 
    *for New Class Opportunities when the stage changes to a Closed-Won Stage (Order or Active) for the first time. 
    **/

    //RecordType rec = [SELECT Id FROM RecordType WHERE Name = 'New Class Opportunities'];
    //List<RecordType> rec = SObjectQueryService.getRecTypeListBySobjTypeAndDevName(' WHERE DeveloperName','',new Set<String>{'New_Classes_Opportunities'});
    Map<String,Id> oppRecTypeMapTemp = new Map<String,Id>();
    OpportunityTrigger_Handler oTH = new OpportunityTrigger_Handler();
    Set<Id> oppRecordTypeIdSet = new Set<Id>();
    String InertnalCostJobsRTId;
    
    if( OpportunityTrigger_Handler.oppRecTypeMap != null && OpportunityTrigger_Handler.oppRecTypeMap.size() > 0 ) {
        oppRecTypeMapTemp = OpportunityTrigger_Handler.oppRecTypeMap;        
    } else {
        oTH.getRecordTypeMap();
        oppRecTypeMapTemp = OpportunityTrigger_Handler.oppRecTypeMap;
    }
    
    if( oppRecTypeMapTemp != null && oppRecTypeMapTemp.size() > 0 ) {
        for(String s : oppRecTypeMapTemp.keyset()) {
            if (s == 'Admin_Opportunities') {
                InertnalCostJobsRTId = oppRecTypeMapTemp.get(s);
            } else if (s == 'Online_Class_Opportunities' || s == 'New_Classes_Opportunities') {
                oppRecordTypeIdSet.add(oppRecTypeMapTemp.get(s));
            }
        }
    }
    
    if(trigger.isBefore ) {

        if(trigger.isInsert){
            for (Opportunity opp : trigger.new) {
                if((opp.StageName == 'Active' || opp.StageName == 'Order')){
                    opp.Enrollment_Date__c = system.Today();
                }
            }
        }
        
        if(trigger.isUpdate){
        
            for (Opportunity opp : trigger.new) {
            
                if(trigger.oldmap.get(opp.Id).StageName != opp.StageName){
                    if((opp.StageName == 'Active' || opp.StageName == 'Order')){
                        opportunityIdSet.add(opp.Id);
                        oppList.add(opp);
                    }
                }
                /*********
                    - Added By HL on Mar 19 2020
                    - Work Item : W-002921 - Time Entry for Testing Projects
                    - To prevent the manual updation of Oral Exam Date & Time field because it is updated by related event
                    ********/
                if(!EventHandler.isFromEve && opp.RecordTypeId == testOppRTId && opp.Oral_Exam__c != Trigger.oldMap.get(opp.Id).Oral_Exam__c &&
                    oppIdAndProjId.containsKey(opp.Id)){
                
                    opp.Oral_Exam__c.addError('You can\'t edit this field, please update related event if you want to update the Oral Exam Date & Time');
                }
            }
            
            if( opportunityIdSet != null && opportunityIdSet.size() > 0 ) {
                List<OpportunityHistory> opphistList = OpportunityService.getOppHistoryListByOppIdAndStage(opportunityIdSet,new Set<String>{'Active','Order'}); 
                for(OpportunityHistory opphist : opphistList ){
                    reducedIdSet.add(opphist.OpportunityId);
                }
                for (Opportunity opp : oppList) {
                    if(!reducedIdSet.contains(opp.Id)) {
                        opp.Enrollment_Date__c = system.Today();
                    }
                } 
            }                      
        }
    }
        
    if (oppIdsToDeleteCA != null && (conIdsToDeleteCA.size() > 0 || oppIdAndUserId.size() > 0)) {
        createContactRoles_Util.deleteContactAssignment(oppIdsToDeleteCA, conIdsToDeleteCA, oppIdAndUserId);
    }
    /*
    System.debug('oppIdSet : ' + oppIdSet);
    if (oppIdSet != null && oppIdSet.size() > 0) {
        createContactRoles_Util.createContactRoles(oppIdSet, true);
    }
    */
    if( langSet != null && langSet.size() > 0 ) {
        List<Overall_Past_Performance__c> overAlllist = OverAllPastPerformanceService.getOverallBylanguage(' WHERE Target_Language__r.Name ', 'Target_Language__r.Name', langSet);
        system.debug('::langSet::'+langSet);
        
        for(Overall_Past_Performance__c ocp : overAlllist) {
            langWithPastperfMap.put(ocp.Target_Language__r.Name,ocp);
        }
    }

    /**
    * Populate Delivery Account, End User Account when first entry to Billing Account is entered
    * for New Class Opportunities, Online Class Opportunities
    **/

    if(trigger.isbefore) {

        for (Opportunity op : trigger.new) {

            if ( op.RecordTypeId == InertnalCostJobsRTId  && (Trigger.isInsert)) { // Added for Internal Cost Jobs Default Account Id on Nov-18, 2016
                System_Values__c sysValueDLS = System_Values__c.getValues('DLS Account');
                if(sysValueDLS != null && sysValueDLS.Value__c != null) {
                    op.AccountId = sysValueDLS.Value__c;
                }
            }

            if(op.AccountId != null && (Trigger.isInsert || (Trigger.oldMap.get(op.Id).AccountId != op.AccountId && Trigger.oldMap.get(op.Id).AccountId == null) )) {
                if(op.Delivery_Account__c == null){
                    op.Delivery_Account__c = op.AccountId;
                }
                if(op.End_User_Account__c == null) {
                    op.End_User_Account__c = op.AccountId;
                }
            }
            if( langWithPastperfMap != null && langWithPastperfMap.size() > 0 ) {
                if((trigger.isInsert || (trigger.isUpdate && trigger.oldmap.get(op.Id).Language__c != op.Language__c)) && langWithPastperfMap.containskey(op.Language__c)) {
                    op.Institutional_Results_in_Target_Language__c = langWithPastperfMap.get(op.Language__c).Results_Institutional__c;
                    op.Relevant_training_in_the_Target_Language__c = langWithPastperfMap.get(op.Language__c).Relevant_Training__c;
                }
            }
        }        
    } 

    // Added by Sukanya Sep 7 2016
    // To create Contact Assignment with the values in Contract KO field

    List<Contact_Assignments__c> contactAssignList = new List<Contact_Assignments__c>();
    //Set<Id> oppId = new Set<Id>();
    Id conAssignRecordTypeId;

    // Added by Sukanya on November 7 2016
    // For Contact field update
    Set<Id> OppIdSetForContact = new Set<Id>();
    Set<Id> oppIdSetToCreateLTS = new Set<Id>();
    Set<Id> oppIdSetToCreateIns = new Set<Id>();
    
    // Planned days off creation - Added by sukanya on Dec 21 2017
    Map<Id,SObject> oppIdRecMap = new Map<Id,SObject>();
    Set<Id> oppIdsToUpdateCAStatus = new Set<Id>();
        
    if (trigger.isAfter && ( Trigger.isInsert || trigger.isUpdate )) {
        for ( Opportunity opp : trigger.New ) {
            // Commented by NS on June 4 2018 - Contract based CA creation automation is not needed
            /*if( Trigger.isInsert || ( trigger.isUpdate && trigger.oldmap.get(opp.Id).ContractId != opp.ContractId)) {
                if(opp.ContractId != null) {
                    oppId.add(opp.Id);
               }
            }*/

            if( Trigger.isInsert || ( trigger.isUpdate && trigger.oldmap.get(opp.Id).Language__c != opp.Language__c)) {
                
                if(opp.Language__c != null) {
                    OppIdSetForContact.add(opp.Id);
                }
            }
            
            if(Trigger.isUpdate && (Trigger.oldMap.get(opp.Id).StageName != opp.StageName || Trigger.oldMap.get(opp.Id).Start_date__c != opp.Start_Date__c || Trigger.oldMap.get(opp.Id).CloseDate != opp.CloseDate)){
                oppIdsForContFieldUpdate.add(opp.Id);
            }
            
            // When a Supervisor is assigned in Opportunity's Supervisor Field Level create a CA
            if( opp.Supervisor__c != null && ( Trigger.isInsert || ( trigger.isUpdate && trigger.oldmap.get(opp.Id).Supervisor__c != opp.Supervisor__c) ) ) {
                oppIdSetToCreateLTS.add(opp.Id);
            }

            if( opp.InstructorName__c != null && ( Trigger.isInsert || ( trigger.isUpdate && trigger.oldmap.get(opp.Id).InstructorName__c != opp.InstructorName__c) ) ) {
                oppIdSetToCreateIns.add(opp.Id);
            }

            if( opp.Student_Name__c != null && ( Trigger.isInsert || ( trigger.isUpdate && trigger.oldmap.get(opp.Id).Student_Name__c != opp.Student_Name__c ) ) ) {
                oppIdSetToCreateIns.add(opp.Id);
            }

            if( opp.Agency_Contact__c != null && ( Trigger.isInsert || ( trigger.isUpdate && trigger.oldmap.get(opp.Id).Agency_Contact__c != opp.Agency_Contact__c) ) ) {
                oppIdSetToCreateIns.add(opp.Id);
            }
            
            // For Planned days off
            if(Trigger.isInsert && opp.Start_Date__c != null && Opp.End_Date__c != null 
                && oppRecTypeMapTemp.containsKey('DLI_W_TO_Opportunities') && oppRecTypeMapTemp.get('DLI_W_TO_Opportunities') == Opp.RecordTypeId 
                && (Opp.Project_Type__c == 'AFPAK' || Opp.Project_Type__c == 'Resident LT')) {
                
                if(!oppIdRecMap.containsKey(Opp.Id)) {
                    oppIdRecMap.put(Opp.Id,Opp);
                }
            }
            
            if(opp.StageName == 'Closed Lost' && (Trigger.isInsert || Trigger.oldMap.get(opp.Id).StageName != opp.StageName)){
                oppIdsToUpdateCAStatus.add(opp.Id);
            }
        }
        
        //system.debug('::::::oppIdRecMap::::'+oppIdRecMap);
        //system.debug(':::::::oppId::::contract:::::::::::'+oppId);
        //system.debug(':::::::OppIdSetForContact:::::::::::::::'+OppIdSetForContact);
        Map<String,Id> cARecTypeMap = new Map<String,Id>();
        if(ContactAssignmentTriggerHandler.conAssignRecordTypeMap != null && ContactAssignmentTriggerHandler.conAssignRecordTypeMap.size() > 0 ) {
            cARecTypeMap = ContactAssignmentTriggerHandler.conAssignRecordTypeMap;
        } else {
            conAssignClass.getRecordTypeMap();
            cARecTypeMap = ContactAssignmentTriggerHandler.conAssignRecordTypeMap;
        }
        
        for( String s : cARecTypeMap.keyset() ) {
            if(s == 'Client_Partner') conAssignRecordTypeId = cARecTypeMap.get(s);
        }
        system.debug('::::::::conAssignRecordTypeId:::::;'+conAssignRecordTypeId);

        Set<Id> CORContIdSet = new Set<Id>();
        Set<Id> BillingContIdSet = new Set<Id>();
        // Commented by NS on June 4 2018 - Contract based CA creation automation is not needed
        /*if( oppId != null && oppId.size() > 0 ) {
            List<Opportunity> oppolist = OpportunityService.getOpportunitiesByInnerQueryOnAllInstructors('',oppId,new Set<Id>{conAssignRecordTypeId},',Contract.Primary_POC__c,Contract.Billing_Contact__c');
            for(Opportunity opp : oppolist) {
    
                //system.debug(':::::::::opp.All_Instructors__r::::::::::::'+opp.All_Instructors__r);
    
                for(Contact_Assignments__c conAss : opp.All_Instructors__r) {
                    if(conAss.Assignment_Position__c == 'COR') {
                        CORContIdSet.add(conAss.Candidate_Name__c); // Add all the COR Positioned Contact Id's
                    }
                    if(conAss.Assignment_Position__c == 'Billing Contact') {
                        BillingContIdSet.add(conAss.Candidate_Name__c); // Add all the BillContactAssignmentTriggerHandlering Contact Positioned Contact Id's
                    }
                }
    
                if(opp.Contract.Primary_POC__c != null && !CORContIdSet.contains(opp.Contract.Primary_POC__c)) {                    
                    Contact_Assignments__c conAssignment = new Contact_Assignments__c();
    
                    conAssignment.Candidate_Name__c = opp.Contract.Primary_POC__c;
                    conAssignment.Opportunity_Name__c = opp.Id;
                    conAssignment.Assignment_Position__c = 'COR';
    
                    if(opp.StageName == 'Response in-progress')
                        conAssignment.Status__c = 'Application in Progress';
                    else if(opp.StageName == 'Submitted')
                        conAssignment.Status__c = 'Submitted';
                    else if(opp.StageName == 'Awarded')
                        conAssignment.Status__c = 'Awarded';
                    else if(opp.StageName == 'Cancelled')
                        conAssignment.Status__c = 'Withdrawn';
    
                    conAssignment.Start_Date__c = opp.Start_Date__c;
                    conAssignment.End_Date__c = opp.End_Date__c;
                    conAssignment.RecordTypeId = conAssignRecordTypeId;
                    //system.debug(':::::::conAssignment:::11::::'+conAssignment);
                    contactAssignList.add(conAssignment);                    
                }
    
                // Added by sukanya sep 17 2016 for Billing contact related contact assignment create
                if(opp.Contract.Billing_Contact__c != null && !BillingContIdSet.contains(opp.Contract.Billing_Contact__c)) {
    
                    Contact_Assignments__c conAssignment = new Contact_Assignments__c();
    
                    conAssignment.Candidate_Name__c = opp.Contract.Billing_Contact__c;
                    conAssignment.Opportunity_Name__c = opp.Id;
                    conAssignment.Assignment_Position__c = 'Billing Contact';
    
                    if(opp.StageName == 'Response in-progress')
                        conAssignment.Status__c = 'Application in Progress';
                    else if(opp.StageName == 'Submitted')
                        conAssignment.Status__c = 'Submitted';
                    else if(opp.StageName == 'Awarded')
                        conAssignment.Status__c = 'Awarded';
                    else if(opp.StageName == 'Cancelled')
                        conAssignment.Status__c = 'Withdrawn';
    
                    conAssignment.Start_Date__c = opp.Start_Date__c;
                    conAssignment.End_Date__c = opp.End_Date__c;
                    conAssignment.RecordTypeId = conAssignRecordTypeId;
    
                    //system.debug(':::::::conAssignment:22::::::'+conAssignment);
                    contactAssignList.add(conAssignment);                    
                }           
            }
            system.debug(':::::::::contactAssignList:::::::'+contactAssignList);                  
        }*/
    }
    
    if(oppIdsToUpdateCAStatus.size() > 0){
        ContactAssignmentTriggerHandler.updateCAStatusOnOppClosedLost(oppIdsToUpdateCAStatus);
    }
    
    // Added by Sukanya on Nov 7 2016 for Contact Field Update
    // Calling helper class for remaining operation

    Set<Id> contactIdSet = new Set<Id>(); 
    conAssignClass.UpdateContactField(OppIdSetForContact,contactIdSet);
    if(oppIdsForContFieldUpdate.size() > 0){
        conAssignClass.updateContactMostRecentOppStatusfield(oppIdsForContFieldUpdate);
    }
    
    
    // When a Supervisor is assigned in Opportunity's Supervisor Field Level create a CA
    if( oppIdSetToCreateLTS != null && oppIdSetToCreateLTS.size() > 0 ) {
        System.debug('oppIdSetToCreateLTS :::'+oppIdSetToCreateLTS );
        List<Contact_Assignments__c> temp1 = conAssignClass.createLTSStaffConAssign(oppIdSetToCreateLTS);
        if(temp1 != null && temp1.size() > 0)
            contactAssignList.addAll(temp1);
    }

    // When a Instructor is assigned in Opportunity's Instructor Field Level create a CA
    if( oppIdSetToCreateIns != null && oppIdSetToCreateIns.size() > 0 ) {
        System.debug('oppIdSetToCreateIns :::'+oppIdSetToCreateIns );
        List<Contact_Assignments__c> temp1 = conAssignClass.createInsConAssign(oppIdSetToCreateIns);
        if(temp1 != null && temp1.size() > 0)
            contactAssignList.addAll(temp1);
    }
    
    if( contactAssignList != null && contactAssignList.size() > 0 ) {
        Insert contactAssignList;
    }
    
    // Call handler to inser new Planned days off records
    if(oppIdRecMap.keySet().size() > 0) {
        OpportunityTrigger_Handler.clonePlannedDaysOff(oppIdRecMap,'Opportunity');
    }
}