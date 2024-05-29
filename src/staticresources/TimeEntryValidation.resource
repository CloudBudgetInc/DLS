window.overAllValidationForMobile =  function(dayRecords,attendance,projectData,plannedDaysOffMap,dliWLTHolidays, federalHolidays){
	
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

	//Check if they have entered hrs for Federal holidays
	resultObj = checkForFederalHolidays(dayRecords,federalHolidays);
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
	
	if(type == 'Actual Entry Check') {
		for(var i = 0;i < dayRecords.length;i++){
			if((dayRecords[i].isNew && dayRecords[i].dayHours) || (dayRecords[i].isUpdated && dayRecords[i].dayHours)){
				if(dayRecords[i].taskType != 'Preparation time' && ((dayRecords[i].taskType == 'fringe' && dayRecords[i].taskName == 'Fringe-PTO') || (dayRecords[i].taskType == 'fringe' && dayRecords[i].taskName == 'Fringe-Holiday'))){
					if(!dayRecords[i].startTime1 || !dayRecords[i].endTime1){
						isValid = false;
					}
				}else if(dayRecords[i].taskType == 'Preparation time' && (dayRecords[i].timeType == 'AM' || dayRecords[i].timeType == 'Single')){
					if(!dayRecords[i].startTime1 || !dayRecords[i].endTime1){
						isValid = false;
					}
				}
				
				if(dayRecords[i].taskType == 'Preparation time' && dayRecords[i].timeType == 'PM'){
					if(!dayRecords[i].startTime2 || !dayRecords[i].endTime2){
						isValid = false;
					}
				}
			}
		}
	}else if(type == 'Student Entry Check'){
		var dayMap = {};
		
		for(var i = 0;i < dayRecords.length;i++){
			if(dayRecords[i].taskType != 'Preparation time'){
				if((dayRecords[i].isNew && dayRecords[i].dayHours) || (dayRecords[i].isUpdated && dayRecords[i].dayHours)){
					if(!dayMap[dayRecords[i].dateVal]){
						dayMap[dayRecords[i].dateVal] = dayRecords[i].dayHours;
					}
				}
			}
		}
		//console.log('::::::::::::dayMap::::',dayMap);
		for(var i = 0;i < attendance.length;i++){
			var hrsExist = (attendance[i].hours === 0 || attendance[i].hours) ? true : false;
			if(dayMap[attendance[i].dateVal] && !hrsExist && !attendance[i].isHrsDisabled){
				isValid = false;
			}
		}
	}
	//console.log(':::::::isValid::::',isValid);
	//console.log(':::::::type::::',type);
	
	resultObj.isValid = isValid;
	
	if(!isValid && type == 'Actual Entry Check'){
		resultObj.message = 'Please enter the Start Time and End Time values for the entries.';
		resultObj.title = 'Start Time and End Time Entry';
	}else if(!isValid && type == 'Student Entry Check'){
		
        if(projectData && !projectData[0].noStudentApproval && (!(projectData[0].projectRTName == 'DLI_W_LT_Projects' && projectData[0].noStudentHrsVerification && projectData[0].dliProType == 'EI'))){
			resultObj.message = 'Please record hours for each student listed in the Student Time table. If any students were absent, please enter 0.00 for that student';
			resultObj.title = 'Warning';
		}else {
			resultObj.isValid = true;
		}
	}
	
	return resultObj;
}

function checkHrsValidOrNot(dayRecords,attendance){
	
	var isValidHrs = true;
	var resultObj = {};
	
	//For actual class hours validation
	for(var i = 0;i < dayRecords.length;i++){
		var hrsExist = (dayRecords[i].dayHours === 0 || dayRecords[i].dayHours) ? true : false;
		
		if(hrsExist){
			
			var hour = ((parseFloat(dayRecords[i].dayHours) || 0)  * 100) % 100;
			
			if(!(hour == 25 || hour == 50 || hour == 75 || hour == 0)){
				isValidHrs = false;
			}
		}
	}
	
	//student hrs valid check
	for(var i = 0;i < attendance.length;i++){
		var hrsExist = (attendance[i].hours === 0 || attendance[i].hours) ? true : false;
		if(hrsExist){
			var hour = ((parseFloat(attendance[i].dayHours) || 0)  * 100) % 100;
			
			if(!(hour == 25 || hour == 50 || hour == 75 || hour == 0)){
				isValidHrs = false;
			}
		}
	}
	
	resultObj.isValid = isValidHrs;
	if(!isValidHrs){
		resultObj.message = 'Allowed decimal values are 00, 25, 50, 75. Please correct the hours which are not in this format.';
		resultObj.title = 'Warning';
	}
	
	return resultObj;
}

