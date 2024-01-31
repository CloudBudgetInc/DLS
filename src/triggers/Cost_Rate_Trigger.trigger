/******************************************
        Created by Vinitha on March 9 2017
    ********************************************/
trigger Cost_Rate_Trigger on AcctSeed__Cost_Rates__c (before insert,before update,after insert, after update) {
    
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            Cost_Rate_Trigger_Handler.insertAndUpdateCostRate(Trigger.New,Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            Set<Id> contactIds = new Set<Id>();
            for(AcctSeed__Cost_Rates__c c : Trigger.new){
                if(c.Contact__c != NULL){
                    contactIds.add(c.Contact__c);
                }
            }
            if(contactIds.size() > 0){
                Map<Id, Contact> contactMap = new Map<Id, Contact>([SELECT Id FROM Contact WHERE Id IN :contactIds AND RecordType.DeveloperName = 'DLS_Employee']);
                System.debug('contactMap========='+contactMap+'contactMap SIZE======='+contactMap.size());
                if(contactMap.size() > 0){
                    Cost_Rate_Trigger_Handler.userPermissionToEditStaffLCR(Trigger.New,contactMap);
                } else{
                    Cost_Rate_Trigger_Handler.insertAndUpdateCostRate(Trigger.New,Trigger.oldMap);
                }
            }
            // Added by HL
            // To Prevent Labor Cost Rate edit once time has been entered
            Cost_Rate_Trigger_Handler.preventLCREdit(Trigger.New,Trigger.oldMap);
        }
    }
    
    // Submit for Approval Automatically when the criterias are met.
    if(Trigger.isAfter) {
        List<AcctSeed__Cost_Rates__c> costRateForNameUpdate = new List<AcctSeed__Cost_Rates__c>();
        Set<String> payRateModifyCRRateTypes = new Set<String>{'LT with Prep','LT without Prep','Non-SCA CD','Non-SCA CD (1099)', 'FT Hourly & Benefits', 'PT Hourly (OH & G&A)', 'FT Salary & Benefits','International Salary','Non-SCA LT','DLI-W LT','DODA PS','DLI-W PS - Group 3','DLI-W PS - Group 4','FSI'}; // pay rate modification for 'Non-SCA LT','Non-SCA CD','Non-SCA CD (1099)' RateTypes
        List<AcctSeed__Cost_Rates__c> payRateModifyRateTypesLCR = new List<AcctSeed__Cost_Rates__c>();
        List<AcctSeed__Cost_Rates__c> meritincreaseLCR = new List<AcctSeed__Cost_Rates__c>();
        
        if( trigger.isInsert) {
            Set<String> staffRateTypePM = new Set<String>{'PT Hourly (OH & G&A)', 'FT Hourly & Benefits', 'FT Salary & Benefits', 'International Salary'}; // pay Rate Modification for staff 
            System.debug('CostRateCreation_Ctrl.isFromCR::::::::::::'+CostRateCreation_Ctrl.isFromCR);
            if(ContactAssignmentLightningCtrl.isFromCA == True || Pay_Rate_Modification_Handler.isFromCRModify == True || CostRateCreation_Ctrl.isFromCR == True) {
                List<Approval.ProcessSubmitRequest> reqs = new List<Approval.ProcessSubmitRequest>();
                Map<Id,Integer> existingCRMap = Cost_Rate_Trigger_Handler.existingCRMap != null ? Cost_Rate_Trigger_Handler.existingCRMap : new Map<Id,Integer>();
                //Set<String> rateType = new Set<String>{'Non-SCA Interpretation (Per Hour)'};
                Set<String> rateType = new Set<String>{'Non-SCA Interpretation (Per Hour)', 'Non-SCA Translation (Per Hour)', 'Non-SCA Translation (FFP)', 'Non-SCA Translation W/O Editing (Per Word)', 'Non-SCA Translation Editing Only (Per Word)', 'Non-SCA Translation + Editing (Per Word)'};
                //new Set<String>{'Non-SCA Translation (Per Word)','Non-SCA Translation (Per Hour)','Non-SCA Interpretation (Per Hour)'};
                List<User> curUser = UserService.getLoggedInUserInfo(UserInfo.getUserId());
                String profileName;
                if(!curUser.isEmpty()) {
                    profileName = curUser[0].Profile.Name;
                }
                System.debug('profileName ======='+profileName );
                System.debug('existingCRMap::::::'+existingCRMap);
                for(AcctSeed__Cost_Rates__c cr : Trigger.New) {
                    System.debug('CR=======11'+cr);
                      System.debug('CR=======11'+cr.Prior_Version__c);
                    // Except for the Pay Rate Modification
                    if(cr.Prior_Version__c == null) {
                        System.debug('LTS====================123==');
                        if((cr.Status__c != 'Approved' && cr.Status__c != 'Submitted for Approval') && !rateType.contains(cr.Rate_Type__c)) {
                            System.debug('cr:::Inside Approval:'+cr);
                            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                            req1.setProcessDefinitionNameOrId('Cost_Rate_Approval_Process');
                            req1.setObjectId(cr.Id);
                            // Submit the approval request for the account
                            //Approval.ProcessResult result = Approval.process(req1);
                            reqs.add(req1);
                        }
                    } else if(profileName == 'LTS' && cr.Prior_Version__c != null && cr.Status__c != 'Approved' && cr.Status__c != 'Submitted for Approval' && (cr.Rate_Type__c == 'LT with Prep' || cr.Rate_Type__c == 'LT without Prep' || cr.Rate_Type__c == 'Non-SCA CD' || cr.Rate_Type__c == 'Non-SCA CD (1099)' || cr.Rate_Type__c == 'DLI-W LT' || cr.Rate_Type__c == 'FSI') && !staffRateTypePM.contains(cr.Rate_Type__c)) { // Non-SCA LT
                        System.debug('LTS====================');
                        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                        if(cr.AcctSeed__Hourly_Cost__c > 25 && (cr.Rate_Type__c == 'LT with Prep' || cr.Rate_Type__c == 'LT without Prep')) { // Non-SCA LT
                            req1.setProcessDefinitionNameOrId('Cost_Rate_Modification_Approval_Process');
                        } else {
                            req1.setProcessDefinitionNameOrId('Cost_Rate_Modification_Approval_to_HR');                           
                        }
                        req1.setObjectId(cr.Id);
                        reqs.add(req1);
                    }
                    /* else if (profileName != 'HR' && cr.Prior_Version__c != null && cr.Status__c != 'Approved' && cr.Status__c != 'Submitted for Approval' && (cr.Rate_Type__c == 'Non-SCA CD' || cr.Rate_Type__c == 'Non-SCA CD (1099)')) { 
                        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                        req1.setProcessDefinitionNameOrId('Cost_Rate_Modification_Approval_to_HR');
                        req1.setObjectId(cr.Id);
                        reqs.add(req1);
                    }*/
                    // To update the LCR MAster Custom Setting Merit Increase field value for the Pay Rate Modification
                    // To create new CA for the Prior version LCR - PAy Rate Modification
                    if((payRateModifyCRRateTypes.contains(cr.Rate_Type__c) || staffRateTypePM.contains(cr.Rate_Type__c)) && cr.Prior_Version__c != null && cr.Status__c == 'Approved') {
                        payRateModifyRateTypesLCR.add(cr);
                        if(cr.Rate_Type__c == 'LT with Prep' || cr.Rate_Type__c == 'LT without Prep') { //Non-SCA LT
                            meritincreaseLCR.add(cr);
                        }
                    }
                }
                System.debug('reqs:::::'+reqs);
                if( reqs != null && reqs.size() > 0 ) {
                    List<Approval.ProcessResult> result = Approval.process(reqs);
                    System.debug('result :::::'+result);
                }
            }
            
            //For FT Houly & Salary Benefits Rate Type Name formating
            for(AcctSeed__Cost_Rates__c cr : Trigger.New){
                if((cr.Rate_Type__c == 'FT Salary & Benefits' || cr.Rate_Type__c == 'FT Hourly & Benefits')){
                    
                    AcctSeed__Cost_Rates__c costRate = new AcctSeed__Cost_Rates__c();
                    costRate.Id = cr.Id;
                    costRate.Cost_Rate_Name__c = cr.Rate_Type__c+'-'+cr.Name;
                    
                    costRateForNameUpdate.add(costRate);
                }
            }
        }
        // To update the Prior Cost Rate Status to Inactive when new version of the CR is Approved 
       
        // W-002994 - Allow Pay Rate Modification action for Non-SCA CD Rate Type
        // We are currently only allowing Pay Rate Modifications for the Non-SCA LT Rate Type, 
        // but we would like to enable the Pay Rate Modification process for the Non-SCA CD Rate Type as well.

        if(trigger.isUpdate) {
            List<AcctSeed__Cost_Rates__c> newVersionCR = new List<AcctSeed__Cost_Rates__c>();
            Set<Id> priorCRId = new Set<Id>();
            
            for(AcctSeed__Cost_Rates__c cr : Trigger.new) {
                System.debug('cr=========222'+cr+'Status==='+cr.Status__c +'Old Status==='+trigger.Oldmap.get(cr.Id).Status__c);
                if(cr.Prior_Version__c != null && trigger.Oldmap.get(cr.Id).Status__c != cr.Status__c && cr.Status__c == 'Approved') {
                    priorCRId.add(cr.Prior_Version__c);
                    newVersionCR.add(cr);
                    if(payRateModifyCRRateTypes.contains(cr.Rate_Type__c)) {
                        payRateModifyRateTypesLCR.add(cr);
                        if(cr.Rate_Type__c == 'LT with Prep' || cr.Rate_Type__c == 'LT without Prep') { //Non-SCA LT
                            meritincreaseLCR.add(cr);
                        }
                    }
                }
                
                
                //For Name format change
                if(trigger.Oldmap.get(cr.Id).Rate_Type__c != cr.Rate_Type__c && (cr.Rate_Type__c == 'FT Salary & Benefits' || cr.Rate_Type__c == 'FT Hourly & Benefits')){
                    AcctSeed__Cost_Rates__c costRate = new AcctSeed__Cost_Rates__c();
                    costRate.Id = cr.Id;
                    costRate.Cost_Rate_Name__c = cr.Rate_Type__c+'-'+cr.Name;
                    
                    costRateForNameUpdate.add(costRate);
                }
            }
            System.debug('priorCRId:::'+priorCRId);
            if(newVersionCR.size() > 0 && priorCRId != null) {
                //Cost_Rate_Trigger_Handler crth= new Cost_Rate_Trigger_Handler();
                Cost_Rate_Trigger_Handler.updatePriorCRStatus(newVersionCR, priorCRId);
            }
            
        }
        
        if(payRateModifyRateTypesLCR.size() > 0) {
            Cost_Rate_Trigger_Handler.updateMeritIncreaseCRMaster(meritincreaseLCR);
            Cost_Rate_Trigger_Handler.updateCAwithLCRforPayRateModification(payRateModifyRateTypesLCR); 
        }
        
        system.debug(':::::::::costRateForNameUpdate:::'+costRateForNameUpdate);
        
        if(costRateForNameUpdate.size() > 0){
            update costRateForNameUpdate;
        }
    }   
}