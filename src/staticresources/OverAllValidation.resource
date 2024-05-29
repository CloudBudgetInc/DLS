window.overAllValidationMethod =  function(dayRecords,attendance,projectData,plannedDaysOffMap,dliWLTHolidays,federalHolidays){
    
    console.log('enter js file');
    
    var resultObj = {};
    
    //Check for Actual Class hrs input values - hrs entered & time values are entered or not
    resultObj = checkForActualClassHrsValidation(dayRecords,attendance,projectData,'Actual Entry Check');
    if(!resultObj.isValid){
        return resultObj;
    }
    
    //check for student time, if class hrs is entered & student hrs are not entered through validation
    resultObj = checkForActualClassHrsValidation(dayRecords,attendance,projectData,'Student Entry Check');
    if(!resultObj.isValid){
        return resultObj;
    }
    
    //check entered hours are in correct format, if not throw validation msg
    resultObj = checkHrsValidOrNot(dayRecords,attendance);
    if(!resultObj.isValid){
        return resultObj;
    }
    
    // Check for student notes are entered are not
    resultObj = checkForStudentTimeValidation(dayRecords,attendance,projectData);
    if(!resultObj.isValid){
        return resultObj;
    }
    
    resultObj = checkForStudentAttendanceValidation(attendance);
    if(!resultObj.isValid){
        return resultObj;
    }
    
    //Work Item W-001730
    //Check for the time & hours difference and throw validation
    resultObj = hrsTimeValidation(dayRecords);
    if(!resultObj.isValid){
        return resultObj;
    }
    
    //Work Item W-001730
    //Start Time & End Time must not overlap with other time entries time related validation
    resultObj = timeOverlapValidation(dayRecords);
    if(!resultObj.isValid){
        return resultObj;
    }
    
    //check the time & hours values both are entered are not if not throw validation msg
    resultObj = checkHrsEnteredOrNot(dayRecords);
    if(!resultObj.isValid){
        return resultObj;
    }
    
    //Check the entries are having end time which are not greater than the current time if not throw validation
    resultObj = checkEndTimeValidOrNot(dayRecords);
    if(!resultObj.isValid){
        return resultObj;
    }
    
    //Check the Planned Days off record for if they have entered hrs for leave days
    resultObj = checkForPlannedDaysOff(dayRecords,plannedDaysOffMap);
    if(!resultObj.isValid){
        return resultObj;
    }
    
    //DLI-W LT project does not have holiday for that date & late cancellation is checked
    //If they entered prep time for that class, then show msg
    //This validation is commented because, they are billing for all type of late cancellation related prep entries - W-004950
    /*resultObj = checkDLIHavePrepEntry(dayRecords,dliWLTHolidays,projectData);
	if(!resultObj.isValid){
		return resultObj;
	}*/
    
    
    resultObj = checkForTimeEnteredOnFederalHolidays(dayRecords, federalHolidays);	
    if(!resultObj.isValid){
        return resultObj;
    }

    //W-007882 - Prep Time Entry Warning Message Request in DLS Online
    resultObj = validatePreparationHours(dayRecords,projectData.defaultCostRateRateType);
    if(!resultObj.isValid){
        return resultObj;
    }
    
    return resultObj;
    
}

