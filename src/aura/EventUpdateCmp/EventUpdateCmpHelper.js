({
    eventSave : function(cmp, event, helper, saveallowed) {
        
        if(saveallowed) {
            var startTime = 0;
            var endTime = 0;
            var eventSelected = cmp.get("v.selectedEvent"); 
            if(eventSelected.length == 1 || (eventSelected.length > 1 && (cmp.get("v.event").End_Time__c == '' || cmp.get("v.event").Start_Time__c == ''))) { 
                for(var i = 0; i < eventSelected.length; i++) {
                    
                    var stTime = helper.convertTime(cmp, event, helper, eventSelected[i].Start_Time__c);
                    
                    if(startTime < stTime) {
                        startTime = stTime;
                    }
                    var enTime = helper.convertTime(cmp, event, helper, eventSelected[i].End_Time__c);
                    if(i == 0) {
                        endTime = enTime;
                    } else if(endTime >= enTime) {
                        endTime = enTime;
                    }
                }
                
                if(cmp.get("v.event").End_Time__c != '' && startTime >= helper.convertTime(cmp, event, helper, cmp.get("v.event").End_Time__c)
                   || cmp.get("v.event").Start_Time__c != '' && endTime <= helper.convertTime(cmp, event, helper, cmp.get("v.event").Start_Time__c)) {
                    cmp.set("v.noValidTime", true);
                }
            } else {
                var stTime = helper.convertTime(cmp, event, helper, cmp.get("v.event").Start_Time__c);
                var enTime = helper.convertTime(cmp, event, helper, cmp.get("v.event").End_Time__c);    
                if(stTime >= enTime) {
                    cmp.set("v.noValidTime", true);
                }
            }
            console.log('::noValidTime::',cmp.get("v.noValidTime"));
            if(!cmp.get("v.noValidTime")) {
                
                var action = cmp.get("c.saveEventRecords");
                action.setParams({
                    eventUpdateList : JSON.stringify(cmp.get("v.beforeUpdateSelectEvent")),
                    event : JSON.stringify(cmp.get("v.event"))
                }); 
                
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    var result = response.getReturnValue();
                    if(state == "SUCCESS") {
                        
                        var getRecEvent = cmp.getEvent("reloadEvent");
                        getRecEvent.fire();
                        
                        var toast = cmp.get("v.toastMessage");
                        toast.message = 'Event Records Updated Successfully';
                        toast.header = 'Success';
                        cmp.set("v.toastMessage", toast);
                        
                        if(Array.isArray(cmp.find("statusModal"))) {
                            cmp.find("statusModal")[0].open();
                        }else{
                            cmp.find("statusModal").open();
                        }
                        cmp.set("v.showSpinner",false);
                        
                    } else {
                        var toast = cmp.get("v.toastMessage");
                        toast.message = response.getError()[0].pageErrors[0].message;
                        toast.header = 'Error';
                        cmp.set("v.toastMessage", toast);
                        
                        if(Array.isArray(cmp.find("statusModal"))) {
                            cmp.find("statusModal")[0].open();
                        }else{
                            cmp.find("statusModal").open();
                        }
                        cmp.set("v.showSpinner",false);
                    }
                });
                $A.enqueueAction(action);
                
                var eventToUpdate = cmp.get("v.beforeUpdateSelectEvent");
                if(eventToUpdate.length == 1) {
                    cmp.set("v.event", eventToUpdate[0]);
                } else {
                    cmp.set("v.event", {});
                }
                cmp.find("modalSlds").close();
            } 
        } else {
            var eventToUpdate = cmp.get("v.beforeUpdateSelectEvent");
            if(eventToUpdate.length == 1) {
                cmp.set("v.event", eventToUpdate[0]);
            } else {
                cmp.set("v.event", {});
            }
            cmp.find("modalSlds").close();
        }
        cmp.set("v.showSpinner",false);
    },
    
    getInstructor : function(cmp, event, helper) {
        var action = cmp.get("c.getContactRecords");
        action.setParams({
            conId : cmp.get("v.selectedEvent")[0].Instructor__c
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            
            if(state == "SUCCESS") {
                if(result) 
                    cmp.set("v.contactSelected", result);
                else 
                    cmp.set("v.contactSelected", []);
            } else {
                var toast = cmp.get("v.toastMessage");
                toast.message = response.getError()[0].pageErrors[0].message;
                toast.header = 'Error';
                cmp.set("v.toastMessage", toast);
                
                if(Array.isArray(cmp.find("statusModal"))) {
                    cmp.find("statusModal")[0].open();
                }else{
                    cmp.find("statusModal").open();
                }
                cmp.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    
    getRoom : function(cmp, event, helper) {
        var action = cmp.get("c.getRoomRecords");
        action.setParams({
            roomId : cmp.get("v.selectedEvent")[0].Room__c
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(state == "SUCCESS") {
                if(result) 
                    cmp.set("v.roomSelected", result);
                else 
                    cmp.set("v.roomSelected", []);
                
            } else {
                
                var toast = cmp.get("v.toastMessage");
                toast.message = response.getError()[0].pageErrors[0].message;
                toast.header = 'Error';
                cmp.set("v.toastMessage", toast);
                
                if(Array.isArray(cmp.find("statusModal"))) {
                    cmp.find("statusModal")[0].open();
                }else{
                    cmp.find("statusModal").open();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getProjTask: function(cmp, event, helper) {
        var action = cmp.get("c.getProjTaskRecords");
        action.setParams({
            projTaskId : cmp.get("v.selectedEvent")[0].Project_Task__c
        }); 
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if(state == "SUCCESS") {
                if(result) 
                    cmp.set("v.projTaskSelected", result);
                else 
                    cmp.set("v.projTaskSelected", []);
                
            } else {
                
                var toast = cmp.get("v.toastMessage");
                toast.message = response.getError()[0].pageErrors[0].message;
                toast.header = 'Error';
                cmp.set("v.toastMessage", toast);
                
                if(Array.isArray(cmp.find("statusModal"))) {
                    cmp.find("statusModal")[0].open();
                }else{
                    cmp.find("statusModal").open();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    convertTime : function(cmp, event, helper, hourString) {
        console.log('::***:::len:::');
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
        console.log(':::***:::Minutes:::',minutes);
        return minutes;
    },
    
    endTimeValue : function(cmp, event, helper) {
        
        if(cmp.get("v.event").Start_Time__c != '' && cmp.get("v.event").Start_Time__c != undefined) {
            var stTime = helper.convertTime(cmp, event, helper, cmp.get("v.event").Start_Time__c);
            var endTimeList = [];
            
            for(var i = 0; i < cmp.get("v.valuesofEventpickList").endTime.length; i++) {
                if(stTime < helper.convertTime(cmp, event, helper, cmp.get("v.valuesofEventpickList").endTime[i]) ||
                   helper.convertTime(cmp, event, helper, cmp.get("v.valuesofEventpickList").endTime[i]) == 0) {
                    endTimeList.push(cmp.get("v.valuesofEventpickList").endTime[i]);
                }
            }
            
            cmp.set("v.endTime", endTimeList);
            
            if(cmp.get("v.event").End_Time__c != '' && cmp.get("v.event").End_Time__c != undefined) { 
                var enTime = helper.convertTime(cmp, event, helper, cmp.get("v.event").End_Time__c);
                if(stTime > enTime) {
                    var selectedEvent = cmp.get("v.event");
                    selectedEvent.End_Time__c = '';
                    cmp.set("v.event", selectedEvent);
                }
            }
        } else {
            cmp.set("v.endTime", cmp.get("v.valuesofEventpickList").endTime);
        }
    },    
    getMinutes : function(cmp,time, isEndTime){
		if(time == undefined){
			return 0;
		}    
        var h = time.split(' ');
        var m = h[0].split(':');
        var t = [];
        if(m[1] != undefined){
            t[1] = m[1];
        } else {
            t[1] = 0;
        }
        if(h[1] == 'AM') {
            if(m[0] == '12' && !isEndTime){
                t[0] = 0;
            } else {
                t[0] = m[0];
            } 
        } else if(h[1] == 'PM'){
            if(m[0] == '12'){
                t[0] = 12;
            } else {
                t[0] = !isEndTime ? parseInt(m[0]) + 12 :  parseInt(m[0]);
            }
        }
        var hrs = parseInt(t[0]) * 60,
            min = !isEndTime ? 60 + parseInt(t[1]) : parseInt(t[1])
        return hrs+min;
	}
})