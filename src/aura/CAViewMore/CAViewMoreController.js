({
    getContactAssignmentRecord : function(component, event, helper) {
        var selectedTab = component.get("v.selectTabName");
    },
    navigateToRecord : function(component, event, helper) {
        
        var recordId = event.target.getAttribute('name');
        var sObectEvent = $A.get("e.force:navigateToSObject");
        sObectEvent .setParams({
            "recordId": window.open('/'+recordId) , 
            "slideDevName": "detail"
        });
        sObectEvent.fire(); 
    },
    doInit : function(component, event, helper) {
        
        var action=component.get("c.contactAssignmentView");
        action.setParams({'conAssignId':component.get("v.conAssignId")});
        action.setCallback(this,function(data){
            var state = data.getState();
            if(state === "SUCCESS"){
                var result = data.getReturnValue();
                component.set("v.contactAssignmentRecord",result.lstConAssignment); 
                component.find("EditRecord").openModal();
            }
            else if(state === "ERROR"){
                console.log(data.getError());  
            }
        });
        $A.enqueueAction(action);
    },
    closeActiontab : function(component, event, helper) {
        component.find("EditRecord").closeModal();
    },
    cAEditAction : function(component, event, helper) {
        
        var cmpEvent = component.getEvent('updateCAEvent');
        cmpEvent.setParams({'typeOfAction':'Edit'});
        cmpEvent.fire();
    },
    cADeleteAction:function(component, event, helper) {
        
        var cmpEvent = component.getEvent('updateCAEvent');
        cmpEvent.setParams({'typeOfAction':'Delete'});
        cmpEvent.fire();
    }
})