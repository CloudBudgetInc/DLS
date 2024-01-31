({
	doinit : function(component, event, helper) {
        component.set("v.showSpinner",true);
		helper.getSemiMonthlyWeekDetails(component);
	},
    handleHeaderClick : function(component, event,helper){
        var eventType = event.getParam("typeOfAction");
        if(eventType == 'Previous'){
            helper.PreviousClick(component);
        }else if(eventType == 'Next'){
            helper.NextClick(component);
        }else if(eventType == 'Approval Summary'){   
            component.set("v.showSpinner",true);
            helper.fireSummaryEvent(component);
        }
        event.stopPropagation();
    },
    contactChange : function(component, event, helper){
        component.set("v.showSpinner",true);
        var contactId = component.get("v.selectedContact");
        var summEntries = component.get("v.wholeSummary");
        component.set("v.summaryEntries",summEntries[contactId]);
        helper.grandTotalCalculation(component);
        component.set("v.showSpinner",false);
    }
})