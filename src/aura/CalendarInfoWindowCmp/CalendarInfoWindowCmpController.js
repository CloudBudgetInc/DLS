({
    doInit : function(cmp, event, helper) {
        // console.log('Selectedrecord', cmp.get('v.selectedRecord'));
        // let data = cmp.get('v.selectedRecord');
        // let dt = new Date(data.eventDate);
        // console.log('::::data:::111');
        // let monthName = dt.toLocaleString('default', { month: 'long' });                    
        // console.log('::::data:::222');
        // let eventTime = data.dayOfWeek+', '+monthName+' '+dt.getDate()+', '+dt.getFullYear();
        // console.log('::::data:::4444');
        // data.eventTime = eventTime;
        // console.log('::::data:::555');
        // cmp.set('v.selectedRecord',data);
        console.log(cmp.get("v.selectedRecord"));
        cmp.set("v.oldSelectedRecord", cmp.get("v.selectedRecord"));
    },
    handleRejectClick : function(cmp, event, helper) {
        let selectedRecord = cmp.get('v.selectedRecord');
        selectedRecord.approvalStatus = 'Instructor Rejected';
        cmp.set('v.selectedRecord', selectedRecord);
        console.log('called11111::::::', cmp.find("reject"));
        //cmp.find("reject").focus();
        window.setTimeout(
            $A.getCallback(function () {
                cmp.find("reject").focus();
            }), 1
        );
        console.log('called::::::', selectedRecord);
    },
    handleApproveClick : function(cmp, event, helper) {
        let selectedRecord = cmp.get('v.selectedRecord');
        selectedRecord.approvalStatus = 'Instructor Approved';
        cmp.set('v.selectedRecord', selectedRecord);
        console.log('called::::::', selectedRecord);
        helper.checkApprovalConflicts(cmp, event, helper);
        //helper.savePendingEventRecs(cmp, event, helper);
    },
    handleCancel : function(cmp, event, helper) {
        let selectedRecord = cmp.get('v.selectedRecord');
        selectedRecord.approvalStatus = 'LTS Approved';
        cmp.set('v.selectedRecord', selectedRecord);
    },
    handlePendingEventsSaveClk : function(cmp, event, helper) {
        
        helper.savePendingEventRecs(cmp, event, helper);
    },
    handleJoinMeetClick : function(cmp, event, helper) {
        let selectedRecord = cmp.get('v.selectedRecord');
        window.open(selectedRecord.meetingUrl, '_blank');
    },
    /*cancelConflictClk : function(cmp, event, helper) {
        cmp.set("v.showConflict",false);
        var p = cmp.get("v.parent");
        p.closePendingEventsModal();
    },*/
    approveEventWithConflictCheck : function(cmp, event, helper) {
        cmp.set("v.showConflict",false);
        helper.savePendingEventRecs(cmp, event,helper);
    },
    openLessonPlanModal: function(cmp){        
        
        var communityName = cmp.get('v.communityName'),
              selectedRecord = cmp.get('v.selectedRecord');
        var urlString = window.location.href;
        var baseURL = urlString.substring(0, urlString.indexOf("/s/"))+'/s/lesson-plan?';
                        
        var url = baseURL+'communityName='+communityName+'&eventId='+selectedRecord.eventId+'&modalHeader=Lesson Plan ' +selectedRecord.dateStr;   
        window.open(url, '_blank');
        
    }
})