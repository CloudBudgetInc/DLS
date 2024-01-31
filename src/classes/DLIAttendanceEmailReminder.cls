/****************
    - Added by HL on Apr 23 2020
    - Work Item : W-005309 - Email Reminders for DLI Attendance
    - To send an email notification to the class leaders to notify to complete their Attendance if it has not been completed
    - Email Template : Dynamic HTML template
    - This scheduler runs daily basis (@ 6 AM, @ 11 AM and @ 1 PM)
    - Updated the scheduler timing based on W-007478 by NS on Jun 20 2022 (@ 6 AM, @ 09.30 AM and @ 11 AM)
    ******************/
    
public class DLIAttendanceEmailReminder implements Schedulable{

    public void execute(SchedulableContext sc) {
    
        Map<Id, AcctSeed__Project__c> projMap = new Map<Id, AcctSeed__Project__c>();
        
        if(!Test.isRunningTest()){
            
            projMap = new Map<Id, AcctSeed__Project__c>([SELECT Id, Name, DLS_Class__c 
                                                            FROM AcctSeed__Project__c 
                                                            WHERE Id IN (SELECT Project__c FROM Events__c WHERE Date__c = TODAY AND 
                                                                Status__c IN ('Scheduled','Completed') AND Project__r.RecordType.DeveloperName = 'DLI_W_LT_Projects' AND 
                                                                Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time' AND Project__r.DLI_Project_Type__c  NOT IN ('EI','Partner School') AND 
                                                                Project__r.Training_Location__r.Name = 'DLS - Online') AND 
                                                                RecordType.DeveloperName = 'DLI_W_LT_Projects' AND DLI_Project_Type__c NOT IN ('EI','Partner School') AND 
                                                                Training_Location__r.Name = 'DLS - Online']);
        }else if(Test.isRunningTest()){
        
              projMap = new Map<Id, AcctSeed__Project__c>([SELECT Id, Name, DLS_Class__c
                                                            FROM AcctSeed__Project__c 
                                                            WHERE Id IN (SELECT Project__c FROM Events__c WHERE Date__c = TODAY AND 
                                                                Status__c IN ('Scheduled','Completed') AND Project__r.RecordType.DeveloperName = 'DLI_W_LT_Projects' AND 
                                                                Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time' AND Project__r.DLI_Project_Type__c  NOT IN ('EI','Partner School')) AND 
                                                                RecordType.DeveloperName = 'DLI_W_LT_Projects' AND DLI_Project_Type__c NOT IN ('EI','Partner School')]);
        }
        System.debug('::::projMap:::'+projMap);
        System.debug('::::projMap:::'+projMap.size());
        
        if(projMap != NULL && projMap.size() > 0){
            
            Set<Id> existProjIds = new Set<Id>();
            Set<Id> filteredProjIds = new Set<Id>();
            Set<Id> existingDLIAttenEventIds = new Set<Id>();
            
            EventHandler eveHandle = new EventHandler();
            DateTime currentDt = System.now();
            Integer currentTime = eveHandle.convertToMinutes(currentDt.format('h:mm a','America/New_York'));
            Integer time1 = eveHandle.convertToMinutes('06:00 AM');
            Integer time2 = eveHandle.convertToMinutes('09:30 AM');
            Integer time3 = eveHandle.convertToMinutes('11:00 AM');
                        
            //Qry existing DLI Attendance records to check already entered for all DLI Projects
            for(DLI_Attendance__c a : [SELECT Id, Project__c, Event__c FROM DLI_Attendance__c WHERE Date__c = TODAY]){
                
                existProjIds.add(a.Project__c);
                existingDLIAttenEventIds.add(a.Event__c);
            }
            System.debug('::::existProjIds:::'+existProjIds);
            
            for(Id projId : projMap.keySet()){
            
                if(!existProjIds.contains(projId)){
                
                    filteredProjIds.add(projId);
                }  
            }
            System.debug('::::filteredProjIds:::'+filteredProjIds);
            
            if(filteredProjIds != NULL && filteredProjIds.size() > 0){
                                
                List<Messaging.SingleEmailMessage> sendEmailToClassLeaders = new List<Messaging.SingleEmailMessage>();
                
                try{
                    
                    Map<Id, Set<Id>> projIdAndStdIds = new Map<Id, Set<Id>>();
                    Set<Id> allStdIds = new Set<Id>();
                    Map<Id, Id> stdIdAndCAId = new Map<Id, Id>();
                    
                    for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c, Project__c 
                                                        FROM Contact_Assignments__c
                                                        WHERE Project__c IN : filteredProjIds AND RecordType.DeveloperName = 'Student' AND 
                                                            Status__c = 'Active' AND Candidate_Name__r.Email != NULL]){
                    
                        if(!projIdAndStdIds.containsKey(ca.Project__c)){
                        
                            projIdAndStdIds.put(ca.Project__c, new Set<Id>());
                        }    
                        projIdAndStdIds.get(ca.Project__c).add(ca.Candidate_Name__c);
                        allStdIds.add(ca.Candidate_Name__c);
                        
                        if(!stdIdAndCAId.containsKey(ca.Candidate_Name__c)){
                            stdIdAndCAId.put(ca.Candidate_Name__c, ca.Id);
                        }
                    }
                    System.debug('::::projIdAndStdIds::::'+projIdAndStdIds);
                    
                    if(projIdAndStdIds != NULL && projIdAndStdIds.size() > 0){
                        
                        Map<Id, Id> projIdAndInsId = new Map<Id, Id>();
                        Map<Id, Id> projIdAndEveId = new Map<Id, Id>();
                        
                        Set<Id> offStdIds = new Set<Id>();
                        Set<Id> allProjStdIds = new Set<Id>();
                        Map<Id, String> stdIdAndDescription = new Map<Id, String>();
                        Map<Id, Id> stdIdAndProjId = new Map<Id, Id>();
                        List<DLI_Attendance__c> createDLIAttenRecs = new List<DLI_Attendance__c>();
                        
                        if((currentTime >= time1 && currentTime < time3) || Test.isRunningTest()){
                        
                            // If the students having planned days off record, then don't send any email notification. Instead of that, need to create DLI Attendance record for those students
                            for(Planned_Days_Off__c p : [SELECT Id, Contact__c, Project__c, All_Projects__c, Description__c, Type__c
                                                            FROM Planned_Days_Off__c
                                                            WHERE Contact__c IN : allStdIds AND Contact__r.RecordType.DeveloperName = 'Student' AND
                                                                Date__c = TODAY AND RecordType.DeveloperName = 'Student_Planned_Days_Off' AND 
                                                                Status__c = 'Approved']){
                                                                
                                if(p.Project__c == NULL && p.All_Projects__c){ 
                                
                                    allProjStdIds.add(p.Contact__c);
                                    stdIdAndDescription.put(p.Contact__c, p.Description__c);
                                    offStdIds.add(p.Contact__c);
                                }
                                
                                if(p.Project__c != NULL && filteredProjIds.contains(p.Project__c) && p.Type__c == 'Student'){
                                
                                    stdIdAndProjId.put(p.Contact__c, p.Project__c);  
                                    stdIdAndDescription.put(p.Contact__c, p.Description__c);
                                    offStdIds.add(p.Contact__c);                          
                                }  
                            }
                            System.debug(':::stdIdAndDescription::::'+stdIdAndDescription);
                            System.debug(':::offStdIds::::'+offStdIds);
                            System.debug(':::allProjStdIds::::'+allProjStdIds);
                            
                            if(allProjStdIds != NULL && allProjStdIds.size() > 0){
                        
                                for(Contact_Assignments__c ca : [SELECT Id, Project__c, Candidate_Name__c
                                                                    FROM Contact_Assignments__c
                                                                    WHERE Candidate_Name__c IN : allProjStdIds AND Status__c = 'Active' AND 
                                                                        RecordType.DeveloperName = 'Student' AND Project__c IN : filteredProjIds]){
                                
                                    stdIdAndProjId.put(ca.Candidate_Name__c, ca.Project__c);
                                    if(!stdIdAndCAId.containsKey(ca.Candidate_Name__c)){
                                        stdIdAndCAId.put(ca.Candidate_Name__c, ca.Id);
                                    }
                                }
                            }
                        }
                        
                        
                        /*Commented By Dhinesh - 27/06/2022 - 
                        //Added by NS on Jun 20 2022 - W-007478
                        //Only create dli attendance & sent reminder notifications for Zoom online class related events 
                        Id zoomRoomId = ZoomUtil.getOnlineRoomId();*/
                        
                        //Qry project related event details for constructing the URL link
                        for(Events__c eve : [SELECT Id, Project__c, Instructor__c 
                                                FROM Events__c 
                                                WHERE Project__c IN :filteredProjIds AND Date__c = TODAY AND Status__c IN ('Scheduled','Completed') AND 
                                                    Project__r.RecordType.DeveloperName = 'DLI_W_LT_Projects' AND 
                                                    Schedule__r.Project_Task__r.Project_Task_Type__c != 'Preparation time' AND 
                                                    Project__r.DLI_Project_Type__c != 'EI' AND Id NOT IN :existingDLIAttenEventIds]){ //AND Room__c = :zoomRoomId
                            
                            if(!projIdAndInsId.containsKey(eve.Project__c)){
                                projIdAndInsId.put(eve.Project__c,eve.Instructor__c);
                            }
                            
                            if(!projIdAndEveId.containsKey(eve.Project__c)){
                                projIdAndEveId.put(eve.Project__c,eve.Id);
                            }
                        }
                        System.debug('::::projIdAndInsId:::'+projIdAndInsId);
                        
                        // Creation of DLI Attendance records
                        if((offStdIds != NULL && offStdIds.size() > 0 && currentTime >= time1 && currentTime < time3) || Test.isRunningTest()){
                            
                            for(Id offStdId : offStdIds){
                            
                                DLI_Attendance__c dliAtt = new DLI_Attendance__c();
                                dliAtt.Attendance__c = FALSE;
                                dliAtt.Attendance_Comment__c = stdIdAndDescription.containsKey(offStdId) ? stdIdAndDescription.get(offStdId) : '';
                                dliAtt.Date__c = System.today();
                                dliAtt.Project__c = stdIdAndProjId.containsKey(offStdId) ? stdIdAndProjId.get(offStdId) : null;
                                dliAtt.Event__c = (dliAtt.Project__c != null && projIdAndEveId.containsKey(dliAtt.Project__c)) ? projIdAndEveId.get(dliAtt.Project__c) : null;
                                dliAtt.Student__c = offStdId;
                                dliAtt.Student_Contact_Assignment__c = stdIdAndCAId.containsKey(offStdId) ? stdIdAndCAId.get(offStdId) : null;
                                dliAtt.Technical_Issue__c = FALSE;
                                dliAtt.Academic_Issue__c = FALSE;
                                createDLIAttenRecs.add(dliAtt);
                            }    
                            System.debug('::::createDLIAttenRecs:::'+createDLIAttenRecs);
                            
                            if(createDLIAttenRecs != NULL && createDLIAttenRecs.size() > 0){
                            
                                insert createDLIAttenRecs;
                            }
                        }                        
                        
                        if(currentTime > time1 || Test.isRunningTest()){
                        
                            Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, FirstName, Name, Email, IsEmailBounced, Salutation FROM Contact WHERE Id IN :allStdIds AND Id NOT IN :offStdIds AND Email != NULL]);
                            System.debug('conIdRec========='+conIdRec+'conIdRec SIZE========'+conIdRec.size());
                            
                            List<OrgWideEmailAddress> orgWideEmail = [SELECT Id, Address FROM OrgWideEmailAddress WHERE DisplayName = 'Attendance@dlsdc.com'];
            
                            String orgWideEmailId = '';
                            
                            if(orgWideEmail != null && orgWideEmail.size() > 0){
                                orgWideEmailId = orgWideEmail[0].Id;
                            }
                                                    
                            Date todayDate = Date.today();
                            String todayStr = String.valueOf(todayDate).split('-')[1]+'/'+String.valueOf(todayDate).split('-')[2]+'/'+String.valueOf(todayDate).split('-')[0];
                    
                            String mailContent = '<html>Hi Chris and April,<br/>The following contacts have bounced email ids, Please correct them: <br/>';
                            Boolean hasBouncedEmail = false;
                            
                            List<Document> documentList = [SELECT Id FROM Document WHERE Name = 'DLS Logo1' LIMIT 1];
                            
                            Id logo_doc_Id;
                            
                            if(documentList.size() > 0){
                                logo_doc_Id = documentList[0].Id;
                            }
                            
                            Id org_Id = [SELECT Id FROM Organization].Id;
                            String logoStr = '<img src="'+URL.getSalesforceBaseUrl().toExternalForm()+'/servlet/servlet.ImageServer?id=' + logo_doc_Id+'&oid='+org_Id+'" alt="DLS Logo"/><br/><br/>';
                            
                            for(Id projId : filteredProjIds){
                            
                                if(projIdAndStdIds.containsKey(projId)){
                                
                                    for(Id stdId : projIdAndStdIds.get(projId)){
                                    
                                        if(conIdRec.containsKey(stdId)){ 
                                        
                                            if(!conIdRec.get(stdId).IsEmailBounced){
                                                
                                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                            
                                                if(orgWideEmailId != null) {
                                                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                                                }
                                                mail.setTargetObjectId(stdId);
                                                
                                                String urlStr = '<a href="'+ System.Label.Student_Community_Site_Prefix +'/s/dli-attendance?projectId='+ projId + '&instructorId='+ projIdAndInsId.get(projId) + '" target="_blank"> Click Here </a>';
                                                
                                                String stdName = '';
                                                if(String.isNotBlank(conIdRec.get(stdId).Salutation)){
                                                    stdName += conIdRec.get(stdId).Salutation;
                                                }
                                                stdName += conIdRec.get(stdId).FirstName;
                                                
                                                String htmlBody = '';
                                                htmlBody += logoStr;
                                                htmlBody += 'Dear '+ stdName + ', <br/><br/>';
                                                
                                                if((currentTime >= time1 && currentTime < time2) || Test.isRunningTest()){
                                            
                                                    mail.subject = 'Please Complete DLI Attendance Report';  
                                                    htmlBody += 'This is a reminder to submit your DLI attendance status today ' + todayStr + ' by 12:00 pm ET so that we can report it to DLI-W as required.<br/><br/>';
                                                }
                                                
                                                if(currentTime >= time2 || Test.isRunningTest()){
                                                
                                                    mail.subject = 'Reminder to Complete DLI Attendance Report';
                                                    htmlBody += 'This is a reminder that your attendance report was due today ' + todayStr + ' by 12:00 pm ET.<br/>';
                                                    htmlBody += 'Please submit your DLI attendance status now so that we can report it to DLI-W as required.<br/><br/>';
                                                }     
                                                
                                                htmlBody += 'Please ' + urlStr + ' to visit DLS Online ' + ' to complete your attendance status report. ';
                                                htmlBody += 'If you encountered any technical or academic issues today, please be sure to note them in the appropriate fields.<br/><br/>';
                                                htmlBody += 'If you have any questions or difficulties accessing the new attendance status tracker, ';
                                                htmlBody += 'please email us at <a href="mailto:attendance@dlsdc.com"> attendance@dlsdc.com </a>.<br/><br/>';
                                                htmlBody += 'Thank you.<br/><br/>DLS Administration<br/>This is a system generated email';
                                                
                                                mail.setHtmlBody(htmlBody);
                                                mail.setSaveAsActivity(TRUE); 
                                                sendEmailToClassLeaders.add(mail);   
                                            }else{
                                                
                                                mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(stdId).Id+'" target="_blank">'+conIdRec.get(stdId).Name+'</a><br/>';
                                                hasBouncedEmail = true;
                                            }   
                                        }
                                    } 
                                }
                            }
                            mailContent += '<br/><p>This e-mail was auto generated. Please do not respond.</p>';
                            mailContent += '</html>';
                        
                            if(hasBouncedEmail || Test.isRunningTest()) {
                        
                                //Added custome setting to hold the exception recipients email ids
                                List<String> toAddressIds = new List<String>();
                    
                                System_Values__c sysVal1 = System_Values__c.getValues('Contact Bounced Exception Email Ids'); 
                                if (sysVal1 != null && sysVal1.Value__c != null) {
                                    for (String st : sysVal1.Value__c.split(',')) {
                                        toAddressIds.add(st.trim());
                                    }
                                }
                                
                                Messaging.SingleEmailMessage bouncedmail = new Messaging.SingleEmailMessage();
                                bouncedmail.setToAddresses(toAddressIds);
                                bouncedmail.setSubject('Bounced email contact information');
                                bouncedmail.sethtmlBody(mailContent);
                                sendEmailToClassLeaders.add(bouncedmail);
                            }
                            //System.debug('::::::sendEmailToClassLeaders::::::::'+sendEmailToClassLeaders);
                            System.debug('::::::sendEmailToClassLeaders::::SIZE::::'+sendEmailToClassLeaders.size());
                            
                            if( sendEmailToClassLeaders != null && sendEmailToClassLeaders.size() > 0 ) {
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailToClassLeaders);
                            }
                        }
                    }
                }catch(Exception e) {
            
                    ErrorHandler errHandler = new ErrorHandler();
                    errHandler.sendExceptionEmail(e.getMessage(),system.Label.TimeCardDayEmail,'Error on DLI Attendance Email Reminder To Class Leaders');  
                } 
            }
        }
    }
}