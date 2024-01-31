public class MaterialsRequestTrigger_Handler{

    /****************
        - Created by HL on June 06 2022
        - Work Item: W-007483 - Automate LMS Enrollment Confirmation Emails
        - To send an email to both instructors and students when the student LMS Enrollment materials request is in Delivered stage
        **************/
    public static void sendLMSEnrollmentEmail(Map<Id, Materials_Request__c> materialReqMap, Map<Id, Id> mrIdAndProjId){
                    
        if(materialReqMap.size() > 0){
        
            Map<Id, Set<Id>> projIdAndStdInsIds = new Map<Id, Set<Id>>();
            Set<Id> stdInsIds = new Set<Id>();
            Set<Id> studentIds = new Set<Id>();
            
            for(Contact_Assignments__c ca : [SELECT Id, Candidate_Name__c, Project__c, RecordType.DeveloperName FROM Contact_Assignments__c WHERE Project__c IN : mrIdAndProjId.values() AND (RecordType.DeveloperName IN ('Instructor', 'Student') OR (RecordType.DeveloperName = 'Staff' AND Assignment_Position__c = 'Project Manager')) AND Status__c = 'Active']){
            
                if(!projIdAndStdInsIds.containsKey(ca.Project__c)){
                    projIdAndStdInsIds.put(ca.Project__c, new Set<Id>());
                }
                projIdAndStdInsIds.get(ca.Project__c).add(ca.Candidate_Name__c);    
                stdInsIds.add(ca.Candidate_Name__c);
                
                if(ca.RecordType.DeveloperName == 'Student'){
                    studentIds.add(ca.Candidate_Name__c);
                }
            }
        
            try{
                
                String mailContent = '';
                Boolean hasBouncedEmail = FALSE;
            
                List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
                
                Map<Id,Contact> contactMap = new Map<Id,Contact>([SELECT Id, Name, Email, IsEmailBounced FROM Contact WHERE Id IN : stdInsIds AND Email != null]);
                
                EmailTemplate lmsEnrollmentTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'LMS_Enrollment_Template'];
                    
                List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
                    
                String orgWideEmailId = '';
                
                if(orgWideEmail != null && orgWideEmail.size() > 0){
                    orgWideEmailId = orgWideEmail[0].Id;
                }
                
                for(Id mrId : materialReqMap.keySet()){
                    
                    if(projIdAndStdInsIds.containsKey(mrIdAndProjId.get(mrId))){
                    
                        for(Id stdInsId : projIdAndStdInsIds.get(mrIdAndProjId.get(mrId))){
                        
                            if(contactMap.containsKey(stdInsId)){
                            
                                if(!contactMap.get(stdInsId).IsEmailBounced){
                                
                                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                    if(orgWideEmailId != null) {
                                        mail.setOrgWideEmailAddressId(orgWideEmailId);
                                    }
                                    mail.setTemplateId(lmsEnrollmentTemplate.Id);
                                    mail.setTargetObjectId(stdInsId);
                                    
                                    if(studentIds.contains(stdInsId)){
                                        mail.setBccAddresses(new List<String>{'sgrabowski@dlsdc.com'});
                                    }
                                    mail.setWhatId(mrId);
                                    sendEmailList.add(mail);
                                    
                                }else{
                                    
                                    mailContent += '<a href="'+System.Label.Org_Prefix_Start_URL+'/'+contactMap.get(stdInsId).Id+'" target="_blank">'+contactMap.get(stdInsId).Name+'</a><br/>';
                                    hasBouncedEmail = TRUE;
                                }
                            }
                        }
                    }
                }
                                    
                if(hasBouncedEmail || Test.isRunningTest()) {
                    
                    Messaging.SingleEmailMessage bouncedmail = ErrorHandler.getBouncedEmail(mailContent);
                    sendEmailList.add(bouncedmail);
                }
            
                if( sendEmailList != NULL && sendEmailList.size() > 0 ) {
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailList);
                }
                
            }catch(Exception e) {
                            
                String errorMessage = '';
                errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                
                ErrorHandler errHandler = new ErrorHandler();
                errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on LMS Enrollment Confirmation Email');
            } 
        }
    }
}