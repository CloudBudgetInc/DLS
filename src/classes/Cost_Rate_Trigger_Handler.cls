/*******************************************
     To update Cost Rate Name by appending Rate Type,Contact Alias Name and Count of records with combination of Rate Type,Contact Alias Name
********************************************/

public class Cost_Rate_Trigger_Handler {
    Static Map<String,Integer> countMap = new Map<String,Integer>();
    //Static Map<Id,String> conaliasMap = new Map<Id,String>();
    
    public static Map<Id,Integer> existingCRMap = new Map<Id,Integer>();    // This static map is used only in CR Trigger for Approval Process Exclusion for "Non SCA Testing" on 2nd record creation
    //public static List<AcctSeed__Cost_Rates__c> newVersionCR = new List<AcctSeed__Cost_Rates__c>();
    //public static Set<Id> priorCRId = new Set<Id>();
    public static Set<String> staffRateTypePM = new Set<String>{'PT Hourly (OH & G&A)', 'FT Hourly & Benefits', 'FT Salary & Benefits','International Salary'}; // To allow Pay Rate Modification Process
    // T & I Conga Template process
    public static Set<String> tAndIRateTypeSet = new Set<String>{'Non-SCA Translation (Per Hour)', 'Non-SCA Translation (FFP)', 'Non-SCA Translation W/O Editing (Per Word)', 'Non-SCA Translation Editing Only (Per Word)', 'Non-SCA Translation + Editing (Per Word)', 'Non-SCA Interpretation (Per Hour)'};
    public static Map<String,String> modifyLTPrepRTLabel = new Map<String,String>{'LT with Prep' => 'LT with Billable Prep','LT without Prep' => 'LT without Billable Prep'};

