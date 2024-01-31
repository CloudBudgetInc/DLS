({
    doInit: function(component, event, helper){
        var currentUsrProfileName = component.get('v.currentUsrProfileName'),
			onlineRoomId = component.get('v.onlineRoomId'),            
            selection = [];
        
        if(currentUsrProfileName == 'LTS' && component.get('v.isDLSOnlineProject')){
            
            selection.push({Id:onlineRoomId, Name:"Zoom - Online"});
        }else{
            component.set("v.roomCondition", '');
        }
        
        component.set('v.selection', selection);
    },
    openRecord : function(component, event, helper) {
        
        component.set("v.showSpinner",true);
        var recId = event.currentTarget.dataset.value;
        console.log(':::',recId);
        var sObjectEvent = $A.get("e.force:navigateToSObject");
        sObjectEvent.setParams({
            "recordId": recId,
            "slideDevName": 'related'
        })
        //sObjectEvent.fire();
        window.open('/'+recId,'_blank');
        component.set("v.showSpinner",false);
        
    },
    activateSchedule : function(component, event, helper) {
        helper.getAllActiveInstructor(component, event, helper,'Student');
    },
    openRoomModal : function(component, event, helper){
        component.find("modalSlds").open();    
    },
    updateRoom : function(component, event, helper){
        helper.updateSchRoom(component,event,helper);
        component.find("modalSlds").close();   
    },
    closeRoomModal : function(component, event, helper){
        component.find("modalSlds").close();   
    },
    assignInstructor : function(component, event, helper){
        helper.getAllActiveInstructor(component, event, helper,'Instructor');
    },
    closeAssignIns : function(component, event, helper){
        component.find('assignInstructor').close();
    },
    deleteScheduleRec : function(component, event, helper){
        var compEvent = component.getEvent("deleteEvent");
        compEvent.setParams({"deleteIndex" : component.get("v.index"),
                             "canceltype" : 'delete'});  
        compEvent.fire();
        component.find("deleteModal").close();
    },
    openCancelModal : function(component,event,helper){
        component.find("cancelModal").open();
    },
    updateCancelSchedule : function(component, event, helper){
        var cancelCmp = component.find("cancelInput");
        console.log('cancel component::',cancelCmp);        
        if (!cancelCmp.get("v.value")){
            cancelCmp.set("v.errors", [{message:"Please enter the required field"}]);
        }else{
            cancelCmp.set("v.errors", null);
            let scheduleRec = component.get("v.schOpli");
            scheduleRec.sch.Status__c = 'Canceled';
            component.set('v.schOpli',scheduleRec);
            var compEvent = component.getEvent("deleteEvent");
            compEvent.setParams({"deleteIndex" : component.get("v.index"),
                                 "canceltype" : 'cancel'});  
            compEvent.fire();
            component.find("cancelModal").close();
        }
    },
    closeCancelModal : function(component, event, helper){
        component.find("cancelModal").close();
    },
    lookupSearch : function(component, event, helper) {
        const serverSearchAction = component.get('c.getLookupRecords');
        component.find('lookup').search(serverSearchAction);
    },
    openDeleteModal : function(component, event, helper){
        component.set("v.deleteIndex",event.getSource().get("v.name"));
        component.find("deleteModal").open();    
    },
    closedeleteModal : function(component, event, helper){
        component.find("deleteModal").close();
    },
    saveInstructor : function(component, event, helper){
    	var schOpli = component.get("v.schOpli");
    	schOpli.sch.Instructor__c = component.find("insSelect").get("v.value");
    	component.set("v.schOpli",schOpli);
    	helper.getConflictInformation(component);
    },
    closeWarning : function(component, event, helper){
        component.find('warningModal').close();
    },
    editIconclick : function(cmp, event, helper){
    	var compEvent = cmp.getEvent("deleteEvent");
        compEvent.setParams({"deleteIndex" : cmp.get("v.index"),
                             "canceltype" : 'edit'});  
        compEvent.fire();
    },
    handleMenuSelect : function(cmp, event, helper){
    	console.log(':::::::selected::menu:::',event.getParam('value'));
    	var type = event.getParam('value');
    	var compEvent = cmp.getEvent("deleteEvent");
        compEvent.setParams({"deleteIndex" : cmp.get("v.index"),
                             "canceltype" : type});  
        compEvent.fire();
    	
    },
    conflictYesClick : function(cmp, event, helper){
    	cmp.set("v.showConflictInfo",false);
    	cmp.find("conflictModel").close();
		helper.assignSchInstructor(cmp, event, helper);	
    },
    closeConlfictModel : function(cmp, event, helper){
		cmp.find("conflictModel").close();
		cmp.set("v.showConflictInfo",false);
    },
    redirectToRoomPage : function(cmp, event, helper){
        if(cmp.get('v.currentUsrProfileName') != 'LTS'){
            var schId = cmp.get("v.schOpli").sch.Id;
            var parentId = cmp.get("v.recordId");
            var schStatus = cmp.get("v.schOpli").sch.Status__c;
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
                "url": '/apex/Room_Search?scheduleId='+schId+'&returnId='+parentId+'&status='+schStatus
            });
            urlEvent.fire();
        }
    },
    manageEvents : function(cmp, event, helper){
    	var schId = cmp.get("v.schOpli").sch.Id;
    	var parentId = cmp.get("v.recordId");
    	var parentType = '';
    	if(cmp.get("v.parentType") == 'Opportunity'){
    		parentType = 'OPPORTUNITY';
    	}else {
    		parentType = 'PROJECT';
    	}
    	var urlEvent = $A.get("e.force:navigateToURL");
	    urlEvent.setParams({
	        "url": '/apex/eventManagement_hybrid?schId=' + schId +'&parentId=' + parentId + '&type=' + parentType
	    });
	    urlEvent.fire();
    },
    redirectToContact : function(cmp, event, helper){
    	var conId = cmp.get("v.schOpli").sch.Instructor__c;
	    window.open('/'+conId,'_target');
    },
    createMeeting : function(cmp, event, helper){
        cmp.set("v.showSpinner",true);
        helper.createZoomMeeting(cmp);
    },
    closeSuccessModel : function(cmp, event, helper){
        cmp.find("successModel").close();
        cmp.set("v.showSuccessModal",false);
        if(cmp.get("v.successTitle") == 'Success'){
            var compEvent = cmp.getEvent("deleteEvent");
            compEvent.setParams({"canceltype" : 'Reload'});  
            compEvent.fire();
        }
    },
    redirectToRoom : function(cmp, event, helper){
        window.open('/'+cmp.get("v.schOpli").sch.Room__c,'_target');
    },
    redirectToZoom : function(cmp, event, helper){
        window.open('/'+cmp.get("v.schOpli").sch.Meeting_URL__c,'_target');
    },
    openCompleteModal : function(cmp,event,helper){
        cmp.find("completeModal").open();
    },
    updateCompleteSchedule :  function(cmp, event, helper){
        var completeCmp = cmp.find("completionInput");
        console.log('complete component::',completeCmp);        
        if (!completeCmp.get("v.value")){
            completeCmp.set("v.errors", [{message:"Please enter the completion date"}]);
        }else{
            completeCmp.set("v.errors", null);
            let scheduleRec = cmp.get("v.schOpli");
            scheduleRec.sch.End_Date__c = cmp.get("v.completionDate");
            scheduleRec.sch.Status__c = 'Completed';
            cmp.set('v.schOpli',scheduleRec);
            var compEvent = cmp.getEvent("deleteEvent");
            compEvent.setParams({"deleteIndex" : cmp.get("v.index"),
                                 "canceltype" : 'complete'});  
            compEvent.fire();
            cmp.find("completeModal").close();
        }
    },
    closeCompleteModal : function(cmp,event,helper){
        cmp.find("completeModal").close();
    }
})