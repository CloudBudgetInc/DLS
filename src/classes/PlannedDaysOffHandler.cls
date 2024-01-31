/****************************************************************************
- For Planned Days off related Approval submission, Request record creation & Contact related user population
- Created by NS on July 3 2018
*******************************************************************************/
public class PlannedDaysOffHandler {
    
    public static Map<Id, Events__c> updateEveRecsMap = new Map<Id, Events__c>();
    public static Map<Id, Set<Date>> projIdAndCancellationDates_Map = new Map<Id, Set<Date>>();
    
    // To populate the Contact related user values
    public static Map<Id,Id> getContactRelatedUsers(Set<Id> contactIds){
        Set<String> firstnameSet = new Set<String>();
        Set<String> midnameSet = new Set<String>();
        Set<String> lastnameSet = new Set<String>();
        Map<String, Id> nameMap = new Map<String, Id>();
        Map<Id,Id> conIdUsrId = new Map<Id,Id>();
        
        List<Contact> contactRecords = [SELECT Id,FirstName,MiddleName,LastName FROM Contact WHERE Id IN :contactIds];
        
        for(Contact con : contactRecords){
            firstnameSet.add(con.FirstName);  
            midnameSet.add(con.MiddleName);
            lastnameSet.add(con.LastName);     
        }
        
        if(!firstnameSet.isEmpty() || !midnameSet.isEmpty() || !lastnameSet.isEmpty()) {
            for(User usr : [SELECT Id,FirstName,MiddleName,LastName FROM User WHERE (FirstName IN :firstnameSet OR LastName IN :lastnameSet OR MiddleName IN :midnameSet) AND IsActive = True ]){
                        
                if(usr.FirstName != null || usr.LastName != null || usr.MiddleName != null){
                    String usrname = usr.FirstName+'--'+usr.MiddleName+'--'+usr.LastName;
                    if(!nameMap.containsKey(usrname)){
                        nameMap.put(usrname,usr.Id);
                    }
                }
            }
        }
        
        for(Contact con : contactRecords){
            if(con.FirstName != null || con.LastName != null || con.MiddleName != null){
                String conName = con.FirstName+'--'+con.MiddleName+'--'+con.LastName;
                if(nameMap.containsKey(conName) && nameMap.get(conName) != null){
                    conIdUsrId.put(con.Id,nameMap.get(conName));
                }
            }
        }
        
        system.debug(':::::::conIdUsrId::::'+conIdUsrId);
        
        return conIdUsrId;
    }
    
    // To create actual planned days off records after the parent record approved
    // Added by NS on July 9 2018
    public void createActualPlannedDaysOff(Set<Id> requestOffIds){
        
        system.debug('::::::::::::requestOffIds::::'+requestOffIds);
        
        Map<String,Id> rtNameRTId = new Map<String,Id>();
        List<Planned_Days_Off__c> newOffRecords = new List<Planned_Days_Off__c>();
        //Map<String,Integer> weekDayValues = new Map<String,Integer>{'Monday' => 0,'Tuesday' => 1,'Wednesday' => 2,'Thursday' => 3,'Friday' => 4,'Saturday' => 5,'Sunday' => 6};
        
        Set<Id> alreadtChildPDOExist = new Set<Id>();
        
        for(RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Planned_Days_Off__c']){
            if(!rtNameRTId.containsKey(rt.DeveloperName))
                rtNameRTId.put(rt.DeveloperName,rt.Id);
        } 
        
        //qry parent planned days off related child - to avoid duplicate child pdo creation
        for(Planned_Days_Off__c pdo : [SELECT Id,Name,Parent_Planned_Day_Off__c FROM Planned_Days_Off__c WHERE Parent_Planned_Day_Off__c IN :requestOffIds]){
            
            if(!alreadtChildPDOExist.contains(pdo.Parent_Planned_Day_Off__c)){
                alreadtChildPDOExist.add(pdo.Parent_Planned_Day_Off__c);    
            }
        }
        
        
        for(Planned_Days_Off__c off : [SELECT Id,Name,Status__c,Date__c,From_Date__c,Project__c,All_Projects__c,
                                            To_Date__c,Description__c,Type__c,Leave_Type__c,Contact__c,User__c, Approver_Name__c
                                        FROM Planned_Days_Off__c 
                                        WHERE Id IN :requestOffIds AND Id NOT IN :alreadtChildPDOExist AND Status__c = 'Approved']) {
            
            if(off.From_Date__c != null && off.To_Date__c == null) {
                Planned_Days_Off__c newOff = generateOffRecords(off,rtNameRTId,null);
                newOffRecords.add(newOff);
            }else if(off.From_Date__c != null && off.To_Date__c != null){
                Set<Date> dates = new Set<Date>();
                
                while(off.From_Date__c <= off.To_Date__c){
                    //W-007800 - PDO Request Record Child Creation Issue
                    //  String dayOfWeek = DateTime.newInstance(off.From_Date__c.year(),off.From_Date__c.month(),off.From_Date__c.day()).format('EEEE');
                    // if(weekDayValues.containsKey(dayOfWeek) && weekDayValues.get(dayOfWeek) != 5 && weekDayValues.get(dayOfWeek) != 6) {
                    dates.add(off.From_Date__c);
                    // }
                    off.From_Date__c = off.From_Date__c.addDays(1);
                }
                
                if(dates.size() > 0){
                    for(Date dt : dates){
                        Planned_Days_Off__c newOff = generateOffRecords(off,rtNameRTId,dt);
                        newOffRecords.add(newOff);
                    }
                }
            }
        }
        
        system.debug('::::::::newOffRecords::::::'+newOffRecords);
        if(newOffRecords.size() > 0){
            insert newOffRecords;
        }
    
    }
    
    public Planned_Days_Off__c generateOffRecords(Planned_Days_Off__c off,Map<String,Id> rtNameRTId,Date offDate) {
        
        Planned_Days_Off__c newOff = new Planned_Days_Off__c();
        
        if(offDate == null) {
            newOff.Date__c = off.From_Date__c;
        } else if(offDate != null) {
            newOff.Date__c = offDate;
        }
            
        newOff.Description__c = off.Description__c;
        newOff.Type__c = off.Type__c;
        newOff.Leave_Type__c = off.Leave_Type__c;
        newOff.Contact__c = off.Contact__c;
        newOff.User__c = off.User__c;
        newOff.Status__c = 'Approved';
        newOff.Parent_Planned_Day_Off__c = off.Id;
        newOff.Project__c = off.Project__c;
        newOff.All_Projects__c = off.All_Projects__c;
        newOff.Approver_Name__c = off.Approver_Name__c;
        
        if(off.Type__c == 'Staff') {
            newOff.RecordTypeId = rtNameRTId.get('Staff_Planned_Days_Off');
        } else if(off.Type__c == 'Student') {
            newOff.RecordTypeId = rtNameRTId.get('Student_Planned_Days_Off');
        } else if(off.Type__c == 'Instructor') {
            newOff.RecordTypeId = rtNameRTId.get('Instructor_Planned_Days_Off');
        }
        
        return newOff;
        
    }
    
    // Qry PDO related all RTs
    public Map<Id,String> getPlannedOffRT(){
        
        Map<Id,String> rtIdName = new Map<Id,String>();
        for(RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Planned_Days_Off__c']){
            rtIdName.put(rt.Id,rt.DeveloperName);
        }
        
        return rtIdName;
    }

    // To populate the user related Contact values
    // Added by HL - Mar 25, 2019
    
    public static Map<Id,Id> getUserRelatedContacts(Set<Id> userIds){
        Set<String> firstnameSet = new Set<String>();
        Set<String> midnameSet = new Set<String>();
        Set<String> lastnameSet = new Set<String>();
        Map<String, Id> nameMap = new Map<String, Id>();
        Map<Id,Id> usrIdConId = new Map<Id,Id>();
        
        List<User> userRecords = [SELECT Id,FirstName,MiddleName,LastName FROM User WHERE Id IN :userIds AND IsActive = TRUE];
        
        for(User u : userRecords){
            firstnameSet.add(u.FirstName);  
            midnameSet.add(u.MiddleName);
            lastnameSet.add(u.LastName);     
        }
        
        if(!firstnameSet.isEmpty() || !midnameSet.isEmpty() || !lastnameSet.isEmpty()) {
            String qryStr = 'SELECT Id,FirstName,MiddleName,LastName FROM Contact WHERE (FirstName LIKE :firstnameSet AND LastName LIKE :lastnameSet AND MiddleName LIKE :midnameSet) AND Email != NULL';
            if(NewClassAnnouncementController.addStaffRecordTypeFilter){
                qryStr += ' AND RecordType.DeveloperName = \'DLS_Employee\'';
            }
            for(Contact con : Database.query(qryStr)){
                        
                if(con.FirstName != null || con.LastName != null || con.MiddleName != null){
                    String conName = con.FirstName+'--'+con.MiddleName+'--'+con.LastName;
                    if(!nameMap.containsKey(conName)){
                        nameMap.put(conName,con.Id);
                    }
                }
            }
        }
        
        for(USer u : userRecords){
            if(u.FirstName != null || u.LastName != null || u.MiddleName != null){
                String userName = u.FirstName+'--'+u.MiddleName+'--'+u.LastName;
                if(nameMap.containsKey(userName) && nameMap.get(userName) != null){
                    usrIdConId.put(u.Id,nameMap.get(userName));
                }
            }
        }
        
        system.debug('usrIdConId============='+usrIdConId);
        
        return usrIdConId;
    }
    
