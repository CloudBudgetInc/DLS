({
	refreshMetrics : function(cmp) {
		var action = cmp.get("c.refreshMetric");
        action.setParams({
            "metricId" : cmp.get("v.recordId"),
            "startDate": cmp.get("v.startDate"),
            "endDate": cmp.get("v.endDate")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
             cmp.set('v.showDates', false);
            if(state == 'SUCCESS'){
                cmp.set("v.message", "Refresh process initiated successfully.");
            }else {
                cmp.set("v.message", response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
	}
})