({
    scriptsLoaded : function(component, event, helper) {
        var device = $A.get("$Browser.formFactor");
        var displayDevice = 'Pc';
        
        if (device == 'PHONE') {
            displayDevice = 'Mobile';
        } 
        component.set("v.displayDevice",displayDevice);
        component.set("v.initialLoad", true);
        component.set("v.showSpinner", false);
        helper.getCommunityName(component, event, helper);        
    },
	
    closeModal : function(component, event, helper) {
        if(component.get("v.selectedRecord").eventType == 'StudentPDO' 
             || component.get("v.selectedRecord").eventType == 'InstructorPDO'){
            component.find("plannedModal").close();
        }
    },
    closeMobileViewModal : function(component, event, helper) {
        component.set("v.showMobileViewModal",false);
    },
    
    openFilterModal : function(component , event ,helper){
        component.set("v.showMobileViewModal",true);
        console.log(component.find("MobileViewModal"));
        component.find("MobileViewModal").open();
    },
    
    handleInfoClose: function(cmp, event, helper) {
        console.log('close called:::::::');
        cmp.set("v.showBackDrop", false);
        console.log('close called:::::::');
        cmp.set("v.showInfoWindow", false);
        $('#infoWindow').hide();

    },

    eventStatusChange : function(cmp, event, helper){
        console.log('event status change');
        console.log('fire event value starting ',cmp.get("v.fireEventChange"));
        var oldStatus = cmp.get("v.oldStatusValues");
        var newStatus = cmp.get("v.selectedStatus");
        
        console.log('::::::oldStatus:::',oldStatus);
        console.log('::::::newStatus:::',newStatus);
        
        var statusChanged = false;
        
        if(oldStatus.length != newStatus.length) {
            statusChanged = true;
        }else {
            for(var i = 0;i < newStatus.length;i++){
                
                if(!(oldStatus.indexOf(newStatus[i]) != -1)){
                    console.log('enter if');
                    statusChanged = true;
                    break;
                }
            }
        }
        
        if(statusChanged) {
            cmp.set("v.oldStatusValues",JSON.parse(JSON.stringify(newStatus)));
            cmp.set("v.initialLoad", false);
            helper.getEventRecords(cmp,event,helper);
        } else {
            cmp.set("v.fireEventChange",false);
        }
        console.log('fire event value final',cmp.get("v.fireEventChange"));
    },

    filterEvents : function(cmp,event,helper){
        cmp.set("v.initialLoad",false);
        helper.filterEventBasedonEventType(cmp, event, helper);
        
        var type = cmp.get("v.selectedEventTypes");
        
        var currentType = event.getSource().get("v.name");
        console.log('type',currentType)
        if(currentType == 'Language Training') {
            var trainingCmp = cmp.find("training");
            if(Array.isArray(trainingCmp)){
                trainingCmp = trainingCmp[0];
            }
            if(!type.training){
                $A.util.removeClass(trainingCmp,'training');
                console.log('removing styles');
            }else {
                $A.util.addClass(trainingCmp,'training');
            }
            
        }else if(currentType == 'Preparation Time') {
            var trainingCmp = cmp.find("preparation");
            if(Array.isArray(trainingCmp)){
                trainingCmp = trainingCmp[0];
            }
            if(!type.preparation){
                $A.util.removeClass(trainingCmp,'preparation');
            }else {
                $A.util.addClass(trainingCmp,'preparation');
            }
            
        }else if(currentType == 'Language Testing'){
            var testingCmp = cmp.find("testing");
            if(Array.isArray(testingCmp)){
                testingCmp = testingCmp[0];
            }
            if(!type.testing){
                console.log('removing styles');
                $A.util.removeClass(testingCmp,'testing');
                console.log('removing styles');
            }else {
                $A.util.addClass(testingCmp,'testing');
            }
        }else if(currentType == 'Holiday'){
            var holCmp = cmp.find("holiday");
            if(Array.isArray(holCmp)){
                holCmp = holCmp[0];
            }
            if(!type.holiday){
                $A.util.removeClass(holCmp,'holiday');
            }else{
                $A.util.addClass(holCmp,'holiday');
            }         
        }else if((currentType == 'My Student Planned Days Off' || currentType == 'Student Planned Days Off')){
            var holCmp = cmp.find("studentDaysOff");
            if(Array.isArray(holCmp)){
                holCmp = holCmp[0];
            }
            if(!type.studentPDO){
                $A.util.removeClass(holCmp,'studentDaysOff');
            }else{
                $A.util.addClass(holCmp,'studentDaysOff');
            }     
        }else if((currentType == 'My Instructor Planned Days Off' || currentType == 'Instructor Planned Days Off')){
            var holCmp = cmp.find("instructorDaysOff");
            if(Array.isArray(holCmp)){
                holCmp = holCmp[0];
            }
            if(!type.instructorPDO){
                $A.util.removeClass(holCmp,'instructorDaysOff');
            }else{
                $A.util.addClass(holCmp,'instructorDaysOff');
            }     
        }else if(currentType == 'pendingEventApproval'){
            var evntCmp = cmp.find("pendingApproval");
            if(Array.isArray(evntCmp)){
                evntCmp = evntCmp[0];
            }
            if(!type.pendingEventApproval){
                $A.util.removeClass(evntCmp,'pendingApproval');
            }else{
                $A.util.addClass(evntCmp,'pendingApproval');
            }
        }
    },
    rescheduleClick : function(cmp, event, helper){
        console.log('reschedule');
        $("#infoWindow").hide();
        cmp.set("v.showRescheduleModel",true);
        //cmp.find("modal").close();
    },
    hideRescheduleModel : function(cmp, event, helper){
        var showRescheduleModel = cmp.get("v.showRescheduleModel");
        
        if(!showRescheduleModel){
            helper.getEventRecords(cmp, event, helper);
        }
    },
    pendingApprovalClick : function(cmp, event, helper) {
        console.log('Pending approval clicccccked');
        cmp.set("v.showMobileViewModal",false);
        $("#infoWindow").hide();
        cmp.set("v.showApprovalModel", true);
        cmp.set("v.showPendingEventList", true);
    },
     successErrorClose : function(cmp, event, helper){
        var successErrorTitle = cmp.get("v.successErrorTitle");
        cmp.find("successErrorModel").close();
         
         if(successErrorTitle == 'Success'){
             cmp.find("modal").close();
             cmp.set("v.initialLoad",false);
             helper.getEventRecords(cmp, event, helper);
         }
    },
    
    hideApprovalModel : function(cmp, event, helper){
        var showApprovalModel = cmp.get("v.showApprovalModel");
        if(!showApprovalModel){
            cmp.set("v.initialLoad",false);
            helper.getEventRecords(cmp, event, helper);
        }
    },

    closeApprovalModal : function(cmp, event, helper) {
        console.log('called:::::: close');
        cmp.set("v.initialLoad", false);
        cmp.set('v.showApprovalModel', false);
        helper.getEventRecords(cmp, event, helper);
    },
    
    hideRescheduleModel : function(cmp, event, helper){
        var showRescheduleModel = cmp.get("v.showRescheduleModel");
        if(!showRescheduleModel){
            cmp.set("v.initialLoad",false);
            helper.getEventRecords(cmp, event, helper);
        }
    },
    closePendingEventsModal : function(cmp,event, helper) {        

        helper.closePendingEvents(cmp,event, helper);
    },
    approveEventWithConflictCheck: function(component, event, helper){
        var calenderInfoCmp = component.find("calenderInfoCmp"),
            index = component.get("v.conflictIndex");        
        
        if(calenderInfoCmp && calenderInfoCmp.length > 1){
            
            for(var i=0;i < calenderInfoCmp.length;i++){
                
                if(i == index){
                    calenderInfoCmp[i].approveEvent();
                }                
            }
        }else{
            calenderInfoCmp.approveEvent();
        }
    },
    cancelConflictClk: function(cmp, event, helper){
        cmp.set("v.showConflict",false);   
        var calenderInfoCmp = cmp.find("calenderInfoCmp"),
            index = cmp.get("v.conflictIndex");        
        
        if(calenderInfoCmp && calenderInfoCmp.length > 1){
            
            for(var i=0;i < calenderInfoCmp.length;i++){
                
                if(i == index){
                    calenderInfoCmp[i].cancelEventChange();
                }                
            }
        }else{
            calenderInfoCmp.cancelEventChange();
        } 
        //helper.closePendingEvents(cmp,event, helper);
    },
    handleApproveBtnClick: function(cmp, event, helper){          
        var calenderInfoCmp = cmp.find("calenderInfoCmp"),
            index = cmp.get("v.conflictIndex");        
        
        if(calenderInfoCmp && calenderInfoCmp.length > 1){
            
            for(var i=0;i < calenderInfoCmp.length;i++){
                
                if(i == index){
                    calenderInfoCmp[i].handleApproveBtnClick();
                }                
            }
        }else{
            calenderInfoCmp.handleApproveBtnClick();
        } 
    },
    handleRejectBtnClick: function(cmp, event, helper){          
        var calenderInfoCmp = cmp.find("calenderInfoCmp"),
            index = cmp.get("v.conflictIndex");        
            
        if(calenderInfoCmp && calenderInfoCmp.length > 1){
            
            for(var i=0;i < calenderInfoCmp.length;i++){
                
                if(i == index){
                    calenderInfoCmp[i].handleRejectBtnClick();
                }                
            }
        }else{
            calenderInfoCmp.handleRejectBtnClick();
        } 
    },
    handlePendingEventsSaveClk: function(cmp, event, helper){          
        var calenderInfoCmp = cmp.find("calenderInfoCmp"),
            index = cmp.get("v.conflictIndex");        
        
        if(calenderInfoCmp && calenderInfoCmp.length > 1){
            
            for(var i=0;i < calenderInfoCmp.length;i++){
                
                if(i == index){
                    calenderInfoCmp[i].handlePendingEventsSaveClk();
                }                
            }
        }else{
            calenderInfoCmp.handlePendingEventsSaveClk();
        } 
    },
    toggleConflictModal: function(component, event, helper){
        
        var params = event.getParam('arguments');
        if (params) {
           
           component.set("v.conflictIndex",params.index);                     
        }
    },
    requestEventBtnClicked: function(component, event, helper) {
        var event={},
            projectRefWithNewReqEvent = component.get('v.projectRefWithNewReqEvent');
        
        if(Object.keys(projectRefWithNewReqEvent).length == 1){
            for (const property in projectRefWithNewReqEvent) {
                event = projectRefWithNewReqEvent[property];
            }
            event['isForRequestEvent'] = true;
        }else{
            event = {isForRequestEvent: true}
        }
                          
        component.set('v.selectedRecord', JSON.parse(JSON.stringify(event)));
        component.set('v.showRescheduleModel', true);
    }
})