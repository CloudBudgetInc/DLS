({
	doInit : function(cmp, event, helper) {
        var urlString = window.location.href;        
        cmp.set("v.folderId", urlString.split("=")[1]);        
	},
    back : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/reports"
        });
        urlEvent.fire();
    }
})