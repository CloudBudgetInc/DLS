({
	getFilterInformation : function(cmp) {
        var self = this;
		const server = cmp.find('server');
        const action = cmp.get('c.getInitialFilterValues');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                //console.log('response::::getInitialFilterValues:::::',response);
                var result = JSON.parse(response);
                //console.log(':::::do::init::;',result);
                cmp.set("v.weekList",result.weekFilter);
                cmp.set("v.contactId",result.contactId);
                cmp.set("v.employeeName",result.employeeName);
                cmp.set("v.timeList",result.timeList);
                cmp.set("v.topicId",result.timekeepingTopicId);
                cmp.set("v.attendancePickList", result.attendancePickList);
                
                var time = result.timeList;
                if(time && time.length > 0){
                    if(time.includes('12:00 AM')){
                        time.unshift(time.pop());
                    }
                    cmp.set("v.timeList",time);
                }
                
                var pmList = [];
                var amList = [];
                var timeList = []; 
                
                for(var i = 0;i < time.length;i++){
                    var timeObj = {'label':time[i],'value':time[i],'temp':self.convertTime(cmp,time[i])};
                    
                    timeList.push(timeObj);
                    if(time.includes('AM')){
                        amList.push(timeObj);
                        
                    }else if(time.includes('PM')){
                        pmList.push(timeObj);
                    }
                }
                
                cmp.set("v.timeList",timeList);
                cmp.set("v.pmTimeList",pmList);
                cmp.set("v.amTimeList",amList);
                window.setTimeout(
                    $A.getCallback(function() {
                        cmp.set("v.selectedWeek",result.selectedWeek);
                        //cmp.set("v.showSpinner",false);
                        self.getProjectFilterDetails(cmp);
                    }),100);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp',errors[0].message);
                self.errorMsgDisplay(cmp,errors[0].message);
            }),
            false, 
            false,
            false
        );
	},
    convertTime : function(cmp,hourString) {
        var split1 = [];
        if(hourString != '') {
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
    dateFormatFunction : function(dateVal){
        return dateVal.split('-')[1]+'/'+dateVal.split('-')[2]+'/'+dateVal.split('-')[0];
    },
    apexDateFormatFunction : function(dateval){
        return dateval.split('/')[2]+'-'+dateval.split('/')[0]+'-'+dateval.split('/')[1];
    },
    getProjectFilterDetails : function(cmp){
        var dt1 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[0]);
        var dt2 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[1]);
        
        var self = this;
		const server = cmp.find('server');
        const action = cmp.get('c.getProjectFilterValues');
        
        var param = {};
        param.startDate = dt1;
        param.endDate = dt2;
        param.contactId = cmp.get("v.contactId");
        
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                //console.log(':::pro::filter:::::::',result);
                let projects = cmp.get("v.projectFilter");
                projects = result.projectFilter;
                
                cmp.set("v.projectFilter",projects);
                cmp.set("v.projectSupervisorMap",result.proIdSupervisorName);
                cmp.set("v.projectIdTimeCompleted",result.projectIdTimeCompleted);
                cmp.set("v.projectStuLeaderMap",result.proIdStuLeaderName);
                
                //check if the urlParams obj have values then load that week
                window.setTimeout(
                    $A.getCallback(function() {
                        var urlParam = cmp.get("v.urlParams");
                        if(Object.keys(urlParam).length > 0 && cmp.get("v.initialLoad")){
                            cmp.set("v.selectedWeek",urlParam.weekRange);
                            cmp.set("v.selectedProject",urlParam.projectId);
                            
                            //To fix the duplicate TCL creation on filter changes with table value changes
                            //cmp.set("v.oldSelectedWeek",urlParam.weekRange);
                            //cmp.set("v.oldSelectedProject",urlParam.projectId);
                            
                            var manager = cmp.get("v.projectSupervisorMap")[cmp.get("v.selectedProject")];
                            cmp.set("v.projectManager",manager);
                            self.getTimeRowsFormation(cmp);
                            
                            //Call schedule details query method
                            self.getClassScheduleDetails(cmp);
                        }
                        
                    }),1000);
                
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp',errors[0].message);
                self.errorMsgDisplay(cmp,errors[0].message);
            }),
            false, 
            false,
            false
        );
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
        
        var self = this;
		
        var param = {};
        param.stDate = dt1;
        param.endDate = dt2;
        param.projectId = cmp.get("v.selectedProject");
        param.contactId = cmp.get("v.contactId");
        param.projectName = projectName;
        param.studentNames = studentNames;
        
        const server = cmp.find('server');
        const action = cmp.get('c.getTimeRowsRelatedInformation');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                console.log(':::::::getTimeRowsRelatedInformation::::::::result:::',result);
                cmp.set("v.summaryList",result.summary);
                cmp.set("v.dliWLTHolidays",result.dliWLTHolidays);
                cmp.set('v.federalHolidays', result.federalHolidays);
                cmp.set("v.showAllButtons",result.displaySubmitBtn);
                cmp.set("v.showRecallBtn",result.displayRecallBtn);
                cmp.set("v.showCompleteBtn",result.displayCompleteBtn);
                cmp.set("v.displayRequestEditLink",result.displayRequestEditLink);
                cmp.set("v.alreadyCaseSubmitted",result.alreadyCaseSubmitted);
                cmp.set("v.validCRExistINCA",result.validCRExistINCA);
                cmp.set("v.overAllHrs",result.totalHrs);
                cmp.set("v.studentAllHrs",result.studentTotal);
                cmp.set("v.showStudentHrsColm",result.displayStudentHrs);
                cmp.set("v.plannedDaysOffMap",result.dateDaysOffValues);
                cmp.set("v.defaultCostRateRateType",result.defaultCostRateRateType);
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp',errors[0].message);
                self.errorMsgDisplay(cmp,errors[0].message);
            }),
            false, 
            false,
            false
        );
        
    },
    getClassScheduleDetails : function(cmp){
        var dt1 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[0]);
        var dt2 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[1]);
        
        var self = this;
        
        var param = {};
        param.projectId = cmp.get("v.selectedProject");
        param.startDate = dt1;
        param.endDate = dt2;
        param.contactId = cmp.get("v.contactId");
        
        const server = cmp.find('server');
        const action = cmp.get('c.getProjectBasedSchedules');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                var result = response;
                cmp.set("v.scheduleRecords",result);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp',errors[0].message);
                self.errorMsgDisplay(cmp,errors[0].message);
            }),
            false, 
            false,
            false
        );
    },
    clearValues : function(cmp){
        cmp.set("v.summaryList",[]);
        cmp.set("v.wholeNotes",[]);
        //cmp.set("v.projectFilter",[]);
        //cmp.set("v.selectedProject","");
        cmp.set("v.showCompleteBtn",false);
        cmp.set("v.showRecallBtn",false);
        cmp.set("v.displayRequestEditLink",false);
    },
    destoryChild : function(cmp) {
        cmp.set("v.showDetail",false);
        cmp.set("v.showSpinner",true);
        this.getTimeRowsFormation(cmp);
    },
    checkTimeEntriesExist : function(cmp){
        console.log('enter check time entries exist');
        var summary = cmp.get("v.summaryList");
        var isEntryExist = false;
        
        for(var i = 0; i < summary.length;i++){
            var entries = summary[i].dayEntries;
            for(var j = 0;j < entries.length; j++){
                let hrsEntered = (entries[j].dayHours === 0 || entries[j].dayHours) ? true : false;
                if((entries[j].isNew && hrsEntered) 
                   || (entries[j].isUpdated && hrsEntered) 
                   || (entries[j].dayId && hrsEntered)){
                    isEntryExist = true;
                }
            }
        }
        //console.log('::::isEntryExist:::',isEntryExist);
        return isEntryExist;
    },
    getScheduledEventsForThisWeek : function(cmp, event){	//For Complete Action validation if they click without any entry in table
        
        var dt1 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[0]);
        var dt2 = this.apexDateFormatFunction(cmp.get("v.selectedWeek").split(' to ')[1]);
        
        var self = this;
		
        var param = {};
        param.startDt = dt1;
        param.endDt = dt2;
        param.projectId = cmp.get("v.selectedProject");
        param.contactId = cmp.get("v.contactId");
        
        const server = cmp.find('server');
        const action = cmp.get('c.getScheduledEvents');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                var result = response;
                if(result){
                    var msg = 'No time has been entered for the following days, but events are scheduled for those days.  Are you sure the timesheet is complete?<br/><br/>';
                	msg += result;
                    self.displayCompleteValidationMsg(cmp,'Warning',msg);
                }else {
                    self.displayCompleteValidationMsg(cmp,'','');
                }
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp',errors[0].message);
                self.errorMsgDisplay(cmp,errors[0].message);
            }),
            false, 
            false,
            false
        );
    },
    displayCompleteValidationMsg :  function(cmp, title, msg){
        if(msg && title){
            if(this.checkTimeEntriesExist(cmp)){
            	cmp.set("v.isValidEntryExist",true);
                cmp.set("v.groupActionMsg",msg);
                cmp.set("v.groupActionTitle",title);    
            }else {
                cmp.set("v.isValidEntryExist",false);
                cmp.set("v.groupActionMsg",'There is no hours to complete.');
                cmp.set("v.groupActionTitle",'Warning');
            }
            
        }else if(!msg && !title){
            cmp.set("v.isValidEntryExist",true);
            
            if(!cmp.get("v.redirectToSubmitPage") && this.checkTimeEntriesExist(cmp)){
                
                cmp.set("v.groupActionTitle","Confirmation");
                cmp.set("v.groupActionMsg",'Would you like to Complete this Timesheet?');
                
            }else if(cmp.get("v.redirectToSubmitPage") && this.checkTimeEntriesExist(cmp)){
                
                cmp.set("v.groupActionTitle","Confirmation");
                cmp.set("v.groupActionMsg",'Timesheets have been completed for all scheduled projects for this week, would you like to proceed to Review & Submit all your time for the week?');
            
            }else if(!this.checkTimeEntriesExist(cmp)){
                
                cmp.set("v.isValidEntryExist",false);
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
    },
    completeTCDEntries : function(cmp){
        var self = this;
        var summary = cmp.get("v.summaryList");
        var dayList = [];
        
        for(var i = 0;i < summary.length;i++){
            var entries = summary[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                if(entries[j].dayId && (entries[j].dayHours == 0 || entries[j].dayHours)){
                    dayList.push(entries[j]);
                }
            }
        }
        //console.log(':::::complete::days::::::::::',dayList);
        
        var param = {};
        param.timeDayJson = JSON.stringify(dayList);
        
        const server = cmp.find('server');
        const action = cmp.get('c.completeTimeCardDayEnties');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                var result = response
                //console.log('::::::result::complete:::',result);   
                cmp.set("v.showSpinner",false);
                cmp.set("v.successMsg",'Time entries are completed successfully');
                cmp.set("v.successTitle",'Success');
                cmp.set("v.displaySuccessModal",true);
                
                if(Array.isArray(cmp.find("successModal"))) {
                    cmp.find("successModal")[0].open();
                }else{
                    cmp.find("successModal").open();
                }
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp',errors[0].message);
                self.errorMsgDisplay(cmp,errors[0].message);
            }),
            false, 
            false,
            false
        );
    },
    errorMsgDisplay :  function(cmp, msg){
        cmp.set("v.successMsg",msg);
        cmp.set("v.successTitle",'Error');
        cmp.set("v.showSpinner",false);
        cmp.set("v.displaySuccessModal",true);
        
        if(Array.isArray(cmp.find("successModal"))) {
            cmp.find("successModal")[0].open();
        }else{
            cmp.find("successModal").open();
        }
    },
    recallActionFunction : function(cmp){
        var daysForRecall = [];
        
        var summary = cmp.get("v.summaryList");
        for(var i = 0;i < summary.length;i++){
            var entries = summary[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                if(entries[j].dayId && (entries[j].dayHours == 0 || entries[j].dayHours)){
                    daysForRecall.push(entries[j]);
                }
            }
        }
        
        console.log(':::::daysForRecall::::',daysForRecall);
        let param = {};
        param.timeDayJson = JSON.stringify(daysForRecall);
        param.typeOfAction = 'Group';
        
        const server = cmp.find('server');
        const action = cmp.get('c.recallTimeEntries');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                var result = response;
                console.log('::::::result::recall:::',result);   
                cmp.set("v.showSpinner",false);
                cmp.set("v.successMsg",'Time entries are recalled successfully.');
                cmp.set("v.successTitle",'Success');
                cmp.set("v.displaySuccessModal",true);
                
                if(Array.isArray(cmp.find("successModal"))) {
                    cmp.find("successModal")[0].open();
                }else{
                    cmp.find("successModal").open();
                }
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp',errors[0].message);
                self.errorMsgDisplay(cmp,errors[0].message);
            }),
            false, 
            false,
            false
        );
    },
    createCaseRecordMethod : function(cmp){
        var caseObj = {};
        caseObj.Type = 'Timesheet Edit Request';
        caseObj.Priority = 'High';
        caseObj.Origin = 'Web';
        
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
        
        var param = {};
        param.caseJson = JSON.stringify(caseArray);
        
        const server = cmp.find('server');
        const action = cmp.get('c.createCaseRecord');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                cmp.set("v.successTitle",'Success');
                cmp.set("v.successMsg",'Thank you for submitting your request. A staff member will contact you as soon as possible');
                cmp.set("v.showSpinner",false);
                cmp.set("v.displaySuccessModal",true);
                
                if(Array.isArray(cmp.find("successModal"))) {
                    cmp.find("successModal")[0].open();
                }else{
                    cmp.find("successModal").open();
                }
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp',errors[0].message);
                self.errorMsgDisplay(cmp,errors[0].message);
            }),
            false, 
            false,
            false
        );
    }
})