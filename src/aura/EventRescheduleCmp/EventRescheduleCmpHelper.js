({
	getTimePicklistValues : function(cmp,event){
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getTimeValues');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) { 
                var time = response;
                var timeList = [];
                
                for(var i = 0;i < time.length;i++){
                    timeList.push({'label':time[i],'value':time[i],'temp':self.convertTime(cmp,time[i])});
                }
                cmp.set("v.startTimeList",timeList);
                cmp.set("v.endTimeList",timeList);
                cmp.set("v.timeList",timeList);
                self.openRescheduleModel(cmp);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,response.getError()[0].message,'error','Error');
            }),
            false, 
            false,
            false
        );
    },
    showToast :  function(cmp,event,message,type,title){
        const toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message : message,
            type : type,
            mode: 'sticky'
        });
        toastEvent.fire();
    },
    convertTime : function(cmp,hourString) {
        var split1 = [];
        
        if(hourString != '') {
            split1 = hourString.split(' ');
        }
        
        var split2 = [];
        var minutes = 0;
        if(split1.length == 2) {
            split2 = split1[0].split(':');
        } else {
            return 0;
        }
      
        if(split2.length != 2) {
            return 0;
        } else {
            if(split1[1] == 'AM') {
                minutes += parseInt(split2[0]) * 60;
                if(split2[0] == '12') {
                    minutes = 0;
                }
                minutes += parseInt(split2[1]);
            } else if(split1[1] == 'PM') {
                var offset = 12;
                if(split2[0] == '12') {
                    offset = 0;
                }
                minutes = (parseInt(split2[0]) + offset) * 60;
                minutes += parseInt(split2[1]);
            }
        }
        return minutes;
    },
    openRescheduleModel : function(cmp){
        var eventRec = cmp.get("v.existingEventRec");
        
        if(eventRec.startTime){
            eventRec.startTimeMinutes = this.convertTime(cmp,eventRec.startTime);
        }
        
        if(eventRec.endTime){
            eventRec.endTimeMinutes = this.convertTime(cmp,eventRec.endTime);
        }
        
        if(eventRec.roomId){
            eventRec.selectedRoom = [{'Id':eventRec.roomId,'Name':eventRec.room}];
        }else {
            eventRec.selectedRoom = [];
        }
        //If user dragged the event 
        if(eventRec.isDragAndDrop) {            
            
            if(eventRec.draggedStartTime) {                
                eventRec.startTimeMinutes = this.convertTime(cmp,eventRec.draggedStartTime);                
            }
            if(eventRec.draggedEndTime) {
                eventRec.endTimeMinutes = this.convertTime(cmp,eventRec.draggedEndTime);                
            }
            eventRec.eventDate = eventRec.draggedDate;
            eventRec.startTime = eventRec.draggedStartTime;
            eventRec.endTime = eventRec.draggedEndTime;
        }
        
        cmp.set("v.rescheduleRec",eventRec);
        console.log(JSON.stringify(eventRec));
        cmp.find("rescheduleModal").open();
        cmp.set("v.showSpinner",false);
    },
    validateCurrentValues : function(cmp, event){
        
        var inputCmps = cmp.find("inputVal");
        var isValid = true;
        var rescheduleRec = cmp.get("v.rescheduleRec");
        
        for(var i = 0;i < inputCmps.length;i++){
            //Added to restricting rescheduling to past date
            if(inputCmps[i].get("v.label") == 'Date' && !this.validatePastDate(rescheduleRec)){
                isValid = false;
                var msg = "The event you are attempting to reschedule is currently scheduled to begin less than 24 hours in the future, and cannot be rescheduled through DLS Online.  Please contact your Language Training Supervisor for this class ";
                    msg += rescheduleRec.LTSName ? "("+ rescheduleRec.LTSName +") for assistance." :  "for assistance.";
                cmp.set("v.isValidInput",false);
                cmp.set("v.title","Warning");
                cmp.set("v.message",msg);
                cmp.set("v.showConflict",true);
            }
            
            if(!inputCmps[i].get("v.value")){
                isValid = false;
                $A.util.addClass(inputCmps[i],"slds-has-error");
            }else {
                $A.util.removeClass(inputCmps[i],"slds-has-error");
            }
        }                
        
        /*var roomCmp = cmp.find("room"); 
        if(rescheduleRec.selectedRoom.length == 0){
            isValid = false;
            $A.util.addClass(roomCmp,"slds-has-error");
        }else {
            $A.util.removeClass(roomCmp,"slds-has-error");
        }*/
        console.log(isValid);
        //check old & new are same or not
        if(isValid){
            cmp.set("v.message",'');
            var existingEvent = cmp.get("v.oldEventRecMap");
            
            if(existingEvent.eventDate != rescheduleRec.eventDate || 
               existingEvent.startTime != rescheduleRec.startTime || 
               existingEvent.endTime != rescheduleRec.endTime || 
               existingEvent.duration != rescheduleRec.duration /*|| 
               existingEvent.roomId != rescheduleRec.selectedRoom[0].Id*/){
                
                cmp.set("v.isValidInput",true);
                //call conflict check method
                this.checkEventConflict(cmp,event);
            }else {
                cmp.set("v.isValidInput",false);
                cmp.set("v.title","Warning");
                cmp.set("v.message","There no change in event.");
                cmp.set("v.showConflict",true);
            }
        }
    },
    checkEventConflict : function(cmp,event){
        var self = this;
        var rescheduleRec = cmp.get("v.rescheduleRec");
        var obj = {};
        obj.eventId = rescheduleRec.eventId;
        obj.startTime = rescheduleRec.startTime;
        obj.endTime = rescheduleRec.endTime;
        obj.eventDate = rescheduleRec.eventDate;
        obj.projectId = rescheduleRec.projectId;
        obj.roomId = rescheduleRec.selectedRoom && rescheduleRec.selectedRoom.length > 0? rescheduleRec.selectedRoom[0].Id : null; 
        obj.room = rescheduleRec.selectedRoom && rescheduleRec.selectedRoom.length > 0? rescheduleRec.selectedRoom[0].Name : null; 
        
        var eventArra = [];
        eventArra.push(obj);
        console.log(eventArra);
        
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
                console.log(':::::::Conflict::::response:::',response);
                cmp.set("v.showSpinner",false);
                var isValid = true;
                var existingEvent = cmp.get("v.oldEventRecMap");
                var newEvent = cmp.get("v.rescheduleRec");
                var eventConflictInfo = response;
           
                if(eventConflictInfo.isAllowForReschedule){
                    isValid = false;
                }else{
                    newEvent.parentStatusChangeTo = 'Rescheduled';
                }
                cmp.set("v.newEvent",newEvent);
                
                if(!isValid){
                    var msg = "The event you are attempting to reschedule is currently scheduled to begin less than 24 hours in the future, and cannot be rescheduled through DLS Online.  Please contact your Language Training Supervisor for this class ";
                    msg += newEvent.LTSName ? "("+ newEvent.LTSName +") for assistance." :  "for assistance.";
                    cmp.set("v.isValidInput",false);
                    cmp.set("v.title","Warning");
                    cmp.set("v.message",msg);
                    cmp.set("v.showConflict",true);
                }else{
                    
                    if(Object.keys(eventConflictInfo.EventConflicts).length > 0){
                        var evtConflicts = eventConflictInfo.EventConflicts;
                        
                        for(var key in evtConflicts){
                            if(key == 'Student/Instructor Conflict' && evtConflicts[key].length > 0){
                                var conflictList = evtConflicts[key];
                                cmp.set("v.stuInsConflictList",conflictList);
                            }else if(key == 'Room Conflict' && evtConflicts[key].length > 0){
                                var conflictList = evtConflicts[key];
                                cmp.set("v.roomConflictList",conflictList);
                            }
                        }
                        
                        cmp.set("v.title","Event Conflict");
                        cmp.set("v.showConflict",true);
                        
                    }else {
                        
                        if(isValid){
                            cmp.set("v.stuInsConflictList",[]);
                            cmp.find("rescheduleModal").close();
                            cmp.set("v.showSpinner",true);
                            self.createNewEvent(cmp,event);
                        }else{
                            cmp.set("v.title","Event Conflict");
                            cmp.set("v.showConflict",true); 
                        }
                        
                    }
                }
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp',errors);
                cmp.set("v.successMsg",response.getError()[0].message);
                cmp.set("v.successTitle",'Error');
                cmp.set("v.showSpinner",false);
                cmp.find("successModel").open();
            }),
            false, 
            false,
            false
        );
    },
    createNewEvent : function(cmp,event){
		
        var self = this;
        var oldEvent = cmp.get("v.existingEventRec");
        var newEvent = cmp.get("v.rescheduleRec");
        var conflictList = cmp.get("v.stuInsConflictList");
        
        var obj = {};
        obj.Date__c = newEvent.eventDate;
        obj.Project__c = newEvent.projectId;
        obj.Instructor__c = newEvent.instructorId;
        obj.Start_Time__c = newEvent.startTime;
        obj.End_Time__c = newEvent.endTime;
        obj.Schedule__c = newEvent.scheduleId;
        obj.Room__c = newEvent.selectedRoom && newEvent.selectedRoom.length > 0 ? newEvent.selectedRoom[0].Id : newEvent.roomId;
        obj.Timezone__c = newEvent.timezone;
        obj.Parent_Event__c = oldEvent.eventId;
        obj.Duration__c = newEvent.duration;
        obj.Is_Request_Event__c = newEvent.isForRequestEvent ? true : false;
        if(newEvent.parentStatusChangeTo){
            if(conflictList.length > 0 && newEvent.parentStatusChangeTo != 'Late Cancellation'){
                obj.Parent_Status_Changed_To__c	= 'Substituted';
            }else {
                obj.Parent_Status_Changed_To__c	= newEvent.parentStatusChangeTo;
            }
        }
        
        var eventArrary = [];
        eventArrary.push(obj);                
        
        var param = {};
        param.newEventJSON = JSON.stringify(eventArrary);
        
        const server = cmp.find('server');
        const action = cmp.get('c.createRescheduledEvent');
        server.callServer(
            action,
            param,
            false,
            $A.getCallback(function(response) {
                
                cmp.set("v.successMsg",'Your reschedule request has been submitted to your Language Training Supervisor ( '+newEvent.LTSName+' ) for approval.');
                cmp.set("v.successTitle",'Submitted');
                cmp.set("v.showSpinner",false);
                cmp.find("successModel").open();
            }),
            $A.getCallback(function(errors) { 
                
                cmp.set("v.showSpinner",false);
                cmp.set("v.successMsg",errors[0].message);
                cmp.set("v.successTitle",'Error');
                cmp.find("successModel").open();
            }),
            false, 
            false,
            false
        );
    },
    get24HourFormat : function(time) {
        if(time == undefined) {
            return [0, 0];
        }
        var h = time.split(' ');
        var m = h[0].split(':');
        var t = [];
        if(m[1] != undefined)
            t[1] = m[1];
        else
            t[1] = 0;
        if(h[1] == 'AM') {
            t[0] = m[0];
        } else if(h[1] == 'PM'){
            if(m[0] == '12')
                t[0] = parseInt(m[0]);
            else
                t[0] = parseInt(m[0]) + 12;
        }
        return t;
    },
    dateFormatFunction : function(dateVal){
        return dateVal.split('-')[0]+'/'+dateVal.split('-')[1]+'/'+dateVal.split('-')[2];
    },
    validatePastDate: function(eventRecord){
        var startTime = this.get24HourFormat(eventRecord.startTime);   
        var currentDtTime = moment().add(1, 'days').tz(eventRecord.timezone);
        var eventDtTime = moment.tz((eventRecord.eventDate+' '+startTime[0]+':'+startTime[1]), 'YYYY-MM-DD hh:mm' , eventRecord.timezone);
        
        return eventDtTime.isAfter(currentDtTime);
    }
})