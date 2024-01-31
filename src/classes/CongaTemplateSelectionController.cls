/*********************************************
developed by GRK, to make use of it in Lightning Action
Gen & Send Docusign, Generate Form button - Cost Rate Object
Gen & Send Docusign - Contact Assignment 
**********************************************/
public Class CongaTemplateSelectionController{
    
    @AuraEnabled
    public Static Map<String,String> getCostRateRecord(String crId){
    
        List<AcctSeed__Cost_Rates__c> cr = SObjectQueryService.SObjectQuery('AcctSeed__Cost_Rates__c', new Set<Id>{crId},',Contact__r.Independent_Contractor_Name__c');
        Map<String,String> crMap;
        
        if( cr != null && cr.size() > 0 ) {
            Id ctId;
            String str='';
            System.debug('cr::::'+cr[0].Gen_Email_Doc_Conga_Workflow_Template__c );

            if(cr[0].Gen_Email_Doc_Conga_Workflow_Template__c != null) {
            
                ctId = cr[0].Gen_Email_Doc_Conga_Workflow_Template__c.substringBetween('&templateId=','&queryId') != 'null' ? cr[0].Gen_Email_Doc_Conga_Workflow_Template__c.substringBetween('&templateId=','&queryId') : null;
                //ctId = cr[0].Gen_Email_Doc_Conga_Workflow_Template__c.substringBetween('&templateId=','&queryId');
                if( ctId != null) {
                    System.debug('ctId::::'+ctId);

                    for( APXTConga4__Conga_Template__c ct : CongaQueryService.CongaTempList()){
                        if(ct.Id == ctId) {
                           str = ct.APXTConga4__Name__c;
                        }
                    }
                 
                }
            } 
            
            Map<Id,String> getProjectWithCAIdMap = new Map<Id,String>();
            Map<Id,String> getProjectOPPWithCAIdMap = new Map<Id,String>();
            //Get LCR relateds projects from Contact Assignments
                
            for(Contact_Assignments__c ca : [SELECT Id,Project__c,Opportunity_Name__c,Project__r.Name,Opportunity_Name__r.Name FROM Contact_Assignments__c WHERE RecordType.DeveloperName = 'Instructor'
                                             AND ((Project__c != NULL AND Status__c IN ('Active','Planned')) OR (Opportunity_Name__c != NULL AND Project__c = NULL AND Status__c IN ('Proposed','Awarded'))) 
                                             AND (Rate_Card_Rate__c = :cr[0].Id OR Drafted_Labor_Cost_Rate__c = :cr[0].Id)]){
                Boolean isOpp = false;
                
                if(ca.Project__c == null && ca.Opportunity_Name__c != null){
                    isOpp = true;
                }

                if(!getProjectOPPWithCAIdMap.containsKey(ca.Id)){ // get CA Opportunity related records for FSI letter and Letter of Intent template to show Project/Opp picklist in UI
                    if(isOpp == true){
                        getProjectOPPWithCAIdMap.put(ca.Id,ca.Opportunity_Name__r.Name);
                    }else{
                        getProjectOPPWithCAIdMap.put(ca.Id,ca.Project__r.Name);                         
                    }
                }
                
                if((!getProjectWithCAIdMap.containsKey(ca.Id)) && isOpp == false){
                    getProjectWithCAIdMap.put(ca.Id,ca.Project__r.Name);
                }
            }
            
            crMap = new Map<String,String> {
                'templateName' => str,
                /**'congaUrl' => cr[0].Gen_Email_Doc_Conga_Workflow_Template__c,**/
                'IndependentContractorName' => cr[0].Contact__r.Independent_Contractor_Name__c,
                'rateType' =>  cr[0].Rate_Type__c,
                'getProjectWithCAIdMap' => JSON.serialize(getProjectWithCAIdMap),
                'getProjectOPPWithCAIdMap' => JSON.serialize(getProjectOPPWithCAIdMap)
            };
            system.debug('crMap:::::'+crMap);
        }
        return crMap;
    }
    
    /****************************************************
    Handles for both the Contact Assignment record and for Cost Rate
    @recId = Id of the record from where it is launched
    @crId = Id of the Cost Rate
    @fieldCTName = Conga Template Name from the URL field
    @selectedCTName = Conga Template Name that is currently selected
    @launchedFrom = define it is from Docusign button or document Generation
    @objName = object Name of the record launched from
    *****************************************************/
    @AuraEnabled
    public static CongaButtonsController.generateWrapper genSendDocuSign(String recId, String crId, String fieldCTName, String selectedCTName, String launchedFrom, String objName , String cAProId, String signer1, String signer2Staff, String signer3Staff) {
        
        try {
                
            CongaButtonsController.generateWrapper wrap = new CongaButtonsController.generateWrapper();
            wrap.isErrorMsg = FALSE;
            Id recordId = (Id)recId;
            Map<string,Id> congaTempNameWithIdMap = new Map<String,Id>();
            String returnCongaURL = '';
            Id userId = userinfo.getuserid() ;
            
            if(objName == 'Contact_Assignments__c') {
                wrap.congaURL = GenSendDocusign.returnsUrlToSendDocusign(recordId);
            } else if(objName == 'AcctSeed__Cost_Rates__c') {
                
                if(launchedFrom == 'Docusign') {
                    returnCongaURL = GenSendDocusign.returnsTheUrl(recordId,selectedCTName,cAProId,signer1,signer2Staff,signer3Staff,cAProId);
                    wrap.congaURL = returnCongaURL;
                } else if(launchedFrom == 'Gen_Form') { 
                    returnCongaURL = GenSendDocusign.returnsUrlToGenForm(recordId,selectedCTName,cAProId,signer1);
                    wrap.congaURL = returnCongaURL;
                }
                wrap.isErrorMsg =  (returnCongaURL == 'Please fill the Contact\'s Supervisor Name' || returnCongaURL == 'This process cannot be initiated from this record because the Gen & Email Doc Conga Workflow Template field is blank. Please create a new Labor Cost Rate record to initiate this process');               
            }
            System.debug('wrap:::::'+wrap);
            wrap.sessionIdServerURL = CongaButtonsController.getServerUrlSessionId();
            System.debug('fieldCTName::::'+fieldCTName);
            System.debug('selectedCTName::::'+selectedCTName);
            System.debug('launchedFrom========='+launchedFrom);
            
            List<AcctSeed__Cost_Rates__c> cr = SObjectQueryService.SObjectQuery('AcctSeed__Cost_Rates__c', new Set<Id>{(Id)crId}, ',Contact__r.Name,Contact__r.Supervisor_Name__c');
            
            //Added By HL to set the Document Name
            String tmpName = '';
            if(cr.size() > 0 && cr != NULL){
            
                // Template Name set when we chose a different Conga Template 
                if(cr[0].Contact__c != null) {
                    tmpName = selectedCTName + ' - ' + cr[0].Contact__r.Name;
                }
                if(cr[0].Effective_Date__c != null) {
                    List<String> tempDate = (cr[0].Effective_Date__c  != null) ? (String.valueOf(cr[0].Effective_Date__c )).split('-') : new List<String>();
                    
                    if(tempDate != null && tempDate.size() > 1){
                        tmpName += '-'+tempDate[1]+''+tempDate[2]+''+tempDate[0];
                    }
                }
                if(cr[0].Name != null) {
                    tmpName += '--' + cr[0].Name;
                }
                System.debug('tmpName :::'+tmpName);
            }
            
            for(APXTConga4__Conga_Template__c ct : [SELECT Id,Name,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c]) {
                congaTempNameWithIdMap.put(ct.APXTConga4__Name__c,ct.Id);
            }
            
            if(fieldCTName == selectedCTName) {     // If the selected Conga Template Name is same as the one in the conga gen field
            
                System.debug('wrap.congaUrl:::::'+wrap.congaUrl);
                System.debug('wrap.isErrorMsg:::::'+wrap.isErrorMsg);
                
                // To exclude appending the other params if we have any error message
                if(!wrap.isErrorMsg){
                    
                    if(wrap.congaUrl.contains('&templateId=')) { 

                        // If the Selected Template is "Offer Letter - DLI-W new and LT", append Non-SCA LT Rate Card to the URL
                        /* if (selectedCTName == 'Offer Letter - DLI-W new and LT') {
                        List<AcctSeed__Cost_Rates__c> nonSCALTCR = [SELECT Id FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'Non-SCA LT' AND Contact__c =: cr[0].Contact__c Order By Effective_Date__c Desc];
                        if(nonSCALTCR != null && nonSCALTCR.size() > 0 ) {
                        wrap.congaUrl += ',[NonSCACR]' + CongaTranslator.getCongaQuery('ICA Agreement Cost Rate Query') + '?pv0=' + nonSCALTCR[0].Id;
                        }
                        wrap.congaUrl += '&OFN='+tmpName;
                        }*/
                        
                        // If launchedFrom Gen & Send Docusign button
                        if(selectedCTName == 'Pay Rate Modification' && (!wrap.congaUrl.contains('[LTS]') || !wrap.congaUrl.contains('?pv0='+cr[0].CreatedById))){
                            Id congaTempId = congaTempNameWithIdMap.containskey('Pay Rate Modification') ? congaTempNameWithIdMap.get('Pay Rate Modification') : null;
                            String congaUrl = '&id='+ cr[0].Id + '&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + cr[0].Contact__c;
                            if(String.isNotBlank(signer1)){
                                congaUrl = congaUrl+ ',[LTS]'+CongaTranslator.getCongaQuery('User Query')+'?pv0='+signer1;
                            } 
                            congaUrl = congaUrl+ '&OFN='+tmpName; 
                            
                            if(launchedFrom == 'Docusign') {
                                String docusign = wrap.congaURL.subStringAfter('&CSVisible=1');//('&qmode=DocuSign');
                                wrap.congaURL = congaUrl + '&CSVisible=1' + docusign;
                            }else{
                                wrap.congaURL = congaUrl;
                            }
                            System.debug('congaUrl:::::'+congaUrl);
                            System.debug('wrap.congaUrl:::::'+wrap.congaUrl);
                           //W-007837 - Create new FSI Labor Cost Rate Rate Type & Offer Letter (SEP-1-2023) and Include project Id in the conga url
                        }else if(selectedCTName == 'FSI Offer Letter' || selectedCTName == 'PT FSI Offer Letter'){
                            if(wrap.congaUrl.contains('&templateId=') && wrap.congaUrl.contains('&queryId=[Con]')){
                                List<String> spiltCongaUrl = (wrap.congaUrl).split('&queryId=');
                                
                                if(spiltCongaUrl.size() > 1){
                                    wrap.congaURL = spiltCongaUrl[0]+'&queryId=[CA]'+CongaTranslator.getCongaQuery('Contact Assignment Query - Pay Rate Addendum')+'?pv0='+cAProId+','+spiltCongaUrl[1];
                                }
                            }
                        }
                        
                        // If launchedFrom Generate Form button
                        if(launchedFrom != 'Docusign') { 
                        
                            wrap.congaUrl = wrap.congaUrl.replace('&DS7=0','');
                            wrap.congaURL = wrap.congaUrl + '&DS7=3&AC0=1&AC2=1&AC1=Generate+Offer+Letter'; // To skip the Conga Template selection screen and log activities
                            if( cr.size() > 0 ) {
                                wrap.congaURL += '&LGParentId=' + cr[0].Contact__c;
                                if(!wrap.congaURL.contains('&OFN=')){
                                    wrap.congaURL += '&OFN='+tmpName;
                                }
                            }
                        } else {
                            wrap.congaURL = wrap.congaUrl + '&AC0=1&AC2=1&&AC1=Generate+Send+Docusign';
                            if( cr.size() > 0 ) {
                                wrap.congaURL += '&LGParentId=' + cr[0].Contact__c;
                                if(!wrap.congaURL.contains('&OFN=')){
                                    wrap.congaURL += '&OFN='+tmpName;
                                }
                            }
                        }
                    }
                }
                return wrap;
            } else {
                
                // Generate Url form  corresponding templated if congaURL is not equal to 'Please fill the Contact\'s Supervisor Name'
                System.debug('wrap.isErrorMsg==========='+wrap.isErrorMsg);
                if(!wrap.isErrorMsg){
                    
                    Id congaTempId;
                    String congaUrl = '';
                    Map<Id,Id> conIdInsMap = new Map<Id,Id>();
                    Map<Id,Id> conIdLTSMap = new Map<Id,Id>();
                    Map<Id,Id> projIdConIdMap = new Map<Id,Id>();
                

                    System.debug('cr::::'+cr);
                    if( cr != null && cr.size() > 0 ) {
                        String productId = null;
                        Set<String> fsiOfferLetters = new Set<String>{'FSI Offer Letter','PT FSI Offer Letter','FSI Letter of Intent','PT FSI Letter of Intent'};

                        if(cAProId != null && (fsiOfferLetters.contains(selectedCTName))){ // get product Id for Letter of intent templete
                            List<Contact_Assignments__c> caList = new List<Contact_Assignments__c>();
                            List<OpportunityLineItem> opliList = new List<OpportunityLineItem>();
                            
                            String oplid = null;
                             
                            caList = [SELECT Id,Project__c,Opportunity_Name__c,Opportunity_Product_Id__c,Project_Task__c,Project_Task__r.Product__c FROM Contact_Assignments__c WHERE Id = :cAProId];
                            if(caList.size() > 0){
                                if(((caList[0].Project__c != null && caList[0].Opportunity_Name__c != null) || (caList[0].Opportunity_Name__c  != null && caList[0].Project__c == null)) &&  caList[0].Opportunity_Product_Id__c != null){
                                    oplid = caList[0].Opportunity_Product_Id__c;
                                }else if(caList[0].Project__c != null && caList[0].Project_Task__c != null && caList[0].Project_Task__r.Product__c != null){
                                    productId = caList[0].Project_Task__r.Product__c; 
                                }
                                
                                if(oplid != null){
                                    opliList = [SELECT Id,Product2Id FROM OpportunityLineItem WHERE Id = :oplid AND Product2Id != null];
                                    if(opliList.size() > 0){
                                        productId = opliList[0].Product2Id;
                                    }
                                }
                            }
                        }
                        
                        
                        if( cr[0].Contact__c != null ) {
                            for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c,RecordType.DeveloperName,Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c =: cr[0].Contact__c Order BY CreatedDate DESC]) {
                                if(!conIdInsMap.containskey(ca.Candidate_Name__c))
                                    conIdInsMap.put(ca.Candidate_Name__c,ca.Id);
                                    
                                if(!projIdConIdMap.containskey(ca.Project__c)) 
                                    projIdConIdMap.put(ca.Project__c, ca.Candidate_Name__c);
                            }
                        }
                        System.debug('::projIdConIdMap::'+projIdConIdMap);
                        if( projIdConIdMap != null && projIdConIdMap.size() > 0 ) {
                            for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c,RecordType.DeveloperName,Project__c FROM Contact_Assignments__c WHERE Project__c IN: projIdConIdMap.Keyset() AND RecordType.DeveloperName = 'Staff' Order BY CreatedDate DESC]) {
                                if(!conIdLTSMap.containskey(ca.Candidate_Name__c)) {
                                    if(projIdConIdMap.containskey(ca.Project__c))
                                        conIdLTSMap.put(projIdConIdMap.get(ca.Project__c),ca.Candidate_Name__c);
                                }
                            }
                        }
                       
                       // When launched from Cost Rate 
                       
                        if( selectedCTName == 'Offer Letter - Instructors LT' ) {
                            congaTempId = congaTempNameWithIdMap.containskey('Offer Letter - Instructors LT') ? congaTempNameWithIdMap.get('Offer Letter - Instructors LT') : null;
                            congaUrl = '&id='+ cr[0].Id + '&DS7=0&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+cr[0].Contact__c+'&OFN='+tmpName;
                            System.debug('Inside if::::'+congaUrl);
                        }else if(selectedCTName == 'FSI Offer Letter') {        
                            //W-007837 - Create new FSI Labor Cost Rate Rate Type & Offer Letter (SEP-1-2023)
                            congaTempId = congaTempNameWithIdMap.containskey('FSI Offer Letter') ? congaTempNameWithIdMap.get('FSI Offer Letter') : null;
                            congaUrl = '&id='+ cr[0].Id + '&DS7=0&templateId='+congaTempId+'&queryId=[CA]'+CongaTranslator.getCongaQuery('Contact Assignment Query - Pay Rate Addendum')+'?pv0='+cAProId+',[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+cr[0].Contact__c+',[Prod]'+CongaTranslator.getCongaQuery('Product Query for FSI Letter of intent')+'?pv0='+productId+'&OFN='+tmpName;
                        }else if(selectedCTName == 'FSI Letter of Intent') {
                            congaTempId = congaTempNameWithIdMap.containskey('FSI Letter of Intent') ? congaTempNameWithIdMap.get('FSI Letter of Intent') : null;
                            congaUrl = '&id='+ cr[0].Id + '&DS7=0&templateId='+congaTempId+'&queryId=[CA]'+CongaTranslator.getCongaQuery('Contact Assignment Query - Pay Rate Addendum')+'?pv0='+cAProId+',[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+cr[0].Contact__c+',[Prod]'+CongaTranslator.getCongaQuery('Product Query for FSI Letter of intent')+'?pv0='+productId+'&OFN='+tmpName;
                        }else if(selectedCTName == 'PT FSI Offer Letter') {        
                            //W-007837 - Create new FSI Labor Cost Rate Rate Type & Offer Letter (SEP-1-2023)
                            congaTempId = congaTempNameWithIdMap.containskey('PT FSI Offer Letter') ? congaTempNameWithIdMap.get('PT FSI Offer Letter') : null;
                            congaUrl = '&id='+ cr[0].Id + '&DS7=0&templateId='+congaTempId+'&queryId=[CA]'+CongaTranslator.getCongaQuery('Contact Assignment Query - Pay Rate Addendum')+'?pv0='+cAProId+',[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+cr[0].Contact__c+',[Prod]'+CongaTranslator.getCongaQuery('Product Query for FSI Letter of intent')+'?pv0='+productId+'&OFN='+tmpName;
                        }else if(selectedCTName == 'PT FSI Letter of Intent') {
                            congaTempId = congaTempNameWithIdMap.containskey('PT FSI Letter of Intent') ? congaTempNameWithIdMap.get('PT FSI Letter of Intent') : null;
                            congaUrl = '&id='+ cr[0].Id + '&DS7=0&templateId='+congaTempId+'&queryId=[CA]'+CongaTranslator.getCongaQuery('Contact Assignment Query - Pay Rate Addendum')+'?pv0='+cAProId+',[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+cr[0].Contact__c+',[Prod]'+CongaTranslator.getCongaQuery('Product Query for FSI Letter of intent')+'?pv0='+productId+'&OFN='+tmpName;
                        }else if( selectedCTName == 'Offer Letter - UAE Template') {
                            congaTempId = congaTempNameWithIdMap.containskey('Offer Letter - UAE Template') ? congaTempNameWithIdMap.get('Offer Letter - UAE Template') : null;
                            congaUrl = '&id='+ cr[0].Id +'&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+cr[0].Contact__c;
                            List<User> signer1List = GenSendDocusign.getUserIdByName('Molly Sampson');
                            if(signer1List.size() > 0){
                                congaUrl = congaUrl + ',[LTS]'+CongaTranslator.getCongaQuery('User Query')+'?pv0='+signer1List[0].Id;
                            } 
                            congaUrl +='&OFN='+tmpName;
                            System.debug('Inside if::::'+congaUrl);
                        }else if (selectedCTName == 'Offer Letter - DLI-W New Contract - SCA') {
                            congaTempId = congaTempNameWithIdMap.containskey('Offer Letter - DLI-W New Contract - SCA') ? congaTempNameWithIdMap.get('Offer Letter - DLI-W New Contract - SCA') : null;
                            congaUrl = '&id='+ cr[0].Id + '&DS7=0&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+cr[0].Contact__c+'&OFN='+tmpName;
                        } else if (selectedCTName == 'MTT ICA') {
                            congaTempId = congaTempNameWithIdMap.containskey('MTT ICA') ? congaTempNameWithIdMap.get('MTT ICA') : null;
                            congaUrl = '&id='+ cr[0].Contact__c + '&DS7=0&templateId='+congaTempId+'&queryId=[CA]'+ CongaTranslator.getCongaQuery('ICA Agreement Contact Assign Query') + '?pv0=' + conIdInsMap.get(cr[0].Contact__c) + ',[LTS]' + CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + conIdLTSMap.get(cr[0].Contact__c)  + ',[CR]'+CongaTranslator.getCongaQuery('ICA Agreement Cost Rate Query') + '?pv0=' + cr[0].Id + '&OFN='+tmpName;                   
                        } else if (selectedCTName == 'Pay Rate Addendum') {
                            congaTempId = congaTempNameWithIdMap.containskey('Pay Rate Addendum') ? congaTempNameWithIdMap.get('Pay Rate Addendum') : null;
                            //congaUrl = '&id='+ cr[0].Contact__c + '&DS7=0&templateId='+congaTempId+'&queryId=[CR]'+CongaTranslator.getCongaQuery('Cost Rate Query - CR Approval')+'?pv0='+cr[0].Contact__c+'~pv1=Approved,[DraftCR]'+CongaTranslator.getCongaQuery('Cost Rate Query - Non approved')+'?pv0='+cr[0].Contact__c+'~pv1=\'Draft\'|\'Submitted for Approval\''; //Cost Rate Query - CR Approval
                            congaUrl = '&id='+cr[0].Id+'&templateId='+congaTempId +'&queryId=[CR]'+CongaTranslator.getCongaQuery('Cost Rate Query - CR Approval')+'?pv0='+cr[0].Contact__c+'~pv1=Approved,[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + cr[0].Contact__c;
                            
                            if(String.isNotBlank(cAProId)){
                                congaUrl = congaUrl + ',[CA]'+CongaTranslator.getCongaQuery('Contact Assignment Query - Pay Rate Addendum')+'?pv0='+cAProId;
                            }
                            
                            if(String.isNotBlank(signer1)){
                                congaUrl = congaUrl+ ',[Signer1]'+CongaTranslator.getCongaQuery('User Query')+'?pv0='+signer1;
                            }
                            congaUrl = congaUrl+ '&OFN='+tmpName; 
                            
                        } else if (selectedCTName == 'Pay Rate Modification') {
                            congaTempId = congaTempNameWithIdMap.containskey('Pay Rate Modification') ? congaTempNameWithIdMap.get('Pay Rate Modification') : null;
                            //congaUrl = '&id='+ cr[0].Contact__c + '&DS7=0&templateId='+congaTempId+'&queryId=[CA]'+ CongaTranslator.getCongaQuery('ICA Agreement Contact Assign Query') + '?pv0=' + conIdInsMap.get(cr[0].Contact__c) + ',[LTS]' + CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + conIdLTSMap .get(cr[0].Contact__c) ;                   
                            congaUrl = '&id='+ cr[0].Id + '&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + cr[0].Contact__c ;
                            
                            if(String.isNotBlank(signer1)){
                                congaUrl = congaUrl+ ',[LTS]'+CongaTranslator.getCongaQuery('User Query')+'?pv0='+signer1;
                            } 
                            congaUrl = congaUrl+ '&OFN='+tmpName; 
                        } else if (selectedCTName == 'ICA DLI-W 2017') {
                            congaTempId = congaTempNameWithIdMap.containskey('ICA DLI-W 2017') ? congaTempNameWithIdMap.get('ICA DLI-W 2017') : null;
                            congaUrl = '&id='+ cr[0].Contact__c + '&templateId='+congaTempId+'&queryId=[CA]'+ CongaTranslator.getCongaQuery('ICA Agreement Contact Assign Query') + '?pv0=' + conIdInsMap.get(cr[0].Contact__c) + ',[LTS]' + CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + conIdLTSMap.get(cr[0].Contact__c)  + ',[CR]'+CongaTranslator.getCongaQuery('ICA Agreement Cost Rate Query') + '?pv0=' + cr[0].Id + '&OFN='+tmpName;          
                        } else if (selectedCTName == 'Translation and Interpretation ICA') {
                            congaTempId = congaTempNameWithIdMap.containskey('Translation and Interpretation ICA') ? congaTempNameWithIdMap.get('Translation and Interpretation ICA') : null;
                            congaUrl = '&id='+ cr[0].Contact__c + '&templateId='+congaTempId+'&queryId=[CA]'+ CongaTranslator.getCongaQuery('ICA Agreement Contact Assign Query') + '?pv0=' + conIdInsMap.get(cr[0].Contact__c) + ',[LTS]' + CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + conIdLTSMap.get(cr[0].Contact__c)  + ',[CR]'+CongaTranslator.getCongaQuery('ICA Agreement Cost Rate Query') + '?pv0=' + cr[0].Id + '&OFN='+tmpName;          
                        } else if (selectedCTName == 'Translation and Interpretation Addendum to ICA') {
                            congaTempId = congaTempNameWithIdMap.containskey('Translation and Interpretation Addendum to ICA') ? congaTempNameWithIdMap.get('Translation and Interpretation Addendum to ICA') : null;
                            congaUrl = '&id='+ cr[0].Contact__c + '&templateId='+congaTempId+'&queryId=[CA]'+ CongaTranslator.getCongaQuery('ICA Agreement Contact Assign Query') + '?pv0=' + conIdInsMap.get(cr[0].Contact__c) + ',[CR]'+CongaTranslator.getCongaQuery('ICA Agreement Cost Rate Query') + '?pv0=' + cr[0].Id + '&OFN='+tmpName;          
                        } else if(selectedCTName == 'Offer Letter - Staff - Exempt') {
                            congaTempId = congaTempNameWithIdMap.containskey('Offer Letter - Staff - Exempt') ? congaTempNameWithIdMap.get('Offer Letter - Staff - Exempt') : null;
                            congaUrl = '&id='+ cr[0].Contact__c +'&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+ '?pv0=' + cr[0].Id + '&OFN='+tmpName; 
                        }else if(selectedCTName == 'Change of Status Form') {
                            congaTempId = congaTempNameWithIdMap.containskey('Change of Status Form') ? congaTempNameWithIdMap.get('Change of Status Form') : null;
                            congaUrl = '&id='+ cr[0].Id +'&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+ cr[0].Contact__c+',[PriorCR]' + CongaTranslator.getCongaQuery('Prior Cost Rate Query') + '?pv0=' + cr[0].Prior_Version__c + '&OFN='+tmpName; 
                        }else if( selectedCTName == 'Offer Letters - Tester') {
                            congaTempId = congaTempNameWithIdMap.containskey('Offer Letters - Tester') ? congaTempNameWithIdMap.get('Offer Letters - Tester') : null;
                            congaUrl = '&id='+ cr[0].Id + '&DS7=0&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+cr[0].Contact__c+'&OFN='+tmpName;
                        }
                        
                        /*
                        else if (selectedCTName == 'Offer Letter - DLI-W new and LT') {
                            congaTempId = congaTempNameWithIdMap.containskey('Offer Letter - DLI-W new and LT') ? congaTempNameWithIdMap.get('Offer Letter - DLI-W new and LT') : null;
                            //List<AcctSeed__Cost_Rates__c> nonSCALTCR = CostRateService.getCRByParentId(' WHERE Rate_Type__c = \'Non-SCA LT\' AND Contact__c', '', new Set<Id>{cr[0].Contact__c});
                            List<AcctSeed__Cost_Rates__c> nonSCALTCR = [SELECT Id FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c = 'Non-SCA LT' AND Contact__c =: cr[0].Contact__c Order By Effective_Date__c Desc];
                            congaUrl = '&id='+ cr[0].Id + '&DS7=0&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+cr[0].Contact__c;                   
                            if(nonSCALTCR != null && nonSCALTCR.size() > 0 ) {
                                congaUrl += ',[NonSCACR]' + CongaTranslator.getCongaQuery('ICA Agreement Cost Rate Query') + '?pv0=' + nonSCALTCR[0].Id;
                            }
                            congaUrl += '&OFN='+tmpName;
                        } 
                        */
                    }
                    
                    // To remove the old field Value when a new COnga Template is selected.
                    String docusign = wrap.congaURL.subStringAfter('&CSVisible=1');//('&qmode=DocuSign');
                    System.debug('docusign:::::'+docusign);
                    System.debug('congaUrl::::'+congaUrl);
                    System.debug('congaTempNameWithIdMap::'+congaTempNameWithIdMap.get('Offer Letter - Staff - Exempt'));
                    
                    // If launchedFrom Gen & Send Docusign button
                    if(launchedFrom == 'Docusign') {
                        //congaUrl = congaUrl.replace('&DS7=0','');
                        if(selectedCTName == 'Pay Rate Addendum') {
                            wrap.congaURL = congaUrl +'&CSVisible=1'+ docusign + '&AC0=1&AC2=1&&AC1=Pay+Rate+Addendum&LGParentId='+cr[0].Contact__c;
                        } else {
                            wrap.congaURL = congaUrl +'&CSVisible=1'/*'&qmode=CongaSign'*/+ docusign + '&AC0=1&AC2=1&&AC1=Generate+Send+Docusign&LGParentId='+cr[0].Contact__c;
                        }
                    } else { // If launchedFrom Generate Form button
                        congaUrl = congaUrl.replace('&DS7=0','');
                        if(selectedCTName == 'Pay Rate Addendum') {
                            wrap.congaURL = congaUrl + '&DS7=3&AC0=1&AC2=1&&AC1=Pay+Rate+Addendum&LGParentId='+cr[0].Contact__c;
                        } else {
                           /* if(String.isNotBlank(congaUrl) == false){
                                congaURL = wrap.congaURL;
                            }*/
                            wrap.congaURL = congaUrl + '&DS7=3&AC0=1&AC2=1&&AC1=Generate+Offer+Letter&LGParentId='+cr[0].Contact__c; // To skip the Conga Template selection screen and log activities
                        }
                    }
                }
                return wrap;
            }
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    // To get lookup records
    @AuraEnabled(cacheable=true)
    public static List<sObject> getLookupRecords(String searchString, String objectName, String fieldName,String condition,List<String> selectedIds){
        return Staff_Daily_Timesheet_Ctrl.search(String.escapeSingleQuotes(searchString),objectName,fieldName,condition,selectedIds);
    }
    @AuraEnabled
    public static String getSignerInfo(String cTName,String crId){
        Map<String,String> signerInfo = new Map<String,String>();
        
        if(cTName == 'Change of Status Form') {
            List<AcctSeed__Cost_Rates__c> crList = [SELECT Id,Contact__c,Contact__r.Name,Contact__r.DLS_User__c,Contact__r.Supervisor_Name__c,Contact__r.RecordTypeId,Contact__r.RecordType.Name FROM AcctSeed__Cost_Rates__c WHERE Id =: crId];
            
            String currentUser = null;
            String staffSigner2,staffSigner3,signer1,staffName;
            String contactId = null;
            
            if(crList.size() > 0 && crList[0].Contact__c != null){
                signer1 = crList[0].Contact__r.Supervisor_Name__c;
                staffName = crList[0].Contact__r.Name;
                
                if( crList[0].Contact__r.DLS_User__c != null){
                    currentUser = crList[0].Contact__r.DLS_User__c;
                }else if(crList[0].Contact__r.RecordTypeId != null && crList[0].Contact__r.RecordType.Name == 'Candidate' ){
                    contactId = crList[0].Contact__c;
                }
            }
            
            String userQryJSON = 'SELECT Id,Name,ContactId FROM User WHERE (Name IN (\'Natalia Stepanov\',\'Jim Bellas\') ';
            if(contactId != null){
                userQryJSON += 'OR ContactId = \''+contactId+'\'';
            }
            userQryJSON += ') AND isActive = true';
            
            System.debug(userQryJSON);
            
            for(User usr : Database.query(userQryJSON)) {
                if(usr.Name == 'Natalia Stepanov') {
                    staffSigner2 = usr.Id;
                } else if(usr.Name == 'Jim Bellas') {
                    staffSigner3 = usr.Id;
                } else if(contactId != null && usr.ContactId == contactId){
                    currentUser = usr.Id; 
                }
            }
            
        signerInfo = new Map<String,String> {
            'SupervisorSigner1' => signer1,
            'StaffSigner2' => staffSigner2,
            'StaffSigner3' => staffSigner3,
            'CurrentUser' => currentUser,
            'StaffName' => staffName
         };
      }
        return JSON.serialize(signerInfo);
    }
}