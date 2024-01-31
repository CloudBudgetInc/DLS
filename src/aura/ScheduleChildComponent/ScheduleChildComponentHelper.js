({
    getAllActiveInstructor : function(component,event,helper,recordType){
        console.log('In get All active Instructors');
        component.set("v.showSpinner",true);
        var action = component.get("c.getActiveAssignments");
        console.log('recordType:::',recordType);
        action.setParams({
            projectId : component.get("v.recordId"),
            recordTypeName : recordType
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == 'SUCCESS') {
                if(recordType == 'Instructor'){
                    component.set('v.instructorList',response.getReturnValue());
                    setTimeout(function(){
                    	if(component.get("v.schOpli").sch.Instructor__c){
	                    	component.find("insSelect").set("v.value",component.get("v.schOpli").sch.Instructor__c);
	                    }
                    },100);
                    
                    component.find('assignInstructor').open(); 
                }else if(recordType == 'Student'){
                    var studentList = response.getReturnValue();
                    console.log('student list:::',studentList);
                    let schedule = component.get("v.schOpli")
                    if(schedule.sch.Instructor__c && studentList.length > 0){
                        this.activateSchedule(component, event, helper);    
                    }else {
                    	var parentRecordType = component.get('v.parentRecordType');
                        let warningMessage = component.get("v.warningMessage")
                        if(!schedule.sch.Instructor__c && (studentList.length == 0 && parentRecordType != 'CD_Projects')){
                            console.log('Both empty');
                            component.set("v.warningMessage",'Please assign Instructor and Student before activating Schedule');
                        }else if(!schedule.sch.Instructor__c){
                            console.log('No instructor:::');
                            component.set("v.warningMessage",'Please assign Instructor before activating the schedule');
                        }else if(studentList.length == 0 && parentRecordType != 'CD_Projects'){
                            console.log('Empty strudent list:::');
                            component.set("v.warningMessage",'Please assign Student before activating Schedule');
                        }
                        if(warningMessage){
                            component.find('warningModal').open();
                        }else {
                            this.activateSchedule(component, event, helper);
                        }
                    }
                }
                component.set("v.showSpinner",false);
            } else {
                console.log("::::ERROR::Schedule Activate::::",response.getError());
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);    
    },
    
    assignSchInstructor : function(component, event, helper){
        
        component.set("v.showSpinner",true);
        var action = component.get("c.assignInstructorRec");
        action.setParams({
            schRecord : component.get("v.schOpli").sch
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == 'SUCCESS') {
                component.set('v.schOpli.sch',response.getReturnValue());
                //console.log('schdule in assign schedule instructor::',JSON.stringify(component.get("v.schOpli")));
                component.find('assignInstructor').close();
                component.set("v.showSpinner",false);
            } else {
                console.log("::::ERROR::Schedule Activate::::",response.getError());
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);    
    },
    
    updateSchRoom : function(component, event, helper){
        component.set("v.showSpinner",true);
        var action = component.get("c.assignRoomRec");
        console.log('update sch room::',component.get("v.selection")[0]);
        component.set("v.schOpli.sch.Room__c",component.get("v.selection")[0].Id)
        action.setParams({
            schRecord : component.get("v.schOpli").sch
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == 'SUCCESS') {
                component.set('v.schOpli.sch',response.getReturnValue());
                console.log('schdule in assign schedule Room::',JSON.stringify(component.get("v.schOpli")));
            } else {
                console.log("::::ERROR::Schedule Room assign::::",response.getError());
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);    
    },
    
    activateSchedule : function(component, event, helper){
        component.set("v.showSpinner",true);
        /*var action = component.get("c.scheduleActivate");
        var schOpli = component.get("v.schOpli");
        
        action.setParams({
            schId : schOpli.sch.Id
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == 'SUCCESS') {
                component.set("v.schOpli", response.getReturnValue());
                component.set("v.showSpinner",false);
            } else {
                component.set("v.showSpinner",false);
            }
        });
        $A.enqueueAction(action);*/
        var compEvent = component.getEvent("deleteEvent");
        compEvent.setParams({"deleteIndex" : component.get("v.index"),
                             "canceltype" : 'Activate'});  
        compEvent.fire();
        
    },
    getConflictInformation : function(cmp){
        cmp.set("v.showSpinner",true);
		var scheduleList = [];
		var scheduleWrapper = [];
		scheduleList.push(cmp.get("v.schOpli").sch);
		var daysOff = [];
		console.log('::::::scheduleList::::',scheduleList);
		var action = cmp.get("c.getScheduleConflicts");
		action.setParams({
			"schWrapperJson" : JSON.stringify(scheduleWrapper),
			"schRecJson" : JSON.stringify(scheduleList),
			"instructorId" : cmp.get("v.schOpli").sch.Instructor__c,
			"parentType" : cmp.get("v.parentType"),
			"parentId" : cmp.get("v.schOpli").sch.Project__c,
			"parentRT" : cmp.get("v.parentRecordType"),
			"daysOffJson" : JSON.stringify(daysOff) 
 		});
 		action.setCallback(this, function(response){
 			var state = response.getState();
 			if(state == 'SUCCESS'){
                cmp.set("v.showSpinner",false);
 				var result = JSON.parse(response.getReturnValue());
 				console.log('::::::result:::conflict::',result);
 				cmp.set("v.scheduleConflictMap",result);
 				cmp.set("v.showConflictInfo",true);
 				cmp.find("conflictModel").open();
            }else {
                console.log(':::::conflict::::error::::',response.getError);
                cmp.set("v.showSpinner",false);
            }
        });
 		$A.enqueueAction(action);
	},
    createZoomMeeting : function(cmp){
        var schId = cmp.get("v.schOpli").sch.Id;
        var taskName = '';
        if(cmp.get("v.schOpli").sch.Project_Task__c){
            taskName = cmp.get("v.schOpli").sch.Project_Task__r.Name;
        }
        var action =  cmp.get("c.createZoomMeetingUrl");
        action.setParams({
            "scheduleId" : schId,
            "projectTaskName" : taskName
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue());
                console.log(':::::::result::::::',JSON.parse(response.getReturnValue()));
                if(result.resultStatus != 'failure'){
                    cmp.set("v.successTitle",'Success');
                    cmp.set("v.successMsg",'Meeting Created Successfully!.');
                    cmp.set("v.showSpinner",false);
                    cmp.set("v.showSuccessModal",true);
                    cmp.find("successModel").open();
                }else {
                    cmp.set("v.successTitle",'Error');
                    cmp.set("v.successMsg",result.error.message);
                    cmp.set("v.showSpinner",false);
                    cmp.set("v.showSuccessModal",true);
                    cmp.find("successModel").open();
                }
            }else {
                console.log('::::::zoom::meeting::error:',response.getError());
                cmp.set("v.successTitle",'Error');
				cmp.set("v.successMsg",response.getError()[0].message);
				cmp.set("v.showSpinner",false);
				cmp.set("v.showSuccessModal",true);
				cmp.find("successModel").open();
            }
        });
        $A.enqueueAction(action);
    }
})