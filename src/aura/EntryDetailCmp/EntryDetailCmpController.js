({	
    doinit : function(component, event, helper) {
        component.set("v.showSpinner",true);
        console.log('child do ninit');
        var dailyViewDates = component.get("v.specificWeekInfo").weekDates;
        var selectedDate = component.get("v.dateSelected");
        
        // For previous week icon display
        if(component.get("v.currWeekIndex") === 0 && dailyViewDates.indexOf(selectedDate) === 0){
            component.set("v.dailyPreviousIcon",false);
        }else {
            component.set("v.dailyPreviousIcon",true);
        }
		// For next week icon display
        if(component.get("v.currWeekIndex") === 8 && dailyViewDates.indexOf(selectedDate) === 5){
        	component.set("v.dailyNextIcon",false);
        }else {
            component.set("v.dailyNextIcon",true);
        }    
        
        // payroll item map formation
         var payrollMap = {};
        var taskMaster = component.get("v.initialValues").taskMasterList;
        
        for(var i = 0;i < taskMaster.length;i++){
            var payrollItems = [];
            if(taskMaster[i].Payroll_Item__c != null && taskMaster[i].Payroll_Item__c.indexOf(';') != -1)
                payrollItems = taskMaster[i].Payroll_Item__c.split(';');
            else
                payrollItems.push(taskMaster[i].Payroll_Item__c);
            
            if(!payrollMap[taskMaster[i].Name]) {
                payrollMap[taskMaster[i].Name] = payrollItems;
            }
        }
        component.set("v.task_PayrollItemMap",payrollMap);   
        component.set("v.locationList",component.get("v.initialValues").locationList);
        
        component.set("v.showSpinner",false);
        helper.getSpecificDateInformation(component);
    },
	addRow : function(component, event, helper) {
        var obj = {};
        obj.projectId = '';
        obj.ProjectName = '';
        obj.taskId = '';
        obj.locationId = '';
        obj.locationName = '';
        obj.location = [];
        obj.TaskType = '';
        obj.isBillable = false;
        obj.isNew = true;
        obj.ParentProjectTask = '';
        obj.payrollItem = '';
        //obj.PayRollItemList = [];
        obj.costRateId = '';
        obj.contactAssignId = '';
        obj.projectRTName = '';
        obj.prMap = {};
        obj.disablePayRoll = false;
        obj.hidebillableSection = false;
        //obj.location = null;
        obj.isUpdated = false;
        obj.dayId = null;
        obj.dateVal = helper.apexDateFormatFunction(component.get("v.dateSelected"));
        obj.isHrsDisabled = false;
        
        component.set("v.newDayRec",obj);
        component.set("v.showAddModal",true);
        if(Array.isArray(component.find("addRowModal"))) {
            component.find("addRowModal")[0].open();
        }else{
            component.find("addRowModal").open();
        }
    },
    NewRowcancel : function(component, event, helper) {
        var obj = {};
        obj.hours = '';
        component.set("v.newDayRec",obj);
        component.set("v.showAddModal",false);
        
        if(Array.isArray(component.find("addRowModal"))) {
            component.find("addRowModal")[0].close();
        }else{
            component.find("addRowModal").close();
        }
    },
    updateTimeRec : function (component, event, helper){
        //console.log("date:selected::",component.get("v.dateSelected"));
        //console.log("::::::today:date::;;",component.get("v.todayDate"));
        var selectedDate = component.get("v.dateSelected");
        var todayDate = component.get("v.todayDate");
        var selectedCmp = component.get("v.timeDayList")[event.currentTarget.getAttribute("data-value")];
        console.log(":::::selectedCmp.isHrsDisabled:::::",selectedCmp.isHrsDisabled);
        if(selectedCmp.isHrsDisabled == false) {
            setTimeout(function(){ 
                component.find("hrsUpdate").focus();
            }, 100);
            component.set("v.dayRecord",selectedCmp);
            /*var m1 = component.find("modalStateUpdate");
            var m2 = component.find("modalBackdropUpdate");
            $A.util.addClass(m1, 'slds-fade-in-open');
            $A.util.addClass(m2, 'slds-backdrop--open');*/
            component.set("v.displayEntryUpdate",true);
            if(Array.isArray(component.find("entryUpdateModal"))) {
                component.find("entryUpdateModal")[0].open();
            }else{
                component.find("entryUpdateModal").open();
            }
        }
    },
    updateCancel : function(component, event, helper){
        $A.util.removeClass(component.find("Daycmt"),'slds-has-error');
        /*var m1 = component.find("modalStateUpdate");
        var m2 = component.find("modalBackdropUpdate");
        $A.util.removeClass(m1, 'slds-fade-in-open');
        $A.util.removeClass(m2, 'slds-backdrop--open');*/
        component.set("v.displayEntryUpdate",false);
        // Open sldsmodel cmp
        if(Array.isArray(component.find("entryUpdateModal"))) {
            component.find("entryUpdateModal")[0].close();
        }else{
            component.find("entryUpdateModal").close();
        }
    },
    dailyViewPrevious: function(component, event, helper){
        helper.dailyPreviousClick(component);
    },
    dailyViewNext: function(component, event, helper){
        helper.dailyNextClick(component);
    },
    handleLookupEvent: function(component, event, helper){
        var selectedobj = event.getParam("objectByEvent");
        var newRec = component.get("v.newDayRec");
        newRec.location = selectedobj;
        component.set("v.newDayRec",newRec);
    },
    populateProjectTask: function(component, event, helper){
        helper.projectTaskPopulation(component);
    },
    taskvalidationFunction : function(component, event, helper){
        helper.validateProjectTask(component);
    },
    okayClickNewRow : function(component, event, heler){
        console.log("okay click on add row");
        var newRec = component.get("v.newDayRec");
        console.log('::::::::::::::newRec::::::',JSON.stringify(newRec));
        if(newRec.location != null && newRec.location.length > 0) {
            newRec.locationName = newRec.location[0].Name;
            newRec.locationId = newRec.location[0].Id;
        }
        var billableType = '';
        if(newRec.isBillable)
            billableType = 'Billable';
        else
            billableType = 'Non-Billable';
        
        newRec.chargeCode = newRec.ProjectName+' / '+newRec.TaskName+' / '+newRec.payrollItem+' / '+billableType+' / '+newRec.locationName;
        if(!newRec.dayId)
        	newRec.isNew = true;
        var dayList = component.get("v.timeDayList");
        
        //Unique key set formation
        var UniqueKeySet = component.get("v.UniqueKeySet");
        var key = newRec.projectId+'-'+newRec.taskId+'-'+newRec.isBillable+'-'+newRec.payrollItem+'-'+newRec.locationId;
        
        if(dayList.length > 0){
            newRec.sequenceNumber = dayList[dayList.length - 1].sequenceNumber + 1;
        }
        
        if(UniqueKeySet.indexOf(key) === -1) {
            UniqueKeySet.push(key);
            
            if(newRec.projectId && newRec.taskId
               && newRec.payrollItem && newRec.locationId){
                dayList.push(newRec);
            }
        }
        
        var projdiv = component.find("project");
        if(!newRec.projectId)
            $A.util.addClass(projdiv,"slds-has-error");
        else
            $A.util.removeClass(projdiv,"slds-has-error");
        
        var taskdiv = component.find("projectTask");
        if(!newRec.taskId)
            $A.util.addClass(taskdiv,"slds-has-error");
        else
            $A.util.removeClass(taskdiv,"slds-has-error");
        
        var payrollDiv = component.find("payroll");
        if(!newRec.payrollItem)
            $A.util.addClass(payrollDiv,"slds-has-error");
        else
            $A.util.removeClass(payrollDiv,"slds-has-error");
        
        if(newRec.projectId && newRec.taskId && newRec.payrollItem){
            component.set("v.timeDayList",dayList);
            component.set("v.showAddModal",false);
            component.set("v.UniqueKeySet",UniqueKeySet);
            
            if(Array.isArray(component.find("addRowModal"))) {
                component.find("addRowModal")[0].close();
            }else{
                component.find("addRowModal").close();
            }
        }
    },
    payrollChange : function(component, event, helper){
        var newRec = component.get("v.newDayRec");
        if(newRec.projectRTName != 'Admin_Projects' && newRec.PayRollItemList && newRec.PayRollItemList.length > 1) {
            console.log(newRec.payrollItem,newRec.prMap[newRec.payrollItem]);
            if(newRec.payrollItem && newRec.PayRollItemList.length > 1) {
                newRec.isBillable = newRec.prMap[newRec.payrollItem];
            }
        }
        component.set("v.newDayRec",newRec);
    },
    okayOnUpdate: function(component, event, helper){
        var recordTochange = component.get("v.dayRecord");
        $A.util.removeClass(component.find("Daycmt"),'slds-has-error');
        
        console.log(recordTochange.hours);
        var dayList = component.get("v.timeDayList");
        console.log('::::::::recordTochange::::',recordTochange.comments);
        var recIndex = dayList.indexOf(recordTochange);
        
        var isCommentAdded = true;
        if(recordTochange.status != 'Unposted' && recordTochange.dayId != null && (!recordTochange.comments || recordTochange.comments === '' || recordTochange.comments === null)){
                isCommentAdded = false;
        }else {
            if(recordTochange.dayId !== null && recordTochange.hrschanged){
                recordTochange.isUpdated = true;
                if(recordTochange.status == 'Unposted')
                	recordTochange.status = 'Draft';
                //isCommentAdded = true;
            }
        }
        if(isCommentAdded){
            console.log("enter if:::::::::::::::::::::",dayList[recIndex]);
            dayList[recIndex] = recordTochange;
            component.set("v.timeDayList",dayList);
            console.log('L::::::::::::dayList::::::',component.get("v.timeDayList"));
            /*var m1 = component.find("modalStateUpdate");
            var m2 = component.find("modalBackdropUpdate");
            $A.util.removeClass(m1, 'slds-fade-in-open');
            $A.util.removeClass(m2, 'slds-backdrop--open');*/
            component.set("v.displayEntryUpdate",false);
            // To clode sldsmodel cmp
            if(Array.isArray(component.find("entryUpdateModal"))) {
                component.find("entryUpdateModal")[0].close();
            }else{
                component.find("entryUpdateModal").close();
            }
        }else {
            var cmtDiv = component.find("Daycmt");
            $A.util.addClass(cmtDiv,'slds-has-error');
        }
    },
    hoursValidation: function(component, event, helper){
        console.log("enter hrsvalidation");
        console.log("hrs entered:::",component.get("v.dayRecord").hours);
        var data = component.get("v.dayRecord");
        var hour = (data.hours * 100) % 100;
        
        data.comments = '';
        if(data.dayId !== null)
        	data.hrschanged = true;
        else
            data.hrschanged = false;
        
        if(data.payrollItem != 'BLE'){
            if(!(hour == 25 || hour == 50 || hour == 75 || hour == 0)){
                console.log('invalid format');
                data.errMsg  = 'Allowed decimal values are 00, 25, 50, 75';
            }else {
                console.log('correct format');
                data.errMsg  = '';
            }
        }else {
            var hour = parseInt(data.hours.toString().split('.')[0]);
            var decimalVal = (data.hours * 100) % 100;
           
            if(!((hour == 4 || hour == 8 || hour == 12 || hour == 16 || hour == 20 || hour == 24) && decimalVal == 0)){
                //console.log('invalid format');
                 data.errMsg = 'Allowed hours values are 4, 8, 12, 16, 20, 24';
            }else {
                //console.log('correct format');
                 data.errMsg = '';
            }
        }
        component.set("v.dayRecord",data);
    },
    saveOperation: function(component, event, helper){
        component.set("v.showSpinner",true);
        console.log("save operation function");
        helper.dayRecordsSaveFunction(component);
    },
    yesClickonAlert: function(component, event, helper){
        component.set("v.displaySaveAlert",false);
        // To close sldsmodel cmp
        if(Array.isArray(component.find("saveAlertModal"))) {
            component.find("saveAlertModal")[0].close();
        }else{
            component.find("saveAlertModal").close();
        }
        component.set("v.showSpinner",true);
        helper.dayRecordsSaveFunction(component);
    },
    discardonAlert: function(component, event, helper){
        component.set("v.displaySaveAlert",false);
        // To close sldsmodel cmp
        if(Array.isArray(component.find("saveAlertModal"))) {
            component.find("saveAlertModal")[0].close();
        }else{
            component.find("saveAlertModal").close();
        }
        
        component.set("v.timeDayList",[]);
        if(component.get("v.nextIconClick"))
            helper.dailyNextClick(component);
        
        if(component.get("v.previousIconClick"))
            helper.dailyPreviousClick(component);
    },
    saveAlertClose: function(component, event, helper){
        component.set("v.displaySaveAlert",false);
        // To close sldsmodel cmp
        if(Array.isArray(component.find("saveAlertModal"))) {
            component.find("saveAlertModal")[0].close();
        }else{
            component.find("saveAlertModal").close();
        }
    },
    deleteClick: function(component, event, helper){
        var currRecord = component.get("v.dayRecord");
        var dayList = component.get("v.timeDayList");
        var recIndex = dayList.indexOf(currRecord);
        if(!currRecord.comments){
            var cmtDiv = component.find("Daycmt");
            $A.util.addClass(cmtDiv,'slds-has-error');
        }else {
            if(currRecord.dayId !== null){
                currRecord.isUpdated = true;
            }
            currRecord.status = 'Unposted';
            dayList[recIndex] = currRecord;
            console.log("dayList[recIndex] :::::delete::::",dayList[recIndex]);
            component.set("v.timeDayList",dayList);
            /*var m1 = component.find("modalStateUpdate");
            var m2 = component.find("modalBackdropUpdate");
            $A.util.removeClass(m1, 'slds-fade-in-open');
            $A.util.removeClass(m2, 'slds-backdrop--open');*/
            component.set("v.displayEntryUpdate",false);
            
            // To close sldsmodel cmp
            if(Array.isArray(component.find("entryUpdateModal"))) {
                component.find("entryUpdateModal")[0].close();
            }else{
                component.find("entryUpdateModal").close();
            }
        }
    },
    closeClickOnSuccess: function(component, event, helper){
        component.set("v.displaySuccessModal",false);
        
        if(Array.isArray(component.find("successModal"))) {
            component.find("successModal")[0].close();
        }else{
            component.find("successModal").close();
        }
        var setEvent = component.getEvent("entryDetailEvent");
        setEvent.setParams({"typeOfAction":"AfterSave"});
        setEvent.fire();
    },
    handleChildEvent: function(component, event, helper){
        console.log("event::::",event.getParam("typeOfAction"));
        var eventType = event.getParam("typeOfAction");
        if(eventType == 'Previous'){
            helper.dailyPreviousClick(component);
        }else if(eventType == 'Next'){
            helper.dailyNextClick(component);
        }
        event.stopPropagation();
    },
    backClick : function(component, event, helper){
        component.set("v.displayDetail",false);
        var setEvent = component.getEvent("entryDetailEvent");
        setEvent.setParams({"typeOfAction":"Back"});
        setEvent.fire();
    },
    lookupSearch : function(component, event, helper) {
        // Get the search server side action
        const serverSearchAction = component.get('c.search');
        // Passes the action to the Lookup component by calling the search method
        component.find('lookup').search(serverSearchAction);
    }
})