({
    updateValues : function(cmp, event, helper) {
        var annualSal = cmp.get("v.annualSalCost");
        if(annualSal){ 
            annualSal = annualSal.replaceAll(',','');
            console.log('annual sal',cmp.get("v.annualSalCost"));
            cmp.set("v.salaryCostperHour",(annualSal/2080).toFixed(2));
            cmp.set("v.salaryCostperPeriod",(annualSal/24).toFixed(2));
        }
    },
    proceedClk : function(cmp, event, helper) {
     var isValidInputs = helper.validateInputs(cmp, event, helper);
        
        if(isValidInputs) {
            var payRateInfo = cmp.get("v.payRateInfo");
            
            payRateInfo.showChangeINPickListPage = true;
            payRateInfo.showInPutsPage = false;
            cmp.set("v.payRateInfo",payRateInfo);
        }
    },
    modifyPayRate : function(cmp, event, helper) {
        var isValidInputs = true
        var payRateInfo = cmp.get("v.payRateInfo");
        var crInfo = cmp.get("v.crInfo");
        var selectedUser = cmp.get("v.selectedUser");

        
        if(payRateInfo.showInPutsPage){
            isValidInputs = helper.validateInputs(cmp, event, helper);
        }else{
            if(crInfo.showJobTitle){
                var titleId = cmp.find("titleId");
                if(!titleId.get("v.value")) {
                    $A.util.addClass(titleId, 'slds-has-error'); 
                    isValidInputs = false;
                } else {
                    $A.util.removeClass(titleId, 'slds-has-error');
                }
            }
            
            if(crInfo.showNewDepartment){
                var homeDept = cmp.find("homeDept");
                if(!homeDept.get("v.value")) {
                    $A.util.addClass(homeDept, 'slds-has-error'); 
                    isValidInputs = false;
                } else {
                    $A.util.removeClass(homeDept, 'slds-has-error');
                }
            }
            
            if(crInfo.showNewManager){
                var userLookup = cmp.find("userLookup");
                
                if(selectedUser && selectedUser.length == 0){
                    isValidInputs = false;
                    $A.util.addClass(userLookup, 'slds-has-error');
                }else{
                    $A.util.removeClass(userLookup, 'slds-has-error');
                }
            }
        }
        if(isValidInputs) {
            cmp.set("v.showSpinner",true);
            var action = cmp.get("c.modifyCostRates");
            var fTPTOptions = cmp.get("v.fTPTOptions");
            var crRecord = cmp.get("v.simpleRecord");
            var conId = crRecord.Contact__c;
            
            var crRec = JSON.parse(JSON.stringify(crRecord));
            var conRecToUpdate = [];
            var conRec = {};
            
            crRec.Payroll_Item__c = null;
            crRec.Exempt_Status__c = null;
            crRec.Rate_Type_Label__c = null;
            crRec.Pay_Type__c = null;
            crRec.Annual_Salary_Cost__c = null;
            crRec.Salary_Cost_Per_Hour__c = null;
            crRec.Semi_Monthly_Salary_Cost__c = null;
            crRec.AcctSeed__Hourly_Cost__c = null;
            crRec.Cost_Rate_Name__c = null;
            
            if(crRec.Rate_Type__c == 'Non-SCA LT'){
                crRec.Rate_Type__c = 'LT';
            }
            var hourlyCost = cmp.get("v.hourlyCost");
            
            if(hourlyCost && hourlyCost.includes(",")){
                hourlyCost = hourlyCost.replaceAll(',','');
            }
            
            if(fTPTOptions.includes(cmp.get("v.selectedFTPT"))){
                crRec.Rate_Type__c = cmp.get("v.selectedFTPT");
                if(cmp.get("v.selectedFTPT") == 'FT Salary & Benefits' || cmp.get("v.selectedFTPT") == 'International Salary') {
                    crRec.Annual_Salary_Cost__c = (cmp.get("v.annualSalCost")).replaceAll(',',''); 
                    crRec.Salary_Cost_Per_Hour__c =  cmp.get("v.salaryCostperHour");  //hCost/2080;
                    crRec.Semi_Monthly_Salary_Cost__c = cmp.get("v.salaryCostperPeriod");  //hCost/24;
                }else {
                    crRec.AcctSeed__Hourly_Cost__c = hourlyCost;
                    crRec.Salary_Cost_Per_Hour__c = hourlyCost;
                }
            }else{
                crRec.AcctSeed__Hourly_Cost__c = hourlyCost;
            }
            
            crRec.Effective_Date__c = cmp.get("v.effectiveDate");;
            crRec.Notes_Reasons_for_Change__c = cmp.get("v.reasonForChange");
            
            
            if(fTPTOptions.includes(crRec.Rate_Type__c)){
                crRec.New_Job_Title__c = crInfo.showJobTitle;
                crRec.Change_in_Reporting_New_Manager__c = crInfo.showNewManager;
                crRec.New_Department__c = crInfo.showNewDepartment;
                crRec.Promotion__c = crInfo.showPromotion;
                crRec.Transfer_Reassignment__c = crInfo.showtransferAssignment;
                
                if(crInfo.nextReviewDate){
                    crRec.Next_Performance_Review_Date__c = crInfo.nextReviewDate;
                }
                
                if(crInfo.leaveAbsenceReason != null){
                    crRec.Leave_of_Absence_Reason__c = crInfo.leaveAbsenceReason;
                }
                
                if(crInfo.benefitchangesReason != null){
                    crRec.Benefit_Changes_Reason__c = crInfo.benefitchangesReason;
                }
                
                if(crInfo.otherReasons != null){
                    crRec.Other_Please_Provide_Specifics__c = crInfo.otherReasons;
                }

                if(crInfo.selectedChangeINSalaryValues){
                    crRec.Change_in_Salary__c = crInfo.selectedChangeINSalaryValues; 
                }else{
                    crRec.Change_in_Salary__c = []; 
                }

                if(crInfo.selectedIncentiveCompValues){
                    crRec.Incentive_Compensation__c = crInfo.selectedIncentiveCompValues; 
                }else{
                    crRec.Incentive_Compensation__c = []; 
                }
                
                if(crInfo.selectedChangeinEmployValues){
                    crRec.Change_in_Employment_Category__c	 = crInfo.selectedChangeinEmployValues; 
                }else{
                    crRec.Change_in_Employment_Category__c	 = null; 
                }
                
                if(crRec.Contact__c){
                    conRec.Id = crRec.Contact__c;
                    conRec.EE_Pay_Status_Eff_Date__c = cmp.get("v.effectiveDate");
                    
                    if(crInfo.showJobTitle){
                        conRec.Title = cmp.get("v.newJobTitle");
                    }
                    
                    if(crInfo.showNewManager && selectedUser.length > 0){
                        conRec.Supervisor_Name__c = selectedUser[0].Id;
                    }
                    
                    if(crInfo.showNewDepartment){
                        conRec.Home_Dept__c = cmp.get("v.selectedHomeDept");
                    }

                    conRecToUpdate.push(conRec);
                }
            }
            
            console.log('crRec',crRec);
            console.log('conRecToUpdate',conRecToUpdate);
            
            action.setParams({
                crRec: crRec,
                conRecToUpdate: conRecToUpdate,
                conId: conId
            });
            action.setCallback(this, function(response) {
                console.log('response::::',response);
                var state = response.getState();
                if(state === "SUCCESS") {
                    var returnStr = response.getReturnValue();
                    console.log('returnStr::::',returnStr);
                    
                    cmp.set("v.showSpinner",false);
                    var navigateToCR = $A.get("e.force:navigateToSObject");
                    navigateToCR.setParams({
                        "recordId": returnStr,
                        "slideDevName": "detail"
                    });
                    navigateToCR.fire();
                } else {
                    var errors = response.getError();
                    cmp.set("v.showSpinner",false);
                    cmp.set("v.showMessage",true);
                    console.log(errors);
                    cmp.set("v.card",{'title' : 'Error', 'message' :errors[0].message ,'buttonName' : 'Close'});
                }
            });
           $A.enqueueAction(action); 
        }
    },
    closeAction : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    },
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            // record is loaded (render other component which needs record data value)
            console.log("Record is loaded successfully.");
            console.log("You loaded a record in " +component.get("v.simpleRecord.Contact__c"));
            component.set("v.showSpinner",true);
            helper.validateCR(component);
        } else if(eventParams.changeType === "CHANGED") {
            // record is changed
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },
    displayInputs : function(cmp, event, helper) {
        var rateOption = cmp.find("rateOption");
        var isValid = true;
        
        if(!rateOption.get("v.value")) {
            $A.util.addClass(rateOption, 'slds-has-error');
            isValid = false;
        }else {
            $A.util.removeClass(rateOption, 'slds-has-error');
        }
        
        if(isValid){ 
            var payRateInfo = cmp.get("v.payRateInfo");
            
            payRateInfo.showFTPTPickListPage = false;
            payRateInfo.showInPutsPage = true;
            cmp.set("v.payRateInfo",payRateInfo);
        }
    },
     userLookupSearch : function(component, event, helper) {
        // Get the search server side action
        const serverSearchAction = component.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        component.find('userLookup').search(serverSearchAction);
    },
     getFullyLoadedValues : function(component,event,helper){
         var rateType = component.get("v.simpleRecord.Rate_Type__c");
         
         if(rateType == 'LT without Prep' ||  rateType == 'LT with Prep' || rateType == 'Non-SCA LT' || rateType == 'DLI-W LT'){
             
             var hourlyCost = component.get("v.hourlyCost");
             var defaultCR = component.get("v.defaultCR");
             var fullyLoadedAmt = 0.00;
             var sickLeave = $A.get("$Label.c.LT_Sick_Leave_Rate");
             
             if(hourlyCost && sickLeave){
                 var sumOfVal = (parseFloat(sickLeave) * parseFloat(hourlyCost)).toFixed(2);
                 fullyLoadedAmt = (parseFloat(sumOfVal) + parseFloat(hourlyCost)).toFixed(2);;
             }
             component.set("v.fullyLoadedAmt",fullyLoadedAmt);
         }
    }
})