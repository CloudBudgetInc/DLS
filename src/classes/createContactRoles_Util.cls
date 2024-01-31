global class createContactRoles_Util {

    global static void createContactRoles(Set<Id> oppIdSet, Boolean legacy) {
    
        Map<Id, Set<Id>> oppIdOCRContactIdSetMap = new Map<Id, Set<Id>>();
        Map<String, Id> conNameIdMap = new Map<String, Id>();
        
        List<OpportunityContactRole> oppConRoleListToInsert = new List<OpportunityContactRole>();
        List<Opportunity> oppList = new List<Opportunity>();
        
        Set<Id> alreadyExistContactIdSet = new Set<Id>();
        Set<String> conNameSetToCompare = new Set<String>();
        
        OpportunityContactRole oppConRole;
      
        System.debug('oppIdSet : ' + oppIdSet);
        System.debug('legacy : ' + legacy);
        
        // Added on Dec 14 2022
        Map<Id, List<Contact_Assignments__c>> oppIdAndConAssigns = new Map<id, List<Contact_Assignments__c>>();
        
        List<Student_Assignment__c> studentAssignList = [SELECT Id, Class_Name__c, Student_Name__c
                                                          FROM Student_Assignment__c 
                                                          WHERE Class_Name__c IN :oppIdSet 
                                                              AND Class_Name__r.RecordType.DeveloperName IN ('New_Classes_Opportunities', 'AFPAK_Classes', 'DLI_W_TO_Opportunities', 'ODNI_CLP_Opportunities','EFL_Opportunities') 
                                                              AND Class_Name__r.RecordType.isActive = TRUE];
        
        List<Contact_Assignments__c> contactAssignmentList = [SELECT Id, Candidate_Name__c, Opportunity_Name__c, Assignment_Position__c
                                                              FROM Contact_Assignments__c 
                                                              WHERE Opportunity_Name__c IN :oppIdSet 
                                                              AND Opportunity_Name__r.RecordType.DeveloperName IN ('New_Classes_Opportunities', 'AFPAK_Classes', 'DLI_W_TO_Opportunities', 'ODNI_CLP_Opportunities','EFL_Opportunities') 
                                                              AND Opportunity_Name__r.RecordType.isActive = TRUE];
                                                              
        for(Contact_Assignments__c ca : contactAssignmentList){
        
            if(!oppIdAndConAssigns.containskey(ca.Opportunity_Name__c)){
                oppIdAndConAssigns.put(ca.Opportunity_Name__c, new List<Contact_Assignments__c>());
            }   
            oppIdAndConAssigns.get(ca.Opportunity_Name__c).add(ca); 
        }
        
        List<OpportunityContactRole> oppCRList = [SELECT Id, ContactId, OpportunityId, Role
                                                  FROM OpportunityContactRole 
                                                  WHERE OpportunityId IN :oppIdSet 
                                                  AND Opportunity.RecordType.DeveloperName IN ('New_Classes_Opportunities', 'AFPAK_Classes', 'DLI_W_TO_Opportunities', 'ODNI_CLP_Opportunities','EFL_Opportunities') 
                                                  AND Opportunity.RecordType.isActive = TRUE];
        
        for (Opportunity opp : [ SELECT Id, Name, Student_Name__c, Contracting_Officer__c, Agency_Contact__c,
                                        InstructorName__c, Supervisor__c, Supervisor__r.Name, RecordTypeId,
                                        RecordType.DeveloperName, RecordType.isActive, EI_lookup__c, 
                                        X2nd_Instructor__c
                                 FROM Opportunity 
                                 WHERE ID IN :oppIdSet
                                 AND RecordType.DeveloperName IN ('New_Classes_Opportunities', 'AFPAK_Classes', 'DLI_W_TO_Opportunities', 'ODNI_CLP_Opportunities','EFL_Opportunities')
                                 AND RecordType.isActive = TRUE
                               ]) {
            
            oppList.add(opp);
            
            // Set of string to query contact which matches supervisor name
            if (String.isNotBlank(opp.Supervisor__c)) conNameSetToCompare.add(opp.Supervisor__r.Name); 
            
            if (oppCRList.size() > 0) {
                
                for (OpportunityContactRole ocr : oppCRList) {
                
                    if (oppIdOCRContactIdSetMap.get(ocr.OpportunityId) == null) {
                        
                        oppIdOCRContactIdSetMap.put(ocr.OpportunityId, new Set<Id>());    
                    }
                    oppIdOCRContactIdSetMap.get(ocr.OpportunityId).add(ocr.ContactId);
                }
                
            } // end if opp.opportunityContactRoles           
            
        } // end for
        
        System.debug('oppList : ' + oppList);
        System.debug('conNameSetToCompare : ' + conNameSetToCompare);
        System.debug('oppIdOCRContactIdSetMap : ' + oppIdOCRContactIdSetMap);
        
        if (conNameSetToCompare.size() > 0) {
        
            for (Contact con : [ SELECT Id, FirstName, LastName, Name, RecordTypeId, RecordType.DeveloperName
                                 FROM Contact
                                 WHERE RecordType.DeveloperName = 'DLS_Employee'
                                 AND Name IN :conNameSetToCompare                                  
                               ] ) {
                               
                conNameIdMap.put(con.Name, con.Id);
            }
        }
                   
        System.debug('conNameIdMap : ' + conNameIdMap);
            
        if (legacy) {
        
            for (Opportunity opp : oppList) {
                
                alreadyExistContactIdSet = oppIdOCRContactIdSetMap.containsKey(opp.Id) ? oppIdOCRContactIdSetMap.get(opp.Id) : new Set<Id>();
                System.debug('alreadyExistContactIdSet : ' + alreadyExistContactIdSet);
                
                // Creating OCR for Student_Name__c 
                if (String.isNotBlank(opp.Student_Name__c) && !alreadyExistContactIdSet.contains(opp.Student_Name__c)) {
                    
                    oppConRole = new OpportunityContactRole( OpportunityId = opp.Id, ContactId = opp.Student_Name__c, Role = 'Student');
                    alreadyExistContactIdSet.add(opp.Student_Name__c);
                    oppConRoleListToInsert.add(oppConRole);
                }
                
                // Creating OCR for Contracting_Officer__c 
                if (String.isNotBlank(opp.Contracting_Officer__c) && !alreadyExistContactIdSet.contains(opp.Contracting_Officer__c)) {
                    
                    oppConRole = new OpportunityContactRole( OpportunityId = opp.Id, ContactId = opp.Contracting_Officer__c, Role = 'COR');
                    alreadyExistContactIdSet.add(opp.Contracting_Officer__c);
                    oppConRoleListToInsert.add(oppConRole);
                }
                
                // Creating OCR for Agency_Contact__c 
                if (String.isNotBlank(opp.Agency_Contact__c) && !alreadyExistContactIdSet.contains(opp.Agency_Contact__c)) {
                    
                    oppConRole = new OpportunityContactRole( OpportunityId = opp.Id, ContactId = opp.Agency_Contact__c, Role = 'Training Officer');
                    alreadyExistContactIdSet.add(opp.Agency_Contact__c);
                    oppConRoleListToInsert.add(oppConRole);
                }
                
                // Creating OCR for InstructorName__c 
                if (String.isNotBlank(opp.InstructorName__c) && !alreadyExistContactIdSet.contains(opp.InstructorName__c)) {
                    
                    oppConRole = new OpportunityContactRole( OpportunityId = opp.Id, ContactId = opp.InstructorName__c, Role = 'Instructor');
                    alreadyExistContactIdSet.add(opp.InstructorName__c);
                    oppConRoleListToInsert.add(oppConRole);
                }
                
                // Creating OCR for supervisor 
                if (opp.Supervisor__c != null && conNameIdMap != null && conNameIdMap.get(opp.Supervisor__r.Name) != null && !alreadyExistContactIdSet.contains(conNameIdMap.get(opp.Supervisor__r.Name))) {
                
                    oppConRole = new OpportunityContactRole( OpportunityId = opp.Id, ContactId = conNameIdMap.get(opp.Supervisor__r.Name), Role = 'LTS');
                    alreadyExistContactIdSet.add(conNameIdMap.get(opp.Supervisor__r.Name));
                    oppConRoleListToInsert.add(oppConRole);
                }  
                
                // Creating OCR for EI 
                if (String.isNotBlank(opp.EI_lookup__c) && !alreadyExistContactIdSet.contains(opp.EI_lookup__c)) {
                    
                    oppConRole = new OpportunityContactRole( OpportunityId = opp.Id, ContactId = opp.EI_lookup__c, Role = 'Instructor');
                    alreadyExistContactIdSet.add(opp.EI_lookup__c);
                    oppConRoleListToInsert.add(oppConRole);
                }
                
                // Creating OCR for Instructor 2 
                if (opp.X2nd_Instructor__c != null && !alreadyExistContactIdSet.contains(opp.X2nd_Instructor__c)) {
                
                    oppConRole = new OpportunityContactRole( OpportunityId = opp.Id, ContactId = opp.X2nd_Instructor__c, Role = 'Instructor');
                    alreadyExistContactIdSet.add(conNameIdMap.get(opp.X2nd_Instructor__c));
                    oppConRoleListToInsert.add(oppConRole);
                }                
                
            } // end for oppList            
            
        } else {
        
            for (Opportunity opp : oppList) {
                
                alreadyExistContactIdSet = oppIdOCRContactIdSetMap.containsKey(opp.Id) ? oppIdOCRContactIdSetMap.get(opp.Id) : new Set<Id>();
                System.debug('alreadyExistContactIdSet : ' + alreadyExistContactIdSet);
                
                for (Contact_Assignments__c ca : oppIdAndConAssigns.get(opp.Id)) {
                
                    if (String.isNotBlank(ca.Candidate_Name__c) && !alreadyExistContactIdSet.contains(ca.Candidate_Name__c)) {
                    
                        oppConRole = new OpportunityContactRole( OpportunityId = opp.Id, ContactId = ca.Candidate_Name__c, Role = ca.Assignment_Position__c);
                        alreadyExistContactIdSet.add(ca.Candidate_Name__c);
                        oppConRoleListToInsert.add(oppConRole);
                    }    
                    
                } // end for contact assignment
                
                for (Student_Assignment__c sa : studentAssignList) {
                
                    if (String.isNotBlank(sa.Student_Name__c) && !alreadyExistContactIdSet.contains(sa.Student_Name__c)) {
                    
                        oppConRole = new OpportunityContactRole( OpportunityId = opp.Id, ContactId = sa.Student_Name__c, Role = 'Student');
                        alreadyExistContactIdSet.add(sa.Student_Name__c);
                        oppConRoleListToInsert.add(oppConRole);
                    }    
                    
                } // end for student assignment                
                
            } // end for oppList
        
        } // end else
        
        System.debug('oppConRoleListToInsert : ' + oppConRoleListToInsert);
        
        if (oppConRoleListToInsert != null && oppConRoleListToInsert.size() > 0) {
            
            insert oppConRoleListToInsert;
        }
        
    } // end method createContactRoles
    
    /********
        - Added on Nov 22 2022
        - W-007633  Urgent: Contact Roles created for wrong Contacts
        *********/
    global static void deleteContactRoles(Set<Id> oppIds, Set<Id> conIds){
        
        /*
        Map<Id, Id> userIdAndConId = new Map<Id, Id>();
        
        if(oppIdAndUserId != null && oppIdAndUserId.size() > 0){
               
            NewClassAnnouncementController.addStaffRecordTypeFilter = true;
            Set<Id> userIds = new Set<Id>();
            userIds.addAll(oppIdAndUserId.values());
            
            userIdAndConId = PlannedDaysOffHandler.getUserRelatedContacts(userIds);
        }
        */
        
        List<OpportunityContactRole> deleteOCRList = [SELECT Id FROM OpportunityContactRole WHERE OpportunityId IN : oppIds AND ContactId IN : conIds];
        System.debug(':::deleteOCRList::'+deleteOCRList);
        
        if(deleteOCRList.size() > 0){
            
            delete deleteOCRList;
        }
    }
    
    global static void deleteContactAssignment(Set<Id> oppIds, Set<Id> conIds, Map<Id, Id> oppIdAndUserId){
    
        Map<Id, Id> userIdAndConId = new Map<Id, Id>();
        
        if(oppIdAndUserId != null && oppIdAndUserId.size() > 0){
               
            NewClassAnnouncementController.addStaffRecordTypeFilter = true;
            Set<Id> userIds = new Set<Id>();
            userIds.addAll(oppIdAndUserId.values());
            
            userIdAndConId = PlannedDaysOffHandler.getUserRelatedContacts(userIds);
        }
        
        List<Contact_Assignments__c> conAssigns = [SELECT Id, Name FROM Contact_Assignments__c WHERE Opportunity_Name__c IN :oppIds AND (Candidate_Name__c IN : conIds OR Candidate_Name__c IN : userIdAndConId.values())];
        System.debug(':::conAssigns::'+conAssigns);
        
        if(conAssigns.size() > 0){
            
            delete conAssigns;
        }
    }
}