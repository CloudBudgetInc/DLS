({
    doinit : function(cmp, event, helper) {
        var recId = cmp.get("v.recordId");
        var action = cmp.get("c.getRelatedInformation");
        action.setParams({
            projectId : recId
        });
        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log("::::result:::",result);
                result.orgWideEmailAddress.push({Id : result.loggedInUser.Id,DisplayName : result.loggedInUser.Name});
                result.fromAddress = result.loggedInUser.Id;
                result.toAddressContacts = [];
                cmp.set("v.initialValues",result);
                cmp.set("v.showContent",true);
            } else {
                console.log(":::error:new:::class:::announce::",response.getError());
            }
        });
         $A.enqueueAction(action);
    },
    
    closeAction : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    }
})