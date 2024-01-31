({
    getWholeWeekDetails: function(component) {
        console.log('helper');
        var action = component.get("c.getWholeWeekInformation");
        action.setParams({
            selectedUser: component.get("v.summaryDetails").selectedDAUser
        });
        action.setCallback(this,function(response) { 
            if(response.getState() === "SUCCESS") {
                console.log("result::::",JSON.parse(response.getReturnValue()));
                var result = JSON.parse(response.getReturnValue());
                var weekRange = result.weekRange;
                component.set("v.weekRangeInfo",result.weekRange);
                if(weekRange.length > 0) {
                    var lastIndex = weekRange.length;
                    var selectedWeek = weekRange[lastIndex - 1];
                    
                    var obj = component.get("v.summaryDetails");
                    obj.selectedStart = this.apexDateFormatFunction(selectedWeek.split(' / ')[0]);
                    obj.selectedEnd = this.apexDateFormatFunction(selectedWeek.split(' / ')[1]);
                    obj.selectedWeekName = weekRange[lastIndex - 1];
                    if(weekRange.length === 1)
                    	obj.displayPreviousIcon = false;
                    else
                        obj.displayPreviousIcon = true;
                    
                    obj.displayNextIcon = false;
                    obj.currWkIndex = lastIndex - 1;
                    obj.userId = result.userId;
                    obj.todayDate = result.currDate;
                    
                    component.set("v.summaryDetails",obj);
                    component.set("v.weekchanged",true);
                    component.set("v.approverChanged",false);
                    if(weekRange.length > 0) {
                    	this.getSpecificWeekInfomations(component);
                    }else {
                        component.set("v.showSpinner",false);
                        component.set("v.dateSummaryDetails",[]);
                        component.set("v.projectSummaryDetails",[]);
                    }
                }
                
            }else{
                component.set("v.showSpinner",false);
                console.log("error:::::::whole::week::",response.getError()[0].message);
                component.set("v.successTitle",'Error');
                component.set("v.successMsg",response.getError()[0].message);
                component.set("v.displayInfoModal",true);
                // To open success/error modal cmp
                if(Array.isArray(component.find("successModal"))) {
                    component.find("successModal")[0].open();
                }else{
                    component.find("successModal").open();
                }                
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
    getSpecificWeekInfomations: function(component){
        component.set("v.showSpinner",true);
        var dt1;
        var dt2;
        if(component.get("v.summaryDetails").selectedStart){
            dt1 = component.get("v.summaryDetails").selectedStart;
        }
        if(component.get("v.summaryDetails").selectedEnd){
            dt2 = component.get("v.summaryDetails").selectedEnd;
        }
        
        if(dt1 && dt2){        
            var action = component.get("c.getSpecificWeekDetails");
            action.setParams({
                selectedUser: component.get("v.summaryDetails").selectedDAUser,
                summaryType: component.get("v.summaryDetails").selecedSummaryType,
                startDate: dt1,
                endDate: dt2
            });
            action.setCallback(this,function(response){
                if(response.getState() === 'SUCCESS'){
                    console.log(":::::::getSpecificWeekInfomations:::response::::::;",JSON.parse(response.getReturnValue()));
                    var result = JSON.parse(response.getReturnValue());
                    
                    component.set("v.specificWeekInfo",result);
                    component.set("v.wholeNotesDetails",result.insIdNotesDetails);  
                    // Contact filter
                    if(component.get("v.weekchanged"))
                        this.contactFilterFormation(component,result);
                    
                    // Contact based summary & week details formation
                    this.instructorBasedWeekFormation(component);
                    //component.set("v.showSpinner",false);
                }else {
                    component.set("v.showSpinner",false);
                    console.log("error:::::::::specific:::::",response.getError()[0].message);
                    component.set("v.successTitle",'Error');
                    component.set("v.successMsg",response.getError()[0].message);
                    component.set("v.displayInfoModal",true);
                    // To open success/error modal cmp
                    if(Array.isArray(component.find("successModal"))) {
                        component.find("successModal")[0].open();
                    }else{
                        component.find("successModal").open();
                    }
                }
            });
        	$A.enqueueAction(action);
        }else {
            component.set("v.showSpinner",false);
        }
    },
    contactFilterFormation : function(component,result){
        //Contact filter formation
        var summaryObj = component.get("v.summaryDetails");
        var summaryType = summaryObj.selecedSummaryType;
        summaryObj.contactList = result.contactList;
        if(result.contactList.length > 0){
            summaryObj.selectedContactId = result.contactList[0].Id;
        }else {
            summaryObj.selectedContactId = null;
        }
        
        component.set("v.summaryDetails",summaryObj);
    },
    instructorBasedWeekFormation :function(component){
        // summary total formation
        var summaryObj = component.get("v.summaryDetails");
        var summaryType = summaryObj.selecedSummaryType;
        var weekInfo = component.get("v.specificWeekInfo");
        var wholeInfo = [];
        if(summaryType == 'Date')
            wholeInfo = weekInfo.insIdDateEntries;
        else
            wholeInfo = weekInfo.insIdProEntries;
        
        var totalMap = {};
        totalMap.pendingHrsTotal = 0;
        totalMap.approvedHrsTotal = 0;
        totalMap.rejectedHrsTotal = 0;
        
        if(wholeInfo[summaryObj.selectedContactId]){
            for(var i = 0;i < wholeInfo[summaryObj.selectedContactId].length;i++) {
                totalMap.pendingHrsTotal += wholeInfo[summaryObj.selectedContactId][i].pendingHrs;
                totalMap.approvedHrsTotal += wholeInfo[summaryObj.selectedContactId][i].approvedHrs;
                totalMap.rejectedHrsTotal += wholeInfo[summaryObj.selectedContactId][i].rejectedHrs;
            }
            component.set("v.TotalHrsObj",totalMap);
            if(summaryType == 'Date') {
                component.set("v.dateSummaryDetails",wholeInfo[summaryObj.selectedContactId]);
            } else {
                component.set("v.projectSummaryDetails",wholeInfo[summaryObj.selectedContactId]);
            }
        }
        
        console.log(":::::totalMap.pendingHrsTotal::::",totalMap.pendingHrsTotal);
        if(component.get("v.updatedTCD").length == 0)
        	component.set("v.totalPendingHrs",totalMap.pendingHrsTotal);
        
        component.set("v.showSpinner",false);
    },
    notesFormationForInstructor: function(component){
        var wholeNotes = component.get("v.wholeNotesDetails");
        var selectedContact = component.get("v.summaryDetails").selectedContactId;
        if(wholeNotes && selectedContact && wholeNotes[selectedContact].length > 0)
        	component.set("v.notesDetails",wholeNotes[selectedContact]);
        else
            component.set("v.notesDetails",[]);
    },
    PreviousIconClick: function(cmp){
        console.log('previous icon click');
        cmp.set("v.showSpinner",true);
        var summaryObj = cmp.get("v.summaryDetails");
        var weekRange = cmp.get("v.weekRangeInfo");
        var currIndex = summaryObj.currWkIndex;
        var previousIndex = currIndex - 1;
        if(previousIndex === 0)
            summaryObj.displayPreviousIcon = false;
        
        summaryObj.selectedStart = this.apexDateFormatFunction(weekRange[previousIndex].split(' / ')[0]);
        summaryObj.selectedEnd = this.apexDateFormatFunction(weekRange[previousIndex].split(' / ')[1]);
        summaryObj.selectedWeekName = weekRange[previousIndex];
        summaryObj.currWkIndex = previousIndex;
        
        if(weekRange.length != 1)
            summaryObj.displayNextIcon = true;
        
        cmp.set("v.summaryDetails",summaryObj);
        //this.getSpecificWeekInfomations(cmp);
        this.displayConfirmationOnAllchanges(cmp);
        //cmp.set("v.showSpinner",false);
    },
    NextIconClick: function(cmp){
        console.log('next icon click');
        cmp.set("v.showSpinner",true);
        var summaryObj = cmp.get("v.summaryDetails");
        var weekRange = cmp.get("v.weekRangeInfo");
        var currIndex = summaryObj.currWkIndex;
        var nextIndex = currIndex + 1;
        if(nextIndex === (weekRange.length - 1))
            summaryObj.displayNextIcon = false;
        
        summaryObj.selectedStart = this.apexDateFormatFunction(weekRange[nextIndex].split(' / ')[0]);
        summaryObj.selectedEnd = this.apexDateFormatFunction(weekRange[nextIndex].split(' / ')[1]);
        summaryObj.selectedWeekName = weekRange[nextIndex];
        summaryObj.currWkIndex = nextIndex;
        
        if(weekRange.length != 1)
            summaryObj.displayPreviousIcon = true;
        
        cmp.set("v.summaryDetails",summaryObj);
        //this.getSpecificWeekInfomations(cmp);
        this.displayConfirmationOnAllchanges(cmp);
        //cmp.set("v.showSpinner",false);
    },
    getDelegatedUserInfo : function(component){
        var action = component.get("c.getDelegatedApproverRelatedUsrs");
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log("delegated approver:::::::",JSON.parse(response.getReturnValue()));
                var obj = component.get("v.summaryDetails");
                obj.delegatedApprovers = JSON.parse(response.getReturnValue());
                component.set("v.summaryDetails",obj);
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    timeEntriesUpdateFunction : function(component){
        var action = component.get("c.updateTCDStatus");
        action.setParams({
            updateString: JSON.stringify(component.get("v.updatedTCD")),
            actionType: component.get("v.actionType"),
            EmailType:component.get("v.emailType")
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var actionType = component.get("v.actionType");
                var msg = '';
                if(actionType == 'ApproveAll') {
                    msg = 'The time entries'+' approval status have been updated successfully.';
                }else if(actionType == 'RejectAll') {
                    msg = 'The time entries'+' rejected status have been updated successfully.';
                }else {
                    msg = 'The time entries'+' changes saved successfully.';
                }
                component.set("v.showSpinner",false);
                component.set("v.successTitle",'Success');
                component.set("v.successMsg",msg);
                component.set("v.displayInfoModal",true);
                
                if(Array.isArray(component.find("successModal"))) {
                    component.find("successModal")[0].open();
                }else{
                    component.find("successModal").open();
                }
            }else {
                component.set("v.showSpinner",false);
                console.log('::::error::::msg:::',response.getError()[0].message);
                component.set("v.successTitle",'Error');
                component.set("v.successMsg",response.getError()[0].message);
                component.set("v.displayInfoModal",true);
                if(Array.isArray(component.find("successModal"))) {
                    component.find("successModal")[0].open();
                }else{
                    component.find("successModal").open();
                }
            }
        });
        $A.enqueueAction(action);
    },
    updateSummaryInfo : function(component){
        var updatedTCD = component.get("v.updatedTCD");
        var summaryDetails = component.get("v.summaryDetails");
        var weekDetails = component.get("v.specificWeekInfo");
        var type = summaryDetails.selecedSummaryType;
        var contactId = summaryDetails.selectedContactId;
        var timeEntries = [];
        if(type == 'Date'){
            timeEntries = weekDetails.insIdDateEntries[contactId];
        }else {
            timeEntries = weekDetails.insIdProEntries[contactId];
        }
        console.log('::::::::timeEntries:updateSummaryInfo:::',timeEntries);
        /*for(var i = 0; i < timeEntries.length;i++){
            var entries = timeEntries[i].entries;
            timeEntries[i].pendingHrs = 0;
            timeEntries[i].approvedHrs = 0;
            timeEntries[i].rejectedHrs = 0;
            for(var j = 0;j < entries.length;j++){
                if(entries[j].status == 'Submitted') {
                    timeEntries[i].pendingHrs += entries[j].hours;             
                }else if(entries[j].status == 'Approved'){
                    timeEntries[i].approvedHrs += entries[j].hours;
                }else if(entries[j].status == 'Rejected'){
                    timeEntries[i].rejectedHrs += entries[j].hours;
                }
            }
            
            if(timeEntries[i].pendingHrs == 0) {
                timeEntries[i].pendingHrs = timeEntries[i].approvedHrs + timeEntries[i].rejectedHrs;
            }else {
                timeEntries[i].pendingHrs += timeEntries[i].approvedHrs + timeEntries[i].rejectedHrs;
            }
                
        }
        console.log('::::::timeEntries::::',timeEntries);
        if(type == 'Date'){
            weekDetails.insIdDateEntries[contactId] = timeEntries;
        }else {
            weekDetails.insIdProEntries[contactId] = timeEntries;
        }*/
        //component.set("v.specificWeekInfo",weekDetails);
        this.instructorBasedWeekFormation(component);
    },
    displayConfirmationOnAllchanges : function(component){
        component.set("v.showSpinner",false);
        var updatedTCDS = component.get("v.updatedTCD");
        if(updatedTCDS.length > 0){
            component.set("v.confirmationaAlert",true);
            if(Array.isArray(component.find("AlertModal"))) {
                component.find("AlertModal")[0].open();
            }else{
                component.find("AlertModal").open();
            }
        }else {
            if(!component.get("v.gotoSumaryClicked")) {
                if(!component.get("v.approverChanged")){
                    this.getSpecificWeekInfomations(component);
                }else {
                    this.getWholeWeekDetails(component);
                }
            	
            }else {
                console.log('enter semi monthly display');
                component.set("v.displaySummary",false);
                component.set("v.displayDetail",false);
                component.set("v.displaySemiMonthly",true);
            }
        }
    }
})