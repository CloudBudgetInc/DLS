({
	doinit : function(cmp, event, helper) {
				
		cmp.set("v.showSpinner",true);
		var type = cmp.get("v.scheduleType"),
            title = (type == 'Regular') ? 'New Schedule' : type;
            
		if(type == 'Room Change' || type == 'Move Online'){
			cmp.set("v.disableInput",true);
		}
        
		cmp.set("v.headerTitle",title);
		cmp.set("v.scheduleRec",{});
		
        var currentUsrProfileName = cmp.get('v.currentUsrProfileName'),
			onlineRoomId = cmp.get('v.onlineRoomId'),            
            selection = [];
        
        if(currentUsrProfileName == 'LTS' && cmp.get('v.isDLSOnlineProject')){
            selection.push({Id:onlineRoomId, Name:"Zoom - Online"});
        }else{
            cmp.set("v.roomCondition", '');
        }
        
        cmp.set('v.roomSelected', selection);
        
		helper.getScheduleInitialDetails(cmp, event, helper);		
	},
	saveBtnClick : function(cmp, event, helper){
		var isValid = helper.validateInput(cmp);
		console.log(':::save:::validation::',isValid);
		if(isValid){
			cmp.set("v.btnType",'Save');
			helper.calculateTotalHrs(cmp);
			helper.getConflictInformation(cmp);
		}
	},
	cancelBtnClick : function(cmp, event, helper){
		cmp.set("v.scheduleRec",{});
        cmp.find("inputModal").close();
		cmp.set("v.displayInputModal",false);
		cmp.set("v.typeOfAction",'');
		cmp.set("v.scheduleId",'');
		var appEvent = $A.get("e.c:reloadEvent");
        appEvent.fire();
	},
	getTimezoneValues : function(cmp, event, helper){
		cmp.set("v.timezones",window.allTimezones);
		console.log(':::::::::::timezones:::',window.allTimezones);
	},
	setPlannedTime : function(cmp, event, helper){
		var scheduleRec = helper.setSchPlannedTime(cmp, event, helper, cmp.get('v.scheduleRec'));
        cmp.set('v.scheduleRec', scheduleRec);
	},
	setExactPlannedTime : function(cmp, event, helper){
		var scheduleRec = cmp.get("v.scheduleRec");
		if(scheduleRec.totalHrsPerSession && scheduleRec.breakTimeHrs) {
            scheduleRec.hoursPlanned = scheduleRec.totalHrsPerSession - scheduleRec.breakTimeHrs;
        }else if(scheduleRec.totalHrsPerSession) {
            scheduleRec.hoursPlanned = scheduleRec.totalHrsPerSession;
        }
       
        console.log('scheduleRec::',JSON.stringify(scheduleRec));
        cmp.set("v.scheduleRec",scheduleRec);
	},
	calculateBtnClick : function(cmp, event, helper){
		var isValid = helper.validateInput(cmp);
		if(isValid){
			helper.calculateTotalHrs(cmp);
		}
	},
	conflictYesClick : function(cmp, event, helper){
		cmp.set("v.showSpinner",true);
        cmp.find("conflictModel").close();
		cmp.set("v.showConflictModal",false);
		if(cmp.get("v.btnType") == 'Save'){
			console.log("::::::::::::::",cmp.get("v.scheduleType"),cmp.get("v.scheduleRec").isNew);
			if(cmp.get("v.scheduleType") == 'Regular') {
				helper.scheduleRecordDMLAction(cmp);
			}else if(cmp.get("v.scheduleType") == 'Substitute'){
				helper.substituteScheduleDMLAction(cmp);
			}else if(cmp.get("v.scheduleType") != 'Regular' && (cmp.get("v.scheduleRec").isNew || cmp.get("v.scheduleRec").isUpdate)){
				console.log('::::::enter:::::');
				cmp.find("conflictModel").close();
                //Method to open cost rate creation model based on rate type
                helper.checkForCRCreation(cmp);
			}
		}else {
            console.log('In Activate schedule record');
			helper.activateScheduleRecord(cmp);
		}
	},
	closeConlfictModel : function(cmp, event, helper){
		cmp.find("conflictModel").close();
	},
	closeSuccessModel : function(cmp,event,helper){
		if(cmp.get("v.successTitle") == 'Success') {
            if(cmp.find("successModel")){
                cmp.find("successModel").close();
            }
			cmp.set("v.showSuccessModal",false);
			cmp.set("v.scheduleRec",{});
            if(cmp.find("inputModal")){
                cmp.find("inputModal").close();
            }
			cmp.set("v.displayInputModal",false);
			cmp.set("v.typeOfAction",'');
			cmp.set("v.scheduleId",'');
			cmp.set("v.showSpinner",false);
			var appEvent = $A.get("e.c:reloadEvent");
			appEvent.fire();
		}else {
			cmp.find("successModel").close();
		}
		
	},
	lookupSearch : function(cmp, event, helper){
		// Get the getLookupRecords server side action
        const serverSearchAction = cmp.get('c.getLookupRecords');        
        event.getSource().search(serverSearchAction); // Passes the action to the Lookup component by calling the search method      
	},
	roomLookupSearch : function(cmp, event, helper){
		// Get the getLookupRecords server side action
        const serverSearchAction = cmp.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        if(cmp.get("v.scheduleType") != 'Substitute'){
        	cmp.find('roomLookup').search(serverSearchAction);
        }else {
        	cmp.find('subRoomLookup').search(serverSearchAction);
        }
	},
	getSubstituteEvents : function(cmp, event, helper){
		if(cmp.get("v.typeOfAction") != 'Activate' && cmp.get("v.scheduleType") == 'Substitute' && cmp.get("v.displayInputModal")){
			var startDate = cmp.get("v.scheduleRec").startDate;
			var endDate = cmp.get("v.scheduleRec").endDate;
			var isValid;
			if(startDate && endDate){
				isValid = helper.validateInput(cmp);
				console.log('::::::isValid::::',isValid);
				if(isValid) {
					helper.getEventDetailForSubstituteType(cmp);
				}
			}
		}
	},
	substituteSaveClick :  function(cmp, event, helper){
		var isValid = helper.validateInput(cmp);
		console.log('::::::isValid::::',isValid);
		
		//validate the selected date range with existing event dates
		var dateList = [];
		dateList = helper.extractSelectedSubstituteDate(cmp);
		var stDt = cmp.get("v.scheduleRec").startDate;
		var endDt = cmp.get("v.scheduleRec").endDate;
		
		if(dateList.length > 0) {
			if(new Date(stDt).getTime() > new Date(dateList[0]).getTime()){				
                
				isValid = false;
			}
            
			if(new Date(endDt).getTime() < new Date(dateList[dateList.length - 1]).getTime()){				
                
				isValid = false;
			}
		}
		
        cmp.find("startDtValue").setCustomValidity("");
        cmp.find("startDtValue").reportValidity();
        
        cmp.find("endDtValue").setCustomValidity("");
        cmp.find("endDtValue").reportValidity();
        
        
		if(isValid){
			
			cmp.set("v.btnType",'Save');
			helper.calculateTotalHrs(cmp);
			helper.getConflictInformation(cmp);
		}
	},
	substituteCancelClick :  function(cmp, event, helper){
        cmp.find("substituteModal").close();
		cmp.set("v.displayInputModal",false);
		var appEvent = $A.get("e.c:reloadEvent");
        appEvent.fire();
	},
    testerSaveClick :  function(cmp, event, helper){
        var isValid = true,
            inputElements = cmp.find('testerFormInputs'),
            lookupElements = cmp.find('testerFormLookupInputs'),
            selectInputElements = cmp.find('testerFormSelectInputs'),
            scheduleRec = cmp.get("v.scheduleRec"),
            noOfDays = 0;
        
        if(scheduleRec.startDate && scheduleRec.endDate){
            noOfDays = moment(scheduleRec.endDate).diff(moment(scheduleRec.startDate), 'days') == 0 ? 1 : moment(scheduleRec.endDate).diff(moment(scheduleRec.startDate), 'days');
        }
        
        for(var index = 0; index < inputElements.length; index++){
            var label = inputElements[index].get('v.label');
                            
            if(!inputElements[index].checkValidity()){
                isValid = false;
            }
            
            if(label == 'End Date'){
                
                if(noOfDays < 0){
                    inputElements[index].setCustomValidity('End Date should not be less than Start Date.');
                    isValid = false;
                }else{
                    inputElements[index].setCustomValidity('');
                }
            }
            inputElements[index].reportValidity();
        }
        
        for(var index = 0; index < lookupElements.length; index++){
            if(!lookupElements[index].validate()){
                isValid = false;
            }
        }
		
        for(var index = 0; index < selectInputElements.length; index++){
            
            if(!selectInputElements[index].checkValidity()){                 
                isValid = false;
            }
            selectInputElements[index].showHelpMessageIfInvalid();
        }

        if(isValid){
            
            scheduleRec.dayVal = {'monday' : false,'tuesday' : false,'wednesday' : false,'thursday' : false,'friday' : false,'saturday' : false,'sunday': false};
            scheduleRec.dayVal[moment(scheduleRec.startDate).format('dddd').toLowerCase()] = true;
            
            scheduleRec.totalHrsPlanned = noOfDays * scheduleRec.totalHrsPerSession;        
            cmp.set("v.scheduleRec", scheduleRec);
            cmp.set("v.btnType",'Save');
            helper.calculateTotalHrs(cmp);
            helper.getConflictInformation(cmp);
        }
	},
    testerCancelClick :  function(cmp, event, helper){
        cmp.find("testerModal").close();
		cmp.set("v.displayInputModal",false);
		var appEvent = $A.get("e.c:reloadEvent");
        appEvent.fire();
	},
	addOrRemoveForSubstituteEvents :  function(cmp, event, helper){
		var weekIndex = event.currentTarget.getAttribute('data-weekIndex');
		var dayIndex = event.currentTarget.getAttribute('data-dayIndex');
		var substituteEventDates = cmp.get("v.substituteEventsList");
		console.log('::::::::weekObj:::::',weekIndex,dayIndex);
		
		var weekRec = substituteEventDates[weekIndex];
		var dayRec = weekRec.daysVal[dayIndex];
		
		if(dayRec.isNew){
			if(dayRec.isSelected){
				dayRec.isSelected = false;
				dayRec.style = 'background-color: #ff6666';
			}else {
				dayRec.isSelected = true;
				dayRec.style = 'background-color: #53c653';
			}
		}
        weekRec.daysVal[dayIndex] = dayRec;
		substituteEventDates[weekIndex] = weekRec;
		
        console.log(substituteEventDates);
		cmp.set("v.substituteEventsList",substituteEventDates);
	},
    displayParentSchRecords : function(cmp, event, helper){
        console.log(':::::::::parentSchRecords::::',cmp.get("v.parentSchRecords"));
        helper.getPrepTimeParentTaskSchedules(cmp,'');
    },
    handleCostRateResult : function(cmp, event,helper){
        var costRateInfo = event.getParam("costRateInfo");
        var costRateId = '';
        var type = '';
        if(costRateInfo.costRateId && costRateInfo.costRateLabel){
            if(costRateInfo.costRateLabel == 'RateCost'){
                costRateId = costRateInfo.costRateId;   
                type = 'Approved CR';
            }else {
                costRateId = costRateInfo.costRateId; 
                type = 'Draft CR';
            }
        }
        cmp.set("v.costRateId",costRateId);
        cmp.set("v.CRType",type);
        cmp.set("v.showCostRateModal",false);
        if(!costRateInfo.isErrorFROMCRModal){
            cmp.set("v.showSpinner",true);
            helper.scheduleCreationForOtherTypes(cmp);
        }
    }
})