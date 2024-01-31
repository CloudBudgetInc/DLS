({
	doinit : function(cmp, event, helper) {
        console.log('::::::index:::::',cmp.get("v.index"));
        console.log('::::::dayRecord:::::',cmp.get("v.dayRecord"));
        console.log('::::detailMap:::',cmp.get("v.detailMap"));
        var detailMap = cmp.get("v.detailMap");
        cmp.set("v.projectRTName",detailMap.projectData[0].projectRTName);
        cmp.set("v.startTimeList",detailMap.timeList);
        cmp.set("v.endTimeList",detailMap.timeList);
        cmp.set("v.amStartTimeList",detailMap.amTimeList);
        cmp.set("v.amEndTimeList",detailMap.amTimeList);
        cmp.set("v.pmStartTimeList",detailMap.pmTimeList);
        cmp.set("v.pmEndTimeList",detailMap.pmTimeList);
        cmp.set("v.defaultCostRateRateType",detailMap.defaultCostRateRateType);
	},
    openScheduleModel : function(cmp, event, helper){
        cmp.set("v.displayScheduleModel",true);
        if(Array.isArray(cmp.find("scheduleModel"))){
            cmp.find("scheduleModel")[0].open();
        }else {
            cmp.find("scheduleModel").open();
        }
    },
    closeScheduleModel : function(cmp, event, helper){
        if(Array.isArray(cmp.find("scheduleModel"))){
            cmp.find("scheduleModel")[0].close();
        }else {
            cmp.find("scheduleModel").close();
        }
        cmp.set("v.displayScheduleModel",false);
    },
    backToSummary : function(cmp, event, helper){
        
        var isChanged = helper.FindTimeEntryChanges(cmp,'From Filter Change');
        console.log('isChanged:::',isChanged);
        
        if(isChanged){
            cmp.set("v.backClickConfirmation",true);
            if(Array.isArray(cmp.find("backClickConfirmModal"))) {
                cmp.find("backClickConfirmModal")[0].open();
            }else{
                cmp.find("backClickConfirmModal").open();
            }
        }else {
            helper.fireBackClickEvent(cmp,event);
        }
    },
    callSaveFunction : function(cmp, event,helper){
        if(Array.isArray(cmp.find("backClickConfirmModal"))) {
            cmp.find("backClickConfirmModal")[0].close();
        }else{
            cmp.find("backClickConfirmModal").close();
        }
        cmp.set("v.backClickConfirmation",false);
        //cmp.set("v.showSpinner",true);
        cmp.set("v.actionType",'Save');
        helper.callValidation(cmp);
    },
    closeModalWithoutAnyAction : function(cmp, event, helper){
        
        if(Array.isArray(cmp.find("backClickConfirmModal"))) {
            cmp.find("backClickConfirmModal")[0].close();
        }else{
            cmp.find("backClickConfirmModal").close();
        }
        cmp.set("v.backClickConfirmation",false);
    },
    proceedWithoutSave : function(cmp, event, helper){
        if(Array.isArray(cmp.find("backClickConfirmModal"))) {
            cmp.find("backClickConfirmModal")[0].close();
        }else{
            cmp.find("backClickConfirmModal").close();
        }
        cmp.set("v.backClickConfirmation",false);
        
        //call parent to go to summary view
        helper.fireBackClickEvent(cmp,event);
    },
    instructorHoursValidation : function(cmp,event,helper){
        var data = event.getSource();
        var index = data.get("v.labelClass");
        console.log(':::row:index::',index);
        
        var hrsInput = cmp.find("hrsInput");
        
        /*if(!hrsInput.get("v.value")){
            hrsInput.set("v.value",null);
        }*/
        
        var dayEntries = cmp.get("v.dayRecord").dayEntries;
        var hour = ((parseFloat(dayEntries[index].dayHours) || 0)  * 100) % 100;
        
        if(!(hour == 25 || hour == 50 || hour == 75 || hour == 0)){
            data.set("v.errors",[{message:"Allowed decimal values are 00, 25, 50, 75 "}]);
            $A.util.addClass(data,'errorClass');
        }else {
            data.set("v.errors",null);
            $A.util.removeClass(data,'errorClass');
            
            helper.addValidationForTimeInputs(cmp,index);                        
            cmp.set("v.isvalueChanged",true);
            
            if(cmp.get("v.buttonType") != 'Edit'){
                //call the student hours check & replace method on day hours change
            	helper.checkForStudenHoursMissMatch(cmp,dayEntries[index].hours,dayEntries[index],-1,-1);
                
            } else {
                var rec = cmp.get("v.editRecord");
                rec.comments = '';
                cmp.set("v.editRecord",rec);
            }         
        }
        //data.reportValidity();
    },
    startTimeChange : function(cmp, event, helper){
        var data = event.getSource();
        console.log('::::::index::::',data.get("v.name"));
        var index = data.get("v.name");
        
        var wholeRecords = cmp.get("v.dayRecord");        
        var dayRecord = wholeRecords.dayEntries[index];
        
        var stCmp = Array.isArray(cmp.find("startTime")) ? cmp.find("startTime")[index] : cmp.find("startTime");
        
        if(dayRecord.startTime1){
            dayRecord.startTime1Minutes = helper.convertTime(cmp,dayRecord.startTime1);
            //remove highlight once value entered
            $A.util.removeClass(stCmp,"slds-has-error");
        }else if(dayRecord.dayHours && !dayRecord.startTime1){
            $A.util.addClass(stCmp,"slds-has-error");
        }
        
        if(dayRecord.taskType != 'Language Training'){
            
            var stCmp = Array.isArray(cmp.find("startTime2")) ? cmp.find("startTime2")[index] : cmp.find("startTime2");
            if(dayRecord.startTime2){
                dayRecord.startTime2Minutes = helper.convertTime(cmp,dayRecord.startTime2);
                //remove highlight once value entered
                $A.util.removeClass(stCmp,"slds-has-error");
            }else if(dayRecord.dayHours && !dayRecord.startTime2){
                $A.util.addClass(stCmp,"slds-has-error");
            }
        }
        
        wholeRecords.dayEntries[index] = dayRecord;
        
        helper.addValidationForTimeInputs(cmp,index);
        
        cmp.set("v.dayRecord",wholeRecords);
    },
    endTimeChange : function(cmp, event, helper){
        var data = event.getSource();
        console.log('::::::index::::',data.get("v.name"));
        var index = data.get("v.name");
        
        var wholeRecords = cmp.get("v.dayRecord");        
        var day = wholeRecords.dayEntries[index];
        if(day.endTime1){
            day.endTime1Minutes = helper.convertTime(cmp,day.endTime1);
        }
        if(day.endTime2){
            day.endTime2Minutes = helper.convertTime(cmp,day.endTime2);
        }
        
        //compare the end time with current, if its in future throw validaiton
        helper.validateEndTime(cmp,index,day);
        
        wholeRecords.dayEntries[index] = day;
        
        helper.addValidationForTimeInputs(cmp,index);
        
        cmp.set("v.dayRecord",wholeRecords);
    },
    //end time validation close btn click
    closeBntClick : function(cmp, event, helper){
        if(Array.isArray(cmp.find("endTimeValidationModel"))) {
            cmp.find("endTimeValidationModel")[0].close();
        }else{
            cmp.find("endTimeValidationModel").close();
        }
        cmp.set("v.endTimeValidationModel",false);
    },
    getCancellationReason : function(cmp, event, helper){
        var data = event.getSource();
        var index = data.get("v.name");
        
        var timeRecords = cmp.get("v.dayRecord");
        var entries = timeRecords.dayEntries;
        var day = entries[index];
        
        cmp.set("v.currentRecordIndex",index);
        
        if(day.lateCancellation){
            
            if(day.cancellationReason){
                cmp.set("v.cancellationReason",day.cancellationReason);
            }
            
            cmp.set("v.showCancellationModal",true);
            if(Array.isArray(cmp.find("cancellationModal"))){
                cmp.find("cancellationModal")[0].open();
            }else{
                cmp.find("cancellationModal").open();
            }
        }else {
            day.cancellationReason = "";
            entries[index] = day;
        	cmp.set("v.timeRecords",timeRecords);
        }
    },
    submitCancellation : function(cmp, event, helper){
        var txtArea = cmp.find("cancelReason");
        var valid = true;
        
        if(!cmp.get("v.cancellationReason")){
            $A.util.addClass(txtArea,"slds-has-error");
            valid = false;
        }else {
            $A.util.removeClass(txtArea,"slds-has-error");
            valid = true;
        }
        if(valid){
            if(Array.isArray(cmp.find("cancellationModal"))) {
                cmp.find("cancellationModal")[0].close();
            }else{
                cmp.find("cancellationModal").close();
            }
            cmp.set("v.showCancellationModal",false);
            
            var timeRecords = cmp.get("v.dayRecord");
            var entries = timeRecords.dayEntries;
            
            var day = entries[cmp.get("v.currentRecordIndex")];
            day.cancellationReason = cmp.get("v.cancellationReason");
            
            cmp.set("v.isvalueChanged",true);
            
            //cmp.set("v.dayRecord",timeRecords);
            helper.disablePrepTimeRows(cmp,day,cmp.get("v.currentRecordIndex")); 
        }
    },
    cancelCancellation : function(cmp, event, helper){
        var timeRecords = cmp.get("v.dayRecord");
        var entries = timeRecords.dayEntries;
        
       	var day = entries[cmp.get("v.currentRecordIndex")];
       
        if(!day.dayId){
            day.lateCancellation = false;
            cmp.set("v.dayRecord",timeRecords);
        }
        if(Array.isArray(cmp.find("cancellationModal"))) {
            cmp.find("cancellationModal")[0].close();
        }else{
            cmp.find("cancellationModal").close();
        }
        cmp.set("v.showCancellationModal",false);
    },
    viewNotesLinkClick : function(cmp, event, helper){
        var index = parseInt(cmp.find("lateCancellation").getElement().className);
        
        var timeRecords = cmp.get("v.dayRecord");
        var entries = timeRecords.dayEntries;
        var day = entries[index];
        
        cmp.set("v.currentRecordIndex",index);
        
        if(day.lateCancellation){
            
            if(day.cancellationReason){
                cmp.set("v.cancellationReason",day.cancellationReason);
                
                if(day.dayId){
                    cmp.set("v.disableInput",true);
                }
            }
            
            cmp.set("v.showCancellationModal",true);
            if(Array.isArray(cmp.find("cancellationModal"))){
                cmp.find("cancellationModal")[0].open();
            }else{
                cmp.find("cancellationModal").open();
            }
        }else {
            day.cancellationReason = "";
            entries[index] = day;
        	cmp.set("v.timeRecords",timeRecords);
        }
    },
    openEditModal : function(cmp,event, helper){
        var index = event.currentTarget.getAttribute("data-value");
        console.log("::::open::edit:index:",index);
        var timeRecords = cmp.get("v.dayRecord");
        var entries = timeRecords.dayEntries;
        var day = entries[index];
        
        cmp.set("v.currentRecordIndex",index);
        
        if(day.startTime2 && day.endTime2){
            cmp.set("v.startTimeLabel",'AM - Start Time');
            cmp.set("v.endTimeLabel",'AM - End Time');      
        }
        helper.formEditModalContents(cmp,day);
        cmp.set("v.buttonType",'Edit');
        cmp.set("v.showEditModal",true);
        if(Array.isArray(cmp.find("editModal"))) {
            cmp.find("editModal")[0].open();
        }else{
            cmp.find("editModal").open();
        }
        
        var cancelReasonDiv = cmp.find("cancelReasonTxt");
        cancelReasonDiv.set("v.value",day.cancellationReason);
    },
    updateStatusToUnposted : function(cmp, event, helper){
        var editedRec = cmp.get("v.editRecord");
        var cmt = cmp.find("comment");
        var isValid = true;
        //commets check
        if(editedRec.comments){
            $A.util.removeClass(cmt,"slds-has-error");
        }else {
            isValid = false;
            $A.util.addClass(cmt,"slds-has-error");
        }
        
        if(isValid){
            editedRec.isHrsDisabled = false;
            editedRec.color = 'Yellow';
            editedRec.isUpdated = true;
            editedRec.isUnposted = true;
            editedRec.cancellationReason = reason.get("v.value");
            
            cmp.set("v.editRecord",editedRec);
            cmp.set("v.buttonType",'Delete');
            
            if(Array.isArray(cmp.find("editModal"))) {
                cmp.find("editModal")[0].close();
            }else{
                cmp.find("editModal").close();
            }
            cmp.set("v.showEditModal",false);
            helper.updateEventInTableLevel(cmp);
        }
    },
    okayClickOnEdit : function(cmp, event, helper){
        console.log('enter okay');
        var editedRec = cmp.get("v.editRecord");
        var cmt = cmp.find("comment");
        var isValid = true;
        //commets check
        if(editedRec.comments){
            $A.util.removeClass(cmt,"slds-has-error");
        }else {
            isValid = false;
            $A.util.addClass(cmt,"slds-has-error");
        }
        
        //cancellation reason check
        var reason = cmp.find("cancelReasonTxt");
        if(editedRec.lateCancellation){
            if(!reason.get("v.value")){
                $A.util.addClass(reason,"slds-has-error");
                isValid = false;
            }else {
                $A.util.removeClass(reason,"slds-has-error");
            }
        }
        
        if(isValid){
            editedRec.isHrsDisabled = false;
            editedRec.color = 'Yellow';
            editedRec.isUpdated = true;
            if(reason){
                editedRec.cancellationReason = reason.get("v.value");
            }
            
            cmp.set("v.editRecord",editedRec);
            cmp.set("v.isvalueChanged",true);
            
            if(Array.isArray(cmp.find("editModal"))) {
                cmp.find("editModal")[0].close();
            }else{
                cmp.find("editModal").close();
            }
            cmp.set("v.showEditModal",false);
            helper.updateEventInTableLevel(cmp);
        }
    },
    cancelClickOnEdit : function(cmp,event, helper){
        if(Array.isArray(cmp.find("editModal"))) {
            cmp.find("editModal")[0].close();
        }else{
            cmp.find("editModal").close();
        }
        cmp.set("v.showEditModal",false);
    },
    editStartTimeChange : function(cmp, event, helper){
        var editRecord = cmp.get("v.editRecord");
        
        if(editRecord.startTime1){
            editRecord.startTime1Minutes = helper.convertTime(cmp,editRecord.startTime1);
        }
        
        if(editRecord.startTime2){
            editRecord.startTime2Minutes = helper.convertTime(cmp,editRecord.startTime2);
        }
        cmp.set("v.editRecord",editRecord);
    },
    editEndTimeChange : function(cmp,event, helper){
        var editRecord = cmp.get("v.editRecord");
        
        if(editRecord.endTime1){
            editRecord.endTime1Minutes = helper.convertTime(cmp,editRecord.endTime1);
        }
        
        if(editRecord.endTime2){
            editRecord.endTime2Minutes = helper.convertTime(cmp,editRecord.endTime2);
        }
        cmp.set("v.editRecord",editRecord);
    },
    openRecallModal : function(cmp, event, helper){
        var index = event.currentTarget.getAttribute("data-value");
        cmp.set("v.currentRecordIndex",index);
		
        var timeRecords = cmp.get("v.dayRecord");
        var entries = timeRecords.dayEntries;
        var day = entries[index];
        
        helper.formEditModalContents(cmp,day);
        
        cmp.set("v.showRecallConfirmationModal",true);
        if(Array.isArray(cmp.find("recallModal"))) {
            cmp.find("recallModal")[0].open();
        }else{
            cmp.find("recallModal").open();
        }
    },
    recallOkayClick : function(cmp, event, helper){
        var reasonDiv = cmp.find("recallReason");
        var isValid = true;
        if(!cmp.get("v.recallReason")){
            $A.util.addClass(reasonDiv,"slds-has-error");
            isValid = false;
        }else {
            $A.util.removeClass(reasonDiv,"slds-has-error");
        }
        
        if(isValid){
            if(Array.isArray(cmp.find("recallModal"))) {
                cmp.find("recallModal")[0].close();
            }else{
                cmp.find("recallModal").close();
            }
            cmp.set("v.showRecallConfirmationModal",false);
            cmp.set("v.buttonType",'Recall');
            var day = cmp.get("v.editRecord");
            day.recallReason = cmp.get("v.recallReason");
            day.isUpdated = true;
            day.showRecallIcon = false;
            
            cmp.set("v.editRecord",day);
            cmp.set("v.showSpinner",true);
            
            helper.updateEventInTableLevel(cmp);
        }
        
    },
    recallCancelClick : function(cmp, event, helper){
        if(Array.isArray(cmp.find("recallModal"))) {
            cmp.find("recallModal")[0].close();
        }else{
            cmp.find("recallModal").close();
        }
        cmp.set("v.showRecallConfirmationModal",false);
    },
    studentHoursValidation : function(cmp, event, helper){
        var data = event.getSource();
        console.log("::::student::hrs:",data.get("v.labelClass"));
        var index = data.get("v.labelClass");
        var hour = ((parseFloat(data.get("v.value")) || 0)  * 100) % 100;
        var isValid = true;
        
        if(!(hour == 25 || hour == 50 || hour == 75 || hour == 0)){
            data.set("v.errors",[{message:"Allowed decimal values are 00, 25, 50, 75 "}]);
            $A.util.addClass(data,'errorClass');
            isValid = false;
        }else {
            data.set("v.errors",null);
            $A.util.removeClass(data,'errorClass');
            cmp.set("v.isvalueChanged",true);
            if(cmp.get("v.studentTimeEditModal")){
                var stuRec = cmp.get("v.studentRec");
                stuRec.comments = '';
                cmp.set("v.studentRec",stuRec);
            }
            helper.checkForStudenHoursMissMatch(cmp,'','',index);
            
            var attendancePickList = cmp.find('attendancePickListInput');
            if(!Array.isArray(attendancePickList)) attendancePickList = [attendancePickList];
            
            if(attendancePickList.length > index){
                var studentAttendanceList = cmp.get('v.dayRecord').studentEntries;                
                if(studentAttendanceList[parseInt(index)].hours){
                    if(!studentAttendanceList[parseInt(index)].attendance){
                    	$A.util.addClass(attendancePickList[index],"slds-has-error");
                    }else{
                        $A.util.removeClass(attendancePickList[index],"slds-has-error");
                    }
                }                                                    
            }
        }
    },
    toggleAttendanceErrorCls: function(cmp, event, helper){
        if(event.getSource().get('v.value')){
            $A.util.removeClass(event.getSource(),"slds-has-error");
        }
    },
    openStudentEditModal : function(cmp, event, helper){
        var data = event.target.getAttribute("data-name");
        console.log("::::data::student::edit:::",data);
        var index = data;
        var rec = {};
        var attendance = cmp.get("v.dayRecord").studentEntries;
        var currentRow =  attendance[index];
        
        rec = currentRow;
        rec.index = index;
        
        cmp.set("v.studentRec",rec);
        
        cmp.set("v.studentTimeEditModal",true);
        console.log(':::::::array:::::',cmp.find("studentEditModal"));
        if(Array.isArray(cmp.find("studentEditModal"))) {
            cmp.find("studentEditModal")[0].open();
        }else{
            cmp.find("studentEditModal").open();
        }
    },
    studentHrsEditValidate : function(cmp, event, helper){
        var data = cmp.find("studHrs");
        var hour = ((parseFloat(data.get("v.value")) || 0)  * 100) % 100;
        var isValid = true;
        
        var studentRec = cmp.get("v.studentRec");
        
        if(!(hour == 25 || hour == 50 || hour == 75 || hour == 0)){
            data.set("v.errors",[{message:"Allowed decimal values are 00, 25, 50, 75 "}]);
            $A.util.addClass(data,'errorClass');
            isValid = false;
        }else {
            data.set("v.errors",null);
            $A.util.removeClass(data,'errorClass');
            cmp.set("v.isvalueChanged",true);
            if(cmp.get("v.studentTimeEditModal")){
                studentRec.comments = '';
                cmp.set("v.studentRec",studentRec);
            }
        }
    },
    studentEditOkayClick : function(cmp, event, helper){
        var studentRec = cmp.get("v.studentRec");
        var isValid = true;
        var cmtDiv = cmp.find("studentComments");
        
        if(!studentRec.comments){
            $A.util.addClass(cmtDiv,"slds-has-error");
            isValid = false;
        }else {
            $A.util.removeClass(cmtDiv,"");
        }
        
        if(isValid){
            studentRec.isUpdated = true;
            studentRec.showEditIcon = false;
            studentRec.isHrsDisabled = false;
            studentRec.color = 'Yellow';
			
			var timeEntries = cmp.get("v.dayRecord");            
            var attendance = timeEntries.studentEntries;
            var data = attendance[studentRec.index];
            //var index = studentRec.index;
            
            delete studentRec.index;
            
            data = studentRec;
            cmp.set("v.dayRecord",timeEntries);
            cmp.set("v.isvalueChanged",true);
            
            if(Array.isArray(cmp.find("studentEditModal"))){
                cmp.find("studentEditModal")[0].close();
            }else {
                cmp.find("studentEditModal").close();
            }
            cmp.set("v.studentTimeEditModal",false);
        }
    },
    studentEditCancelClick : function(cmp, event, helper){
        if(Array.isArray(cmp.find("studentEditModal"))) {
            cmp.find("studentEditModal")[0].close();
        }else{
            cmp.find("studentEditModal").close();
        }
        cmp.set("v.studentTimeEditModal",false);
    },
    checkHrsEditedOrNot : function(cmp, event, helper){
        
        var index = event.target.getAttribute("data-value");
        
        var timeEntries = cmp.get("v.dayRecord");
        var day = timeEntries.dayEntries[index];
        
        if(day.isUpdated){
            cmp.set("v.currentRecordIndex",index);
        
            if(day.startTime2 && day.endTime2){
                cmp.set("v.startTimeLabel",'AM - Start Time');
                cmp.set("v.endTimeLabel",'AM - End Time');      
            }
            helper.formEditModalContents(cmp,day);
            cmp.set("v.buttonType",'Edit');
            cmp.set("v.showEditModal",true);
            if(Array.isArray(cmp.find("editModal"))) {
                cmp.find("editModal")[0].open();
            }else{
                cmp.find("editModal").open();
            }
            
            var cancelReasonDiv = cmp.find("cancelReasonTxt");
            cancelReasonDiv.set("v.value",day.cancellationReason);
        }
    },
    studentHrsEditedOrNot : function(cmp, event, helper){
        var data = event.target.getAttribute("data-value");
        console.log("::::data::student::edit:::",data);
        var index = data;
        var rec = {};
        var attendance = cmp.get("v.dayRecord").studentEntries;
        var currentRow =  attendance[index];
        
        rec = currentRow;
        rec.index = index;
        
        if(rec.isUpdated){
            cmp.set("v.studentRec",rec);
        
            cmp.set("v.studentTimeEditModal",true);
            console.log(':::::::array:::::',cmp.find("studentEditModal"));
            if(Array.isArray(cmp.find("studentEditModal"))) {
                cmp.find("studentEditModal")[0].open();
            }else{
                cmp.find("studentEditModal").open();
            }
        }
        
    },
    openStudentRecallModal : function(cmp, event, helper){   
        
        var index = event.target.getAttribute("data-name");
        
        var attendanceRows = cmp.get("v.dayRecord").studentEntries;
        var currColumnRec = attendanceRows[index];
        currColumnRec.index = index;
        cmp.set("v.studentRec",currColumnRec);
        
        cmp.set("v.showStudentTimeRecallModal",true);
        if(Array.isArray(cmp.find("studentTimeRecallModal"))){
            cmp.find("studentTimeRecallModal")[0].open();
        }else {
            cmp.find("studentTimeRecallModal").open();
        }
    },
    studentRecallOkayClick : function(cmp, event,helper){
        var reasonDiv = cmp.find("studentRecallReason");
        var reasonEntered = true;
        
        if(!cmp.get("v.studenRecallReason")){
            $A.util.addClass(reasonDiv,"slds-has-error");
            reasonEntered = false;
        }else {
            $A.util.removeClass(reasonDiv,"");
        }
        if(reasonEntered){
            if(Array.isArray(cmp.find("studentTimeRecallModal"))){
                cmp.find("studentTimeRecallModal")[0].close();
            }else {
                cmp.find("studentTimeRecallModal").close();
            }
            cmp.set("v.showStudentTimeRecallModal",false);
            
            cmp.set("v.showSpinner",true);
            var rec = cmp.get("v.studentRec");
            rec.recallReason = cmp.get("v.studenRecallReason");
            cmp.set("v.studentRec",rec);
            
            cmp.set("v.buttonType",'Student Recall');
            
            helper.callStudentTimeRecallMethod(cmp);
        }
    },
    studentRecallCancelClick : function(cmp, event, helper){
        if(Array.isArray(cmp.find("studentTimeRecallModal"))){
            cmp.find("studentTimeRecallModal")[0].close();
        }else {
            cmp.find("studentTimeRecallModal").close();
        }
        cmp.set("v.showStudentTimeRecallModal",false);
    },
    captureMissMatchReason : function(cmp, event, helper){
        var index = event.target.getAttribute("data-value");
        
        var timeRecords = cmp.get("v.dayRecord");
        var attendances = timeRecords.studentEntries;
        var currentRow =  attendances[index];
        var rec = currentRow;
        
        rec.index = index;
        cmp.set("v.studentRec",rec);
        //cmp.set("v.studentNotes",rec.comments);
        
        cmp.set("v.showStudentNotesModal",true);
        if(Array.isArray(cmp.find("studentNotesModal"))){
            cmp.find("studentNotesModal")[0].open();
        }else {
            cmp.find("studentNotesModal").open();
        }
        
        var notesDiv = cmp.find("studentNotes");
        notesDiv.set("v.value",rec.comments);
    },
    studentNotesOkayClick : function(cmp, event, helper){
        var notesDiv = cmp.find("studentNotes");
        var notesEntered = true;
        
        if(!notesDiv.get("v.value") || notesDiv.get("v.value").trim() == ''){
            $A.util.addClass(notesDiv,"slds-has-error");
            notesEntered = false;
        }else {
            $A.util.removeClass(notesDiv,"slds-has-error");
        }
        
        if(notesEntered && notesDiv.get("v.value").trim() != ''){
            if(Array.isArray(cmp.find("studentNotesModal"))){
                cmp.find("studentNotesModal")[0].close();
            }else {
                cmp.find("studentNotesModal").close();
            }
            cmp.set("v.showStudentNotesModal",false);
            
            var studentRec = cmp.get("v.studentRec");
            studentRec.comments = notesDiv.get("v.value");
            studentRec.color = null;
            
            var timeRecords = cmp.get("v.dayRecord");
            var attendance = timeRecords.studenEntries;
            var data = rowData.entries[studentRec.index];
            
            data = studentRec;
            
            cmp.set("v.dayRecord",timeRecords);
        }
    },
    studentNotesCancelClick : function(cmp, event, helper){
        if(Array.isArray(cmp.find("studentNotesModal"))){
            cmp.find("studentNotesModal")[0].close();
        }else {
            cmp.find("studentNotesModal").close();
        }
        cmp.set("v.showStudentNotesModal",false);
    },
    saveBtnClick : function(cmp, event, helper){
        cmp.set("v.actionType",'Save');
        helper.callValidation(cmp);
    },
    proceedOnSave : function(cmp, event, helper){
        cmp.set("v.showSaveConfirmation",true);
        if(Array.isArray(cmp.find("confirmationModal"))) {
            cmp.find("confirmationModal")[0].open();
        }else{
            cmp.find("confirmationModal").open();
        }
        cmp.set("v.showSpinner",true);
        helper.saveTCDChanges(cmp);
    },
    cancelOnsave : function(cmp, event, helper){
        if(Array.isArray(cmp.find("confirmationModal"))) {
            cmp.find("confirmationModal")[0].close();
        }else{
            cmp.find("confirmationModal").close();
        }
        cmp.set("v.showSaveConfirmation",false);
        cmp.set('v.hasTimeInFederalHoliday', false);
    },
    closeClickOnSuccess : function(cmp, event, helper){
        if(Array.isArray(cmp.find("successModal"))) {
            cmp.find("successModal")[0].close();
        }else{
            cmp.find("successModal").close();
        }
        cmp.set("v.displaySuccessModal",false);
        
        if(cmp.get("v.buttonType") == 'Recall'){
		
            var timeRecords = cmp.get("v.dayRecord");
            var entries = timeRecords.dayEntries;
            var day = entries[cmp.get("v.currentRecordIndex")];
            day.isUpdated = false;
            day.showReverseIcon = false;
            day.color = '';
            day.showEditIcon = true;
            
            cmp.set("v.dayRecord",timeRecords);
            
        }else if(cmp.get("v.buttonType") == 'Student Recall'){
            
            var timeRecords = cmp.get("v.dayRecord");
            var studentEntries = timeRecords.studentEntries;
            var attendance = studentEntries[cmp.get("v.currentRecordIndex")];
            attendance.isUpdated = false;
            attendance.showReverseIcon = false;
            attendance.color = '';
            attendance.showEditIcon = true;
            
            cmp.set("v.dayRecord",timeRecords);
        }else if(cmp.get("v.actionType") == 'Save'){
            helper.fireBackClickEvent(cmp,event);
        }
    },
    needHelpBtnClick : function(cmp, event, helper){
        window.location.href = '/instructor/s/topic/'+cmp.get("v.detailMap").topicId+'/timekeeping?';
    },
    proceedOnFederalHoliday: function(cmp, event, helper){
        helper.checkOtherValidations(cmp);
    }    
    
})