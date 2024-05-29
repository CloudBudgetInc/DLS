({
	loadCongaTemplates : function(component, event, helper) {
        var sObjectName = component.get("v.sObjectName");
        var recId = null;
        console.log('Simple Record::::::',component.get("v.record"));
        console.log('Object Name::::::',component.get("v.sObjectName"));
        
        component.set("v.showSpinner",true);
        if(sObjectName == 'Contact_Assignments__c') {
            if(component.get("v.record.Rate_Card_Rate__c") != null) {
            	recId = component.get("v.record.Rate_Card_Rate__c");
        	} else if(component.get("v.record.Drafted_Labor_Cost_Rate__c") != null) {
                recId = component.get("v.record.Drafted_Labor_Cost_Rate__c");
            } else {
                component.set("v.showMessage",true);
                component.set("v.card",{'title' : 'Warning', 'message' : 'Please assign a rate card', 'buttonName' : 'Close'});
            } 
        } else if(sObjectName == 'AcctSeed__Cost_Rates__c') {
            recId = component.get("v.recordId");
        }
        
        if(component.get("v.launchedFrom") == "Docusign") {
            component.set("v.buttonName", "Gen & Send Conga Sign");
        } else if(component.get("v.launchedFrom") == "Gen_Form") {
            component.set("v.buttonName", "Generate Form");
        }
        
        if(recId != null ) {
            component.set("v.costRateId",recId);
            var action = component.get("c.getCostRateRecord");
            action.setParams({
                "crId":recId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state === "SUCCESS"){
                    component.set("v.showSpinner",false);
                    var crRecs = response.getReturnValue();
                    console.log('default value::',crRecs);
                    
                    if(crRecs["rateType"]) {
                        component.set("v.rateType",crRecs["rateType"]);
                    }
                    
                    if(crRecs["exempt_Status"]) {
                        component.set("v.exempt_Status",crRecs["exempt_Status"]);
                    }
                    
                    if(crRecs['IndependentContractorName']){
                        component.set("v.independContractorName",crRecs['IndependentContractorName'])
                    }
                    
                    if(crRecs["templateName"]) {
                        component.set("v.defaultVal",crRecs["templateName"]);
                        component.set("v.fieldVal",crRecs["templateName"]);
                    }
                    
                    if(crRecs["getProjectWithCAIdMap"]){
                        var projectMap = JSON.parse(crRecs.getProjectWithCAIdMap);
                        var projectKeyList =  Object.keys(projectMap);
                        var projectList = [];
                        
                        projectList.push({'label':'--None--','value':''});
                        for(var i = 0;i < projectKeyList.length;i++){
                            projectList.push({'label':(projectMap[projectKeyList[i]]),'value':projectKeyList[i]});
                        }
                        component.set("v.projectList",projectList);
                    }
                    
                    if(crRecs["getProjectOPPWithCAIdMap"]){
                        var projectOppMap = JSON.parse(crRecs.getProjectOPPWithCAIdMap);
                        var projectOppKeyList =  Object.keys(projectOppMap);
                        var projectOppList = [];
                        
                        projectOppList.push({'label':'--None--','value':''});
                        for(var i = 0;i < projectOppKeyList.length;i++){
                            projectOppList.push({'label':(projectOppMap[projectOppKeyList[i]]),'value':projectOppKeyList[i]});
                        }
                        component.set("v.projectOppList",projectOppList);
                    }
                    
                    if(crRecs["rateType"]) {
                        var rateType = crRecs["rateType"];
                        var options = [];
                        
                        if(sObjectName == 'AcctSeed__Cost_Rates__c') {
                            if(rateType == 'DLI-21 SCA CD' || rateType == 'DLI-21 SCA LT') {
                                options = [
                                    //  {value:"Offer Letter - DLI-W new and LT", label:"Offer Letter - DLI-W new and LT"},
                                    {value:"Offer Letter - DLI-W New Contract - SCA", label:"Offer Letter - DLI-W New Contract - SCA"},
                                    {value:"Pay Rate Addendum", label:"Pay Rate Addendum"}
                                ];
                            } else if(rateType == 'Non-SCA Testing') {
                                options = [
                                    {value:"Offer Letters - Tester", label:"Offer Letters - Tester"},
                                    {value:"Pay Rate Addendum", label:"Pay Rate Addendum"}
                                ];
                                
                            } else if(rateType == 'FSI') {
                                options = [];
                                if(crRecs["templateName"] == 'FSI Offer Letter' || crRecs["templateName"] == 'Pay Rate Modification' || crRecs["templateName"] == 'Pay Rate Addendum'){
                                    
                                    if(crRecs["templateName"] == 'Pay Rate Modification'){
                                        options.push({value:"Pay Rate Modification", label:"Pay Rate Modification"});
                                        options.push({value:"Pay Rate Addendum", label:"Pay Rate Addendum"});
                                    }else if(crRecs["templateName"] == 'Pay Rate Addendum'){
                                        options.push({value:"Pay Rate Addendum", label:"Pay Rate Addendum"});
                                    }
                                    
                                    options.push({value:"FSI Offer Letter", label:"FSI Offer Letter"});
                                    options.push({value:"FSI Letter of Intent", label:"FSI Letter of Intent"});
                                    options.push({value:"PT FSI Offer Letter", label:"PT FSI Offer Letter"});
                                    options.push({value:"PT FSI Letter of Intent", label:"PT FSI Letter of Intent"});
                                }
                            } else if(rateType == 'DLI-21 SCA MTT') {
                                options = [
                                    {value:"MTT ICA", label:"MTT ICA"},
                                    {value:"Pay Rate Addendum", label:"Pay Rate Addendum"}
                                ];
                            } else if (rateType == 'LT with Prep' || rateType == 'LT without Prep' || rateType == 'Non-SCA CD' || rateType == 'Non-SCA LT-S' || rateType == 'DLI-W LT') {
                                options = [
                                    {value:"Offer Letter - Instructors LT", label:"Offer Letter - Instructors LT"},
                                    {value:"Pay Rate Addendum", label:"Pay Rate Addendum"}
                                ];
                                if(rateType != 'Non-SCA LT-S') {
                                    options.push({value:"Pay Rate Modification", label:"Pay Rate Modification"});
                                }
                                
                            } else if(rateType == 'Non-SCA CD (1099)' || rateType == 'DLI-21 SCA CD (1099)') {
                                options = [
                                    {value:"ICA DLI-W 2017", label:"ICA DLI-W 2017"}
                                ];
                                if( rateType == 'Non-SCA CD (1099)') {
                                    options.push({value:"Pay Rate Modification", label:"Pay Rate Modification"});
                                }
                            } else if(rateType == 'FT Salary & Benefits') {
                                options = [
                                    {value:"Offer Letter - Staff - Exempt", label:"Offer Letter - Staff - Exempt"},
                                    {value:"Change of Status Form", label:"Change of Status Form"}
                                ];
                            } else if(rateType == 'Non-SCA Translation (Per Hour)' || rateType == 'Non-SCA Translation (FFP)' || rateType == 'Non-SCA Translation W/O Editing (Per Word)' || rateType == 'Non-SCA Translation Editing Only (Per Word)' || rateType == 'Non-SCA Translation + Editing (Per Word)' || rateType == 'Non-SCA Interpretation (Per Hour)') {
                                options = [
                                    {value:"Translation and Interpretation ICA", label:"Translation and Interpretation ICA"},
                                    {value:"Translation and Interpretation Addendum to ICA", label:"Translation and Interpretation Addendum to ICA"}
                                ];
                            } else if(rateType == 'PT Hourly (OH & G&A)' || rateType == 'FT Hourly & Benefits') {
                                options = [
                                    {value:"Change of Status Form", label:"Change of Status Form"},
                                    {value:"Offer Letter - Staff - Non-Exempt", label:"Offer Letter - Staff - Non-Exempt"}
                            	];
                            }else if(rateType == 'International Salary') {
                                options = [{value:"Offer Letter - UAE Template", label:"Offer Letter - UAE Template"},
                                           {value:"Change of Status Form", label:"Change of Status Form"}]; 
                            }else{
                                component.set("v.showMessage",true);
                                component.set("v.card",{'title' : 'Warning', 'message' : 'Offer Letter Process is not available for '+rateType+' Rate Type.', 'buttonName' : 'Close'});

                            }
                        } else if(sObjectName == 'Contact_Assignments__c') {
                            if(rateType == 'DLI-21 SCA MTT') {
                                options = [
                                        {value:"MTT ICA", label:"MTT ICA"},
                                        {value:"Pay Rate Addendum", label:"Pay Rate Addendum"}
                                ];
                            } else {
                                component.set("v.showMessage",true);
                				component.set("v.card",{'title' : 'Warning', 'message' : 'You can Generate offer letter for "DLI-21 SCA MTT" Cost Rate using Contact Assignment. Please go to Cost Rate record to generate for other types.', 'buttonName' : 'Close'});
                            }
                        } 
                        component.set("v.congaTemplates",options);
                        console.log('options::::::',options);
                    }
                } else {
                    component.set("v.showSpinner",false);
                    console.log('::::::error:::',response.getError()[0].message);
                }
            });
            $A.enqueueAction(action);
        }
	},
    handleClick : function(cmp, event, helper) { 
        var userHRObjLookup = cmp.get("v.userHRObjLookup");
        var userDlsExecObjLookup = cmp.get("v.userDlsExecObjLookup");
        var signerValMap = cmp.get("v.signerValMap");
        var signerInfoMap = cmp.get("v.signerMap");
        var userObjLookup = cmp.get("v.userObjLookup");
        var launchedFrom = cmp.get("v.launchedFrom");
        
        var isValid = true;
        var signer2Staff = '';
        var signer3Staff = '';
        var tempSelectedValue = cmp.get("v.defaultVal");
        var fsiOfferLetters = ['FSI Offer Letter','PT FSI Offer Letter','FSI Letter of Intent','PT FSI Letter of Intent'];
        var exempt_Status = cmp.get("v.exempt_Status");

        
        if(tempSelectedValue == 'Change of Status Form' && launchedFrom == "Docusign"){
            
            if(userHRObjLookup.length > 0){
                signer2Staff = userHRObjLookup[0].Id;
                signerInfoMap['signer2Staff'] = signer2Staff;
                cmp.set("v.signerMap",signerInfoMap);
            }else if(signerValMap && signerValMap['signer2Staff'] != null){
                signer2Staff = signerValMap.signer2Staff;
            }
            
            if(userDlsExecObjLookup.length > 0){
                signer3Staff = userDlsExecObjLookup[0].Id;
            }else if(signerValMap && signerValMap['signer3Staff'] != null){
                signer3Staff = signerValMap.signer3Staff;
            }
            
            
            if((!signer2Staff) && (!signer3Staff) && (signerValMap['isValidHRUser'] && signerValMap['isValidDlsExecUser'])){
                helper.getSignerInfoHelper(cmp,event,helper);
                isValid = false;
            }else{
                if((!signer2Staff) || (!signer3Staff) && ((!signerValMap['isValidHRUser']) || (!signerValMap['isValidDlsExecUser']))){
                    var hrUserInput = cmp.find("hrUserId");
                    var dlsUserInput = cmp.find("dlsUserId");
                    
                    if(userHRObjLookup.length == 0){
                        isValid = false;
                        $A.util.addClass(hrUserInput, 'slds-has-error'); 
                    }else {
                        $A.util.removeClass(hrUserInput, 'slds-has-error');
                    }
                    
                    if(userDlsExecObjLookup.length == 0){
                        isValid = false;
                        $A.util.addClass(dlsUserInput, 'slds-has-error'); 
                    }else {
                        $A.util.removeClass(dlsUserInput, 'slds-has-error');
                    }
                }
                
            }
        }
        
        if(tempSelectedValue == 'Pay Rate Addendum' || (fsiOfferLetters.includes(tempSelectedValue) || (tempSelectedValue == 'Offer Letter - Staff - Non-Exempt' && exempt_Status == 'Non-Exempt'))){
            var proInput = cmp.find("selectProject");
            var userInput = cmp.find("userId");
            
            if(Array.isArray(proInput)){
                for(var i = 0;i < proInput.length;i++) { 
                    if(!proInput[i].get("v.value")){
                        isValid = false;
                        $A.util.addClass(proInput[i], 'slds-has-error'); 
                    }else {
                        $A.util.removeClass(proInput[i], 'slds-has-error'); 
                    }  
                }
            }else {
                if(!proInput.get("v.value")){
                    isValid = false;
                    $A.util.addClass(proInput, 'slds-has-error'); 
                }else {
                    $A.util.removeClass(proInput, 'slds-has-error');
                }
            }
            
            if(tempSelectedValue == 'Pay Rate Addendum'){
                if(userObjLookup.length == 0){
                    isValid = false;
                    $A.util.addClass(userInput, 'slds-has-error'); 
                }else {
                    $A.util.removeClass(userInput, 'slds-has-error');
                }
            }
        }
        
        if(isValid){
            helper.launchConga(cmp,event,helper,signer2Staff,signer3Staff)
        }
    },
    handleSelectedTemp : function(component, event, helper) {
        console.log(component.get("v.defaultVal"));
        component.set('v.selectedCAId','');
    },
    closeAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    userLookupSearch : function(cmp ,event,helper){
       const serverSearchAction = cmp.get('c.getLookupRecords');
       event.getSource().search(serverSearchAction);
    }
   
})