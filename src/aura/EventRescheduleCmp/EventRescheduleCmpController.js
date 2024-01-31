({
	doinit : function(cmp, event, helper) {
        var device = $A.get("$Browser.formFactor");
        
        if (device == 'PHONE') {
            cmp.set("v.displayDevice",'Mobile');
        } else {
            cmp.set("v.displayDevice",'PC');
        }
        cmp.set("v.showSpinner",true);
        
        var eventRec = cmp.get("v.existingEventRec");
        console.log(':::',eventRec);
        var oldEventRecMap = {'startTime' : '','endTime' : '','eventDate' : '','roomId' : '','duration' : ''};
        
        if(eventRec.startTime){
            oldEventRecMap.startTime = eventRec.startTime;
        }
        
        if(eventRec.endTime){
            oldEventRecMap.endTime = eventRec.endTime;
        }
        
        if(eventRec.eventDate){
            oldEventRecMap.eventDate = eventRec.eventDate;
        }
        
        if(eventRec.roomId){
            oldEventRecMap.roomId = eventRec.roomId;
        }        
        
        if(eventRec.duration){
            oldEventRecMap.duration = eventRec.duration;   
        }
        
         if(eventRec.startDateTime){
            oldEventRecMap.startDateTime = eventRec.startDateTime;   
        }
         if(eventRec.endDateTime){
            oldEventRecMap.endDateTime = eventRec.endDateTime;   
        }
        eventRec['timezone'] = eventRec['timezone'] ? eventRec['timezone'] : 'America/New_York';
        eventRec['title'] = eventRec.isForRequestEvent ? 'Request New Event' : (eventRec.dayOfWeek + '/' + eventRec.project + '/' +eventRec.room);
        if(eventRec.isForRequestEvent){
            var projectRef = [];
            var projectRefWithNewReqEvent = cmp.get("v.projectRefWithNewReqEvent");
            projectRef = Object.keys(projectRefWithNewReqEvent);
            if(projectRef.length > 1){
                cmp.set('v.projectRef',projectRef);
            }            
        }    
        cmp.set('v.existingEventRec', eventRec);
        cmp.set("v.oldEventRecMap",oldEventRecMap);
		helper.getTimePicklistValues(cmp,event);
	},
    startTimeChange : function(cmp, event, helper){
        var rescheduleRec = cmp.get("v.rescheduleRec");
        rescheduleRec.startTimeMinutes = helper.convertTime(cmp,rescheduleRec.startTime);
        cmp.set("v.rescheduleRec",rescheduleRec);
    },
    endTimeChange : function(cmp, event, helper){
        var rescheduleRec = cmp.get("v.rescheduleRec");
        rescheduleRec.endTimeMinutes = helper.convertTime(cmp,rescheduleRec.endTime);
        cmp.set("v.rescheduleRec",rescheduleRec);
    },
    saveReschedule : function(cmp, event, helper){
        helper.validateCurrentValues(cmp,event);
    },
    closeReschedule : function(cmp, event, helper){
        cmp.find("rescheduleModal").close();
        cmp.set("v.showRescheduleModel",false);
    },
    roomLookupSearch : function(cmp, event, helper){
        const serverSearchAction = cmp.get('c.getLookupRecords');
        cmp.find('room').search(serverSearchAction);
    },
    proceedClick : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        cmp.set("v.showConflict",false);
        cmp.find("rescheduleModal").close();
        helper.createNewEvent(cmp,event);
    },
    closeClick : function(cmp, event, helper){
        cmp.set("v.showConflict",false);
    },
    successClose : function(cmp, event, helper){
        cmp.find("successModel").close();
        //if(cmp.get("v.successTitle") == 'Success'){
            cmp.set("v.showRescheduleModel",false);
       // }
    },
    selectedProjectChange : function(cmp, event){
        var selectedProjectRef = cmp.get("v.selectedProject"),
            rescheduleRec = cmp.get("v.rescheduleRec"),
            projectRefWithNewReqEvent = cmp.get("v.projectRefWithNewReqEvent"),
            newReqEvent = projectRefWithNewReqEvent[selectedProjectRef];
            
            newReqEvent['startTimeMinutes'] = rescheduleRec['startTimeMinutes'];
            newReqEvent['endTimeMinutes'] = rescheduleRec['endTimeMinutes'];
            newReqEvent['eventDate'] = rescheduleRec['eventDate'];
            newReqEvent['duration'] = rescheduleRec['duration'];
            newReqEvent['isForRequestEvent'] = rescheduleRec['isForRequestEvent'];
            newReqEvent['title'] = rescheduleRec['title'];
            newReqEvent['endTime'] = rescheduleRec['endTime'];
            newReqEvent['startTime'] = rescheduleRec['startTime'];
            if(newReqEvent.roomId){
                newReqEvent['selectedRoom'] = [{'Id':newReqEvent.roomId,'Name':newReqEvent.room}];
            }else {
                newReqEvent['selectedRoom'] = [];
            }

            cmp.set("v.rescheduleRec",newReqEvent);
    }
})