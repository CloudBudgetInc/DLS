({
    doinit : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        var filterObj = {};
        filterObj.selectedWeek = null;
        filterObj.selectedLTS = [];
        cmp.set("v.filterObj",filterObj);
        helper.getWeekRangeFilterValues(cmp);
    },
    searchClick : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        cmp.set("v.showDetails",false);
        helper.getProjectSummaryDetails(cmp);
    },
    displayDetails : function(cmp, event, helper){
        var updatedEventIds = cmp.get("v.updatedEventIds");
        cmp.set("v.selectedIndex",event.currentTarget.getAttribute("data-value"));
        if(updatedEventIds.length > 0){
            cmp.set("v.displaySaveAlert",true);
            if(Array.isArray(cmp.find("saveAlertModal"))) {
                cmp.find("saveAlertModal")[0].open();
            }else{
                cmp.find("saveAlertModal").open();
            }
            
        }else {
            var selectedRow = cmp.get("v.projectTimeEventDetails")[event.currentTarget.getAttribute("data-value")];
            cmp.set("v.selectedProjectId",selectedRow.projectId);
            cmp.set("v.seletedProjectName",selectedRow.projectName);
            cmp.set("v.selectedRowInstructorId",selectedRow.instructorId);
            cmp.set("v.selectedRowProtaskId",selectedRow.proTaskId);
            cmp.set("v.instructorName",selectedRow.instructorName);
            helper.getEventTimeRecords(cmp);
        }
    },
    saveAlertClose: function(cmp, event, helper){
        
        // To close sldsmodel cmp
        if(Array.isArray(cmp.find("saveAlertModal"))) {
            cmp.find("saveAlertModal")[0].close();
        }else{
            cmp.find("saveAlertModal").close();
        }
        cmp.set("v.displaySaveAlert",false);
        cmp.set("v.studentTimeEntryRow",[]);
        cmp.set("v.eventDetails",[]);
        cmp.set("v.dayDetails",[]);
        cmp.set("v.noteDetails",[]);
    },
    proceedWithoutSave : function(cmp, event, helper){
        
        // To close sldsmodel cmp
        if(Array.isArray(cmp.find("saveAlertModal"))) {
            cmp.find("saveAlertModal")[0].close();
        }else{
            cmp.find("saveAlertModal").close();
        }
        cmp.set("v.displaySaveAlert",false);
        
        cmp.set("v.updatedEventIds",[]);
        cmp.set("v.dayEntriesRecords",[]);  
        
        // To close detail model
        if(Array.isArray(cmp.find("displayDetailModal"))) {
            cmp.find("displayDetailModal")[0].close();
        }else{
            cmp.find("displayDetailModal").close();
        }
        cmp.set("v.showDetails",false);
    },
    saveAlertOkClick : function(cmp, event, helper){
        var updatedEventIds = cmp.get("v.updatedEventIds");
        
        if(updatedEventIds.length > 0){
            helper.updateEventRecords(cmp);
        }
        if(cmp.get("v.dayEntriesRecords").length > 0){
            helper.saveTimeCardDayRecords(cmp,'Save Changes');  
        }
        if(Array.isArray(cmp.find("saveAlertModal"))) {
            cmp.find("saveAlertModal")[0].close();
        }else{
            cmp.find("saveAlertModal").close();
        }
        cmp.set("v.displaySaveAlert",false);
        helper.getProjectSummaryDetails(cmp);
    },
    lookupSearch : function(cmp, event, helper){
        cmp.set("v.isDisplayProjectfilter",false);
        // Get the getLookupRecords server side action
        const serverSearchAction = cmp.get('c.getLookupRecords');
        // Passes the action to the Lookup cmp by calling the search method
        cmp.find('lookup').search(serverSearchAction);
    },
    saveBtnClick : function(cmp, event, helper){
        var updatedEventIds = cmp.get("v.updatedEventIds");
        if(updatedEventIds.length > 0){
            cmp.set("v.TypeOfAction",'Event');
            helper.updateEventRecords(cmp);
        }
    },
    closeClickOnSuccess: function(cmp, event, helper){
        if(Array.isArray(cmp.find("successModal"))) {
            cmp.find("successModal")[0].close();
        }else{
            cmp.find("successModal").close();
        }  
        cmp.set("v.displaySuccessModal",false);
        
        if(cmp.get("v.successTitle") == 'Success'){
            cmp.set("v.eventDetails",[]);
            cmp.set("v.dayDetails",[]);
            cmp.set("v.seletedProjectName",'');
            
            if(cmp.get("v.TypeOfAction") == 'Time Card Day'){
                
                cmp.set("v.showSpinner",true);
                // To close detail model
                if(Array.isArray(cmp.find("displayDetailModal"))) {
                    cmp.find("displayDetailModal")[0].close();
                }else{
                    cmp.find("displayDetailModal").close();
                }
                
                cmp.set("v.showDetails",false);
                cmp.set("v.selectedProjectId",'');
                cmp.set("v.seletedProjectName",'');
                cmp.set("v.selectedRowInstructorId",'');
                cmp.set("v.selectedRowProtaskId",'');
                cmp.set("v.dayEntriesRecords",[]);
                cmp.set("v.updatedDayMap",{});
                helper.getProjectSummaryDetails(cmp);
            }else {
                
                if(Array.isArray(cmp.find("displayDetailModal"))) {
                    cmp.find("displayDetailModal")[0].close();
                }else{
                    cmp.find("displayDetailModal").close();
                }  
                cmp.set("v.showDetails",false);
                helper.getEventTimeRecords(cmp);
                cmp.set("v.dayEntriesRecords",[]);
                cmp.set("v.updatedDayMap",{});
            }
            
            cmp.set("v.updatedEventIds",[]);
        }
    },
    closeOnDetailDisplay: function(cmp,event, helper){
        var updatedEventIds = cmp.get("v.updatedEventIds");
        
        if(updatedEventIds.length > 0 || cmp.get("v.dayEntriesRecords").length > 0){
            cmp.set("v.displaySaveAlert",true);
            if(Array.isArray(cmp.find("saveAlertModal"))) {
                cmp.find("saveAlertModal")[0].open();
            }else{
                cmp.find("saveAlertModal").open();
            }
        }else {
            cmp.set("v.eventDetails",[]);
            cmp.set("v.dayDetails",[]);
            cmp.set("v.dayEntriesRecords",[]);
            cmp.set("v.seletedProjectName",'');
            // To close detail model
            if(Array.isArray(cmp.find("displayDetailModal"))) {
                cmp.find("displayDetailModal")[0].close();
            }else{
                cmp.find("displayDetailModal").close();
            }
            cmp.set("v.showDetails",false);
        }
    },
    viewChange :  function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        cmp.set("v.showDetails",false);
        cmp.set("v.isDisplayProjectfilter",false);
        helper.getProjectSummaryDetails(cmp);
    },
    selectedWeeK : function(cmp, event, helper){
        cmp.set("v.isDisplayProjectfilter",false);
    },
    selectedProject : function(cmp, event, helper){
        
        var proId = cmp.find('selProject').get("v.value");
        var selectedproArray = [];
        cmp.set("v.projectTimeEventDetails",[]);
        
        if(proId == 'All'){
            cmp.set("v.projectTimeEventDetails",cmp.get("v.projectTimeEventInfo"));  
        }else {
            for(var i = 0; i < cmp.get("v.projectTimeEventInfo").length;i++){
                if(proId == cmp.get("v.projectTimeEventInfo")[i].projectId){
                    selectedproArray.push(cmp.get("v.projectTimeEventInfo")[i]);
                }
            }
            cmp.set("v.projectTimeEventDetails",selectedproArray);
        }
    },
    
    onRecordTypeChange : function(cmp, event, helper){
        var recordType = cmp.find('selRecordType').get("v.value");
        var selectedproArray = [];
        cmp.set("v.projectTimeEventDetails",[]);
        
        if(recordType == 'All'){
            cmp.set("v.projectTimeEventDetails",cmp.get("v.projectTimeEventInfo"));  
        }else {
            for(var i = 0; i < cmp.get("v.projectTimeEventInfo").length;i++){ 
                if(recordType == cmp.get("v.projectTimeEventInfo")[i].recordType ){
                    selectedproArray.push(cmp.get("v.projectTimeEventInfo")[i]);
                }
            }
            cmp.set("v.projectTimeEventDetails",selectedproArray);
        }
    },
    
    approveClk : function(cmp, event, helper){
        var index = event.getSource().get("v.alternativeText");
        cmp.set("v.rowIndex",parseInt(index));
        var dayRecords = cmp.get("v.dayDetails");
        dayRecords[parseInt(index)].status = 'Save - Approved';
        cmp.set("v.dayDetails", dayRecords);
        
        var dayId = dayRecords[parseInt(index)].dayId;
        var dayEntriesRecords = cmp.get("v.dayEntriesRecords");
        var dayindex = -1;
        
        for(var i = 0;i < dayEntriesRecords.length;i++){
            if(dayId == dayEntriesRecords[i].Id ){
                dayindex = i; 
            }
        }
        if(dayindex >= 0){
            dayEntriesRecords[dayindex] = {'Id':dayId,'Status__c':'Save - Approved','AcctSeed__Hours__c': dayRecords[parseInt(index)].hours,'Approved_by__c':null,'AcctSeed__Invoice_Comment__c':null};
        }else{
            dayEntriesRecords.push({'Id':dayId,'Status__c':'Save - Approved','AcctSeed__Hours__c': dayRecords[parseInt(index)].hours,'Approved_by__c':null,'AcctSeed__Invoice_Comment__c':null});
        }
        cmp.set("v.dayEntriesRecords",dayEntriesRecords);
    },
    rejectClk : function(cmp, event, helper){
        var index = event.getSource().get("v.alternativeText");
        cmp.set("v.rowIndex",parseInt(index));
        cmp.set("v.showRejectionReasonModal",true);
        cmp.set("v.rejectionReason","");
        
        if(Array.isArray(cmp.find("showRejectReason"))) {
            cmp.find("showRejectReason")[0].open();
        }else{
            cmp.find("showRejectReason").open();
        }     
        
    },
    handleRemoveClk : function(cmp, event, helper){
        var index = event.getSource().get("v.name");
        cmp.set("v.rowIndex",parseInt(index));
        
        var dayRecords = cmp.get("v.dayDetails");
        if(dayRecords[parseInt(index)].status == 'Save - Approved' 
           || dayRecords[parseInt(index)].status == 'Save - Rejected'
           || dayRecords[parseInt(index)].status == 'Rejected'){
            dayRecords[parseInt(index)].status = 'Submitted';
        }
        
        cmp.set("v.dayDetails", dayRecords);
        
        var dayId = dayRecords[parseInt(index)].dayId;
        var dayEntriesRecords = cmp.get("v.dayEntriesRecords");
        var dayindex = -1;
        
        for(var i = 0;i < dayEntriesRecords.length;i++){
            if(dayId == dayEntriesRecords[i].Id ){
                dayindex = i; 
            }
        }
        if(dayindex >= 0){
            dayEntriesRecords[dayindex] = {'Id':dayId,'Status__c':'Submitted','AcctSeed__Hours__c': 0.0,'Approved_by__c':null,'AcctSeed__Invoice_Comment__c':null};
        }else{
            dayEntriesRecords.push({'Id':dayId,'Status__c':'Submitted','AcctSeed__Hours__c': 0.0,'Approved_by__c':null,'AcctSeed__Invoice_Comment__c':null});
        }
        cmp.set("v.dayEntriesRecords",dayEntriesRecords);  
        
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
            var dayRecords = cmp.get("v.dayDetails");
            var rowIndex = cmp.get("v.rowIndex");
            
            dayRecords[rowIndex].rejectionReason = cmp.get("v.rejectionReason");
            dayRecords[rowIndex].status = 'Save - Rejected';
            cmp.set("v.dayDetails", dayRecords);
            
            cmp.set("v.showRejectionReasonModal",false);
            var dayId = dayRecords[rowIndex].dayId;
            var dayEntriesRecords = cmp.get("v.dayEntriesRecords");
            var dayindex = -1;
            
            for(var i = 0;i < dayEntriesRecords.length;i++){
                if(dayId == dayEntriesRecords[i].Id ){
                    dayindex = i; 
                }
            }
            if(dayindex >= 0){
                dayEntriesRecords[dayindex] = {'Id':dayId,'Status__c':'Save - Rejected','Approved_by__c':null,'AcctSeed__Invoice_Comment__c':cmp.get("v.rejectionReason")};
            }else{
                dayEntriesRecords.push({'Id':dayId,'Status__c':'Save - Rejected','Approved_by__c':null,'AcctSeed__Invoice_Comment__c':cmp.get("v.rejectionReason")});
            }
            cmp.set("v.dayEntriesRecords",dayEntriesRecords); 
        }
    },
    rejectionCloseClk : function(cmp, event, helper){
        cmp.set("v.showRejectionReasonModal",false);
    },
    viewReasonClk : function(cmp, event, helper){
        var index = event.currentTarget.name;
        cmp.set("v.rejectionReason","");
        var rejectReason = cmp.get("v.dayDetails")[parseInt(index)].rejectionReason;
        cmp.set("v.rejectionReason",rejectReason);
        cmp.set("v.showRejectionReasonModal",true);
        
        if(Array.isArray(cmp.find("showRejectReason"))) {
            cmp.find("showRejectReason")[0].open();
        }else{
            cmp.find("showRejectReason").open();
        }     
    },
    
    saveChangesClick : function(cmp, event, helper) {
        
        if(cmp.get("v.viewType") == 'Pending Submission') {
            if(cmp.get("v.ShowApproveReject")) {
                if(helper.validateTCDchange(cmp, event)) {
                    cmp.find("pendingSubmissionConfirmation").open();
                }else {
                    cmp.set("v.successTitle",'Warning');
                    cmp.set("v.successMsg",'Please Approve or reject the entries');
                    cmp.set("v.displaySuccessModal",true);
                    // To open success/error modal cmp
                    if(Array.isArray(cmp.find("successModal"))) {
                        cmp.find("successModal")[0].open();
                    }else{
                        cmp.find("successModal").open();
                    }   
                }
            }
        }else {
            helper.updateTCD(cmp, event, helper);
        }
        
    },
    
    savePendingApprovalTimeCardDays : function(cmp, event, helper) {
        helper.updateTCD(cmp, event, helper);
    },
    
    closePendingApprovalModal : function(cmp, event, helper) {
        cmp.find("pendingSubmissionConfirmation").close();
    },
    
    submitClick : function(cmp, event, helper) {
        
        var allowSubmit = helper.validateScheduledEvents(cmp, event);
        if(allowSubmit) {
            if(cmp.get("v.viewType") == 'Pending Submission') {
                if(helper.validateTCDchange(cmp, event)) {
                    cmp.find("pendingSubmissionConfirmation").open();
                    cmp.set("v.TypeOfAction",'Time Card Day');
                }else {
                    cmp.set("v.successTitle",'Warning');
                    cmp.set("v.successMsg",'Please Approve or reject the entries');
                    cmp.set("v.displaySuccessModal",true);
                    // To open success/error modal cmp
                    if(Array.isArray(cmp.find("successModal"))) {
                        cmp.find("successModal")[0].open();
                    }else{
                        cmp.find("successModal").open();
                    }   
                }
            }else{
                
                var updatedTCDs = [];
                var dayDetails = cmp.get("v.dayDetails");
                var totalRecordsCnt = dayDetails.length;
                
                var count = cmp.get("v.count");
                count.approveCount = 0;
                count.rejectCount = 0;
                cmp.set("v.count", count);
                
                var studentApprovalIsPending = false;
                
                var warningMsg = '';
                
                updatedTCDs = helper.updateTCDHelper(cmp,count.approveCount,count.rejectCount);
                
                //Get the already approved / Rejected time entries for Submit action
                for(var  i = 0;i < dayDetails.length;i++){
                    
                    if(dayDetails[i].stuApproveStatus != 'Approved' && !dayDetails[i].skipStudentApprovalRequiredModal){ //dayDetails[i].taskType != 'Preparation time'){
                        studentApprovalIsPending = true;
                        
                        if(!warningMsg){
                            warningMsg = '<ul style="list-style-type: initial;"><li>'+dayDetails[i].chargeCode+' - '+dayDetails[i].dayDate+' - '+dayDetails[i].startTime+' - '+dayDetails[i].endTime+' - '+dayDetails[i].dayHours+' Hrs</li>';
                        }else {
                            warningMsg += '<li>'+dayDetails[i].chargeCode+' - '+dayDetails[i].dayDate+' - '+dayDetails[i].startTime+' - '+dayDetails[i].endTime+' - '+dayDetails[i].dayHours+' Hrs</li>'; 
                        }
                    }
                }
                
                if(studentApprovalIsPending){
                    warningMsg += '</ul>';
                    cmp.set("v.warningMsg",warningMsg);
                }
                
                cmp.set("v.TypeOfAction",'Time Card Day');
                var cntMap = cmp.get("v.count");
                
                if(!studentApprovalIsPending){
                    cmp.set("v.dayEntriesRecords",updatedTCDs);
                    if(totalRecordsCnt == cntMap.approveCount){
                        helper.saveTimeCardDayRecords(cmp,'Approve All');
                    }else if(totalRecordsCnt == cntMap.rejectCount){
                        helper.saveTimeCardDayRecords(cmp,'Reject All');
                    }else {
                        helper.saveTimeCardDayRecords(cmp,'Save Changes');
                    }
                }else {
                    if(totalRecordsCnt == cntMap.approveCount){
                        cmp.set("v.actionType",'Approve All');
                    }else if(totalRecordsCnt == cntMap.rejectCount){
                        cmp.set("v.actionType",'Reject All');
                    }else {
                        cmp.set("v.actionType",'Save Changes');
                    }
                    
                    cmp.set("v.displayWarningModal",true);
                    if(Array.isArray(cmp.find("submitWarningModal"))) {
                        cmp.find("submitWarningModal")[0].open();
                    }else{
                        cmp.find("submitWarningModal").open();
                    }   
                }
            }
        }else {
            cmp.set("v.successTitle",'Warning');
            cmp.set("v.successMsg",'Please match all the events before submitting to approve');
            cmp.set("v.displaySuccessModal",true);
            // To open success/error modal cmp
            if(Array.isArray(cmp.find("successModal"))) {
                cmp.find("successModal")[0].open();
            }else{
                cmp.find("successModal").open();
            }   
        }
    }, 
    
    proceedOnPendingSubmission : function(cmp, event, helper) {
        var valid = true;
        var cmtDiv = cmp.find("approveCmt");
        var updatedTCDs = [];
        var dayDetails = cmp.get("v.dayDetails");
        
        if(!cmp.get("v.approvalComment")){
            $A.util.addClass(cmtDiv, 'slds-has-error');
            valid = false;
        }else {
            $A.util.removeClass(cmtDiv, 'slds-has-error');
            valid = true;
        }
        
        if(valid){
            updatedTCDs = helper.updateTCDHelper(cmp,0,0);
            cmp.set("v.dayEntriesRecords",updatedTCDs);
            
            if(updatedTCDs.length > 0){
                cmp.set("v.showSpinner",true);
                helper.saveTimeCardDayRecords(cmp,cmp.get("v.actionType"));
            }
            
            cmp.find("pendingSubmissionConfirmation").close();
        }
    },
    
    proceedOnSubmitWarning : function(cmp, event, helper) {
        var valid = true; 
        var cmtDiv = cmp.find("approveCmt");
        var updatedTCDs = [];
        var dayDetails = cmp.get("v.dayDetails");
        
        if(!cmp.get("v.approvalComment")){
            $A.util.addClass(cmtDiv, 'slds-has-error');
            valid = false;
        }else {
            $A.util.removeClass(cmtDiv, 'slds-has-error');
            valid = true;
        }
        
        if(valid){
            updatedTCDs = helper.updateTCDHelper(cmp,0,0);
            cmp.set("v.dayEntriesRecords",updatedTCDs);
            
            if(updatedTCDs.length > 0){
                cmp.set("v.showSpinner",true);
                helper.saveTimeCardDayRecords(cmp,cmp.get("v.actionType"));
            }
            
            if(cmp.get("v.updatedEventIds").length > 0){
                helper.updateEventRecords(cmp);
            }
            
            if(Array.isArray(cmp.find("submitWarningModal"))) {
                cmp.find("submitWarningModal")[0].close();
            }else{
                cmp.find("submitWarningModal").close();
            }   
            cmp.set("v.displayWarningModal",false);
        }
        
    },
    cancelOnSubmitWarning : function(cmp, event, helper){
        if(Array.isArray(cmp.find("submitWarningModal"))) {
            cmp.find("submitWarningModal")[0].close();
        }else{
            cmp.find("submitWarningModal").close();
        }   
        cmp.set("v.displayWarningModal",false);
    },
    sendReminderEmails : function(cmp, event, helper){
        var selectedInstructorList = cmp.get("v.selectedEmailList");
        cmp.get("v.selectedStudentEmailList").forEach(function(student){
            selectedInstructorList.push(student);
        });
        
        if(cmp.get("v.selectedEmailList").length > 0) {
            helper.emailSendingMethod(cmp,'Send Email');
        }else{
            cmp.find("showSendRemiderModal").close();
            cmp.set("v.successMsg",'Please choose atlease one Instructor or Student');
            cmp.set("v.successTitle",'Warning');
            cmp.set("v.showSpinner",false);
            cmp.set("v.displaySuccessModal",true);
            
            if(Array.isArray(cmp.find("successModal"))) {
                cmp.find("successModal")[0].open();
            }else{
                cmp.find("successModal").open();
            }
        }
        
    },
    
    //Added by Mohana
    openSendReminderModal : function(cmp, event, helper){
        // helper.getInstructorStudentList(cmp, event);
        cmp.set("v.selectedEmailList",[]);
        cmp.set("v.selectedStudentEmailList",[]);
        helper.emailSendingMethod(cmp, '');
        
    },
    
    closeSendReminderModal : function(cmp, event, helper) {
        cmp.find("showSendRemiderModal").close(); 
    },
    approvalAllClick : function(cmp, event ,helper){
        var dayDetails = cmp.get("v.dayDetails");
        var updatedRecords = [];
        
        for(var i = 0;i < dayDetails.length;i++){
            if(dayDetails.status != 'Approved'){
                updatedRecords.push({'Id':dayDetails[i].dayId,'AcctSeed__Hours__c': dayDetails[i].hours,'Status__c':'Approved','Approved_by__c':null,'AcctSeed__Invoice_Comment__c':null});
            }
        }
        if(updatedRecords.length > 0){
            cmp.set("v.TypeOfAction",'Time Card Day');
            cmp.set("v.dayEntriesRecords",updatedRecords);
            cmp.set("v.showSpinner",true);
            helper.saveTimeCardDayRecords(cmp,'Approve All');
        }
    },
    
    tableSort : function(cmp, event, helper) {
        var target = event.currentTarget;
        var name = target.getAttribute("data-name"); 
        var sortingMap =  cmp.get("v.sortingMap");
        
        sortingMap.fieldToSort = name;
        var currentDir = cmp.get("v.sortingMap.arrowDirection");
        if (currentDir == 'down') {
            sortingMap.arrowDirection = 'up';//cmp.set("v.arrowDirection", 'up');
            sortingMap.sortingOrder = 'Asc';
            helper.sortTableContentsAsc(cmp, event , name);
        } else {
            sortingMap.arrowDirection = 'down';
            sortingMap.sortingOrder = 'Desc';
            helper.sortTableContentsDesc(cmp, event , name);
        }
        cmp.set("v.sortingMap",sortingMap);
    },
})