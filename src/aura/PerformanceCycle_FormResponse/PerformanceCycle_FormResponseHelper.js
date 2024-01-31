({
    getAllFormResponseElementsAndFormTemplateElements : function(cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        var action = cmp.get("c.getAllFormResElementsAndFormTempElements");
        action.setParams({ formResponseId : cmp.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set('v.showSpinner', false);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();     
                let dueDate = moment(result.formResponseAndFormResElements.Due_Date__c)._i;
                if(result.formResponseAndFormResElements.Due_Date__c && dueDate < moment().format('YYYY-MM-DD')){
                 
                    helper.showToast(cmp, 'Feedback can\'t be modified because of due date is ended on '+moment(result.formResponseAndFormResElements.Due_Date__c).format('MM/DD/YYYY'), 'error'); 
                    $A.get("e.force:closeQuickAction").fire();
                }else if(!result.formResponseAndFormResElements.Is_Feedback_By_Me__c){
                    helper.showToast(cmp, "You don't have permission to perform this action", 'error'); 
                    $A.get("e.force:closeQuickAction").fire();
                }else{
                    var formTempIdWithFormResElement = {},
                        formResElements = result.formResponseAndFormResElements.Form_Response_Elements__r;
                    
                    if(formResElements && formResElements.length > 0){
                        for(var formResEle of formResElements){
                            formTempIdWithFormResElement[formResEle.Question__c] = formResEle;
                        }
                    }
                    cmp.set('v.IsShareWithEmployee', result.formResponseAndFormResElements.Is_Share_with_Employee__c);
                    cmp.set('v.formTempIdWithFormResElement', formTempIdWithFormResElement);
                    cmp.set('v.formResponse', result.formResponseAndFormResElements);
                    cmp.set("v.formTempEleIdwithOptionLimit", result.formTemplateAndFormTempElements.formTempEleIdwithOptionLimit);
                    cmp.set("v.formTempEleIdWithResponseForUniqueResponse", result.formTemplateAndFormTempElements.formTempEleIdWithResponseForUniqueResponse);
                    cmp.set('v.formTemplate', result.formTemplateAndFormTempElements.formTemplate); 
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast(cmp,   errors[0].message, 'error');
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        }); 
        $A.enqueueAction(action);
    },
    saveFormResponse: function(cmp, event, helper, formResponseElements, status){
        var formRes = {Id: cmp.get('v.recordId'),Status__c : status, Is_Share_with_Employee__c: cmp.get('v.IsShareWithEmployee')};
        cmp.set('v.showSpinner', true);
        var action = cmp.get("c.saveFormResAndFormResElements");   
        console.log(JSON.stringify(formResponseElements));
        action.setParams({ formResponseElementsStr : JSON.stringify(formResponseElements) , formResponseStr: JSON.stringify(formRes)});
        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set('v.showSpinner', false);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result == 'success'){
                    helper.showToast(cmp,  'Form response saved successfully!', 'success');
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();                    
                }else{
                    helper.showToast(cmp, result, 'error');
                }
            }
            else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        helper.showToast(cmp,   errors[0].message, 'error');
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        }); 
        $A.enqueueAction(action);
    },
    showToast : function(component, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            message: message,
            type: type
        });
        toastEvent.fire();
    }
})