({
    doInit : function(component, event, helper) {
        component.set("v.showSpinner",true);
        helper.getArticleRecords(component, event, helper);
    },
    tabActionClicked  : function(component, event, helper) {
     
        var actionId = event.getParam('actionId');
        var row = event.getParam('row');
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId":row.Id,
            "slideDevName": "related"
        });
        navEvt.fire();
    }
})