/*****************************************************************
- Batch to update the existing records values
- To populate Entered On Time, Entered Late, Submitted On time, Submitted Late for all TCL & TCD - Updated by Dhinesh on March 22 2023

*****************************************************************/

global class ExistingRecords_UpdationBatch implements Database.batchable<Sobject>,Database.Stateful{
    
    public static Set<String> positions = new Set<String>{'Instructor', 'EI', 'Substitute Instructor', 'Tester', 'Examiner', 'Translator', 'Developer', 'Editor', 'Coordinator', 'DTP / Formatting'};
    public static Set<String> statusSet = new Set<String>{'Active', 'Ended', 'On Hold'};
    
    global Database.QueryLocator start(Database.BatchableContext BC){
                
        String conQuery = 'SELECT Id, Name FROM Contact WHERE Id IN (SELECT Candidate_Name__c FROM Contact_Assignments__c WHERE RecordType.DeveloperName = \'Instructor\' AND Assignment_Position__c IN : positions AND Project__c != null AND Status__c IN : statusSet) AND Id = \'00360000014OXEhAAO\'';
        if(Test.isRunningTest()){
            conQuery += ' LIMIT 1';
        }
        return Database.getQueryLocator(conQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> contacts){
    
        System.debug('::::contacts::::'+contacts.size());
        
        if(contacts.size() > 0){
            
            Set<String> otherRTNames = new Set<String>{'Testing_Projects', 'Translation_Projects', 'CD_Projects'};
            
            Id profWorkExpRTId = Schema.SObjectType.Experience__c.getRecordTypeInfosByDeveloperName().get('Professional_Work_Experience').getRecordTypeId();
            Map<String, Contact_Assignments__c> conIdPosAndCA = new Map<String, Contact_Assignments__c>();
            Map<String, Experience__c> conIdServiceAndExp = new Map<String, Experience__c>();
            
            Map<String, Contact_Assignments__c> conIdPosAndCA_Active = new Map<String, Contact_Assignments__c>();
            Map<String, Contact_Assignments__c> conIdPosAndCA_OnHold = new Map<String, Contact_Assignments__c>();
            Map<String, Contact_Assignments__c> conIdPosAndCA_Ended = new Map<String, Contact_Assignments__c>();
            List<Experience__c> upsertExpRecs = new List<Experience__c>();
            
            for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c, Assignment_Position__c, Status__c, Start_Date__c, End_Date__c, Oral_Exam_Date_Time__c, Project__r.On_Hold_Date__c, Project__r.Oral_Exam_Date_Time__c,
                                                    Project__r.Recordtype.DeveloperName, Project__r.Start_Date__c, Project__r.End_Date__c
                                                FROM Contact_Assignments__c 
                                                WHERE Candidate_Name__c IN : contacts AND RecordType.DeveloperName = 'Instructor' AND Assignment_Position__c IN : positions AND Project__c != null AND Status__c IN : statusSet ORDER BY Start_Date__c ASC]){
                
                String pos;
                
                if(!otherRTNames.contains(ca.Project__r.RecordType.DeveloperName) && (ca.Assignment_Position__c == 'Instructor' || ca.Assignment_Position__c == 'EI' || ca.Assignment_Position__c == 'Substitute Instructor')){
                    pos = 'Language Training';
                }else if(ca.Project__r.RecordType.DeveloperName == 'Testing_Projects' || ca.Assignment_Position__c == 'Tester' || ca.Assignment_Position__c == 'Examiner'){
                    pos = 'Testing';
                }else if(ca.Project__r.RecordType.DeveloperName == 'Translation_Projects' && (ca.Assignment_Position__c == 'Translator' || ca.Assignment_Position__c == 'Editor' || ca.Assignment_Position__c == 'DTP / Formatting')){
                    pos = 'Translation';
                }else if(ca.Project__r.RecordType.DeveloperName == 'CD_Projects' && (ca.Assignment_Position__c == 'Developer' || ca.Assignment_Position__c == 'Editor' || ca.Assignment_Position__c == 'Coordinator')){
                    pos = 'Curriculum Development';
                }
                // Service not populated issue fix
                if(String.isNotBlank(pos)){
                
                    String conIdAndPos = ca.Candidate_Name__c + '-' + pos;
                    
                    if(!conIdPosAndCA.containsKey(conIdAndPos)){
                        conIdPosAndCA.put(conIdAndPos, ca);
                    }
                                    
                    if(ca.Status__c == 'Active'){
                        conIdPosAndCA_Active.put(conIdAndPos, ca);
                    }
                    if(ca.Status__c == 'Ended'){
                        conIdPosAndCA_Ended.put(conIdAndPos, ca);
                    }
                    if(ca.Status__c == 'On Hold'){
                        conIdPosAndCA_OnHold.put(conIdAndPos, ca);
                    }
                }
            }
            System.debug('::::conIdPosAndCA::::'+conIdPosAndCA.size());
            System.debug('::::conIdPosAndCA_Active::::'+conIdPosAndCA_Active);
            System.debug('::::conIdPosAndCA_Ended::::'+conIdPosAndCA_Ended);
            System.debug('::::conIdPosAndCA_OnHold::::'+conIdPosAndCA_OnHold);
            
            for(Experience__c exp : [SELECT Id,Contact__c,Start_Date__C,End_Date__c,Services__c,Role_Title__c,Intensive_Proficiency_Oriented_Experienc__c,RecordTypeId,Name_of_Company__c FROM Experience__c WHERE Contact__c IN: contacts AND (Name_of_Company__c LIKE '%DLS%' OR Name_of_Company__c LIKE '%Diplomatic Language Services%') AND RecordTypeId = : profWorkExpRTId AND Services__c != '']){
                
                for(String str : exp.Services__c.split(';')){
                
                    String service = '';
                    if(str == 'LT'){
                        service = 'Language Training';
                    }else if(str == 'CD'){
                        service = 'Curriculum Development';
                    }else{
                        service = str;
                    }
                    if(!conIdServiceAndExp.containskey(exp.Contact__c + '-' + service)){
                        conIdServiceAndExp.put(exp.Contact__c + '-' + service, exp);
                    }
                }
            }
            System.debug('::::conIdServiceAndExp::::'+conIdServiceAndExp);
            
            for(String conIdPos : conIdPosAndCA.keySet()){
                
                Id conId = Id.valueOf(conIdPos.split('-')[0]);
                String position = conIdPos.split('-')[1];  
                Contact_Assignments__c ca = conIdPosAndCA.get(conIdPos);
                Date endDateVal;
                
                System.debug(':::conIdPos:::'+conIdPos);
                
                if(!conIdServiceAndExp.containsKey(conIdPos)){
                    
                    Experience__c exp = new Experience__c();
                    exp.Contact__c = conId;
                    exp.Name_of_Company__c = 'DLS';
                    exp.RecordTypeId = profWorkExpRTId;
                    
                    Date startDateVal;
                    
                    if(position != 'Testing'){
                        startDateVal = ca.Start_Date__c != null ? ca.Start_Date__c : ca.Project__r.Start_Date__c;
                    }else{
                        
                        if(ca.Project__r.RecordType.DeveloperName == 'Testing_Projects'){
                            if(ca.Oral_Exam_Date_Time__c != null){
                                startDateVal = Date.newInstance(ca.Oral_Exam_Date_Time__c.year(), ca.Oral_Exam_Date_Time__c.month(), ca.Oral_Exam_Date_Time__c.day());
                            }else if(ca.Project__r.Oral_Exam_Date_Time__c != null){
                                startDateVal = Date.newInstance(ca.Project__r.Oral_Exam_Date_Time__c.year(), ca.Project__r.Oral_Exam_Date_Time__c.month(), ca.Project__r.Oral_Exam_Date_Time__c.day());
                            }else if(ca.Start_Date__c != null || ca.Project__r.Start_Date__c != null){
                                startDateVal = ca.Start_Date__c != null ? ca.Start_Date__c : ca.Project__r.Start_Date__c;  
                            }
                        }else{    
                            // Tester CA under non-testing project
                            startDateVal = ca.Start_Date__c != null ? ca.Start_Date__c : ca.Project__r.Start_Date__c;
                        }
                    }
                    
                    exp.Start_Date__c = startDateVal; // 1'st Contact Assignment's Start Date
                    exp.Intensive_Proficiency_Oriented_Experienc__c = true;
                    if(position == 'Language Training'){
                        exp.Services__c = 'Language Training';
                        exp.Role_Title__c = 'Language Instructor';
                    }else if (position == 'Testing'){
                        exp.Services__c = 'Testing';
                        exp.Role_Title__c = 'Tester';
                    }else if (position == 'Translation'){
                        exp.Services__c = 'Translation';
                        exp.Role_Title__c = 'Translator';
                    }else if(position == 'Curriculum Development'){
                        exp.Services__c = 'Curriculum Development';
                        exp.Role_Title__c = 'Curriculum Developer';    
                    }
                                            
                    if(!conIdPosAndCA_Active.containsKey(conIdPos)){
                    
                        if(conIdPosAndCA_Ended.containsKey(conIdPos) && conIdPosAndCA_OnHold.containsKey(conIdPos)){
                            
                            Contact_Assignments__c caRec_End = conIdPosAndCA_Ended.get(conIdPos);
                            Contact_Assignments__c caRec_OnHold = conIdPosAndCA_OnHold.get(conIdPos);
                            
                            if(ca.Project__r.RecordType.DeveloperName != 'Testing_Projects'){
                                
                                Date ca_EndDate = caRec_End.End_Date__c != null ? caRec_End.End_Date__c : caRec_End.Project__r.End_Date__c;
                                // Some of the projects dosn't have on hold date value
                                Date onHoldDate = caRec_OnHold.Project__r.On_Hold_Date__c != null ? caRec_OnHold.Project__r.On_Hold_Date__c : caRec_OnHold.End_Date__c;
                                
                                endDateVal = (ca_EndDate != null && ca_EndDate > onHoldDate) ? ca_EndDate : onHoldDate;
                                
                            }else if(ca.Project__r.RecordType.DeveloperName == 'Testing_Projects'){
                                
                                Date ca_OralDate;
                                if(caRec_End.Oral_Exam_Date_Time__c != null){
                                    ca_OralDate = Date.newInstance(caRec_End.Oral_Exam_Date_Time__c.year(), caRec_End.Oral_Exam_Date_Time__c.month(), caRec_End.Oral_Exam_Date_Time__c.day());  
                                }else if(caRec_End.Project__r.Oral_Exam_Date_Time__c != null){
                                    ca_OralDate = Date.newInstance(caRec_End.Project__r.Oral_Exam_Date_Time__c.year(), caRec_End.Project__r.Oral_Exam_Date_Time__c.month(), caRec_End.Project__r.Oral_Exam_Date_Time__c.day());
                                }else if(caRec_End.End_Date__c != null || caRec_End.Project__r.End_Date__c != null){
                                    ca_OralDate = caRec_End.End_Date__c != null ? caRec_End.End_Date__c : caRec_End.Project__r.End_Date__c;
                                }
                                Date onHoldDate = caRec_OnHold.Project__r.On_Hold_Date__c != null ? caRec_OnHold.Project__r.On_Hold_Date__c : caRec_OnHold.End_Date__c;
                                
                                endDateVal = (ca_OralDate != null && ca_OralDate > onHoldDate) ? ca_OralDate : onHoldDate;
                            }
                        } 
                        
                        if(conIdPosAndCA_Ended.containsKey(conIdPos) && !conIdPosAndCA_OnHold.containsKey(conIdPos)) {
                            
                            Contact_Assignments__c caRec_End = conIdPosAndCA_Ended.get(conIdPos);
                            
                            if(ca.Project__r.RecordType.DeveloperName != 'Testing_Projects'){
                            
                                endDateVal = caRec_End.End_Date__c != null ? caRec_End.End_Date__c : caRec_End.Project__r.End_Date__c;
                            }else if(ca.Project__r.RecordType.DeveloperName == 'Testing_Projects'){
                            
                                Date ca_OralDate;
                                if(caRec_End.Oral_Exam_Date_Time__c != null){
                                    ca_OralDate = Date.newInstance(caRec_End.Oral_Exam_Date_Time__c.year(), caRec_End.Oral_Exam_Date_Time__c.month(), caRec_End.Oral_Exam_Date_Time__c.day());  
                                }else if(caRec_End.Project__r.Oral_Exam_Date_Time__c != null){
                                    ca_OralDate = Date.newInstance(caRec_End.Project__r.Oral_Exam_Date_Time__c.year(), caRec_End.Project__r.Oral_Exam_Date_Time__c.month(), caRec_End.Project__r.Oral_Exam_Date_Time__c.day());
                                }else if(caRec_End.End_Date__c != null || caRec_End.Project__r.End_Date__c != null){
                                    ca_OralDate = caRec_End.End_Date__c != null ? caRec_End.End_Date__c : caRec_End.Project__r.End_Date__c;
                                }
                                endDateVal = ca_OralDate;
                            }
                        }
                        if(!conIdPosAndCA_Ended.containsKey(conIdPos) && conIdPosAndCA_OnHold.containsKey(conIdPos)){
                            
                            endDateVal = conIdPosAndCA_OnHold.get(conIdPos).Project__r.On_Hold_Date__c != null ? conIdPosAndCA_OnHold.get(conIdPos).Project__r.On_Hold_Date__c : conIdPosAndCA_OnHold.get(conIdPos).End_Date__c;
                        }
                        if(endDateVal != null){
                            
                            exp.End_Date__c = endDateVal;
                        }
                    }
                    System.debug('::exp::::'+exp);
                    upsertExpRecs.add(exp);    
                }else{
                    
                    Experience__c exp = conIdServiceAndExp.get(conIdPos);    
                    System.debug('::exp::UPDATE::'+exp);
                    
                    Experience__c newExp = exp.clone(false, true, false, false);
                    
                    Experience__c updateExp = new Experience__c();
                    updateExp.Id = exp.Id;
                    
                    String strPickListValue = exp.Services__c;
                    Set<String> picklistValuesSet = new Set<String>(strPickListValue.split(';'));
                            
                    if(picklistValuesSet.size() > 1){
                    
                        String strValueToRemove = position;
                        picklistValuesSet.remove(strValueToRemove);
                        
                        String serviceStr = String.join(new List<String>(picklistValuesSet),';');
                        
                        newExp.Services__c = position;
                        
                        // Assign remaining services to actual exp
                        exp.Services__c = serviceStr;
                        
                        updateExp.Services__c = serviceStr;
                        System.debug('::updateExp:::'+updateExp);
                        upsertExpRecs.add(updateExp);
                    }else{
                        newExp.Id = exp.Id;
                    }
                    if(conIdPosAndCA_Active.containsKey(conIdPos) && exp.End_Date__c != null){
                        
                        newExp.End_Date__c = null;
                        upsertExpRecs.add(newExp); 
                    }else if(!conIdPosAndCA_Active.containsKey(conIdPos)){
                        
                        if(conIdPosAndCA_Ended.containsKey(conIdPos) && conIdPosAndCA_OnHold.containsKey(conIdPos)){
                            
                            System.debug('::BOTH::::');
                            Contact_Assignments__c caRec_End = conIdPosAndCA_Ended.get(conIdPos);
                            Contact_Assignments__c caRec_OnHold = conIdPosAndCA_OnHold.get(conIdPos);
                            
                            if(ca.Project__r.RecordType.DeveloperName != 'Testing_Projects'){
                                
                                Date ca_EndDate = caRec_End.End_Date__c != null ? caRec_End.End_Date__c : caRec_End.Project__r.End_Date__c;
                                // Some of the projects dosn't have on hold date value
                                Date onHoldDate = caRec_OnHold.Project__r.On_Hold_Date__c != null ? caRec_OnHold.Project__r.On_Hold_Date__c : caRec_OnHold.End_Date__c;
                                
                                endDateVal = (ca_EndDate != null && ca_EndDate > onHoldDate) ? ca_EndDate : onHoldDate;
                                
                            }
                        }     
                        if(conIdPosAndCA_Ended.containsKey(conIdPos) && !conIdPosAndCA_OnHold.containsKey(conIdPos)){
                            
                            System.debug('::ENDED::::');
                            Contact_Assignments__c caRec_End = conIdPosAndCA_Ended.get(conIdPos);
                            
                            if(ca.Project__r.RecordType.DeveloperName != 'Testing_Projects'){
                            
                                endDateVal = caRec_End.End_Date__c != null ? caRec_End.End_Date__c : caRec_End.Project__r.End_Date__c;
                            }
                        }
                        if(!conIdPosAndCA_Ended.containsKey(conIdPos) && conIdPosAndCA_OnHold.containsKey(conIdPos)){
                            System.debug('::ON HOLD::::');
                            endDateVal = conIdPosAndCA_OnHold.get(conIdPos).Project__r.On_Hold_Date__c != null ? conIdPosAndCA_OnHold.get(conIdPos).Project__r.On_Hold_Date__c : conIdPosAndCA_OnHold.get(conIdPos).End_Date__c;
                        }
                        
                        if(endDateVal != null && (exp.End_Date__c == null || endDateVal != exp.End_Date__c)){
                            
                            newExp.End_Date__c = endDateVal;
                            System.debug('::newExp:::'+newExp);
                            upsertExpRecs.add(newExp); 
                        }                            
                    }
                }
            }
            System.debug(':::upsertExpRecs::size::'+upsertExpRecs.size());
            System.debug(':::upsertExpRecs:::'+upsertExpRecs);
            if(!upsertExpRecs.isEmpty()){
               
               List<Experience__c> allExpRecs = new List<Experience__c>();
               List<Experience__c> createExpRecs = new List<Experience__c>();
               Map<Id, Experience__c> updateExpRecs = new Map<Id, Experience__c>();
               
                for (Integer i = 0; i < upsertExpRecs.size(); i++){
                    if (upsertExpRecs[i].Id == null){
                        createExpRecs.add(upsertExpRecs[i]);
                    }else{
                        updateExpRecs.put(upsertExpRecs[i].Id, upsertExpRecs[i]);    
                    }
                }
                if(createExpRecs.size() > 0){
                    allExpRecs.addAll(createExpRecs);
                }
                if(updateExpRecs.size() > 0){
                    allExpRecs.addAll(updateExpRecs.values());
                }
                
                System.debug(':::allExpRecs::size::'+allExpRecs.size());
                System.debug(':::allExpRecs:::'+allExpRecs);
                //upsert allExpRecs;
            }
        }    
    }
    
    global void finish(Database.BatchableContext BC){
       
    }
}