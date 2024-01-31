({
    doInit : function(cmp, event, helper) {
        helper.getCongaUrlHelper(cmp, event, helper); 
    },
    launchUrl : function(cmp, event, helper) {
        helper.updateAssesmentReportStatus(cmp);
    },
    closeAction : function(cmp, event, helper) {
        helper.unSubscribePlatformEvent(cmp, event, helper);
        $A.get("e.force:closeQuickAction").fire();
    },
    yesAction: function(cmp, event, helper){
        var assessmentReport = cmp.get('v.assessmentReport'),
               ca = cmp.get("v.ca");
        if(ca && ca.length > 0){
            assessmentReport.Total_Hours_Absent__c = ca[0].Student_Hours_Absent__c;
        }else{
        	assessmentReport.Total_Hours_Used__c = assessmentReport.Project_Task__r.Total_Hours_Used_For_Language_Training__c;
        }
        helper.updateTotalHrsUsed(cmp, helper, assessmentReport);
    }
})