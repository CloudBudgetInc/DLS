({
    doInit : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        
        var action = cmp.get("c.getInitialProjectTaskRelatedCA");
        action.setParams({
            projectInfo  : String(window.location)
        });
        action.setCallback(this, function(response) {
            var status = response.getState(); 
            if(status == "SUCCESS") {
                var returnValue = JSON.parse(response.getReturnValue());
                console.log('returnValue'+JSON.stringify(returnValue));
                cmp.set("v.projectTaskList",returnValue.proTasks);
                cmp.set("v.showSpinner",false);
                cmp.set("v.projectId",returnValue.projectId);
                cmp.set("v.templateType",returnValue.templateType);
            } else {
                cmp.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message :  response.getError()[0].message,
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();  
            }
        });
        $A.enqueueAction(action);
    },
    saveBtnClk : function(cmp, event, helper) {
        cmp.set("v.isSaveAndGenAction",false);
        helper.totalQtyplannedHoursValidation(cmp, event, helper)
    },
    closeWarningIconClk : function(cmp, event, helper) {
        var projectTaskId = event.getSource().get("v.alternativeText");
        var proTaskList = cmp.get("v.projectTaskList");
        
        for(var i = 0;i < proTaskList.length;i++){
            if(proTaskList[i].proTaskId == projectTaskId){
                proTaskList[i]['showMsg'] = '';
            }
        }
        cmp.set("v.projectTaskList",proTaskList);
        cmp.set("v.isProceedBtn",false);
    },
    hoursValidation : function(cmp, event, helper) {
        var projectTaskId =  event.getSource().get("v.name");
        var proTaskList = cmp.get("v.projectTaskList");
        
        for(var i = 0;i < proTaskList.length;i++){
            if(proTaskList[i].proTaskId == projectTaskId){
                proTaskList[i]['showMsg'] = '';
            }
        }
        cmp.set("v.projectTaskList",proTaskList);
        cmp.set("v.isProceedBtn",false);
    },
    saveAndGenBtnClk : function(cmp, event, helper){
        cmp.set("v.isSaveAndGenAction",true);
        helper.totalQtyplannedHoursValidation(cmp, event, helper);
        
    },
    proceedBtnClk : function(cmp, event, helper){
        cmp.set("v.isSaveAndGenAction",false);
        helper.saveCARecords(cmp, event, helper);
    },
    cancelBtnClk : function(cmp,event,helper){
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        
        sObjectEvent .setParams({
            "recordId":cmp.get("v.projectId"), 
            "slideDevName": "detail"
        });
        sObjectEvent.fire(); 
    },
    navigateToInstructor : function(cmp,event,helper){
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        
        sObjectEvent .setParams({
            "recordId":event.currentTarget.name, 
            "slideDevName": "detail"
        });
        sObjectEvent.fire(); 
    },
    navigateToProTask : function(cmp,event,helper){
        
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent .setParams({
            "recordId":event.currentTarget.name, 
            "slideDevName": "detail"
        });
        sObjectEvent.fire(); 
    }
    
})