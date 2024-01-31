({
    doInit : function(cmp, event, helper) {
        helper.getRefundCalculationInfoHelper(cmp, event, helper); 
    },
    closeAction : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    launchUrl : function(cmp, event, helper) {
        var congaUrl = cmp.get("v.congaUrl");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": congaUrl
        });
        urlEvent.fire();
        $A.get("e.force:closeQuickAction").fire(); 
        cmp.set("v.showSpinner",false);
    }
})