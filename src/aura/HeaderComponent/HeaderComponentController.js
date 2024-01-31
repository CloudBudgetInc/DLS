({
	previousClick : function(component, event, helper) {
		console.log("previous click");
        var setEvent = component.getEvent("clickEvent");
        console.log("setEvent",setEvent);
        setEvent.setParams({"typeOfAction":"Previous"});
        setEvent.fire();
	},
    nextClick : function(component, event, helper){
        console.log("next click");
        var setEvent = component.getEvent("clickEvent");
        console.log("setEvent",setEvent);
        setEvent.setParams({"typeOfAction":"Next"});
        setEvent.fire();
    },
    summaryClick : function(component, event, helper){
        console.log('summary click');
        var setEvent = component.getEvent("clickEvent");
        setEvent.setParams({"typeOfAction":"Approval Summary"});
        setEvent.fire();
    }
})