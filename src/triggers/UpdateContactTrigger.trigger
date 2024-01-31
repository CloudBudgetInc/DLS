/**
 * @description       : 
 * @author            : Dhinesh Kumar
 * @group             : 
 * @last modified on  : 03/18/2022
 * @last modified by  : Dhinesh Kumar
**/
trigger UpdateContactTrigger on Get_Feedback__c (before insert, before update, after insert, after update) {

    /*Set<Id> oppIdSet = new Set<Id>();
    Map<Id,String> OppIdSupervisorName = new Map<Id,String>();
    Map<String,Id> conNameContactId = new Map<String,Id>();
    
    if (trigger.isBefore && Trigger.isInsert) {        
        for (Get_Feedback__c GetFeed : trigger.new) {
            system.debug('::::::GetFeed:::::'+GetFeed);
            system.debug('::::::GetFeed:::::'+GetFeed.Opportunity__c);
            
            if(GetFeed.Opportunity__c != null)
                oppIdSet.add(GetFeed.Opportunity__c);
        }
        
        for(Opportunity opp : [SELECT Id,Name,Supervisor__c,Supervisor__r.Name FROM Opportunity WHERE Id IN :oppIdSet]) {
            if(!OppIdSupervisorName.containsKey(opp.Id)) {
                OppIdSupervisorName.put(opp.Id,opp.Supervisor__r.Name);
            }
        }
        
        system.debug(':::::OppIdSupervisorName::::::'+OppIdSupervisorName);
        
        for(Contact con : [SELECT Id,Name FROM Contact WHERE Name IN :OppIdSupervisorName.values()]) {
            if(!conNameContactId.containsKey(con.Name)) {
                conNameContactId.put(con.Name,con.Id);
            }
        }
        system.debug(':::::conNameContactId::::::'+conNameContactId);
        
        for (Get_Feedback__c GetFeed : trigger.new) {
           
            if(GetFeed.Opportunity__c != null) {
                if(OppIdSupervisorName.containsKey(GetFeed.Opportunity__c)) {                
                    if(conNameContactId.containsKey(OppIdSupervisorName.get(GetFeed.Opportunity__c))) {
                        GetFeed.Supervisor_Project_Manager__c = conNameContactId.get(OppIdSupervisorName.get(GetFeed.Opportunity__c));
                    }
                }
            }
            system.debug('::::::GetFeed:::::'+GetFeed);
        }
    } */  
    
    //Added by Shalini on Feb 6 2018 to update Supervisor_Project_Manager__c field from Project
    Set<Id> proIdSet = new Set<Id>();
    Map<Id,Id> proIdActiveSupervisorId = new Map<Id,Id>();
    Map<Id,Id> proIdEndedSupervisorId = new Map<Id,Id>();
    Id courseEndFbId, vrSurveyId;
    Map<Id, String> rtIdAndRTDevName = new Map<Id, String>();
    
    // Added to find the Course End Feedback Record Type Id 
    for(RecordType rt : [SELECT Id,Name,DeveloperName,SobjectType FROM RecordType WHERE SobjectType = 'Get_Feedback__c']) {
        if(rt.DeveloperName == 'Ending_Feedback') {
            courseEndFbId = rt.Id;
        }
        if(rt.DeveloperName == 'VR_Survey') {
            vrSurveyId = rt.Id;
        }
        rtIdAndRTDevName.put(rt.Id, rt.DeveloperName);
    }
        
    if (trigger.isBefore && Trigger.isInsert) {
               
        for (Get_Feedback__c GetFeed : trigger.new) {
            if(GetFeed.Project__c != null)
                proIdSet.add(GetFeed.Project__c);
        }
        
        if(proIdSet.size() > 0){
            for(Contact_Assignments__c ca : [SELECT Id,Candidate_Name__c,Project__c,Assignment_Position__c,Project__r.RecordType.DeveloperName,Status__c FROM Contact_Assignments__c WHERE Project__c IN :proIdSet AND RecordType.DeveloperName = 'Staff' AND Status__c IN ('Active','Ended') ORDER BY CreatedDate DESC]) {
                if(ca.Status__c == 'Active') {
                    
                    //Commented by NS on JUN 7 2022 - W-007488
                    /*if(!proIdActiveSupervisorId.containsKey(ca.Project__c)){
                        proIdActiveSupervisorId.put(ca.Project__c,ca.Candidate_Name__c);
                    }*/
                    
                    if(ca.Project__r.RecordType.DeveloperName != 'Admin_Projects' && ca.Assignment_Position__c == 'Project Manager') {
                        if(!proIdActiveSupervisorId.containsKey(ca.Project__c)){
                            proIdActiveSupervisorId.put(ca.Project__c,ca.Candidate_Name__c);
                        }
                    } else if(ca.Project__r.RecordType.DeveloperName == 'Admin_Projects' && ca.Assignment_Position__c == 'Manager') {
                        if(!proIdActiveSupervisorId.containsKey(ca.Project__c)){
                            proIdActiveSupervisorId.put(ca.Project__c,ca.Candidate_Name__c);
                        }
                    }  
                // Added to maintain a map for the Ended Supervisor For End of Training Survey
                } else if(ca.Status__c == 'Ended') {
                    if(!proIdEndedSupervisorId.containsKey(ca.Project__c)){
                        proIdEndedSupervisorId.put(ca.Project__c,ca.Candidate_Name__c);
                    }
                }
            }
            
            Map<Id, Acctseed__Project__c> projectIdWithRecMap = new Map<Id, Acctseed__Project__c>([SELECT Id, Language__c FROM Acctseed__Project__c WHERE Id IN :proIdSet]);
            
            for (Get_Feedback__c GetFeed : trigger.new) {
               
                if(GetFeed.Project__c != null) {
                
                    if(proIdActiveSupervisorId.containsKey(GetFeed.Project__c)){  
                        GetFeed.Supervisor_Project_Manager__c = proIdActiveSupervisorId.get(GetFeed.Project__c);                        
                    } else if(proIdEndedSupervisorId.containsKey(GetFeed.Project__c)){
                        // Added to check and map the Ended Supervisor For End of Training Survey
                        // Removed courseEndFbId == GetFeed.RecordTypeId condition on Dec 28 2022 - W-007671: Automate GetFeedBack Supervisor/Project Manager Field
                        GetFeed.Supervisor_Project_Manager__c = proIdEndedSupervisorId.get(GetFeed.Project__c);
                    } else {
                        GetFeed.Supervisor_Project_Manager__c = null;
                    }
                    
                    if(projectIdWithRecMap.containsKey(GetFeed.Project__c)){
                        GetFeed.Language_LU__c = projectIdWithRecMap.get(GetFeed.Project__c).Language__c;
                    }
                    
                    /*if(GetFeed.RecordTypeId == vrSurveyId && proIdActiveInsId.containskey(GetFeed.Project__c)) {
                        GetFeed.Instructor__c = proIdActiveInsId.get(GetFeed.Project__c);
                    }*/
                }
            }
        }
        
        /**************
            Added by HL on Apr 23 2019
            Work Item : W-001292
            To update Instructor__c field value in Get_Feedback__c from Contact Assignment
            ***************/
        
        Set<Id> projIds = new Set<Id>();
        List<Get_Feedback__c> feedBacks = new List<Get_Feedback__c >();
        Map<Id, List<Contact_Assignments__c>> projIdAndCARec = new Map<Id, List<Contact_Assignments__c>>();
        
        Id endOfTrainingRTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('Ending_Feedback').getRecordTypeId();
        
        for(Get_Feedback__c f : trigger.new){
        
            if((f.RecordTypeId == endOfTrainingRTId || f.RecordTypeId == vrSurveyId) && f.Project__c != NULL 
                && (String.isNotBlank(f.Instructor_Name__c) && !f.Instructor_Name__c.containsAny(',') 
                || String.isNotBlank(f.Other_Instructor_Name__c) && !f.Other_Instructor_Name__c.containsAny(',')
                || String.isNotBlank(f.any_other_instructor_Name__c) && !f.any_other_instructor_Name__c.containsAny(','))){
            
                feedBacks.add(f);
                projIds.add(f.Project__c);
            }
        }
        
        System.debug('projIds::>'+projIds);
        
        if(feedBacks.size() > 0){
        
            for(Contact_Assignments__c c : [
                SELECT Id, Candidate_Name__c, Candidate_Name__r.Name, Project__c 
                FROM Contact_Assignments__c
                WHERE RecordType.DeveloperName = 'Instructor' And Project__c IN :projIds AND Candidate_Name__c != NULL
            ]){
            
                if(!projIdAndCARec.containsKey(c.Project__c)){
                    projIdAndCARec.put(c.Project__c, new List<Contact_Assignments__c>());
                }
                projIdAndCARec.get(c.Project__c).add(c);
            }
            
            if(projIdAndCARec.size() > 0){
            
                for(Get_Feedback__c f : feedBacks){
                
                    if(projIdAndCARec.containsKey(f.Project__c)){
                        
                        for(Contact_Assignments__c c : projIdAndCARec.get(f.Project__c)){
                        
                            if(String.isNotBlank(f.Instructor_Name__c) && (f.Instructor_Name__c.containsIgnoreCase(c.Candidate_Name__r.Name) || c.Candidate_Name__r.Name.containsIgnoreCase(f.Instructor_Name__c))){
                            
                                f.Instructor__c = c.Candidate_Name__c;
                            }
                            
                            if(String.isNotBlank(f.Other_Instructor_Name__c) && (f.Other_Instructor_Name__c.containsIgnoreCase(c.Candidate_Name__r.Name) || c.Candidate_Name__r.Name.containsIgnoreCase(f.Other_Instructor_Name__c))){
                            
                                f.Instructor_2__c = c.Candidate_Name__c;
                            }
                            
                            if(String.isNotBlank(f.any_other_instructor_Name__c) && (f.any_other_instructor_Name__c.containsIgnoreCase(c.Candidate_Name__r.Name) || c.Candidate_Name__r.Name.containsIgnoreCase(f.any_other_instructor_Name__c))){
                            
                                f.Instructor_3__c = c.Candidate_Name__c;
                            }
                        }
                    }
                }
            }
        }
    }  
    
    // Added by HL on Apr 29 2019
    if(Trigger.isBefore && Trigger.isUpdate){
    
        Set<Id> projIds = new Set<Id>();
        Set<Id> insIds = new Set<Id>();
        List<Get_Feedback__c> feedBacks = new List<Get_Feedback__c >();
        Map<Id, List<Contact_Assignments__c>> projIdAndCARec = new Map<Id, List<Contact_Assignments__c>>();
        
        Id endOfTrainingRTId = Schema.SObjectType.Get_Feedback__c.getRecordTypeInfosByDeveloperName().get('Ending_Feedback').getRecordTypeId();
        
        for(Get_Feedback__c f : trigger.new){
        
            if(f.RecordTypeId == endOfTrainingRTId && String.isNotBlank(f.Instructor_Name__c) && !f.Instructor_Name__c.containsAny(',') && f.Project__c != NULL &&
                f.Instructor__c != NULL && f.Instructor__c != trigger.oldMap.get(f.Id).Instructor__c ){
            
                feedBacks.add(f);
                projIds.add(f.Project__c);
                insIds.add(f.Instructor__c);
            }
        }
        
        if(feedBacks.size() > 0){
        
            Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Id IN :insIds]);
            System.debug('contactMap=============='+contactMap+'contactMap SIZE========'+contactMap.size());
            
            for(Contact_Assignments__c c : [
                SELECT Id, Candidate_Name__c, Candidate_Name__r.Name, Project__c 
                FROM Contact_Assignments__c
                WHERE RecordType.DeveloperName = 'Instructor' And Project__c IN :projIds AND Candidate_Name__c IN :insIds
            ]){
            
                if(!projIdAndCARec.containsKey(c.Project__c)){
                    projIdAndCARec.put(c.Project__c, new List<Contact_Assignments__c>());
                }
                projIdAndCARec.get(c.Project__c).add(c);
            }
                        
            for(Get_Feedback__c f : feedBacks){
            
                if(contactMap.containsKey(f.Instructor__c) /*&& f.Instructor_Name__c.equalsIgnoreCase(contactMap.get(f.Instructor__c).Name)*/){
                
                    if(projIdAndCARec.size() > 0){
                        if(!projIdAndCARec.containsKey(f.Project__c)){
                            f.addError('No Instructor available under the Project for the selected Contact');
                        }
                    }else{
                         f.addError('No Instructor available under the Project for the selected Contact');
                    }
                }/*else{
                    f.addError('The Selected Contact name doesn\'t match with the \"Instructor Name\", Please verify the \"Instructor Name\"');
                }*/
            }
        }
    }
    
    if(Trigger.isAfter){
    
        List<Get_Feedback__c> gfListToSendResponseEmail = new List<Get_Feedback__c>();
        Set<Id> projIdsToSendResponseEmail = new Set<Id>();
        
        for(Get_Feedback__c gf : Trigger.new){
        
            if(!gf.Sent_Responce__c && gf.Contact__c != null && (Trigger.isInsert || (Trigger.isUpdate && gf.Sent_Responce__c != Trigger.oldMap.get(gf.Id).Sent_Responce__c))){
                
                gfListToSendResponseEmail.add(gf);
                projIdsToSendResponseEmail.add(gf.Project__c);
            }    
        }
        
        if(gfListToSendResponseEmail.size() > 0){
            GetFeedbackTrigger_Handler.sendResponseEmailToUser(gfListToSendResponseEmail, projIdsToSendResponseEmail, rtIdAndRTDevName);
        }
    }
}