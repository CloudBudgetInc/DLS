({
	toogleModal : function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            if(params.isLarge) {
                $A.util.toggleClass(component.find("modal"),'slds-modal_large slds-fade-in-open');
                $A.util.toggleClass(component.find("modal-backdrop"),'slds-backdrop--open');
                return;
            }
        }

		$A.util.toggleClass(component.find("modal"),'slds-fade-in-open');
        $A.util.toggleClass(component.find("modal-backdrop"),'slds-backdrop--open');
	}
})