({
	doinit : function(cmp, event, helper) {
		const server = cmp.find('server');
        const action = cmp.get('c.getCurrentUserProfileName');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                console.log('response:::',response);
                cmp.set("v.profileName",response)
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                //cmp.set("v.showSpinner",false);
                //self.showToast(cmp,event,response.getError()[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
	}
})