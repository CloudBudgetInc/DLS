({
    getWeekRangeFilterValues : function(cmp){
        var action  = cmp.get("c.weekRangeFormation");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue());
                cmp.set("v.weekRangeValues",result.weekrange);
                cmp.set("v.filterObj.selectedWeek",result.weekrange[result.weekrange.length - 1]);
                cmp.set("v.projSections", result.sections);
                //cmp.set("v.showSpinner",false);
                this.getProjectSummaryDetails(cmp);
            }else {
                console.log(":::::week::range::error::;",response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    getProjectSummaryDetails : function(cmp) {
        var supervisorId = (cmp.get("v.filterObj").selectedLTS.length > 0) ? cmp.get("v.filterObj").selectedLTS[0].Id : null;
        var selectedWeek = cmp.get("v.filterObj").selectedWeek;
        var dt1 = selectedWeek.split(' to ')[0];
        var dt2 = selectedWeek.split(' to ')[1];
        
        var action = cmp.get("c.getWholeDetails");
        action.setParams({
            "fromDate" : dt1,
            "toDate" : dt2,
            "supervisorId" : supervisorId,
            "viewType" : cmp.get("v.viewType"),
            "projSection": cmp.get("v.selectedProjSection")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log("response",response.getReturnValue());
                var result = response.getReturnValue();
                var filterObj = cmp.get("v.filterObj");
                filterObj.fromDate = result.fromDate;
                filterObj.toDate = result.toDate;
                if(filterObj.selectedLTS.length == 0){
                    filterObj.selectedLTS = result.ltsContact;
                }
                cmp.set("v.filterObj",filterObj);
                cmp.set("v.projectTimeEventInfo",result.timeEventInfo);
                cmp.set("v.projectTimeEventDetails",result.timeEventInfo);                
                cmp.set("v.showSpinner",false);
                if(result.projectList.length > 0){
                    cmp.set("v.isDisplayProjectfilter",true);
                    cmp.set("v.filteredProject",result.projectList);
                }else{
                    cmp.set("v.filteredProject",[]);
                }
                
                if(result.projectRecordTypeList.length > 0) {
                    cmp.set("v.recordTypeList", result.projectRecordTypeList);
                }else {
                    cmp.set("v.recordTypeList", []);
                }
                
                this.sortTableContentsAsc(cmp, event, 'instructorName');
            }else {
                console.log("response:::::::::::::",response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    updateEventRecords : function(cmp){
        
        var updatedEventIds = cmp.get("v.updatedEventIds");
        console.log("::::::updatedEventIds:::::",updatedEventIds);
        var eventRecords = cmp.get("v.eventDetails");
        var recordToUpdate = [];
        
        for(var i = 0;i < eventRecords.length;i++){
            if(updatedEventIds.indexOf(eventRecords[i].eventId) != -1){
                recordToUpdate.push(this.eventRecordsFormation(cmp,eventRecords[i]));
            }
        }
        
        if(recordToUpdate.length > 0){
            cmp.set("v.showSpinner",true);
            var action = cmp.get("c.eventUpdate");
            action.setParams({
                "eventJson" : JSON.stringify(recordToUpdate)
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === 'SUCCESS'){
                    //display success model
                    cmp.set("v.showSpinner",false);
                    
                    if(cmp.set("v.TypeOfAction") != 'Time Card Day'){
                        
                        cmp.set("v.successTitle",'Success');
                        cmp.set("v.successMsg",'Events Updated Successfully');
                        cmp.set("v.updatedEventIds",[]);
                        cmp.set("v.displaySuccessModal",true);
                        // To open success/error modal cmp
                        if(Array.isArray(cmp.find("successModal"))) {
                            cmp.find("successModal")[0].open();
                        }else{
                            cmp.find("successModal").open();
                        }    
                    }
                    
                }else{
                    cmp.set("v.showSpinner",false);
                    console.log("error:::::::event:update:",response.getError()[0].message);
                    cmp.set("v.successTitle",'Error');
                    cmp.set("v.successMsg",response.getError()[0].message);
                    cmp.set("v.displaySuccessModal",true);
                    // To open success/error modal cmp
                    if(Array.isArray(cmp.find("successModal"))) {
                        cmp.find("successModal")[0].open();
                    }else{
                        cmp.find("successModal").open();
                    }             
                }
            });
            $A.enqueueAction(action);
        }
        
    },
    eventRecordsFormation : function(cmp,event){
        var obj = {};
        obj.Id = event.eventId;
        if(event.selectedTCD != '--Select--' && event.cancelSelection != 'Late Cancellation') {
            obj.Status__c = 'Completed';
        }else if(event.cancelSelection != '--Select--'){
            obj.Status__c = event.cancelSelection;
        }
        if(event.selectedTCD != '--Select--') {
            obj.Time_Card_Day__c = event.selectedTCD;
        }
        return obj;
    },
    _setFixedHeader : function(cmp) {
        if(cmp.get("v.projectTimeEventDetails").length > 0){
            
            const globalId = cmp.getGlobalId(),
                parentnode = document.getElementById(globalId),
                thElements = parentnode.getElementsByTagName('th'),
                tdElements = parentnode.getElementsByTagName('td'),
                tableContent = cmp.find("tableContent").getElement(),
                tableFixedheight =  400;
            
            
            if(tableContent.offsetHeight > tableFixedheight && thElements.length > 0){
                let lastHeaderWidth = tableContent.offsetWidth;
                for (let i = 0; i < thElements.length; i++) {
                    lastHeaderWidth = lastHeaderWidth - tdElements[i].offsetWidth;
                    tdElements[i].style.width = tdElements[i].offsetWidth  + 'px';
                    
                    if(i !== thElements.length - 1) {
                        thElements[i].style.width = tdElements[i].style.width;
                    }
                    
                    //thElements.style.width = tdElements[i].offsetWidth  + 'px';
                    
                }
                
            }
        } 
    },
    setFixedHeader : function(cmp) {
        //return;
        if(cmp.get("v.projectTimeEventDetails").length > 0){
            
            const globalId = cmp.getGlobalId(),
                parentnode = document.getElementById(globalId),
                thElements = parentnode.getElementsByTagName('thead'),
                tdElements = parentnode.getElementsByTagName('td'),
                tableContent = cmp.find("tableContent").getElement(),
                //tableContent = document.getElementsByClassName('scrollable-table');
                tableFixedheight =  400;
            tableContent.addEventListener('scroll', function() {
                thElements[0].setAttribute('style', 'transform: translate(0, ' + tableContent.scrollTop + 'px);');
            });
        }
    },
    getEventTimeRecords : function(cmp){
        cmp.set("v.showSpinner",true);
        var supervisorId = (cmp.get("v.filterObj").selectedLTS.length > 0) ? cmp.get("v.filterObj").selectedLTS[0].Id : null;
        var selectedWeek = cmp.get("v.filterObj").selectedWeek;
        var dt1 = selectedWeek.split(' to ')[0];
        var dt2 = selectedWeek.split(' to ')[1];
        
        var action = cmp.get("c.getProjectBasedEventTimeDetails");
        action.setParams({
            "fromDate" : dt1,
            "toDate" : dt2,
            "supervisorId" : supervisorId,
            "projectId" : cmp.get("v.selectedProjectId"),
            "viewType" : cmp.get("v.viewType"),
            "instructorId" : cmp.get("v.selectedRowInstructorId"),
            "taskId" : cmp.get("v.selectedRowProtaskId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var studentTimeEntryRow = [];
                var result = response.getReturnValue();
                console.log(':::::result::::',result);
                cmp.set("v.eventDetails",result.eventInfo);
                cmp.set("v.dayDetails",result.timeDayInfo);
                cmp.set("v.noteDetails",JSON.parse(result.notes));
                cmp.set("v.ShowApproveReject",false);
                if(result.studentTimeEntry){
                    studentTimeEntryRow = JSON.parse(result.studentTimeEntry);
                }
                if(result.projectRTName == 'DLI_W_LT_Projects' || result.projectRTName == 'DODA_Projects' || (result.projectRTName == 'Language_Training_Projects' && result.showSendReminderBtn)){
                    cmp.set("v.showSendEmailBtn",true);
                }
                cmp.set("v.studentTimeEntryRow",studentTimeEntryRow);
                cmp.set("v.weekDetails",JSON.parse(result.weekDetails));
                cmp.set("v.projectRTName",result.projectRTName);
                cmp.set("v.showSendEmailBtn",result.showSendReminderBtn);
                 
                var approvedCnt = 0;
                var rejectedCnt = 0;
                var submittedCnt = 0;
                var studentApprovedAll = true;
                
                for(var i = 0;i < result.timeDayInfo.length;i++){
                    if(result.timeDayInfo[i].status == 'Approved' || result.timeDayInfo[i].status == 'Admin Approved'){
                        approvedCnt += 1;
                    }else if(result.timeDayInfo[i].status == 'Rejected'){
                        rejectedCnt += 1;
                    }else if(result.timeDayInfo[i].status == 'Save - Approved' 
                             || result.timeDayInfo[i].status == 'Save - Rejected'
                             || result.timeDayInfo[i].status == 'Submitted'){
                        submittedCnt += 1;
                    }
                    
                    //To display Apporve All btn
                    if(result.timeDayInfo[i].taskType != 'Preparation time' && (!result.timeDayInfo[i].skipStudentApprovalRequiredModal && result.timeDayInfo[i].stuApproveStatus != 'Approved')){
                        studentApprovedAll = false;
                    }
                }
                
                if(approvedCnt == result.timeDayInfo.length){
                    cmp.set("v.displayActions",false);
                }else if(rejectedCnt == result.timeDayInfo.length || submittedCnt == result.timeDayInfo.length){
                    cmp.set("v.displayActions",true);
                }                
                
                //Show Approve All Btn
                var eventsMapped = true;
                for(var i = 0;i < result.eventInfo.length;i++){
                    if(!result.eventInfo[i].tcdId){
                        eventsMapped = false;
                    }
                }
                
                if(eventsMapped && studentApprovedAll){
                    cmp.set("v.showApproveAll",true);
                }else {
                    cmp.set("v.showApproveAll",false);
                }
                
                //Added by mohana 
                if(cmp.get("v.viewType") == 'Pending Submission') {
                    this.addApproveOrReject(cmp, event);
                }
                
                cmp.set("v.showDetails",true);
                // To open detail model
                if(Array.isArray(cmp.find("displayDetailModal"))) {
                    cmp.find("displayDetailModal")[0].open();
                }else{
                    cmp.find("displayDetailModal").open();
                }
                cmp.set("v.showSpinner",false);
            }else {
                cmp.set("v.showSpinner",false);
                console.log("error::::event::time::detailsQry:::",response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    
    addApproveOrReject : function(cmp,event){
        var eventList = cmp.get("v.eventDetails");
        var dayList = cmp.get("v.dayDetails");
        var breakLoop = false;
        
        for(var j = 0; j < eventList.length; j++) {
            if(eventList[j].tcdId) { 
                breakLoop = true;
            }else {
                breakLoop = false;
                break;
            }
        }
        
        /* for(var i=0; i < dayList.length ; i++){
            breakLoop = false;
            for(var j = 0; j < eventList.length; j++) {
                if(eventList[j].tcdId == dayList[i].dayId) { 
                    breakLoop = true;
                }
            }
            if(!breakLoop){
                break;
            }
        }*/
        
        if(breakLoop) {
            cmp.set("v.ShowApproveReject",true);
        }else {
            cmp.set("v.ShowApproveReject",false);
        }
        
    },
    
    updateTCD : function(cmp, event, helper) {
        var updatedTCDs = cmp.get("v.dayEntriesRecords");
        if(updatedTCDs.length > 0) {
            for(var i = 0;i < updatedTCDs.length;i++){
                delete updatedTCDs[i].AcctSeed__Hours__c;
            }
            
            cmp.set("v.dayEntriesRecords",updatedTCDs);
            
            this.saveTimeCardDayRecords(cmp,'Save Changes');
        }    
    }, 
    
    validateScheduledEvents : function(cmp, event) {
        var eventRecords = cmp.get("v.eventDetails");
        var eventDetailCmp = cmp.find('eventDetailCmp');
        if(!Array.isArray(eventDetailCmp)){
            eventDetailCmp = [eventDetailCmp];
        }
        var allow = true;
        console.log('EventREc::');
        console.log(eventRecords)
        var i = 0;
        eventRecords.forEach(function(eve) {            
            if((eve.hasOwnProperty('selectedTCD') && eve.hasOwnProperty('cancelSelection')) 
               && ((eve.selectedTCD == '--Select--' && eve.cancelSelection == '--Select--') ||
                   (eve.cancelSelection != 'Canceled' && eve.selectedTCD == '--Select--'))) {
                allow = false;
                eventDetailCmp[i].toggleError(true);
            }else{
                eventDetailCmp[i].toggleError(false);
            }
            i++;
        });
        
        return allow;
    },
    
    saveTimeCardDayRecords : function(cmp,type){
        console.log('::::::dayEntriesRecords::',cmp.get("v.dayEntriesRecords"));
        
        if(cmp.get("v.dayEntriesRecords").length > 0){
            cmp.set("v.showSpinner",true);
            var action =  cmp.get("c.saveTimeCardEntryRecords");
            action.setParams({
                'tCDRecords':JSON.stringify(cmp.get("v.dayEntriesRecords")),
                'actionType' : type,
                'comment' : cmp.get("v.approvalComment")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    console.log(':::saveTimeCardDayRecords::::result:::',response.getReturnValue());
                    cmp.set("v.successTitle","Success");
                    cmp.set("v.successMsg",'Time entries updated successfully.');
                    cmp.set("v.displaySuccessModal",true);
                    
                    cmp.set("v.updatedEventIds",[]);
                    
                    if(Array.isArray(cmp.find("successModal"))) {
                        cmp.find("successModal")[0].open();
                    }else{
                        cmp.find("successModal").open();
                    }  
                    cmp.set("v.showSpinner",false);
                }else {
                    cmp.set("v.successMsg",response.getError()[0].message);
                    cmp.set("v.successTitle",'Error');
                    cmp.set("v.showSpinner",false);
                    cmp.set("v.displaySuccessModal",true);
                    
                    if(Array.isArray(cmp.find("successModal"))) {
                        cmp.find("successModal")[0].open();
                    }else{
                        cmp.find("successModal").open();
                    }
                }  
            });
            $A.enqueueAction(action); 
        }
    },
    emailSendingMethod : function(cmp, source){
        cmp.set("v.showSpinner",true);
        
        var selectedWeek = cmp.get("v.filterObj").selectedWeek;
        var dt1 = selectedWeek.split(' to ')[0];
        var dt2 = selectedWeek.split(' to ')[1];
        
        var action =  cmp.get("c.sendReminderEmailToStudentInstructor");
        action.setParams({
            'projectId': cmp.get("v.selectedProjectId"),
            'instructorId': cmp.get("v.selectedRowInstructorId"),
            'startDate': dt1,
            'endDate' : dt2,
            'source' : source,
            'selectedEmailTobeSend' : JSON.stringify(cmp.get("v.selectedEmailList"))
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                cmp.set("v.showSpinner",false);
                if(source == 'Send Email') {
                    cmp.find("showSendRemiderModal").close();
                    cmp.set("v.successTitle","Success");
                    cmp.set("v.successMsg",'Email send to Student(s) and Instructor Successfully.');
                    cmp.set("v.displaySuccessModal",true);
                    
                    if(Array.isArray(cmp.find("successModal"))) {
                        cmp.find("successModal")[0].open();
                    }else{
                        cmp.find("successModal").open();
                    }  
                    
                }else {
                    var instructorStudentList = JSON.parse(response.getReturnValue());
                    if(instructorStudentList.length > 0) {
                        var instructors = [];
                        instructors.push(JSON.parse(JSON.stringify(instructorStudentList[0])));
                        cmp.set("v.instructorList",instructors);
                        instructorStudentList.splice(0,1);
                        cmp.set("v.studentList", instructorStudentList);
                        cmp.find("showSendRemiderModal").open();
                    }else { 
                        
                    }
                }
                
            }else {
                cmp.set("v.successMsg",response.getError()[0].message);
                cmp.set("v.successTitle",'Error');
                cmp.set("v.showSpinner",false);
                cmp.set("v.displaySuccessModal",true);
                
                if(Array.isArray(cmp.find("successModal"))) {
                    cmp.find("successModal")[0].open();
                }else{
                    cmp.find("successModal").open();
                }
            }  
        });
        $A.enqueueAction(action); 
    },
    updateTCDHelper : function(cmp,approvedCnt,rejectedCnt){
        
        var updatedTCDs = JSON.parse(JSON.stringify(cmp.get("v.dayEntriesRecords")));
        var dayDetails = cmp.get("v.dayDetails");
        var totalRecordsCnt = dayDetails.length;
        var currentlyUpdatedIds = [];
        
        for(var i = 0;i < updatedTCDs.length;i++) {
            if(updatedTCDs[i].Status__c == 'Save - Approved'){
                updatedTCDs[i].Status__c = 'Approved';
                approvedCnt += 1;
            }else if(updatedTCDs[i].Status__c == 'Save - Rejected'){
                rejectedCnt += 1;
                updatedTCDs[i].Status__c = 'Rejected';
            }
            currentlyUpdatedIds.push(updatedTCDs[i].Id);
        }
        
        //Get the already approved / Rejected time entries for Submit action
        for(var  i = 0;i < dayDetails.length;i++){
            if(currentlyUpdatedIds.indexOf(dayDetails[i].dayId) == -1){
                if(dayDetails[i].status == 'Save - Approved'){
                    approvedCnt += 1;
                    updatedTCDs.push({'Id':dayDetails[i].dayId,'AcctSeed__Hours__c': dayDetails[i].hours,'Status__c':'Approved','Approved_by__c':null,'AcctSeed__Invoice_Comment__c':null});
                }else if(dayDetails[i].status == 'Save - Rejected'){
                    rejectedCnt += 1;
                    updatedTCDs.push({'Id':dayDetails[i].dayId,'Status__c':'Rejected','Approved_by__c':null,'AcctSeed__Invoice_Comment__c':dayDetails[i].rejectionReason});
                }
            }   
        }
        
        var count = cmp.get("v.count");
        count.approveCount = approvedCnt;
        count.rejectCount = rejectedCnt;
        cmp.set("v.count", count);
        
        return updatedTCDs;
    },
    
    //Added by Mohana
    getInstructorStudentList : function(cmp, event) {
        cmp.set("v.showSpinner",true);
        var action =  cmp.get("c.sendReminderEmailToStudentInstructor");
        action.setParams({
            'projectId': cmp.get("v.selectedProjectId"),
            'instructorId': cmp.get("v.selectedRowInstructorId"),
            'startDate': dt1,
            'endDate' : dt2
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                
                cmp.set("v.showSpinner",false);
            }else {
                
            }  
        });
        $A.enqueueAction(action); 
    },
    
    sortTableContentsAsc : function(cmp, event,colTobeSort) {
        var tableContents = cmp.get("v.projectTimeEventDetails");
        tableContents.sort(function(a, b) {
            var textA = a[colTobeSort];
            var textB = b[colTobeSort];
            return (textA < textB) ? -1 : (textA > textB) ? 1 : 0;
        });
        
        cmp.set("v.projectTimeEventDetails",tableContents);
    },
    
    sortTableContentsDesc : function(cmp, event,colTobeSort) {
        var tableContents = cmp.get("v.projectTimeEventDetails");
        tableContents.sort(function(a, b) {
            var textA = a[colTobeSort];
            var textB = b[colTobeSort];
            return (textA > textB) ? -1 : (textA < textB) ? 1 : 0;
        });
        
        cmp.set("v.projectTimeEventDetails",tableContents);
    },
    
    validateTCDchange : function(cmp, event) {
        var dayDetails = cmp.get("v.dayDetails");
        var changeOccurred = false;
        for(var  i = 0;i < dayDetails.length;i++) {
            if(dayDetails[i].status == 'Save - Approved' || dayDetails[i].status == 'Save - Rejected'){
                changeOccurred = true;
            }
        }
        return changeOccurred;
    }
})