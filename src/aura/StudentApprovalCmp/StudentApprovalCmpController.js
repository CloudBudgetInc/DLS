({
    doinit : function(cmp, event, helper) {
        var device = $A.get("$Browser.formFactor");
        
        if (device == 'PHONE') {
            cmp.set("v.displayDevice",'Mobile');
        } else {
            cmp.set("v.displayDevice",'PC');
        }
        cmp.set("v.showSpinner",true);
        var regex = /[?&]([^=#]+)=([^&#]*)/g,
            url = (decodeURIComponent(window.location)),
            params = {},
            match;
        while(match = regex.exec(url)) {
            params [match[1]] = match[2].replace(/[+]/g,' ');
        }
        params['proIdAndInsId'] = params['projectId']+'-'+params['instructorId'];
        cmp.set("v.fromCommunityUrlMap",params);
        helper.getFilterInitialInformation(cmp,event,helper);
    },
    onChangeprojectClk  : function(cmp, event, helper) {
        if(cmp.get("v.updateDayEntriesRecords").length == 0 && cmp.get("v.updateStuAttendanceRecords").length == 0){
            helper.onChangeprojectHelper(cmp, event, helper);
        }else{
            cmp.set("v.filterChanged",'Project');
            helper.openFilterChangeConfirmationModal(cmp);
        }
    },
    onSelectedWeekChange:function(cmp, event){
        cmp.set('v.oldSelectedWeek', event.getParam("oldValue"));
    },
    onSelectedProjectChange: function(cmp, event){
        cmp.set('v.oldSelectedProject', event.getParam("oldValue"));
    },
    onChangeWeekClk: function(cmp, event, helper) {
        
        if(cmp.get("v.updateDayEntriesRecords").length == 0 && cmp.get("v.updateStuAttendanceRecords").length == 0){
            cmp.set("v.fromCommunityUrlMap",{});
            helper.getProFilterDetails(cmp, event, helper);
            var weekDetailsList =  cmp.get("v.weekDetailList");
            weekDetailsList['notes'] = [];
            cmp.set("v.weekDetailList",weekDetailsList);
        }else{
            cmp.set("v.filterChanged",'Week');
            helper.openFilterChangeConfirmationModal(cmp);
        }
    },
    approveRejectIconClk : function(cmp, event, helper){
        var indexs = event.getSource().get("v.name");
        var rowIndex = parseInt(indexs.split("/")[0]);
        var dayIndex = parseInt(indexs.split("/")[1]);
        cmp.set("v.rowIndex",rowIndex);
        cmp.set("v.dayIndex",dayIndex);
        var weekDetails = cmp.get("v.weekDetailList");
        
        weekDetails.entries[rowIndex].dayEntries[dayIndex].studentApprovalStatus = 'Submitted';
        weekDetails.entries[rowIndex].dayEntries[dayIndex].color = null;
        cmp.set("v.weekDetailList", cmp.get("v.weekDetailList"));
        
        var selectedDayEntries = cmp.get("v.weekDetailList");
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
        
        var weekDetail = cmp.get("v.weekDetailList");
        
        weekDetail.entries[rowIndex].dayEntries[dayIndex].studentApprovalStatus = 'Approved';
        weekDetail.entries[rowIndex].dayEntries[dayIndex].color = null;
        var dayId = weekDetail.entries[rowIndex].dayEntries[dayIndex].dayId;
        cmp.set("v.weekDetailList",weekDetail);
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
        cmp.find("showRejectReason").openModal();
    },
    viewReasonClk : function(cmp, event, helper){
        var indexs = event.currentTarget.name;
        var rowIndex = parseInt(indexs.split("/")[0]);
        var dayIndex = parseInt(indexs.split("/")[1]);
        cmp.set("v.rejectionReason","");
        var weekDetails = cmp.get("v.weekDetailList");
        var rejectionreason = weekDetails.entries[rowIndex].dayEntries[dayIndex].rejectionReason;
        cmp.set("v.rowIndex",rowIndex);
        cmp.set("v.dayIndex",dayIndex);
        cmp.set("v.rejectionReason",rejectionreason);
        cmp.set("v.showRejectionReasonModal",true);
        cmp.find("showRejectReason").openModal();
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
            var selectedDayEntries = cmp.get("v.weekDetailList");
            var rowIndex = cmp.get("v.rowIndex");
            var dayIndex = cmp.get("v.dayIndex");
            selectedDayEntries.entries[rowIndex].dayEntries[dayIndex].rejectionReason = cmp.get("v.rejectionReason");
            selectedDayEntries.entries[rowIndex].dayEntries[dayIndex].studentApprovalStatus = 'Rejected';
            selectedDayEntries.entries[rowIndex].dayEntries[dayIndex].color = null;
            var dayId =  selectedDayEntries.entries[rowIndex].dayEntries[dayIndex].dayId;
            cmp.set("v.weekDetailList", selectedDayEntries);
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
        if(cmp.get("v.filterChangeConfirmationModal"))
        	helper.closeFilterChangeConfirmationModal(cmp);
       helper.saveDayEntryAndAttendanceRecords(cmp, event, helper);
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
        cmp.find("showStuTimeRejectReason").openModal();
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
        cmp.find("showStuTimeRejectReason").openModal();
    },
    studentNotesClk : function(cmp,event,helper){
        var indexs = event.currentTarget.name;
        cmp.set("v.studentAtnRec",{});
        var stuRowIndex = parseInt(indexs.split("/")[0]);
        var stuColIndex = parseInt(indexs.split("/")[1]);
        
        var stuRowEntries = cmp.get("v.studentRowEntries")[stuRowIndex].entries[stuColIndex];
        cmp.set("v.studentAtnRec",stuRowEntries);
        cmp.set("v.showStuNotesModal",true);
        cmp.find("showStuNotes").openModal();
    },
    stuNotesCloseClk : function(cmp,event,helper){
         cmp.set("v.showStuNotesModal",false);
    },
    successCloseClk : function(cmp,event,helper){
        cmp.set("v.saveSuccessModel",false);
        helper.getDayRowsFormation(cmp,event,helper);
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
                cmp.find("viewScheduleModal").openModal();
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
    approveRejectValCloseClk : function(cmp,event,helper){
        cmp.set("v.showStuApprovalValModal",false);
    },
    needHelpBtnClick : function(cmp, event, helper){
        window.location.href = '/student/s/contactsupport';
    },
    closeModalWithoutAnyAction : function(cmp, event, helper){
        var oldSelectedWeek = cmp.get('v.oldSelectedWeek'),
              oldSelectedProject =  cmp.get('v.oldSelectedProject');
        if(oldSelectedProject)
        	cmp.set('v.selectedProject', oldSelectedProject);
		if(oldSelectedWeek)
                cmp.set('v.selectedWeek', oldSelectedWeek);  
        
        helper.closeFilterChangeConfirmationModal(cmp);
    }    
})