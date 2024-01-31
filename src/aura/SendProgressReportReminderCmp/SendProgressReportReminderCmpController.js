({
	doInit : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
		var action = cmp.get("c.sendReminderMailToInstructor");
        action.setParams({ recId : cmp.get("v.recordId") });

        action.setCallback(this, function(response) {
            var state = response.getState();
            cmp.set("v.showSpinner",false);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result == 'success'){
                    helper.showToast(cmp, 'Reminder sent successfully!', 'success');
                }else{
                    helper.showToast(cmp, result, 'error');
                }
                $A.get("e.force:closeQuickAction").fire();
            }else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + 
                                 errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
       
        $A.enqueueAction(action);
	}
})