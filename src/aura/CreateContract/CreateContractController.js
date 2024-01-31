({
    doinit : function(cmp, event, helper) {
        var action = cmp.get("c.createContractRec");

        action.setParams({
            oppId : cmp.get("v.recordId")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state == "SUCCESS") {
                var returnValue = response.getReturnValue();
                if(returnValue != null) {
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/"+returnValue
                    });
                    urlEvent.fire();
                } 
                $A.get("e.force:closeQuickAction").fire(); 
            } else {
                console.log(":::CreateContract init Error:::", response.getError());
                var str = cmp.get("v.card");
                str.title = "Error";
                str.message = response.getError()[0].message;
                str.buttonName = "Okay";
                
                cmp.set("v.card", str);
            }
        });
        $A.enqueueAction(action);
    },
    
    closeAction : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    }
})