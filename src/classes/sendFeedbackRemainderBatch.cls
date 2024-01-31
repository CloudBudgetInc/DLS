global class sendFeedbackRemainderBatch implements Database.Batchable<SObject>, Database.Stateful {

    global Database.QueryLocator start(Database.BatchableContext BC) {
        List<RecordType> recType = [SELECT Id,DeveloperName,SobjectType FROM RecordType WHERE SobjectType = 'Contact_Assignments__c' AND DeveloperName = 'Student'];
        String query = 'SELECT Id,Name,Close_Getfeedback_Received__c,Opportunity_Name__c,Close_Getfeedback_sent__c,Candidate_Name__c,Email__c,Weekly_Getfeedback_Received__c,Weekly_Getfeedback_sent__c FROM Contact_Assignments__c WHERE (Weekly_Getfeedback_sent__c != null OR Close_Getfeedback_sent__c != null) AND Email__c != null AND RecordTypeId=\''+recType[0].Id+'\'';
        System.debug(':::query:::' + query);
        return Database.getQueryLocator(query);
    } 
      
    global void execute(Database.BatchableContext BC,List<Contact_Assignments__c> conAssignList) {
        System.debug(':::conAssignList:::' + conAssignList);
        if(conAssignList != null && conAssignList.size() > 0) {
            List<Messaging.SingleEmailMessage> sendEmailList = new List<Messaging.SingleEmailMessage>();
            List<EmailTemplate> emailTemp = [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName IN ('CourseEndGetfeedback', 'weeklyGetfeedbackEmailTemplate')];
            if(emailTemp.size() == 2) {
                for(Contact_Assignments__c con : conAssignList) {
                    if(con.Weekly_Getfeedback_sent__c != null && con.Weekly_Getfeedback_Received__c == null) {
                        if(con.Weekly_Getfeedback_sent__c == System.today()-2) {
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setToAddresses(new List<String> { con.Email__c });
                            mail.setTemplateId(emailTemp[1].Id);
                            mail.setWhatId(con.Opportunity_Name__c);
                            mail.setTargetObjectId(con.Candidate_Name__c); 
                            sendEmailList.add(mail);
                        }
                    }
                    if(con.Close_Getfeedback_sent__c != null && con.Close_Getfeedback_Received__c == null) {
                        if(con.Close_Getfeedback_sent__c == System.today()-5) {
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setToAddresses(new List<String> { con.Email__c });
                            mail.setTemplateId(emailTemp[0].Id);
                            mail.setWhatId(con.Opportunity_Name__c);
                            mail.setTargetObjectId(con.Candidate_Name__c); 
                            sendEmailList.add(mail);
                        }
                    }
                }
            }
            System.debug(':::sendEmailList:::' + sendEmailList);
            if(sendEmailList.size() > 0) { Messaging.sendEmail(sendEmailList); }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}