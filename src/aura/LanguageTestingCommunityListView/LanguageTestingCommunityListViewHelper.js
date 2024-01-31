({
	getLanguageTestings : function(component, event, helper) {
		component.set("v.showSpinner", true);
        var selectedFilterValues = component.get("v.selectedFilterValues");
        var projId = component.get('v.projectId');
        const server = component.find("server");        
        const action = component.get("c.getLanguageTestingRecords");
       
        var param = {
            projectId: projId
        };
        
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function (response) {
                component.set("v.testingRecs", response);
                
                if(response.length > 0){
                    component.find("devTable").initialize({});
                }
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