    /**************
        - Added by HL on Sep 10 2019
        - Instructor & Student Planned Days Off
        - Send an email notification to instructor / student Upon LTS approval
        **************/
    public void emailNotificationToInsStd(Set<Id> pdoIds){
    
        System.debug(':::pdoIds::::'+pdoIds);
        
        if(pdoIds != NULL && pdoIds.size() > 0){
        
            Set<Id> allContactIds = new Set<Id>();            
            Set<Id> instructorIds = new Set<Id>();
            Set<Id> studentIds = new Set<Id>();
            
            List<Planned_Days_Off__c> insRequest = new List<Planned_Days_Off__c>();
            List<Planned_Days_Off__c> stdRequest = new List<Planned_Days_Off__c>();
            
            Set<Id> insProjIds = new Set<Id>();
            Map<Id, List<Planned_Days_Off__c>> stdIdAndPDORequest = new Map<Id, List<Planned_Days_Off__c>>();
            
            Set<Id> stdProjIds = new Set<Id>();
            //Map<Id, List<Planned_Days_Off__c>> insIdAndPDORequest = new Map<Id, List<Planned_Days_Off__c>>();
            
            // Added on June 01 2022
            // W-007484: Plan Days off Auto Email Process Issue
            Set<Date> fromDates = new Set<Date>();
            Set<Date> toDates = new Set<Date>();
            
            Map<Id, Set<Date>> insIdAndEventDates = new Map<Id, Set<Date>>();
            Map<Id, List<Planned_Days_Off__c>> insIdAndPDORequest = new Map<Id, List<Planned_Days_Off__c>>();
            
            for(Planned_Days_Off__c p : [SELECT Id, Contact__c, Contact__r.RecordType.DeveloperName, Date__c, Project__c, 
                From_Date__c, To_Date__c, Type__c, All_Projects__c
                FROM Planned_Days_Off__c
                WHERE Id IN : pdoIds AND Contact__c != NULL
            ]){
                                
                if(p.Project__c == NULL && p.All_Projects__c){
                
                    if(p.Contact__r.RecordType.DeveloperName == 'Candidate'){
                        instructorIds.add(p.Contact__c);
                        insRequest.add(p);
                    }
                    
                    if(p.Contact__r.RecordType.DeveloperName == 'Student'){
                        studentIds.add(p.Contact__c);
                        stdRequest.add(p);
                    }
                }
                
                if(p.Project__c != NULL){
                
                    if(p.Contact__r.RecordType.DeveloperName == 'Candidate' && String.isNotBlank(p.Type__c) && p.Type__c == 'Instructor'){
                        insProjIds.add(p.Project__c);
                        insRequest.add(p);
                    }
                    
                    if(p.Contact__r.RecordType.DeveloperName == 'Student' && String.isNotBlank(p.Type__c) && p.Type__c == 'Student'){
                        stdProjIds.add(p.Project__c);
                        stdRequest.add(p);
                    }
                }
                if(p.From_Date__c != null){
                    fromDates.add(p.From_Date__c);
                }
                if(p.To_Date__c != null){
                    toDates.add(p.To_Date__c);
                }
            }  
            
            if(instructorIds.size()  > 0){
            
                for(Contact_Assignments__c ins : [SELECT Id, Project__c
                    FROM Contact_Assignments__c
                    WHERE Candidate_Name__c IN : instructorIds AND Status__c = 'Active' AND RecordType.DeveloperName = 'Instructor'
                        AND Project__c != NULL AND Project__r.AcctSeed__Status__c = 'Active'
                ]){
                
                    insProjIds.add(ins.Project__c);
                }
            }
                        
            for(Contact_Assignments__c sCA : [SELECT Id, Start_Date__c, End_Date__c, Candidate_Name__c
                FROM Contact_Assignments__c
                WHERE Status__c = 'Active' AND RecordType.DeveloperName = 'Student'
                    AND Project__c IN : insProjIds AND Project__r.AcctSeed__Status__c = 'Active'
            ]){
                for(Planned_Days_Off__c p : insRequest){
                    if((p.From_Date__c != NULL && p.To_Date__c != NULL && sCA.Start_Date__c <= p.From_Date__c && 
                        (sCA.End_Date__c >= p.To_Date__c || sCA.End_Date__c <= p.To_Date__c)) || (p.From_Date__c != NULL && 
                        p.To_Date__c == NULL && sCA.Start_Date__c <= p.From_Date__c && 
                        (sCA.End_Date__c >= p.From_Date__c || sCA.End_Date__c <= p.From_Date__c))){
                        
                        if(!stdIdAndPDORequest.containsKey(sCA.Candidate_Name__c)){
                            stdIdAndPDORequest.put(sCA.Candidate_Name__c, new List<Planned_Days_Off__c>());
                        }
                        stdIdAndPDORequest.get(sCA.Candidate_Name__c).add(p);
                    }
                }
            }
            allContactIds.addAll(stdIdAndPDORequest.keySet());
            
            if(studentIds.size()  > 0 || stdProjIds.size() > 0){
            
                insIdAndPDORequest = getStudentPDORelatedInstructors(studentIds, stdProjIds, stdRequest, fromDates, toDates);
            }
            System.debug('::::::insIdAndPDORequest:::::'+insIdAndPDORequest);
            
            allContactIds.addAll(insIdAndPDORequest.keySet());
                        
            try{
                
                Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :allContactIds AND Email != NULL]);
                System.debug('::::conIdRec:::::'+conIdRec);
                
                EmailTemplate stdPDOToIns = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Instructor_Student_Planned_Days_Off_Req'];
                System.debug('::::stdPDOToIns:::::'+stdPDOToIns);
                
                // Modified By HL on Mar 25 2021
                // WorkItem: W-006590 - Update the Instructor PDO Approval Email to Student
                EmailTemplate insPDOToStd = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Instructor_Planned_Days_Off_Req_To_Std'];
                System.debug('::::insPDOToStd:::::'+insPDOToStd);
                
                List<Messaging.SingleEmailMessage> emailToSend = new List<Messaging.SingleEmailMessage>();
                
                if(conIdRec.size() > 0){
                    
                    String mailContent = '';
                    Boolean hasBouncedEmail = FALSE;
                
                    for(Id conId : allContactIds){
                    
                        if(conIdRec.containsKey(conId)){
                        
                            if(!conIdRec.get(conId).IsEmailBounced){
                        
                                if(stdIdAndPDORequest.containsKey(conId) && insPDOToStd != NULL){
                                
                                    for(Planned_Days_Off__c stdReq : stdIdAndPDORequest.get(conId)){
                                    
                                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                        mail.setTargetObjectId(conId);
                                        mail.setWhatId(stdReq.Id);
                                        mail.setSaveAsActivity(TRUE);
                                        mail.setTemplateID(insPDOToStd.Id);
                                        emailToSend.add(mail);
                                    }
                                }
                            
                                if(insIdAndPDORequest.containsKey(conId) && stdPDOToIns != NULL){
                                
                                    for(Planned_Days_Off__c insReq : insIdAndPDORequest.get(conId)){
                                    
                                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                        mail.setTargetObjectId(conId);
                                        mail.setWhatId(insReq.Id);
                                        mail.setSaveAsActivity(TRUE);
                                        mail.setTemplateID(stdPDOToIns.Id);
                                        emailToSend.add(mail);
                                    }
                                }
                            }else {
                    
                                mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(conId).Id+'" target="_blank">'+conIdRec.get(conId).Name+'</a><br/>';
                                hasBouncedEmail = true;
                            }
                        }
                    }
                    if(hasBouncedEmail || Test.isRunningTest()){
                    
                        Messaging.SingleEmailMessage bouncedmail = ErrorHandler.getBouncedEmail(mailContent);
                        emailToSend.add(bouncedmail);
                    }
                }
                System.debug('::::emailToSend::::'+emailToSend);
                System.debug('::::emailToSend:::SIZE:::::'+emailToSend.size());
            
                if( emailToSend != NULL && emailToSend.size() > 0 ) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToSend);
                }
            }catch(Exception e) {
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Planned Days off Request for Instructors - Students');
            } 
        }
    }
    
    /**************
        - Added by HL on Oct 10 2019
        - WorkItem - W-002984 : Student/Instructor Planned Days Off "Not Approved" Addition
        - Send an email notification to Instructor / Student when LTS Not Approved the planned days off request
        - This email only sending to the instructors when student PDO is rejected
        **************/
        
    public void notApprovedEmailNotificationToInsStd(List<Planned_Days_Off__c> notApprovedPDORecs){
    
    
        if(notApprovedPDORecs.size() > 0){
            
            Set<Id> allContactIds = new Set<Id>();            
            Set<Id> studentIds = new Set<Id>();
            List<Planned_Days_Off__c> stdRequest = new List<Planned_Days_Off__c>();
            Set<Id> stdProjIds = new Set<Id>();
            
            Set<Date> fromDates = new Set<Date>();
            Set<Date> toDates = new Set<Date>();
            Map<Id, List<Planned_Days_Off__c>> insIdAndPDORequest = new Map<Id, List<Planned_Days_Off__c>>();
            
            for(Planned_Days_Off__c p : notApprovedPDORecs){
            
                if(p.Project__c == NULL && p.All_Projects__c){
                    
                    studentIds.add(p.Contact__c);
                    stdRequest.add(p);
                }
                if(p.Project__c != NULL){
               
                    stdProjIds.add(p.Project__c);
                    stdRequest.add(p);
                }
                if(p.From_Date__c != null){
                    fromDates.add(p.From_Date__c);
                }
                if(p.To_Date__c != null){
                    toDates.add(p.To_Date__c);
                }
            } 
            
            if(studentIds.size()  > 0 || stdProjIds.size() > 0){
            
                insIdAndPDORequest = getStudentPDORelatedInstructors(studentIds, stdProjIds, stdRequest, fromDates, toDates);
            }
            System.debug('::::::insIdAndPDORequest:::::'+insIdAndPDORequest);     
            allContactIds.addAll(insIdAndPDORequest.keySet());
            
            try{
            
                Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :allContactIds AND Email != NULL]);
                
                EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Student_PDO_Not_Approved_Email_To_Ins'];
                               
                List<Messaging.SingleEmailMessage> emailToSend = new List<Messaging.SingleEmailMessage>();
                
                if(conIdRec.size() > 0 ){
                    
                    String mailContent = '';
                    Boolean hasBouncedEmail = FALSE;
                    
                     for(Id conId : allContactIds){
                    
                        if(conIdRec.containsKey(conId)){
                        
                            if(!conIdRec.get(conId).IsEmailBounced){
                                
                                if(insIdAndPDORequest.containsKey(conId)){
                                
                                    for(Planned_Days_Off__c insReq : insIdAndPDORequest.get(conId)){
                                    
                                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                        mail.setTargetObjectId(conId);
                                        mail.setWhatId(insReq.Id);
                                        mail.setSaveAsActivity(TRUE);
                                        mail.setTemplateID(template.Id);
                                        emailToSend.add(mail);
                                    }
                                }
                            }else {
                    
                                mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(conId).Id+'" target="_blank">'+conIdRec.get(conId).Name+'</a><br/>';
                                hasBouncedEmail = true;
                            }
                        }
                    }
                    
                    if(hasBouncedEmail || Test.isRunningTest()){
                    
                        Messaging.SingleEmailMessage bouncedmail = ErrorHandler.getBouncedEmail(mailContent);
                        emailToSend.add(bouncedmail);
                    }
                }
                System.debug('::::emailToSend::::'+emailToSend);
            
                if( emailToSend != NULL && emailToSend.size() > 0 ) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToSend);
                }
                
            }catch(Exception e) {
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on Student/Instructor Planned Days Off "Not Approved"');
            }
        }    
    }
    
    /**************
        - Added by HL on Oct 19 2019
        - WorkItem : W-003064 - Add ability for students and instructors to edit and delete Planned Days Off records in the community
        - To send an email notification to LTS / Project Manager or Contact Supervisor Whenever a Planned Days Off record is edited or deleted
        **************/
    public void sendEmailToLTSManagerSupr(List<Planned_Days_Off__c> editDelPDOReqs, Map<Id, Planned_Days_Off__c> oldPDOReqs){
    
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType pdoSchema = schemaMap.get('Planned_Days_Off__c');
        Map<String, Schema.SObjectField> fieldMap = pdoSchema.getDescribe().fields.getMap();
        
        Set<String> fieldAPINames = new Set<String>{'description__c', 'type__c', 'date__c', 'status__c', 'from_date__c', 'to_date__c'};
        Set<Id> pdoIds = new Set<Id>();
        Map<String, String> fieldLabelAndfieldvalue;
        Map<Id, Map<String, String>> pdoIdAndfieldNamefieldValue = new Map<Id, Map<String, String>>();
        
        for (Planned_Days_Off__c p : editDelPDOReqs) {
                                        
            pdoIds.add(p.Id);
            fieldLabelAndfieldvalue = new Map<String, String>();       
            Planned_Days_Off__c oldP = oldPDOReqs.get(p.Id);

            for (String fieldName: fieldAPINames) {
                                        
                try {                             
                    String oldAndNewvalue = '';
                    if(p.get(fieldName) != oldP.get(fieldName)){ 
                        
                        if(fieldMap.get(fieldName).getDescribe().getType() ==  Schema.DisplayType.DATE){
                            String oldVal = String.valueOf(oldP.get(fieldName)).split(' ')[0];
                            String newVal = String.valueOf(p.get(fieldName)).split(' ')[0];              
                            String oldVal_Dateformat = oldVal.split('-')[1]+'/'+oldVal.split('-')[2]+'/'+oldVal.split('-')[0];
                            String newVal_Dateformat = newVal.split('-')[1]+'/'+newVal.split('-')[2]+'/'+newVal.split('-')[0];               
                            oldAndNewvalue =  oldVal_Dateformat+ ','+ newVal_Dateformat;
                        }else{
                            oldAndNewvalue = oldP.get(fieldName) + ','+ p.get(fieldName);
                        }
                        fieldLabelAndfieldvalue.put(fieldMap.get(fieldName).getDescribe().getLabel(), oldAndNewvalue);
                    } 
                } catch (Exception e) { 
                    System.debug('Error: ' + e); 
                } 
            }
            
            if(fieldLabelAndfieldvalue.size() > 0){
            
                if(!pdoIdAndfieldNamefieldValue.containsKey(p.Id)){
                    pdoIdAndfieldNamefieldValue.put(p.Id, new Map<String, String>());
                }
                pdoIdAndfieldNamefieldValue.get(p.Id).putAll(fieldLabelAndfieldvalue);
            }
        }
        
        if(pdoIds.size() > 0){
        
            Map<Id, String> pdoIdAndLTSIdAndName = new Map<Id, String>();
            Map<Id, Planned_Days_Off__c> pdoIdAndRec = new Map<Id, Planned_Days_Off__c>();
            List<Messaging.SingleEmailMessage> emailToLTSAndIns = new List<Messaging.SingleEmailMessage>();
            
            for(Planned_Days_Off__c p : [SELECT Id, Contact__r.Name, Contact__r.Supervisor_Name__c, Contact__r.Supervisor_Name__r.FirstName, 
                    Project__r.Project_Manager__c, Project__r.Project_Manager__r.FirstName, Project__c, All_Projects__c, Date_Range__c,
                    Description__c, Contact__c, Name, Parent_Planned_Day_Off__c
                FROM Planned_Days_Off__c
                WHERE Id IN : pdoIds
            ]){
            
                if(p.Project__c == NULL && p.All_Projects__c && p.Contact__r.Supervisor_Name__c != NULL){                
                    pdoIdAndLTSIdAndName.put(p.Id, p.Contact__r.Supervisor_Name__c+'-'+p.Contact__r.Supervisor_Name__r.FirstName);
                }
                
                if(p.Project__c != NULL && p.Project__r.Project_Manager__c != NULL){
                    pdoIdAndLTSIdAndName.put(p.Id, p.Project__r.Project_Manager__c+'-'+p.Project__r.Project_Manager__r.FirstName);               
                }
                pdoIdAndRec.put(p.Id, p);
            }
            
            try{
            
                Map<Id, Set<Id>> projIdAndInsIds = new Map<Id, Set<Id>>();
                Map<Id, Set<Id>> stdIdAndInsIds = new Map<Id, Set<Id>>();
                Set<Id> allInsIds = new Set<Id>();
                
                PlannedDaysOffHandler.PDOInstructors all_Ins = new PlannedDaysOffHandler.PDOInstructors();
                all_Ins = getPDOInstructorIds(editDelPDOReqs);
                projIdAndInsIds = all_Ins.projIdAndInsIds;
                stdIdAndInsIds = all_Ins.stdIdAndInsIds;
                allInsIds = all_Ins.allInsIds;
                                
                Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, FirstName, Email, IsEmailBounced FROM Contact WHERE Id IN :allInsIds AND Email != NULL]);
                
                if(pdoIdAndLTSIdAndName.size() > 0){
                
                    for(Planned_Days_Off__c pdo : editDelPDOReqs){
                    
                        if(pdoIdAndLTSIdAndName.containsKey(pdo.Id)){
                        
                            Messaging.SingleEmailMessage lts_mail = new Messaging.SingleEmailMessage();
                            Id ltsId = pdoIdAndLTSIdAndName.get(pdo.Id).split('-')[0];
                            String ltsName = pdoIdAndLTSIdAndName.get(pdo.Id).split('-')[1];
                            lts_mail.setTargetObjectId(ltsId);
                            lts_mail.setWhatId(pdo.Id);
                            lts_mail.subject = pdoIdAndRec.get(pdo.Id).Contact__r.Name+ ' has edited or deleted an approved Planned Day Off';
                            
                            String dateVal = '';
                            if(pdo.Parent_Planned_Day_Off__c != null){
                                dateVal = String.valueOf(pdo.Date__c);
                                dateVal = dateVal.split('-')[1]+'/'+dateVal.split('-')[2]+'/'+dateVal.split('-')[0];
                            }else{
                                dateVal = pdo.Date_Range__c;
                            }
                            String htmlBody = '';
                            htmlBody += 'Hi '+ ltsName + ',<br/><br/>';
                            htmlBody += pdoIdAndRec.get(pdo.Id).Contact__r.Name + ' has edited or deleted a Planned Day Off that has already been approved.  Please see below for the details of the change. <br/>';
                            
                            //Table of fields that were changed with the old value and new value
                            if(pdoIdAndfieldNamefieldValue.size() > 0 && pdoIdAndfieldNamefieldValue.containsKey(pdo.Id)){
                                                            
                                if(pdo.Status__c == 'Delete' && oldPDOReqs.get(pdo.Id).Status__c == 'Approved'){
                                     htmlBody += '<br/><table border="1" style="border-collapse: collapse"><tr><th width="25%" style="text-align: center; vertical-align: middle;">Date</th><th width="25%" style="text-align: center; vertical-align: middle;">Field</th><th width="25%" style="text-align: center; vertical-align: middle;">Old Value</th><th width="25%" style="text-align: center; vertical-align: middle;">New Value</th></tr>'; 
                                }else{
                                    htmlBody += '<br/><table border="1" style="border-collapse: collapse"><tr><th width="25%" style="text-align: center; vertical-align: middle;">Field</th><th width="25%" style="text-align: center; vertical-align: middle;">Old Value</th><th width="25%" style="text-align: center; vertical-align: middle;">New Value</th></tr>';
                                }
                                for(String label : pdoIdAndfieldNamefieldValue.get(pdo.Id).keySet()){
                                
                                    String fieldvalue = pdoIdAndfieldNamefieldValue.get(pdo.Id).get(label);
                                    String oldValue = '';
                                    String newValue = '';
                                    
                                    oldValue = fieldvalue.split(',')[0];
                                    newValue = fieldvalue.split(',')[1];
                                    
                                    if(pdo.Status__c == 'Delete' && oldPDOReqs.get(pdo.Id).Status__c == 'Approved'){
                                        htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + dateVal  + '</td><td style="text-align: center; vertical-align: middle;">' + label  + '</td><td style="text-align: center; vertical-align: middle;">' + oldValue + '</td><td style="text-align: center; vertical-align: middle;">' + newValue + '</td></tr>';
                                    }else{
                                        htmlBody += '<tr><td style="text-align: center; vertical-align: middle;">' + label  + '</td><td style="text-align: center; vertical-align: middle;">' + oldValue + '</td><td style="text-align: center; vertical-align: middle;">' + newValue + '</td></tr>';
                                    }
                                }
                                htmlBody += '</table><br/>';
                            }
                            htmlBody += '<br/>Please <a href="'+ System.Label.Org_Prefix_Start_URL +'/lightning/r/Planned_Days_Off__c/' + pdo.Id +'/view" target="_blank"> click here </a> to view the record for more information.';
                            htmlBody += '<br/><br/>Thank you<br/><br/>System Generated Email';
                            lts_mail.setHtmlBody(htmlBody);
                            lts_mail.setSaveAsActivity(false);
                            emailToLTSAndIns.add(lts_mail);
                        }
                        if(projIdAndInsIds.containsKey(pdo.Project__c)){
                        
                            for(Id insId : projIdAndInsIds.get(pdo.Project__c)){
                                
                                Messaging.SingleEmailMessage ins_mail = new Messaging.SingleEmailMessage();
                                ins_mail.setTargetObjectId(insId);
                                ins_mail.setWhatId(pdo.Id);
                                ins_mail.subject = pdoIdAndRec.get(pdo.Id).Contact__r.Name+ ' has updated planned day(s) off for ' + pdoIdAndRec.get(pdo.Id).Date_Range__c;
                                
                                String htmlBody = '';
                                htmlBody += 'Dear '+ conIdRec.get(insId).FirstName + ',<br/><br/>';
                                htmlBody += 'This email is to notify you that ' + pdoIdAndRec.get(pdo.Id).Contact__r.Name;
                                if(pdo.Status__c == 'Delete' && oldPDOReqs.get(pdo.Id).Status__c == 'Approved'){
                                    htmlBody += ' has deleted their planned days off for: <br/>';   
                                    htmlBody += '<p>Dates: '+  pdoIdAndRec.get(pdo.Id).Date_Range__c;
                                }else{
                                    htmlBody += ' has updated their planned days off for: <br/>';   
                                    htmlBody += '<p>Dates: '+  oldPDOReqs.get(pdo.Id).Date_Range__c + ' to '+pdoIdAndRec.get(pdo.Id).Date_Range__c;
                                }
                                htmlBody += '<br/>Description: '+ pdoIdAndRec.get(pdo.Id).Description__c+'</p><br/>';
                                htmlBody += 'Please contact your LTS with any questions or concerns.<br/>';
                                htmlBody += '<br/>Thank you<br/><br/>System Generated Email';
                                
                                ins_mail.setHtmlBody(htmlBody);
                                ins_mail.setSaveAsActivity(true);
                                emailToLTSAndIns.add(ins_mail);
                            }
                        }
                        
                        if(stdIdAndInsIds.containsKey(pdo.Contact__c)){
                        
                            for(Id insId : stdIdAndInsIds.get(pdo.Contact__c)){
                                
                                Messaging.SingleEmailMessage ins_mail = new Messaging.SingleEmailMessage();
                                ins_mail.setTargetObjectId(insId);
                                ins_mail.setWhatId(pdo.Id);
                                ins_mail.subject = pdoIdAndRec.get(pdo.Id).Contact__r.Name+ ' has updated planned day(s) off for ' + pdoIdAndRec.get(pdo.Id).Date_Range__c;
                                
                                String htmlBody = '';
                                htmlBody += 'Dear '+ conIdRec.get(insId).FirstName + ',<br/><br/>';
                                htmlBody += 'This email is to notify you that ' + pdoIdAndRec.get(pdo.Id).Contact__r.Name;
                                if(pdo.Status__c == 'Delete' && oldPDOReqs.get(pdo.Id).Status__c == 'Approved'){
                                    htmlBody += ' has deleted their planned days off for: <br/>';   
                                    htmlBody += '<p>Dates: '+  pdoIdAndRec.get(pdo.Id).Date_Range__c;
                                }else{
                                    htmlBody += ' has updated their planned days off for: <br/>';   
                                    htmlBody += '<p>Dates: '+  oldPDOReqs.get(pdo.Id).Date_Range__c + ' to '+pdoIdAndRec.get(pdo.Id).Date_Range__c;
                                }
                                htmlBody += '<br/>Description: '+ pdoIdAndRec.get(pdo.Id).Description__c+'</p><br/>';
                                htmlBody += 'Please contact your LTS with any questions or concerns.<br/>';
                                htmlBody += '<br/>Thank you<br/><br/>System Generated Email';
                                
                                ins_mail.setHtmlBody(htmlBody);
                                ins_mail.setSaveAsActivity(true);
                                emailToLTSAndIns.add(ins_mail);
                            }
                        }
                    }
                    
                    if(emailToLTSAndIns != NULL && emailToLTSAndIns.size() > 0) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToLTSAndIns);
                    }
                }
            }catch(Exception e) {
                
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,'hemalatha@softsquare.biz','Error on Email Notification To LTS / Project Manager or Contact Supervisor and Instructor Whenever a Planned Days Off record is edited or deleted');
            } 
        }
    }
    
    public PDOInstructors getPDOInstructorIds(List<Planned_Days_Off__c> pdoRecs){
        
        Set<Id> projIds = new Set<Id>();
        Set<Id> stdIds = new Set<Id>();
        Set<Id> remProjIds = new Set<Id>();
        
        Map<String, Planned_Days_Off__c> projInfo_PDOIdAndPDO = new Map<String, Planned_Days_Off__c>();
        Map<Id, Set<Id>> projIdAndStdIds = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> projIdAndInsIds = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> stdIdAndInsIds = new Map<Id, Set<Id>>();
        Set<Id> allInsIds = new Set<Id>();
        
        PlannedDaysOffHandler.PDOInstructors all_Instructors = new PlannedDaysOffHandler.PDOInstructors();
        
        for(Planned_Days_Off__c p : pdoRecs){
        
            String projInfo = '';
            if(p.Project__c != NULL){
                projIds.add(p.Project__c);
                projInfo = p.Project__c;
            }
            if(p.Project__c == NULL && p.All_Projects__c){
                stdIds.add(p.Contact__c);
                projInfo = 'True';
            }
            String projInfo_PDOId = projInfo+'-'+p.Id;
            projInfo_PDOIdAndPDO.put(projInfo_PDOId, p);
        }
        if(stdIds.size() > 0){
            for(Contact_Assignments__c ca : [SELECT Id, Project__c, Candidate_Name__c
                FROM Contact_Assignments__c
                WHERE Candidate_Name__c IN : stdIds AND Status__c = 'Active' AND RecordType.DeveloperName = 'Student' 
            ]){
                remProjIds.add(ca.Project__c);
                if(!projIdAndStdIds.containsKey(ca.Project__c)){
                    projIdAndStdIds.put(ca.Project__c, new Set<Id>());
                }
                projIdAndStdIds.get(ca.Project__c).add(ca.Candidate_Name__c);
            }
        }
        
        for(AcctSeed__Project__c proj : [SELECT Id,(SELECT Id,Candidate_Name__c,Project__c FROM Contact_Assignments__r WHERE RecordType.DeveloperName = 'Instructor' AND Status__c = 'Active') 
            FROM AcctSeed__Project__c 
            WHERE (Id IN : projIds OR Id IN : remProjIds)]){
            
            if(projIds.contains(proj.Id)){
                for(Contact_Assignments__c insCA : proj.Contact_Assignments__r){
                    if(!projIdAndInsIds.containsKey(proj.Id)){
                        projIdAndInsIds.put(proj.Id, new Set<Id>());
                    }
                    projIdAndInsIds.get(proj.Id).add(insCA.Candidate_Name__c);
                    allInsIds.add(insCA.Candidate_Name__c);
                }
            } 
            if(remProjIds.contains(proj.Id) && projIdAndStdIds.containsKey(proj.Id)){
                for(Id stdId : projIdAndStdIds.get(proj.Id)){
                    for(Contact_Assignments__c insCA : proj.Contact_Assignments__r){
                        if(!stdIdAndInsIds.containsKey(stdId)){
                            stdIdAndInsIds.put(stdId, new Set<Id>());
                        }
                        stdIdAndInsIds.get(stdId).add(insCA.Candidate_Name__c);
                        allInsIds.add(insCA.Candidate_Name__c);
                    }
                }
            }    
        }
        System.debug(':::projIdAndInsIds:::'+projIdAndInsIds);
        System.debug(':::stdIdAndInsIds:::'+stdIdAndInsIds);
        all_Instructors.projIdAndInsIds = projIdAndInsIds;
        all_Instructors.stdIdAndInsIds = stdIdAndInsIds;
        all_Instructors.allInsIds = allInsIds;
        
        return all_Instructors;
    }
    
    /***************
        - Added b HL on Dec 04 2019
        - Work Item : W-003064 - Add ability for students and instructors to edit and delete Planned Days Off records in the community
        - Update event records Status as "Cancelled" that are related to student Planned Day Off records which are approved
        **************************/
    public void updateEventRecsToCancelled(List<Planned_Days_Off__c> pdoRecs){        
        
        if(pdoRecs != NULL && pdoRecs.size() > 0){
            
            PlannedDaysOffHandler.UpdateEveRecs updateEve = new PlannedDaysOffHandler.UpdateEveRecs();
            updateEve = getProjIdAndCancellationDateForEvent(pdoRecs);
            
            Map<Id, Set<Date>> projIdAndCancelledDates = updateEve.projIdAndCancelledDates;
            Set<Date> cancelledDates = updateEve.cancelledDates;
            
            if(projIdAndCancelledDates != NULL && projIdAndCancelledDates.size() > 0){
                    
                List<Events__c> events = updateEventRecs(projIdAndCancelledDates.keySet(), cancelledDates, 'Update Canceled');
                
                if(events != NULL && events.size() > 0){
                
                    List<Events__c> updateEvents = new List<Events__c>();
                    
                    for(Events__c e : events){
                    
                        if(projIdAndCancelledDates.containsKey(e.Project__c) && 
                            projIdAndCancelledDates.get(e.Project__c).contains(e.Date__c)){
                        
                            e.Status__c = 'Canceled';
                            updateEvents.add(e);
                        }
                    }
                    System.debug('::::updateEvents::::'+updateEvents);
                    
                    if(updateEvents.size() > 0){
                        update updateEvents;
                    }
                }    
            }
        }        
    }
    
    /***************
        - Added b HL on Dec 04 2019
        - Work Item : W-003064 - Add ability for students and instructors to edit and delete Planned Days Off records in the community
        - Update event records Status as "Scheduled" that are related to student Planned Day Off records which are approved for deleting
        ***********************/
    public void updateEventRecsToScheduled(List<Planned_Days_Off__c> pdoRecs){

        if(pdoRecs != NULL && pdoRecs.size() > 0){
            
            PlannedDaysOffHandler.UpdateEveRecs updateEve = new PlannedDaysOffHandler.UpdateEveRecs();
            updateEve = getProjIdAndCancellationDateForEvent(pdoRecs);
            
            Map<Id, Set<Date>> projIdAndCancelledDates = updateEve.projIdAndCancelledDates;
            Set<Date> cancelledDates = updateEve.cancelledDates;
            
            if(projIdAndCancelledDates != NULL && projIdAndCancelledDates.size() > 0){
                
                List<Events__c> events = updateEventRecs(projIdAndCancelledDates.keySet(), cancelledDates, 'Update Scheduled');
                
                if(events != NULL && events.size() > 0){
                
                    List<Events__c> updateEvents = new List<Events__c>();
                    
                    for(Events__c e : events){
                    
                        if(projIdAndCancelledDates.containsKey(e.Project__c) && 
                            projIdAndCancelledDates.get(e.Project__c).contains(e.Date__c)){
                        
                            e.Status__c = 'Scheduled';
                            updateEvents.add(e);
                        }
                    }
                    System.debug('::::updateEvents::::'+updateEvents);
                    
                    if(updateEvents.size() > 0){
                        update updateEvents;
                    }
                }    
            }
        }
    }
    
    // Added By HL on Mar 26 2021
    // WorkItem: W-006589 - PDO Submitted for Student by Instructor
    public PlannedDaysOffHandler.UpdateEveRecs getProjIdAndCancellationDateForEvent(List<Planned_Days_Off__c> pdoRecs){
        
        Map<Id, Set<Date>> projIdAndCancelledDates = new Map<Id, Set<Date>>();
        Set<Date> cancelledDates = new Set<Date>();
        
        if(pdoRecs != NULL && pdoRecs.size() > 0){
        
            Set<Id> projIds = new Set<Id>();
            Set<Id> stdIds = new Set<Id>();
            Set<Id> remProjIds = new Set<Id>();
        
            Map<Id, Set<Date>> stdIdAndPDODates = new Map<Id, Set<Date>>();
            Map<Id, Set<Id>> projIdAndStdIds = new Map<Id, Set<Id>>(); 
               
            Set<Date> newPDODates = new Set<Date>();
            Set<Id> allStdIds = new Set<Id>();
        
            for(Planned_Days_Off__c p : pdoRecs){
                            
                if(p.Contact__c != NULL && p.Date__c != NULL){
                
                    if(p.Project__c != NULL){
                        projIds.add(p.Project__c);
                    }
                    
                    if(p.Project__c == NULL && p.All_Projects__c){
                        stdIds.add(p.Contact__c);
                    }
                                
                    if(!stdIdAndPDODates.containsKey(p.Contact__c)){
                        stdIdAndPDODates.put(p.Contact__c, new Set<Date>());
                    }
                    stdIdAndPDODates.get(p.Contact__c).add(p.Date__c);
                    newPDODates.add(p.Date__c);
                }
            }
            System.debug(':::stdIds::::'+stdIds);
            System.debug(':::projIds::::'+projIds);
            System.debug(':::stdIdAndPDODates::::'+stdIdAndPDODates);
        
            if(stdIds.size() > 0 || projIds.size() > 0){
                
                for(Contact_Assignments__c ca : [SELECT Id, Project__c, Candidate_Name__c
                    FROM Contact_Assignments__c
                    WHERE Status__c = 'Active' AND RecordType.DeveloperName = 'Student' AND (Candidate_Name__c IN : stdIds OR Project__c IN : projIds)
                ]){
                    
                    if(projIds.contains(ca.Project__c)){
                        
                        if(!projIdAndStdIds.containsKey(ca.Project__c)){
                            projIdAndStdIds.put(ca.Project__c, new Set<Id>());
                        }
                        projIdAndStdIds.get(ca.Project__c).add(ca.Candidate_Name__c);
                        allStdIds.add(ca.Candidate_Name__c);
                    }
                    
                    if(stdIds.contains(ca.Candidate_Name__c)){
                    
                        remProjIds.add(ca.Project__c);
                    }
                }
            }
            System.debug(':::remProjIds::::'+remProjIds);
        
            if(remProjIds.size() > 0){
            
                for(Contact_Assignments__c ca : [SELECT Id, Project__c, Candidate_Name__c
                    FROM Contact_Assignments__c
                    WHERE Status__c = 'Active' AND RecordType.DeveloperName = 'Student' AND Project__c IN : remProjIds
                ]){
                    if(!projIdAndStdIds.containsKey(ca.Project__c)){
                        projIdAndStdIds.put(ca.Project__c, new Set<Id>());
                    }
                    projIdAndStdIds.get(ca.Project__c).add(ca.Candidate_Name__c);
                    allStdIds.add(ca.Candidate_Name__c);
                }
            }
            System.debug(':::projIdAndStdIds::::'+projIdAndStdIds);
        
            if(stdIdAndPDODates != NULL && stdIdAndPDODates.size() > 0){
            
                Map<Id, Set<Date>> oldStdIdAndPDODates = new Map<Id, Set<Date>>();
                
                for(Planned_Days_Off__c oldP : [SELECT Id, Contact__c, Date__c
                                                    FROM Planned_Days_Off__c
                                                    WHERE Id NOT IN : pdoRecs AND Date__c IN : newPDODates AND 
                                                        Contact__c IN : allStdIds AND (Project__c IN :projIdAndStdIds.keySet() OR 
                                                        All_Projects__c = TRUE)]){
                                                        
                    if(!oldStdIdAndPDODates.containsKey(oldP.Contact__c)){
                    
                        oldStdIdAndPDODates.put(oldP.Contact__c, new Set<Date>());
                    }
                    oldStdIdAndPDODates.get(oldP.Contact__c).add(oldP.Date__c);
                }
                System.debug(':::oldStdIdAndPDODates::::'+oldStdIdAndPDODates);
                System.debug(':::oldStdIdAndPDODates::::'+oldStdIdAndPDODates.size());
                
                for(Id newStdId : stdIdAndPDODates.keySet()){
                
                    for(Date newDate : stdIdAndPDODates.get(newStdId)){
                    
                        for(Id projId : projIdAndStdIds.keySet()){
                            
                            if(projIdAndStdIds.get(projId).size() > 1){
                            
                                Boolean isLeave = TRUE;
                                for(Id allStdId : projIdAndStdIds.get(projId)){
                                
                                    if(newStdId != allStdId && (!oldStdIdAndPDODates.containsKey(allStdId) || 
                                        (oldStdIdAndPDODates.containsKey(allStdId) && 
                                        !oldStdIdAndPDODates.get(allStdId).contains(newDate)))){
                                    
                                        isLeave = FALSE;
                                        break;
                                    }
                                    if(oldStdIdAndPDODates.containsKey(allStdId) && oldStdIdAndPDODates.get(allStdId).contains(newDate)){
                                    
                                        isLeave = TRUE;
                                    }
                                }
                                if(isLeave){
                                    
                                    if(!projIdAndCancelledDates.containsKey(projId)){
                                    
                                        projIdAndCancelledDates.put(projId, new Set<Date>());
                                    }    
                                    projIdAndCancelledDates.get(projId).add(newDate);
                                    cancelledDates.add(newDate);
                                }
                            }else if(projIdAndStdIds.get(projId).size() == 1){
                            
                                if(!projIdAndCancelledDates.containsKey(projId)){
                                    
                                    projIdAndCancelledDates.put(projId, new Set<Date>());
                                }    
                                projIdAndCancelledDates.get(projId).add(newDate);
                                cancelledDates.add(newDate);
                            }
                        }
                    }
                }
                System.debug(':::projIdAndCancelledDates::::'+projIdAndCancelledDates);
                System.debug(':::projIdAndCancelledDates::::'+projIdAndCancelledDates.size());
            }
        }        
        UpdateEveRecs eve = new UpdateEveRecs();
        eve.projIdAndCancelledDates = projIdAndCancelledDates;
        eve.cancelledDates = cancelledDates;
        
        return eve;
    }
    
    public List<Events__c> updateEventRecs(Set<Id> projIds, Set<Date> pdoDates, String statusStr){
        
        List<Events__c> events = new List<Events__c>();
        
        if(projIds.size() > 0 && pdoDates.size() > 0 && String.isNotBlank(statusStr)){
        
            String eveQry = 'SELECT Id, Status__c, Project__c, Date__c FROM Events__c WHERE Project__c IN : projIds AND Date__c IN : pdoDates ';
            
            if(statusStr == 'Update Scheduled'){
                eveQry += 'AND Status__c != \'Scheduled\'';
            }
            if(statusStr == 'Update Canceled'){
                eveQry += 'AND Status__c != \'Canceled\'';
            }
            
            events = Database.Query(eveQry);
        }
        return events;
    }
    
    /*********
        - Added By HL on Mar 10 2021
        - Work Item: W-006413 - Planned Days Off Approval Email to Student
        - To create a task for maintaining the activity history for contacts who are created the PDO record while approving or rejecting the PDO records. 
            Because we are sending an email notification to submitting Instructor / Student via Approval Process's email alert (Dosn't show the activity history).
        ************/
    public void createTaskForSubmittingIns_Std(List<Planned_Days_Off__c> pdoRecs){
    
        if(pdoRecs != NULL && pdoRecs.size() > 0){
            
            List<Task> taskList = new List<Task>();
            
            for(Planned_Days_Off__c pdo : pdoRecs){
            
                Task t = new Task();
                t.WhoId = pdo.Contact__c;
                t.WhatId = pdo.Id;
                t.Status = 'Completed';
                t.Subject = 'Email: '+UserInfo.getName()+' has '+pdo.Status__c+' your planned day(s) off for '+pdo.Date_Range__c;
                t.ActivityDate = Date.Today();
                taskList.add(t);
            }
            System.debug('::::taskList::::'+taskList);
            
            if(taskList.size() > 0){
                insert taskList;
            }
        }
    }
    
    // Added By HL on June 02 2021
    // Work Item: W-006749 - Planned Days Off did not Cancel Events
    // To update Event records directly without checking any other conditions(all students leave on this day) if Project PDO is created/updated
    public void updateEventRecsForProjectPDO(Set<Id> projIds, Set<Date> pdoDates, String statusStr){
    
        if(projIds != NULL && pdoDates != NULL && String.isNotBlank(statusStr)){
        
            List<Events__c> events = updateEventRecs(projIds, pdoDates, statusStr);
                
            if(events != NULL && events.size() > 0){
            
                List<Events__c> updateEvents = new List<Events__c>();
                
                for(Events__c e : events){
                
                    if(projIds.contains(e.Project__c) && pdoDates.contains(e.Date__c)){
                        
                        if(statusStr == 'Update Scheduled'){
                            e.Status__c = 'Scheduled';
                        }
                        if(statusStr == 'Update Canceled'){
                            e.Status__c = 'Canceled';
                        }
                        updateEvents.add(e);
                    }
                }
                System.debug('::::updateEvents::::'+updateEvents);
                
                if(updateEvents.size() > 0){
                    update updateEvents;
                }
            }
        }
    }
    
    /********
        - Added By HL on Nov 23 2021
        - Work Item: W-007088 - PDO - Notifications and updated Parent record when child record is updated
        - To update the Child Planned Days Off records, to update related Event records and to create new Planned Days Off records 
            when the Date Range/Project value in Parent Planned Days Off record is updated
        *********/
    public static void updateChildPDOAndEventRecs(Map<Id, Planned_Days_Off__c> old_PDORecValue, Map<Id, Planned_Days_Off__c> new_PDORecValue){
        
        if(old_PDORecValue != null && new_PDORecValue != null){
            
            Map<Id, Set<Date>> pIdAndAllDateRange = new Map<Id, Set<Date>>();
            Map<Id, Set<Date>> pIdAndOldDateRange = new Map<Id, Set<Date>>();
            Map<Id, Set<Date>> pIdAndNewDateRange = new Map<Id, Set<Date>>();
            
            Map<Id, Set<Date>> pIdAndDatesToCreatePDO = new Map<Id, Set<Date>>();
            Map<Id, Set<Date>> pIdAndDatesToDeletePDO = new Map<Id, Set<Date>>();
            Set<Date> datesToDeletePDO = new Set<Date>();
            Map<Id, Set<Date>> pIdAndDatesToPreventDelete = new Map<Id, Set<Date>>();
            Map<Id, Set<Date>> pIdAndDatesToPreventNewPDOCreation = new Map<Id, Set<Date>>();
                
            List<Planned_Days_Off__c> deletePDORecs = new List<Planned_Days_Off__c>();
            
            for(Id oldPId : old_PDORecValue.keySet()){
            
                Date fromDate = old_PDORecValue.get(oldPId).From_Date__c;
                Date toDate = old_PDORecValue.get(oldPId).To_Date__c;
                
                if(fromDate != null && toDate != null){
                    while(fromDate <= toDate){
                    
                        if(!pIdAndOldDateRange.containsKey(oldPId)){
                            pIdAndOldDateRange.put(oldPId, new Set<Date>());
                        }
                        pIdAndOldDateRange.get(oldPId).add(fromDate);
                         
                        if(!pIdAndAllDateRange.containsKey(oldPId)){
                            pIdAndAllDateRange.put(oldPId, new Set<Date>());
                        }
                        pIdAndAllDateRange.get(oldPId).add(fromDate);
                        
                        fromDate = fromDate.addDays(1);
                    }  
                }else if(fromDate != null && toDate == null){
                    if(!pIdAndOldDateRange.containsKey(oldPId)){
                        pIdAndOldDateRange.put(oldPId, new Set<Date>());
                    }
                    pIdAndOldDateRange.get(oldPId).add(fromDate);
                } 
            }
            
            for(Id newPId : new_PDORecValue .keySet()){
            
                Date fromDate = new_PDORecValue .get(newPId).From_Date__c;
                Date toDate = new_PDORecValue .get(newPId).To_Date__c;
                
                if(fromDate != null && toDate != null){
                    while(fromDate <= toDate){
                    
                        if(!pIdAndNewDateRange.containsKey(newPId)){
                            pIdAndNewDateRange.put(newPId, new Set<Date>());
                        }
                        pIdAndNewDateRange.get(newPId).add(fromDate);
                             
                        if(!pIdAndAllDateRange.containsKey(newPId)){
                            pIdAndAllDateRange.put(newPId, new Set<Date>());
                        }
                        pIdAndAllDateRange.get(newPId).add(fromDate);
                        fromDate = fromDate.addDays(1);
                    }    
                }else if(fromDate != null && toDate == null){
                    if(!pIdAndNewDateRange.containsKey(newPId)){
                        pIdAndNewDateRange.put(newPId, new Set<Date>());
                    }
                    pIdAndNewDateRange.get(newPId).add(fromDate);
                } 
            }
            
            // To update child PDO's All_Projects__c/Project__c field value when parent PDO's All_Projects__c/Project__c field value is updated
            Map<Id, Planned_Days_Off__c> upateChildPDOProjAndDateValues = new Map<Id, Planned_Days_Off__c>();
            
            for(Planned_Days_Off__c parentPDO : [SELECT Id, From_Date__c, To_Date__c, All_Projects__c, Project__c,
                                                (SELECT Id, Date__c, All_Projects__c, Project__c, Status__c FROM Planned_Days_Off__r)
                                            FROM Planned_Days_Off__c
                                            WHERE Id IN : new_PDORecValue .keySet()]){    
                                                                        
                for(Planned_Days_Off__c childPDO : parentPDO.Planned_Days_Off__r){
                          
                    if(parentPDO.All_Projects__c != childPDO.All_Projects__c || parentPDO.Project__c != childPDO.Project__c){
                        childPDO.All_Projects__c = parentPDO.All_Projects__c;
                        childPDO.Project__c = parentPDO.Project__c;
                        upateChildPDOProjAndDateValues.put(childPDO.Id, childPDO);
                    }    
                    
                    if(pIdAndNewDateRange.containsKey(parentPDO.Id) && pIdAndNewDateRange.get(parentPDO.Id).contains(childPDO.Date__c) && childPDO.Status__c == 'Delete'){
                         // To prevent Event's field status updated as 'Canceled' if already had PDO record for this date and which was updated as 'Delete'
                         //pIdAndNewDateRange.get(parentPDO.Id).remove(childPDO.Date__c); // Revert the change
                        childPDO.Status__c = 'Approved';    // To set status value as Approved when again date range is increased
                        // To prevent new PDO creation if we had PDO record for this Date and its status will reverted to Approved from Delete
                        if(!pIdAndDatesToPreventNewPDOCreation.containsKey(parentPDO.Id)){
                             pIdAndDatesToPreventNewPDOCreation.put(parentPDO.Id, new Set<Date>());    
                        }
                        pIdAndDatesToPreventNewPDOCreation.get(parentPDO.Id).add(childPDO.Date__c);
                        upateChildPDOProjAndDateValues.put(childPDO.Id, childPDO);
                         // If we had PDO for specific date and it was updated as 'Delete' Status. In this time, the week range gets udpated means, we don't delete this PDO record.
                         if(!pIdAndDatesToPreventDelete.containsKey(parentPDO.Id)){
                             pIdAndDatesToPreventDelete.put(parentPDO.Id, new Set<Date>());    
                         }
                         pIdAndDatesToPreventDelete.get(parentPDO.Id).add(childPDO.Date__c);
                    }
                    if(parentPDO.From_Date__c != null && parentPDO.To_Date__c == null && parentPDO.From_Date__c != childPDO.Date__c){
                        childPDO.Date__c = parentPDO.From_Date__c;
                        upateChildPDOProjAndDateValues.put(childPDO.Id, childPDO);
                    }
                    if(pIdAndOldDateRange.containsKey(parentPDO.Id) && pIdAndNewDateRange.containsKey(parentPDO.Id) && 
                        pIdAndOldDateRange.get(parentPDO.Id).contains(childPDO.Date__c) && !pIdAndNewDateRange.get(parentPDO.Id).contains(childPDO.Date__c) && childPDO.Status__c == 'Approved'){
                        childPDO.Status__c = 'Delete';
                        upateChildPDOProjAndDateValues.put(childPDO.Id, childPDO);
                    }
                }
            }
            if(upateChildPDOProjAndDateValues.size() > 0){
                update upateChildPDOProjAndDateValues.values();
            }
            
            for(Id pId : pIdAndAllDateRange.keySet()){
                for(Date d : pIdAndAllDateRange.get(pId)){
                    // Currently we are updating the PDO's status as 'Delete' instead of deleting the PDO record
                    /*
                    // To delete PDOs when date range is decreased
                    if(pIdAndOldDateRange.get(pId).contains(d) && !pIdAndNewDateRange.get(pId).contains(d)){
                        if(!pIdAndDatesToDeletePDO.containsKey(pId)){
                            pIdAndDatesToDeletePDO.put(pId, new Set<Date>());
                        }
                         pIdAndDatesToDeletePDO.get(pId).add(d);
                         if(pIdAndDatesToPreventDelete.containsKey(pId) && !pIdAndDatesToPreventDelete.get(pId).contains(d)){
                             datesToDeletePDO.add(d);
                         }
                    } 
                    */
                    // To create PDOs when date range is increased
                    if(!pIdAndOldDateRange.get(pId).contains(d) && pIdAndNewDateRange.get(pId).contains(d)){
                        if(!pIdAndDatesToPreventNewPDOCreation.containsKey(pId) || (pIdAndDatesToPreventNewPDOCreation.containsKey(pId) && !pIdAndDatesToPreventNewPDOCreation.get(pId).contains(d))){
                            if(!pIdAndDatesToCreatePDO.containsKey(pId)){
                                pIdAndDatesToCreatePDO.put(pId, new Set<Date>());
                            }
                            pIdAndDatesToCreatePDO.get(pId).add(d);
                        }
                    }  
                }
            }  
            /*
            deletePDORecs = [SELECT Id FROM Planned_Days_Off__c WHERE Parent_Planned_Day_Off__c IN : pIdAndDatesToDeletePDO.keySet() AND Date__c IN : datesToDeletePDO];
            System.debug(':::deletePDORecs::'+deletePDORecs);
            if(deletePDORecs.size() > 0){
                delete deletePDORecs;            
            }
            */
            List<Planned_Days_Off__c> newPDOs = createNewChildPDORecs(pIdAndDatesToCreatePDO, new_PDORecValue);
            if(newPDOs != null && newPDOs.size() > 0){
                insert  newPDOs;   
            }            
            
            Map<Id, Events__c> updateEventRecs = new Map<Id, Events__c>();
            List<Events__c> updateEventsToCanceled = processNewAndOldPDOs(new_PDORecValue.values(), pIdAndNewDateRange, True);
            List<Events__c> updateEventsToScheduled = processNewAndOldPDOs(old_PDORecValue.values(), pIdAndOldDateRange, False);
            
            if(updateEventsToCanceled != null && updateEventsToCanceled.size() > 0){
                updateEventRecs.putAll(updateEventsToCanceled);
            }
            if(updateEventsToScheduled != null && updateEventsToScheduled.size() > 0){
                updateEventRecs.putAll(updateEventsToScheduled);
            }
            
            if(updateEventRecs.size() > 0){
                update updateEventRecs.values();
            }
        }
    }
    
    public static List<Planned_Days_Off__c> createNewChildPDORecs(Map<Id, Set<Date>> pIdAndDatesToCreatePDO, Map<Id,Planned_Days_Off__c> parentPDORec){
    
        Map<String,Id> rtNameRTId = new Map<String,Id>();
        for(RecordType rt : [SELECT Id,DeveloperName FROM RecordType WHERE SobjectType = 'Planned_Days_Off__c']){
            if(!rtNameRTId.containsKey(rt.DeveloperName))
                rtNameRTId.put(rt.DeveloperName,rt.Id);
        } 
        //Map<String,Integer> weekDayValues = new Map<String,Integer>{'Monday' => 0,'Tuesday' => 1,'Wednesday' => 2,'Thursday' => 3,'Friday' => 4,'Saturday' => 5,'Sunday' => 6};
        List<Planned_Days_Off__c> newOffRecords = new List<Planned_Days_Off__c>();
        PlannedDaysOffHandler pdo = new PlannedDaysOffHandler();
        
        for(Id pId : pIdAndDatesToCreatePDO.keySet()){
            for(Date d : pIdAndDatesToCreatePDO.get(pId)){
                if(parentPDORec.containsKey(pId)){
                    /*String dayOfWeek = DateTime.newInstance(d.year(),d.month(),d.day()).format('EEEE');
                    if(weekDayValues.containsKey(dayOfWeek) && weekDayValues.get(dayOfWeek) != 5 && weekDayValues.get(dayOfWeek) != 6) {*/
                        Planned_Days_Off__c newOff = pdo.generateOffRecords(parentPDORec.get(pId),rtNameRTId,d);
                        newOffRecords.add(newOff);
                    //}
                }
            }
        }
        return newOffRecords;
    }
    
    public static List<Events__c> processNewAndOldPDOs(List<Planned_Days_Off__c> pdoRecs, Map<Id, Set<Date>> pIdAndDateRange, Boolean isNew){
        
        List<Events__c> updateEvents = new List<Events__c>();
        Map<Id, Set<Date>> stdIdAndPDODates = new Map<Id, Set<Date>>();
        Map<Id, Set<Id>> projIdAndStdIds = new Map<Id, Set<Id>>();
        
        Set<Id> allStdIds = new Set<Id>();
        Set<Id> remProjIds = new Set<Id>();
        
        Map<Id, Set<Date>> projIdAndCancelledDates = new Map<Id, Set<Date>>();
        Set<Date> cancelledDates = new Set<Date>();
        
        Set<Id> projIds = new Set<Id>();
        Set<Id> stdIds = new Set<Id>();
        
        if(pdoRecs != NULL && pdoRecs.size() > 0){
        
            for(Planned_Days_Off__c p : pdoRecs){
                            
                if(p.Contact__c != NULL){    
                
                    if(p.Project__c != NULL){
                        projIds.add(p.Project__c);
                    }
                    
                    if(p.Project__c == NULL && p.All_Projects__c){
                        stdIds.add(p.Contact__c);
                    }
                    if(pIdAndDateRange.containsKey(p.Id)){
                        stdIdAndPDODates.put(p.Contact__c, pIdAndDateRange.get(p.Id));
                    }       
                }
            }        
            for(Contact_Assignments__c ca : [SELECT Id, Project__c, Candidate_Name__c
                FROM Contact_Assignments__c
                WHERE Status__c = 'Active' AND RecordType.DeveloperName = 'Student' AND (Candidate_Name__c IN : stdIds OR Project__c IN : projIds)
            ]){
                // Remaining students under this project
                if(projIds.contains(ca.Project__c)){
                    
                    if(!projIdAndStdIds.containsKey(ca.Project__c)){
                        projIdAndStdIds.put(ca.Project__c, new Set<Id>());
                    }
                    projIdAndStdIds.get(ca.Project__c).add(ca.Candidate_Name__c);
                    allStdIds.add(ca.Candidate_Name__c);
                }
                
                // All the projects under this student
                if(stdIds.contains(ca.Candidate_Name__c)){
                   
                    remProjIds.add(ca.Project__c);
                }
            }
            
            if(remProjIds.size() > 0){
            
                // All the students under this project
                for(Contact_Assignments__c ca : [SELECT Id, Project__c, Candidate_Name__c
                    FROM Contact_Assignments__c
                    WHERE Status__c = 'Active' AND RecordType.DeveloperName = 'Student' AND Project__c IN : remProjIds
                ]){
                    if(!projIdAndStdIds.containsKey(ca.Project__c)){
                        projIdAndStdIds.put(ca.Project__c, new Set<Id>());
                    }
                    projIdAndStdIds.get(ca.Project__c).add(ca.Candidate_Name__c);
                    allStdIds.add(ca.Candidate_Name__c);
                }
            }
            if(stdIdAndPDODates != NULL && stdIdAndPDODates.size() > 0){
            
                Map<Id, Set<Date>> oldStdIdAndPDODates = new Map<Id, Set<Date>>();
                Map<String, Set<Date>> stdIdProjInfo_OldPDODates = new Map<String, Set<Date>>();
                
                // To get existing PDOs details for all the students
                for(Planned_Days_Off__c oldP : [SELECT Id, Contact__c, Date__c, Project__c, All_Projects__c
                                                    FROM Planned_Days_Off__c
                                                    WHERE Contact__c IN : allStdIds AND (Project__c IN :projIdAndStdIds.keySet() OR 
                                                        All_Projects__c = TRUE)]){
                                                        
                    if(!oldStdIdAndPDODates.containsKey(oldP.Contact__c)){
                    
                        oldStdIdAndPDODates.put(oldP.Contact__c, new Set<Date>());
                    }
                    oldStdIdAndPDODates.get(oldP.Contact__c).add(oldP.Date__c);
                    
                    String stdIdProjInfo = oldP.Contact__c+'-'+(oldP.Project__c != null ? String.valueOf(oldP.Project__c) : 'True');
                    if(!stdIdProjInfo_OldPDODates.containsKey(stdIdProjInfo)){
                    
                        stdIdProjInfo_OldPDODates.put(stdIdProjInfo, new Set<Date>());
                    }
                    stdIdProjInfo_OldPDODates.get(stdIdProjInfo).add(oldP.Date__c);
                }
                if(isNew){
                    // To update related event's status as canceled for new date range
                    updateEvents = updateEventTo_Canceled(stdIdAndPDODates, projIdAndStdIds, oldStdIdAndPDODates);
                }
                if(!isNew){
                    // To update related event's status as scheduled for old date range
                    updateEvents = updateEventTo_Scheduled(stdIdAndPDODates, projIdAndStdIds, stdIdProjInfo_OldPDODates);
                }
            }            
        }
        return updateEvents;
    }
    
    public static List<Events__c> updateEventTo_Canceled(Map<Id, Set<Date>> stdIdAndPDODates, Map<Id, Set<Id>> projIdAndStdIds, Map<Id, Set<Date>> oldStdIdAndPDODates){
        
        List<Events__c> updateEvents = new List<Events__c>();
        Map<Id, Set<Date>> projIdAndCancelledDates = new Map<Id, Set<Date>>();
        Set<Date> cancelledDates = new Set<Date>();
        
        // if all the students under a project are having PDO for specific date then the event record will updated as Canceled
        for(Id newStdId : stdIdAndPDODates.keySet()){
                
            for(Date newDate : stdIdAndPDODates.get(newStdId)){
            
                for(Id projId : projIdAndStdIds.keySet()){
                    
                    if(projIdAndStdIds.get(projId).size() > 1){
                    
                        Boolean isLeave = TRUE;
                        for(Id allStdId : projIdAndStdIds.get(projId)){
                        
                            if(newStdId != allStdId && (!oldStdIdAndPDODates.containsKey(allStdId) || 
                                (oldStdIdAndPDODates.containsKey(allStdId) && 
                                !oldStdIdAndPDODates.get(allStdId).contains(newDate)))){
                            
                                isLeave = FALSE;
                                break;
                            }
                            if(oldStdIdAndPDODates.containsKey(allStdId) && oldStdIdAndPDODates.get(allStdId).contains(newDate)){
                            
                                isLeave = TRUE;
                            }
                        }
                        if(isLeave){
                            
                            if(!projIdAndCancelledDates.containsKey(projId)){
                            
                                projIdAndCancelledDates.put(projId, new Set<Date>());
                            }    
                            projIdAndCancelledDates.get(projId).add(newDate);
                            cancelledDates.add(newDate);
                        }
                    }else if(projIdAndStdIds.get(projId).size() == 1){
                    
                        if(!projIdAndCancelledDates.containsKey(projId)){
                            
                            projIdAndCancelledDates.put(projId, new Set<Date>());
                        }    
                        projIdAndCancelledDates.get(projId).add(newDate);
                        cancelledDates.add(newDate);
                    }
                }
            }
        }
        // Static Map to prevent override of Event's status value when the specific date is present at both new and old range
        projIdAndCancellationDates_Map.putAll(projIdAndCancelledDates);
        
        for(Events__c e : [SELECT Id, Status__c, Project__c, Date__c FROM Events__c WHERE Project__c IN : projIdAndCancelledDates.keySet() AND Date__c IN : cancelledDates]){
            if(projIdAndCancelledDates.containsKey(e.Project__c) && projIdAndCancelledDates.get(e.Project__c).contains(e.Date__c) && e.Status__c == 'Scheduled'){
                if(!updateEveRecsMap.containsKey(e.Id)){
                    e.Status__c = 'Canceled';
                    updateEvents.add(e); 
                    updateEveRecsMap.put(e.Id, e);
                }
            }   
        } 
        return updateEvents;
    }
    
    public static List<Events__c> updateEventTo_Scheduled(Map<Id, Set<Date>> stdIdAndPDODates, Map<Id, Set<Id>> projIdAndStdIds, Map<String, Set<Date>> stdIdProjInfo_OldPDODates){
        
        List<Events__c> updateEvents = new List<Events__c>();
        Map<Id, Set<Date>> projIdAndScheduledDates = new Map<Id, Set<Date>>();
        Set<Date> scheduledDates = new Set<Date>();
        
        // if any one of the student under a project aren't having PDO for specific date then the event record will updated as Scheduled
        for(Id newStdId : stdIdAndPDODates.keySet()){
            
            for(Date newDate : stdIdAndPDODates.get(newStdId)){
                
                for(Id projId : projIdAndStdIds.keySet()){
                    
                    Boolean allStdAvailable = False;
                    
                    for(Id allStdId : projIdAndStdIds.get(projId)){
                        
                        String str1 = allStdId+'-'+projId;
                        String str2 = allStdId+'-'+'True';
                        
                        if((!stdIdProjInfo_OldPDODates.containsKey(str1) || (stdIdProjInfo_OldPDODates.containsKey(str1) && !stdIdProjInfo_OldPDODates.get(str1).contains(newDate))) || 
                            (!stdIdProjInfo_OldPDODates.containsKey(str2) || (stdIdProjInfo_OldPDODates.containsKey(str2) && !stdIdProjInfo_OldPDODates.get(str2).contains(newDate)))){
                        
                            allStdAvailable = True;
                            Break;
                        }
                    }
                    if(allStdAvailable){
                        
                        if(!projIdAndScheduledDates.containsKey(projId)){
                        
                            projIdAndScheduledDates.put(projId, new Set<Date>());
                        }    
                        projIdAndScheduledDates.get(projId).add(newDate);
                        scheduledDates.add(newDate);
                    }
                }
            }
        }
        for(Events__c e : [SELECT Id, Status__c, Project__c, Date__c FROM Events__c WHERE Project__c IN : projIdAndScheduledDates.keySet() AND Date__c IN : scheduledDates]){
            if(!projIdAndCancellationDates_Map.containsKey(e.Project__c) || (projIdAndCancellationDates_Map.containsKey(e.Project__c) && !projIdAndCancellationDates_Map.get(e.Project__c).contains(e.Date__c))){
                if(projIdAndScheduledDates.containsKey(e.Project__c) && projIdAndScheduledDates.get(e.Project__c).contains(e.Date__c) && e.Status__c == 'Canceled'){
                    if(!updateEveRecsMap.containsKey(e.Id)){
                        e.Status__c = 'Scheduled';
                        updateEvents.add(e);
                        updateEveRecsMap.put(e.Id, e);
                    } 
                }   
            }
        } 
        return updateEvents;
    }
    

    //To update parent pdo's From Date and To Date value while updating child pdo's status as 'Delete'
    public static void updateParentPDO(Set<Id> parentPDOIds){
    
        Map<Id, Date> parentPDOIdAndFromDate = new Map<Id, Date>();
        Map<Id, Date> parentPDOIdAndToDate = new Map<Id, Date>();
        Map<Id, Planned_Days_Off__c> updateParentPDOs = new Map<Id, Planned_Days_Off__c>();
        
        for(Planned_Days_Off__c childPDO : [SELECT Id, Date__c, Parent_Planned_Day_Off__c FROM Planned_Days_Off__c WHERE Parent_Planned_Day_Off__c IN : parentPDOIds AND Status__c != 'Delete' ORDER BY Date__c ASC]){
            
            //First record's Date value would be the From Date of Parent PDO
            if(!parentPDOIdAndFromDate.containsKey(childPDO.Parent_Planned_Day_Off__c)){
                parentPDOIdAndFromDate.put(childPDO.Parent_Planned_Day_Off__c, childPDO.Date__c);
            }  
            //This map filled with last child record's Date value so it would be the To Date of Parent PDO
            parentPDOIdAndToDate.put(childPDO.Parent_Planned_Day_Off__c, childPDO.Date__c);      
        }
        for(Planned_Days_Off__c parentPDO : [SELECT Id, From_Date__c, To_Date__c FROM Planned_Days_Off__c WHERE Id IN : parentPDOIds]){    
                                                                        
            if(parentPDOIdAndFromDate.containsKey(parentPDO.Id) && parentPDO.From_Date__c != parentPDOIdAndFromDate.get(parentPDO.Id)){
                parentPDO.From_Date__c = parentPDOIdAndFromDate.get(parentPDO.Id);
                updateParentPDOs.put(parentPDO.Id, parentPDO);
            }
            if(parentPDOIdAndToDate.containsKey(parentPDO.Id) && parentPDO.To_Date__c != parentPDOIdAndToDate.get(parentPDO.Id)){
                parentPDO.To_Date__c = parentPDOIdAndToDate.get(parentPDO.Id);
                updateParentPDOs.put(parentPDO.Id, parentPDO);
            }
        }
        if(updateParentPDOs.size() > 0){
            update updateParentPDOs.values();
        }
    }
    
    /***********
        - Created By HL on June 09 2022
        - W-007484 - Plan Days off Auto Email Process Issue
        - To send an email to instructor when student submitting a Request Planned Days Off
        ******************/
    public static void sendStudentPDOEmailToInstructor(List<Planned_Days_Off__c> pdoRecs){
    
        Set<Id> studentIds = new Set<Id>();
        Set<Id> stdProjIds = new Set<Id>();
        Set<Date> fromDates = new Set<Date>();
        Set<Date> toDates = new Set<Date>();
        List<Planned_Days_Off__c> stdRequest = new List<Planned_Days_Off__c>();
            
        for(Planned_Days_Off__c p : pdoRecs){
            
            if(p.Project__c == NULL && p.All_Projects__c){
                
                studentIds.add(p.Contact__c);
                stdRequest.add(p);
            }
            if(p.Project__c != NULL){
           
                stdProjIds.add(p.Project__c);
                stdRequest.add(p);
            }
            if(p.From_Date__c != null){
                fromDates.add(p.From_Date__c);
            }
            if(p.To_Date__c != null){
                toDates.add(p.To_Date__c);
            }
        }       
        
        if(studentIds.size()  > 0 || stdProjIds.size() > 0){
            
            Map<Id, List<Planned_Days_Off__c>> insIdAndPDORequest = new Map<Id, List<Planned_Days_Off__c>>();
            
            insIdAndPDORequest = getStudentPDORelatedInstructors(studentIds, stdProjIds, stdRequest, fromDates, toDates);
            
            try{
            
                String mailContent = '';
                Boolean hasBouncedEmail = FALSE;
                
                // Added on Dec 08 2023 : W-007943 : Update to DLS Online PDO Request Email Template
                List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
                                
                String orgWideEmailId = '';
                
                if(orgWideEmail != null && orgWideEmail.size() > 0){
                    orgWideEmailId = orgWideEmail[0].Id;
                }

                List<Messaging.SingleEmailMessage> emailToSend = new List<Messaging.SingleEmailMessage>();
                
                Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :insIdAndPDORequest.keySet()]);
                
                EmailTemplate stdPDOToIns = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Student_PDO_Request_Email_To_Instructor'];
                
                for(Id insId : conIdRec.keySet()){
                    
                    if(!conIdRec.get(insId).IsEmailBounced){
                    
                        if(insIdAndPDORequest.containsKey(insId)){
                                        
                            for(Planned_Days_Off__c insReq : insIdAndPDORequest.get(insId)){
                            
                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                mail.setOrgWideEmailAddressId(orgWideEmailId);
                                mail.setTargetObjectId(insId);
                                mail.setTemplateID(stdPDOToIns.Id);
                                mail.setWhatId(insReq.Id);
                                mail.setSaveAsActivity(TRUE);
                                emailToSend.add(mail);
                            }
                        }
                    }else{
                    
                        mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(insId).Id+'" target="_blank">'+conIdRec.get(insId).Name+'</a><br/>';
                        hasBouncedEmail = true;
                    }
                }
                if(hasBouncedEmail || Test.isRunningTest()){
                    
                    Messaging.SingleEmailMessage bouncedmail = ErrorHandler.getBouncedEmail(mailContent);
                    emailToSend.add(bouncedmail);
                }
            
                if( emailToSend != NULL && emailToSend.size() > 0 ) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToSend);
                }
                                
            }catch(Exception e) {
                
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on Student Planned Days off Request Email to Instructors');
            } 
        }
    }
    
    /*******************
        - Added By HL on June 30 2022
        - Work Item: W-007484 - Plan Days off Auto Email Process Issue
        - This method is used to get all active instructors who are related to the students when they have All_Projects__c value as true
        ****************/
    public static Map<Id, List<Planned_Days_Off__c>> getStudentPDORelatedInstructors(Set<Id> studentIds, Set<Id> stdProjIds, List<Planned_Days_Off__c> stdRequest, Set<Date> fromDates, Set<Date> toDates){
    
        Map<Id, Set<Date>> insIdAndEventDates = new Map<Id, Set<Date>>();
        Map<Id, List<Planned_Days_Off__c>> insIdAndPDORequest = new Map<Id, List<Planned_Days_Off__c>>();
            
        if(studentIds != null && studentIds.size()  > 0){
            
            for(Contact_Assignments__c ins : [SELECT Id, Project__c
                                                FROM Contact_Assignments__c
                                                WHERE Candidate_Name__c IN : studentIds AND Status__c = 'Active' AND RecordType.DeveloperName = 'Student'
                                                    AND Project__c != NULL AND Project__r.AcctSeed__Status__c = 'Active']){
                stdProjIds.add(ins.Project__c);
            }
        }     
        if(stdProjIds != null && stdProjIds.size() > 0){
                    
            String eveQryStr = 'SELECT Id, Instructor__c, Date__c FROM Events__c WHERE Project__c IN : stdProjIds';
            if(fromDates.size() > 0 && toDates.size() > 0){
                eveQryStr += ' AND (Date__c >= : fromDates AND Date__c <= : toDates)';
            }else if(fromDates.size() > 0){
                eveQryStr += ' AND Date__c IN : fromDates';
            }
            List<Events__c> events = Database.Query(eveQryStr);
        
            if(events != null && events.size() > 0){
        
                for(Events__c e : events){
                    
                    if(!insIdAndEventDates.containsKey(e.Instructor__c)){
                        insIdAndEventDates.put(e.Instructor__c, new Set<Date>());
                    }
                    insIdAndEventDates.get(e.Instructor__c).add(e.Date__c);
                }
            }
        
            for(Contact_Assignments__c iCA : [SELECT Id, Candidate_Name__c, Start_Date__c, End_Date__c
                                                FROM Contact_Assignments__c 
                                                WHERE Status__c = 'Active' AND RecordType.DeveloperName = 'Instructor' AND 
                                                    Project__c IN : stdProjIds AND Project__r.AcctSeed__Status__c = 'Active' AND Candidate_Name__r.Email != null]){
                for(Planned_Days_Off__c p : stdRequest){
                
                    if((p.From_Date__c != NULL && p.To_Date__c != NULL && iCA.Start_Date__c <= p.From_Date__c && 
                        (iCA.End_Date__c >= p.To_Date__c || iCA.End_Date__c <= p.To_Date__c)) || (p.From_Date__c != NULL && 
                        p.To_Date__c == NULL && iCA.Start_Date__c <= p.From_Date__c && 
                        (iCA.End_Date__c >= p.From_Date__c || iCA.End_Date__c <= p.From_Date__c))){
                    
                        Date fromDate = p.From_Date__c;
                        Date todate = p.To_Date__c != null ? p.To_Date__c : p.From_Date__c;
                        
                        Boolean hasEvent = False;
                        while(fromDate <= todate){
                                                    
                            // To send an email to instructors who is scheduled to teach on the day the student has an approved planned days off
                            if(insIdAndEventDates.containsKey(iCA.Candidate_Name__c) && insIdAndEventDates.get(iCA.Candidate_Name__c).contains(fromDate)){
                                hasEvent = True;
                                break;                              
                            }
                            fromDate = fromDate.addDays(1);
                        }
                        if(hasEvent){
                            if(!insIdAndPDORequest.containsKey(iCA.Candidate_Name__c)){
                                insIdAndPDORequest.put(iCA.Candidate_Name__c, new List<Planned_Days_Off__c>());
                            }
                            insIdAndPDORequest.get(iCA.Candidate_Name__c).add(p);
                        }                        
                    }
                }        
            }
        }
        return insIdAndPDORequest;
    }
    
    /**************
        - Added By HL on Oct 27 2022
        - W-007609 : Email Notifications when PDO entered from Project
        - To send an email notification to the instructors / students when a Planned Days Off is entered from the Project page directly by an internal user
        ***********/
    public static void pdoApprovalEmailByInternalUser(List<Planned_Days_Off__c> pdoRecs){
    
        Set<Id> projIds = new Set<Id>();
        
        Map<Id, Set<Id>> projIdAndInsIds = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> projIdAndStdIds = new Map<Id, Set<Id>>();
        
        Map<String, String> conIdProjIdAndType = new Map<String, String>();
        Map<Id, String> projIdAndDLSClassNo = new Map<Id, String>();
        Set<Id> allContactIds = new Set<Id>();
        Map<String, List<Planned_Days_Off__c>> conIdProjIdAndPDORecs = new Map<String, List<Planned_Days_Off__c>>();
        
        for(Planned_Days_Off__c pdo: pdoRecs){
            
            projIds.add(pdo.Project__c);
            
            String conIdProjId = pdo.Contact__c+'-'+pdo.Project__c;
            conIdProjIdAndType.put(conIdProjId, pdo.Type__c);
            
            if(!conIdProjIdAndPDORecs.containsKey(conIdProjId)){
                conIdProjIdAndPDORecs.put(conIdProjId, new List<Planned_Days_Off__c>());
            }
            conIdProjIdAndPDORecs.get(conIdProjId).add(pdo);
        }
        
        for(Contact_Assignments__c ca : [SELECT Id, Project__c, Candidate_Name__c, Project__r.DLS_Ref__c, RecordType.DeveloperName
            FROM Contact_Assignments__c
            WHERE Project__c IN : projIds AND Status__c = 'Active' AND RecordType.DeveloperName IN ('Instructor', 'Student')]){
        
            if(ca.RecordType.DeveloperName == 'Instructor'){
                if(!projIdAndInsIds.containsKey(ca.Project__c)){
                    projIdAndInsIds.put(ca.Project__c, new Set<Id>());
                }
                projIdAndInsIds.get(ca.Project__c).add(ca.Candidate_Name__c);
            }
            
            if(ca.RecordType.DeveloperName == 'Student'){
                if(!projIdAndStdIds.containsKey(ca.Project__c)){
                    projIdAndStdIds.put(ca.Project__c, new Set<Id>());
                }
                projIdAndStdIds.get(ca.Project__c).add(ca.Candidate_Name__c);
            }
            
            allContactIds.add(ca.Candidate_Name__c);
            projIdAndDLSClassNo.put(ca.Project__c, ca.Project__r.DLS_Ref__c);
        }
        
        try{
            
            String logged_In_User_Name = (UserInfo.getFirstName() != null ? (UserInfo.getFirstName()+ ' ' + UserInfo.getLastName()) :  UserInfo.getLastName());
            
            String mailContent = '';
            Boolean hasBouncedEmail = FALSE;
        
            List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
            
            Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id, FirstName, Name, Email, IsEmailBounced FROM Contact WHERE Id IN : allContactIds AND Email != null]);
                            
            List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
                
            String orgWideEmailId = '';
            
            if(orgWideEmail != null && orgWideEmail.size() > 0){
                orgWideEmailId = orgWideEmail[0].Id;
            }
            
            for(String conIdProjId : conIdProjIdAndType.keySet()){
                
                Id contId = conIdProjId.split('-')[0];
                Id projId = conIdProjId.split('-')[1];
                    
                if(contactMap.containsKey(contId)){
                                    
                    String generic_Sub_1 = logged_In_User_Name + ' has Approved your planned day(s) off';
                    String generic_Sub_2 = contactMap.get(contId).Name + ' have Approved planned day(s) off';
                    
                    String generic_Mail_Content_1 = '';
                    String generic_Mail_Content_2 = '';
                    String generic_Table_Content = '';
                    
                    generic_Mail_Content_1 += 'This email is to notify you that '+ logged_In_User_Name +' has Approved the planned days off for:<br/>';
                    generic_Mail_Content_2 += 'This email is to notify you that '+ contactMap.get(contId).Name +' have Approved planned days off for:<br/>';
                    generic_Table_Content += '<br/><table border="1" style="border-collapse: collapse"><tr><th width="25%" style="text-align: center; vertical-align: middle;">Date</th><th width="25%" style="text-align: center; vertical-align: middle;">Type</th><th width="25%" style="text-align: center; vertical-align: middle;">Description</th><th width="25%" style="text-align: center; vertical-align: middle;">DLS class #</th></tr>';
                    
                    for(Planned_Days_Off__c pdo : conIdProjIdAndPDORecs.get(conIdProjId)){
                            
                        generic_Table_Content += '<tr><td style="text-align: center; vertical-align: middle;">' + pdo.Date_Range__c + '</td><td style="text-align: center; vertical-align: middle;">' + pdo.Type__c + '</td><td style="text-align: center; vertical-align: middle;">' + pdo.Description__c + '</td><td style="text-align: center; vertical-align: middle;">' + projIdAndDLSClassNo.get(pdo.Project__c) + '</td></tr>';    
                    }
                    generic_Table_Content += '</table>';
                    
                    String urlLink = '';
                    if(conIdProjIdAndType.get(conIdProjId) == 'Instructor'){
                        urlLink = System.Label.Instructor_Community_Site_Prefix;
                    }else if(conIdProjIdAndType.get(conIdProjId) == 'Student'){
                        urlLink = System.Label.Student_Community_Site_Prefix;
                    }
                    
                    String generic_URL_Link = '';
                    generic_URL_Link += '<br/>Please <a href="'+ urlLink +'/s/planned-days-off" target="_blank"> Click Here </a> to view the planned days off.<br/>';
                    
                    String generic_Mail_End_Content = '';
                    generic_Mail_End_Content += '<br/>Please contact your LTS with any questions or concerns.';
                    generic_Mail_End_Content += '<br/><br/>Thank you,<br/><br/>DLS<br/>System Generated Email';
                                    
                    if(conIdProjIdAndType.get(conIdProjId) == 'Instructor'){
                    
                        List<Messaging.SingleEmailMessage> emailList_1 = getEmailList(projIdAndStdIds, contactMap, projId, contId, orgWideEmailId, generic_Sub_1, generic_Sub_2, generic_Mail_Content_1, generic_Mail_Content_2, generic_Table_Content, generic_URL_Link, generic_Mail_End_Content);
                        sendEmailList.addAll(emailList_1);
                        
                    }else if(conIdProjIdAndType.get(conIdProjId) == 'Student'){
                        
                        List<Messaging.SingleEmailMessage> emailList_2 = getEmailList(projIdAndInsIds, contactMap, projId, contId, orgWideEmailId, generic_Sub_1, generic_Sub_2, generic_Mail_Content_1, generic_Mail_Content_2, generic_Table_Content, generic_URL_Link, generic_Mail_End_Content);
                        sendEmailList.addAll(emailList_2);
                    }
                }
            }
            
            if( sendEmailList != NULL && sendEmailList.size() > 0 ) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailList);
            }
            
        }catch(Exception e) {
                        
            String errorMessage = '';
            errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
            
            ErrorHandler errHandler = new ErrorHandler();
            errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on PDO Approval Email By Internal User');
        } 
    }
    
    public static List<Messaging.SingleEmailMessage> getEmailList(Map<Id, Set<Id>> projIdAndConIds, Map<Id,Contact> contactMap, Id projId, Id primary_ConId, String orgWideEmailId, String generic_Sub_1, String generic_Sub_2, String primary_Mail_Content, String secondary_Mail_Content, String generic_Table_Content, String generic_URL_Link, String generic_Mail_End_Content){
        
        List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage primary_mail = new Messaging.SingleEmailMessage();
        primary_mail.setOrgWideEmailAddressId(orgWideEmailId);
        primary_mail.setTargetObjectId(primary_ConId);     
            
        primary_mail.subject = generic_Sub_1;
                        
        String primary_mail_htmlBody = '';
        primary_mail_htmlBody += 'Dear '+ contactMap.get(primary_ConId).FirstName + ', <br/><br/>';
        primary_mail_htmlBody += primary_Mail_Content;
        primary_mail_htmlBody += generic_Table_Content;
        primary_mail_htmlBody += generic_URL_Link;
        primary_mail_htmlBody += generic_Mail_End_Content;
        
        primary_mail.setHtmlBody(primary_mail_htmlBody);
        primary_mail.setSaveAsActivity(true);
        sendEmailList.add(primary_mail);
        
        if(projIdAndConIds.containsKey(projId)){
                    
            for(Id stdId : projIdAndConIds.get(projId)){
                
                if(contactMap.containsKey(stdId)){
                
                    Messaging.SingleEmailMessage secondary_mail = new Messaging.SingleEmailMessage();
                    secondary_mail.setOrgWideEmailAddressId(orgWideEmailId);
                    secondary_mail.setTargetObjectId(stdId);
                    
                    secondary_mail.subject = generic_Sub_2;
                    
                    String secondary_mail_htmlBody = '';
                    secondary_mail_htmlBody += 'Dear '+ contactMap.get(stdId).FirstName + ', <br/><br/>';
                    secondary_mail_htmlBody += secondary_Mail_Content;
                    secondary_mail_htmlBody += generic_Table_Content;
                    secondary_mail_htmlBody += generic_Mail_End_Content;
                        
                    secondary_mail.setHtmlBody(secondary_mail_htmlBody);
                    secondary_mail.setSaveAsActivity(true);
                    sendEmailList.add(secondary_mail);
                }
            }    
        }
                    
        return sendEmailList;
    }
    
    public static void cancelInstructorPDORelatedEvents(List<Planned_Days_Off__c> ins_pdoRecs){
            
        if(ins_pdoRecs.size() > 0){
            
            Map<Id, Set<Date>> insIdAndPDODates = new Map<Id, Set<Date>>();
            Set<Id> projIds = new Set<Id>();
            
            Set<Id> insIds = new Set<Id>();
            Set<Date> pdoDates = new Set<Date>();
            List<Events__c> updateEvents = new List<Events__c>();
            
            for(Planned_Days_Off__c p : ins_pdoRecs){
                            
                if(p.Contact__c != NULL && p.Date__c != NULL){
                
                    if(p.Project__c != NULL){
                        projIds.add(p.Project__c);
                    }
                    
                    if(p.Project__c == NULL && p.All_Projects__c){
                        insIds.add(p.Contact__c);
                    }
                                
                    if(!insIdAndPDODates.containsKey(p.Contact__c)){
                        insIdAndPDODates.put(p.Contact__c, new Set<Date>());
                    }
                    insIdAndPDODates.get(p.Contact__c).add(p.Date__c);
                    
                    pdoDates.add(p.Date__c);
                }
            }       
            
            if(insIds.size() > 0){
            
                for(Contact_Assignments__c ca : [SELECT Id, Project__c
                    FROM Contact_Assignments__c
                    WHERE Status__c = 'Active' AND RecordType.DeveloperName = 'Instructor' AND Candidate_Name__c IN : insIds
                ]){
                    projIds.add(ca.Project__c);
                }
            }     
            
            if(projIds.size() > 0){
                
                for(Events__c e : [SELECT Id, Status__c, Instructor__c, Date__c FROM Events__c WHERE Project__c IN : projIds AND Date__c IN : pdoDates AND Instructor__c IN : insIdAndPDODates.keySet() AND Status__c = 'Scheduled']){
                
                    if(insIdAndPDODates.containsKey(e.Instructor__c) && insIdAndPDODates.get(e.Instructor__c).contains(e.Date__c)){
                        
                        e.Status__c = 'Canceled';  
                        updateEvents.add(e);
                    }
                }
            }
            if(updateEvents.size() > 0){
               
               update updateEvents; 
            }
        }    
    }
    
    /*************
        - Added on Dec 08 2022
        - W-007560 : Create Task when an Instructor PDO is Approved (DEC-15-2022)
        - To create a Task which is related to the project(s) when instructor PDO is approved
        ************/
    public static void create_Update_DeleteTaskRelatedToProject(List<Planned_Days_Off__c> pdoRecs, Boolean is_Create, Boolean is_Update, Boolean is_Delete){
        
        Set<Id> conIds = new Set<Id>();
        Set<Id> projIds = new Set<Id>();
        
        Set<Id> allConIds = new Set<Id>();
        Map<Id, Set<Id>> conIdAndProjIds = new Map<Id, Set<Id>>();
        List<Task> taskList = new List<Task>();
        
        for(Planned_Days_Off__c pdo: pdoRecs){
            
            if(pdo.Contact__c != null){
                
                if(pdo.Project__c == null && pdo.All_Projects__c){
                
                     conIds.add(pdo.Contact__c);   
                }
                if(pdo.Project__c != null){
                
                    projIds.add(pdo.Project__c);
                    
                    if(!conIdAndProjIds.containsKey(pdo.Contact__c)){
                        conIdAndProjIds.put(pdo.Contact__c, new Set<Id>());
                    }
                    conIdAndProjIds.get(pdo.Contact__c).add(pdo.Project__c);
                }
                allConIds.add(pdo.Contact__c);
            }
        }    
        
        if(conIds.size()  > 0){
            
            for(Contact_Assignments__c ins : [SELECT Id, Project__c, Candidate_Name__c
                                                FROM Contact_Assignments__c
                                                WHERE Candidate_Name__c IN : conIds AND Status__c = 'Active' AND 
                                                RecordType.DeveloperName = 'Instructor' AND Project__r.AcctSeed__Status__c = 'Active']){
            
                if(!conIdAndProjIds.containsKey(ins.Candidate_Name__c)){
                    conIdAndProjIds.put(ins.Candidate_Name__c, new Set<Id>());
                }
                conIdAndProjIds.get(ins.Candidate_Name__c).add(ins.Project__c);
                projIds.add(ins.Project__c);                
            }
        }
        
        Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, Name FROM Contact WHERE Id IN :allConIds]);
        
        if(is_Create){
            
            // Added on Aug 18 2023 - W-007864 : Request to Allow Team Members of the Same Department to Mark Task Assigned to Project Manager as "Complete"
            // Assign task to queue(group) to allow team members to mark as complete
            List<QueueSObject> queueRec = [SELECT Id, QueueId FROM QueueSObject WHERE Queue.Type ='Queue' AND Queue.Name = 'LTS' LIMIT 1];
            
            for(Planned_Days_Off__c pdo: pdoRecs){
                
                if(conIdAndProjIds.containsKey(pdo.Contact__c)){
                    
                    for(Id projId : conIdAndProjIds.get(pdo.Contact__c)){
                    
                        Task t = new Task();
                        if(queueRec.size() > 0){
                           t.OwnerId = queueRec[0].QueueId; 
                        }
                        t.WhoId = pdo.Contact__c;
                        t.WhatId = projId;
                        t.Status = 'Not Started';
                        t.Subject = 'Reminder '+ conIdRec.get(pdo.Contact__c).Name +' has a PDO for '+ pdo.Date_Range__c;
                        Date dueDate = pdo.From_Date__c.addDays(-14);                    
                        t.ActivityDate = (dueDate < Date.Today() ? Date.Today().addDays(1) : dueDate);
                        t.Description = 'Please find a Substitute Instructor';
                        taskList.add(t);    
                    }
                }
            }
            
            if(taskList.size() > 0){
                insert taskList;
            }
        }
        if(is_Update){
            
            Map<String, Task> whoIdwhatIdAndTask = new Map<String, Task>();
            
            for(Task t : [SELECT Id, WhoId, WhatId FROM Task WHERE WhoId IN : allConIds AND WhatId IN : projIds]){
                
                String whoIdAndWhatId = t.WhoId+'-'+t.WhatId;
                whoIdwhatIdAndTask.put(whoIdAndWhatId, t);
            }
            
            if(whoIdwhatIdAndTask.size() > 0){
            
                for(Planned_Days_Off__c pdo: pdoRecs){
                    
                    if(conIdAndProjIds.containsKey(pdo.Contact__c)){
                        
                        for(Id projId : conIdAndProjIds.get(pdo.Contact__c)){
                        
                            String whoIdAndWhatId = pdo.Contact__c+'-'+projId;
                            
                            if(whoIdwhatIdAndTask.containsKey(whoIdAndWhatId)){
                                
                                Task t = new Task();
                                t.Id = whoIdwhatIdAndTask.get(whoIdAndWhatId).Id;
                                Date dueDate = pdo.From_Date__c.addDays(-14);                    
                                t.ActivityDate = (dueDate < Date.Today() ? Date.Today().addDays(1) : dueDate);
                                taskList.add(t);    
                            }
                        }
                    }
                }
            }
            
            if(taskList.size() > 0){
                update taskList;
            }
        }
        if(is_Delete){
        
            taskList = [SELECT Id FROM Task WHERE WhoId IN : allConIds AND WhatId IN : projIds];
            
            if(taskList.size() > 0){
                delete taskList;
            }
        }
    }
    
    public class UpdateEveRecs{
    
        public Map<Id, Set<Date>> projIdAndCancelledDates;
        public Set<Date> cancelledDates;
    }
    
    public class PDOInstructors{
    
        public Map<Id, Set<Id>> projIdAndInsIds;
        public Map<Id, Set<Id>> stdIdAndInsIds;
        public Set<Id> allInsIds;
    }
}