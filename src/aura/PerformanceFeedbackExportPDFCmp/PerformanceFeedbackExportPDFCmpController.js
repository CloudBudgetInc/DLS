({
	doinit : function(cmp, event, helper) {
		window.open('/apex/PerformanceFeedbackExportPDF?feedbackId='+cmp.get("v.recordId"));
        $A.get("e.force:closeQuickAction").fire();
	}
})