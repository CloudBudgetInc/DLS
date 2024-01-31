({
    doinit : function(cmp, event, helper) {
        cmp.set("v.isCongaPickist",true);
        cmp.find("congaTypeId").set("v.value",'Job Summary Report - Labor Actual');
    },
 
    closeAction : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    },
    downloadCongaDoc : function(cmp, event, helper) {
        helper.congaUrl(cmp,event,helper,cmp.get("v.selectedtemplateOption"),cmp.get("v.congaQueryName"));
    },
    closeSldsModal : function(cmp, event, helper) {
        $A.get("e.force:closeQuickAction").fire(); 
    },
    openValidationVFPage : function(cmp, event, helper) {
        var idRec = cmp.get("v.recordId");
        $A.get("e.force:closeQuickAction").fire(); 
       // window.open("/apex/contactAssignmentHoursValidation?projectId="+idRec+"&web=true&templateType=Planned",'_self');
         window.open("/lightning/n/Managed_Planned_Hours?templateType=Planned&web=true&projectId="+idRec,'_self');
    },
    proceedClk : function(cmp, event, helper) {
        
        if(cmp.find("congaTypeId").get("v.value") == 'Job Summary Report - Labor Actual'){
            var templateName = 'Job Summary Report - Labor Actual';
            cmp.set("v.congaQueryName",'Project Query for Job Summary Report,Job Summary Report - Project Task Query,ContactAssign Prep Time Query for Job Summary Report - Actual,ContactAssign Query for Job Summary Report - Actual')
            helper.getCongaForJobSummaryReport(cmp,event,helper,templateName);
        }else if(cmp.find("congaTypeId").get("v.value") == 'Job Summary Report - Labor Planned'){
            var templateName = 'Job Summary Report - Labor Planned';
            cmp.set("v.congaQueryName",'Project Query for Job Summary Report,Job Summary Report - Project Task Query,ContactAssign Prep Time Query for Job Summary Report,ContactAssign Query for Job Summary Report');
            helper.getCongaForJobSummaryReport(cmp,event,helper,templateName);
        }
    }
})