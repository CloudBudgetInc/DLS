// Created batch class by Sukanya on June 8 2017
// Events updation process from convert to project execution

global class EventUpdation_FromCTP implements Database.batchable<sObject>,Database.Stateful { 
    
    global Set<Id> scheduleIdSet = new Set<Id>();
    global Set<Id> eventIdSet = new Set<Id>();
    global List<UtilDomain.EventInnerClass> eventList = new List<UtilDomain.EventInnerClass>();
    global Map<Id,Id> schIdWithInstructorIdMap = new Map<Id,Id>();
    global Id newProjectId;
    
     // For Exception handling process
    global List<UtilDomain.ErrorWrapper> errorWrapperList = new List<UtilDomain.ErrorWrapper>();
    
    public EventUpdation_FromCTP(Set<Id> scheduleIds,Set<Id> eventIds,List<UtilDomain.EventInnerClass> innerList,Map<Id,Id> schIdMap,Id proId) {
        scheduleIdSet = scheduleIds;
        eventIdSet = eventIds;
        eventList = innerList;
        schIdWithInstructorIdMap = schIdMap;
        newProjectId = proId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext info){
        String eventQry = 'SELECT Id,Name,Project__c,Start_Time__c,End_Time__c,Date__c,Schedule__c FROM Events__c WHERE Schedule__c In: scheduleIdSet AND Id NOT IN: eventIdSet';
        return Database.getQueryLocator(eventQry);
    }
    
    global void execute(Database.BatchableContext info, List<Events__c> eventsList){
        
        List<Events__c> eventListToUpdate = new List<Events__c>();
        
        Savepoint sp = Database.setSavepoint(); 
         
        try {
            
            for(Events__c evt : eventsList) {
                evt.Project__c = newProjectId;
                evt.Instructor__c = (schIdWithInstructorIdMap != null && schIdWithInstructorIdMap.containskey(evt.Schedule__c)) ? schIdWithInstructorIdMap.get(evt.Schedule__c):null;
                eventListToUpdate.add(evt);
            }
            
            for(UtilDomain.EventInnerClass e : eventList) {
                e.evt.Project__c = newProjectId;
                eventListToUpdate.add(e.evt);
            }
            
            if( eventListToUpdate != null && eventListToUpdate.size() > 0 ) {
                //update eventListToUpdate;
                Database.SaveResult[] srList = Database.update(eventListToUpdate, false);
                
                for (Integer i = 0; i < srList.size(); i++) {
                    Events__c origRecord = eventListToUpdate[i];
                    String errMsg = '';
                    if (!srList[i].isSuccess()) {
                        system.debug(origRecord.Id);
                         for(Database.Error err : srList[i].getErrors()) {
                            System.debug('::::::::::::::: ' + err.getMessage());
                            errMsg += err.getMessage();
                        }
                        
                        UtilDomain.ErrorWrapper errWrapper = new UtilDomain.ErrorWrapper(origRecord,errMsg,'Event');
                        errorWrapperList.add(errWrapper);
                    }
                }
            }
            
        }catch(DmlException e) {
            sendEmailWhenErrorOccurs(e.getMessage());
            Database.RollBack(sp);
        } catch(SObjectException e) {
            sendEmailWhenErrorOccurs(e.getMessage());  
            Database.RollBack(sp);  
        } catch(Exception e) {
            sendEmailWhenErrorOccurs(e.getMessage()); 
            Database.RollBack(sp);   
        }
    }
    
    global void finish(Database.BatchableContext info){ 
        
        // Consolidated Email for Event updation failure
        
        if(errorWrapperList != null && errorWrapperList.size() > 0) {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            String mailContent = '<html>Dear Softsquare,<br/>The following errors are occured during Event updation process:'; 
            mailContent += '<br/><table border="1" style="border-collapse: collapse"><thead><th>Event Name</th><th>Date</th><th>Error Description</th></thead><tbody>';    
            
            for(UtilDomain.ErrorWrapper val : errorWrapperList) {
                mailContent += '<tr><td width="25%">'+val.record.get('Name')+'</td><td width="25%">'+val.record.get('Date__c')+'</td><td width="25%">'+ val.message +'</td></tr>'; 
            }
            
            mailContent += '</tbody></table><br/><p>This e-mail was auto generated. Please do not respond.</p><p>If you have questions, contact your Salesforce Administrator.</p>';
            mailContent += '</html>';
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            List<String> supervisorEmails = new List<String>();
            for(Contact_Assignments__c conAss : [SELECT Id,Name,Project__c,Candidate_Name__c,Candidate_Name__r.Email FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Project__c = :newProjectId AND Status__c = 'Active']) {
                if(conAss.Candidate_Name__r.Email != null)
                    supervisorEmails.add(conAss.Candidate_Name__r.Email);
            }
            
            supervisorEmails.add('cbellas@dlsdc.com');
            supervisorEmails.add('abellas@dlsdc.com');
            
            //mail.setToAddresses(supervisorEmails);
            mail.setToAddresses(new List<String> {'sukanyan@softsquare.biz','cbellas@dlsdc.com','abellas@dlsdc.com'});
            mail.setSubject('Error on Event updation process');
            mail.sethtmlBody(mailContent);
            mails.add(mail);
            System.debug('mails::::'+mails);
            if( mails != null && mails.size() > 0 && !Test.isRunningTest()) {
                Messaging.sendEmail(mails);
            }
            
        }
    }
    
    public void sendEmailWhenErrorOccurs(String mailContent) {
        
        List<Messaging.SingleEmailMessage> ErrorMailMsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setToAddresses(new String[] {system.Label.TimeCardDayEmail});
        mail.setSubject('Error on Events updation from ConverToproject execution'); 
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