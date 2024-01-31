({
    getToDoItemsInfo : function(cmp,event,helper) {
        cmp.set("v.showSpinner",true);
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getToDoItems');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                console.log('response:::',response);
                cmp.set("v.showSpinner",false);
                var result = JSON.parse(response);
                cmp.set("v.toDoItemsList",result);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,'Error', 'Error found', errors[0].message, null);
            }),
            false, 
            false,
            false
        );
    },
    navigateMyProfilePage : function(cmp,event,helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/my-profile"
        });
        urlEvent.fire();
    },
    /* update status toDo Item Task Record as Completed*/
    updateToDoItemStatus : function(cmp,event,helper,toDOId) {
        cmp.set("v.showSpinner",true);
        var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.updateToDoItem');
        server.callServer(
            action,
            {'toDOId':toDOId},
            false,
            $A.getCallback(function(response) {
                cmp.set("v.showSpinner",false);
                console.log('response:::',response);
                var result = JSON.parse(response);
                cmp.set("v.toDoItemsList",result);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,'Error', 'Error found', errors[0].message, null);
            }),
            false, 
            false,
            false
        );
    },
    getDLIProjectInfo : function(cmp, event){
        console.log('enter getDLIProjectInfo');
    	var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getSummaryDLIAttendanceInfo');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                console.log(':::::dli::response::',response);
                var result = JSON.parse(response);
                console.log(':::::DLI::attendance:result:::',result);
                cmp.set("v.dliSummaryDetail",result);
                //cmp.set("v.showSpinner",false);
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,'Error', 'Error found', errors[0].message, null);
            }),
            false, 
            false,
            false
        );
	},
    getAssessmentReports: function(cmp, event){
        
    	var self = this;
        const server = cmp.find('server');
        const action = cmp.get('c.getPendingAssessmentReportCount');
        server.callServer(
            action,
            {},
            false,
            $A.getCallback(function(response) {
                
                cmp.set("v.pendingAssessmentReportCount",response);                
            }),
            $A.getCallback(function(errors) { 
                console.log('Error n comp');
                cmp.set("v.showSpinner",false);
                self.showToast(cmp,event,'Error', 'Error found', errors[0].message, null);
            }),
            false, 
            false,
            false
        );
	},
    showToast: function(component, event, type, title, message, mode) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            
            message: message,
            title: title,
            type: type
        });
        toastEvent.fire();
    }
})