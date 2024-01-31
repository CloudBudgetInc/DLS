({
	doinit : function(cmp, event, helper) {
        const server = cmp.find('server');
        const action = cmp.get('c.initiateUserCreation');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                console.log('response:::beta::group:::user::::',response);
                 window.setTimeout(
                    $A.getCallback(function() {
                        $A.get("e.force:closeQuickAction").fire();
                    }),2000);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp',errors[0].message);
            }),
            false, 
            false,
            false
        );
	}
})