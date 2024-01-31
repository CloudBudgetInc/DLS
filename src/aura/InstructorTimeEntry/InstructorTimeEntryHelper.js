({
    getFilterInformation : function(cmp) {
        var action = cmp.get("c.getInitialFilterValues");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == "SUCCESS"){
                var result = JSON.parse(response.getReturnValue());
                console.log(':::::do::init::;',result);
                cmp.set("v.weekList",result.weekFilter);
                cmp.set("v.contactId",result.contactId);
                cmp.set("v.employeeName",result.employeeName);
                cmp.set("v.attendancePickList", result.attendancePickList);
                cmp.set("v.topicId",result.timekeepingTopicId);
                cmp.set("v.timeEnteredLate", result.timeEnteredLate);
                cmp.set("v.timeEnteredOnTime", result.timeEnteredOnTime);
                cmp.set("v.showStaffTimeEntry",result.showStaffTimeEntry);
                var time = result.timeList;

                if(time && time.length > 0){
                    if(time.includes('12:00 AM')){
                        time.unshift(time.pop());
                    }
                    cmp.set("v.timeList",time);
                }
                
                var pmList = [];
                var amList = [];
                                
                for(var i = 0;i < time.length;i++){
                    if(time[i].includes('PM')){
                        pmList.push(time[i]);
                    }else if(time[i].includes('AM')){
                        amList.push(time[i]);
                    }
                }  
                
                cmp.set("v.pmTimeList",pmList);
                cmp.set("v.amTimeList",amList);
                
                var self = this;
                window.setTimeout(
                    $A.getCallback(function() {
                        cmp.set("v.selectedWeek",result.selectedWeek);
                        cmp.set("v.oldSelectedWeek",result.selectedWeek);
                        if(result.selectedWeek){
                            self.getProjectFilterDetails(cmp);
                        }else{
                            cmp.set("v.showSpinner",false);
                        }
                    }),100);
                
            }else {
                console.log(':::::::::err::msg::',response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    dateFormatFunction : function(dateVal){
        return dateVal.split('-')[1]+'/'+dateVal.split('-')[2]+'/'+dateVal.split('-')[0];
    },
    apexDateFormatFunction : function(dateval){
        return dateval.split('/')[2]+'-'+dateval.split('/')[0]+'-'+dateval.split('/')[1];
    },
    getProjectFilterDetails :  function(cmp){
        var dt1 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[0]);
        var dt2 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[1]);
        
        console.log(dt1,dt2);
        
        var action =  cmp.get("c.getProjectFilterValues");
        action.setParams({
            "startDate" : dt1,
            "endDate" : dt2,
            "contactId" : cmp.get("v.contactId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = JSON.parse(response.getReturnValue());
                console.log(':::pro::filter:::::::',result);
                var projects = cmp.get("v.projectFilter");
                projects = result.projectFilter;
                
                cmp.set("v.projectFilter",projects);
                cmp.set("v.selectedProject",'--Select--');
                cmp.set("v.projectSupervisorMap",result.proIdSupervisorName);
                cmp.set("v.projectInsPositionMap",result.projectIdInsPosition);
                cmp.set("v.projectIdTimeCompleted",result.projectIdTimeCompleted);
                cmp.set("v.projectStuLeaderMap",result.proIdStuLeaderName);
                
                //check if the urlParams obj have values then load that week
                var self = this;
                window.setTimeout(
                    $A.getCallback(function() {
                        var urlParam = cmp.get("v.urlParams");
                        if(Object.keys(urlParam).length > 0 && cmp.get("v.initialLoad")){
                            cmp.set("v.selectedWeek",urlParam.weekRange);
                            cmp.set("v.selectedProject",urlParam.projectId);
                            
                            //To fix the duplicate TCL creation on filter changes with table value changes
                            cmp.set("v.oldSelectedWeek",urlParam.weekRange);
                            cmp.set("v.oldSelectedProject",urlParam.projectId);
                            
                            var manager = cmp.get("v.projectSupervisorMap")[cmp.get("v.selectedProject")];
                            cmp.set("v.projectManager",manager);
                            cmp.set("v.instructorPosition",cmp.get("v.projectInsPositionMap")[cmp.get("v.selectedProject")]);
                            self.getTimeRowsFormation(cmp);
                            
                            //Call schedule details query method
                            self.getClassScheduleDetails(cmp);
                        }
                        
                    }),1000);
                
                cmp.set("v.showSpinner",false);
            }else {
                console.log(':::pro:::filter:::err::::',response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    getTimeRowsFormation : function(cmp){
        var dt1 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[0]);
        var dt2 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[1]);
        
        var projectData = cmp.get("v.projectFilter").filter(obj => {
            return obj.projectId === cmp.get("v.selectedProject");
        });
        
        var projectName = projectData[0].projectName.split(' / ')[0];
        var studentNames = projectData[0].projectName.split(' / ')[1];
        cmp.set("v.studentNames",studentNames);
        
        var action = cmp.get("c.getTimeRowsRelatedInformation");
        action.setParams({
            "stDate" : dt1,
            "endDate" : dt2,
            "projectId" : cmp.get("v.selectedProject"),
            "contactId" : cmp.get("v.contactId"),
            "projectName" : projectName,
            "studentNames" : studentNames
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = JSON.parse(response.getReturnValue());
                console.log('::::::::result::::::;',result,result.entries instanceof Array);
                cmp.set("v.headerList", result.weekDates);
                var dayRecords = cmp.get("v.dayRecords");
                dayRecords = result.entries;
                cmp.set("v.dayRecords", dayRecords);
                cmp.set("v.showAllButtons",result.displaySubmitBtn);
                cmp.set("v.showRecallBtn",result.displayRecallBtn);
                cmp.set("v.showCompleteBtn",result.displayCompleteBtn);
                cmp.set("v.displayRequestEditLink",result.displayRequestEditLink);
                cmp.set("v.alreadyCaseSubmitted",result.alreadyCaseSubmitted);
                cmp.set("v.validCRExistINCA",result.validCRExistINCA);
                cmp.set("v.notesList",result.notes);
                cmp.set("v.studentAttendanceList",result.studentEntries);
                cmp.set("v.plannedDaysOffMap",result.dateDaysOffValues);
                cmp.set("v.dliWLTHolidays",result.dliWLTHolidays);
                cmp.set("v.federalHolidays",result.federalHolidays);
                cmp.set("v.defaultCostRateRateType",result.defaultCostRateRateType);

                console.log('notes::::',result.notes);
                //Check valid Cost Rate record is assigned to the instructor contact assignment
                //If not display the msg
                if(result.validCRExistINCA){
                    if(result.entries.length > 0){
                        this.calculateTotalHours(cmp);
                    }
                    
                    //call student table total hrs calculation
                    if(result.studentEntries.length > 0){
                        this.calculateStudentTotalHrs(cmp);
                    }
                }else {
                    cmp.set("v.displayCRValidationModal",true);
                    if(Array.isArray(cmp.find("CRModal"))) {
                        cmp.find("CRModal")[0].open();
                    }else{
                        cmp.find("CRModal").open();
                    }
                }
                cmp.set("v.showSpinner",false);
            }else {
                console.log(':::::error:::on ::row::infor:::',response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    dmlActionFunction : function(cmp){
        var rowRecords = cmp.get("v.dayRecords");
        var dayList = [];
        
        var changesMade = false;
        var studentTimeChanged = false;
        var isUpdate = true;
        
        //TCD ids which are going for update action to use it in Notes formation
        //Work Item No: W-001481
        var updatedTCDIds = [];
        
        var dliWLTHolidays = cmp.get("v.dliWLTHolidays");
        var projectData = cmp.get("v.projectFilter").filter(obj => {
            return obj.projectId === cmp.get("v.selectedProject");
        });
        
        var projectId = '';
        
        for(var i = 0;i < rowRecords.length;i++){
            var entries = rowRecords[i].dayEntries;
            
            for(var j = 0;j < entries.length;j++){
                console.log(entries[j]);
                projectId = entries[j].projectId;
                
                let hrsEntered = (entries[j].dayHours == 0 || entries[j].dayHours)? true : false;
                if((entries[j].isNew && hrsEntered) 
                   || (entries[j].isUpdated && hrsEntered)){
                    if(entries[j].isNew){
                        entries[j].status = 'Draft';
                        if(entries[j].taskType != 'Preparation time'){
                            
                            //check the entry is in DLI-W LT holiday then set studen approval status as N/A
                            if(projectData.length > 0 && projectData[0].projectRTName == 'DLI_W_LT_Projects'){
                                
                                if(dliWLTHolidays.indexOf(entries[j].dateVal) != -1 && entries[j].lateCancellation){
                                    entries[j].studentApprovalStatus = 'N/A';
                                }else {
                                    entries[j].studentApprovalStatus = 'Submitted';
                                }
                                
                            }else if(projectData.length > 0 && ((projectData[0].projectRTName == 'DLI_W_LT_Projects' 
                                                                 && dliWLTHolidays.indexOf(entries[j].dateVal) == -1) || projectData[0].projectRTName != 'DLI_W_LT_Projects')){
                                
                                entries[j].studentApprovalStatus = 'Submitted';
                            }
                        }
                        isUpdate = false;
                    }else if(entries[j].isUpdated && hrsEntered){
                        if(entries[j].status == 'Unposted' && !entries[j].isUnposted){
                            entries[j].status = 'Draft';
                            if(entries[j].taskType != 'Preparation time'){
                                
                                //check the entry is in DLI-W LT holiday then set studen approval status as N/A
                                if(projectData.length > 0 && projectData[0].projectRTName == 'DLI_W_LT_Projects'){
                                    
                                    if(dliWLTHolidays.indexOf(entries[j].dateVal) != -1 && entries[j].lateCancellation){
                                        entries[j].studentApprovalStatus = 'N/A';
                                    }else {
                                        entries[j].studentApprovalStatus = 'Submitted';
                                    }
                                    
                                }else if(projectData.length > 0 && ((projectData[0].projectRTName == 'DLI_W_LT_Projects' 
                                                                     && dliWLTHolidays.indexOf(entries[j].dateVal) == -1) || projectData[0].projectRTName != 'DLI_W_LT_Projects')){
                                    
                                    entries[j].studentApprovalStatus = 'Submitted';
                                }
                            }
                        }
                        if(entries[j].status == 'Rejected'){
                            entries[j].status = 'Draft';
                        }
                        updatedTCDIds.push(entries[j].dayId);
                    }
                    changesMade = true;
                    
                    if(entries[j].startTime1 == '--None--'){
                        entries[j].startTime1 = null;
                    }
                    if(entries[j].endTime1 == '--None--'){
                        entries[j].endTime1 = null;
                    }
                    if(entries[j].startTime2 == '--None--'){
                        entries[j].startTime2 = null;
                    }
                    if(entries[j].endTime2 == '--None--'){
                        entries[j].endTime2 = null;
                    }
                    
                    dayList.push(entries[j]);
                }else if((cmp.get("v.actionType") == 'Submit' || cmp.get("v.actionType") == 'Complete') && hrsEntered 
                         && !entries[j].isUpdated && !entries[j].isNew && cmp.get("v.isvalueChanged")){	//when time entry changed & directly submitting the time entry 
                    //need to include the non edited time entries for time submission
                    
                    if(entries[j].taskType != 'Preparation time' && entries[j].studentApprovalStatus == 'Rejected'){
                        entries[j].studentApprovalStatus = 'Submitted';
                    }
                    changesMade = true;
                    dayList.push(entries[j]);
                }
            }
        }
        console.log('::::::::dayList::::',dayList);
        console.log(':::::::changesMade::::',changesMade);
        console.log('::::::::updatedTCDIds::::',updatedTCDIds);
        
        //Student Time Table changes capture
        var studentList = [];
        var stuAttendance = cmp.get("v.studentAttendanceList");
        for(var i = 0;i < stuAttendance.length;i++){
            var entry = stuAttendance[i].entries;
            for(var j = 0;j < entry.length;j++){
                if(entry[j].hours || entry[j].hours === 0){
                    if((entry[j].isNew && (entry[j].hours || entry[j].hours === 0)) || 
                       (entry[j].isUpdated && (entry[j].hours || entry[j].hours === 0)) || 
                      	entry[j].studentApprovalStatus == 'Recalled'){	//Add this status condition for W-007547 by NS
                        studentTimeChanged = true;
                        studentList.push(entry[j]);
                    }
                }
            }
        }
        console.log('::::::::studentList:::::::',studentList);
        console.log('::::::isChanged::::',cmp.get("v.isvalueChanged"));
        
        var dt1;
        var dt2;
        
        console.log('Old week:::',cmp.get("v.oldSelectedWeek"));
        console.log('selectedWeek:::',cmp.get("v.selectedWeek"));
        
        /*if(cmp.get("v.oldSelectedWeek") != cmp.get("v.selectedWeek")){
            dt1 = this.apexDateFormatFunction(cmp.get("v.oldSelectedWeek").split(' to ')[0]);
            dt2 = this.apexDateFormatFunction(cmp.get("v.oldSelectedWeek").split(' to ')[1]);
        }else {*/
            dt1 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[0]);
            dt2 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[1]);
        //}
        
        /*var projectId = '';
        
        console.log('Old project:::',cmp.get("v.oldSelectedProject"));
        console.log('selectedproject:::',cmp.get("v.selectedProject"));
        
        if(cmp.get("v.oldSelectedProject") != cmp.get("v.selectedProject")) {
            projectId = cmp.get("v.oldSelectedProject");
        }else {
            projectId = cmp.get("v.selectedProject");
        }*/

        if(cmp.get("v.isvalueChanged") || studentTimeChanged){
            var action = cmp.get("c.dmlOperationMethod");
            action.setParams({
                "startDate" : dt1,
                "endDate" : dt2,
                "conId" : cmp.get("v.contactId"),
                "timeDayJson" : JSON.stringify(dayList),
                "projectId" : projectId,
                "actionType" : cmp.get("v.actionType"),
                "studentJson" : JSON.stringify(studentList),
                "updatedTCDs" : updatedTCDIds
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                    
                    console.log('::::::result:::::',response.getReturnValue());   
                    
                    console.log('::::::dmlOperation::::::redirectToSubmitPage:',cmp.get("v.redirectToSubmitPage"));
                    
                    if(cmp.get("v.actionType") == 'Save'){
                        if(!isUpdate) {
                            cmp.set("v.successMsg",'Time entries created successfully.');
                        }else {
                            cmp.set("v.successMsg",'Time entries updated successfully.');
                        }
                        cmp.set("v.isvalueChanged",false);
                    }else if(cmp.get("v.actionType") == 'Submit'){
                        cmp.set("v.successMsg",'Time entries are submitted to supervisor for approval.');
                    }else if(cmp.get("v.actionType") == 'Complete' && !cmp.get("v.redirectToSubmitPage")){	//Check if current timesheet is last for that week 
                        cmp.set("v.successMsg",'Time entries are completed successfully.');
                    }else if(cmp.get("v.actionType") == 'Complete' && cmp.get("v.redirectToSubmitPage")){
                        
                        //cmp.set("v.successMsg",'Timesheets have been completed for all scheduled projects for this week, would you like to proceed to Review & Submit all your time for the week?');
                        
                        if(!cmp.get("v.internalView")){
                            window.location.href = '/instructor/s/time-submit?week='+cmp.get("v.selectedWeek");
                        }else {
                            this.redirectToStaffTimeEntry(cmp);
                        }
                    }
                    
                    if(cmp.get("v.successMsg")){
                        cmp.set("v.successTitle",'Success');
                        cmp.set("v.displaySuccessModal",true);
                        
                        cmp.set("v.showSpinner",false);
                        
                        if(Array.isArray(cmp.find("successModal"))) {
                            cmp.find("successModal")[0].open();
                        }else{
                            cmp.find("successModal").open();
                        }
                    }
                    
                }else {
                    console.log(':::::dml::::erro::::::',response.getError());
                    var errors = response.getError();
                    var errmsg = '';
                    
                    if(errors && errors[0]['message']) {
                        errmsg = errors[0].message;
                    }else if(errors && errors[0]['pageErrors'] && errors[0].pageErrors.length > 0 && errors[0].pageErrors[0].message){
                        errmsg = errors[0].pageErrors[0].message;
                    }
                    
                    cmp.set("v.successMsg",errmsg);
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
        }else if(cmp.get("v.actionType") == 'Submit' && !cmp.get("v.isvalueChanged") && !studentTimeChanged){
            this.submitWholeWeekTime(cmp);
        }else if(cmp.get("v.actionType") == 'Complete' && !cmp.get("v.isvalueChanged") && !studentTimeChanged){
            this.completeWholeWeekTime(cmp);
        }
    },
    calculateTotalHours : function(cmp){
        var rowData = cmp.get("v.dayRecords");
        var columnTotalHrsMap = {};
        columnTotalHrsMap.mondayTotalHrs = 0.00;
        columnTotalHrsMap.tuesdayTotalHrs = 0.00;
        columnTotalHrsMap.wednesdayTotalHrs = 0.00;
        columnTotalHrsMap.thursdayTotalHrs = 0.00;
        columnTotalHrsMap.fridayTotalHrs = 0.00;
        columnTotalHrsMap.saturdayTotalHrs = 0.00;
        columnTotalHrsMap.sundayTotalHrs = 0.00;
        var overAllHrs = 0.00;
        var totalHrsForSubmit = 0.00;
        
        for(var i = 0;i < rowData.length;i++){
            var totalHrs = 0.00;
            var entries = rowData[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                if(entries[j].dayHours){
                    totalHrs += parseFloat(entries[j].dayHours);
                    
                    if(entries[j].dayType == 'Monday'){
                        columnTotalHrsMap.mondayTotalHrs += parseFloat(entries[j].dayHours);
                    }else if(entries[j].dayType == 'Tuesday'){
                        columnTotalHrsMap.tuesdayTotalHrs += parseFloat(entries[j].dayHours);
                    }else if(entries[j].dayType == 'Wednesday'){
                        columnTotalHrsMap.wednesdayTotalHrs += parseFloat(entries[j].dayHours);
                    }else if(entries[j].dayType == 'Thursday'){
                        columnTotalHrsMap.thursdayTotalHrs += parseFloat(entries[j].dayHours);
                    }else if(entries[j].dayType == 'Friday'){
                        columnTotalHrsMap.fridayTotalHrs += parseFloat(entries[j].dayHours);
                    }else if(entries[j].dayType == 'Saturday'){
                        columnTotalHrsMap.saturdayTotalHrs += parseFloat(entries[j].dayHours);
                    }else if(entries[j].dayType == 'Sunday'){
                        columnTotalHrsMap.sundayTotalHrs += parseFloat(entries[j].dayHours);
                    }
                    
                    if(entries[j].status != 'Approved' && entries[j].status != 'Admin Approved' 
                       && entries[j].status != 'Unposted' && entries[j].status != 'Submitted'){
                        totalHrsForSubmit += parseFloat(entries[j].dayHours);
                    }
                }
            }
            rowData[i].totalHours = ((totalHrs * 100) / 100).toFixed(2).toString();
            
            overAllHrs += totalHrs;
        }
        
        if(columnTotalHrsMap.mondayTotalHrs.toString().indexOf('.') == -1){
            columnTotalHrsMap.mondayTotalHrs = columnTotalHrsMap.mondayTotalHrs+'.00';
        }
        if(columnTotalHrsMap.tuesdayTotalHrs.toString().indexOf('.') == -1){
            columnTotalHrsMap.tuesdayTotalHrs = columnTotalHrsMap.tuesdayTotalHrs+'.00';
        }
        if(columnTotalHrsMap.wednesdayTotalHrs.toString().indexOf('.') == -1){
            columnTotalHrsMap.wednesdayTotalHrs = columnTotalHrsMap.wednesdayTotalHrs+'.00';
        }
        if(columnTotalHrsMap.thursdayTotalHrs.toString().indexOf('.') == -1){
            columnTotalHrsMap.thursdayTotalHrs = columnTotalHrsMap.thursdayTotalHrs+'.00';
        }
        if(columnTotalHrsMap.fridayTotalHrs.toString().indexOf('.') == -1){
            columnTotalHrsMap.fridayTotalHrs = columnTotalHrsMap.fridayTotalHrs+'.00';
        }
        if(columnTotalHrsMap.saturdayTotalHrs.toString().indexOf('.') == -1){
            columnTotalHrsMap.saturdayTotalHrs = columnTotalHrsMap.saturdayTotalHrs+'.00';
        }
        if(columnTotalHrsMap.sundayTotalHrs.toString().indexOf('.') == -1){
            columnTotalHrsMap.sundayTotalHrs = columnTotalHrsMap.sundayTotalHrs+'.00';
        }
        
        overAllHrs =  ((overAllHrs * 100) / 100).toFixed(2);
        cmp.set("v.totalRowColumnHrs",overAllHrs);
        
        totalHrsForSubmit = ((totalHrsForSubmit * 100) / 100).toFixed(2);
        cmp.set("v.overAllHrs",totalHrsForSubmit);
        cmp.set("v.columnTotalHoursMap",columnTotalHrsMap);
        cmp.set("v.dayRecords",rowData);
        
    },
    FindTimeEntryChanges : function(cmp,type){
        var rowRecords = cmp.get("v.dayRecords");
        var changesMade = false;
        for(var i = 0;i < rowRecords.length;i++){
            var entries = rowRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                let hrsEntered = (entries[j].dayHours === 0 || entries[j].dayHours) ? true : false;
                if((entries[j].isNew && hrsEntered) 
                   || (entries[j].isUpdated && hrsEntered) 
                   || (type == 'From Validation' && entries[j].dayId && hrsEntered)){
                    changesMade = true;
                }
            }
        }
        
        return changesMade;
    },
    submitWholeWeekTime : function(cmp){
        var rowRecords = cmp.get("v.dayRecords");
        var dayList = [];
        
        for(var i = 0;i < rowRecords.length;i++){
            var entries = rowRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                if(entries[j].dayId && (entries[j].dayHours == 0 || entries[j].dayHours)){
                    dayList.push(entries[j]);
                }
            }
        }
        console.log(':::::submit::days::::::::::',dayList);
        
        var action = cmp.get("c.submitTCDEntries");
        action.setParams({
            "timeDayJson" : JSON.stringify(dayList)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log('::::::result::submit:::',response.getReturnValue());   
                cmp.set("v.showSpinner",false);
                cmp.set("v.successMsg",'Time entries are submitted to supervisor for approval.');
                cmp.set("v.successTitle",'Success');
                cmp.set("v.displaySuccessModal",true);
                
                if(Array.isArray(cmp.find("successModal"))) {
                    cmp.find("successModal")[0].open();
                }else{
                    cmp.find("successModal").open();
                }
            }else{
                console.log(':::::submit::::erro::::::',response.getError()[0].message);
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
    recallActionFunction : function(cmp,type){
        var daysForRecall = [];
        
        var rowRecords = cmp.get("v.dayRecords");
        for(var i = 0;i < rowRecords.length;i++){
            var entries = rowRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                if(entries[j].dayId && (entries[j].dayHours == 0 || entries[j].dayHours)){
                    if(type == 'Individual' && entries[j].isUpdated){
                        daysForRecall.push(entries[j]);
                    }else if(type != 'Individual'){
                        daysForRecall.push(entries[j]);
                    }
                }
            }
        }
        
        var action = cmp.get("c.recallExistingTimeEntries");
        action.setParams({
            "timeDayJson" : JSON.stringify(daysForRecall),
            "typeOfAction" : type
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                cmp.set("v.showSpinner",false);
                console.log('::::::result::recall:::',response.getReturnValue());   
                if(type == 'Group'){
                    cmp.set("v.successMsg",'Time entries are recalled successfully.');
                }else {
                    cmp.set("v.successMsg",'Time entry recalled successfully.');
                }
                
                cmp.set("v.successTitle",'Success');
                cmp.set("v.displaySuccessModal",true);
                
                if(Array.isArray(cmp.find("successModal"))) {
                    cmp.find("successModal")[0].open();
                }else{
                    cmp.find("successModal").open();
                }
            }else {
                console.log(':::::dml::::erro::::::',response.getError()[0].message);
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
    calculateStudentTotalHrs : function(cmp){
        var overAllHrs = 0.00;
        
        var studentRows = cmp.get("v.studentAttendanceList");
        
        for(var i = 0;i < studentRows.length;i++){
            var entry = studentRows[i].entries;
            var rowTotal = 0.00;
            
            for(var j = 0;j < entry.length;j++){
                if(entry[j].hours || entry[j].hours === 0){
                    rowTotal += parseFloat(entry[j].hours);
                }
            }
            studentRows[i].totalHours = ((rowTotal * 100) / 100).toFixed(2).toString();
            
            overAllHrs += rowTotal;
        }
        
        overAllHrs =  ((overAllHrs * 100) / 100).toFixed(2);
        cmp.set("v.studentOverAllSum",overAllHrs);
        
        cmp.set("v.studentAttendanceList",studentRows);
    },
    callStudentTimeRecallMethod : function(cmp){
        
        var stuArray = [];
        stuArray.push(cmp.get("v.studentRec"));
        
        var action = cmp.get("c.recallStudentAttendanceEntry");
        action.setParams({
            "studentJson" : JSON.stringify(stuArray)
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                cmp.set("v.successMsg",'Time entry recalled successfully.');
                cmp.set("v.successTitle",'Success');
                cmp.set("v.showSpinner",false);
                cmp.set("v.displaySuccessModal",true);
                if(Array.isArray(cmp.find("successModal"))) {
                    cmp.find("successModal")[0].open();
                }else{
                    cmp.find("successModal").open();
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
    //Method to check the hrs missmatch on day Hrs & student hours changes
    checkForStudenHoursMissMatch : function(cmp,oldHrsValue,updatedDay,rowIndex,columnIndex){
        console.log('enter student miss match');
        var attendance = cmp.get("v.studentAttendanceList");
        
        var projectData = cmp.get("v.projectFilter").filter(obj => {
            return obj.projectId === cmp.get("v.selectedProject");
        });
        
        //If day record hours is changed then update the corresponding values in student table
        if(oldHrsValue && updatedDay){
            console.log('if 1');
            for(var i = 0;i < attendance.length;i++){
                var entry = attendance[i].entries;
                for(var j = 0;j < entry.length;j++){
                    
                    if(updatedDay.dateVal == entry[j].dateVal && entry[j].hours && entry[j].hours == oldHrsValue){
                        if(entry[j].isNew){
                            entry[j].hours = updatedDay.dayHours;
                        }
                    }else if(updatedDay.dateVal == entry[j].dateVal && entry[j].hours 
                             && entry[j].hours != oldHrsValue && !entry[j].comments 
                             && projectData.length > 0 && !projectData[0].noStudentHrsVerification){
                        entry[j].displayNotesLink = 'true';
                    }
                }
            }
        }else if(rowIndex != -1 && columnIndex != -1){	//if the student time is entered check for the day record hourd & add the notes link if there is miss match
            console.log('2');
            var rowData = attendance[rowIndex];
            var columnData = rowData.entries[columnIndex];
            var dayRecords = cmp.get("v.dayRecords");
            
            for(var i = 0;i < dayRecords.length;i++){
                if(dayRecords[i].taskType != 'Preparation time'){
                    var entries = dayRecords[i].dayEntries;
                    for(var j = 0;j < entries.length;j++){
                        
                        if(entries[j].dateVal == columnData.dateVal 
                           && entries[j].dayHours != null && columnData.hours != null 
                           && (entries[j].dayHours != columnData.hours 
                               || columnData.hours === 0)
                           && projectData.length > 0 && !projectData[0].noStudentHrsVerification){
                            
                            columnData.displayNotesLink = 'true';
                            
                        }else if(entries[j].dateVal == columnData.dateVal 
                                 && entries[j].dayHours 
                                 && (entries[j].dayHours == columnData.hours || !columnData.hours)
                                 && projectData.length > 0 && !projectData[0].noStudentHrsVerification){
                            
                            columnData.displayNotesLink = 'false';
                        }
                    }
                }                
            }
            
            console.log(':::::::::else::2::');
        }else {	//if student time is entered first & then class time 2nd entered below else will come
            console.log('3');
            var dayRecords = cmp.get("v.dayRecords");
            var dayMap = {};
            
            for(var i = 0;i < dayRecords.length;i++){
                if(dayRecords[i].taskType != 'Preparation time'){
                    var entries = dayRecords[i].dayEntries;
                    for(var j = 0;j < entries.length;j++){
                        if((entries[j].isNew && entries[j].dayHours) || (entries[j].isUpdated && entries[j].dayHours)){
                            if(!dayMap[entries[j].dateVal]){
                                dayMap[entries[j].dateVal] = entries[j].dayHours;
                            }
                        }
                    }
                }
            }
            
            //Now iterate the attendance table & check notes entered or not
            for(var i = 0;i < attendance.length;i++){
                var entry = attendance[i].entries;
                for(var j = 0;j < entry.length;j++){
                    if((entry[j].isNew && entry[j].hours) || (entry[j].isUpdated && entry[j].hours)){
                        
                        if(dayMap[entry[j].dateVal]){
                            var dayHrs = dayMap[entry[j].dateVal];
                            
                            if(entry[j].hours != null && (entry[j].hours != dayHrs || entry[j].hours == 0)
                               && projectData.length > 0 && !projectData[0].noStudentHrsVerification){
                                
                                entry[j].displayNotesLink = 'true';
                            }else if(entry[j].hours == dayHrs){
                                entry[j].displayNotesLink = 'false';
                            }
                        }
                    }
                }
            }
            console.log(':::::::::else::3::');
        }
        //console.log('::::::::attendance::validation:',attendance);
        cmp.set("v.studentAttendanceList",attendance);
    },
    populateUpdatedValuesInTable : function(cmp,updatedDay,lineIndex,dayIndex){
        
        console.log(':lineIndex::::dayIndex::',lineIndex,dayIndex);
        console.log('updatedDay',updatedDay);

        var temp1 = cmp.find("time");
        //console.log(':::::temp1::::',temp1);
        if(temp1){
            for(var i = 0;i < temp1.length;i++){
                var day = temp1[i].get("v.dayRecord");
                
                //For New Entries
                var index1 = temp1[i].get("v.lineIndex");
                var index2 = temp1[i].get("v.dayIndex");
                
                if(updatedDay.dayId && day.dayId == updatedDay.dayId){
                    console.log('if');
                    temp1[i].set("v.startTime",updatedDay.startTime1);
                    
                    var stTime = this.convertTime(cmp,updatedDay.startTime1);
                    temp1[i].set("v.endTimeList",this.endTimeCalculation(cmp,stTime,temp1[i].get("v.startTimeList")));
                    temp1[i].set("v.endTime",updatedDay.endTime1);
                }else if(lineIndex == index1 && dayIndex == index2){
                    temp1[i].set("v.startTime",updatedDay.startTime1);
                    
                    var stTime = this.convertTime(cmp,updatedDay.startTime1);
                    temp1[i].set("v.endTimeList",this.endTimeCalculation(cmp,stTime,temp1[i].get("v.startTimeList")));
                    temp1[i].set("v.endTime",updatedDay.endTime1);
                }
            }
        }
        
        
        var pmTemp = cmp.find("pmTime");
        //console.log(':::::pmTemp::::',pmTemp);
        if(pmTemp){
            for(var i = 0;i < pmTemp.length;i++){
                var day = pmTemp[i].get("v.dayRecord");
                
                //For New Entries
                var index1 = temp1[i].get("v.lineIndex");
                var index2 = temp1[i].get("v.dayIndex");
                
                if(updatedDay.dayId && day.dayId == updatedDay.dayId){
                    console.log('if PM time');
                    pmTemp[i].set("v.startTime",updatedDay.startTime2);
                    
                    var stTime = this.convertTime(cmp,updatedDay.startTime2);
                    pmTemp[i].set("v.endTimeList",this.endTimeCalculation(cmp,stTime,pmTemp[i].get("v.startTimeList")));
                    pmTemp[i].set("v.endTime",updatedDay.endTime2);
                }else if(lineIndex == index1 && dayIndex == index2){
                    pmTemp[i].set("v.startTime",updatedDay.startTime2);
                    
                    var stTime = this.convertTime(cmp,updatedDay.startTime2);
                    pmTemp[i].set("v.endTimeList",this.endTimeCalculation(cmp,stTime,pmTemp[i].get("v.startTimeList")));
                    pmTemp[i].set("v.endTime",updatedDay.endTime2);
                }
            }
        }
        
        var lateCmp = cmp.find("lateCancel");
        if(lateCmp){
            for(var i = 0;i < lateCmp.length;i++){
                var day = lateCmp[i].get("v.dayRecord");
                
                //For New Entries
                var index1 = temp1[i].get("v.lineIndex");
                var index2 = temp1[i].get("v.dayIndex");
                
                if(updatedDay.dayId && day.dayId == updatedDay.dayId){
                    console.log('if late cancellation');
                    lateCmp[i].set("v.dayRecord",updatedDay);
                }else if(lineIndex == index1 && dayIndex == index2){
                    lateCmp[i].set("v.dayRecord",updatedDay);
                }
            }
        }
        
    },
    endTimeCalculation :  function(cmp,stTime,startTimeList){
        var endTimeList = [];
        
        for(var k = 0; k < startTimeList.length; k++) {
            if(stTime < this.convertTime(cmp,startTimeList[k]) ||
               this.convertTime(cmp,startTimeList[k]) == 0) {
                endTimeList.push(startTimeList[k]);
            }
        }
        
        return endTimeList;
    },
    convertTime : function(cmp,hourString) {
        var split1 = [];
        if(hourString) {
            split1 = hourString.split(' ');
        }
        
        var split2 = [];
        var minutes = 0;
        if(split1.length == 2) {
            split2 = split1[0].split(':');
        } else {
            return 0;
        }
        if(split2.length != 2) {
            return 0;
        } else {
            if(split1[1] == 'AM') {
                minutes += parseInt(split2[0]) * 60;
                if(split2[0] == '12') {
                    minutes = 0;
                }
                minutes += parseInt(split2[1]);
            } else if(split1[1] == 'PM') {
                var offset = 12;
                if(split2[0] == '12') {
                    offset = 0;
                }
                minutes = (parseInt(split2[0]) + offset) * 60;
                minutes += parseInt(split2[1]);
            }
        }
        return minutes;
    },
    addValidationInTimeInputs : function(cmp,updatedDay,lineIndex,dayIndex){
        //Get current time value to compare with end time
        //W-001894
        var dt = new Date();
        var h =  dt.getHours(), m = dt.getMinutes();
        var currentTime = (h > 12) ? ('0'+ (h-12) + ':' + m +' PM') : ('0'+h+ ':' + m +' AM');
        
        var columnDt = new Date(updatedDay.dateVal);
        columnDt.setTime(columnDt.getTime() + columnDt.getTimezoneOffset() * 1000 * 60);
        
        var currentDt = new Date();
        
        //AM Time validation
        var temp1 = cmp.find("time");
        if(temp1){
            for(var i = 0;i < temp1.length;i++){
                var day = temp1[i].get("v.dayRecord");
                var index1 = temp1[i].get("v.lineIndex");
                var index2 = temp1[i].get("v.dayIndex");
                if(lineIndex == index1 && dayIndex == index2){
                    var stCmp = temp1[i].find("startTime");
                    var edCmp = temp1[i].find("endTime");
                    
                    var start2 = 0;
                    var end2 = 0;
                    
                    if(updatedDay.startTime2 && updatedDay.endTime2){
                        start2 = this.getMinutes(updatedDay.startTime2);
                        end2 = this.getMinutes(updatedDay.endTime2);
                    }
                    
                    var timeDifference = (end2 - start2)/60;
                    
                    //start time value check
                    if((updatedDay.dayHours && !temp1[i].get("v.startTime")) && (timeDifference < updatedDay.dayHours)){
                        $A.util.addClass(stCmp,"slds-has-error");                 
                    }else {
                        $A.util.removeClass(stCmp,"slds-has-error");          
                    }
                    
                    //end time value check
                    if((updatedDay.dayHours && !temp1[i].get("v.endTime")) && (timeDifference < updatedDay.dayHours)){
                        $A.util.addClass(edCmp,"slds-has-error");   
                    }else if(!updatedDay.dayHours || !temp1[i].get("v.endTime") || this.getMinutes(currentTime) >= this.getMinutes(temp1[i].get("v.endTime"))){
                        $A.util.removeClass(edCmp,"slds-has-error");   
                    }
                }
            }
        }
        
        //PM Time validation
        var pmTemp = cmp.find("pmTime");
        if(pmTemp){
            for(var i = 0;i < pmTemp.length;i++){
                var index1 = pmTemp[i].get("v.lineIndex");
                var index2 = pmTemp[i].get("v.dayIndex");
                if(lineIndex == index1 && dayIndex == index2){
                    var stCmp = pmTemp[i].find("startTime");
                    var edCmp = pmTemp[i].find("endTime");
                    
                    var start1 = 0;
                    var end1 = 0;
                    
                    if(updatedDay.startTime1 && updatedDay.endTime1){
                        start1 = this.getMinutes(updatedDay.startTime1);
                        end1 = this.getMinutes(updatedDay.endTime1);
                    }
                    
                    var timeDifference = (end1 - start1)/60;
                    
                    //start time value check
                    if((updatedDay.dayHours && !pmTemp[i].get("v.startTime")) && (timeDifference < updatedDay.dayHours)){
                        $A.util.addClass(stCmp,"slds-has-error"); 
                    }else {
                        $A.util.removeClass(stCmp,"slds-has-error");
                    }
                    
                    //end time value check
                    if((updatedDay.dayHours && !pmTemp[i].get("v.endTime")) && (timeDifference < updatedDay.dayHours)){
                        $A.util.addClass(edCmp,"slds-has-error");  
                    }else if(!updatedDay.dayHours || !pmTemp[i].get("v.endTime") 
                             || (this.getMinutes(currentTime) >= this.getMinutes(pmTemp[i].get("v.endTime")))){
                        $A.util.removeClass(edCmp,"slds-has-error");  
                    }
                }
            }
        }
    },
    
    getMinutes : function(time){
        if(time == undefined){
            return 0;
        }    
        var h = time.split(' ');
        var m = h[0].split(':');
        var t = [];
        if(m[1] != undefined){
            t[1] = m[1];
        } else {
            t[1] = 0;
        }
        if(h[1] == 'AM') {
            t[0] = m[0];
        } else if(h[1] == 'PM'){
            if(m[0] == '12'){
                t[0] = 12;
            } else {
                t[0] = parseInt(m[0]) + 12;
            }
        }
        return (parseInt(t[0]) * 60) + parseInt(t[1]);
    },
    dateComparison : function(currentDt,columnDt){
        if(currentDt.getFullYear() <= columnDt.getFullYear() && currentDt.getMonth() <= columnDt.getMonth() 
           && currentDt.getDate() <= columnDt.getDate()){
            return true;
        }else {
            return false;
        }
    },
    
    getClassScheduleDetails : function(cmp){
        var dt1 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[0]);
        var dt2 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[1]);
        
        var action = cmp.get("c.getProjectBasedSchedules");
        action.setParams({
            'projectId' : cmp.get("v.selectedProject"),
            'startDate' : dt1,
            'endDate' : dt2,
            'contactId' : cmp.get("v.contactId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                cmp.set("v.scheduleRecords",result);
            }else {
                cmp.set("v.successMsg",response.getError()[0].message);
                cmp.set("v.successTitle",'Error');
                //cmp.set("v.showSpinner",false);
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
    createCaseRecordMethod : function(cmp){
        console.log(':::::createCaseRecordMethod:::');
        var caseObj = {};
        caseObj.Type = 'Timesheet Edit Request';
        caseObj.Priority = 'High';
        caseObj.Origin = 'Web';
        caseObj.Environment__c = 'Instructor Community';
        
        var projectFilter = cmp.get("v.projectFilter");
        var dlsClassNo = '';
        for(var i = 0;i < projectFilter.length;i++){
            if(projectFilter[i].projectId == cmp.get("v.selectedProject")){
                dlsClassNo = projectFilter[i].projectName.split(' / ')[0];
                break;
            }
        }
        
        caseObj.Subject = 'User '+cmp.get("v.employeeName").split(' - ')[0]+' is requesting access to edit their timesheet for '+dlsClassNo+' for '+cmp.get("v.selectedWeek");
        caseObj.ContactId = cmp.get("v.contactId");
        
        if(cmp.get("v.reasonForEditLinkAccess")){
            caseObj.Description = cmp.get("v.reasonForEditLinkAccess");
        }
        
        var caseArray = [];
        caseArray.push(caseObj);
        console.log('::::::::caseArray::::',caseArray);
        
        var action = cmp.get("c.createCaseRecord");
        action.setParams({
            'caseJson' : JSON.stringify(caseArray)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                
                cmp.set("v.successTitle",'Success');
                cmp.set("v.successMsg",'Thank you for submitting your request. A staff member will contact you as soon as possible');
                cmp.set("v.showSpinner",false);
                cmp.set("v.displaySuccessModal",true);
                
                if(Array.isArray(cmp.find("successModal"))) {
                    cmp.find("successModal")[0].open();
                }else{
                    cmp.find("successModal").open();
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
    checkExistingTCDRecords : function(cmp){	//Method to check existing TCD for same date & time in other projects
        
        var dt1 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[0]);
        var dt2 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[1]);
        
        var action = cmp.get("c.getExistingTCDsForOtherProjects");
        action.setParams({
            'instructorId' : cmp.get("v.contactId"),
            'startDate' : dt1,
            'endDate' : dt2,
            'projectId' : cmp.get("v.selectedProject")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue());
                //console.log('::getExistingTCDsForOtherProjects:::result::::',result);
                cmp.set("v.existingTCDMap",result);
                var msg = this.validateCurrentEntryWithOld(cmp);
                //console.log(':::::::msg:::',msg);
                if(msg){
                    cmp.set("v.isValidInput",false);
                    this.displayValidationMsg(cmp,msg,'Warning');
                }else {
                    
                    if(cmp.get("v.actionType") == 'Complete' && !this.FindTimeEntryChanges(cmp,'From Validation')){
                        this.getScheduledEventsForThisWeek(cmp, event);                        
                    }else if(cmp.get("v.actionType") == 'Complete' && this.FindTimeEntryChanges(cmp,'From Validation')){	//Complete btn clicked & time entries are available
                        
                        console.log('enter else if');
                        var projectIdTimeCompleted = cmp.get("v.projectIdTimeCompleted");
                        
                        var allTimesAreCompleted = true;
                        for(var key in projectIdTimeCompleted){
                            if(key != cmp.get("v.selectedProject") && !projectIdTimeCompleted[key]){
                                allTimesAreCompleted = false;
                            }
                        }
                        console.log("allTimesAreCompleted:::::",allTimesAreCompleted);
                        
                        cmp.set("v.redirectToSubmitPage",allTimesAreCompleted);
                        this.displayValidationMsg(cmp,'','');
                    }else {
                        this.displayValidationMsg(cmp,'','');
                    }
                }
                
            }else {
                cmp.set("v.successMsg",response.getError()[0].message);
                cmp.set("v.successTitle",'Error');
                //cmp.set("v.showSpinner",false);
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
    validateCurrentEntryWithOld : function(cmp){
        
        var oldEntry = cmp.get("v.existingTCDMap");
        var dayRecords = cmp.get("v.dayRecords");
        var overLapMsg = '';
        
        //check for Language Training PT Conflicts
        for(var i = 0; i < dayRecords.length;i++){
            var entries = dayRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                if((entries[j].isNew && entries[j].dayHours) || (entries[j].isUpdated && entries[j].dayHours)){
                    
                    //For Language Training Time Comparison
                    if(dayRecords[i].taskType != 'Preparation time' && entries[j].startTime1 && entries[j].endTime1){
                        
                        var haveOverLap = false;
                        
                        if(oldEntry[entries[j].dateVal]){
                            var oldEntries = oldEntry[entries[j].dateVal];
                            //Iterate the old map list values
                            for(var k = 0;k < oldEntries.length;k++){
                                if(oldEntries[k].taskType != 'Preparation time'){
                                    let start1 = this.getMinutes(oldEntries[k].startTime1);
                                    let end1 = this.getMinutes(oldEntries[k].endTime1);
                                    
                                    let start2;
                                    let end2;
                                    if(entries[j].startTime1 && entries[j].endTime1){
                                        start2 = this.getMinutes(entries[j].startTime1);
                                        end2 = this.getMinutes(entries[j].endTime1);
                                    }
                                    
                                    let ST1,ET1,ST2,ET2;
                                    
                                    if((start1 && end1) && (start2 && end2)){
                                        if(start2 > start1){
                                            ST1 = start1;
                                            ET1 = end1;
                                            
                                            ST2 = start2;
                                            ET2 = end2;
                                        }else {
                                            ST1 = start2;
                                            ET1 = end2;
                                            
                                            ST2 = start1;
                                            ET2 = end1;
                                        }
                                        //console.log('::::swapped::times:1:',ST1,ET1,ST2,ET2);
                                        if(ET2 >= ST1 && ST2 < ET1){
                                            haveOverLap = true;
                                        }
                                    }
                                    
                                    if(haveOverLap){
                                        overLapMsg += '<ul style="list-style-type: initial;">The time entry you are attempting to save for <b>'+entries[j].displayDate+'</b> is in conflict with the following time entries: ';
                                        overLapMsg += '<li>'+oldEntries[k].projectName+' / '+oldEntries[k].studentNames+' / '+oldEntries[k].taskName+' / '+oldEntries[k].startTime1+' - '+oldEntries[k].endTime1+'</li>';
                                    }
                                }
                            }//end of old list 
                            
                            if(haveOverLap){
                                overLapMsg += '</ul>';
                            }
                        }
                    }else if(dayRecords[i].taskType == 'Preparation time' && ((entries[j].startTime1 && entries[j].endTime1) || (entries[j].startTime2 && entries[j].endTime2))){	//Preparation Hours comparision
                        let haveOverLap = false;
                        let time1OverLap = false;
                        let time2OverLap = false;
                        
                        if(oldEntry[entries[j].dateVal]){
                            var oldEntries = oldEntry[entries[j].dateVal];
                            //Iterate the old map list values
                            for(var k = 0;k < oldEntries.length;k++){
                                if(oldEntries[k].taskType == 'Preparation time'){
                                    
                                    let start1 = this.getMinutes(oldEntries[k].startTime1);
                                    let end1 = this.getMinutes(oldEntries[k].endTime1);
                                    let start2 = this.getMinutes(oldEntries[k].startTime2);
                                    let end2 = this.getMinutes(oldEntries[k].endTime2);
                                    
                                    let start3;
                                    let end3;
                                    if(entries[j].startTime1 && entries[j].endTime1){
                                        start3 = this.getMinutes(entries[j].startTime1);
                                        end3 = this.getMinutes(entries[j].endTime1);
                                    }
                                    
                                    let start4;
                                    let end4;
                                    if(entries[j].startTime2 && entries[j].endTime2){
                                        start4 = this.getMinutes(entries[j].startTime2);
                                        end4 = this.getMinutes(entries[j].endTime2);
                                    }
                                    
                                    let ST1,ET1,ST2,ET2;
                                    if((start1 && end1) && (start3 && end3)){
                                        if(start3 > start1){
                                            ST1 = start1;
                                            ET1 = end1;
                                            
                                            ST2 = start3;
                                            ET2 = end3;
                                        }else {
                                            ST1 = start3;
                                            ET1 = end3;
                                            
                                            ST2 = start1;
                                            ET2 = end1;
                                        }
                                        
                                        if(ET2 >= ST1 && ST2 < ET1){
                                            haveOverLap = true;
                                            time1OverLap = true;
                                        }
                                    }
                                    
                                    let ST3,ET3,ST4,ET4;
                                    if((start2 && end2) && (start4 && end4)){
                                        if(start3 > start2){
                                            ST3 = start2;
                                            ET3 = end2;
                                            
                                            ST4 = start4;
                                            ET4 = end4;
                                        }else {
                                            ST3 = start4;
                                            ET3 = end4;
                                            
                                            ST4 = start2;
                                            ET4 = end2;
                                        }
                                        //console.log('::::swapped::times:2:',ST1,ET1,ST2,ET2);
                                        if(ET4 >= ST3 && ST4 < ET3){
                                            haveOverLap = true;
                                            time2OverLap = true;
                                        }
                                    }
                                    
                                    if(haveOverLap){
                                        console.log('enter  msg formation');
                                        overLapMsg += '<ul style="list-style-type: initial;">The time entry you are attempting to save for <b>'+entries[j].displayDate+'</b> is in conflict with the following time entries: ';
                                        
                                        if(time1OverLap && time2OverLap){
                                            overLapMsg += '<li>'+oldEntries[k].projectName+' / '+oldEntries[k].studentNames+' / '+oldEntries[k].taskName+' / '+oldEntries[k].startTime1+' - '+oldEntries[k].endTime1+' / '+oldEntries[k].startTime2+' - '+oldEntries[k].endTime2+'</li>';
                                        }else if(time1OverLap){
                                            overLapMsg += '<li>'+oldEntries[k].projectName+' / '+oldEntries[k].studentNames+' / '+oldEntries[k].taskName+' / '+oldEntries[k].startTime1+' - '+oldEntries[k].endTime1+'</li>';
                                        }else if(time2OverLap){
                                            overLapMsg += '<li>'+oldEntries[k].projectName+' / '+oldEntries[k].studentNames+' / '+oldEntries[k].taskName+' / '+oldEntries[k].startTime2+' - '+oldEntries[k].endTime2+'</li>';
                                        }
                                    }
                                }
                                
                            }//end of old list 
                            
                            if(haveOverLap){
                                overLapMsg += '</ul>';
                            }
                        }
                    }
                    
                }
            }//end of inner for loop
        }//end of outer for loop
        
        return overLapMsg;
    },
    checkwithEventsDuration : function(cmp){
        console.log('checkwithEventsDuration');
        
        var dt1 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[0]);
        var dt2 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[1]);
        
        var dayRecords = cmp.get("v.dayRecords");
        
        var dayEntries = [];
        
        for(var i = 0;i < dayRecords.length;i++){
            if(dayRecords[i].taskType != 'Preparation time'){
                var entries = dayRecords[i].dayEntries;
                for(var j = 0;j < entries.length;j++){
                    var hrsExist = (entries[j].dayHours === 0 || entries[j].dayHours) ? true : false;
                    if((entries[j].isNew && hrsExist) || (entries[j].isUpdated && hrsExist)){
                        dayEntries.push(entries[j]);
                    }
                }
            }
        }
        
        var action = cmp.get("c.getProjectRelatedEvents");
        action.setParams({
            'projectId' : cmp.get("v.selectedProject"),
            'instructorId' : cmp.get("v.contactId"),
            'startDate' : dt1,
            'endDate' : dt2,
            'timeDayJson' : JSON.stringify(dayEntries)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var dateNotesRequiredFlagMap = JSON.parse(response.getReturnValue());
                
                console.log('::events:::compare::::',dateNotesRequiredFlagMap);
                if(Object.keys(dateNotesRequiredFlagMap).length > 0){
                    this.studentNotesRequiredMethod(cmp,dateNotesRequiredFlagMap);
                }else {
                    this.checkExistingTCDRecords(cmp);
                }
            }else {
                cmp.set("v.successMsg",response.getError()[0].message);
                cmp.set("v.successTitle",'Error');
                //cmp.set("v.showSpinner",false);
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
    studentNotesRequiredMethod : function(cmp,dateNotesRequiredFlagMap){
        
        var attendance = cmp.get("v.studentAttendanceList");
        
        var showMsg = false;
        
        for(var i = 0;i < attendance.length;i++){
            var entry = attendance[i].entries;
            for(var j = 0;j < entry.length;j++){
                
                var hrsExist = (entry[j].hours === 0 || entry[j].hours) ? true : false;
                if((entry[j].isNew && hrsExist) || (entry[j].isUpdated && hrsExist)){
                    
                    if(dateNotesRequiredFlagMap[entry[j].dateVal]){
                        var notesRequired = dateNotesRequiredFlagMap[entry[j].dateVal];
                        
                        if(notesRequired && !entry[j].comments){
                            entry[j].displayNotesLink = 'true';
                            entry[j].color = 'pink';
                            showMsg = true;
                            
                        }else if(notesRequired && entry[j].comments){
                            entry[j].color = null;
                        }
                    }else {
                        entry[j].color = null;
                    }
                }
            }
        }
        
        cmp.set("v.studentAttendanceList",attendance);
        
        if(showMsg){
            cmp.set("v.isValidInput",false);
            this.displayValidationMsg(cmp,'Please enter notes for each of the highlighted student time entries','Notes Required');
            return;
        }else {
            this.checkExistingTCDRecords(cmp);
        }
    },
    
    overAllValidation :  function(cmp){
        
        var projectData = cmp.get("v.projectFilter").filter(obj => {
            return obj.projectId === cmp.get("v.selectedProject");
        });
        
        //W-007882
        projectData['defaultCostRateRateType'] = cmp.get("v.defaultCostRateRateType");
        console.log('projectData::::',projectData);

        var dayRecords = cmp.get("v.dayRecords");
        var attendance = cmp.get("v.studentAttendanceList");
        var plannedOffMap = cmp.get("v.plannedDaysOffMap");
        var dliWLTHolidays = cmp.get("v.dliWLTHolidays");
        var federalHolidays = cmp.get("v.federalHolidays");

        var validationResult = overAllValidationMethod(dayRecords,attendance,projectData,plannedOffMap,dliWLTHolidays,federalHolidays);
        console.log(':::::::::validationResult:::::',validationResult);

        cmp.set("v.isValidInput",validationResult.isValidInput);

        if(validationResult.invalidPrepDay) {
            var invalidPrepDay = validationResult.invalidPrepDay;
            this.inputValidationAction(cmp, invalidPrepDay);
        }

        if(!validationResult.isValid){
            this.displayValidationMsg(cmp,validationResult.message,validationResult.title);
            return;
        }
        
        if(validationResult.isHasTimeInFederalHoliday){
            this.displayValidationMsg(cmp,validationResult.message,validationResult.title, validationResult.isHasTimeInFederalHoliday);
            return;
        }
        
        this.checkOtherValidations(cmp);
                              
    },
    
    checkOtherValidations: function(cmp){
        var projectData = cmp.get("v.projectFilter").filter(obj => {
            return obj.projectId === cmp.get("v.selectedProject");
        });
        //W-004359
        //If current project is DODA then check for the scheduled event hours
        if(projectData.length > 0 && projectData[0].projectRTName == 'DODA_Projects'){
            this.checkwithEventsDuration(cmp);
        }else {
            //Check if the instructor entered hours for other project on same date & time range
            //If yes we have to throw validation msg
            var existingTCDOverLapMsg = this.checkExistingTCDRecords(cmp);
        }  
    },
    
    checkOnlyHolidayEntriesPresent : function(cmp){
        var dayRecords = cmp.get("v.dayRecords");
        
        var dliWLTHolidays = cmp.get("v.dliWLTHolidays");         
        var projectData = cmp.get("v.projectFilter").filter(obj => {
            return obj.projectId === cmp.get("v.selectedProject");
        });
        var projectRTName = projectData.length > 0? projectData[0].projectRTName : '';
        
        var onlyHolidayEntryPresent = true;
        
        for(var i = 0;i < dayRecords.length;i++){
            var entries = dayRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                if(entries[i].taskType != 'Preparation time'){
                    var hrsExist = (entries[j].dayHours === 0 || entries[j].dayHours) ? true : false;
                    if((entries[j].isNew && hrsExist) || (entries[j].isUpdated && hrsExist)){
                        if(projectRTName == 'DLI_W_LT_Projects'){
                            
                            if(dliWLTHolidays.indexOf(entries[j].dateVal) == -1 
                               || (dliWLTHolidays.indexOf(entries[j].dateVal) != -1 && !entries[j].lateCancellation)){
                                onlyHolidayEntryPresent = false;
                            }
                        }
                    }
                }
            }
        }
        
        return onlyHolidayEntryPresent;
    },
    displayValidationMsg : function(cmp,msg,title, hasTimeInFederalHoliday){
        console.log(cmp.get("v.actionType"), msg, title);
        if(cmp.get("v.actionType") == 'Save'){
            
            if(!msg && !title){
                
                cmp.set("v.isValidInput",true);
                console.log(cmp.get("v.isvalueChanged"));
                if(cmp.get("v.isvalueChanged")){
                    
                    //Check the current project is CD then no need to submit for student approval
                    var projectData = cmp.get("v.projectFilter").filter(obj => {
                        return obj.projectId === cmp.get("v.selectedProject");
                    });
                    
                    var confirmMsg = '';
                    console.log(projectData[0].projectRTName, projectData[0].noStudentApproval);
                    //check only DLI-W LT holiday entry is entered/updated
                    var onlyHolidayEntryExist = this.checkOnlyHolidayEntriesPresent(cmp);
                    console.log(onlyHolidayEntryExist);
                    if(projectData && projectData[0].projectRTName != 'CD_Projects' && !projectData[0].noStudentApproval && !onlyHolidayEntryExist){
                        
                        var stuNames = cmp.get("v.studentNames");
                        if((projectData[0].projectRTName == 'DLI_W_LT_Projects' || projectData[0].projectRTName == 'DODA_Projects' 
                            || projectData[0].projectRTName == 'ESL_LT_Projects')
                           && stuNames.indexOf(';') != -1 && stuNames.split(';').length > 0){
                            
                            var studentLeader = cmp.get("v.projectStuLeaderMap")[projectData[0].projectId];
                            
                            confirmMsg = '<p>The Training Hours submitted will be sent to the student class leader: <b>'+studentLeader+'</b> for approval.</p>';
                            confirmMsg += '<p> The Student Hours will be sent to the following students for their approval: <b>'+cmp.get("v.studentNames")+'</b>.</p>';
                            confirmMsg += 'Do you want to proceed?';
                        }else {
                            confirmMsg = 'These hours will be submitted to your student: <b>'+cmp.get("v.studentNames")+'</b> for approval, do you want to proceed?';
                        }                        
                    }else if(projectData && (projectData[0].projectRTName == 'CD_Projects' || projectData[0].noStudentApproval) || onlyHolidayEntryExist){
                        confirmMsg = 'Would you like to save the changes?';
                    }
                    console.log(confirmMsg);
                    cmp.set("v.ConfirmMsg",confirmMsg);
                    cmp.set("v.groupActionTitle",'Confirmation');
                }else {
                    cmp.set("v.ConfirmMsg",'There is no hours to save.');
                    cmp.set("v.isValidInput",false);
                    cmp.set("v.groupActionTitle",'Warning');
                }
                
            }else if(msg && title){
                
                cmp.set("v.ConfirmMsg",msg);
                cmp.set("v.groupActionTitle",title);
                if(title == 'Warning' && msg.includes('conflicts with a planned day off for the same date')){
                    cmp.set("v.isValidInput",false);
                }
            }
            
            console.log(cmp.get('v.hasTimeInFederalHoliday'));
            if(cmp.get('v.hasTimeInFederalHoliday')){
                cmp.set('v.hasTimeInFederalHoliday', false);
            }else{
                if(hasTimeInFederalHoliday){
                    cmp.set('v.hasTimeInFederalHoliday', true);
                }
                cmp.set("v.showSaveConfirmation",true);
                if(Array.isArray(cmp.find("confirmationModal"))) {
                    cmp.find("confirmationModal")[0].open();
                }else{
                    cmp.find("confirmationModal").open();
                }
            }
            
        }else if(cmp.get("v.actionType") == 'Complete'){
            
            if(msg && title){
                cmp.set("v.groupActionMsg",msg);
                cmp.set("v.groupActionTitle",title);
                
            }else if(!msg && !title){
                
                cmp.set("v.isValidInput",true);
                if(!cmp.get("v.redirectToSubmitPage") && this.FindTimeEntryChanges(cmp,'From Validation')){
                    
                    cmp.set("v.groupActionTitle","Confirmation");
                    cmp.set("v.groupActionMsg",'Would you like to Complete this Timesheet?');
                    
                }else if(cmp.get("v.redirectToSubmitPage") && this.FindTimeEntryChanges(cmp,'From Validation')){
                    
                    cmp.set("v.groupActionTitle","Confirmation");
                    cmp.set("v.groupActionMsg",'Timesheets have been completed for all scheduled projects for this week, would you like to proceed to Review & Submit all your time for the week?');
                    
                }else if(!this.FindTimeEntryChanges(cmp,'From Validation')){
                    
                    cmp.set("v.isValidInput",false);
                    cmp.set("v.groupActionMsg",'There is no hours to complete.');
                    cmp.set("v.groupActionTitle",'Warning');
                }
            }
            
            cmp.set("v.showGroupActionModal",true);
            if(Array.isArray(cmp.find("groupActionModal"))) {
                cmp.find("groupActionModal")[0].open();
            }else{
                cmp.find("groupActionModal").open();
            }
        }
    },    
    disablePrepTimeRows : function(cmp,updatedDay,lineIndex,dayIndex){
        console.log('::::::disablePrepTimeRows::::::::',lineIndex,dayIndex);
        var dayRecords = cmp.get("v.dayRecords");
        
        for(var i = 0;i < dayRecords.length;i++){
            if(dayRecords[i].taskType == 'Preparation time' && i != lineIndex){
                var entries = dayRecords[i].dayEntries;
                if(updatedDay.lateCancellation && cmp.get("v.projectRTName") == 'DLI_W_LT_Projects'){ 
                    //Commented By Dhinesh - 15/09/2022 - W-007562 - To disable prep time only for DLI W LT Projects
                   //&& cmp.get("v.projectRTName") != 'DODA_Projects'  && cmp.get("v.projectRTName") != 'ESL_LT_Projects'){ 
                    
                    entries[dayIndex].dayHours = null;
                    entries[dayIndex].startTime1 = '--None--';
                    entries[dayIndex].endTime1 = '--None--';
                    entries[dayIndex].startTime2 = '--None--';
                    entries[dayIndex].endTime2 = '--None--';
                    entries[dayIndex].isHrsDisabled = true;
                }else {
                    entries[dayIndex].isHrsDisabled = false;
                }
                
            }
        }
        
        cmp.set("v.dayRecords",dayRecords);
    },
    completeWholeWeekTime : function(cmp){
        var rowRecords = cmp.get("v.dayRecords");
        var dayList = [];
        
        for(var i = 0;i < rowRecords.length;i++){
            var entries = rowRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                if(entries[j].dayId && (entries[j].dayHours == 0 || entries[j].dayHours)){
                    dayList.push(entries[j]);
                }
            }
        }
        console.log(':::::complete::days::::::::::',dayList);
        
        var action = cmp.get("c.completeTCDEntries");
        action.setParams({
            "timeDayJson" : JSON.stringify(dayList)
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log('::::::result::complete:::',response.getReturnValue());   
                cmp.set("v.showSpinner",false);
                cmp.set("v.successMsg",'Time entries are completed successfully');
                cmp.set("v.successTitle",'Success');
                cmp.set("v.displaySuccessModal",true);
                
                if(Array.isArray(cmp.find("successModal"))) {
                    cmp.find("successModal")[0].open();
                }else{
                    cmp.find("successModal").open();
                }
            }else{
                console.log(':::::complete::::erro::::::',response.getError()[0].message);
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
    getScheduledEventsForThisWeek : function(cmp, event){	//For Complete Action validation if they click without any entry in table
        
        var dt1 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[0]);
        var dt2 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[1]);
        
        var action = cmp.get("c.getScheduledEvents");
        action.setParams({
            "startDt" : dt1,
            "endDt" : dt2,
            "projectId" : cmp.get("v.selectedProject"),
            "contactId" : cmp.get("v.contactId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                //console.log('::::::result::getScheduledEventsForThisWeek:::',response.getReturnValue());
                var result = response.getReturnValue();
                if(result){
                    var msg = 'No time has been entered for the following days, but events are scheduled for those days.  Are you sure the timesheet is complete?';
                    msg += result;
                    cmp.set("v.isValidInput",false);
                    this.displayValidationMsg(cmp,msg,'Warning');
                }else {
                    this.displayValidationMsg(cmp,'','');
                }
                
                cmp.set("v.showSpinner",false);
            }else{
                console.log(':::::complete::::erro::::::',response.getError()[0].message);
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
    //Added by Mohana
    clearTableValues : function(cmp, event) {
        cmp.set("v.headerList",[]);
        cmp.set("v.dayRecords",[]);
        cmp.set("v.notesList",[]);
    },
    redirectToStaffTimeEntry : function(cmp){
        
        var dt1 = (cmp.get("v.selectedWeek").split(' to ')[0]).split('/').join('-');
        var dt2 = (cmp.get("v.selectedWeek").split(' to ')[1]).split('/').join('-');
        var week = dt1+' to '+dt2;
        
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/DLS_Staff_Time_Entry_Page?WeekRange="+week
        });
        urlEvent.fire();
    },

    inputValidationAction : function(cmp, invalidPrepDays) {
        
        var findcomp = cmp.find('prepRow');
        for(let invalidPrepDay of invalidPrepDays){
            let index = invalidPrepDay.dayIndex+(invalidPrepDay.lineIndex*7);
            findcomp[index].prepHrsInputValidation(invalidPrepDay.PrepDay);
        }
    }
    
})