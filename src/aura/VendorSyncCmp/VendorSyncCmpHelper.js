({
    getAccountInfo : function(component, event){
    	component.set("v.showSpinner", true);
		console.log("helper");
        const server = component.find("server");
        const action = component.get("c.getAccountForVendorCreation");
        
        var param = {
            accountId: component.get("v.recordId")
        };
        
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function (response) {
                component.set("v.accountRecord",response);               
                component.set("v.showSpinner", false);                
            }),
            $A.getCallback(function (errors) {
                helper.showToast(component, event, "Error", errors[0].message, "error");
            }),
            false,
            false,
            false
        );
	},
    executeBatch : function(component, event, helper) {
        component.set("v.showSpinner", true);

        const server = component.find("server");
        const action = component.get("c.executeVendorCreationBatch");
        
        var param = {
            accountId: component.get("v.recordId")
        };
        
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function (response) {
                component.set("v.message", 'Bill.com Sync Batch job initiated');                
                component.set("v.showSpinner", false);
                $A.get("e.force:closeQuickAction").fire();
            }),
            $A.getCallback(function (errors) {
                helper.showToast(component, event, "Error", errors[0].message, "error");
            }),
            false,
            false,
            false
        );
    }
})