/*Created by SivaPrasanth on Dec 20 2019*/
public class CostRateCreation_Ctrl {
    
    //For sending Cost Rate records for approval process
    public static Boolean isFromCR = false;
    
    // Method to  get Existing cost rate information for 'LT with Prep','LT without Prep' , 'Non-SCA CD','DLI-21 SCA CD','DLI-21 SCA LT','DLI-21 SCA MTT these rate type.
    @AuraEnabled
    public static MultiplePayRateExistingCRDetails getExistingCRInfo(Id contactId, String defaultCR, String projectId, String parentObjName, String oppId){
        
        Map<String, ContactAssignmentDomain.MultiplePayRateCostRate> rateTypeAndMulitiPayRate = new Map<String, ContactAssignmentDomain.MultiplePayRateCostRate>();
        Map<String, AcctSeed__Cost_Rates__c> cRRateTypeAndCR = new Map<String, AcctSeed__Cost_Rates__c>();
   		Map<String,String> modifyLTPrepRTLabel = new Map<String,String>{'LT with Prep' => 'LT with Billable Prep','LT without Prep' => 'LT without Billable Prep'};

        
        List<AcctSeed__Cost_Rates__c> crs = new List<AcctSeed__Cost_Rates__c>(); 
        
        Set<String> crRateTypeSet = new Set<String>{'LT with Prep','LT without Prep','DLI-W LT','Non-SCA CD','DLI-21 SCA CD','DLI-21 SCA LT','DLI-21 SCA MTT','DODA PS','DLI-W PS - Group 3','DLI-W PS - Group 4'};
        Set<String> crStatus = new Set<String>{'Approved','Draft','Submitted for Approval'};
        Set<String> dliCDSet = new Set<String>{'DLI-21 SCA CD'};
        Set<String> dliPSgrpCDSet = new Set<String>{'DLI-W PS - Group 3','DLI-W PS - Group 4'};
        Set<String> hourlyRTSet = new set<String>{'FT Hourly & Benefits','PT Hourly (OH & G&A)'};
            
        Boolean LtWithOrWithoutBillablePrepExist = false;
        Boolean dlsGrpCRExist = false;
        Boolean proOppLanguExist = false;
        Boolean isActualLT = false;
        
        Integer cRcount = 0;
        
        Decimal fulLoadAmt = 0;
        Decimal DLIGrpHC = 0.00;

        MultiplePayRateExistingCRDetails multipayCR = new MultiplePayRateExistingCRDetails();
        
        
        if(defaultCR == 'LT with Billable Prep'){
            defaultCR = 'LT with Prep';
            LtWithOrWithoutBillablePrepExist = true;
        }else if(defaultCR == 'LT without Billable Prep'){
            defaultCR = 'LT without Prep';
            LtWithOrWithoutBillablePrepExist = true;
        }        

        for(AcctSeed__Cost_Rates__c cr : CostRateService.getCostrateRec(' WHERE Contact__c = \''+ contactId + '\'  Order By Effective_Date__c Desc', '')) {
            if(crStatus.contains(cr.Status__c) && (cr.Rate_Type__c == defaultCR || (cr.Rate_Type__c == 'FT Salary & Benefits' && cr.Exempt_Status__c == 'Exempt') || hourlyRTSet.contains(cr.Rate_Type__c))) { 
                crs.add(cr);
                
                if(LtWithOrWithoutBillablePrepExist == false && modifyLTPrepRTLabel.containsKey(cr.Rate_Type__c) && defaultCR == cr.Rate_Type__c) {
                    LtWithOrWithoutBillablePrepExist = true;
                    isActualLT = true;
                }
            }
            
            cRcount = cRcount + 1;
        }
        
        // get Project / Opportunity related language rate for DLI-W PS - Group 3 and 4
        if((projectId != null || oppId != null) && (defaultCR == 'DLI-W PS - Group 3' || defaultCR == 'DLI-W PS - Group 4')){
            String langId = null;
            List<Contact_Assignments__c> CAStuds = new  List<Contact_Assignments__c>();
            System.debug('CAStuds::::'+CAStuds);
            if(parentObjName == 'AcctSeed__Project__c'){
                CAStuds = [SELECT Id FROM Contact_Assignments__c WHERE Project__c = :projectId AND RecordType.DeveloperName = 'Student' AND Status__c IN ('Active','Planned')];

                List<AcctSeed__Project__c> pros = [SELECT Id,Language__r.DLI_PS_Rate__c,Language__r.DLI_PS_Additional_Stud_Rate__c FROM AcctSeed__Project__c WHERE Id = :projectId AND Language__c != null];
                
                if(pros.size() > 0){
                    proOppLanguExist = true;
                    
                    if(pros[0].Language__r.DLI_PS_Rate__c != null){
                        DLIGrpHC = pros[0].Language__r.DLI_PS_Rate__c;
                        
                        if(CAStuds.size() >= 3){
                            if(pros[0].Language__r.DLI_PS_Additional_Stud_Rate__c != null){
                                DLIGrpHC += pros[0].Language__r.DLI_PS_Additional_Stud_Rate__c;
                            }
                        }
                    }
                }
            }else if(parentObjName == 'Opportunity'){
                CAStuds = [SELECT Id FROM Contact_Assignments__c WHERE Opportunity_Name__c = :oppId AND RecordType.DeveloperName = 'Student' AND Status__c IN ('Active','Planned')];
                List<Opportunity> oops = [SELECT Id,Language_LU__r.DLI_PS_Rate__c,Language_LU__r.DLI_PS_Additional_Stud_Rate__c FROM Opportunity WHERE Id = :oppId AND Language_LU__c != null];
                
                if(oops.size() > 0){
                    proOppLanguExist = true;
                    if(oops[0].Language_LU__r.DLI_PS_Rate__c != null){
                        DLIGrpHC = oops[0].Language_LU__r.DLI_PS_Rate__c;
                        if(CAStuds.size() >= 3){
                            if(oops[0].Language_LU__r.DLI_PS_Additional_Stud_Rate__c != null){
                                DLIGrpHC += oops[0].Language_LU__r.DLI_PS_Additional_Stud_Rate__c;
                                System.debug('Inside oops DLI_PS_Additional_Stud_Rate__c');
                            }
                        }
                    }
                }
            }
        }
        
        if(crRateTypeSet.contains(defaultCR)){
            for(AcctSeed__Cost_Rates__c c : crs){
                
                if(!cRRateTypeAndCR.containsKey(c.Rate_Type__c)){
                    Boolean isValidCR = false;
                    
                    if(!dliPSgrpCDSet.contains(c.Rate_Type__c)){
                        // if project default cost rate is LT with Prep / LT without Prep, get the LT with  / LT without  Prep costrate name related CR
                        if(isActualLT == true){
                            if((c.Cost_Rate_Name__c).contains(c.Rate_Type__c)){
                                isValidCR = true;
                            }
                        }else{
                            isValidCR = true;
                        }
                    }else if(dliPSgrpCDSet.contains(c.Rate_Type__c) && DLIGrpHC == c.AcctSeed__Hourly_Cost__c){
                        dlsGrpCRExist = true;
                        isValidCR = true;
                    }
                    if(isValidCR == true){
                        cRRateTypeAndCR.put(c.Rate_Type__c, c);
                    }
                }
            }
            
            // DLI-W LT  or LT with Prep or LT withput Prep cost rate lick leave calculation
            if(defaultCR == 'DLI-W LT' || defaultCR == 'LT with Prep' || defaultCR == 'LT without Prep'){
                ContactAssignmentDomain.MultiplePayRateCostRate fullyLoadedRates = new ContactAssignmentDomain.MultiplePayRateCostRate();
                fullyLoadedRates.fullyLoadedAmt = Decimal.valueOf(Label.LT_Sick_Leave_Rate);
                rateTypeAndMulitiPayRate.put('fullyLoadedAmt', fullyLoadedRates);
            }
            
            if(dliCDSet.contains(defaultCR)){
                List<Labor_Cost_Rate_Master__c> lcrms = [SELECT Id, H_W_Rate__c,Hourly_Cost__c,HOL_Rate__c, VAC_Rate__c FROM Labor_Cost_Rate_Master__c WHERE Rate_Type__c = :defaultCR];
                
                if(lcrms.size() > 0){
                    
                    fulLoadAmt += (lcrms[0].H_W_Rate__c != null ? lcrms[0].H_W_Rate__c : 0);
                    fulLoadAmt += (lcrms[0].HOL_Rate__c != null ? lcrms[0].HOL_Rate__c : 0);
                    fulLoadAmt += (lcrms[0].VAC_Rate__c != null? lcrms[0].VAC_Rate__c : 0);
                    
                    ContactAssignmentDomain.MultiplePayRateCostRate fullyLoadedRate = new ContactAssignmentDomain.MultiplePayRateCostRate();
                    fullyLoadedRate.fullyLoadedAmt = fulLoadAmt;
                    rateTypeAndMulitiPayRate.put('fullyLoadedAmt', fullyLoadedRate);
                    
                    ContactAssignmentDomain.MultiplePayRateCostRate hourlyCR = new ContactAssignmentDomain.MultiplePayRateCostRate();
                    hourlyCR.lcrmHourlyCost = lcrms[0].Hourly_Cost__c;
                    rateTypeAndMulitiPayRate.put('lcrmHourlyCost', hourlyCR);
                }
            }
            
            if(cRRateTypeAndCR != NULL && cRRateTypeAndCR.size() > 0){
                
                for(AcctSeed__Cost_Rates__c c : cRRateTypeAndCR.values()){       
                    ContactAssignmentDomain.MultiplePayRateCostRate multiPayRate = new ContactAssignmentDomain.MultiplePayRateCostRate();

                    if(crRateTypeSet.contains(c.Rate_Type__c)) {
                        Boolean isValidCR = true;
                        
                        System.debug(':::LtWithOrWithoutBillablePrepExist'+LtWithOrWithoutBillablePrepExist);
                        // if project default cost rate is LT with Billable / LT without Billable Prep, assign the LT with Billable / LT without Billable Prep costrate name related LCR instead of LT with Prep / LT without Prep CR
                        if(modifyLTPrepRTLabel.containsKey(c.Rate_Type__c)){
                            String rateTypeLabel = modifyLTPrepRTLabel.get(c.Rate_Type__c);
                            if(LtWithOrWithoutBillablePrepExist == true){
                                System.debug('rateTypeLabel'+c.Cost_Rate_Name__c);

                                if(!(c.Cost_Rate_Name__c.contains(rateTypeLabel)) && isActualLT == false){
                                    isValidCR = false;
                                }
                            }else{
                                if(c.Cost_Rate_Name__c.contains(rateTypeLabel)){
                                    isValidCR = false;
                                }
                            }
                        }

                        if(isValidCR == true){
                            multiPayRate.isSelectedVal = true;
                            multiPayRate.costRateMsg = 'The following Cost Rate will be assigned <a href="/'+c.Id+'">'+c.Cost_Rate_Name__c+'</a>.  Please contact HR to change this Contact\'s Pay Rate for this assignment.';
                            multiPayRate.crId = c.Id;
                            multiPayRate.isApproved = (c.Status__c == 'Approved' ? true: false);
                            rateTypeAndMulitiPayRate.put(c.Rate_Type__c, multiPayRate);
                        }
                    }
                    
                    if(c.Rate_Type__c == 'FT Salary & Benefits' && c.Exempt_Status__c == 'Exempt') {
                        multiPayRate.isSelectedVal = true;
                        multiPayRate.costRateMsg = 'The following Cost Rate will be assigned <a href="/'+c.Id+'">'+c.Cost_Rate_Name__c+'</a>.  Please contact HR to change this Contact\'s Pay Rate for this assignment.';
                        multiPayRate.crId = c.Id;
                        multiPayRate.isApproved = (c.Status__c == 'Approved' ? true: false);
                        rateTypeAndMulitiPayRate.put(c.Rate_Type__c, multiPayRate);
                    }
                    
                    if(hourlyRTSet.contains(c.Rate_Type__c)) {
                        
                        multiPayRate.isSelectedVal = true;
                        multiPayRate.costRateMsg = 'The following Cost Rate will be assigned <a href="/'+c.Id+'">'+c.Cost_Rate_Name__c+'</a>.  Please contact HR to change this Contact\'s Pay Rate for this assignment.';
                        multiPayRate.crId = c.Id;
                        multiPayRate.isApproved = (c.Status__c == 'Approved' ? true: false);
                        rateTypeAndMulitiPayRate.put(c.Rate_Type__c, multiPayRate);
                    }
                }
            } 
        }
        
        if(String.isNotBlank(projectId)){
            List<AcctSeed__Project__c> proList = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',new Set<Id>{projectId},',Training_Location__r.Name');
            
            if(proList.size() > 0){
              multipayCR.projectLocation = proList[0].Training_Location__r.Name; 
            }
        }
        Id profileId = userinfo.getProfileId();
        if(profileId != null) {
            List<Profile> profileList = [Select Id,Name from Profile where Id= :profileId];
            multipayCR.profileName = profileList[0].Name;
        }
        
        if(dlsGrpCRExist == false && (defaultCR == 'DLI-W PS - Group 3' || defaultCR == 'DLI-W PS - Group 4')){
            ContactAssignmentDomain.MultiplePayRateCostRate DLIGrpHCRate = new ContactAssignmentDomain.MultiplePayRateCostRate();
            DLIGrpHCRate.DLIGroupHCCost = DLIGrpHC;
            rateTypeAndMulitiPayRate.put('DLIPSGroupRate', DLIGrpHCRate);   
        }
        
        multipayCR.MultiplePayRateCR = rateTypeAndMulitiPayRate;
        multipayCR.isFirstCR = (cRCount == 0 ? true : false);
        multipayCR.proOPPLangExist = proOppLanguExist;
        return multipayCR;  
    }
    // method to get contact related CR
    @AuraEnabled
    public static List<AcctSeed__Cost_Rates__c> getContactOrAccountRelCR(String contactId, Boolean isConRelCR, String accountId){
        Map<String,String> modifyLTPrepRTLabel = new Map<String,String>{'LT with Prep' => 'LT with Billable Prep','LT without Prep' => 'LT without Billable Prep'};
        String crString = ' WHERE Rate_Type__c != NULL  AND Status__c IN (\'Approved\',\'Draft\',\'Submitted for Approval\')';

        if(isConRelCR == true){
          crString += ' AND Contact__c = \''+ contactId +'\''; 
        }else{
           crString += ' AND Account__c = \''+ accountId+'\'';  
        }
        List<AcctSeed__Cost_Rates__c> conrelatedCRlst = CostRateService.getCostrateRec(crString, '');
        
        for(AcctSeed__Cost_Rates__c cr : conrelatedCRlst){
            if(modifyLTPrepRTLabel.containsKey(cr.Rate_Type__c)){
                String rateType = modifyLTPrepRTLabel.get(cr.Rate_Type__c);
                
                if(cr.Cost_Rate_Name__c != null && cr.Cost_Rate_Name__c.contains(rateType)){
                    cr.Rate_Type__c = rateType;
                }
            } 
        }
        return conrelatedCRlst;
    } 
    // method to get transInterPretPTExistingCR
    @AuraEnabled
    public static transIntrepretExistingCRDetails transInterPretPTExistingCR(String projectTaskId,string contactId){
        
        Map<String,Map<String, List<ContactAssignmentDomain.MultiplePayRateCostRate>>> pTCrMap = new  Map<String,Map<String,List<ContactAssignmentDomain.MultiplePayRateCostRate>>>();
        Map<String, List<ContactAssignmentDomain.MultiplePayRateCostRate>> rateTypeAndMulitiPayRate = new Map<String, List<ContactAssignmentDomain.MultiplePayRateCostRate>>();
        
        List<String> perWordBasedCRNames =  new List<String>{'Non-SCA Translation W/O Editing (Per Word)','Non-SCA Translation Editing Only (Per Word)','Non-SCA Translation + Editing (Per Word)'};
        List<String> perHrFFPBasedCRNames =  new List<String>{'Non-SCA Translation (Per Hour)','Non-SCA Translation (Per Hour)','Non-SCA Interpretation (Per Hour)', 'Non-SCA Translation (FFP)','Non-SCA Interpretation (FFP)'};
        List<AcctSeed__Cost_Rates__c> cRFTList = new List<AcctSeed__Cost_Rates__c>();
        List<AcctSeed__Cost_Rates__c> cRperWordList = new List<AcctSeed__Cost_Rates__c>();
        List<AcctSeed__Cost_Rates__c> cRperHrFFPList = new List<AcctSeed__Cost_Rates__c>();
        
        Set<String> crStatus = new Set<String>{'Approved','Draft','Submitted for Approval'};
        Set<String> hourlyRTSet = new set<String>{'FT Hourly & Benefits','PT Hourly (OH & G&A)'};
                
        Boolean isValidPTDefaultRateType = false;
        Integer cRcount = 0;

        transIntrepretExistingCRDetails tIExistingCRInfo = new transIntrepretExistingCRDetails();
        
        for(AcctSeed__Cost_Rates__c cr : CostRateService.getCostrateRec(' WHERE Contact__c = \''+ contactId + '\'  Order By Effective_Date__c Desc', '')) {
            if(crStatus.contains(cr.Status__c)  && (cr.Rate_Type__c == 'FT Salary & Benefits' && cr.Exempt_Status__c == 'Exempt') || hourlyRTSet.contains(cr.Rate_Type__c)) { 
                cRFTList.add(cr);
            }else if(perHrFFPBasedCRNames.contains(cr.Rate_Type__c) && crStatus.contains(cr.Status__c)){
                cRperHrFFPList.add(cr);
            }else if(perWordBasedCRNames.contains(cr.Rate_Type__c) && crStatus.contains(cr.Status__c)){
                cRperWordList.add(cr);
            }
            cRcount = cRcount + 1;
        }
        
        
        if(cRFTList.size() > 0){
            for(AcctSeed__Cost_Rates__c cr : cRFTList){
                ContactAssignmentDomain.MultiplePayRateCostRate multiPayRate = new ContactAssignmentDomain.MultiplePayRateCostRate();
                
                if(!rateTypeAndMulitiPayRate.containsKey('FTSalaryBenefits')){
                    multiPayRate.costRateMsg = 'The following Cost Rate will be assigned <a href="/'+cr.Id+'">'+cr.Cost_Rate_Name__c+'</a>.  Please contact HR to change this Contact\'s Pay Rate for this assignment.';
                    multiPayRate.crId = cr.Id;
                    multiPayRate.costRateName = cr.Cost_Rate_Name__c;
                    multiPayRate.isApproved = (cr.Status__c == 'Approved' ? true: false);
                    rateTypeAndMulitiPayRate.put('FTSalaryBenefits',new List<ContactAssignmentDomain.MultiplePayRateCostRate>{multiPayRate});
                }else{
                    multiPayRate.costRateMsg = 'The following Cost Rate will be assigned <a href="/'+cr.Id+'">'+cr.Cost_Rate_Name__c+'</a>.  Please contact HR to change this Contact\'s Pay Rate for this assignment.';
                    multiPayRate.crId = cr.Id;
                    multiPayRate.costRateName = cr.Cost_Rate_Name__c;
                    multiPayRate.isApproved = (cr.Status__c == 'Approved' ? true: false);
                    rateTypeAndMulitiPayRate.get('FTSalaryBenefits').add(multiPayRate);
                }
            }
        }
        
        List<AcctSeed__Project_Task__c> pTList = [SELECT Id ,Project_Task_Type__c,Default_Cost_Rate_Rate_Type__c FROM AcctSeed__Project_Task__c WHERE Id = :projectTaskId];
        
        if(pTList.size() > 0){
            // static Map to store the Mapping for the Project Task Type and Default Cost Rate Rate Type field in Project Task
            Map<String,String> taskTypeWithRateTypeMap = new Map<String,String> {
                'Transcription (per hr)' =>  'Non-SCA Translation (Per Hour)',
                'Translation (per hr)' => 'Non-SCA Translation (Per Hour)',
                'Interpretation (per hr)' => 'Non-SCA Interpretation (Per Hour)',
                'Translation (per FFP)' => 'Non-SCA Translation (FFP)',
                'Interpretation (per FFP)' => 'Non-SCA Interpretation (FFP)'
            };
                        
            if(taskTypeWithRateTypeMap.containsKey(pTList[0].Project_Task_Type__c) && pTList[0].Default_Cost_Rate_Rate_Type__c == taskTypeWithRateTypeMap.get(pTList[0].Project_Task_Type__c)){
                String rateType = pTList[0].Default_Cost_Rate_Rate_Type__c;
                isValidPTDefaultRateType = true;
                
                if(cRperHrFFPList.size() > 0){
                    for(AcctSeed__Cost_Rates__c cr : cRperHrFFPList){
                        
                        ContactAssignmentDomain.MultiplePayRateCostRate multiPayRate = new ContactAssignmentDomain.MultiplePayRateCostRate();
                        
                        if(rateType == cr.Rate_Type__c){
                            if(!rateTypeAndMulitiPayRate.containsKey(cr.Rate_Type__c)){
                                multiPayRate.costRateMsg = 'The following Cost Rate will be assigned <a href="/'+cr.Id+'">'+cr.Cost_Rate_Name__c+'</a>.  Please contact HR to change this Contact\'s Pay Rate for this assignment.';
                                multiPayRate.crId = cr.Id;
                                multiPayRate.costRateName = cr.Cost_Rate_Name__c;
                                multiPayRate.isApproved = (cr.Status__c == 'Approved' ? true: false);
                                multipayRate.crHourlyFFPCost = (cr.Rate_Type__c != 'Non-SCA Translation (FFP)' ? cr.AcctSeed__Hourly_Cost__c : cr.Per_FFP_Cost__c);
                                rateTypeAndMulitiPayRate.put(cr.Rate_Type__c, new List<ContactAssignmentDomain.MultiplePayRateCostRate>{multiPayRate});
                            }else {
                                multiPayRate.costRateMsg = 'The following Cost Rate will be assigned <a href="/'+cr.Id+'">'+cr.Cost_Rate_Name__c+'</a>.  Please contact HR to change this Contact\'s Pay Rate for this assignment.';
                                multiPayRate.crId =cr.Id;
                                multiPayRate.isApproved = (cr.Status__c == 'Approved' ? true: false);
                                multiPayRate.costRateName = cr.Cost_Rate_Name__c;
                                multipayRate.crHourlyFFPCost = (cr.Rate_Type__c != 'Non-SCA Translation (FFP)' ? cr.AcctSeed__Hourly_Cost__c : cr.Per_FFP_Cost__c);
                                rateTypeAndMulitiPayRate.get(cr.Rate_Type__c).add(multiPayRate);
                            }
                        }
                    }
                }
            }else if(pTList[0].Project_Task_Type__c == 'Translation (per word)' && pTList[0].Default_Cost_Rate_Rate_Type__c == 'Non-SCA Translation (Per Word)'){
                isValidPTDefaultRateType = true;
                
                if(cRperWordList.size() > 0){
                    for(AcctSeed__Cost_Rates__c crList : cRperWordList){
                        ContactAssignmentDomain.MultiplePayRateCostRate multiPayRate = new ContactAssignmentDomain.MultiplePayRateCostRate();
                        
                        if(!rateTypeAndMulitiPayRate.containsKey(crList.Rate_Type__c)){
                            multiPayRate.costRateMsg = 'The following Cost Rate will be assigned <a href="/'+crList.Id+'">'+crList.Cost_Rate_Name__c+'</a>.  Please contact HR to change this Contact\'s Pay Rate for this assignment.';
                            multiPayRate.crId = crList.Id;
                            multiPayRate.costRateName = crList.Cost_Rate_Name__c;
                            multipayRate.crHourlyFFPCost = crList.Per_Word_Cost__c;
                            multiPayRate.isApproved = (crList.Status__c == 'Approved' ? true: false);
                            rateTypeAndMulitiPayRate.put(crList.Rate_Type__c,new List<ContactAssignmentDomain.MultiplePayRateCostRate>{multiPayRate});
                        }else{
                            multiPayRate.costRateMsg = 'The following Cost Rate will be assigned <a href="/'+crList.Id+'">'+crList.Cost_Rate_Name__c+'</a>.  Please contact HR to change this Contact\'s Pay Rate for this assignment.';
                            multiPayRate.crId = crList.Id;
                            multiPayRate.costRateName = crList.Cost_Rate_Name__c;
                            multipayRate.crHourlyFFPCost = crList.Per_Word_Cost__c;
                            multiPayRate.isApproved = (crList.Status__c == 'Approved' ? true: false);
                            rateTypeAndMulitiPayRate.get(crList.Rate_Type__c).add(multiPayRate);
                        }  
                    }
                }
            }
            if(!pTCrMap.containsKey(pTList[0].Project_Task_Type__c) && isValidPTDefaultRateType){        
                pTCrMap.put(pTList[0].Default_Cost_Rate_Rate_Type__c,rateTypeAndMulitiPayRate);
            }else{
                if(String.isBlank(pTList[0].Default_Cost_Rate_Rate_Type__c)){
                    pTCrMap.put('Empty PTDefaultCR',rateTypeAndMulitiPayRate);
                }else{
                    pTCrMap.put('Not Valid RateType',rateTypeAndMulitiPayRate);
                }
            }
        }
        tIExistingCRInfo.tIExistingCRMap = pTCrMap;
        tIExistingCRInfo.isFirstCR = (cRcount == 0 ? true : false);
        tIExistingCRInfo.perWordBasedCRNames = perWordBasedCRNames;
        tIExistingCRInfo.perHrFFPBasedCRNames = perHrFFPBasedCRNames;
        
        return tIExistingCRInfo;
    }
    // method to get other rate type Existing Cost rate Info
    @AuraEnabled
    public static ContactAssignmentDomain.CostRateDetails otherExistingCRInfo(String defaultCR,String parentRTName,String parentObjName,String contactId){
        
        ContactAssignmentDomain.CostRateDetails  costDetails = new ContactAssignmentDomain.CostRateDetails();
        
        Set<String> crRateTypeSet = new Set<String>{'Non-SCA MTT (1099)','Non-SCA Testing','FSI'};
        Set<String> ftPTRateTypeSet = new Set<String>{'FT Salary & Benefits','PT Hourly (OH & G&A)','FT Hourly & Benefits'};
        Set<String> crStatus = new Set<String>{'Approved','Draft','Submitted for Approval'};
        Set<Id> defaultCRRelCRs = new Set<Id>();
        
        List<AcctSeed__Cost_Rates__c> allCR = new List<AcctSeed__Cost_Rates__c>();

        String contactRT;
        Boolean isOppInsCA = (parentObjName == 'Opportunity');
        
        
        for(AcctSeed__Cost_Rates__c cr : CostRateService.getCostrateRec(' WHERE Contact__c = \''+ contactId + '\'','Contact__r.RecordType.DeveloperName')) {
            Boolean allcostRate = true;
            if(crStatus.contains(cr.Status__c) && cr.Rate_Type__c == defaultCR ) { 
                defaultCRRelCRs.add(cr.Id);
            }
            
            if(ftPTRateTypeSet.contains(defaultCR)){
                if(cr.Rate_Type__c != defaultCR){
                    allcostRate = false;
                }
            }
            
            if(allcostRate == true){
                allCR.add(cr);
            }
            
            contactRT = cr.Contact__r.RecordType.DeveloperName;
        }
        
        if(allCR.size() == 0){
            costDetails.createCAWithoutCR = true;
        }
           

        System.debug('allCR'+allCR.size());
        if( allCR != null && allCR.size() > 0 ) {  
            
            // When the Selected Contact has CR regardless of the Status and Rate Type
            if( crRateTypeSet.contains(defaultCR)  || ftPTRateTypeSet.contains(defaultCR)) {
                
                if ( defaultCR == 'Non-SCA Testing' ) {
                    
                    if(parentObjName == 'AcctSeed__Project__c' && parentRTName == 'Testing_Projects' && contactRT == 'DLS_Employee') {    
                        costDetails = ContactAssignmentLightningCtrl.staffNonScaTestingmethod(contactId,defaultCR);
                        if(costDetails.isAlreadyCRExist == true){
                            costDetails.contactRTName = contactRT;
                        }else{
                            costDetails.isAlreadyCRExist = null;
                            costDetails.costRateMessage = 'Please enter the amount this Contact should be paid for each test completed on this Project';   
                            costDetails.createNewCR = true; 
                        }
                    }else{
                        costDetails.costRateMessage = 'Please enter the amount this Contact should be paid for each test completed on this Project';   
                        
                        if(parentObjName == 'AcctSeed__Project__c'){
                            costDetails.createNewCR = false; 
                        }else{
                            costDetails.createNewCR = true;   
                        }
                     }
                }else {
                    for( AcctSeed__Cost_Rates__c cr : allCR ) {
                        // Added for Salary Benefited Contacts not to create a new CR when they are assigned as a Sub Ins.
                        if( (parentRTName == 'DLI_W_LT_Projects' || parentRTName == 'DLI_W_TO_Opportunities') && contactRT == 'DLS_Employee' && cr.Rate_Type__c == 'FT Salary & Benefits' && cr.Status__c == 'Approved') {
                            costDetails.rateCardRate = cr.Id;
                            costDetails.costRateMessage = 'This Contact\'s FT Salary & Benefits Cost Rate has been assigned for this Project Task. Please contact HR if you have any questions or concerns.';
                            costDetails.isAlreadyCRExist = true;
                            break;
                        } else {

                            if( cr.Rate_Type__c == defaultCR ) {
                                if(defaultCRRelCRs.contains(cr.Id)) {
                                    costDetails.rateCardRate = cr.Id;
                                    costDetails.costRateMessage = 'The following Cost Rate will be assigned <a href="/'+cr.Id+'">'+cr.Cost_Rate_Name__c+'</a>.  Please contact HR to change this Contact\'s Pay Rate for this assignment.';
                                    costDetails.createNewCR = False;
                                    costDetails.displayEffectiveDate = False;
                                    costDetails.isAlreadyCRExist = true;
                                    costDetails.costLabel = cr.Status__c == 'Approved' ? 'RateCost' : 'LaborCost';
                                    break;
                                } else {
                                    //W-007837 - Create new FSI Labor Cost Rate Rate Type & Offer Letter (SEP-1-2023)
                                    if(defaultCR == 'FSI'){
                                        if((parentObjName == 'AcctSeed__Project__c' && parentRTName == 'FSI_Projects') || (parentObjName == 'Opportunity' && parentRTName == 'FSI_Opportunities')){
                                            costDetails.CostRateMessage = 'Please enter Effective Date and Hourly Cost to create a "'+defaultCR+'" Type Cost Rate. If you have any questions, please contact HR.';
                                            costDetails.displayEffectiveDate = true;
                                            costDetails.createNewCR = true;
                                        }
                                    }else if(defaultCR == 'Non-SCA MTT (1099)'){
                                        if(isOppInsCA == true) {
                                            costDetails.createNewCR = False;
                                            break;
                                        } else {
                                            costDetails.CostRateMessage = 'Please enter Effective Date and Hourly Cost to create a "Non-SCA MTT (1099)" Type Cost Rate. If you have any questions, please contact HR.';
                                            costDetails.displayEffectiveDate = true;
                                            costDetails.createNewCR = true;
                                        }
                                    }else {
                                        costDetails.costRateMessage = 'This Contact does not have an Approved Cost Rate for this Project Task.  Please enter the hourly rate to submit for approval.  If you need assistance, please contact HR.';
                                        costDetails.createNewCR = true;
                                    }
                                }
                                
                            }else if(ftPTRateTypeSet.contains(defaultCR)){
                                costDetails.createCAWithoutCR = true;
                                break;
                            }else{
                                System.debug('inside Loop');
                                if (defaultCR == 'Non-SCA MTT (1099)') {
                                    if(isOppInsCA == true) {
                                        costDetails.createNewCR = false;
                                        break;
                                    } else {
                                        costDetails.CostRateMessage = 'Please enter Effective Date and Hourly Cost to create a "Non-SCA MTT (1099)" Type Cost Rate. If you have any questions, please contact HR.';
                                        costDetails.displayEffectiveDate = true;
                                        costDetails.createNewCR = true;
                                    }
                                }else if(defaultCR == 'FSI'){
                                    System.debug('parentObjName'+parentObjName);
                                     System.debug('parentRTName'+parentRTName);
                                    if((parentObjName == 'AcctSeed__Project__c' && parentRTName == 'FSI_Projects') || (parentObjName == 'Opportunity' && parentRTName == 'FSI_Opportunities')){
                                        costDetails.CostRateMessage = 'Please enter Effective Date and Hourly Cost to create a "'+defaultCR+'" Type Cost Rate. If you have any questions, please contact HR.';
                                        costDetails.displayEffectiveDate = true;
                                        costDetails.createNewCR = true;
                                    }
                                }else {
                                    costDetails.costRateMessage = 'This Contact does not have an Approved Cost Rate for this Project Task.  Please enter the hourly rate to submit for approval.  If you need assistance, please contact HR.';
                                    costDetails.createNewCR = true;
                                }
                            }
                        }
                    }
                } 
            }
            
        } else { // When the Selected Contact has No CR and it is purely a new Hire
            if(crRateTypeSet.contains(defaultCR)) {
                costDetails.isFirstCR = True;        
                if(defaultCR == 'Non-SCA Testing') {
                    costDetails.costRateMessage = 'Please enter the total amount this Contact should be paid on the Contact Assignment.  This Contact has not yet been hired, and this pay request will be sent to HR for approval';
                    costDetails.createNewCR = true;
                }else if(defaultCR == 'Non-SCA MTT (1099)') {
                    costDetails.costRateMessage = 'A "Non-SCA MTT (1099)" Type Cost Rate has been created for this Contact and submitted to HR for approval. An ICA Agreement will be created and sent to this Contact. If you have any questions, please contact HR.';
                    costDetails.createNewCR = true;
                }else if(defaultCR == 'FSI'){
                    if((parentObjName == 'AcctSeed__Project__c' && parentRTName == 'FSI_Projects') || (parentObjName == 'Opportunity' && parentRTName == 'FSI_Opportunities')){
                        costDetails.costRateMessage = 'This Contact has not yet been hired and does not have an Approved Cost Rate for this Project Task. Please enter the Hourly Rate and Effective Date to submit for approval. An Offer Letter will be created and sent to this Contact. If you need assistance, please contact HR.';
                        costDetails.createNewCR = true;
                    }
                }else {
                    costDetails.costRateMessage = 'This Contact has not yet been hired and does not have an Approved Cost Rate for this Project Task. Please enter the Hourly Rate and Effective Date to submit for approval. An Offer Letter will be created and sent to this Contact. If you need assistance, please contact HR.';
                    costDetails.createNewCR = true;
                }
                costDetails.displayEffectiveDate = true;
            }
        } 
        
        return costDetails;
    }
    // method to create Cost Rate Record
    @AuraEnabled
    public static string createLaborCR(String defaultCR, String projectId, String costRateInputJSON, String contactId, String accountId, Boolean isAccRelCR){
        
        ContactAssignmentDomain.CostRateCreationInputWrapper cRInputs = (ContactAssignmentDomain.CostRateCreationInputWrapper) System.JSON.deserialize(costRateInputJSON, ContactAssignmentDomain.CostRateCreationInputWrapper.class);
        List<String> tempDate = cRInputs.effectiveDate != null ? (cRInputs.effectiveDate).split('-') : new List<String>();
        Date crDate = (tempDate != null && tempDate.size() > 1) ? Date.ValueOf(tempDate[0]+'-'+tempDate[1]+'-'+tempDate[2]) : null;
        
        Boolean alreadyCRExist = false;
        Boolean isAssignLCRTOCA = false;

        
        Set<String> perWordRateTypeSet = new Set<String>{'Non-SCA Translation W/O Editing (Per Word)','Non-SCA Translation Editing Only (Per Word)','Non-SCA Translation + Editing (Per Word)'};
        Set<String> perHourRateTypeSet = new Set<String>{'Non-SCA Translation (Per Hour)','Non-SCA Interpretation (Per Hour)','Non-SCA Translation (FFP)','Non-SCA Interpretation (FFP)'};
        Set<String> defaultCRSet = new Set<String>{'DLI-21 SCA CD' ,'DLI-21 SCA MTT','DLI-21 SCA LT'};
        Set<String> dliCDSet = new Set<String>{'DLI-21 SCA CD'};  
        Set<String> dliMTTSet = new Set<String>{'DLI-21 SCA MTT'};  
        Set<String> dliLTSet = new Set<String>{'DLI-21 SCA LT'};  
        Set<String> otherDefaultCR = new Set<String>{/*'Non-SCA LT'*/ 'LT with Prep','LT without Prep','Non-SCA CD','Non-SCA LT-S','SubK-LT','DODA PS','DLI-W LT','DLI-W PS - Group 3','DLI-W PS - Group 4','FSI'};

        //For Cost Rate records approval process submit condition check in cost rate trigger
        
        List<AcctSeed__Cost_Rates__c> crs = new List<AcctSeed__Cost_Rates__c>();
        List<AcctSeed__Cost_Rates__c> crsToInsertList = new List<AcctSeed__Cost_Rates__c>();
        List<AcctSeed__Cost_Rates__c> insertedCRList = new List<AcctSeed__Cost_Rates__c>();
        
        AcctSeed__Cost_Rates__c crToInsertLT = new AcctSeed__Cost_Rates__c();
        AcctSeed__Cost_Rates__c crToInsert = new AcctSeed__Cost_Rates__c(Rate_Type__c = defaultCR, Status__c = 'Draft',AcctSeed__Hourly_Cost__c=0, Effective_Date__c = System.today());
        Savepoint sp = Database.setSavepoint();
        try {
            
            isFromCR = true;
            //Inorder to avoid inserting Cost Rates with same amount for the Testing Rate Type.
            if( defaultCR == 'Non-SCA Testing' || (defaultCR == 'SubK-LT' && isAccRelCR == true)) {
                String crQueryStr = '';

                if(defaultCR == 'Non-SCA Testing'){
                    crQueryStr += ' WHERE Contact__c = \''+contactId+'\' AND '+(cRInputs.getHourlyCost != null  ? 'AcctSeed__Hourly_Cost__c = '+cRInputs.getHourlyCost : 'Per_Test_Cost__c  = '+cRInputs.perTestCost);
                }else{
                    //W-006039 -  Process change when DLI projects are sub-contracted
                    //Inorder to avoid inserting Cost Rates with same amount for the SubK-LT Rate Type.

                    crQueryStr += ' WHERE Account__c = \''+accountId+'\' AND AcctSeed__Hourly_Cost__c = '+cRInputs.getHourlyCost;
                }
                
                crQueryStr +=  'AND Status__c = \'Approved\' AND Rate_Type__c = \''+defaultCR+'\' Order By Effective_Date__c Desc';
                crs = CostRateService.getCostrateRec(crQueryStr,'');
            }

            if( crs != null && crs.size() > 0 ) {
                crToInsert = crs[0];
                crsToInsertList.add(crs[0]);
                
                alreadyCRExist = true; 
                isAssignLCRTOCA = true;
            }else {
                alreadyCRExist = false; 

                if(isAccRelCR == true){
                    crToInsert.Account__c = accountId;
                    crToInsertLT.Account__c = accountId;
                }else{
                    crToInsert.Contact__c = contactId;
                    crToInsertLT.Contact__c = contactId;  
                }
                
                if(crDate != null) {
                    crToInsert.Effective_Date__c = crDate; 
                }
                
                if( defaultCR == 'Non-SCA Testing' ) {
                    
                    if(cRInputs.getHourlyCost != null) {
                        crToInsert.AcctSeed__Hourly_Cost__c = decimal.valueOf(cRInputs.getHourlyCost);  
                    }else if(cRInputs.perTestCost != null) {
                        crToInsert.Per_Test_Cost__c  = cRInputs.perTestCost;
                    } 
                    
                } else if(!dliCDSet.contains(defaultCR)) {
                    
                    if(String.isNotBlank(cRInputs.getHourlyCost)){
                        crToInsert.AcctSeed__Hourly_Cost__c = Decimal.valueOf(cRInputs.getHourlyCost);
                    }
                  
                }
                system.debug('defaultCR:::'+defaultCR);
                
                if((!defaultCRSet.contains(defaultCR)) || (((dliLTSet.contains(defaultCR))) && cRInputs.isFirstCR == true && cRInputs.createNonSCALT == false)) { // To Create CR by getting the input from User && cRInputs.isFirstCR == true && cRInputs.createNonSCALT == false) { // To Create CR by getting the input from User
                    
                    if(perHourRateTypeSet.contains(cRInputs.selectedTIRateType)){
                        system.debug('Inside per Hour Rate Type Set');
                        if(String.isNotBlank(cRInputs.getHourlyCost )){
                            crToInsert.AcctSeed__Hourly_Cost__c = decimal.valueOf(cRInputs.getHourlyCost);
                        }
                        if(String.isNotBlank(cRInputs.getperFFP)){
                            crToInsert.Per_FFP_Cost__c = decimal.valueOf(cRInputs.getperFFP);
                        }
                        crToInsert.Rate_Type__c = cRInputs.selectedTIRateType;
                        crsToInsertList.add(crToInsert);
                        
                    }else if(perWordRateTypeSet.contains(cRInputs.selectedTIRateType)){ 
                        system.debug('Inside per Word Rate Type Set');
                        if(cRInputs.perWordCost != null){
                            crToInsert.Per_Word_Cost__c = cRInputs.perWordCost;
                        }
                        crToInsert.Rate_Type__c = cRInputs.selectedTIRateType;
                        crsToInsertList.add(crToInsert);
                        
                    } else {
                        
                        if( defaultCR == 'Non-SCA Testing'){
                            crsToInsertList.add(crToInsert);
                        } 
                    }
                }
                
                String congaQryId = CongaTranslator.getCongaQuery('ICA Agreement Cost Rate Query');
                System.debug('defaultCR::'+ defaultCR);
                
                //Use the first rate type set for this. (contains) 
                if((defaultCRSet.contains(defaultCR) && (!dliMTTSet.contains(defaultCR))) || ((dliMTTSet.contains(defaultCR)) && cRInputs.isOppInsCA != true)  || otherDefaultCR.contains(defaultCR)) {
                    // For SCA LT we have create 2 CR one for SCA LT and one for Non SCA LT.
                    System.debug('defaultCR::'+ defaultCR);
                    List<Labor_Cost_Rate_Master__c> lcrms = new List<Labor_Cost_Rate_Master__c>();
                    
                    if(cRInputs.ftSalRT == true){
                        lcrms = [SELECT Id,Hourly_Cost__c, Tax_Type__c, Rate_Type__c FROM Labor_Cost_Rate_Master__c WHERE Rate_Type__c = 'FT Salary & Benefits'];
                    } else if(string.isNotBlank(cRInputs.taxType)){
                        lcrms = [SELECT Id,Hourly_Cost__c, Tax_Type__c, Rate_Type__c FROM Labor_Cost_Rate_Master__c WHERE Rate_Type__c = :cRInputs.taxType];
                    }else{
                        lcrms = [SELECT Id,Hourly_Cost__c,Tax_Type__c, Rate_Type__c FROM Labor_Cost_Rate_Master__c WHERE Rate_Type__c = :defaultCR];
                    }
                    
                    System.debug('lcrms :::::'+lcrms);
                    if(cRInputs.getHourlyCost != null){
                        crToInsertLT.AcctSeed__Hourly_Cost__c = decimal.valueOf(cRInputs.getHourlyCost);
                    }else if( lcrms != null && lcrms.size() > 0 ) {
                        crToInsertLT.AcctSeed__Hourly_Cost__c = lcrms[0].Hourly_Cost__c;
                    }
                    
                    crToInsertLT.Effective_Date__c = crDate != null ? crDate : System.Today();
                    if(cRInputs.annualCost != null){   
                        crToInsertLT.Annual_Salary_Cost__c = cRInputs.annualCost;
                    }
                    
                    if(cRInputs.perWordCost != null){
                        crToInsertLT.Per_Word_Cost__c = cRInputs.perWordCost;
                    }
                    
                    if(cRInputs.salaryCostPerHour != null){
                        crToInsertLT.Salary_Cost_Per_Hour__c = cRInputs.salaryCostPerHour;
                    }
                    
                    if(String.isNotBlank(cRInputs.taxType)){
                        crToInsertLT.Rate_Type__c = cRInputs.taxType;
                    }else{
                        crToInsertLT.Rate_Type__c = defaultCR;
                    }
                    
                    if(cRInputs.ftSalRT == true){
                        crToInsertLT.Rate_Type__c = 'FT Salary & Benefits';
                    }
                    
                    if(defaultCR == 'SubK-LT' && isAccRelCR == true){
                        crToInsertLT.Status__c = 'Approved';
                    }
                    crsToInsertList.add(crToInsertLT);
                    System.debug('crToInsertLT::Inside::'+crToInsertLT);
                }                 
            }
            if(crsToInsertList  != null && crsToInsertList.size() > 0 && alreadyCRExist == false) {
                system.debug('crsToInsertListBefore::::::::::'+crsToInsertList);
                Insert crsToInsertList;
                isAssignLCRTOCA = true;
            } 
            
            if(isAssignLCRTOCA == true){
                Set<Id> crIds = new Set<Id>();
                for(AcctSeed__Cost_Rates__c cr : crsToInsertList){
                    crIds.add(cr.Id);
                }
                insertedCRList = SObjectQueryService.SObjectQuery('AcctSeed__Cost_Rates__c',crIds,'');
            }
            
            // To update the Contact's Field when a new contact is hired
             List<AcctSeed__Project__c> proList = new  List<AcctSeed__Project__c>();
            if(String.isNotBlank(projectId)){
                proList = SObjectQueryService.SObjectQuery('AcctSeed__Project__c',new Set<Id>{projectId},',RecordType.DeveloperName');
            }
            System.debug('isFirstCR ::::'+cRInputs.isFirstCR );
            if(cRInputs.isFirstCR == true) {
                
                Contact toUpdateCon;
                Boolean isChanged = false;
                Map<String,String> projClassificationDeptMap = Cost_Rate_Trigger_Handler.getProjClassiMap();
                
                for(Contact c : [SELECT Id,Name,Original_Hire_Date__c,Supervisor_Name__c,Home_Dept__c,Department__c FROM Contact WHERE Id =: contactId]) {
                    
                    if(c.Original_Hire_Date__c == null) {
                        c.Original_Hire_Date__c = (crDate != null ? crDate : System.Today());  
                        isChanged = true;                      
                    }
                    if(c.Supervisor_Name__c == null) {
                        c.Supervisor_Name__c = UserInfo.getUserId();
                        isChanged = true;
                    }
                    if(c.Home_Dept__c == null && proList.size() > 0 && proList[0].QB_Classification__c != null) {
                        c.Home_Dept__c = proList[0].QB_Classification__c;
                        isChanged = true;
                    }
                    if(c.Department__c == null && proList.size() > 0 && proList[0].QB_Classification__c != null) {
                        c.Department__c = projClassificationDeptMap.containskey(proList[0].QB_Classification__c) ? projClassificationDeptMap.get(proList[0].QB_Classification__c) : '';
                        isChanged = true;
                    }
                    toUpdateCon = c;
                }
                if(isChanged == true){
                    update toUpdateCon;
                }
            }
            
            return JSON.serialize(insertedCRList);
            
        } catch(Exception ex) {
           System.debug('ex.getMessage()::createLaborCostRate:::'+ex.getMessage());
           Database.rollback(sp);
           throw new AuraHandledException(ex.getMessage());
        }
        
    }
    /*public static AssignCRToCAInfo AssignCRToCA(String conId,String defaultCR){
        AssignCRToCAInfo crInfo = new AssignCRToCAInfo();
        String crID = null;
        Boolean isApprovedCR = false;
        
        if(defaultCR != null && conId != null){
            Set<String> crRateTypeSet = new Set<String>{'DLI-21 SCA CD','DLI-21 SCA LT','DLI-21 SCA MTT','Non-SCA MTT (1099)','Non-SCA Testing'};   
            Set<String> otherCRRateTypeSet = new Set<String>{};
                    
                if(crRateTypeSet.contains(defaultCR)){
                    List<AcctSeed__Cost_Rates__c> crList = CostRateService.getCostrateRec(' WHERE Contact__c = \''+ conId + '\' AND Rate_Type__c = \'' +defaultCR+'\' Order By Effective_Date__c Desc', '');
                        
                    if(crList.size() > 0){
                        crID = crList[0].Id;
                        isApprovedCR = (crList[0].Status__c == 'Approved');
                    }
                }
        }
        crInfo.crId = crID;
        crInfo.isApprovedCR = isApprovedCR;
        return crInfo;
    }*/
    public class transIntrepretExistingCRDetails{
        @AuraEnabled
        public Map<String,Map<String, List<ContactAssignmentDomain.MultiplePayRateCostRate>>> tIExistingCRMap;
        @AuraEnabled
        public List<String> perWordBasedCRNames;
        @AuraEnabled
        public List<String> perHrFFPBasedCRNames;
        @AuraEnabled
        public Boolean isFirstCR;
    }
    public class MultiplePayRateExistingCRDetails{
        @AuraEnabled 
        public Map<String,ContactAssignmentDomain.MultiplePayRateCostRate> MultiplePayRateCR;
        @AuraEnabled
        public Boolean isFirstCR;
        @AuraEnabled
        public String projectLocation;
        @AuraEnabled
        public String profileName;
        @AuraEnabled
        public Boolean proOPPLangExist;
    }
    public class AssignCRToCAInfo{
        @AuraEnabled
        public Boolean isApprovedCR;
        @AuraEnabled
        public String crId;
    }
}