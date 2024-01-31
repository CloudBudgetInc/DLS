({
    doInit : function(cmp, event, helper) {
        helper.getOpenCompletedToDoItemsInfo(cmp,event,helper);
    },
    back : function(cmp, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"
        });
        urlEvent.fire();
    }
})