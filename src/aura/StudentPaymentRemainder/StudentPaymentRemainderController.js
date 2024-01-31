({
	doinit : function(cmp, event, helper) {
        
        var action =  cmp.get("c.getServiceProjectTasks");
        action.setParams({
            "projectId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                console.log("::::::::result::task::::",result);
                cmp.set("v.projectTaskRecords",result);
            }else {
                console.log("::::::error::::::",response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
        
		
	},
    nextBtnClick : function(cmp, event, helper){
        
        var task = cmp.get("v.selectedProjectTask");
		var valid = true;
        if(task == '--None--'){
            valid = false;
        }
        
        if(valid){
            var action =  cmp.get("c.getStudentPaymentInformation");
            action.setParams({
                "projectId" : cmp.get("v.recordId"),
                "taskId" : cmp.get("v.selectedProjectTask")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state == 'SUCCESS'){
                    var result = response.getReturnValue();
                    console.log("::::::::result::::::",result);
                    cmp.set("v.initialValues",result);
                    cmp.set("v.showContent",true);
                }else {
                    console.log("::::::error::::::",response.getError()[0].message);
                }
            });
            $A.enqueueAction(action);
        }else {
            var taskCmp = cmp.find("taskSelect");
            $A.util.addClass(taskCmp,'slds-has-error');
        }
	}
})