/**********************
    - W-007961 : Automatically Send an Email 7 days before Project End Date
    - To send an email to the Students and the Instructors 7 days before the Project End Date.
    - This scheduler runs on daily basis
    - Cron Expression Info:
        SendEmail7DaysBeforeProjectEndDate_Batch  sch2 = new SendEmail7DaysBeforeProjectEndDate_Batch(); 
        String sch = '0 30 10 * * ?'; 
        system.schedule('Send Email 7 Days Before Project End Date @ 10.30 AM EST', sch, sch2);
    *******************/

public class SendEmail7DaysBeforeProjectEndDate_Batch implements Database.Batchable<SObject>, Schedulable, Database.Stateful{

    public Set<String> projectTypes = new Set<String>{'SLP-FT', 'SLP-PT', 'PLP'};
    
    public void execute(SchedulableContext sc){
        SendEmail7DaysBeforeProjectEndDate_Batch sendEmail = new SendEmail7DaysBeforeProjectEndDate_Batch();
        Database.executeBatch(sendEmail);
    }
    
    public Database.QueryLocator start(Database.BatchableContext context){  
    
        Date endDate = Date.Today().addDays(7);
        String projectQryStr = 'SELECT Id, Name, Account_Name__c, Project_Type__c, Project_Manager__c FROM AcctSeed__Project__c WHERE End_Date__c = : endDate AND Acctseed__Status__c = \'Active\' AND Project_Record_Type_Name__c NOT IN (\'Testing_Projects\', \'Translation_Projects\', \'Interpretation_Projects\') AND QB_Classification__c != \'OF0UAE\'';
        return Database.getQueryLocator(projectQryStr);    
    }
    
    public void execute(Database.BatchableContext context, List<AcctSeed__Project__c> projects){
                 
        if(!projects.isEmpty()){
            
            List<AcctSeed__Project__c> projRecs = new List<AcctSeed__Project__c>();
            
            for(AcctSeed__Project__c pro : projects){
                
                if(!pro.Account_Name__c.contains('PVT') && !pro.Account_Name__c.contains('DLI') && !pro.Account_Name__c.contains('FAS') && !pro.Account_Name__c.contains('FCS') && 
                    (!pro.Account_Name__c.contains('DODA') || (pro.Account_Name__c.contains('DODA') && !projectTypes.contains(pro.Project_Type__c))) && 
                    !pro.Account_Name__c.contains('AFSAT') && !pro.Name.contains('UAE') && pro.Account_Name__c != 'Booz Allen Hamilton (BAH)'){
                    
                    projRecs.add(pro);        
                }
            }    
                        
            if(!projRecs.isEmpty()){
            
                Map<Id, List<String>> projIdAndStdInsEmails = new Map<Id, List<String>>();
                Map<Id, String> projIdAndPMEmail = new Map<Id, String>();
                List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
                // To fix "ERROR: System.EmailException:SendEmail failed.REQUIRED_FIELD_MISSING, Missing targetObjectId with template"
                Map<Id, Id> projIdAndTargetObjId = new Map<Id, Id>(); 
                
                for(Contact_Assignments__c ca : [SELECT Id, Project__c, Candidate_Name__c, Candidate_Name__r.Email, Project__r.Project_Manager__r.Email FROM Contact_Assignments__c WHERE Project__c IN : projRecs AND Candidate_Name__r.Email != null AND Candidate_Name__r.IsEmailBounced = false AND Status__c = 'Active' AND RecordType.DeveloperName IN ('Instructor', 'Student')]){
                
                    if(!projIdAndStdInsEmails.containsKey(ca.Project__c)){
                        projIdAndStdInsEmails.put(ca.Project__c, new List<String>());
                    }
                    projIdAndStdInsEmails.get(ca.Project__c).add(ca.Candidate_Name__r.Email);
                    projIdAndTargetObjId.put(ca.Project__c, ca.Candidate_Name__c);
                    
                    if(!projIdAndPMEmail.containsKey(ca.Project__c) && ca.Project__r.Project_Manager__c != null){
                        projIdAndPMEmail.put(ca.Project__c, ca.Project__r.Project_Manager__r.Email); 
                    }                   
                }
                
                try{
                    
                    String orgWideEmailId = ProjectTrigger_Handler.getOrgWideEmailId('support@dlsdc.com');
                    String emailTemplateId = ProjectTrigger_Handler.getEmailTemplateId('Send_Email_7_Days_Before_Project_EndDate');
                   
                    for(AcctSeed__Project__c proj : projRecs){
                        
                        if(projIdAndStdInsEmails.containsKey(proj.Id)){
                            
                            List<String> cCAddresses = projIdAndPMEmail.containsKey(proj.Id) ?  new List<String>{projIdAndPMEmail.get(proj.Id)} : null;
                            Messaging.SingleEmailMessage mail = ProjectTrigger_Handler.getSingleEmail(orgWideEmailId, projIdAndTargetObjId.get(proj.Id), projIdAndStdInsEmails.get(proj.Id), cCAddresses, emailTemplateId, proj.Id, '', '', true, false);
                            sendEmailList.add(mail);
                        }
                    }                     
                    if(!sendEmailList.isEmpty()){
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailList);
                    }
                }catch(Exception e){
                
                    String errorMessage = '';
                    errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                        
                    ErrorHandler errHandler = new ErrorHandler();    
                    errHandler.sendExceptionEmail(errorMessage,System.Label.TimeCardDayEmail,'Error on Sending Email 7 Days Before Project End Date');
                } 
            }
        }
    }
        
    public void finish(Database.BatchableContext context) {
    
    }
}