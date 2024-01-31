({
    doinit : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        var eventToUpdate = cmp.get("v.selectedEvent");
        cmp.set("v.contactSelected", []);
        cmp.set("v.roomSelected", []);
        
        if(eventToUpdate.length == 1) {
            cmp.set("v.event", eventToUpdate[0]);
            if(eventToUpdate[0].Instructor__c){ 
                helper.getInstructor(cmp, event, helper);
            }
            if(eventToUpdate[0].Room__c){
                helper.getRoom(cmp, event, helper);
            }
            if(eventToUpdate[0].Project_Task__c){
                helper.getProjTask(cmp, event, helper);
            }
        } else {
            cmp.set("v.event", {});
        }
        helper.endTimeValue(cmp, event, helper);
        var proIds = cmp.get("v.projectIds");
        if(proIds.length > 0) {
            var proIdStr = '';
            for(var i = 0; i < proIds.length; i++) {
                if(proIdStr == '') {
                    proIdStr = proIds[i];
                } else {
                    proIdStr += ', '+proIds[i];
                }
            }
            cmp.set("v.proIdString", proIdStr);
        }
        
        //diable all other attributes except room for Front End User profile
        var profileName = cmp.get("v.currentUserProfile");
        if(profileName == 'Front End User' && cmp.get("v.allowRoomEdit"))
            cmp.set("v.disableOtherValues",true);
        else if(cmp.get("v.allowRoomEdit") || profileName == 'System Administrator')
            cmp.set("v.disableOtherValues",false);
        
        cmp.set("v.showSpinner",false);
    },
    
    saveEvent : function(cmp, event, helper) {
        cmp.set("v.showSpinner",true);
        cmp.set("v.noValidTime", false);
        var allowSave = false;
        var eventRecordsBeforeUpdate = cmp.get("v.beforeUpdateSelectEvent");
        var eventUpdated = cmp.get("v.event");
        
        if(cmp.get("v.contactSelected").length > 0) {
            eventUpdated.Instructor__c = cmp.get("v.contactSelected")[0].Id;
        }
        if(cmp.get("v.roomSelected").length > 0) {
            eventUpdated.Room__c = cmp.get("v.roomSelected")[0].Id;
        }
        if(cmp.get("v.projTaskSelected").length > 0) {
            eventUpdated.Project_Task__c = cmp.get("v.projTaskSelected")[0].Id;
        }
        for(var i = 0; i < eventRecordsBeforeUpdate.length; i++) {
            if(eventRecordsBeforeUpdate[i].Date__c != eventUpdated.Date__c ||
               eventRecordsBeforeUpdate[i].Start_Time__c != eventUpdated.Start_Time__c ||
               eventRecordsBeforeUpdate[i].End_Time__c != eventUpdated.End_Time__c ||
               eventRecordsBeforeUpdate[i].Instructor__c != eventUpdated.Instructor__c ||
               eventRecordsBeforeUpdate[i].Room__c != eventUpdated.Room__c || 
               eventRecordsBeforeUpdate[i].Status__c != eventUpdated.Status__c || 
               eventRecordsBeforeUpdate[i].No_Student_Approval__c != eventUpdated.No_Student_Approval__c) {
                allowSave = true;
                break;
            } 
        }
        cmp.set("v.event", eventUpdated);
        helper.eventSave(cmp, event, helper, allowSave);
    },
    
    instructorLookupSearch : function(cmp, event, helper){
        // Get the search server side action
        const serverSearchAction = cmp.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        cmp.find('instructorLookup').search(serverSearchAction);
    },
    
    roomLookupSearch : function(cmp, event, helper){
        // Get the search server side action
        const serverSearchAction = cmp.get('c.getLookupRecords');
        // Passes the action to the Lookup component by calling the search method
        cmp.find('roomLookup').search(serverSearchAction);
    },
    projectTaskLookupSearch: function(cmp, event, helper){
        var projectTaskCondition = 'AcctSeed__Project__c = \''+cmp.get('v.proIdString')+'\' AND Project_Task_Type__c != \'Material budget\'';
        cmp.set('v.projectTaskCondition', projectTaskCondition);
        const serverSearchAction = cmp.get('c.getGenericLookupRecords');
        cmp.find('projectTaskLookup').search(serverSearchAction);
    },
    
    closeStatusModal : function(cmp, event, helper) {        
        if(Array.isArray(cmp.find("statusModal"))) {
            cmp.find("statusModal")[0].close();
        }else{
            cmp.find("statusModal").close();
        }
        
        if(cmp.get("v.toastMessage.header") == 'Success'){
            /* var reloadEvent = $A.get("e.c:reloadEvent");
            reloadEvent.fire();*/
            cmp.set("v.selectedEvent",[]);
            //cmp.set("v.event", {});
        }
    },
    
    closeSldsModal : function(cmp, event, helper) {
        var eventToUpdate = cmp.get("v.beforeUpdateSelectEvent");
        cmp.set("v.event", {});
        cmp.set("v.contactSelected", []);
        cmp.set("v.roomSelected", []);
        cmp.set("v.selectedEvent", []);
        cmp.find("modalSlds").close();
    }, 
    setEventTimeAndDuration: function(cmp, event, helper){
        
        var eventObj = cmp.get('v.event'),
              startTimeMinutes, endTimeMinutes;
        var isEndTime = eventObj.endTime == '12:00 AM';
		
		if(eventObj.Start_Time__c) {			
            startTimeMinutes = helper.getMinutes(cmp,eventObj.Start_Time__c, isEndTime);
		}
		
		if(eventObj.End_Time__c){
			endTimeMinutes = helper.getMinutes(cmp,eventObj.End_Time__c, isEndTime);
		}
		   
		if(startTimeMinutes && endTimeMinutes){			           
			var totalHrsPerSession = (endTimeMinutes - startTimeMinutes) / 60;
			eventObj.Duration__c = totalHrsPerSession;			
        }else{
            eventObj.Duration__c = 0;
        }
        
        if(event.getSource().get("v.label") == 'Start Time'){
        	helper.endTimeValue(cmp, event, helper);
        }
        cmp.set("v.event",eventObj);
    }
})