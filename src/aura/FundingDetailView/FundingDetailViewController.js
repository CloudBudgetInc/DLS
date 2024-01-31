({
	getFundingItemList : function(component, event, helper) {
		var urlString = window.location.href;
        
        var fundingId = urlString.split("=")[1];
        console.log('fundng id',fundingId)
        const server = component.find('server');
        console.log('server')
        const action = component.get('c.getFundsItemsByFund');
        server.callServer(
            action, 
            {fundingId : fundingId}, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
                console.log('result',result);
                let fundingItem = result.FundingItemInfo;
                console.log('fundingInfo',fundingItem);
                if(fundingItem.length > 0){
                    fundingItem.forEach(function(fund) {
                        console.log(fund);
                        fund.amount = helper.getFormatedString(fund.amount, "en-US", "$");
                        fund.ratePerQty = helper.getFormatedString(fund.ratePerQty, "en-US", "$");
                    });
                }
                if(result.FundingInfo) {
                    result.FundingInfo.totalAmount = helper.getFormatedString(result.FundingInfo.totalAmount, "en-US", "$");
                }
                console.log('called',result.FundingItemInfo);
              	component.set("v.fundingItemList", fundingItem);                
                component.set("v.fundingRec",result.FundingInfo);
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
    back : function(component, event, helper) {
       
        var urlEvent = $A.get("e.force:navigateToURL");
        var projectId = component.get("v.fundingRec").projectId;
        urlEvent.setParams({
            "url": "/projectdetailview?recordId="+projectId
        });
        urlEvent.fire();
    }
})