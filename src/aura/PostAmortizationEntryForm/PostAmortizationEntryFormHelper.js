({
	getAmortizationEntriesHelper : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var selectedFilter = component.get("v.selectedFilter");
		var action = component.get("c.getAmortizationEntries");
        action.setParams({ filterName : selectedFilter});

        action.setCallback(this, function(response) {
        	var resState = response.getState(); 
            var totalCount = 0;
            var totalAmount = 0;
            var currentMonth ='';
            console.log('resState:::',resState);
            if(resState == 'SUCCESS') {
            	console.log('inside response',response.getReturnValue());
                var result = JSON.parse(response.getReturnValue());
                console.log('Parsed result:::',result);
                for( var i=0; i < result.length; i++) {
                    totalCount+= result[i].count;
                    totalAmount+= result[i].amountSum;
                    currentMonth = result[i].currentMonth;
                }
                console.log('totalCount',totalCount,totalAmount);
                component.set("v.entryList",result);
                component.set("v.totalCount",totalCount);
                component.set("v.totalAmount",totalAmount);
                component.set("v.showSpinner",false);
                component.set("v.currentMonth",currentMonth);
            }else{
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})