function checkForActualClassHrsValidation(dayRecords,attendance,projectData,type){
    console.log('::::::::type:::',type);
    var isValid = true;
    
    var resultObj = {};
    
    if(type == 'Actual Entry Check' && projectData[0].projectRTName != 'EFL_Projects') {
        for(var i = 0;i < dayRecords.length;i++){
            var entries = dayRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){                
                if((entries[j].isNew && entries[j].dayHours) || (entries[j].isUpdated && entries[j].dayHours)){  
                    let isFringeTaskWithoutTime = (dayRecords[i].taskType == 'fringe' && (dayRecords[i].taskName == 'Fringe-PTO' || dayRecords[i].taskName == 'Fringe-Holiday'));               
                    if((dayRecords[i].taskType != 'Preparation time')){
                        if((!isFringeTaskWithoutTime) && (!entries[j].startTime1 || !entries[j].endTime1)){
                            isValid = false;
                        }
                    }else if(dayRecords[i].taskType == 'Preparation time' && (dayRecords[i].timeType == 'AM' || dayRecords[i].timeType == 'Single')){
                        if(!entries[j].startTime1 || !entries[j].endTime1){
                            isValid = false;
                        }
                    }
                    
                    if(entries[i].taskType == 'Preparation time' && dayRecords[i].timeType == 'PM'){
                        if(!entries[j].startTime2 || !entries[j].endTime2){
                            isValid = false;
                        }
                    }
                }
            }
        }
    }else if(type == 'Student Entry Check'){
        var dayMap = {};
        
        for(var i = 0;i < dayRecords.length;i++){
            if(dayRecords[i].taskType != 'Preparation time'){
                var entries = dayRecords[i].dayEntries;
                for(var j = 0;j < entries.length;j++){
                    var hrsExist = (entries[j].dayHours === 0 || entries[j].dayHours) ? true : false;
                    if(hrsExist){ //if((entries[j].isNew && hrsExist) || (entries[j].isUpdated && hrsExist)){
                        if(!dayMap[entries[j].dateVal]){
                            dayMap[entries[j].dateVal] = true;
                        }
                    }
                }
            }
        }
        //console.log('::::::::::::dayMap::::',dayMap);
        for(var i = 0;i < attendance.length;i++){
            var entry = attendance[i].entries;
            for(var j = 0;j < entry.length;j++){
                var hrsExist = (entry[j].hours === 0 || entry[j].hours) ? true : false;
                if(dayMap[entry[j].dateVal] && !hrsExist && !entry[j].isHrsDisabled){
                    isValid = false;				  
                }
            }
        }
    }
    //console.log(':::::::isValid::::',isValid);
    //console.log(':::::::type::::',type);
    
    resultObj.isValid = isValid;
    
    if(!isValid && type == 'Actual Entry Check'){
        resultObj.message = 'Please enter the Start Time and End Time values for the entries.';
        resultObj.title = 'Start Time and End Time Entry';
        resultObj.isValidInput = false;
    }else if(!isValid && type == 'Student Entry Check'){

        if(projectData && !projectData[0].noStudentApproval && (!(projectData[0].projectRTName == 'DLI_W_LT_Projects' && projectData[0].noStudentHrsVerification && projectData[0].dliProType == 'EI'))){
            resultObj.message = 'Please record hours for each student listed in the Student Time table. If any students were absent, please enter 0.00 for that student';
            resultObj.title = 'Warning';
            resultObj.isValidInput = false;
        }else {
            resultObj.isValid = true;
            resultObj.isValidInput = true;
        }
    }
    
    return resultObj;
}

function checkHrsValidOrNot(dayRecords,attendance){
    
    var isValidHrs = true;
    var resultObj = {};
    
    //For actual class hours validation
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
    
    resultObj.isValid = isValidHrs;
    if(!isValidHrs){
        resultObj.message = 'Allowed decimal values are 00, 25, 50, 75. Please correct the hours which are not in this format.';
        resultObj.title = 'Warning';
        resultObj.isValidInput = false;
    }
    
    return resultObj;
}

