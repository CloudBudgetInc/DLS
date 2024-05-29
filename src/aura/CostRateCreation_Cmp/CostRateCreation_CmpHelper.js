({
    showCRPickListOption: function(cmp,event,helper){
        cmp.set("v.showSpinner",true);
        var defaultCR = cmp.get("v.defaultCR");
        var action = cmp.get("c.getExistingCRInfo");
        var parentObjName  = cmp.get("v.parentObjName");
        var caRecord = cmp.get("v.caRecord");
        var projectId = '';
        var contactId = '';
        var oppId = '';
        var self = this;

        if(caRecord){
           if(caRecord.Project__c){
               projectId = caRecord.Project__c;
            }
            if(caRecord.Candidate_Name__c){
               contactId = caRecord.Candidate_Name__c;
            }
            
            if(caRecord.Opportunity_Name__c){
                oppId = caRecord.Opportunity_Name__c;
            }
        }
        
        const server = cmp.find('server');
        server.callServer(
            action, {
                'contactId' : contactId,
                'defaultCR' : defaultCR,
                'projectId' : projectId,
                'parentObjName' : parentObjName,
                'oppId' : oppId
            },
            false,
            $A.getCallback(function(response) {
                var crRateTypeOptions = [];
                var result = response;
                var crInputs = cmp.get("v.crInputValues");
                var profileName = result.profileName;
                crInputs.isFirstCR = result.isFirstCR;
                cmp.set("v.multiPayRateCR", result.MultiplePayRateCR);
                cmp.set("v.crInputValues",crInputs);
                cmp.set("v.projectLocation",result.projectLocation);
                console.log(result);
                
                var showCROptionModel = true;
                if((defaultCR == 'DLI-W PS - Group 3'|| defaultCR == 'DLI-W PS - Group 4') && result.proOPPLangExist == false){
                    showCROptionModel = false;
                    self.showPTLanguageValidation(cmp);  
                }
                
                if(showCROptionModel){
                    cmp.set("v.showCROptionModal", true);
                    cmp.find("showOptions").open();
                    
                    var modifyLTPrepRTLabel = cmp.get("v.modifyLTPrepRTLabel");
                    
                    if(modifyLTPrepRTLabel != null && modifyLTPrepRTLabel[defaultCR]){
                        defaultCR = modifyLTPrepRTLabel[defaultCR];
                    }
                    
                    if(defaultCR == 'DLI-W PS - Group 3'|| defaultCR == 'DLI-W PS - Group 4'){
                        self.dliPSGrpTPickListFormation(cmp);  
                    }else if(defaultCR == 'LT with Prep' || defaultCR == 'LT without Prep' || defaultCR == 'Non-SCA CD'|| defaultCR == 'DODA PS' || defaultCR == 'DLI-W LT'){
                        self.nonSCALTCDPickListFormation(cmp,profileName);
                    }else if(defaultCR == 'DLI-21 SCA LT' ){
                        self.dliSCALTPickListFormation(cmp);
                    }else if(defaultCR == 'DLI-21 SCA CD'){
                        self.dliSCACDPickListFormation(cmp);
                    }else if(defaultCR == 'DLI-21 SCA MTT') {
                        self.dliSCAMTTPickListFormation(cmp);
                    }
                  
                }
                cmp.set("v.showSpinner", false);
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false); 
                cmp.set("v.showErrorMsg",  errors[0].message);
                cmp.set("v.isShowErrorModal",true);
                cmp.find("errorModal").open();
            }),
            false,
            false,
            false
        );
    },
    
    // for DLI PS GrouprateType CR option PickList Formation
    dliPSGrpTPickListFormation : function(cmp){
        var crRateTypeOptions = [];
        var defaultCR = cmp.get("v.defaultCR");
        var multiPayRateCR = cmp.get("v.multiPayRateCR");
        
        crRateTypeOptions.push({'label': '--None--', 'value':''});
        cmp.find("rateTypeId").set("v.value", "");
        
        if(multiPayRateCR[defaultCR] && multiPayRateCR[defaultCR].isSelectedVal == true){
            crRateTypeOptions.push({'label': 'Assign existing '+defaultCR+' Rate', 'value':'Assign existing '+defaultCR+' Rate'});
        }else{
            crRateTypeOptions.push({'label': 'Create a new '+defaultCR+' Rate', 'value':'Create a new '+defaultCR+' Rate'});
        }
        
        if((multiPayRateCR['FT Salary & Benefits']) && multiPayRateCR['FT Salary & Benefits'].isSelectedVal == true){
            crRateTypeOptions.push({'label': 'Assign Existing FT Salary & Benefits Rate', 'value':'Assign Existing FT Salary & Benefits Rate'});
        } 
        
        this.ftPtSalaryoptions(cmp,multiPayRateCR,crRateTypeOptions);

        cmp.set("v.crRateTypeOptions",crRateTypeOptions);
    },
    // DLI-21 SCA LT rateType CR option PickList Formation
    dliSCALTPickListFormation : function(cmp){
        var crRateTypeOptions = [];
        var defaultCR = cmp.get("v.defaultCR");
        var multiPayRateCR = cmp.get("v.multiPayRateCR");
        
        crRateTypeOptions.push({'label': '--None--', 'value':''});
        cmp.find("rateTypeId").set("v.value", "");
        
        if(multiPayRateCR[defaultCR] && multiPayRateCR[defaultCR].isSelectedVal == true){
            crRateTypeOptions.push({'label': 'Assign existing '+defaultCR+' Rate', 'value':'Assign existing '+defaultCR+' Rate'});
        }else{
            crRateTypeOptions.push({'label': 'Create a new '+defaultCR+' Rate', 'value':'Create a new '+defaultCR+' Rate'});
        }
        
        if((multiPayRateCR['FT Salary & Benefits']) && multiPayRateCR['FT Salary & Benefits'].isSelectedVal == true){
            crRateTypeOptions.push({'label': 'Assign Existing FT Salary & Benefits Rate', 'value':'Assign Existing FT Salary & Benefits Rate'});
        } 
        
        this.ftPtSalaryoptions(cmp,multiPayRateCR,crRateTypeOptions);

        cmp.set("v.crRateTypeOptions",crRateTypeOptions);
    },
    // for LT  and  Non-SCA CD rateType CR option PickList Formation
    nonSCALTCDPickListFormation : function(cmp,profileName){
        
        var crRateTypeOptions = [];
        var defaultCR = cmp.get("v.defaultCR");
        var multiPayRateCR = cmp.get("v.multiPayRateCR");
        var modifyLTPrepRTLabel = cmp.get("v.modifyLTPrepRTLabel");
        var rateType = '';
        
        crRateTypeOptions.push({'label': '--None--', 'value':''});
        cmp.set("v.selectedPayRate",'');
        
        rateType = defaultCR;
        if(modifyLTPrepRTLabel != null && modifyLTPrepRTLabel[defaultCR]){
            defaultCR = modifyLTPrepRTLabel[defaultCR];
        }else{
            defaultCR = defaultCR;
        }
        
        if(multiPayRateCR[defaultCR] && multiPayRateCR[defaultCR].isSelectedVal == true){
            
            crRateTypeOptions.push({'label' : 'Assign existing '+rateType+' Rate', 'value' : 'Assign existing '+rateType+' Rate'});
        }else{
            crRateTypeOptions.push({'label' : 'Create a new '+rateType+' Rate', 'value' : 'Create a new '+rateType+' Rate'});
        }
        
        if((multiPayRateCR['FT Salary & Benefits']) && multiPayRateCR['FT Salary & Benefits'].isSelectedVal == true){
            crRateTypeOptions.push({'label': 'Assign Existing FT Salary & Benefits Rate', 'value':'Assign Existing FT Salary & Benefits Rate'});
        } 
        
        this.ftPtSalaryoptions(cmp,multiPayRateCR,crRateTypeOptions);
        
        if(cmp.get("v.parentObjName") == 'AcctSeed__Project__c' && profileName == 'HR' && defaultCR == 'LT'){
            crRateTypeOptions.push({'label' : 'Assign New Project Specific Rate', 'value' : 'Assign New Project Specific Rate'});
        }
        
        
        cmp.set("v.crRateTypeOptions",crRateTypeOptions);
    },
    // for DLI-21 SCA CD rateType CR option PickList Formation
    dliSCACDPickListFormation : function(cmp){
        
        var crRateTypeOptions = [];
        var defaultCR = cmp.get("v.defaultCR");
        var multiPayRateCR = cmp.get("v.multiPayRateCR");
        
        if(multiPayRateCR[defaultCR] && multiPayRateCR[defaultCR].isSelectedVal == true){
            crRateTypeOptions.push({'label': 'Assign Existing '+defaultCR+' Rate', 'value':'Assign Existing '+defaultCR+' Rate'});
            cmp.find("rateTypeId").set("v.value", "Assign Existing "+defaultCR+" Rate");
        } else{
            crRateTypeOptions.push({'label': 'Create a new '+defaultCR+' Rate', 'value':'Create a new '+defaultCR+' Rate'});
            cmp.find("rateTypeId").set("v.value", "Create a new "+defaultCR+" Rate");
        }
        
        if((multiPayRateCR['FT Salary & Benefits']) && multiPayRateCR['FT Salary & Benefits'].isSelectedVal == true){
            crRateTypeOptions.push({'label': 'Assign their Existing Salary Exempt Cost Rate', 'value':'Assign their Existing Salary Exempt Cost Rate'});
        }else{
            crRateTypeOptions.push({'label': 'Create a new Salary Exempt Cost Rate', 'value':'Create a new Salary Exempt Cost Rate'});
        }
        
        this.ftPtSalaryoptions(cmp,multiPayRateCR,crRateTypeOptions);
        
        crRateTypeOptions.push({'label': 'W-2 Hourly Rate greater than the SCA Rate', 'value':'W-2 Hourly Rate greater than the SCA Rate'});
        crRateTypeOptions.push({'label': 'Create a new SCA 1099 Contract', 'value':'Create a new SCA 1099 Contract'});
        crRateTypeOptions.push({'label': 'Create a new Non-SCA 1099 Contract', 'value':'Create a new Non-SCA 1099 Contract'});
        cmp.set("v.crRateTypeOptions",crRateTypeOptions);
        
    },
    // for  DLI-21 SCA MTT rateType CR option PickList Formation
    dliSCAMTTPickListFormation : function(cmp){
        
        var crRateTypeOptions = [];
        var defaultCR = cmp.get("v.defaultCR");
        var multiPayRateCR = cmp.get("v.multiPayRateCR");
        
        if(multiPayRateCR[defaultCR] && multiPayRateCR[defaultCR].isSelectedVal == true){
            crRateTypeOptions.push({'label': 'Assign Existing '+defaultCR+' Rate', 'value':'Assign Existing '+defaultCR+' Rate'});
            cmp.find("rateTypeId").set("v.value", "Assign Existing "+defaultCR+" Rate");
        } else{
            crRateTypeOptions.push({'label': 'Create a new '+defaultCR+' Rate', 'value':'Create a new '+defaultCR+' Rate'});
            cmp.find("rateTypeId").set("v.value", "Create a new "+defaultCR+" Rate");
        }
        
        if((multiPayRateCR['FT Salary & Benefits']) && multiPayRateCR['FT Salary & Benefits'].isSelectedVal == true){
            crRateTypeOptions.push({'label': 'Assign Existing Staff Salary Exempt Rate', 'value':'Assign Existing Staff Salary Exempt Rate'});
        }
        
        this.ftPtSalaryoptions(cmp,multiPayRateCR,crRateTypeOptions);

        crRateTypeOptions.push({'label': 'W-2 Hourly Rate greater than the SCA Rate', 'value':'W-2 Hourly Rate greater than the SCA Rate'});
        crRateTypeOptions.push({'label': 'Create a new Non-SCA 1099 Contract', 'value':'Create a new Non-SCA 1099 Contract'});
        cmp.set("v.crRateTypeOptions",crRateTypeOptions);
        
    },
    // Save for LT and  Non-SCA CD rateType
    saveForNONSCALTCD : function(cmp){
        
        var defaultCR = cmp.get("v.defaultCR");
        var selectedPayRate = cmp.get("v.selectedPayRate");
        var multiPayRateCR = cmp.get("v.multiPayRateCR");
        var crInputs = cmp.get("v.crInputValues");
        var crInputFields = cmp.get("v.cRPicklistBasedInput");
        var modifyLTPrepRTLabel = cmp.get("v.modifyLTPrepRTLabel");
        var rateType = '';
        
        rateType = defaultCR;
        if(modifyLTPrepRTLabel && modifyLTPrepRTLabel[defaultCR]){
            defaultCR = modifyLTPrepRTLabel[defaultCR];
        }

        if(selectedPayRate == 'Assign existing '+rateType+' Rate' || selectedPayRate == 'Assign Existing FT Salary & Benefits Rate'
         || selectedPayRate == 'Assign Existing FT Hourly & Benefits Rate' ||  selectedPayRate == 'Assign Existing PT Hourly (OH & G&A) Rate'){
            
            if(selectedPayRate == 'Assign existing '+rateType+' Rate'){
                this.showExistingCRAssignMsgModal(cmp,defaultCR);
            }
            
            if(selectedPayRate == 'Assign Existing FT Salary & Benefits Rate'){
                this.showExistingCRAssignMsgModal(cmp,'FT Salary & Benefits');
                cmp.set("v.ftSalRT", true);
            }
            
            if(selectedPayRate == 'Assign Existing PT Hourly (OH & G&A) Rate'){
                this.showExistingCRAssignMsgModal(cmp,'PT Hourly (OH & G&A)');
            }

            if(selectedPayRate == 'Assign Existing FT Hourly & Benefits Rate'){
                this.showExistingCRAssignMsgModal(cmp,'FT Hourly & Benefits');
            }
            
        }else if(selectedPayRate == 'Create a new '+rateType+' Rate'){
            
            crInputFields.showDate = true;
            crInputFields.showHC = true;
            crInputFields.defaultCostRate = rateType;
                        
            if(defaultCR == 'LT with Prep' || defaultCR == 'DLI-W LT' || defaultCR == 'LT without Prep'){
                crInputFields.fulLoadAmtFlag = true;
            }
            this.getCreationInputs(cmp,crInputFields);
            
        }else if(selectedPayRate == 'Assign New Project Specific Rate' && (defaultCR == 'LT with Prep' || defaultCR == 'LT without Prep')){
            cmp.set("v.defaultCR",'Non-SCA LT-S');
            
            crInputFields.showDate = true;
            crInputFields.showHC = true;
            crInputFields.defaultCostRate = defaultCR; 
            this.getCreationInputs(cmp,crInputFields);
            
            if(cmp.get("v.parentObjName") == 'AcctSeed__Project__c' && cmp.get("v.projectLocation") == 'Bolling AFB'){
                crInputs.getHourlyCost = '30.50';
                cmp.set("v.crInputValues",crInputs);
            }
        }
    },
    //Save  for  DLI-21 SCA LT rateType CR 
    saveForDLISCALT: function(cmp){
        
        var defaultCR = cmp.get("v.defaultCR");
        var selectedPayRate = cmp.get("v.selectedPayRate");
        var crInputFields = cmp.get("v.cRPicklistBasedInput");
        
        if(selectedPayRate == 'Assign existing '+defaultCR+' Rate' || selectedPayRate == 'Assign Existing FT Salary & Benefits Rate'
           || selectedPayRate == 'Assign Existing PT Hourly (OH & G&A) Rate' || selectedPayRate == 'Assign Existing FT Hourly & Benefits Rate'){
                      
            if(selectedPayRate == 'Assign existing '+defaultCR+' Rate'){
                this.showExistingCRAssignMsgModal(cmp,defaultCR);
            }
            
            if(selectedPayRate == 'Assign Existing FT Salary & Benefits Rate'){
                this.showExistingCRAssignMsgModal(cmp,'FT Salary & Benefits');
                cmp.set("v.ftSalRT", true);
            }
            
            if(selectedPayRate == 'Assign Existing FT Hourly & Benefits Rate'){
                this.showExistingCRAssignMsgModal(cmp,'FT Hourly & Benefits');
            }
            
            if(selectedPayRate == 'Assign Existing PT Hourly (OH & G&A) Rate'){
                this.showExistingCRAssignMsgModal(cmp,'PT Hourly (OH & G&A)');
            }
            
        }else if(selectedPayRate == 'Create a new '+defaultCR+' Rate'){
            
            crInputFields.showDate = true;
            crInputFields.defaultCostRate = defaultCR; 
            this.getCreationInputs(cmp,crInputFields);
        }
    },
     //Save  for  DLS PS group 3 and 4 rateType CR 
    saveForDLIPSGrp: function(cmp){
        
        var defaultCR = cmp.get("v.defaultCR");
        var selectedPayRate = cmp.get("v.selectedPayRate");
        var crInputFields = cmp.get("v.cRPicklistBasedInput");
        var multiPayRateCR = cmp.get("v.multiPayRateCR");


        if(selectedPayRate == 'Assign existing '+defaultCR+' Rate' || selectedPayRate == 'Assign Existing FT Salary & Benefits Rate' 
        	|| selectedPayRate == 'Assign Existing PT Hourly (OH & G&A) Rate' || selectedPayRate == 'Assign Existing FT Hourly & Benefits Rate'){
           
            if(selectedPayRate == 'Assign existing '+defaultCR+' Rate'){
                this.showExistingCRAssignMsgModal(cmp,defaultCR);
            }
            
            if(selectedPayRate == 'Assign Existing FT Salary & Benefits Rate'){
                this.showExistingCRAssignMsgModal(cmp,'FT Salary & Benefits');
                cmp.set("v.ftSalRT", true);
            }
            
            if(selectedPayRate == 'Assign Existing FT Hourly & Benefits Rate'){
                this.showExistingCRAssignMsgModal(cmp,'FT Hourly & Benefits');
            }
            
            if(selectedPayRate == 'Assign Existing PT Hourly (OH & G&A) Rate'){
                this.showExistingCRAssignMsgModal(cmp,'PT Hourly (OH & G&A)');
            }
            
        }else if(selectedPayRate == 'Create a new '+defaultCR+' Rate'){
            var hourlyCost = 0;
            if(multiPayRateCR['DLIPSGroupRate'] && multiPayRateCR['DLIPSGroupRate']['DLIGroupHCCost']){
                hourlyCost = multiPayRateCR['DLIPSGroupRate'].DLIGroupHCCost;
            }
            
            crInputFields.showHC = true;
            crInputFields.showDate = true;
            crInputFields.defaultCostRate = defaultCR; 
            crInputFields.getHourlyCost = hourlyCost; 
            console.log(JSON.stringify(crInputFields));
            this.getCreationInputs(cmp,crInputFields);
        }
    },
     //Save  for DLI-21 SCA CD rateType CR
    saveForDLISCACD  : function(cmp){
        var defaultCR = cmp.get("v.defaultCR");
        var selectedPayRate = cmp.get("v.selectedPayRate");
        var crInputFields = cmp.get("v.cRPicklistBasedInput");
        
        if(selectedPayRate == 'Assign Existing '+defaultCR+' Rate' || selectedPayRate == 'Assign their Existing Salary Exempt Cost Rate'
           || selectedPayRate == 'Assign Existing PT Hourly (OH & G&A) Rate' || selectedPayRate == 'Assign Existing FT Hourly & Benefits Rate'){
            
            if(selectedPayRate == 'Assign Existing '+defaultCR+' Rate'){
                this.showExistingCRAssignMsgModal(cmp,defaultCR);
            }
            
            if(selectedPayRate == 'Assign their Existing Salary Exempt Cost Rate'){
                this.showExistingCRAssignMsgModal(cmp,'FT Salary & Benefits');
                cmp.set("v.ftSalRT", true);
            }
            
            if(selectedPayRate == 'Assign Existing FT Hourly & Benefits Rate'){
                this.showExistingCRAssignMsgModal(cmp,'FT Hourly & Benefits');
            }
            
            if(selectedPayRate == 'Assign Existing PT Hourly (OH & G&A) Rate'){
                this.showExistingCRAssignMsgModal(cmp,'PT Hourly (OH & G&A)');
            }
            
        }else if(selectedPayRate == 'Create a new '+defaultCR+' Rate'){
            
            crInputFields.showDate = true;
            crInputFields.defaultCostRate = defaultCR;
            this.getCreationInputs(cmp,crInputFields);
            
        }else if(selectedPayRate == 'Create a new Salary Exempt Cost Rate'){
            
            cmp.set("v.ftSalRT",true);
            crInputFields.showDate = true;
            crInputFields.defaultCostRate = 'FT Salary & Benefits';
            crInputFields.showAS = true; 
            this.getCreationInputs(cmp,crInputFields);
            
        }else if(selectedPayRate == 'W-2 Hourly Rate greater than the SCA Rate'){
            
            crInputFields.showDate = true;
            crInputFields.showHC = true;
            crInputFields.defaultCostRate = defaultCR;
            crInputFields.fulLoadAmtFlag = true; 
            crInputFields.isGreaterHourly = true; 
            this.getCreationInputs(cmp,crInputFields);
            
        }else if(selectedPayRate == 'Create a new SCA 1099 Contract'){
            
            crInputFields.showDate = true;
            crInputFields.showHC = true;
            crInputFields.defaultCostRate = (defaultCR+' (1099)');
            crInputFields.taxType = (defaultCR+' (1099)');
            this.getCreationInputs(cmp,crInputFields);
            
        }else if(selectedPayRate == 'Create a new Non-SCA 1099 Contract'){
            
            crInputFields.showDate = true;
            crInputFields.showHC = true;
            crInputFields.defaultCostRate = 'Non-SCA CD (1099)';
            crInputFields.taxType = 'Non-SCA CD (1099)';
            this.getCreationInputs(cmp,crInputFields);
        }
    },
    //Save  for  DLI-21 SCA MTT rateType CR
    saveForDLISCAMTT : function(cmp){
        var defaultCR = cmp.get("v.defaultCR");
        var selectedPayRate = cmp.get("v.selectedPayRate");
        var crInputFields = cmp.get("v.cRPicklistBasedInput");
        
        if(selectedPayRate == ('Assign Existing '+defaultCR+' Rate') || selectedPayRate == 'Assign Existing Staff Salary Exempt Rate'
           || selectedPayRate == 'Assign Existing PT Hourly (OH & G&A) Rate' || selectedPayRate == 'Assign Existing FT Hourly & Benefits Rate'){
           
            if(selectedPayRate == 'Assign Existing '+defaultCR+' Rate'){
                this.showExistingCRAssignMsgModal(cmp,cmp.get("v.defaultCR"));
            }
           
            if(selectedPayRate == 'Assign Existing Staff Salary Exempt Rate'){
                this.showExistingCRAssignMsgModal(cmp,'FT Salary & Benefits');
                cmp.set("v.ftSalRT", true);
            }
            
            if(selectedPayRate == 'Assign Existing FT Hourly & Benefits Rate'){
                this.showExistingCRAssignMsgModal(cmp,'FT Hourly & Benefits');
            }
            
            if(selectedPayRate == 'Assign Existing PT Hourly (OH & G&A) Rate'){
                this.showExistingCRAssignMsgModal(cmp,'PT Hourly (OH & G&A)');
            }
            
        }else if(selectedPayRate == 'Create a new '+defaultCR+' Rate'){
            
            crInputFields.showDate = true;
            crInputFields.defaultCostRate = defaultCR; 
            this.getCreationInputs(cmp,crInputFields);
            
        }else if(selectedPayRate == 'W-2 Hourly Rate greater than the SCA Rate'){
            
            crInputFields.showDate = true;
            crInputFields.showHC = true;
            crInputFields.defaultCostRate = defaultCR; 
            crInputFields.isGreaterHourly = true;
            this.getCreationInputs(cmp,crInputFields);
            
        }else if(selectedPayRate == 'Create a new Non-SCA 1099 Contract'){

            crInputFields.showDate = true;
            crInputFields.showHC = true;
            crInputFields.defaultCostRate = 'Non-SCA MTT (1099)'; 
            crInputFields.taxType = 'Non-SCA MTT (1099)';
            this.getCreationInputs(cmp,crInputFields);
            
        }
    },
    getCreationInputs : function(cmp,crInputFields){
        
        var crInputs = cmp.get("v.crInputValues");
        var inputFields = crInputFields;
        var defaultCR = cmp.get("v.defaultCR");
        inputFields.showProceedBtn = true;
        crInputs.ftSalRT = cmp.get("v.ftSalRT");
        crInputs.isOppInsCA = (cmp.get("v.parentObjName") == 'Opportunity');
        crInputs.isHCDisable = false;
        
        if(inputFields.taxType){
            crInputs.taxtype = inputFields.taxType;alert
        }
        
        
        if(crInputFields.defaultCostRate){
            var ratetype = crInputFields.defaultCostRate;
            cmp.set("v.displayRateTypeMsg",ratetype);
        }
        if(crInputFields['getHourlyCost'] && (defaultCR == 'DLI-W PS - Group 3'|| defaultCR == 'DLI-W PS - Group 4')){
            crInputs.getHourlyCost = (crInputFields.getHourlyCost).toFixed(2);
            crInputs.isHCDisable = true;
        }
        
        cmp.set("v.crInputValues",crInputs);
        console.log(JSON.stringify(crInputs));
        cmp.set("v.cRPicklistBasedInput",inputFields);
        cmp.set("v.showCROptionModal",false);
        cmp.set("v.showCRCreationInputModal",true);
        cmp.find("showInputModalId").open();
        
    },
    contactOrAccountRelCRTable : function(cmp, event, helper){
        
        var dataCRHeader = [{'label': 'Rate Type'},
                            {'label': 'Fully Loaded Rate'},
                            {'label': 'Effective Date'}, 
                            {'label': 'Status'}];
        
        cmp.set("v.conOrAccRelCRHeader",dataCRHeader); 
        cmp.set("v.showExistingCRTable",true); 
        
        console.log(cmp.get("v.conOrAccRelCRRows"));
    },
    showTransInterPretCRPickOption : function(cmp, event, helper){
        
        var caRecord = cmp.get("v.caRecord");
        var projectTaskId = '';
        var contactId = '';
        
        if(caRecord){
            if(caRecord && caRecord.Project_Task__c){
                projectTaskId = caRecord.Project_Task__c;
            }
            if(caRecord.Candidate_Name__c){
                contactId = caRecord.Candidate_Name__c;
            }
        }
        cmp.set("v.showSpinner",true);
        
        var action = cmp.get("c.transInterPretPTExistingCR");
        var self = this;
        const server = cmp.find('server');
        server.callServer(
            action, {
                'projectTaskId': projectTaskId,
                'contactId' : contactId
            },
            false,
            $A.getCallback(function(response) {
                if(response){
                    var caRecord = cmp.get("v.caRecord");
                    console.log(response);
                    var proTaskRateTypeMap = response.tIExistingCRMap;
                    var proTaskDefaultCR = (Object.keys(proTaskRateTypeMap))[0];
                    var cRMap = proTaskRateTypeMap[proTaskDefaultCR];
                    var existingCostRatePicklist  = (Object.keys(proTaskRateTypeMap[proTaskDefaultCR]));
                    var tiProjectCRDetailMap = cmp.get("v.tiProjectCRDetailMap");
                    var crRateTypeOptions = [];
                    var crInputs = cmp.get("v.crInputValues");
                    var oldPTDefaultCR = '';

                    if(caRecord.Project_Task__r && caRecord.Project_Task__r.Default_Cost_Rate_Rate_Type__c != null){
                        oldPTDefaultCR = caRecord.Project_Task__r.Default_Cost_Rate_Rate_Type__c;
                    }
                    crInputs.isFirstCR = response.isFirstCR;
                    cmp.set("v.crInputValues",crInputs);
                    tiProjectCRDetailMap.perWordCRRateTypeLst = response.perWordBasedCRNames;
                    tiProjectCRDetailMap.perHrFFPBasedRateTypeLst = response.perHrFFPBasedCRNames;
                    
                    if((proTaskDefaultCR == 'Non-SCA Translation (Per Word)') || (tiProjectCRDetailMap.perHrFFPBasedRateTypeLst).includes(proTaskDefaultCR)){
                        if(oldPTDefaultCR != proTaskDefaultCR){
                            cmp.set("v.visibleError",'slds-hide');
                            
                            tiProjectCRDetailMap.isTIProjectCreateCR = true;
                            tiProjectCRDetailMap.tiPTExistingCRMap = cRMap;
                            tiProjectCRDetailMap.tiproTaskDefaultCR = proTaskDefaultCR;
                            
                            if(proTaskDefaultCR == 'Non-SCA Translation (Per Word)'){
                                tiProjectCRDetailMap =  self.tIPerwordDeptPickListHelper(cmp,existingCostRatePicklist,tiProjectCRDetailMap);
                            }
                            
                            crRateTypeOptions.push({'label': '--None--', 'value':''});
                            crRateTypeOptions.push({'label': 'Create a new Cost Rate', 'value':'Create a new Cost Rate'});
                            
                            var  existingCRForTI = (Object.keys(cRMap));
                            if(existingCRForTI.indexOf("FTSalaryBenefits") != -1){
                                existingCRForTI.splice(existingCRForTI.indexOf("FTSalaryBenefits"),1);
                            }
                            
                            if(existingCRForTI.length != 0 ){
                                crRateTypeOptions.push({'label': 'Assign Existing Cost Rate', 'value':'Assign Existing Cost Rate'});
                            }
                            
                            if('FTSalaryBenefits' in cRMap){
                                crRateTypeOptions.push({'label': 'Assign their Existing Salary Exempt Cost Rate', 'value':'Assign their Existing Salary Exempt Cost Rate'});
                                cmp.set("v.ftSalRT", true);
                            }
                            cmp.set("v.crRateTypeOptions",crRateTypeOptions);
                            cmp.set("v.tiProjectCRDetailMap",tiProjectCRDetailMap);
                            cmp.set("v.showCROptionModal", true);
                            cmp.find("showOptions").open();
                        }else {
                            self.assignCRTOCAByEvent(cmp);
                        }
                    }else{
                        if(proTaskDefaultCR == 'Empty PTDefaultCR'){
                            cmp.set("v.showErrorMsg",'This Project Task does not have Default Cost Rate Rate Type value. Please update the record to perform Cost Rate creation.');            
                        }else{
                            cmp.set("v.showErrorMsg",'This Project Task does not have appropriate Default Cost Rate Rate Type value. Please update the record to perform Cost Rate creation.');            
                        }
                        cmp.set("v.isShowErrorModal",true);
                        cmp.find("errorModal").open();
                    }
                }
                cmp.set("v.showSpinner", false);
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                cmp.set("v.showErrorMsg",  errors[0].message);  
                cmp.set("v.isShowErrorModal",true);
                cmp.find("errorModal").open();
            }),
            false,
            false,
            false
        );
    },
    tIPerwordDeptPickListHelper : function(cmp,existingCostRatePicklist,tiProjectCRDetailMap){
        
        var tiProjectCreateCR = [];
        var tiProjectExistingCR = [];
        var perWordCRRateTypeLst = tiProjectCRDetailMap.perWordCRRateTypeLst;
        
        for(var i = 0;i < perWordCRRateTypeLst.length;i++){
            if(existingCostRatePicklist.includes(perWordCRRateTypeLst[i])){
                tiProjectExistingCR.push({'label': perWordCRRateTypeLst[i], 'value':perWordCRRateTypeLst[i]});
            }
            tiProjectCreateCR.push({'label': perWordCRRateTypeLst[i], 'value':perWordCRRateTypeLst[i]});
        }
        
        tiProjectCRDetailMap.tiProjectPerWordExistingCR = tiProjectExistingCR;
        tiProjectCRDetailMap.tiProjectPerWordCreateCR = tiProjectCreateCR;
        
        return tiProjectCRDetailMap;
    },
    formTIExistingCROptionInfo : function(cmp,selectedRateTypeCRRecs,tiProjectCRDetailMap){
        var tiExistingcRList = [];
        
        for( var i = 0;i < selectedRateTypeCRRecs.length;i++){
            tiExistingcRList.push({'label': selectedRateTypeCRRecs[i]['costRateName'],'value':selectedRateTypeCRRecs[i]['crId']});
        }
        
        tiProjectCRDetailMap.tiExistingCROptions = tiExistingcRList;
        tiProjectCRDetailMap.isShowTIExistingCROptions = true;
        
        if(tiExistingcRList.length > 0){
            tiProjectCRDetailMap.tiSelectedCRId = tiExistingcRList[0].value;
        }
        
        return tiProjectCRDetailMap;
    },
    TransInterPretCRHelperForSave :function(cmp,event,helper){
        
        var tiProjectCRDetailMap = cmp.get("v.tiProjectCRDetailMap");
        var tiproTaskDefaultCR = tiProjectCRDetailMap.tiproTaskDefaultCR;
        var selectedPayRate = cmp.get("v.selectedPayRate");
        var crInputFields = cmp.get("v.cRPicklistBasedInput");
        var selectedTICR = tiProjectCRDetailMap.selectedTICR;
        var selectedRateTypeCRRecs = [];
        var existingCostRateMap = {};

        
        if(selectedPayRate == 'Assign Existing Cost Rate' || selectedPayRate == 'Assign their Existing Salary Exempt Cost Rate'){
            var selectedCRId = tiProjectCRDetailMap.tiSelectedCRId;
            
            selectedRateTypeCRRecs = tiProjectCRDetailMap.tiPTExistingCRMap[(selectedPayRate == 'Assign Existing Cost Rate') ? ((tiproTaskDefaultCR == 'Non-SCA Translation (Per Word)') ? selectedTICR : tiproTaskDefaultCR ) : 'FTSalaryBenefits'];
           
            // W-001288 - Translation Labor Cost Rates - Multiple Active Labor Cost Rates for the Same Rate Type
            //  - Assign LCR to CA
            if(selectedCRId && selectedRateTypeCRRecs.length > 0){
                for( var i = 0;i < selectedRateTypeCRRecs.length;i++){
                    if(selectedRateTypeCRRecs[i].crId == selectedCRId){
                        existingCostRateMap[[(selectedPayRate == 'Assign Existing Cost Rate') ? ((tiproTaskDefaultCR == 'Non-SCA Translation (Per Word)') ? selectedTICR : tiproTaskDefaultCR ): 'FTSalaryBenefits']] = selectedRateTypeCRRecs[i];
                    }
                }
            }
            
            cmp.set("v.multiPayRateCR",existingCostRateMap);
            
            if(selectedPayRate == 'Assign Existing Cost Rate') {
               
                if((tiProjectCRDetailMap.perHrFFPBasedRateTypeLst).includes(tiproTaskDefaultCR)){
                    this.showExistingCRAssignMsgModal(cmp,tiproTaskDefaultCR);
                }else if(tiproTaskDefaultCR == 'Non-SCA Translation (Per Word)'){
                    if((tiProjectCRDetailMap.perWordCRRateTypeLst).includes(selectedTICR)){
                        this.showExistingCRAssignMsgModal(cmp,selectedTICR);
                    }
                }
                
            }else if(selectedPayRate == 'Assign their Existing Salary Exempt Cost Rate'){
                this.showExistingCRAssignMsgModal(cmp,'FTSalaryBenefits');
            }
        }else if(selectedPayRate == 'Create a new Cost Rate') {
            
            if((tiProjectCRDetailMap.perHrFFPBasedRateTypeLst).includes(tiproTaskDefaultCR)){
                
                if(tiproTaskDefaultCR == 'Non-SCA Translation (FFP)' || tiproTaskDefaultCR == 'Non-SCA Interpretation (FFP)'){
                    
                    crInputFields.showDate = true;
                    crInputFields.defaultCostRate = tiproTaskDefaultCR;
                    crInputFields.showFFP = true;
                    this.getCreationInputs(cmp,crInputFields);
                    
                }else{
                      
                    crInputFields.showDate = true;
                    crInputFields.defaultCostRate = tiproTaskDefaultCR;
                    crInputFields.showHC = true;
                    this.getCreationInputs(cmp,crInputFields);
                }         
                
            }else if(tiproTaskDefaultCR == 'Non-SCA Translation (Per Word)'){
                
                if(selectedTICR == 'Non-SCA Translation W/O Editing (Per Word)'){
                    
                    crInputFields.showDate = true;
                    crInputFields.defaultCostRate = selectedTICR;
                    crInputFields.perWordCost = true;
                    this.getCreationInputs(cmp,crInputFields);
                    
                }else if(selectedTICR == 'Non-SCA Translation Editing Only (Per Word)'){
                    cmp.set("v.displayRateTypeMsg",selectedTICR);
                    
                    crInputFields.showDate = true;
                    crInputFields.defaultCostRate = selectedTICR;
                    crInputFields.perWordCost = true;
                    this.getCreationInputs(cmp,crInputFields);
                    
                } else if(selectedTICR == 'Non-SCA Translation + Editing (Per Word)'){
                    cmp.set("v.displayRateTypeMsg",selectedTICR);
                    
                    crInputFields.showDate = true;
                    crInputFields.defaultCostRate = selectedTICR;
                    crInputFields.perWordCost = true;
                    this.getCreationInputs(cmp,crInputFields);    
                }
            }
        }
    },
    validateCRInputs : function(cmp,event,helper,crInputField,isValidInputs){
        var multiPayRateCR = cmp.get("v.multiPayRateCR");
        var cRPicklistBasedInput = cmp.get("v.cRPicklistBasedInput");
        var lcrmHourlyCost = '';
        
        if(multiPayRateCR && multiPayRateCR.lcrmHourlyCost){
            lcrmHourlyCost = parseFloat(multiPayRateCR['lcrmHourlyCost'].lcrmHourlyCost);
        }
        
        if(Array.isArray(crInputField)){
            for(var i = 0;i < crInputField.length;i++) {   
                if(!crInputField[i].get("v.value")) {
                    $A.util.addClass(crInputField[i], 'slds-has-error'); 
                    isValidInputs = false;
                }else {   
                    if(cRPicklistBasedInput.hourlyGreaterThanLCRMHourly){
                        if(lcrmHourlyCost > crInput.get("v.value")){
                            crInputField.setCustomValidity('Hourly Cost must be greater than $'+lcrmHourlyCost+'');
                            $A.util.addClass(crInputField[i], 'slds-has-error'); 
                            isValidInputs = false;
                        }else {
                            crInputField.setCustomValidity('');
                            $A.util.removeClass(crInputField[i], 'slds-has-error');
                        }
                    }else {
                        $A.util.removeClass(crInputField[i], 'slds-has-error');
                    }
                }
            }
        } else {
            if(!crInputField.get("v.value")){
                isValidInputs = false
                $A.util.addClass(crInputField, 'slds-has-error'); 
            }else{
                if(cRPicklistBasedInput.hourlyGreaterThanLCRMHourly){
                    if(lcrmHourlyCost > crInputField.get("v.value")){
                        crInputField.setCustomValidity('Hourly Cost must be greater than $'+lcrmHourlyCost+'');
                        $A.util.addClass(crInputField, 'slds-has-error'); 
                        isValidInputs = false;
                    }else {
                        crInputField.setCustomValidity('');
                        $A.util.removeClass(crInputField, 'slds-has-error');
                    }
                }else {
                    $A.util.removeClass(crInputField, 'slds-has-error');
                }
            }
        }
        return isValidInputs;
    },
    showOtherCRCreationModal : function(cmp, event, helper){
        
        cmp.set("v.showSpinner",true);
        var defaultCR = cmp.get("v.defaultCR");
        var parentObjName  =  cmp.get("v.parentObjName");
        var caRecord = cmp.get("v.caRecord");
        var contactId = '';
        
        if(caRecord && caRecord.Candidate_Name__c){
            contactId = caRecord.Candidate_Name__c;
        }
        
        var action = cmp.get("c.otherExistingCRInfo");
        var self = this;
        const server = cmp.find('server');
        server.callServer(
            action, {
                
                'defaultCR' : defaultCR,
                'parentRTName' : cmp.get("v.parentRTName"),
                'parentObjName' :parentObjName,
                'contactId' : contactId
            },
            false,
            $A.getCallback(function(response) {
                var result = response;
                var otherCRCreationMap = {};
                var crInputs = cmp.get("v.crInputValues");
                var parentRTName  = cmp.get("v.parentRTName");

                otherCRCreationMap.costRateMessage = result.costRateMessage;
                otherCRCreationMap.displayEffectiveDate = result.displayEffectiveDate;
                otherCRCreationMap.isFirstCR  = result.isFirstCR;
                otherCRCreationMap.crRequest  = result.createNewCR;
                otherCRCreationMap.isAlreadyCRExist = result.isAlreadyCRExist;
                otherCRCreationMap.contactRTName = result.contactRTName;
                cmp.set("v.otherCRCreationMap", otherCRCreationMap);
                console.log(result);
                
                if(parentObjName == 'AcctSeed__Project__c' && defaultCR == 'Non-SCA Testing' && parentRTName == 'Testing_Projects' 
                   && otherCRCreationMap.contactRTName == 'DLS_Employee'){
                    var costRateInfo = {};
                    
                    if(otherCRCreationMap.isAlreadyCRExist){
                        costRateInfo.costRateId = result.rateCardRate;
                        costRateInfo.costRateLabel = result.costLabel;
                        
                        cmp.set("v.displayRateTypeMsg",result.costRateMessage);
                        cmp.set("v.costRateInfo",costRateInfo);
                        cmp.set("v.showCRMessageModel",true);
                        cmp.find("showFinalCRMsg").open();
                    }else{
                        self.assignCRTOCAByEvent(cmp);
                    }
                    
                }else if((parentObjName == 'AcctSeed__Project__c' && defaultCR == 'Non-SCA Testing') 
                         || otherCRCreationMap.crRequest == true || otherCRCreationMap.displayEffectiveDate == true
                         || otherCRCreationMap.isAlreadyCRExist == false){
                    
                    if(otherCRCreationMap.isFirstCR){
                        crInputs.isFirstCR = otherCRCreationMap.isFirstCR;
                    }else {
                        crInputs.isFirstCR = false;
                    }
                    
                    crInputs.ftSalRt = false;
                    
                    if(otherCRCreationMap.isAlreadyCRExist == false && otherCRCreationMap.crRequest == false ){
                        otherCRCreationMap.showProceedBtn = false;
                    }else {
                         otherCRCreationMap.showProceedBtn = true;
                    }
                    
                    if((parentObjName == 'AcctSeed__Project__c' && defaultCR == 'Non-SCA Testing')){   
                        var nonSCATestingLCRPayType = {'selectedNonSCATestPay' : ''};
                      
                        if(parentObjName == 'AcctSeed__Project__c' && defaultCR == 'Non-SCA Testing') {
                            
                            nonSCATestingLCRPayType.testingPayTypeOption = [{'label':'--NONE--','value':''},
                                                                            {'label':'Per Hour','value':'Per Hour'},
                                                                            {'label':'Per Test','value':'Per Test'}];		
                            nonSCATestingLCRPayType.isTestingPayType = true;
                        }else {
                            nonSCATestingLCRPayType.isTestingPayType = false; 
                        }
                   
                    }
                    cmp.set("v.nonSCATestingLCRPayType",nonSCATestingLCRPayType); 
                    
                    cmp.set("v.crInputValues",crInputs);
                    cmp.set("v.otherCRCreationMap", otherCRCreationMap);
                    cmp.set("v.showCRCreationInputModal",true);
                    cmp.find("showInputModalId").open();
                }else{
                    var costRateInfo = {};
                    
                    if(otherCRCreationMap.isAlreadyCRExist){
 
                        costRateInfo.costRateId = result.rateCardRate;
                        costRateInfo.costRateLabel = result.costLabel;
                        
                        cmp.set("v.displayRateTypeMsg",result.costRateMessage);
                        cmp.set("v.costRateInfo",costRateInfo);
                        cmp.set("v.showCRMessageModel",true);
                        cmp.find("showFinalCRMsg").open();
                    }else{
                        if(result.createCAWithoutCR){
                            costRateInfo.createCAWithoutCR = result.createCAWithoutCR;
                            cmp.set("v.costRateInfo",costRateInfo);
                        }
                        self.assignCRTOCAByEvent(cmp);
                    }
                }
                
                cmp.set("v.showSpinner", false);
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false); 
                cmp.set("v.showErrorMsg",  errors[0].message);  
                cmp.set("v.isShowErrorModal",true);
                cmp.find("errorModal").open();
            }),
            false,
            false,
            false
        );
    },// Create CostRate Record
    createCRRecord : function(cmp, event, helper){
        var defaultCR = cmp.get("v.defaultCR");
        var crInputs  = cmp.get("v.crInputValues")
        var crInputsJSON = JSON.stringify(crInputs);
        var parentObjName  =  cmp.get("v.parentObjName");
        var nonSCATestingLCRPayType = cmp.get("v.nonSCATestingLCRPayType");
        var modifyLTPrepRTLabel = cmp.get("v.modifyLTPrepRTLabel");
        var caRecord = cmp.get("v.caRecord");
        var projectId = '';
        var contactId = '';
        var isAccRelCR = cmp.get("v.isAccRelatedCR");
        var accountId = '';
        
        if(modifyLTPrepRTLabel != null && modifyLTPrepRTLabel[defaultCR]){
            defaultCR = modifyLTPrepRTLabel[defaultCR];
        }

        if(caRecord){
            if(caRecord.Project__c){
                projectId = caRecord.Project__c;
            }
            if(caRecord.Candidate_Name__c){
                contactId = caRecord.Candidate_Name__c;
            }
            if(caRecord.Account__c){
                accountId = caRecord.Account__c;
            }
        }
        
        if(isAccRelCR && (caRecord.Assignment_Position__c == 'Partner School EI' || caRecord.Assignment_Position__c  == 'Partner School Instructor')){
            defaultCR ='SubK-LT';  
        }


        cmp.set("v.showSpinner",true);
        cmp.set("v.visibleError",'slds-hide');
        console.log(crInputsJSON);
        var self = this;
        var action = cmp.get("c.createLaborCR");
        const server = cmp.find('server');
        server.callServer(
            action, {
                'defaultCR' : defaultCR,
                'projectId' : projectId,
                'costRateInputJSON' : crInputsJSON,
                'contactId' : contactId,
                'accountId' : accountId,
                'isAccRelCR': isAccRelCR
            },
            false,
            $A.getCallback(function(response) {
                var result = response;
                var cRArray = JSON.parse(result);
                console.log(response);
                if(cRArray.length > 0){
                    var costRateInfo = {};
                    
                    if(parentObjName == 'AcctSeed__Project__c'  && defaultCR == 'Non-SCA Testing' && nonSCATestingLCRPayType.selectedNonSCATestPay == 'Per Hour' 
                     																			  &&  crInputs.noHrsExcepted){
                        costRateInfo.nohrsExcepted = crInputs.noHrsExcepted;
                    }
                    costRateInfo.costRateId = cRArray[0].Id;
                    
                    if(cRArray[0].Status__c == 'Approved'){
                        costRateInfo.costRateLabel = 'RateCost';   
                    }else {
                        costRateInfo.costRateLabel = 'LaborCost';
                    }
                   cmp.set("v.costRateInfo",costRateInfo) ;
                }
                self.assignCRTOCAByEvent(cmp);
                cmp.set("v.showSpinner", false);
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false); 
                console.log(":::::::::::::::::cost rate creation error:::::::::::::",errors);
                
                if(errors[0].message){
                    cmp.set("v.showErrorMsg",  errors[0].message);   
                }else if(errors[0].fieldErrors && errors[0].fieldErrors && errors[0].fieldErrors.AcctSeed__Hourly_Cost__c){
                     cmp.set("v.showErrorMsg",errors[0].fieldErrors.AcctSeed__Hourly_Cost__c[0].message);  
                }
                          
                cmp.set("v.visibleError",'slds-show');
            }),
            false,
            false,
            false
        );        
       
        
    },// show CR Message Modal
    showExistingCRAssignMsgModal : function(cmp,costRateName){
        var existingCostRateMap = cmp.get("v.multiPayRateCR");
        var costRateInfo = {};

        if(costRateName != null){
            if(existingCostRateMap[costRateName] && existingCostRateMap[costRateName].isApproved == false){
                costRateInfo.costRateId = existingCostRateMap[costRateName].crId;
                costRateInfo.costRateLabel = 'LaborCost';
            }else if(existingCostRateMap[costRateName] && existingCostRateMap[costRateName].isApproved == true){
                costRateInfo.costRateId = existingCostRateMap[costRateName].crId;
                costRateInfo.costRateLabel = 'RateCost';  
            }
            
            cmp.set("v.costRateInfo",costRateInfo);
            cmp.set("v.showCROptionModal", false);
            cmp.set("v.displayRateTypeMsg",existingCostRateMap[costRateName].costRateMsg);
            cmp.set("v.showCRMessageModel",true);
            cmp.find("showFinalCRMsg").open();
        }
    }, // Event to update CR value to CA
    assignCRTOCAByEvent : function(cmp){
        
        var cmpEvent = cmp.getEvent("assignCostRateTOCA");
        var costRateInfo = cmp.get("v.costRateInfo");

        cmp.set("v.showSpinner",true);
        cmpEvent.setParams({
            "costRateInfo" :costRateInfo
        });
        cmpEvent.fire();
    },
    //W-006039 -  Process change when DLI projects are sub-contracted
    showAccRelCRCreationModal: function(cmp, event, helper){
        var otherCRCreationMap = {};
        var costRateInfo = {};
        
        otherCRCreationMap.costRateMessage = 'Please enter Effective Date and Hourly Cost to create a "SubK-LT" Type Cost Rate. If you have any questions, please contact HR.';
        otherCRCreationMap.displayEffectiveDate = true;
        otherCRCreationMap.crRequest = true;
        otherCRCreationMap.isAlreadyCRExist = false;
        
        if(otherCRCreationMap.crRequest == true || otherCRCreationMap.displayEffectiveDate == true
           || otherCRCreationMap.isAlreadyCRExist == false){
            
            if(otherCRCreationMap.isAlreadyCRExist == false && otherCRCreationMap.crRequest == false ){
                otherCRCreationMap.showProceedBtn = false;
            }else {
                otherCRCreationMap.showProceedBtn = true;
            }
            
            cmp.set("v.otherCRCreationMap", otherCRCreationMap);
            cmp.set("v.showCRCreationInputModal",true);
            cmp.find("showInputModalId").open();
        }
    },
    viewConOrAccRelatedCR : function(cmp, event, helper, isConRelCR) {
        
        cmp.set("v.showSpinner",true);
        var caRecord = cmp.get("v.caRecord");
        var contactId = '';
        var accountId = '';
        
        if(isConRelCR){
        if(caRecord.Candidate_Name__c){
            contactId = caRecord.Candidate_Name__c;
        }
        }else{
            if(caRecord.Account__c){
                accountId = caRecord.Account__c;
            } 
        }
        
        var action = cmp.get("c.getContactOrAccountRelCR");      
        var self = this;
        const server = cmp.find('server');
        server.callServer(
            action, {
                'contactId': contactId,
                'isConRelCR': isConRelCR,
                'accountId' : accountId
            },
            false,
            $A.getCallback(function(response) {
                var conOrAccRelCRRecords = response;

                for(var i = 0;i < conOrAccRelCRRecords.length;i++ ){
                    var FullyLoadedRate = typeof(conOrAccRelCRRecords[i].Fully_Loaded_Rate__c);
                    var efDate = [];
                    
                    efDate = (conOrAccRelCRRecords[i].Effective_Date__c).split('-');
                    conOrAccRelCRRecords[i].Effective_Date__c = (efDate[1] + "/" + efDate[2] + "/" + efDate[0]);
                    
                    if(FullyLoadedRate == 'number'){
                        conOrAccRelCRRecords[i].Fully_Loaded_Rate__c = '$'+conOrAccRelCRRecords[i].Fully_Loaded_Rate__c;
                    }
                }
                cmp.set("v.conOrAccRelCRRows",conOrAccRelCRRecords);
                console.log(conOrAccRelCRRecords);
                self.contactOrAccountRelCRTable(cmp,event,helper);
                cmp.set("v.showSpinner", false);
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false); 
                cmp.set("v.showErrorMsg",  errors[0].message);            
                cmp.set("v.visibleError",'slds-show');
            }),
            false,
            false,
            false
        );
    },
     // Event to show error message in parent component
    showPTLanguageValidation : function(cmp){
        
        var cmpEvent = cmp.getEvent("ErrorLogEvt");
        
        cmp.set("v.showSpinner",false);
        cmpEvent.setParams({
            "errorMsg" : 'Please populate Language for this Opportunity/Project'
        });
        cmpEvent.fire();
    },
    ftPtSalaryoptions : function(cmp,multiPayRateCR,crRateTypeOptions){
        
        if((multiPayRateCR['FT Hourly & Benefits']) && multiPayRateCR['FT Hourly & Benefits'].isSelectedVal == true){
            crRateTypeOptions.push({'label': 'Assign Existing FT Hourly & Benefits Rate', 'value':'Assign Existing FT Hourly & Benefits Rate'});
        } 
        
        if((multiPayRateCR['PT Hourly (OH & G&A)']) && multiPayRateCR['PT Hourly (OH & G&A)'].isSelectedVal == true){
            crRateTypeOptions.push({'label': 'Assign Existing PT Hourly (OH & G&A) Rate', 'value':'Assign Existing PT Hourly (OH & G&A) Rate'});
        } 
    }
})