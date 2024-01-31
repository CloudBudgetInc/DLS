({
    doInit : function(cmp, event, helper) {
        helper.getReportTypes(cmp,event,helper);
    },
     closeAction : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
     },
    createAssesmentReports : function(cmp, event, helper) {
        var  reportDateInput = cmp.find("reportDateInput");
        var reportTypeInput = cmp.find("reportTypeInput");
        var isValid = true;
        
        if(!reportDateInput.get("v.value")){
            isValid = false;
            reportDateInput.set("v.errors", [{message:" "}])
        }else{
            reportDateInput.set("v.errors",null);
        }
        
        if(!reportTypeInput.get("v.value")){
            isValid = false;
            $A.util.addClass(reportTypeInput, 'slds-has-error'); 
        }else {
            $A.util.removeClass(reportTypeInput, 'slds-has-error'); 
        }

        if(isValid){
            var self = this;
            cmp.set("v.showSpinner",true);
            const server = cmp.find('server');
            var action = cmp.get("c.createAssessmentReportRecs");
            server.callServer(
                action, {proId: cmp.get("v.recordId"),
                         'reportValJSON' : JSON.stringify(cmp.get("v.trainingReportInfo"))
                        },
                false,
                $A.getCallback(function(response) {
                    console.log(response);
                    cmp.set("v.card",{'title' : 'Assessment Report', 'message' : response, 'showCloseBtn' : true,showMsg:true});
                    cmp.set("v.showSpinner",false);
                }),
                $A.getCallback(function(errors) {
                    cmp.set("v.showSpinner",false);
                    cmp.set("v.card",{'title' : 'Error', 'message' : errors[0].message, 'showCloseBtn' : true,showMsg:true});
                }),
                false,
                false,
                false
            );
        }
    }
})