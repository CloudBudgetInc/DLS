({
    doinit : function(cmp, event, helper) {
        console.log('::::::::recordId:::::',cmp.get("v.recordId"));
        console.log('::::::::objectName:::::',cmp.get("v.sObjectName"));
        helper.getWorkItem(cmp);
    },
    saveEditModal : function(cmp, event, helper) {
        if(cmp.get("v.sObjectName") == 'agf__ADM_Work__c'){
            helper.saveTimerecord(cmp);
        }else {
            helper.updateTimeRecord(cmp);
        }
    },
    closeEditModal: function(cmp, event, helper) {
        var cmpTarget = cmp.find('editDialog');
        var cmpBack = cmp.find('dialogBack');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
        $A.util.removeClass(cmpBack, 'slds-backdrop--open'); 
        
        if(cmp.get("v.sObjectName") == 'agf__ADM_Work__c'){
            $A.get("e.force:closeQuickAction").fire();
        }else {
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": cmp.get("v.recordId")
            });
            navEvt.fire();
        }
    },
    hoursValidation : function(cmp, event, helper){
        var data = cmp.get("v.timeInput");
        var hour = (data.Hours_Manual__c * 100) % 100;
        var errMsg = '';
        if(!(hour == 25 || hour == 50 || hour == 75 || hour == 0)){
            console.log('invalid format');
            errMsg  = 'Allowed decimal values are 00, 25, 50, 75';
        }else {
            console.log('correct format');
            errMsg  = '';
        }
        cmp.set("v.errMsg",errMsg);
    },
    validateDescription : function(cmp, event, helper){
        var data = cmp.get("v.timeInput");
        var description = data.Description__c;
        var cmtDiv = cmp.find("comments");
        if(!description){
            $A.util.addClass(cmtDiv,"slds-has-error");
        }else {
            if(description && description.length > 500){
                cmtDiv.setCustomValidity("Maximum 500 characters allowed");
                $A.util.addClass(cmtDiv,"slds-has-error");
            }else if(description && description.length <= 500){
                cmtDiv.setCustomValidity("");
                $A.util.removeClass(cmtDiv,"slds-has-error");
            }
            cmtDiv.reportValidity();
        }
    },
    calculateLength : function(cmp, event, helper){
        var data = cmp.get("v.timeInput");
        var description = data.Description__c;
        var desDiv = cmp.find('comments');
        if(description && description.length > 500){
            desDiv.setCustomValidity("Maximum 500 characters allowed");
            $A.util.addClass(desDiv,"slds-has-error");
        }else if(description && description.length <= 500){
            desDiv.setCustomValidity("");
            $A.util.removeClass(desDiv,"slds-has-error");
        }
        desDiv.reportValidity();
    }
})