//method to check the comments entered or not on Save & Submit btn click
function checkForStudentTimeValidation(dayRecords,attendance,projectData){
	
	var dayMap = {};
	var reasonEntered = true;
	
	var resultObj = {};
	
	for(var i = 0;i < dayRecords.length;i++){
		if(dayRecords[i].taskType != 'Preparation time'){
			var hrsExist = (dayRecords[i].dayHours === 0 || dayRecords[i].dayHours) ? true : false;
			if((dayRecords[i].isNew && hrsExist) || (dayRecords[i].isUpdated && hrsExist)){
				if(!dayMap[dayRecords[i].dateVal]){
					dayMap[dayRecords[i].dateVal] = dayRecords[i].dayHours;
				}
			}
		}
	}
	
	//console.log(':::::::dayMap::::',JSON.stringify(dayMap));
	
	//Now iterate the attendance table & check notes entered or not
	for(var i = 0;i < attendance.length;i++){
		var hrsExist = (attendance[i].hours === 0 || attendance[i].hours) ? true : false;
		if((attendance[i].isNew && hrsExist) || (attendance[i].isUpdated && hrsExist)){
			if(dayMap[attendance[i].dateVal] != null || dayMap[attendance[i].dateVal] != ''){
				var dayHrs = dayMap[attendance[i].dateVal];
				if((attendance[i].hours != dayHrs || attendance[i].hours === 0.00) && !attendance[i].comments
				  && projectData.length > 0 && !projectData[0].noStudentHrsVerification){
					reasonEntered = false;
				}
			}
		}
	}
	
	console.log(':::::::::::reasonEntered:::',reasonEntered);
	
	resultObj.isValid = reasonEntered;
	if(!reasonEntered){
		resultObj.message = 'Please enter the comments for student time values which are mismatch with actual class hours or zero';
		resultObj.title = 'Warning';		
	}
	
	return resultObj;
}

//method to check the attendance entered or not on Save & Submit btn click
function checkForStudentAttendanceValidation(attendance){
	
	var resultObj = {isValid: true};
	
	//Now iterate the attendance table & check notes entered or not
	for(var i = 0;i < attendance.length;i++){
		var hrsExist = (attendance[i].hours === 0 || attendance[i].hours) ? true : false;
		if(hrsExist && !attendance[i].attendance){ //(entry[j].isNew && hrsExist) || (entry[j].isUpdated && hrsExist)){
			resultObj.isValid = false;
		}
	}
	
	
	if(!resultObj.isValid){
		resultObj.message = "Please enter Attendance for each student listed in the Student Time table.";
		resultObj.title = 'Warning';
	}
	
	return resultObj;
}

