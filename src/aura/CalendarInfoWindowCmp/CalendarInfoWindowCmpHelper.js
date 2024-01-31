({
    savePendingEventRecs : function(cmp, event, helper) {
        
        var newEventRecs = [];
        var newEventRec = {};
        let selectedRecord = cmp.get('v.selectedRecord');
        
        if(selectedRecord.approvalStatus == 'Instructor Approved') {
                        
            newEventRec.Id = selectedRecord.eventId;
            newEventRec.Approval_Status__c = 'Instructor Approved';
            newEventRec.Status__c = 'Scheduled';
            newEventRec.Reject_Comment__c = '';
            
            if(selectedRecord.parentStatusChangeTo) {
                newEventRec.Parent_Status_Changed_To__c = selectedRecord.parentStatusChangeTo;
            }

            if(selectedRecord.parentEventId) {
                newEventRec.Parent_Event__c = selectedRecord.parentEventId;
            }
            newEventRecs.push(newEventRec);
            helper.updateNewEventRecsHelper(cmp, newEventRecs);            
        } else {            
            var rejectReasonInput = cmp.find("reject");
            if(!rejectReasonInput.get("v.value")) {
                $A.util.addClass(rejectReasonInput, 'slds-has-error'); 
            } else {
                newEventRec.Id = selectedRecord.eventId;
                newEventRec.Approval_Status__c = 'Instructor Rejected';
                newEventRec.Reject_Comment__c = cmp.get('v.rejectionReason');
                newEventRecs.push(newEventRec);
                helper.updateNewEventRecsHelper(cmp, newEventRecs)
            }
            
        }
        
        console.log('newEventRecs::::::', newEventRecs);

        
    },

    updateNewEventRecsHelper : function(cmp, newEventRecs) {
        
        cmp.set('v.showSpinner', true);
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.saveEventRecs');
        server.callServer(
            action,
            {
             'newEventRecs' : newEventRecs
            },
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                console.log('Sucess');
                var p = cmp.get("v.parent");
                p.closePendingEventsModal();
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,errors[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
    },
    checkApprovalConflicts : function(cmp, event, helper) {
        let selectedRecord = cmp.get('v.selectedRecord');
        console.log('checking for approval conflicts:::::', selectedRecord);
        var self = this;
        var obj = {};
        obj.eventId = selectedRecord.eventId;
        obj.startTime = selectedRecord.startTime;
        obj.endTime = selectedRecord.endTime;
        obj.eventDate = selectedRecord.eventDate;
        obj.projectId = selectedRecord.projectId;
        obj.roomId = selectedRecord.roomId;  
        obj.room = selectedRecord.room;
        
        if(selectedRecord.room){
            obj.room = selectedRecord.room;  
        }
        console.log('obj', obj);

        var eventArra = [];
        eventArra.push(obj);
        
        var param = {};
        param.eventJSON = JSON.stringify(eventArra);
        param.communityName = cmp.get("v.communityName");
        cmp.set("v.showSpinner",true);

        const server = cmp.find('server');
        const action = cmp.get('c.getEventConflictInfo');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                console.log(':::::::Conflict::::response:::', response);
                cmp.set("v.showSpinner",false);
                var eventConflictInfo = response;
                var showConfictModal = false;
                
                 if(Object.keys(eventConflictInfo.EventConflicts).length > 0){
                     var evtConflicts = eventConflictInfo.EventConflicts;
                    
                     for(var key in evtConflicts){
                         if(key == 'Student/Instructor Conflict' && evtConflicts[key].length > 0){
                             var conflictList = evtConflicts[key];
                             cmp.set("v.stuInsConflictList",conflictList);
                             showConfictModal = true;
                         }else if(key == 'Room Conflict' && evtConflicts[key].length > 0){
                             var conflictList = evtConflicts[key];
                             cmp.set("v.roomConflictList",conflictList);
                             showConfictModal = true;
                         }
                     }
                 } 
                
                if(showConfictModal){
                    cmp.set("v.showConflict",true);
                    var p = cmp.get("v.parent");
                    p.toggleConflictModal(cmp.get("v.index"));
                    //cmp.find("showConflictModal").open();
                    
                }else {
                    self.savePendingEventRecs(cmp, event,helper);
                }
            }),
            $A.getCallback(function(errors) { 
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,errors[0].message,'error','Error');      
            }),
            false, 
            false,
            false
        );
    },
    showToast :  function(cmp,message,type,title){
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message : message,
            type : type,
            mode: 'sticky'
        });
        toastEvent.fire();
    }
})