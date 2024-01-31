({
    updateProject : function(cmp, event, helper) {
        var dtCmp = cmp.find("dtVal");
        var isValid = true;        
        if(!dtCmp.get("v.value")){
            dtCmp.set("v.errors", [{message:" "}]);
            isValid = false;
        }else {
            dtCmp.set("v.errors", null);
        }
        
        if(isValid){
            cmp.set("v.showSpinner",true);
            var action = cmp.get("c.updateProStatusToOnHold");
            action.setParams({
                "proId" : cmp.get("v.recordId"),
                "onholdDt" : cmp.get("v.onHoldDt")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state == 'SUCCESS'){
                    //display toast msg
                    cmp.set("v.showSpinner",false);
                    helper.showToast(cmp,event,'Success','Project status updated successfully. Please reload this page to see the changes.','success');
                    window.setTimeout(
                        $A.getCallback(function() {
                            $A.get("e.force:closeQuickAction").fire();
                            //$A.get("e.force:refreshView").fire();
                        }),1000);
                    
                }else {
                    console.log(":::::::update::pro::status:onhold:error::::::",response.getError()[0].message);
                    cmp.set("v.showSpinner",false);
                    helper.showToast(cmp,event,'Error',response.getError()[0].message,'error');
                }
            });
            $A.enqueueAction(action);
        }
    },
    closeAction :  function(cmp, event, helper){
        $A.get("e.force:closeQuickAction").fire();
    },
    closeToast : function(cmp, event, helper) {
        $A.util.toggleClass(cmp.find("toast"),'slds-hide');
    }
})