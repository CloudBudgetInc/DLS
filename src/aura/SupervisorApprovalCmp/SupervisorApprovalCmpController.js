({
    doinit : function(component, event, helper) {
        console.log('init');
        component.set("v.showSpinner",true);
        var typeArra = ["Date","Project"]; 
        var obj = {};
        obj.displayType = typeArra;
        obj.showDateGrouping = true;
        obj.selecedSummaryType = 'Date';
        obj.selectedDAUser = '--None--';
        component.set("v.summaryDetails",obj);
       
        helper.getWholeWeekDetails(component);
        helper.getDelegatedUserInfo(component);
    },
    dateRowclick: function(component, event, helper){
        var selectedRowVal = event.currentTarget.getAttribute("data-value");
        component.set("v.selectedRowValue",selectedRowVal);
        component.set("v.displaySummary",false);
        component.set("v.displayDetail",true);
    },
    viewChange: function(component, event, helper){
        component.set("v.showSpinner",true);
        var type = component.get("v.summaryDetails").selecedType;
        
        if(type == 'Date') {
            //helper.getSpecificWeekInfomations(component);
            helper.displayConfirmationOnAllchanges(component);
        }else {
            //helper.getSpecificWeekInfomations(component);
            helper.displayConfirmationOnAllchanges(component);
        }
        var summaryObj = component.get("v.summaryDetails");
        summaryObj.showDateGrouping = !summaryObj.showDateGrouping;
        component.set("v.summaryDetails",summaryObj);
        component.set("v.weekchanged",false);
        component.set("v.approverChanged",false);
    },
    contactFilter: function(component, event, helper){
        component.set("v.showSpinner",true);
        component.set("v.approverChanged",false);
        helper.instructorBasedWeekFormation(component);
        component.set("v.showSpinner",false);
    },
    displayNotes: function(component, event, helper){
        helper.notesFormationForInstructor(component);
        component.set("v.notesDisplay",true);
        // To open notes sldsModal cmp
        if(Array.isArray(component.find("notesModal"))) {
            component.find("notesModal")[0].open();
        }else{
            component.find("notesModal").open();
        }
    },
    closeNotes: function(component, event, helper){
        component.set("v.notesDisplay",false);
        // To close notes sldsModal cmp
        if(Array.isArray(component.find("notesModal"))) {
            component.find("notesModal")[0].close();
        }else{
            component.find("notesModal").close();
        }
    },
    handleChildEvent: function(component, event, helper){
        console.log("event::::",event.getParam("typeOfAction"));
        var eventType = event.getParam("typeOfAction");
        if(eventType == 'Previous'){
            helper.PreviousIconClick(component);
        }else if(eventType == 'Next'){
            helper.NextIconClick(component);
        }else if(eventType == 'Approval Summary'){
            component.set("v.gotoSumaryClicked",true);
            helper.displayConfirmationOnAllchanges(component);
        }
    },
    closeClickOnSuccess: function(component, event, helper){
        component.set("v.displayInfoModal",false);
        // To close success/error modal cmp
        if(Array.isArray(component.find("successModal"))) {
            component.find("successModal")[0].close();
        }else{
            component.find("successModal").close();
        }
        component.set("v.updatedTCD",[]);
        //helper.getWholeWeekDetails(component);
        if(component.get("v.successTitle") != 'Error'){
        	if(!component.get("v.gotoSumaryClicked")) {
            
                helper.getSpecificWeekInfomations(component);
                helper.getDelegatedUserInfo(component);
            }else {
                component.set("v.displaySummary",false);
                component.set("v.displayDetail",false);
                component.set("v.displaySemiMonthly",true);
            }    
        }
    },
    handlerDetailEvent : function(component ,event, helper){
        var eventType = event.getParam("typeOfAction");
        var tcds = event.getParam("updatedTCDs");
        var weekUpdatedInfo = event.getParam("udpatedWeekInfo");
        if(eventType == 'Back'){
            component.set("v.updatedTCD",tcds);
            component.set("v.specificWeekInfo",weekUpdatedInfo);
            component.set("v.showSpinner",true);
            helper.updateSummaryInfo(component);
            component.set("v.displaySummary",true);
            component.set("v.displayDetail",false);
        }
    },
    // Delegated approver selection changes
    DAChange: function(component, event, helper){
        var summaryObj = component.get("v.summaryDetails");
        var selectedDAName = '';
        for(var i = 0;i < summaryObj.delegatedApprovers.length;i++){
            if(summaryObj.delegatedApprovers[i].Id == summaryObj.selectedDAUser)
                selectedDAName = summaryObj.delegatedApprovers[i].Name;
        }
        console.log('::::::selectedDAName:::',selectedDAName);
        summaryObj.selectedDAName = selectedDAName;
        component.set("v.summaryDetails",summaryObj);
        component.set("v.approverChanged",true);
        //helper.getSpecificWeekInfomations(component);
        helper.displayConfirmationOnAllchanges(component);
    },
    saveBtnClick : function(component, event, helper){
        component.set("v.showSpinner",true);
        var actionType = '';
        var emailType = '';
        var updatedTCDs = component.get("v.updatedTCD");
        var pendingHrsCnt = component.get("v.totalPendingHrs");
        var totalHrsMap = component.get("v.TotalHrsObj");
        if(pendingHrsCnt == totalHrsMap.approvedHrsTotal){
            actionType = 'ApproveAll';
            emailType = 'ApproveAll';
        }else if(pendingHrsCnt == totalHrsMap.rejectedHrsTotal){
            actionType = 'RejectAll';
            emailType = 'RejectAll';
        }else {
            actionType = 'Partial';
            emailType = 'Partial';
        }
        console.log(':::::::actionType:::',actionType);
        component.set("v.actionType",actionType);
        component.set("v.emailType",emailType);
        helper.timeEntriesUpdateFunction(component);
    },
    yesClickonAlert : function(component, event, helper){
        component.set("v.showSpinner",true);
        component.set("v.confirmationaAlert",false);
        if(Array.isArray(component.find("AlertModal"))) {
            component.find("AlertModal")[0].close();
        }else{
            component.find("AlertModal").close();
        }
        helper.timeEntriesUpdateFunction(component);
    },
    noClickonAlert: function(component, event, helper){
        component.set("v.updatedTCD",[]);
        component.set("v.confirmationaAlert",false);
        if(Array.isArray(component.find("AlertModal"))) {
            component.find("AlertModal")[0].close();
        }else{
            component.find("AlertModal").close();
        }
        helper.getSpecificWeekInfomations(component);
    },
    // To display the approval week summary & hide the semi monthly summary cmp
    monthlySummaryEvent : function(component, event, helper){
        console.log('approval cmp monthlysummary event');
        component.set("v.showSpinner",true);
        var eventType = event.getParam("typeOfAction");
        if(eventType == 'From Summary'){
            component.set("v.displaySemiMonthly",false);
            component.set("v.gotoSumaryClicked",false)
            component.set("v.displaySummary",true);
        	component.set("v.displayDetail",false);
            helper.getWholeWeekDetails(component);
            helper.getDelegatedUserInfo(component);
        }
        //event.stopPropagation();
    }
})