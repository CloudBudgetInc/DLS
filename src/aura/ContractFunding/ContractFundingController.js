({
    doinit : function(cmp, event, helper) {
        var action = cmp.get("c.createFundingRecord");
        
        action.setParams({
            oppId : cmp.get("v.recordId")
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            
            if(state == "SUCCESS") {
                console.log(":::ContractFunding:::SUCCESS:::", response.getReturnValue());
                if(response.getReturnValue() == 'Success') {
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/"+cmp.get("v.recordId")
                    });
                    urlEvent.fire();
                    $A.get("e.force:closeQuickAction").fire(); 
                } else {
                    cmp.set("v.message", response.getReturnValue());
                    var str = cmp.get("v.card");
                    str.title = "Error";
                    str.message = response.getReturnValue();
                    str.buttonName = "Okay";
                    
                    cmp.set("v.card", str);
                }
                
            } else {
                console.log(":::ContractFunding init Error:::", response.getError());
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