({
	doInit : function(cmp, event, helper) {
        var device = $A.get("$Browser.formFactor");
        if (device == 'PHONE') {
            cmp.set("v.displayDevice",'Mobile');
        }else {
            cmp.set("v.displayDevice",'Pc');
        }
        cmp.set("v.showSpinner",true);
        helper.getCurrentCommunityName(cmp,event);        
    },
    hideRescheduleModel : function(cmp, event, helper) {
        var showRescheduleModel = cmp.get("v.showRescheduleModel");
        
        if(!showRescheduleModel){
            cmp.set("v.showSpinner",true);
            helper.getEventRecords(cmp, event);
        }
    },
    filterEvents : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        helper.getEventRecords(cmp,event);
        
        var type = cmp.get("v.filterObj");
        
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
    eventStatusChange : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
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
            helper.getEventRecords(cmp,event,helper);
        }else {
            cmp.set("v.fireEventChange",false);
        }
        window.setTimeout(function(){
            cmp.set("v.showSpinner",false);
        },1000);
    },
    tabActionClick : function(cmp, event, helper){
        var actionId = event.getParam('actionId') || null;
        var rowRecord = event.getParam("row");
        var selectedRecord = JSON.parse(JSON.stringify(rowRecord));
        console.log('actionId::>'+actionId);
        if(actionId == 'reScheduleTask'){
            cmp.set("v.selectedRecord",JSON.parse(JSON.stringify(rowRecord)));
            cmp.set("v.showRescheduleModel",true);
        }else if(actionId == 'joinMeetingUrl'){
            if(rowRecord.allowToJoinMeeting){
                window.open(rowRecord.meetingUrl, '_blank');
            }else{
                var modal = {header:'Warning', message:'This meeting is scheduled for a future date, Please contact your LTS/ Instructor for any questions.'};
                cmp.set('v.modal', modal);
                cmp.find("msgModal").open(); 
            }            
        }else if(actionId == 'lessonPlan'){
            helper.openLessonPlanModal(cmp, rowRecord);      
        }else if(actionId == 'moveOnline' || actionId == 'createMeeting'){
            
            var rowIdx = event.getParam("index");
            helper.moveEventOnline(cmp, selectedRecord, rowIdx);           
        }else if(actionId == 'pendingEventApproval'){
            var pendingApprovalEvtList = cmp.get('v.pendingApprovalEvtList');
            var selectedPendingApprovalEvent = [];

            for(var i = 0; i < pendingApprovalEvtList.length; i++) {
                if(pendingApprovalEvtList[i].selectedEvent.eventId == selectedRecord.eventId) {
                    selectedPendingApprovalEvent.push(pendingApprovalEvtList[i]);
                    break;
                }
            }
            console.log('selectedPendingApprovalEvent', selectedPendingApprovalEvent);
            cmp.set("v.selectedPendingApprovalEvent", selectedPendingApprovalEvent);
            cmp.set("v.showApprovalModel",true);
            cmp.set("v.isMultiApproval",false);

        }
    },
    pendingApprovalClick : function(cmp, event, helper){
        cmp.set("v.isMultiApproval",true);
        cmp.set('v.selectedPendingApprovalEvent', cmp.get('v.pendingApprovalEvtList'));
        cmp.set("v.showApprovalModel",true);
    },
    hideApprovalModel : function(cmp, event, helper){
        var showApprovalModel = cmp.get("v.showApprovalModel");
        if(!showApprovalModel){
            cmp.set("v.initialLoad",false);
            cmp.set("v.showSpinner",true);
            helper.getEventRecords(cmp, event, helper);
        }
    },
    
    hideRescheduleModel : function(cmp, event, helper){
        var showRescheduleModel = cmp.get("v.showRescheduleModel");
        if(!showRescheduleModel){
            cmp.set("v.initialLoad",false);
            cmp.set("v.showSpinner",true);
            helper.getEventRecords(cmp, event, helper);
        }
    },
    closeApprovalModal : function(cmp, event, helper) {
        cmp.set("v.showApprovalModel", false);
    },
    toggleConflictModal : function(cmp, event, helper){
        var params = event.getParam('arguments');
        
        if (params) {
            cmp.set("v.conflictIndex",params.index);                     
        }
    },
    closePendingEventsModal : function(cmp, event, helper){
        var isMultiApproval = cmp.get(("v.isMultiApproval"));
        
        helper.showToast(cmp,event,'Events updated successfully.','success','Success')
        if(!isMultiApproval){
            cmp.set("v.showApprovalModel",false);
        }else{
            cmp.set("v.showSpinner",true);
            helper.getPendingApprovalRecords(cmp, event, helper);
        }
    },
    approveEventWithConflictCheck : function(cmp, event, helper){
        cmp.set("v.showConflict",false);   
        
        var calenderInfoCmp = cmp.find("calenderInfoCmp");
        var  index = cmp.get("v.conflictIndex");        
        
        if(calenderInfoCmp && calenderInfoCmp.length > 1){
            
            for(var i = 0;i < calenderInfoCmp.length;i++){
                
                if(i == index){
                    calenderInfoCmp[i].approveEvent();
                }                
            }
        }else{
            calenderInfoCmp.approveEvent();
        }
    },
    cancelConflictClk : function(cmp, event, helper){
        cmp.set("v.showConflict",false);   
        var calenderInfoCmp = cmp.find("calenderInfoCmp"),
            index = cmp.get("v.conflictIndex");        
        
        if(calenderInfoCmp && calenderInfoCmp.length > 1){
            
            for(var i = 0;i < calenderInfoCmp.length;i++){
                
                if(i == index){
                    calenderInfoCmp[i].cancelEventChange();
                }                
            }
        }else{
            calenderInfoCmp.cancelEventChange();
        } 
    },
    closeModal : function(component, event, helper) {
        component.find("msgModal").close();        
    },
    closeLessonPlanModal: function(component){
        
    }
    
})