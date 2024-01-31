({
    doinit : function(cmp, event, helper){
        var action = cmp.get("c.getPickListValues");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue());
                console.log('::::result::::::::',result);
                var type = result.typeValues;
                var priority = result.priorityValues;
                type.unshift({'label':'--None--','value':''});
                priority.unshift({'label':'--None--','value':''});
                
                cmp.set("v.types",type);
                cmp.set("v.priorities",priority);
            }else {
                console.log(':::doinit::::error::::::',response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    clickCreate: function(component, event, helper) {
        var description = component.find("caseform");
        var isValid = true;
        
        for(var i = 0;i < description.length;i++){
            if(!description[i].get("v.value")){
                $A.util.addClass(description[i], 'slds-has-error'); 
                isValid = false;
            }else {
                $A.util.removeClass(description[i], 'slds-has-error'); 
            }
        }
        if(isValid){
            helper.uploadfileWithSaveCase(component, event);
        }
    },
    closeAction :  function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
       
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        if (event.getSource().get("v.files").length > 0) {
            var file = event.getSource().get("v.files")
                fileName  = file[0].name;
        }
        component.set("v.fileName", fileName);
        helper.uploadFileHelper(component, event);
    }
})