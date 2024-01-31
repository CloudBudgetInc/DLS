/*
    This trigger is intended to update the record type of contact on lead conversion and to create Contact assignment for Opportunity 
    Implemented by Softsquare on 09/27/2016
*/
trigger LeadTypeMatching on Lead (after update, before insert, before update) {
    
    if (trigger.isBefore) {
    
        List<Lead> leadListToUpdate = new List<Lead>();
        Set<Id> languageIdSet = new Set<Id>();
        
        for (Lead ld : trigger.new) {
        
            Lead oldLdRec = (trigger.isUpdate) ? trigger.oldMap.get(ld.Id) : null;            
            if ((ld.Language_or_Dialect__c != null || ld.Source_Language__c != null || ld.Target_Language__c != null) && 
               (trigger.isInsert || (trigger.isUpdate && (ld.Language_or_Dialect__c != oldLdRec.Language_or_Dialect__c || ld.Source_Language__c != oldLdRec.Source_Language__c || ld.Target_Language__c != oldLdRec.Target_Language__c)))) {
            
                leadListToUpdate.add(ld);
                if (ld.Language_or_Dialect__c != null) {
                    languageIdSet.add(ld.Language_or_Dialect__c);
                }
                if (ld.Source_Language__c != null) {
                    languageIdSet.add(ld.Source_Language__c);
                }
                if (ld.Target_Language__c != null) {
                    languageIdSet.add(ld.Target_Language__c);
                }
            }
            
            if (trigger.isUpdate) {
                if (oldLdRec.Language_or_Dialect__c != null && ld.Language_or_Dialect__c == null) { 
                    ld.Languages__c = '';
                } 
                if (oldLdRec.Source_Language__c != null && ld.Source_Language__c == null) {
                    ld.Source_Language_Pardot__c = '';   
                }
                if (oldLdRec.Target_Language__c != null && ld.Target_Language__c == null) {
                    ld.Target_Language_Pardot__c = '';
                }    
            }
        }
        
        if (leadListToUpdate.size() > 0) {
            Map<Id, Language__c> languageMap = new Map<Id, Language__c>([SELECT Id, Name FROM Language__c WHERE Id IN :languageIdSet]);
            for (Lead ld : leadListToUpdate) {
                ld.Languages__c = (languageMap.containsKey(ld.Language_or_Dialect__c)) ? languageMap.get(ld.Language_or_Dialect__c).Name : '';
                ld.Source_Language_Pardot__c = (languageMap.containsKey(ld.Source_Language__c)) ? languageMap.get(ld.Source_Language__c).Name : '';
                ld.Target_Language_Pardot__c = (languageMap.containsKey(ld.Target_Language__c)) ? languageMap.get(ld.Target_Language__c).Name : '';
            }
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){        
           
        Set<Id> acc =  new Set<Id>();
        set<Id> cnt =  new Set<Id>();
        Set<Id> opp = new Set<Id>();         
        List<String> listTypeName = new List<String>();  
        Map<String,RecordType> custIdCustObject = new Map<String,RecordType>();                         
        Map<Id,Id> accs = new Map<Id,Id>();
        Map<Id,Id> cnts = new Map<Id,Id>();
        Map<Id,Id> opps = new Map<Id,Id>();        
        List<Account> upAccountList = new List<Account>();
        List<Contact> upContactList = new List<Contact>();
        List<Opportunity> upOpportunityList = new List<Opportunity>();
        List<Contact_Assignments__c> upContactAssignments = new List<Contact_Assignments__c>();    
        Long milliseconds = 30000;
        Map<String,RecordType> OppDevNameRecTypeMap = new Map<String,RecordType>();
        Map<String,RecordType> AccDevNameRecTypeMap = new Map<String,RecordType>();               
        Map<String,String> leadAndOppTypeMap = new Map<String,String>{
            /*'AFPAK Classes' => 'AFPAK_Classes',
            'IREX Testing' => 'IREX_Testing',
            'LOD Opportunities' => 'LOD_Opportunities',
            'FBI WO' => 'FBI_WO',            
            'FSI Classes' => 'FSI',
            'ODNI CLP Opportunities ' => 'ODNI_CLP_Opportunities'*/
            'CD Opportunities' => 'CD_Opportunities',
            'Contract Opportunities' => 'Contract_Opportunities',
            'EFL Opportunities' => 'EFL_Opportunities',
            'Interpretation Opportunities' => 'Interpretation_Opportunities',
            'MTT Opportunities' => 'MTT_Opportunities',
            'New Classes Opportunities' => 'New_Classes_Opportunities',
            'Partner School' => 'Partner_School',
            'Testing Opportunities' => 'Testing_Opportunities',
            'Translation Opportunities' => 'Translation_Opportunities',
            'DLI Small Business' => 'DLI_W_Small_Business', // Added the below types on March 17, 2020
            'DLI-W TO Opportunities' => 'DLI_W_TO_Opportunities',
            'DODA Opportunities' => 'ODNI_CLP_Opportunities',
            'Linguist Support' => 'Linguist_Support'
                    
        };
        
        Map<String,String> leadAndAccTypeMap = new Map<String,String>{
            'Candidate' => 'Candidate',
            'Commercial Clients' => 'Commercial_Clients',
            'Commercial Vendors' => 'Commercial_Vendor',
            'DLS' => 'DLS',
            'Partner School' => 'Partner_School',
            'Partners/Competitors' => 'Partner_Competitor',
            'USG Clients' => 'Accounts',
            'Foreign Governments' => 'Foreign_Governments',
            'NGO Clients' => 'NGO_Clients',
            'State GVT Clients' => 'State_GVT_Clients'           
        };
        Map<Id, String> oppIdWithLanguageName = new Map<Id, String>();                   
        system.debug('OldMap'+Trigger.oldMap);
        system.debug('NewMap'+Trigger.newMap);
        
        /***********
            - Added By HL on Mar 16 2020
            - Work Item : W-005025 - Account creation -few updates
            - Populate Account_Code__c, ParentId and AcctSeed__Accounting_Type__c fields only when Account is created from Lead Conversion if Account\'s Recordtype Commercial Clients
            ***********/ 
        Id parentPVTAcc;
        Map<Id, String> accIdAndAccCode = new Map<Id, String>();
        Map<Id, Boolean> accIdAndIsNeedFieldUpdate = new Map<Id, Boolean>();
        Map<Id, String> accIdAndStdName = new Map<Id, String>();
        
        for(Id idOfLead : Trigger.OldMap.keyset()){
          
            if(Trigger.newMap.containsKey(idOfLead)){                
                
                if((Trigger.OldMap.get(IdOfLead).IsConverted == FALSE) && (Trigger.newMap.get(IdOfLead).IsConverted == TRUE)){
                    
                    if(Trigger.OldMap.get(IdOfLead).Type__c!=NULL){                            /* in future it may change to another field*/
                        
                        system.debug(Trigger.newMap.get(IdOfLead).ConvertedAccountId);                                                                              
                        acc.add(Trigger.newMap.get(IdOfLead).ConvertedAccountId);                     
                        cnt.add(Trigger.newMap.get(IdOfLead).ConvertedContactId);
                        opp.add(Trigger.newMap.get(IdOfLead).ConvertedOpportunityId);                         
                        listTypeName.add(Trigger.newMap.get(IdOfLead).Type__c);                                                                                                    
                    }
                }
            }
        }             
        if(acc!=NULL && acc.size()>0){
            
            // Need to populate Parent accountId as PVT for the account which is created from lead conversion, so that PVT account is queried                  
            for (Account act : [SELECT Id,RecordTypeId,CreatedDate, Name FROM Account WHERE (Id=:acc OR Name = 'PVT')]){
                                        
                Long mydateTime = System.now().millisecond() - act.CreatedDate.millisecond();
                           
                if(act.Name == 'PVT' && !acc.contains(act.Id)){
                
                    parentPVTAcc = act.Id; 
                }else if(myDateTime <= milliseconds && act.Name != 'PVT' && acc.contains(act.Id)){
                
                    accs.put(act.Id,act.RecordTypeId); 
                    if(act.Name.contains('PVT')){
                        accIdAndIsNeedFieldUpdate.put(act.Id, TRUE);        
                    }
                }
            }                                             
        }
        if(cnt!=NULL && cnt.size()>0){
                       
            for (Contact con : [SELECT Id,RecordTypeId,CreatedDate,FirstName,LastName,AccountId,Name FROM Contact WHERE Id=:cnt]){
                                        
                Long mydateTime = System.now().millisecond() - con.CreatedDate.millisecond();
                if(myDateTime <= milliseconds){
                
                    cnts.put(con.Id,con.RecordTypeId);              
                    accIdAndStdName.put(con.AccountId, con.Name);  
                }
                //Need to populate Account_Code__c field value for Account is created from Lead Conversion
                accIdAndAccCode.put(con.AccountId, (con.FirstName+''+con.LastName.substring(0,1)).toUpperCase());
            }
        }
        System.debug('accIdAndAccCode::::'+accIdAndAccCode);
        if(Opp!=NULL && Opp.size()>0){
           
            for (Opportunity oppRec : [SELECT Id,RecordTypeId,CreatedDate, Language_LU__r.Name FROM Opportunity WHERE Id=:Opp]){
                                        
                Long mydateTime = System.now().millisecond() - oppRec.CreatedDate.millisecond();
                if(myDateTime <= milliseconds){
                
                    opps.put(oppRec.Id,oppRec.RecordTypeId);                
                }
                if(oppRec.Language_LU__r.Name != null){
                    oppIdWithLanguageName.put(oppRec.Id, oppRec.Language_LU__r.Name);
                }
            }
        } 
        if(listTypeName!=NULL && listTypeName.size()>0){                        
            List<String> tempList = new List<String>();
            for(String ls : listTypeName){
                tempList.add(ls.replace(' ','_'));    
            }
            
            for(RecordType Rec: [SELECT Id, Name, DeveloperName, SobjectType FROM RecordType WHERE DeveloperName =:tempList AND SobjectType = 'Contact']){               
                custIdCustObject.put(Rec.Name,Rec);          
            }                                    
        } 
        List<RecordType> rdType = [
            SELECT Id,DeveloperName 
            FROM RecordType
            Where (DeveloperName ='Student' OR DeveloperName='Client_Partner') AND SobjectType = 'Contact_Assignments__c'
        ];
        Map<String,RecordType> devNameRdType = new Map<String,RecordType>();
        for(RecordType rd : rdType){            
            devNameRdType.put(rd.DeveloperName,rd);    
        }
        
        for(RecordType rt : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType = 'Opportunity']) {
            OppDevNameRecTypeMap.put(rt.DeveloperName,rt);
        }
        
        for(RecordType rt : [SELECT Id,Name,DeveloperName FROM RecordType WHERE SobjectType = 'Account']) {
            AccDevNameRecTypeMap.put(rt.DeveloperName,rt);
        }
        
        System.debug('OppDevNameRecTypeMap:::'+OppDevNameRecTypeMap);
        System.debug('leadAndOppTypeMap :::'+leadAndOppTypeMap );
        /* This below block updates contact recordtype with selected Type in lead record*/
        
        //Modified By Dhinesh - 19/11/2020 - W-006043 - Opp Field Population on Lead Conversion
        Set<String> serviceItemPickListValueSet = new Set<String>();
        
        for (Schema.PicklistEntry entry :  Schema.getGlobalDescribe().get('Opportunity').getDescribe().fields.getMap().get('Service_Item__c').getDescribe().getPicklistValues()) {
            if (entry.isActive()) {
                serviceItemPickListValueSet.add(entry.getValue());
            }
        }
        
        for(Lead leadInst : Trigger.newMap.values()){            
            if(leadInst.Type__c !=NULL){
                
                if(custIdCustObject !=NULL && custIdCustObject.containsKey(leadInst.Type__c)){
                        
                    if(accs !=NULL && accs.size()>0 && accs.containsKey(leadInst.ConvertedAccountId)){
                        Account abc = new Account();
                        abc.Id = leadInst.ConvertedAccountId;
                        //Work Item: W-007329 - Auto-populate the "Account Full Name" field with the Student's full name
                        if(accIdAndStdName.containsKey(leadInst.ConvertedAccountId) && leadInst.Type__c == 'Student'){
                            abc.Account_Full_Name__c = accIdAndStdName.get(leadInst.ConvertedAccountId);       
                        }
                        if(leadInst.Lead_Account_Type__c != null && leadAndAccTypeMap.containsKey(leadInst.Lead_Account_Type__c) && AccDevNameRecTypeMap.containskey(leadAndAccTypeMap.get(leadInst.Lead_Account_Type__c))) {
                            abc.RecordTypeId = AccDevNameRecTypeMap.get(leadAndAccTypeMap.get(leadInst.Lead_Account_Type__c)).Id;
                            
                            //Populate Account_Code__c, ParentId and AcctSeed__Accounting_Type__c fields, only when Account is created from Lead Conversion if Account\'s Recordtype Commercial Clients
                            if(leadInst.Lead_Account_Type__c == 'Commercial Clients' && accIdAndIsNeedFieldUpdate.containsKey(leadInst.ConvertedAccountId) &&
                                accIdAndIsNeedFieldUpdate.get(leadInst.ConvertedAccountId)){
                                abc.Account_Code__c = accIdAndAccCode.containsKey(leadInst.ConvertedAccountId) ? accIdAndAccCode.get(leadInst.ConvertedAccountId) : '';
                                abc.AcctSeed__Accounting_Type__c = 'Customer and Vendor';
                                abc.ParentId = parentPVTAcc;
                            }
                        }                             
                        upAccountList.add(abc); 
                        
                    }
                    if(cnts !=NULL && cnts.size()>0 && cnts.containsKey(leadInst.ConvertedContactId)){
                        Contact contObjectUpdate = new Contact();
                        contObjectUpdate.Id = leadInst.ConvertedContactId;
                        contObjectUpdate.RecordTypeId = custIdCustObject.get(leadInst.Type__c).Id;  
                        upContactList.add(contObjectUpdate);
                    }
                    if(opps !=NULL && opps.size()>0 && opps.containsKey(leadInst.ConvertedOpportunityId)){
                        
                        Opportunity oppObjectUpdate = new Opportunity();
                        oppObjectUpdate.Id = leadInst.ConvertedOpportunityId;
                        //Work Item: W-007330 - Autopopulate "Close Date" 4 Month in Future - Lead to Opportunity Conversion
                        oppObjectUpdate.CloseDate = Date.Today().addMonths(4);
                        
                        //Modified By Dhinesh - 19/11/2020 - W-006043 - Opp Field Population on Lead Conversion 
                        oppObjectUpdate.Method_of_Inquiry__c = 'Web'; 
                        for(String value : serviceItemPickListValueSet){
                            if(oppIdWithLanguageName.get(leadInst.ConvertedOpportunityId) != null && value.contains(oppIdWithLanguageName.get(leadInst.ConvertedOpportunityId))){
                                oppObjectUpdate.Service_Item__c = value;
                                break;
                            }
                        }
                        if(leadInst.Lead_Account_Type__c == 'Commercial Clients'){
                            oppObjectUpdate.QB_Contract_Type__c = 'COMM:INDV';
                        } 
                        System.debug('leadInst.Lead_Opportunity_Type__c:::'+leadInst.Lead_Opportunity_Type__c); 
                        if(leadInst.Lead_Opportunity_Type__c != null && leadAndOppTypeMap.containsKey(leadInst.Lead_Opportunity_Type__c) && OppDevNameRecTypeMap.containskey(leadAndOppTypeMap.get(leadInst.Lead_Opportunity_Type__c))) {
                            oppObjectUpdate.RecordTypeId = OppDevNameRecTypeMap.get(leadAndOppTypeMap.get(leadInst.Lead_Opportunity_Type__c)).Id;
                        }                     
                        upOpportunityList.add(oppObjectUpdate);
                        
                        /*Contact assignement creation with specific Record type*/
                        
                        Contact_Assignments__c cntAssgn = new Contact_Assignments__c();
                        if(leadInst.Type__c == 'Student' || leadInst.Type__c == 'Testee'){
                            
                            if(devNameRdType!=NULL && devNameRdType.containsKey('Student')){
                               
                                cntAssgn.RecordTypeId = devNameRdType.get('Student').Id;                             
                            }
                            cntAssgn.Assignment_Position__c = 'Student';
                        }else{
                                                    
                            if(devNameRdType!=NULL && devNameRdType.containsKey('Client_Partner')){
                                
                                cntAssgn.RecordTypeId = devNameRdType.get('Client_Partner').Id;   
                            }    
                            if(leadInst.Type__c != 'Partner'){
                                cntAssgn.Assignment_Position__c = 'Training Officer';    
                            }
                        }
                        cntAssgn.Candidate_Name__c = leadInst.ConvertedContactId; 
                        cntAssgn.Opportunity_Name__c = leadInst.ConvertedOpportunityId;
                        cntAssgn.Start_Date__c = leadInst.Start_Date__c;
                        cntAssgn.Status__c = 'Planned';    //W-006761 - Added by NS on June 10
                                
                        upContactAssignments.add(cntAssgn);
                    }                                                                        
                }            
                
            }            
        }
        System.debug('\nAccountList:::::'+upAccountList+'\nContactlist:::::'+upContactList+'\nOpportunityList'+upOpportunityList+'\nContactAssignList'+upContactAssignments);
        if(upAccountList!=NULL && upAccountList.size()>0){
            Update upAccountList;
        }        
        if(upContactList !=NULL && upContactList.size()>0){
            Update upContactList;
        }
        if(upOpportunityList !=NULL && upOpportunityList.size()>0){
        
            Update upOpportunityList;
            if(upContactAssignments!=NULL && upContactAssignments.size()>0){
        
                Insert upContactAssignments;
            }
        }
            
        system.debug('\nAccountList::::::::'+upAccountList+'\nContactlist::::::::::'+upContactList+'\nOpportunityList::::::::'+upOpportunityList+'\nContactAssignments'+upContactAssignments);                      
    }
}