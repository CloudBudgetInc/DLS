({
    init: function(component, event, helper) {
        var urlString = window.location.href;
        var device = $A.get("$Browser.formFactor");
        
        if (device == 'PHONE') {
            component.set("v.displayDevice",'Mobile');
        } else {
            component.set("v.displayDevice",'PC');
        }
        var action = component.get("c.getSchduleRecord");
        action.setParams({'scheduleId': urlString.split("=")[1]});
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log('state:::',state);
            if(state == "SUCCESS"){
                let res = response.getReturnValue();
                if(res){
                    component.set("v.scheduleRec",JSON.parse(res));
                }
            }else if(state == 'ERROR'){
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
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
        });
        $A.enqueueAction(action);
    },
    
    back : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/schedules?viewType=schedule"
        });
        urlEvent.fire();
    }
})