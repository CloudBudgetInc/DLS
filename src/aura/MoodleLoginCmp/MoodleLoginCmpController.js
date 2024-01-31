({
	doinit : function(cmp, event, helper) {
        const server = cmp.find('server');
        const action = cmp.get('c.getLoginDetialsForD2L');
        
        server.callServer(
            action, 
            {}, 
            false, 
            $A.getCallback(function(response) { 
                var result = response;
                
                if(result && result == 'Redirect to Moodle'){
                    var url = $A.get("$Label.c.Moodle_Url");
                    window.open(url,'_blank');
                    cmp.set("v.showSpinner",false);
                    var urlEvent1 = $A.get("e.force:navigateToURL");
                    urlEvent1.setParams({
                        'url': '/'
                    });
                    urlEvent1.fire();
                }else{
                    cmp.set("v.message",result);
                    cmp.set("v.showSpinner",false);
                }
                
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                cmp.set("v.showSpinner",false);
                helper.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
	}
})