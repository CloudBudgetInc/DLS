({
	doinit : function(cmp, event, helper) {
		const server = cmp.find('server');
        const action = cmp.get('c.getCommunityUrl');
        
        server.callServer(
            action, 
            {}, 
            false, 
            $A.getCallback(function(response) { 
                var result = response;
                console.log('::::::::final:::url::',result);
                window.location.href = result;
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
            }),
            false, 
            false, 
            false 
        );
        
	}
})