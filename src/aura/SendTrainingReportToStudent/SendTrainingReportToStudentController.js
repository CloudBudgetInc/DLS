({
    doInit: function (cmp, event, helper) {
        var testReport = cmp.get('v.assessmentReport'),
            error = { isShow: false };
        var recordId = cmp.get("v.recordId");
        if ((((testReport.RecordType.DeveloperName != 'DLI_W_Progress_2022' && testReport.RecordType.DeveloperName != 'DLI_W_Self_Assessment_Test_Report' && testReport.RecordType.DeveloperName != 'DLI_W_Test_Report') && testReport.Status__c == 'Approved by LTS') || ((testReport.RecordType.DeveloperName == 'DLI_W_Progress_2022' || testReport.RecordType.DeveloperName == 'DLI_W_Self_Assessment_Test_Report' || testReport.RecordType.DeveloperName == 'DLI_W_Test_Report') && testReport.Status__c == 'Submitted to LTS')) && testReport.Student__c) {
            cmp.set("v.showSpinner", true);
            const server = cmp.find('server');
            var action = cmp.get("c.validateAssessmentRecBoxFolder");
            server.callServer(
                action, { assessmentReportId: recordId },
                false,
                $A.getCallback(function (responseStr) {
                    let response = JSON.parse(responseStr);
                    if (response.errorMsg == 'No Box Record') {
                        helper.subscribePlatformEvent(cmp, event, helper, recordId);
                    } else if (response.errorMsg) {
                        error.isShow = true;
                        error.errorMsg = response.errorMsg;
                        cmp.set("v.showSpinner", false);
                        cmp.set('v.showProceedBtn', true);
                        cmp.set("v.error", error);
                        cmp.set('v.congaUrl', response.congaUrl);
                    } else {
                        helper.launchCongaUrl(cmp, response.congaUrl);
                    }
                }),
                $A.getCallback(function (errors) {
                    cmp.set("v.showSpinner", false);
                    helper.showToast(cmp, event, errors[0].message, "error", "Error");
                }),
                false,
                false,
                false
            );
        } else {
            error.isShow = true;
            if (testReport.Status__c != 'Approved by LTS' || testReport.Status__c != 'Submitted to LTS') {
                error.errorMsg = 'Please change the Status to ' + (testReport.RecordType.DeveloperName == 'DLI_W_Progress_2022' || testReport.RecordType.DeveloperName == 'DLI_W_Self_Assessment_Test_Report' || testReport.RecordType.DeveloperName == 'DLI_W_Test_Report' ? '"Submitted to LTS"' : '"Approved by LTS"') + ' to send the report to Student.'
            } else if (!testReport.Student__c) {
                error.errorMsg = 'Student is not populated.'
            }
            cmp.set('v.error', error);
        }        
    },
    launchUrl: function(cmp, event, helper){
        helper.launchCongaUrl(cmp, cmp.get('v.congaUrl'));
    },
    closeAction: function(cmp){
        $A.get("e.force:closeQuickAction").fire();
    }
})