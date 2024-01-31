({
	doinit : function(cmp, event, helper) {
		var action =  cmp.get("c.getOnHoldProjectAndStudentInformation");
        action.setParams({
            "projectId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                console.log(result);
                cmp.set("v.initialValues",result);
                cmp.set("v.showContent",true);
            }else {
                console.log("::::::error::::::",response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
	}
})