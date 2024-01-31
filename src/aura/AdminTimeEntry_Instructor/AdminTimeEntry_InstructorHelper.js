({
	getInitialValues : function(cmp,event) {
		var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getInitialFilterValues');
        server.callServer(
            action, 
            {}, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
                console.log('result:::::::',result);  
                
                cmp.set("v.weekRangeValues",result.weekRangeValues);
                result.contactStatusValues.unshift('All');
                cmp.set("v.contactStatusValues",result.contactStatusValues);
				cmp.set("v.studentStatusValues",result.studentStatusValues);                
                cmp.set("v.payrollItemValues",result.payRollItemList);
                cmp.set("v.contactIdNameMap", result.contactIdNameMap);
                cmp.set("v.userHaspermission", result.userHaspermission);
                cmp.set("v.userReadOnlyMode", result.readOnlyMode);

                cmp.set("v.attendancePickListValues", result.attendancePickListValues);
                
                window.setTimeout(
                    $A.getCallback(function() {
                        
                        var lastIndex = result.weekRangeValues.length;
                        console.log(':::::::week:::::',result.weekRangeValues[lastIndex - 3]);
                        cmp.set("v.selectedContactStatus",'All');
                        cmp.set("v.selectedWeek",result.weekRangeValues[lastIndex - 3]);
                        cmp.set("v.selectedContact",result.contactRecords[0]);
                        
                        cmp.set("v.oldSelectedContact",result.contactRecords[0]);
                        cmp.set("v.oldSelectedWeek",result.weekRangeValues[lastIndex - 3]);
                        
                        //self.getProjectFilterInfo(cmp,event);
                        
                    }),100);
                
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
	},
    showToast : function(cmp,event,title,message,type){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            type: type,
            mode: 'sticky'
        });
        toastEvent.fire();
    },
    apexDateFormatFunction : function(dateval){
        return dateval.split('/')[2]+'-'+dateval.split('/')[0]+'-'+dateval.split('/')[1];
    },
    getProjectFilterInfo : function(cmp, event){
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getProjectFilterDetail');
        
        var dt1 = cmp.get("v.selectedWeek").split(' to ')[0];
        var dt2 = cmp.get("v.selectedWeek").split(' to ')[1];
        
        var contactId;
        
        if(cmp.get("v.selectedContact").length > 0){
            contactId = cmp.get("v.selectedContact")[0].Id;
        }else {
            contactId = null;
        }
        
        console.log('::::pro:::params:::',dt1,dt2,contactId);
        
        var param = {};
        param.startDate = dt1;
        param.endDate = dt2;
        param.contactId = contactId;
        
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
                console.log('result::project::filter:::',result);  
                
                result.unshift({projectId:'--None--',projectName: '--None--'});
				cmp.set("v.projectRecords",result);
	               
                var self = this;
                window.setTimeout(
                    $A.getCallback(function() {
                        if(result.length > 0) {
                        	cmp.set("v.selectedProject",result[0].projectId);
                        }
                    }),100);
                
                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
    },
    validateContact : function(cmp,event){
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getContactRelatedUser');

        var contactId;
        if(cmp.get("v.selectedContact").length > 0){
            contactId = cmp.get("v.selectedContact")[0].Id;
        }else {
            contactId = null;
        }
        
        var param = {};
        param.contactId = contactId;
        
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                var userExist = response;
                console.log(':::::userExist:::',userExist);
                console.log(':::initialLoad:::',cmp.get("v.initialLoad"));
                if(!userExist && !cmp.get("v.initialLoad")){
                    self.showToast(cmp,event,'Error','No user found for selected contact. Please create user with same Contact Name to proceed further.','error');
                }else {
                    //call filterChange
                    //cmp.set("v.showSpinner",true);
                    console.log('::::::values::::',cmp.get("v.selectedWeek"),cmp.get("v.weekChanged"),cmp.get("v.initialLoad"));
                    if(cmp.get("v.selectedWeek") && (cmp.get("v.isContactChanged") || cmp.get("v.weekChanged") || cmp.get("v.initialLoad"))){
                        cmp.set("v.projectRecords",[]);
                        self.getProjectFilterInfo(cmp,event);
                    }else if(cmp.get("v.selectedWeek") && cmp.get("v.selectedProject") != '--None--'){
                        self.getTCDInformation(cmp,event);
                    }
                }
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
    },
    getTCDInformation : function(cmp,event){
        var self = this;
        
        var dt1 = cmp.get("v.selectedWeek").split(' to ')[0];
        var dt2 = cmp.get("v.selectedWeek").split(' to ')[1];
        
        var projectData = cmp.get("v.projectRecords").filter(obj => {
            return obj.projectId === cmp.get("v.selectedProject");
        });
        console.log('To Check start'); //Added by Mohana
        if(projectData && projectData.length > 0){
            var projectName = projectData[0].projectName.split(' / ')[0];
            var studentNames = projectData[0].projectName.split(' / ')[2];
            
            var contactId = cmp.get("v.selectedContact").length > 0 ? cmp.get("v.selectedContact")[0].Id : null;
             console.log('To Check end'); //Added by Mohana
            var param = {};
            param.stDate = dt1;
            param.endDate = dt2;
            param.projectId = cmp.get("v.selectedProject");
            param.contactId = contactId;
            param.studentNames = studentNames;
            
            const server = cmp.find('server');
            const action = cmp.get('c.getSpecificWeekTCDDetials');
            server.callServer(
                action, 
                param, 
                false, 
                $A.getCallback(function(response) { 
                    var result = JSON.parse(response);
                    console.log('result::day:::::',result);  
                    cmp.set("v.defaultCostRateRateType",result.rowDetails.defaultCostRateRateType);
                    cmp.set("v.timeList",result.timeList);
                    var time = result.timeList;
                    var pmList = [];
                    var amList = [];
                    var index = time.indexOf('12:00 PM');                
                    for(var i = index;i < time.length;i++){
                        pmList.push(time[i]);
                    }
                    
                    for(var i = 0;i <= index;i++){
                        amList.push(time[i]);
                    }
                    
                    cmp.set("v.pmTimeList",pmList);
                    cmp.set("v.amTimeList",amList);
                    
                    window.setTimeout(
                        $A.getCallback(function() {
                            var timeDetails = result.rowDetails;
                            cmp.set("v.headerList", timeDetails.weekDates);
                            var dayRecords = cmp.get("v.dayRecords");
                            dayRecords = timeDetails.entries;
                            cmp.set("v.dayRecords", dayRecords);
                            cmp.set("v.notesList",timeDetails.notes);
                            cmp.set("v.studentAttendanceList",timeDetails.studentEntries);
                            cmp.set("v.plannedDaysOffMap",timeDetails.dateDaysOffValues);
                            cmp.set("v.taskIdCAIdMap",result.taskIdCAIdMap);
                            cmp.set("v.taskIdCostRateMap",result.taskIdCostRateMap);
                            cmp.set("v.taskRecords",result.taskRecords);
                            cmp.set("v.uniqueKeySet",result.uniqueKeySet);
                            cmp.set("v.isOlderWeek",result.isWeekIs3weeksOlder);
                            cmp.set("v.totalHrs",result.totalHours);
                            cmp.set("v.timeCardId", result.timeCardId);
                            cmp.set("v.dliWLTHolidays", timeDetails.dliWLTHolidays);
                            cmp.set("v.federalHolidays", timeDetails.federalHolidays);
                            
                            if(timeDetails.entries.length > 0){
                                self.calculateTotalHours(cmp);
                            }
                            cmp.set("v.showSpinner",false);
                        }),100);
                }),
                $A.getCallback(function(errors) { 
                    console.log('error',errors)
                    self.showToast(cmp,event,'Error',errors[0].message,'error');
                }),
                false, 
                false, 
                false 
            );
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
    populateUpdatedValuesInTable : function(cmp,updatedDay,lineIndex,dayIndex){
        
        console.log(':lineIndex::::dayIndex::',lineIndex,dayIndex);
        
        var temp1 = cmp.find("time");
        console.log(':::::temp1::::',temp1);
        if(temp1){
            for(var i = 0;i < temp1.length;i++){
                var day = temp1[i].get("v.dayRecord");
                
                //For New Entries
                var index1 = temp1[i].get("v.lineIndex");
                var index2 = temp1[i].get("v.dayIndex");
                
                //console.log(':::::updatedDay.dayId:::::',updatedDay.dayId);
                //console.log(':::::day.dayId:::::',day.dayId);
                
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
        console.log(':::::pmTemp::::',pmTemp);
        if(pmTemp){
            for(var i = 0;i < pmTemp.length;i++){
                var day = pmTemp[i].get("v.dayRecord");
                
                //For New Entries
                var index1 = pmTemp[i].get("v.lineIndex");
                var index2 = pmTemp[i].get("v.dayIndex");
                
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
    addValidationInTimeInputs : function(cmp,updatedDay,lineIndex,dayIndex){
        console.log('::::::addValidationInTimeInputs:::');
        //Get current time value to compare with end time
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
    disablePrepTimeRows : function(cmp,updatedDay,lineIndex,dayIndex){
        console.log('::::::disablePrepTimeRows::::::::',lineIndex,dayIndex);
        var dayRecords = cmp.get("v.dayRecords");
        
        for(var i = 0;i < dayRecords.length;i++){
            if(dayRecords[i].taskType == 'Preparation time' && i != lineIndex){
                var entries = dayRecords[i].dayEntries;
                if(updatedDay.lateCancellation && cmp.get("v.projectRTName") != 'DODA_Projects'
                  	&& cmp.get("v.projectRTName") != 'DLI_W_LT_Projects' && cmp.get("v.projectRTName") != 'ESL_LT_Projects'){
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
    calculateStudentTotalHrs : function(cmp){
        var overAllHrs = 0.00;
        
        var studentRows = cmp.get("v.studentAttendanceList");
        
        for(var i = 0;i < studentRows.length;i++){
            var entry = studentRows[i].entries;
            var rowTotal = 0.00;
            
            for(var j = 0;j < entry.length;j++){
                if(entry[j].hours || entry[j].hours === 0){
                    rowTotal += parseInt(entry[j].hours);
                }
            }
            studentRows[i].totalHours = ((rowTotal * 100) / 100).toFixed(2).toString();
            
            overAllHrs += rowTotal;
        }
        
        overAllHrs =  ((overAllHrs * 100) / 100).toFixed(2);
        cmp.set("v.studentOverAllSum",overAllHrs);
        
        cmp.set("v.studentAttendanceList",studentRows);
    },
    //Method to check the hrs missmatch on day Hrs & student hours changes
    checkForStudenHoursMissMatch : function(cmp,oldHrsValue,updatedDay,rowIndex,columnIndex){
        console.log('enter student miss match');
        var attendance = cmp.get("v.studentAttendanceList");
        
        var projectData = cmp.get("v.projectRecords").filter(obj => {
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
                             && (entry[j].hours != oldHrsValue || entry[j].hours == 0) && !entry[j].comments
                            && projectData.length > 0 && !projectData[0].noStudentHrsVerification){
                        entry[j].displayNotesLink = 'true';
                    }
                }
            }
        }else if(rowIndex != -1 && columnIndex != -1){	//if the student time is entered check for the day record hourd & add the notes link if there is miss match
            console.log('2',rowIndex,columnIndex);
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
                               || columnData.hours == 0 || entries[j].dayHours == 0)
                          && projectData.length > 0 && !projectData[0].noStudentHrsVerification){
                            
                            columnData.displayNotesLink = 'true';
                            
                        }else if(entries[j].dateVal == columnData.dateVal 
                                 && entries[j].dayHours 
                                 && (entries[j].dayHours == columnData.hours || !columnData.hours)){
                            
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
    convertTime : function(cmp,hourString) {
        var split1 = [];
        if(hourString && hourString != '') {
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
    formNewRowContents : function(cmp, event){
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.newRowDetailFormation');
        
        var dt1 = cmp.get("v.selectedWeek").split(' to ')[0];
        var dt2 = cmp.get("v.selectedWeek").split(' to ')[1];
        
        var obj = {};
		obj = cmp.get("v.newDayObj");    
        obj.contactId = cmp.get("v.selectedContact").length > 0 ? cmp.get("v.selectedContact")[0].Id : null;
        obj.startDate = dt1;
        obj.endDate = dt2;
        obj.locationId = obj.selectedLocation.length > 0 ? obj.selectedLocation[0].Id : null;
        obj.locationName = obj.selectedLocation.length > 0 ? obj.selectedLocation[0].Name : null;
        
        var dayRecords = cmp.get("v.dayRecords");
        
        if(dayRecords.length > 0){
            obj.seqNum = dayRecords[dayRecords.length - 1].sequenceNumber;
        }else {
            obj.seqNum = 0;
        }
        
        var param = {};
        param.inputJson = JSON.stringify(obj);
        
        console.log('::::::param::::',JSON.stringify(param));
        
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
                var result = JSON.parse(response);
                console.log('::::::result::::',result);
                var dayRecords = [];
                dayRecords = cmp.get("v.dayRecords");
                dayRecords.push(result);
                cmp.set("v.dayRecords",dayRecords);
                
                console.log('::set::::::dayRecords::::',cmp.get("v.dayRecords"));

                cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
        self.calculateTotalHours(cmp);

    },
    checkTimeEntryChanged : function(cmp){
        var rowRecords = cmp.get("v.dayRecords");
        var changesMade = false;
        
        for(var i = 0;i < rowRecords.length;i++){
            var entries = rowRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                let hrsEntered = (entries[j].dayHours === 0 || entries[j].dayHours) ? true : false;
                if((entries[j].isNew && hrsEntered) 
                   || (entries[j].isUpdated && hrsEntered)
                  || (entries[j].dayId && hrsEntered)){
                    changesMade = true;
                }
            }
        }
        
        var attendance = cmp.get("v.studentAttendanceList");
        for(var i = 0;i < attendance.length;i++){
            var entry = attendance[i].entries;
            for(var j = 0;j < entry.length;j++){
                let hrsEntered = (entry[j].hours === 0 || entry[j].hours)? true : false;
                if((entry[j].isNew && hrsEntered) 
                   || (entry[j].isUpdated && hrsEntered)
                  || (entry[j].studentId && hrsEntered)){
                    changesMade = true;
                }
            }
        }
        console.log('::::::changesMade:::::',changesMade);
        //cmp.set("v.isvalueChanged",changesMade);
        return changesMade;
    },
    calculateStatusBasedHrsSum : function(cmp, event){
        var rowRecords = cmp.get("v.dayRecords");
        var statusHrsSum = {};
        var statusHrsSummaryList = [];
        
        for(var i = 0;i < rowRecords.length;i++){
            var entries = rowRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                let hrsEntered = (entries[j].dayHours === 0 || entries[j].dayHours) ? true : false;
                if((entries[j].isNew && hrsEntered) || (entries[j].isUpdated && hrsEntered) ){
                    
                    if(entries[j].isNew && hrsEntered){
                        entries[j].status = cmp.get("v.selectedTCDStatus");
                    }
                    if(!statusHrsSum[entries[j].status]){
                        statusHrsSum[entries[j].status] = parseFloat(entries[j].dayHours);
                    }else if(statusHrsSum[entries[j].status]){
                        statusHrsSum[entries[j].status] += parseFloat(entries[j].dayHours);
                    }
                }
            }
        }
        console.log('::::::statusHrsSum:::',JSON.stringify(statusHrsSum));
        for(var key in statusHrsSum){
            statusHrsSummaryList.push({status: key, hours: statusHrsSum[key]});
        }
        
        console.log('::::::::statusHrsSummaryList:::',statusHrsSummaryList);
        cmp.set("v.statusHrsSummary",statusHrsSummaryList);
    },
    checkForActualClassHrsValidation :  function(cmp,type){
        console.log('::::::::type:::',type);
        var dayRecords = cmp.get("v.dayRecords");
        var isValid = true;
        if(type == 'Actual Entry Check') {
            for(var i = 0;i < dayRecords.length;i++){
                var entries = dayRecords[i].dayEntries;
                for(var j = 0;j < entries.length;j++){
                    if((entries[j].isNew && entries[j].dayHours) || (entries[j].isUpdated && entries[j].dayHours)){
                        if(dayRecords[i].taskType != 'Preparation time' && ((dayRecords[i].taskType == 'fringe' && dayRecords[i].taskName == 'Fringe-PTO') || (dayRecords[i].taskType == 'fringe' && dayRecords[i].taskName == 'Fringe-Holiday'))){
                            if((!entries[j].startTime1 || !entries[j].endTime1) && entries[j].dayHours > 0){
                                isValid = false;
                            }
                        }
                        //For Admin Time - because paper timesheet doesnot have time values
                        /*else if(dayRecords[i].taskType == 'Preparation time' && dayRecords[i].timeType == 'AM'){
                            if(!entries[j].startTime1 || !entries[j].endTime1){
                                isValid = false;
                            }
                        }
                        
                        if(entries[i].taskType == 'Preparation time' && dayRecords[i].timeType == 'PM'){
                            if(!entries[j].startTime2 || !entries[j].endTime2){
                                isValid = false;
                            }
                        }*/
                    }
                }
            }
        }else if(type == 'Student Entry Check'){
            var dayMap = {};
            var attendance = cmp.get("v.studentAttendanceList");
            
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
            console.log('::::::::::::dayMap::::',dayMap);
            for(var i = 0;i < attendance.length;i++){
                var entry = attendance[i].entries;
                for(var j = 0;j < entry.length;j++){
                    var hrsExist = (entry[j].hours === 0 || entry[j].hours) ? true : false;
                    if(dayMap[entry[j].dateVal] && !hrsExist){
                        isValid = false;
                    }
                }
            }
        }
        console.log(':::::::isValid::::',isValid);
        //console.log(':::::::type::::',type);
        
        return isValid;
    },
    checkHrsValidOrNot : function(cmp){
        var isValidHrs = true;
        
        //For actual class hours validation
        var dayRecords = cmp.get("v.dayRecords");
        for(var i = 0;i < dayRecords.length;i++){
            
            var entries = dayRecords[i].dayEntries;
            
            for(var j = 0;j < entries.length;j++){
                
                var hrsExist = (entries[j].dayHours === 0 || entries[j].dayHours) ? true : false;
                
                if(hrsExist){
                    
                    var hour = ((parseFloat(entries[j].dayHours) || 0)  * 100) % 100;
                    
                    if(!(hour == 25 || hour == 50 || hour == 75 || hour == 0)){
                        isValidHrs = false;
                    }
                }
            }
        }
        
        //student hrs valid check
        var attendance = cmp.get("v.studentAttendanceList");
        for(var i = 0;i < attendance.length;i++){
            var entry = attendance[i].entries;
            for(var j = 0;j < entry.length;j++){
                var hrsExist = (entry[j].hours === 0 || entry[j].hours) ? true : false;
                if(hrsExist){
                    var hour = ((parseFloat(entries[j].dayHours) || 0)  * 100) % 100;
                    
                    if(!(hour == 25 || hour == 50 || hour == 75 || hour == 0)){
                        isValidHrs = false;
                    }
                }
            }
        }
        console.log(':::decimal::format::::check::isValidHrs::;',isValidHrs);
        return isValidHrs;
    },
    //method to check the comments entered or not on Save & Submit btn click
    checkForStudentTimeValidation : function(cmp){
        var dayRecords = cmp.get("v.dayRecords");
        var attendance = cmp.get("v.studentAttendanceList");
        
        var dayMap = {};
        var reasonEntered = true;
        
        var projectData = cmp.get("v.projectRecords").filter(obj => {
            return obj.projectId === cmp.get("v.selectedProject");
        });
        
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
        
        //console.log(':::::::dayMap::::',JSON.stringify(dayMap));
        
        //Now iterate the attendance table & check notes entered or not
        for(var i = 0;i < attendance.length;i++){
            var entry = attendance[i].entries;
            for(var j = 0;j < entry.length;j++){
                if((entry[j].isNew && entry[j].hours) || (entry[j].isUpdated && entry[j].hours)){
                    if(dayMap[entry[j].dateVal]){
                        var dayHrs = dayMap[entry[j].dateVal];
                        if(entry[j].hours != dayHrs && !entry[j].comments
                          && projectData.length > 0 && !projectData[0].noStudentHrsVerification){
                            reasonEntered = false;
                        }
                    }
                }
            }
        }
        
        console.log(':::::::::::reasonEntered:::',reasonEntered);
        return reasonEntered;
    },
    //Method to check the class hours & time range is greater than or equal
    //If time selected is less than the hrs then throw validation on save btn click 
    hrsTimeValidation : function(cmp){
        var dayRecords = cmp.get("v.dayRecords");
        var validationMsg = '';
        
        for(var i = 0;i < dayRecords.length;i++){
            var entries = dayRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                if((entries[j].isNew && entries[j].dayHours) || (entries[j].isUpdated && entries[j].dayHours)){
                    if(dayRecords[i].taskType != 'Preparation time'){
                        if(entries[j].startTime1 && entries[j].endTime1){
                            
                            var startTimeMinute = this.getMinutes(entries[j].startTime1);
                            var endTimeMinute = this.getMinutes(entries[j].endTime1);
                            
                            var selectedMinuts = (endTimeMinute - startTimeMinute);
                            var actualHrsMinuts = entries[j].dayHours * 50;
                            
                            //Updated the logic based on recent disscussion on August 22 2019
                            //Need to exclude this validation if the time difference & hrs values are 10mins different
                            //We allow user to take 10mints break for each hours
                            
                            if(selectedMinuts < actualHrsMinuts){
                                if(!validationMsg){
                                    validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range entered.</li>';
                                }else {
                                    validationMsg += '<li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range entered.</li>';
                                }
                            }
                        }
                    }else {
                        
                        if(dayRecords[i].taskType == 'Preparation time'){
                            if(dayRecords[i].timeType == 'Both'){
                                var start1;
                                var end1;
                                var start2;
                                var end2;
                                if((entries[j].startTime1 && entries[j].endTime1) && (entries[j].startTime2 && entries[j].endTime2)){
                                    start1 = this.getMinutes(entries[j].startTime1);
                                    end1 = this.getMinutes(entries[j].endTime1);
                                    
                                    start2 = this.getMinutes(entries[j].startTime2);
                                    end2 = this.getMinutes(entries[j].endTime2);
                                    
                                    var selectedHrs = ((end1 - start1) / 60) + ((end2 - start2) / 60);
                                    if(selectedHrs < entries[j].dayHours ){
                                        if(!validationMsg){
                                            validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                        }else {
                                            validationMsg += '<li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                        }
                                    }
                                }else if(entries[j].startTime1 && entries[j].endTime1){
                                    start1 = this.getMinutes(entries[j].startTime1);
                                    end1 = this.getMinutes(entries[j].endTime1);
                                    
                                    if(((end1 - start1) / 60) < entries[j].dayHours ){
                                        if(!validationMsg){
                                            validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                        }else {
                                            validationMsg += '<li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                        }
                                    }
                                }else if(entries[j].startTime2 && entries[j].endTime2){
                                    start2 = this.getMinutes(entries[j].startTime2);
                                    end2 = this.getMinutes(entries[j].endTime2);
                                    
                                    if(((end2 - start2) / 60) < entries[j].dayHours ){
                                        if(!validationMsg){
                                            validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                        }else {
                                            validationMsg += '<li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                        }
                                    }
                                }
                            }else if(dayRecords[i].timeType == 'AM' && (entries[j].startTime1 && entries[j].endTime1)){
                                var start1 = this.getMinutes(entries[j].startTime1);
                                var end1 = this.getMinutes(entries[j].endTime1);
                                
                                if(((end1 - start1) / 60) < entries[j].dayHours ){
                                    if(!validationMsg){
                                        validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                    }else {
                                        validationMsg += '<li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                    }
                                }
                            }else if(dayRecords[i].timeType == 'PM' && (entries[j].startTime2 && entries[j].endTime2)){
                                var start2 = this.getMinutes(entries[j].startTime2);
                                var end2 = this.getMinutes(entries[j].endTime2);
                                
                                if(((end2 - start2) / 60) < entries[j].dayHours ){
                                    if(!validationMsg){
                                        validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                    }else {
                                        validationMsg += '<li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                    }
                                }
                            }
                        }
                        
                    }// end of preparation time else
                }
            }//end of inner for loop
        }//end of outer for loop
        
        if(validationMsg){
            validationMsg += '<br/>Please correct your entry in order to Save.</ul>'
        }
        
        console.log('::::hrs:::time::::::validation::::',validationMsg);
        
        return validationMsg;
    },
    //Method to check time overlap in entire table
    timeOverlapValidation : function(cmp){
        var dayRecords = cmp.get("v.dayRecords");
        var timeOverlapMsg = '';
        
        var dateTimeMap = {};
        for(var i = 0; i < dayRecords.length;i++){
            var entries = dayRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                if((entries[j].isNew && entries[j].dayHours) || (entries[j].isUpdated && entries[j].dayHours)){
                    if(dayRecords[i].taskType != 'Preparation time' && entries[j].startTime1 && entries[j].endTime1){
                        
                        if(!dateTimeMap[entries[j].dateVal]){
                            dateTimeMap[entries[j].dateVal] = entries[j];
                        }
                    }
                }
            }//end of inner for loop
        }//end of outer for loop
        
        
        //iterate the Prep Entries to check the overlap
        for(var i = 0; i < dayRecords.length;i++){
            var entries = dayRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                if((entries[j].isNew && entries[j].dayHours) || (entries[j].isUpdated && entries[j].dayHours)){
                    if(dayRecords[i].taskType == 'Preparation time' 
                       && ((entries[j].startTime1 && entries[j].endTime1) 
                           || (entries[j].startTime2 && entries[j].endTime2))){
                        
                        var haveOverLap = false;
                        var time1OverLap = false;
                        var time2OverLap = false;
                        
                        //Compare the LT time & Pre time values. Find there is a overlap or not
                        if(dateTimeMap[entries[j].dateVal]){
                            let start1 = this.getMinutes(dateTimeMap[entries[j].dateVal].startTime1);
                            let end1 = this.getMinutes(dateTimeMap[entries[j].dateVal].endTime1);
                            
                            let start2;
                            let end2;
                            if(entries[j].startTime1 && entries[j].endTime1){
                                start2 = this.getMinutes(entries[j].startTime1);
                                end2 = this.getMinutes(entries[j].endTime1);
                            }
                            
                            let start3;
                            let end3;
                            if(entries[j].startTime2 && entries[j].endTime2){
                                start3 = this.getMinutes(entries[j].startTime2);
                                end3 = this.getMinutes(entries[j].endTime2);
                            }
                            //console.log('::::::times::::',start1,end1,start2,end2,start3,end3);
                            
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
                                    time1OverLap = true;
                                }
                            }
                            
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
                                //console.log('::::swapped::times:2:',ST1,ET1,ST2,ET2);
                                if(ET2 >= ST1 && ST2 < ET1){
                                    haveOverLap = true;
                                    time2OverLap = true;
                                }
                            }
                            /*console.log('::::::::dateVal::::',entries[j].dateVal);
                            console.log('::::haveOverLap:::',haveOverLap);
                            console.log('::::time1OverLap:::',time1OverLap);
                            console.log('::::time2OverLap:::',time2OverLap);*/
                            
                            if(haveOverLap){
                                if(!timeOverlapMsg){
                                    timeOverlapMsg = '<ul style="list-style-type: initial;">The time ranges for the below Project Tasks for <b>'+entries[j].displayDate+'</b> are in conflict. Please adjust the Start Times and End Times for each project task to ensure none overlaps.';
                                    timeOverlapMsg += '<li>'+dateTimeMap[entries[j].dateVal].taskName+' / '+dateTimeMap[entries[j].dateVal].startTime1+' - '+dateTimeMap[entries[j].dateVal].endTime1+'</li>';
                                    
                                    if(time1OverLap){
                                        timeOverlapMsg += '<li>'+entries[j].taskName+' / '+entries[j].startTime1+' - '+entries[j].endTime1+'</li>';
                                    }else if(time2OverLap){
                                        timeOverlapMsg += '<li>'+entries[j].taskName+' / '+entries[j].startTime2+' - '+entries[j].endTime2+'</li></ul>';
                                    }
                                    
                                }else {
                                    timeOverlapMsg += '<br/><ul style="list-style-type: initial;">The time ranges for the below Project Tasks for <b>'+entries[j].displayDate+'</b> are in conflict. Please adjust the Start Times and End Times for each project task to ensure none overlaps.';
                                    timeOverlapMsg += '<li>'+dateTimeMap[entries[j].dateVal].taskName+' / '+dateTimeMap[entries[j].dateVal].startTime1+' - '+dateTimeMap[entries[j].dateVal].endTime1+'</li>';
                                    
                                    if(time1OverLap){
                                        timeOverlapMsg += '<li>'+entries[j].taskName+' / '+entries[j].startTime1+' - '+entries[j].endTime1+'</li>';
                                    }else if(time2OverLap){
                                        timeOverlapMsg += '<li>'+entries[j].taskName+' / '+entries[j].startTime2+' - '+entries[j].endTime2+'</li></ul>';
                                    }
                                }
                                
                            }
                            
                        }//end of dateTimeMap
                        
                    }//end of hrs validation
                }
            }//end of inner loop
        }//end of outer loop
        
        console.log(':::::::::timeOverlapMsg::::',timeOverlapMsg);
        
        return timeOverlapMsg;
    },
    checkHrsEnteredOrNot : function(cmp){
        var dayRecords = cmp.get("v.dayRecords");
        var invalidEntryAvailable = false;
        
        for(var i = 0;i < dayRecords.length;i++){
            var entries = dayRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                var start1 = (entries[j].startTime1 && entries[j].startTime1 != '--None--')? true : false;
                var end1 = (entries[j].endTime1 && entries[j].endTime1 != '--None--')? true : false;
                var start2 = (entries[j].startTime2 && entries[j].startTime2 != '--None--')? true : false;
                var end2 = (entries[j].endTime2 && entries[j].endTime2 != '--None--')? true : false;
                
                var hrsExist = (entries[j].dayHours === 0 || entries[j].dayHours) ? true : false;
                
                if(((start1 && end1) 
                    || (start2 && end2))
                   && !hrsExist){
                    invalidEntryAvailable = true;
                }
            }
        }
        console.log('::::::invalidEntryAvailable::',invalidEntryAvailable);
        return invalidEntryAvailable;
    },
    checkEndTimeValidOrNot : function(cmp){
        var dayRecords = cmp.get("v.dayRecords");
        var invalidEndTime = false;
        
        //Get current time value to compare with end time
        //W-001894
        var dt = new Date();
        var h =  dt.getHours(), m = dt.getMinutes();
        var currentTime = (h > 12) ? ('0'+ (h-12) + ':' + m +' PM') : ('0'+h+ ':' + m +' AM');
        
        var currentDt = new Date();
        
        for(var i = 0;i < dayRecords.length;i++){
            var entries = dayRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                if((entries[j].isNew && entries[j].dayHours) || (entries[j].isUpdated && entries[j].dayHours)){
                    var columnDt = new Date(entries[j].dateVal);
                    columnDt.setTime(columnDt.getTime() + columnDt.getTimezoneOffset() * 1000 * 60);
                    
                    if(this.dateComparison(currentDt,columnDt) && entries[j].endTime1 && entries[j].endTime1 != '--None--' && this.getMinutes(currentTime) < this.getMinutes(entries[j].endTime1)){
                        invalidEndTime = true;
                    }
                    
                    if(this.dateComparison(currentDt,columnDt) && entries[j].endTime2 && entries[j].endTime2 != '--None--' && this.getMinutes(currentTime) < this.getMinutes(entries[j].endTime2)){
                        invalidEndTime = true;
                    }
                }
            }
        }
        console.log('::::::invalidEndTime::',invalidEndTime);
        return invalidEndTime;
    },
    checkForPlannedDaysOff : function(cmp){
        var dayRecords = cmp.get("v.dayRecords");
        var plannedOffMap = cmp.get("v.plannedDaysOffMap");
        var daysOffMsg = '';
        
        console.log('dayRecords::',dayRecords);
        if(plannedOffMap){
            for(var i = 0;i < dayRecords.length;i++){
                var entries = dayRecords[i].dayEntries;
                for(var j = 0;j < entries.length;j++){
                    if((!(dayRecords[i].taskName == 'Fringe-PTO' && entries[j].payrollItem  == 'PTO')) && (entries[j].isNew && entries[j].dayHours || entries[j].isUpdated && entries[j].dayHours)){
                        if(plannedOffMap[entries[j].dateVal]){
                            daysOffMsg += '<ul style="padding-left:2rem;"> <li style="list-style-type: initial;text-align:left;">The time you entered for <b>'+entries[j].displayDate+'</b> conflicts with a planned day off for the same date.</li>';
                            daysOffMsg += '<li>'+plannedOffMap[entries[j].dateVal].daysOffDate+' / '+plannedOffMap[entries[j].dateVal].contactName+' / '+plannedOffMap[entries[j].dateVal].description+'</li></ul>';
                        }
                    }
                }
            }
        }
        
        if(daysOffMsg){
          //  daysOffMsg += '<br/>Are you sure you would like to save this time entry?';
        }
        
        console.log(':::::::daysOffMsg:::;',daysOffMsg);
        
        return daysOffMsg;
    },
    checkExistingTCDRecords : function(cmp,event){	//Method to check existing TCD for same date & time in other projects
        var self = this;
		
		var dt1 = cmp.get("v.selectedWeek").split(' to ')[0];
        var dt2 = cmp.get("v.selectedWeek").split(' to ')[1];
        
        const server = cmp.find('server');
        const action = cmp.get('c.getExistingTCDsForOtherProjects');
		var param = {};
        param.instructorId = cmp.get("v.selectedContact").length > 0 ? cmp.get("v.selectedContact")[0].Id : null;
		param.startDate = dt1;
		param.endDate = dt2;
		param.projectId = cmp.get("v.selectedProject");
        
        server.callServer(
            action, 
            param, 
            false, 
            $A.getCallback(function(response) { 
				var result = JSON.parse(response);
                console.log('::getExistingTCDsForOtherProjects:::result::::',result);
                cmp.set("v.existingTCDMap",result);
                var msg = self.validateCurrentEntryWithOld(cmp);
                console.log(':::::::msg:::',msg);
                if(msg){
                    cmp.set("v.isValidInput",false);
                    self.displayValidationMsg(cmp,msg,'Warning');
                }else {
                    self.displayValidationMsg(cmp,'','');
                }
            }),
            $A.getCallback(function(errors) { 
                console.log('error',errors)
                self.showToast(cmp,event,'Error',errors[0].message,'error');
            }),
            false, 
            false, 
            false 
        );
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
        
        console.log('::old::&:new::time::overLapMsg:::',overLapMsg);
        
        return overLapMsg;
    },
    checkDLIHavePrepEntry : function(cmp){
        var dayRecords = cmp.get("v.dayRecords");
        
        var dliWLTHolidays = cmp.get("v.dliWLTHolidays");         
        var projectData = cmp.get("v.projectRecords").filter(obj => {
            return obj.projectId === cmp.get("v.selectedProject");
        });
        var projectRTName = projectData.length > 0? projectData[0].projectRTName : '';
        var lateCancellationMap = {};
        var isPrepEntryExist = false;
        
        for(var i = 0;i < dayRecords.length;i++){
            var entries = dayRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                if(entries[i].taskType != 'Preparation time'){
                    var hrsExist = (entries[j].dayHours === 0 || entries[j].dayHours) ? true : false;
                    if(hrsExist){
                        if(projectRTName == 'DLI_W_LT_Projects' && dliWLTHolidays.indexOf(entries[j].dateVal) == -1
                          && entries[j].lateCancellation){
                            if(!lateCancellationMap[entries[j].dateVal]){
                                lateCancellationMap[entries[j].dateVal] = true;
                            }
                        }
                    }
                }
            }
        }
        //check lang training entries with prep
        for(var i = 0;i < dayRecords.length;i++){
            var entries = dayRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                if(entries[i].taskType == 'Preparation time'){
                    if((entries[j].isNew && entries[j].dayHours) || (entries[j].isUpdated && entries[j].dayHours)){
                        if(lateCancellationMap[entries[j].dateVal]){
                            isPrepEntryExist = true;
                        }
                    }
                }
            }
        }
        
        return isPrepEntryExist;
    },
    checkhHasTimeInFederalHoliday: function(cmp){
        var dayRecords = cmp.get("v.dayRecords");
        
        var federalHolidays = cmp.get("v.federalHolidays");
        var resultObj = {isValid: true};
        var dateVal;
        for(var i = 0;i < dayRecords.length;i++){
            if(dayRecords[i].taskType != 'Preparation time'){
                var entries = dayRecords[i].dayEntries;
                for(var j = 0;j < entries.length;j++){
                    var hrsExist = (entries[j].dayHours === 0 || entries[j].dayHours) ? true : false;
                    if(hrsExist && (entries[j].isNew || entries[j].isUpdated) && federalHolidays.indexOf(entries[j].dateVal) != -1){ 
                        dateVal = entries[j].dateVal;
                        resultObj.isValid = false; 
                    }
                }
            }
        }
    
        if(!resultObj.isValid){
            resultObj.message = 'This date ('+dateVal+') is a Federal Holiday, are you sure that you want to enter hours?';
            resultObj.title = 'Warning';
        }
        
        return resultObj;
    },
    overAllValidationMethod :  function(cmp,event){
        
        var projectData = cmp.get("v.projectRecords").filter(obj => {
            return obj.projectId === cmp.get("v.selectedProject");
        });
        
        //Check for Actual Class hrs input values - hrs entered & time values are entered or not
        var isTimeEntered = this.checkForActualClassHrsValidation(cmp,'Actual Entry Check');
        console.log(':::isTimeEntered::',isTimeEntered);
        cmp.set("v.isValidInput",isTimeEntered);
        if(!isTimeEntered){
            this.displayValidationMsg(cmp,'Please enter the Start Time and End Time values for the entries.','Start Time and End Time Entry');
            return;
        }
        
        //check for student time, if class hrs is entered & student hrs are not entered thorugh validation
        var studentHrsEntered = this.checkForActualClassHrsValidation(cmp,'Student Entry Check');
        console.log(':::studentHrsEntered::',studentHrsEntered);
        cmp.set("v.studentHrsEntered",studentHrsEntered);
        if(!studentHrsEntered && (projectData && !projectData[0].noStudentApproval)){
            this.displayValidationMsg(cmp,'Please record hours for each student listed in the Student Time table. If any students were absent, please enter 0.00 for that student','Warning');
            return;
        }
        
        //check entered hours are in correct format, if not throw validation msg
        var isValidHrs = this.checkHrsValidOrNot(cmp);
        cmp.set("v.isValidInput",isValidHrs);
        if(!isValidHrs){
            this.displayValidationMsg(cmp,'Allowed decimal values are 00, 25, 50, 75. Please correct the hours which are not in this format.','Warning');
            return;
        }
        
        // Check for student notes are entered are not
        var reasonEntered = this.checkForStudentTimeValidation(cmp);
        console.log(':::reasonEntered::',reasonEntered);
        cmp.set("v.missmatchReasonEntered",reasonEntered);
        if(!reasonEntered){
            this.displayValidationMsg(cmp,'Please enter the comments for student time values which are missmatch with actual class hours','Warning');
            return;
        }
        
        //Work Item W-001730
        //Check for the time & hours difference and throw validation
        var timeValidationMsg = this.hrsTimeValidation(cmp);
        console.log(':::::timeValidationMsg::::',timeValidationMsg);
        if(timeValidationMsg){
            cmp.set("v.isValidInput",false);
            this.displayValidationMsg(cmp,timeValidationMsg,'Warning');
            return;
        }
        
        //Work Item W-001730
        //Start Time & End Time must not overlap with other time entries time related validation
        var timeOverlapMsg = this.timeOverlapValidation(cmp);
        console.log(':::timeOverlapMsg::',timeOverlapMsg);
        if(timeOverlapMsg){
            cmp.set("v.isValidInput",false);
            this.displayValidationMsg(cmp,timeOverlapMsg,'Warning');
            return;
        }
        
        //check the time & hours values both are entered are not if not throw validation msg
        var invalidEntryAvailable = this.checkHrsEnteredOrNot(cmp);
        if(invalidEntryAvailable){
            cmp.set("v.isValidInput",false);
            this.displayValidationMsg(cmp,'Please enter the hours for the time entry associated to the Start Time and End Time entered.','Warning');
            return;
        }
        
        //Commented by NS on July 12 2022 - W-007497 becuase admin can enter time in Futre time & dates
        //Check the entries are having end time which are not greater than the current time if not throw validation
        /*var invalidEndTime = this.checkEndTimeValidOrNot(cmp);
        if(invalidEndTime){
            cmp.set("v.isValidInput",false);
            this.displayValidationMsg(cmp,'You have selected an End Time that is in the future. Users are not allowed to enter time for a future date or time. <br/>Please correct your entry or wait until the end of the day to enter your time.','Warning');
            return;
        }*/
        
        //Check the Planned Days off record for if they have entered hrs for leave days
        var plannedDaysOffMsg = this.checkForPlannedDaysOff(cmp);
        if(plannedDaysOffMsg){
            cmp.set("v.isValidInput",true);
            this.displayValidationMsg(cmp,plannedDaysOffMsg,'Warning');
            return;
        }
        
        //DLI-W LT project does not have holiday for that date & late cancellation is checked
        //If they entered prep time for that class, then show msg
        var isPrepEntryPresent = this.checkDLIHavePrepEntry(cmp);
        console.log(':::::::isPrepEntryPresent:::',isPrepEntryPresent);
        if(isPrepEntryPresent){
            cmp.set("v.isValidInput",false);
            this.displayValidationMsg(cmp,'Preparation Time can not be performed for sessions that have been cancelled, please clear the preparation time and then save.  If you have any questions, please submit a case on contact your Language Training Supervisor','Warning');
            return;
        }else{
            cmp.set("v.isValidInput",true);
        }
        
        var hasTimeInFederalHoliday = this.checkhHasTimeInFederalHoliday(cmp);
        if(!hasTimeInFederalHoliday.isValid){
            cmp.set("v.isValidInput",false);
            this.displayValidationMsg(cmp,hasTimeInFederalHoliday.message,'Warning',true);
            return;
        }

        //W-007882 - Prep Time Entry Warning Message Request in DLS Online
        var ltWithPrep = this.validatePreparationHours(cmp.get("v.dayRecords"),cmp.get("v.defaultCostRateRateType"));
        if(!ltWithPrep.isValid){
            cmp.set("v.isValidInput",false);
            if(ltWithPrep.invalidPrepDay) {
                var invalidPrepDay = ltWithPrep.invalidPrepDay;
                this.inputValidationAction(cmp, invalidPrepDay);
            }
            this.displayValidationMsg(cmp,ltWithPrep.message,'Warning',true);
            return;
        }
        
        //Check if the instructor entered hours for other project on same date & time range
        //If yes we have to throw validation msg
        var existingTCDOverLapMsg = this.checkExistingTCDRecords(cmp,event);
        
    },
    displayValidationMsg : function(cmp,msg,title,hasTimeInFederalHoliday){
        console.log(':::::::title::::',msg,title);
            
       if(msg && title){
            cmp.set("v.confirmMsg",msg);
            cmp.set("v.showWarningInfo",true);
            if(Array.isArray(cmp.find("warningModal"))) {
                cmp.find("warningModal")[0].open();
            }else{
                cmp.find("warningModal").open();
            }
           if(hasTimeInFederalHoliday){
               cmp.set('v.hasTimeInFederalHoliday', true);
           }
       }else if(!msg && !title ){
           if(cmp.get("v.actionType") == 'Save' && cmp.get("v.isvalueChanged")){
               
                //var changesMade = this.checkTimeEntryChanged(cmp);
                this.calculateStatusBasedHrsSum(cmp);
                cmp.set("v.showSaveModal",true);
                if(Array.isArray(cmp.find("saveModal"))) {
                    cmp.find("saveModal")[0].open();
                }else{
                    cmp.find("saveModal").open();
                }
               
           }else if(cmp.get("v.actionType") == 'Revert'){
               
               var changesMade = this.checkTimeEntryChanged(cmp);
               
               if(changesMade){
                    cmp.set("v.showRevertModal",true);
                    if(Array.isArray(cmp.find("revertModal"))){
                        cmp.find("revertModal")[0].open();
                    }else{
                        cmp.find("revertModal").open();
                    }
                }
           }
       }
    },
    getRecordsTCDForDMLOperation :  function(cmp,type){
        var rowRecords = cmp.get("v.dayRecords");
        var dayList = [];
        
        var updatedTCDIds = [];
        var isUpdate = true;
        
        var dliWLTHolidays = cmp.get("v.dliWLTHolidays");
        var projectData = cmp.get("v.projectRecords").filter(obj => {
            return obj.projectId === cmp.get("v.selectedProject");
        });
        
        for(var i = 0;i < rowRecords.length;i++){
            var entries = rowRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                
                let hrsEntered = (entries[j].dayHours == 0 || entries[j].dayHours)? true : false;
                if((entries[j].isNew && hrsEntered) 
                   || (entries[j].isUpdated && hrsEntered)){
                    if(entries[j].isNew){
                        entries[j].status = cmp.get("v.selectedTCDStatus");
                        if(entries[j].taskType != 'Preparation time'){
                            
                            //check the entry is in DLI-W LT holiday then set studen approval status as N/A
                            if(projectData.length > 0 && projectData[0].projectRTName == 'DLI_W_LT_Projects'){
                                
                                if((dliWLTHolidays.indexOf(entries[j].dateVal) != -1 && entries[j].lateCancellation)
                                  	|| (rowRecords[i].isNewRow && !entries[j].isBillable) || cmp.get("v.isOlderWeek")){
                                   
                                    entries[j].studentApprovalStatus = 'N/A';
                                }else {
                                    //entries[j].studentApprovalStatus = 'Submitted';
                                    entries[j].studentApprovalStatus = cmp.get("v.selectedStudentStatus"); //Added by Mohana
                                }
                                
                            }else if(projectData.length > 0 && ((projectData[0].projectRTName == 'DLI_W_LT_Projects' 
                                 && dliWLTHolidays.indexOf(entries[j].dateVal) == -1) || projectData[0].projectRTName != 'DLI_W_LT_Projects')){
                                
                                if((rowRecords[i].isNewRow && !entries[j].isBillable) || cmp.get("v.isOlderWeek")){
                                    entries[j].studentApprovalStatus = 'N/A';
                                }else {
                                    entries[j].studentApprovalStatus = 'Submitted';
                                }
                            }
                            
                        }else {
                            entries[j].studentApprovalStatus = 'N/A';
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
                                    }
                                }
                                
                                if(cmp.get("v.isOlderWeek")){
                                    entries[j].studentApprovalStatus = 'N/A';
                                }
                            }else {
                                entries[j].studentApprovalStatus = 'N/A';
                            }
                        }
                        
                        updatedTCDIds.push(entries[j].dayId);
                    }
                    
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
                }else if(type == 'Revert' && hrsEntered 
                         && !entries[j].isUpdated && !entries[j].isNew){	
                    //when time entry changed & directly reverting the time entry 
                    //need to include the non edited time entries for time submission
                    
                    dayList.push(entries[j]);
                }
            }
        }
        console.log('::::::::dayList::::',dayList);
        cmp.set("v.updatedTCDIds",updatedTCDIds);
        cmp.set("v.isUpdate",isUpdate);
        
        return dayList;
    },
    getStudentRecordsForDMLOperation : function(cmp){
        //Student Time Table changes capture
        var studentList = [];
        var studentTimeChanged = false;
        
        var stuAttendance = cmp.get("v.studentAttendanceList");
        for(var i = 0;i < stuAttendance.length;i++){
            var entry = stuAttendance[i].entries;
            for(var j = 0;j < entry.length;j++){
                if(entry[j].hours || entry[j].hours === 0){
                    if((entry[j].isNew && (entry[j].hours || entry[j].hours === 0)) || (entry[j].isUpdated && (entry[j].hours || entry[j].hours === 0))){
                        studentTimeChanged = true;
                        studentList.push(entry[j]);
                    }
                }
            }
        }
        console.log('::::::::studentList:::::::',studentList);
		
        return studentList;
    },
    revertActionMethod :  function(cmp, event){
        var dayList = this.getRecordsTCDForDMLOperation(cmp,cmp.get("v.actionType"));
        var studentList = this.getStudentRecordsForDMLOperation(cmp);
        
        var self = this;
		
        var dt1;
        var dt2;
        
        if(cmp.get("v.oldSelectedWeek") != cmp.get("v.selectedWeek")){
            dt1 = cmp.get("v.oldSelectedWeek").split(' to ')[0];
        	dt2 = cmp.get("v.oldSelectedWeek").split(' to ')[1];
        }else {
            dt1 = cmp.get("v.selectedWeek").split(' to ')[0];
        	dt2 = cmp.get("v.selectedWeek").split(' to ')[1];
        }
        
        var projectId = '';
        
        if(cmp.get("v.oldSelectedProject") != cmp.get("v.selectedProject")) {
            projectId = cmp.get("v.oldSelectedProject");
        }else {
            projectId = cmp.get("v.selectedProject");
        }
        
        var contactId = '';
        if(cmp.get("v.oldSelectedContact")[0].Id != cmp.get("v.selectedContact")[0].Id) {
            contactId = cmp.get("v.oldSelectedContact")[0].Id;
        }else {
            contactId = cmp.get("v.selectedContact")[0].Id;
        }
        
        if(cmp.get("v.isvalueChanged")){
            
            const server = cmp.find('server');
            const action = cmp.get('c.dmlOperationMethod');
            var param = {};
            
            param.startDate = dt1;
            param.endDate = dt2;
            param.instructorId = contactId;
            param.projectId = projectId;
            param.actionType = cmp.get("v.actionType");
            param.timeDayJson = JSON.stringify(dayList);
            param.studentJson = JSON.stringify(studentList);
            param.comment = cmp.get("v.comments");
            param.updatedTCDs = cmp.get("v.updatedTCDIds");
            
            server.callServer(
                action, 
                param, 
                false, 
                $A.getCallback(function(response) { 
                    var result = response;
                    console.log('::revert:::with:changes:::',result);
                    cmp.set("v.successMsg",'Time entries reverted successfully.');
                    cmp.set("v.isvalueChanged",false);
                    cmp.set("v.successTitle",'Success');
                    cmp.set("v.displaySuccessModal",true);
                    
                    cmp.set("v.showSpinner",false);
                    
                    if(Array.isArray(cmp.find("successModal"))) {
                        cmp.find("successModal")[0].open();
                    }else{
                        cmp.find("successModal").open();
                    }
                }),
                $A.getCallback(function(errors) { 
                    console.log('error',errors)
                    self.showToast(cmp,event,'Error',errors[0].message,'error');
                }),
                false, 
                false, 
                false 
            );
        }else {
            const server = cmp.find('server');
            const action = cmp.get('c.revertTCDEntries');
            var param = {};
            param.timeDayJson = JSON.stringify(dayList);
            param.comment = cmp.get("v.comments");
            
            server.callServer(
                action, 
                param, 
                false, 
                $A.getCallback(function(response) { 
                    var result = response;
                    console.log('::reverted:::without:changes:::',result);
                    cmp.set("v.successMsg",'Time entries reverted successfully.');
                    cmp.set("v.successTitle",'Success');
                    cmp.set("v.displaySuccessModal",true);
                    
                    cmp.set("v.showSpinner",false);
                    
                    if(Array.isArray(cmp.find("successModal"))) {
                        cmp.find("successModal")[0].open();
                    }else{
                        cmp.find("successModal").open();
                    }
                }),
                $A.getCallback(function(errors) { 
                    console.log('error',errors)
                    self.showToast(cmp,event,'Error',errors[0].message,'error');
                    cmp.set("v.showSpinner",false);
                }),
                false, 
                false, 
                false 
            );
        }
    },
    saveActionMethod : function(cmp, event){
        var dayList = this.getRecordsTCDForDMLOperation(cmp,cmp.get("v.actionType"));
        var studentList = this.getStudentRecordsForDMLOperation(cmp);
        
        var self = this;
		
        var dt1;
        var dt2;
        
        if(cmp.get("v.oldSelectedWeek") != cmp.get("v.selectedWeek")){
            dt1 = cmp.get("v.oldSelectedWeek").split(' to ')[0];
        	dt2 = cmp.get("v.oldSelectedWeek").split(' to ')[1];
        }else {
            dt1 = cmp.get("v.selectedWeek").split(' to ')[0];
        	dt2 = cmp.get("v.selectedWeek").split(' to ')[1];
        }
        console.log('::::::dt1:dt2::',dt1,dt2);
        
        var projectId = '';
        
        if(cmp.get("v.oldSelectedProject") != cmp.get("v.selectedProject")) {
            projectId = cmp.get("v.oldSelectedProject");
        }else {
            projectId = cmp.get("v.selectedProject");
        }
        console.log('::::::projectId:::',projectId);
        
        var contactId = '';
        if(cmp.get("v.oldSelectedContact")[0].Id != cmp.get("v.selectedContact")[0].Id) {
            contactId = cmp.get("v.oldSelectedContact")[0].Id;
        }else {
            contactId = cmp.get("v.selectedContact")[0].Id;
        }
        console.log(':::::::::contactId::::',contactId);
        
        const server = cmp.find('server');
        const action = cmp.get('c.dmlOperationMethod');
        var param = {};
        
        param.startDate = dt1;
        param.endDate = dt2;
        param.instructorId = contactId;
        param.projectId = projectId;
        param.actionType = cmp.get("v.actionType");
        param.timeDayJson = JSON.stringify(dayList);
        param.studentJson = JSON.stringify(studentList);
        param.comment = cmp.get("v.comments");
        param.updatedTCDs = cmp.get("v.updatedTCDIds");
        
        if(cmp.get("v.isvalueChanged") || cmp.get('v.hasTimeInFederalHoliday')){
            server.callServer(
                action, 
                param, 
                false, 
                $A.getCallback(function(response) { 
                    var result = response;
                    console.log('::revert:::with:changes:::',result);
                    if(!cmp.get("v.isUpdate")){
                        cmp.set("v.successMsg",'Time entries created successfully.');
                    }else {
                        cmp.set("v.successMsg",'Time entries updated successfully.');
                    }
                    cmp.set("v.isvalueChanged",false);
                    cmp.set("v.successTitle",'Success');
                    cmp.set("v.displaySuccessModal",true);
                    
                    cmp.set("v.showSpinner",false);
                    
                    if(Array.isArray(cmp.find("successModal"))) {
                        cmp.find("successModal")[0].open();
                    }else{
                        cmp.find("successModal").open();
                    }
                }),
                $A.getCallback(function(errors) { 
                    console.log('error',errors)
                    self.showToast(cmp,event,'Error',errors[0].message,'error');
                    cmp.set("v.showSpinner",false);
                }),
                false, 
                false, 
                false 
            );
        }
    },
    clearTableValues :  function(cmp){
        cmp.set("v.headerList",[]);
        cmp.set("v.dayRecords",[]);
        cmp.set("v.notesList",[]);
        cmp.set("v.studentAttendanceList",[]);
        cmp.set("v.timeCardId", null);
    },

    formatDate : function(inputDate){
    
        var dateArr = inputDate.split("-");
        return dateArr[1]+'/'+dateArr[2]+'/'+dateArr[0];    
    },

    //W-007882 - Prep Time Entry Warning Message Request in DLS Online
    validatePreparationHours : function(dayRecords, defaultCostRateRateType){
        var resultObj = {isValid: true}; 
        var dateVal =  [];
        var invalidPrep = [];
        var invalidPrepDay = [];
        var isValid = true;
        for(var i = 0;i < dayRecords.length;i++){
    
            if(dayRecords[i].taskType == 'Language Training' && defaultCostRateRateType == 'LT with Prep'){
                var entries = dayRecords[i].dayEntries;
                for(var j = 0;j < entries.length;j++){
                    var hrsExist = (entries[j].dayHours === 0 || entries[j].dayHours) ? true : false;
                    if(hrsExist){ 
                        dateVal.push(entries[j].dateVal);
                    }
                }
            }
    
            if(dayRecords[i].taskType == 'Preparation time' && defaultCostRateRateType == 'LT with Prep'){
                var entries = dayRecords[i].dayEntries;
                for(var j = 0;j < entries.length;j++){
                    if(dateVal.includes(entries[j].dateVal) && entries[j].dayHours == null){ 
                        isValid = false; 
                        var invalidPrepRec = {};
                        invalidPrep.push(this.formatDate(entries[j].dateVal));
                        invalidPrepRec['PrepDay']= entries[j].dateVal;
                        invalidPrepRec['dayIndex']= j;
                        invalidPrepRec['lineIndex'] =i;
                        invalidPrepDay.push(invalidPrepRec);
                    }
                }
            }
        }
    
        if(!isValid){
            resultObj.isValid = false;
            resultObj.message = `Please enter time for Language Training - Preparation for <b>${invalidPrep.join(',')}</b>.`;
            resultObj.title = 'Warning';
            resultObj.isValidInput = false;
            resultObj['invalidPrepDay'] = invalidPrepDay;
        }
        return resultObj;
    },
    inputValidationAction : function(cmp, invalidPrepDays) {
        
        var findcomp = cmp.find('prepRow');
        for(let invalidPrepDay of invalidPrepDays){
            let index = invalidPrepDay.dayIndex+(invalidPrepDay.lineIndex*7);
            findcomp[index].prepHrsInputValidation(invalidPrepDay.PrepDay);
        }
    }
    
})