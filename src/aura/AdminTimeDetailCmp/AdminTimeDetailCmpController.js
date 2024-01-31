({
    doinit : function(cmp, event, helper){
        var type = cmp.get("v.type");
        var day = cmp.get("v.dayRecord");
        if(day) {
            if(type == 'Normal'){
                cmp.set("v.startTime",day.startTime1);
                helper.endTimeCalculation(cmp,day.startTime1);
                cmp.set("v.endTime",day.endTime1);
            }else if(type == 'AM'){
                cmp.set("v.startTime",day.startTime1);
                helper.endTimeCalculation(cmp,day.startTime1);
                cmp.set("v.endTime",day.endTime1);
            }else if(type == 'PM'){
                cmp.set("v.startTime",day.startTime2);
                helper.endTimeCalculation(cmp,day.startTime2);
                cmp.set("v.endTime",day.endTime2);
            }
        }else {
            cmp.set("v.endTimeList",[]);
            cmp.set("v.amEndTimeList",[]);
            cmp.set("v.pmEndTimeList",[]);
        }
        
    },
    populateEndTimeList : function(cmp, event, helper) {
        console.log('start time change');
        helper.endTimeCalculation(cmp,cmp.get("v.startTime"));
        var stCmp = cmp.find("startTime");
        if(cmp.get("v.startTime")){
            $A.util.removeClass(stCmp,"slds-has-error");
        }
        helper.fireInputChangeToParent(cmp, event);
    },
    endTimeChangeHandle : function(cmp, event, helper){
        cmp.set("v.changedField",'Time');
        var endCmp = cmp.find("endTime");
        console.log('enter end time');
        if(cmp.get("v.endTime")){
            //compare the end time with current, if its in future throw validaiton
            var dt = new Date();
            var h =  dt.getHours(), m = dt.getMinutes();
            var currentTime = (h > 12) ? ('0'+ (h-12) + ':' + m +' PM') : ('0'+h+ ':' + m +' AM');
            
            var endTime = cmp.get("v.endTime");
            var columnDt = new Date(cmp.get("v.dayRecord").dateVal);
            columnDt.setTime(columnDt.getTime() + columnDt.getTimezoneOffset() * 1000 * 60);
            
            var currentDt = new Date();
            
            //Commented by NS on July 12 2022 - W-007497 becuase admin can enter time in Futre time & dates
            /*if(helper.dateComparison(currentDt,columnDt) && helper.getMinutes(currentTime) < helper.getMinutes(endTime)){
                cmp.set("v.endTimeValidationModel",true);
                if(Array.isArray(cmp.find("endTimeValidationModel"))) {
                    cmp.find("endTimeValidationModel")[0].open();
                }else{
                    cmp.find("endTimeValidationModel").open();
                }
                cmp.set("v.endTimeValidationMsg",'You have selected an End Time that is in the future. Users are not allowed to enter time for a future date or time. <br/>Please correct your entry or wait until the end of the day to enter your time.');
            }else {*/
                $A.util.removeClass(endCmp,"slds-has-error"); 
            //}     
        }
        helper.fireInputChangeToParent(cmp, event);
    },
    hoursValidation: function(cmp, event, helper){
        var data = event.getSource();
        var hour = ((parseFloat(event.getSource().get("v.value")) || 0)  * 100) % 100;
        
        var hrsCmp = cmp.find("hrsInput");
        
        if(!(hour == 25 || hour == 50 || hour == 75 || hour == 0)){
            data.setCustomValidity("Allowed decimal values are 00, 25, 50, 75 ");
        }else {
            data.setCustomValidity("");
            if(cmp.get("v.buttonType") != 'Edit'){
                cmp.set("v.changedField",'Hours');
                helper.fireInputChangeToParent(cmp, event);
            } else {
                var rec = cmp.get("v.editRecord");
                rec.comments = '';
                if(rec.studentApprovalStatus != 'Submitted'){
                    rec.studentApprovalStatus = 'Submitted';
                }
                
                cmp.set("v.editRecord",rec);
            }           
        }
        data.reportValidity();
    },
    getCancellationReason : function(cmp, event, helper){
        if(cmp.get("v.dayRecord").lateCancellation){
            cmp.set("v.showCancellationModal",true);
            if(Array.isArray(cmp.find("cancellationModal"))){
                cmp.find("cancellationModal")[0].open();
            }else{
                cmp.find("cancellationModal").open();
            }
        }else {
            var day = cmp.get("v.dayRecord");
            day.cancellationReason = "";
            if(!cmp.get("v.showEditModal")) {
                day.isUpdated = true;
                cmp.set("v.dayRecord",day);
                cmp.set("v.changedField",'Cancellation');
                helper.fireInputChangeToParent(cmp, event);
            }
        }
    },
    submitCancellation : function(cmp, event, helper){
        var txtArea = cmp.find("cancelReason");
        var valid = true;
        if(!cmp.get("v.dayRecord").cancellationReason){
            $A.util.addClass(txtArea,"slds-has-error");
            valid = false;
        }else {
            $A.util.removeClass(txtArea,"slds-has-error");
            valid = true;
        }
        if(valid){
            var day = cmp.get("v.dayRecord");
            if(day.dayId){
                day.isUpdated = true;
                cmp.set("v.dayRecord",day);
            }
            if(Array.isArray(cmp.find("cancellationModal"))) {
                cmp.find("cancellationModal")[0].close();
            }else{
                cmp.find("cancellationModal").close();
            }
            cmp.set("v.showCancellationModal",false);
            cmp.set("v.changedField",'Cancellation');
            helper.fireInputChangeToParent(cmp, event);
        }
    },
    cancelCancellation : function(cmp, event, helper){
        var day = cmp.get("v.dayRecord");
        if(!day.dayId){
            day.lateCancellation = !day.lateCancellation;            
        	cmp.set("v.dayRecord",day);
        }
        if(Array.isArray(cmp.find("cancellationModal"))){
            cmp.find("cancellationModal")[0].close();
        }else{
            cmp.find("cancellationModal").close();
        }
        cmp.set("v.showCancellationModal",false);
    },
    
    checkHrsEditedOrNot : function(cmp, event, helper){
        helper.timeListFormation(cmp);
        var day = cmp.get("v.dayRecord");
        if(day.dayId){
            if(cmp.get("v.timeType") == 'Both' || (day.startTime2 && day.endTime2)){
                cmp.set("v.startTimeLabel",'AM - Start Time');
                cmp.set("v.endTimeLabel",'AM - End Time');      
                
                cmp.set("v.startTimeList",cmp.get("v.amStartTimeList"));
                helper.endTimeCalculation(cmp,day.startTime1);
                helper.pmEndTimeCalculation(cmp,day.startTime2);
            }
            helper.formEditModalContents(cmp);
            cmp.set("v.buttonType",'Edit');
            cmp.set("v.showEditModal",true);
            if(Array.isArray(cmp.find("editModal"))) {
                cmp.find("editModal")[0].open();
            }else{
                cmp.find("editModal").open();
            }
        }
    },
    calculateEndTimeValues : function(cmp, event, helper){
        var day = cmp.get("v.dayRecord");
        if(day.taskType == 'Preparation time'){
            cmp.set("v.startTimeList",cmp.get("v.amStartTimeList"));
            helper.endTimeCalculation(cmp,cmp.get("v.editRecord").startTime);
        }else {
            helper.endTimeCalculation(cmp,cmp.get("v.editRecord").startTime);
        }        
    },
    calculateEndTime1Values : function(cmp, event, helper){
       helper.pmEndTimeCalculation(cmp,cmp.get("v.editRecord").startTime2);
    },
    closeBntClick : function(cmp, event, helper){
        
        if(Array.isArray(cmp.find("endTimeValidationModel"))) {
            cmp.find("endTimeValidationModel")[0].close();
        }else{
            cmp.find("endTimeValidationModel").close();
        }
        cmp.set("v.endTimeValidationModel",false);
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
            
            cmp.set("v.editRecord",editedRec);
            cmp.set("v.buttonType",'Delete');
            
            if(Array.isArray(cmp.find("editModal"))) {
                cmp.find("editModal")[0].close();
            }else{
                cmp.find("editModal").close();
            }
            cmp.set("v.showEditModal",false);
            helper.dayValueUpdateANDNotesFormation(cmp,event,'From Delete');
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
        if(editedRec.lateCancellation){
            var reason = cmp.find("cancelReasonTxt");
            if(!editedRec.cancellationReason){
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
            
            cmp.set("v.editRecord",editedRec);
            
            if(Array.isArray(cmp.find("editModal"))) {
                cmp.find("editModal")[0].close();
            }else{
                cmp.find("editModal").close();
            }
            cmp.set("v.showEditModal",false);
            helper.dayValueUpdateANDNotesFormation(cmp,event);
        }
    },
    cancelClickOnEdit : function(cmp, event, helper){
        cmp.set("v.editRecord",{});
        if(Array.isArray(cmp.find("editModal"))) {
            cmp.find("editModal")[0].close();
        }else{
            cmp.find("editModal").close();
        }
        cmp.set("v.showEditModal",false);
    },

    //W-007882 - Prep Time Entry Warning Message Request in DLS Online
    inputValidation : function (cmp, event, helper) {
        var dayRecord = cmp.get("v.dayRecord");
        var params = event.getParam('arguments');
        var stCmp = cmp.find("hrsInput");
        if (params) {
            if(!dayRecord.dayHours && dayRecord.taskType == 'Preparation time' && dayRecord.dateVal == params.prepDayRecord){
                stCmp.setCustomValidity("Plese Enter a value")
            }else{
                stCmp.setCustomValidity("");
            }
        }
        stCmp.reportValidity();
    }    
})