//method to check the comments entered or not on Save & Submit btn click
function checkForStudentTimeValidation(dayRecords,attendance,projectData){
    
    var dayMap = {};
    var reasonEntered = true;
    var atteStatusSelectedForSameEntry = true;
    var atteStatusSelectedForDiffEntry = true;
    var valAttStatusForDiffEntry = ['Absent','Left Early','Late'];
    var valAttStatusForSameEntry = ['Absent','Left Early','Late','No Class'];
    var valAttForZeroEntry = ['Absent','No Class']
    var atteStatusSelectedValue = '';
    var atteHoursZeroForDiffEntry = true;
    var atteHoursZeroForSameEntry = true;
        
    var resultObj = {};
    
    for(var i = 0;i < dayRecords.length;i++){
        if(dayRecords[i].taskType != 'Preparation time'){
            var entries = dayRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                var hrsExist = (entries[j].dayHours === 0 || entries[j].dayHours) ? true : false;
                if(hrsExist){ //(entries[j].isNew && hrsExist) || (entries[j].isUpdated && hrsExist)
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
            var hrsExist = (entry[j].hours === 0 || entry[j].hours) ? true : false;
            if(hrsExist){ //(entry[j].isNew && hrsExist) || (entry[j].isUpdated && hrsExist)){
                if(dayMap[entry[j].dateVal] != null || dayMap[entry[j].dateVal] != ''){
                    var dayHrs = dayMap[entry[j].dateVal];
                    
                    if(projectData.length > 0 && !projectData[0].noStudentHrsVerification){
                        
                        if(entry[j].hours != dayHrs || (entry[j].hours === 0.00 && dayHrs != 0.00)){
                            if(!entry[j].comments){
                                reasonEntered = false;
                            }
                            
                            if(entry[j].hours === 0.00 && entry[j].attendance != 'Absent'){
                                atteHoursZeroForDiffEntry = false;
                            }
                            
                            if(entry[j].attendance != '' && entry[j].attendance != null ){
                                if((entry[j].hours != dayHrs && entry[j].hours != 0.00 && entry[j].attendance == 'Absent') || (!valAttStatusForDiffEntry.includes(entry[j].attendance))){
                                    atteStatusSelectedForDiffEntry = false;
                                }
                            }
                        }else if(entry[j].hours === dayHrs){
                            
                            if(entry[j].attendance != '' && entry[j].attendance != null){
                                
                                if(entry[j].hours === 0.00){
                                    if(!entry[j].comments){
                                        reasonEntered = false;
                                    }
                                    if(!valAttForZeroEntry.includes(entry[j].attendance)){
                                        atteHoursZeroForSameEntry = false;
                                    }
                                }else if(valAttStatusForSameEntry.includes(entry[j].attendance)){
                                    atteStatusSelectedForSameEntry = false;
                                    
                                }
                                atteStatusSelectedValue = entry[j].attendance;
                            }
                        }
                    }
                }
            }
        }
    }
    console.log(':::::::::::reasonEntered:::',reasonEntered);
    console.log(':::::::::::atteStatusSelectedForSameEntry:::',atteStatusSelectedForSameEntry);
    console.log(':::::::::::atteStatusSelectedForDiffEntry:::',atteStatusSelectedForDiffEntry);
    console.log(':::::::::::atteStatusSelectedValue:::',atteStatusSelectedValue);

    
    
    
    resultObj.isValid = (reasonEntered && atteStatusSelectedForDiffEntry && atteStatusSelectedForSameEntry && atteHoursZeroForDiffEntry && atteHoursZeroForSameEntry);
    if(!reasonEntered || !atteStatusSelectedForSameEntry || !atteStatusSelectedForDiffEntry || !atteHoursZeroForDiffEntry || !atteHoursZeroForSameEntry){
        resultObj.message = '';
        if(!reasonEntered){
            resultObj.message += "Please use the 'Note' button below the Student Hours to explain why the Student Hours are different from the instruction hours or are zero.";
        }else if(!atteStatusSelectedForDiffEntry || !atteHoursZeroForDiffEntry){
            resultObj.message += "You entered different hours for the Instructor and Student sections";
            if(!atteHoursZeroForDiffEntry){
                resultObj.message += " but entered Student hours are zero. Please change the Attendance field to <b>Absent</b> .";
            }else if(!atteStatusSelectedForDiffEntry){
                resultObj.message += ". Please change the Attendance field to <b>Left Early</b>, or <b>Late</b>.";
            }
        }else if(!atteStatusSelectedForSameEntry || !atteHoursZeroForSameEntry){
            resultObj.message += "You entered same hours for the Instructor and Student sections";
            if(!atteHoursZeroForSameEntry){
                resultObj.message += " but entered Student hours are zero. Please change the Attendance field to <b>Absent</b> .";
            }else if(!atteStatusSelectedForSameEntry){
                resultObj.message += " but the Attendance field is <b>"+atteStatusSelectedValue+"</b>. Please change the Attendance to <b>Present</b> or update the Student Hours to the correct hours attended or enter 0 if the Student was absent.";
            }
        }
        resultObj.title = 'Warning';
        resultObj.isValidInput = false;
    }
    
    return resultObj;
}

//method to check the attendance entered or not on Save & Submit btn click
function checkForStudentAttendanceValidation(attendance){
    
    var resultObj = {isValid: true};
    
    //Now iterate the attendance table & check notes entered or not
    for(var i = 0;i < attendance.length;i++){
        var entry = attendance[i].entries;
        for(var j = 0;j < entry.length;j++){
            var hrsExist = (entry[j].hours === 0 || entry[j].hours) ? true : false;
            if(hrsExist && !entry[j].attendance){ //(entry[j].isNew && hrsExist) || (entry[j].isUpdated && hrsExist)){
                resultObj.isValid = false;
            }
        }
    }
    
    
    if(!resultObj.isValid){
        resultObj.message = "Please enter Attendance for each student listed in the Student Time table.";
        resultObj.title = 'Warning';
        resultObj.isValidInput = false;
    }
    
    return resultObj;
}

//Method to check the class hours & time range is greater than or equal
//If time selected is less than the hrs then throw validation on save btn click 
function hrsTimeValidation(dayRecords){
    
    var validationMsg = '';
    var resultObj = {};
    
    for(var i = 0;i < dayRecords.length;i++){
        var entries = dayRecords[i].dayEntries;
        for(var j = 0;j < entries.length;j++){
            
            if((entries[j].isNew && entries[j].dayHours) || (entries[j].isUpdated && entries[j].dayHours)){
                if(dayRecords[i].taskType != 'Preparation time'){
                    if(entries[j].startTime1 && entries[j].endTime1){
                        
                        var startTimeMinute = getMinutes(entries[j].startTime1, entries[j].endTime1 == '12:00 AM');
                        var endTimeMinute = getMinutes(entries[j].endTime1, entries[j].endTime1 == '12:00 AM');
                        
                        //W-006600 - Changes By Dhinesh on 09-04-2021 - validation change when the endtime is 12:00 AM
                        
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
                        var isEndTime1 = entries[j].endTime1 == '12:00 AM',
                            isEndTime2 = entries[j].endTime2 == '12:00 AM';
                        
                        if(dayRecords[i].timeType == 'Both'){
                            var start1;
                            var end1;
                            var start2;
                            var end2;							
                            
                            if((entries[j].startTime1 && entries[j].endTime1) && (entries[j].startTime2 && entries[j].endTime2)){
                                
                                start1 = getMinutes(entries[j].startTime1, isEndTime1);
                                end1 = getMinutes(entries[j].endTime1, isEndTime1);
                                
                                start2 = getMinutes(entries[j].startTime2, isEndTime2);
                                end2 = getMinutes(entries[j].endTime2, isEndTime2);
                                
                                var selectedHrs = ((end1 - start1) / 60) + ((end2 - start2) / 60);
                                if(selectedHrs < entries[j].dayHours ){
                                    if(!validationMsg){
                                        validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                    }else {
                                        validationMsg += '<li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                    }
                                }
                            }else if(entries[j].startTime1 && entries[j].endTime1){
                                start1 = getMinutes(entries[j].startTime1, isEndTime1);
                                end1 = getMinutes(entries[j].endTime1, isEndTime1);
                                
                                if(((end1 - start1) / 60) < entries[j].dayHours ){
                                    if(!validationMsg){
                                        validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                    }else {
                                        validationMsg += '<li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                    }
                                }
                            }else if(entries[j].startTime2 && entries[j].endTime2){
                                start2 = getMinutes(entries[j].startTime2, isEndTime2);
                                end2 = getMinutes(entries[j].endTime2, isEndTime2);
                                
                                if(((end2 - start2) / 60) < entries[j].dayHours ){
                                    if(!validationMsg){
                                        validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                    }else {
                                        validationMsg += '<li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                    }
                                }
                            }
                        }else if(dayRecords[i].timeType == 'Single' && (entries[j].startTime1 && entries[j].endTime1)){
                            var start1 = getMinutes(entries[j].startTime1, isEndTime1);
                            var end1 = getMinutes(entries[j].endTime1, isEndTime1);
                            
                            if(((end1 - start1) / 60) < entries[j].dayHours ){
                                if(!validationMsg){
                                    validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                }else {
                                    validationMsg += '<li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
                                }
                            }
                        }/*else if(dayRecords[i].timeType == 'PM' && (entries[j].startTime2 && entries[j].endTime2)){
							var start2 = getMinutes(entries[j].startTime2);
							var end2 = getMinutes(entries[j].endTime2);
							console.log(start2, end2);
							if(((end2 - start2) / 60) < entries[j].dayHours ){
								if(!validationMsg){
									validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
								}else {
									validationMsg += '<li>The number of hours entered for <b>'+entries[j].taskName+'</b> for <b>'+entries[j].displayDate+'</b> is greater than the time range(s) entered.</li>';
								}
							}
						}*/
                    }
                    
                }// end of preparation time else
            }
        }//end of inner for loop
    }//end of outer for loop
    
    if(validationMsg){
        
        validationMsg += '<br/>Please correct your entry in order to Save.</ul>';
        
        resultObj.isValid = false;
        resultObj.message = validationMsg;
        resultObj.title = 'Warning';
        resultObj.isValidInput = false;
    }else {
        resultObj.isValid = true;
        resultObj.isValidInput = true;
    }
    
    //console.log('::::hrs:::time::::::validation::::',validationMsg);
    
    return resultObj;
}

//Method to check time overlap in entire table
function timeOverlapValidation(dayRecords){
    
    var timeOverlapMsg = '';
    var resultObj = {};
    
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
                        let start1 = getMinutes(dateTimeMap[entries[j].dateVal].startTime1);
                        let end1 = getMinutes(dateTimeMap[entries[j].dateVal].endTime1);
                        
                        let start2;
                        let end2;
                        if(entries[j].startTime1 && entries[j].endTime1){
                            start2 = getMinutes(entries[j].startTime1);
                            end2 = getMinutes(entries[j].endTime1);
                        }
                        
                        let start3;
                        let end3;
                        if(entries[j].startTime2 && entries[j].endTime2){
                            start3 = getMinutes(entries[j].startTime2);
                            end3 = getMinutes(entries[j].endTime2);
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
    
    if(timeOverlapMsg){
        resultObj.isValid = false;
        resultObj.message = timeOverlapMsg;
        resultObj.title = 'Warning';
        resultObj.isValidInput = false;
    }else{
        resultObj.isValid = true;
        resultObj.isValidInput = true;
    }
    
    return resultObj;
}

function checkHrsEnteredOrNot(dayRecords){
    
    var isValid = true;
    
    var resultObj = {};
    
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
                isValid = false;
            }
        }
    }
    //console.log('::::::validEntryAvailable:::isValid:::::',isValid);
    
    resultObj.isValid = isValid;
    
    if(!isValid){
        resultObj.message = 'Please enter hours for the time entry associated to the Start Time and End Time entered.';
        resultObj.title = 'Warning';
        resultObj.isValidInput = false;
    }
    
    return resultObj;
}

function checkEndTimeValidOrNot(dayRecords){
    
    var isvalidEndTime = true;
    
    var resultObj = {};
    
    //Get current time value to compare with end time
    //W-001894
    let currentTimezone = moment.tz.guess();
    let currentTime = moment.tz(currentTimezone);
    
    /*var dt = new Date();
	var h =  dt.getHours(), m = dt.getMinutes();
	var currentTime = (h > 12) ? ('0'+ (h-12) + ':' + m +' PM') : ('0'+h+ ':' + m +' AM');
	
	var currentDt = new Date();*/
    
    for(var i = 0;i < dayRecords.length;i++){
        var entries = dayRecords[i].dayEntries;
        for(var j = 0;j < entries.length;j++){
            if((entries[j].isNew && entries[j].dayHours) || (entries[j].isUpdated && entries[j].dayHours)){
                
                let scheduleTimezone = dayRecords[i].scheduleTimezone;
                
                if(entries[j].endTime1 && entries[j].endTime1 != '--None--'){
                    
                    var dt = dateConstruction(entries[j].dateVal,entries[j].endTime1);
                    let columnTime = moment.tz(dt,scheduleTimezone);
                    
                    if(currentTime <= columnTime){
                        isvalidEndTime = false;    
                    }
                }
                
                if(entries[j].endTime2 && entries[j].endTime2 != '--None--'){
                    var dt = dateConstruction(entries[j].dateVal,entries[j].endTime2);
                    let columnTime = moment.tz(dt,scheduleTimezone);
                    
                    if(currentTime <= columnTime){
                        isvalidEndTime = false;    
                    }
                }
                
                /*if(dateComparison(currentDt,columnDt) && entries[j].endTime1 && entries[j].endTime1 != '--None--' && getMinutes(currentTime) < getMinutes(entries[j].endTime1)){
					isvalidEndTime = false;
				}
				
				if(dateComparison(currentDt,columnDt) && entries[j].endTime2 && entries[j].endTime2 != '--None--' && getMinutes(currentTime) < getMinutes(entries[j].endTime2)){
					isvalidEndTime = false;
				}*/
            }
        }
    }
    //console.log('::::::isvalidEndTime::',isvalidEndTime);
    
    resultObj.isValid = isvalidEndTime;
    
    if(!isvalidEndTime){
        
        resultObj.message = 'You have selected an End Time that is in the future. Users are not allowed to enter time for a future date or time. <br/>Please correct your entry or wait until the end of the day to enter your time.';
        resultObj.title = 'Warning';
        resultObj.isValidInput = false;
    }
    
    return resultObj;
}

function checkForPlannedDaysOff(dayRecords,plannedOffMap){ 
    
    var daysOffMsg = ''; 
    
    var resultObj = {};
    
    if(plannedOffMap){
        for(var i = 0;i < dayRecords.length;i++){
            var entries = dayRecords[i].dayEntries; 
            for(var j = 0;j < entries.length;j++){
                if((!(dayRecords[i].taskName == 'Fringe-PTO' && entries[j].payrollItem == 'PTO')) && (entries[j].isNew && entries[j].dayHours) || (entries[j].isUpdated && entries[j].dayHours)){
                    if(plannedOffMap[entries[j].dateVal]){
						   
                        daysOffMsg += '<ul style="padding-left:2rem;"><li style="list-style-type: initial;text-align:left;">The time you entered for <b>'+entries[j].displayDate+'</b> conflicts with a planned day off for the same date.</li>';
                        daysOffMsg += '<li>'+plannedOffMap[entries[j].dateVal].daysOffDate+' / '+plannedOffMap[entries[j].dateVal].contactName+' / '+plannedOffMap[entries[j].dateVal].description+'</li></ul>';
                    }
                }
            }
        }
    }
    
    if(daysOffMsg){
        //daysOffMsg += '<br/>Are you sure you would like to save this time entry?';
        
        resultObj.isValid = false;
        resultObj.message = daysOffMsg;
        resultObj.title = 'Warning';
        resultObj.isValidInput = true;
        
    }else {
        resultObj.isValid = true;
        resultObj.isValidInput = true;
    }
    
    return resultObj;
}

function checkDLIHavePrepEntry(dayRecords,dliWLTHolidays,projectData){
    
    var projectRTName = projectData.length > 0? projectData[0].projectRTName : '';
    var lateCancellationMap = {};
    
    var isPrepEntryExist = false;
    
    var resultObj = {};
    
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
    
    if(isPrepEntryExist){
        
        resultObj.isValid = false;
        resultObj.message = 'Preparation Time can not be performed for sessions that have been cancelled, please clear the preparation time and then save.  If you have any questions, please submit a case on contact your Language Training Supervisor';
        resultObj.title = 'Warning';
        resultObj.isValidInput = false;
        
    }else {
        resultObj.isValid = true;
        resultObj.isValidInput = true;
    }
    
    return resultObj;
}

function getMinutes(time, isEndTime){
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
        if(m[0] == '12'  && !isEndTime){
            t[0] = 0;
        } else {
            t[0] = m[0];
        } 				
    } else if(h[1] == 'PM'){
        if(m[0] == '12'){
            t[0] = 12;
        } else {
            t[0] = !isEndTime ? parseInt(m[0]) + 12 :  parseInt(m[0]);
        }
    }
    var hrs = parseInt(t[0]) * 60,
        min = !isEndTime ? 60 + parseInt(t[1]) : parseInt(t[1]);
    
    return hrs+min;
}

function dateComparison(currentDt,columnDt){
    if(currentDt.getFullYear() <= columnDt.getFullYear() && currentDt.getMonth() <= columnDt.getMonth() 
       && currentDt.getDate() <= columnDt.getDate()){
        return true;
    }else {
        return false;
    }
}
function dateConstruction(dateVal,time){
    
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
}

function checkForTimeEnteredOnFederalHolidays(dayRecords, federalHolidays){
    var resultObj = {isValid: true};
    var dateVal,
        isValid = true;
    for(var i = 0;i < dayRecords.length;i++){
        if(dayRecords[i].taskType != 'Preparation time'){
            var entries = dayRecords[i].dayEntries;
            for(var j = 0;j < entries.length;j++){
                var hrsExist = (entries[j].dayHours === 0 || entries[j].dayHours) ? true : false;
                if(hrsExist && (entries[j].isNew || entries[j].isUpdated) && federalHolidays.indexOf(entries[j].dateVal) != -1){ 
                    dateVal = entries[j].dateVal;
                    isValid = false; 
                }
            }
        }
    }
    
    if(!isValid){
        resultObj.message = 'This date ('+ formatDate(dateVal) +') is a Federal Holiday, are you sure that you want to enter hours?';
        resultObj.title = 'Warning';
        resultObj.isHasTimeInFederalHoliday = true;
    }
    
    return resultObj;
}

function formatDate(inputDate){
    
    var dateArr = inputDate.split("-");
    return dateArr[1]+'/'+dateArr[2]+'/'+dateArr[0];    
}

//W-007882 - Prep Time Entry Warning Message Request in DLS Online
function validatePreparationHours(dayRecords, defaultCostRateRateType){
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
                    invalidPrep.push(formatDate(entries[j].dateVal));
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
}