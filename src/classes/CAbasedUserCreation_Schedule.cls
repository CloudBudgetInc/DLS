/****************
    - Added by HL on Sep 04 2019
    - Auto-creation of User accounts
    - If the Contact Assignment is created more than 3 business days before the Start Date of the Contact Assignment, 
        wait until 3 business days before the Start Date to automatically create a User account for the Contact if one does not exist already
    - This scheduler runs daily basis
    ******************/
    
public class CAbasedUserCreation_Schedule implements Schedulable{
         
    public void execute(SchedulableContext sc) {
    
        List<Contact_Assignments__c> filteredCAs = new List<Contact_Assignments__c>();
        Set<Id> filteredProjIds = new Set<Id>();
        Set<Id> filteredConIds = new Set<Id>();
        
        Set<String> projectType = new Set<String>{'SLP-PT','SLP-FT','JMAS','IND'};
        
        List<UtilDomain.ErrorWrapper> errorWrapperList = new List<UtilDomain.ErrorWrapper>();
        Set<Id> conIds = new Set<Id>();
        DateTime todayVal = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        
        Date startDate = Date.Today()+18;
        
        Date dodaProjSD = Date.Today()+20;
        
        // Added on July 29 2022 - Work Item: W-007477 - LMS Access for DLI-W Academic Advisors (AUG-1-2022)
        // Modified on Nov 18 2022 - Work Item: W-007631 - Create Instructor Community Users for Testing Projects
        Set<String> caPositionSet = new Set<String>{'Instructor','EI','Substitute Instructor','Class Leader','Student','Training Officer','Client','Coordinator','Billing Contact','Academic Adviser','COR','Contracting POC','Technical POC', 'KO', 'Tester'};
        Set<String> caRecordTypeSet = new Set<String>{'Instructor', 'Student'};
        
        /*
        if(todayVal.format('EEEE') == 'Monday'){
            startDate = Date.Today() + 4;
        }
        
        if(todayVal.format('EEEE') == 'Tuesday' || todayVal.format('EEEE') == 'Wednesday' || 
            todayVal.format('EEEE') == 'Thursday' || todayVal.format('EEEE') == 'Friday'){
            startDate = Date.Today() + 6;
        }
        */
        
        if(todayVal.format('EEEE') != 'Saturday' && todayVal.format('EEEE') != 'Sunday'){
        
            for(Contact_Assignments__c c : [
                SELECT Id, Candidate_Name__c, Start_Date__c, CreatedDate, Project__r.RecordType.DeveloperName, Project__r.Program_Iteration__r.Name, Project__c, 
                    RecordType.DeveloperName, Project__r.Project_Type__c, Project__r.Program_Iteration__c, Project__r.Moodle_Course_Id__c, 
                    Candidate_Name__r.Moodle_User_Id__c, Project__r.Start_Date__c, Candidate_Name__r.Active_DLS_Online_User__c, Assignment_Position__c, 
                    Project__r.DLS_Class__c, Project__r.Language__r.Name, Moodle_Sync_Status__c, Candidate_Name__r.Moodle_User_Status__c
                FROM Contact_Assignments__c
                WHERE Candidate_Name__c != NULL AND Candidate_Name__r.RecordType.DeveloperName != 'DLS_Employee' AND Status__c IN ('Planned', 'Active') 
                    AND (RecordType.DeveloperName IN : caRecordTypeSet OR (RecordType.DeveloperName = 'Client_Partner' 
                    AND Candidate_Name__r.RecordType.DeveloperName IN ('Commercial_Client', 'USG_Client') AND Candidate_Name__r.Account.Name LIKE '%DLI%'))
                    AND Start_Date__c != NULL AND ((Project__r.RecordType.DeveloperName != 'DLI_W_LT_Projects' AND Start_Date__c > TODAY) 
                    OR (Project__r.RecordType.DeveloperName = 'DLI_W_LT_Projects' AND Start_Date__c <= TODAY)) AND Paper_Timesheet__c = FALSE
                    AND Assignment_Position__c IN : caPositionSet
                    AND Project__r.QB_Classification__c != 'OF0MTT0PS' AND (NOT Project__r.Name LIKE '%Bah%') AND Project__r.AcctSeed__Status__c IN ('Order','Active') 
                    AND Project__r.Name NOT IN ('ELIZABETH HUML','MARA BOROUGHS','LEANN TAGWERKER','TRAVIS CUNNINGHAM','DLI Hausa-2018-Pena/Falanga','DLI Somali-2018-Deborah/Mickayla/Katie/Collin','Danielle Ward 2019')
            ]){
               
               if(c.Assignment_Position__c != 'Tester' && c.Project__r.RecordType.DeveloperName != 'Testing_Projects'){
                
                    filteredCAs.add(c);
                    filteredProjIds.add(c.Project__c);
                    filteredConIds.add(c.Candidate_Name__c);
                }
                
                Date stDate = c.Start_Date__c;
                DateTime stDateVal = DateTime.newInstance(stDate, Time.newInstance(0, 0, 0, 0));
                
                DateTime dT = c.CreatedDate;
                Date createDate = Date.newinstance(dT.year(), dT.month(), dT.day());
                
                Integer dayDiff = createDate.daysBetween(c.Start_Date__c);
                
                if(c.Candidate_Name__r.Active_DLS_Online_User__c == FALSE && 
                    c.Project__r.RecordType.DeveloperName != 'DODA_Projects' && c.Start_Date__c <= startDate && 
                    c.Project__r.RecordType.DeveloperName != 'DLI_W_LT_Projects'){
                    
                    /*
                    if(stDateVal.format('EEEE') == 'Monday' || stDateVal.format('EEEE') == 'Tuesday' ||
                        stDateVal.format('EEEE') == 'Wednesday' || stDateVal.format('EEEE') == 'Thursday'){
                        stDate = c.Start_Date__c - 5;
                    }
                
                    if(stDateVal.format('EEEE') == 'Friday' || stDateVal.format('EEEE') == 'Saturday'){
                        stDate = c.Start_Date__c - 3;
                    }
                    
                    if(stDateVal.format('EEEE') == 'Sunday'){
                        stDate = c.Start_Date__c - 4;
                    }
                    */
                    // Added By HL on Oct 14 2020
                    if(stDateVal.format('EEEE') == 'Monday' || stDateVal.format('EEEE') == 'Tuesday' ||
                        stDateVal.format('EEEE') == 'Sunday'){
                        stDate = c.Start_Date__c - 18;
                    }
                    
                    if(stDateVal.format('EEEE') == 'Wednesday' || stDateVal.format('EEEE') == 'Thursday' ||
                        stDateVal.format('EEEE') == 'Friday'){
                        stDate = c.Start_Date__c - 16;
                    }
                    
                    if(stDateVal.format('EEEE') == 'Saturday'){
                        stDate = c.Start_Date__c - 17;
                    }
                }else if(c.Candidate_Name__r.Active_DLS_Online_User__c == FALSE && 
                    c.Project__r.RecordType.DeveloperName == 'DODA_Projects' && c.Start_Date__c <= dodaProjSD &&
                    String.isNotBlank(c.Project__r.Project_Type__c) && projectType.contains(c.Project__r.Project_Type__c) && 
                    (c.Project__r.Program_Iteration__c != NULL || c.Project__r.Project_Type__c == 'IND')){
                
                    if(stDateVal.format('EEEE') == 'Monday' || stDateVal.format('EEEE') == 'Tuesday' ||
                        stDateVal.format('EEEE') == 'Wednesday' || stDateVal.format('EEEE') == 'Thursday' ||
                        stDateVal.format('EEEE') == 'Sunday'){
                        stDate = c.Start_Date__c - 20;
                    }
                
                    if(stDateVal.format('EEEE') == 'Friday'){
                        stDate = c.Start_Date__c - 18;
                    }
                    
                    if(stDateVal.format('EEEE') == 'Saturday'){
                        stDate = c.Start_Date__c - 19;
                    }
                }
                
                if((Date.Today() == stDate && ((c.Project__r.RecordType.DeveloperName != 'DODA_Projects' && dayDiff >= 12) || 
                    (c.Project__r.RecordType.DeveloperName == 'DODA_Projects' && dayDiff >= 14))) ||  
                    (c.Project__r.RecordType.DeveloperName == 'DLI_W_LT_Projects' && c.Start_Date__c <= Date.Today()) || 
                    Test.isRunningTest()){
                    
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
                    mail.sethtmlBody(mailContent);
                    mail.setSaveAsActivity(false);
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
}