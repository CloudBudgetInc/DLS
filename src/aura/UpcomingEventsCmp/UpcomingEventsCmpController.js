({
    doInit : function(cmp, event, helper) {
        helper.getCommunityNames(cmp,event,helper);
    },
    hideRescheduleModel : function(cmp, event, helper) {
        var showRescheduleModel = cmp.get("v.showRescheduleModel");
        
        if(!showRescheduleModel){            
            helper.getEventRecords(cmp,event);
        }
    },
    hideApprovalModel : function(cmp, event, helper) {
        var showApprovalModel = cmp.get("v.showApprovalModel");
        
        if(!showApprovalModel){
            helper.getEventRecords(cmp,event);
        }
    },
    goToProjectDetailPage :function(cmp, event, helper) {
     var projecId = event.currentTarget.name;
        var urlEvent = $A.get("e.force:navigateToURL");
        
        urlEvent.setParams({
            "url": "/projectdetailview?recordId="+projecId
        });
        urlEvent.fire();
    },
    rescheduleClick : function(cmp, event, helper){
        var eventList = cmp.get("v.evtList");
        var index =  parseInt(event.currentTarget.name);
        var selectedRecord = {};
        
        selectedRecord =  eventList[index];
        cmp.set("v.selectedRecord",JSON.parse(JSON.stringify(selectedRecord)));
        cmp.set("v.showRescheduleModel",true);
    },
    pendingApprovalClick : function(cmp, event, helper){
        cmp.set("v.showApprovalModel", true);
    },
    closeApprovalModal : function(cmp, event, helper) {
        cmp.set("v.showApprovalModel", false);
    },
    closePendingEventsModal : function(cmp, event, helper) {
        console.log('New Pending Events');
        helper.showToast(cmp,event,'Events updated successfully.','success','Success')
        cmp.set("v.showSpinner",true);
        helper.getPendingApprovalRecords(cmp,event);
    },
     toggleConflictModal : function(cmp, event, helper){
        var params = event.getParam('arguments');
        
        if (params) {
            cmp.set("v.conflictIndex",params.index);                     
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
    handleRequestEvent: function(component, evt){
        var event={};
        var projectRefWithNewReqEvent = component.get('v.projectRefWithNewReqEvent');
        if(Object.keys(projectRefWithNewReqEvent).length == 1){
            for (const property in projectRefWithNewReqEvent) {
                event = projectRefWithNewReqEvent[property];
            }
            event['isForRequestEvent'] = true;
        }else{
            event = {isForRequestEvent: true};
        }
                      
        component.set('v.selectedRecord', JSON.parse(JSON.stringify(event)));
        component.set('v.showRescheduleModel', true);
    },
    handleJoinMeetClick : function(cmp, event, helper) {
        var eventList = cmp.get("v.evtList");
        var index =  parseInt(event.currentTarget.name);
        var selectedRecord = {};
        
        selectedRecord =  eventList[index];
        if(selectedRecord.allowToJoinMeeting){
            window.open(selectedRecord.meetingUrl, '_blank'); 
        }else{
            var modal = {header:'Warning', message:'This meeting is scheduled for a future date, Please contact your LTS/ Instructor for any questions.'};
            cmp.set('v.modal', modal);
            cmp.find("msgModal").open(); 
        }        
    },
    handleMoveOnlineClick: function(cmp, event, helper){
        var eventList = cmp.get("v.evtList");
        var index =  parseInt(event.currentTarget.name);
        var selectedRecord = {};
        
        selectedRecord =  eventList[index];       
        helper.moveEventOnline(cmp, selectedRecord, index);
    },
    showLessonPlan: function(cmp, event, helper){
        var eventList = cmp.get("v.evtList");
        var index =  parseInt(event.currentTarget.name);
        var selectedRecord = {};
        
        selectedRecord =  eventList[index]; 
        cmp.set('v.selectedRecord', selectedRecord);
       
        var communityName = cmp.get('v.communityName'),
              selectedRecord = cmp.get('v.selectedRecord');
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s/"))+'/s/lesson-plan?';
                        
        var url = baseURL+'communityName='+communityName+'&eventId='+selectedRecord.eventId+'&modalHeader=Lesson Plan ' +selectedRecord.dateStr;   
        window.open(url, '_blank');
    },
    closeModal : function(component, event, helper) {
        component.find("msgModal").close();        
    },
    // Take them to the My Schedules page
    goToMySchedulePage : function(cmp, event, helper){
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/schedules"
        });
        urlEvent.fire();
    }
})