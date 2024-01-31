//Contact Name Updation details
trigger User_Trigger on User (before insert,before update,after update, after insert) {
   
   List<Contact> conupdateList = new List<Contact>();
   Map<String,String> userMap = new Map<String,String>();
   Map<String,String> userOldMap = new Map<String,String>();
   Set<String> middlenameSet = new Set<String>();   
   
   // Added by NS on April 18 2017 for User.ManagerId field update on Contact.Supervisor field
   Set<String> firstName = new Set<String>();
   Set<String> middleName = new Set<String>();
   Set<String> lastName = new Set<String>();
   
   Map<String,Id> userNameManagerIdMap = new Map<String,Id>();
   
   for(User usr : Trigger.new){
   
       if(trigger.isAfter){
       
           if(trigger.isUpdate && (Trigger.oldMap.get(usr.Id).FirstName != usr.FirstName || Trigger.oldMap.get(usr.Id).MiddleName != usr.MiddleName || Trigger.oldMap.get(usr.Id).LastName != usr.LastName)){
              middlenameSet.add(Trigger.oldMap.get(usr.Id).MiddleName);
              userOldMap.put(Trigger.oldMap.get(usr.Id).FirstName,Trigger.oldMap.get(usr.Id).LastName); 
              userMap.put(Trigger.oldMap.get(usr.Id).FirstName+';'+Trigger.oldMap.get(usr.Id).MiddleName+';'+Trigger.oldMap.get(usr.Id).LastName,usr.FirstName+';'+usr.MiddleName+';'+usr.LastName); 
           } 
       
           // Start of Code - NS
       
            if(Trigger.isInsert || ( trigger.isUpdate && trigger.oldmap.get(usr.Id).ManagerId != usr.ManagerId)) {
                if(usr.IsActive && usr.ManagerId != null) {
                     firstName.add(usr.FirstName);
                     middleName.add(usr.MiddleName);
                     lastName.add(usr.LastName);
                     
                     String name =  usr.FirstName+'-'+usr.MiddleName+'-'+usr.LastName;
                     if(!userNameManagerIdMap.containsKey(name)) {
                         userNameManagerIdMap.put(name,usr.ManagerId);
                     }
                 }
            }
        }  
   }
   
   //Qry user names related DLS Employee contact records to update name
   //This contact update is done in same execution beacuase it will not create any pblm
   
   //List<Contact> conList = [Select Id,Name,FirstName,LastName From Contact where FirstName like :userOldMap.keySet() AND LastName like :userOldMap.values() AND MiddleName like :middlename];
   List<Contact> conList = new List<Contact>();
   Set<String> lastnameSet = new Set<String>(userOldMap.values());
   if((userOldMap.keySet() != null && userOldMap.keySet().size() > 0) || (lastnameSet != null && lastnameSet.size() > 0) || (middlenameSet != null && middlenameSet.size() > 0)){
      conList = ContactService.getContactRecDetails(userOldMap.keySet(),lastnameSet,middlenameSet);
   }
   
    for(Contact con : conList){
       String old = con.FirstName+';'+con.MiddleName+';'+con.LastName;       
       if(userMap.containsKey(old)){
           List<String> newconname = userMap.get(old).Split(';');
           if(newconname[0] == 'null')
               con.FirstName = '';
           else
               con.FirstName = newconname[0];
           
           if(newconname[1] == 'null')
               con.MiddleName = '';
           else
               con.MiddleName  = newconname[1];
               
           if(newconname[2] == 'null')
               con.LastName = '';
           else
               con.LastName  = newconname[2];
       }           
       conupdateList.add(con);
    }
    
    if(conupdateList != null && conupdateList.size() > 0){
        update conupdateList;
    }
    
    // Start of my Code - NS
    // Qry user name related DLS Employee contact record to update supervisor field on contact
    
    List<Contact> conSupervisorUpdate = new List<Contact>();
    system.debug('firstName'+firstName);
    if(firstName.size() > 0 || middleName.size() > 0 || lastName.size() > 0) {
    
        for(Contact conRec : [SELECT Id,FirstName,MiddleName,LastName,Supervisor_Name__c FROM Contact 
                                WHERE FirstName IN :firstName AND MiddleName IN :middleName AND LastName IN :lastName 
                                    AND RecordType.DeveloperName = 'DLS_Employee']) {
                                
            String conName = conRec.FirstName+'-'+conRec.MiddleName+'-'+conRec.LastName;
            if(userNameManagerIdMap.containsKey(conName) && conRec.Supervisor_Name__c != userNameManagerIdMap.get(conName)) {
                conRec.Supervisor_Name__c = userNameManagerIdMap.get(conName);
                conSupervisorUpdate.add(conRec);
            }
        }
    }
    
   //Call future method to avoid Mixed DML Error
    if(conSupervisorUpdate.size() > 0) {
        ContactTrigger_FutureHandler.updateContactRecords(JSON.serialize(conSupervisorUpdate));
    }
    //End of my added code - NS

    
    /*****************
        - Added by HL on Sep 10 2019
        - Work Item :  W-001476 - Community User Login Experience (Login, Logout, New User Welcome Emails, Password Resets, etc.
        - This is related to community user creation
        - Once user records are created / updated then the task records will created under related contact 
        **************/
        
    if(Trigger.isAfter){
    
        if(Trigger.isInsert || Trigger.isUpdate){
            
            Id instructorProfileId;
            Id studentProfileId;
            Id clientProfileId;    //W-007477: LMS Access for DLI-W Academic Advisors (AUG-1-2022)
            Set<Id> conIds = new Set<Id>();
            List<contact> contactsForUpdate = new List<contact>();
            
            for(Profile pro : [SELECT Id,Name FROM Profile WHERE Name IN ('Instructor Community','Student Community','Client Community')]){
                if(pro.Name == 'Instructor Community'){
                    instructorProfileId = pro.Id;
                }else if(pro.Name == 'Student Community'){
                    studentProfileId = pro.Id;
                }else if(pro.Name == 'Client Community'){
                    clientProfileId = pro.Id;
                }
            }
                        
            for(User u : Trigger.new){
                           
                //For task creation
                if(Trigger.isInsert || (Trigger.isUpdate && (u.ProfileId != Trigger.oldMap.get(u.Id).ProfileId ||
                    u.Email != Trigger.oldMap.get(u.Id).Email || u.IsActive != Trigger.oldMap.get(u.Id).IsActive))){
                       
                    // To prevent contact field updation while sending reminder email to create password
                    if(!ContactTrigger_FutureHandler.fromContactEmail && !UserManagementUtil.skipContactUpdateFromPwdReminder){ /*&& !UserManagementUtil.fromExistingUserUpdate*/    // Active_DLS_Online_User__c flag is not updated so that commented this condition
                    
                        if(u.IsActive && u.ContactId != NULL && (u.ProfileId == instructorProfileId || u.ProfileId == studentProfileId)){
                        
                            conIds.add(u.ContactId);    
                        }    
                        
                        //checkfor active field update, based on that update contact's Active DLS Online User field
                        if(u.ContactId != NULL && (u.ProfileId == instructorProfileId || u.ProfileId == studentProfileId || u.ProfileId == clientProfileId)){
                            
                            Contact con = new Contact();
                            con.Id = u.ContactId;
                            con.Active_DLS_Online_User__c = u.IsActive;
                            
                            if(Trigger.isUpdate && u.ProfileId != Trigger.oldMap.get(u.Id).ProfileId && 
                                Trigger.oldMap.get(u.Id).ProfileId == studentProfileId){
                            
                                con.Time_Approval_Preference__c = '';
                            }
                            if(u.ProfileId == studentProfileId){
                                // Work Item: W-007441 - Student Timekeeping Approval Reminder and Process Changes (4.20.22)
                                // To update default Timekeeping Reminders to "Weekly" instead of "Daily"
                                con.Time_Approval_Preference__c = 'Weekly';
                            }
                            contactsForUpdate.add(con);
                        }
                    }
                }
            } 
             
            System.debug(':::::::conIds::::::'+conIds);
            system.debug(':::::::::contactsForUpdate::::'+contactsForUpdate);
            
            // Create Task list & update contact's Active DLS Online User flag
            if(conIds.size() > 0 || contactsForUpdate.size() > 0){
                UserManagementUtil.createTaskForContact(conIds,contactsForUpdate);   
            } 
        }          
    }
}