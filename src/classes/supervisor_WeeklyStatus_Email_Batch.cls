/********************************************************************************************
    - Batch called from WeeklyStatusEmail_schedule class
    - An e-mail notification to the managers will be sent to all Supervisors on Monday outlining status of timesheets by Approval Status
    - Email template used - Supervisor_Weekly_Status_Summary_Mail
********************************************************************************************/

global class supervisor_WeeklyStatus_Email_Batch implements Database.batchable<sObject>,Database.Stateful{ 

    global List<Messaging.SingleEmailMessage> EmailToInstructorList;
    global Set<Id> contactIdset = new Set<Id>();
    global Map<Id,Id> DAUsrId_DAConId = new Map<Id,Id>();
    global Map<Id,Id> sconId_sUserId = new Map<Id,Id>(); // To hold supervisor Contact Id equivalent user Id
    global Map<Id,Boolean> ConIdLeaveFlag = new Map<Id,Boolean>();    // To capture the supervisor which are in leave
    global Map<Id,String> actualConId_Email = new Map<Id,String>();    // Actual supervisor contact id & email 
    global Map<Id,Id> supervisorId_DAId = new Map<Id,Id>();
    
    Date myDate = date.today();
    Date weekstdate = myDate.toStartofWeek()+1;
    Date weekenddate = myDate.toStartofWeek()+7;
    
    Date Laststdate = weekstdate.addDays(-7);
    Date Lastenddate = weekenddate.addDays(-7);

    global Database.QueryLocator start(Database.BatchableContext info){
       
        String  dayQry = 'SELECT Id,Name,AcctSeed__Time_Card_Line__c,AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__c,'+
                                'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__c,'+
                                'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__c,'+
                                'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.FirstName,'+
                                'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.MiddleName,'+
                                'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.LastName,'+
                                'AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.DelegatedApproverId'+
                         ' FROM AcctSeed__Time_Card_Day__c'+
                         ' WHERE AcctSeed__Date__c >= :Laststdate AND AcctSeed__Date__c <= :Lastenddate '+
                         'AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.RecordType.DeveloperName = \'DLS_Employee\' '+
                         'AND AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.IsActive = true '+
                         'AND AcctSeed__Time_Card_Line__r.of_Submitted_Hours__c > 0';
        System.debug(':::::::dayQry::::::'+dayQry);
        return Database.getQueryLocator(dayQry);
    }
        
    global void execute(Database.BatchableContext info, List<AcctSeed__Time_Card_Day__c> dayList){
       
        /*for(AcctSeed__Time_Card_Day__c dayValues : dayList){
            contactIdset.add(dayValues.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__c);
        }*/
        
        Set<String> firstName = new Set<String>();
        Set<String> middleName = new Set<String>();
        Set<String> lastName = new set<String>();
        Set<Id> supervisorIds = new Set<Id>();
        Map<String,Id> supervisorName_Id = new Map<String,Id>();
        
        // Get the delegated Approver user related infor
        Map<String,Id> DAName_DAId = new Map<String,Id>();
        Set<String> DAFirstName = new Set<String>();
        Set<String> DAMiddleName = new Set<String>();
        Set<String> DALastName = new Set<String>();
        
         
        for(AcctSeed__Time_Card_Day__c dayValues : dayList){
            String fName = dayValues.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.FirstName;
            String mName = dayValues.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.MiddleName;
            String lName = dayValues.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.LastName;
            firstName.add(fName);
            middleName.add(mName);
            lastName.add(lName);
            
            //Send Email to the Delegated Approver, if the actual approver is off on that day 
            Id supervisorId = dayValues.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__c;
            Id DAId = dayValues.AcctSeed__Time_Card_Line__r.AcctSeed__Time_Card__r.Intructor__r.Supervisor_Name__r.DelegatedApproverId;
            
            String supervisorName = fName+'~'+mName+'~'+lName;
            if(!supervisorName_Id.containsKey(supervisorName))
                supervisorName_Id.put(supervisorName,supervisorId);
            
            supervisorIds.add(supervisorId);
            
            if(!supervisorId_DAId.containsKey(supervisorId))
                supervisorId_DAId.put(supervisorId,DAId);
        }
        
        system.debug('::::firstName::::::::'+firstName);
        system.debug('::::middleName::::::::'+middleName);
        system.debug('::::lastName::::::::'+lastName);
        system.debug(':::::supervisorIds::::'+supervisorIds);
        
        
        // Delagated Approver related information
        for(User usr : [SELECT Id,Name,FirstName,MiddleName,LastName FROM User WHERE Id IN :supervisorId_DAId.values()]){
            String DAName = usr.FirstName+'~'+usr.MiddleName+'~'+usr.LastName;
            if(!DAName_DAId.containsKey(DAName))
                DAName_DAId.put(DAName,usr.Id);
                
            DAFirstName.add(usr.FirstName);
            DAMiddleName.add(usr.MiddleName);
            DALastName.add(usr.LastName);
        }
        
        // Qry DA Names related contacts to form the DA User related contacts
        for(Contact con : [SELECT Id,Name,FirstName,MiddleName,LastName 
                            FROM Contact 
                            WHERE FirstName IN :DAFirstName AND MiddleName IN :DAMiddleName AND LastName IN :DALastName 
                                AND RecordType.DeveloperName = 'DLS_Employee' AND Active_DLS_Employee__c = true]){
            String conName = con.FirstName+'~'+con.MiddleName+'~'+con.LastName;
            
            if(DAName_DAId.containsKey(conName)) {
                DAUsrId_DAConId.put(DAName_DAId.get(conName),con.Id);
            }
        }
        
        // Get the delegated approvar infor based on supervisor planned days off
        
        for(Planned_Days_Off__c pdo : [SELECT Id,Name,Date__c,Contact__c,Contact__r.DLS_User__c
                                         FROM Planned_Days_Off__c 
                                         WHERE Date__c = TODAY AND RecordType.DeveloperName = 'Staff_Planned_Days_Off' AND Contact__r.DLS_User__c IN :supervisorIds]){
            
            if(!ConIdLeaveFlag.containsKey(pdo.Contact__c))
                ConIdLeaveFlag.put(pdo.Contact__c,true);
        }
        
        for(Contact con : [SELECT Id,Name,Email,FirstName,MiddleName,LastName 
                            FROM Contact 
                            WHERE FirstName IN :firstName AND MiddleName IN :middleName AND LastName IN :lastName 
                                AND RecordType.DeveloperName = 'DLS_Employee' AND Active_DLS_Employee__c = true]) {
            contactIdset.add(con.Id);
            actualConId_Email.put(con.Id,con.Email);
            
            String conName = con.FirstName+'~'+con.MiddleName+'~'+con.LastName;
            
            if(supervisorName_Id.containsKey(conName)) {
                sconId_sUserId.put(con.Id,supervisorName_Id.get(conName));
            }
        }
        
        system.debug(':::supervisor_WeeklyStatus_Email:::contactIdset::::::'+contactIdset);
        system.debug(':::supervisor_WeeklyStatus_Email:::ConIdLeaveFlag::::::'+ConIdLeaveFlag);
        system.debug(':::supervisor_WeeklyStatus_Email:::sconId_sUserId::::::'+sconId_sUserId);
        system.debug(':::supervisor_WeeklyStatus_Email:::supervisorId_DAId::::::'+supervisorId_DAId);
        system.debug(':::supervisor_WeeklyStatus_Email:::DAUsrId_DAConId::::::'+DAUsrId_DAConId);
    }
    
    global void finish(Database.BatchableContext info){ 
    
        EmailToInstructorList = new List<Messaging.SingleEmailMessage>(); 
        try {
           EmailTemplate templateId = [Select id from EmailTemplate WHERE DeveloperName = 'Supervisor_Weekly_Status_Summary_Mail'];
           
           // Qry system value custom setting to get org wide email address for timesheets
           System_Values__c sysVal = System_Values__c.getValues('Timesheet'); 
           String orgWideEmailId = '';
           
           if(sysVal != null && sysVal.Value__c != null) {
               orgWideEmailId = sysVal.Value__c;
           }
           
           if(contactIdset != null && contactIdset.size() > 0 && templateId != null) {
            
                for(Id conId :contactIdset){
                
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    if(orgWideEmailId != null) {
                        mail.setOrgWideEmailAddressId(orgWideEmailId);
                    }
                    // Check if the supervisor contact is in leave or not - Added by NS on July 
                    if(ConIdLeaveFlag.containsKey(conId) && ConIdLeaveFlag.get(conId)) {
                        Id supervisorId = sconId_sUserId.containsKey(conId) ? sconId_sUserId.get(conId) : null;
                        
                        mail.setCcAddresses(new List<String>{actualConId_Email.get(conId)});
                        mail.setWhatId(conId);
                        
                        if(supervisorId_DAId.containsKey(supervisorId)) {
                            Id DAUsrId = supervisorId_DAId.get(supervisorId);
                            
                            if(DAUsrId_DAConId.containsKey(DAUsrId))
                                mail.setTargetObjectId(DAUsrId_DAConId.get(DAUsrId));
                        }
                    }else {
                        mail.setTargetObjectId(conId);
                    }
                    mail.setTemplateID(templateId.Id);
                    mail.setSaveAsActivity(false);
                    EmailToInstructorList.add(mail);
                }
            }
            
            System.debug('EmailToInstructorList:::::::::::supervisor_WeeklyStatus_Email:::::::'+EmailToInstructorList);
            
            if( EmailToInstructorList != null && EmailToInstructorList.size() > 0 ) {
               Messaging.SendEmailResult[] results = Messaging.sendEmail(EmailToInstructorList);
            }
        }catch(Exception e) {
        
            List<Messaging.SingleEmailMessage> ErrorMailMsg = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
            mail.setToAddresses(new String[] {system.Label.TimeCardDayEmail});
            mail.setSubject('Error on Supervisor Weekly status Email send'); 
            mail.setPlainTextBody(e.getMessage());
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
}