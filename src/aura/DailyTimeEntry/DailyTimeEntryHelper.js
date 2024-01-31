({
    specificWeekInformation : function(component) {
        var wholeInfo = component.get("v.initialValues");
        var selectedStart = component.get("v.selectedStart");
        var selectedEnd = component.get("v.selectedEnd");
        component.set("v.showSpinner",true);
        console.log('::::::::wholeInfo::::::',selectedStart,selectedEnd,wholeInfo.contactId);
        if(wholeInfo.contactId != null) {
            var action = component.get("c.specificWeekInformation");
            action.setParams({
                "startDt": selectedStart,
                "endDt": selectedEnd,
                "contactId": wholeInfo.contactId
            });
            action.setCallback(this,function(response) { 
                if(response.getState() === "SUCCESS") {
                    console.log(':::::::::specific:::::::',JSON.parse(response.getReturnValue()));
                    
                    var result = JSON.parse(response.getReturnValue());
                    var weekArr = [];
                    var totalSum = 0.00;
                    for(var i = 0; i < result.entryDetails.length; i ++) {
                        weekArr.push(result.entryDetails[i]);
                        totalSum += result.entryDetails[i].totalHrs;
                    }
                    console.log('::::::totalSum::::::',totalSum);
                    var wholeWeeks = wholeInfo.weekRange;
                    // Find current week range index
                    var index;
                    var selectedWeek = this.dateFormatFunction(selectedStart)+' - '+this.dateFormatFunction(selectedEnd);
                    for(var i = 0;i < wholeWeeks.length;i++){
                        if(wholeWeeks[i] == selectedWeek) {
                            index = i;
                        }
                    }
                    component.set("v.weekList",weekArr);
                    component.set("v.weekName",selectedWeek);
                    component.set("v.nextSelection",true);
                    component.set("v.currWeekIndex",index);
                    component.set("v.notesList",result.notes);
                    component.set("v.showAllbuttons",result.displaySubmitBtn);
                    component.set("v.showRecallBtn",result.displayRecallBtn);
                    component.set("v.showSpinner",false);
                    component.set("v.weekHrsSum",totalSum);
                    
                    var childCmp = component.find("entryDetailCmp");
                    //console.log(":::::::childCmp::::",childCmp);
                    var loanNextWeek = false;
                    if(childCmp){
                        if(Array.isArray(childCmp)) {
                            loanNextWeek = childCmp[0].get("v.loadNextWeekData");
                            
                        }else{
                            loanNextWeek = childCmp.get("v.loadNextWeekData");
                        }
                    }
                    //console.log("loanNextWeek",loanNextWeek);
                    if(loanNextWeek){
                        //console.log(":::::::::::weekl::::::",component.get("v.weekList"));
                        var weekList = component.get("v.weekList");
                        
                        if(component.get("v.previousIconClick"))
                            component.set("v.dateSelected",weekList[weekList.length - 1].Date);
                        else if(component.get("v.nextIconClick"))
                            component.set("v.dateSelected",weekList[0].Date);
                        
                        this.getSpecificDateInformation(component);
                    }
                    component.set("v.specificWeekInfo",JSON.parse(response.getReturnValue()));
                    
                    //To call the submit action after holiday hrs save & refreshing the list to perform the submit action
                    if(component.get("v.buttonType") == 'Submit'){
                        this.submitAction(component);
                    }
                }else {
                    component.set("v.showSpinner",false);
                    console.log('::::error:::::',response.getError()[0].message);
                    component.set("v.successMsg",response.getError()[0].message);
                    component.set("v.successTitle",'Error');
                    component.set("v.displaySuccessModal",true);
                    // To open error msg sldsModal cmp
                    if(Array.isArray(component.find("successMsgModal"))) {
                        component.find("successMsgModal")[0].open();
                    }else{
                        component.find("successMsgModal").open();
                    }
                }
            });
            $A.enqueueAction(action);
        }else {
            var weekArr = [];
            var totalSum = 0.00;
            var wholeWeeks = wholeInfo.weekRange;
            // Find current week range index
            var index;
            var selectedWeek = this.dateFormatFunction(selectedStart)+' - '+this.dateFormatFunction(selectedEnd);
            for(var i = 0;i < wholeWeeks.length;i++){
                if(wholeWeeks[i] == selectedWeek) {
                    index = i;
                }
            }
            component.set("v.weekList",weekArr);
            component.set("v.weekName",selectedWeek);
            component.set("v.nextSelection",true);
            component.set("v.currWeekIndex",index);
            component.set("v.showSpinner",false);
            component.set("v.weekHrsSum",totalSum);
            component.set("v.showAllbuttons",false);
            component.set("v.showRecallBtn",false);
        }
    },
    dateFormatFunction : function(dateVal){
        return dateVal.split('-')[1]+'/'+dateVal.split('-')[2]+'/'+dateVal.split('-')[0];
    },
    apexDateFormatFunction : function(dateval){
        return dateval.split('/')[2]+'-'+dateval.split('/')[0]+'-'+dateval.split('/')[1];
    },
    getSpecificDateInformation : function(component){
        component.set("v.showSpinner",true);
        console.log("enter getSpecificDateInformation");
        var summarydiv = component.find("summary").getElement();
        
        $A.util.removeClass(summarydiv,'slds-show');
        $A.util.addClass(summarydiv,'slds-hide');
        console.log("summary div",summarydiv);
        component.set("v.displayDetail",true);
        component.set("v.showSpinner",false);
    },
    submitAction: function(component){
        component.set("v.showSpinner",true);
        console.log("submit click");
        var specificWeekData = [];
        if(component.get("v.specificWeekInfo"))
        	specificWeekData = component.get("v.specificWeekInfo").entryDetails;
        
        //console.log("::submit:::::::specificWeekData::::::",specificWeekData);
        var entriesArr = [];
        var holidayEntriesForSave = [];
        for(var i = 0;i < specificWeekData.length;i++){
            if(specificWeekData[i].hasOwnProperty("entries")) {
                var records = [];
                records = specificWeekData[i].entries;
                if(records){
                    for(var j = 0;j < records.length;j++){
                        if(records[j].dayId !== null) {
                            entriesArr.push(records[j]);
                        }
                        if(records[j].hours != null && records[j].isNew && records[j].isHoliday){
                            holidayEntriesForSave.push(records[j]);
                        }
                    }
                }
            }
        }
        console.log(":::submit::::::entriesArr::::::",entriesArr);
        console.log(":::submit::::::holidayEntriesForSave::::::",holidayEntriesForSave);
        if(entriesArr.length > 0 && holidayEntriesForSave.length == 0){
            var action = component.get("c.submitActionFunction");
            action.setParams({
                submitdayJson: JSON.stringify(entriesArr)
            });
            action.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    component.set("v.showSpinner",false);
                    component.set("v.successMsg",'The time entries have successfully been submitted to your supervisor for approval.');
                    component.set("v.successTitle",'Success');
                    component.set("v.displaySuccessModal",true);
                    component.set("v.buttonType","");
                    
                    // To open success msg sldsModal cmp
                    if(Array.isArray(component.find("successMsgModal"))) {
                        component.find("successMsgModal")[0].open();
                    }else{
                        component.find("successMsgModal").open();
                    }
                    
                    this.specificWeekInformation(component);
                }else {
                    component.set("v.showSpinner",false);
                    console.log('::::error:::::',response.getError()[0].message);
                    component.set("v.successMsg",response.getError()[0].message);
                    component.set("v.successTitle",'Error');
                    component.set("v.displaySuccessModal",true);
                    component.set("v.buttonType","");
                    
                    // To open error msg sldsModal cmp
                    if(Array.isArray(component.find("successMsgModal"))) {
                        component.find("successMsgModal")[0].open();
                    }else{
                        component.find("successMsgModal").open();
                    }
                } 
            });
           $A.enqueueAction(action);
        }else if(holidayEntriesForSave.length > 0){
            // To save the holiday hrs before the submit action
            // Added by NS on Nov 27 2018
            var action = component.get("c.dmlOperationFunction");
            action.setParams({
                timeDayJson: JSON.stringify(holidayEntriesForSave),
                conId: component.get("v.initialValues").contactId,
                startDate: component.get("v.specificWeekInfo").startDate,
                endDate: component.get("v.specificWeekInfo").endDate
            });
            action.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    console.log(":::::::::::success:on::save:before::submit:::",response.getReturnValue());
                    // CAll the week method to refresh the list to have newly created record ids to perform the submit action
                    this.specificWeekInformation(component);
                }else {
                    console.log('::::error::save::before::submit::',response.getError()[0].message);
                }
            });
            $A.enqueueAction(action);
        }else {
            component.set("v.showSpinner",false);
        }
    },
    recallAction: function(component){
        component.set("v.showSpinner",true);
        console.log("recall btn click");
        var specificWeekData = [];
        if(component.get("v.specificWeekInfo"))
        	specificWeekData = component.get("v.specificWeekInfo").entryDetails;
        
        //console.log(":::recall::::::specificWeekData::::::",specificWeekData);
        var entriesArr = [];
        for(var i = 0;i < specificWeekData.length;i++){
            if(specificWeekData[i].hasOwnProperty("entries")) {
                var records = [];
                records = specificWeekData[i].entries;
                if(records){
                    for(var j = 0;j < records.length;j++){
                        if(records[j].dayId !== null) {
                            entriesArr.push(records[j]);
                        }
                    }
                }
            }
        }
        //console.log("::::recall:::::entriesArr::::::",entriesArr);        
        if(entriesArr.length > 0){
            var action = component.get("c.recallActionFunction");
            action.setParams({
                recallJson: JSON.stringify(entriesArr)
            });
            action.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    component.set("v.showSpinner",false);
                    component.set("v.successMsg",'Recalled all time entries Successfully.');
                    component.set("v.successTitle",'Success');
                    component.set("v.displaySuccessModal",true);
                    
                    // To open success msg sldsModal cmp
                    if(Array.isArray(component.find("successMsgModal"))) {
                        component.find("successMsgModal")[0].open();
                    }else{
                        component.find("successMsgModal").open();
                    }
                    
                    this.specificWeekInformation(component);
                }else {
                    component.set("v.showSpinner",false);
                    console.log('::::error:::::',response.getError()[0].message);
                    component.set("v.successMsg",response.getError()[0].message);
                    component.set("v.successTitle",'Error');
                    component.set("v.displaySuccessModal",true);
                    
                    // To open error msg sldsModal cmp
                    if(Array.isArray(component.find("successMsgModal"))) {
                        component.find("successMsgModal")[0].open();
                    }else{
                        component.find("successMsgModal").open();
                    }
                }
            });
            $A.enqueueAction(action);
        }else {
            component.set("v.showSpinner",false);
        }
    },
    weekSummaryPrevious: function(component){
        console.log('enter previous');
        component.set("v.showSpinner",true);
        // Enable next week click icon
        component.set("v.nextIconDisplay",true);
        var currentIndex = component.get("v.currWeekIndex");
        var initial = component.get("v.initialValues");
        var weekRange = initial.weekRange;
        var weekname = component.get("v.weekName");
        var previousWeekIndex = weekRange.indexOf(weekname) - 1;
        console.log(":::::::::::weekRange[previousWeekIndex]:::::",currentIndex,weekRange[previousWeekIndex]);
        var currStart = this.apexDateFormatFunction(weekRange[previousWeekIndex].split(' - ')[0]);
        var currEnd = this.apexDateFormatFunction(weekRange[previousWeekIndex].split(' - ')[1]);
        
        if(previousWeekIndex == 0)
            component.set("v.previousIconDisplay",false);
        
        component.set("v.currWeekIndex",previousWeekIndex);
        //console.log('enter nextweekclick',initial.currWeekStart,initial.currWeekEnd);
        component.set("v.selectedStart",currStart);
        component.set("v.selectedEnd",currEnd);
        component.set("v.weekName",weekRange[previousWeekIndex]);
        
        component.set("v.showSpinner",false);
        this.specificWeekInformation(component);
    },
    weekSummaryNext: function(component){
        component.set("v.showSpinner",true);
        console.log('enter nextweekclick');
        // Enable previous week icon
        component.set("v.previousIconDisplay",true);
        
        var currentIndex = component.get("v.currWeekIndex");
        var initial = component.get("v.initialValues");
        var weekRange = initial.weekRange;
        var weekname = component.get("v.weekName");
        var nextWeekIndex = weekRange.indexOf(weekname) + 1;
        
        var currStart = this.apexDateFormatFunction(weekRange[nextWeekIndex].split(' - ')[0]);
        var currEnd = this.apexDateFormatFunction(weekRange[nextWeekIndex].split(' - ')[1]);
        
        if(nextWeekIndex == (weekRange.length - 1))
            component.set("v.nextIconDisplay",false);
        
        component.set("v.currWeekIndex",nextWeekIndex);
        console.log('enter nextweekclick',initial.currWeekStart,initial.currWeekEnd);
        component.set("v.selectedStart",currStart);
        component.set("v.selectedEnd",currEnd);
        component.set("v.weekName",weekRange[nextWeekIndex]);
        component.set("v.showSpinner",false);
        this.specificWeekInformation(component);
    },
    updatePreviousWeekLines: function(component){
        console.log("previousWeek line",component.get("v.previousChargeCodeList"));
        component.set("v.showSpinner",true);
        var CCList = component.get("v.previousChargeCodeList");
        var performDML = false;
        for(var i = 0;i < CCList.length;i++){
            if(CCList.lineId !== null && CCList.lineId != '' && !CCList.isAvailable_FutureWeek){
                performDML = true;
            }
        }
        
        if(performDML){
            var action = component.get("c.previousWeekLineUpdation");
            action.setParams({
                lineJson: JSON.stringify(CCList)
            });
            action.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    component.set("v.showSpinner",false);
                    this.specificWeekInformation(component);
                }else {
                    component.set("v.showSpinner",false);
                    console.log('::::error:::::',response.getError()[0].message);
                    component.set("v.successMsg",response.getError()[0].message);
                    component.set("v.successTitle",'Error');
                    component.set("v.displaySuccessModal",true);
                    
                    // To open error msg sldsModal cmp
                    if(Array.isArray(component.find("successMsgModal"))) {
                        component.find("successMsgModal")[0].open();
                    }else{
                        component.find("successMsgModal").open();
                    }
                }
            });
            $A.enqueueAction(action);
        }else {
            component.set("v.showSpinner",false);
        }
    },
    destoryChild : function(component){
        var summarydiv = component.find("summary").getElement();
        component.set("v.displayDetail",false);
        
        $A.util.removeClass(summarydiv,'slds-hide');
        $A.util.addClass(summarydiv,'slds-show');
        component.set("v.loadNextWeekData",false);
        this.specificWeekInformation(component);
    }
})