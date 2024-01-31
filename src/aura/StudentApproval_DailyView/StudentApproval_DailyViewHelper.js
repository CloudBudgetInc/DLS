({
    apexDateFormatFunction : function(dateval){
        return dateval.split('/')[2]+'-'+dateval.split('/')[0]+'-'+dateval.split('/')[1];
    },
    saveDayEntryAndAttendanceRecords : function(cmp, event, helper){
        if((cmp.get("v.updateDayEntriesRecords").length > 0 || cmp.get("v.updateStuAttendanceRecords").length > 0)){
            cmp.set("v.showSpinner",true);
            var action =  cmp.get("c.updateDayAndAttendanceEntryRecord");
            action.setParams({
                'tCDRecords':JSON.stringify(cmp.get("v.updateDayEntriesRecords")),
                'projectRTName':cmp.get("v.projectRTName"),
                'stuAttendanceRecords':JSON.stringify(cmp.get("v.updateStuAttendanceRecords"))
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    cmp.set("v.updateDayEntriesRecords",[]);
                    cmp.set("v.updateStuAttendanceRecords",[]);
                    cmp.set("v.saveConfirmationModel",false);
                    cmp.set("v.showSpinner",false);
                    cmp.set("v.saveSuccessModel",true);
                    cmp.find("successModal").open();
                }else {
                    cmp.set("v.showSpinner",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        message :  response.getError()[0].message,
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }    });
            $A.enqueueAction(action);
        }
    },
    validateDayAndAttendanceEntryRecs : function(cmp, event, helper){
        
        if(cmp.get("v.updateDayEntriesRecords").length == 0 && cmp.get("v.updateStuAttendanceRecords").length == 0){
            
            cmp.set("v.stuApprovalValMessage",'Please update any of time entry to save the changes');
            cmp.set("v.showStuApprovalValModal",true);
            cmp.find("stuApprovalValModal").open();
            
        }else if(cmp.get('v.weekDetailInfo').isStudentLeader && cmp.get("v.updateDayEntriesRecords").length != cmp.get("v.updateStuAttendanceRecords").length){
            cmp.set("v.stuApprovalValMessage",'You are also required to approve the "Attendance" entries provided by your instructor. Approve each entry then click Save.');
            cmp.set("v.showStuApprovalValModal",true);
            cmp.find("stuApprovalValModal").open();
        }else {
            cmp.set("v.saveConfirmationModel",true);
            cmp.find("saveConfirmModal").open();
        }
    }
    
})