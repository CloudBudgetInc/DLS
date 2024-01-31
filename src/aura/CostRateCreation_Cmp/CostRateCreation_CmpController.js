({
    doInit : function(cmp, event, helper) {
        var crOptionModalRateTypeNames = cmp.get("v.crOptionModalRateTypeNames");
        var defaultCR = cmp.get("v.defaultCR"); 
        var parentRTName  = cmp.get("v.parentRTName");
        var caRecord = cmp.get("v.caRecord");
        var parentObjName = cmp.get("v.parentObjName");
        var modifyLTPrepRTLabel = cmp.get("v.modifyLTPrepRTLabel");
        var projectTaskId = '';
               
        if(defaultCR == 'Non-SCA LT'){
            defaultCR = 'LT with Prep';
        }
        cmp.set("v.defaultCR",defaultCR);

        if(caRecord && caRecord.Project_Task__c){
            projectTaskId = caRecord.Project_Task__c;
        }
        
        if(modifyLTPrepRTLabel && modifyLTPrepRTLabel[defaultCR]){
            defaultCR = modifyLTPrepRTLabel[defaultCR];
        }
        
        if(parentObjName == 'AcctSeed__Project__c' && projectTaskId != null 
           && (parentRTName == 'Interpretation_Projects' || parentRTName == 'Translation_Projects')){
            
            helper.showTransInterPretCRPickOption(cmp);
        }           
        //W-006039 -  Process change when DLI projects are sub-contracted
        else if(((parentObjName == 'AcctSeed__Project__c' && projectTaskId != null) || parentObjName == 'Opportunity')  && (parentRTName == 'DLI_W_LT_Projects' || parentRTName == 'DLI_W_TO_Opportunities')
                  && caRecord.Account__c && ((caRecord.dliProjectType && caRecord.dliProjectType == 'Partner School' && defaultCR == 'SubK-LT') 
                 || (caRecord.Assignment_Position__c == 'Partner School EI' || caRecord.Assignment_Position__c  == 'Partner School Instructor'))){
          
            cmp.set('v.isAccRelatedCR',true); 
            helper.showAccRelCRCreationModal(cmp, event, helper);
        }else if(crOptionModalRateTypeNames.includes(defaultCR)){
            helper.showCRPickListOption(cmp, event, helper);
        }else {
            helper.showOtherCRCreationModal(cmp, event, helper);
        }
    },
    closeExistingCRTable : function(cmp, event, helper) {
        cmp.set("v.showExistingCRTable",false);
    },
    closeCRModal : function(cmp, event, helper) {
        helper.assignCRTOCAByEvent(cmp);
    },// view the contact related CR records
    viewConRelatedCR : function(cmp, event, helper) {
        helper.viewConOrAccRelatedCR(cmp, event, helper, true);
    },
    viewAccRelatedCR : function(cmp, event, helper) {
        helper.viewConOrAccRelatedCR(cmp, event, helper, false);
    },
    proceedWithSelectedValues : function(cmp, event, helper) {
        var crOptionModalRateTypeNames = cmp.get("v.crOptionModalRateTypeNames");
        var defaultCR = cmp.get("v.defaultCR"); 
        var parentRTName  = cmp.get("v.parentRTName");
        var parentObjName = cmp.get("v.parentObjName");
        var caRecord = cmp.get("v.caRecord");
        var modifyLTPrepRTLabel = cmp.get("v.modifyLTPrepRTLabel");
        var projectTaskId = '';
        
        if(caRecord && caRecord.Project_Task__c){
            projectTaskId = caRecord.Project_Task__c;
        }
        
        var isValid = true;
        var rateTypeOption = cmp.find("rateTypeId");
        
        if(!rateTypeOption.get("v.value")){
            isValid = false;
            $A.util.addClass(rateTypeOption, 'slds-has-error'); 
        }else {
            $A.util.removeClass(rateTypeOption, 'slds-has-error'); 
        }
        
        if(modifyLTPrepRTLabel && modifyLTPrepRTLabel[defaultCR]){
            defaultCR = modifyLTPrepRTLabel[defaultCR];
        }
        
        if(isValid){

            if(parentObjName == 'AcctSeed__Project__c' && projectTaskId != null && 
               (parentRTName == 'Interpretation_Projects' || parentRTName == 'Translation_Projects')){
                helper.TransInterPretCRHelperForSave(cmp);
                
            }else if(crOptionModalRateTypeNames.includes(defaultCR)){
                if(defaultCR == 'LT with Prep' || defaultCR == 'LT without Prep' || defaultCR == 'Non-SCA CD'|| defaultCR == 'DODA PS' || defaultCR == 'DLI-W LT'){
                    helper.saveForNONSCALTCD(cmp);
                }else if(defaultCR == 'DLI-21 SCA LT'){
                    helper.saveForDLISCALT(cmp);
                }else if(defaultCR == 'DLI-21 SCA CD'){
                    helper.saveForDLISCACD(cmp);
                }else if(defaultCR == 'DLI-21 SCA MTT') {
                    helper.saveForDLISCAMTT(cmp);
                }else if( defaultCR == 'DLI-W PS - Group 3'|| defaultCR == 'DLI-W PS - Group 4'){
                    helper.saveForDLIPSGrp(cmp);
                }
            }
        }
    },
    showPerWordDepPickList : function(cmp, event, helper) {
        
        var parentRTName  = cmp.get("v.parentRTName");
        var parentObjName = cmp.get("v.parentObjName");
        var caRecord = cmp.get("v.caRecord");
        var projectTaskId = '';
        
        if(caRecord && caRecord.Project_Task__c){
            projectTaskId = caRecord.Project_Task__c;
        }
        
        if(parentObjName == 'AcctSeed__Project__c' && projectTaskId != null && 
           (parentRTName == 'Interpretation_Projects' || parentRTName == 'Translation_Projects')){
            
            var tiProjectCRDetailMap = cmp.get("v.tiProjectCRDetailMap");
            var selectedPayRate = cmp.get("v.selectedPayRate");
            var selectedRateTypeCRRecs = [];
            var tiPTExistingCRMap =  tiProjectCRDetailMap.tiPTExistingCRMap; 
            var tiproTaskDefaultCR = tiProjectCRDetailMap.tiproTaskDefaultCR;
            
            tiProjectCRDetailMap.isShowTIExistingCROptions = false;
            tiProjectCRDetailMap.isTIProjectCreateCR = false;
            tiProjectCRDetailMap.isTIProjectExistingCR = false;
            cmp.set("v.ftSalRT", false);
            
            if(selectedPayRate == 'Assign their Existing Salary Exempt Cost Rate' && ((tiproTaskDefaultCR == 'Non-SCA Translation (Per Word)') 
               																	  || (tiProjectCRDetailMap.perHrFFPBasedRateTypeLst).includes(tiproTaskDefaultCR))){
                
                selectedRateTypeCRRecs = tiPTExistingCRMap['FTSalaryBenefits'];
                cmp.set("v.ftSalRT", true);
                tiProjectCRDetailMap = helper.formTIExistingCROptionInfo(cmp,selectedRateTypeCRRecs,tiProjectCRDetailMap);
                
            }else if(tiProjectCRDetailMap.tiproTaskDefaultCR == 'Non-SCA Translation (Per Word)'){
                
                if(selectedPayRate == 'Create a new Cost Rate'){
                    var tiProjectPerWordCreateCR = tiProjectCRDetailMap.tiProjectPerWordCreateCR;
                    tiProjectCRDetailMap.isTIProjectCreateCR = true;
                    
                    if(tiProjectPerWordCreateCR.length > 0){
                        tiProjectCRDetailMap.selectedTICR = tiProjectPerWordCreateCR[0].value;
                    }
                    
                }else if(selectedPayRate == 'Assign Existing Cost Rate'){
                    
                    var tiProjectPerWordExistingCR = tiProjectCRDetailMap.tiProjectPerWordExistingCR;
                    tiProjectCRDetailMap.isTIProjectExistingCR = true;
                    
                    if(tiProjectPerWordExistingCR.length > 0){
                        tiProjectCRDetailMap.selectedTICR = tiProjectPerWordExistingCR[0].value;
                        selectedRateTypeCRRecs = tiPTExistingCRMap[tiProjectPerWordExistingCR[0].value];
                        tiProjectCRDetailMap = helper.formTIExistingCROptionInfo(cmp,selectedRateTypeCRRecs,tiProjectCRDetailMap);
                    }
                    
                }
            }else if(selectedPayRate == 'Assign Existing Cost Rate'){
                
                var tiProjectPerWordExistingCR = tiProjectCRDetailMap.tiProjectPerWordExistingCR;
                if((tiProjectCRDetailMap.perHrFFPBasedRateTypeLst).includes(tiproTaskDefaultCR)){                  
                    selectedRateTypeCRRecs = tiPTExistingCRMap[tiproTaskDefaultCR];
                    tiProjectCRDetailMap = helper.formTIExistingCROptionInfo(cmp,selectedRateTypeCRRecs,tiProjectCRDetailMap);                
                }
                
            }
            console.log(JSON.stringify(tiProjectCRDetailMap));
            cmp.set("v.tiProjectCRDetailMap",tiProjectCRDetailMap); 
        }
    },
    showTIExistingCROptions: function(cmp,event,helper) {
        var tiProjectCRDetailMap = cmp.get("v.tiProjectCRDetailMap");
        var selectedTICR = tiProjectCRDetailMap.selectedTICR;
        var tiPTExistingCRMap =  tiProjectCRDetailMap.tiPTExistingCRMap;
        var selectedRateTypeCRRecs= [];
        
        selectedRateTypeCRRecs = tiPTExistingCRMap[selectedTICR];
        tiProjectCRDetailMap = helper.formTIExistingCROptionInfo(cmp,selectedRateTypeCRRecs,tiProjectCRDetailMap);
        cmp.set("v.tiProjectCRDetailMap",tiProjectCRDetailMap);
    },
    closeCRCreateModal : function(cmp,event,helper) {
        var otherCRCreationMap = cmp.get("v.otherCRCreationMap");

        if(otherCRCreationMap != null && otherCRCreationMap.isAlreadyCRExist == false && otherCRCreationMap.crRequest == false){
            helper.createCRRecord(cmp);
        }else {
            helper.assignCRTOCAByEvent(cmp);
        }
    },
    proceedToCreateCR : function(cmp,event,helper) {
        var cRPicklistBasedInput = cmp.get("v.cRPicklistBasedInput");
        var otherCRCreationMap = cmp.get("v.otherCRCreationMap");
        var crInputField = cmp.find("crInputField");
        var defaultCR = cmp.get("v.defaultCR"); 
        var parentObjName = cmp.get("v.parentObjName");
        var parentRTName = cmp.get("v.parentRTName");
        var isValidInputs = true;
        var crInputs = cmp.get("v.crInputValues");
        var modifyLTPrepRTLabel = cmp.get("v.modifyLTPrepRTLabel");
        var crOptionModalRateTypeNames = cmp.get("v.crOptionModalRateTypeNames");

        var selectedRateTypeCRRecs = [];
        var existingCostRateMap = {};

        if(cRPicklistBasedInput.showDate || otherCRCreationMap.displayEffectiveDate){
            var crInputDate = cmp.find("crInputDate");
            
            if(!crInputDate.get("v.value")){
                isValidInputs = false
                crInputDate.set("v.errors", [{message:" "}])
            }else{
                crInputDate.set("v.errors",null);
            }
        }
        if(crInputField){
            isValidInputs = helper.validateCRInputs(cmp,event,helper,crInputField,isValidInputs);
        }
        if(isValidInputs){
            
             if(modifyLTPrepRTLabel != null && modifyLTPrepRTLabel[defaultCR]){
                defaultCR = modifyLTPrepRTLabel[defaultCR];
            }
            
            
            cmp.set("v.showSpinner", true);
            if(parentObjName == 'AcctSeed__Project__c' && (parentRTName == 'Interpretation_Projects' || parentRTName == 'Translation_Projects')){
                var tiProjectCRDetailMap = cmp.get("v.tiProjectCRDetailMap");
                var perHRFFPCRNames = tiProjectCRDetailMap.perHrFFPBasedRateTypeLst;
                var tiproTaskDefaultCR = tiProjectCRDetailMap.tiproTaskDefaultCR;
                var getHourlyCost = crInputs.getHourlyCost;
                var getPerFFP = crInputs.getPerFFP;
                var perWordCost = crInputs.perWordCost;
                var tiPTExistingCRMap = tiProjectCRDetailMap.tiPTExistingCRMap;
                var isValidToCreate = true;
                
                if(perHRFFPCRNames.includes(tiproTaskDefaultCR)){
                    crInputs.selectedTIRateType = tiproTaskDefaultCR;
                    selectedRateTypeCRRecs = tiPTExistingCRMap[tiproTaskDefaultCR];
                }else if(tiproTaskDefaultCR == 'Non-SCA Translation (Per Word)'){
                    crInputs.selectedTIRateType = tiProjectCRDetailMap.selectedTICR;
                    selectedRateTypeCRRecs = tiPTExistingCRMap[tiProjectCRDetailMap.selectedTICR];
                }
                
                if(selectedRateTypeCRRecs && selectedRateTypeCRRecs.length > 0) {
                    for(var i = 0; i < selectedRateTypeCRRecs.length; i++) {
                        if(selectedRateTypeCRRecs[i]['crHourlyFFPCost'] == ((tiproTaskDefaultCR == 'Non-SCA Translation (FFP)' || tiproTaskDefaultCR == 'Non-SCA Interpretation (FFP)'  ) ? getPerFFP : ((tiproTaskDefaultCR == 'Non-SCA Translation (Per Word)')  ? perWordCost : getHourlyCost ))){
                            existingCostRateMap[tiproTaskDefaultCR] = selectedRateTypeCRRecs[i];
                            isValidToCreate = false;
                        }
                    }
                }
                
                if(isValidToCreate){
                    cmp.get("v.crInputValues",crInputs);
                    cmp.set("v.defaultCR",crInputs.selectedTIRateType);
                    helper.createCRRecord(cmp,event,helper);
                }else {
                    helper.assignCRTOCAByEvent(cmp);
                }
            }else if(crOptionModalRateTypeNames.includes(defaultCR) || defaultCR == 'Non-SCA LT-S' ) {
                helper.createCRRecord(cmp,event,helper);
            }else if(otherCRCreationMap.showProceedBtn || cRPicklistBasedInput.showProceedBtn){
                helper.createCRRecord(cmp);
            }else {
               helper.assignCRTOCAByEvent(cmp);
            }
        }
    },
    validateHCGreaterThanSCACD : function(cmp,event,helper){ 
        var isValidInputs = true;
        var crInputField = cmp.find("crInputField");
        helper.validateCRInputs(cmp,event,helper,crInputField,isValidInputs);
    },
    getFullyLoadedValues : function(cmp, event, helper){
        var cRPicklistBasedInput = cmp.get("v.cRPicklistBasedInput");
        var multiPayRateCR = cmp.get("v.multiPayRateCR");
        var crInputValues = cmp.get("v.crInputValues");
        var crOptionModalRateTypeNames = cmp.get("v.crOptionModalRateTypeNames"),defaultCR = cmp.get("v.defaultCR");
        var modifyLTPrepRTLabel = cmp.get("v.modifyLTPrepRTLabel");
        
        if(cRPicklistBasedInput.fulLoadAmtFlag == true){
            if(modifyLTPrepRTLabel != null && modifyLTPrepRTLabel[defaultCR]){
                defaultCR = modifyLTPrepRTLabel[defaultCR];
            }
            
            var sumOfVal = multiPayRateCR['fullyLoadedAmt'].fullyLoadedAmt;
            var hourlyCost = crInputValues.getHourlyCost;
            
            if(defaultCR == 'LT with Prep'|| defaultCR == 'LT without Prep' || defaultCR == 'DLI-W LT'){
                let fullyLoadVal = parseFloat(sumOfVal) * parseFloat(hourlyCost);
                
                sumOfVal = fullyLoadVal.toFixed(2)
            }

            var fullyLoadedAmt = parseFloat(sumOfVal) + parseFloat(hourlyCost);
            crInputValues.fullyLoadedAmount = fullyLoadedAmt.toFixed(2);
            cmp.set("v.crInputValues",crInputValues);
        }
    },
    createNonSCATestingLCR : function(cmp, event, helper){
        var payType = cmp.find('payTypeId');
        var nonSCATestingLCRPayType = cmp.get("v.nonSCATestingLCRPayType");
        var crInputValues = cmp.get("v.crInputValues");
        var isValid = true;
        var otherCRCreationMap = cmp.get("v.otherCRCreationMap");
        
        if(Array.isArray(payType)){
            for(var i = 0;i < payType.length;i++) { 
                if(!payType[i].get("v.value")){
                    isValid = false;
                    $A.util.addClass(payType[i], 'slds-has-error'); 
                }else {
                    $A.util.removeClass(payType[i], 'slds-has-error'); 
                }
            }
        }else {
            if(!payType.get("v.value")){
                isValid = false;
                $A.util.addClass(payType, 'slds-has-error'); 
            }else {
                $A.util.removeClass(payType, 'slds-has-error'); 
            }
        }
        if(isValid) {
            var selectedNonSCATestPay = (Array.isArray(payType) ? payType[0].get("v.value") : payType.get("v.value"));
            var otherCRCreationMap = cmp.get("v.otherCRCreationMap");
            
            crInputValues.getHourlyCost  = null;
            crInputValues.perTestCost  = null;
            crInputValues.noHrsExcepted  = null;
            otherCRCreationMap.crRequest = false;

            if(selectedNonSCATestPay == 'Per Hour'){
                otherCRCreationMap.noHrsExcepted = true;
                otherCRCreationMap.perTestCost = false;
                otherCRCreationMap.perHourCost = true;
            }else{
                otherCRCreationMap.perTestCost = true;
                otherCRCreationMap.noHrsExcepted = false;
                otherCRCreationMap.perHourCost = false;
            }
            
            nonSCATestingLCRPayType.selectedNonSCATestPay = selectedNonSCATestPay;
            nonSCATestingLCRPayType.isTestingPayType = false;
            cmp.set("v.nonSCATestingLCRPayType",nonSCATestingLCRPayType);
            cmp.set("v.crInputValues",crInputValues);
            cmp.set("v.otherCRCreationMap",otherCRCreationMap);
        }
    },
    backTONonSCATestPayType : function(cmp, event, helper){
        var nonSCATestingLCRPayType = cmp.get("v.nonSCATestingLCRPayType");
        nonSCATestingLCRPayType.isTestingPayType = true;
        cmp.set("v.nonSCATestingLCRPayType",nonSCATestingLCRPayType);
    },
    closeErrorModal : function(cmp, event, helper){
        cmp.set("v.isShowErrorModal",false);
        var costRateInfo = {'isErrorFROMCRModal' : true};
        
        cmp.set("v.costRateInfo",costRateInfo);
        helper.assignCRTOCAByEvent(cmp);
    }
})