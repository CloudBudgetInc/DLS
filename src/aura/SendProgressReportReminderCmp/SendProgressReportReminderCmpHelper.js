({
	showToast : function(component, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            mode: 'sticky',
            message: message,
            type: type
        });
        toastEvent.fire();
	}
})