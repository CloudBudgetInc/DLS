/****************
    - Added by HL on Sep 07 2019
    - Auto-creation of User accounts
    - If the Contact Assignment is created less than 3 business days before the Start Date of the Contact Assignment, 
        create a User for the Contact immediately if one does not exist already 
    - This scheduler runs every one hour basis
    ******************/
    
public class CAbasedUserCreationOnEveryHour_Schedule implements Schedulable{
         
    public void execute(SchedulableContext sc) {
    
        List<Contact_Assignments__c> filteredCAs = new List<Contact_Assignments__c>();
        Set<Id> filteredProjIds = new Set<Id>();
        Set<Id> filteredConIds = new Set<Id>();
        
        List<UtilDomain.ErrorWrapper> errorWrapperList = new List<UtilDomain.ErrorWrapper>();
        Set<Id> conIds = new Set<Id>();
        
        Set<String> projectType = new Set<String>{'SLP-PT','SLP-FT','JMAS','IND'};
        
        List<Integer> noOfDays = new List<Integer>{1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19};
        Set<Date> startDates = new Set<Date>{Date.today()};
        Set<Date> dodaProjStartDates = new Set<Date>{Date.today()};
        
        for(Integer i : noOfDays){
            // Modified (i<=3 in to i<= 12)By HL on Oct 14 2020
            if(i<=12){
                startDates.add(Date.today().addDays(i));
            }  
            dodaProjStartDates.add(Date.today().addDays(i));
        }
        System.debug(':::startDates::::'+startDates);
        System.debug(':::dodaProjStartDates::::'+dodaProjStartDates);
        
        // Added on July 29 2022 - Work Item: W-007477 - LMS Access for DLI-W Academic Advisors (AUG-1-2022)
        // Modified on Nov 18 2022 - Work Item: W-007631 - Create Instructor Community Users for Testing Projects
        Set<String> caPositionSet = new Set<String>{'Instructor','EI','Substitute Instructor','Class Leader','Student','Training Officer','Client','Coordinator','Billing Contact','Academic Adviser','COR','Contracting POC','Technical POC', 'KO', 'Tester'};
        Set<String> caRecordTypeSet = new Set<String>{'Instructor', 'Student'};
        
        for(Contact_Assignments__c c : [
                                        SELECT Id, Candidate_Name__c, Start_Date__c, CreatedDate, Project__r.RecordType.DeveloperName, Project__r.Program_Iteration__r.Name, Project__c, 
                                            RecordType.DeveloperName, Project__r.Project_Type__c, Project__r.Program_Iteration__c, Project__r.Moodle_Course_Id__c,
                                            Candidate_Name__r.Moodle_User_Id__c, Project__r.Start_Date__c, Candidate_Name__r.Active_DLS_Online_User__c, Assignment_Position__c, 
                                            Project__r.DLS_Class__c, Project__r.Language__r.Name, Moodle_Sync_Status__c, Candidate_Name__r.Moodle_User_Status__c
                                            FROM Contact_Assignments__c
                                            WHERE Candidate_Name__c != NULL AND Candidate_Name__r.RecordType.DeveloperName != 'DLS_Employee' AND Status__c IN ('Planned', 'Active') 
                                                AND (RecordType.DeveloperName IN : caRecordTypeSet OR (RecordType.DeveloperName = 'Client_Partner' 
                                                AND Candidate_Name__r.RecordType.DeveloperName IN ('Commercial_Client', 'USG_Client') AND Candidate_Name__r.Account.Name LIKE '%DLI%')) 
                                                AND (NOT Candidate_Name__r.Name LIKE '%Student%')
                                                AND Start_Date__c != NULL AND Paper_Timesheet__c = FALSE   
                                                AND Assignment_Position__c IN : caPositionSet AND Project__r.QB_Classification__c != 'OF0MTT0PS' 
                                                AND (NOT Project__r.Name LIKE '%Bah%') AND Project__r.AcctSeed__Status__c IN ('Order','Active') 
                                                AND Project__r.Name NOT IN ('ELIZABETH HUML','MARA BOROUGHS','LEANN TAGWERKER','TRAVIS CUNNINGHAM','DLI Hausa-2018-Pena/Falanga','DLI Somali-2018-Deborah/Mickayla/Katie/Collin','Danielle Ward 2019')
        ]){
        
            if(c.Assignment_Position__c != 'Tester' && c.Project__r.RecordType.DeveloperName != 'Testing_Projects'){
            
                filteredCAs.add(c);
                filteredProjIds.add(c.Project__c);
                filteredConIds.add(c.Candidate_Name__c);
            }
            
            if(c.Candidate_Name__r.Active_DLS_Online_User__c == FALSE && 
                ((c.Project__r.RecordType.DeveloperName != 'DODA_Projects' && startDates.contains(c.Start_Date__c)) ||
                (c.Project__r.RecordType.DeveloperName == 'DODA_Projects' && String.isNotBlank(c.Project__r.Project_Type__c) &&
                projectType.contains(c.Project__r.Project_Type__c) && (c.Project__r.Program_Iteration__c != NULL || 
                c.Project__r.Project_Type__c == 'IND') && dodaProjStartDates.contains(c.Start_Date__c)) || 
                (c.Project__r.RecordType.DeveloperName == 'DLI_W_LT_Projects' && c.Start_Date__c <= Date.Today()))){
                
                // W-007579: Please Restrict Client Community Site Access to all Non - DLI-W Clients
                if(c.RecordType.DeveloperName != 'Client_Partner' || (c.RecordType.DeveloperName == 'Client_Partner' && c.Project__r.RecordType.DeveloperName == 'DLI_W_LT_Projects')){
                    conIds.add(c.Candidate_Name__c);
                }
            }
        }
        System.debug('conIds==='+conIds+'conIds SIZE===='+conIds.size());
            
        if(conIds.size() > 0){
            
            Set<Id> conIdsToCreateUser = new Set<Id>();
            Set<Id> conIdsToUpdateUser = new Set<Id>();
        
            Map<Id, Boolean> conIdAndIsUserExist = UserManagementUtil.checkAlreadyUserExist(conIds);
        
            for(Id conId : conIdAndIsUserExist.keySet()){
                
                if(conIdAndIsUserExist.get(conId)){
                
                    conIdsToUpdateUser.add(conId);
                }else{
                    
                    conIdsToCreateUser.add(conId);
                }
            }
            System.debug('conIdsToUpdateUser====='+conIdsToUpdateUser+'conIdsToUpdateUser SIZE===='+conIdsToUpdateUser.size());
            System.debug('conIdsToCreateUser====='+conIdsToCreateUser+'conIdsToCreateUser SIZE===='+conIdsToCreateUser.size());
            
            if(conIdsToUpdateUser.size() > 0){
                
                List<UtilDomain.ErrorWrapper> errorInUserUpdation = UserManagementUtil.updateExistingUser(conIdsToUpdateUser);
                errorWrapperList.addAll(errorInUserUpdation);
            }
        
            if(conIdsToCreateUser.size() > 0){
                
                List<UtilDomain.ErrorWrapper> errorInUserCreation = UserManagementUtil.createUserForContact(conIdsToCreateUser);
                errorWrapperList.addAll(errorInUserCreation);
            }
            
            if(errorWrapperList.size() > 0){
            
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
               
                //Form Email contents
                
                String mailContent = '<html>Dear Admin,<br/><br/>The following errors are occured during Auto User creation:'; 
                mailContent += '<br/><br/><table border="1" style="border-collapse: collapse"><thead><th>Contact Name</th><th>Error Description</th></thead><tbody>';    
                
                Set<String> keyStrSet = new Set<String>();
                
                for(UtilDomain.ErrorWrapper val : errorWrapperList) {
                    String key = val.record.get('FirstName')+'-'+val.record.get('LastName')+'-'+val.message;
                    
                                                            
                    if(!keyStrSet.contains(key)) {
                        mailContent += '<tr><td width="25%">'+ '<a href="'+ System.Label.Org_Prefix_Start_URL +'/lightning/r/Contact/' + val.record.get('Id') +'/view" target="_blank">'+ val.record.get('FirstName')+' '+val.record.get('LastName') +'</a>' +'</td><td width="100%">'+ val.message +'</td></tr>'; 
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
                mail.setSubject('Error on Auto User Creation');
                mail.setSaveAsActivity(false);
                mail.sethtmlBody(mailContent);
                mails.add(mail);
                if( mails != null && mails.size() > 0 && !Test.isRunningTest()) {
                    Messaging.sendEmail(mails);
                }
            }
        }
        
        if(filteredCAs.size() > 0 && filteredProjIds.size() > 0 && filteredConIds.size() > 0){
        
            UserManagementUtil.updateMoodleRelatedFields(filteredCAs, filteredProjIds,filteredConIds);
        }
    }
}