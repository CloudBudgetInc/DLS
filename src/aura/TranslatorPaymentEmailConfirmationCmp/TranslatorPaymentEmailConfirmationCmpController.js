({
	doinit : function(cmp, event, helper) {
		var action =  cmp.get("c.getTranslatorPaymentEmailConfirmationInformation");
        action.setParams({
            "caId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                console.log(result);
                cmp.set('v.userId',$A.get("$SObjectType.CurrentUser.Id"));
                cmp.set("v.initialValues",result);
                
            }else {
                console.log("::::::error::::::",response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
	},
    validateProfileAndConAssignmentRecToShowContent: function(cmp, event, helper){
        let conAssigmentRec = cmp.get('v.contactAssignmentRecord'),  
            allowedProfileNames = ['System Administrator', 'Accounting', 'Timekeeping', 'Payroll'],
            showContent = (conAssigmentRec.Project__r.RecordType.DeveloperName == 'Translation_Projects' || conAssigmentRec.Project__r.RecordType.DeveloperName == 'Interpretation_Projects') && conAssigmentRec.RecordType.DeveloperName == 'Instructor' && conAssigmentRec.Linguist_Paid__c && allowedProfileNames.indexOf(cmp.get('v.userRecord').Profile.Name) >= 0;
        
        cmp.set("v.showContent",showContent);
        cmp.set("v.showError", allowedProfileNames.indexOf(cmp.get('v.userRecord').Profile.Name) < 0);        
    }    
})