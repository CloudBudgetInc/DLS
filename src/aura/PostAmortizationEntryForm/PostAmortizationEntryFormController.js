({
	doInit : function(component, event, helper) {
       helper.getAmortizationEntriesHelper(component, event, helper);
    },    
    toHome : function(component, event, helper) {       
    	console.log('Inside home page');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/home/home.jsp"
        })
        urlEvent.fire();
    },
    handleSelect : function(component, event, helper){
        helper.getAmortizationEntriesHelper(component, event, helper);
    }
})