    public static void insertAndUpdateCostRate(List<AcctSeed__Cost_Rates__c> newList,Map<Id,AcctSeed__Cost_Rates__c> oldMap) {
        //System.debug('::::::::oldMap::::::::::'+oldMap);
        
        List<AcctSeed__Cost_Rates__c> newVersionCR = new List<AcctSeed__Cost_Rates__c>();
        Set<Id> priorCRId = new Set<Id>();        
        Map<Id,Integer> existingCRCountMap = new Map<Id,Integer>();    // New Map to use in this method locally instead of static one. Becuase static map counts are not accurate in before insert Conga Template Url population process
        //Map<Id,Set<String>> existingCRRateTypeMap = new Map<Id,Set<String>>(); // For Non SCA LT CR Id value population in DLI-16 SCA LT CR record Conga Template Url Field

        integer count = 0;
        Map<String,Labor_Cost_Rate_Master__c> rateTypeValueMap = new Map<String,Labor_Cost_Rate_Master__c>();
        Map<Id,Contact> contIdWithContactMap = new Map<Id,Contact>();
        // Old one Set<String> overTimeRateSet = new Set<String>{'Non-SCA Translation (Per Word)', 'Non-SCA Testing', 'International Salary', 'FT Salary & Benefits'};
        // Newly added based on the task #tasks/18743778 
        // Non-SCA LT modified into LT
        Set<String> newOverTimeRateTypeSet = new Set<String>{'LT with Prep', 'LT without Prep', 'Non-SCA LT-S', 'Non-SCA CD', 'DLI-21 SCA LT', 'DLI-21 SCA CD', 'DLI-21 SCA LT +5','DLI-21 SCA CD +5','PT Hourly (OH & G&A)', 'DLI-W LT'};
         
        // Pay Rate Modification Related Rate Types
        Set<String> prmRelatedRateTypes = new Set<String>{'DLI-W PS - Group 3','DLI-W PS - Group 4','LT with Prep','LT without Prep','Non-SCA CD','Non-SCA CD (1099)','DLI-W LT','DODA PS','FSI'};

        Map<Id,Id> conIdInsMap = new Map<Id,Id>();
        Map<Id,Id> conIdLTSMap = new Map<Id,Id>();
        Map<Id,Id> conIdprojIdMap = new Map<Id,Id>();
        Set<Id> contIds = new Set<Id>();
        
        // To update the Original Cost rate field in the Contact Assignment Object from Drafted CR Field.
        Set<Id> approvedCRIds = new Set<Id>();
        List<Contact_Assignments__c> caToUpdate = new List<Contact_Assignments__c>();
        
        // Variables to query the limited records by GRK
        Boolean isCountMapReq = false;
        Set<String> rateTypesToQuery = new Set<String>();
        Set<Id> contIdsToQuery = new Set<Id>();
        Set<Id> acctIdsToQuery = new Set<Id>();
        
        // To Assign the Conga Template Id and Conga Query Id to the "Gen_Email_Doc_Conga_Workflow_Template__c" field to make use in Outbound Message in Approval Process
        Map<string,Id> congaTempNameWithIdMap = new Map<String,Id>();
        // Non-SCA LT modified into LT
        Set<String> crRateTypeSet = new Set<String>{'LT with Prep','LT without Prep', 'Non-SCA LT-S', 'Non-SCA CD','DLI-W LT'};
        
        for(APXTConga4__Conga_Template__c ct : [SELECT Id,Name,APXTConga4__Name__c FROM APXTConga4__Conga_Template__c]) {
            congaTempNameWithIdMap.put(ct.APXTConga4__Name__c,ct.Id);
        }
        
        //Query the Custom Setting records to map the values based on the Rate Type field.
        for(Labor_Cost_Rate_Master__c lcr : [SELECT Id,Name,Exempt_Status__c,H_W_Rate__c,Holiday_Pay_Type__c,HOL_Rate__c,Hourly_Cost__c,Pay_frequency__c,Payroll_Item__c,Pay_Type__c,Rate_Type__c,SCA_Type__c,Tax_Type__c,VAC_Rate__c,Non_Billable_Payroll_Item__c,Fringe_Payroll_Item__c,Position__c, Rate_Type_Label__c FROM Labor_Cost_Rate_Master__c]) {
            rateTypeValueMap.put(lcr.Rate_Type__c, lcr);
        }
        Set<Id> tempIds = new Set<Id>();
        
        for(AcctSeed__Cost_Rates__c cr : newList) {
            // Since we need the LTS Id for the Template
            if(cr.Rate_Type__c == 'DLI-21 SCA MTT' || cr.Rate_Type__c == 'Non-SCA MTT (1099)' || cr.Rate_Type__c == 'DLI-21 SCA CD (1099)' || cr.Rate_Type__c == 'Non-SCA CD (1099)' || cr.Rate_Type__c == 'LT with Prep' || cr.Rate_Type__c == 'LT without Prep' || tAndIRateTypeSet.contains(cr.Rate_Type__c)) {    // Non-SCA LT modified into LT
                tempIds.add(cr.Contact__c);
            }
            if(Trigger.isInsert && cr.Contact__c != null) {
                contIds.add(cr.Contact__c);
            }
            
            // To form the countMap only when a new record is created or when Rate Type or Contact gets updated
            if(Trigger.isInsert || (Trigger.isupdate && (cr.Rate_Type__c != oldMap.get(cr.Id).Rate_Type__c || cr.Contact__c != oldMap.get(cr.Id).Contact__c))) {
                isCountMapReq = true;
                
                if(cr.Rate_Type__c != null) {
                    rateTypesToQuery.add(cr.Rate_Type__c);
                }
                
                if(cr.Contact__c != null) {
                    contIdsToQuery.add(cr.Contact__c);
                }
                
                if(cr.Account__c != null) {
                    acctIdsToQuery.add(cr.Account__c);
                }
            }
        }
        
        if(contIds != null) {
            contIdWithContactMap = new Map<Id,Contact>([SELECT Id,Name,RecordType.DeveloperName FROM Contact WHERE Id In: contIds]);
        }
        //if( conIdInsMap != null && conIdInsMap.size() > 0 ) 
        if( tempIds != null && tempIds.size() > 0 ) {
            for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c,RecordType.DeveloperName,Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c IN: tempIds Order BY CreatedDate DESC]) {
                if(!conIdInsMap.containskey(ca.Candidate_Name__c))
                    conIdInsMap.put(ca.Candidate_Name__c,ca.Id);
                    
                if(ca.Project__c != null && !conIdprojIdMap.containskey(ca.Project__c)) 
                    conIdprojIdMap.put(ca.Project__c, ca.Candidate_Name__c);
            }
        }
        
        if( conIdprojIdMap != null && conIdprojIdMap.size() > 0 ) {
            for(Contact_Assignments__c ca : [SELECT Id,Name,Candidate_Name__c,RecordType.DeveloperName,Project__c FROM Contact_Assignments__c WHERE Project__c IN: conIdprojIdMap.Keyset() AND RecordType.DeveloperName = 'Staff' Order BY CreatedDate DESC]) {
                if(conIdprojIdMap.containskey(ca.Project__c)) {
                    if(!conIdLTSMap.containskey(conIdprojIdMap.get(ca.Project__c)))
                        conIdLTSMap.put(conIdprojIdMap.get(ca.Project__c),ca.Candidate_Name__c);
                }
            }
        }
        
        if(isCountMapReq == true) { 
            for(AcctSeed__Cost_Rates__c ac : [SELECT Id,Name,Rate_Type__c,Contact__c,Account__c,Cost_Rate_Name__c FROM AcctSeed__Cost_Rates__c WHERE Rate_Type__c IN: rateTypesToQuery AND ( Account__c IN: acctIdsToQuery OR Contact__c IN: contIdsToQuery)]) {
            //for(AcctSeed__Cost_Rates__c ac : CostRateService.getCostrateRec('','')){ 
            
                if(ac.Rate_Type__c != null && ac.Contact__c != null){
                    String rateType = ac.Rate_Type__c;
                    Boolean isValidCRCount = true;
                    
                    if(modifyLTPrepRTLabel.containsKey(ac.Rate_Type__c)){
                        String rateTypeLabel = modifyLTPrepRTLabel.get(ac.Rate_Type__c);
                        if(ac.Cost_Rate_Name__c.contains(rateTypeLabel)){
                            rateType = rateTypeLabel;
                        }else{
                            isValidCRCount = false;
                        }
                    }
                    
                    if(isValidCRCount == true){
                        if(!countMap.containskey(rateType+'-'+ac.Contact__c)){
                            countMap.put(rateType+'-'+ac.Contact__c,count+1);
                        } else {
                            countMap.put(rateType+'-'+ac.Contact__c,countMap.get(rateType+'-'+ac.Contact__c)+1);
                        }
                    }
                    
                } else if(ac.Contact__c != null){
                    if(!countMap.containskey(ac.Contact__c)){
                        countMap.put(ac.Contact__c,count+1);
                    } else {
                        countMap.put(ac.Contact__c,countMap.get(ac.Contact__c)+1);
                    } 
                } else if(ac.Account__c != null){ // W-006039, related changes for the Rate Type = 'SubK-LT'
                    if(!countMap.containskey(ac.Account__c)){
                        countMap.put(ac.Account__c,count+1);
                    } else {
                        countMap.put(ac.Account__c,countMap.get(ac.Account__c)+1);
                    } 
                } else if(ac.Rate_Type__c != null){
                    if(!countMap.containskey(ac.Rate_Type__c)){
                        countMap.put(ac.Rate_Type__c,count+1);
                    } else {
                        countMap.put(ac.Rate_Type__c,countMap.get(ac.Rate_Type__c)+1);
                    } 
                }
                
                // To Assign the Conga Template Id and Conga Query Id to the "Gen_Email_Doc_Conga_Workflow_Template__c" field to make use in Outbound Message in Approval Process
                /*
                if(existingCRMap.containskey(ac.Contact__c)) {
                    existingCRMap.put(ac.Contact__c, existingCRMap.get(ac.Contact__c)+1);
                } else {
                    existingCRMap.put(ac.Contact__c,1);
                }
                */
                
                //This map for local usage in this method instead of static version of above one
                /*
                if(existingCRCountMap.containskey(ac.Contact__c)) {
                    existingCRCountMap.put(ac.Contact__c, existingCRCountMap.get(ac.Contact__c)+1);
                } else {
                    existingCRCountMap.put(ac.Contact__c,1);
                }
                */
                
                // For Non SCA LT CR Id value population in DLI-16 SCA LT CR record Conga Template Url Field
                /* This is not in any place
                if(!existingCRRateTypeMap.containsKey(ac.Contact__c)){
                    existingCRRateTypeMap.put(ac.Contact__c,new Set<String>{ac.Rate_Type__c});
                } else {
                    existingCRRateTypeMap.get(ac.Contact__c).add(ac.Rate_Type__c);
                }
                */
            }
            
            if(contIdsToQuery != null && contIdsToQuery.size() > 0 ) {
                for(AcctSeed__Cost_Rates__c ac : [SELECT Id,Name,Rate_Type__c,Contact__c,Account__c FROM AcctSeed__Cost_Rates__c WHERE Contact__c IN: contIdsToQuery]) {
                    //This map for local usage in this method instead of static version of above one
                    if(existingCRCountMap.containskey(ac.Contact__c)) {
                        existingCRCountMap.put(ac.Contact__c, existingCRCountMap.get(ac.Contact__c)+1);
                    } else {
                        existingCRCountMap.put(ac.Contact__c,1);
                    }
                    
                    // To Assign the Conga Template Id and Conga Query Id to the "Gen_Email_Doc_Conga_Workflow_Template__c" field to make use in Outbound Message in Approval Process
                    if(existingCRMap.containskey(ac.Contact__c)) {
                        existingCRMap.put(ac.Contact__c, existingCRMap.get(ac.Contact__c)+1);
                    } else {
                        existingCRMap.put(ac.Contact__c,1);
                    }
                }
            }
        }
         
        System.debug('countMap:::::'+countMap); 
          
        if(Trigger.isInsert){
          /*  Set<Id> conIds = new Set<Id>();      
            for (AcctSeed__Cost_Rates__c ac: newList) {
                if( ac.Rate_Type__c == 'FSI'){
                    conIds.add(ac.Contact__c);
                }
            }
            
            for(AcctSeed__Project__c ap : [SELECT Id,Name,(SELECT Id,Name,Candidate_Name__c FROM Contact_Assignments__r WHERE Id IN: conIds) FROM AcctSeed__Project__c WHERE Id IN (SELECT Project__c FROM Contact_Assignments__c WHERE Candidate_Name__c IN :conIds ) ORDER BY CreatedDate Desc]) {
                for(Contact_Assignments__c ca : ap.Contact_Assignments__r) {
                    if(!conIdProjIdMap.containskey(ca.Candidate_Name__c))
                        conIdProjIdMap.put(ca.Candidate_Name__c, ap.Id);
                }
            }*/
            
            Boolean hasPermission = FeatureManagement.checkPermission('Pay_Rate_Modification_Access');
            System.debug('hasPermission===='+hasPermission);
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            system.debug('ProfileName'+profileName);
            Set<String> translationCRs = new Set<String>{'Non-SCA Translation (Per Hour)', 'Non-SCA Interpretation (Per Hour)', 'Non-SCA Translation (FFP)', 'Non-SCA Translation W/O Editing (Per Word)', 'Non-SCA Translation Editing Only (Per Word)', 'Non-SCA Translation + Editing (Per Word)'};
            
            for (AcctSeed__Cost_Rates__c ac: newList) {
                if(ac.Rate_Type__c != null && rateTypeValueMap.containskey(ac.Rate_Type__c)) {
                    Labor_Cost_Rate_Master__c lcr = rateTypeValueMap.get(ac.Rate_Type__c);
                    if(ac.AcctSeed__Hourly_Cost__c == null && lcr.Hourly_Cost__c != null) {
                        ac.AcctSeed__Hourly_Cost__c = lcr.Hourly_Cost__c;
                    }
                    
                    // Calculate the Annual Salary Cost for FSI ratetype
                    if(ac.Rate_Type__c == 'FSI' && ac.AcctSeed__Hourly_Cost__c != null) {
                        ac.Annual_Salary_Cost__c = (ac.AcctSeed__Hourly_Cost__c * 2080);
                    }
                    
                    if(ac.H_W_Rate__c == null && lcr.H_W_Rate__c != null) {
                        ac.H_W_Rate__c = lcr.H_W_Rate__c;
                    }
                    if(ac.Holiday_Pay_Type__c == null && lcr.Holiday_Pay_Type__c != null) {
                        ac.Holiday_Pay_Type__c = lcr.Holiday_Pay_Type__c;
                    }
                    if(ac.Rate_Type_Label__c == null && lcr.Rate_Type_Label__c != null) {
                        ac.Rate_Type_Label__c = lcr.Rate_Type_Label__c;
                    }
                    if(ac.HOL_Rate__c == null && lcr.HOL_Rate__c != null) {
                        ac.HOL_Rate__c = lcr.HOL_Rate__c;
                    }
                    if(ac.Exempt_Status__c == null && lcr.Exempt_Status__c != null) {
                        ac.Exempt_Status__c = lcr.Exempt_Status__c;
                    }
                    if(ac.Pay_frequency__c == null && lcr.Pay_frequency__c != null) {
                        ac.Pay_frequency__c = lcr.Pay_frequency__c;
                    }
                    if(ac.Payroll_Item__c == null && lcr.Payroll_Item__c != null) {
                        ac.Payroll_Item__c = lcr.Payroll_Item__c;
                    } 
                    if(ac.Pay_Type__c == null && lcr.Pay_Type__c != null) {
                        ac.Pay_Type__c = lcr.Pay_Type__c;
                    }
                    if(ac.SCA_Type__c == null && lcr.SCA_Type__c != null) {
                        ac.SCA_Type__c = lcr.SCA_Type__c;
                    }
                    if(ac.Tax_Type__c == null && lcr.Tax_Type__c != null) {
                        ac.Tax_Type__c = lcr.Tax_Type__c;
                    }
                    if(ac.VAC_Rate__c == null && lcr.VAC_Rate__c != null) {
                        ac.VAC_Rate__c = lcr.VAC_Rate__c;
                    }
                    if(ac.Non_Billable_Payroll_Item__c == null && lcr.Non_Billable_Payroll_Item__c != null) {
                        ac.Non_Billable_Payroll_Item__c = lcr.Non_Billable_Payroll_Item__c;
                    }
                    if(ac.Fringe_Payroll_Item__c == null && lcr.Fringe_Payroll_Item__c != null) {
                        ac.Fringe_Payroll_Item__c = lcr.Fringe_Payroll_Item__c;
                    }
                    /* if(ac.OverTime_Rate__c == null) {
                        if(ac.Rate_Type__c == 'FT Hourly & Benefits' && ac.Salary_Cost_Per_Hour__c != null) {
                            ac.OverTime_Rate__c = ac.Salary_Cost_Per_Hour__c * 5;
                        } else if (!overTimeRateSet.contains(ac.Rate_Type__c) && ac.AcctSeed__Hourly_Cost__c != null ) {
                            ac.OverTime_Rate__c = ac.AcctSeed__Hourly_Cost__c * 5;
                        }
                    } */
                    // commented above and Newly added to update the OverTime_Hourly_Cost based on the task #tasks/18743778
                    if(ac.AcctSeed__Overtime_Hourly_Cost__c == null && ac.AcctSeed__Hourly_Cost__c != null && newOverTimeRateTypeSet.contains(ac.Rate_Type__c)) {
                        ac.AcctSeed__Overtime_Hourly_Cost__c = ac.AcctSeed__Hourly_Cost__c * 1.5;
                    }
                    if(ac.Position__c == null && lcr.Position__c != null) {
                        ac.Position__c = lcr.Position__c;
                    }
                }
                
                //Added by Shalini on Feb 12 2018 
                //To update Status as "Draft" if Status is blank
                if(ac.Status__c == null){
                    ac.Status__c = 'Draft';     
                }
                
                // To make use of it in the Sharing Rules by GRK on 16/11/2018
                if(ac.Contact_Record_Type__c == null && ac.Contact__c != null && contIdWithContactMap.Containskey(ac.Contact__c)) {
                    ac.Contact_Record_Type__c = contIdWithContactMap.get(ac.Contact__c).RecordType.DeveloperName;
                }
                
                // To Assign the Conga Template Id and Conga Query Id to the "Gen_Email_Doc_Conga_Workflow_Template__c" field to make use in Outbound Message in Approval Process
                
                Id congaTempId;
                String tempName ='';
                
                /*Start of the code to set the Conga generated Doc Name */
                if(contIdWithContactMap.containskey(ac.Contact__c)) {
                    tempName = ' - ' + contIdWithContactMap.get(ac.Contact__c).Name;
                }
                if(ac.Effective_Date__c != null){
                    tempName += ' - ' + String.ValueOf(ac.Effective_Date__c).replace('-','');
                }
                /*End of the code to set the Conga generated Doc Name */
                //System.debug('existingCRCountMap============'+existingCRCountMap.containskey(ac.Contact__c));
                if(existingCRCountMap.containskey(ac.Contact__c)) {
                    System.debug('Inside existingCRCountMap');
                    /*if(ac.Rate_Type__c == 'Non-SCA Testing') {
                        congaTempId = congaTempNameWithIdMap.containskey('Tester Payment Form') ? congaTempNameWithIdMap.get('Tester Payment Form') : null;
                        ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&templateId='+congaTempId+'&queryId=[Pro]'+CongaTranslator.getCongaQuery('Project Query for Job Summary Report')+'?pv0=' + conIdProjIdMap.get(ac.Contact__c) + ',[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+ac.Contact__c; // Need to add conIdProjIdMap
                    } else {
                        congaTempId = congaTempNameWithIdMap.containskey('Pay Rate Addendum') ? congaTempNameWithIdMap.get('Pay Rate Addendum') : null;
                        ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&id='+ ac.Contact__c + '&DS7=0&templateId='+congaTempId+'&queryId=[CR]'+CongaTranslator.getCongaQuery('Cost Rate Query - CR Approval')+'?pv0='+ac.Contact__c+'~pv1=Approved,[DraftCR]'+CongaTranslator.getCongaQuery('Cost Rate Query - CR Approval')+'?pv0='+ac.Contact__c+'~pv1=Draft';
                    }*/
                    if ( ac.Rate_Type__c == 'DLI-21 SCA MTT' || ac.Rate_Type__c == 'Non-SCA MTT (1099)') {
                        congaTempId = congaTempNameWithIdMap.containskey('MTT ICA') ? congaTempNameWithIdMap.get('MTT ICA') : null;
                        ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&id='+ ac.Contact__c + '&templateId='+congaTempId+'&queryId=[CA]'+ CongaTranslator.getCongaQuery('ICA Agreement Contact Assign Query') + '?pv0=' + conIdInsMap.get(ac.Contact__c) + ',[LTS]' + CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + conIdLTSMap.get(ac.Contact__c);       //&DS7=0            
                    } else if ( ac.Rate_Type__c == 'DLI-21 SCA CD (1099)' || ac.Rate_Type__c == 'Non-SCA CD (1099)') { // based on the CD Workflow Changes "W-000759"
                        congaTempId = congaTempNameWithIdMap.containskey('ICA DLI-W 2017') ? congaTempNameWithIdMap.get('ICA DLI-W 2017') : null;
                        ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&id='+ ac.Contact__c + '&templateId='+congaTempId+'&queryId=[CA]'+ CongaTranslator.getCongaQuery('ICA Agreement Contact Assign Query') + '?pv0=' + conIdInsMap.get(ac.Contact__c) + ',[LTS]' + CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + conIdLTSMap.get(ac.Contact__c);       //&DS7=0            
                    } else if (staffRateTypePM.contains(ac.Rate_Type__c)) { //tried to include it from CR and found we need the Ins and Staff info from the Project
                        // To use the Pay Rate Modification form for the staffRateTypePM values 
                        if(ac.Prior_Version__c != null) {
                            congaTempId = congaTempNameWithIdMap.containskey('Change of Status Form') ? congaTempNameWithIdMap.get('Change of Status Form') : null;                            
                            ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&templateId='+congaTempId + '&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+ac.Contact__c+',[PriorCR]' + CongaTranslator.getCongaQuery('Prior Cost Rate Query') + '?pv0=' + ac.Prior_Version__c;
                        } else if((ac.Rate_Type__c == 'FT Salary & Benefits' || ac.Rate_Type__c == 'FT Hourly & Benefits' || ac.Rate_Type__c == 'PT Hourly (OH & G&A)') && ac.Exempt_Status__c == 'Exempt') {
                            congaTempId = congaTempNameWithIdMap.containskey('Offer Letter - Staff - Exempt') ? congaTempNameWithIdMap.get('Offer Letter - Staff - Exempt') : null;
                            ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+ac.Contact__c;     
                        }else if((ac.Rate_Type__c == 'FT Hourly & Benefits' || ac.Rate_Type__c == 'PT Hourly (OH & G&A)') && ac.Exempt_Status__c == 'Non-Exempt') {
                            congaTempId = congaTempNameWithIdMap.containskey('Offer Letter - Staff - Non-Exempt') ? congaTempNameWithIdMap.get('Offer Letter - Staff - Non-Exempt') : null;
                            ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&id='+ ac.Contact__c +'&templateId='+congaTempId; 
                        }else if(ac.Rate_Type__c == 'International Salary') {
                            congaTempId = congaTempNameWithIdMap.containskey('Offer Letter - UAE Template') ? congaTempNameWithIdMap.get('Offer Letter - UAE Template') : null;
                            ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+ac.Contact__c;     
                        }
                    } else if ( tAndIRateTypeSet.contains(ac.Rate_Type__c)) {
                        congaTempId = congaTempNameWithIdMap.containskey('Translation and Interpretation ICA') ? congaTempNameWithIdMap.get('Translation and Interpretation ICA') : null; 
                        ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&id='+ ac.Contact__c + '&templateId='+congaTempId+'&queryId=[CA]'+ CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + conIdInsMap.get(ac.Contact__c) + ',[LTS]' + CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + conIdLTSMap.get(ac.Contact__c);                   
                    } else if(ac.Rate_Type__c != 'Non-SCA Testing' && ac.Rate_Type__c != 'SubK-LT') {
                        if((ac.Rate_Type__c == 'FSI' || ac.Rate_Type__c == 'LT with Prep' || ac.Rate_Type__c == 'LT without Prep' || ac.Rate_Type__c == 'Non-SCA CD' || ac.Rate_Type__c == 'Non-SCA CD (1099)' || ac.Rate_Type__c == 'DLI-W LT') && ac.Prior_Version__c != null) {    // Non-SCA LT modified into LT
                            congaTempId = congaTempNameWithIdMap.containskey('Pay Rate Modification') ? congaTempNameWithIdMap.get('Pay Rate Modification') : null;
                            ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + ac.Contact__c; // + ',[LTS]' + CongaTranslator.getCongaQuery('User Query') + '?pv0=' +UserInfo.getUserId(); LTS will be the one who is initiating the Signing process
                            // Id will be the Cost Rate Id, set in Generating the URL
                        } else {
                            congaTempId = congaTempNameWithIdMap.containskey('Pay Rate Addendum') ? congaTempNameWithIdMap.get('Pay Rate Addendum') : null;
                            //ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&id='+ ac.Contact__c + '&DS7=0&templateId='+congaTempId+'&queryId=[CR]'+CongaTranslator.getCongaQuery('Cost Rate Query - CR Approval')+'?pv0='+ac.Contact__c+'~pv1=Approved,[DraftCR]'+CongaTranslator.getCongaQuery('Cost Rate Query - CR Approval')+'?pv0='+ac.Contact__c+'~pv1=Draft';
                            //ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&id='+ ac.Contact__c + '&templateId='+congaTempId+'&queryId=[CR]'+CongaTranslator.getCongaQuery('Cost Rate Query - CR Approval')+'?pv0='+ac.Contact__c+'~pv1=Approved,[DraftCR]'+CongaTranslator.getCongaQuery('Cost Rate Query - Non approved')+'?pv0='+ac.Contact__c+'~pv1=\'Draft\'|\'Submitted for Approval\'' +'&OFN=Pay Rate Addendum'+tempName; //Cost Rate Query - CR Approval   &DS7=0
                            ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&templateId='+congaTempId +'&queryId=[CR]'+CongaTranslator.getCongaQuery('Cost Rate Query - CR Approval')+'?pv0='+ac.Contact__c+'~pv1=Approved,[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + ac.Contact__c ;
                        }
                    } else if(ac.Rate_Type__c == 'Non-SCA Testing') {
                        congaTempId = congaTempNameWithIdMap.containskey('Pay Rate Addendum') ? congaTempNameWithIdMap.get('Pay Rate Addendum') : null;
                        ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&templateId='+congaTempId +'&queryId=[CR]'+CongaTranslator.getCongaQuery('Cost Rate Query - CR Approval')+'?pv0='+ac.Contact__c+'~pv1=Approved,[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + ac.Contact__c ;
                    } 
                    
                    // Added DODA PS to Auto Approve the Labor Cost Rate
                    // Removed ac.Rate_Type__c == 'Non-SCA Testing' from Auto approval process #W-007618
                    if((ac.Rate_Type__c == 'DODA PS' || ac.Rate_Type__c == 'DLI-W PS - Group 3' || ac.Rate_Type__c == 'DLI-W PS - Group 4') && (CostRateCreation_Ctrl.isFromCR == True )) {
                        ac.Status__c = 'Approved';
                    }
                    
                    // Added By HL
                    // To update the Prior Cost Rate Status to Inactive when new version of the CR is Approved
                    if(ac.Prior_Version__c != NULL && ( hasPermission && (profileName != 'LTS' && prmRelatedRateTypes.contains(ac.Rate_Type__c)) || staffRateTypePM.contains(ac.Rate_Type__c))) {    // Non-SCA LT modified into LT
                        ac.Status__c = 'Approved';                        
                        priorCRId.add(ac.Prior_Version__c);
                        newVersionCR.add(ac);
                    }
                } else {
                    System.debug('Inside else existingCRCountMap');
                    if(ac.Rate_Type__c == 'Non-SCA Testing') {
                        congaTempId = congaTempNameWithIdMap.containskey('Offer Letters - Tester') ? congaTempNameWithIdMap.get('Offer Letters - Tester') : null;
                        ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+ '?pv0='+ac.Contact__c;
                    } else if (ac.Rate_Type__c == 'LT with Prep' || ac.Rate_Type__c == 'LT without Prep' || ac.Rate_Type__c == 'Non-SCA CD' || ac.Rate_Type__c == 'Non-SCA LT-S' || ac.Rate_Type__c == 'DLI-W LT') {    // Non-SCA LT modified into LT
                        
                        congaTempId = congaTempNameWithIdMap.containskey('Offer Letter - Instructors LT') ? congaTempNameWithIdMap.get('Offer Letter - Instructors LT') : null;
                        ac.Gen_Email_Doc_Conga_Workflow_Template__c = /*'&id='+ ac.Id + &DS7=0*/ '&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+ '?pv0='+ac.Contact__c;
                        
                    }else if(ac.Rate_Type__c == 'FSI') { // Added by Siva on August 16, 2023
                        congaTempId = congaTempNameWithIdMap.containskey('FSI Offer Letter') ? congaTempNameWithIdMap.get('FSI Offer Letter') : null;
                        ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+ac.Contact__c;     
                   
                    } else if ( ac.Rate_Type__c == 'DLI-21 SCA CD' || ac.Rate_Type__c == 'DLI-21 SCA LT') {
                        
                        congaTempId = congaTempNameWithIdMap.containskey('Offer Letter - DLI-W New Contract - SCA') ? congaTempNameWithIdMap.get('Offer Letter - DLI-W New Contract - SCA') : null;
                        ac.Gen_Email_Doc_Conga_Workflow_Template__c = /*'&id='+ ac.Id + &DS7=0*/ '&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+ '?pv0='+ac.Contact__c;
                    
                    } 
                    // commented based on the task W-001427
                    /*else if (ac.Rate_Type__c == 'DLI-16 SCA LT' || ac.Rate_Type__c == 'DLI-20 SCA LT') {
                        
                        /String nonSCAValues = ac.Gen_Email_Doc_Conga_Workflow_Template__c;
                        system.debug(':::::::nonSCAValues:::::'+nonSCAValues);
                        congaTempId = congaTempNameWithIdMap.containskey('Offer Letter - DLI-W new and LT') ? congaTempNameWithIdMap.get('Offer Letter - DLI-W new and LT') : null;
                        ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+ '?pv0='+ac.Contact__c;                   
                        
                        //For Non SCA LT CR record related information binding in DLI-16 SCA LT related CR Template field
                        if(nonSCAValues != null && nonSCAValues.contains(',[NonSCACR]')){
                            ac.Gen_Email_Doc_Conga_Workflow_Template__c += nonSCAValues;
                        }
                        
                    }*/ else if (ac.Rate_Type__c == 'DLI-21 SCA MTT' || ac.Rate_Type__c == 'Non-SCA MTT (1099)') {
                        
                        congaTempId = congaTempNameWithIdMap.containskey('MTT ICA') ? congaTempNameWithIdMap.get('MTT ICA') : null;
                        ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&id='+ ac.Contact__c + '&templateId='+congaTempId+'&queryId=[CA]'+ CongaTranslator.getCongaQuery('ICA Agreement Contact Assign Query') + '?pv0=' + conIdInsMap.get(ac.Contact__c) + ',[LTS]' + CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + conIdLTSMap.get(ac.Contact__c);           //&DS7=0         
                    
                    } else if (ac.Rate_Type__c == 'DLI-21 SCA CD (1099)' || ac.Rate_Type__c == 'Non-SCA CD (1099)') {
                        
                        congaTempId = congaTempNameWithIdMap.containskey('ICA DLI-W 2017') ? congaTempNameWithIdMap.get('ICA DLI-W 2017') : null;
                        ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&id='+ ac.Contact__c + '&templateId='+congaTempId+'&queryId=[CA]'+ CongaTranslator.getCongaQuery('ICA Agreement Contact Assign Query') + '?pv0=' + conIdInsMap.get(ac.Contact__c) + ',[LTS]' + CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + conIdLTSMap.get(ac.Contact__c);       //&DS7=0            
                    
                    } else if ((ac.Rate_Type__c == 'FT Salary & Benefits' || ac.Rate_Type__c == 'FT Hourly & Benefits' || ac.Rate_Type__c == 'PT Hourly (OH & G&A)') && ac.Exempt_Status__c == 'Exempt') { //tried to include it from CR and found we need the Ins and Staff info from the Project
                        
                        congaTempId = congaTempNameWithIdMap.containskey('Offer Letter - Staff - Exempt') ? congaTempNameWithIdMap.get('Offer Letter - Staff - Exempt') : null;
                        ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+ac.Contact__c;     
                    
                    } else if(ac.Rate_Type__c == 'International Salary') { // Added by GRK on July 03, 2023
                    
                        congaTempId = congaTempNameWithIdMap.containskey('Offer Letter - UAE Template') ? congaTempNameWithIdMap.get('Offer Letter - UAE Template') : null;
                        ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+ac.Contact__c;     
                   
                    } else if( tAndIRateTypeSet.contains(ac.Rate_Type__c)) {
                        
                        congaTempId = congaTempNameWithIdMap.containskey('Translation and Interpretation ICA') ? congaTempNameWithIdMap.get('Translation and Interpretation ICA') : null;
                        //ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&DS7=0&templateId='+congaTempId+'&queryId=[Con]'+CongaTranslator.getCongaQuery('Offer Letter - Contact Query')+'?pv0='+ac.Contact__c;
                        ac.Gen_Email_Doc_Conga_Workflow_Template__c = '&id='+ ac.Contact__c + '&templateId='+congaTempId+'&queryId=[CA]'+ CongaTranslator.getCongaQuery('ICA Agreement Contact Assign Query') + '?pv0=' + conIdInsMap.get(ac.Contact__c) + ',[LTS]' + CongaTranslator.getCongaQuery('Offer Letter - Contact Query') + '?pv0=' + conIdLTSMap.get(ac.Contact__c);                   
                    
                    }
                }
                // Since it is before insert Trigger, the Id of the CR for Conga query is mapped in the formula field which is making use of this field.
                if(ac.Rate_Type__c != 'FT Salary & Benefits' && ac.Rate_Type__c != 'FT Hourly & Benefits'){
                    ac.Cost_Rate_Name__c = getCRName(ac);
                }
                system.debug(':Cost_Rate_Trigger::Cost_Rate_Name__c:::ac:'+ac);
                
                // To Auto Approved Translation related CRs
                if(ac.Rate_Type__c != NULL && translationCRs.contains(ac.Rate_Type__c )){
                    ac.Status__c = 'Approved';
                }                
            }
            
            if(newVersionCR.size() > 0 && priorCRId != null) {
                Cost_Rate_Trigger_Handler.updatePriorCRStatus(newVersionCR, priorCRId);
            }
        }
        if(Trigger.isUpdate){
            
            for (AcctSeed__Cost_Rates__c ac: newList) {
                if(oldMap != Null){
                    
                    // To update the default values for some fields based on the Rate Type
                    if(ac.Rate_Type__c != oldMap.get(ac.Id).Rate_Type__c ) {
                        Labor_Cost_Rate_Master__c newLCR = (ac.Rate_Type__c != null && rateTypeValueMap.containskey(ac.Rate_Type__c) ? rateTypeValueMap.get(ac.Rate_Type__c) : null);
                        Labor_Cost_Rate_Master__c oldLCR = (oldMap.get(ac.Id).Rate_Type__c != null && rateTypeValueMap.containskey(oldMap.get(ac.Id).Rate_Type__c) ? rateTypeValueMap.get(oldMap.get(ac.Id).Rate_Type__c) : null);
                        
                        // If Old Value is changed to New Value/ null in Rate Type field OR If changed from null to New Value in Rate Type Field
                        if( ( oldLCR != null && ac.AcctSeed__Hourly_Cost__c == oldLCR.Hourly_Cost__c) || ( oldLCR == null && ac.AcctSeed__Hourly_Cost__c == null ) ) {
                            ac.AcctSeed__Hourly_Cost__c = newLCR != null ? newLCR.Hourly_Cost__c : null;
                            
                            // Calculate the Annual Salary Cost for FSI ratetype
                            if(ac.Rate_Type__c == 'FSI' && ac.AcctSeed__Hourly_Cost__c != null){
                                ac.Annual_Salary_Cost__c = (ac.AcctSeed__Hourly_Cost__c * 2080);
                            }
                        }

                        if( ( oldLCR != null && ac.H_W_Rate__c == oldLCR.H_W_Rate__c ) || ( oldLCR == null && ac.H_W_Rate__c == null ) ) {
                            ac.H_W_Rate__c = newLCR != null ? newLCR.H_W_Rate__c : null;
                        }
                        if( ( oldLCR != null && ac.Holiday_Pay_Type__c == oldLCR.Holiday_Pay_Type__c ) || ( oldLCR == null && ac.Holiday_Pay_Type__c == null ) ) {
                            ac.Holiday_Pay_Type__c = newLCR != null ? newLCR.Holiday_Pay_Type__c : null;
                        }
                        if( ( oldLCR != null && ac.Rate_Type_Label__c == oldLCR.Rate_Type_Label__c ) || ( oldLCR == null && ac.Rate_Type_Label__c == null ) ) {
                            ac.Rate_Type_Label__c = newLCR != null ? newLCR.Rate_Type_Label__c : null;
                        }
                        if( ( oldLCR != null && ac.HOL_Rate__c == oldLCR.HOL_Rate__c ) || (oldLCR == null && ac.HOL_Rate__c == null ) ) {
                            ac.HOL_Rate__c = newLCR != null ? newLCR.HOL_Rate__c : null;
                        }
                        if( ( oldLCR != null && ac.Exempt_Status__c == oldLCR.Exempt_Status__c) || (oldLCR == null && ac.Exempt_Status__c == null ) ) {
                            ac.Exempt_Status__c = newLCR != null ? newLCR.Exempt_Status__c : null;
                        }
                        if(  ( oldLCR != null && ac.Pay_frequency__c == oldLCR.Pay_frequency__c) || (oldLCR == null && ac.Pay_frequency__c == null ) ) {
                            ac.Pay_frequency__c = newLCR != null ? newLCR.Pay_frequency__c : null;
                        }
                        if( ( oldLCR != null && ac.Payroll_Item__c == oldLCR.Payroll_Item__c) || (oldLCR == null && ac.Payroll_Item__c == null ) ) {
                            ac.Payroll_Item__c = newLCR != null ? newLCR.Payroll_Item__c : null;
                        } 
                        if( ( oldLCR != null && ac.Pay_Type__c == oldLCR.Pay_Type__c) || (oldLCR == null && ac.Pay_Type__c == null ) ) {
                            ac.Pay_Type__c = newLCR != null ? newLCR.Pay_Type__c : null;
                        }
                        if( ( oldLCR != null && ac.Rate_Type__c == oldLCR.Rate_Type__c) || (oldLCR == null && ac.Rate_Type__c == null ) ) {
                            ac.Rate_Type__c = newLCR != null ? newLCR.Rate_Type__c : null;
                        } 
                        if( ( oldLCR != null && ac.SCA_Type__c == oldLCR.SCA_Type__c) || (oldLCR == null && ac.SCA_Type__c == null ) ) {
                            ac.SCA_Type__c = newLCR != null ? newLCR.SCA_Type__c : null;
                        }
                        if( ( oldLCR != null && ac.Tax_Type__c == oldLCR.Tax_Type__c) || (oldLCR == null && ac.Tax_Type__c == null ) ) {
                            ac.Tax_Type__c = newLCR != null ? newLCR.Tax_Type__c : null;
                        }
                        if( ( oldLCR != null && ac.VAC_Rate__c == oldLCR.VAC_Rate__c) || (oldLCR == null && ac.VAC_Rate__c == null ) ) {
                            ac.VAC_Rate__c = newLCR != null ? newLCR.VAC_Rate__c : null;
                        }
                        if( ( oldLCR != null && ac.Non_Billable_Payroll_Item__c == oldLCR.Non_Billable_Payroll_Item__c) || (oldLCR == null && ac.Non_Billable_Payroll_Item__c == null ) ) {
                            ac.Non_Billable_Payroll_Item__c = newLCR != null ? newLCR.Non_Billable_Payroll_Item__c : null;
                        }
                        if( ( oldLCR != null && ac.Fringe_Payroll_Item__c == oldLCR.Fringe_Payroll_Item__c) || (oldLCR == null && ac.Fringe_Payroll_Item__c == null ) ) {
                            ac.Fringe_Payroll_Item__c = newLCR != null ? newLCR.Fringe_Payroll_Item__c : null;
                        }
                        if( ( oldLCR != null && ac.Position__c == oldLCR.Position__c) || ( oldLCR == null && ac.Position__c == null) ) {
                            ac.Position__c = newLCR != null ? newLCR.Position__c : null;
                        }
                        // To update the Over Time Rate when the Rate Type is updated
                        if(ac.AcctSeed__Hourly_Cost__c != null && newOverTimeRateTypeSet.contains(ac.Rate_Type__c)) {
                            ac.AcctSeed__Overtime_Hourly_Cost__c = ac.AcctSeed__Hourly_Cost__c * 1.5;
                        } else if(!newOverTimeRateTypeSet.contains(ac.Rate_Type__c)) {
                            ac.AcctSeed__Overtime_Hourly_Cost__c = 0;
                        }
                    }                    
                    
                    if(ac.AcctSeed__Hourly_Cost__c != NULL && ac.AcctSeed__Hourly_Cost__c != oldMap.get(ac.Id).AcctSeed__Hourly_Cost__c && newOverTimeRateTypeSet.contains(ac.Rate_Type__c)) {
                        ac.AcctSeed__Overtime_Hourly_Cost__c = ac.AcctSeed__Hourly_Cost__c * 1.5;
                    }
                    
                    if( ac.Status__c != oldMap.get(ac.Id).Status__c && ac.Status__c == 'Approved') {
                        approvedCRIds.add(ac.Id);
                    }
                }
                
                if((oldMap.get(ac.Id).Contact__c != ac.Contact__c || oldMap.get(ac.Id).Rate_Type__c != ac.Rate_Type__c) 
                    && (ac.Rate_Type__c != 'FT Salary & Benefits' && ac.Rate_Type__c != 'FT Hourly & Benefits')){
                    
                    ac.Cost_Rate_Name__c = getCRName(ac);
                    //system.debug(':Cost_Rate_Trigger::Cost_Rate_Name__c:::ac:'+ac);
                }
                
                //Developed method to calculate Fully Loaded Rate when changes occur in Rate field
                //W-008029
                if(oldMap.get(ac.Id).AcctSeed__Hourly_Cost__c != ac.AcctSeed__Hourly_Cost__c && ac.Rate_Type__c != 'FT Salary & Benefits' && ac.Rate_Type__c != 'FT Hourly & Benefits') {
                    Decimal oldVal = getCRNameFullyLoadedRate(oldMap.get(ac.Id));
                    Decimal newVal = getCRNameFullyLoadedRate(ac);
                    System.debug('oldVal::::'+String.ValueOf(oldVal));
                    System.debug('newVal::::'+String.ValueOf(newVal));
                    System.debug(':::ac.Cost_Rate_Name__c::::'+ac.Cost_Rate_Name__c);
                    if(ac.Cost_Rate_Name__c.contains(String.ValueOf(oldVal))) {
                        String tmp = ac.Cost_Rate_Name__c.replace(String.ValueOf(oldVal),String.ValueOf(newVal));
                        ac.Cost_Rate_Name__c = tmp;
                        System.debug(':::tmp::::'+tmp);
                    }
                }
            }  
            
            if( approvedCRIds != null && approvedCRIds.size() > 0 ) {
                for(Contact_Assignments__c ca : [SELECT Id,Name,Drafted_Labor_Cost_Rate__c,Rate_Card_Rate__c FROM Contact_Assignments__c WHERE Drafted_Labor_Cost_Rate__c IN: approvedCRIds]) {
                    ca.Rate_Card_Rate__c = ca.Drafted_Labor_Cost_Rate__c;
                    ca.Drafted_Labor_Cost_Rate__c = null;
                    caToUpdate.add(ca);
                }
                if(caToUpdate != null && caToUpdate.size() > 0 ) {
                    update caToUpdate;
                }
            }  
        }   
    }
    
    public static String appendZeroleft(Integer finalCount) { 
        String sizeList = '00001';

        Integer n = finalCount,i;
        for(i=0;n!=0;i++){
           //system.debug('::Cost_Rate_Trigger:::'+n);        
           n=n/10;
           //system.debug('::Cost_Rate_Trigger:::'+n);
        }
        
        system.debug(':::n:::'+i);
        if(i <=5 && i >= 1){
            if(i == 1) sizeList = '0000'+String.ValueOf(finalCount);
            if(i == 2) sizeList = '000'+String.ValueOf(finalCount);
            if(i == 3) sizeList = '00'+String.ValueOf(finalCount);
            if(i == 4) sizeList = '0'+(finalCount);
        }
        return sizeList;
    }      
    
    public static String getCRName(AcctSeed__Cost_Rates__c ac) {
        Decimal fullyLoadedRate = 0.00;
        String refValue;
        integer count = 0;
        if(ac.Rate_Type__c == 'Non-SCA Testing') {
            if(ac.Per_Test_Cost__c != NULL ){
                fullyLoadedRate = ac.Per_Test_Cost__c;
            }else if(ac.AcctSeed__Hourly_Cost__c != NULL){
                fullyLoadedRate = ac.AcctSeed__Hourly_Cost__c;
            }
        //} else if (ac.Rate_Type__c == 'Non-SCA Translation (Per Word)') {
        } else if (ac.Rate_Type__c == 'Non-SCA Translation W/O Editing (Per Word)' || ac.Rate_Type__c == 'Non-SCA Translation Editing Only (Per Word)' || ac.Rate_Type__c == 'Non-SCA Translation + Editing (Per Word)') {
            fullyLoadedRate = ac.Per_Word_Cost__c;
        } else if (ac.Rate_Type__c == 'Non-SCA Translation (Per Hour)') {
            fullyLoadedRate = ac.AcctSeed__Hourly_Cost__c;
        } else if(ac.Rate_Type__c == 'Non-SCA Translation (FFP)') {
            fullyLoadedRate = ac.Per_FFP_Cost__c;
        } else {
            if(ac.H_W_Rate__c != null)
                fullyLoadedRate = ac.H_W_Rate__c;
            
            if(ac.HOL_Rate__c != null)
               fullyLoadedRate += ac.HOL_Rate__c;
            
            if(ac.VAC_Rate__c != null)
                fullyLoadedRate += ac.VAC_Rate__c;
            
            if(ac.AcctSeed__Hourly_Cost__c != null)
                fullyLoadedRate += ac.AcctSeed__Hourly_Cost__c;
        }
        
        if(countMap != Null && ac.Rate_Type__c != null && ac.Contact__c != null) {
            String rateType = ac.Rate_Type__c;
            
            if(modifyLTPrepRTLabel.containsKey(ac.Rate_Type__c)){
                rateType = modifyLTPrepRTLabel.get(ac.Rate_Type__c);
            }

            if(!countMap.containskey(rateType+'-'+ac.Contact__c)){
                countMap.put(rateType+'-'+ac.Contact__c,count);
            } else {
                countMap.put(rateType+'-'+ac.Contact__c,countMap.get(rateType+'-'+ac.Contact__c)+1);
            }
            //refValue = ac.Rate_Type__c + '-'+ conaliasMap.get(ac.Contact__c) +'-'+appendZeroleft(countMap.get(ac.Rate_Type__c+'-'+conaliasMap.get(ac.Contact__c))); 
           refValue = rateType + '-'+appendZeroleft(countMap.get(rateType+'-'+ac.Contact__c)).right(2) + '-$' +fullyLoadedRate;
        } else if(ac.Contact__c != null) {   
            if(!countMap.containskey(ac.Contact__c)) {
                countMap.put(ac.Contact__c,count);
            } else {
                countMap.put(ac.Contact__c,countMap.get(ac.Contact__c)+1);
            } 
            //refValue = conaliasMap.get(ac.Contact__c) +'-'+appendZeroleft(countMap.get(conaliasMap.get(ac.Contact__c))); 
            if(ac.Rate_Type__c != null)
                refValue = ac.Rate_Type__c +'-'+appendZeroleft(countMap.get(ac.Contact__c)).right(2)+'-$'+fullyLoadedRate;
            
        } else if(ac.Account__c != null) {   // W-006039, related changes for the Rate Type = 'SubK-LT'
            if(!countMap.containskey(ac.Account__c)) {
                countMap.put(ac.Account__c,count);
            } else {
                countMap.put(ac.Account__c,countMap.get(ac.Account__c)+1);
            } 
            //refValue = conaliasMap.get(ac.Account__c) +'-'+appendZeroleft(countMap.get(conaliasMap.get(ac.Account__c))); 
            if(ac.Rate_Type__c != null)
                refValue = ac.Rate_Type__c +'-'+appendZeroleft(countMap.get(ac.Account__c)).right(2)+'-$'+fullyLoadedRate;
            
        } else if(ac.Rate_Type__c != null) {
            if(!countMap.containskey(ac.Rate_Type__c)){
                countMap.put(ac.Rate_Type__c,count);
            } else {
                countMap.put(ac.Rate_Type__c,countMap.get(ac.Rate_Type__c)+1);
            } 
            //refValue = ac.Rate_Type__c +'-'+appendZeroleft(countMap.get(ac.Rate_Type__c));
            refValue = ac.Rate_Type__c +'-'+appendZeroleft(countMap.get(ac.Rate_Type__c)).right(2)+'-$'+fullyLoadedRate;
        }
        return refValue;       
    }
    
    //Developed method to calculate Fully Loaded Rate when changes occur in Rate field
    //W-008029
    public static Decimal getCRNameFullyLoadedRate(AcctSeed__Cost_Rates__c ac) {
    
        Decimal fullyLoadedRate = 0.00;
        if(ac.Rate_Type__c == 'Non-SCA Testing') {
            if(ac.Per_Test_Cost__c != NULL ){
                fullyLoadedRate = ac.Per_Test_Cost__c;
            }else if(ac.AcctSeed__Hourly_Cost__c != NULL){
                fullyLoadedRate = ac.AcctSeed__Hourly_Cost__c;
            }
        //} else if (ac.Rate_Type__c == 'Non-SCA Translation (Per Word)') {
        } else if (ac.Rate_Type__c == 'Non-SCA Translation W/O Editing (Per Word)' || ac.Rate_Type__c == 'Non-SCA Translation Editing Only (Per Word)' || ac.Rate_Type__c == 'Non-SCA Translation + Editing (Per Word)') {
            fullyLoadedRate = ac.Per_Word_Cost__c;
        } else if (ac.Rate_Type__c == 'Non-SCA Translation (Per Hour)') {
            fullyLoadedRate = ac.AcctSeed__Hourly_Cost__c;
        } else if(ac.Rate_Type__c == 'Non-SCA Translation (FFP)') {
            fullyLoadedRate = ac.Per_FFP_Cost__c;
        } else {
            if(ac.H_W_Rate__c != null)
                fullyLoadedRate = ac.H_W_Rate__c;
            
            if(ac.HOL_Rate__c != null)
                fullyLoadedRate += ac.HOL_Rate__c;
            
            if(ac.VAC_Rate__c != null)
                fullyLoadedRate += ac.VAC_Rate__c;
            
            if(ac.AcctSeed__Hourly_Cost__c != null)
                fullyLoadedRate += ac.AcctSeed__Hourly_Cost__c;
        }
        System.debug('fullyLoadedRate::::'+fullyLoadedRate);
        return fullyLoadedRate;
    }
    
    // To defaultly populate the Department__c field for the Contact on First CR creation
    public Static Map<String, String> getProjClassiMap() {
        return new Map<String, String>{'ADM' => '', 'CD' => 'Curriculum Development', 'CD0CLP' => 'Curriculum Development', 'CD0DLI' => 'Curriculum Development', 'CD0MAR' => 'Curriculum Development', 'CD0NSW' => 'Curriculum Development', 'CD0OTH' => 'Curriculum Development', 'CD0SCM' => 'Curriculum Development',
         'CD0SLT' => 'Curriculum Development', 'OF0DBL' => 'Language Training', 'OF0DCA' => 'Language Training', 'OF0FSI' => 'Language Training', 'OF0KSA' => 'EFL', 'OF0MTT' => 'Language Training', 'OF0MTT0DLI' => 'Language Training', 'OF0MTT0HUB' => 'Language Training', 'OF0MTT0PS' => 'Language Training', 'OF0MTT0RTT' => 'Language Training',
          'OF0SCM' => 'Language Training', 'OF0TANDI' => 'Translation & Interpretation', 'OF0TST' => 'Testing', 'OF0UAE' => 'EFL', 'ON0ARL0AFP' => 'Language Training', 'ON0ARL0CLP' => 'Language Training', 'ON0LT' => 'Language Training', 'ON0LT0ARL' => 'Language Training' , 'ON0LT0HRN' => 'Language Training',
           'ON0LT0LTM' => 'Language Training', 'ON0TANDI' => 'Translation & Interpretation', 'ON0TST' => 'Testing', 'ON0LNG' => 'Linguist Support'};
    }
    
    //To update the Parent CR Status to Inactive on Approving the new Cost Rate Version
    public static void updatePriorCRStatus(List<AcctSeed__Cost_Rates__c> modifiedCR, Set<Id> priorIds) {
        List<AcctSeed__Cost_Rates__c> crToUpdate = new List<AcctSeed__Cost_Rates__c>();
        Map<Id,AcctSeed__Cost_Rates__c> priorCRIdNewCRRecMap = new Map<Id,AcctSeed__Cost_Rates__c>();
        for(AcctSeed__Cost_Rates__c newCr : modifiedCR) {
            priorCRIdNewCRRecMap.put(newCr.Prior_Version__c, newCr);
        }
        for(AcctSeed__Cost_Rates__c cr : (List<AcctSeed__Cost_Rates__c>)SObjectQueryService.SObjectQuery('AcctSeed__Cost_Rates__c', priorIds, '')) {
            if(priorCRIdNewCRRecMap.containskey(cr.Id) && priorCRIdNewCRRecMap.get(cr.Id).Effective_Date__c != null) {
                if(cr.Status__c != 'Inactive' ) {
                    cr.Expiration_Date__c = priorCRIdNewCRRecMap.get(cr.Id).Effective_Date__c - 1;
                    // W-007646 -  InActive the LCR when Expiration Date less than Today
                    if(cr.Expiration_Date__c < System.Today()) {
                        cr.Status__c = 'Inactive';
                    }
                    crToUpdate.add(cr);
                }
            }
        }
        System.debug('crToUpdate:::::'+crToUpdate);
        if(crToUpdate.size() > 0) {
            update crToUpdate;
        }
    }
    
    /******
        Added By HL
        Only System Admin, HR & Payroll users should have access to Labor Cost Rate records related to DLS Staff record type Contact records
    ******/
    public static void userPermissionToEditStaffLCR(List<AcctSeed__Cost_Rates__c> newList, Map<Id,Contact> contactMap) {
        
        if(contactMap.size() > 0){
        
            Boolean hasCustomPermission = FeatureManagement.checkPermission('Access_Staff_LCR');
            System.debug('hasCustomPermission===='+hasCustomPermission);
            System.debug('contactMap========='+contactMap+'contactMap SIZE======='+contactMap.size());
            
            if(contactMap.size() > 0){
                for(AcctSeed__Cost_Rates__c c : newList){
                
                    if(contactMap.containsKey(c.Contact__c) && ! hasCustomPermission){
                        c.addError('Only HR, Payroll and System Admin users should have access to Labor Cost Rate records related to DLS Staff record type Contact records');
                    }
                }
            }
        }
    }
    
    /**********
        - Added by HL
        - Work Item : W-001739
        - Custom Permission : "Prevent_LCR_Edit" : This custom permission is assigned to "System Admin, HR & Payroll" profiles.
            Only HR, Payroll and System Admin users have access to Edit Status of Labor Cost Rate records
        To Prevent Labor Cost Rate edit on Active Contact Assignments once time has been entered
        ******************/
        
    public static void preventLCREdit(List<AcctSeed__Cost_Rates__c> newList,Map<Id,AcctSeed__Cost_Rates__c> oldMap){
    
        Map<Id,AcctSeed__Cost_Rates__c> costIdAndRec = new Map<Id, AcctSeed__Cost_Rates__c >();
        
        for(AcctSeed__Cost_Rates__c c : newList){
        
            //System.debug('COST RATE==='+c.Status__c);
            costIdAndRec.put(c.Id, c);
        }
        System.debug('costIdAndRec========='+costIdAndRec+'costIdAndRec SIZE======='+costIdAndRec.size());
        
        if(costIdAndRec.size() > 0){
        
            Map<Id, List<AcctSeed__Time_Card_Day__c>> costRateIdAndDays = new Map<Id, List<AcctSeed__Time_Card_Day__c>>();
            
            Boolean hasCustomPermission = FeatureManagement.checkPermission('Prevent_LCR_Edit');
            System.debug('hasCustomPermission===='+hasCustomPermission);
                    
           
            for(AcctSeed__Time_Card_Line__c l : [SELECT Id, Labor_Cost_Rate__c, (SELECT Id FROM AcctSeed__Time_Card_Days__r) 
                                                  FROM AcctSeed__Time_Card_Line__c 
                                                  WHERE Labor_Cost_Rate__c IN :costIdAndRec.keySet()]){
            
                if(l.AcctSeed__Time_Card_Days__r.size() > 0){
                
                    if(!costRateIdAndDays.containsKey(l.Labor_Cost_Rate__c)){
                    
                        costRateIdAndDays.put(l.Labor_Cost_Rate__c, new List<AcctSeed__Time_Card_Day__c>());
                    }
                    costRateIdAndDays.get(l.Labor_Cost_Rate__c).addAll(l.AcctSeed__Time_Card_Days__r);
                }
            }
            System.debug('costRateIdAndDays=='+costRateIdAndDays);
            
            for(AcctSeed__Cost_Rates__c c : newList){
            
                AcctSeed__Cost_Rates__c newLCR = costIdAndRec.get(c.Id);
                System.debug('newLCR ===='+newLCR.Status__c);
                AcctSeed__Cost_Rates__c oldLCR = oldMap.get(c.Id);
                System.debug('oldLCR===='+oldLCR.Status__c);
                
                // In production, there exist no direct relationship between TCD and LCR. So that below code is commented. 
                // And these functionality will move in to production if once all the community changes are done and moved it in to production 
                /*
                if(c.Time_Card_Days__r.size() > 0 ){
                    System.debug('c.Time_Card_Days__r======'+c.Time_Card_Days__r);
                    if(newLCR.AcctSeed__Hourly_Cost__c != oldLCR.AcctSeed__Hourly_Cost__c || newLCR.Annual_Salary_Cost__c != oldLCR.Annual_Salary_Cost__c || newLCR.Fixed_Cost__c != oldLCR.Fixed_Cost__c || newLCR.H_W_Rate__c != oldLCR.H_W_Rate__c ||
                        newLCR.HOL_Rate__c != oldLCR.HOL_Rate__c || newLCR.Per_FFP_Cost__c != oldLCR.Per_FFP_Cost__c || newLCR.Per_Test_Cost__c != oldLCR.Per_Test_Cost__c ||
                        newLCR.Per_Word_Cost__c != oldLCR.Per_Word_Cost__c || newLCR.Salary_Cost_Per_Hour__c != oldLCR.Salary_Cost_Per_Hour__c || newLCR.Semi_Monthly_Salary_Cost__c != oldLCR.Semi_Monthly_Salary_Cost__c ||
                        newLCR.VAC_Rate__c != oldLCR.VAC_Rate__c || newLCR.Rate_Type__c != oldLCR.Rate_Type__c){
                        
                        System.debug('TESTING');
                        newLCR.addError(' Currency and Rate Type of Labor Cost Rate records cannot be modified by any user');   
                    }
                    if(newLCR.Status__c != oldLCR.Status__c && !hasCustomPermission){
                        
                        newLCR.addError('Only HR, Payroll and System Admin users have access to Edit Status of Labor Cost Rate records');    
                    }
                }else 
                
                */
                
                if(costRateIdAndDays.containsKey(c.Id)){
                                    
                    if(costRateIdAndDays.get(c.Id).size() > 0){
                    
                        if(newLCR.AcctSeed__Hourly_Cost__c != oldLCR.AcctSeed__Hourly_Cost__c || newLCR.Annual_Salary_Cost__c != oldLCR.Annual_Salary_Cost__c || newLCR.Fixed_Cost__c != oldLCR.Fixed_Cost__c || newLCR.H_W_Rate__c != oldLCR.H_W_Rate__c ||
                            newLCR.HOL_Rate__c != oldLCR.HOL_Rate__c || newLCR.Per_FFP_Cost__c != oldLCR.Per_FFP_Cost__c || newLCR.Per_Test_Cost__c != oldLCR.Per_Test_Cost__c ||
                            newLCR.Per_Word_Cost__c != oldLCR.Per_Word_Cost__c || newLCR.Salary_Cost_Per_Hour__c != oldLCR.Salary_Cost_Per_Hour__c || newLCR.Semi_Monthly_Salary_Cost__c != oldLCR.Semi_Monthly_Salary_Cost__c ||
                            newLCR.VAC_Rate__c != oldLCR.VAC_Rate__c || newLCR.Rate_Type__c != oldLCR.Rate_Type__c){
                            
                            newLCR.addError(' Currency and Rate Type of Labor Cost Rate records cannot be modified by any user');   
                        }
                        if(newLCR.Status__c != oldLCR.Status__c && !hasCustomPermission){
                            
                            newLCR.addError('Only HR, Payroll and System Admin users have access to Edit Status of Labor Cost Rate records');    
                        }
                    }
                }
            }  
        }
    }
    
    /*******
    * To update the merit increase for a specific rate type for the current year
    
    ********/
    
    public static void updateMeritIncreaseCRMaster(List<AcctSeed__Cost_Rates__c> nonSCALTCR) {
    
        System.debug('nonSCALTCR =============================');
        List<Labor_Cost_Rate_Master__c> masterToUpd = new List<Labor_Cost_Rate_Master__c>();
        Map<String, Decimal> rateTypeAndValueMap = new Map<String, Decimal>();
        
        Set<Id> costRateIds = new Set<Id>();
        List<AcctSeed__Cost_Rates__c> allOtherCostRates = new List<AcctSeed__Cost_Rates__c>();
        
        for (AcctSeed__Cost_Rates__c cr : nonSCALTCR) {
            //System.debug('cr.Prior_Hourly_Rate__c==============='+cr.Prior_Hourly_Rate__c);
            if((cr.Rate_Type__c == 'LT with Prep' || cr.Rate_Type__c == 'LT without Prep') && cr.AcctSeed__Hourly_Cost__c != NULL && cr.Prior_Hourly_Rate__c != NULL) {    // Non-SCA LT modified into LT
                Decimal meritInc = cr.AcctSeed__Hourly_Cost__c - cr.Prior_Hourly_Rate__c;
                //System.debug('meritInc1================='+meritInc);
                
                if(meritInc > 0){
                
                    //System.debug('meritInc2================='+meritInc);
                    if(!rateTypeAndValueMap.containskey(cr.Rate_Type__c)) {
                        rateTypeAndValueMap.put(cr.Rate_Type__c, meritInc);
                    } else {
                        rateTypeAndValueMap.put(cr.Rate_Type__c, rateTypeAndValueMap.get(cr.Rate_Type__c) + meritInc);
                    }  
                    if(cr.Effective_Date__c.month() == 1){
                        costRateIds.add(cr.Id);
                    }
                }       
            }
        }
                
        if(costRateIds.size() > 0){
        
            List<AcctSeed__Cost_Rates__c> allCostRates = [SELECT Id, Effective_Date__c FROM AcctSeed__Cost_Rates__c WHERE Status__c = 'Approved' AND Prior_Version__c != NULL AND (Rate_Type__c = 'LT with Prep' OR Rate_Type__c = 'LT without Prep')  AND Effective_Date__c != NULL AND Id NOT IN :costRateIds];    // Non-SCA LT modified into LT
        
            if(allCostRates.size() > 0 ){
            
                for(AcctSeed__Cost_Rates__c c : allCostRates){
                
                    if(c.Effective_Date__c.month() == 1){
                        allOtherCostRates.add(c);
                    }
                }
            }
        }
        
        
        if( rateTypeAndValueMap.size() > 0 ) {
            for(Labor_Cost_Rate_Master__c lcrm : [SELECT Id,Name,Rate_Type__c,YTD_Merit_Increases__c FROM Labor_Cost_Rate_Master__c WHERE Rate_Type__c IN: rateTypeAndValueMap.keyset()]) {
                Decimal newIncVal = 0;
                if(rateTypeAndValueMap.get(lcrm.Rate_Type__c) != null) {
                    newIncVal += rateTypeAndValueMap.get(lcrm.Rate_Type__c);
                }
                if(lcrm.YTD_Merit_Increases__c != null) {
                    newIncVal += lcrm.YTD_Merit_Increases__c;
                }
                
                if(costRateIds.size() > 0 && allOtherCostRates.size() == 0){
                    lcrm.YTD_Merit_Increases__c = rateTypeAndValueMap.get(lcrm.Rate_Type__c);
                }else{
                    lcrm.YTD_Merit_Increases__c = newIncVal;
                }
                masterToUpd.add(lcrm);
            }
            System.debug('masterToUpd:::::'+masterToUpd);
            if( masterToUpd.size() > 0 ) {
                update masterToUpd;
            }
        }
    }
      /*******
     * To update ContactAssignment with costrate for Pay Rate Modification Process
     
     ********/
    public static void updateCAwithLCRforPayRateModification(List<AcctSeed__Cost_Rates__c> nonSCALTCDCR) {
        
        Map<String,Date> conIdwithPriorLCRMap = new Map<String,Date>(); 
        Map<Id,AcctSeed__Cost_Rates__c> priorCRIdAndnewCRRec = new Map<Id,AcctSeed__Cost_Rates__c>();
        
        List<Contact_Assignments__c> updateCAwithEndDate  = new List<Contact_Assignments__c>();
        List<Contact_Assignments__c> insertCAwithLCR  = new  List<Contact_Assignments__c>();
        set<Id> newLCRIds  = new set<Id>();
        set<Id> oldLCRIds  = new set<Id>();
        set<Id> excludeCASet = new set<Id>();
        set<Id> excludeOldCAByProjectIdSet = new set<Id>();
        Set<Id> crIdForConUpdate = new Set<Id>();
        
        Set<String> staffRelatedRTType = new Set<String>{'FT Hourly & Benefits', 'PT Hourly (OH & G&A)', 'FT Salary & Benefits','International Salary'};

        //To update the Event's LCR 
        Map<Id, Date> priorLCRIdAndnewEffectiveDate = new Map<Id, Date>();
        List<Events__c> evntsToUpdate = new List<Events__c>();
        List<Contact> updateStaffRelCons = new List<Contact>();

        
        for(AcctSeed__Cost_Rates__c cr : nonSCALTCDCR) {
            
            if(cr.Prior_Version__c != null) {
                
                if(!conIdwithPriorLCRMap.containsKey(cr.Contact__c+'-'+cr.Prior_Version__c)){
                    conIdwithPriorLCRMap.put(cr.Contact__c+'-'+cr.Prior_Version__c,cr.Effective_Date__c);
                    priorCRIdAndnewCRRec.put(cr.Prior_Version__c, cr);
                    priorLCRIdAndnewEffectiveDate.put(cr.Prior_Version__c,cr.Effective_Date__c);
                }  
                newLCRIds.add(cr.Id);
                oldLCRIds.add(cr.Prior_Version__c);
                
                if(staffRelatedRTType.contains(cr.Rate_Type__c)){
                    crIdForConUpdate.add(cr.Id);
                }
            }
        }
        
        
        if(crIdForConUpdate.size() > 0){
            // W-008034 - Request to Update Staff PRM Logic
            //  When a PRM is triggered for Labor Cost Rates where Contact Record type = DLS Employee, we would like the system to update the Supervisor and Home Department values on the user Contact record on the day of the Labor Cost Rate Effective date.
            updateStaffRelCons = updateConWithDeptAndSups(newLCRIds);
        }
        
        // to exclude new Contact Assignment Created record in Insertion if new LCR have already Contact Assignment record and exclude old CA related Projects in new CA Created.
        //List<AcctSeed__Cost_Rates__c> costRateListToExcludenewCA = [Select Id,Contact__c,(SELECT Id,Project__c FROM Contact_Assignments__r) FROM AcctSeed__Cost_Rates__c WHERE Id IN :newLCRIds];
        //List<Contact_Assignments__c> costRateListToExcludenewCA = [Select Id,Project__c FROM Contact_Assignments__c WHERE (Rate_Card_Rate__c IN :newLCRIds OR  Drafted_Labor_Cost_Rate__c IN :newLCRIds)];
        
        //if(costRateListToExcludenewCA.size() > 0){
        if(newLCRIds != null && newLCRIds.size() > 0) {
                    
            for(Contact_Assignments__c ca : [Select Id,Project__c FROM Contact_Assignments__c WHERE (Rate_Card_Rate__c IN :newLCRIds OR  Drafted_Labor_Cost_Rate__c IN :newLCRIds)]){
                excludeCASet.add(ca.Id);
                
                if(ca.Project__c != null){
                    excludeOldCAByProjectIdSet.add(ca.Project__c);
                }
            }
        }
        //}

        //List<Contact_Assignments__c> costRateListToExcludeOldCA = [Select Id FROM Contact_Assignments__c WHERE Project__c IN :excludeOldCAByProjectIdSet AND 
                                                                  // (Rate_Card_Rate__c IN :oldLCRIds OR  Drafted_Labor_Cost_Rate__c IN :oldLCRIds)];
        //if(costRateListToExcludeOldCA.size() > 0){  
        if( excludeOldCAByProjectIdSet.size() > 0 && oldLCRIds.size() > 0 ) {
            for(Contact_Assignments__c caRecord : [Select Id FROM Contact_Assignments__c WHERE Project__c IN :excludeOldCAByProjectIdSet AND 
                                                                   (Rate_Card_Rate__c IN :oldLCRIds OR  Drafted_Labor_Cost_Rate__c IN :oldLCRIds)]) {
                excludeCASet.add(caRecord.Id);
            }
        }
        //}
        
        Set<Id> crIds = priorCRIdAndnewCRRec.keySet();
        String filterCondition = ' WHERE (RecordType.DeveloperName = \'Instructor\' OR RecordType.DeveloperName = \'Staff\') AND Status__c IN (\'Planned\',\'Active\') ';
        //List<Contact_Assignments__c> caInsList =  ContactAssignmentService.getContactassignmentByCRId(filterCondition,',Rate_Card_Rate__r.Contact__c,Rate_Card_Rate__r.Status__c,RecordType.DeveloperName',crIds,excludeCASet);
        
        if(crIds.size() > 0) {
            for(Contact_Assignments__c caRecord : ContactAssignmentService.getContactassignmentByCRId(filterCondition,',Rate_Card_Rate__r.Contact__c,Rate_Card_Rate__r.Status__c,RecordType.DeveloperName',crIds,excludeCASet)) {
                
                String costRateId = '';
                Date newCREffectiveDate = null;
                if(caRecord.Rate_Card_Rate__c != null || caRecord.Drafted_Labor_Cost_Rate__c != null) {
                    costRateId = (caRecord.Rate_Card_Rate__c != null ? caRecord.Rate_Card_Rate__c : (caRecord.Drafted_Labor_Cost_Rate__c != null ? caRecord.Drafted_Labor_Cost_Rate__c : ''));
                    newCREffectiveDate = conIdwithPriorLCRMap.get(caRecord.Candidate_Name__c+'-'+costRateId) != null ? conIdwithPriorLCRMap.get(caRecord.Candidate_Name__c+'-'+costRateId) : null; // optimized the effective date variable
                
                    if(caRecord.RecordType.DeveloperName == 'Instructor') {
                        if(caRecord.End_Date__c != newCREffectiveDate && caRecord.End_Date__c > newCREffectiveDate && caRecord.Start_Date__c < newCREffectiveDate) { 
                             
                            Contact_Assignments__c newCA = new Contact_Assignments__c();
                            newCA = caRecord.clone(false, true, false, false);
                            newCA.Rate_Card_Rate__c = null;
                            newCA.Drafted_Labor_Cost_Rate__c = null; 
                            newCA.Start_Date__c = newCREffectiveDate;
                            newCA.Moodle_Sync_Status__c = null;
                            
                            // To Make the Instructor status as Planned for the Future Effective Date Cost Rate on  July 28, 2020
                            if(newCREffectiveDate> System.Today()) {
                                newCA.Status__c = 'Planned';
                            }
                            
                            if(priorCRIdAndnewCRRec.containsKey(costRateId)) {
                                
                                if(priorCRIdAndnewCRRec.get(costRateId).Status__c == 'Approved'){
                                    newCA.Rate_Card_Rate__c = priorCRIdAndnewCRRec.get(costRateId).Id;
                                }else if(priorCRIdAndnewCRRec.get(costRateId).Status__c == 'Draft' || priorCRIdAndnewCRRec.get(costRateId).Status__c == 'Submitted for Approval') {
                                    newCA.Drafted_Labor_Cost_Rate__c  = priorCRIdAndnewCRRec.get(costRateId).Id;
                                }
                            }
                            insertCAwithLCR.add(newCA);
                            caRecord.End_Date__c = (newCREffectiveDate).addDays(-1);
                        }
                        if(caRecord.Start_Date__c >= newCREffectiveDate) { // Added = in the start Date condition to include the CA starting on the same effective date with old CR
                            
                            if(priorCRIdAndnewCRRec.containsKey(costRateId)){
                           
                                if(priorCRIdAndnewCRRec.get(costRateId).Status__c == 'Approved'){
                                    caRecord.Rate_Card_Rate__c = priorCRIdAndnewCRRec.get(costRateId).Id;
                                }else if(priorCRIdAndnewCRRec.get(costRateId).Status__c == 'Draft' || priorCRIdAndnewCRRec.get(costRateId).Status__c == 'Submitted for Approval') {
                                    caRecord.Drafted_Labor_Cost_Rate__c  = priorCRIdAndnewCRRec.get(costRateId).Id;
                                }
                            }
                        } else if(newCREffectiveDate <=  System.today()){
                            caRecord.Status__c = 'Ended';
                        }
                        system.debug(' caRecord.Status__c'+caRecord.Status__c);
                        updateCAwithEndDate.add(caRecord);
                    
                      // To update the Staff Contact Assignment Rate Card Rate when new Rate type is created
                    } else if(caRecord.RecordType.DeveloperName == 'Staff') {
                        if(priorCRIdAndnewCRRec.containsKey(costRateId)) {
                            //#W-007674 -  Enable Cost Rate Auto-Deactivation Process for Additional Rate Types

                            if(newCREffectiveDate <=  System.today()){
                                if(priorCRIdAndnewCRRec.get(costRateId).Status__c == 'Approved'){
                                    caRecord.Rate_Card_Rate__c = priorCRIdAndnewCRRec.get(costRateId).Id;
                                }else if(priorCRIdAndnewCRRec.get(costRateId).Status__c == 'Draft' || priorCRIdAndnewCRRec.get(costRateId).Status__c == 'Submitted for Approval') {
                                    caRecord.Drafted_Labor_Cost_Rate__c  = priorCRIdAndnewCRRec.get(costRateId).Id;
                                }
                                updateCAwithEndDate.add(caRecord);
                            }
                        }                   
                    }
                }           
            }
        }
        system.debug('insertCAwithLCR'+insertCAwithLCR);
        system.debug('updateCAwithEndDate'+updateCAwithEndDate);
        
        if(insertCAwithLCR.size() > 0) {
            insert insertCAwithLCR;
        }
        
        if(updateCAwithEndDate.size() > 0) {
            update updateCAwithEndDate;
        }
        
        if(updateStaffRelCons.size() > 0){
            update updateStaffRelCons;
        }
        
        // To update the events when Pay Rate Modification is done for a Contact
        if(priorLCRIdAndnewEffectiveDate.size() > 0) {
            for(Events__c ev : [SELECT Id,Name,Date__c,Labor_Cost_Rate__c,Instructor__c FROM Events__c WHERE Labor_Cost_Rate__c IN : priorLCRIdAndnewEffectiveDate.keyset() AND Status__c IN ('Draft','Scheduled') AND Date__c >=: priorLCRIdAndnewEffectiveDate.values()]) {
                if(priorLCRIdAndnewEffectiveDate.containskey(ev.Labor_Cost_Rate__c) && priorLCRIdAndnewEffectiveDate.get(ev.Labor_Cost_Rate__c) != null && ev.Date__c >= priorLCRIdAndnewEffectiveDate.get(ev.Labor_Cost_Rate__c)) {
                    System.debug('before :: ev.Labor_Cost_Rate__c:::'+ev.Labor_Cost_Rate__c);
                    ev.Labor_Cost_Rate__c =  priorCRIdAndnewCRRec.get(ev.Labor_Cost_Rate__c).Id;
                    System.debug('after :: ev.Labor_Cost_Rate__c:::'+ev.Labor_Cost_Rate__c);
                    evntsToUpdate.add(ev);
                }
            }
            
            if( evntsToUpdate.size() > 0 ) {
                System.debug('evntsToUpdate::size::'+evntsToUpdate.size());
                System.debug('evntsToUpdate::::'+evntsToUpdate);
                update evntsToUpdate;
            }
        }
    }
    public static List<Contact> updateConWithDeptAndSups(Set<Id> lcrIds){
        // W-008034 - Request to Update Staff PRM Logic
        //  When a PRM is triggered for Labor Cost Rates where Contact Record type = DLS Employee, we would like the system to update the Supervisor and Home Department values on the user Contact record on the day of the Labor Cost Rate Effective date.
        List<Contact> updateStaffRelCons = new List<Contact>(); 
        
        for(AcctSeed__Cost_Rates__c lcr : [SELECT Id,Contact__c,New_Contact_Job_Title__c,Rate_Type__c,New_Supervisor_Id__c,Contact__r.Home_Dept__c,Contact__r.Supervisor_Name__c,New_Department_Name__c,Effective_Date__c FROM AcctSeed__Cost_Rates__c WHERE Contact__r.RecordType.DeveloperName = 'DLS_Employee' AND Id IN :lcrIds AND Effective_Date__c <= :System.today()]){
            Contact con = new Contact();    
            con.Id = lcr.Contact__c;
            
            if(lcr.New_Contact_Job_Title__c != null){
                con.Title = lcr.New_Contact_Job_Title__c;
            }
            
            if(lcr.Effective_Date__c != null){
                con.EE_Pay_Status_Eff_Date__c = lcr.Effective_Date__c;
            }
            
            if(lcr.New_Department_Name__c != null){
                con.Home_Dept__c = lcr.New_Department_Name__c;
            }
            if(lcr.New_Supervisor_Id__c != null){
                con.Supervisor_Name__c = lcr.New_Supervisor_Id__c;
            }
            
            if(lcr.Rate_Type__c == 'FT Salary & Benefits'){
                con.EE_Pay_Status__c = 'Salary';
            }else if(lcr.Rate_Type__c == 'FT Hourly & Benefits'){
                con.EE_Pay_Status__c = 'Hourly - FT';
            }else if(lcr.Rate_Type__c == 'PT Hourly (OH & G&A)'){
                con.EE_Pay_Status__c = 'Hourly - PT';
            }
            updateStaffRelCons.add(con);
        }
        return updateStaffRelCons;
    }
}