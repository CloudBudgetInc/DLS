({
	getScheduleInitialDetails : function(cmp, event, helper) {
		var action = cmp.get("c.getScheduleRelatedInformation");
		action.setParams({
			"parentId" : cmp.get("v.parentId"),
			"parentType" : cmp.get("v.objectName"),
			"scheduleId" : cmp.get("v.scheduleId"),
			"scheduleType" : cmp.get("v.scheduleType"),
			"priorScheduleId" : cmp.get("v.priorScheduleId"),
			"parentScheduleId" : cmp.get("v.parentScheduleId")
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if(state === 'SUCCESS'){
				var result = JSON.parse(response.getReturnValue());
				console.log('::::::result::::::',result);
				
				cmp.set("v.timeList",result.timeValues);
				cmp.set("v.endTimeList",result.timeValues);
				cmp.set("v.taskRecords",result.projectTaskRecords);
				cmp.set("v.opliRecords",result.opliRecords);
				cmp.set("v.alottedHrsMap",result.opliTaskIdAlottedHrs);
				cmp.set("v.holidayRecords",result.holidays);
				cmp.set("v.possibleHrsMap",result.totalPlannedHrsMap);
				cmp.set("v.exisitngSchedules",result.exisitngSchedules);
				cmp.set("v.defaultCRRateType",result.defaultCRRateType);
                //Call the prep time related parent schedule qry method
                this.getPrepTimeParentTaskSchedules(cmp,result.schDetail.projectTaskId);
				
				var self = this;
				
				window.setTimeout(
					$A.getCallback(function() {
						var scheduleType = cmp.get("v.scheduleType");
						if(scheduleType != 'Regular' && !cmp.get("v.scheduleId")) {
							console.log('::::::::::::enter::::');
                            result.schDetail = JSON.parse(JSON.stringify(result.exisitngSchedules[cmp.get("v.priorScheduleId")]));
                            result.schDetail.roomId = null;
                            result.schDetail.roomName = ''; 
                            
							if(scheduleType != 'Extend End Date'){
								result.schDetail.priorScheduleId = result.schDetail.scheduleId;
								result.schDetail.scheduleId = '';
								result.schDetail.scheduleName = '';
								result.schDetail.isNew = true;
								result.schDetail.isUpdate = false;
							}
							result.schDetail.scheduleType = cmp.get("v.scheduleType");
						}
						
						if(scheduleType != 'Extend End Date' && scheduleType != 'Regular' && result.schDetail.isNew){
							result.schDetail.startDate = '';
							result.schDetail.status = 'Drafted';
						}else {
							cmp.set("v.oldEndDate",result.schDetail.endDate);
						}
						
						if(scheduleType == 'Extend End Date' || scheduleType == 'Room change' ) {
			                cmp.set("v.disableInput",true);
			            } 
						
						if((scheduleType == 'Substitute' || scheduleType == 'Tester')&& result.schDetail.isNew){
							result.schDetail.endDate = '';
							result.schDetail.instructorId = '';
						}
					
					if(scheduleType == 'Schedule Change' || scheduleType == 'Room Change' || scheduleType == 'Move Online'){
						var insRec = [];
						insRec.push({Id : result.schDetail.instructorId,Name : result.schDetail.instructorName});
						cmp.set("v.instructorSelected",insRec);
					}
                    if(scheduleType == 'Schedule Change' || scheduleType == 'Move Online' || scheduleType == 'Tester'){
						var roomSelected = [];
						roomSelected.push({Id : result.schDetail.roomId,Name : result.schDetail.roomName});
						cmp.set("v.roomSelected",roomSelected);
					}
                    
                    if(scheduleType == 'Tester'){
                        
                    	result.schDetail = self.setSchPlannedTime(cmp, event, self, result.schDetail);                        
                    }
					cmp.set("v.scheduleRec",result.schDetail);
					
					//call substitute schedule related events formation
					if(cmp.get("v.scheduleType") == 'Substitute' && result.schDetail.isUpdate){
						self.getEventDetailForSubstituteType(cmp);
					}
					 
					if(cmp.get("v.typeOfAction") != 'Activate'){
                        
                        cmp.set("v.displayInputModal",true);
                        
						if(cmp.get("v.scheduleType") == 'Substitute'){                            
							cmp.find("substituteModal").open();							
						}else if(cmp.get("v.scheduleType") == 'Tester'){                            
							cmp.find("testerModal").open();
                        }else{                             
							cmp.find("inputModal").open();
                        }
					}else {
						cmp.set("v.btnType",'Activate');
						self.calculateTotalHrs(cmp);
						self.getConflictInformation(cmp);
					}
					
				}),100);
				
				//form minutes list
				this.convertTimeToMinutes(cmp);
				cmp.set("v.showSpinner",false);
			}else {
				console.log(':::::error:::::on:::schedule:detail::methos:',response.getError()[0].message);
				cmp.set("v.successTitle",'Error');
				cmp.set("v.successMsg",response.getError[0].message);
				cmp.set("v.showSpinner",false);
				cmp.set("v.showSuccessModal",true);
				cmp.find("successModel").open();
			}
		});
		$A.enqueueAction(action);
	},
	validateInput: function(cmp){
		var isValid = true;
		if(cmp.get("v.scheduleType") != 'Substitute') {
			var inputValues = cmp.find("inputValue");
			//console.log(':::::::inputValues::::::',inputValues);
			
			//All other inputs except date fields
			if(inputValues){
				for(var i = 0; i < inputValues.length; i++){
					if(!inputValues[i].get("v.value")){
						$A.util.addClass(inputValues[i], 'slds-has-error'); 
						isValid = false;
					}else {
						$A.util.removeClass(inputValues[i], 'slds-has-error'); 
					}
				}
			}
		}
		//For substitute start & end date validation
		if(cmp.get("v.scheduleType") == 'Substitute') {
			var stInput = cmp.find("startDtValue");
			var endInput = cmp.find("endDtValue");
			
			var stVal;
			if(!stInput.get("v.value")){
				//stInput.set("v.errors", [{message:" "}]);
				isValid = false;
			}else {
				stVal = new Date(stInput.get("v.value")).getTime();
				stInput.setCustomValidity("");
                stInput.reportValidity();
			}
			if(!endInput.get("v.value") || (endInput.get("v.value") && stVal > new Date(endInput.get("v.value")).getTime())){
				if(endInput.get("v.value") && stVal > new Date(endInput.get("v.value")).getTime()){
                    endInput.setCustomValidity("End Date must be greater than the start date.");
                    endInput.reportValidity();
					isValid = false;
				}else if(!endInput.get("v.value")){
					endInput.setCustomValidity("");
                    endInput.reportValidity();
					isValid = false;
				}                
			}else {
				endInput.setCustomValidity("");
                endInput.reportValidity();
			}
		}
		
		//For normal start & end date validation
		if(cmp.get("v.scheduleType") != 'Substitute') {
			var sInput = cmp.find("startDateValue");
			var eInput = cmp.find("endDateValue");
			
			var sVal;
			
			if(!sInput.get("v.value")){
				sInput.set("v.errors", [{message:" "}]);
				isValid = false;
			}else {
				var currentUsrProfileName = cmp.get("v.currentUsrProfileName");
				var currentDate = new Date();
                var formattedDate = currentDate.toISOString().split('T')[0];
                
                if(cmp.get("v.scheduleType") != 'Extend End Date'){//W-007970 - Issue with Extend End Date Schedule Action Button
                    
                    if(sInput.get("v.value") >= formattedDate || currentUsrProfileName == 'System Administrator' || currentUsrProfileName == 'Power User') {
                        sVal = new Date(sInput.get("v.value")).getTime();
                        sInput.set("v.errors", null);
                    } else {
                        sInput.set("v.errors", [{message:"Start Date is in the past, please enter a Start Date Greater, or Equal to Today"}]);
                        isValid = false;
                    }
                }
                
            }
            
			var oldEndDate = new Date(cmp.get("v.oldEndDate")).getTime();
			
			if(!eInput.get("v.value") || eInput.get("v.value")){
				//Normal types
				if(eInput.get("v.value") && sVal > new Date(eInput.get("v.value")).getTime()) {
					eInput.set("v.errors", [{message:"End Date must be greater than the start date "}]);
					isValid = false;
				}else if(cmp.get("v.scheduleType") == 'Extend End Date' && oldEndDate > new Date(eInput.get("v.value")).getTime()){
					eInput.set("v.errors", [{message:"End Date should be greater than the old End Date "+cmp.get("v.oldEndDate")}]);
					isValid = false;
				}else if(!eInput.get("v.value")){
					eInput.set("v.errors", [{message:""}]);
					isValid = false;
				}else {
					eInput.set("v.errors", null);
				}
				
			}else {
				eInput.set("v.errors", null);
			}
			
			//Travel In & Travel Out date related validation
			if(cmp.get("v.scheduleRec").isTravelRequired){
				var inInput = cmp.find("travelInDate");
				var outInput = cmp.find("travelOutDate");
				
				var inVal;
				
				if(!inInput.get("v.value")){
					inInput.set("v.errors", [{message:" "}]);
					isValid = false;
				}else {
					inVal = new Date(inInput.get("v.value")).getTime();
					inInput.set("v.errors", null);
				}
				
				
				if(!outInput.get("v.value") || outInput.get("v.value")){
					//Normal types
					if(outInput.get("v.value") && inVal > new Date(outInput.get("v.value")).getTime()) {
						outInput.set("v.errors", [{message:"Travel Out Date must be greater than or equal to travel in date "}]);
						isValid = false;
					}else if(!outInput.get("v.value")){
						outInput.set("v.errors", [{message:""}]);
						isValid = false;
					}else {
						outInput.set("v.errors", null);
					}
					
				}else {
					outInput.set("v.errors", null);
				}
			}
		}
			
		/*for(var i = 0; i < dateInputs.length; i++){
			if(!dateInputs[i].get("v.value")){
				dateInputs[i].set("v.errors", [{message:" "}]);
				isValid = false;
			}else {
				dateInputs[i].set("v.errors", null);
			}
		}*/
		
		//For Days validation
		if(cmp.get("v.scheduleType") != 'Substitute') {
			var isVaired = cmp.get("v.scheduleRec").variedDay;
			var daysSelected = cmp.find("dayinput");
			var daysChecked = false;
			if(!isVaired){
				for(var i = 0; i < daysSelected.length; i++){
					if(daysSelected[i].get("v.checked")){
						daysChecked = true;
						break;
					}
				}
				
				for(var i = 0; i < daysSelected.length; i++){
					if(!daysChecked){
						$A.util.addClass(daysSelected[i], 'slds-has-error'); 
					}else {
						$A.util.removeClass(daysSelected[i], 'slds-has-error'); 
					}
				}
				
				if(!daysChecked){
					isValid = false;
				}
			}
		}
		
		return isValid;
	},
	convertTimeToMinutes : function(cmp){
		var timeList = cmp.get("v.timeList");
		var minutesList = [];
		for(var i = 0; i < timeList.length; i++){
            minutesList.push({minutes: this.getMinutes(cmp,timeList[i]),time: timeList[i]});  
        }
        cmp.set("v.minutesList",minutesList);
	},
	getMinutes : function(cmp,time, isEndTime){
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
            if(m[0] == '12' && !isEndTime){
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
            min = !isEndTime ? 60 + parseInt(t[1]) : parseInt(t[1])
        return hrs+min;
	},
	filterEndTimeValues : function(cmp,startTime){
		var filteredHours = [];
		var minutesList = cmp.get("v.minutesList");
		startTime = this.getMinutes(cmp,startTime);
        var i = 0;
        if(startTime) {
            while(i < minutesList.length) {
                if(startTime == minutesList[i].minutes) {
                    i++;
                    break;
                }
                i++;
            }
        }
    	for(var j = i; j < minutesList.length; j++) {
            filteredHours.push(minutesList[j].time);
        }
        
        cmp.set("v.endTimeList",filteredHours);
	},
	calculateTotalHrs: function(cmp){
		var createdHours = 0;
		var scheduleRec = cmp.get("v.scheduleRec");
		var alottedHrsMap = cmp.get("v.alottedHrsMap");
		var possibleHrsMap = cmp.get("v.possibleHrsMap");
		var schType = scheduleRec.scheduleType;
		var totalAlottedHrs = 0;
		var totalPossibleHrs = 0;
		var parentType = cmp.get("v.objectName");
		var exisitngSchedules = cmp.get("v.exisitngSchedules");
		
        //console.log(':::::::::scheduleRec:::',JSON.stringify(scheduleRec));
        
		if(schType != 'Substitute'){
			createdHours = this.calculateDuration(cmp,cmp.get("v.scheduleRec"),cmp.get("v.holidayRecords"));  
		}else {
			//separate hours calculation for substitute type schedules
			var datesArray = this.extractSelectedSubstituteDate(cmp);
			console.log('::::::::::datesArray.length:::::',datesArray.length);
			createdHours = datesArray.length * scheduleRec.hoursPlanned;
		}
		console.log(':::::::::totalAlottedHrs::::',totalAlottedHrs);
		console.log(':::::::::created::hrs::::',createdHours);
		var alottedHours = 0;
		if(parentType == 'Opportunity' && alottedHrsMap){
			alottedHours = alottedHrsMap[scheduleRec.opliId];
		}else if(parentType == 'AcctSeed__Project__c' && alottedHrsMap){
			alottedHours = alottedHrsMap[scheduleRec.projectTaskId];
		}
		
		console.log('alottedHours ::::createdHours::',schType,alottedHours,createdHours);
	    if(schType == 'Regular') {
	        totalAlottedHrs = ((alottedHours != null && scheduleRec.isChanged) ? alottedHours:0) + createdHours;
	    }else if(schType != 'Regular'){
	        
	        var oldSch = exisitngSchedules[scheduleRec.priorScheduleId];
	        console.log(':::::::oldSch::::',JSON.stringify(oldSch));
	        
	        var oldHrs = 0;
	        
	        if(oldSch) {
	            oldHrs = this.calculateDuration(cmp,oldSch,cmp.get("v.holidayRecords"));
	        }
	        var finalHrs = 0;
	        
	        console.log('::::oldHrs::::createdHrs::::::',oldHrs,createdHours,alottedHours);
	        
	        if(oldHrs > createdHours){
	            finalHrs = oldHrs - createdHours;
	            if(alottedHours){
	            	alottedHours = alottedHours - finalHrs;
	            }else{
	            	alottedHours = finalHrs;
	            }
	        }else if(oldHrs < createdHours){
	            finalHrs = createdHours - oldHrs;
	            alottedHours = alottedHours + finalHrs;
	        }
	        
	        console.log('::finalHRs:::alottedHours:::::::',finalHrs,alottedHours);
	        
	        totalAlottedHrs = ((alottedHours != null && scheduleRec.isChanged) ? alottedHours:0);
            
            //Added by Mohana
            if(!scheduleRec.isChanged) {
                totalAlottedHrs = createdHours;
            }
	    }
		
		if(parentType == 'AcctSeed__Project__c') {
            totalPossibleHrs = possibleHrsMap[scheduleRec.projectTaskId];
        } else if(parentType == 'Opportunity') {
            totalPossibleHrs = possibleHrsMap[scheduleRec.opliId];
        }
         console.log('totalAlottedHrs!1111::::',totalAlottedHrs);
        
        if(scheduleRec.isUpdate && scheduleRec.isChanged && schType != 'Substitute') {
            console.log('createdHours::::',createdHours);
            console.log('existing::::',exisitngSchedules[scheduleRec.scheduleId].totalHrsPlanned);
            if(createdHours > exisitngSchedules[scheduleRec.scheduleId].totalHrsPlanned) {
                var oldHrs = exisitngSchedules[scheduleRec.scheduleId].totalHrsPlanned != null ? exisitngSchedules[scheduleRec.scheduleId].totalHrsPlanned:0;
                var newHrsToAdd = createdHours - oldHrs;
                
                console.log(':::::::existing:::record:::::::',oldHrs,newHrsToAdd);
                
                totalAlottedHrs += newHrsToAdd;
            }
        }
		
        console.log('::::::::::totalAlottedHrs:::::',totalAlottedHrs);
        console.log('::::::::::totalPossibleHrs:::::',totalPossibleHrs);
        
        cmp.set("v.newHrsToBeCreated",createdHours);
        cmp.set("v.totalAlottedHrs",totalAlottedHrs);
        cmp.set("v.totalPossibleHrs",totalPossibleHrs);
		
	},
	calculateDuration : function(cmp,record,holidaysObj){
		var dayList = [];
        var hours = 0;
        var daysSelected = record.dayVal,
        	biweek = true,
            firstOccWeekNo;
        console.log('daysSelected:::',daysSelected);
        if(daysSelected.sunday) {
            dayList.push(0);
        }
        if(daysSelected.monday) {
            dayList.push(1);
        }
        if(daysSelected.tuesday) {
            dayList.push(2);
        }
        if(daysSelected.wednesday) {
            dayList.push(3);
        }
        if(daysSelected.thursday) {
            dayList.push(4);
        }
        if(daysSelected.friday) {
            dayList.push(5);
        }
        if(daysSelected.saturday) {
            dayList.push(6);
        }
        console.log('dayList::',dayList);
        var startDate = record.startDate;
        var endDate = record.endDate;
        console.log('Record start and end date::::',startDate,endDate);
        var tDate = new Date(moment(startDate).format('YYYY-MM-DD'));
        tDate.setTime(tDate.getTime() + tDate.getTimezoneOffset() * 60 * 1000);
        console.log(':::::::tDate:::::',tDate);
        var tEndDate = new Date(moment(endDate).format('YYYY-MM-DD'));
        tEndDate.setTime(tEndDate.getTime() + tEndDate.getTimezoneOffset() * 60 * 1000);
        console.log('tEndDate:::::',tEndDate);
        
        var duration = record.hoursPlanned;
        var eventDay = {};
        while(tDate <= tEndDate) {
            
            var weekno = moment(tDate).week(), 
            	isValidDay = this.checkDayList(tDate, dayList);
            
            if(!firstOccWeekNo && isValidDay){
                firstOccWeekNo = weekno;
            }
            if(firstOccWeekNo && weekno != firstOccWeekNo && record.biWeekly){
                
                var no = weekno - firstOccWeekNo;                                               
                biweek = (no != 0 && no % 2 == 0) ? true : false;
            }
            if(isValidDay && biweek) {
                var intersectDay = this.checkIntersection(tDate, record.excludeFederalHoliday,holidaysObj);
                if(intersectDay || eventDay[moment(tDate).format('YYYY-MM-DD')]) {
                    if((intersectDay && intersectDay.rescheduleDate && this.checkIntersection(intersectDay.rescheduleDate, record.excludeFederalHoliday,holidaysObj)) || (intersectDay && !intersectDay.rescheduleDate) || eventDay[moment(tDate).format('YYYY-MM-DD')]) {
                        //pushIntersectionDate(tDate);
                        tDate.setDate(tDate.getDate() + 1);
                        continue;
                    }
                    if(intersectDay.rescheduleDate) {
                        console.log('Event Rescheduled.', new Date(intersectDay.rescheduleDate));
                        eventDay[moment(intersectDay.rescheduleDate).format('YYYY-MM-DD')] = true;
                    }
                }
                hours += parseInt(duration);
            }
            tDate.setDate(tDate.getDate() + 1);
        }
        return hours;
	},
	checkDayList: function(date,dayList){
		var day = date.getDay();
        if(dayList.indexOf(day) != -1) {
            return true;
        }
        return false;
	},
	checkIntersection: function(tDate, excludeFederalHolidays,holidaysObj){
		var date = moment(tDate).format('YYYY-MM-DD');
        if(holidaysObj[date]) {
            if(!excludeFederalHolidays && holidaysObj[date].type == 'HOLIDAY') {
                console.log('holiday intersected', date);
                return false;
            }
            return holidaysObj[date];
        }
        return false;
	},
	getConflictInformation : function(cmp){
		
		var instructorSelected = cmp.get("v.instructorSelected");
		var insId = '';
		if(instructorSelected.length > 0){
			insId = instructorSelected[0].Id;
		}else {
			insId = cmp.get("v.scheduleRec").instructorId;
		}
		
		var parentType = '';
		if(cmp.get("v.objectName") == 'Opportunity'){
			parentType = 'OPPORTUNITY';
		}else {
			parentType = 'PROJECT';
		}
		
		var daysOff = [];
		var scheduleList = [];
		var scheRecList = [];
        
        var scheduleRec = cmp.get("v.scheduleRec")
         if(!scheduleRec.breakTimeHrs) {
            console.log('inside break time');
            scheduleRec.breakTimeHrs = 0;
        }
        cmp.set("v.scheduleRec",scheduleRec);
        console.log('Schedule Rec::::::', JSON.stringify(cmp.get("v.scheduleRec")));
		scheduleList.push(cmp.get("v.scheduleRec"));
		console.log(':::::scheduleList:::',JSON.stringify(scheduleList));
		console.log(':::::insId:::',insId,parentType,cmp.get("v.parentId"),cmp.get("v.parentRTName"));
		cmp.set('v.showSpinner', true);
		var action = cmp.get("c.getScheduleConflicts");
		action.setParams({
			"schWrapperJson" : JSON.stringify(scheduleList),
			"schRecJson" : JSON.stringify(scheRecList),
			"instructorId" : insId,
			"parentType" : parentType,
			"parentId" : cmp.get("v.parentId"),
			"parentRT" : cmp.get("v.parentRTName"),
			"daysOffJson" : JSON.stringify(daysOff) 
 		});
 		action.setCallback(this, function(response){
 			var state = response.getState();
            cmp.set('v.showSpinner', false);
 			if(state == 'SUCCESS'){
 				var result = JSON.parse(response.getReturnValue());
 				console.log('::::::result:::conflict::',result);
 				cmp.set("v.scheduleConflictMap",result);
 				cmp.set("v.showConflictModal",true);
 				cmp.find("conflictModel").open();
 			}else {
 				console.log(':::::conflict::::error::::',response.getError());
 				cmp.set("v.successTitle",'Error');
				cmp.set("v.successMsg",response.getError()[0].message);
				cmp.set("v.showSpinner",false);
				cmp.set("v.showSuccessModal",true);
				cmp.find("successModel").open();
 			}
 		});
 		$A.enqueueAction(action);
	},
	scheduleRecordDMLAction : function(cmp){
		cmp.set("v.showSpinner",true);
		var scheduleArr = [];
		scheduleArr.push(cmp.get("v.scheduleRec"));
		
		var action = cmp.get("c.createdRegularSchedule");
		action.setParams({
			"scheduleJson" : JSON.stringify(scheduleArr),
			"parentType" : cmp.get("v.objectName"),
			"parentId" : cmp.get("v.parentId")
		});
		action.setCallback(this,function(response){
			var state = response.getState();
			if(state == 'SUCCESS'){
				console.log(":::result:::::::::",response.getReturnValue());
				//cmp.set("v.showSpinner",false);
				cmp.find("inputModal").close();
				cmp.set("v.successTitle",'Success');
				if(cmp.get("v.scheduleRec").isNew){
					cmp.set("v.successMsg",'Schedule record created successfully.');
				} else {
					cmp.set("v.successMsg",'Schedule record updated successfully.');
				}
				//cmp.find("conflictModel").close();
				//cmp.set("v.showConflictModal",false);
				
				cmp.find("inputModal").close();
				cmp.set("v.displayInputModal",false);
				
				cmp.set("v.showSpinner",false);
				cmp.set("v.showSuccessModal",true);
				cmp.find("successModel").open();
			}else {
				console.log(":::::::::schedule::sml::error:::",response.getError);
				cmp.set("v.successTitle",'Error');
				cmp.set("v.successMsg",response.getError[0].message);
				cmp.set("v.showSpinner",false);
				cmp.set("v.showSuccessModal",true);
				cmp.find("successModel").open();
			}
		});
		$A.enqueueAction(action);
	},
	substituteScheduleDMLAction :  function(cmp){
		console.log(':::::::substitute::dml::::');
		/*var scheduleRec = cmp.get("v.scheduleRec");
		if(scheduleRec.isUpdate){
			this.scheduleCreationForOtherTypes(cmp);
		}else if(scheduleRec.isNew){
			this.scheduleCreationForOtherTypes(cmp);
		}*/
        //Method to open cost rate creation model based on rate type
        this.checkForCRCreation(cmp);
	},
	substituteUpdateAction :  function(cmp){
		//call substitute update apex class method
		
		var scheduleRec = cmp.get("v.scheduleRec");
		var instructor = cmp.get("v.instructorSelected");
		var room = cmp.get("v.roomSelected");
		
		if(instructor.length > 0){
			scheduleRec.instructorId = instructor[0].Id
		}
		if(room.length > 0){
			scheduleRec.room = room[0].Id
		}
		var dateList = [];
		dateList = this.extractSelectedSubstituteDate(cmp);
		
		if(dateList.length > 0) {
			var action = cmp.get("c.createEventsForSubstituteSchEdit");
			action.setParams({
				"schedule" : JSON.stringify(scheduleRec),
				"newEventDates" : dateList
			});
			action.setCallback(this, function(response){
				var state = response.getState();
				if(state == 'SUCCESS'){
					var result = response.getReturnValue();
				}else {
					console.log(':::substitute::schedule:update:::error::::::',response.getError[0].message);
					cmp.set("v.successTitle",'Error');
					cmp.set("v.successMsg",response.getError[0].message);
					cmp.set("v.showSpinner",false);
					cmp.set("v.showSuccessModal",true);
					cmp.find("successModel").open();
				}
			});
			$A.enqueueAction(action);
		}
		
	},
	activateScheduleRecord : function(cmp){
        
		var action = cmp.get("c.scheduleActivate");
		action.setParams({
			"schId" : cmp.get("v.scheduleRec").scheduleId
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if(state == 'SUCCESS'){
				cmp.set("v.successTitle",'Success');
				cmp.set("v.successMsg",'Schedule record activated successfully.');
				//cmp.find("conflictModel").close();
				//cmp.set("v.showConflictModal",false);
				
				cmp.set("v.showSpinner",false);
				cmp.set("v.showSuccessModal",true);
				cmp.find("successModel").open();
			}else {
				console.log(':::activate:::schedule::error::::',response.getError()[0].message);
				cmp.set("v.successTitle",'Error');
				cmp.set("v.successMsg",response.getError()[0].message);
				cmp.set("v.showSpinner",false);
				cmp.set("v.showSuccessModal",true);
				cmp.find("successModel").open();
			}
		});
		$A.enqueueAction(action);
	},
	scheduleCreationForOtherTypes : function(cmp){
		console.log(':::::::::enter::schedule::::::creation::for:::::::other::::');
		var scheduleRec = cmp.get("v.scheduleRec");
		var instructor = cmp.get("v.instructorSelected");
		var room = cmp.get("v.roomSelected");
		
		if(instructor.length > 0){
			scheduleRec.instructorId = instructor[0].Id;
		}
		
		if(room.length > 0){
			scheduleRec.roomId = room[0].Id;
		}
		
		if(cmp.get("v.scheduleType") == 'Extend End Date'){
			scheduleRec.scheduleType = 'Extended';
		}
        
        if(cmp.get("v.scheduleType") == 'Substitute'){
            scheduleRec.roomId = null;
        }
		
		var dateList = [];
		dateList = this.extractSelectedSubstituteDate(cmp);
        console.log('::::::::::dateList::::',dateList);

		
		var action = cmp.get("c.createScheduleForOtherTypes");
		action.setParams({
			"schedule" : JSON.stringify(scheduleRec),
			"schType" : cmp.get("v.scheduleType"),
			"rateType" : cmp.get("v.defaultCRRateType"),
			"parentType" : cmp.get("v.objectName"),
			"parentId" : cmp.get("v.parentId"),
			"eventDates" : dateList,
            "costRateId" : cmp.get("v.costRateId"),
            "CRType" : cmp.get("v.CRType")
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if(state == 'SUCCESS'){
				console.log('::::other::schedule::creation::response::::::',response.getReturnValue());
				var result = response.getReturnValue();
				if(result == 'SUCCESS'){
					cmp.set("v.successTitle",'Success');
					cmp.set("v.successMsg",'Schedule record created successfully.');
				}else {
					cmp.set("v.successTitle",'Success');
					cmp.set("v.successMsg",result);
				}
				if(scheduleRec.scheduleType != 'Substitute' && scheduleRec.scheduleType != 'Tester'){
					cmp.find("inputModal").close();
                }else if(scheduleRec.scheduleType == 'Tester'){
                    cmp.find("testerModal").close();
                }else {
					if(scheduleRec.isUpdate){
						this.substituteUpdateAction(cmp);
					}
					cmp.find("substituteModal").close();
				}
				cmp.set("v.displayInputModal",false);
				
				//cmp.find("conflictModel").close();
				//cmp.set("v.showConflictModal",false);
				
				cmp.set("v.showSpinner",false);
				cmp.set("v.showSuccessModal",true);
				cmp.find("successModel").open();
			}else {
				//console.log('::::other::schedule:creation:::error::::::',response.getError[0].message);
                let errors = response.getError();
                let message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
				cmp.set("v.successTitle",'Error');
				cmp.set("v.successMsg",message);
				cmp.set("v.showSpinner",false);
				cmp.set("v.showSuccessModal",true);
				cmp.find("successModel").open();
			}
		});
		$A.enqueueAction(action);
	},
	extractSelectedSubstituteDate :  function(cmp) {
		var dateList = [];
		var eventDates = cmp.get("v.substituteEventsList");
		for(var i = 0; i < eventDates.length;i++) {
			var days = eventDates[i].daysVal;
			for(var j = 0;j < days.length;j++){
				if(days[j].isSelected) {
	                var dte = days[j].date;
	                dateList.push(dte.split('/')[2]+'-'+dte.split('/')[0]+'-'+dte.split('/')[1]);
	            }
			}
	    }
		return dateList;
	},
	getEventDetailForSubstituteType :  function(cmp){
		cmp.set("v.showSpinner",true);
		var schId = '';
		var scheduleRec = cmp.get("v.scheduleRec");
		var status = [];
		if(scheduleRec.isNew){
			schId = scheduleRec.priorScheduleId;
			status.push('Scheduled');
		}else if(scheduleRec.isUpdate){
			schId = scheduleRec.scheduleId;
			if(scheduleRec.status == 'Drafted'){
				status.push('Draft');
			}
			status.push('Scheduled');
			status.push('Completed');
		}
		var sDate;
		var eDate;
		if(scheduleRec.isNew){
			sDate = scheduleRec.startDate;
			eDate = scheduleRec.endDate;
		}else {
			sDate = null;
			eDate = null;
		}
		
		var action = cmp.get("c.getEventsFromSchedule");
		action.setParams({
			"scheduleId" : schId,
			"sDate" : sDate,
			"eDate" : eDate,
			"status" : status
		});
		action.setCallback(this, function(response){
			var state = response.getState();
			if(state == 'SUCCESS'){
				var result = JSON.parse(response.getReturnValue());
				console.log("result::::::::subsitute:::::",result);
				this.substituteCalenderDataFormation(cmp,result);
			}else {
				console.log("::::error::substitute:events:::::",response.getError()[0].message);
				cmp.set("v.successTitle",'Error');
				cmp.set("v.successMsg",response.getError[0].message);
				cmp.set("v.showSpinner",false);
				cmp.set("v.showSuccessModal",true);
				cmp.find("successModel").open();
			}
		});
		$A.enqueueAction(action);
	},
	substituteCalenderDataFormation :  function(cmp,result){
		 var millisecondMap = {};
		 var tempMap = {};
		 var finalMap = {};
		 var weekStartValues = [];
		 
		for(var key in result){
			var datesArray = result[key];
			for(var i = 0;i < datesArray.length;i++){
				var dt = new Date(datesArray[i]);
				var dtDay = dt.getDay();
				var wkStart = new Date(dt.getTime() - (dtDay * 24 * 60 * 60 * 1000) + 24 * 60 * 60 * 1000);
				var wkEnd = new Date(dt.getTime() + ((7 - dtDay) * 24 * 60 * 60 * 1000));
				var wkKey = this.millisecondToString(wkStart.getTime()) +'-' + this.millisecondToString(wkEnd.getTime());
				if(!millisecondMap[wkStart.getTime()]){
					weekStartValues.push(wkStart.getTime());
                    millisecondMap[wkStart.getTime()] = wkKey;
				}
				if(!tempMap[wkKey]){
					tempMap[wkKey] = {};
					tempMap[wkKey]['Monday'] = {};
					tempMap[wkKey]['Tuesday'] = {};
					tempMap[wkKey]['Wednesday'] = {};
					tempMap[wkKey]['Thursday'] = {};
					tempMap[wkKey]['Friday'] = {};
					tempMap[wkKey]['Saturday'] = {};
					tempMap[wkKey]['Sunday'] = {};
				}
				
				var bgcolr;
				var newRec = false;
				if(cmp.get("v.scheduleRec").isUpdate) {
					 if(key == 'Scheduled' || key == 'Draft') {
	                    bgcolr = 'background-color:yellow';
	                } else {
	                    bgcolr = 'background-color:darkgrey';
	                }
	                newRec = false;
				}else if(cmp.get("v.scheduleRec").isNew){
					bgcolr = 'background-color: #53c653';
					newRec = true;
				}
				
				if(tempMap[wkKey][this.millisecondToDay(datesArray[i])]){
					tempMap[wkKey][this.millisecondToDay(datesArray[i])] = {date : this.millisecondToString(datesArray[i]), isSelected : newRec, isNew : newRec, style : bgcolr, day : this.millisecondToDay(datesArray[i])};
				}
			}
		}
		
		weekStartValues.sort();
		for(var i = 0; i < weekStartValues.length ; i++) {
            var tmpKey = millisecondMap[weekStartValues[i]];
            if(tempMap[tmpKey]) {
                finalMap[tmpKey] = tempMap[tmpKey];
            }
        }
		
		console.log(':::::::::tempMap::::',tempMap);
		console.log('::::::::finalMap:::::',finalMap);
		
		var calendarDates = [];
		var daysList = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
		
		for(var key in finalMap){
			var obj = {};
			obj.weekVal = key;
			obj.daysVal = [];
			
			for(var i in finalMap[key]){
				obj.daysVal.push(finalMap[key][i]? finalMap[key][i] : null);
			}
			
			calendarDates.push(obj);
		}
		cmp.set("v.substituteEventsList",calendarDates);
		console.log('::::::::',calendarDates);
		cmp.set("v.showSpinner",false);
	},
	millisecondToString :  function(millisecond){
		var date = new Date(millisecond);            
        date.setTime(date.getTime() + date.getTimezoneOffset() * 1000 * 60); // To fix the time zone issue.from 2012/6/31 to 2012/7/1 
        var day = date.getDate();
        var month = date.getMonth() + 1;
        if(day < 10) {
            day = '0' + day;
        }
        if(month < 10) {
            month = '0' + month;
        }
        return  month + '/' + day + '/' + date.getFullYear();
	},
	millisecondToDay :  function(millisecond){
		var date1  = new Date(millisecond);
        date1.setTime(date1.getTime() + date1.getTimezoneOffset() * 1000 * 60);
        var weekday = new Array(7);
        weekday[0] = "Sunday";
        weekday[1] = "Monday";
        weekday[2] = "Tuesday";
        weekday[3] = "Wednesday";
        weekday[4] = "Thursday";
        weekday[5] = "Friday";
        weekday[6] = "Saturday";
        var n = weekday[date1.getDay()];
        return n;
	},
    getPrepTimeParentTaskSchedules : function(cmp,taskId){
        var projectTaskId = '';
        
        if(taskId){
            projectTaskId = taskId;
        }else {
            projectTaskId = cmp.get("v.scheduleRec").projectTaskId;
        }
        
        var action = cmp.get("c.getPTRelatedScheduleRecord");
        action.setParams({
            "prepPTId" : projectTaskId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = response.getReturnValue();
                //console.log(':::::::::result::::',result);
                if(result && result != 'Not Prep PT'){
                    var parentSchedules = JSON.parse(result);
                    for(var i = 0;i < parentSchedules.length;i++){
                        parentSchedules[i].displayName = parentSchedules[i].Name+'-'+parentSchedules[i].Project_Task__r.Name;
                    }
                    cmp.set("v.parentSchRecords",parentSchedules);
                    cmp.set("v.showParentSchSelection",true);
                }else {
                    cmp.set("v.showParentSchSelection",false);
                }
            }else {
                console.log(':::::parent:PT::qry::error:::',response.getError()[0].message);
            }
        });
        $A.enqueueAction(action);
    },
    checkForCRCreation : function(cmp){
        var scheduleRec = cmp.get("v.scheduleRec");
		var instructor = cmp.get("v.instructorSelected");
        console.log('::::::::instructor::::',instructor);
        console.log('',scheduleRec);
        var instructorId = '';
        var schEndDate = null;
        
        if(instructor.length > 0){
			instructorId = instructor[0].Id;
        }else if(scheduleRec.instructorId){
            instructorId = scheduleRec.instructorId;
        }
        
        if(scheduleRec.endDate){
            schEndDate = scheduleRec.endDate;
        }
        
        var schType = cmp.get("v.scheduleType");
        
        if(schType != 'Extend End Date' && schType != 'Room Change' && instructor != null){
            
            var action = cmp.get("c.checkContactAssignmentExist");
            action.setParams({
                "contactId" : instructorId,
                "parentId" : cmp.get("v.parentId"),
                "schType" : schType,
                "cAEndDate" : schEndDate
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state == 'SUCCESS'){
                    var alreayCAExist = response.getReturnValue();
                    console.log('::::::alreayCAExist::::',alreayCAExist);
                    if(!alreayCAExist){
                        var caMap = {};
                        caMap.Candidate_Name__c = instructorId;
                        caMap.Project__c = cmp.get("v.parentId");
                        caMap.Project_Task__c = scheduleRec.projectTaskId;
                        cmp.set("v.caMap",caMap);
                        cmp.set("v.showSpinner",false);
                        cmp.set("v.showCostRateModal",true);
                    }else {
                        this.scheduleCreationForOtherTypes(cmp);
                    }
                }else {
                    console.log('::::checkForCRCreation::error:::',response.getError());
                }
            });
        	$A.enqueueAction(action);
        }else {
            this.scheduleCreationForOtherTypes(cmp);
        }
    },
    setSchPlannedTime: function(cmp, event, helper, scheduleRec){
        var startTimeMinutes;
		var endTimeMinutes;
        var isEndTime = scheduleRec.endTime == '12:00 AM';
		
		if(scheduleRec.startTime) {
			startTimeMinutes = helper.getMinutes(cmp,scheduleRec.startTime, isEndTime);
			helper.filterEndTimeValues(cmp,scheduleRec.startTime);
		}
		
		if(scheduleRec.endTime){
			endTimeMinutes = helper.getMinutes(cmp,scheduleRec.endTime, isEndTime);
		}
		
		if(startTimeMinutes && endTimeMinutes){
			scheduleRec.startTimeMinutes = startTimeMinutes;
			scheduleRec.endTimeMinutes = endTimeMinutes;            
			scheduleRec.totalHrsPerSession = (endTimeMinutes - startTimeMinutes) / 60;
			scheduleRec.hoursPlanned = (scheduleRec.breakTimeHrs ? scheduleRec.totalHrsPerSession - scheduleRec.breakTimeHrs : scheduleRec.totalHrsPerSession);			
		}
        return scheduleRec;            
    }
	
})