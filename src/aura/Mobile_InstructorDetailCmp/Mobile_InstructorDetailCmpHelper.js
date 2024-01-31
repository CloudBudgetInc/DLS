({
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
    dateConstruction :  function(dateVal,time){
        
        var hrs = parseInt(time.split(':')[0]);
        var mint = parseInt(time.split(':')[1].split(' ')[0]);
        var ampm = time.split(' ')[1];
        
        if(ampm == 'PM' && hrs != 12){
            hrs += 12;
        }
        
        var shrs = hrs.toString();
        var smints = mint.toString();
        
        if(hrs < 10){
            shrs = '0'+hrs;
        }
        
        if(mint < 10){
            smints = '0'+mint;
        }
        
        return dateVal+' '+shrs+':'+smints+':00';
    },
    apexDateFormatFunction : function(dateval){
        return dateval.split('/')[2]+'-'+dateval.split('/')[0]+'-'+dateval.split('/')[1];
    },
    addValidationForTimeInputs : function(cmp,index) {
        
        var dayRecord = cmp.get("v.dayRecord").dayEntries[index];
        
        var dt = new Date();
        var h =  dt.getHours(), m = dt.getMinutes();
        var currentTime = (h > 12) ? ('0'+ (h-12) + ':' + m +' PM') : ('0'+h+ ':' + m +' AM');
        
        var columnDt = new Date(dayRecord.dateVal);
        columnDt.setTime(columnDt.getTime() + columnDt.getTimezoneOffset() * 1000 * 60);
        
        var currentDt = new Date();
        
        if((dayRecord.taskType == 'Language Training' || 
           (dayRecord.taskType != 'Language Training' && dayRecord.timeType == 'Single')) && (dayRecord.taskName != 'Fringe-PTO')){
            
            let stCmp = Array.isArray(cmp.find("startTime")) ? cmp.find("startTime")[index] : cmp.find("startTime");
            let edCmp = Array.isArray(cmp.find("endTime")) ? cmp.find("endTime")[index] : cmp.find("endTime");
            
            //start time value check
            if(dayRecord.dayHours && !stCmp.get("v.value")){
                $A.util.addClass(stCmp,"slds-has-error");                 
            }else {
                $A.util.removeClass(stCmp,"slds-has-error");          
            }
            
            //end time value check
            if(dayRecord.dayHours && !edCmp.get("v.value")){
                $A.util.addClass(edCmp,"slds-has-error");   
            }else if(!dayRecord.dayHours || !edCmp.get("v.value") || this.getMinutes(currentTime) >= this.getMinutes(edCmp.get("v.value"))){
                $A.util.removeClass(edCmp,"slds-has-error");   
            }
            
        }else if(dayRecord.taskType != 'Language Training' && dayRecord.timeType != 'Single' && dayRecord.taskName != 'Fringe-PTO'){
            
            if(dayRecord.timeType == 'AM' || dayRecord.timeType == 'Both'){
                
                let stCmp = Array.isArray(cmp.find("startTime")) ? cmp.find("startTime")[index] : cmp.find("startTime");
                let edCmp = Array.isArray(cmp.find("endTime")) ? cmp.find("endTime")[index] : cmp.find("endTime");
                
                let start2 = 0;
                let end2 = 0;
                
                if(dayRecord.startTime2 && dayRecord.endTime2){
                    start2 = this.getMinutes(dayRecord.startTime2);
                    end2 = this.getMinutes(dayRecord.endTime2);
                }
                
                let timeDifference = (end2 - start2)/60;
                
                //start time value check
                if((dayRecord.dayHours && !stCmp.get("v.value")) && (timeDifference < dayRecord.dayHours)){
                    $A.util.addClass(stCmp,"slds-has-error");                 
                }else {
                    $A.util.removeClass(stCmp,"slds-has-error");          
                }
                
                //end time value check
                if((dayRecord.dayHours && !edCmp.get("v.value")) && (timeDifference < dayRecord.dayHours)){
                    $A.util.addClass(edCmp,"slds-has-error");   
                }else if(!dayRecord.dayHours || !edCmp.get("v.value") || this.getMinutes(currentTime) >= this.getMinutes(edCmp.get("v.value"))){
                    $A.util.removeClass(edCmp,"slds-has-error");   
                }
            }
            
            if(dayRecord.timeType == 'PM' || dayRecord.timeType == 'Both'){
                
                let stCmp = Array.isArray(cmp.find("startTime2")) ? cmp.find("startTime2")[index] : cmp.find("startTime2");
                let edCmp = Array.isArray(cmp.find("endTime2")) ? cmp.find("endTime2")[index] : cmp.find("endTime2");
                
                let start1 = 0;
                let end1 = 0;
                
                if(dayRecord.startTime1 && dayRecord.endTime1){
                    start1 = this.getMinutes(dayRecord.startTime1);
                    end1 = this.getMinutes(dayRecord.endTime1);
                }
                
                let timeDifference = (end1 - start1)/60;
                
                //start time value check
                if((dayRecord.dayHours && !stCmp.get("v.value")) && (timeDifference < dayRecord.dayHours)){
                    $A.util.addClass(stCmp,"slds-has-error");                 
                }else {
                    $A.util.removeClass(stCmp,"slds-has-error");          
                }
                
                //end time value check
                if((dayRecord.dayHours && !edCmp.get("v.value")) && (timeDifference < dayRecord.dayHours)){
                    $A.util.addClass(edCmp,"slds-has-error");   
                }else if(!dayRecord.dayHours || !edCmp.get("v.value") || this.getMinutes(currentTime) >= this.getMinutes(edCmp.get("v.value"))){
                    $A.util.removeClass(edCmp,"slds-has-error");   
                }
            }
        }
        
    },
    //compare the end time with current, if its in future throw validaiton
    validateEndTime : function(cmp, rowIndex,dayRec){
        let currentTimezone = moment.tz.guess();
        let currentTime = moment.tz(currentTimezone);
        
        var scheduleTimezone = dayRec.scheduleTimezone;
        
        var endTime1Cmp = Array.isArray(cmp.find("endTime")) ? cmp.find("endTime")[rowIndex] : cmp.find("endTime");
        var endTime2Cmp = Array.isArray(cmp.find("endTime2")) ? cmp.find("endTime2")[rowIndex] : cmp.find("endTime2");
        
        if(dayRec.endTime1){
            let dt = this.dateConstruction(dayRec.dateVal,dayRec.endTime1);
        	let columnTime = moment.tz(dt,scheduleTimezone);
        	
            if(currentTime < columnTime){
                
            	cmp.set("v.endTimeValidationModel",true);
                if(Array.isArray(cmp.find("endTimeValidationModel"))) {
                    cmp.find("endTimeValidationModel")[0].open();
                }else{
                    cmp.find("endTimeValidationModel").open();
                }
                cmp.set("v.endTimeValidationMsg",'You have selected an End Time that is in the future. Users are not allowed to enter time for a future date or time. <br/>Please correct your entry or wait until the end of the day to enter your time.');
            
            }else {
                if(dayRec.endTime1){
                    $A.util.removeClass(endTime1Cmp,"slds-has-error"); 
                }else if(dayRec.dayHours && !dayRec.endTime1){
                    $A.util.addClass(endTime1Cmp,"slds-has-error"); 
                }            
            }
        }
        
        if(dayRec.endTime2){
            let dt = this.dateConstruction(dayRec.dateVal,dayRec.endTime2);
        	let columnTime = moment.tz(dt,scheduleTimezone);
            
            if(currentTime < columnTime){
                
            	cmp.set("v.endTimeValidationModel",true);
                if(Array.isArray(cmp.find("endTimeValidationModel"))) {
                    cmp.find("endTimeValidationModel")[0].open();
                }else{
                    cmp.find("endTimeValidationModel").open();
                }
                cmp.set("v.endTimeValidationMsg",'You have selected an End Time that is in the future. Users are not allowed to enter time for a future date or time. <br/>Please correct your entry or wait until the end of the day to enter your time.');
            
            }else {
                if(dayRec.endTime2){
                    $A.util.removeClass(endTime2Cmp,"slds-has-error"); 
                }else if(dayRec.dayHours && !dayRec.endTime2){
                    $A.util.addClass(endTime2Cmp,"slds-has-error");
                }
            }
        }
    },
    formEditModalContents : function(cmp,oldDay){
        var obj = {};
        var type = oldDay.timeType;
        obj.hours = oldDay.dayHours;
        obj.lateCancellation = oldDay.lateCancellation;
        obj.cancellationReason = oldDay.cancellationReason;
        obj.comments = oldDay.comments;
        obj.startTime1 = oldDay.startTime1;
        obj.endTime1 = oldDay.endTime1;
        obj.projectName = oldDay.projectName;
        obj.taskName = oldDay.taskName;
        obj.displayDate = oldDay.displayDate;
        obj.timeType = oldDay.timeType;
        obj.startTime1Minutes = oldDay.startTime1Minutes;
        obj.endTime1Minutes = oldDay.endTime1Minutes;
        
        
        if((type == 'PM' || type == 'Normal') || (oldDay.startTime2 && oldDay.endTime2)){
            obj.startTime2 = oldDay.startTime2;
            obj.endTime2 = oldDay.endTime2;
            
            obj.startTime2Minutes = oldDay.startTime2Minutes;
            obj.endTime2Minutes = oldDay.endTime2Minutes;
        }
        cmp.set("v.editRecord",obj);
    },
    updateEventInTableLevel : function(cmp){
        var timeRecords = cmp.get("v.dayRecord");
        var entries = timeRecords.dayEntries;
        var currentIndex = cmp.get("v.currentRecordIndex");
        
        var updatedDay = cmp.get("v.editRecord");
        
        entries[currentIndex].dayHours = updatedDay.hours;
        entries[currentIndex].startTime1 = updatedDay.startTime1;
        entries[currentIndex].endTime1 = updatedDay.endTime1;
        
        entries[currentIndex].startTime1Minutes = updatedDay.startTime1Minutes;
        entries[currentIndex].endTime1Minutes = updatedDay.endTime1Minutes;
        
        entries[currentIndex].startTime2 = updatedDay.startTime2;
        entries[currentIndex].endTime2 = updatedDay.endTime2;
        
        entries[currentIndex].startTime2Minutes = updatedDay.startTime2Minutes;
        entries[currentIndex].endTime2Minutes = updatedDay.endTime2Minutes;
        
        entries[currentIndex].lateCancellation = updatedDay.lateCancellation;
        entries[currentIndex].cancellationReason = updatedDay.cancellationReason;
        entries[currentIndex].comments = updatedDay.comments;
        
        if(cmp.get("v.buttonType") == 'Edit'){
            if(entries[currentIndex].status == 'Unposted'){
                entries[currentIndex].status = 'Draft';
                entries[currentIndex].studentApprovalStatus = 'Submitted';
            }else {
                entries[currentIndex].studentApprovalStatus = 'Submitted';
            }
        }else if(cmp.get("v.buttonType") == 'Delete'){
            entries[currentIndex].status = 'Unposted';
            entries[currentIndex].studentApprovalStatus = '';
        }
        
        entries[currentIndex].color = updatedDay.color;
        entries[currentIndex].isHrsDisabled = false;
        entries[currentIndex].isUpdated = true;
        entries[currentIndex].showEditIcon = false;
        entries[currentIndex].isUnposted = updatedDay.isUnposted;
        entries[currentIndex].showReverseIcon = false;
        entries[currentIndex].recallReason = updatedDay.recallReason;
        
        cmp.set("v.dayRecord",timeRecords);
        //console.log(':::::::after::update:',cmp.get("v.dayRecord").dayEntries);
        
        if(cmp.get("v.buttonType") == 'Recall'){
            this.recallForSingleEntry(cmp);
        }
    },
    recallForSingleEntry : function(cmp, event){
        var daysForRecall = [];
        console.log('::::::recallForSingleEntry:::');
        var entries = cmp.get("v.dayRecord").dayEntries;
        for(var i = 0;i < entries.length;i++){
            if(entries[i].dayId && (entries[i].dayHours == 0 || entries[i].dayHours)){
                if(entries[i].isUpdated){
                    daysForRecall.push(entries[i]);
                }
            }
        }
        
        console.log(":::daysForRecall:::",daysForRecall);
        
        var self = this;
        
        var param = {};
        param.timeDayJson = JSON.stringify(daysForRecall);
        param.type = 'Individual';
        
        const server = cmp.find('server');
        const action = cmp.get('c.recallTimeEntries');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                //console.log('::::::result::recall:::',response);   
                
                cmp.set("v.successMsg",'Time entry recalled successfully.');
                
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
    //Method to check the hrs missmatch on day Hrs & student hours changes
    checkForStudenHoursMissMatch : function(cmp,oldHrsValue,updatedDay,index){
        //console.log('enter student miss match');
        var dayRecord = cmp.get("v.dayRecord");
        var attendance = dayRecord.studentEntries;
        
        var projectData = cmp.get("v.detailMap").projectData;
        
        //If day record hours is changed then update the corresponding values in student table
        if(oldHrsValue && updatedDay){
            //console.log('if 1');
            for(var i = 0;i < attendance.length;i++){
                if(updatedDay.dateVal == attendance[i].dateVal && attendance[i].hours && attendance[i].hours == oldHrsValue){
                    if(attendance[i].isNew){
                        attendance[i].hours = updatedDay.dayHours;
                    }
                }else if(updatedDay.dateVal == attendance[i].dateVal && attendance[i].hours 
                         && (attendance[i].hours != oldHrsValue || attendance[i].dayHours == 0) && !attendance[i].comments 
                         && projectData.length > 0 && !projectData[0].noStudentHrsVerification){
                    attendance[i].displayNotesLink = 'true';
                }
            }
        }else if(index != -1){	//if the student time is entered check for the day record hourd & add the notes link if there is miss match
            //console.log('2');
            var columnData = attendance[index];
            var dayEntries = dayRecord.dayEntries;
            
            for(var i = 0;i < dayEntries.length;i++){
                if(dayEntries[i].taskType != 'Preparation time'){
                    if(dayEntries[i].dateVal == columnData.dateVal 
                       && dayEntries[i].dayHours != null && columnData.hours != null 
                       && (dayEntries[i].dayHours != columnData.hours 
                           || columnData.hours === 0 || dayEntries[i].dayHours == 0)
                       && projectData.length > 0 && !projectData[0].noStudentHrsVerification){
                        
                        columnData.displayNotesLink = 'true';
                        
                    }else if(dayEntries[i].dateVal == columnData.dateVal 
                             && dayEntries[i].dayHours 
                             && (dayEntries[i].dayHours == columnData.hours || !columnData.hours)
                             && projectData.length > 0 && !projectData[0].noStudentHrsVerification){
                        
                        columnData.displayNotesLink = 'false';
                    }
                }                
            }
            
            //console.log(':::::::::else::2::');
        }else {	//if student time is entered first & then class time 2nd entered below else will come
            //console.log('3');
            var dayEntries = dayRecord.dayEntries;
            var dayMap = {};
            
            for(var i = 0;i < dayEntries.length;i++){
                if(dayEntries[i].taskType != 'Preparation time'){
                    if((dayEntries[i].isNew && dayEntries[i].dayHours) || (dayEntries[i].isUpdated && dayEntries[i].dayHours)){
                        if(!dayMap[dayEntries[i].dateVal]){
                            dayMap[dayEntries[i].dateVal] = dayEntries[i].dayHours;
                        }
                    }
                }
            }
            
            //Now iterate the attendance table & check notes entered or not
            for(var i = 0;i < attendance.length;i++){
                if((attendance[i].isNew && attendance[i].hours) || (attendance[i].isUpdated && attendance[i].hours)){
                    
                    if(dayMap[attendance[i].dateVal]){
                        var dayHrs = dayMap[attendance[i].dateVal];
                        
                        if(attendance[i].hours != null && (attendance[i].hours != dayHrs || attendance[i].hours == 0)
                           && projectData.length > 0 && !projectData[0].noStudentHrsVerification){
                            
                            attendance[i].displayNotesLink = 'true';
                        }else if(attendance[i].hours == dayHrs){
                            attendance[i].displayNotesLink = 'false';
                        }
                    }
                }
            }
            //console.log(':::::::::else::3::');
        }
        
        cmp.set("v.dayRecord",dayRecord);
    },
    callStudentTimeRecallMethod : function(cmp){
        
        var param = {};
        var stuArray = [];
        
        var self = this;
        
        var studentRec = cmp.get("v.studentRec");
        cmp.set("v.currentRecordIndex",studentRec.index);
        delete studentRec.index;		
        
        stuArray.push(cmp.get("v.studentRec"));
        
        param.studentJson = JSON.stringify(stuArray);
        
        const server = cmp.find('server');
        const action = cmp.get('c.recallStudentEntries');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                //console.log('::::::result:student:recall:::',response);   
                
                cmp.set("v.successMsg",'Time entry recalled successfully.');
                cmp.set("v.successTitle",'Success');
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
    },    
    disablePrepTimeRows : function(cmp,updatedDay,dayIndex){
        //console.log(':::::::disbale Prep time:::::::');
        var timeRecords = cmp.get("v.dayRecord");
        var detailMap = cmp.get("v.detailMap");
        var projectData = detailMap.projectData;
        
        var dayRecords = timeRecords.dayEntries;
        
        for(var i = 0;i < dayRecords.length;i++){
            if(dayRecords[i].taskType == 'Preparation time' && i != dayIndex){
                if(updatedDay.lateCancellation && projectData && projectData[0].projectRTName == 'DLI_W_LT_Projects'){
                    //Commented By Dhinesh - 15/09/2022 - W-007562 - To disable prep time only for DLI W LT Projects
                   //&& projectData[0].projectRTName != 'DODA_Projects' && projectData[0].projectRTName != 'ESL_LT_Projects'){
                    
                    dayRecords[i].dayHours = null;
                    dayRecords[i].startTime1 = '--None--';
                    dayRecords[i].endTime1 = '--None--';
                    dayRecords[i].startTime2 = '--None--';
                    dayRecords[i].endTime2 = '--None--';
                    dayRecords[i].isHrsDisabled = true;
                }else {
                    dayRecords[i].isHrsDisabled = false;
                }
            }
        }
        
        cmp.set("v.dayRecord",timeRecords);
    },
    callValidation : function(cmp){
        
        var detailMap = cmp.get("v.detailMap");
        
        var projectData = detailMap.projectData;
        
        // W-007882
        projectData['defaultCostRateRateType'] = cmp.get("v.defaultCostRateRateType");

        var timeRecords = cmp.get("v.dayRecord");
        
        var dayRecords = timeRecords.dayEntries;
        var attendance = timeRecords.studentEntries;
        var plannedOffMap = detailMap.plannedDaysOffMap;
        var dliWLTHolidays = detailMap.dliWLTHolidays;
        var federalHolidays = detailMap.federalHolidays;
        
        var validationResult = overAllValidationForMobile(dayRecords,attendance,projectData,plannedOffMap,dliWLTHolidays,federalHolidays);
        console.log(':::::::::validationResult:::::',validationResult);
        
        cmp.set("v.isValidInput",validationResult.isValid);

        if(validationResult.invalidPrepDay) {
            var invalidPrepDay = validationResult.invalidPrepDay;
            this.inputValidationAction(cmp, invalidPrepDay);
        }

        if(!validationResult.isValid){
            this.displayValidationMsg(cmp,validationResult.message,validationResult.title);
            return;
        }
        
        if(validationResult.isHasTimeInFederalHoliday){
            this.displayValidationMsg(cmp,validationResult.message,validationResult.title, validationResult.isHasTimeInFederalHoliday,true);
            return;
        } 
        this.checkOtherValidations(cmp);
    },
    checkOtherValidations: function(cmp){
        var detailMap = cmp.get("v.detailMap");
        var projectData = detailMap.projectData;
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
    displayValidationMsg : function(cmp,msg,title, hasTimeInFederalHoliday){
        console.log('::::msg::title:::',msg,title,cmp.get("v.isvalueChanged"));
        if(!msg && !title){
            
            cmp.set("v.isValidInput",true);
            
            if(cmp.get("v.isvalueChanged")){
                
                //Check the current project is CD then no need to submit for student approval
                var projectData = cmp.get("v.detailMap").projectData;
                
                var confirmMsg = '';
                
                //check only DLI-W LT holiday entry is entered/updated
                var onlyHolidayEntryExist = this.checkOnlyHolidayEntriesPresent(cmp);
                
                if(projectData && projectData[0].projectRTName != 'CD_Projects' && !projectData[0].noStudentApproval && !onlyHolidayEntryExist){
                    
                    var stuNames = cmp.get("v.detailMap").studentNames;
                    if((projectData[0].projectRTName == 'DLI_W_LT_Projects' || projectData[0].projectRTName == 'DODA_Projects' 
                        || projectData[0].projectRTName == 'ESL_LT_Projects')
                       && stuNames.indexOf(';') != -1 && stuNames.split(';').length > 0){
                        
                        var projectStuLeaderMap = cmp.get("v.detailMap").projectStuLeaderMap;
                        var studentLeader = projectStuLeaderMap[projectData[0].projectId];
                        
                        confirmMsg = '<p>The Training Hours submitted will be sent to the student class leader: <b>'+studentLeader+'</b> for approval.</p>';
                        confirmMsg += '<p> The Student Hours will be sent to the following students for their approval: <b>'+cmp.get("v.detailMap").studentNames+'</b>.</p>';
                        confirmMsg += 'Do you want to proceed?';
                    }else {
                        confirmMsg = 'These hours will be submitted to your student: <b>'+cmp.get("v.detailMap").studentNames+'</b> for approval, do you want to proceed?';
                    }                        
                }else if(projectData && (projectData[0].projectRTName == 'CD_Projects' || projectData[0].noStudentApproval) || onlyHolidayEntryExist){
                    confirmMsg = 'Would you like to save the changes?';
                }
                
                cmp.set("v.confirmMsg",confirmMsg);
                cmp.set("v.confirmTitle",'Confirmation');
            }else {
                cmp.set("v.confirmMsg",'There is no hours to save.');
                cmp.set("v.isValidInput",false);
                cmp.set("v.confirmTitle",'Warning');
            }
            
        }else if(msg && title){
            
            cmp.set("v.confirmMsg",msg);
            cmp.set("v.confirmTitle",title);
            if(title == 'Warning' && msg.includes('conflicts with a planned day off for the same date')){
                cmp.set("v.isValidInput",false);
            }
            
            //cmp.set("v.isValidInput",false);
        }
        
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
    },
    checkOnlyHolidayEntriesPresent : function(cmp){
        
        var timeRecords = cmp.get("v.dayRecord");
        var detailMap = cmp.get("v.detailMap");
        
        var dayRecords = timeRecords.dayEntries;
        
        var dliWLTHolidays = detailMap.dliWLTHolidays;         
        var projectData = detailMap.projectData;
        var projectRTName = projectData.length > 0? projectData[0].projectRTName : '';
        
        var onlyHolidayEntryPresent = true;
        
        for(var i = 0;i < dayRecords.length;i++){
            if(dayRecords[i].taskType != 'Preparation time'){
                var hrsExist = (dayRecords[i].dayHours === 0 || dayRecords[i].dayHours) ? true : false;
                if((dayRecords[i].isNew && hrsExist) || (dayRecords[i].isUpdated && hrsExist)){
                    if(projectRTName == 'DLI_W_LT_Projects'){
                        
                        if(dliWLTHolidays.indexOf(dayRecords[i].dateVal) == -1 
                           || (dliWLTHolidays.indexOf(dayRecords[i].dateVal) != -1 && !dayRecords[i].lateCancellation)){
                            onlyHolidayEntryPresent = false;
                        }
                    }
                }
            }
        }
        
        //console.log('::::::onlyHolidayEntryPresent:::',onlyHolidayEntryPresent);
        
        return onlyHolidayEntryPresent;
    },
    checkwithEventsDuration : function(cmp){
        
        var detailMap = cmp.get("v.detailMap");
        var timeEntries = cmp.get("v.dayRecord");
        
        var dt1 = this.apexDateFormatFunction(detailMap.selectedWeek.split(' to ')[0]);
        var dt2 = this.apexDateFormatFunction(detailMap.selectedWeek.split(' to ')[1]);
        
        var dayRecords = timeEntries.dayEntries;
        
        var dayEntries = [];
        
        for(var i = 0;i < dayRecords.length;i++){
            if(dayRecords[i].taskType != 'Preparation time'){
                var hrsExist = (dayRecords[i].dayHours === 0 || dayRecords[i].dayHours) ? true : false;
                if((dayRecords[i].isNew && hrsExist) || (dayRecords[i].isUpdated && hrsExist)){
                    dayEntries.push(dayRecords[i]);
                }
            }
        }
        
        var self = this;
        
        var param = {};
        param.projectId = detailMap.projectId;
        param.instructorId = detailMap.contactId;
        param.startDate = dt1;
        param.endDate = dt2;
        param.timeDayJson = JSON.stringify(dayEntries);
        
        const server = cmp.find('server');
        const action = cmp.get('c.getProjectRelatedEvents');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                var dateNotesRequiredFlagMap = JSON.parse(response);
                
                //console.log('::events:::compare::::',dateNotesRequiredFlagMap);
                if(Object.keys(dateNotesRequiredFlagMap).length > 0){
                    self.studentNotesRequiredMethod(cmp,dateNotesRequiredFlagMap);
                }else {
                    self.checkExistingTCDRecords(cmp);
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
    studentNotesRequiredMethod : function(cmp,dateNotesRequiredFlagMap){
        
        var timeRecords = cmp.get("v.dayRecord");
        var attendance = timeRecords.studentEntries;
        
        var showMsg = false;
        
        for(var i = 0;i < attendance.length;i++){
            var hrsExist = (attendance[i].hours === 0 || attendance[i].hours) ? true : false;
            if((attendance[i].isNew && hrsExist) || (attendance[i].isUpdated && hrsExist)){
                
                if(dateNotesRequiredFlagMap[attendance[i].dateVal]){
                    var notesRequired = dateNotesRequiredFlagMap[attendance[i].dateVal];
                    
                    if(notesRequired && !attendance[i].comments){
                        attendance[i].displayNotesLink = 'true';
                        attendance[i].color = 'pink';
                        showMsg = true;
                        
                    }else if(notesRequired && attendance[i].comments){
                        attendance[i].color = null;
                    }
                }else {
                    attendance[i].color = null;
                }
            }
        }
        
        cmp.set("v.dayRecord",timeRecords);
        
        if(showMsg){
            cmp.set("v.isValidInput",false);
            this.displayValidationMsg(cmp,'Please enter notes for each of the highlighted student time entries','Notes Required');
            return;
        }else {
            this.checkExistingTCDRecords(cmp);
        }
    },
    checkExistingTCDRecords : function(cmp){	//Method to check existing TCD for same date & time in other projects
        
        var detailMap = cmp.get("v.detailMap");
        var self = this;
        
        var dt1 = this.apexDateFormatFunction(detailMap.selectedWeek.split(' to ')[0]);
        var dt2 = this.apexDateFormatFunction(detailMap.selectedWeek.split(' to ')[1]);
        
        var param = {};
        param.instructorId = detailMap.contactId;
        param.startDate = dt1;
        param.endDate = dt2;
        param.projectId = detailMap.projectId;
        
        const server = cmp.find('server');
        const action = cmp.get('c.getExistingTCDsForOtherProjects');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                //console.log('::::existing::tcd::::',result);
                cmp.set("v.existingTCDMap",result);
                var msg = self.validateCurrentEntryWithOld(cmp);
                if(msg){
                    cmp.set("v.isValidInput",false);
                    self.displayValidationMsg(cmp,msg,'Warning');
                }else {
                    self.displayValidationMsg(cmp,'','');
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
    validateCurrentEntryWithOld : function(cmp){
        
        var oldEntry = cmp.get("v.existingTCDMap");
        var dayRecords = cmp.get("v.dayRecord").dayEntries;
        var overLapMsg = '';
        
        //check for Language Training PT Conflicts
        for(var i = 0; i < dayRecords.length;i++){
            if((dayRecords[i].isNew && dayRecords[i].dayHours) 
               || (dayRecords[i].isUpdated && dayRecords[i].dayHours)){
                
                //For Language Training Time Comparison
                if(dayRecords[i].taskType != 'Preparation time' 
                   && dayRecords[i].startTime1 && dayRecords[i].endTime1){
                    
                    var haveOverLap = false;
                    
                    if(oldEntry[dayRecords[i].dateVal]){
                        var oldEntries = oldEntry[dayRecords[i].dateVal];
                        //Iterate the old map list values
                        for(var k = 0;k < oldEntries.length;k++){
                            if(oldEntries[k].taskType != 'Preparation time'){
                                let start1 = this.getMinutes(oldEntries[k].startTime1);
                                let end1 = this.getMinutes(oldEntries[k].endTime1);
                                
                                let start2;
                                let end2;
                                if(dayRecords[i].startTime1 && dayRecords[i].endTime1){
                                    start2 = this.getMinutes(dayRecords[i].startTime1);
                                    end2 = this.getMinutes(dayRecords[i].endTime1);
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
                                    overLapMsg += '<ul style="list-style-type: initial;">The time entry you are attempting to save for <b>'+dayRecords[i].displayDate+'</b> is in conflict with the following time entries: ';
                                    overLapMsg += '<li>'+oldEntries[k].projectName+' / '+oldEntries[k].studentNames+' / '+oldEntries[k].taskName+' / '+oldEntries[k].startTime1+' - '+oldEntries[k].endTime1+'</li>';
                                }
                            }
                        }//end of old list 
                        
                        if(haveOverLap){
                            overLapMsg += '</ul>';
                        }
                    }
                }else if(dayRecords[i].taskType == 'Preparation time' 
                         && ((dayRecords[i].startTime1 && dayRecords[i].endTime1) 
                             || (dayRecords[i].startTime2 && dayRecords[i].endTime2))){	//Preparation Hours comparision
                    
                    let haveOverLap = false;
                    let time1OverLap = false;
                    let time2OverLap = false;
                    
                    if(oldEntry[dayRecords[i].dateVal]){
                        var oldEntries = oldEntry[dayRecords[i].dateVal];
                        //Iterate the old map list values
                        for(var k = 0;k < oldEntries.length;k++){
                            if(oldEntries[k].taskType == 'Preparation time'){
                                
                                let start1 = this.getMinutes(oldEntries[k].startTime1);
                                let end1 = this.getMinutes(oldEntries[k].endTime1);
                                let start2 = this.getMinutes(oldEntries[k].startTime2);
                                let end2 = this.getMinutes(oldEntries[k].endTime2);
                                
                                let start3;
                                let end3;
                                if(dayRecords[i].startTime1 && dayRecords[i].endTime1){
                                    start3 = this.getMinutes(dayRecords[i].startTime1);
                                    end3 = this.getMinutes(dayRecords[i].endTime1);
                                }
                                
                                let start4;
                                let end4;
                                if(dayRecords[i].startTime2 && dayRecords[i].endTime2){
                                    start4 = this.getMinutes(dayRecords[i].startTime2);
                                    end4 = this.getMinutes(dayRecords[i].endTime2);
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
                                    overLapMsg += '<ul style="list-style-type: initial;">The time entry you are attempting to save for <b>'+dayRecords[i].displayDate+'</b> is in conflict with the following time entries: ';
                                    
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
                }else if(dayRecords[i].taskType != 'Preparation time'  
                   && !(dayRecords[i].startTime1 && dayRecords[i].endTime1) && dayRecords[i].taskName == "Fringe-Holiday" && dayRecords[i].dayHours != null && (!dayRecords[i].dayId)){
                    cmp.set("v.isvalueChanged",true);
                }
                
            }
        }//end of outer for loop
        
        return overLapMsg;
    },
    FindTimeEntryChanges : function(cmp,type){
        var rowRecords = cmp.get("v.dayRecord").dayEntries;
        var changesMade = false;
        for(var i = 0;i < rowRecords.length;i++){
            let hrsEntered = (rowRecords[i].dayHours === 0 || rowRecords[i].dayHours) ? true : false;
            if((rowRecords[i].isNew && hrsEntered) 
               || (rowRecords[i].isUpdated && hrsEntered) 
               || (type == 'From Validation' && entries[j].dayId && hrsEntered)){
                changesMade = true;
            }
        }
        
        return changesMade;
    },
    fireBackClickEvent : function(cmp, event){
        var setEvent = cmp.getEvent("entryDetailAction");
        setEvent.setParams({"typeOfAction":"Back"});
        setEvent.fire();
    },
    saveTCDChanges : function(cmp){
        var timeRecords = cmp.get("v.dayRecord");
        var dayEntries = timeRecords.dayEntries;
        
        var dayList = [];
        
        var updatedTCDIds = [];
        
        var changesMade = false;
        var studentTimeChanged = false;
        var isUpdate = true;
        
        var detailMap = cmp.get("v.detailMap");
        var dliWLTHolidays = detailMap.dliWLTHolidays;
        var projectData = detailMap.projectData;
        
        for(var i = 0;i < dayEntries.length;i++){
            let hrsEntered = (dayEntries[i].dayHours == 0 || dayEntries[i].dayHours)? true : false;
            if((dayEntries[i].isNew && hrsEntered) 
               || (dayEntries[i].isUpdated && hrsEntered)){
                if(dayEntries[i].isNew){
                    dayEntries[i].status = 'Draft';
                    if(dayEntries[i].taskType != 'Preparation time'){
                        
                        //check the entry is in DLI-W LT holiday then set studen approval status as N/A
                        if(projectData.length > 0 && projectData[0].projectRTName == 'DLI_W_LT_Projects'){
                            
                            if(dliWLTHolidays.indexOf(dayEntries[i].dateVal) != -1 && dayEntries[i].lateCancellation){
                                dayEntries[i].studentApprovalStatus = 'N/A';
                            }else {
                                dayEntries[i].studentApprovalStatus = 'Submitted';
                            }
                            
                        }else if(projectData.length > 0 && ((projectData[0].projectRTName == 'DLI_W_LT_Projects' 
                                                             && dliWLTHolidays.indexOf(dayEntries[i].dateVal) == -1) || projectData[0].projectRTName != 'DLI_W_LT_Projects')){
                            
                            dayEntries[i].studentApprovalStatus = 'Submitted';
                        }
                    }
                    isUpdate = false;
                }else if(dayEntries[i].isUpdated && hrsEntered){
                    
                    if(dayEntries[i].status == 'Unposted' && !entries[j].isUnposted){
                        dayEntries[i].status = 'Draft';
                        if(dayEntries[i].taskType != 'Preparation time'){
                            
                            //check the entry is in DLI-W LT holiday then set studen approval status as N/A
                            if(projectData.length > 0 && projectData[0].projectRTName == 'DLI_W_LT_Projects'){
                                
                                if(dliWLTHolidays.indexOf(dayEntries[i].dateVal) != -1 && dayEntries[i].lateCancellation){
                                    dayEntries[i].studentApprovalStatus = 'N/A';
                                }else {
                                    dayEntries[i].studentApprovalStatus = 'Submitted';
                                }
                                
                            }else if(projectData.length > 0 && ((projectData[0].projectRTName == 'DLI_W_LT_Projects' 
                                                                 && dliWLTHolidays.indexOf(dayEntries[i].dateVal) == -1) || projectData[0].projectRTName != 'DLI_W_LT_Projects')){
                                
                                dayEntries[i].studentApprovalStatus = 'Submitted';
                            }
                        }
                    }
                    if(dayEntries[i].status == 'Rejected'){
                        dayEntries[i].status = 'Recalled';
                    }
                    updatedTCDIds.push(dayEntries[i].dayId);
                }
                changesMade = true;
                
                if(dayEntries[i].startTime1 == '--None--'){
                    dayEntries[i].startTime1 = null;
                }
                if(dayEntries[i].endTime1 == '--None--'){
                    dayEntries[i].endTime1 = null;
                }
                if(dayEntries[i].startTime2 == '--None--'){
                    dayEntries[i].startTime2 = null;
                }
                if(dayEntries[i].endTime2 == '--None--'){
                    dayEntries[i].endTime2 = null;
                }
                
                dayList.push(dayEntries[i]);
            }
        }
        
        console.log('::::::::dayList::::',dayList);
        console.log(':::::::changesMade::::',changesMade);
        console.log('::::::::updatedTCDIds::::',updatedTCDIds);
        
        //Student Time Table changes capture
        var studentList = [];
        var stuAttendance = timeRecords.studentEntries;
        for(var i = 0;i < stuAttendance.length;i++){
            if(stuAttendance[i].hours || stuAttendance[i].hours === 0){
                if((stuAttendance[i].isNew && (stuAttendance[i].hours || stuAttendance[i].hours === 0)) 
                   || (stuAttendance[i].isUpdated && (stuAttendance[i].hours || stuAttendance[i].hours === 0))
                  	|| stuAttendance[i].studentApprovalStatus == 'Recalled'){	//Add this status condition for W-007547 by NS
                    studentTimeChanged = true;
                    studentList.push(stuAttendance[i]);
                }
            }
        }
        console.log('::::::::studentList:::::::',studentList);
        //console.log('::::::isChanged::::',cmp.get("v.isvalueChanged"));
        
        var dt1 = this.apexDateFormatFunction(detailMap.selectedWeek.split(' to ')[0]);
        var dt2 = this.apexDateFormatFunction(detailMap.selectedWeek.split(' to ')[1]);
        
        var projectId = detailMap.projectId;
        
        var self = this;
        
        if(cmp.get("v.isvalueChanged") || studentTimeChanged){
            var param = {};
            param.startDate = dt1;
            param.endDate = dt2;
            param.conId = detailMap.contactId;
            param.timeDayJson = JSON.stringify(dayList);
            param.projectId = detailMap.projectId;
            param.actionType = 'Save';
            param.studentJson = JSON.stringify(studentList);
            param.updatedTCDs = updatedTCDIds;
            
            const server = cmp.find('server');
            const action = cmp.get('c.saveTimeEntryRecords');
            server.callServer(
                action,
                param,
                false,
                $A.getCallback(function(response){
                    if(!isUpdate) {
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
                    console.log('Error n comp',errors[0].message);
                    self.errorMsgDisplay(cmp,errors[0].message);
                }),
                false, 
                false,
                false
            );
        }
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
    inputValidationAction : function(cmp, invalidPrepDays) {
        var dayRecords = cmp.get("v.dayRecord");
        var stCmp = cmp.find("hrsInput1");
        console.log(Array.isArray(stCmp));
        for(let dayRecord of dayRecords.dayEntries){
            if(!dayRecord.dayHours && dayRecord.taskType == 'Preparation time' && dayRecord.dateVal == invalidPrepDays){
                $A.util.addClass(stCmp,'errorClass');
            }else{
                $A.util.removeClass(stCmp,"errorClass");
            }
        }
    }
})