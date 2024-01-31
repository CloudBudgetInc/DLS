({
    doInit : function(cmp, event, helper) {
        if(cmp.get("v.sObjectName") == 'Opportunity'){
            helper.validateStartAndEndDate(cmp, event, helper);        
        }else{
        	helper.getStudentPolicyInfo(cmp, event, helper);
        }
    },
    launchConga : function(cmp, event, helper) {
        var selectedCA =  cmp.get("v.selectedStudent");
        var congaDetailList = cmp.get("v.congaDetailList");
        
        for(var i = 0;i < congaDetailList.length;i++){
            if(congaDetailList[i].value == selectedCA){
                helper.updateOppProjectsRecords(cmp, event, helper, congaDetailList[i].congaUrl);  
            }
        }
    },
    studentChange : function(cmp, event, helper) {
        var selectedCA =  cmp.get("v.selectedStudent");
        var congaDetailList = cmp.get("v.congaDetailList");
        var getWarnMsg = null;
        
        for(var i = 0;i < congaDetailList.length;i++){
            if(congaDetailList[i].value == selectedCA && congaDetailList[i].customMessage != null){
                getWarnMsg = congaDetailList[i].customMessage;
            }
        }
        cmp.set("v.showWarningMsg",getWarnMsg);
    }

})