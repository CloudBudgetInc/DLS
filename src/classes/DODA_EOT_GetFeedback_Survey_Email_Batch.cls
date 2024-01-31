global class DODA_EOT_GetFeedback_Survey_Email_Batch implements Database.batchable<sObject>,Database.Stateful { 
    
    global Database.QueryLocator start(Database.BatchableContext info){ 
    
        String  projectQry = '';
        
        if(!Test.isRunningTest()){
        
            projectQry = 'SELECT Id, Name FROM AcctSeed__Project__c WHERE End_Date__c = TODAY AND (AcctSeed__Account__r.Name LIKE \'%DODA%\' OR RecordType.DeveloperName = \'DODA_Projects\') AND AcctSeed__Status__c IN (\'Active\', \'Ended\')';
        }else if(Test.isRunningTest()){
        
            projectQry = 'SELECT Id, Name FROM AcctSeed__Project__c WHERE End_Date__c = TODAY AND (AcctSeed__Account__r.Name LIKE \'%DODA%\' OR RecordType.DeveloperName = \'DODA_Projects\') AND AcctSeed__Status__c IN (\'Active\', \'Ended\') LIMIT 1';
        }
        
        return Database.getQueryLocator(projectQry);
    }
    
     global void execute(Database.BatchableContext info, List<AcctSeed__Project__c > dodaProjects){
     
         if(dodaProjects.size() > 0){
                                     
            List<Contact_Assignments__c> conAssigns = [SELECT Id, Project__c, Candidate_Name__c 
                FROM Contact_Assignments__c 
                WHERE Project__c IN : dodaProjects AND RecordType.DeveloperName = 'Student' AND 
                    Candidate_Name__r.Opt_Out_From_All_Surveys_Forever__c = FALSE AND Opt_Out_From_All_Surveys_for_This_Projec__c = FALSE AND
                    Status__c IN ('Active', 'Ended')];
            
            if(conAssigns.size() > 0){
            
                try{
                    
                    List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
                    
                    List<OrgWideEmailAddress> orgWideEmail = [SELECT Id,Address,DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'support@dlsdc.com'];
                            
                    String orgWideEmailId = '';
                    
                    if(orgWideEmail != null && orgWideEmail.size() > 0){
                        orgWideEmailId = orgWideEmail[0].Id;
                    }
                        
                    EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'DODA_EOT_GF_Survey_Template'];
            
                    for(Contact_Assignments__c ca : conAssigns){
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        if(orgWideEmailId != null) {
                            mail.setOrgWideEmailAddressId(orgWideEmailId);
                        }
                        mail.setTemplateId(template.Id);
                        mail.setTargetObjectId(ca.Candidate_Name__c);
                        mail.setWhatId(ca.Id);
                        sendEmailList.add(mail);
                    }
                    System.debug(':sendEmailList::::'+sendEmailList.size());
                    if(sendEmailList.size() > 0) {
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(sendEmailList);
                    }
                }catch(Exception e) {
                    
                    String errorMessage = '';
                    errorMessage += 'ERROR: ' + e.getTypeName() + ':'+e.getMessage() + ':' + e.getLineNumber() + ':' + e.getStackTraceString();
                    
                    ErrorHandler errHandler = new ErrorHandler();
                    errHandler.sendExceptionEmail(errorMessage,system.Label.TimeCardDayEmail,'Error on DODA EOT GetFeedback Survey Email');
                }    
            }
        }    
    }
     
    global void finish(Database.BatchableContext info){
    
    }
}