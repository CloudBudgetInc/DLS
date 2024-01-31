// Created by Sukanya on November 4 2017
// To delete the following records related to particular project
// Accounting Seed Time Snapshot,Time card day, Time card line, Project Task and Project records deletion.
global class ProjectRecord_DeletionClass {
    
    // Added by Shalini on Jan 25 2018 to show alert message for Notes & Attachments before Project deletion
    @AuraEnabled
    webservice static String alertForNotesAttachments(Id projectId) {
        String alertMsg;
        
        List<Attachment> attments = [SELECT Id, Name, ParentId, ContentType, Body, BodyLength, Description, IsPrivate FROM Attachment WHERE ParentId = :projectId];
        List<ContentDocumentLink> conDocs = [SELECT ContentDocumentId, ShareType, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId = :projectId];
        List<Note> notes = [SELECT Id, ParentId, Body, IsPrivate, Title FROM Note WHERE ParentId = :projectId];  
        
        if(attments.size() > 0 || conDocs.size() > 0 || notes.size() > 0){
            alertMsg = 'This Project has Notes & Attachments. So please Upload these attachments into Box folder and then delete that attachments. And Please try again.';
        } else {
            alertMsg = 'No records';
        }
        
        return alertMsg;
    }
    
    @AuraEnabled
    webservice static void deleteRecords(Id projectId) {
        system.debug('::::::projectId::::::'+projectId);
       
        // Qry Project related time card line for deletion
        List<AcctSeed__Time_Card_Line__c> timeCardLineList = [SELECT Id,Name FROM AcctSeed__Time_Card_Line__c WHERE ( AcctSeed__Project_Task__r.AcctSeed__Project__c = :projectId OR AcctSeed__Project__c = :projectId)];
        system.debug(':::::::::timeCardLineList:::::::::::'+timeCardLineList.size());
        
        Set<Id> timeCardLineIds = new Set<Id>();
        for(AcctSeed__Time_Card_Line__c timeline : timeCardLineList){
            timeCardLineIds.add(timeline.Id);
        }
        
        List<AcctSeed__Project__c> projectList = [SELECT Id,Name FROM AcctSeed__Project__c WHERE Id = :projectId];
        List<Materials_Request__c> mRlist = [SELECT Id,Name FROM Materials_Request__c WHERE Project__c  = :projectId AND Class_Name__c = null];
        
        try {
        
            if(timeCardLineList.size() > 0)
                delete timeCardLineList;
            if(mRlist.size() > 0)
                delete mRlist;
            if(projectList.size() > 0)
                delete projectList;
                
        }catch(DmlException e){
            sendEmailWhenErrorOccurs(e.getMessage());
        }
     }
    
     public static void sendEmailWhenErrorOccurs(String mailContent) {
        
        List<Messaging.SingleEmailMessage> ErrorMailMsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setToAddresses(new String[] {system.Label.TimeCardDayEmail});
        mail.setSubject('Error on Project Record deletion Process'); 
        mail.setPlainTextBody(mailContent);
        ErrorMailMsg.add(mail);
        try{
            if( ErrorMailMsg != null && ErrorMailMsg.size() > 0 ){
                Messaging.sendEmail(ErrorMailMsg); 
            }
        } catch (Exception ex){
            system.debug('Ex::::'+ex);
        }
    }
}