({
	validateCR : function(cmp) {
        var action = cmp.get("c.getPermissionAccess");
        action.setParams({
            lcrRateType: cmp.get("v.simpleRecord.Rate_Type__c")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                cmp.set("v.crInfo",result);
                var rateType = cmp.get("v.simpleRecord.Rate_Type__c");
                var payRateInfo = cmp.get("v.payRateInfo");
                var permmissionAccess = result.isPermissionAccess;
                var rateTypeSet = ['LT with Prep','LT without Prep','Non-SCA CD','Non-SCA CD (1099)', 'FT Hourly & Benefits', 'PT Hourly (OH & G&A)', 'FT Salary & Benefits','International Salary','Non-SCA LT','DLI-W LT','DODA PS','DLI-W PS - Group 3','DLI-W PS - Group 4','FSI'];
                
        		if((!rateTypeSet.includes(rateType)) && permmissionAccess == false) {
                    cmp.set("v.showMessage",true);
                    cmp.set("v.card",{'title' : 'Warning', 'message' : 'This process can only be done for LT, DLI-W LT, Non-SCA CD, Non-SCA CD (1099), FT Hourly & Benefits, PT Hourly (OH & G&A), FT Salary & Benefits and International Salary Rate Types and You don\'t have sufficient privileges to perform this action, Please contact HR.', 'buttonName' : 'Close'});
                } else if(!rateTypeSet.includes(rateType)) {
                    cmp.set("v.showMessage",true);
                    cmp.set("v.card",{'title' : 'Warning', 'message' : 'This process can only be done for LT, DLI-W LT, Non-SCA CD, Non-SCA CD (1099), FT Hourly & Benefits, PT Hourly (OH & G&A) , FT Salary & Benefits and International Salary Rate Types.', 'buttonName' : 'Close'});
                } else if(permmissionAccess == false) {
					cmp.set("v.showMessage",true);
                    cmp.set("v.card",{'title' : 'Warning', 'message' : 'You don\'t have sufficient privileges to perform this action, Please contact HR.' ,'buttonName' : 'Close'});
                } else {
                    cmp.set("v.showMessage",false);
                    cmp.set("v.effectiveDate", result.currentDate);
                    
                    if(result.isShowFTPTOptions){
                        payRateInfo.showFTPTPickListPage = true;
                        cmp.set("v.fTPTOptions",result.showFTPTPickList);
                    }else{
                        payRateInfo.showInPutsPage = true;
                    }
                    
                    if(rateType == 'LT' || rateType == 'Non-SCA LT' || rateType == 'DLI-W LT'){
                        payRateInfo.fullyLoadedFlag = true;
                    }
                    cmp.set("v.payRateInfo",payRateInfo);
                }
                cmp.set("v.showSpinner",false);
            }else{
                cmp.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
	},
    validateInputs : function(cmp,event,helper) {
        var crInputfield = cmp.find("crInputs");
        var crInput = cmp.find("crInput");
        var isValidInputs = true;
      
            if(!crInput.get("v.value")) {
                $A.util.addClass(crInput, 'slds-has-error'); 
            	isValidInputs = false;
            } else {
                $A.util.removeClass(crInput, 'slds-has-error');
            }
        
        
        if(Array.isArray(crInput)){
            for(var i = 0;i < crInput.length;i++) { 
                if(!crInput[i].get("v.value")){
                    isValidInputs = false;
                    $A.util.addClass(crInput[i], 'slds-has-error'); 
                }else {
                    $A.util.removeClass(crInput[i], 'slds-has-error'); 
                }
            }
        }else{
            if(!crInput.get("v.value")) {
                $A.util.addClass(crInput, 'slds-has-error'); 
                isValidInputs = false;
            } else {
                $A.util.removeClass(crInput, 'slds-has-error');
            }
        }
        
        if(Array.isArray(crInputfield)){                
            for(var i = 0;i < crInputfield.length;i++) {   
                if(!crInputfield[i].get("v.value")) {
                    crInputfield[i].set("v.errors", [{message:""}]);
                    isValidInputs = false;
                }else {   
                    crInputfield[i].set("v.errors", null);
                }
            }
        }else{
            if(!crInputfield.get("v.value")) {
                crInputfield.set("v.errors", [{message:""}]);
                isValidInputs = false;
            }else {   
                crInputfield.set("v.errors", null);
            } 
        }
        return isValidInputs;
    }
})