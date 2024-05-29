/*****************************************************************************
    - Created by Karthiga GR on Feb 16, 2018
    - To be called from the below button to gen the Document using Conga and send it to the Supervisor and then to the Instructor
    - Button names - "Gen & Send Docusign" in Labor Cost Rate Object
*******************************************************************************/

global class GenSendDocusign { 
    
    /*************************
    @crId = Cost Rate Id
    **************************/
    public class AllException extends Exception {}
   
    webservice static String returnsTheUrl(Id crId, String cTName, String cAId, String signer1, String signer2Staff, String signer3Staff,String cAProId) {
        Set<String> cbAsSigner1Rate = new Set<String>{'DLI-21 SCA CD (1099)','Non-SCA CD (1099)','DLI-21 SCA MTT','Non-SCA MTT (1099)'};
        Set<String> fsiOfferLetters = new Set<String>{'FSI Offer Letter','PT FSI Offer Letter','FSI Letter of Intent','PT FSI Letter of Intent'};


       try {
            String retUrl;
            //Id congaTempId;
            Id signer1Id;
            String signer1Name;
            Id signer2Id;
            String signer2Name;
            DateTime expDateTime =  System.now().addDays(30);
            String expDate = expDateTime.format('yyyy-MM-dd') + 'T' + expDateTime.format('HH:mm:ss.SSS')+'Z';
            List<Contact> recipientBoxCont = [SELECT Id,Email,Name FROM Contact WHERE Name = 'Labor Cost Rate - Conga Sign' LIMIT 1];
            Set<String> cosfEmails = new Set<String>();
             
            AcctSeed__Cost_Rates__c cr = [SELECT Id,Name,Rate_Type__c,Contact__c,Change_in_Reporting_New_Manager__c,New_Supervisor_Id__c,Contact__r.Name,Contact__r.FirstName,Contact__r.DLS_User__c,Contact__r.DLS_User__r.Email,Contact__r.Supervisor_Name__r.Email,Contact__r.Supervisor_Name__c,CreatedById,CreatedBy.Name,Contact__r.Supervisor_Name_Formula__c,Contact__r.Email,Gen_Email_Doc_Conga_Workflow_Template__c FROM AcctSeed__Cost_Rates__c WHERE Id =: crId];
            
            // Gen_Email_Doc_Conga_Workflow_Template__c field value population handled in trigger (Cost_Rate_Trigger -> Cost_Rate_Trigger_Handler)
            // To set Corresponding person as the initial Signer for T&I, some ICA documents
            String userName = '';
            
            if(Cost_Rate_Trigger_Handler.tAndIRateTypeSet.contains(cr.Rate_Type__c) || cbAsSigner1Rate.contains(cr.Rate_Type__c)) {
                userName = 'Chris Bellas';
            }
            /*} else if(cr.Rate_Type__c != 'DLI-16 SCA LT' && cr.Rate_Type__c != 'Non-SCA LT') {
            } else if (cTName == 'Pay Rate Addendum'){ // Only for Pay Rate Addendum we have the Signer 1 as Natalia
                userName = 'Natalia Stepanov';
            } commented since we allow user to select the Signer 1 for Pay Rate Addendum*/
             
            List<User> userList = new List<User>();
            if(userName != '') {
                userList = [SELECT Id,Name,isActive FROM User WHERE Name = :userName AND isActive = true];  //'Softsquare']; userName
                System.debug('userList::::'+userList);
            }
               
            if(cr.Gen_Email_Doc_Conga_Workflow_Template__c != null && cr.Gen_Email_Doc_Conga_Workflow_Template__c != '') {
                //retUrl = cr.Gen_Email_Doc_Conga_Workflow_Template__c.contains('&id=') ? cr.Gen_Email_Doc_Conga_Workflow_Template__c : '&id='+cr.Id+cr.Gen_Email_Doc_Conga_Workflow_Template__c;                    
                if( cr.Gen_Email_Doc_Conga_Workflow_Template__c.contains('&id=' +cr.Id) ) {
                    retUrl = cr.Gen_Email_Doc_Conga_Workflow_Template__c;
                } else if (cr.Gen_Email_Doc_Conga_Workflow_Template__c.contains('&id=')) { // Need to add condition for the MTT ICA and ICA DLI-W 2017 Conga Templates 
                    retUrl = cr.Gen_Email_Doc_Conga_Workflow_Template__c + ',[CR]'+CongaTranslator.getCongaQuery('ICA Agreement Cost Rate Query') + '?pv0='  + cr.Id;
                } else {
                    retUrl = '&id='+cr.Id+cr.Gen_Email_Doc_Conga_Workflow_Template__c;
                }
                // Append 'Contact Assignment Query - Pay Rate Addendum' Query Id for Pay Rate Addendum template in url
                if(cTName == 'Pay Rate Addendum' && retUrl != null){
                    if(cAId != null){
                        if(!cr.Gen_Email_Doc_Conga_Workflow_Template__c.contains('[CA]') ) {
                            retUrl += ',[CA]'+CongaTranslator.getCongaQuery('Contact Assignment Query - Pay Rate Addendum')+'?pv0='+cAId;
                        }
                    }
                    
                    if(signer1 != null){
                        retUrl += ',[Signer1]'+CongaTranslator.getCongaQuery('User Query')+'?pv0='+signer1;
                    }
                }
                
            } else {
                retUrl = 'This process cannot be initiated from this record because the Gen & Email Doc Conga Workflow Template field is blank. Please create a new Labor Cost Rate record to initiate this process';
            }
            if(cTName == 'Pay Rate Addendum' && String.isNotBlank(signer1)) {
                List<User> signer1NameList = [SELECT Id,Name,isActive FROM User WHERE Id = :signer1];  
                if(signer1NameList.size() > 0){
                    signer1Id = signer1NameList[0].Id;
                    signer1Name = signer1NameList[0].Name;
                }
            } else if((Cost_Rate_Trigger_Handler.tAndIRateTypeSet.contains(cr.Rate_Type__c) || cbAsSigner1Rate.contains(cr.Rate_Type__c)) && userList.size() > 0 ) {
                signer1Id = userList[0].Id;
                signer1Name = userList[0].Name;
            } else if(cTName == 'Pay Rate Modification'){
                if(signer1 != null){
                    List<User> loggedUserNameList = [SELECT Id,Name,isActive FROM User WHERE Id = :signer1];  
                    if(loggedUserNameList.size() > 0){
                        System.debug('loggedUserNameList::::'+loggedUserNameList);
                        signer1Id = loggedUserNameList[0].Id;
                        signer1Name = loggedUserNameList[0].Name;
                        retUrl += ',[Signer1]'+CongaTranslator.getCongaQuery('User Query')+'?pv0='+signer1Id;
                    }
                }
            }else if(cTName == 'Offer Letter - UAE Template'){
                List<User> UserNameList = getUserIdByName('Molly Sampson');
                signer1Id = UserNameList[0].Id;
                signer1Name = UserNameList[0].Name;
            }else if(fsiOfferLetters.contains(cTName)){
                signer1Id = cr.Contact__c;
                signer1Name = cr.Contact__r.Name;
            }else if(cr.Contact__r.Supervisor_Name__c != null) {
                signer1Id = cr.Contact__r.Supervisor_Name__c;
                signer1Name = cr.Contact__r.Supervisor_Name_Formula__c;
            } else {
                return 'Please fill the Contact\'s Supervisor Name';
            }
                     
            if(!fsiOfferLetters.contains(cTName)){
                signer2Id = cr.Contact__c;
                signer2Name = cr.Contact__r.Name;
                cosfEmails.add(cr.Contact__r.Email);
            }
                       
            if(!retUrl.contains('Gen & Email Doc Conga Workflow Template field is blank')) {
                if(cTName == 'Change of Status Form') {
                    String conUserEmail = null;
                    String conSupervisorEmail = null;
                    Set<String> ccUserEmails;
                    
                    if(!Test.isRunningTest()){
                        ccUserEmails = new Set<String>{'jdumont@dlsdc.com','ptovanabutra@dlsdc.com'};
                    }else{
                        ccUserEmails = new Set<String>{'test@gmail.com'};
                     }
                        
                    if(cr.Contact__r.DLS_User__c != null){
                        conUserEmail = cr.Contact__r.DLS_User__r.Email;
                    }
                    if(cr.Contact__r.Supervisor_Name__c != null){
                        conSupervisorEmail = cr.Contact__r.Supervisor_Name__r.Email;
                    }
                    
                    /*retUrl += '&qmode=DocuSign&DocuSignVisible=1&DocuSignR1ID='+signer1Id+'&DocuSignR1SignNow=0&DocusignR1SIPName='+signer1Name+'&DocuSignR1RoutingOrder=1&DocuSignR1Type=Signer&DocuSignR1Role=Signer 1'+
                    '&DocuSignR2ID='+staffSigner2+'&DocuSignR2SignNow=0&DocusignR2SIPName=Natalia Stepanov&DocuSignR2RoutingOrder=2&DocuSignR2Type=Signer&DocuSignR2Role=Signer 2'+
                    '&DocuSignR3ID='+staffSigner3+'&DocuSignR3SignNow=0&DocusignR3SIPName=Jim Bellas&DocuSignR3RoutingOrder=3&DocuSignR3Type=Signer&DocuSignR3Role=Signer 3'+
                    '&DocuSignR4ID='+signer2Id+'&DocuSignR4SignNow=0&DocusignR4SIPName='+signer2Name+'&DocuSignR4RoutingOrder=4&DocuSignR4Type=Signer&DocuSignR4Role=Signer 4'+
                    // Commented by GRK on 28 April 2022 Task #W-007450
                    //'&DocuSignR5Name=Julie Dumont&DocuSignR5RoutingOrder=5&DocuSignR5Email=Jdumont@dlsdc.com&DocuSignR5Type=Carbon+Copy&DocuSignR5Role=Carbon+Copy'+
                    //'&DocuSignR6Name=Pim Tovanabutra&DocuSignR6RoutingOrder=6&DocuSignR6Email=ptovanabutra@dlsdc.com&DocuSignR6Type=Carbon+Copy&DocuSignR6Role=Carbon+Copy'+
                    '&DocuSignExpireIn=30&DocuSignEndpoint='+System.Label.DocuSign_Endpoint;*/
                    
                    Set<String> cosfSignerIds = new Set<String>();
                    if(String.isNotBlank(signer2Staff)){
                        cosfSignerIds.add(signer2Staff);
                    }
                    if(String.isNotBlank(signer3Staff)){
                        cosfSignerIds.add(signer3Staff);
                    }
                    if(String.isNotBlank(signer1Id)){
                        cosfSignerIds.add(signer1Id);
                    }
                    
                    if(cosfSignerIds.size() > 0){
                        for(User u :[SELECT Id,Email FROM User WHERE Id IN :cosfSignerIds]){
                            cosfEmails.add(u.Email); 
                        }
                    }
                    
                    if(cr.Change_in_Reporting_New_Manager__c == true && cr.New_Supervisor_Id__c != null){
                        retUrl += ',[Sup]'+CongaTranslator.getCongaQuery('User Query')+'?pv0='+ cr.New_Supervisor_Id__c; 
                    }
                    
                    //Added by Dhinesh - 31/5/22 - Moving Cost rate from docsign to congasign
                    retUrl += '&CSVisible=1&CSRoutingType=SERIAL&CSExpiration='+expDate;
                    retUrl += '&CSRecipient1='+signer2Staff+'&CSRole1=SIGNER'+
                              '&CSRecipient2='+signer1Id+'&CSRole2=SIGNER'+
                              '&CSRecipient3='+signer3Staff+'&CSRole3=SIGNER'+
                              '&CSRecipient4='+signer2Id+'&CSRole4=SIGNER';                   
                    
                    if(!ccUserEmails.contains(conUserEmail) && !ccUserEmails.contains(conSupervisorEmail)){
                        Integer boxCount = 0;
                        if(recipientBoxCont.size() > 0){
                            retUrl += '&CSRecipient5='+recipientBoxCont[0].Id+'&CSRole5=CC';
                            boxCount = 1;
                        }
                        if(!cosfEmails.contains('ptovanabutra@dlsdc.com')){
                            Integer ccNo1 = (recipientBoxCont.size() > 0 ? 6 : 5);
                            retUrl +='&CSEmail'+ccNo1+'=ptovanabutra@dlsdc.com&CSName'+ccNo1+'=Pim Tovanabutra&CSRole'+ccNo1+'=CC'; 
                        }
                        if(!cosfEmails.contains('jdumont@dlsdc.com')){
                            Integer ccNo2 = (cosfEmails.contains('ptovanabutra@dlsdc.com') ? 5 : 6);
                            if(recipientBoxCont.size() > 0){
                                ccNo2 = ccNo2 + 1;
                            }
                            retUrl +='&CSEmail'+ccNo2+'=jdumont@dlsdc.com&CSName'+ccNo2+'=Julie Dumont&CSRole'+ccNo2+'=CC'; 
                        } 
                        
                    }else if((ccUserEmails.contains(conUserEmail) || ccUserEmails.contains(conSupervisorEmail))){
                        
                        if((conUserEmail == 'ptovanabutra@dlsdc.com' || conSupervisorEmail == 'ptovanabutra@dlsdc.com' || cosfEmails.contains('ptovanabutra@dlsdc.com')) && 
                           (conUserEmail == 'jdumont@dlsdc.com' || conSupervisorEmail == 'jdumont@dlsdc.com' || cosfEmails.contains('jdumont@dlsdc.com'))){
                               retUrl +=((recipientBoxCont.size() > 0) ? '&CSRecipient5='+recipientBoxCont[0].Id+'&CSRole5=CC' : '');
                           }else{
                               if(recipientBoxCont.size() > 0){
                                   retUrl += '&CSRecipient5='+recipientBoxCont[0].Id+'&CSRole5=CC&CSEmail6='+((conUserEmail == 'ptovanabutra@dlsdc.com' || conSupervisorEmail == 'ptovanabutra@dlsdc.com' || cosfEmails.contains('ptovanabutra@dlsdc.com')) ? 'jdumont@dlsdc.com&CSName6=Julie Dumont' : 'ptovanabutra@dlsdc.com&CSName6=Pim Tovanabutra')+'&CSRole6=CC';
                               }else{
                                   retUrl += '&CSEmail5='+((conUserEmail == 'ptovanabutra@dlsdc.com' || conSupervisorEmail == 'ptovanabutra@dlsdc.com' || cosfEmails.contains('ptovanabutra@dlsdc.com')) ? 'jdumont@dlsdc.com&CSName5=Julie Dumont' : 'ptovanabutra@dlsdc.com&CSName5=Pim Tovanabutra')+'&CSRole5=CC';
                               }
                           }
                    }
                    
                    retUrl += '&CSEmailSubject=DLS: Please Sign the Following Offer Letter&CSEmailMessage=I am sending you this request for your electronic signature, please review and electronically sign by following the link below'+
                        '&CSSendonbehalfofname=HR - Diplomatic Language Services&CSSendonbehalfofemail=hr@dlsdc.com';
                                   
                } else {
                    /* retUrl += '&qmode=DocuSign&DocuSignVisible=1&DocuSignR1ID='+signer1Id+'&DocuSignR1SignNow=0&DocusignR1SIPName='+signer1Name+'&DocuSignR1RoutingOrder=1&DocuSignR1Type=Signer&DocuSignR1Role=Signer 1'+
                            '&DocuSignR2ID='+signer2Id+'&DocuSignR2SignNow=0&DocusignR2SIPName='+ signer2Name +'&DocuSignR2RoutingOrder=2&DocuSignR2Type=Signer&DocuSignR2Role=Signer 2';*/
                    
                    //Added by Dhinesh - 31/5/22 - Moving Cost rate from docsign to congasign
                        List<User> ccUserForFSI = getUserIdByName('Lindsey Weaver');
                        Set<String> transIntrepTemplates = new Set<String>{'Translation and Interpretation ICA','Translation and Interpretation Addendum to ICA','FSI Letter of Intent','PT FSI Letter of Intent'};
                        retUrl += '&CSVisible=1&CSRoutingType=SERIAL&CSExpiration='+expDate+'&CSRecipient1='+signer1Id+'&CSRole1=SIGNER'+
                                  '&CSRecipient2='+signer2Id+'&CSRole2=SIGNER'+((recipientBoxCont.size() > 0) ? '&CSRecipient3='+recipientBoxCont[0].Id+
                                  '&CSRole3=CC' : '');
                    
                        if(!transIntrepTemplates.contains(cTName)){
                            retUrl += '&CSEmail4=ptovanabutra@dlsdc.com&CSName4=Pim Tovanabutra&CSRole4=CC&CSEmail5=jdumont@dlsdc.com&CSName5=Julie Dumont&CSRole5=CC';
                        }
                    
                    if(fsiOfferLetters.contains(cTName) && ccUserForFSI.size() > 0){
                        retUrl += '&CSEmail6='+ccUserForFSI[0].email+'&CSName6='+ccUserForFSI[0].Name+'&CSRole6=CC';
                    }
                        
                    retUrl += '&CSsenderreturnurl='+EncodingUtil.urlEncode(System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+cr.Id,'UTF-8');
                    
                    if(fsiOfferLetters.contains(cTName)){
                        
                        List<Contact_Assignments__c> cA = [SELECT Id,Project__c,Start_Date__c,Project__r.Name,Opportunity_Name__r.Language_LU__c,Opportunity_Name__r.Language_LU__r.Name,Opportunity_Name__c,Project__r.Language__c,Project__r.Language__r.Name,Assignment_Position__c FROM Contact_Assignments__c
                                                            WHERE Id =:cAProId 
                                                             AND RecordType.DeveloperName = 'Instructor' 
                                                             AND (Rate_Card_Rate__c = :crId OR Drafted_Labor_Cost_Rate__c = :crId) AND ((Project__c != null AND Status__c IN ('Active','Planned')) OR (Project__c= NULL AND Opportunity_Name__c != null AND Status__c IN ('Proposed','Awarded'))) 
                                                           LIMIT 1];
                        
                        if(cA.size() > 0){     
                            String stDate = null;
                            String langName = null;
                            if(cA[0].Start_Date__c != null){
                                stDate = (cA[0].Start_Date__c).month()+'/'+(cA[0].Start_Date__c).day()+'/'+(cA[0].Start_Date__c).year();
                            }
                            
                            if(cA[0].Project__c != null && cA[0].Project__r.Language__c != null){
                                langName = cA[0].Project__r.Language__r.Name;
                            }else if(cA[0].Opportunity_Name__c != null && cA[0].Opportunity_Name__r.Language_LU__c != null){
                                langName = cA[0].Opportunity_Name__r.Language_LU__r.Name;
                            }
                            
                            if(cTName == 'FSI Offer Letter' || cTName == 'PT FSI Offer Letter'){
                                retUrl += '&CSEmailSubject=Offer Letter for FSI project for '+cr.Contact__r.Name+'&CSEmailMessage=Dear '+cr.Contact__r.FirstName+',%250a%250aWe are happy to extend the offer for the '+ langName+' '+cA[0].Assignment_Position__c+' position with FSI as of '+stDate;
                                retUrl += '. Please, review this letter and sign at your earliest convenience. Once signed, we will continue with the next steps.%250a%250aDLS%250ahr@dlsdc.com';            
                            }else if(cTName == 'FSI Letter of Intent' || cTName == 'PT FSI Letter of Intent'){
                                retUrl += '&CSEmailSubject=FSI Employment Letter of Intent for '+cr.Contact__r.Name+'&CSEmailMessage=Dear '+cr.Contact__r.FirstName+',%250a%250aPlease, review this letter of intent and sign at your earliest convenience. Once signed, we will continue with the next steps';
                                retUrl += '. This offer is contingent on FSI accepting your application.%250a%250aDLS%250ahr@dlsdc.com';            
                            }
                        }
                    }else{
                        retUrl += '&CSEmailSubject=DLS: Please Sign the Following Offer Letter&CSEmailMessage=I am sending you this request for your electronic signature, please review and electronically sign by following the link below';
                        
                    }
                    retUrl += '&CSSendonbehalfofname=HR - Diplomatic Language Services&CSSendonbehalfofemail=hr@dlsdc.com';
                    
                        System.debug('retUrl:::::'+retUrl);
                   /* if(cTName == 'Pay Rate Modification') {
                            retUrl += '&DocuSignR3Name=Julie Dumont&DocuSignR3RoutingOrder=3&DocuSignR3Email=jdumont@dlsdc.com&DocuSignR3Type=Carbon+Copy&DocuSignR3Role=Carbon+Copy'+
                            '&DocuSignR4Name=Pim Tovanabutra&DocuSignR4RoutingOrder=4&DocuSignR4Email=ptovanabutra@dlsdc.com&DocuSignR4Type=Carbon+Copy&DocuSignR4Role=Carbon+Copy'+
                            '&DocuSignR5Name=Box Folder&DocuSignR5RoutingOrder=5&DocuSignR5Email='+System.Label.Docusign_Box_Email_Id+'&DocuSignR5Type=Carbon+Copy&DocuSignR5Role=Carbon+Copy';                        
                        // Commented by GRK on 28 April 2022 Task #W-007450
                        retUrl += '&DocuSignR3Name=Box Folder&DocuSignR3RoutingOrder=3&DocuSignR3Email='+System.Label.Docusign_Box_Email_Id+'&DocuSignR3Type=Carbon+Copy&DocuSignR3Role=Carbon+Copy';                        
                    } else {
                        retUrl += '&DocuSignR3Name=Box Folder&DocuSignR3RoutingOrder=3&DocuSignR3Email='+System.Label.Docusign_Box_Email_Id+'&DocuSignR3Type=Carbon+Copy&DocuSignR3Role=Carbon+Copy';
                    }
                    retUrl += '&DocuSignExpireIn=30&DocuSignEndpoint='+System.Label.DocuSign_Endpoint;*/
                }
                retUrl = retUrl.replace(' ', '+');
            }
            
            System.debug('retUrl:::::'+retUrl);
            return retUrl;
        } catch(exception e) {
            throw new AllException(e.getMessage());
        }
    }
    
    /* Called from "Generate Form' button*/
    
    webservice static String returnsUrlToGenForm(Id crId,String cTName, String cAId, String signer1) {
        
        try {
        
            String retUrl;
            AcctSeed__Cost_Rates__c cr = [SELECT Id,Name,Rate_Type__c,Contact__c,Contact__r.Name,Contact__r.Supervisor_Name__c,CreatedBy.Name,Contact__r.Supervisor_Name_Formula__c,Gen_Email_Doc_Conga_Workflow_Template__c FROM AcctSeed__Cost_Rates__c WHERE Id =: crId];
            System.debug('cr.Gen_Email_Doc_Conga_Workflow_Template__c:::::'+cr.Gen_Email_Doc_Conga_Workflow_Template__c);
            if(cr.Contact__r.Supervisor_Name__c == null && cTName != 'Pay Rate Modification') {
                return 'Please fill the Contact\'s Supervisor Name';
            } else {
                if(cr.Gen_Email_Doc_Conga_Workflow_Template__c != null && cr.Gen_Email_Doc_Conga_Workflow_Template__c != '') {
                    if( cr.Gen_Email_Doc_Conga_Workflow_Template__c.contains('&id=' +cr.Id) ) {
                        System.debug('IF::::');
                        retUrl = cr.Gen_Email_Doc_Conga_Workflow_Template__c;
                    } else if (cr.Gen_Email_Doc_Conga_Workflow_Template__c.contains('&id=')) { // Need to add condition for the MTT ICA and ICA DLI-W 2017 Conga Templates 
                        System.debug('Else::::');
                        retUrl = cr.Gen_Email_Doc_Conga_Workflow_Template__c + ',[CR]'+CongaTranslator.getCongaQuery('ICA Agreement Cost Rate Query') + '?pv0='  + cr.Id;
                    } else {
                        retUrl = '&id='+cr.Id+cr.Gen_Email_Doc_Conga_Workflow_Template__c;
                    }
                    
                    // Append 'Contact Assignment Query - Pay Rate Addendum' Query Id for Pay Rate Addendum template in url
                    if(cTName == 'Pay Rate Addendum' && retUrl != null){
                        if(cAId != null){
                            if(!cr.Gen_Email_Doc_Conga_Workflow_Template__c.contains('[CA]')) {
                                retUrl += ',[CA]'+ CongaTranslator.getCongaQuery('Contact Assignment Query - Pay Rate Addendum')+'?pv0='+cAId;
                            }
                        }
                        if(signer1 != null){
                            retUrl += ',[Signer1]'+ CongaTranslator.getCongaQuery('User Query')+'?pv0='+signer1;
                        }
                    }
                } else {
                    retUrl = 'This process cannot be initiated from this record because the Gen & Email Doc Conga Workflow Template field is blank. Please create a new Labor Cost Rate record to initiate this process';
                }
            }
            
            System.debug('retUrl:::::'+retUrl);
            return retUrl;
            
        } catch(exception e) {
            throw new AllException(e.getMessage());
        }
    }
    /***********************************************************
    Created for the Exception Rate Types Like 
    DLi-16 SCA MTT 
    to send the docusign for the Process
    ***********************************************************/
    public static String returnsUrlForCA(Contact_Assignments__c ca) {
        String retStr;
        try {
            Map<string,Id> congaTempNameWithIdMap = new Map<String,Id>();
            List<AcctSeed__Cost_Rates__c> crs = new List<AcctSeed__Cost_Rates__c>();
            List<Contact_Assignments__c> lts = new List<Contact_Assignments__c>();
            for(APXTConga4__Conga_Template__c ct : [SELECT Id,Name,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c]) {
                congaTempNameWithIdMap.put(ct.APXTConga4__Name__c,ct.Id);
            }
        
            if(ca.Rate_Card_Rate__c != null || ca.Drafted_Labor_Cost_Rate__c != null) {
                crs = [SELECT Id,Name,Rate_Type__c FROM AcctSeed__Cost_Rates__c WHERE Id =: ca.Rate_Card_Rate__c OR Id =: ca.Drafted_Labor_Cost_Rate__c ];
            } else {
                return 'Please map a Rate Card rate for this Instructor';
            }
            
            if(ca.Project__c != null) {
                lts = ContactAssignmentService.getContactAssignmentByParentIdsAndRTName(new Set<Id>{ca.Project__c},new Set<String>{'Staff'},' AND Status__c IN (\'Active\')','');
            }
            
            String congaTempId = congaTempNameWithIdMap.containskey('MTT ICA') ? congaTempNameWithIdMap.get('MTT ICA') : null;
            retStr = '&id='+ ca.Candidate_Name__c + '&templateId='+congaTempId+'&queryId=[CA]'+ CongaTranslator.getCongaQuery('ICA Agreement Contact Assign Query') + '?pv0=' + ca.Id + ',[CR]' + CongaTranslator.getCongaQuery('ICA Agreement Cost Rate Query') + '?pv0=' + (ca.Rate_Card_rate__c != null ? ca.Rate_Card_rate__c : ca.Drafted_Labor_Cost_Rate__c);                   
            // &DS7=0
            if( lts != null && lts.size() > 0 ) {
                retStr += ',[LTS]' + CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + lts[0].Candidate_Name__c;
            }
            List<User> usr = [SELECT Id,Name FROM User WHERE Name LIKE '%Chris bellas%' AND isActive = true];
            retStr += '&qmode=DocuSign&DocuSignVisible=1&DocuSignR1ID='+ca.Candidate_Name__c+'&DocuSignR1SignNow=0&DocusignR1SIPName='+ca.Candidate_Name__r.Name+'&DocuSignR1RoutingOrder=1&DocuSignR1Type=Signer&DocuSignR1Role=Signer 1';
            
            if( usr != null && usr.size() > 0 ) {
                retStr += '&DocuSignR2ID='+usr[0].Id+'&DocuSignR2SignNow=0&DocusignR2SIPName='+ usr[0].Name +'&DocuSignR2RoutingOrder=2&DocuSignR2Type=Signer&DocuSignR2Role=Signer 2'+
                '&DocuSignR3Name=Box Folder&DocuSignR3RoutingOrder=3&DocuSignR3Email='+System.Label.Docusign_Box_Email_Id+'&DocuSignR3Type=Carbon+Copy&DocuSignR3Role=Carbon+Copy'+
                '&DocuSignExpireIn=30&DocuSignEndpoint='+System.Label.DocuSign_Endpoint;
            }
            retStr = retStr.replace(' ', '+');
            return retStr;
        } catch(Exception e) {
            
            throw new AllException(e.getMessage());
        }
    }
    
    /********************************************************
    Called from the custom button "Gen & Send DocuSign" in Contact Assignment Object
    To Gen the Document and Send it through the Docusign Process
    *********************************************************/
    webservice static String returnsUrlToSendDocusign(Id caId) {
        
        try {
            List<Contact_Assignments__c> cas = SObjectQueryService.SObjectQuery('Contact_Assignments__c', new Set<Id>{caId}, ',Candidate_Name__r.Name');
            String rtn;
            if( cas != null && cas.size() > 0 ) {
                rtn = returnsUrlForCA(cas[0]);
            } else {
                rtn = 'Error';
            }
            System.debug('rtn :::::'+rtn );
            return rtn;
        } catch(exception e) {
            throw new AllException(e.getMessage());
        }
    }                  
    //Get User Id BY Name
    public static List<User> getUserIdByName(String userName){
        String usrName = '%'+userName+'%';
        List<User> usr = [SELECT Id,Name,Email FROM User WHERE Name LIKE :usrName AND isActive = true];
        return usr;
    }
}