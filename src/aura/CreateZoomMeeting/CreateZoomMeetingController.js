({
	doInit : function(component, event, helper) {
		const server = component.find("server");
        const action = component.get("c.createMeetingForEvent");   
        component.set("v.loading", true);
        
        var param = {            
            eventId: component.get('v.recordId')
        };
        
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function (response) {
                component.set("v.loading", false);
                
                if(response == 'success'){
                    helper.showToast(component, event, "Success", 'Zoom Meeting created successfully!', "success");
                }else{
                    helper.showToast(component, event, "Error", response, "error");
                }
				$A.get("e.force:closeQuickAction").fire();                
            }),
            $A.getCallback(function (errors) {
                component.set("v.loading", false);
                helper.showToast(component, event, "Error", errors[0].message, "error");
                $A.get("e.force:closeQuickAction").fire();
            }),
            false,
            false,
            false 
        );
	}
})