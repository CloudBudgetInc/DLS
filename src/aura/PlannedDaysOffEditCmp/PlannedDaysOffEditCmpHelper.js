({
	fireEditEvent : function(cmp, isEdit) {
		var cmpEvent = cmp.getEvent("CommunityPDOEditEvent");
        cmpEvent.setParams({ "isEdit" : isEdit });
        cmpEvent.fire();
	}
})