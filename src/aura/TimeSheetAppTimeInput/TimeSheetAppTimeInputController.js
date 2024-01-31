({
    doInit: function (cmp, event, helper) {
        console.log('Init Time Input');
        var timeInput = cmp.get("v.timeInput");
        var today = new Date();
        console.log('Today: ' + today);
        var monthDigit = today.getMonth() + 1;
        console.log('Month Digit(pre): ' + monthDigit);
        if (monthDigit <= 9) {
            monthDigit = '0' + monthDigit;
        }
        console.log('Month Digit(post add 0): ' + monthDigit);
        timeInput.Date_of_Work__c = today.getFullYear() + "-" + monthDigit + "-" + today.getDate();
        var myDate = new Date(timeInput.Date_of_Work__c);
        timeInput.Date_of_Work__c - myDate;
        console.log('timeInput Date: ' + timeInput.Date_of_Work__c);
        cmp.set("v.timeInput", timeInput);
        console.log('Today(get timeInput):'+ cmp.get("v.timeInput.Date_of_Work__c"));
    },
    addLineToParentOrEdit : function(cmp, event, helper) {
		console.log('Entering addLineToParentOrEdit');
        helper.addLineToParentOrEdit(cmp, event);
	},
    editLineInArray : function(cmp, event, helper) {
		console.log('Entering editLineInArray');
        helper.editLineInArray(cmp, event);
	},
    deleteLine : function(cmp, event, helper) {
		console.log('Entering deleteLine');
        helper.deleteLine(cmp, event);
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