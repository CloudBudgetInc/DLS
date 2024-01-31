({
	backToProjectDetail : function(cmp, event, helper) {
        
        var url = window.location.href;
        const urlParams = new URL(url);
		const projectId = urlParams.searchParams.get('projectId');
        var urlEvent = $A.get("e.force:navigateToURL");
        
        urlEvent.setParams({
            "url": "/projectdetailview?recordId="+projectId
        });
        urlEvent.fire();
    }
})