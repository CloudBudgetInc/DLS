({
    selectedEvents : function(cmp, event, helper, action) {
        
        var selectEvent = [];
        if(action == "updateSelectedEvent") {
            selectEvent = cmp.find("eventsTable").get("v.selectedRows");
        } else if(action == "updateEventBtn") {
            var clickedRow = event.getParam('row');
            selectEvent.push(clickedRow);
        }
        cmp.set("v.eventSelected",selectEvent);
        if(cmp.get("v.eventSelected").length == 0 && action == "updateSelectedEvent") {
            
            var toast = cmp.get("v.toastMessage");
            toast.message = 'Please Select atleast one record';
            toast.header = 'Message';
            cmp.set("v.toastMessage", toast);
            
            if(Array.isArray(cmp.find("statusMsgModal"))) {
                cmp.find("statusMsgModal")[0].open();
            }else{
                cmp.find("statusMsgModal").open();
            }            
        } else {
            console.log(':::***:::ELSE UPDATE:::');
            cmp.set("v.copyOfEventSelected", JSON.parse(JSON.stringify(cmp.get("v.eventSelected"))));
            cmp.find("eventUpdate").find("modalSlds").open();
        }
        cmp.set("v.showSpinner",false);
    },
    
    initializeTable : function(cmp, event, helper){
        
        cmp.set("v.showSpinner",false);
        cmp.find("eventsTable").initialize(
            {"order" : [1,"asc"]}
        );
    },
    
    eventRecords : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true); 
        var action = cmp.get("c.getEventRecords");
        action.setParams({
            projId : cmp.get("v.proRecordIds"),
            stDate : cmp.get("v.previousWeekStDate"),
            enDate : cmp.get("v.nextWeekEnDate"),
            eventStatus : cmp.get("v.statusSelected"),
            selectedProTaskId : cmp.get("v.selectedProTask")
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                cmp.set("v.eventList", result.eveList);
                cmp.set('v.eventsIdsHasLP',result.eventsIdsHasLP);
                cmp.find("eventsTable").rerenderRows();
            } else {                
                var toast = cmp.get("v.toastMessage");
                toast.message = response.getError()[0].pageErrors[0].message;
                toast.header = 'Error';
                cmp.set("v.toastMessage", toast);
                
                if(Array.isArray(cmp.find("statusMsgModal"))) {
                    cmp.find("statusMsgModal")[0].open();
                }else{
                    cmp.find("statusMsgModal").open();
                }
                
            }
        });
        $A.enqueueAction(action);
        cmp.set("v.showSpinner",false);
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
    validateInput : function(cmp){
        var eventRec = cmp.get("v.eventObj");
        
        var inputCmp = cmp.find("input");            
        
        var isValid = true;
        
        for(var i = 0; i < inputCmp.length;i++){
            
            if(!inputCmp[i].checkValidity()){
                isValid = false;
            }
            inputCmp[i].showHelpMessageIfInvalid();
        }
        
        var insCmp = cmp.find("instructorLookup");
        
        if(eventRec.instructor.length == 0){
            isValid = false;
            $A.util.addClass(insCmp, 'slds-has-error');
        }else {
            $A.util.removeClass(insCmp, 'slds-has-error');
        }
        
        var projTaskCmp = cmp.find("projectTaskLookup");
        if(eventRec.projTask.length == 0 && cmp.get('v.isProjTaskRequired')){
            $A.util.addClass(projTaskCmp, 'slds-has-error');
             isValid = false;
        }else {
            $A.util.removeClass(projTaskCmp, 'slds-has-error');
        }
        
        if(isValid){
            let recTypeName = cmp.get("v.parenRecordTypeName");

            if(recTypeName == 'Testing_Projects'){
                cmp.set("v.showCreateEventModal",false);
                cmp.set("v.testingProOralDateVal",true);
                
                if(Array.isArray(cmp.find("testingProOralDateVal"))) {
                    cmp.find("testingProOralDateVal")[0].open();
                }else{
                    cmp.find("testingProOralDateVal").open();
                }
            }else{
                this.checkInstructorAvailable(cmp);
            }
           
        }
    },
    checkInstructorAvailable: function(cmp){
        cmp.set("v.showSpinner",true);
        var eventObj = cmp.get("v.eventObj"),
            instructorId, parentId;
        
        if(eventObj.instructor.length > 0){
            instructorId = eventObj.instructor[0].Id;
        }
        
        if(cmp.get("v.sObjectName") == 'AcctSeed__Project__c'){
        	parentId = cmp.get("v.proRecordIds").length > 0 ? cmp.get("v.proRecordIds")[0] : null;    
        }else if(cmp.get("v.sObjectName") == 'Opportunity'){
            parentId = cmp.get("v.proRecordIds").length > 0 ? cmp.get("v.proRecordIds")[0] : null;    
        }
        
        var action = cmp.get("c.checkContactAssignmentExist");
        action.setParams({
            contactId: instructorId,
            parentId: parentId
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state == "SUCCESS") {
                cmp.set("v.showSpinner",false);
                
                if(response.getReturnValue()){
                    cmp.set('v.isCreateCA', false);
                    this.createEventRecords(cmp);
                    cmp.set("v.showCreateEventModal",false);
                }else{
                    cmp.set('v.isCreateCA', true);
                    var ca = cmp.get('v.caRecord'),
                        eventObj = cmp.get("v.eventObj");
                    
                    ca.Project_Task__c = eventObj.projTask && eventObj.projTask.length > 0 ? eventObj.projTask[0].Id : null;
                    ca.Candidate_Name__c = instructorId;
                    cmp.set('v.caRecord', ca);
                    cmp.set('v.showCostRateModal', true);
                }
            } else {         
                cmp.set("v.showSpinner",false);
                var toast = cmp.get("v.toastMessage");
                toast.message = response.getError()[0].message;
                toast.header = 'Error';
                cmp.set("v.toastMessage", toast);
                
                if(Array.isArray(cmp.find("statusMsgModal"))) {
                    cmp.find("statusMsgModal")[0].open();
                }else{
                    cmp.find("statusMsgModal").open();
                }
            }
        });
        $A.enqueueAction(action);
    },
    createEventRecords : function(cmp){
        cmp.set("v.showSpinner",true);
        var obj = {};
        var eventObj = cmp.get("v.eventObj");
        
        obj.Date__c = eventObj.dateVal;
        obj.Start_Time__c = eventObj.startTime;
        obj.End_Time__c = eventObj.endTime;
        obj.Status__c = eventObj.status;
        obj.Duration__c = eventObj.duration;
        
        var instructorId;
        if(eventObj.instructor.length > 0){
            instructorId = eventObj.instructor[0].Id;
        }
        
        var roomId;
        if(eventObj.room.length > 0){
            roomId = eventObj.room[0].Id;
        }
        
        var projTaskId;
        if(eventObj.projTask.length > 0){
            obj.Project_Task__c = eventObj.projTask[0].Id;
        }
        
        obj.Instructor__c = instructorId;
        obj.Room__c = roomId;
        
        
        if(cmp.get("v.sObjectName") == 'AcctSeed__Project__c'){
        	obj.Project__c = cmp.get("v.proRecordIds").length > 0 ? cmp.get("v.proRecordIds")[0] : null;    
        }else if(cmp.get("v.sObjectName") == 'Opportunity'){
            obj.Opportunity__c = cmp.get("v.proRecordIds").length > 0 ? cmp.get("v.proRecordIds")[0] : null;    
        }
        
        var eventArrary = [];
        eventArrary.push(obj);
        
        var action = cmp.get("c.createEventsForTestingProject");
        action.setParams({
            eventJSON : JSON.stringify(eventArrary),
            caRec : JSON.stringify(cmp.get('v.caRecord')),
            isCreateCA: cmp.get('v.isCreateCA'),
            isUpdateTestingProDates : cmp.get("v.isUpdateTestingProDates")
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state == "SUCCESS") {
                cmp.set("v.showSpinner",false);
				                
                var toast = cmp.get("v.toastMessage");
                toast.message = 'Event created successfully';
                toast.header = 'Success';
                cmp.set("v.toastMessage", toast);
                
                if(Array.isArray(cmp.find("statusMsgModal"))) {
                    cmp.find("statusMsgModal")[0].open();
                }else{
                    cmp.find("statusMsgModal").open();
                }
                
                this.eventRecords(cmp);
            } else {         
                cmp.set("v.showSpinner",false);
                var toast = cmp.get("v.toastMessage");
                toast.message = response.getError()[0].message;
                toast.header = 'Error';
                cmp.set("v.toastMessage", toast);
                
                if(Array.isArray(cmp.find("statusMsgModal"))) {
                    cmp.find("statusMsgModal")[0].open();
                }else{
                    cmp.find("statusMsgModal").open();
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    endTimeValue : function(cmp, event, helper) {
        var startTime = cmp.get("v.eventObj").startTime,
            endTimeList = cmp.get("v.endTimeList");
        
        if(startTime != '' && startTime != undefined) {
            var stTime = helper.convertTime(cmp, startTime);
            var filteredEndTimeList = [];
            
            for(var i = 0; i < endTimeList.length; i++) {
                
                if(stTime < helper.convertTime(cmp, endTimeList[i].value) ||
                   helper.convertTime(cmp, endTimeList[i].value) == 0) {
                    filteredEndTimeList.push(endTimeList[i]);
                }
            }
            
            cmp.set("v.filteredEndTimeList", filteredEndTimeList);
            
        } else {
            cmp.set("v.filteredEndTimeList", []);
        }
    },
    openLessonPlanModal: function(cmp, event){
       cmp.set("v.selectedRecord", event);
       cmp.set("v.showLessonPlan", true);     
       cmp.find("lessonPlanModal").open();
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