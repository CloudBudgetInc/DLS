({
	doinit : function(cmp, event, helper) {
        helper.getInitialValues(cmp,event);
        cmp.set("v.initialLoad",true);
	},
    contactLookupSearch : function(cmp, event, helper) {
        // Get the search server side action
        const serverSearchAction = cmp.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        cmp.find('contactLookup').search(serverSearchAction);
    },
    weekRangeChange : function(cmp,event, helper){
        cmp.set("v.initialLoad",false);
        cmp.set("v.weekChanged",true);
        cmp.set("v.projectRecords",[]);
        
        //Add logic to check any change in table later
        if(cmp.get("v.isvalueChanged")){
            
            cmp.set("v.filterChanged",'Week');
            cmp.set("v.filterChangeConfirmationModal",true);
            if(Array.isArray(cmp.find("filterConfirmModal"))) {
                cmp.find("filterConfirmModal")[0].open();
            }else{
                cmp.find("filterConfirmModal").open();
            }
        }else {
            cmp.set("v.oldSelectedWeek",cmp.get("v.selectedWeek"));
            helper.clearTableValues(cmp);
            
            if(cmp.get("v.selectedContact").length > 0){
                cmp.set("v.showSpinner",true);
                helper.getProjectFilterInfo(cmp,event);
            }
        }
    },
    contactChange : function(cmp, event, helper){
        cmp.set("v.contactChanged",true);
        cmp.set("v.isContactChanged",true);
        //Add logic to check any change in table later
        if(cmp.get("v.isvalueChanged")){
            
            cmp.set("v.filterChanged",'Contact');
            cmp.set("v.filterChangeConfirmationModal",true);
            if(Array.isArray(cmp.find("filterConfirmModal"))) {
                cmp.find("filterConfirmModal")[0].open();
            }else{
                cmp.find("filterConfirmModal").open();
            }
            
        }else {
            
            helper.clearTableValues(cmp);
            cmp.set("v.isvalueChanged",false);
            cmp.set("v.comments","");
            
            //call contact have corresponding user record
            if(cmp.get("v.selectedContact").length > 0){
                cmp.set("v.oldSelectedContact",cmp.get("v.selectedContact"));
                cmp.set("v.showSpinner",true);
                var userExist = helper.validateContact(cmp,event);
            }
        }
    },
    projectChange : function(cmp, event, helper){
        cmp.set("v.initialLoad",false);
        
        //Add logic to check any change in table later
        if(cmp.get("v.isvalueChanged")){
            
            cmp.set("v.filterChanged",'Project');
            cmp.set("v.filterChangeConfirmationModal",true);
            if(Array.isArray(cmp.find("filterConfirmModal"))) {
                cmp.find("filterConfirmModal")[0].open();
            }else{
                cmp.find("filterConfirmModal").open();
            }
            
        }else {
            if(cmp.get("v.selectedContact").length > 0 && cmp.get("v.selectedProject") != '--None--'){
                cmp.set("v.oldSelectedProject",cmp.get("v.selectedProject"));
                
                helper.clearTableValues(cmp);
                cmp.set("v.showSpinner",true);
                helper.getTCDInformation(cmp,event);
            }
        }
    },
    userTypeChange : function(cmp, event, helper){
        if(cmp.get("v.isvalueChanged")){
            
            cmp.set("v.filterChanged",'User Type');
            cmp.set("v.filterChangeConfirmationModal",true);
            if(Array.isArray(cmp.find("filterConfirmModal"))) {
                cmp.find("filterConfirmModal")[0].open();
            }else{
                cmp.find("filterConfirmModal").open();
            }
            
        }else {
            window.location.href = '/lightning/n/Admin_Time_Entry';
        }
    },
    clearSelectedContact :  function(cmp, event,helper){
        cmp.set("v.selectedContact",[]);
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
    },
    studentHoursValidation: function(cmp, event, helper){
        var data = event.getSource();
        
        var rowIndex = data.get("v.name");
        var columnIndex = data.get("v.ariaLabel");
        var hour = ((parseFloat(data.get("v.value")) || 0)  * 100) % 100;
        var isValid = true;
        
        if(!(hour == 25 || hour == 50 || hour == 75 || hour == 0)){
            data.setCustomValidity("Allowed decimal values are 00, 25, 50, 75");
            isValid = false;
        }else {
            data.setCustomValidity("");
            cmp.set("v.isvalueChanged",true);
            helper.checkForStudenHoursMissMatch(cmp,'','',rowIndex,columnIndex);
        }
        data.reportValidity();
        
        if(isValid){
            helper.calculateStudentTotalHrs(cmp);
        }
    },
    studentHrsEditValidation : function(cmp, event, helper){
        var stuHrs = cmp.find("stuHrs");
        var hour = ((parseFloat(stuHrs.get("v.value")) || 0)  * 100) % 100;
        if(!(hour == 25 || hour == 50 || hour == 75 || hour == 0)){
            stuHrs.setCustomValidity("Allowed decimal values are 00, 25, 50, 75");
        }else {
            stuHrs.setCustomValidity("");
        }
    },
    openStudentEditModal : function(cmp, event, helper){
        
        var data = event.getSource();
        
        var rowIndex = parseInt(event.getSource().get("v.name"));
        var columnIndex = parseInt(event.getSource().get("v.ariaLabel")); 
        var rec = {};
        var attendanceRows = cmp.get("v.studentAttendanceList");
        var currentRow =  attendanceRows[rowIndex];
        var currColumnRec = currentRow.entries[columnIndex];
        rec = currColumnRec;
        
        if(rec.attendanceId){
            rec.rowIndex = rowIndex;
            rec.columnIndex = columnIndex;
            
            cmp.set("v.studentRec",rec);
            
            cmp.set("v.showStudentTimeEditModal",true);
            if(Array.isArray(cmp.find("studentTimeEditModal"))) {
                cmp.find("studentTimeEditModal")[0].open();
            }else{
                cmp.find("studentTimeEditModal").open();
            }
            var cmtDiv = cmp.find("studentComments");
            cmtDiv.set("v.value",rec.comments);
        }
        
    },
    studentEditOkayClick : function(cmp, event, helper){
        var studentRec = cmp.get("v.studentRec");
        var isValid = true;
        var cmtDiv = cmp.find("studentComments");
        console.log('::::cmtDiv:::',cmtDiv);
        
        if(!cmtDiv.get("v.value") || cmtDiv.get("v.value").trim() == ''){
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
            studentRec.comments = cmtDiv.get("v.value");
            
            var attendance = cmp.get("v.studentAttendanceList");
            var rowData = attendance[studentRec.rowIndex];
            var data = rowData.entries[studentRec.columnIndex];
            
            data = studentRec;
            cmp.set("v.studentAttendanceList",attendance);
            cmp.set("v.isvalueChanged",true);
            
            helper.checkForStudenHoursMissMatch(cmp,'','',studentRec.rowIndex,studentRec.columnIndex);
            
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
    captureMissMatchReason : function(cmp, event, helper){
        console.log(':::::::::::data::::',event);
        var rowIndex = parseInt(event.target.getAttribute("data-index1"));
        var columnIndex = parseInt(event.target.getAttribute("data-index2"));
        
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
    addNewRow :  function(cmp, event, helper){
        console.log('::::add:::row::::');
        var newObj = {};
        
        var projectData = cmp.get("v.projectRecords").filter(obj => {
            return obj.projectId === cmp.get("v.selectedProject");
        });
        console.log(':::::::data::::',projectData);
        
        newObj.project = cmp.get("v.selectedProject");
        newObj.task = '';
        newObj.payrollItem = '';
        newObj.selectedLocation = [];
        newObj.studentNames = projectData.length > 0 ? projectData[0].projectName.split(' / ')[1] : '';
        newObj.projectName = projectData.length > 0 ? projectData[0].projectName.split(' / ')[0] : '';
        
        if(projectData.length > 0 && projectData[0].locationId){
            var locObj = {};
            locObj.Id = projectData[0].locationId;
            locObj.Name = projectData[0].locationName;
            newObj.selectedLocation.push(locObj);
        }
        newObj.isBillable = false;
        
        cmp.set("v.newDayObj",newObj);
        
        cmp.set("v.showAddModel",true);
        if(Array.isArray(cmp.find("addModel"))){
            cmp.find("addModel")[0].open();
        }else {
            cmp.find("addModel").open();
        }
    },
    locationLookupSearch : function(cmp, event, helper) {
        // Get the search server side action
        const serverSearchAction = cmp.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        cmp.find('locationLookup').search(serverSearchAction);
    },
    taskValidationFunction : function(cmp, event, helper){
        var taskIdCAIdMap = cmp.get("v.taskIdCAIdMap");
        var taskIdCostRateMap = cmp.get("v.taskIdCostRateMap");
        
        var newObj = cmp.get("v.newDayObj");
        var payrollItems = [];
        var payrollBillableMap = {};
        
        var taskRecords = cmp.get("v.taskRecords");
        var selectedTask;
        for(var i = 0;i < taskRecords.length;i++){
            if(taskRecords[i].Id == newObj.task){
                selectedTask = taskRecords[i];
            }
        }
        console.log('taskRecords::::::',taskRecords);
        newObj.payrollItem = '';
        newObj.isBillable = false;
        if(newObj.task){
            if(taskIdCAIdMap[newObj.task] && taskIdCostRateMap[newObj.task] 
               && selectedTask.RecordType.DeveloperName != 'Cost' && selectedTask.Project_Task_Type__c != 'Fringe'){
                
                if(taskIdCostRateMap[newObj.task].Payroll_Item__c != null){
                    payrollItems.push(taskIdCostRateMap[newObj.task].Payroll_Item__c);    
                    
                    if(!payrollBillableMap[taskIdCostRateMap[newObj.task].Payroll_Item__c]){
                        payrollBillableMap[taskIdCostRateMap[newObj.task].Payroll_Item__c] = true;
                    }
                }
                
                if(taskIdCostRateMap[newObj.task].Non_Billable_Payroll_Item__c != null){
                    payrollItems.push(taskIdCostRateMap[newObj.task].Non_Billable_Payroll_Item__c);    
                    
                    if(!payrollBillableMap[taskIdCostRateMap[newObj.task].Non_Billable_Payroll_Item__c]){
                        payrollBillableMap[taskIdCostRateMap[newObj.task].Non_Billable_Payroll_Item__c] = false;
                    }
                }
                
                if(payrollItems.length > 0){
                    newObj.payrollItem = payrollItems[0];
                    newObj.isBillable = payrollBillableMap[payrollItems[0]];
                }else{
                    newObj.payrollItem = '';
                    newObj.isBillable = false;
                }
                
            }else if((selectedTask.RecordType.DeveloperName == 'Cost'|| selectedTask.RecordType.DeveloperName == 'Fringe') 
            && selectedTask.Project_Task_Type__c == 'Fringe'){ // W-007880
                payrollItems.push(selectedTask.Payroll_Item__c);
                newObj.payrollItem = selectedTask.Payroll_Item__c;
            }
        }
        cmp.set("v.newDayObj",newObj);
        cmp.set("v.payrollItemList",payrollItems);
        cmp.set("v.payrollBillableMap",payrollBillableMap);
    },
    populateBillable : function(cmp,event,helper){
        var newObj = cmp.get("v.newDayObj");
        
        var payrollBillableMap = cmp.get("v.payrollBillableMap");
        
        if(newObj.payrollItem){
            newObj.isBillable = payrollBillableMap[newObj.payrollItem];
        }
        
        cmp.set("v.newDayObj",newObj);
    },
    cancelOnAddBtn : function(cmp,event,helper){
        cmp.set("v.newDayObj",{});
        if(Array.isArray(cmp.find("addModel"))){
            cmp.find("addModel")[0].close();
        }else {
            cmp.find("addModel").close();
        }
        cmp.set("v.showAddModel",false);
    },
    okayOnAddBtn : function(cmp,event,helper){
        var uniqueKeySet = cmp.get("v.uniqueKeySet");
        var newObj = cmp.get("v.newDayObj");
        
        var taskIdCAIdMap = cmp.get("v.taskIdCAIdMap");
        var taskIdCostRateMap = cmp.get("v.taskIdCostRateMap");
        
        var isValid;
        
        if(newObj.task && newObj.payrollItem && newObj.selectedLocation.length > 0){
            var key = newObj.project+'~'+newObj.task+'~'+newObj.payrollItem+'~'+newObj.isBillable+'~'+newObj.selectedLocation[0].Id;
        	
            if(uniqueKeySet.indexOf(key) == -1){
                if(taskIdCostRateMap[newObj.task] && taskIdCostRateMap[newObj.task].Id){
                    //call helper method to form the new row for insert
                    uniqueKeySet.push(key);
                    cmp.set("v.uniqueKeySet", uniqueKeySet);
                    cmp.set("v.duplicateMsg",'');
                    isValid = true;
                }else {
                    cmp.set("v.duplicateMsg",'Please contact your HR to create corresponding Cost Rate record to proceed further.');
                }
            }else{
                cmp.set("v.duplicateMsg",'This combination of Project, Project Task, Contact, Location already exist.');
            }
        }else{
            var inputCmp = cmp.find("inputValue");
            for(var i = 0;i < inputCmp.length;i++){
                if(!inputCmp[i].get("v.value")){
                    isValid = false;
                    $A.util.addClass(inputCmp[i],"slds-has-error");
                }else{
                    isValid = true;
                    $A.util.removeClass(inputCmp[i],"slds-has-error");
                }
            }
            
            //location
            var locationCmp = cmp.find("locationLookup");
            if(newObj.selectedLocation.length == 0){
                isValid = false;
                $A.util.addClass(locationCmp,"slds-has-error");
            }
        }
        
        if(isValid){
                
            helper.formNewRowContents(cmp,event);
            
            if(Array.isArray(cmp.find("addModel"))){
                cmp.find("addModel")[0].close();
            }else {
                cmp.find("addModel").close();
            }
            cmp.set("v.showAddModel",false);
            cmp.set("v.showSpinner",true);
        }
    },
    deleteRow : function(cmp, event, helper){
        var data = event.getSource();
        console.log(':::::::index::::',data.get("v.name"));
        var lineIndex = data.get("v.name");
        var dayRecords = cmp.get("v.dayRecords");
        console.log(dayRecords);
        dayRecords.splice(lineIndex,1);
        
        cmp.set("v.dayRecords",dayRecords);
    },
    revertBtnClick :  function(cmp, event, helper){
        cmp.set("v.actionType",'Revert');
        helper.overAllValidationMethod(cmp, event);
    },
    saveBtnClick :  function(cmp, event, helper){
        cmp.set("v.actionType",'Save');
        helper.overAllValidationMethod(cmp, event);
    },
    revertOkayClick :  function(cmp, event, helper){
        var cmtDiv = cmp.find("cmt");
        if(!cmp.get("v.comments")){
            $A.util.addClass(cmtDiv,"slds-has-error");
        }else {
            $A.util.removeClass(cmtDiv,"slds-has-error");
            
            if(Array.isArray(cmp.find("revertModal"))){
                cmp.find("revertModal")[0].close();
            }else{
                cmp.find("revertModal").close();
            }
            cmp.set("v.showRevertModal",false);
            
            cmp.set("v.showSpinner",true);
            
            helper.revertActionMethod(cmp, event);
        }
    },
    revertCancelClick:  function(cmp, event, helper){
        if(Array.isArray(cmp.find("revertModal"))){
            cmp.find("revertModal")[0].close();
        }else{
            cmp.find("revertModal").close();
        }
        cmp.set("v.showRevertModal",false);
    },
    saveOkayClick:  function(cmp, event, helper){
        var cmtDiv = cmp.find("saveCmt");
        if(!cmp.get("v.comments")){
            $A.util.addClass(cmtDiv,"slds-has-error");
        }else {
            $A.util.removeClass(cmtDiv,"slds-has-error");
            
            if(Array.isArray(cmp.find("saveModal"))) {
                cmp.find("saveModal")[0].close();
            }else{
                cmp.find("saveModal").close();
            }
            cmp.set("v.showSaveModal",false);
            cmp.set("v.showSpinner",true);
            
            helper.saveActionMethod(cmp, event);
        }
    },
    saveCancelClick:  function(cmp, event, helper){
        cmp.set("v.comments",'');
        if(Array.isArray(cmp.find("saveModal"))) {
            cmp.find("saveModal")[0].close();
        }else{
            cmp.find("saveModal").close();
        }
        cmp.set("v.showSaveModal",false);
    },
    closeClickOnWarning : function(cmp, event, helper){
        if(Array.isArray(cmp.find("warningModal"))) {
            cmp.find("warningModal")[0].close();
        }else{
            cmp.find("warningModal").close();
        }
        cmp.set("v.showWarningInfo",false);
    },
    callSaveFunction : function(cmp, event, helper){
        if(Array.isArray(cmp.find("filterConfirmModal"))) {
            cmp.find("filterConfirmModal")[0].close();
        }else{
            cmp.find("filterConfirmModal").close();
        }
        cmp.set("v.filterChangeConfirmationModal",false);
        cmp.set("v.actionType",'Save');
        cmp.set("v.showSpinner",true);
        helper.saveActionMethod(cmp,event);
    },
    closeModalWithoutAnyAction : function(cmp, event, helper){
        
        cmp.set("v.selectedWeek",cmp.get("v.oldSelectedWeek"));
        cmp.set("v.selectedProject",cmp.get("v.oldSelectedProject"));
        cmp.set("v.selectedContact",cmp.get("v.oldSelectedContact"));
        
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
        
        helper.clearTableValues(cmp);
        cmp.set("v.projectFilter",[]);
        cmp.set("v.selectedProject","");
        cmp.set("v.isvalueChanged",false);
        
        var filterChanged = cmp.get("v.filterChanged");
        
        if(filterChanged == 'Project'){            
            cmp.set("v.oldSelectedProject",cmp.get("v.selectedProject"));
            helper.getTCDInformation(cmp,event);
            
        }else if(filterChanged == 'Week'){
            cmp.set("v.oldSelectedWeek",cmp.get("v.selectedWeek"));
            helper.getProjectFilterInfo(cmp,event);
        }else if(filterChanged == 'Contact'){
            cmp.set("v.oldSelectedContact",cmp.get("v.selectedContact"));
            cmp.set("v.isvalueChanged",false);
        }else if(filterChanged == 'User Type'){
            window.location.href = '/lightning/n/Admin_Time_Entry';
        }
    },
    closeClickOnSuccess: function(cmp, event, helper){
        
        
        
        if(Array.isArray(cmp.find("successModal"))) {
            cmp.find("successModal")[0].close();
        }else{
            cmp.find("successModal").close();
        }
        cmp.set("v.displaySuccessModal",false);
        
        var filterChanged = cmp.get("v.filterChanged");
        
        console.log('filterChanged:::',filterChanged); //Added by Mohana
        
        helper.clearTableValues(cmp);
        cmp.set("v.isvalueChanged",false);
        cmp.set("v.comments","");
        
        if(filterChanged == 'Project'){
            
            cmp.set("v.showSpinner",true);
            cmp.set("v.oldSelectedProject",cmp.get("v.selectedProject"));
            helper.getTCDInformation(cmp,event);
            
        }else if(filterChanged == 'Week'){
            
            cmp.set("v.projectFilter",[]);
        	cmp.set("v.selectedProject","");
            
            cmp.set("v.oldSelectedWeek",cmp.get("v.selectedWeek"));
            helper.getProjectFilterInfo(cmp,event);
            
        }else if(filterChanged == 'Contact'){
            
            cmp.set("v.oldSelectedContact",cmp.get("v.selectedContact"));
            cmp.set("v.isvalueChanged",false);
            
        }else if(filterChanged == 'User Type'){
            window.location.href = '/lightning/n/Admin_Time_Entry';
        }else if(cmp.get("v.successTitle") == 'Success'){
            
           cmp.set("v.showSpinner",true);
           helper.getTCDInformation(cmp,event);
        }
    },
    downloadBtnClick : function(cmp, event, helper){        
        var contactId = cmp.get("v.selectedContact").length > 0 ? cmp.get("v.selectedContact")[0].Id : null;
        var projectId = cmp.get("v.selectedProject");
        var dt1 = cmp.get("v.selectedWeek").split(' to ')[0];
        var dt2 = cmp.get("v.selectedWeek").split(' to ')[1];
        if(contactId && projectId != '--None--'){
            if(!cmp.get("v.isShowDownloadPDFOptionModal")){
                cmp.set("v.isShowDownloadPDFOptionModal", true);
                cmp.find("pdfoptionsmodal").open();
            }else{
                cmp.find("pdfoptionsmodal").close();
                cmp.set("v.isShowDownloadPDFOptionModal", false);                               
                window.open('/apex/AdminTimesheetExport?contactId='+contactId+'&dt1='+dt1+'&dt2='+dt2+'&projectId='+projectId+'&isBillable='+cmp.get("v.isBillableFilter"));
            }
        }
    },
    cancelDownloadBtnClick: function(cmp, event, helper){
        cmp.find("pdfoptionsmodal").close();
        cmp.set("v.isShowDownloadPDFOptionModal", false);
    },
    proceedOnOtherValidation: function(cmp, event, helper){
        if(Array.isArray(cmp.find("warningModal"))) {
            cmp.find("warningModal")[0].close();
        }else{
            cmp.find("warningModal").close();
        }
        cmp.set("v.showWarningInfo",false);        
        cmp.set("v.actionType",'Save');
        cmp.set("v.showSpinner",true);
        helper.saveActionMethod(cmp,event);
    }
})