//Method to check the class hours & time range is greater than or equal
//If time selected is less than the hrs then throw validation on save btn click 
function hrsTimeValidation(dayRecords){
	
	var validationMsg = '';
	var resultObj = {};
	
	for(var i = 0;i < dayRecords.length;i++){
		if((dayRecords[i].isNew && dayRecords[i].dayHours) || (dayRecords[i].isUpdated && dayRecords[i].dayHours)){
			if(dayRecords[i].taskType != 'Preparation time'){
				if(dayRecords[i].startTime1 && dayRecords[i].endTime1){
					
					var startTimeMinute = getMinutes(dayRecords[i].startTime1, dayRecords[i].endTime1 == '12:00 AM');
					var endTimeMinute = getMinutes(dayRecords[i].endTime1, dayRecords[i].endTime1 == '12:00 AM');
					
					var selectedMinuts = (endTimeMinute - startTimeMinute);
					var actualHrsMinuts = dayRecords[i].dayHours * 50;
					
					//Updated the logic based on recent disscussion on August 22 2019
					//Need to exclude this validation if the time difference & hrs values are 10mins different
					//We allow user to take 10mints break for each hours
					
					if(selectedMinuts < actualHrsMinuts){
						if(!validationMsg){
							validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+dayRecords[i].taskName+'</b> for <b>'+dayRecords[i].displayDate+'</b> is greater than the time range entered.</li>';
						}else {
							validationMsg += '<li>The number of hours entered for <b>'+dayRecords[i].taskName+'</b> for <b>'+dayRecords[i].displayDate+'</b> is greater than the time range entered.</li>';
						}
					}
				}
			}else {
				
				if(dayRecords[i].taskType == 'Preparation time'){
					var isEndTime1 = dayRecords[i].endTime1 == '12:00 AM',
					    isEndTime2 = dayRecords[i].endTime2 == '12:00 AM';

					if(dayRecords[i].timeType == 'Both'){
						var start1;
						var end1;
						var start2;
						var end2;
						if((dayRecords[i].startTime1 && dayRecords[i].endTime1) && (dayRecords[i].startTime2 && dayRecords[i].endTime2)){
							start1 = getMinutes(dayRecords[i].startTime1, isEndTime1);
							end1 = getMinutes(dayRecords[i].endTime1, isEndTime1);
							
							start2 = getMinutes(dayRecords[i].startTime2, isEndTime2);
							end2 = getMinutes(dayRecords[i].endTime2, isEndTime2);
							
							var selectedHrs = ((end1 - start1) / 60) + ((end2 - start2) / 60);
							if(selectedHrs < dayRecords[i].dayHours ){
								if(!validationMsg){
									validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+dayRecords[i].taskName+'</b> for <b>'+dayRecords[i].displayDate+'</b> is greater than the time range(s) entered.</li>';
								}else {
									validationMsg += '<li>The number of hours entered for <b>'+dayRecords[i].taskName+'</b> for <b>'+dayRecords[i].displayDate+'</b> is greater than the time range(s) entered.</li>';
								}
							}
						}else if(dayRecords[i].startTime1 && dayRecords[i].endTime1){
							start1 = getMinutes(dayRecords[i].startTime1, isEndTime1);
							end1 = getMinutes(dayRecords[i].endTime1, isEndTime1);
							
							if(((end1 - start1) / 60) < dayRecords[i].dayHours ){
								if(!validationMsg){
									validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+dayRecords[i].taskName+'</b> for <b>'+dayRecords[i].displayDate+'</b> is greater than the time range(s) entered.</li>';
								}else {
									validationMsg += '<li>The number of hours entered for <b>'+dayRecords[i].taskName+'</b> for <b>'+dayRecords[i].displayDate+'</b> is greater than the time range(s) entered.</li>';
								}
							}
						}else if(dayRecords[i].startTime2 && dayRecords[i].endTime2){
							start2 = getMinutes(dayRecords[i].startTime2);
							end2 = getMinutes(dayRecords[i].endTime2);
							
							if(((end2 - start2) / 60) < dayRecords[i].dayHours ){
								if(!validationMsg){
									validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+dayRecords[i].taskName+'</b> for <b>'+dayRecords[i].displayDate+'</b> is greater than the time range(s) entered.</li>';
								}else {
									validationMsg += '<li>The number of hours entered for <b>'+dayRecords[i].taskName+'</b> for <b>'+dayRecords[i].displayDate+'</b> is greater than the time range(s) entered.</li>';
								}
							}
						}
					}else if(dayRecords[i].timeType == 'Single' && (dayRecords[i].startTime1 && dayRecords[i].endTime1)){
						var start1 = getMinutes(dayRecords[i].startTime1, isEndTime1);
						var end1 = getMinutes(dayRecords[i].endTime1, isEndTime1);
						
						if(((end1 - start1) / 60) < dayRecords[i].dayHours ){
							if(!validationMsg){
								validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+dayRecords[i].taskName+'</b> for <b>'+dayRecords[i].displayDate+'</b> is greater than the time range(s) entered.</li>';
							}else {
								validationMsg += '<li>The number of hours entered for <b>'+dayRecords[i].taskName+'</b> for <b>'+dayRecords[i].displayDate+'</b> is greater than the time range(s) entered.</li>';
							}
						}
					}/*else if(dayRecords[i].timeType == 'PM' && (dayRecords[i].startTime2 && dayRecords[i].endTime2)){
						var start2 = getMinutes(dayRecords[i].startTime2);
						var end2 = getMinutes(dayRecords[i].endTime2);
						
						if(((end2 - start2) / 60) < dayRecords[i].dayHours ){
							if(!validationMsg){
								validationMsg = '<ul style="list-style-type: initial;"><li>The number of hours entered for <b>'+dayRecords[i].taskName+'</b> for <b>'+dayRecords[i].displayDate+'</b> is greater than the time range(s) entered.</li>';
							}else {
								validationMsg += '<li>The number of hours entered for <b>'+dayRecords[i].taskName+'</b> for <b>'+dayRecords[i].displayDate+'</b> is greater than the time range(s) entered.</li>';
							}
						}
					}*/
				}
				
			}// end of preparation time else
		}
	}//end of outer for loop
	
	if(validationMsg){
		
		validationMsg += '<br/>Please correct your entry in order to Save.</ul>';
		
		resultObj.isValid = false;
		resultObj.message = validationMsg;
		resultObj.title = 'Warning';
	}else {
		resultObj.isValid = true;
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
		if((dayRecords[i].isNew && dayRecords[i].dayHours) || (dayRecords[i].isUpdated && dayRecords[i].dayHours)){
			if(dayRecords[i].taskType != 'Preparation time' && dayRecords[i].startTime1 && dayRecords[i].endTime1){
				
				if(!dateTimeMap[dayRecords[i].dateVal]){
					dateTimeMap[dayRecords[i].dateVal] = dayRecords[i];
				}
			}
		}
	}//end of outer for loop
	
	
	//iterate the Prep Entries to check the overlap
	for(var i = 0; i < dayRecords.length;i++){
		if((dayRecords[i].isNew && dayRecords[i].dayHours) || (dayRecords[i].isUpdated &&dayRecords[i].dayHours)){
			if(dayRecords[i].taskType == 'Preparation time' 
			   && ((dayRecords[i].startTime1 && dayRecords[i].endTime1) 
				   || (dayRecords[i].startTime2 && dayRecords[i].endTime2))){
				
				var haveOverLap = false;
				var time1OverLap = false;
				var time2OverLap = false;
				
				//Compare the LT time & Pre time values. Find there is a overlap or not
				if(dateTimeMap[dayRecords[i].dateVal]){
					let start1 = getMinutes(dateTimeMap[dayRecords[i].dateVal].startTime1);
					let end1 = getMinutes(dateTimeMap[dayRecords[i].dateVal].endTime1);
					
					let start2;
					let end2;
					if(dayRecords[i].startTime1 && dayRecords[i].endTime1){
						start2 = getMinutes(dayRecords[i].startTime1);
						end2 = getMinutes(dayRecords[i].endTime1);
					}
					
					let start3;
					let end3;
					if(dayRecords[i].startTime2 && dayRecords[i].endTime2){
						start3 = getMinutes(dayRecords[i].startTime2);
						end3 = getMinutes(dayRecords[i].endTime2);
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
							timeOverlapMsg += '<li>'+dateTimeMap[dayRecords[i].dateVal].taskName+' / '+dateTimeMap[dayRecords[i].dateVal].startTime1+' - '+dateTimeMap[dayRecords[i].dateVal].endTime1+'</li>';
							
							if(time1OverLap){
								timeOverlapMsg += '<li>'+dayRecords[i].taskName+' / '+dayRecords[i].startTime1+' - '+dayRecords[i].endTime1+'</li>';
							}else if(time2OverLap){
								timeOverlapMsg += '<li>'+dayRecords[i].taskName+' / '+dayRecords[i].startTime2+' - '+dayRecords[i].endTime2+'</li></ul>';
							}
							
						}else {
							timeOverlapMsg += '<br/><ul style="list-style-type: initial;">The time ranges for the below Project Tasks for <b>'+dayRecords[i].displayDate+'</b> are in conflict. Please adjust the Start Times and End Times for each project task to ensure none overlaps.';
							timeOverlapMsg += '<li>'+dateTimeMap[dayRecords[i].dateVal].taskName+' / '+dateTimeMap[dayRecords[i].dateVal].startTime1+' - '+dateTimeMap[dayRecords[i].dateVal].endTime1+'</li>';
							
							if(time1OverLap){
								timeOverlapMsg += '<li>'+dayRecords[i].taskName+' / '+dayRecords[i].startTime1+' - '+dayRecords[i].endTime1+'</li>';
							}else if(time2OverLap){
								timeOverlapMsg += '<li>'+dayRecords[i].taskName+' / '+dayRecords[i].startTime2+' - '+dayRecords[i].endTime2+'</li></ul>';
							}
						}
						
					}
					
				}//end of dateTimeMap
				
			}//end of hrs validation
		}
	}//end of outer loop
	
	console.log(':::::::::timeOverlapMsg::::',timeOverlapMsg);
	
	if(timeOverlapMsg){
		resultObj.isValid = false;
		resultObj.message = timeOverlapMsg;
		resultObj.title = 'Warning';
	}else{
		resultObj.isValid = true;
	}
	
	return resultObj;
}

