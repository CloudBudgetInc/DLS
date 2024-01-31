({
    saveNewContractHelper : function(component) {
        var action = component.get("c.saveNewContract");
        var newContractArray = [];
        
        component.set("v.showSpinner",true);
        newContractArray.push(component.get("v.newContract"));
        action.setParams({
            "contractJSON" : JSON.stringify(newContractArray),
            "parentContractId" : component.get("v.recordId")
        });
        action.setCallback(this, function(data){
            var state = data.getState();
            if(state == 'SUCCESS'){
                var result = data.getReturnValue();
                if(result){
                    window.open('/'+result,'_Self');
                }
                component.set("v.showSpinner",false);
            }else{
                var toastEvent = $A.get("e.force:showToast");
                component.set("v.showSpinner",false);
                component.set("v.visibleError",'slds-show');
                component.set("v.showErrorMsg",data.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    }
})