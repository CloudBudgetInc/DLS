({
    doinit : function(component, event, helper){
        component.set("v.showSpinner",true);
        var action = component.get("c.getInitialInformation");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showSpinner",false);
                var result = JSON.parse(response.getReturnValue());
                console.log(':::result:::::::doinit::::::::::',result);
                component.set("v.initialValues",JSON.parse(response.getReturnValue()));
                component.set("v.selectedStart",result.currWeekStart);
                component.set("v.selectedEnd",result.currWeekEnd);
                component.set("v.nextIconDisplay",true);
                component.set("v.previousIconDisplay",true);
                component.set("v.todayDate",result.currDate);
                component.set("v.documents",result.documentList);
                 
                helper.specificWeekInformation(component);
            }
        });
        $A.enqueueAction(action);
    },
    dateRowclick : function(component, event, helper) {
        //component.set("v.showSpinner",true);
        var selectedDate =  event.currentTarget.getAttribute("data-value");
        var dailyViewDates = component.get("v.specificWeekInfo").weekDates;
       
        console.log("::::::selectedDate::::",selectedDate);
        component.set("v.dateSelected",selectedDate);
        component.set("v.showSpinner",false);
        helper.getSpecificDateInformation(component);
    },
   	displayNotes : function(component, event, helper){
        component.set("v.displayNotes",true);
        // To open notes display sldsModal cmp
        if(Array.isArray(component.find("notesModal"))) {
            component.find("notesModal")[0].open();
        }else{
            component.find("notesModal").open();
        }
    },
    closeNotes : function(component, event, helper){
         component.set("v.displayNotes",false);
        // To close notes display sldsModal cmp
        if(Array.isArray(component.find("notesModal"))) {
            component.find("notesModal")[0].close();
        }else{
            component.find("notesModal").close();
        }
    },
    /*nextWeekClick: function(component, event, helper){
        helper.weekSummaryNext(component);
    },
    previousWeekClick: function(component, event, helper){
        helper.weekSummaryPrevious(component);
    },*/
    submitClick: function(component, event, helper){
        component.set("v.buttonType",'Submit');  
        var totalHrs = 0;
        var weekSummary = component.get("v.specificWeekInfo").entryDetails;
        for(var i = 0;i < weekSummary.length;i++){
            if(weekSummary[i].totalHrs != 0){
                totalHrs += weekSummary[i].totalHrs
            }
        }
        console.log(':::::totalHrs:::::',totalHrs);
        var confirmationMsg = 'The total number of hours being submitted is '+totalHrs+'. Would you like to Submit changes?';
        component.set("v.overAllActionMsg",confirmationMsg);
        component.set("v.displaySubmitConfirmation",true);
        
        // To open submit confirmation sldsModal cmp
        if(Array.isArray(component.find("submitConfirmModal"))) {
            component.find("submitConfirmModal")[0].open();
        }else{
            component.find("submitConfirmModal").open();
        }
    },
    recallClick: function(component, event, helper){
        component.set("v.overAllActionMsg",'Would you like to recall changes?');
        component.set("v.buttonType",'Recall');
        component.set("v.displaySubmitConfirmation",true);
        
        // To open recall confirmation sldsModal cmp
        if(Array.isArray(component.find("submitConfirmModal"))) {
            component.find("submitConfirmModal")[0].open();
        }else{
            component.find("submitConfirmModal").open();
        }
    },
    okayClickonWholeAction: function(component, event, helper){
        
        var btnType = component.get("v.buttonType");
        if(btnType === 'Submit'){
            helper.submitAction(component);
        }else {
            helper.recallAction(component);
        }
        component.set("v.displaySubmitConfirmation",false);
        // To close submit confirmation sldsModal cmp
        if(Array.isArray(component.find("submitConfirmModal"))) {
            component.find("submitConfirmModal")[0].close();
        }else{
            component.find("submitConfirmModal").close();
        }
    },
    cancelOnSubmit: function(component, event, helper){
        component.set("v.displaySubmitConfirmation",false);
        // To close submit confirmation sldsModal cmp
        if(Array.isArray(component.find("submitConfirmModal"))) {
            component.find("submitConfirmModal")[0].close();
        }else{
            component.find("submitConfirmModal").close();
        }
    },
    closeClickOnSuccess: function(component, event, helper){
        component.set("v.displaySuccessModal",false);
        // To close msg sldsModal cmp
        if(Array.isArray(component.find("successMsgModal"))) {
            component.find("successMsgModal")[0].close();
        }else{
            component.find("successMsgModal").close();
        }
    },
    chargeCodeDeletion: function(component, event, helper){
        //console.log('::::::previousWeekEntries::::::',component.get("v.specificWeekInfo").previousWeekEntries);
        component.set("v.previousChargeCodeList",component.get("v.specificWeekInfo").previousWeekEntries);
        component.set("v.displayChargecodeModal",true);
        
        // To open sldsModal cmp
        if(Array.isArray(component.find("CCdisplayModal"))) {
            component.find("CCdisplayModal")[0].open();
        }else{
            component.find("CCdisplayModal").open();
        }
    },
    deleteCC: function(component, event, helper){
        console.log("current rec",event.currentTarget.getAttribute("data-value"));
        var ccList = component.get("v.previousChargeCodeList");
        var rec = component.get("v.previousChargeCodeList")[event.currentTarget.getAttribute("data-value")];
        console.log("rec:::::",rec);
        rec.isAvailable_FutureWeek = false;
        rec.color = 'red';
        
        ccList[rec] = rec;
        component.set("v.previousChargeCodeList",ccList);
    },
    displayCCDeleteConfirmation: function(component, event, helper){
        component.set("v.displayChargecodeModal",false);
        component.set("v.displayChargeCodeConfirmation",true);
        
        // To close CC display sldsModal cmp
        if(Array.isArray(component.find("CCdisplayModal"))) {
            component.find("CCdisplayModal")[0].close();
        }else{
            component.find("CCdisplayModal").close();
        }
        
        // To open confirmation sldsModal cmp
        if(Array.isArray(component.find("CCConfirmationModal"))) {
            component.find("CCConfirmationModal")[0].open();
        }else{
            component.find("CCConfirmationModal").open();
        }
    },
    closeClickCC: function(component, event, helper){
        component.set("v.displayChargecodeModal",false);
        // To close sldsModal cmp
        if(Array.isArray(component.find("CCdisplayModal"))) {
            component.find("CCdisplayModal")[0].close();
        }else{
            component.find("CCdisplayModal").close();
        }
    },
    closeDeleteModal: function(component, event, helper){
        component.set("v.displayChargeCodeConfirmation",false);
        // To close sldsModal cmp
        if(Array.isArray(component.find("CCConfirmationModal"))) {
            component.find("CCConfirmationModal")[0].close();
        }else{
            component.find("CCConfirmationModal").close();
        }
    },
    updatePastLines: function(component, event, helper){
        component.set("v.showSpinner",true);
        component.set("v.displayChargeCodeConfirmation",false);
        // To close the sldsModal cmp
        if(Array.isArray(component.find("CCConfirmationModal"))) {
            component.find("CCConfirmationModal")[0].close();
        }else{
            component.find("CCConfirmationModal").close();
        }
        helper.updatePreviousWeekLines(component);
    },
    procedureDownload: function(component, event, helper){
    	var  docList = component.get("v.documents");
        var procedure = '';
        for(var i = 0;i < docList.length;i++){
            if(docList[i].Title == 'Timekeeping Policies & Procedures')
                procedure = docList[i].Id;
        }
		//sforce.one.navigateToSObject(procedure,"detail"); 
		var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": procedure
        });
        navEvt.fire();
    },
    pptDownload: function(component, event, helper){
        var  docList = component.get("v.documents");
        var ppt = '';
        for(var i = 0;i < docList.length;i++){
            if(docList[i].Title == 'Timekeeping Training Presentation')
                ppt = docList[i].Id;
        }
		//sforce.one.navigateToSObject(ppt,"detail"); 
		var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": ppt
        });
        navEvt.fire();
    },
    handleChildEvent: function(component, event, helper){
        console.log("event::header::",event.getParam("typeOfAction"));
        var eventType = event.getParam("typeOfAction");
        if(eventType == 'Previous'){
            helper.weekSummaryPrevious(component);
        }else if(eventType == 'Next'){
            helper.weekSummaryNext(component);
        }
    },
    handleEntryDetailEvent: function(component, event, helper){
        console.log("event::entry:details::::",event.getParam("typeOfAction"));
        var eventType = event.getParam("typeOfAction");
        if(eventType == 'Previous'){
            component.set("v.previousIconClick",true)
            helper.weekSummaryPrevious(component);
        }else if(eventType == 'Next'){
            component.set("v.nextIconClick",true)
            helper.weekSummaryNext(component);
        }else if(eventType == 'Back'){
            helper.destoryChild(component);
        }else if(eventType == 'AfterSave'){
            helper.destoryChild(component);
        }
    }
    
    
})