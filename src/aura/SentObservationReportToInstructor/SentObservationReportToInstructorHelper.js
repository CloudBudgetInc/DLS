({
    validateBoxFolderExist: function (cmp, event, helper) {
        cmp.set("v.showSpinner", true);
        const server = cmp.find('server');
        var action = cmp.get("c.validateAssessmentRecBoxFolder");
        server.callServer(
            action, { assessmentReportId: cmp.get("v.recordId") },
            false,
            $A.getCallback(function (responseStr) {
                let response = JSON.parse(responseStr),
                    error = cmp.get('v.error');

                if (response.errorMsg == 'No Box Record') {
                    helper.subscribePlatformEvent(cmp, event, helper, cmp.get("v.recordId"));
                } else if (response.errorMsg) {
                    error.isShow = true;
                    error.errorMsg = response.errorMsg;
                    cmp.set('v.error', error);
                    cmp.set("v.showSpinner", false);
                    cmp.set('v.showProceedBtn', true);
                    cmp.set('v.congaUrl', response.congaUrl);
                } else {
                    helper.launchCongaUrl(cmp, response.congaUrl) 
                }
            }),
            $A.getCallback(function (errors) {
                cmp.set("v.showSpinner", false);
                helper.showToast(component, event, errors[0].message, "error", "Error");
            }),
            false,
            false,
            false
        );
    },
    showToast: function (cmp, event, message, type, title) {
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            type: type,
            mode: 'sticky'
        });
        toastEvent.fire();
    },
    closeQuickAction: function (cmp) {
        $A.get("e.force:closeQuickAction").fire();
    },
    launchCongaUrl : function(cmp, congaUrl) {
		window.open(congaUrl, '_blank');		
		this.closeQuickAction(cmp);
	}
})