// Created batch class by Sukanya on June 06 2017
// To create users from contact which are related to the time log records
global class UserCreation_FrmContact implements Database.batchable<sObject>,Database.Stateful { 

    global Id oppId;
    global UtilDomain.batchParameters batchParam = new UtilDomain.batchParameters();
    global Id newProjectId;
    
    global Set<Id> existingTLIds = new Set<Id>();
    
    // For Exception handling process
    global List<UtilDomain.ErrorWrapper> errorWrapperList = new List<UtilDomain.ErrorWrapper>();
    
    public UserCreation_FrmContact(UtilDomain.batchParameters params) {
        system.debug(':::::params'+params);
        oppId = params.oppId;
        batchParam = params;
        existingTLIds = params.existingTLIds;
        newProjectId = params.newProjectId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext info){  
        system.debug('::::::querylocator'+info);
        String timeLogQry = 'SELECT Contact__c,Contact__r.FirstName,Contact__r.MiddleName,Contact__r.LastName '+
                            'FROM Time_Log__c '+
                            'WHERE Opportunity__c = :oppId AND Unposted__c = False AND Contact__c != null AND Id NOT IN : existingTLIds';
        
        system.debug('::::::::::timeLogQry:::::::'+timeLogQry);
        return Database.getQueryLocator(timeLogQry);
    }
    
    global void execute(Database.BatchableContext info, List<Time_Log__c> timeLoglist){
        system.debug(':::::::::timeLoglist:::::::::'+timeLoglist);
        
        Set<Id> contactIdSet = new Set<Id>();
        List<User> userList = new List<User>();
        Map<Id,Id> conIdUsrIdMap = new Map<Id,Id>();
        String nick;
        String aliasName;
        String last;
        Map<String,Id> usrNameidMap = new Map<String,Id>();
        
        Set<String> firstName = new Set<String>();
        Set<String> middleName = new Set<String>();
        Set<String> lastName = new Set<String>();
        
        //Savepoint sp = Database.setSavepoint(); 
        
        try {
            for(Time_Log__c timeLog : timeLoglist) {
                contactIdSet.add(timeLog.Contact__c);
                
                firstName.add(timeLog.Contact__r.FirstName);
                middleName.add(timeLog.Contact__r.MiddleName);
                lastName.add(timeLog.Contact__r.LastName);
                
            }
            
            system.debug(':::::::::contactIdSet::::::::'+contactIdSet);
            system.debug(':::::contactIdSet:::size:::'+contactIdSet.size());
            
            List<Profile> profileRec = [SELECT Id,Name FROM Profile WHERE Name = 'Customer Community User Clone'];
            
            for(User usr : [SELECT Id,Name,Email,ContactId,FirstName,MiddleName,LastName FROM User WHERE FirstName IN : firstName AND MiddleName IN : middleName AND LastName IN : lastName]){
                
                if(!conIdUsrIdMap.containsKey(usr.ContactId) && usr.ContactId != null){
                    conIdUsrIdMap.put(usr.ContactId,usr.Id);
                }
                
                String nameStr = usr.FirstName+'-'+usr.MiddleName+'-'+usr.LastName;
                nameStr = nameStr.toLowerCase();
                
                if(!usrNameidMap.containsKey(nameStr))
                    usrNameidMap.put(nameStr,usr.Id);
                    
            }
            system.debug(':::::conIdUsrIdMap::::::'+conIdUsrIdMap);
            system.debug('::::::usrNameidMap::::::'+usrNameidMap);
            
            for(Contact con: [SELECT Id,Email,Name,FirstName,LastName,MiddleName,AccountId,Account.Name,RecordType.DeveloperName FROM Contact WHERE Id IN : contactIdSet]){
                
                String nickName = '';
                
                if(con.Email != null && con.Email.contains('@'))
                    nickName = con.Email.Split('@')[0];
                    
                if(nickName.contains('.')){
                    nick = nickName.Split('\\.')[0];
                }else if(nickName.contains('_')){
                    nick = nickName.Split('_')[0];
                }else {
                    nick = nickName;
                }
                
                String fname = con.FirstName;
                String lname = con.LastName;
                
                if(lname.length() <= 4){
                    last = lname;
                }else{
                    last = lname.substring(0,4);
                }
                aliasName = fname.substring(0,1)+last;
                system.debug('::::aliasName:::::'+aliasName);
                
                
                String conNameStr = con.FirstName+'-'+con.MiddleName+'-'+con.LastName;
                system.debug('::::::::::conNameStr:::::::::'+conNameStr);
                
                conNameStr = conNameStr.toLowerCase();
                
                if(usrNameidMap.containsKey(conNameStr)) {
                    system.debug('::::::::conNameStr::::::'+conNameStr);
                    system.debug(':::usrNameidMap:::::::::::::::'+usrNameidMap.get(conNameStr));
                }
                    
                if(!conIdUsrIdMap.containsKey(con.Id) && con.RecordType.DeveloperName != 'DLS_Employee' && !usrNameidMap.containsKey(conNameStr)){
                    User usr = new User(Email = 'sukanyan@softsquare.biz',ProfileId = profileRec[0].Id,Username = con.Email,CommunityNickname = nick,Instructor_Access__c = true,ContactId = con.Id,IsActive = true,EmailEncodingKey = 'ISO-8859-1',FirstName = con.FirstName,LastName = con.LastName,Alias = aliasName,LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',TimeZoneSidKey = 'America/New_York');
                    userList.add(usr);
                }else if(!conIdUsrIdMap.containsKey(con.Id) && !usrNameidMap.containsKey(conNameStr)) {
                    User usr = new User(Email = 'sukanyan@softsquare.biz',ProfileId = profileRec[0].Id,Username = con.Email,CommunityNickname = nick,Staff_Access__c = true,ContactId = con.Id,IsActive = true,EmailEncodingKey = 'ISO-8859-1',FirstName = con.FirstName,LastName = con.LastName,Alias = aliasName,LanguageLocaleKey = 'en_US',LocaleSidKey = 'en_US',TimeZoneSidKey = 'America/New_York');
                    userList.add(usr);
                }
            
            }
            
            system.debug('::::::::userList:::::::::'+userList);
            system.debug('::::::::userList:::::::::'+userList.size());
            
            if(userList.size() > 0){
                //insert userList;
                
                Database.SaveResult[] srList = Database.insert(userList, false);
               
                for(Integer i = 0; i < srList.size(); i++) {
                    String errMsg = '';
                    
                    system.debug('::::::::::userList:::::::::'+userList[i]);
                    
                    User usr = userList[i];
                    
                    if (!srList[i].isSuccess()) {
                        system.debug('::::::::usr::id::::::'+usr.Id);
                        if(srList[i].getId() == null) {
                            system.debug('::::::::::usr:::::::::'+usr);
                            
                            Contact con = new Contact();
                            con.Id = usr.ContactId;
                            con.FirstName = usr.FirstName;
                            con.LastName = usr.LastName;
                            
                            for(Database.Error err : srList[i].getErrors()) {
                                System.debug('::::::::::::::: ' + err.getMessage());
                                errMsg += err.getMessage();
                            }
                            
                            UtilDomain.ErrorWrapper errWrapper = new UtilDomain.ErrorWrapper(con,errMsg,'User');
                            errorWrapperList.add(errWrapper);
                        }
                    }
                }
                
            }
        }catch(DmlException e) {
            sendEmailWhenErrorOccurs(e.getMessage());
            //Database.RollBack(sp);
        } catch(SObjectException e) {
            sendEmailWhenErrorOccurs(e.getMessage()); 
            //Database.RollBack(sp);  
        } catch(Exception e) {
            sendEmailWhenErrorOccurs(e.getMessage());  
            //Database.RollBack(sp);   
        }
    }
    
    global void finish(Database.BatchableContext info){ 
        
        // Consolidated Email for user creation failure
        
        if(errorWrapperList != null && errorWrapperList.size() > 0) {
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            String mailContent = '<html>Dear Softsquare,<br/>The following errors are occured during user creation:'; 
            mailContent += '<br/><table border="1" style="border-collapse: collapse"><thead><th>Contact Name</th><th>Error Description</th></thead><tbody>';    
            
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
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            List<String> supervisorEmails = new List<String>();
            for(Contact_Assignments__c conAss : [SELECT Id,Name,Project__c,Candidate_Name__c,Candidate_Name__r.Email FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Staff' AND Project__c = :newProjectId AND Status__c = 'Active']) {
                if(conAss.Candidate_Name__r.Email != null)
                    supervisorEmails.add(conAss.Candidate_Name__r.Email);
            }
            
            supervisorEmails.add('cbellas@dlsdc.com');
            supervisorEmails.add('abellas@dlsdc.com');
            
            //To add any emails in future used custom label to hold the emails
            List<String> exceptionMails = new List<String>();
            
            for(String str : system.Label.Convert_to_Project_Exception_Mails.split(',')){
                exceptionMails.add(str.trim());
            }
            
            //mail.setToAddresses(supervisorEmails);
            mail.setToAddresses(exceptionMails);
            mail.setSubject('Error on User creation from contact');
            mail.sethtmlBody(mailContent);
            mails.add(mail);
            System.debug('mails::::'+mails);
            if( mails != null && mails.size() > 0 && !Test.isRunningTest()) {
                Messaging.sendEmail(mails);
            }
            
        }
        
        // Time Card details creation batch call
        
        TimeCard_Creation_FromCTP  timeCTP = new TimeCard_Creation_FromCTP(batchParam);
        database.executeBatch(timeCTP,1);
    }
    
     public void sendEmailWhenErrorOccurs(String mailContent) {
        
        List<Messaging.SingleEmailMessage> ErrorMailMsg = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
        mail.setToAddresses(new String[] {system.Label.TimeCardDayEmail});
        mail.setSubject('Error on User record creation from contact on ConverToproject execution'); 
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