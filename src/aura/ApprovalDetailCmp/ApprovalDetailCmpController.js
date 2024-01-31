({
    doinit : function(component, event, helper) {
        console.log("child do init");
        component.set("v.showSpinner",true);
        var selectedRowValue = component.get("v.selectedRowValue");
        console.log("selectedRowValue::::::::",selectedRowValue);
        
        var summaryObj = component.get("v.summaryDetails");
        var weekDetails = component.get("v.specificWeekInfo");
        var type = summaryObj.selecedSummaryType;
        var contactId = summaryObj.selectedContactId;
        var index = 0;
        var lastIndex;
        
        if(type == 'Date'){
            index = weekDetails.weekDates.indexOf(selectedRowValue);
            lastIndex = weekDetails.weekDates.length - 1;
        }else {
            var projects = weekDetails.insIdProjectList[contactId];
            for(var i = 0; i < projects.length;i++) {
                if(projects[i].Id === selectedRowValue)
                    index = i;
            }
            lastIndex = projects.length - 1;
        }
        console.log("index::::::::::::",index);
        console.log("lastIndex:::::::;",lastIndex);
        
        if(index === 0)
            component.set("v.previousIcondisplay",false);
        
        if(index === lastIndex)
            component.set("v.nextIcondisplay",false);
        
        component.set("v.currentIndex",index);
        component.set("v.approvedHrs",0);
        component.set("v.rejectedHrs",0);
        
        //Display save related info
        var updatedTCDs = component.get("v.updatedTCD");
        console.log(':::::::updatedTCDs:::::',updatedTCDs);
        if(updatedTCDs.length > 0) {
            component.set("v.displayCommitInfo",true);
            component.set("v.CommitInfo",'Changes saved temporarily');
            
            var idsArray = [];
            for(var i = 0; i < updatedTCDs.length;i++){
                idsArray.push(updatedTCDs[i].Id);
            }
            component.set("v.tcdIds",idsArray);
        }
        
        helper.loadCurrentData(component);
    },
    handleChildEvent: function(component, event, helper){
        console.log("event:::detail:",event.getParam("typeOfAction"));
        var eventType = event.getParam("typeOfAction");
        if(eventType == 'Previous'){
            helper.PreviousIconClick(component);
        }else if(eventType == 'Next'){
            helper.NextIconClick(component);
        }
        event.stopPropagation();
    },
    backClick : function(component, event, helper){
        var tcds = component.get("v.updatedTCD");
        console.log('::::::::tcds::child:::',tcds);
        var backEvent = component.getEvent("approvalDetailEvent");
        backEvent.setParams({"typeOfAction" : 'Back',"updatedTCDs" : tcds,"udpatedWeekInfo" : component.get("v.specificWeekInfo")});
        backEvent.fire();
    },
    approveClick: function(component, event, helper){
        var index = event.getSource().get("v.name");
        var entries = component.get("v.detailInfo");
        var approvedHrs = component.get("v.approvedHrs");
        var approvedIds = component.get("v.approvedIds");
        var rejectedIds = component.get("v.rejectedIds");
        var rejectedHrs = component.get("v.rejectedHrs");
        var alreadyRejectedIds = component.get("v.alreadyRejectedIds");
        
        if(!approvedHrs)
            approvedHrs = 0;
        
        if(!rejectedHrs)
            rejectedHrs = 0
            
            approvedHrs += entries[index].hours;
        
        if(approvedIds.indexOf(entries[index].dayId) == -1 && entries[index].status != 'Approved') {
            approvedIds.push(entries[index].dayId);
            entries[index].status = 'Approved';
            entries[index].isUpdated = true;
            
            component.set("v.approvedHrs",approvedHrs);
            component.set("v.approvedIds",approvedIds);
            component.set("v.detailInfo",entries);
        }
        
        if(rejectedIds.indexOf(entries[index].dayId) != -1) {
            rejectedIds.splice(rejectedIds.indexOf(entries[index].dayId),1);
            rejectedHrs -= entries[index].hours;
            
            component.set("v.rejectedIds",rejectedIds);
            component.set("v.rejectedHrs",rejectedHrs);
        }
        
        // Remove the ids from already rejected list from database
        if(alreadyRejectedIds.indexOf(entries[index].dayId) != -1){
            alreadyRejectedIds.splice(alreadyRejectedIds.indexOf(entries[index].dayId),1);
            
            component.set("v.alreadyRejectedIds",alreadyRejectedIds);
        }
    },
    rejectClick: function(component, event, helper){
        var index = event.getSource().get("v.name");
        var entries = component.get("v.detailInfo");
        component.set("v.btnIndex",index);
        component.set("v.rejectionReason",entries[index].comments);
        component.set("v.displayRejectBox",true);
        if(Array.isArray(component.find("rejectModal"))) {
            component.find("rejectModal")[0].open();
        }else{
            component.find("rejectModal").open();
        }
    },
    okayonRejectReason : function(component, event, helper){
        var reason = component.get("v.rejectionReason");
        var closeModal = false;
        if(reason){
            closeModal = true;
            var entries = component.get("v.detailInfo");
            var index = component.get("v.btnIndex");
            entries[index].comments = reason;
            component.set("v.detailInfo",entries);
        }else {
            console.log('no reason entered');
            var txtArea = component.find("rejectReasonBox");
            $A.util.addClass(txtArea,"slds-has-error");
        }
        if(closeModal){
            helper.addRejectedHrsToSummary(component);
            component.set("v.displayRejectBox",false);
            if(Array.isArray(component.find("rejectModal"))) {
                component.find("rejectModal")[0].close();
            }else{
                component.find("rejectModal").close();
            }
        }
    },
    closeonRejectReason: function(component, event, helper){
        component.set("v.displayRejectBox",false);
        if(Array.isArray(component.find("rejectModal"))) {
            component.find("rejectModal")[0].close();
        }else{
            component.find("rejectModal").close();
        }
    },
    approveAllClick : function(component, event, helper){
        console.log('approve all');
        component.set("v.actionType",'ApproveAll');
        helper.approveAllAction(component);
    },
    rejectAllClick : function(component, event, helper){
        console.log('reject all');
        component.set("v.actionType",'RejectAll');
        helper.rejectAllAction(component);
    },
    yesClickApproveReject : function(component, event, helper){
        var allow = false;
        var actionType = component.get("v.actionType");
        if(actionType == 'RejectAll'){
            var reason = component.get("v.rejectAllReason");
            if(reason){
                allow = true;
                var txtArea = component.find("rejectAllReason");
                $A.util.removeClass(txtArea,"slds-has-error");
                
                var entrydata = component.get("v.detailInfo");
                var rejectedHrs = 0;
                
                for(var i = 0;i < entrydata.length;i++){
                    entrydata[i].comments = component.get("v.rejectAllReason");
                    entrydata[i].status = 'Rejected';
                    rejectedHrs += entrydata[i].hours;
                }
                component.set("v.approvedHrs",0);
                component.set("v.rejectedHrs",rejectedHrs);
                component.set("v.detailInfo",entrydata);
            }else {
                console.log('no reason entered');
                var txtArea = component.find("rejectAllReason");
                $A.util.addClass(txtArea,"slds-has-error");
            }
        }else if(actionType == 'ApproveAll'){
                var entrydata = component.get("v.detailInfo");
                var approvedHrs = 0;
                for(var i = 0;i < entrydata.length;i++){
                    entrydata[i].status = 'Approved';
                    approvedHrs += entrydata[i].hours;
                }
                component.set("v.approvedHrs",approvedHrs);
                component.set("v.rejectedHrs",0);
                component.set("v.detailInfo",entrydata);
            allow = true;
        }else if(actionType == 'Save Changes'){
            allow = true;
        }
        
        if(allow) {
            component.set("v.showSpinner",true);
            component.set("v.displayConfirmation",false);
            //To close confirmation sldsModal cmp
            if(Array.isArray(component.find("confirmationModal"))) {
                component.find("confirmationModal")[0].close();
            }else{
                component.find("confirmationModal").close();
            }
            //helper.updateChangesInWeekAttribute(component);
            helper.IncludeApprovedEntries(component);
        }
    },
    closeClickApproveReject: function(component, event, helper){
        component.set("v.displayConfirmation",false);
        //To close confirmation sldsModal cmp
        if(Array.isArray(component.find("confirmationModal"))) {
            component.find("confirmationModal")[0].close();
        }else{
            component.find("confirmationModal").close();
        }
    },
    savechangesOnly : function(component, event, helper){
        console.log('enter save changes');
        component.set("v.actionType",'Save Changes');
        helper.savechangesAction(component);
    },
    saveAlertClose : function(component, event, helper){
        component.set("v.displaySaveAlert",false);
        // To close sldsmodel cmp
        if(Array.isArray(component.find("saveAlertModal"))) {
            component.find("saveAlertModal")[0].close();
        }else{
            component.find("saveAlertModal").close();
        }
    },
    yesClickonAlert : function(component, event, helper){
        component.set("v.displaySaveAlert",false);
        // To close sldsmodel cmp
        if(Array.isArray(component.find("saveAlertModal"))) {
            component.find("saveAlertModal")[0].close();
        }else{
            component.find("saveAlertModal").close();
        }
        component.set("v.actionType",'Save Changes');
        helper.IncludeApprovedEntries(component);
    },
    discardonAlert : function(component, event, helper){
        component.set("v.displaySaveAlert",false);
        // To close sldsmodel cmp
        if(Array.isArray(component.find("saveAlertModal"))){
            component.find("saveAlertModal")[0].close();
        }else{
            component.find("saveAlertModal").close();
        }
        
        if(component.get("v.nextIconClicked"))
            helper.NextIconClick(component);
        
        if(component.get("v.previousIconClicked"))
            helper.PreviousIconClick(component);
    }
})