({
	showToast: function(component, event, helper, type, title, message, mode) {
        console.log('msg',message);
                          
		console.log('title',title);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            message: message,
            title: title,
            type: type
        });
        toastEvent.fire();
    }
})