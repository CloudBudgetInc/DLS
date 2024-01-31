({
    doinit : function(cmp, event, helper) {
        var device = $A.get("$Browser.formFactor");
        
        if (device == 'PHONE') {
            cmp.set("v.displayDevice",'Mobile');
        } else {
            cmp.set("v.displayDevice",'PC');
        }
        
        console.log(':::::::projectId::quote:',cmp.get("v.projectId"));
		const server = cmp.find('server');
        const action = cmp.get('c.getQuoteInformation');
        server.callServer(
            action, 
            {projectId : cmp.get("v.projectId")}, 
            false, 
            $A.getCallback(function(response) { 
                console.log('response quote:::',JSON.parse(response));
                var result = JSON.parse(response);
                for(var i = 0;i < result.length;i++){
                    result[i].totalPrice = helper.getFormatedString(result[i].totalPrice,"en-US", "$");
                }
            	cmp.set("v.quoteDetails",result);
            }),
            $A.getCallback(function(errors) { 
            		/*var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message: message,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();*/
                console.log('errors:::',errors);
            }),
            false, 
            false, 
            false 
            );
	},
    gotoQuoteDetailPage : function(cmp,event,helper){
        var quoteId = event.currentTarget.name;
        console.log(':::quoteId:::',quoteId);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/quote-detail?projectId="+cmp.get("v.projectId")+'&quoteId='+quoteId
        });
        urlEvent.fire();
    }
})