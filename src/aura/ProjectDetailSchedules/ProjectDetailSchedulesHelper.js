({
	getSchedules : function(component, event, helper,recordId) {        
        component.set("v.showSpinner",true);
		var action = component.get("c.getSchedule");
        action.setParams({projectId : recordId,
                          status : component.get("v.statusSelected")});
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state:::',state);
            if(state == "SUCCESS"){
                let res = response.getReturnValue();
                if(res){
                    let listViewWrapper = JSON.parse(res);
                    console.log('res:::',res);
                    console.log("list view contents",listViewWrapper.scheduleRecords);
                    component.set("v.schStatusValue",listViewWrapper.statusValues);
                    component.set("v.scheduleList",listViewWrapper.scheduleRecords);
                   
                }
            }else if(state == 'ERROR'){
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message: message,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
            
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
	}
})