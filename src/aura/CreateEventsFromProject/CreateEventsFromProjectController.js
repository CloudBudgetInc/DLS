({	
    doinit : function(cmp, event, helper){
        var action = cmp.get("c.EventsCreationFromProject");
        action.setParams({
            "projectId" : cmp.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                cmp.set("v.message", "Batch process initiated successfully. Events will be created sortly.");
            }else {
                console.log('::::create::Events:doinit::: error:::',response.getError());
                cmp.set("v.message", response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
        
    },
	closeAction : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    }
})