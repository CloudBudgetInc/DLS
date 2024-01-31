public class AccountUtil{

    /**************
    - Added by Hl on Jan 24 2020
    - Work Item : W-004721 - PVT Student Child Account Creation
    ************/
    public static Boolean isChildPVTExist = FALSE;
    
    public static void createPVTAccRecs(String projId){
    
        Set<String> projStatus = new Set<String>{'Ended'};
        Set<String> childPVTAcNameANDEmail = new Set<String>();
        Set<String> conNameANDEmail = new Set<String>();
        
        Map<Id, Id> projIdAndConId = new Map<Id, Id>();
        List<Contact> contacts = new List<Contact>();
        List<Contact> updateCons = new List<Contact>();
                
        List<Account> accListToInsert = new List<Account>();
        List<AcctSeed__Project__c> updateProjs = new List<AcctSeed__Project__c>();
        Map<Id, Id> conIdAndAccId = new Map<Id, Id>();
        List<Opportunity> updatOppRecs = new List<Opportunity>();
        Set<Id> conIdsNotHavingPVTAcc = new Set<Id>();
        Map<String, Id> accNameEmailAndId = new Map<String, Id>();
               
        String conQry = 'SELECT Id, FirstName, LastName, Name, Email, Phone, AccountId, OwnerId, Owner.isActive, Account.Name';
        conQry += ' FROM Contact';
                
        String conAssignQry = 'SELECT Id, Candidate_Name__c, Candidate_Name__r.Name, Candidate_Name__r.Email, Project__c, Assignment_Position__c, Opportunity_Name__c';
        conAssignQry += ' FROM Contact_Assignments__c';
        conAssignQry += ' WHERE Project__c != NULL AND Project__r.AcctSeed__Status__c IN :projStatus AND Project__r.End_Date__c = LAST_MONTH AND RecordType.DeveloperName = \'Student\'';        
        try {
            if(String.isNotBlank(projId)){
                
                Id commClientRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commercial_Clients').getRecordTypeId();
                Account parentPVTAcc = new Account();            
                
                for(Account a : [SELECT Id, Name, Email__c FROM Account WHERE ((ParentId != NULL AND Parent.Name = 'PVT' AND RecordType.DeveloperName = 'Commercial_Clients') OR Name = 'PVT')]){
                
                    if(a.Name == 'PVT'){
                        parentPVTAcc = a;
                    }else{
                    
                        String nameEmail = a.Name+''+a.Email__c;
                        childPVTAcNameANDEmail.add(nameEmail);
                        accNameEmailAndId.put(nameEmail, a.Id);
                    }
                }
                System.debug(':::childPVTAcNameANDEmail::::'+childPVTAcNameANDEmail);
                System.debug('::::parentPVTAcc:::::'+parentPVTAcc);
                
                conAssignQry += ' AND Project__c = :projId';
                System.debug('::::conAssignQry:::::'+conAssignQry);
                    
                for(Contact_Assignments__c ca : Database.Query(conAssignQry)){
                    
                    String conNameEmail = ca.Candidate_Name__r.Name+''+ca.Candidate_Name__r.Email;
                    
                    if(!conNameANDEmail.contains(conNameEmail)){
                        
                        conNameANDEmail.add(conNameEmail);
                        if(!projIdAndConId.containsKey(ca.Project__c)) {
                            projIdAndConId.put(ca.Project__c, ca.Candidate_Name__c);
                        } else {
                        
                            if(ca.Assignment_Position__c == 'Class Leader'){
                                projIdAndConId.put(ca.Project__c, ca.Candidate_Name__c);    
                            }
                        }
                    }
                }
                System.debug('::::projIdAndConId:::::'+projIdAndConId);
                
                Set<Id> contIds = new Set<Id>(projIdAndConId.values());
                
                conQry += ' WHERE Id IN : contIds';
                
                System.debug('::::Database.Query(conQry):::::'+Database.Query(conQry));
                
                for(Contact c : Database.Query(conQry)){
                    
                    String nameEmail = 'PVT - '+c.Name+''+c.Email;
                    if(!childPVTAcNameANDEmail.contains(nameEmail)){
                        Account childPVTAcc = new Account();
                        childPVTAcc.Account_Code__c = (c.FirstName+''+c.LastName.substring(0,1)).toUpperCase();
                        childPVTAcc.Account_Full_Name__c = c.Name;
                        childPVTAcc.Name = 'PVT - '+c.Name;
                        childPVTAcc.RecordTypeId = commClientRTId;
                        childPVTAcc.AcctSeed__Accounting_Active__c = TRUE;
                        childPVTAcc.AcctSeed__Accounting_Type__c = 'Customer and Vendor';
                        childPVTAcc.Email__c = c.Email;
                        childPVTAcc.ParentId = parentPVTAcc.Id;
                        childPVTAcc.Phone = c.Phone;
                        childPVTAcc.OwnerId = c.OwnerId;
                        accListToInsert.add(childPVTAcc);
                        contacts.add(c);
                    } else {
                        // When the contact has PVT child Account
                        if(accNameEmailAndId.containsKey(nameEmail)) {
                            conIdAndAccId.put(c.Id, accNameEmailAndId.get(nameEmail));
                        }
                    }
                    
                    if(c.Account.Name != 'PVT'){
                    
                        conIdsNotHavingPVTAcc.add(c.Id);
                    }
                }
                System.debug(':::accListToInsert:::'+accListToInsert);
                System.debug(':::conIdsNotHavingPVTAcc:::'+conIdsNotHavingPVTAcc);
                System.debug(':::conIdsNotHavingPVTAcc:::SIZE::::::'+conIdsNotHavingPVTAcc.size());
                    
                if(accListToInsert.size() > 0){
                
                    insert accListToInsert; 
                    
                    for(Account a : accListToInsert){
                    
                        String s = a.Name+''+a.Email__c;
                        accNameEmailAndId.put(s, a.Id);    
                    }
                    System.debug(':::accNameEmailAndId:::::'+accNameEmailAndId);
                    
                }
                
                if(accNameEmailAndId != NULL && accNameEmailAndId.size() > 0){
                
                    for(Contact c : contacts){
                    
                        String s = 'PVT - '+c.Name+''+c.Email;
                        if(accNameEmailAndId.containsKey(s)){
                            c.AccountId = accNameEmailAndId.get(s);
                            conIdAndAccId.put(c.Id, c.AccountId);
                            updateCons.add(c);
                        }
                    }
                    System.debug(':::updateCons:::'+updateCons);
                    
                    if(updateCons.size() > 0){
                        update updateCons;
                    }
                }
                    
                System.debug(':::conIdAndAccId:::'+conIdAndAccId);
                
                if(projIdAndConId.size() > 0) {
                    for(AcctSeed__Project__c p : [SELECT Id, AcctSeed__Account__c, AcctSeed__Account__r.Name, AcctSeed__Opportunity__c, 
                                                    AcctSeed__Opportunity__r.AccountId, AcctSeed__Opportunity__r.Account.Name  
                                                FROM AcctSeed__Project__c 
                                                WHERE Id IN : projIdAndConId.keySet()]){
                    
                        if(projIdAndConId.containsKey(p.Id) && conIdAndAccId.containsKey(projIdAndConId.get(p.Id))){
                        
                            if(p.AcctSeed__Account__c != NULL && p.AcctSeed__Account__r.Name == 'PVT'){
                            
                                p.AcctSeed__Account__c = conIdAndAccId.get(projIdAndConId.get(p.Id));
                                updateProjs.add(p);
                            }
                            
                            if(p.AcctSeed__Opportunity__c != NULL && p.AcctSeed__Opportunity__r.AccountId != NULL && p.AcctSeed__Opportunity__r.Account.Name == 'PVT'){
                            
                                Opportunity opp = new Opportunity(Id = p.AcctSeed__Opportunity__c, AccountId = conIdAndAccId.get(projIdAndConId.get(p.Id)));
                                updatOppRecs.add(opp);  
                            }
                        }    
                    }
                }
                System.debug(':::updateProjs:::'+updateProjs);
                System.debug(':::updatOppRecs:::'+updatOppRecs);
                               
                if(updateProjs.size() > 0){
                    update updateProjs;
                }
                
                if(updatOppRecs.size() > 0){
                    update updatOppRecs;
                }
                
            }
        } Catch (Exception ex) {
            System.debug('Exception ::::'+ex);
        }
    }
    
    /**************
    - Added by Hl on Jan 24 2020
    - Work Item : W-004721 - PVT Student Child Account Creation
    ************/
    public static Id createChildPVT(String conId){
        
        Id childPVTAccId;
        String pvtOwnerId = '';
        
        Map<String, Id> accNameEmailAndId = new Map<String, Id>();
        
        Set<String> childPVTAcNameANDEmail = new Set<String>();        
        List<Contact> contacts = new List<Contact>();
        List<Contact> updateCons = new List<Contact>();
                
        List<Account> accListToInsert = new List<Account>();
        Map<Id, Id> conIdAndAccId = new Map<Id, Id>();
        Set<Id> conIdsNotHavingPVTAcc = new Set<Id>();
                
        String conQry = 'SELECT Id, FirstName, LastName, Name, Email, Phone, AccountId, OwnerId, Owner.IsActive, Account.Name';
        conQry += ' FROM Contact';
        
              
        try {
            if(String.isNotBlank(conId)){
                
                Id commClientRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Commercial_Clients').getRecordTypeId();
                Account parentPVTAcc = new Account();            
                
                for(Account a : [SELECT Id, Name, Email__c FROM Account WHERE ((ParentId != NULL AND Parent.Name = 'PVT' AND RecordType.DeveloperName = 'Commercial_Clients') OR Name = 'PVT')]){
                
                    if(a.Name == 'PVT'){
                        parentPVTAcc = a;
                    }else{
                                            
                        String nameEmail = a.Name+''+a.Email__c;
                        childPVTAcNameANDEmail.add(nameEmail);
                        accNameEmailAndId.put(nameEmail, a.Id);
                        
                    }
                }
                System.debug(':::childPVTAcNameANDEmail::::'+childPVTAcNameANDEmail);
                System.debug('::::parentPVTAcc:::::'+parentPVTAcc);
                                                
                conQry += ' WHERE Id =: conId';
                
                System.debug('::::conQry:::::'+conQry);
                // To populate Alma as the PVT Child account owner when the Contac's Owner is Inactive
                System_Values__c pvtChildAccOwnerId = System_Values__c.getValues('PVT Child Account Owner');
                            
                if(pvtChildAccOwnerId != NULL && pvtChildAccOwnerId.Value__c != NULL){
                    pvtOwnerId = pvtChildAccOwnerId.Value__c;
                }
                
                for(Contact c : Database.Query(conQry)){
                    
                    String nameEmail = 'PVT - '+c.Name+''+c.Email;
                    if(!childPVTAcNameANDEmail.contains(nameEmail)){
                    
                        Account childPVTAcc = new Account();
                        childPVTAcc.Account_Code__c = (c.FirstName+''+c.LastName.substring(0,1)).toUpperCase();
                        childPVTAcc.Account_Full_Name__c = c.Name;
                        childPVTAcc.Name = 'PVT - '+c.Name;
                        childPVTAcc.RecordTypeId = commClientRTId;
                        childPVTAcc.AcctSeed__Accounting_Active__c = TRUE;
                        childPVTAcc.AcctSeed__Accounting_Type__c = 'Customer and Vendor';
                        childPVTAcc.Email__c = c.Email;
                        childPVTAcc.ParentId = parentPVTAcc.Id;
                        childPVTAcc.Phone = c.Phone;
                        // When the Contact's Owner is Active, populate the Account owner from Contact Owner
                        if(c.Owner.IsActive == True ) {
                            childPVTAcc.OwnerId = c.OwnerId;
                        } else { // For Inactive Contact Owner's, Alma is the Owner of the PVT child account
                            childPVTAcc.OwnerId = pvtOwnerId;
                        }
                        accListToInsert.add(childPVTAcc);
                        contacts.add(c);
                    }else {
                                                
                        // Already child PVT Account record exist for this combination(Name and Email)
                        if(accNameEmailAndId.containsKey(nameEmail)){
                            
                            isChildPVTExist = TRUE;
                            
                            // For duplicate (Same Name and Email) contact record, in this case need to update contact record
                            if((c.AccountId != NULL && c.AccountId != accNameEmailAndId.get(nameEmail)) || c.AccountId == NULL){
                                contacts.add(c);
                            }else if(c.AccountId != NULL && c.AccountId == accNameEmailAndId.get(nameEmail)){
                                // if one contact comes again which have correct accountId already
                                // When the contact has PVT child Account
                                conIdAndAccId.put(c.Id, c.AccountId);
                            }
                        }
                    }
                    
                    if(c.Account.Name != 'PVT'){
                    
                        conIdsNotHavingPVTAcc.add(c.Id);
                    }
                }
                System.debug(':::accListToInsert:::'+accListToInsert);
                System.debug(':::conIdsNotHavingPVTAcc:::'+conIdsNotHavingPVTAcc);
                System.debug(':::conIdsNotHavingPVTAcc:::SIZE::::::'+conIdsNotHavingPVTAcc.size());
                    
                if(accListToInsert.size() > 0){
                
                    insert accListToInsert;
                                                
                    for(Account a : accListToInsert){
                    
                        String s = a.Name+''+a.Email__c;
                        accNameEmailAndId.put(s, a.Id);    
                    }
                    System.debug(':::accNameEmailAndId:::::'+accNameEmailAndId);
                }
                
                for(Contact c : contacts){
                    
                    String s = 'PVT - '+c.Name+''+c.Email;
                    if(accNameEmailAndId.containsKey(s)){
                        c.AccountId = accNameEmailAndId.get(s);
                        conIdAndAccId.put(c.Id, c.AccountId);
                        updateCons.add(c);
                    }
                }
                System.debug(':::updateCons:::'+updateCons);
                System.debug(':::conIdAndAccId:::'+conIdAndAccId);
                
                if(updateCons.size() > 0){
                    update updateCons;
                }
                    
                if(conIdAndAccId != NULL && conIdAndAccId.containsKey(conId)){
                    childPVTAccId = conIdAndAccId.get(conId);
                }    
            }                        
        } Catch (Exception ex) {
            System.debug('Exception ::::'+ex);
        }
        return childPVTAccId;
    }
    
    /**********************
        - Added by HL on Feb 17 2020
        - Work Item : W-004939 - Account Creation for Candidates (Instructors) for Accounting and HR
        - To create an account record for Candidate or DLS_Employee contact 
        *****************/
    public static String dlsInstructorAccountCreation(String conId){
    
        String childDLSAccId = '';
        Boolean isConExist = FALSE;
        
        Map<String, Id> accNameEmailAndId = new Map<String, Id>();
        Set<String> childDLSAccNameAndEmail = new Set<String>(); 
        
        List<Account> accListToInsert = new List<Account>();
        List<Contact> updateConRecs = new List<Contact>();
        
        Map<Id, Id> conIdAndAccId = new Map<Id, Id>();
        List<Contact> updateCons = new List<Contact>();
                    
        Account parentDLSCandAcc = new Account(); 
        Account parentDLSAcc = new Account();
        //String childAccOwnerId;
        
        Set<String> contactRTNames = new set<String>{'Candidate', 'DLS_Employee'};
        
        try{
        
            if(String.isNotBlank(conId)){
                
                List<Contact> contacts = [SELECT Id, FirstName, LastName, Name, Email, Phone, AccountId, OwnerId, Account.Name, 
                        RecordType.DeveloperName, MailingStreet, MailingCity, MailingState, MailingCountry, MailingPostalCode,
                        W_9_on_file__c, PC_EE_ID__c, EE_Pay_Status__c
                    FROM Contact 
                    WHERE Id = :conId AND RecordType.DeveloperName IN ('Candidate', 'DLS_Employee', 'Student')];
                System.debug('::::contacts:::::'+contacts);
                
                if(contacts != NULL && contacts.size() > 0){
                    
                    // Added By HL on Apr 22 2020
                    // Work Item : W-005307 - PVT - child account creation from Student Contact page
                    if(contacts[0].RecordType.DeveloperName == 'Student'){
                        
                        if(contacts[0].Account.Name == 'PVT'){
                        
                            Id childPVTAccId = createChildPVT(conId);
                                                
                            if(isChildPVTExist){
                                childDLSAccId = 'Account Exist'+'~'+childPVTAccId;
                            }else{
                                childDLSAccId = childPVTAccId;
                            }
                        }
                    }else if(contactRTNames.contains(contacts[0].RecordType.DeveloperName)){
                    
                        for(Account a : [SELECT Id, Name, Email__c, ParentId, Parent.Name, RecordType.DeveloperName 
                                            FROM Account 
                                            WHERE (Name = 'DLS - Candidate' OR Name = 'DLS' OR 
                                                (ParentId != NULL AND RecordType.DeveloperName = 'DLS' AND 
                                                (Parent.Name = 'DLS - Candidate' OR Parent.Name = 'DLS')))]){
                        
                            if(a.Name == 'DLS - Candidate'){
                                parentDLSCandAcc = a;
                            }
                            if(a.Name == 'DLS'){
                                parentDLSAcc = a;
                            }
                            if(a.ParentId != NULL && (a.Parent.Name == 'DLS - Candidate' || a.Parent.Name == 'DLS') && 
                                a.RecordType.DeveloperName == 'DLS'){
                                                    
                                String nameEmail = a.Name+''+a.Email__c;
                                childDLSAccNameAndEmail.add(nameEmail);
                                accNameEmailAndId.put(nameEmail, a.Id);
                            }
                        }
                    
                        //System_Values__c dlsChildAccOwnerId = System_Values__c.getValues('DLS Child Account OwnerId');
                            
                        /*if(dlsChildAccOwnerId != NULL && dlsChildAccOwnerId.Value__c != NULL){
                            childAccOwnerId = dlsChildAccOwnerId.Value__c;
                        }*/
                                
                        System.debug(':::childDLSAccNameAndEmail::::'+childDLSAccNameAndEmail);
                        System.debug('::::parentDLSCandAcc:::::'+parentDLSCandAcc);
                        System.debug('::::accNameEmailAndId:::::'+accNameEmailAndId);
                        
                        Id dlsRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('DLS').getRecordTypeId();
                                                    
                        for(Contact c : contacts){
                                
                            String nameEmail = 'DLS - '+c.Name+''+c.Email;
                            if(!childDLSAccNameAndEmail.contains(nameEmail)){
                            
                                Account childDLSAcc = new Account();
                                childDLSAcc.Account_Code__c = (c.FirstName+''+c.LastName.substring(0,1)).toUpperCase();
                                childDLSAcc.Account_Full_Name__c = c.Name;
                                childDLSAcc.Name = 'DLS - '+c.Name;
                                childDLSAcc.RecordTypeId = dlsRTId;
                                childDLSAcc.AcctSeed__Accounting_Active__c = TRUE;
                                childDLSAcc.AcctSeed__Accounting_Type__c = 'Customer and Vendor';
                                childDLSAcc.Email__c = c.Email;
                                childDLSAcc.Phone = c.Phone;
                                childDLSAcc.W_9_on_file__c = c.W_9_on_file__c;
                                childDLSAcc.PC_EE_ID__c = c.PC_EE_ID__c;
                                childDLSAcc.EE_Pay_Status__c = c.EE_Pay_Status__c;
                                childDLSAcc.OwnerId = UserInfo.getUserId();
                                if(c.RecordType.DeveloperName == 'Candidate'){
                                    childDLSAcc.ParentId = parentDLSCandAcc.Id;
                                    
                                    //Work Item : W-005025 - Account creation -few updates
                                    // Copying Contact's Mailing Address in to Account's shipping address
                                    /*childDLSAcc.ShippingStreet = c.MailingStreet;
                                    childDLSAcc.ShippingCity = c.MailingCity; 
                                    childDLSAcc.ShippingState = c.MailingState;
                                    childDLSAcc.ShippingCountry = c.MailingCountry;
                                    childDLSAcc.ShippingPostalCode = c.MailingPostalCode;*/
                                    childDLSAcc.BillingStreet = c.MailingStreet;
                                    childDLSAcc.BillingCity = c.MailingCity; 
                                    childDLSAcc.BillingState = c.MailingState;
                                    childDLSAcc.BillingCountry = c.MailingCountry;
                                    childDLSAcc.BillingPostalCode = c.MailingPostalCode;
                                } else if(c.RecordType.DeveloperName == 'DLS_Employee'){
                                    childDLSAcc.ParentId = parentDLSAcc.Id;
                                }
                                
                                /*if(String.isNotBlank(childAccOwnerId)){
                                    childDLSAcc.OwnerId = childAccOwnerId;
                                }*/
                                //Requested to set the created by User as the Account Owner instead of Leonora
                                
                                accListToInsert.add(childDLSAcc);
                                updateConRecs.add(c);
                            }else{
                            
                                // Already child DLS Account record exist for this combination(Name and Email)
                                if(accNameEmailAndId.containsKey(nameEmail)){
                                
                                    isConExist = TRUE;
                                    
                                    // For duplicate (Same Name and Email) contact record, in this case need to update contact record
                                    if((c.AccountId != NULL && c.AccountId != accNameEmailAndId.get(nameEmail)) || c.AccountId == NULL){
                                        updateConRecs.add(c);
                                    }else if(c.AccountId != NULL && c.AccountId == accNameEmailAndId.get(nameEmail)){
                                        // if click the button more than once (Already has DLS Account)
                                        conIdAndAccId.put(c.Id, c.AccountId);
                                    }
                                }
                            }
                        }
                        System.debug(':::accListToInsert:::'+accListToInsert);
                            
                        if(accListToInsert.size() > 0){
                        
                            insert accListToInsert;
                                                        
                            for(Account a : accListToInsert){
                            
                                String s = a.Name+''+a.Email__c;
                                accNameEmailAndId.put(s, a.Id);    
                            }
                            System.debug(':::accNameEmailAndId:::::'+accNameEmailAndId);
                        }
                        
                        if(updateConRecs != NULL && updateConRecs.size() > 0){
                        
                            for(Contact c : updateConRecs){
                                
                                String s = 'DLS - '+c.Name+''+c.Email;
                                if(accNameEmailAndId.containsKey(s)){
                                    c.AccountId = accNameEmailAndId.get(s);
                                    conIdAndAccId.put(c.Id, c.AccountId);
                                    updateCons.add(c);
                                }
                            }
                        }
                        
                        System.debug(':::updateCons:::'+updateCons);
                        System.debug(':::conIdAndAccId:::'+conIdAndAccId);
                            
                        if(updateCons.size() > 0){
                            update updateCons;
                        }
                        
                        if(conIdAndAccId != NULL && conIdAndAccId.containsKey(conId)){
                        
                            if(isConExist){
                                childDLSAccId = 'Account Exist'+'~'+conIdAndAccId.get(conId);
                            }else{
                                childDLSAccId = conIdAndAccId.get(conId);
                            }
                        } 
                    }
                }else{
                
                    childDLSAccId = 'Invalid RecordType';
                }
                System.debug(childDLSAccId);
            }
        }Catch (Exception ex) {
            throw new DmlException(ex.getMessage());
        }
        System.debug(':::::childDLSAccId:::::'+childDLSAccId);
        return childDLSAccId;
    }
}