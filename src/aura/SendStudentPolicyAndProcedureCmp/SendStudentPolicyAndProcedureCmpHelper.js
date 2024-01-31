({
    updateCA: function(component, event, helper, rows){        
        const server = component.find("server");
        const action = component.get("c.updateContactRecords");    
        var param = {conAssignmentStr: JSON.stringify(rows), initCAFRUPCheck: false};
        component.set("v.showSpinner",true);
        
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function (response) {
                component.set("v.showSpinner",false);
				helper.showToast(component, event,'Policy and Procedure sent successfully for selected students.', "success", "Success");                              
            }),
            $A.getCallback(function (errors) {
                helper.showToast(component, event,errors[0].message, "error", "Error");
            }),
            false,
            false,
            false 
        );
    },
    showToast : function(cmp,event,message,type,title){
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message : message,
            type : type,
            mode: 'sticky'
        });
        toastEvent.fire();
    }
})