function checkHrsEnteredOrNot(dayRecords){
	
	var isValid = true;
	
	var resultObj = {};
	
	for(var i = 0;i < dayRecords.length;i++){
		var start1 = (dayRecords[i].startTime1 && dayRecords[i].startTime1 != '--None--')? true : false;
		var end1 = (dayRecords[i].endTime1 && dayRecords[i].endTime1 != '--None--')? true : false;
		var start2 = (dayRecords[i].startTime2 && dayRecords[i].startTime2 != '--None--')? true : false;
		var end2 = (dayRecords[i].endTime2 && dayRecords[i].endTime2 != '--None--')? true : false;
		
		var hrsExist = (dayRecords[i].dayHours === 0 || dayRecords[i].dayHours) ? true : false;
		
		if(((start1 && end1) 
			|| (start2 && end2))
		   && !hrsExist){
			isValid = false;
		}
	}
	//console.log('::::::validEntryAvailable:::isValid:::::',isValid);
	
	resultObj.isValid = isValid;
	
	if(!isValid){
		resultObj.message = 'Please enter in hours for the time entry associated to the Start Time and End Time entered.';
		resultObj.title = 'Warning';
	}
	
	return resultObj;
}

function checkEndTimeValidOrNot(dayRecords){
        
	var isvalidEndTime = true;
	
	var resultObj = {};
	
	//Get current time value to compare with end time
	//W-001894
	var dt = new Date();
	var h =  dt.getHours(), m = dt.getMinutes();
	var currentTime = (h > 12) ? ('0'+ (h-12) + ':' + m +' PM') : ('0'+h+ ':' + m +' AM');
	
	var currentDt = new Date();
	
	for(var i = 0;i < dayRecords.length;i++){
		if((dayRecords[i].isNew && dayRecords[i].dayHours) || (dayRecords[i].isUpdated && dayRecords[i].dayHours)){
			var columnDt = new Date(dayRecords[i].dateVal);
			columnDt.setTime(columnDt.getTime() + columnDt.getTimezoneOffset() * 1000 * 60);
			
			if(dateComparison(currentDt,columnDt) && dayRecords[i].endTime1 && dayRecords[i].endTime1 != '--None--' && getMinutes(currentTime) < getMinutes(dayRecords[i].endTime1)){
				isvalidEndTime = false;
			}
			
			if(dateComparison(currentDt,columnDt) && dayRecords[i].endTime2 && dayRecords[i].endTime2 != '--None--' && getMinutes(currentTime) < getMinutes(dayRecords[i].endTime2)){
				isvalidEndTime = false;
			}
		}
	}
	//console.log('::::::isvalidEndTime::',isvalidEndTime);
	
	resultObj.isValid = isvalidEndTime;
	
	if(!isvalidEndTime){
		
		resultObj.message = 'You have selected an End Time that is in the future. Users are not allowed to enter time for a future date or time. <br/>Please correct your entry or wait until the end of the day to enter your time.';
		resultObj.title = 'Warning';
	}
	
	return resultObj;
}

