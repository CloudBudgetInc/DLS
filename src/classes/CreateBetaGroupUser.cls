/**************************************************************************************
- Batch to create/update user based on the Contact's Beta Group flag for student & instructor community user creation
- In production already instructor community users, if alredy exist need to update contact's email in user
- This batch is called from Global action
- Created by NS on August 29 2019
**************************************************************************************/
global class CreateBetaGroupUser implements Database.batchable<sObject>,Database.Stateful {
    
    global List<UtilDomain.ErrorWrapper> errorWrapperList = new List<UtilDomain.ErrorWrapper>();
    
    global Iterable<sObject> start(Database.BatchableContext info){  
    
        //String contactQty = 'SELECT Id,Name,FirstName,MiddleName,LastName,Email,RecordType.DeveloperName FROM Contact WHERE RecordType.DeveloperName IN (\'Candidate\',\'Student\') AND Active_DLS_Online_User__c = false AND Beta_Group__c = false';
        
        List<Contact> contactRecords = new List<Contact>();
        
        if(!Test.isRunningTest()) {
            Set<Id> contactIds = new Set<Id>();
            
            //Qry Contact Assignment get student & instructor ids
            for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c FROM Contact_Assignments__c 
                                                WHERE (
                                                        (RecordType.DeveloperName = 'Instructor' AND Assignment_Position__c IN ('Instructor','EI','Substitute Instructor') AND (NOT Candidate_Name__r.Name LIKE '%Instructor%') 
                                                            AND (NOT Candidate_Name__r.Name LIKE '%Student%')) 
                                                        OR (RecordType.DeveloperName = 'Student' AND Assignment_Position__c IN ('Class Leader','Student') AND (NOT Candidate_Name__r.Name LIKE '%Student%'))
                                                    ) AND (Project__r.AcctSeed__Status__c = 'Active' OR (Project__r.AcctSeed__Status__c = 'Order' AND Project__r.Start_Date__c <= 2019-10-28)) 
                                                        AND Status__c IN ('Active','Planned') AND Project__r.End_Date__c >= 2019-10-28 AND End_Date__c >= 2019-10-28 AND Candidate_Name__r.Name != 'Inna Golovakha' 
                                                        AND Project__r.Name NOT IN ('ELIZABETH HUML','MARA BOROUGHS','LEANN TAGWERKER','TRAVIS CUNNINGHAM','DLI Hausa-2018-Pena/Falanga','DLI Somali-2018-Deborah/Mickayla/Katie/Collin','Danielle Ward 2019') 
                                                        AND Project__r.QB_Classification__c != 'OF0MTT0PS']){
                                                        
                contactIds.add(ca.Candidate_Name__c);
                
            }
            
            system.debug(':::::::contactIds:::'+contactIds.size());
            
            contactRecords = [SELECT Id,Name,FirstName,MiddleName,LastName,Email,RecordType.DeveloperName FROM Contact 
                                                WHERE Id IN :contactIds AND RecordType.DeveloperName IN ('Candidate','Student') AND Active_DLS_Online_User__c = false AND Beta_Group__c = false];
            
            system.debug(':::::::::::contactRecords:::::'+contactRecords.size());
        
        }else {
            contactRecords = [SELECT Id,Name,FirstName,MiddleName,LastName,Email,RecordType.DeveloperName FROM Contact 
                                                WHERE RecordType.DeveloperName IN ('Candidate','Student') AND Active_DLS_Online_User__c = false AND Beta_Group__c = false LIMIT 1];
        }
        return contactRecords;
    }
    
    global void execute(Database.BatchableContext info, List<Contact> contactRecords){
        
        Set<Id> contactIds = new Set<Id>();
                
        Set<Id> conIdsToCreateUser = new Set<Id>();
        Set<Id> conIdsToUpdateUser = new Set<Id>();
        
        for(Contact con : contactRecords){
            contactIds.add(con.Id);
        }
        
        Map<Id, Boolean> conIdAndIsUserExist = UserManagementUtil.checkAlreadyUserExist(contactIds);
        
        for(Id conId : conIdAndIsUserExist.keySet()){
            
            if(conIdAndIsUserExist.get(conId)){
            
                conIdsToUpdateUser.add(conId);
            }else{
                
                conIdsToCreateUser.add(conId);
            }
        }
        System.debug(':::::::::::conIdsToUpdateUser SIZE:::::::::'+conIdsToUpdateUser.size());
        System.debug(':::::::::::conIdsToCreateUser SIZE:::::::::::'+conIdsToCreateUser.size());
        
        if(conIdsToUpdateUser.size() > 0){
            
            List<UtilDomain.ErrorWrapper> errorInUserUpdation = UserManagementUtil.updateExistingUser(conIdsToUpdateUser);
            errorWrapperList.addAll(errorInUserUpdation);
        }
        
        if(conIdsToCreateUser.size() > 0){
            
            List<UtilDomain.ErrorWrapper> errorInUserCreation = UserManagementUtil.createUserForContact(conIdsToCreateUser);
            errorWrapperList.addAll(errorInUserCreation);
        }
        
    }
    
    global void finish(Database.BatchableContext info){ 
        
        system.debug(':::::::::::errorWrapperList::::::finish:::::'+errorWrapperList.size());
        
        //Send Email with failed records information
        
        if(errorWrapperList.size() > 0){
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
           
            //Form Email contents
            
            String mailContent = '<html>Dear Softsquare,<br/><br/>The following errors are occured during Beta Group User creation:'; 
            mailContent += '<br/><br/><table border="1" style="border-collapse: collapse"><thead><th>Contact Name</th><th>Error Description</th></thead><tbody>';    
            
            Set<String> keyStrSet = new Set<String>();
            
            for(UtilDomain.ErrorWrapper val : errorWrapperList) {
                String key = val.record.get('FirstName')+'-'+val.record.get('LastName')+'-'+val.message;
                
                if(!keyStrSet.contains(key)) {
                    mailContent += '<tr><td width="25%">'+val.record.get('FirstName')+' '+val.record.get('LastName')+'</td><td width="100%">'+ val.message +'</td></tr>'; 
                    keyStrSet.add(key);
                }
            }
            
            mailContent += '</tbody></table><br/><p>This e-mail was auto generated. Please do not respond.</p><p>If you have questions, contact your Salesforce Administrator.</p>';
            mailContent += '</html>';
            
            
            //Send Email
            
            //Added custome setting to hold the exception recipients email ids
            //By NS on March 3 2020
            List<String> toAddressIds = new List<String>();

            System_Values__c sysVal = System_Values__c.getValues('User Creation Exception Mails'); 
            if (sysVal != null && sysVal.Value__c != null) {
                for (String st : sysVal.Value__c.split(',')) {
                    toAddressIds.add(st.trim());
                }
            }
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddressIds);
            mail.setSubject('Error on Beta Group User Creation');
            mail.sethtmlBody(mailContent);
            mails.add(mail);
            if( mails != null && mails.size() > 0 && !Test.isRunningTest()) {
                Messaging.sendEmail(mails);
            }
        }
    }
}