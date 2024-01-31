({
    loadCurrentData : function(component){
        component.set("v.showSpinner",true);
        console.log('enter load current data');
        var summaryObj = component.get("v.summaryDetails");
        var weekDetails = component.get("v.specificWeekInfo");
        var selectedRowValue = component.get("v.selectedRowValue");
        console.log(':::::selectedRowValue:::::::',selectedRowValue);
        var timeEntries = [];
        var entriesList = [];
        var type = summaryObj.selecedSummaryType;
        var contactId = summaryObj.selectedContactId;
        var viewName = '';
        
        if(type == 'Date'){
            timeEntries = weekDetails.insIdDateEntries[contactId];
        }else {
            timeEntries = weekDetails.insIdProEntries[contactId];
        }
        for(var i = 0;i < timeEntries.length;i++){
            if(type == 'Date' && timeEntries[i].dateVal === selectedRowValue){
                entriesList = timeEntries[i].entries;
                viewName = selectedRowValue;
            }else if(type == 'Project' && timeEntries[i].projectId === selectedRowValue){
                entriesList = timeEntries[i].entries;
                viewName = timeEntries[i].projectName;
            }
        }
        console.log('::::::entriesList::::',entriesList);
        component.set("v.detailInfo",entriesList);
        component.set("v.viewName",viewName);
        component.set("v.approvedHrs",0);
        component.set("v.rejectedHrs",0);
        component.set("v.nextIconClicked",false);
        component.set("v.previousIconClicked",false);
        this.alreadyApproved_RejectedEntriesInfo(component);
        component.set("v.showSpinner",false);
    },
    alreadyApproved_RejectedEntriesInfo : function(component){
        var entries = component.get("v.detailInfo");
        var alreadyApprovedIds = [];
        var alreadyRejectedIds = [];
        var approvedHrs = 0;
        var rejectedHrs = 0;
        for(var i = 0;i < entries.length;i++){
            if(entries[i].status == 'Approved'){
                alreadyApprovedIds.push(entries[i].dayId);
                approvedHrs += entries[i].hours;
            }else if(entries[i].status == 'Rejected'){
                alreadyRejectedIds.push(entries[i].dayId);
                rejectedHrs += entries[i].hours;
            }
        }
        component.set("v.alreadyApprovedIds",alreadyApprovedIds);
        component.set("v.alreadyRejectedIds",alreadyRejectedIds);
        component.set("v.approvedHrs",approvedHrs);
        component.set("v.rejectedHrs",rejectedHrs);
    },
    PreviousIconClick : function(component) {
        component.set("v.showSpinner",true);
        var weekDetails = component.get("v.specificWeekInfo");
        var summaryObj = component.get("v.summaryDetails");
        var selectedData = component.get("v.selectedRowValue");
        
        var type = summaryObj.selecedSummaryType;
        var contactId = summaryObj.selectedContactId;
        
        var currIndex = component.get("v.currentIndex");
        var previousIndex;
        var lastIndex;
        
        // To display alert to save the changes
        var currentEntries = component.get("v.detailInfo");
        var updatedTCDIds = component.get("v.tcdIds");
        var changesMade = false;
        for(var i = 0;i < currentEntries.length;i++){
            if(currentEntries[i].isUpdated && updatedTCDIds.indexOf(currentEntries[i].dayId) == -1)
                changesMade = true;
        }
        
        if(type == 'Date'){
            previousIndex = weekDetails.weekDates.indexOf(selectedData) - 1;
            lastIndex = weekDetails.weekDates.length - 1;
            selectedData = weekDetails.weekDates[previousIndex];
        }else {
            projects = weekDetails.insIdProjectList[contactId];
            lastIndex = projects.length - 1;
            var index;
            for(var i = 0; i < projects.length;i++) {
                if(projects[i].Id === selectedData)
                    index = i;
            }
            previousIndex = index - 1;            
            if(previousIndex >= 0)
                selectedData = projects[previousIndex].Id;
        }
        
        component.set("v.previousIconClicked",true);
        
        if(changesMade) {
            // show popup to save the changes
            component.set("v.showSpinner",false);
            component.set("v.displaySaveAlert",true);
            console.log('changesMade:::::::::',component.find("saveAlertModal"));
            if(Array.isArray(component.find("saveAlertModal"))) {
                component.find("saveAlertModal")[0].open();
            }else{
                component.find("saveAlertModal").open();
            }
        }else {
            if(previousIndex < 1)
                component.set("v.previousIcondisplay",false);
            
            if(previousIndex === lastIndex)
                component.set("v.nextIcondisplay",false);
            else
                component.set("v.nextIcondisplay",true);
            
            component.set("v.currentIndex",previousIndex);
            component.set("v.selectedRowValue",selectedData);
            this.loadCurrentData(component);
        }
    },
    NextIconClick : function(component){
        var weekDetails = component.get("v.specificWeekInfo");
        var summaryObj = component.get("v.summaryDetails");
        var selectedData = component.get("v.selectedRowValue");
        
        var type = summaryObj.selecedSummaryType;
        var contactId = summaryObj.selectedContactId;
        
        var currIndex = component.get("v.currentIndex");
        var nextIndex;
        var lastIndex;
        
        // To display alert to save the changes
        var currentEntries = component.get("v.detailInfo");
        var updatedTCDIds = component.get("v.tcdIds");
        var changesMade = false;
        for(var i = 0;i < currentEntries.length;i++){
            if(currentEntries[i].isUpdated && updatedTCDIds.indexOf(currentEntries[i].dayId) == -1)
                changesMade = true;
        }
        
        if(type == 'Date'){
            nextIndex = weekDetails.weekDates.indexOf(selectedData) + 1;
            lastIndex = weekDetails.weekDates.length - 1;
            selectedData = weekDetails.weekDates[nextIndex];
        }else {
            projects = weekDetails.insIdProjectList[contactId];
            lastIndex = projects.length - 1;
            var index;
            for(var i = 0; i < projects.length;i++) {
                if(projects[i].Id === selectedData)
                    index = i;
            }
            nextIndex = index + 1;
            if(nextIndex <= lastIndex)
                selectedData = projects[nextIndex].Id;
        }
        
        component.set("v.nextIconClicked",true);
        if(changesMade){
            // show popup to save the changes
            component.set("v.showSpinner",false);
            component.set("v.displaySaveAlert",true);
            if(Array.isArray(component.find("saveAlertModal"))) {
                component.find("saveAlertModal")[0].open();
            }else{
                component.find("saveAlertModal").open();
            }
        }else {
            if(nextIndex < 1)
            	component.set("v.previousIcondisplay",false);
            else
                component.set("v.previousIcondisplay",true);
            
            if(nextIndex === lastIndex)
                component.set("v.nextIcondisplay",false);
            
            component.set("v.currentIndex",nextIndex);
            component.set("v.selectedRowValue",selectedData);
            this.loadCurrentData(component);
        }
    },
    approveAllAction : function(component){
        console.log('1');
        var arrayToUpdate = this.wholeActionTCDFormation(component,'Approved');
        var totalHRs = component.get("v.overAllActionHrs");
        var summaryObj = component.get("v.summaryDetails");
        var DAMsg = '';
        
        if(summaryObj.selectedDAUser != '--None--')
            DAMsg = 'You are approving timesheet on behalf of <b>'+summaryObj.selectedDAName+'</b>.';
        
        var msg = 'The total hours that will be approved is: '+totalHRs+', and any previous changes made to the page will be overridden, would you like to proceed?';
        
        //component.set("v.updatedTCD",arrayToUpdate);
        component.set("v.DAApproverMsg",DAMsg);
        component.set("v.overAllActionMsg",msg);
        component.set("v.displayConfirmation",true);
        //To open confirmation sldsModal cmp
        if(Array.isArray(component.find("confirmationModal"))){
            component.find("confirmationModal")[0].open();
        }else{
            component.find("confirmationModal").open();
        }
    },
    rejectAllAction : function(component){
        console.log('2');
        var arrayToUpdate = this.wholeActionTCDFormation(component,'Rejected');  
        var totalHRs = component.get("v.overAllActionHrs");
        var summaryObj = component.get("v.summaryDetails");
        var DAMsg = '';
        
        if(summaryObj.selectedDAUser != '--None--')
            DAMsg = 'You are approving timesheet on behalf of <b>'+summaryObj.selectedDAName+'</b>.';
        
        var msg = 'The total hours that will be rejected is: '+totalHRs+', and any previous changes made to the page will be overridden, would you like to proceed?';
        
        //component.set("v.updatedTCD",arrayToUpdate);
        component.set("v.DAApproverMsg",DAMsg);
        component.set("v.overAllActionMsg",msg);
        component.set("v.displayConfirmation",true);
        //To open confirmation sldsModal cmp
        if(Array.isArray(component.find("confirmationModal"))){
            component.find("confirmationModal")[0].open();
        }else{
            component.find("confirmationModal").open();
        }
    },
    wholeActionTCDFormation : function(component,status){
        console.log('3');
        var summaryObj = component.get("v.summaryDetails");
        var weekDetails = component.get("v.detailInfo");
        var type = summaryObj.selecedSummaryType;
        var contactId = summaryObj.selectedContactId;
        var alreadyApprovedIds = component.get("v.alreadyApprovedIds");
        var alreadyRejectedIds = component.get("v.alreadyRejectedIds");
        
        var overAllActionHrs = 0;
        var finalArray = [];
        var approvedIds = [];
        var rejectedIds = [];
        
        console.log(':::::::weekDetails::::',weekDetails);
        
        for(var i = 0; i < weekDetails.length;i++){
            if((status == 'Approved' && alreadyApprovedIds.indexOf(weekDetails[i].dayId) == -1) 
               || (status == 'Rejected' && alreadyRejectedIds.indexOf(weekDetails[i].dayId) == -1)){
                var obj = {};
                obj.Id = weekDetails[i].dayId;
                obj.AcctSeed__Hours__c = weekDetails[i].hours;
                obj.Status__c = status;
                obj.Approved_Date__c = summaryObj.todayDate;
                obj.Approved_by__c = summaryObj.userId;
                finalArray.push(obj);
                overAllActionHrs += weekDetails[i].hours;
                
                if(status == 'Approved')
                    approvedIds.push(weekDetails[i].dayId);
                else if(status == 'Rejected')
                    rejectedIds.push(weekDetails[i].dayId);
            }
        }       
        component.set("v.overAllActionHrs",overAllActionHrs);
        component.set("v.approvedIds",approvedIds);
        component.set("v.rejectedIds",rejectedIds);
        return finalArray;
    },
    savechangesAction : function(component){
        var approvedIds = component.get("v.approvedIds");
        var rejectedIds = component.get("v.rejectedIds");
        var entries = component.get("v.detailInfo");
        var summaryObj = component.get("v.summaryDetails");
        var finalArray = [];
        
        if(approvedIds.length > 0 || rejectedIds.length > 0) {
            for(var i = 0;i < entries.length;i++){
                    var obj = {};
                    obj.Id = entries[i].dayId;
                    obj.AcctSeed__Hours__c = entries[i].hours;
                    obj.Approved_Date__c = summaryObj.todayDate;
                    obj.Approved_by__c = summaryObj.userId;
                if(approvedIds.indexOf(entries[i].dayId) != -1){
                    obj.Status__c = 'Approved';
                }else if(rejectedIds.indexOf(entries[i].dayId) != -1){
                    obj.Status__c = 'Rejected';
                    obj.AcctSeed__Invoice_Comment__c = entries[i].comments;
                }
                if(approvedIds.indexOf(entries[i].dayId) != -1 || rejectedIds.indexOf(entries[i].dayId) != -1)
                	finalArray.push(obj);
            }
        }
        console.log(':::::::::finalArray::::',finalArray);
        var summaryObj = component.get("v.summaryDetails");
        var approvedHrs = component.get("v.approvedHrs");
        var rejectedHrs = component.get("v.rejectedHrs");
        
        var DAMsg = '';
        
        if(summaryObj.selectedDAUser != '--None--')
            DAMsg = 'You are approving timesheet on behalf of <b>'+summaryObj.selectedDAName+'</b>.';
        
        var msg = '';
        if(finalArray.length > 0)
        	msg = 'Total Approved hours: '+component.get("v.approvedHrs")+' <br/> Total Rejected hours: '+component.get("v.rejectedHrs")+'<br/> would you like to save the changes?';
        else
            msg = 'Please approve/reject any one of the record to save.';
        
        //component.set("v.updatedTCD",finalArray);
        component.set("v.DAApproverMsg",DAMsg);
        component.set("v.overAllActionMsg",msg);
        component.set("v.displayConfirmation",true);
        //To open confirmation sldsModal cmp
        if(Array.isArray(component.find("confirmationModal"))){
            component.find("confirmationModal")[0].open();
        }else{
            component.find("confirmationModal").open();
        }
    },
    addRejectedHrsToSummary : function(component){
        var index = component.get("v.btnIndex");
        var entries = component.get("v.detailInfo");
        var approvedHrs = component.get("v.approvedHrs");
        var approvedIds = component.get("v.approvedIds");
        var rejectedIds = component.get("v.rejectedIds");
        var rejectedHrs = component.get("v.rejectedHrs");
        var alreadyApprovedIds = component.get("v.alreadyApprovedIds");
        
        if(!approvedHrs)
            approvedHrs = 0;
        
        if(!rejectedHrs)
            rejectedHrs = 0
            
            rejectedHrs += entries[index].hours;
        
        if(rejectedIds.indexOf(entries[index].dayId) == -1 && entries[index].status != 'Rejected') {
            rejectedIds.push(entries[index].dayId);
            entries[index].status = 'Rejected';
            entries[index].isUpdated = true;
            
            component.set("v.rejectedHrs",rejectedHrs);
            component.set("v.rejectedIds",rejectedIds);
            component.set("v.detailInfo",entries);
        }
        if(approvedIds.indexOf(entries[index].dayId) != -1) {
            approvedIds.splice(approvedIds.indexOf(entries[index].dayId),1);
            approvedHrs -= entries[index].hours;
            
            component.set("v.approvedIds",approvedIds);
            component.set("v.approvedHrs",approvedHrs);
        }
        // Remove the ids from already approved list from database
        if(alreadyApprovedIds.indexOf(entries[index].dayId) != -1){
            alreadyApprovedIds.splice(alreadyApprovedIds.indexOf(entries[index].dayId),1);
            component.set("v.alreadyApprovedIds",alreadyApprovedIds);
        }
    },
    IncludeApprovedEntries : function(component){
        // To update the current week instance with new status values
        this.updateChangesInWeekAttribute(component);
        
        if(component.get("v.nextIconClicked") || component.get("v.previousIconClicked"))
        	component.set("v.detailInfo",[]);
        
        console.log(':::::::next:::click::',component.get("v.nextIconClicked"));
        console.log(':::::::previous:::click::',component.get("v.previousIconClicked"));
        
        if(component.get("v.nextIconClicked"))
            this.NextIconClick(component);
        
        if(component.get("v.previousIconClicked"))
            this.PreviousIconClick(component);
    },
    updateChangesInWeekAttribute : function(component){
        var summaryObj = component.get("v.summaryDetails");
        var weekDetails = component.get("v.specificWeekInfo");
        var selectedRowValue = component.get("v.selectedRowValue");
        console.log(':::::selectedRowValue:::::::',selectedRowValue);
        
        var approvedIds = component.get("v.approvedIds");
        var rejectedIds = component.get("v.rejectedIds");
        
        var timeEntries = [];
        var updatedEntries = component.get("v.updatedTCD");
        var type = summaryObj.selecedSummaryType;
        var contactId = summaryObj.selectedContactId;
        var viewName = '';
        var updatedTCDIds = component.get("v.tcdIds");
        var alreadyApprovedIds = component.get("v.alreadyApprovedIds");
        var alreadyRejectedIds = component.get("v.alreadyRejectedIds");
        
        if(type == 'Date'){
            timeEntries = weekDetails.insIdDateEntries[contactId];
        }else {
            timeEntries = weekDetails.insIdProEntries[contactId];
        }
        for(var i = 0;i < timeEntries.length;i++){
            var newAppHrs = 0;
            var newRejHrs = 0;
            if(type == 'Date' && timeEntries[i].dateVal === selectedRowValue){
                for(var j = 0;j < timeEntries[i].entries.length;j++){
                    var include = false;
                    if(alreadyApprovedIds.indexOf(timeEntries[i].entries[j].dayId) == -1 && approvedIds.indexOf(timeEntries[i].entries[j].dayId) != -1){
                        timeEntries[i].entries[j].status = 'Approved';
                        include = true;   
                    }else if(alreadyRejectedIds.indexOf(timeEntries[i].entries[j].dayId) == -1 && rejectedIds.indexOf(timeEntries[i].entries[j].dayId) != -1){
                        timeEntries[i].entries[j].status = 'Rejected';
                        include = true;
                    }
                    if(include) {                        
                        var obj = {};
                        obj.Id = timeEntries[i].entries[j].dayId;
                        obj.AcctSeed__Hours__c = timeEntries[i].entries[j].hours;
                        obj.Approved_Date__c = summaryObj.todayDate;
                        obj.Approved_by__c = summaryObj.userId;
                        obj.Status__c = timeEntries[i].entries[j].status;
                    	obj.AcctSeed__Invoice_Comment__c = timeEntries[i].entries[j].comments;
                        console.log('day index::',updatedTCDIds.indexOf(obj.Id),obj.Id);
                        if(updatedTCDIds.indexOf(obj.Id) == -1) {
                            console.log("type",typeof obj.Id);
                            updatedTCDIds.push(obj.Id);
                            updatedEntries.push(obj);
                            
                            if(obj.Status__c == 'Approved')
                            	newAppHrs += timeEntries[i].entries[j].hours;
                            
                            if(obj.Status__c == 'Rejected')
                            newRejHrs += timeEntries[i].entries[j].hours;
                        }
                    }
                }
            }else if(type == 'Project' && timeEntries[i].projectId === selectedRowValue){
                for(var j = 0;j < timeEntries[i].entries.length;j++){
                    var include = false;
                    if(alreadyApprovedIds.indexOf(timeEntries[i].entries[j].dayId) == -1 && approvedIds.indexOf(timeEntries[i].entries[j].dayId) != -1){
                        timeEntries[i].entries[j].status = 'Approved';
                        include = true;
                    }else if(alreadyRejectedIds.indexOf(timeEntries[i].entries[j].dayId) == -1 && rejectedIds.indexOf(timeEntries[i].entries[j].dayId) != -1){
                        timeEntries[i].entries[j].status = 'Rejected';
                        include = true;
                    }
                    if(include) {                        
                        var obj = {};
                        obj.Id = timeEntries[i].entries[j].dayId;
                        obj.AcctSeed__Hours__c = timeEntries[i].entries[j].hours;
                        obj.Approved_Date__c = summaryObj.todayDate;
                        obj.Approved_by__c = summaryObj.userId;
                        obj.Status__c = timeEntries[i].entries[j].status;
                    	obj.AcctSeed__Invoice_Comment__c = timeEntries[i].entries[j].comments;
                        
                        if(updatedTCDIds.indexOf(obj.Id) == -1) {
                            updatedTCDIds.push(obj.Id);
                            updatedEntries.push(obj);
                            
                            if(obj.Status__c == 'Approved')
                            	newAppHrs += timeEntries[i].entries[j].hours;
                            
                            if(obj.Status__c == 'Rejected')
                            newRejHrs += timeEntries[i].entries[j].hours;
                        }
                    }
                }
            }
            timeEntries[i].approvedHrs += newAppHrs;
            timeEntries[i].rejectedHrs += newRejHrs;
        }
        console.log('::::::timeEntries::::',timeEntries,updatedEntries);
        if(type == 'Date'){
            weekDetails.insIdDateEntries[contactId] = timeEntries;
        }else {
            weekDetails.insIdProEntries[contactId] = timeEntries;
        }
        
        if(approvedIds.length > 0 || rejectedIds.length > 0) {
            component.set("v.specificWeekInfo",weekDetails);
            component.set("v.updatedTCD",updatedEntries);
            component.set("v.tcdIds",updatedTCDIds);
            component.set("v.displayCommitInfo",true);
            component.set("v.CommitInfo",'Changes saved temporarily');
        }
        component.set("v.showSpinner",false);
    }
})