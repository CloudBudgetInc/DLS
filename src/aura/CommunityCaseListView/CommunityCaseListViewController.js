({
	doInit : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var device = $A.get("$Browser.formFactor");
        
        if (device == 'PHONE') {
            component.set("v.displayDevice",'Mobile');
        } else {
            component.set("v.displayDevice",'PC');
        }
        helper.getCasesRecords(component, event, helper);
	},
    handleFilterChange : function(component, event, helper) {
        component.set("v.showSpinner",true); 
        helper.filterCaseRecords(component, event);
    },
      tabActionClicked: function(component, event, helper) {
          
        var actionId = event.getParam('actionId');
        var row = event.getParam('row');
          var navEvt = $A.get("e.force:navigateToSObject");
          navEvt.setParams({
              "recordId":row.Id,
              "slideDevName": "related"
          });
          navEvt.fire();
        
    },
    navigateSubmitCase : function(component, event, helper) {
        window.location.href = '/'+component.get("v.communityName")+'/s/contactsupport';
    }
})