({
	getCongaUrlHelper : function(cmp, event, helper) {
        var self = this;
        cmp.set("v.showSpinner",true);
        const server = cmp.find('server');
        var action = cmp.get("c.getCongaUrlInfo");
        server.callServer(
            action, {objName : cmp.get("v.sObjectName"),objId : cmp.get("v.recordId")},
            false,
            $A.getCallback(function(response) {
                var returnValue = response;
                console.log(returnValue);
                if(returnValue.errorMsg){
                    if(returnValue.errorMsg == 'No Box Record'){
                       helper.subscribePlatformEvent(cmp, event, helper, cmp.get("v.recordId"));
                    }else{
                        cmp.set("v.card",{'title' : 'Warning - Email Already Sent!', 'message' : returnValue.errorMsg});
                        cmp.set('v.assessmentReport', returnValue.assessmentReport);
                        cmp.set("v.showErrorMsg",true);
                        cmp.set("v.showSpinner",false);
                        if(returnValue.errorMsg.includes('Total Hours Used') || returnValue.errorMsg.includes('Total Hours Absent')){
                            cmp.set("v.card",{'title' : 'Total Hours Warning', 'message' : returnValue.errorMsg});
                            cmp.set('v.isShowClose', false);
                            helper.setCongaUrl(cmp, returnValue);
                            cmp.set("v.ca", returnValue.contactAssignments);
                        }else if(returnValue.errorMsg.includes('pending')){
                            
                            cmp.set('v.isShowProceed', true);
                        }
                    }
                }else{
                    cmp.set("v.isLoad",true);
                    cmp.set('v.isShowClose', true);
                    helper.setCongaUrl(cmp, returnValue);                    
                }
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                cmp.set("v.showErrorMsg",true);
                cmp.set("v.card",{'title' : 'Error', 'message' : errors[0].message});
            }),
            false,
            false,
            false
        );
	},
    setCongaUrl: function(cmp, returnValue){ 
        cmp.set("v.showSpinner",false);
        if(returnValue && returnValue.sessionIdServerURL){
            var serverUrlSessionId = JSON.parse(returnValue.sessionIdServerURL);
            var url = "https://composer.congamerge.com?sessionId="+serverUrlSessionId["sessionId"]+
                "&serverUrl="+serverUrlSessionId["serverUrl"] + returnValue.congaURL;
            cmp.set("v.congaUrl",url);
        }
    },
    updateTotalHrsUsed: function(cmp, helper, assessmentReport){
        cmp.set("v.showSpinner",true);
        const server = cmp.find('server');
        var action = cmp.get("c.updateAssessmentReportRecord");
        server.callServer(
            action, {assessmentReport : assessmentReport},
            false,
            $A.getCallback(function(response) {                
                cmp.set("v.showSpinner",false);
                if(response == 'success'){
                    helper.updateAssesmentReportStatus(cmp);        
                }else{
                    cmp.set("v.showErrorMsg",true);
                	cmp.set("v.card",{'title' : 'Error', 'message' : response});
                }
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                cmp.set("v.showErrorMsg",true);
                cmp.set("v.card",{'title' : 'Error', 'message' : errors[0].message});
            }),
            false,
            false,
            false
        );
    },
    updateAssesmentReportStatus : function(cmp) { 
        var self = this;
        cmp.set("v.showSpinner",true);
        const server = cmp.find('server');
        var action = cmp.get("c.updateAssesmentReports");
        server.callServer(
            action, {arId : cmp.get("v.recordId")},
            false,
            $A.getCallback(function(response) {
                var congaUrl = cmp.get("v.congaUrl");
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": congaUrl
                });
                urlEvent.fire();
                $A.get("e.force:closeQuickAction").fire(); 
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) {
                cmp.set("v.showSpinner",false);
                cmp.set("v.showErrorMsg",true);
                cmp.set("v.card",{'title' : 'Error', 'message' : errors[0].message});
            }),
            false,
            false,
            false
        );
    }
 })