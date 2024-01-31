({
	getAllCommunityComponentVisibilities : function(cmp, event, helper) {
		var action = cmp.get("c.getComponentVisibilities");   
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               console.log(response.getReturnValue());
                 cmp.set('v.communityCmpVisibilities', response.getReturnValue());
                cmp.get('v.show', true);
                cmp.set("v.showSpinner",false);
            }
            else if (state === "INCOMPLETE") {
                // do something
                cmp.set("v.showSpinner",false);
            }
            else if (state === "ERROR") {
                cmp.set("v.showSpinner",false);
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