function checkForPlannedDaysOff(dayRecords,plannedOffMap){
	
	var daysOffMsg = '';
	
	var resultObj = {};
	
	if(plannedOffMap){
		for(var i = 0;i < dayRecords.length;i++){
			if((!(dayRecords[i].taskName == 'Fringe-PTO' && dayRecords[i].payrollItem == 'PTO')) && (dayRecords[i].isNew && dayRecords[i].dayHours) || (dayRecords[i].isUpdated && dayRecords[i].dayHours)){
				console.log(1);
				if(plannedOffMap[dayRecords[i].dateVal]){
					daysOffMsg += '<ul style="list-style-type: initial;">The time you entered for <b>'+dayRecords[i].displayDate+'</b> conflicts with a planned day off for the same date.';
					daysOffMsg += '<li>'+plannedOffMap[dayRecords[i].dateVal].daysOffDate+' / '+plannedOffMap[dayRecords[i].dateVal].contactName+' / '+plannedOffMap[dayRecords[i].dateVal].description+'</li>';
				}
			}
		}
	}
	if(daysOffMsg){
		//daysOffMsg += '<br/>Are you sure you would like to save this time entry?';
		
		resultObj.isValid = false;
		resultObj.message = daysOffMsg;
		resultObj.title = 'Warning';
		
	}else {
		resultObj.isValid = true;
	}
	return resultObj;
}

