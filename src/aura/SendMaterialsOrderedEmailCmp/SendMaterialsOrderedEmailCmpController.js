({
	doinit : function(cmp, event, helper) {
        var param = {};
        param.projectId = cmp.get("v.recordId");
        
		const server = cmp.find('server');
        const action = cmp.get('c.getMaterialsOrderedInformation');
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                console.log("::::::response::",response);
                cmp.set("v.initialValues",response);
            }),
            $A.getCallback(function(errors) { 
                console.log('::::::::::Send Materials Ordered email exception:::::::::',errors[0].message);
            }),
            false, 
            false, 
            false 
        );
	}
})