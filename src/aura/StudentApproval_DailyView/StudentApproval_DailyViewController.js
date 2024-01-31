({
    doInit : function(cmp, event, helper) {
        var selectedDayNotesInfo = [];
        var weekDetailInfo = cmp.get("v.weekDetailInfo");
        var studentSummaryDetails = cmp.get("v.studentSummaryDetails");
        var isDisableSaveBtn = false;
        var studentRowEntries = cmp.get("v.studentRowEntries");
        
        if(weekDetailInfo && weekDetailInfo.notes){
            var notes = weekDetailInfo.notes;
            for(var i = 0;i < notes.length;i++){
                if(studentSummaryDetails['selectedWkDate'] == notes[i].daydate){
                    selectedDayNotesInfo.push(notes[i]);
                }
            }
        }
        cmp.set("v.selectedDayNotesInfo",selectedDayNotesInfo);
        
        if(weekDetailInfo && weekDetailInfo.entries){
            for(var i = 0;i < weekDetailInfo.entries.length;i++){
                if(weekDetailInfo.entries[i].dayEntries){
                    for(var j = 0;j < weekDetailInfo.entries[i].dayEntries.length;j++){
                        if(weekDetailInfo.entries[i].dayEntries[j].displayDate == studentSummaryDetails['selectedWkDate']){
                            if(!weekDetailInfo.entries[i].dayEntries[j].studentApprovalStatus){
                                isDisableSaveBtn =  true;
                            }
                        }
                    }
                }
            }
        }
        if(studentRowEntries.length > 0){
            for(var i = 0;i < studentRowEntries.length;i++){
                if(studentRowEntries[i].entries && studentRowEntries[i].entries.length > 0){
                    for(var j = 0;j < studentRowEntries[i].entries.length;j++){
                        if(studentRowEntries[i].entries[j].displayDate == studentSummaryDetails['selectedWkDate'] && cmp.get("v.studentId") == studentRowEntries[i].entries[j].studentId){
                            if(!studentRowEntries[i].entries[j].studentApprovalStatus){
                                isDisableSaveBtn =  true;
                            }
                        }
                    }
                }
            }
        }
        cmp.set("v.isDisableSaveBtn",isDisableSaveBtn);
    },
    backToHomePageView : function(cmp, event, helper) {
        var summaryDetails = cmp.get("v.studentSummaryDetails");
        
        if(cmp.get("v.updateDayEntriesRecords").length == 0 && cmp.get("v.updateStuAttendanceRecords").length == 0){
            summaryDetails.isHomeView = true;
            summaryDetails.isDailyView = false;
            summaryDetails.isBackFromDailyView = false;
        }else{
            summaryDetails.isBackFromDailyView = true;
            cmp.set("v.saveConfirmationModel",true);
            cmp.find("saveConfirmModal").open();
        }
        cmp.set("v.studentSummaryDetails",summaryDetails);

    },
    viewProjectRelatedSchedule : function(cmp,event,helper){
        
        var dt1 = helper.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[0]);
        var dt2 = helper.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[1]);
        
        cmp.set("v.showSpinner",true);
        var proRelSchduleArray = [];
        var action =  cmp.get("c.getProjectRelatedSchedules");
        action.setParams({
            'projectId': cmp.get("v.selectedProject").split('-')[0],
            'startDate' : dt1,
            'endDate' : dt2
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result =  response.getReturnValue();
                cmp.set("v.showSpinner",false);
                proRelSchduleArray = JSON.parse(result) 
                cmp.set("v.projectRelScheduleRecords",proRelSchduleArray);
                cmp.set("v.viewClassScheduleModal",true);
                cmp.find("viewScheduleModal").open();
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
            }
        });
        $A.enqueueAction(action);
        
    },
    closeScheduleTableClk : function(cmp,event,helper){
        cmp.set("v.viewClassScheduleModal",false);
    },
    needHelpBtnClick : function(cmp, event, helper){
        window.location.href = '/student/s/topic/'+cmp.get("v.topicId")+'/timekeeping?';
    },
    /* For DODA and DLW_Projects(Attendence)*/
    stuTimeApproveClk : function(cmp,event,helper){
        var indexs = event.getSource().get("v.alternativeText");
        var stuAttendenceRecords = cmp.get("v.updateStuAttendanceRecords");
        var stuRowIndex = parseInt(indexs.split("/")[0]);
        var stuColIndex = parseInt(indexs.split("/")[1]);
        
        cmp.set("v.stuRowIndex",stuRowIndex);
        cmp.set("v.stuColIndex",stuColIndex);
        
        var studentRowEntries = cmp.get("v.studentRowEntries");
        studentRowEntries[stuRowIndex].entries[stuColIndex].studentApprovalStatus = 'Approved';
        studentRowEntries[stuRowIndex].entries[stuColIndex].color = null;
        cmp.set("v.studentRowEntries",studentRowEntries);
        var attendanceId = studentRowEntries[stuRowIndex].entries[stuColIndex].attendanceId;
        
        var index = -1;
        for(var i = 0;i < stuAttendenceRecords.length;i++){
            if(attendanceId == stuAttendenceRecords[i].Id ){
                index = i; 
            }
        }
        if(index >= 0){
            stuAttendenceRecords[index] = {'Id':attendanceId,'Rejection_Reason__c':null,'Student_Approval_Status__c':'Approved'};
        }else{
            stuAttendenceRecords.push({'Id':attendanceId,'Rejection_Reason__c':null,'Student_Approval_Status__c':'Approved'});
        }
        cmp.set("v.updateStuAttendanceRecords",stuAttendenceRecords);
    },
    stuTimeRejectionClk : function(cmp,event,helper){
        var indexs = event.getSource().get("v.alternativeText");
        var stuRowIndex = parseInt(indexs.split("/")[0]);
        var stuColIndex = parseInt(indexs.split("/")[1]);
        
        cmp.set("v.stuRowIndex",stuRowIndex);
        cmp.set("v.stuColIndex",stuColIndex);
        cmp.set("v.stuTimeRejectionReason",'');
        
        var studentRowEntries = cmp.get("v.studentRowEntries");
        var rejectionreason = studentRowEntries[stuRowIndex].entries[stuColIndex].rejectionReason;
        cmp.set("v.stuTimeRejectionReason",rejectionreason);
        cmp.set("v.showStuTimeRejectionReasonModal",true);
        cmp.find("showStuTimeRejectReason").open();
    },
    submitStuTimeRejectReasonModel : function(cmp,event,helper){
        
        var rejectReasonInput = cmp.find("reason1");
        var stuAttendenceRecords = cmp.get("v.updateStuAttendanceRecords");
        var isValid = true;
        
        if(!rejectReasonInput.get("v.value")){
            $A.util.addClass(rejectReasonInput, 'slds-has-error'); 
            isValid = false;
        }else {
            $A.util.removeClass(rejectReasonInput, 'slds-has-error'); 
        }
        if(isValid){
            cmp.set("v.showStuTimeRejectionReasonModal",false);
            var stuRowIndex = cmp.get("v.stuRowIndex");
            var stuColIndex = cmp.get("v.stuColIndex");
            
            var studentRowEntries = cmp.get("v.studentRowEntries");
            studentRowEntries[stuRowIndex].entries[stuColIndex].studentApprovalStatus = 'Rejected';
            studentRowEntries[stuRowIndex].entries[stuColIndex].color = null;
            studentRowEntries[stuRowIndex].entries[stuColIndex].rejectionReason = cmp.get("v.stuTimeRejectionReason");
            cmp.set("v.studentRowEntries",studentRowEntries);
            var attendanceId = studentRowEntries[stuRowIndex].entries[cmp.get("v.stuColIndex")].attendanceId;
            var index = -1;
            
            for(var i = 0;i < stuAttendenceRecords.length;i++){
                if(attendanceId == stuAttendenceRecords[i].Id ){
                    index = i; 
                }
            }
            if(index >= 0){
                stuAttendenceRecords[index] = {'Id':attendanceId,'Rejection_Reason__c':cmp.get("v.stuTimeRejectionReason"),'Student_Approval_Status__c':'Rejected'};
            }else{
                stuAttendenceRecords.push({'Id':attendanceId,'Rejection_Reason__c':cmp.get("v.stuTimeRejectionReason"),'Student_Approval_Status__c':'Rejected'});
            }
            cmp.set("v.updateStuAttendanceRecords",stuAttendenceRecords);
        }
    },
    rejectionStuTimeCloseClk : function(cmp,event,helper){
        cmp.set("v.showStuTimeRejectionReasonModal",false);
    },
    stuAttApproveRejecticonClk : function(cmp,event,helper){
        var indexs = event.getSource().get("v.name");
        var stuRowIndex = parseInt(indexs.split("/")[0]);
        var stuColIndex = parseInt(indexs.split("/")[1]);
        var stuAttendenceRecords = cmp.get("v.updateStuAttendanceRecords");
        
        cmp.set("v.stuRowIndex",stuRowIndex);
        cmp.set("v.stuColIndex",stuRowIndex);
        
        var studentRowEntries = cmp.get("v.studentRowEntries");
        studentRowEntries[stuRowIndex].entries[stuColIndex].studentApprovalStatus = 'Submitted';
        studentRowEntries[stuRowIndex].entries[stuColIndex].color = null;
        studentRowEntries[stuRowIndex].entries[stuColIndex].rejectionReason = '';
        cmp.set("v.studentRowEntries",studentRowEntries);
        var attendanceId = studentRowEntries[stuRowIndex].entries[stuColIndex].attendanceId;
        
        var index = -1;
        for(var i = 0;i < stuAttendenceRecords.length;i++){
            if(attendanceId == stuAttendenceRecords[i].Id ){
                index = i; 
            }
        }
        if(index >= 0){
            stuAttendenceRecords[index] = {'Id':attendanceId,'Rejection_Reason__c':null,'Student_Approval_Status__c':'Submitted'};
        }else{
            stuAttendenceRecords.push({'Id':attendanceId,'Rejection_Reason__c':null,'Student_Approval_Status__c':'Submitted'});
        }
        cmp.set("v.updateStuAttendanceRecords",stuAttendenceRecords);
        console.log(JSON.stringify(stuAttendenceRecords));
    },
    viewStuTimeReasonClk : function(cmp,event,helper){
        var indexs = event.currentTarget.name;
        cmp.set("v.stuTimeRejectionReason","");
        var stuRowIndex = parseInt(indexs.split("/")[0]);
        var stuColIndex = parseInt(indexs.split("/")[1]);
        cmp.set("v.stuRowIndex",stuRowIndex);
        cmp.set("v.stuColIndex",stuColIndex);
        
        var rejectionreason = cmp.get("v.studentRowEntries")[stuRowIndex].entries[stuColIndex].rejectionReason;
        cmp.set("v.stuTimeRejectionReason",rejectionreason);
        cmp.set("v.showStuTimeRejectionReasonModal",true);
        cmp.find("showStuTimeRejectReason").open();
    },
    studentNotesClk : function(cmp,event,helper){
        var indexs = event.currentTarget.name;
        cmp.set("v.studentAtnRec",{});
        var stuRowIndex = parseInt(indexs.split("/")[0]);
        var stuColIndex = parseInt(indexs.split("/")[1]);
        
        var stuRowEntries = cmp.get("v.studentRowEntries")[stuRowIndex].entries[stuColIndex];
        cmp.set("v.studentAtnRec",stuRowEntries);
        cmp.set("v.showStuNotesModal",true);
        cmp.find("showStuNotes").open();
    },
    stuNotesCloseClk : function(cmp,event,helper){
        cmp.set("v.showStuNotesModal",false);
    },
    approveRejectIconClk : function(cmp, event, helper){
        var indexs = event.getSource().get("v.name");
        var rowIndex = parseInt(indexs.split("/")[0]);
        var dayIndex = parseInt(indexs.split("/")[1]);
        cmp.set("v.rowIndex",rowIndex);
        cmp.set("v.dayIndex",dayIndex);
        var weekDetails = cmp.get("v.weekDetailInfo");
        
        weekDetails.entries[rowIndex].dayEntries[dayIndex].studentApprovalStatus = 'Submitted';
        weekDetails.entries[rowIndex].dayEntries[dayIndex].color = null;
        cmp.set("v.weekDetailInfo", cmp.get("v.weekDetailInfo"));
        
        var selectedDayEntries = cmp.get("v.weekDetailInfo");
        var dayId =  selectedDayEntries.entries[rowIndex].dayEntries[dayIndex].dayId;
        var updateDayEntriesRecords = cmp.get("v.updateDayEntriesRecords");
        var index = -1;
        
        for(var i = 0;i < updateDayEntriesRecords.length;i++){
            if(dayId == updateDayEntriesRecords[i].Id ){
                index = i; 
            }
        }
        if(index >= 0){
            updateDayEntriesRecords[index] = {'Id':dayId,'Student_Approval_Status__c':'Submitted','Student_Approver__c':null,'Student_Notes__c':null,'Student_Approved_Date__c':null};
        }else{
            updateDayEntriesRecords.push({'Id':dayId,'Student_Approval_Status__c':'Submitted','Student_Approver__c':null,'Student_Notes__c':null,'Student_Approved_Date__c':null});
        }
        cmp.set("v.updateDayEntriesRecords",updateDayEntriesRecords);  
    },
    approveClk : function(cmp, event, helper){
        var indexs = event.getSource().get("v.alternativeText");
        var rowIndex = parseInt(indexs.split("/")[0]);
        var dayIndex = parseInt(indexs.split("/")[1]);
        cmp.set("v.rowIndex",rowIndex);
        cmp.set("v.dayIndex",dayIndex);
        
        var weekDetail = cmp.get("v.weekDetailInfo");
        
        weekDetail.entries[rowIndex].dayEntries[dayIndex].studentApprovalStatus = 'Approved';
        weekDetail.entries[rowIndex].dayEntries[dayIndex].color = null;
        var dayId = weekDetail.entries[rowIndex].dayEntries[dayIndex].dayId;
        cmp.set("v.weekDetailInfo",weekDetail);
        var updateDayEntriesRecords = cmp.get("v.updateDayEntriesRecords");
        var index = -1;
        
        for(var i = 0;i < updateDayEntriesRecords.length;i++){
            if(dayId == updateDayEntriesRecords[i].Id ){
                index = i; 
            }
        }
        if(index >= 0){
            updateDayEntriesRecords[index] = {'Id':dayId,'Student_Approval_Status__c':'Approved','Student_Approver__c':cmp.get("v.studentId"),'Student_Notes__c':null};
        }else{
            updateDayEntriesRecords.push({'Id':dayId,'Student_Approval_Status__c':'Approved','Student_Approver__c':cmp.get("v.studentId"),'Student_Notes__c':null});
        }
        cmp.set("v.updateDayEntriesRecords",updateDayEntriesRecords);  
    },
    rejectClk: function(cmp, event, helper){
        var indexs = event.getSource().get("v.alternativeText");
        var rowIndex = parseInt(indexs.split("/")[0]);
        var dayIndex = parseInt(indexs.split("/")[1]);
        
        cmp.set("v.rowIndex",rowIndex);
        cmp.set("v.dayIndex",dayIndex);
        cmp.set("v.showRejectionReasonModal",true);
        cmp.set("v.rejectionReason","");
        cmp.find("showRejectReason").open();
    },
    viewReasonClk : function(cmp, event, helper){
        var indexs = event.currentTarget.name;
        var rowIndex = parseInt(indexs.split("/")[0]);
        var dayIndex = parseInt(indexs.split("/")[1]);
        cmp.set("v.rejectionReason","");
        var weekDetails = cmp.get("v.weekDetailInfo");
        var rejectionreason = weekDetails.entries[rowIndex].dayEntries[dayIndex].rejectionReason;
        cmp.set("v.rowIndex",rowIndex);
        cmp.set("v.dayIndex",dayIndex);
        cmp.set("v.rejectionReason",rejectionreason);
        cmp.set("v.showRejectionReasonModal",true);
        cmp.find("showRejectReason").open();
    },
    submitRejectReasonModel : function(cmp, event, helper){
        var RejectReasonInput = cmp.find("reason");
        var isValid = true;
        
        if(!RejectReasonInput.get("v.value")){
            $A.util.addClass(RejectReasonInput, 'slds-has-error'); 
            isValid = false;
        }else {
            $A.util.removeClass(RejectReasonInput, 'slds-has-error'); 
        }
        
        if(isValid){
            var selectedDayEntries = cmp.get("v.weekDetailInfo");
            var rowIndex = cmp.get("v.rowIndex");
            var dayIndex = cmp.get("v.dayIndex");
            selectedDayEntries.entries[rowIndex].dayEntries[dayIndex].rejectionReason = cmp.get("v.rejectionReason");
            selectedDayEntries.entries[rowIndex].dayEntries[dayIndex].studentApprovalStatus = 'Rejected';
            selectedDayEntries.entries[rowIndex].dayEntries[dayIndex].color = null;
            var dayId =  selectedDayEntries.entries[rowIndex].dayEntries[dayIndex].dayId;
            cmp.set("v.weekDetailInfo", selectedDayEntries);
            var updateDayEntriesRecords = cmp.get("v.updateDayEntriesRecords");
            var index = -1;
            
            for(var i = 0;i < updateDayEntriesRecords.length;i++){
                if(dayId == updateDayEntriesRecords[i].Id ){
                    index = i; 
                }
            }
            if(index >= 0){
                updateDayEntriesRecords[index] = {'Id':dayId,'Student_Approval_Status__c':'Rejected','Student_Approver__c':cmp.get("v.studentId"),'Student_Approved_Date__c':null,'Student_Notes__c':cmp.get("v.rejectionReason")};
            }else{
                updateDayEntriesRecords.push({'Id':dayId,'Student_Approval_Status__c':'Rejected','Student_Approver__c':cmp.get("v.studentId"),'Student_Approved_Date__c':null,'Student_Notes__c':cmp.get("v.rejectionReason")});
            }
            cmp.set("v.updateDayEntriesRecords",updateDayEntriesRecords);  
            cmp.set("v.showRejectionReasonModal",false);
            console.log(JSON.stringify(updateDayEntriesRecords));
        }
    },
    rejectionCloseClk : function(cmp, event, helper){
        cmp.set("v.showRejectionReasonModal",false);
    },
    updateDayEntryAndAttendanceRecords : function(cmp, event, helper){
        helper.validateDayAndAttendanceEntryRecs(cmp, event, helper);
    },
    approveRejectValCloseClk : function(cmp,event,helper){
        cmp.set("v.showStuApprovalValModal",false);
    },
    successCloseClk : function(cmp,event,helper){
        cmp.set("v.saveSuccessModel",false);
        var summaryDetails = cmp.get("v.studentSummaryDetails");
        var cmpEvent = cmp.getEvent("getTCDAttendanceRecords");
        cmpEvent.fire();
        
        if(summaryDetails['isBackFromDailyView']){
            summaryDetails.isHomeView = true;
            summaryDetails.isDailyView = false;
            summaryDetails.isBackFromDailyView = false;            
            cmp.set("v.studentSummaryDetails",summaryDetails);
        }
    },
    saveTimeEntries : function(cmp,event,helper){
        var summaryDetails = cmp.get("v.studentSummaryDetails");
       
        helper.saveDayEntryAndAttendanceRecords(cmp,event,helper);
    },
    confirmationCancelClk :  function(cmp,event,helper){
        var summaryDetails = cmp.get("v.studentSummaryDetails");
        
        if(summaryDetails.isBackFromDailyView){
            summaryDetails.isHomeView = true;
            summaryDetails.isDailyView = false;
            
            cmp.set("v.updateDayEntriesRecords",[]);
            cmp.set("v.updateStuAttendanceRecords",[]);
            cmp.set("v.studentSummaryDetails",summaryDetails);
            var cmpEvent = cmp.getEvent("getTCDAttendanceRecords");
            cmpEvent.fire();
        }
        cmp.set("v.saveConfirmationModel",false);
    }
})