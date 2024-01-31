({
    doinit : function(cmp, event, helper) {
        
        var device = $A.get("$Browser.formFactor");
        console.log('::::::::device:::::',device);
        if (device == 'PHONE') {
            cmp.set("v.displayDevice",'Mobile');
        } else {
            cmp.set("v.displayDevice",'Desktop');
        }
        
        if(device != 'PHONE'){
            
            cmp.set("v.showSpinner",true);
        	cmp.set("v.initialLoad",true);
            
            //Get the url params to prepopulate that week & project
            //if launched from email click here link
            var url = window.location.href;
            var formattedUrl = '';
            var urlMap = {};
            if(url.includes('+')){
                url = url.split('+').join('%20');
            }
            formattedUrl = decodeURIComponent(url);
            
            if(formattedUrl.includes('week')){
                if(!cmp.get("v.internalView")){
                    urlMap.weekRange = formattedUrl.split('week=')[1];
                }else {
                    urlMap.weekRange = formattedUrl.split('week=')[1].split('&c__projectId')[0];
                }
            }
            if(formattedUrl.includes('projectId')){
                urlMap.projectId = formattedUrl.split('projectId=')[1].split('&week')[0];
            }
            
            console.log('::::::urlMap:::',JSON.stringify(urlMap));
            cmp.set("v.urlParams",urlMap);
            
            helper.getFilterInformation(cmp);
        }
        
    },
    getRowDetails : function(cmp, event, helper){
        
        cmp.set("v.initialLoad",false);
        let oldValue = event.getParam("oldValue");
        console.log(oldValue);
        var isChanged = helper.FindTimeEntryChanges(cmp,'From Filter Change');
        console.log(isChanged);
        if(isChanged){
            if(!cmp.get("v.filterChangeConfirmationModal")){
            	cmp.set("v.oldSelectedProject", oldValue);
            }
            cmp.set("v.filterChanged",'Project');
            cmp.set("v.filterChangeConfirmationModal",true);
            if(Array.isArray(cmp.find("filterConfirmModal"))) {
                cmp.find("filterConfirmModal")[0].open();
            }else{
                cmp.find("filterConfirmModal").open();
            }
        }else {
            if(cmp.get("v.selectedProject") != '--Select--'){
                cmp.set("v.oldSelectedProject",cmp.get("v.selectedProject"));
                
                cmp.set("v.showSpinner",true);
                var manager = cmp.get("v.projectSupervisorMap")[cmp.get("v.selectedProject")];
                cmp.set("v.projectManager",manager);
                cmp.set("v.instructorPosition",cmp.get("v.projectInsPositionMap")[cmp.get("v.selectedProject")]);
                
                var projectData = cmp.get("v.projectFilter").filter(obj => {
                    return obj.projectId === cmp.get("v.selectedProject");
                });
                
                if(projectData.length > 0){
                    cmp.set("v.projectRTName",projectData[0].projectRTName);
                    cmp.set("v.studentApprovalNotRequired",projectData[0].noStudentApproval);
                }
                
                helper.getTimeRowsFormation(cmp);
                
                //Call schedule details query method
                helper.getClassScheduleDetails(cmp);
            }else {
                cmp.set("v.headerList",[]);
                cmp.set("v.dayRecords",[]);
                cmp.set("v.notesList",[]);
                cmp.set("v.studentAttendanceList",[]);
                cmp.set("v.showSpinner",false);
            }            
        }       
    },
    getProjectFilter : function(cmp, event, helper){
        
        cmp.set("v.initialLoad",false);
        let oldValue = event.getParam("oldValue");
       console.log(oldValue);
        var isChanged = helper.FindTimeEntryChanges(cmp,'From Filter Change');
        console.log(isChanged);
        if(isChanged){
            if(!cmp.get("v.filterChangeConfirmationModal")){
            	cmp.set("v.oldSelectedWeek", oldValue);
            }
            cmp.set("v.filterChanged",'Week');
            cmp.set("v.filterChangeConfirmationModal",true);
            if(Array.isArray(cmp.find("filterConfirmModal"))) {
                cmp.find("filterConfirmModal")[0].open();
            }else{
                cmp.find("filterConfirmModal").open();
            }
        }else {
            cmp.set("v.oldSelectedWeek", oldValue);
            cmp.set("v.headerList",[]);
            cmp.set("v.dayRecords",[]);
            cmp.set("v.notesList",[]);
            cmp.set("v.projectFilter",[]);
            cmp.set("v.studentAttendanceList",[]);
            cmp.set("v.studentApprovalNotRequired", false);
            //cmp.set("v.selectedProject","");
            console.log('selected week::',cmp.get("v.selectedWeek"));
            helper.getProjectFilterDetails(cmp);
        }
        
        console.log('old  week::',cmp.get("v.oldSelectedWeek"));
        console.log('selected week::',cmp.get("v.selectedWeek"));
    },
    populateValues : function(cmp, event, helper){
        var lineIndex = event.getParam("index1");
        var dayIndex = event.getParam("index2");
        var updatedDay = event.getParam("udpatedWeekInfo");
        var typeOfAction = event.getParam("typeOfAction");
        var fieldName = event.getParam("fieldName");
        var note = event.getParam("notesInfo");
        var oldValue = event.getParam("oldValue");
        
        var wholeRows = cmp.get("v.dayRecords");
        var rowRec = wholeRows[lineIndex];
        var dayRec = rowRec.dayEntries[dayIndex];
        dayRec = updatedDay;
        
        if(typeOfAction == 'Changed'){
            cmp.set("v.isvalueChanged",true);
        }
        cmp.set("v.dayRecords",wholeRows);
        console.log(':::::::fieldName:oldValue::',fieldName,oldValue,typeOfAction);
        console.log(':::::::new:updated::',updatedDay.isNew,updatedDay.isUpdated);
        console.log(":::::after::::",cmp.get("v.dayRecords"));

        if(updatedDay.isUpdated){
            //time values update
            //normal & AM values
            helper.populateUpdatedValuesInTable(cmp,updatedDay,lineIndex,dayIndex);
            
            //validate start & end time values for unposted time entries
            if(fieldName == 'Hours' && typeOfAction && updatedDay.status == 'Unposted'){
                helper.addValidationInTimeInputs(cmp,updatedDay,lineIndex,dayIndex);
            }
            
        }else if(fieldName == 'Hours' && (updatedDay.isNew || updatedDay.isUpdated)){	
            // to make the start & end time input as required when hours values are entered
            helper.addValidationInTimeInputs(cmp,updatedDay,lineIndex,dayIndex);
        }else if(fieldName == 'Time'){
            helper.addValidationInTimeInputs(cmp,updatedDay,lineIndex,dayIndex);
        }else if(fieldName == 'Cancellation'){
            helper.disablePrepTimeRows(cmp,updatedDay,lineIndex,dayIndex);
        }
        
        //Call Total Hours calculation for row & column level
        if(fieldName == 'Hours'){
            helper.calculateTotalHours(cmp);
            
            //call the student hours check & replace method on day hours change
            helper.checkForStudenHoursMissMatch(cmp,oldValue,updatedDay,-1,-1);
        }
        
        if(fieldName == 'Recalled'){
            cmp.set("v.showSpinner",true);
            helper.recallActionFunction(cmp,'Individual');
        }
    },
    saveBtnClick : function(cmp, event, helper){
        cmp.set("v.actionType",'Save');
        helper.overAllValidation(cmp);
    },
    submitBtnClick : function(cmp, event, helper){
        cmp.set("v.actionType",'Submit');
        helper.overAllValidation(cmp);
    },
    proceedOnSave : function(cmp, event, helper){
        cmp.set("v.showSaveConfirmation",true);
        if(Array.isArray(cmp.find("confirmationModal"))) {
            cmp.find("confirmationModal")[0].open();
        }else{
            cmp.find("confirmationModal").open();
        }
        cmp.set("v.actionType",'Save');
        cmp.set("v.showSpinner",true);
        helper.dmlActionFunction(cmp);
    },
    cancelOnsave : function(cmp, event, helper){
        if(Array.isArray(cmp.find("confirmationModal"))) {
            cmp.find("confirmationModal")[0].close();
        }else{
            cmp.find("confirmationModal").close();
        }
        cmp.set("v.showSaveConfirmation",false);
        cmp.set('v.hasTimeInFederalHoliday', false);
        cmp.set("v.actionType",'');
    },
    recallBtnClick : function(cmp, event, helper){
        console.log('recall btn click');
        cmp.set("v.groupActionMsg",'Would you like to recall the time entries?');
        cmp.set("v.actionType",'Recall');
        cmp.set("v.groupActionTitle","Confirmation");
        
        cmp.set("v.showGroupActionModal",true);
        if(Array.isArray(cmp.find("groupActionModal"))) {
            cmp.find("groupActionModal")[0].open();
        }else{
            cmp.find("groupActionModal").open();
        }
        console.log(':::::action:::',cmp.get("v.actionType"));
    },
    closeClickOnSuccess: function(cmp, event, helper){
        if(Array.isArray(cmp.find("successModal"))) {
            cmp.find("successModal")[0].close();
        }else{
            cmp.find("successModal").close();
        }
        cmp.set("v.displaySuccessModal",false);
        
        if(cmp.get("v.filterChanged") == 'Project'){
            cmp.set("v.showSpinner",true);
            cmp.set("v.oldSelectedProject",cmp.get("v.selectedProject")); // Added by Mohana
            var manager = cmp.get("v.projectSupervisorMap")[cmp.get("v.selectedProject")];
            cmp.set("v.projectManager",manager);
            cmp.set("v.instructorPosition",cmp.get("v.projectInsPositionMap")[cmp.get("v.selectedProject")]);
            helper.getTimeRowsFormation(cmp);
        }else if(cmp.get("v.filterChanged") == 'Week'){
            cmp.set("v.oldSelectedWeek",cmp.get("v.selectedWeek")); // Added by Mohana
            helper.clearTableValues(cmp, event); //Added by Mohana
            cmp.set("v.studentAttendanceList",[]);
            helper.getProjectFilterDetails(cmp);
            cmp.set("v.filterChanged",'');
        }else if(cmp.get("v.successTitle") == 'Success'){
            helper.clearTableValues(cmp, event); //Added by Mohana
            cmp.set("v.studentAttendanceList",[]);
            cmp.set("v.showSpinner",true);
            
            if(!cmp.get("v.redirectToSubmitPage")){
            	helper.getTimeRowsFormation(cmp);
            }else if(cmp.get("v.actionType") == 'Complete' && cmp.get("v.redirectToSubmitPage")){
                
                if(!cmp.get("v.internalView")){
                    window.location.href = '/instructor/s/time-submit?week='+cmp.get("v.selectedWeek");
                }else {
                    helper.redirectToStaffTimeEntry(cmp);
                }
            }
        }
    },
    costRateValidationClose : function(cmp,event, helper){
        if(Array.isArray(cmp.find("CRModal"))) {
            cmp.find("CRModal")[0].close();
        }else{
            cmp.find("CRModal").close();
        }
        cmp.set("v.displayCRValidationModal",false);
    },
    callSaveFunction : function(cmp, event, helper){
        let filterChanged = cmp.get('v.filterChanged');
        if(filterChanged == 'Week'){
        	cmp.set("v.selectedWeek",cmp.get("v.oldSelectedWeek"));
        }else if(filterChanged == 'Project'){
        	cmp.set("v.selectedProject",cmp.get("v.oldSelectedProject"));
        }
        if(Array.isArray(cmp.find("filterConfirmModal"))) {
            cmp.find("filterConfirmModal")[0].close();
        }else{
            cmp.find("filterConfirmModal").close();
        }
        cmp.set("v.filterChangeConfirmationModal",false);
        cmp.set("v.actionType",'Save');
        helper.overAllValidation(cmp);
    },
    closeModalWithoutAnyAction : function(cmp, event, helper){
        
        cmp.set("v.selectedWeek",cmp.get("v.oldSelectedWeek"));
        cmp.set("v.selectedProject",cmp.get("v.oldSelectedProject"));
        
        if(Array.isArray(cmp.find("filterConfirmModal"))) {
            cmp.find("filterConfirmModal")[0].close();
        }else{
            cmp.find("filterConfirmModal").close();
        }
        cmp.set("v.filterChangeConfirmationModal",false);
    },
    proceedWithoutSave : function(cmp, event, helper){
        
        if(Array.isArray(cmp.find("filterConfirmModal"))) {
            cmp.find("filterConfirmModal")[0].close();
        }else{
            cmp.find("filterConfirmModal").close();
        }
        cmp.set("v.filterChangeConfirmationModal",false);
        
        if(cmp.get("v.filterChanged") == 'Project'){
            cmp.set("v.oldSelectedProject",cmp.get("v.selectedProject"));
            cmp.set("v.headerList",[]);
            cmp.set("v.dayRecords",[]);
            cmp.set("v.notesList",[]);
            cmp.set("v.studentAttendanceList",[]);
            
            cmp.set("v.isvalueChanged",false);
            if(cmp.get("v.selectedProject") != '--Select--') {
                cmp.set("v.showSpinner",true);
                var manager = cmp.get("v.projectSupervisorMap")[cmp.get("v.selectedProject")];
                cmp.set("v.projectManager",manager);
                cmp.set("v.instructorPosition",cmp.get("v.projectInsPositionMap")[cmp.get("v.selectedProject")]);
                helper.getTimeRowsFormation(cmp);
            
                //Call schedule details query method
                helper.getClassScheduleDetails(cmp);
            }else {
                cmp.set("v.showSpinner",false);
            }                       
        }else if(cmp.get("v.filterChanged") == 'Week'){
            cmp.set("v.oldSelectedWeek",cmp.get("v.selectedWeek"));
            cmp.set("v.headerList",[]);
            cmp.set("v.dayRecords",[]);
            cmp.set("v.notesList",[]);
            cmp.set("v.projectFilter",[]);
            cmp.set("v.selectedProject","");
            cmp.set("v.studentAttendanceList",[]);
            cmp.set("v.isvalueChanged",false);
            helper.getProjectFilterDetails(cmp);
        }else if(cmp.get("v.filterChanged") == 'recall'){
            cmp.set("v.showStudentTimeRecallModal",true);
            if(Array.isArray(cmp.find("studentTimeRecallModal"))){
                cmp.find("studentTimeRecallModal")[0].open();
            }else {
                cmp.find("studentTimeRecallModal").open();
            }
        }else{ //Added by Mohana
            cmp.set("v.headerList",[]);
            cmp.set("v.dayRecords",[]);
            cmp.set("v.notesList",[]);
            cmp.set("v.studentAttendanceList",[]);
            cmp.set("v.showSpinner",false);
        }
    },
    groupActionOkayClick : function(cmp, event, helper){
        if(Array.isArray(cmp.find("groupActionModal"))) {
            cmp.find("groupActionModal")[0].close();
        }else{
            cmp.find("groupActionModal").close();
        }
        cmp.set("v.showGroupActionModal",false);
        
        if(cmp.get("v.actionType") == 'Submit' || cmp.get("v.actionType") == 'Complete'){
            cmp.set("v.showSpinner",true);
            helper.dmlActionFunction(cmp);
        }else {
            cmp.set("v.showSpinner",true);
            helper.recallActionFunction(cmp,'Group');
        }
    },
    groupActionCancel : function(cmp, event, helper){
        if(Array.isArray(cmp.find("groupActionModal"))) {
            cmp.find("groupActionModal")[0].close();
        }else{
            cmp.find("groupActionModal").close();
        }
        cmp.set("v.showGroupActionModal",false);
        cmp.set("v.actionType",'');
    },
    studentHoursValidation: function(cmp, event, helper){
        var data = event.getSource();
        console.log("::::labelClass:::",data.get("v.labelClass"));
        var rowIndex = data.get("v.labelClass").split("-")[0];
        var columnIndex = data.get("v.labelClass").split("-")[1];
        var hour = ((parseFloat(data.get("v.value")) || 0)  * 100) % 100;
        var isValid = true;
        
        if(!(hour == 25 || hour == 50 || hour == 75 || hour == 0)){
            //data.setCustomValidity("Allowed decimal values are 00, 25, 50, 75");
            //data.isValid(false);
            data.set("v.errors",[{message:"Allowed decimal values are 00, 25, 50, 75 "}]);
            $A.util.addClass(data,'errorClass');
            isValid = false;
        }else {
            //data.setCustomValidity("");
            //data.isValid(true);
            data.set("v.errors",null);
            $A.util.removeClass(data,'errorClass');
            cmp.set("v.isvalueChanged",true);
            if(cmp.get("v.showStudentTimeEditModal")){
                var stuRec = cmp.get("v.studentRec");
                stuRec.comments = '';
                cmp.set("v.studentRec",stuRec);
            }
            helper.checkForStudenHoursMissMatch(cmp,'','',rowIndex,columnIndex);
            var attendancePickList = cmp.find('attendancePickList');
            var index = (parseInt(rowIndex) * 7) + parseInt(columnIndex);
            
            if(attendancePickList.length > index){
                var studentAttendanceList = cmp.get('v.studentAttendanceList');
                if(studentAttendanceList[parseInt(rowIndex)].entries[parseInt(columnIndex)].hours){
                    if(!studentAttendanceList[parseInt(rowIndex)].entries[parseInt(columnIndex)].attendance){
                    	$A.util.addClass(attendancePickList[index],"slds-has-error");
                    }else{
                        $A.util.removeClass(attendancePickList[index],"slds-has-error");
                    }
                }                                                    
            }
        }
        //data.reportValidity();
        
        if(isValid){
            helper.calculateStudentTotalHrs(cmp);
        }
    },
    toggleAttendanceErrorCls: function(cmp, event, helper){
        if(event.getSource().get('v.value')){
            $A.util.removeClass(event.getSource(),"slds-has-error");
        }
    },
    openStudentEditModal : function(cmp, event, helper){
        var data = event.target.getAttribute("data-name");
        
        var rowIndex = parseInt(data.split('-')[0]);
        var columnIndex = parseInt(data.split('-')[1]);
        //var rowIndex = data.get("v.name");
        //var columnIndex = data.get("v.ariaLabel");
        
        var rec = {};
        var attendanceRows = cmp.get("v.studentAttendanceList");
        var currentRow =  attendanceRows[rowIndex];
        var currColumnRec = currentRow.entries[columnIndex];
        rec = currColumnRec;
        rec.rowIndex = rowIndex;
        rec.columnIndex = columnIndex;
        
        cmp.set("v.studentRec",rec);
        
        cmp.set("v.showStudentTimeEditModal",true);
        if(Array.isArray(cmp.find("studentTimeEditModal"))) {
            cmp.find("studentTimeEditModal")[0].open();
        }else{
            cmp.find("studentTimeEditModal").open();
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
            
            var attendance = cmp.get("v.studentAttendanceList");
            var rowData = attendance[studentRec.rowIndex];
            var data = rowData.entries[studentRec.columnIndex];
            
            data = studentRec;
            cmp.set("v.studentAttendanceList",attendance);
            cmp.set("v.isvalueChanged",true);
            
            if(Array.isArray(cmp.find("studentTimeEditModal"))){
                cmp.find("studentTimeEditModal")[0].close();
            }else {
                cmp.find("studentTimeEditModal").close();
            }
            cmp.set("v.showStudentTimeEditModal",false);
        }
    },
    studentEditCancelClick : function(cmp, event, helper){
        if(Array.isArray(cmp.find("studentTimeEditModal"))) {
            cmp.find("studentTimeEditModal")[0].close();
        }else{
            cmp.find("studentTimeEditModal").close();
        }
        cmp.set("v.showStudentTimeEditModal",false);
    },
    openStudentRecallModal : function(cmp, event, helper){   
        
        var data = event.target.getAttribute("data-name");
        
        var rowIndex = parseInt(data.split('-')[0]);
        var columnIndex = parseInt(data.split('-')[1]);
        //var rowIndex = data.get("v.name");
        //var columnIndex = data.get("v.ariaLabel");
        
        var attendanceRows = cmp.get("v.studentAttendanceList");
        var currentRow =  attendanceRows[rowIndex];
        var currColumnRec = currentRow.entries[columnIndex];
        cmp.set("v.studentRec",currColumnRec);
        
        var isChanged = helper.FindTimeEntryChanges(cmp,'From Filter Change');
        
        if(isChanged){
            cmp.set("v.filterChanged",'recall');
            cmp.set("v.filterChangeConfirmationModal",true);
            if(Array.isArray(cmp.find("filterConfirmModal"))) {
                cmp.find("filterConfirmModal")[0].open();
            }else{
                cmp.find("filterConfirmModal").open();
            }
        }else {                        
            cmp.set("v.showStudentTimeRecallModal",true);
            if(Array.isArray(cmp.find("studentTimeRecallModal"))){
                cmp.find("studentTimeRecallModal")[0].open();
            }else {
                cmp.find("studentTimeRecallModal").open();
            }
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
        //console.log(':::::::::::data::::',event);
        var rowIndex = event.target.getAttribute("data-index1");
        var columnIndex = event.target.getAttribute("data-index2");
        
        var attendanceRows = cmp.get("v.studentAttendanceList");
        var currentRow =  attendanceRows[rowIndex];
        var currColumnRec = currentRow.entries[columnIndex];
        var rec = currColumnRec;
        
        rec.rowIndex = rowIndex;
        rec.columnIndex = columnIndex;
        cmp.set("v.studentRec",rec);
        cmp.set("v.studentNotes",rec.comments);
        
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
            
            var attendance = cmp.get("v.studentAttendanceList");
            var rowData = attendance[studentRec.rowIndex];
            var data = rowData.entries[studentRec.columnIndex];
            
            data = studentRec;
            cmp.set("v.studentAttendanceList",attendance);
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
    requestEditLinkClick : function(cmp,event, helper){
        cmp.set("v.showCaseReasonModal",true);
        if(Array.isArray(cmp.find("caseReasonModal"))){
            cmp.find("caseReasonModal")[0].open();
        }else {
            cmp.find("caseReasonModal").open();
        }
    },
    submitCase : function(cmp, event, helper){
        console.log('submit case');
        var caseReasons = cmp.find('caseReason');
        var isValid = true;
        
        if(!caseReasons.get("v.value")){
            $A.util.addClass(caseReasons,"slds-has-error");
            isValid = false;
        }else {
            $A.util.removeClass(caseReasons,"");
        }
        
        if(isValid){
            helper.createCaseRecordMethod(cmp);
            if(Array.isArray(cmp.find("caseReasonModal"))){
                cmp.find("caseReasonModal")[0].close();
            }else {
                cmp.find("caseReasonModal").close();
            }
            cmp.set("v.showCaseReasonModal",false);
            cmp.set("v.showSpinner",true);
        }
    },
    cancelSubmitCase : function(cmp, event, helper){
        
        if(Array.isArray(cmp.find("caseReasonModal"))){
            cmp.find("caseReasonModal")[0].close();
        }else {
            cmp.find("caseReasonModal").close();
        }
        cmp.set("v.showCaseReasonModal",false);
    },
    completeBtnClick : function(cmp, event, helper){
        //cmp.set("v.showSpinner",true);
        cmp.set("v.actionType",'Complete');
        helper.overAllValidation(cmp);
    },
    needHelpBtnClick : function(cmp, event, helper){
        window.location.href = '/instructor/s/contactsupport';
    },
    navigateInternalTimeEntry : function(cmp, event, helper){
        window.location.href = '/instructor/s/internal-time-entry';
    },
    proceedOnFederalHoliday: function(cmp, event, helper){
        helper.checkOtherValidations(cmp);
    }
    
})