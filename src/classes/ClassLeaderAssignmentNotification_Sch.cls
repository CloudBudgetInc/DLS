/*********
    - Created By HL on Mar 25 2021
    - WorkItem:W-006448 - Class Leader Assignment Notification (APR-1-2021)
    - To send an email notification to LTS from 2'nd scheduled day of training that no class leader has yet been assigned on the Project
    - This Scheduler Runs Daily basis
    ********/
public class ClassLeaderAssignmentNotification_Sch implements Schedulable{

    public void execute(SchedulableContext sc) {
    
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        if(todayVal.format('EEEE') != 'Saturday' && todayVal.format('EEEE') != 'Sunday'){
        
            List<AcctSeed__Project__c> projRecs = [SELECT Id, (SELECT Id, Assignment_Position__c
                                                                FROM Contact_Assignments__r 
                                                                WHERE Project__c != NULL AND Status__c = 'Active' AND RecordType.DeveloperName = 'Student' AND 
                                                                    Project__r.RecordType.DeveloperName != 'DLI-W LT Projects')
                                                    FROM AcctSeed__Project__c
                                                    WHERE RecordType.DeveloperName != 'DLI-W LT Projects' AND AcctSeed__Status__c = 'Active' AND Project_Manager__c != NULL AND CreatedDate = THIS_MONTH];
            
            System.debug(':::projRecs::'+projRecs);
            System.debug(':::projRecs::'+projRecs.size());
            
            if(projRecs != NULL && projRecs.size() > 0){
                
                Set<Id> filteredProjIds = new Set<Id>();
                
                for(AcctSeed__Project__c proj : projRecs){
                
                    if(proj.Contact_Assignments__r.size() > 1){
                    
                        Boolean isClassLeader = FALSE;
                        for(Contact_Assignments__c ca : proj.Contact_Assignments__r){
                        
                            if(ca.Assignment_Position__c == 'Class Leader'){
                                
                                isClassLeader = TRUE;
                                break;
                            }
                        }
                        if(!isClassLeader){
                        
                            filteredProjIds.add(proj.Id);
                        }
                    }    
                }
                System.debug(':::filteredProjIds::'+filteredProjIds);
                System.debug(':::filteredProjIds::'+filteredProjIds.size());
                        
                if(filteredProjIds != NULL && filteredProjIds.size() > 0){
                    
                    List<Schedule__c> scheduleRecs = [SELECT Id, Project__c, Start_Date__c, Project__r.Project_Manager__c
                                                    FROM Schedule__c 
                                                    WHERE Status__c = 'Active' AND Project__c IN :filteredProjIds AND Start_Date__c = YESTERDAY
                                                        ORDER BY Start_Date__c ASC ];
                    System.debug(':::scheduleRecs::'+scheduleRecs);
                    System.debug(':::scheduleRecs::'+scheduleRecs.size());
                
                    if(scheduleRecs != NULL && scheduleRecs.size() > 0){
                    
                        Set<String> projIdAndManagerId = new Set<String>();
                        Set<Id> userIds =  new Set<Id>();
                        
                        for(Schedule__c s : scheduleRecs){
                            
                            Date secondScheduledDay = s.Start_Date__c+1;
                            if(Date.Today() == secondScheduledDay){
                            
                                String projIdAndManId = s.Project__c+'-'+s.Project__r.Project_Manager__c;
                                
                                if(!projIdAndManagerId.contains(projIdAndManId)){
                                    
                                    projIdAndManagerId.add(projIdAndManId);
                                }
                                userIds.add(s.Project__r.Project_Manager__c);
                            }
                        }
                        System.debug(':::projIdAndManagerId::'+projIdAndManagerId);
                        System.debug(':::projIdAndManagerId::'+projIdAndManagerId.size());
                        
                        if(projIdAndManagerId != NULL && projIdAndManagerId.size() > 0){
                        
                            List<Messaging.SingleEmailMessage> emailToLTSList = new List<Messaging.SingleEmailMessage>();
                            
                            Map<Id, Id> userIdAndConId = PlannedDaysOffHandler.getUserRelatedContacts(userIds);
                            System.debug(':::userIdAndConId::'+userIdAndConId);
                            System.debug(':::userIdAndConId::'+userIdAndConId.size());
                            
                            try{
                                
                                if(userIdAndConId != NULL && userIdAndConId.size() > 0){
                                
                                    Map<Id, Contact> conIdRec = new Map<Id, Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN :userIdAndConId.values()]);
                                    
                                    EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Class_Leader_Assignment_Notification'];
                                    
                                    List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
                                    
                                    String orgWideEmailId = '';
                                    
                                    if(orgWideEmail != null && orgWideEmail.size() > 0){
                                        orgWideEmailId = orgWideEmail[0].Id;
                                    }
                                    
                                    String mailContent = '<html>Hi Chris, April and Nafisa <br/>The following contacts have bounced email ids, Please correct them: <br/>';
                                    Boolean hasBouncedEmail = false;
                                
                                    for(String s : projIdAndManagerId){
                                    
                                        Id projId = s.split('-')[0];
                                        Id projManagerId = s.split('-')[1];
                                        
                                        if(userIdAndConId.containsKey(projManagerId) && conIdRec.containsKey(userIdAndConId.get(projManagerId))){
                                              
                                            if(!conIdRec.get(userIdAndConId.get(projManagerId)).IsEmailBounced){
                                            
                                                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                                if(orgWideEmailId != NULL) {
                                                    mail.setOrgWideEmailAddressId(orgWideEmailId);
                                                }
                                                mail.setTargetObjectId(userIdAndConId.get(projManagerId));
                                                mail.setWhatId(projId);
                                                mail.setSaveAsActivity(TRUE);
                                                mail.setTemplateID(template.Id);
                                                emailToLTSList.add(mail);
                                            }else {
                                            
                                                mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+conIdRec.get(userIdAndConId.get(projManagerId)).Id+'" target="_blank">'+conIdRec.get(userIdAndConId.get(projManagerId)).Name+'</a><br/>';
                                                hasBouncedEmail = true;
                                            }
                                        }
                                    }
                                    mailContent += '<br/><p>This e-mail was auto generated. Please do not respond.</p>';
                                    mailContent += '</html>';
                                    
                                    if(hasBouncedEmail || Test.isRunningTest()) {
                                    
                                        //Added custome setting to hold the exception recipients email ids
                                        List<String> toAddressIds = new List<String>();
                            
                                        System_Values__c sysVal = System_Values__c.getValues('Contact Bounced Exception Email Ids'); 
                                        if (sysVal != null && sysVal.Value__c != null) {
                                            for (String st : sysVal.Value__c.split(',')) {
                                                toAddressIds.add(st.trim());
                                            }
                                        }
                                        
                                        Messaging.SingleEmailMessage bouncedmail = new Messaging.SingleEmailMessage();
                                        bouncedmail.setToAddresses(toAddressIds);
                                        bouncedmail.setSubject('Bounced email contact information');
                                        bouncedmail.sethtmlBody(mailContent);
                                        emailToLTSList.add(bouncedmail);
                                    }
                                
                                    System.debug('emailToLTSList::::'+emailToLTSList);
                                    
                                    if( emailToLTSList != NULL && emailToLTSList.size() > 0 ) {
                                        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailToLTSList);
                                    }
                                }
                            }catch(Exception e) {
                                
                                String errorMessage = '';
                                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                                
                                ErrorHandler errHandler = new ErrorHandler();
                                errHandler.sendExceptionEmail(errorMessage,'hemalatha@softsquare.biz','Error on Class Leader Assignment Notification Schedule');
                                
                            }
                        }
                    }
                }
            }
        }
    }
}