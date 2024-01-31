({
	toogleCheckBox : function(component, event, helper) {
		component.set("v.checked",!component.get("v.checked"));
        event.stopPropagation();
	}
})