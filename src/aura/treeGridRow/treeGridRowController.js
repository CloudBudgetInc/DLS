({
	toogle : function(component, event, helper) {
		component.set("v.expanded",!component.get("v.expanded"));
	},
    editRecord: function(component, event, helper) {
		     var dtActionEvt = component.getEvent("dtActionClick"),
            actionId = 'editicon',
            params = {
                "actionId":actionId
            };
        
        if(component.get("v.gridData")){
            params['row'] = component.get("v.gridData");
        }
        
        dtActionEvt.setParams(params);
        dtActionEvt.fire();

	},
    navigateToRecord :function(component, event, helper){
       /* var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.gridData").Id,
            "slideDevName": "related"
        });
        navEvt.fire();*/
        window.open('/'+component.get("v.gridData").Id);
    },
    navigateToCLINRecord: function(component, event, helper){
        window.open('/'+component.get("v.gridData").clinId);
    },
    fundingRecord: function(component, event, helper) {
        
        var dtActionEvt = component.getEvent("dtActionClick"),
            actionId = 'fund',
            params = {
                "actionId":actionId
            };
        
        if(component.get("v.gridData")){
            params['row'] = component.get("v.gridData");
        }
        
        dtActionEvt.setParams(params);
        dtActionEvt.fire();
	},
    deleteRecord: function(component, event, helper) {
	 var dtActionEvt = component.getEvent("dtActionClick"),
            actionId = 'delete',
            params = {
                "actionId":actionId
            };
        
        if(component.get("v.gridData")){
            params['row'] = component.get("v.gridData");
        }
        
        dtActionEvt.setParams(params);
        dtActionEvt.fire();

	},
    
})