function checkDLIHavePrepEntry(dayRecords,dliWLTHolidays,projectData){
        
	var projectRTName = projectData.length > 0? projectData[0].projectRTName : '';
	var lateCancellationMap = {};
	
	var isPrepEntryExist = false;
	
	var resultObj = {};
	
	for(var i = 0;i < dayRecords.length;i++){
		if(dayRecords[i].taskType != 'Preparation time'){
			var hrsExist = (dayRecords[i].dayHours === 0 || dayRecords[i].dayHours) ? true : false;
			if(hrsExist){
				if(projectRTName == 'DLI_W_LT_Projects' && dliWLTHolidays.indexOf(dayRecords[i].dateVal) == -1
				  && dayRecords[i].lateCancellation){
					if(!lateCancellationMap[dayRecords[i].dateVal]){
						lateCancellationMap[dayRecords[i].dateVal] = true;
					}
				}
			}
		}
	}
	//check lang training entries with prep
	for(var i = 0;i < dayRecords.length;i++){
		if(dayRecords[i].taskType == 'Preparation time'){
			if((dayRecords[i].isNew && dayRecords[i].dayHours) || (dayRecords[i].isUpdated && dayRecords[i].dayHours)){
				if(lateCancellationMap[dayRecords[i].dateVal]){
					isPrepEntryExist = true;
				}
			}
		}
	}
	
	if(isPrepEntryExist){
		
		resultObj.isValid = false;
		resultObj.message = 'Preparation Time can not be performed for sessions that have been cancelled, please clear the preparation time and then save.  If you have any questions, please submit a case on contact your Language Training Supervisor';
		resultObj.title = 'Warning';
		
	}else {
		resultObj.isValid = true;
	}
	
	return resultObj;
}

function checkForFederalHolidays(dayRecords,federalHolidays){
	
	var resultObj = {isValid: true};
	var dateVal,
            isValid = true;
	
	if(federalHolidays){
		for(var i = 0;i < dayRecords.length;i++){
			console.log('::dayRecords[i]::>'+dayRecords[i].isNew,dayRecords[i].isUpdated,dayRecords[i].dayHours,dayRecords[i].dateVal);
			if((dayRecords[i].isNew && dayRecords[i].dayHours) || (dayRecords[i].isUpdated && dayRecords[i].dayHours)){
				if(federalHolidays.indexOf(dayRecords[i].dateVal) != -1){
					dateVal = dayRecords[i].dateVal;
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
function formatDate(inputDate){
    var dateArr = inputDate.split("-");
    return dateArr[1]+'/'+dateArr[2]+'/'+dateArr[0];
}

//W-007882 - Prep Time Entry Warning Message Request in DLS Online
function validatePreparationHours(dayRecords, defaultCostRateRateType){
	var resultObj = {isValid: true}; 
    var dateVal;
    var invalidPrep;
    var invalidPrepDay;
    var isValid = true;
    for(var i = 0;i < dayRecords.length;i++){
        if(dayRecords[i].taskType == 'Language Training' && defaultCostRateRateType == 'LT with Prep'){
			var hrsExist = (dayRecords[i].dayHours === 0 || dayRecords[i].dayHours) ? true : false;
			if(hrsExist){ 
				dateVal = dayRecords[i].dateVal;
			}
        }

        if(dayRecords[i].taskType == 'Preparation time' && defaultCostRateRateType == 'LT with Prep' && dateVal == dayRecords[i].dateVal && dayRecords[i].dayHours == null){
			isValid = false; 
			invalidPrep = formatDate(dayRecords[i].dateVal);
			invalidPrepDay = dayRecords[i].dateVal;
        }
    }

    if(!isValid){
        resultObj.isValid = false;
        resultObj.message = `Please enter time for Language Training - Preparation for <b>${invalidPrep}</b>.`;
        resultObj.title = 'Warning';
        resultObj['invalidPrepDay'] = invalidPrepDay;
        
    }

    return resultObj;
}