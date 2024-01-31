({
	doinit : function(cmp, event, helper) {
		var urlString = window.location.href;
        var quoteId = urlString.split("quoteId=")[1];
        var projectId = urlString.split("projectId=")[1].split("&quoteId")[0];
        cmp.set("v.projectId",projectId);
        cmp.set("v.quoteId",quoteId);
        
        const server = cmp.find('server');
        const action = cmp.get('c.getQuoteLineInformation');
        server.callServer(
            action, 
            {quoteId : quoteId}, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
                console.log('quote line:::result:',result);
                var quoteDetail = result.quoteInfo;
                
                quoteDetail.totalPrice = helper.getFormatedString(quoteDetail.totalPrice,"en-US", "$");
                
                var quoteLines = result.quoteLineInfo;
                
                for(var i = 0;i < quoteLines.length;i++){
                    quoteLines[i].salesPrice = helper.getFormatedString(quoteLines[i].salesPrice, "en-US", "$");
                    quoteLines[i].subTotal = helper.getFormatedString(quoteLines[i].subTotal, "en-US", "$");
                }
                
                cmp.set("v.quoteDetail",quoteDetail);
              	cmp.set("v.quoteLineDetails", quoteLines);
            }),
            $A.getCallback(function(errors) { 
            console.log('error',errors)
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error Message',
                    message: message,
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }),
            false, 
            false, 
            false 
            );
	},
    backClick : function(cmp, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/projectdetailview?recordId="+cmp.get("v.projectId")
        });
        urlEvent.fire();
    }
})