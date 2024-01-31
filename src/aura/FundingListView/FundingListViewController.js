({
	getFundingList : function(component, event, helper) {
		
        var device = $A.get("$Browser.formFactor");
        
        if (device == 'PHONE') {
            component.set("v.displayDevice",'Mobile');
        } else {
            component.set("v.displayDevice",'PC');
        }
        
        var projectId = component.get("v.projectId");
        console.log(projectId);
        const server = component.find('server');
        const action = component.get('c.getFundsListByProject');
        
        server.callServer(
            action, 
            {projectId : projectId}, 
            false, 
            $A.getCallback(function(response) { 
                console.log('response project',JSON.parse(response));
                var fundings = JSON.parse(response);
                for(var i = 0;i < fundings.length;i++){
                    fundings[i].totalAmount = helper.getFormatedString(fundings[i].totalAmount,"en-US", "$");
                }
            	component.set("v.fundingList",fundings);
            }),
            $A.getCallback(function(errors) { 
                console.log(errors);
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
            }),
            false, 
            false, 
            false 
            );
	},
    
    
    getFundingDetailView : function(component , event , helper){
        
      console.log('url redirect');
        var fundingRecordId;
        if(event.target && event.target.getAttribute("name")) {
            var index = event.target.getAttribute("name"); 
            fundingRecordId = component.get('v.fundingList')[index].transactionId;
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": "/payment-detail?recordId="+fundingRecordId
            });
            urlEvent.fire();
        }
    },
    generateReceiptPDF : function(cmp , event , helper){
        var fundingId = event.currentTarget.name;
        var projectId = cmp.get("v.projectId");
        
        if(fundingId){
            var urlEvent = $A.get("e.force:navigateToURL");
            
            urlEvent.setParams({
                "url": "/funding-receipt-pdf?recordId="+fundingId+'&projectId='+projectId
            });
            urlEvent.fire();
        }
    }
})